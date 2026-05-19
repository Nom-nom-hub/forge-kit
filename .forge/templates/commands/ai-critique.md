---
description: "AI critique of FORGE artifacts — evaluates hypothesis falsifiability, decision quality, feature completeness, and flags weaknesses with recommendations."
handoffs:
  - label: Clarify Artifact
    agent: forge.clarify
    prompt: Address the issues found during AI critique
    send: true
  - label: Capture New Signal
    agent: forge.signal
    prompt: Capture the gaps found as new signals
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before AI critique)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_ai_critique` key.
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally.
- Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
- For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
  - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
  - If the hook defines a non-empty `condition`, skip the hook and leave condition evaluation to the HookExecutor implementation
- For each executable hook, output the following based on its `optional` flag:
  - **Optional hook** (`optional: true`):
    ```
    ## Extension Hooks

    **Optional Pre-Hook**: {extension}
    Command: `/{command}`
    Description: {description}

    Prompt: {prompt}
    To execute: `/{command}`
    ```
  - **Mandatory hook** (`optional: false`):
    ```
    ## Extension Hooks

    **Automatic Pre-Hook**: {extension}
    Executing: `/{command}`
    EXECUTE_COMMAND: {command}

    Wait for the result of the hook command before proceeding to the Outline.
    ```
- If no hooks are registered or `.forge/extensions.yml` does not exist, skip silently

## Outline

**IMPORTANT**: You are the AI agent executing this workflow. Do all artifact loading, analysis, and reporting yourself. Be transparent about confidence levels.

### 1. Identify Target

**Parse `$ARGUMENTS`** for artifact ID:
- Pattern: `sig-*`, `hyp-*`, `dec-*`, `fea-*`
- If no ID: Scan all `.forge/` directories, find the most recently created artifact.

**If ID provided**:
```
path = .forge/{type}s/{id}.yaml
```
Check file exists. If missing: ERROR "Artifact {id} not found. Available: [list recent artifacts]" STOP.

**Load the artifact**: Read the YAML file. If invalid YAML: ERROR "File exists but cannot be parsed. Manual review required."

### 2. Perform Structured Critique

Analyze the artifact against FORGE quality criteria. For each check, determine pass/fail AND confidence level.

**For Hypotheses**:
| Check | Method | Confidence Logic |
|-------|--------|-----------------|
| Falsifiability | Check if `falsification_criteria` contains specific, measurable scenarios | High if criteria exist and are actionable; Low if criteria are vague |
| Measurability | Check if `validation_criteria.primary_metric` has name AND target AND direction | High if all three present; Low if partial |
| Guardrails | Check if `guardrail_metrics` has ≥1 entry | High if ≥1; Low if empty |
| Unknowns | Check if `unknowns.known_unknowns` has ≥1 entry | High if ≥1; Low if empty |
| Specificity | Count words in `statement`. If <20 words, likely too vague | Medium — structural heuristic |

**For Decisions**:
| Check | Method | Confidence Logic |
|-------|--------|-----------------|
| Alternatives | Count `alternatives_considered`. Need ≥2 | High if ≥2; Medium if 1; Low if 0 |
| Reversibility | Check `reversibility.type` is set | High if set; Low if not |
| Assumptions | Check `assumptions` has ≥1 entry with monitoring | High if ≥1 with monitoring; Medium if ≥1 without |
| Consent | Check `consent_record.process` and `consented_at` | High if consent completed; Medium if pending; Low if not initiated |

**For Features**:
| Check | Method | Confidence Logic |
|-------|--------|-----------------|
| Scope clarity | Check `scope.includes` AND `scope.excludes` are non-empty | High if both present; Medium if one; Low if none |
| AC testability | Check each `acceptance_criteria[].description` for measurable language | High if >80% are measurable; Medium if >50%; Low if <50% |
| Observability | Check `observability.events_to_track` non-empty | High if >3 events; Medium if 1-3; Low if empty |
| Feature flag | Check `feature_flag.key` and `rollout_strategy` are set | High if both; Medium if one; Low if neither |

**For Signals**:
| Check | Method | Confidence Logic |
|-------|--------|-----------------|
| Specificity | Count words in `observation`. If <15 words, too vague | High if >20 words; Medium if 15-20; Low if <15 |
| No interpretation | Check if `observation` contains "because", "so that", "therefore" | High if no causal language; Low if causal language present |
| Evidence | Check `evidence` has ≥1 entry with content | High if evidence with content; Low if empty |
| Dimensions | Check `affected_dimensions` has users, frequency, severity | High if all three; Medium if 1-2; Low if empty |

### 3. Generate Report

```
## AI Critique: {artifact ID}

**Type**: {signal | hypothesis | decision | feature}
**Analyzed**: {filename}

### Summary
{artifact type}: {name or first 80 chars of statement/observation}
{N}/{M} checks passed (score: {percentage}%)

### Findings
| Check | Status | Severity | Recommendation | Confidence |
|-------|--------|----------|----------------|------------|
| Falsifiability | ❌ FAIL | HIGH | Define 2+ specific scenarios that would prove this wrong | High |
| Measurability | ✅ PASS | — | — | High |
| Guardrails | ❌ FAIL | MEDIUM | Add at least 1 guardrail metric | High |

### Strengths
- Well-structured validation criteria (measurable, specific)

### Recommendations
1. Add falsification criteria (HIGH priority) — currently empty
2. Define guardrail metrics (MEDIUM priority) — currently empty

### Confidence Statement
This critique is based on structural pattern matching against FORGE quality standards.
- **High confidence** in structural checks (field presence, format)
- **Medium confidence** in domain-specific recommendations (lacks full project context)
- **Low confidence** in semantic correctness (cannot validate domain logic)

---

**Next steps**:
- `/forge.clarify {id}` — Address the specific issues found
- Manual review of structural recommendations
```

## Quick Guidelines

- **Critique Is Structural, Not Semantic**: The AI judges FORGE artifact structure, not domain correctness — it can tell you if a hypothesis is measurable, not if it's the right hypothesis
- **Confidence Matters**: High-confidence findings are structural (field presence, format); low-confidence findings are semantic (domain logic) — treat them accordingly
- **Strengths Alongside Weaknesses**: Always report what's working well, not just what's broken
- **Recommendations Must Be Actionable**: "Add falsification criteria" not "Improve hypothesis" — each recommendation should have a clear next step
- **DO NOT modify artifacts** — critique is advisory, never write directly to artifact files
- **DO NOT make domain-specific recommendations without stating confidence**

### 4. Post-Execution Checks

**Check for extension hooks (after AI critique)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_ai_critique` key.
- Filter out disabled hooks and process executable hooks using the same pattern as Pre-Execution Checks.
