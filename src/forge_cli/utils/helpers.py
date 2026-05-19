"""Helper utilities for Forge CLI."""

import re
import uuid
from datetime import UTC, datetime
from pathlib import Path


def generate_id(prefix: str = "sig") -> str:
    """Generate a short unique ID for a FORGE artifact."""
    short = uuid.uuid4().hex[:8]
    return f"{prefix}-{short}"


def timestamp() -> str:
    """Get current ISO8601 timestamp."""
    return datetime.now(UTC).isoformat()


def find_forge_root() -> Path | None:
    """Walk up from CWD to find the .forge directory."""
    cwd = Path.cwd()
    for parent in [cwd] + list(cwd.parents):
        if (parent / ".forge").is_dir():
            return parent
    return None


def slugify(text: str) -> str:
    """Convert text to a URL-friendly slug."""
    text = text.lower().strip()
    text = re.sub(r"[^\w\s-]", "", text)
    text = re.sub(r"[\s_]+", "-", text)
    text = re.sub(r"-+", "-", text)
    return text
