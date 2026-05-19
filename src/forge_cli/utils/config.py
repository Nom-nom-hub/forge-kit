"""Configuration utilities for Forge CLI."""

from pathlib import Path
from typing import Any, Dict, Optional

import yaml

from .helpers import find_forge_root


def load_config() -> Optional[Dict[str, Any]]:
    """Load the FORGE configuration file."""
    root = find_forge_root()
    if not root:
        return None

    config_path = root / ".forge" / "forge.config.yaml"
    if not config_path.exists():
        return None

    with open(config_path, "r") as f:
        return yaml.safe_load(f)


def get_staleness_settings() -> Dict[str, int]:
    """Get staleness thresholds from config."""
    config = load_config()
    if config and "staleness" in config:
        return config["staleness"]
    return {
        "signal_days": 90,
        "hypothesis_days": 30,
        "decision_days": 180,
        "feature_days": 45,
    }


def get_drift_thresholds() -> Dict[str, float]:
    """Get drift thresholds from config."""
    config = load_config()
    if config and "drift" in config:
        return config["drift"]
    return {
        "warning_threshold": 0.2,
        "critical_threshold": 0.4,
        "emergency_threshold": 0.6,
    }
