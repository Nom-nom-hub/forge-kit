"""Azure OpenAI integration.

Writes a context file to ``.azure-openai/instructions.md`` that tells
Azure OpenAI-powered agents about the FORGE slash commands.
"""

from .base import MarkdownIntegration


class AzureOpenAIIntegration(MarkdownIntegration):
    key = "azure-openai"
    context_file = ".azure-openai/instructions.md"
