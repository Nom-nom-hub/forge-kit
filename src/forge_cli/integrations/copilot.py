"""GitHub Copilot integration.

Writes a context file to ``.github/copilot-instructions.md``
that tells Copilot about the FORGE slash commands available
in ``.forge/templates/commands/``.
"""

from .base import MarkdownIntegration


class CopilotIntegration(MarkdownIntegration):
    key = "copilot"
    context_file = ".github/copilot-instructions.md"
