"""Base classes for AI coding agent integrations."""

from abc import ABC, abstractmethod
from pathlib import Path
from typing import Any

from .manifest import IntegrationManifest


class IntegrationOption:
    """An option flag for an integration."""

    def __init__(
        self,
        name: str,
        is_flag: bool = False,
        default: Any = None,
        help_text: str = "",
    ):
        self.name = name
        self.is_flag = is_flag
        self.default = default
        self.help_text = help_text


class IntegrationBase(ABC):
    """Base class for all integrations."""

    key: str = ""
    config: dict[str, Any] = {}
    registrar_config: dict[str, Any] = {}
    context_file: str | None = None

    @abstractmethod
    def setup(self, target_dir: str, options: dict[str, Any] | None = None) -> None:
        """Install integration files into the target directory."""
        ...

    @abstractmethod
    def teardown(self, target_dir: str) -> None:
        """Remove integration files from the target directory."""
        ...

    @classmethod
    def options(cls) -> list[IntegrationOption]:
        """Return integration-specific CLI options."""
        return []


class ContextFileIntegration(IntegrationBase):
    """For agents that use a single markdown context/rules file.

    Subclasses define:
      * ``key`` — integration key (e.g. ``"copilot"``)
      * ``context_file`` — path relative to project root
      * ``_format_context(commands)`` — returns the context file content
    """

    @staticmethod
    def _extract_description(content: str, filename: str) -> str:
        """Extract the description from a command file's YAML frontmatter.

        Command files use YAML frontmatter delimited by ``---`` with a
        ``description:`` field. Falls back to the first non-frontmatter line.
        """
        fallback = f"See `.forge/templates/commands/{filename}`"
        lines = content.split("\n")
        if not lines or lines[0].strip() != "---":
            return fallback

        # Find closing ---
        end = None
        for i in range(1, len(lines)):
            if lines[i].strip() == "---":
                end = i
                break
        if end is None:
            return fallback

        frontmatter_lines = lines[1:end]
        for line in frontmatter_lines:
            if line.strip().startswith("description:"):
                val = line.split(":", 1)[1].strip().strip('"').strip("'")
                if val:
                    return val
        return fallback

    def _available_commands(self, target_dir: str) -> list[dict[str, str]]:
        """Read available commands from .forge/templates/commands/."""
        commands_dir = Path(target_dir) / ".forge" / "templates" / "commands"
        if not commands_dir.is_dir():
            return []
        commands = []
        for f in sorted(commands_dir.glob("*.md")):
            try:
                text = f.read_text()
            except Exception:
                continue
            stem = f.stem
            desc = self._extract_description(text, f.name)
            commands.append({"name": stem, "file": f.name, "description": desc})
        return commands

    @abstractmethod
    def _format_context(self, commands: list[dict[str, str]]) -> str:
        """Format the context file content for this agent."""
        ...

    def setup(self, target_dir: str, options: dict[str, Any] | None = None) -> None:
        commands = self._available_commands(target_dir)
        target = Path(target_dir)
        context_path = target / self.context_file  # type: ignore[operator]
        context_path.parent.mkdir(parents=True, exist_ok=True)
        content = self._format_context(commands)
        context_path.write_text(content)

        manifest = IntegrationManifest(target_dir, self.key)
        manifest.add_files([str(context_path)])

    def teardown(self, target_dir: str) -> None:
        manifest = IntegrationManifest(target_dir, self.key)
        for f in manifest.remove_files():
            Path(f).unlink(missing_ok=True)


class MarkdownIntegration(ContextFileIntegration):
    """For agents that use a standard Markdown context file with a simple command list."""

    def _format_context(self, commands: list[dict[str, str]]) -> str:
        lines = [
            "# Forge Kit Slash Commands",
            "",
            "This project uses the FORGE methodology. The following slash commands are available.",
            "Full command templates are stored in `.forge/templates/commands/`.",
            "",
        ]
        for cmd in commands:
            lines.append(f"- `/forge.{cmd['name']}` — {cmd['description']}")
        lines.append("")
        return "\n".join(lines)


class TomlIntegration(IntegrationBase):
    """For agents that use TOML command files."""

    def setup(self, target_dir: str, options: dict[str, Any] | None = None) -> None:
        pass

    def teardown(self, target_dir: str) -> None:
        pass


class SkillsIntegration(IntegrationBase):
    """For agents that use skill directories."""

    def setup(self, target_dir: str, options: dict[str, Any] | None = None) -> None:
        pass

    def teardown(self, target_dir: str) -> None:
        pass


class YamlIntegration(IntegrationBase):
    """For agents that use YAML recipe files."""

    def setup(self, target_dir: str, options: dict[str, Any] | None = None) -> None:
        pass

    def teardown(self, target_dir: str) -> None:
        pass
