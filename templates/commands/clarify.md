---
description: "Identify and reduce ambiguity in FORGE artifacts through structured, sequential questioning. Maximum 5 questions per session, each with recommended answers."
handoffs:
  - label: Form Hypothesis
    agent: forge.hypothesize
    prompt: Form a hypothesis using the clarified information
    send: true
  - label: Create Feature
    agent: forge.feature
    prompt: Create a feature using the clarified information
    send: true
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --paths-only
  ps: scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before clarification)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_clarify` key.
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

**IMPORTANT**: You are the AI agent executing this workflow. Do NOT ask the user to perform file operations.

### 1. Identify Target Artifact

**Parse `$ARGUMENTS`** for artifact type and ID:
- Pattern: `sig-*`, `hyp-*`, `dec-*`, `fea-*` IDs
- Pattern: `/forge.clarify <type>` where type is one of: `signal`, `hypothesis`, `decision`, `feature`

**If artifact ID specified**:
```
path = .forge/{type}s/{id}.yaml
```
Check if file exists. If missing: ERROR "Artifact {id} not found." STOP.

**If no ID specified but type provided**:
- Scan `.forge/{type}s/` for artifacts with `status: draft`
- If exactly 1: Auto-select it
- If multiple: List with IDs and names, ask user to choose
- If zero: ERROR "No draft {type}s found."

**If neither ID nor type provided**:
- Scan all artifact directories
- Find the most recently created artifact (newest `created_at` across all files)
- Auto-select it and report: "Clarifying most recent artifact: {id}"

### 2. Perform Ambiguity Scan

Load the artifact and scan for underspecified areas using type-specific checks:

**For Signals**:
- `observation` — is it specific (not vague like "users are unhappy")? Check word count: if <15 words, flag as vague.
- `signal.category` — is it assigned to a concrete category?
- `signal.source.type` — is source type documented?
- `signal.affected_dimensions` — are user, frequency, severity all defined?
- `signal.evidence` — is at least 1 piece of evidence provided?

**For Hypotheses**:
- `hypothesis.statement` — does it contain all 4 components? Check for: CHANGE, USERS, OUTCOME, REASONING. Count missing components.
- `hypothesis.validation_criteria.primary_metric` — is it defined with name, target, direction?
- `hypothesis.validation_criteria.guardrail_metrics` — are guardrails defined?
- `hypothesis.falsification_criteria` — is at least 1 criterion defined?
- `hypothesis.unknowns.known_unknowns` — is at least 1 unknown documented?

**For Decisions**:
- `decision.rationale` — is rationale provided (>20 chars)?
- `decision.alternatives_considered` — are at least 2 alternatives listed?
- `decision.reversibility.type` — is reversibility assessed?
- `decision.assumptions` — is at least 1 assumption documented?

**For Features**:
- `feature.scope.includes` / `feature.scope.excludes` — are both defined?
- `feature.journeys` — is at least 1 journey with GIVEN/WHEN/THEN defined?
- `feature.journeys[].acceptance_criteria` — is at least 1 AC per journey defined?
- `feature.observability.events_to_track` — are events defined?

Generate an ambiguity score: `(total gaps found) / (total checks)`.
- If score is 0: Report "No critical ambiguities detected." STOP.
- If score is >0: Proceed to generate questions

### 3. Generate Clarification Questions

From the gaps identified in step 2, generate up to 5 questions. Prioritize by:
1. Impact on downstream decisions (scope > security > UX > technical)
2. Ambiguity severity (completely missing > vague > could be clearer)
3. Blocks to progress (required fields > optional fields)

**Question Format**:
- Each question MUST be answerable with a short multiple-choice selection (2-5 options) OR a short answer (≤5 words)
- Include a **recommended answer** based on best practices and context
- Use exactly this format:

```
**Q1: {Question}**

**Recommended**: Option {X} - {brief reasoning}

| Option | Description |
|--------|-------------|
| A | {Option A description} |
| B | {Option B description} |
| C | {Option C description} |
| Short | Provide a different short answer (≤5 words) |

You can reply with the option letter (e.g., "A"), accept the recommendation by saying "yes", or provide your own answer.
```

**DO NOT reveal future questions. DO NOT show all questions at once.**

### 4. Sequential Questioning (Interactive)

**Present ONE question at a time**:
1. Show the question with recommended answer and options
2. Wait for user response
3. On response:
   - If "yes", "recommended", "suggested": Use your recommended answer
   - If option letter ("A", "B", etc.): Use that option
   - If custom answer: Validate it fits constraints, then use it
4. **Immediately update the artifact file** with the clarification:
   - Read the current file
   - Apply the change to the relevant field
   - Add a `## Clarifications` section if not present
   - Add `### Session YYYY-MM-DD` subsection
   - Append: `- Q: {question} → A: {answer}`
   - Write the file back
5. Move to the next question

**Stop conditions**:
- All 5 questions asked
- User signals "done", "stop", "proceed"
- No more critical ambiguities (all gaps resolved)

### 5. Validate Updates

After all clarifications applied, re-validate the artifact:
- Re-check the same gaps from step 2
- If any gaps remain (and max questions not reached), generate remaining questions
- If max questions reached, report unresolved items

### 6. Report Completion

```
## Clarification Session Complete

**Artifact**: {id}
**Sections Updated**: {list of sections}
**Questions Asked**: {N}/{5 max}
**Resolved**: {N} gaps closed
**Unresolved**: {N} gaps remaining (requires another session)

---

**Next steps**:
- Proceed to `/forge.hypothesize` or `/forge.feature`
- Run `/forge.check` to verify artifact health
```

### 7. Post-Execution Checks

**Check for extension hooks (after clarification)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_clarify` key.
- Filter out disabled hooks and process executable hooks using the same pattern as Pre-Execution Checks.

## Quick Guidelines

- **DO NOT ask the user to update files** — apply clarifications directly
- **DO NOT reveal future questions** — present one at a time
- **DO NOT exceed 5 questions** per session
- **DO NOT ask about things already specified** — only ask about genuine gaps
- **DO recommend answers** — never present options without stating your recommendation
- **DO update the artifact immediately** after each answer — don't batch updates at the end
