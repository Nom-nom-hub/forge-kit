---
description: "Record a FORGE decision with context, alternatives, reversibility assessment, and consent protocol. Every significant choice becomes a first-class, traceable artifact."
handoffs:
  - label: Create Feature
    agent: forge.feature
    prompt: Create a feature aligned with the decision I just recorded
    send: true
  - label: Form Hypothesis
    agent: forge.hypothesize
    prompt: Form a hypothesis that considers the decision I just recorded
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before decision recording)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_decide` key.
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

**IMPORTANT**: You are the AI agent executing this workflow. Do NOT ask the user to perform file operations. Generate, propose, and write artifacts autonomously. Only involve the user for decisions requiring human judgment.

### 1. Setup

1. Ensure `.forge/decisions/` directory exists: `mkdir -p .forge/decisions/`
2. Generate decision ID: `dec-{8-char-nanoid}`

### 2. Parse Input

**Parse `$ARGUMENTS`** for:
1. **Decision statement**: The core decision being made. Everything before `--` flags.
2. **Linked artifacts**: References to `sig-*`, `hyp-*`, `fea-*` IDs in the arguments.
3. **Flags**:
   - `--type=<type>`: architectural | product | operational | execution
   - `--reversible=<bool>`: true | false
   - `--cost=<cost>`: trivial | low | medium | high | extreme

**If statements is empty or only flags**: Ask the user for the decision context:
```text
What decision needs to be recorded? Describe it in one sentence, e.g.:
"We decided to [CHOICE] over [ALTERNATIVE] for [REASON]"
```
Wait for user response.

**If statement provided**: Help refine it into a clear, specific decision statement:
- Format: "We have decided to [CHOICE] in the context of [SITUATION]."
- Example: "We have decided to use PostgreSQL over MongoDB for the export feature given our existing infrastructure and team expertise."

### 3. Determine Decision Type and Reversibility

**Infer decision type** from the statement content:

| Keyword Pattern | Decision Type |
|----------------|--------------|
| database, architecture, API, data model, framework, language | architectural |
| UX, UI, feature, pricing, positioning | product |
| process, tooling, team, workflow, sprint | operational |
| implementation detail, how to, which library | execution |

If ambiguous: Present top 2 options and let the user choose.

**Assess reversibility** automatically:

| Criteria | Reversibility |
|----------|--------------|
| Choice affects data schema, public API, or team structure | partially_reversible |
| Choice affects infrastructure, pricing, or legal compliance | terminal |
| Implementation detail, library choice, UI component | reversible |
| Default | partially_reversible |

**Estimate reversal cost**:
- Reversible + implementation detail → `trivial`
- Reversible + affects users → `low`
- Partially reversible + affects data → `medium`
- Terminal + affects infrastructure → `high`
- Terminal + affects legal/compliance → `extreme`

Present: "I've classified this as a **[type]** decision — **[reversible/cost]** . Does this seem right?"

### 4. Generate Alternatives

**Auto-generate 2-4 alternatives** based on the decision context:

For each alternative, provide:
- Option description
- Why it would be rejected
- Conditions under which it could be revisited

Example for "PostgreSQL over MongoDB":
```yaml
alternatives_considered:
  - option: "MongoDB — document store, flexible schema"
    why_rejected: "Our data has strong relational structure; team has deeper PostgreSQL expertise; no need for horizontal write scaling yet"
    could_revisit_if: "Data volume exceeds 10TB or we need geo-distributed writes"
  - option: "SQLite — embedded, zero-config"
    why_rejected: "Does not support concurrent multi-process access needed for web app"
    could_revisit_if: "We pivot to a desktop-only application"
  - option: "Amazon Aurora — managed PostgreSQL with better scaling"
    why_rejected: "Vendor lock-in concern and higher cost for current scale"
    could_revisit_if: "PostgreSQL's operational overhead becomes a bottleneck at scale"
```

**Present alternatives for user review**: "I've drafted these alternatives. Would you like to add, remove, or modify any?"

### 5. Document Rationale and Constraints

**Extract rationale** from the decision statement and alternatives:
- Why was THIS option chosen over the alternatives?
- What evidence supports this choice?

**Auto-detect constraints** from the statement keywords:

| Keyword | Constraint Type |
|---------|----------------|
| budget, cost, resources, headcount | resource |
| team expertise, knowledge, experience | resource (team) |
| timeline, deadline, Q1, Q2, release date | time |
| compliance, regulation, audit, GDPR, SOC2 | regulatory |
| existing infrastructure, current stack, migration | technical |
| market, customer requirement | business |

If no constraints detected: Generate an empty list and ask "Any constraints that forced this decision?"

### 6. Document Assumptions

**Auto-generate assumptions** from the decision context:

For each plausible assumption, format:
```yaml
- assumption: "Our current data volume will not exceed 10TB within 2 years"
  invalidated_by: "Data volume exceeds 10TB"
  monitoring: "Track monthly storage growth rate; re-evaluate when approaching 5TB"
```

Present with a prompt: "I've identified these assumptions. Which need modification?"

**If the user provides none**: Auto-generate at least 2 assumptions based on common patterns for the decision type.

### 7. Initiate Consent Protocol

If the decision type is `architectural`, `product`, or `operational`:

Auto-detect who needs to consent:
- `architectural`: "Tech leads + affected teams"
- `product`: "Product + design + affected squads"
- `operational`: "Team leads + affected members"
- `execution`: "Squad (delegated, no formal consent needed)"

Document consent record:
```yaml
consent_record:
  process: consent
  participants: ["{auto-detected participants}"]
  objections: []
  consented_at: null
