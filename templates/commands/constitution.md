---
description: "Create or update the FORGE constitution — the governing principles that guide all development decisions. Defines signal-first, hypothesis framing, consent, and drift detection principles."
handoffs:
  - label: Capture Signal
    agent: forge.signal
    prompt: Capture the first signal based on our constitution principles
    send: true
  - label: Create Feature
    agent: forge.feature
    prompt: Create a feature that follows our constitution principles
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before constitution update)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_constitution` key.
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

**IMPORTANT**: You are the AI agent executing this workflow. Do all file reading, drafting, and writing yourself.

### 1. Setup

1. Ensure `.forge/memory/` directory exists: `mkdir -p .forge/memory/`
2. Load the existing constitution OR the template: `templates/constitution-template.md`
   - First check: `.forge/memory/constitution.md`
   - If missing: `templates/constitution-template.md` (project-relative path)
   - If both missing: Create from scratch with the FORGE default principles

### 2. Identify Placeholders

Read the template/constitution and extract ALL placeholder tokens of the form `[ALL_CAPS_IDENTIFIER]`:
- `[PROJECT_NAME]`, `[PRINCIPLE_1_NAME]`, `[PRINCIPLE_1_RULE]`, etc.
- Count total placeholders found

If `$ARGUMENTS` contain any values, use them to fill placeholders directly. Otherwise, proceed to step 3.

### 3. Collect / Derive Values

For each placeholder token, resolve in this order:
1. **From `$ARGUMENTS`**: If the user provided a value in arguments, use it
2. **From project context**: Read `README.md`, `package.json`, or other project files to infer values
3. **From defaults**: Use FORGE methodology defaults
4. **From user**: Only ask if no default exists AND the value materially changes the constitution

**Never ask more than 3 questions.** If more than 3 placeholders are unknown, make reasonable assumptions and document them with a `TODO` marker.

### 4. Draft Constitution Content

Structure the constitution:

1. **Preamble**: Project context, philosophy, and ratifying body
2. **Core Principles**: 3-9 articles tailored to the project
   - Each principle: Name | Statement (MUST/SHOULD/MAY) | Rationale
3. **Governance**: Amendment procedure, versioning, compliance review
4. **Version History**: Version, date, change description

**Default FORGE Principles** (use as base, customize per project):
1. **Signal-First**: Every feature MUST start with a documented signal
2. **Hypothesis Framing**: Every feature is framed as a testable hypothesis
3. **Consent Over Approval**: Decisions require consent, not approval
4. **Decisions Are Artifacts**: Every significant choice is recorded permanently
5. **Unknowns Are First-Class**: Explicitly track what you don't know
6. **Drift Detection**: Continuously measure implementation drift from intent

**Versioning**:
- MAJOR: Backward incompatible principle removal/redefinition
- MINOR: New principle/section added
- PATCH: Clarifications, wording fixes
- Initial: `v0.1.0` for new constitutions

### 5. Validate Constitution

Create validation checklist at `.forge/memory/constitution-check.md`:

```markdown
# Constitution Validation Checklist

- [ ] **CON-001**: Principles are declarative (MUST/SHOULD/MAY), not vague
- [ ] **CON-002**: Governance section defines amendment process
- [ ] **CON-003**: No placeholder tokens remain (unless explicitly deferred)
- [ ] **CON-004**: Version and dates are set
- [ ] **CON-005**: Principles are self-consistent (no contradictions)
- [ ] **CON-006**: Rationale is provided for each principle
- [ ] **CON-007**: Version history is up-to-date
```

Run validation (max 2 iterations):
- Check each criterion
- Fix placeholders, missing versions, contradictions
- If still failing after 2 iterations, report remaining issues

### 6. Write the Constitution File

Write to `.forge/memory/constitution.md`. Overwrite the existing file if it exists (after preserving version history).

### 7. Report Completion

```
## Constitution Updated

**File**: .forge/memory/constitution.md
**Version**: v{version}
**Principles**: {N} articles
**Placeholders Resolved**: {N}/{total}

**Validation**: {N}/7 checks passed

---

**Next steps**:
- `/forge.signal` — Capture your first signal aligned with these principles
- `/forge.feature` — Create a feature following these principles
- Run `/forge.check` to verify all artifacts comply with the constitution
```

## Quick Guidelines

- **Principles Must Be Actionable**: Each principle should use MUST/SHOULD/MAY declarative language — if a principle can't be tested, it's not actionable
- **Less Is More**: 3-9 principles — any more and the constitution becomes unwieldy
- **Evolve, Don't Rewrite**: Amendments should add clarity, not break existing governance
- **Placeholder Resolution**: Resolve at least the PROJECT_NAME and first 3 principles before deploying — mark remaining with TODO
- **DO NOT create more than 9 principles** — keep the constitution focused
- **DO NOT skip versioning** — every change gets a version bump

### 8. Post-Execution Checks

**Check for extension hooks (after constitution update)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_constitution` key.
- Filter out disabled hooks and process executable hooks using the same pattern as Pre-Execution Checks.
