"""Continue integration.

Writes a JSON config file to ``.continue/config.json`` that tells
Continue about the FORGE slash commands.
"""

import json
from pathlib import Path
from typing import Any

from .base import IntegrationBase
from .manifest import IntegrationManifest


class ContinueIntegration(IntegrationBase):
    """Continue integration.

    Continue uses a ``.continue/config.json`` configuration file.
    This integration updates it to include a custom command referencing
    the FORGE command templates in ``.forge/templates/commands/``.
    """

    key = "continue"
    context_file = ".continue/config.json"

    def setup(self, target_dir: str, options: dict[str, Any] | None = None) -> None:
        target = Path(target_dir)
        config_dir = target / ".continue"
        config_dir.mkdir(parents=True, exist_ok=True)
        config_path = config_dir / "config.json"

        commands_dir = target / ".forge" / "templates" / "commands"
        commands = []
        if commands_dir.is_dir():
            for f in sorted(commands_dir.glob("*.md")):
                commands.append(f"/forge.{f.stem}")

        forge_block = {
            "title": "Forge Kit",
            "description": "FORGE methodology commands",
            "commands": commands,
            "note": "Full command templates in .forge/templates/commands/",
        }

        if config_path.exists():
            try:
                existing = json.loads(config_path.read_text())
            except Exception:
                existing = {}
            existing.setdefault("customCommands", [])
            # Replace existing forge block if present
            existing["customCommands"] = [
                b for b in existing.get("customCommands", [])
                if b.get("title") != "Forge Kit"
            ]
            existing["customCommands"].append(forge_block)
            config_path.write_text(json.dumps(existing, indent=2))
        else:
            config = {
                "customCommands": [forge_block],
            }
            config_path.write_text(json.dumps(config, indent=2))

        manifest = IntegrationManifest(target_dir, self.key)
        manifest.add_files([str(config_path)])

    def teardown(self, target_dir: str) -> None:
        manifest = IntegrationManifest(target_dir, self.key)
        for f in manifest.remove_files():
            Path(f).unlink(missing_ok=True)
