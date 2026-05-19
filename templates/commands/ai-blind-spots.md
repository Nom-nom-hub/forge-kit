---
description: "AI detection of unknown unknowns in FORGE artifacts — identifies hidden assumptions, external factors, missing stakeholders, and data gaps."
handoffs:
  - label: Capture New Signal
    agent: forge.signal
    prompt: Capture the blind spots found as new signals
    send: true
  - label: Clarify Artifact
    agent: forge.clarify
    prompt: Address the blind spots found in the artifact
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before AI blind spot detection)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_ai_blind_spots` key.
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

**IMPORTANT**: You are the AI agent executing this workflow. Do all scanning, analysis, and reporting yourself. Be explicit about what you know vs. what you're guessing.

### 1. Identify Target

**Parse `$ARGUMENTS`** for artifact ID:
- Pattern: `sig-*`, `hyp-*`, `dec-*`, `fea-*`, `exp-*`

**If ID provided**:
```
path = .forge/{type}s/{id}.yaml
```
Check file exists. If missing: ERROR "Artifact {id} not found." STOP.
Load the artifact and its linked artifacts (traverse links).

**If no ID provided**:
- Scan ALL artifact directories under `.forge/`
- Load every `.yaml` file
- Analyze all artifacts for collective blind spots

### 2. Blind Spot Analysis per Category

**Hidden Assumptions** — scan the artifact for unstated beliefs:
1. Read the artifact's core content (statement, observation, rationale)
2. Identify statements that are assumed true without evidence
3. Rate risk:
   - HIGH: Assumption is core to validity AND has no evidence
   - MEDIUM: Assumption is secondary AND has partial evidence
   - LOW: Assumption is minor OR well-supported
4. Suggest evidence that would validate the assumption

Patterns to detect:
- "We assume [X] is the root cause" without evidence
- "We assume [X] will not change" in a volatile domain
- "We assume users will [behavior]" without usability data

**External Factors** — what outside forces could invalidate this:
1. Scan for domain keywords that suggest external dependencies
2. Match against common risk categories:
   - `regulatory`: GDPR, HIPAA, SOX, CCPA, data privacy
   - `market`: competitor moves, pricing changes, adoption shifts
   - `technology`: dependency lifecycle, API deprecations, framework changes
   - `organizational`: team changes, priority shifts, budget changes
3. Rate impact: HIGH (blocking) / MEDIUM (significant change) / LOW (minor impact)
4. Suggest monitoring mechanism for each factor

**Missing Stakeholders** — who's not represented:
1. Analyze user segments mentioned vs. not mentioned
2. Consider these common overlooked stakeholders:
   - Enterprise IT admins (need control, audit, permissions)
   - Customer support (need to understand and explain the feature)
   - QA / Testing (need test environments, test data)
   - Compliance / Legal (need data flow documentation)
   - Operations / SRE (need runbooks, monitoring, alerting)
3. Rate impact based on how significantly the artifact would change if they were included

**Unconsidered Scenarios** — edge cases not explored:
1. Scan for these common missing scenarios:
   - What happens at max scale (users, data, traffic)?
   - What happens when external dependencies fail? (timeout, degrade, error)
   - What happens under adversarial conditions? (abuse, attack, edge input)
   - What happens during transitions? (migration, upgrade, rollback)
   - What happens with partial data? (incomplete, delayed, corrupt)
2. Rate each: will likely occur / could occur / unlikely but impactful

**Data Gaps** — what data would change priority:
1. For each decision or recommendation in the artifact:
   - What data would cause us to change our mind?
   - Do we have that data?
2. Rate gap severity: BLOCKING (can't proceed without) / SIGNIFICANT (would change approach) / INFORMATIONAL (nice to have)

### 3. Generate Report

```
## AI Blind Spot Detection: {artifact ID}

**Analyzed**: {filename} (+ {N} linked artifacts)

### Hidden Assumptions
| # | Assumption | Where | Risk | Evidence Needed |
|---|------------|-------|------|-----------------|
| 1 | Export is primary CSAT driver | rationale | HIGH | Tag support tickets by primary complaint for 30 days |

### External Factors
| # | Factor | Category | Impact | Monitoring |
|---|--------|----------|--------|------------|
| 1 | New data privacy regulation | regulatory | HIGH | Track regulatory calendar quarterly |

### Missing Stakeholders
| # | Stakeholder | Why They Matter | Impact If Overlooked |
|---|-------------|-----------------|---------------------|
| 1 | Enterprise IT admins | May need to control export permissions per team | Feature unusable for enterprise segment |

### Unconsidered Scenarios
| # | Scenario | Category | Likelihood |
|---|----------|----------|------------|
| 1 | Export takes >30 seconds for large datasets | scale edge case | likely |
| 2 | User has 10,000+ records and export stalls | data threshold | could occur |

### Data Gaps
| # | Gap | Severity | Data Source |
|---|-----|----------|-------------|
| 1 | No abandonment-rate data for current export flow | SIGNIFICANT | Analytics event tracking |

### Confidence Statement
- **High confidence** in assumptions and data gaps (structural patterns)
- **Medium confidence** in external factors and missing stakeholders (common patterns)
- **Low confidence** in scenario completeness (domain-specific blind spots require team expertise)

---

**Next steps**:
- `/forge.signal` — Capture identified blind spots as new signals
- `/forge.clarify {id}` — Address high-risk assumptions
- Review with team for domain-specific blind spots
```

## Quick Guidelines

- **Unknown Unknowns Are Inherent**: The most valuable blind spots are things the team didn't even know to look for — but by definition, this analysis can only find structural patterns, not domain-specific surprises
- **Assumptions Are the Riskiest**: Hidden assumptions that are core to artifact validity should be addressed before anything else
- **External Factors Change Fast**: Regulatory and market factors can invalidate decisions quickly — always suggest monitoring mechanisms
- **Missing Stakeholders Compound**: Who's NOT in the room matters more than who is — consider each stakeholder class independently
- **DO NOT claim completeness** — blind spot detection can't be comprehensive
- **DO NOT treat detected blind spots as proven risks** — they are hypotheses about risks
- **DO signal captured blind spots as new FORGE signals** — close the loop

### 4. Post-Execution Checks

**Check for extension hooks (after AI blind spot detection)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_ai_blind_spots` key.
- Filter out disabled hooks and process executable hooks using the same pattern as Pre-Execution Checks.
