---
description: "Design a FORGE experiment — a time-boxed test of a hypothesis with rigorous variant design, metric configuration, and stop conditions. Transforms a feature hypothesis into a measurable, executable experiment."
handoffs:
  - label: Create Release Manifest
    agent: forge.release
    prompt: Plan a release that includes this experiment
    send: true
  - label: Run Retrospective
    agent: forge.retrospect
    prompt: Capture learnings from the experiment results
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before experiment design)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_experiment` key.
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally.
- Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
- For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
  - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
  - If the hook defines a non-empty `condition`, skip the hook and leave condition evaluation to the HookExecutor implementation
- For each executable hook, output the following based on its `optional` flag:
  - **Optional hook** (`optional: true`): Output the hook with a prompt for the user to execute
  - **Mandatory hook** (`optional: false`): Execute the hook automatically and wait for its result
- If no hooks are registered or `.forge/extensions.yml` does not exist, skip silently

## Outline

**IMPORTANT**: You are the AI agent executing this workflow. Do NOT ask the user to perform file operations or run commands. Generate, create, and validate artifacts autonomously.

### 1. Setup

1. Ensure `.forge/experiments/` directory exists: `mkdir -p .forge/experiments/`
2. Generate experiment ID: `exp-{8-char-nanoid}`

### 2. Load Context

**Parse `$ARGUMENTS`** for:
- Hypothesis reference (`hyp-*` ID)
- Feature reference (`fea-*` ID)
- Experiment type flag (`--type=ab_test|multivariate|canary|shadow|chaos|usability`)

**Load hypothesis** (resolve in order):
1. If `hyp-*` ID in arguments: Load `.forge/hypotheses/{id}.yaml`
2. If no hypothesis ID but `fea-*` in arguments: Load `.forge/features/{id}.yaml`, then follow its `hypothesis` link
3. If neither present: Scan `.forge/hypotheses/` for `status: draft` or `status: active`
   - If exactly 1: Auto-link it
   - If multiple: List with IDs and statements, ask user to choose
   - If zero: ERROR "No hypotheses available. Run `/forge.hypothesize` first."

**Load feature** (if `fea-*` ID in arguments):
- Load `.forge/features/{id}.yaml`
- Extract: `feature.scope`, `feature.journeys`, `feature.observability`

If hypothesis loaded but validation criteria are empty or "TBD":
- WARN: "The hypothesis has incomplete validation criteria. I'll use best-guess defaults, but consider running `/forge.hypothesize` to complete them first."
- Ask user: "Proceed with defaults? (yes / go back and fix)"

### 3. Determine Experiment Type

**Infer experiment type** from the feature/hypothesis context:

| Feature Context | Recommended Type |
|----------------|-----------------|
| UX change, UI placement, copy change | ab_test |
| Multi-component UX change | multivariate |
| Infrastructure, backend, migration | canary |
| Critical path, zero-downtime requirement | shadow |
| Reliability, resilience feature | chaos |
| New paradigm, first-of-its-kind UX | usability |

**If `--type` flag provided**: Use it directly.
**If no explicit type**: Recommend the best type with reasoning. Ask user to confirm.

### 4. Design Variants

**Generate variants** based on the experiment type:

**For `ab_test`** (default):
```yaml
design:
  variants:
    - id: control
      description: "Current behavior — no change from existing state"
      traffic_allocation: 0.5
    - id: treatment_a
      description: "{the proposed change from the hypothesis}"
      traffic_allocation: 0.5
```

**For `multivariate`**:
```yaml
design:
  variants:
    - id: control
      description: "Current behavior"
      traffic_allocation: 0.33
    - id: treatment_a
      description: "{variant 1 description}"
      traffic_allocation: 0.33
    - id: treatment_b
      description: "{variant 2 description}"
      traffic_allocation: 0.34
```

**For `canary`**:
```yaml
design:
  variants:
    - id: control
      description: "Existing stable version"
      traffic_allocation: 0.95
    - id: canary
      description: "New version with {change}"
      traffic_allocation: 0.05
```

**Auto-configure targeting**:
- Default segments: ["all users"]
- Default sample size: "1000 per variant (for 80% power at 5% significance)"
- Default power: 0.8
- Default significance: 0.05

**If the user provided targeting info in arguments**: Use it. Otherwise, present the default targeting and ask: "Does this targeting work for you?"

### 5. Define Metrics

**Extract primary metric** from the hypothesis validation criteria:
- If hypothesis has `validation_criteria.primary_metric`: Copy it directly
- If not: Extract from the hypothesis statement's outcome clause
- If neither: Ask "What metric determines success?"

**Generate secondary metrics** based on experiment type:
- `ab_test`: ["Click-through rate", "Task completion rate", "Time on task"]
- `canary`: ["Error rate", "p50 latency", "p99 latency"]
- `chaos`: ["Recovery time", "Error budget consumption"]
- `usability`: ["Task success rate", "Time to complete", "SUS score"]
- Default: ["User engagement", "Satisfaction score"]

**Auto-generate guardrail metrics**:
```yaml
guardrails:
  - name: "Error rate"
    threshold: "Must not increase >5% from baseline"
    alert_on_breach: true
  - name: "Page load time (p95)"
    threshold: "Must not increase >10% from baseline"
    alert_on_breach: true
