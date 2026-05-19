---
description: "Generate FORGE quality checklists — 'unit tests for requirements writing.' Validates artifact completeness, clarity, consistency, and coverage across any FORGE domain."
handoffs:
  - label: Run Analysis
    agent: forge.analyze
    prompt: Analyze the artifacts against the generated checklist
    send: true
  - label: Clarify Issues
    agent: forge.clarify
    prompt: Help clarify the issues identified by the checklist
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before checklist generation)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_checklist` key.
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

**IMPORTANT**: You are the AI agent executing this workflow. Do all artifact scanning, item generation, and file writing yourself. Do NOT ask the user to create files.

**CRITICAL CONCEPT**: Checklists are UNIT TESTS FOR REQUIREMENTS WRITING. They validate the quality, clarity, and completeness of FORGE artifacts — NOT the implementation.

### 1. Determine Checklist Type

**Parse `$ARGUMENTS`** for checklist type:
- `--signal`: Generate signal quality checklist
- `--hypothesis`: Generate hypothesis quality checklist
- `--decision`: Generate decision quality checklist
- `--feature`: Generate feature readiness checklist
- `--release`: Generate release readiness checklist
- `--compliance`: Generate FORGE methodology compliance checklist

If no type specified: Default to `compliance`. If user provided an artifact ID (sig-*, hyp-*, etc.), auto-detect the type from the ID prefix.

**If an ID is provided**: Load `.forge/{type}s/{id}.yaml`. If file missing: ERROR "Artifact {id} not found." STOP.

If no ID provided and type is not `compliance`: Ask the user once: "Which [type] should I check? (provide the ID or press Enter to scan all)" If empty response, scan all artifacts of that type.

### 2. Load Relevant Context

**For single-artifact checks**:
- Load the specific artifact file
- If the artifact has links, also load linked artifacts for cross-reference validation

**For compliance checks**:
- Scan all `.forge/` directories and load every artifact

**For cross-artifact checks (release)**:
- Load the release manifest
- Load all linked features, experiments

### 3. Generate Quality Items

Generate items as QUESTIONS about requirement quality. Each item MUST test the REQUIREMENTS themselves, not the implementation:

**Signal Quality** (tests if the signal is well-written):
```markdown
## Signal Quality
- [ ] CHK001 - Is the observation concrete and specific (not vague like 'users are unhappy')? [Clarity]
- [ ] CHK002 - Is the observation free of interpretation (describes WHAT, not WHY)? [Completeness]
- [ ] CHK003 - Is the source type documented? [Completeness]
- [ ] CHK004 - Is there at least one piece of evidence? [Coverage]
- [ ] CHK005 - Are affected dimensions defined (users, frequency, severity)? [Coverage]
- [ ] CHK006 - Is the signal file valid YAML? [Structure]
```

**Hypothesis Quality**:
```markdown
## Hypothesis Quality
- [ ] CHK001 - Does the statement follow the template (CHANGE + USERS + OUTCOME + REASONING)? [Structure]
- [ ] CHK002 - Is the primary metric defined with name and direction? [Measurability]
- [ ] CHK003 - Are guardrail metrics defined (what must NOT regress)? [Completeness]
- [ ] CHK004 - Are falsification criteria specific and testable? [Testability]
- [ ] CHK005 - Are known unknowns identified? [Completeness]
- [ ] CHK006 - Is the hypothesis linked to at least 1 signal? [Traceability]
```

**Decision Quality**:
```markdown
## Decision Quality
- [ ] CHK001 - Is the decision statement clear and specific? [Clarity]
- [ ] CHK002 - Are at least 2 alternatives documented? [Completeness]
- [ ] CHK003 - Is reversibility assessed (type + cost)? [Completeness]
- [ ] CHK004 - Is at least 1 assumption documented? [Coverage]
- [ ] CHK005 - Is the rationale provided (>20 chars)? [Clarity]
- [ ] CHK006 - Is a review trigger set? [Completeness]
```

**Feature Readiness**:
```markdown
## Feature Readiness
- [ ] CHK001 - Are scope boundaries defined (includes AND excludes)? [Completeness]
- [ ] CHK002 - Does each user journey have acceptance criteria? [Coverage]
- [ ] CHK003 - Are acceptance criteria testable (specific, measurable)? [Clarity]
- [ ] CHK004 - Is the technical surface area documented? [Completeness]
- [ ] CHK005 - Are observability requirements defined? [Completeness]
- [ ] CHK006 - Is there a feature flag strategy? [Completeness]
- [ ] CHK007 - Is the feature linked to a hypothesis? [Traceability]
- [ ] CHK008 - Is the ICE score populated? [Completeness]
```

**Release Readiness**:
```markdown
## Release Readiness
- [ ] CHK001 - Is the release narrative written? [Clarity]
- [ ] CHK002 - Are rollout stages defined with gate criteria? [Completeness]
- [ ] CHK003 - Are rollback triggers defined per stage? [Coverage]
- [ ] CHK004 - Is the monitoring window configured? [Completeness]
- [ ] CHK005 - Are auto-rollback conditions defined? [Coverage]
- [ ] CHK006 - Is the readiness checklist populated? [Completeness]
- [ ] CHK007 - Is there a communications plan? [Completeness]
```

### 4. Generate Checklist File

- Ensure `.forge/checklists/` directory exists: `mkdir -p .forge/checklists/`
- Determine filename: `{id or type}-quality.md` (e.g., `sig-a3kx-quality.md` or `hypothesis-quality.md`)
- Write file with content from step 3

**File handling**:
- If file does NOT exist: Create new, start IDs at CHK001
- If file exists: Append new items, continue numbering from last CHK ID
- Never delete or replace existing checklist content

### 5. Run Initial Assessment

After generating the checklist, perform an initial pass against the artifact:
- Read the artifact file
- For each checklist item, determine if it passes or fails
- Mark: `[X]` for pass, `[ ]` for fail
- Write the initial assessment back to the checklist file

If running for a single artifact with an ID, you can auto-assess. If running compliance scan (no specific ID), mark all as `[ ]` for manual review.

### 6. Report Completion

```
## Checklist Generated

**File**: .forge/checklists/{filename}.md
**Type**: {checklist type}
**Items**: {N}
**Auto-Assessment**: {N} pass / {N} fail / {N} pending review

**Failed Items**:
{list failed items if any}

---

**Next steps**:
- Review and check off each item with the team
- Run `/forge.analyze` for deeper cross-artifact analysis
- Run `/forge.clarify` to address failed items
```

## Quick Guidelines

- **Unit Tests for Requirements**: Checklist items are QUESTIONS about requirement quality, NOT implementation tasks — test the WHAT, not the HOW
- **Be Specific**: Each item must be a single, testable question — "Is the observation specific?" not "Is the artifact good?"
- **Append Never Replace**: Always append new items to existing checklists, never replace them
- **Auto-Assess When Possible**: For single-artifact checks, run an initial pass and mark pass/fail
- **DO NOT ask the user to create files** — generate and write checklists yourself
- **DO NOT include implementation-specific items** — checklists validate requirements, not code

### 7. Post-Execution Checks

**Check for extension hooks (after checklist generation)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_checklist` key.
- Filter out disabled hooks and process executable hooks using the same pattern as Pre-Execution Checks.
