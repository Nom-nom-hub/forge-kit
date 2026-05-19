"""Manifest system for tracking installed integration files."""

import json
from pathlib import Path


class IntegrationManifest:
    """Tracks files installed by an integration for clean uninstall."""

    def __init__(self, target_dir: str, integration_key: str):
        self.path = Path(target_dir) / ".forge" / f"{integration_key}.manifest.json"
        self.integration_key = integration_key

    def add_files(self, files: list[str]) -> None:
        """Record installed files."""
        manifest = self._read()
        manifest.setdefault("files", [])
        for f in files:
            if f not in manifest["files"]:
                manifest["files"].append(f)
        self._write(manifest)

    def remove_files(self) -> list[str]:
        """Get list of installed files and clear manifest."""
        manifest = self._read()
        files = manifest.get("files", [])
        self._write({"files": []})
        return files

    def _read(self) -> dict:
        if self.path.exists():
            try:
                return json.loads(self.path.read_text())
            except Exception:
                pass
        return {"files": []}

    def _write(self, data: dict) -> None:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text(json.dumps(data, indent=2))
