"""Tests for the forge init command."""

from pathlib import Path
from unittest.mock import patch

import pytest
from typer.testing import CliRunner

from forge_cli.cli import app

runner = CliRunner()


def test_version():
    """Test the version command."""
    result = runner.invoke(app, ["version"])
    assert result.exit_code == 0
    assert "Forge CLI" in result.stdout


def test_init_help():
    """Test init command help."""
    result = runner.invoke(app, ["init", "--help"])
    assert result.exit_code == 0
    assert "Initialize" in result.stdout


@pytest.mark.skip(reason="Requires filesystem setup; tested via integration tests")
def test_init_project(tmp_path):
    """Test initializing a FORGE project (placeholder for integration test)."""
    pass
