---
description: Forge Kit — FORGE methodology slash commands for this project
globs: ".forge/**/*"
---

# Forge Kit — FORGE Methodology Commands

This project (Forge Kit) uses the FORGE (Feature-Oriented Requirements & Governance Engine) methodology.

The following slash commands are available. Full command templates with detailed step-by-step instructions are stored in `.forge/templates/commands/`.

| Command | Description |
|---------|-------------|
| `/forge.signal` | Capture a FORGE signal — the atomic observation unit that drives all development |
| `/forge.hypothesize` | Form a FORGE hypothesis from one or more signals |
| `/forge.decide` | Record a FORGE decision with context, alternatives, and consent protocol |
| `/forge.feature` | Create a FORGE feature from a hypothesis or decision |
| `/forge.experiment` | Design an experiment to test a hypothesis |
| `/forge.release` | Create a FORGE release manifest |
| `/forge.retrospect` | Conduct a FORGE retrospective |
| `/forge.analyze` | Analyze FORGE artifacts for insights, patterns, and clusters |
| `/forge.check` | Run quality checks on FORGE artifacts |
| `/forge.checklist` | Create a FORGE quality checklist |
| `/forge.clarify` | Refine and clarify underspecified artifacts |
| `/forge.constitution` | View or modify the FORGE constitution |
| `/forge.graph` | View and explore the FORGE artifact graph |
| `/forge.ai-analyze` | AI-assisted analysis of FORGE artifacts |
| `/forge.ai-critique` | AI-generated critique of hypotheses and decisions |
| `/forge.ai-blind-spots` | AI detection of blind spots in reasoning |

## Quick Reference

- **Read the full template** before executing any command: `.forge/templates/commands/<command>.md`
- **All artifacts** are YAML files in `.forge/{signals,hypotheses,decisions,features,experiments,releases,retrospectives,cognitive-contracts}/`
- **Bidirectional links** must be maintained between related artifacts
- **Scripts** are in `.forge/scripts/{bash,powershell}/`
- **Templates** for new artifacts are in `.forge/templates/`

## Core Principles

1. **Signal-First**: Every feature MUST start with a Signal
2. **Hypothesis Framing**: Every feature is a hypothesis, not a requirement
3. **Consent Over Approval**: Governance is consent-based
4. **Decisions Are Artifacts**: Every significant choice is recorded
5. **Unknowns Are First-Class**: Every artifact MUST carry unknowns
6. **Drift Detection**: Implementation drift from intent is continuously measured
7. **Review-Before-Merge**: Every feature MUST pass automated code review before being marked complete (see Workflow Gates below)
8. **Interactive-When-Present**: CLI tools SHOULD use TTY-detect with fallback defaults

## Workflow Gates

### Mandatory: Code Review Before Completion

After implementing any non-trivial change, you MUST spawn `code-reviewer-deepseek-flash` before declaring the task done. This is a hard gate — do not skip it.

**Why**: The interactive forge init implementation had a bug where `_write_config()` accepted a `script_type` parameter but never used it in the template string — it always hardcoded `script_type: bash`. This would have shipped silently since ruff/pytest cannot detect unused template parameters. The automated code reviewer caught it. (Source: sig-5857a02e, rsp-5800e091)

**What to do**:
1. After implementing changes and running tests/lints, spawn `code-reviewer-deepseek-flash`
2. Provide a summary of what changed (files, purpose)
3. Read and address the review feedback
4. Fix any issues identified before proceeding
5. **Exception**: Comments, documentation-only, or formatting-only changes MAY skip the gate with explicit justification
