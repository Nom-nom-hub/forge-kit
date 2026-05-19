"""Anthropic integration.

Alias for Claude — writes a context file to ``CLAUDE.md``.
"""

from .claude import ClaudeIntegration


class AnthropicIntegration(ClaudeIntegration):
    key = "anthropic"
