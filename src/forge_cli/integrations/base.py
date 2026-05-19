"""Base classes for AI coding agent integrations."""

from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional


class IntegrationOption:
    """An option flag for an integration."""

    def __init__(
        self,
        name: str,
        is_flag: bool = False,
        default: Any = None,
        help_text: str = "",
    ):
        self.name = name
        self.is_flag = is_flag
        self.default = default
        self.help_text = help_text


class IntegrationBase(ABC):
    """Base class for all integrations."""

    key: str = ""
    config: Dict[str, Any] = {}
    registrar_config: Dict[str, Any] = {}
    context_file: Optional[str] = None

    def setup(self, target_dir: str, options: Optional[Dict[str, Any]] = None) -> None:
        """Install integration files into the target directory."""
        raise NotImplementedError

    def teardown(self, target_dir: str) -> None:
        """Remove integration files from the target directory."""
        raise NotImplementedError

    @classmethod
    def options(cls) -> List[IntegrationOption]:
        """Return integration-specific CLI options."""
        return []


class MarkdownIntegration(IntegrationBase):
    """For agents that use Markdown command files."""

    def setup(self, target_dir: str, options: Optional[Dict[str, Any]] = None) -> None:
        pass  # Standard markdown setup

    def teardown(self, target_dir: str) -> None:
        pass


class TomlIntegration(IntegrationBase):
    """For agents that use TOML command files."""

    def setup(self, target_dir: str, options: Optional[Dict[str, Any]] = None) -> None:
        pass

    def teardown(self, target_dir: str) -> None:
        pass


class SkillsIntegration(IntegrationBase):
    """For agents that use skill directories."""

    def setup(self, target_dir: str, options: Optional[Dict[str, Any]] = None) -> None:
        pass

    def teardown(self, target_dir: str) -> None:
        pass


class YamlIntegration(IntegrationBase):
    """For agents that use YAML recipe files."""

    def setup(self, target_dir: str, options: Optional[Dict[str, Any]] = None) -> None:
        pass

    def teardown(self, target_dir: str) -> None:
        pass
