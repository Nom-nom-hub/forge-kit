# Development Notes

Forge Kit is a toolkit for FORGE-driven development. At its core, it is a coordinated set of prompts, templates, scripts, and CLI/integration assets that define and deliver a FORGE workflow for AI coding agents. This document is a starting point for people modifying Forge Kit itself.

**Essential project documents:**

| Document | Role |
|----------|------|
| [README.md](README.md) | Primary user-facing overview of Forge Kit and its workflow. |
| [DEVELOPMENT.md](DEVELOPMENT.md) | This document. |
| [forge-methodology.md](forge-methodology.md) | Complete FORGE methodology reference. |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution process and testing. |

**Main repository components:**

| Directory | Role |
|-----------|------|
| `templates/` | Prompt assets and templates defining core FORGE workflow behavior and generated artifacts. |
| `scripts/` | Supporting scripts used by the workflow, setup, and repository tooling. |
| `src/forge_cli/` | Python source for the `forge` CLI, including agent-specific assets. |
| `extensions/` | Extension-related docs, catalogs, and supporting assets. |
| `presets/` | Preset-related docs, catalogs, and supporting assets. |
