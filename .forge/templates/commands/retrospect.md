---
description: "Run a FORGE retrospective — review releases, hypothesis outcomes, decision validity, and generate new signals from learnings. Closes the feedback loop by transforming outcomes into new signals."
handoffs:
  - label: Capture New Signals
    agent: forge.signal
    prompt: Capture signals from the retrospective learnings
    send: true
  - label: Update Constitution
    agent: forge.constitution
    prompt: Update the constitution based on retrospective findings
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before retrospective)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_retrospect` key.
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally.
- Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
- For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
  - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
  - If the hook defines a non-empty `condition`, skip the hook and leave condition evaluation to the HookExecutor implementation
- For each executable hook, output the following based on its `optional` flag:
  - **Optional hook** (`optional: true`): Output with prompt for user execution
  - **Mandatory hook** (`optional: false`): Execute automatically and wait for result
- If no hooks are registered or `.forge/extensions.yml` does not exist, skip silently

## Outline

**IMPORTANT**: You are the AI agent executing this workflow. Do NOT ask the user to perform file operations. Read, analyze, and generate artifacts autonomously. Only involve the user for evaluations requiring human judgment (e.g., "Was this hypothesis validated?").

### 1. Setup

1. Ensure `.forge/retrospectives/` directory exists: `mkdir -p .forge/retrospectives/`
2. Ensure `.forge/signals/` directory exists (new signals will be generated here).
3. Generate retrospective ID: `rsp-{8-char-nanoid}`

### 2. Load Context

**Parse `$ARGUMENTS`** for:
- Release reference (`rel-*` ID)
- Sprint/cycle identifier

**If `rel-*` ID in arguments**: Load `.forge/releases/{id}.yaml`
- Extract: `release.features[]`, `release.experiments[]`, `release.hypotheses_under_test[]`, `release.name`

**If no release ID**: Scan `.forge/releases/` for releases with `status: deployed` or `status: monitoring`.
- List available releases:
  ```text
  Recent Releases:
  - rel-abc1: v2.1.0 "Export Sprint" (status: monitoring, created: 2024-03-15)
  - rel-xyz2: v2.0.0 "Q1 Refresh" (status: deployed, created: 2024-02-01)
  ```
- Ask user to select one or provide a custom scope description.

**Load linked artifacts**:
- For each feature `fea-{id}` in the release: Load `.forge/features/{id}.yaml`
  - Extract: `feature.name`, `feature.hypothesis`, `status`
- For each experiment `exp-{id}` in the release: Load `.forge/experiments/{id}.yaml`
  - Extract: `experiment.type`, `experiment.hypothesis`, `experiment.results`
- For each hypothesis `hyp-{id}`: Load `.forge/hypotheses/{id}.yaml`
  - Extract: `hypothesis.statement`, `hypothesis.validation_criteria`, `status`

**If no release selected and no artifacts found**: Use the arguments as the retro scope description.

### 3. Review What Happened

**Auto-compile delivery status** from feature files:

```text
## Delivered
| Feature | Status | Linked Hypothesis | Notes |
|---------|--------|-------------------|-------|
| Export Navigation Shortcut | deployed | hyp-b2mp | Shipped to 100% |

## Not Delivered
| Feature | Status | Reason |
|---------|--------|--------|
| Dashboard Redesign | building | Scope increased, deferred to next release |

## Unexpected
```
Ask user to fill in the "Unexpected" section:
- "What happened that we didn't plan for?"
- "Positive surprises?"
- "Negative surprises?"
- "Process issues?"

### 4. Review Hypothesis Outcomes

For each hypothesis tested (linked to features or experiments in scope):

**Auto-load experiment results** if the experiment has data:
- Read `experiment.results.status`: `completed`, `stopped_early`, `running`
- Read `experiment.results.conclusion`: `validated`, `invalidated`, `inconclusive`, `needs_more_data`

**For each hypothesis, present for evaluation**:
```
## Hypothesis Review: hyp-{id}

**Statement**: {first 100 chars of statement}

**Linked Experiment**: exp-{id} (status: {experiment status})
**Conclusion**: {experiment conclusion} {or "No experiment data available"}

**Validation Criteria**:
- Primary: {metric} — target: {target} — {actual or "awaiting data"}
- Guardrails: {status}

**Was this hypothesis validated, invalidated, or inconclusive?**
```
Wait for user judgment for each hypothesis.

**Update the hypothesis file**:
- Open `.forge/hypotheses/{id}.yaml`
- Update `status` to: `validated`, `invalidated`, or `inconclusive`
- Add outcome notes to the file

### 5. Review Decision Validity

**Scan `.forge/decisions/`** for decisions whose review trigger has passed:
- Check `decision.review_trigger.date` — if past due, flag for review
- Check `decision.review_trigger.metric_threshold` — if threshold met, flag

**List decisions needing review**:
```text
## Decisions Due for Review
| Decision | Created | Review Trigger | Still Valid? |
|----------|---------|----------------|--------------|
| dec-abc1: PostgreSQL choice | 2024-01-15 | 2024-07-15 (scheduled) | ? |
| dec-xyz2: Export API design | 2024-03-01 | Data volume >5TB | ? (currently 3.2TB) |
```

For each, ask user: "Is this decision still valid? (yes / no / needs update)"

**Document outcomes** in the decision files — add a `last_reviewed` field if not present.

### 6. GENERATE NEW SIGNALS FROM LEARNINGS (MANDATORY)

**This is the most important step — it closes the FORGE feedback loop.**

Analyze the retrospective findings and generate signal artifacts for each actionable learning:

**Auto-detect signal candidates** from:
1. **Hypothesis outcomes**: An invalidated hypothesis IS a signal (something unexpected happened)
2. **Unexpected events**: Positive and negative surprises often hide signals
3. **Decision changes**: If a decision is no longer valid, that generates a signal
4. **Process improvements**: What should change about how the team works
5. **Unknown unknowns**: Things discovered that weren't even on the radar

For each candidate, create a `.forge/signals/` entry:

```yaml
forge_type: signal
id: sig-{nanoid}
version: "1.0.0"
created_at: {ISO8601}
created_by: "{user}"
status: raw

