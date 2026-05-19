"""Integration registry for Forge CLI.

Each AI coding agent is registered as an integration that defines
how command templates are installed and context files are managed.
"""

from typing import Dict, List, Optional

from .base import IntegrationBase

INTEGRATION_REGISTRY: Dict[str, IntegrationBase] = {}
_registry_initialized = False


def _register(integration: IntegrationBase) -> None:
    """Register an integration in the global registry."""
    INTEGRATION_REGISTRY[integration.key] = integration


def _register_builtins() -> None:
    """Register all built-in integrations."""
    global _registry_initialized
    if _registry_initialized:
        return
    _registry_initialized = True

    # Built-in integrations will be added as they are implemented.
    # Each integration subpackage defines a class extending IntegrationBase
    # which is registered here. Example:
    #
    # from .claude import ClaudeIntegration
    # _register(ClaudeIntegration())
    pass


def get_integration(key: str) -> Optional[IntegrationBase]:
    """Get an integration by key."""
    _register_builtins()
    return INTEGRATION_REGISTRY.get(key)


def list_integrations() -> List[str]:
    """List all registered integration keys."""
    _register_builtins()
    return list(INTEGRATION_REGISTRY.keys())
