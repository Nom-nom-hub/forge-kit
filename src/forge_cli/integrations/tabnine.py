"""Tabnine integration.

Writes a context file to ``.tabnine/instructions.md`` that tells
Tabnine about the FORGE slash commands.
"""

from .base import MarkdownIntegration


class TabnineIntegration(MarkdownIntegration):
    key = "tabnine"
    context_file = ".tabnine/instructions.md"
