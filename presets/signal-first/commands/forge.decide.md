---
description: "Signal-first — quick consent-based decision with signal-driven alternatives"
handoffs: ["forge.feature", "forge.hypothesize"]
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

**IMPORTANT**: You are the AI agent. You are the one who records the decision. Do not ask the user to do any of these steps themselves.

## Outline

### Phase 1: Context

1. **Identify linked artifacts**: Parse `$ARGUMENTS` for signal IDs (`sig-*`) or hypothesis IDs (`hyp-*`). If none found, scan `.forge/signals/` and `.forge/hypotheses/` for the most recent items.

2. **Load context**: Read the linked signal(s) and hypothesis(s) to understand what drove this decision need.

3. **Generate alternatives** (2-4):
   - Each alternative must be concrete and actionable
   - Include a brief (1-2 sentence) description of each
   - Note trade-offs for each

### Phase 2: Decide

4. **Present alternatives** to the user with trade-offs, then **await their selection**.

5. **Record the decision** at `.forge/decisions/<id>.yml`:
   ```yaml
   id: dec-<8-char-nanoid>
   created: <ISO-8601-timestamp>
   title: <short-title>
   context:
     signals: [<linked-signal-ids>]
     hypotheses: [<linked-hypothesis-ids>]
   
   alternatives:
     - option: <option-1>
       tradeoffs: <tradeoffs>
     - option: <option-2>
       tradeoffs: <tradeoffs>
   
   selected: <selected-option>
   rationale: |
     <reason-for-selection>
   
   status: active  # active | implemented | superseded | rejected
   linked_features: []
   ```

### Phase 3: Update Links

6. **Update linked artifacts**: Append `<id>` to `linked_decisions` in the relevant `.forge/signals/<id>.yml` and `.forge/hypotheses/<id>.yml`.

### Phase 4: Validation

7. **Quality validation**:
   - [ ] At least 2 alternatives considered
   - [ ] Each alternative has documented trade-offs
   - [ ] Selected option has explicit rationale
   - [ ] All linked artifacts are updated
   
   If any validation fails, fix and re-check.

### Phase 5: Completion

8. **Output**:
   ```
   ✓ Decision recorded: dec-<id>
     Title: <title>
     Selected: <selected-option>
     Linked to: <N> signals, <M> hypotheses
   ```

## Post-Execution Checks

Check `.forge/extensions.yml` for `hooks.after_decide`. Process hooks using the same pattern as Pre-Execution Checks.

## Quick Guidelines

- **Alternatives required** — Never record a decision without at least two options
- **Trade-offs surface** — Every alternative must name its cost
- **Link everything** — Decisions without signal or hypothesis links are orphans
- **DO NOT** make the decision yourself — present alternatives to the user
- **DO NOT** skip linked artifact updates
