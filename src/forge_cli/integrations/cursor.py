"""Cursor integration.

Writes a rules file to ``.cursor/rules/forge-rules.md`` with YAML frontmatter
that Cursor uses to discover slash commands.
"""

from .base import ContextFileIntegration


class CursorIntegration(ContextFileIntegration):
    key = "cursor"
    context_file = ".cursor/rules/forge-rules.md"

    def _format_context(self, commands):
        parts = [
            "---",
            "description: Forge Kit slash commands for the FORGE methodology",
            "globs: ",
            "---",
            "",
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
