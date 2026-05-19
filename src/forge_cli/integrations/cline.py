"""Cline integration.

Writes a rules file to ``.cline/rules/forge-rules.md`` (with markdown
frontmatter) and appends a reference to ``.clinerules``.
"""

from pathlib import Path
from typing import Any

from .base import ContextFileIntegration
from .manifest import IntegrationManifest


class ClineIntegration(ContextFileIntegration):
    """Cline integration.

    Cline reads rules from ``.clinerules`` and also supports a
    ``.cline/rules/`` directory for organised rule files.
    """

    key = "cline"
    context_file = ".cline/rules/forge-rules.md"

    def _format_context(self, commands):
        parts = [
            "# Forge Kit Slash Commands",
            "",
            "This project uses the FORGE methodology. The following slash commands are available.",
            "Full command templates are stored in `.forge/templates/commands/`.",
            "",
        ]
        for cmd in commands:
            parts.append(f"- `/forge.{cmd['name']}` — {cmd['description']}")
        parts.append("")
        return "\n".join(parts)

    def setup(self, target_dir: str, options: dict[str, Any] | None = None) -> None:
        # Write the rules file via the base class
        super().setup(target_dir, options)

        # Also append a reference to .clinerules
        target = Path(target_dir)
        clinerules_path = target / ".clinerules"
        reference = "For FORGE methodology slash commands, see `.cline/rules/forge-rules.md`."
        if clinerules_path.exists():
            existing = clinerules_path.read_text()
            if reference not in existing:
                clinerules_path.write_text(existing.rstrip() + "\n\n" + reference + "\n")
        else:
            clinerules_path.write_text("# Cline Rules\n\n" + reference + "\n")

        manifest = IntegrationManifest(target_dir, self.key)
        manifest.add_files([str(clinerules_path)])
