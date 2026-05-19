"""AWS Bedrock integration.

Writes a context file to ``.bedrock/instructions.md`` that tells
AWS Bedrock agents about the FORGE slash commands.
"""

from .base import MarkdownIntegration


class AwsBedrockIntegration(MarkdownIntegration):
    key = "aws-bedrock"
    context_file = ".bedrock/instructions.md"
