"""Gemini Code Assist integration.

Writes a context file to ``.gemini/rules/forge-rules.md`` that tells
Gemini Code Assist about the FORGE slash commands.
"""

from .base import MarkdownIntegration


class GeminiIntegration(MarkdownIntegration):
    key = "gemini"
    context_file = ".gemini/rules/forge-rules.md"
