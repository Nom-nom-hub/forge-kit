---
description: "Form a FORGE hypothesis from one or more signals. Transforms raw observations into a testable belief with validation criteria, falsification conditions, and known unknowns."
handoffs:
  - label: Record Decision
    agent: forge.decide
    prompt: Record a decision to act on the hypothesis I just formed
    send: true
  - label: Create Feature
    agent: forge.feature
    prompt: Create a feature from the hypothesis I just formed
    send: true
  - label: Clarify Hypothesis
    agent: forge.clarify
    prompt: Clarify the hypothesis I just formed
    send: true
scripts:
  sh: scripts/bash/check-prerequisites.sh --json
  ps: scripts/powershell/check-prerequisites.ps1 -Json
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before hypothesis formation)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_hypothesize` key.
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

**IMPORTANT**: You are the AI agent executing this workflow. Do NOT ask the user to do steps you can do yourself. Only involve the user for decisions that require human judgment (e.g., choosing between genuinely ambiguous options).

### 1. Setup

1. Run `{SCRIPT}` from repo root (if available) to verify project state. Parse any JSON output for `FORGE_DIR`.
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\\''m Groot'.
   - If the script fails or is unavailable, proceed with defaults (`FORGE_DIR = .forge`).
2. Ensure `.forge/hypotheses/` directory exists. If not, create it: `mkdir -p .forge/hypotheses/`.
3. Generate hypothesis ID: `hyp-{8-char-nanoid}`.

### 2. Load Signal Context

Parse signal references from `$ARGUMENTS`:
- Look for signal IDs (pattern: `sig-[a-z0-9]+`) in the arguments
- If signal IDs found: Read each referenced `.forge/signals/{id}.yaml` file
- If no signal IDs found: Scan `.forge/signals/` for signals with `status: raw` or `status: validated`

**If no signals exist** (directory missing or empty):
- ERROR: "No signals found. Please capture a signal first using `/forge.signal`"
- STOP execution and suggest running `/forge.signal`

**If signals exist but none specified**:
- List available unlinked signals (those without linked hypotheses):
  ```
  Available Signals:
  - sig-a3kx: "users can't find the export button" (user_pain, high)
  - sig-b7mq: "Where is the dashboard?" (user_pain, medium)
  - sig-c9np: "Navigation usability score: 2.1/5" (metric_anomaly, high)
  
  Which signal(s) should inform this hypothesis? (comma-separated IDs, or "all")
  ```
- Wait for user response

**If 1+ signal IDs found**: Read each signal file and extract:
- `observation` text
- `signal.category`
- `signal.affected_dimensions`
- `signal.evidence`

If any signal file cannot be read (missing, invalid YAML), skip it and warn the user.

### 3. Formulate the Hypothesis Statement

Parse `$ARGUMENTS` for an existing hypothesis statement. If arguments after any `sig-*` references contain a statement, use it as a starting point.

**If no hypothesis statement provided**: Generate one from the signal(s) using this process:

1. **Extract the problem**: From each signal's observation, identify the core problem statement (remove evidence, metadata, context).
2. **Identify the proposed change**: Generate a concrete change that addresses the problem:
   - Must be a specific action (e.g., "adding an Export button to the primary navigation")
   - NOT vague ("improving navigation") — if AI cannot generate a specific change, flag with `[NEEDS_CLARIFICATION: change]`
3. **Identify the target users**: From affected_dimensions or observation context:
   - Be specific about segments ("enterprise data analysts who export >50 reports/week")
   - Default to "affected users" if not specified
4. **Identify the expected outcome**: Generate a measurable target metric:
   - Must include metric name + direction + magnitude (e.g., "reduce related support tickets by 80%")
   - If cannot generate confidently, flag with `[NEEDS_CLARIFICATION: outcome]`
5. **Connect reasoning**: Explain why this change will produce this outcome, referencing signal evidence
6. **Draft the statement** in the template format:
   ```
   We believe [SPECIFIC CHANGE] for [SPECIFIC USERS] will result in [MEASURABLE OUTCOME] because [REASONING FROM SIGNALS].
   ```

**Present the draft to the user**:
```
## Hypothesis Draft

