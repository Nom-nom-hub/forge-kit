---
description: "Signal-first — formulate a hypothesis directly from a signal"
handoffs: ["forge.decide", "forge.feature"]
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

**IMPORTANT**: You are the AI agent. You are the one who formulates the hypothesis. Do not ask the user to do any of these steps themselves.

## Outline

### Phase 1: Load Signal Context

1. **Identify the target signal**: If `$ARGUMENTS` contains a signal ID (e.g., `sig-abc12345`), use that. If not, parse the description to find a matching signal in `.forge/signals/` by scanning `*.yml` files.

2. **Load the signal file**: Read the identified `<id>.yml` from `.forge/signals/` and extract:
   - The description and context
   - The severity and category (these inform hypothesis scope)
   - Any existing linked hypotheses

3. **Check if already linked**: If the signal already has linked hypotheses, note them: `Signal <id> already linked to hypothesis <hid>. Consider formulating an alternative or refining the existing one.`

### Phase 2: Formulate

4. **Generate ID**: `hyp-{8-char-nanoid}`

5. **Formulate the hypothesis** from the signal:
   ```
   If <signal-observation> is true,
   Then <predicted-cause-or-relationship>
   Because <reasoning-trace>
   ```

6. **Define validation criteria** (minimum 2, maximum 5):
   - Each criterion must be testable without special tooling
   - Include at least one criterion that could *disprove* the hypothesis

7. **Create the hypothesis file** at `.forge/hypotheses/<id>.yml`:
   ```yaml
   id: <id>
   created: <ISO-8601-timestamp>
   signal_id: <linked-signal-id>
   statement: |
     If <observation> then <prediction> because <reasoning>
   
   validation_criteria:
     - criterion: <testable-statement>
       type: confirm | disprove
     - criterion: <testable-statement>
       type: confirm | disprove
   
   status: proposed  # proposed | testing | confirmed | refuted
   linked_decisions: []
   ```

### Phase 3: Update Signal Link

8. **Update the signal file**: Append `<id>` to `linked_hypotheses` in `.forge/signals/<signal-id>.yml`.

### Phase 4: Validation

9. **Quality validation**:
   - [ ] Hypothesis is falsifiable (has disprove criteria)
   - [ ] Each criterion is testable without special infrastructure
   - [ ] Hypothesis directly addresses the signal observation
   - [ ] Reasoning trace is explicit and logical
   - [ ] YAML is well-formed
   
   If any validation fails, refine and re-check.

### Phase 5: Completion

10. **Output**:
    ```
    ✓ Hypothesis formulated: <id>
      Signal: <signal-id>
      Statement: <truncated-statement>
      Validation: <N> criteria (<M> confirm, <P> disprove)
    ```

## Post-Execution Checks

Check for extension hooks: Check `.forge/extensions.yml` for `hooks.after_hypothesize`. Process hooks using the same pattern as Pre-Execution Checks.

## Quick Guidelines

- **One hypothesis per formulation** — Don't batch multiple ideas
- **Falsifiability required** — Every hypothesis must have disprove criteria
- **Link or lose** — Every hypothesis MUST link to exactly one signal
- **DO NOT** merge multiple signals into one hypothesis
- **DO NOT** skip validation criteria — even if the answer seems obvious
