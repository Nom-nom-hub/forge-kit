"""Forge CLI main application."""

from typing import Optional

import typer

app = typer.Typer(
    name="forge",
    help="🔥 Forge CLI — Feature-Oriented Requirements & Governance Engine",
    no_args_is_help=True,
)


@app.command()
def init(
    project_name: Optional[str] = typer.Argument(None, help="Project name or '.' for current directory"),
    integration: str = typer.Option("copilot", "--integration", "-i", help="AI coding agent integration"),
    force: bool = typer.Option(False, "--force", "-f", help="Overwrite existing files"),
):
    """Initialize a new FORGE project."""
    from .commands.init import run_init
    run_init(project_name=project_name, integration=integration, force=force)


@app.command()
def version():
    """Show the Forge CLI version."""
    try:
        from importlib.metadata import version as get_version
        ver = get_version("forge-cli")
    except Exception:
        ver = "0.1.0.dev0"
    typer.echo(f"Forge CLI v{ver}")


@app.callback()
def callback():
    """Forge CLI — the tool for FORGE methodology projects."""
    pass