We believe adding an Export button to the primary navigation for enterprise data analysts
will result in reducing 'can't find export' support tickets by 80% because the export
feature currently requires 4 clicks through unintuitive menus.

**Does this look right?** (yes / modify / reject)
```

Wait for user response:
- `yes` or blank: Accept the draft
- `modify` or specific changes: Update the draft based on feedback
- `reject`: Ask "What would you change?", iterate max 2 times, then accept whatever version exists

### 4. Define Validation Criteria

Using the hypothesis statement, generate validation criteria:

**Primary Metric** (auto-generate from outcome in the statement):
- Extract metric name from the measurable outcome
- If "reduce [metric] by [X]%": Set target as `(1 - X/100) * current_baseline`
- If "increase [metric] to [X]": Set target as X
- If the metric cannot be extracted: Set `current_baseline: TBD`, `target: TBD`, `direction: increase`
- Timeframe default: `30 days post-launch`

**Secondary Metrics** (generate based on category):
- `user_pain`: ["CSAT score", "task completion rate", "time on task"]
- `metric_anomaly`: ["error rate", "p50 latency", "p99 latency"]
- `competitive`: ["feature adoption rate", "user retention"]
- `technical_debt`: ["build time", "test coverage", "deploy frequency"]
- Default: ["user satisfaction", "engagement rate"]

**Guardrail Metrics** (auto-generate for safety):
- Always include: ["Error rate (must not increase >5%)", "Page load time (must not increase >10%)"]

**Present to user for confirmation**: Show the criteria in a compact table, wait for confirmation.

### 5. Define Falsification Criteria

**Auto-generate** 2-3 falsification scenarios based on the hypothesis:

```text
This hypothesis would be WRONG if:
1. {metric} does not improve after {timeframe} — the root cause is elsewhere
2. {secondary effect} worsens while {primary metric} stays flat — the change addresses symptoms, not cause
3. {guardrail metric} degrades beyond {threshold} — the change introduces unacceptable tradeoffs
```

Example for an export button hypothesis:
```text
This hypothesis would be WRONG if:
1. Support tickets don't decrease within 30 days — the discoverability issue is not the root cause
2. Navigation click-through rate drops >10% — the nav change adds too much clutter
3. Users click Export but still can't complete the task — the button isn't the only friction point
```

Present to user: "I've drafted these falsification criteria. Would you like to add, remove, or modify any?"

### 6. Identify Known Unknowns

Analyze the hypothesis and linked signals, then **auto-generate** known unknowns:

For each assumption in the hypothesis:
- What are we assuming to be true?
- How risky? (high / medium / low)
- How can we resolve this?

**AI-assisted detection** — scan for these patterns:
- "You're assuming that the cause of [X] is indeed [Y]. Alternative: [Z] could be the cause."
- "You're assuming the metric accurately reflects user sentiment. Consider session replay data."
- "You're assuming users will notice the change. Consider A/B test visibility."

For each detected unknown:
- Rate its risk based on how core it is to the hypothesis validity
- Suggest a method to resolve it (interview, data analysis, prototype test, etc.)

Present to the user: "I've identified these assumptions in the hypothesis. Which need further investigation?"

### 7. Hypothesis Quality Validation

Create validation checklist at `.forge/hypotheses/hyp-{nanoid}-checklist.md`:

```markdown
# Hypothesis Quality Checklist: hyp-{nanoid}

