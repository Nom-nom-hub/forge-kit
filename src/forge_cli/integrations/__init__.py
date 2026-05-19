"""Integration registry for Forge CLI.

Each AI coding agent is registered as an integration that defines
how command templates are installed and context files are managed.
"""

import typer

from .base import IntegrationBase

INTEGRATION_REGISTRY: dict[str, IntegrationBase] = {}
_registry_initialized = False

# Well-known integration keys that Forge Kit supports.
# These are documented in AGENTS.md and recognised by the CLI.
# As integration subpackages are implemented, they will be registered
# here and added to this set.
KNOWN_INTEGRATIONS: set[str] = {
    "claude",
    "copilot",
    "gemini",
    "windsurf",
    "cursor",
    "codeium",
    "continue",
    "tabnine",
    "aws-bedrock",
    "azure-openai",
    "openai",
    "anthropic",
}


def _register(integration: IntegrationBase) -> None:
    """Register an integration in the global registry."""
    INTEGRATION_REGISTRY[integration.key] = integration


def _register_builtins() -> None:
    """Register all built-in integrations."""
    global _registry_initialized
    if _registry_initialized:
        return
    _registry_initialized = True

    from .anthropic import AnthropicIntegration
    from .aws_bedrock import AwsBedrockIntegration
    from .azure_openai import AzureOpenAIIntegration
    from .claude import ClaudeIntegration
    from .cline import ClineIntegration
    from .codeium import CodeiumIntegration
    from .continue_ import ContinueIntegration
    from .copilot import CopilotIntegration
    from .cursor import CursorIntegration
    from .gemini import GeminiIntegration
    from .openai import OpenAIIntegration
    from .tabnine import TabnineIntegration
    from .windsurf import WindsurfIntegration

    _register(AnthropicIntegration())
    _register(AwsBedrockIntegration())
    _register(AzureOpenAIIntegration())
    _register(ClaudeIntegration())
    _register(ClineIntegration())
    _register(CodeiumIntegration())
    _register(ContinueIntegration())
    _register(CopilotIntegration())
    _register(CursorIntegration())
    _register(GeminiIntegration())
    _register(OpenAIIntegration())
    _register(TabnineIntegration())
    _register(WindsurfIntegration())


def get_integration(key: str) -> IntegrationBase | None:
    """Get an integration by key."""
    _register_builtins()
    return INTEGRATION_REGISTRY.get(key)


def list_integrations() -> list[str]:
    """List all registered integration keys."""
    _register_builtins()
    return list(INTEGRATION_REGISTRY.keys())


def validate_integration(key: str) -> None:
    """Validate an integration key.

    Raises a typer error if the key is not recognised.
    Integrations that are registered in INTEGRATION_REGISTRY are always valid;
    unknown keys are checked against KNOWN_INTEGRATIONS and rejected if not found.
    """
    _register_builtins()
    if key in INTEGRATION_REGISTRY:
        return
    if key not in KNOWN_INTEGRATIONS:
        known = ", ".join(sorted(KNOWN_INTEGRATIONS))
        raise typer.BadParameter(
            f"Unknown integration '{key}'. Available integrations: {known}"
        )


def format_integrations_help() -> str:
    """Format known integrations for CLI help text."""
    known = ", ".join(sorted(KNOWN_INTEGRATIONS))
    return f"AI coding agent integration (default: copilot). Available: {known}"
