"""Forge CLI main application."""


import sys

import typer

from .integrations import format_integrations_help, validate_integration
from .prompts import pick_integration, pick_script_type

_SCRIPT_TYPES = ["bash", "powershell"]

app = typer.Typer(
    name="forge",
    help="🔥 Forge CLI — Feature-Oriented Requirements & Governance Engine",
    no_args_is_help=True,
)


def _script_type_complete(incomplete: str) -> list[str]:
    """Shell completion for script types."""
    return [s for s in _SCRIPT_TYPES if s.startswith(incomplete)]


@app.command()
def init(
    project_name: str | None = typer.Argument(None, help="Project name or '.' for current directory"),
    integration: str = typer.Option(
        None,  # None = trigger interactive prompt
        "--integration",
        "-i",
        help=format_integrations_help(),
        show_default=False,
    ),
    script_type: str = typer.Option(
        None,  # None = trigger interactive prompt
        "--script-type",
        "-s",
        help="Scripting environment (bash, powershell). Default: bash",
        shell_complete=_script_type_complete,
        show_default=False,
    ),
    force: bool = typer.Option(False, "--force", "-f", help="Overwrite existing files"),
):
    """Initialize a new FORGE project."""

    # Interactive prompts when running in a terminal without flags
    is_tty = sys.stdin.isatty()

    if is_tty and integration is None:
        picked = pick_integration()
        if picked is None:
            raise typer.Exit(code=1)
        integration = picked
    elif integration is None:
        integration = "copilot"  # non-interactive default

    if is_tty and script_type is None:
        picked = pick_script_type()
        if picked is None:
            raise typer.Exit(code=1)
        script_type = picked
    elif script_type is None:
        script_type = "bash"  # non-interactive default

    if script_type not in _SCRIPT_TYPES:
        raise typer.BadParameter(
            f"Unknown script type '{script_type}'. Choose from: {', '.join(_SCRIPT_TYPES)}"
        )

    validate_integration(integration)

    from .commands.init import run_init

    run_init(
        project_name=project_name,
        integration=integration,
        script_type=script_type,
        force=force,
    )


@app.command()
def version():
    """Show the Forge CLI version."""
    try:
        from importlib.metadata import version as get_version
        ver = get_version("forge-cli")
    except Exception:
        ver = "0.2.0"
    typer.echo(f"Forge CLI v{ver}")


@app.callback()
def callback():
    """Forge CLI — the tool for FORGE methodology projects."""
    pass
