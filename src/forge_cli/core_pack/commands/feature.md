---
description: "Create a FORGE feature from a hypothesis — the delivery container connecting hypotheses to code. Defines scope, user journeys, acceptance criteria, and technical surface area."
handoffs:
  - label: Design Experiment
    agent: forge.experiment
    prompt: Design an experiment to test the feature's hypothesis
    send: true
  - label: Create Release Manifest
    agent: forge.release
    prompt: Plan a release that includes this feature
    send: true
  - label: Clarify Feature
    agent: forge.clarify
    prompt: Clarify the feature scope and requirements
    send: true
scripts:
  sh: scripts/bash/create-new-feature.sh
  ps: scripts/powershell/setup-feature.ps1
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before feature creation)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_feature` key.
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

**IMPORTANT**: You are the AI agent executing this workflow. Do NOT ask the user to perform file operations or run commands. Generate, create, and validate artifacts autonomously.

### 1. Setup

1. Run `{SCRIPT}` from repo root (if available) to scaffold the feature directory structure.
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\\''m Groot'.
   - If the script fails or is unavailable, fall back: `mkdir -p .forge/features/ specs/`
2. Ensure `.forge/features/` exists.
3. Generate feature ID: `fea-{8-char-nanoid}`.
4. Generate short name (2-4 words): Extract from hypothesis or user input. Lowercase, hyphenated.
   - Example: "adding export to navigation" → `export-nav-shortcut`
5. Determine feature directory: `specs/{nanoid}-{short-name}/`

### 2. Load Context

**Parse `$ARGUMENTS`** for:
- Hypothesis reference (`hyp-*` ID)
- Decision reference (`dec-*` ID)
- Feature description text

**If hypothesis ID found**: Load `.forge/hypotheses/{id}.yaml`
- Extract: `hypothesis.statement`, `hypothesis.validation_criteria`, `signals[]`
- If file missing or invalid YAML: WARN, proceed with partial context
- Extract linked signal IDs from the hypothesis

**If no hypothesis ID found**: Load available hypotheses from `.forge/hypotheses/` directory
- Scan `*.yaml` files with `status: draft` or `status: active`
- If exactly 1 draft hypothesis: Auto-link it
- If multiple: List them and ask user to choose
- If zero: WARN "No hypotheses found. A hypothesis is the foundation of a feature. Run `/forge.hypothesize` first." Offer to continue anyway.

**If signal IDs found in the hypothesis**: Load `.forge/signals/{id}.yaml` for each linked signal. Extract `observation` and `affected_dimensions`.

### 3. Define Feature Identity

**Generate name and tagline** automatically from the hypothesis:

- **Name**: Extract the core change from the hypothesis statement. 
  - "We believe adding Export to nav..." → "Export Navigation Shortcut"
  - Keep it short (2-5 words)
- **Tagline**: One sentence, human-readable.
  - "Add an Export button to the primary navigation so enterprise analysts can access it in one click"

**Present to user**: "I've drafted the feature identity. **`Name`: [name]** — **`Tagline`: [tagline]** — Does this capture it?"

### 4. Define Scope (CRITICAL)

**Compute ICE score** automatically:

- **Impact**: Based on the hypothesis target metric magnitude
  - >50% improvement → 8-10
  - 20-50% → 5-7
  - <20% or qualitative → 3-5
  - Unknown → ask user: "How impactful is this on a scale of 1-10?"
- **Confidence**: Based on source confidence and evidence quality
  - Multiple high-confidence signals + clear causal link → 7-9
  - Single signal + reasonable inference → 4-6
  - Speculative → 1-3
- **Ease**: Based on technical complexity inferred from the description
  - Simple UI change → 8-10
  - New component/service → 5-7
  - Core architecture change → 2-4

**Generate scope boundaries** from the hypothesis + signals:

**Includes** — what this feature IS:
- Extract concrete actions from the hypothesis statement
- Example: `"adding Export to nav"` → ["Export button in primary nav bar", "Tooltip on hover"]

**Excludes** — what this feature is NOT (prevents scope creep):
- Identify adjacent concerns that are NOT in the hypothesis
- Example: ["New export formats", "Scheduled exports", "Export history", "Mobile responsive design"]

**Deferred** — explicitly pushed to future:
- Items that are related but beyond the current hypothesis scope
- Each with reason and optional linked signal

**If the user provides scope via `$ARGUMENTS`**: Parse and merge with auto-generated scope.
**If `$ARGUMENTS` is empty**: Present auto-generated scope with: "Here's my proposed scope. What should I add, remove, or change?"

### 5. Generate User Journeys

**Auto-generate journeys** from the hypothesis and signals:

For each distinct user persona in the signals' `affected_dimensions`, generate:
```yaml
- persona: "Enterprise data analyst"
  journey: |
    GIVEN I am logged in to any page
    WHEN I look at the navigation bar
    THEN I see an "Export" item clearly visible
    AND clicking it opens the export panel immediately
  acceptance_criteria:
    - id: ac-001
      description: "Export button is visible on all authenticated pages without scrolling"
      type: functional
      automated: true
    - id: ac-002
      description: "Export panel opens within 500ms of clicking the button"
      type: performance
      automated: true
