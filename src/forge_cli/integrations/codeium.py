"""Codeium integration.

Writes a rules file to ``.codeium/rules/forge-rules.md`` that tells
Codeium (and Windsurf) about the FORGE slash commands.
"""

from .base import MarkdownIntegration


class CodeiumIntegration(MarkdownIntegration):
    key = "codeium"
    context_file = ".codeium/rules/forge-rules.md"
