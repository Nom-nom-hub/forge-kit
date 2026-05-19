"""OpenAI integration.

Writes a context file to ``.openai/instructions.md`` that tells
ChatGPT / OpenAI-powered agents about the FORGE slash commands.
"""

from .base import MarkdownIntegration


class OpenAIIntegration(MarkdownIntegration):
    key = "openai"
    context_file = ".openai/instructions.md"