```

**Generate at least 1 journey** even without explicit user input. Use the hypothesis statement as the basis.

**AC types to assign based on quality**:
- `functional`: Default for most ACs
- `performance`: If the AC mentions timing, speed, or responsiveness
- `accessibility`: If the AC mentions keyboard, screen reader, or color contrast
- `security`: If the AC mentions auth, permissions, or data protection

**DO NOT** generate ACs that are vague or untestable (e.g., "looks good", "works well"). Each AC must have a specific, measurable condition.

Present: "I've drafted {N} user journeys with {M} acceptance criteria. Review and suggest changes."

### 6. Define Technical Surface Area

**Auto-generate technical surface area** from the feature scope:

```yaml
technical:
  components_affected:
    - "Primary navigation component"
    - "Export panel/modal"
  apis_changed:
    - "Export endpoint (add direct nav entry point)"
  data_schema_changes: []
  performance_budget:
    metric: "Export panel open time"
    current: "N/A (not currently in nav)"
    target: "<500ms"
  security_review_required: false
  accessibility_requirements:
    - "Keyboard accessible (Tab + Enter to open)"
    - "Screen reader label on Export button"
```

**If the user provided technical details in `$ARGUMENTS`**: Use them. Otherwise, infer from the feature type and scope.

**NOTE**: This is a lightweight estimate. Mark `performance_budget.current` as "TBD" if unknown.

### 7. Generate Observability Requirements

**Auto-generate based on feature type**:

```yaml
observability:
  events_to_track:
    - "export_nav_clicked - user clicked Export in navigation"
    - "export_panel_opened - export panel rendered"
    - "export_completed - user completed an export"
  dashboards:
    - "Feature: Export Nav - click rate, open rate, completion rate"
  alerts:
    - "export_panel_open_rate drops >20% week-over-week"
  slo_impact: []
```

**Keep it minimal** — 3-5 events, 1 dashboard, 1-2 alerts unless the user requests more.

### 8. Feature Quality Validation

Create validation checklist at `.forge/features/fea-{nanoid}-checklist.md`:

```markdown
# Feature Quality Checklist: fea-{nanoid}

- [ ] **FEA-001**: Linked to a valid hypothesis (hyp-* ID populated)
- [ ] **FEA-002**: Name and tagline are clear and descriptive
- [ ] **FEA-003**: Scope includes and excludes are defined (at least 1 each)
- [ ] **FEA-004**: ICE score has at least 2 of 3 dimensions populated
- [ ] **FEA-005**: At least 1 user journey is documented
- [ ] **FEA-006**: Each journey has at least 1 acceptance criterion
- [ ] **FEA-007**: Acceptance criteria are testable (specific, not vague)
- [ ] **FEA-008**: Technical surface area is documented
- [ ] **FEA-009**: Observability requirements are defined
- [ ] **FEA-010**: No speculative or "might need" items in scope includes
```

Run validation (max 2 iterations with auto-fixes):
- If any fail, attempt to auto-fill the missing data
- If still failing after 2 iterations, report remaining issues

### 9. Create Feature Files

**Write the feature YAML** at `.forge/features/fea-{nanoid}.yaml`:

```yaml
forge_type: feature
id: fea-{nanoid}
version: "1.0.0"
created_at: {ISO8601}

