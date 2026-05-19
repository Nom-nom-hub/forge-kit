# Contributing to Forge Kit

Welcome! We're excited you're here. Forge Kit is an open-source toolkit for the FORGE methodology, and contributions of all kinds — code, documentation, issue templates, extensions, and presets — are what make this project thrive.

Please take a moment to read through this guide before contributing. It covers everything from development setup to our AI contribution policy.

---

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
- [Development Workflow](#development-workflow)
  - [Branching](#branching)
  - [Coding Standards](#coding-standards)
  - [Testing](#testing)
  - [Running the CLI Locally](#running-the-cli-locally)
- [Pull Request Process](#pull-request-process)
- [AI Contribution Policy](#ai-contribution-policy)
  - [Why Disclosure Matters](#why-disclosure-matters)
  - [How to Disclose](#how-to-disclose)
  - [What Requires Disclosure](#what-requires-disclosure)
  - [What Does Not Require Disclosure](#what-does-not-require-disclosure)
  - [Review Expectations for AI-Assisted Contributions](#review-expectations-for-ai-assisted-contributions)
- [Community Extensions & Presets](#community-extensions--presets)
  - [Extensions](#extensions)
  - [Presets](#presets)
- [Reporting Issues](#reporting-issues)
- [Labels Glossary](#labels-glossary)

---

## Code of Conduct

This project follows the [FORGE methodology's governance principles](forge-methodology.md). Please read and adhere to our [Code of Conduct](CODE_OF_CONDUCT.md). Be respectful, assume good intent, and resolve disagreements through reasoned consent — not veto.

---

## Getting Started

### Prerequisites

- **Python 3.11+**
- **[uv](https://docs.astral.sh/uv/)** — package manager and tool runner
- **Git**
- Access to this repository (clone or fork as appropriate)

> 💡 If you use VS Code, consider using the **Dev Containers** extension for a consistent environment.

### Setup

```bash
# Clone the repository
git clone https://github.com/Nom-nom-hub/forge-kit.git
cd forge-kit

# Install the project with test dependencies
uv sync --extra test

# Install linting tools
uv sync --extra lint
```

Verify everything works:

```bash
uv run ruff check src/
uv run pytest
```

---

## Development Workflow

### Branching

- **`main`** is the default and protected branch. All changes must go through a pull request.
- Create feature branches from `main` with a descriptive name:
  ```bash
  git checkout -b feat/my-feature
  git checkout -b fix/issue-123
  git checkout -b docs/update-readme
  ```
- Keep branches focused on a single concern. Smaller PRs are easier to review.

### Coding Standards

Forge Kit follows strict code quality practices enforced by **ruff**:

```bash
# Check for lint issues
uv run ruff check src/

# Auto-fix what can be fixed
uv run ruff check --fix src/
```

**Guidelines:**

- **Line length:** 120 characters
- **Formatting:** ruff formatter (`uv run ruff format src/`)
- **Imports:** Sorted via ruff's isort rules (I)
- **Naming:** PEP 8 naming conventions enforced by ruff (N)
- **Type hints:** Use Python 3.11+ type hints wherever possible
- **Target:** Python 3.11+

### Testing

Tests use **pytest** with coverage reporting:

```bash
# Run all tests
uv run pytest

# Run with coverage
uv run pytest --cov

# Run a specific test file
uv run pytest tests/test_something.py
```

**Testing expectations:**

- New features and bug fixes should include tests
- Tests live in the `tests/` directory matching the `src/` structure
- Use descriptive test names — `test_my_function_returns_expected_value`
- If you're adding a new integration, include an integration test

### Running the CLI Locally

```bash
# Run as a Python module
uv run forge

# Run with a specific subcommand
uv run forge init my-project --integration copilot
```

---

## Pull Request Process

1. **Discuss large changes first** — Open an issue or start a discussion before investing significant effort. We want to make sure your contribution aligns with the project direction.

2. **Ensure CI passes** — Before requesting review, run:
   ```bash
   uv run ruff check src/   # Lint check
   uv run pytest            # Test suite
   ```

3. **Fill out the PR template** — Our [pull request template](.github/PULL_REQUEST_TEMPLATE.md) includes:
   - A **description** of what changed and why
   - **Related FORGE artifacts** (signals, hypotheses, decisions, etc.)
   - A **type of change** selector
   - A **quality checklist** (lint, tests, docs, changelog)
   - An **AI disclosure** section (see policy below)

4. **Keep PRs focused** — A single PR should address a single concern. If you find yourself describing multiple unrelated changes, split them into separate PRs.

5. **Respond to feedback** — Reviewers may ask for changes. Please address them promptly. Inactive PRs may be marked stale and eventually closed.

6. **Squash merge** — All PRs are squash-merged into `main`. You don't need to worry about cleaning up your commit history.

---

## AI Contribution Policy

Forge Kit embraces AI-assisted development. However, **transparency is essential** for maintaining trust, reproducibility, and the quality of the project.

### Why Disclosure Matters

- **Reviewability:** Reviewers need to know whether they're reviewing original thought or AI-generated content, which changes how they evaluate the submission.
- **Accountability:** Humans are ultimately responsible for every contribution. Disclosure ensures the right person is accountable for each change.
- **Traceability:** As an AI-native project, we practice what we preach — every decision (including *how* a contribution was made) should be traceable.

### How to Disclose

When submitting a pull request, check the appropriate option in the **AI Disclosure** section of the PR template:

```
- [ ] I **did not** use AI assistance for this contribution
- [ ] I **did** use AI assistance (describe how below)
```

If you used AI assistance, briefly describe how in the PR description. Examples:

> *"Used Claude Code to generate the initial implementation of the Copilot integration, then manually reviewed, adjusted, and tested."*

> *"Used ChatGPT to help debug a pytest fixture issue. No AI-generated code in the final submission."*

> *"Used AI code review tools to suggest optimizations, then manually implemented changes."*

### What Requires Disclosure

| Activity | Disclose? |
|----------|-----------|
| AI wrote the initial implementation | ✅ Yes |
| AI suggested a code fix | ✅ Yes |
| AI helped debug or diagnose an issue | ✅ Yes |
| AI generated test cases | ✅ Yes |
| AI reviewed your PR before submission | ✅ Yes |
| AI wrote documentation | ✅ Yes |
| AI helped refine commit messages or PR descriptions | ✅ Yes |

### What Does Not Require Disclosure

| Activity | Disclose? |
|----------|-----------|
| Spell-checking, grammar fixes in comments/docs | ❌ No |
| Using an AI-powered IDE autocomplete (e.g., GitHub Copilot inline suggestions) | ❌ No |
| AI-assisted search (e.g., "find all uses of function X") | ❌ No |

If in doubt, **disclose**. A brief disclosure is never penalized — omitting one when it was needed undermines trust.

### Review Expectations for AI-Assisted Contributions

- **Human understanding is required** — AI-generated code that the submitter cannot explain will not be accepted. Be prepared to discuss your changes in review.
- **Testing is required** — AI-generated code must be tested, just like any other contribution. Submissions that are clearly untested AI output may be closed without review.
- **Quality matters** — AI can produce code that *looks* correct but has subtle bugs, security issues, or doesn't follow project conventions. The submitter is responsible for verifying all aspects of the contribution.

---

## Community Extensions & Presets

Forge Kit supports two community contribution systems:

### Extensions

Extensions add new capabilities to Forge Kit beyond the core commands. If you've built an extension that others might find useful, submit it via the [Extension Submission template](.github/ISSUE_TEMPLATE/extension_submission.yml).

For development guidance, see the [Extension Publishing Guide](extensions/EXTENSION-PUBLISHING-GUIDE.md).

### Presets

Presets customize how Forge Kit behaves — overriding templates, commands, and terminology without changing any tooling. Submit presets via the [Preset Submission template](.github/ISSUE_TEMPLATE/preset_submission.yml).

For development guidance, see the [Preset Publishing Guide](presets/PUBLISHING.md).

---

## Reporting Issues

We use GitHub Issues to track bugs, feature requests, and agent integration requests.

Before opening a new issue:

1. **Search existing issues** — Your problem may already be reported or addressed.
2. **Use the appropriate template**:
   - [Bug Report](.github/ISSUE_TEMPLATE/bug_report.yml) — Something isn't working
   - [Feature Request](.github/ISSUE_TEMPLATE/feature_request.yml) — New capability idea
   - [Agent Request](.github/ISSUE_TEMPLATE/agent_request.yml) — Support for a new AI coding agent
3. **Include reproduction steps** for bugs — "it doesn't work" is not actionable. Show us *how* to reproduce the issue.
4. **Share relevant context** — Python version, OS, AI agent, error output, and what you expected to happen.

### Security Issues

If you discover a security vulnerability, **do not** open a public issue. Instead, follow the guidelines in [SECURITY.md](SECURITY.md).

---

## Labels Glossary

| Label | Meaning |
|-------|---------|
| `bug` | Something isn't working as expected |
| `enhancement` | New feature or improvement |
| `documentation` | Docs-related changes |
| `integration` | New AI agent integration |
| `extension` | Extension-related |
| `preset` | Preset-related |
| `good first issue` | Great for newcomers |
| `help wanted` | Maintainers are seeking contributors |
| `needs discussion` | Decision required before proceeding |
| `question` | Inquiry, not a bug report |

---

*Thank you for contributing to Forge Kit! Every contribution — big or small — makes the FORGE methodology stronger.*