```

Ask the user: "This decision affects others and needs consent from **[participants]**. Should I proceed with the consent protocol, or is this a unilateral/approved decision?"

Options:
- **consent** (default): Document with consent process
- **approval**: Document as approved by a specific person
- **unilateral**: Document as individual decision
- **delegated**: Document as covered by existing delegation

**Consent Rule** (document for reference): An objection must include: (1) What specifically will break, (2) Under what conditions, (3) A proposed resolution.

### 8. Set Review Trigger

**Auto-generate a review trigger** based on the decision type:

```yaml
review_trigger:
  date: "{6 months from today for architectural, 3 months for product, 1 month for execution}"
  metric_threshold: "{detected threshold if applicable}"
  event: "{triggering event if applicable}"
```

Default dates:
- `architectural`: 6 months out
- `product`: 3 months out
- `operational`: 3 months out
- `execution`: No review needed (mark as delegated)

Ask the user: "I've set the review trigger to [date/threshold]. Does this look right?"

### 9. Decision Quality Validation

Create validation checklist at `.forge/decisions/dec-{nanoid}-checklist.md`:

```markdown
# Decision Quality Checklist: dec-{nanoid}

- [ ] **DEC-001**: Decision statement is clear and specific
- [ ] **DEC-002**: Decision type is assigned
- [ ] **DEC-003**: At least 2 alternatives were considered and documented
- [ ] **DEC-004**: Rationale explains why this option was chosen
- [ ] **DEC-005**: Reversibility is assessed (type + cost)
- [ ] **DEC-006**: At least 1 assumption is documented (what would invalidate this choice)
- [ ] **DEC-007**: Review trigger is set
- [ ] **DEC-008**: If affecting others (architectural/product/operational), consent record is initiated
```

Run validation (max 2 iterations):
- For each criterion, note pass/fail
- If any fail, attempt to auto-fix (generate the missing field)
- If still failing after 2 iterations, report remaining issues

### 10. Create the Decision File

Write `.forge/decisions/dec-{nanoid}.yaml`:

```yaml
forge_type: decision
id: dec-{nanoid}
version: "1.0.0"
created_at: {ISO8601}

decision:
  title: "{short title from statement — max 10 words}"
  statement: |
    We have decided to {choice} in the context of {situation}.

  type: {architectural | product | operational | execution}
  rationale: |
    {why this option was chosen over alternatives}

  alternatives_considered:
    - option: "{alternative 1}"
      why_rejected: "{reason}"
      could_revisit_if: "{condition}"

  reversibility:
    type: {reversible | partially_reversible | terminal}
    reversal_cost: {trivial | low | medium | high | extreme}
    reversal_condition: "{when to revisit}"

  constraints:
    - type: {technical | business | regulatory | time | resource}
      description: "{constraint}"

  assumptions:
    - assumption: "{assumption statement}"
      invalidated_by: "{event or threshold}"
      monitoring: "{method}"

  consent_record:
    process: {consent | approval | unilateral | delegated}
    participants: [{list}]
    objections: []
    consented_at: {null or ISO8601}

  review_trigger:
    date: {ISO8601}
    metric_threshold: "{metric}"
    event: "{event}"

signals: [{linked signal IDs}]
hypotheses: [{linked hypothesis IDs}]
features: []

owner: {user or "anonymous"}
status: proposed
superseded_by: ""
```

**DO NOT** ask the user to create this file.

### 11. Update Linked Artifacts

For each linked signal `sig-{id}`: Open `.forge/signals/{id}.yaml` and append this decision ID to `links.decisions`.
For each linked hypothesis `hyp-{id}`: Open `.forge/hypotheses/{id}.yaml` and append this decision ID to `decisions`.

**DO NOT** skip this step — traceability requires bidirectional links.

### 12. Report Completion

```
## Decision Recorded: dec-{nanoid}

**File**: .forge/decisions/dec-{nanoid}.yaml

**Decision**: {short title}
**Type**: {type} | **Reversible**: {reversibility} | **Cost**: {cost}
**Alternatives Considered**: {N}
**Assumptions**: {N}
**Consent**: {consent process} {if consent: "— pending review by: [participants]"}

**Quality Score**: {N}/8 checks passed

---

**Suggested next steps**:
- `/forge.feature dec-{nanoid}` — Create a feature implementing this decision
- `/forge.hypothesize dec-{nanoid}` — Form a hypothesis informed by this decision
- Share the decision with {participants} for consent review
```

### 13. Post-Execution Checks

**Check for extension hooks (after decision recording)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_decide` key.
- Filter out disabled hooks and process executable hooks using the same pattern as Pre-Execution Checks.

## Quick Guidelines

- **Decisions Are Artifacts**: Every significant choice is recorded — if it would take >10min to reverse, it deserves a decision
- **Alternatives Matter**: Always document what was NOT chosen and why — if you can't think of alternatives, you haven't explored enough
- **Assumptions Decay**: What's true today may not be true tomorrow — always set a review trigger
- **Reversible > Terminal**: Prefer reversible decisions when possible — flag terminal decisions prominently
- **Consent > Approval**: Governance is based on consent, not approval chains — document objections when they arise
- **DO NOT ask the user to create files** — you are the agent, create them
- **DO NOT skip validation** — always generate and check the quality checklist
- **DO NOT break traceability** — always update linked artifacts