feature:
  name: "{name}"
  tagline: "{tagline}"
  hypothesis: hyp-{id}

  scope:
    ice_score:
      impact: {N}
      confidence: {N}
      ease: {N}
    includes:
      - "{include 1}"
      - "{include 2}"
    excludes:
      - "{exclude 1}"
    deferred:
      - item: "{deferred item}"
        reason: "{why deferred}"

  journeys:
    - persona: "{persona}"
      journey: |-
        GIVEN {context}
        WHEN {action}
        THEN {outcome}
      acceptance_criteria:
        - id: ac-001
          description: "{specific, measurable criterion}"
          type: functional | performance | accessibility | security
          automated: true

  technical:
    components_affected:
      - "{component}"
    apis_changed: []
    data_schema_changes: []
    performance_budget:
      metric: "{metric}"
      current: "{current}"
      target: "{target}"
    security_review_required: false
    accessibility_requirements:
      - "{a11y requirement}"

  feature_flag:
    key: "fea-{nanoid}"
    rollout_strategy: boolean

  observability:
    events_to_track:
      - "{event_name} - {description}"
    dashboards:
      - "{dashboard description}"
    alerts:
      - "{alert condition}"

  dependencies:
    upstream_features: []
    downstream_features: []
    external_dependencies: []

signals: [{linked signal IDs}]
decisions: [{linked decision IDs}]
hypothesis: hyp-{id}

owner: {user or "anonymous"}
status: ideation
```

**Write the spec document** at `specs/{nanoid}-{short-name}/spec.md`:

```markdown
# Feature Specification: {Name}

**ID**: fea-{nanoid}
**Status**: Draft | **ICE**: {impact}/{confidence}/{ease}

## Tagline
{tagline}

## Linked Hypothesis
{hypothesis statement}

## Signals Driving This Feature
- sig-{id}: {observation summary}

## Scope
### Includes
{list}

### Excludes
{list}

### Deferred
{list}

## User Journeys
{journeys with GIVEN/WHEN/THEN}

## Acceptance Criteria
{ACs from journeys}

## Technical Surface Area
{technical details}

## Observability
{events, dashboards, alerts}
```

**DO NOT** ask the user to create these files.

### 10. Update Linked Artifacts

For each linked hypothesis `hyp-{id}`: Open `.forge/hypotheses/{id}.yaml` and add this feature ID to `features`.

For each linked signal `sig-{id}`: Open `.forge/signals/{id}.yaml` and add this feature ID to `links.features`.

**DO NOT** skip traceability updates.

### 11. Report Completion

```
## Feature Created: fea-{nanoid}

**File**: .forge/features/fea-{nanoid}.yaml
**Spec**: specs/{nanoid}-{short-name}/spec.md

**Name**: {name}
**Tagline**: {tagline}
**Hypothesis**: hyp-{id} ({hypothesis status})

**ICE Score**: {impact}/{confidence}/{ease} (avg: {(I+C+E)/3:.0f}/10)
**Scope**: {N} includes, {M} excludes, {P} deferred
**Journeys**: {N} journeys, {M} acceptance criteria
**Observability**: {N} events, {N} dashboards

**Quality Score**: {N}/10 checks passed

---

**Suggested next steps**:
- `/forge.experiment fea-{nanoid}` — Design an experiment to test this feature's hypothesis
- `/forge.release fea-{nanoid}` — Plan a release including this feature
- `/forge.clarify fea-{nanoid}` — Refine any underspecified areas
```

### 12. Post-Execution Checks

**Check for extension hooks (after feature creation)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_feature` key.
- Filter out disabled hooks and process executable hooks using the same pattern as Pre-Execution Checks.

## Quick Guidelines

- **Hypothesis-Linked**: Every feature tests a specific hypothesis — if no hypothesis exists, flag it before proceeding
- **Scope Discipline**: Includes/Excludes/Deferred — all three are required
- **Testable ACs**: "Export visible on all authenticated pages" not "Better navigation" — if an AC isn't testable, reword it
- **ICE Scores**: Force prioritization discussions upfront — auto-calculate defaults but accept overrides
- **Observability**: If you can't measure it, you can't validate the hypothesis
- **No Speculative Features**: Everything traces to a signal and hypothesis
- **DO NOT ask the user to create files or run commands**
- **DO NOT skip validation — always run the quality checklist**
- **DO NOT break traceability — always update linked artifacts**
- **DO NOT generate vague ACs — each one must be specific and testable**