signal:
  category: team_observation  # default for retro signals
  source:
    type: team_retro
    reference: "rsp-{nanoid}"
    confidence: 0.8
  observation: |
    {the learning or discovery in 1-2 sentences}
  affected_dimensions:
    - users: "team"
      frequency: always
      severity: medium
links:
  decisions: []
  features: []
  experiments: []
```

**Present each candidate**: "I've identified a signal from [source]: `{observation}`. Create this signal? (yes / no / modify)"

**If yes**: Write the signal file immediately.
**If modify**: Accept user edits, then write the file.
**If no**: Document why (e.g., "per-process observation, no user impact").

**Requirement**: At least 1 signal MUST be generated per retrospective. If no candidates are found, ask the user directly: "What did we learn that should inform future decisions?"

### 7. Document Unknown Unknowns

Ask: "What did we NOT know that we didn't know? Any discoveries that surprised the team?"

These are the most valuable retro outputs — things the team wasn't even aware were blind spots.

If user provides them: Include in the retro artifact.
If user says none: Document "No unknown unknowns surfaced this cycle."

### 8. Retrospective Quality Validation

Create validation checklist at `.forge/retrospectives/rsp-{nanoid}-checklist.md`:

```markdown
# Retrospective Quality Checklist: rsp-{nanoid}

- [ ] **RSP-001**: Release/sprint being reviewed is identified
- [ ] **RSP-002**: Delivered and not-delivered features are listed
- [ ] **RSP-003**: At least 1 hypothesis outcome is documented
- [ ] **RSP-004**: Decision validity is reviewed (at least 1 check if decisions exist)
- [ ] **RSP-005**: New signals are generated from learnings (at least 1)
- [ ] **RSP-006**: Unknown unknowns are documented (or explicitly noted as none)
- [ ] **RSP-007**: All linked hypothesis files updated with outcomes
- [ ] **RSP-008**: All generated signal files are valid YAML
```

Run validation (max 2 iterations). RSP-005 is required — if no signals exist after validation, re-attempt signal generation.

### 9. Create the Retrospective File

Write `.forge/retrospectives/rsp-{nanoid}.yaml`:

```yaml
forge_type: retrospective
id: rsp-{nanoid}
version: "1.0.0"
created_at: {ISO8601}

retrospective:
  release: rel-{id}
  sprint: "{sprint or cycle name}"

  what_happened:
    delivered:
      - fea-{id}: "{feature name}"
    not_delivered:
      - fea-{id}: "{feature name} — {reason}"
    unexpected:
      - "{unexpected event}"

  hypothesis_outcomes:
    - hypothesis: hyp-{id}
      outcome: {validated | invalidated | inconclusive | not_measurable}
      evidence: "{summary of evidence}"

  decision_reviews:
    - decision: dec-{id}
      still_valid: true | false
      new_information: "{relevant new info}"

  generated_signals:
    - sig-{id}: "{observation}"

  unknown_unknowns_discovered:
    - "{discovery}"

owner: {user or "anonymous"}
status: completed
```

### 10. Report Completion

```
## Retrospective Completed: rsp-{nanoid}

**File**: .forge/retrospectives/rsp-{nanoid}.yaml

**Release Reviewed**: {release name}
**Hypothesis Outcomes**: {N} reviewed ({M} validated, {P} invalidated, {Q} inconclusive)
**Decisions Reviewed**: {N}
**New Signals Generated**: {N}
**Unknown Unknowns**: {N} discovered

**Quality Score**: {N}/8 checks passed

---

**New Signals Created**:
{sig-id}: {observation summary}

**Suggested next steps**:
- Review the new signals and prioritize them with `/forge.ai.analyze`
- `/forge.constitution` — Update principles based on learnings
- `/forge.hypothesize sig-{id}` — Form hypotheses from new signals
- Take action on decisions flagged as no longer valid
```

### 11. Post-Execution Checks

**Check for extension hooks (after retrospective)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_retrospect` key.
- Filter out disabled hooks and process executable hooks using the same pattern as Pre-Execution Checks.

## Quick Guidelines

- **Close the Loop**: Every retro MUST generate new signals — this is the mechanism that turns experience into improvement. If no signals are generated, the retro is incomplete.
- **Hypothesis Outcomes**: Were we right? Wrong? Inconclusive? Update the hypothesis files to reflect reality
- **Decision Reviews**: Don't let bad decisions persist — check if decisions are still valid given new information
- **Unknown Unknowns**: The most valuable retro discoveries are things you didn't know to look for
- **Action Items > Blame**: Focus on systemic improvements, not individual failures — signal categories should reflect this
- **DO NOT ask the user to create files or run commands**
- **DO NOT skip signal generation — this is MANDATORY (RSP-005)**
- **DO NOT leave hypothesis statuses un-updated — always write outcomes back**
