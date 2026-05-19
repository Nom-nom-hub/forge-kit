---
description: "Run cross-artifact consistency and coverage analysis across FORGE artifacts. Checks links, hypothesis coverage, decision health, and identifies gaps before implementation."
handoffs:
  - label: Check Health
    agent: forge.check
    prompt: Run a health check on the issues found during analysis
    send: true
  - label: Clarify Issues
    agent: forge.clarify
    prompt: Help resolve the issues found during analysis
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before analysis)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_analyze` key.
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally.
- Filter out hooks where `enabled` is explicitly `false`.
- Process hooks using the standard pattern.

## Outline

**IMPORTANT**: You are the AI agent executing this workflow. This is a **READ-ONLY** analysis — do NOT modify any files. Generate all findings in the output report.

### 1. Scan All Artifacts

Read all directories under `.forge/` to build a complete picture:

| Directory | Contains |
|-----------|----------|
| `.forge/signals/` | Signal artifacts |
| `.forge/hypotheses/` | Hypothesis artifacts |
| `.forge/decisions/` | Decision artifacts |
| `.forge/features/` | Feature artifacts |
| `.forge/experiments/` | Experiment artifacts |
| `.forge/releases/` | Release manifests |
| `.forge/retrospectives/` | Retro artifacts |

**Error handling**: If `.forge/` directory does not exist, ERROR: "No FORGE project found. Run `/forge.init` first." STOP.

### 2. Analyze Relationships

For each artifact directory, read every `.yaml` file and extract `links`, `signals`, `hypotheses`, `decisions`, `features`, `experiments` fields.

Build internal relationship map (internal only, do not output full map):

**Graph Consistency** — check each condition, mark pass/fail:
- Every signal (except retros) is linked to a hypothesis or marked as stand-alone
- Every hypothesis is linked to at least one signal
- Every decision has linked signals or hypotheses
- Every feature has a linked hypothesis
- No orphan artifacts (unlinked after expected window)

If a file cannot be parsed (invalid YAML), skip it and add a WARNING to the output.

### 3. Analyze Coverage

**Signal Coverage**:
- Count total signals. Count signals with non-empty `links.hypotheses` or `links.decisions`. Compute linked ratio.
- Count signals with `status: raw` that are >60 days old (check `created_at`).

**Hypothesis Coverage**:
- Count total hypotheses. Count those with linked experiments, features.
- Count hypotheses by status: `draft`, `active`, `validated`, `invalidated`, `inconclusive`.

**Decision Health**:
- Count total decisions. Count those with populated `consent_record.consented_at`.
- Check each `review_trigger.date` — count those past due.
- Count decisions with non-empty `superseded_by` (superseded).

**Feature Health**:
- Count total features. Count those with `feature.journeys` (has ACs), `feature.observability.events_to_track`.
- Count features by status: `ideation`, `building`, `review`, `staged`, `deployed`.

### 4. Identify Critical Issues

Score findings by severity. Count, then output only the findings table:

**CRITICAL** (blockers — require immediate action):
- Hypothesis with zero linked signals
- Decision past review trigger with no update
- Feature with no acceptance criteria

**HIGH** (should be resolved this cycle):
- Orphan signal >60 days old
- Hypothesis >30 days with no experiment
- Decision with no consent record

**MEDIUM** (should track):
- Feature with no observability requirements
- Signal with no evidence
- Hypothesis with no falsification criteria

**LOW** (nice to fix):
- Feature with no technical surface area documentation
- Signal with no affected dimensions

Format findings as a table with stable IDs (A1, A2, etc.) and recommendations.

### 5. Produce Analysis Report

Output a structured Markdown report:

```
## FORGE Analysis Report
**Generated**: {timestamp}

### Metrics
- Total Artifacts: {n}
- Linked Artifacts: {n} ({percentage}%)
- Orphans: {n}
- Stale Artifacts: {n}

### Issues by Severity
| ID | Severity | Artifact | Issue | Recommendation |
|----|----------|----------|-------|----------------|
| A1 | CRITICAL | hyp-b2mp | No linked signals | Connect to relevant signals |
| A2 | HIGH | dec-p4qw | Past review trigger | Schedule review |

### Coverage Summary
| Type | Total | Linked | Orphaned | Stale |
|------|-------|--------|----------|-------|
| Signals | {n} | {n} | {n} | {n} |
| Hypotheses | {n} | {n} | {n} | {n} |
| Decisions | {n} | {n} | {n} | {n} |
| Features | {n} | {n} | {n} | {n} |

### Next Actions
- Resolve CRITICAL issues before proceeding with implementation
- Run `/forge.check` for detailed health measurements
- Run `/forge.clarify` to address specific issues
```

### 6. Offer Remediation

Ask the user: "Would you like me to suggest concrete remediation steps for the top {N} issues?" 

**DO NOT** apply edits automatically. Only suggest steps.

## Quick Guidelines

- **Read-Only Analysis**: Do NOT modify any artifacts — analysis informs, it does not change
- **Severity Hierarchy**: CRITICAL > HIGH > MEDIUM > LOW — focus on CRITICAL first
- **Link Integrity**: Missing links are the most common issue — always check signal→hypothesis→feature chains
- **Staleness Is Relative**: A 30-day-old hypothesis with no experiment is more concerning than a 90-day-old raw signal
- **DO NOT modify files during analysis**
- **DO NOT skip invalid YAML — add warnings but continue scanning**
- **DO NOT make assumptions — derive all metrics from actual file content**

### 7. Post-Execution Checks

**Check for extension hooks (after analysis)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_analyze` key.
- Filter out disabled hooks and process executable hooks using the same pattern as Pre-Execution Checks.
