---
description: "Create a FORGE release manifest — a narrative connecting features and experiments to a release story. Defines rollout strategy, readiness gates, and monitoring window."
handoffs:
  - label: Run Retrospective
    agent: forge.retrospect
    prompt: Capture learnings from this release
    send: true
  - label: Capture New Signals
    agent: forge.signal
    prompt: Capture signals from the release outcomes
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before release manifest creation)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_release` key.
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

**IMPORTANT**: You are the AI agent executing this workflow. Do NOT ask the user to perform file operations or run commands. Generate, create, and validate artifacts autonomously.

### 1. Setup

1. Ensure `.forge/releases/` directory exists: `mkdir -p .forge/releases/`
2. Generate release ID: `rel-{8-char-nanoid}`

### 2. Load Available Features and Experiments

**Scan `.forge/features/`** for features with status `building`, `review`, or `staged`:
- Read each `*.yaml` file
- Extract: `feature.name`, `feature.tagline`, `feature.scope`, `status`
- Filter to features not yet linked to any release (check for `release` links or ask)

**Scan `.forge/experiments/`** for experiments with status `running` or `completed`:
- Read each `*.yaml` file
- Extract: `experiment.type`, `experiment.hypothesis`, `experiment.results`

**If `$ARGUMENTS` contains specific fea-* or exp-* IDs**:
- Load only those specific artifacts
- Skip scanning

**If no features or experiments found**: ERROR "No features or experiments available for release. Run `/forge.feature` first."

### 3. Craft the Release Identity

**Generate release metadata:**
- **Version**: If a `version` file exists (e.g., `VERSION`, `package.json`), read and increment appropriately (semver: patch for bugfixes, minor for features, major for breaking changes)
- **Name**: Use the version as the release name (e.g., "v1.2.0")
- **Codename**: Auto-generate a human-friendly name from the features included (e.g., "Export Sprint")

**Generate release narrative** automatically from selected features:
```text
This release brings {N} features to improve {common theme across features}:

- {feature 1}: {tagline}
- {feature 2}: {tagline}

Users will benefit from {benefit summary}.
```

Present: "Here's the release identity I've drafted. Review and adjust?"

### 4. Select Features and Experiments

**Auto-select all available features/experiments** by default. Present:
```
Available Features:
- fea-abc1: Export Navigation Shortcut (status: review)
- fea-xyz2: Dashboard Redesign (status: building)

Available Experiments:
- exp-mno3: Export Button A/B Test (status: running)

Include all of these in this release? (yes / select specific ones)
```

If user says "yes" or doesn't specify: Include all.
If user specifies specific IDs: Include only those.

### 5. Define Rollout Strategy

**Auto-select rollout strategy** based on included features:

| Feature Risk Profile | Recommended Strategy |
|---------------------|---------------------|
| Simple UI change, non-critical path | big_bang |
| Moderate change, some risk | progressive |
| Infrastructure, data migration, critical path | canary |
| High risk, need maximum control | feature_flagged |

**Generate rollout stages**:
```yaml
rollout:
  strategy: {selected strategy}
  stages:
    - name: "internal"
      gate_criteria:
        - "All acceptance criteria pass automated tests"
        - "Performance targets met"
      rollback_trigger:
        - "Error rate increases >5%"
        - "Any P1 bug reported"
    - name: "beta"
      gate_criteria:
        - "Internal rollout stable for 24h"
      rollback_trigger:
        - "Error rate increases >2%"
    - name: "general"
      gate_criteria:
        - "Beta rollout stable for 72h"
        - "No open P1 bugs"
      rollback_trigger:
        - "Error rate increases >1%"
        - "Guardrail metric breached"
```

Present for review: "I've configured a {strategy} rollout with {N} stages. Does this look right?"

### 6. Generate Readiness Checklist

**Auto-generate readiness gates** based on what's included in the release:

```yaml
readiness:
  - category: engineering
    checks:
      - item: "All ACs have passing automated tests"
        required: true
        status: pending
      - item: "Code review completed for all features"
        required: true
        status: pending
      - item: "Performance targets verified"
        required: false
        status: pending

  - category: security
    checks:
      - item: "Security review completed (if required)"
        required: true
        status: pending
      - item: "Vulnerability scan passed"
        required: false
        status: pending

  - category: observability
    checks:
      - item: "Monitoring dashboards configured"
        required: true
        status: pending
      - item: "Alerts configured for key metrics"
        required: true
        status: pending

  - category: documentation
    checks:
      - item: "User documentation updated"
        required: false
        status: pending
      - item: "Changelog entry created"
        required: true
        status: pending

  - category: support
    checks:
      - item: "Support team briefed on changes"
        required: true
        status: pending
      - item: "Known issues documented"
        required: true
        status: pending
