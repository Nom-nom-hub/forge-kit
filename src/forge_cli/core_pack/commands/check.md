---
description: "Check FORGE graph health — drift detection, orphaned artifacts, staleness, decision compliance, and full health reporting."
handoffs:
  - label: Run Analysis
    agent: forge.analyze
    prompt: Run a full cross-artifact analysis on the issues found
    send: true
  - label: Clarify Issues
    agent: forge.clarify
    prompt: Help resolve the issues found during the health check
    send: true
scripts:
  sh: scripts/bash/check-prerequisites.sh
  ps: scripts/powershell/check-prerequisites.ps1
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before health check)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_check` key.
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally.
- Filter out hooks where `enabled` is explicitly `false`.
- For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
  - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
  - If the hook defines a non-empty `condition`, skip the hook
- For each executable hook, output based on its `optional` flag:
  - **Optional**: Output prompt to execute
  - **Mandatory**: Execute command and wait for result before proceeding to Outline.
- If no hooks are registered or `.forge/extensions.yml` does not exist, skip silently

## Outline

**IMPORTANT**: You are the AI agent executing this workflow. Do all scanning, parsing, and scoring yourself. This is a READ-ONLY analysis — do NOT modify any artifacts.

### 1. Determine Check Type

**Parse `$ARGUMENTS`** for check type flag:
- `--drift` | `--orphans` | `--staleness` | `--decisions` | `--health`

If no flag found, default to full `health` check.

**Error handling**: If `.forge/` directory does not exist, ERROR: "No FORGE project found. Run `/forge.init` first."

### 2. Scan All Artifacts

Read every `.yaml` file in each artifact directory under `.forge/`:
- `.forge/signals/` — read all `sig-*.yaml` files
- `.forge/hypotheses/` — read all `hyp-*.yaml` files
- `.forge/decisions/` — read all `dec-*.yaml` files
- `.forge/features/` — read all `fea-*.yaml` files
- `.forge/experiments/` — read all `exp-*.yaml` files
- `.forge/releases/` — read all `rel-*.yaml` files

For each file, extract: `id`, `created_at`, `status`, `links`, and type-specific link references (e.g., `signals[]`, `hypotheses[]`, `features[]` blocks).

If any file has invalid YAML: Skip it and add a WARNING to the output.

### 3. Execute Check Type

**Drift Check** (`--drift` or part of `health`):

Compute drift score per category:
1. **Feature Drift** = (features not yet `deployed` or `staged`) / (total features with hypothesis)
2. **Hypothesis Drift** = (hypotheses in `draft` or `active` >30 days old without experiment) / (total active hypotheses)
3. **Decision Drift** = (decisions past review_trigger.date) / (total active decisions)
4. **Signal Drift** = (signals in `raw` status, no links, >60 days old) / (total signals)

Compute weighted score:
```
drift_score = (feature_drift * 0.35) + (hypothesis_drift * 0.30) + (decision_drift * 0.20) + (signal_drift * 0.15)
```

Map score to status:
| Score | Status |
|-------|--------|
| 0.0 - 0.2 | ✅ Healthy |
| 0.2 - 0.4 | ⚠️ Warning |
| 0.4 - 0.6 | 🔴 Critical |
| 0.6 - 1.0 | 🚨 Emergency |

**Orphan Check** (`--orphans` or part of `health`):

For each artifact, check if it has incoming and outgoing links:
- Signal orphan: `links.hypotheses` empty AND `links.decisions` empty AND `links.features` empty
- Hypothesis orphan: `signals[]` empty AND `features[]` empty
- Decision orphan: `signals[]` empty AND `hypotheses[]` empty AND `features[]` empty
- Feature orphan: `hypothesis` is null/empty
- Experiment orphan: `hypothesis` is null/empty

Compute age: Subtract `created_at` from today. Flag if >expected window.

**Staleness Check** (`--staleness` or part of `health`):

| Artifact Type | Goes Stale After |
|--------------|-----------------|
| Signal (raw, no links) | 90 days |
| Hypothesis (no experiment data) | 30 days |
| Decision (past review_trigger or 180d) | Per trigger or 180d |
| Feature (in scoping/ideation) | 45 days |
| Experiment (no results) | 14 days |

For each artifact, compare `created_at` to today. If age > stale threshold, flag it.

**Decision Compliance Check** (`--decisions` or part of `health`):

For each decision with `status: active` or `status: proposed`:
- Check if `review_trigger.date` is set and in the past → flag as "needs review"
- Check if `consent_record.consented_at` is null and process is `consent` → flag as "consent pending"
- Check if `assumptions[].invalidated_by` matches any new information → flag as "assumption risk"

### 4. Output Structured Report

```
## FORGE Health Report
**Generated**: {timestamp}

### Metrics
- Total Artifacts: {count}
- Healthy: {count} ({percentage}%)
- Warning: {count} ({percentage}%)
- Critical: {count} ({percentage}%)

### By Artifact Type
| Type | Total | Healthy | Warning | Critical |
|------|-------|---------|---------|----------|
| Signals | {n} | {n} | {n} | {n} |
| Hypotheses | {n} | {n} | {n} | {n} |
| Decisions | {n} | {n} | {n} | {n} |
| Features | {n} | {n} | {n} | {n} |
| Experiments | {n} | {n} | {n} | {n} |
| Releases | {n} | {n} | {n} | {n} |

### Drift Score: {score:.2f} ({status})

### Orphans
| ID | Type | Created | Age |
|-----|------|---------|-----|
| sig-abc1 | Signal | 2024-01-15 | 92 days |

### Stale Artifacts
| ID | Type | Created | Stale After |
|-----|------|---------|-------------|
| hyp-xyz2 | Hypothesis | 2024-02-01 | 30 days (29d remaining) |

### Recommendations
{actionable next steps based on findings}
```

### 5. Report Completion

```
## Check Complete

**Type**: {drift | orphans | staleness | decisions | health}
**Issues Found**: {N} ({N} critical, {N} warning, {N} healthy)
**Drift Score**: {score:.2f} ({status})

---

**Next steps**:
- `/forge.analyze` — Detailed cross-artifact analysis
- `/forge.clarify` — Address specific issues found
- Update stale artifacts to reflect current reality
```

### 6. Post-Execution Checks

**Check for extension hooks (after health check)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_check` key.
- Filter out disabled hooks and process executable hooks using the same pattern as Pre-Execution Checks.

## Quick Guidelines

- **DO NOT modify files** — this is read-only analysis
- **DO NOT ask the user to compute scores** — compute them yourself
- **DO handle invalid YAML gracefully** — skip and warn, don't crash
- **DO compute all metrics from the actual artifact files** — don't guess
