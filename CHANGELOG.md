# Changelog

<!-- insert new changelog below this comment -->

## [0.2.0] - 2026-05-19

### Added

- feat: interactive `forge init` with arrow-key-selectable model picker and script-type selector
- feat: TTY-detect pattern — interactive when human-present, falls back to defaults when piped/CI
- feat: non-interactive fallback preserves backward compatibility (copilot+bash defaults)
- feat: 13 AI coding agent integrations with context files installed at init
- feat: core pack bundling — templates, scripts, and presets baked into the package
- feat: FORGE constitution with 9 articles (Review-Before-Merge, Interactive-When-Present)
- feat: autonomous agent instruction pattern — `code-reviewer-deepseek-flash` mandated as workflow gate
- feat: signal-driven health checks (`/forge.check`) with drift scoring and constitution compliance

### Changed

- `forge init` now prompts interactively when run in a terminal (pass `--integration` and `--script-type` flags to bypass)
- Version bump: 0.1.0.dev0 → 0.2.0 (stable release)
- pyproject.toml: added questionary>=2.1.0 dependency

### Fixed

- `_write_config()` no longer ignores the `script_type` parameter (caught by automated code review)

---

## [0.1.0] - 2026-05-18

### Changed

- feat: initial FORGE Kit release — signal-driven development toolkit
- feat: 16 slash command templates (signal, hypothesize, decide, feature, experiment, release, retrospect, check, analyze, clarify, graph, checklist, constitution, ai-analyze, ai-critique, ai-blind-spots)
- feat: autonomous agent instruction pattern for all commands
- feat: signal-first workflow preset with overrides for signal, hypothesize, decide
- feat: git extension with 45 hooks and cross-platform scripts (bash + powershell)
- feat: FORGE-Driven Development methodology docs (forge-driven.md, FDD concept doc)
- feat: extensions system with extension.yml manifest and hook lifecycle
- feat: presets system with catalog.json and override resolution
- feat: AI coding agent integrations (Claude, Gemini, Copilot, Cursor, Windsurf, etc.)
- feat: Forge CLI for project bootstrapping (`forge init`)
- feat: template-driven quality validation with checklists
- feat: ICE scoring, hypothesis framing, consent protocol templates
- feat: CI/CD with ruff linting, pytest, and branch protection
- docs: comprehensive AGENTS.md integration architecture docs
- docs: quickstart guide, installation guide, and README