```

**Auto-enable/disable categories**:
- If feature has `security_review_required: true` → mark security checks as `required: true`
- If feature has `accessibility_requirements` → add accessibility category
- Default: Include all categories with sensible defaults

### 7. Configure Monitoring Window

**Auto-generate monitoring configuration**:

```yaml
monitoring_window:
  duration: "{72h for progressive, 168h (7d) for canary, 24h for big_bang}"
  on_call: "{user or 'TBD'}"
  escalation: "{user or 'TBD'}"
  auto_rollback_conditions:
    - "Error rate increase >5% from pre-release baseline"
    - "p99 latency increase >200ms from pre-release baseline"
    - "Any P1 security incident"
```

### 8. Generate Communications Plan

**Auto-generate** based on release scope:

```yaml
communications:
  internal_announcement: "#release-announce channel"
  customer_announcement: "blog post / changelog entry"
  documentation_updates:
    - "Update changelog"
    - "Update feature documentation"
  support_briefing: "Slack message to #support with release notes"
```

### 9. Release Quality Validation

Create validation checklist at `.forge/releases/rel-{nanoid}-checklist.md`:

```markdown
# Release Quality Checklist: rel-{nanoid}

- [ ] **REL-001**: Release narrative is written and clear
- [ ] **REL-002**: At least 1 feature or experiment is included
- [ ] **REL-003**: Rollout strategy is defined
- [ ] **REL-004**: Rollout stages have gate criteria and rollback triggers
- [ ] **REL-005**: Readiness checklist has engineering and observability categories
- [ ] **REL-006**: Monitoring window is configured with duration and auto-rollback conditions
- [ ] **REL-007**: Communications plan is documented
- [ ] **REL-008**: All included features/experiments exist and are valid
```

Run validation (max 2 iterations):
- Check each criterion; auto-fix where possible
- Report remaining issues

### 10. Create the Release Manifest

Write `.forge/releases/rel-{nanoid}.yaml`:

```yaml
forge_type: release
id: rel-{nanoid}
version: "1.0.0"
created_at: {ISO8601}

release:
  name: "{version string}"
  codename: "{codename}"
  narrative: |
    {release narrative}

  features:
    - fea-{id}
  experiments:
    - exp-{id}
  hypotheses_under_test:
    - hyp-{id}

  rollout:
    strategy: {big_bang | progressive | canary | dark_launch | feature_flagged}
    stages:
      - name: "internal"
        gate_criteria:
          - "{criterion 1}"
        rollback_trigger:
          - "{trigger 1}"

  communications:
    internal_announcement: "{channel}"
    customer_announcement: "{channel}"
    documentation_updates:
      - "{doc update}"
    support_briefing: "{method}"

  readiness:
    - category: engineering
      checks:
        - item: "{check item}"
          required: true
          status: pending

  monitoring_window:
    duration: "{duration}"
    on_call: "{user}"
    escalation: "{user}"
    auto_rollback_conditions:
      - "{condition}"

owner: {user or "anonymous"}
status: planning
```

### 11. Report Completion

```
## Release Manifest Created: rel-{nanoid}

**File**: .forge/releases/rel-{nanoid}.yaml

**Name**: {version} "{codename}"
**Features**: {N} features, {M} experiments
**Rollout**: {strategy} ({N} stages)
**Monitoring**: {duration} window with auto-rollback
**Readiness**: {N} checks across {M} categories

**Quality Score**: {N}/8 checks passed

---

**Suggested next steps**:
- Complete the readiness checklist items
- `/forge.retrospect rel-{nanoid}` — After release, capture learnings
- `/forge.check rel-{nanoid}` — Verify all readiness gates are green
```

### 12. Post-Execution Checks

**Check for extension hooks (after release manifest creation)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_release` key.
- Filter out disabled hooks and process executable hooks using the same pattern as Pre-Execution Checks.

## Quick Guidelines

- **Release is a Narrative**: Not just a list of features — tell the story of what problem is solved
- **Rollout Strategy**: Choose based on risk profile, not habit — canary for risky, big_bang for safe
- **Readiness > Deadlines**: If the checklist isn't complete, the release isn't ready — flag missing items
- **Monitoring Window**: Always define what happens AFTER you ship — every release needs a post-release watch
- **Auto-Rollback**: If you can't roll back automatically, your canary is too big — define conditions upfront
- **DO NOT ask the user to create files or run commands**
- **DO NOT skip validation — always run the quality checklist**
- **DO NOT create empty releases — require at least 1 feature or experiment**