- [ ] **HYP-001**: Statement follows the template structure (CHANGE + USERS + OUTCOME + REASONING)
- [ ] **HYP-002**: At least one signal is linked (signal IDs populated)
- [ ] **HYP-003**: Primary metric has at minimum a name and direction
- [ ] **HYP-004**: Falsification criteria are defined (at least 2 specific scenarios)
- [ ] **HYP-005**: Outcome is measurable with a specific metric (not vague like "improve UX")
- [ ] **HYP-006**: Known unknowns are identified (at least 1 if assumptions exist)
- [ ] **HYP-007**: Falsification criteria are specific and testable (not just "it doesn't work")
- [ ] **HYP-008**: All linked signal IDs exist and their files are valid
```

Run validation (max 2 iterations with fixes):
- Check each criterion, note pass/fail
- If any fail, attempt to fix automatically (auto-generate missing fields)
- If still failing after 2 iterations, report remaining issues

### 8. Create the Hypothesis File

Write `.forge/hypotheses/hyp-{nanoid}.yaml`:

```yaml
forge_type: hypothesis
id: hyp-{nanoid}
version: "1.0.0"
created_at: {ISO8601}

hypothesis:
  statement: |
    {the final accepted statement}

  validation_criteria:
    primary_metric:
      name: "{metric name}"
      current_baseline: {value or "TBD"}
      target: {value or "TBD"}
      direction: increase | decrease
      timeframe: "{timeframe}"
    secondary_metrics:
      - "{secondary metric 1}"
      - "{secondary metric 2}"
    guardrail_metrics:
      - name: "{guardrail}"
        threshold: "{threshold}"
    confidence_level: 0.95

  falsification_criteria:
    - "{falsification 1}"
    - "{falsification 2}"

  unknowns:
    known_unknowns:
      - assumption: "{assumption}"
        risk: high | medium | low
        how_to_resolve: "{method}"
    acknowledged_blind_spots: []

signals:
  - {signal-id-1}
  - {signal-id-2}
decisions: []
features: []

owner: {user or "anonymous"}
status: draft

confidence_score: 1.0
last_confidence_update: {ISO8601}
```

**DO NOT** ask the user to create this file — you are the agent, create it directly.

### 9. Update Signal Links

For each linked signal, open its `.forge/signals/{id}.yaml` file and add this hypothesis ID to the `links.hypotheses` array (create the key if it doesn't exist).

**DO NOT** skip this step — signals MUST be updated to maintain traceability.

### 10. Report Completion

```
## Hypothesis Formed: hyp-{nanoid}

**File**: .forge/hypotheses/hyp-{nanoid}.yaml

**Statement**: {first 120 chars of statement}...

**Linked Signals**: {N} signal(s) linked
**Validation Criteria**: {primary metric} → {direction} to {target}
**Falsification**: {N} criteria defined
**Known Unknowns**: {N} identified

**Quality Score**: {N}/8 checks passed

---

**Suggested next steps**:
- `/forge.decide hyp-{nanoid}` — Record a decision on how to proceed
- `/forge.feature hyp-{nanoid}` — Create a feature from this hypothesis
- `/forge.clarify hyp-{nanoid}` — Refine underspecified areas
- `/forge.ai.critique hyp-{nanoid}` — Get AI feedback on the hypothesis
```

### 11. Post-Execution Checks

**Check for extension hooks (after hypothesis formation)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_hypothesize` key.
- Filter out disabled hooks and process executable hooks using the same pattern as Pre-Execution Checks.

## Quick Guidelines

- **Hypothesis Framing**: Every feature is a hypothesis, not a requirement
- **Be Falsifiable**: If you can't prove it wrong, it's not a hypothesis — if you struggle to write falsification criteria, the hypothesis is probably not specific enough
- **Connect to Signals**: Every hypothesis must trace to at least one signal — update the signal links
- **Measurable Outcomes**: "Reduce tickets by 80%" not "Improve user experience" — if the outcome isn't measurable, flag it
- **Guardrails**: Always define what must NOT regress — auto-generate if the user doesn't provide them
- **DO NOT ask the user to create files or run commands** — execute them yourself
- **DO NOT skip validation** — always generate and check the checklist
- **DO NOT leave signal links empty** — update the linked signals
