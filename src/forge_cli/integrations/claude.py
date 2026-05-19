"""Claude Code integration.

Writes a context file to ``CLAUDE.md`` that tells Claude Code
about the FORGE slash commands available in ``.forge/templates/commands/``.
"""

from .base import MarkdownIntegration


class ClaudeIntegration(MarkdownIntegration):
    key = "claude"
    context_file = "CLAUDE.md"