```

Present metrics: "I've configured these metrics. Would you like to add, remove, or modify any?"

### 6. Set Duration and Stop Conditions

**Auto-calculate duration** based on experiment type:
- `ab_test`: Minimum 7 days, Maximum 30 days
- `multivariate`: Minimum 14 days, Maximum 45 days
- `canary`: Minimum 3 days, Maximum 14 days
- `shadow`: Minimum 7 days, Maximum 21 days
- `chaos`: Minimum 1 day, Maximum 7 days
- `usability`: Minimum 1 day, Maximum 5 days (session-based, not time-based)

**Generate stop conditions**:
```yaml
duration:
  minimum: "{minimum duration}"
  maximum: "{maximum duration}"
  stop_conditions:
    - type: significance_reached
      threshold: "p < 0.05"
    - type: sample_reached
      threshold: "1000 per variant"
    - type: harm_detected
      threshold: "Any guardrail breached"
    - type: time_limit
      threshold: "{maximum duration} elapsed"
```

Present: "Duration and stop conditions configured. Review and adjust?"

### 7. Experiment Quality Validation

Create validation checklist at `.forge/experiments/exp-{nanoid}-checklist.md`:

```markdown
# Experiment Quality Checklist: exp-{nanoid}

- [ ] **EXP-001**: Linked to a valid hypothesis (hyp-* ID populated)
- [ ] **EXP-002**: Experiment type is assigned
- [ ] **EXP-003**: At least 2 variants defined (control + treatment)
- [ ] **EXP-004**: Traffic allocations sum to 100%
- [ ] **EXP-005**: Primary metric is defined and matches hypothesis
- [ ] **EXP-006**: Guardrail metrics defined (at least 1)
- [ ] **EXP-007**: Minimum and maximum duration set
- [ ] **EXP-008**: Stop conditions defined (at least 2 types)
```

Run validation (max 2 iterations):
- Check each criterion
- Auto-fix where possible (e.g., missing guardrail → add default)
- If still failing after 2 iterations, report remaining issues

### 8. Create the Experiment File

Write `.forge/experiments/exp-{nanoid}.yaml`:

```yaml
forge_type: experiment
id: exp-{nanoid}
version: "1.0.0"
created_at: {ISO8601}

experiment:
  type: {ab_test | multivariate | canary | shadow | chaos | usability}
  hypothesis: hyp-{id}
  feature: fea-{id}

  design:
    variants:
      - id: control
        description: "Current behavior"
        traffic_allocation: {0.0-1.0}
      - id: treatment_a
        description: "{change description}"
        traffic_allocation: {0.0-1.0}
    targeting:
      segments:
        - "all users"
      exclusions: []
      sample_size_required: 1000
      power: 0.8
      significance_level: 0.05

  metrics:
    primary: "{metric name}"
    secondary:
      - "{secondary metric 1}"
    guardrails:
      - name: "{guardrail}"
        threshold: "{threshold}"
        alert_on_breach: true

  duration:
    minimum: "{duration}"
    maximum: "{duration}"
    stop_conditions:
      - type: significance_reached
        threshold: "p < 0.05"
      - type: sample_reached
        threshold: "{sample size}"
      - type: harm_detected
        threshold: "Guardrail breach"
      - type: time_limit
        threshold: "{max duration}"

  results:
    status: not_started
    stop_reason: null
    conclusion: null
    recommendation: null

owner: {user or "anonymous"}
status: designing
```

**DO NOT** ask the user to create this file.

### 9. Update Linked Artifacts

For linked feature `fea-{id}`: Open `.forge/features/{id}.yaml` and add this experiment ID to `experiments` (create key if missing).

For linked hypothesis `hyp-{id}`: Open `.forge/hypotheses/{id}.yaml` and add this experiment ID to `experiments`.

**DO NOT** skip traceability updates.

### 10. Report Completion

```
## Experiment Designed: exp-{nanoid}

**File**: .forge/experiments/exp-{nanoid}.yaml

**Type**: {experiment type}
**Hypothesis**: hyp-{id} ({first 80 chars of statement})
**Feature**: fea-{id} ({feature name})

**Variants**: {N} (control + {M} treatment)
**Traffic**: {control allocation}% control / {treatment allocation}% treatment
**Primary Metric**: {metric}
**Duration**: {min} to {max}
**Stop Conditions**: {N} defined

**Quality Score**: {N}/8 checks passed

---

**Suggested next steps**:
- Deploy the experiment variants and start collecting data
- `/forge.release exp-{nanoid}` — Plan a release that includes this experiment
- `/forge.retrospect exp-{nanoid}` — After the experiment concludes, capture learnings
```

### 11. Post-Execution Checks

**Check for extension hooks (after experiment design)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_experiment` key.
- Filter out disabled hooks and process executable hooks using the same pattern as Pre-Execution Checks.

## Quick Guidelines

- **Hypothesis-Linked**: Every experiment tests a specific hypothesis — if no hypothesis, block with an error
- **Control Matters**: Without a control variant, you can't measure impact — always require at least control + 1 treatment
- **Guardrails**: Always define what must NOT regress — auto-generate if user doesn't provide them
- **Stop Conditions**: Know when to stop before you start — include significance_reached, sample_reached, harm_detected, and time_limit
- **Statistical Rigor**: Default to 80% power, 5% significance, 1000/sample per variant — override for qualitative usability tests
- **DO NOT ask the user to create files or run commands**
- **DO NOT skip validation — always run the quality checklist**
- **DO NOT leave verification criteria "TBD" — ask the user once, then use best-guess defaults**
