"""Interactive prompts for `forge init`.

Provides arrow-key-selectable menus for picking the AI agent integration
(model) and script type when running interactively.
"""

from __future__ import annotations

import sys
from collections.abc import Sequence

import questionary

from .integrations import list_integrations

_SCRIPT_TYPES: Sequence[dict[str, str]] = [
    {"name": "🐚 Bash", "value": "bash", "description": "Unix shell scripts (Linux, macOS)"},
    {"name": "🪟 PowerShell", "value": "powershell", "description": "PowerShell scripts (Windows, cross-platform)"},
]

# User-friendly display names for integrations
_INTEGRATION_LABELS: dict[str, str] = {
    "aws-bedrock": "☁️  AWS Bedrock",
    "azure-openai": "☁️  Azure OpenAI",
    "anthropic": "🧠 Anthropic (Claude)",
    "claude": "🧠 Claude Code",
    "cline": "📝 Cline",
    "codeium": "⚡ Codeium",
    "continue": "🔄 Continue",
    "copilot": "🚀 GitHub Copilot",
    "cursor": "🖱️  Cursor",
    "gemini": "🌟 Gemini",
    "openai": "🤖 OpenAI",
    "tabnine": "🔮 Tabnine",
    "windsurf": "🏄 Windsurf",
}


def _is_tty() -> bool:
    """Check if we're running in an interactive terminal."""
    return sys.stdin.isatty()


def pick_integration() -> str | None:
    """Show an interactive picker for the AI agent integration.

    Returns the integration key, or *None* if the user aborts.
    """
    if not _is_tty():
        return None

    integrations = list_integrations()
    choices = []
    for key in sorted(integrations):
        label = _INTEGRATION_LABELS.get(key, key)
        choices.append(
            questionary.Choice(
                title=label,
                value=key,
            )
        )

    result = questionary.select(
        "Which AI coding agent are you using?",
        choices=choices,
        default="copilot",
        qmark="🔥",
        instruction="(Use ↑↓ arrows, press Enter)",
    ).ask()

    return result


def pick_script_type() -> str | None:
    """Show an interactive picker for the script type (bash / powershell).

    Returns the script type key, or *None* if the user aborts.
    """
    if not _is_tty():
        return None

    choices = [
        questionary.Choice(title=st["name"], value=st["value"])
        for st in _SCRIPT_TYPES
    ]

    result = questionary.select(
        "Which scripting environment?",
        choices=choices,
        default="bash",
        qmark="🔥",
        instruction="(Use ↑↓ arrows, press Enter)",
    ).ask()

    return result
