---
description: "Capture a FORGE signal — the atomic observation unit that drives all development. Validates, enriches, and persists the signal as a first-class artifact."
handoffs:
  - label: Form Hypothesis
    agent: forge.hypothesize
    prompt: Form a hypothesis from the signal I just captured
    send: true
  - label: Clarify Signal
    agent: forge.clarify
    prompt: Clarify the signal I just captured
    send: true
scripts:
  sh: scripts/bash/signal-capture.sh
  ps: scripts/powershell/signal-capture.ps1
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before signal capture)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_signal` key.
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

**IMPORTANT**: You are the AI agent executing this workflow. Do NOT ask the user to do steps you can do yourself (file creation, parsing, enrichment, validation, file writing). Only involve the user for decisions that require human judgment.

### 1. Setup

1. Run `{SCRIPT}` from repo root to scaffold the signal directory structure.
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\\''m Groot' (or double-quote if possible: "I'm Groot").
   - If the script fails or is unavailable, fall back to creating directories manually:
     ```
     mkdir -p .forge/signals/
     ```
2. Ensure `.forge/signals/` exists (verify after script or create if missing).
3. Generate a unique signal ID: `sig-{8-char-nanoid}` (use `date +%s | md5sum | head -c 8` or similar deterministic method).

### 2. Parse User Input

**If `$ARGUMENTS` is empty or only whitespace**: 
- ERROR: "No observation provided. Usage: `/forge.signal <observation> [--source=<type>] [--severity=<level>] [--category=<type>]`"
- Ask: "What did you observe?" (single sentence preferred)
- Wait for user response before proceeding

**If `$ARGUMENTS` is provided**: Parse the input to extract:
1. **Observation text**: Everything before the first `--` flag, trimmed
2. **Flags**:
   - `--source=<type>`: One of `support_ticket | interview | analytics | stakeholder | monitoring | competitor_analysis | team_retro | ab_test | team_observation`
   - `--severity=<level>`: One of `critical | high | medium | low | backlog`
   - `--category=<type>`: One of `user_pain | metric_anomaly | competitive | technical_debt | strategic | regulatory | team_observation | experiment_result`
   - `--tags=<tag1,tag2>`: Comma-separated tags

**Validation**: If the observation is fewer than 10 characters and not a clearly complete sentence, append: `[NEEDS_CLARIFICATION: This observation seems brief. Did you mean to capture more context?]`

If any flag values are invalid (not in the allowed list), skip that flag with a warning and use best-guess defaults:
- Unknown source → `team_observation`
- Unknown severity → `medium`
- Unknown category → `team_observation`

**DO NOT ask the user to repeat information they already provided.** Only ask for missing required fields.

### 3. Auto-Enrich the Signal

For each missing field, infer from the observation text using keyword matching:

**Category inference** (choose best match):
- Contains "ticket", "support", "bug", "error", "can't", "unable", "frustrat" → `user_pain`
- Contains "metric", "anomaly", "dropped", "increased", "decreased", "latency", "error rate" → `metric_anomaly`
- Contains "competitor", "they have", "market" → `competitive`
- Contains "tech debt", "legacy", "rewrite", "outdated" → `technical_debt`
- Contains "roadmap", "opportunity", "vision" → `strategic`
- Contains "compliance", "regulation", "audit", "legal" → `regulatory`
- Contains "retro", "sprint", "process" → `team_observation`
- Contains "experiment", "ab test", "test result" → `experiment_result`
- Default: `user_pain` (most common signal type)

**Severity inference** (choose best match):
- Contains "critical", "down", "outage", "data loss", "security", "breach" → `critical`
- Contains "high", "blocking", "cannot", "prevent" → `high`
- Contains "medium", "moderate", "somewhat" → `medium`
- Contains "low", "minor", "slight", "occasional" → `low`
- Default: `medium`

**If no source is provided and cannot be inferred**: Set default to `team_observation`.

If 2+ categories are equally plausible, ask the user once: "I'm seeing the signal could be [A] or [B]. Which fits better?" (Do not ask if there's a clear best match.)

### 4. Create the Signal File

Create `.forge/signals/sig-{nanoid}.yaml` with the following content (fill all placeholders with concrete values):

```yaml
forge_type: signal
id: sig-{nanoid}
version: "1.0.0"
created_at: {ISO8601 date in UTC}
created_by: {user if known, else "anonymous"}
status: raw

signal:
  category: {inferred or provided category}
  source:
    type: {inferred or provided source}
    reference: "{URL or ticket ID if provided, else ''}"
    confidence: 1.0
  observation: |
    {the parsed observation text, word-wrapped at ~80 chars}
  evidence:
    - type: text
      content: "{observation text}"
      timestamp: {ISO8601}
  affected_dimensions:
    - users: "{user segment if known, else 'affected users'}"
      frequency: often
      severity: {inferred or provided severity}
  raw_tags: [{extracted tags if provided}]

context:
  business_area: []
  technical_area: []
  time_sensitivity: {map severity: critical→urgent, high→high, medium→medium, low→backlog}

links:
  decisions: []
  features: []
  experiments: []
```

Write the file using `write_file` or direct file creation. **DO NOT** ask the user to create the file.

### 5. Signal Quality Validation

After writing the file, validate it against these criteria. Create the checklist as `.forge/signals/sig-{nanoid}-checklist.md`:

```markdown
# Signal Quality Checklist: sig-{nanoid}

**Created**: {ISO8601}

- [ ] **SIG-001**: Observation is concrete and specific (not vague like "users are unhappy")
- [ ] **SIG-002**: Observation describes WHAT was observed, not WHY it happened (no interpretation)
- [ ] **SIG-003**: Category is assigned and appropriate for the observation
- [ ] **SIG-004**: Source type is documented
- [ ] **SIG-005**: Affected dimensions are defined (who, how often, severity)
- [ ] **SIG-006**: Evidence is included
- [ ] **SIG-007**: File is valid YAML and all required fields are present
```

Run validation against each item:
- For each item, determine if it passes or fails
- If all items pass: Mark checklist complete
- If any items fail: 
  1. Note the failing items
  2. Update the signal file to fix them
  3. Re-run validation (max 2 iterations)
  4. If still failing after 2 iterations, report remaining issues to user with suggested fixes

**CRITICAL**: SIG-002 is the most important — the observation MUST describe what was observed, not an interpretation. If the observation contains interpretation (e.g., "users hate the button" instead of "3 users said they couldn't find the button"), rewrite it to be purely observational.

### 6. Signal Clustering Check

After validation, scan `.forge/signals/` for existing signals (exclude the one just created):
- Read each `sig-*.yaml` file
- Extract the `observation` and `signal.category` fields
- Compare keywords between the new signal and each existing signal
- If 3+ related signals exist (same category OR overlapping keywords in observation):
  ```
  Signal Cluster Detected:
  - sig-abc1: "users can't find export" (user_pain)
  - sig-abc2: "Where did export go?" (user_pain)
  - sig-{new}: "{new observation}" ({category})
  
  These signals appear to form a cluster. Suggest: `/forge.ai.analyze` to analyze them together.
  ```
- If fewer than 3 related signals, skip silently.

### 7. Report Completion

Report to the user with this exact format:

```
## Signal Captured: sig-{nanoid}

**File**: .forge/signals/sig-{nanoid}.yaml

**Observation**: {first 100 chars of observation}...

**Category**: {category} | **Source**: {source} | **Severity**: {severity}

**Signal Quality**: {N}/7 checks passed {if any failed, list them}

---

**Suggested next steps**:
- `/forge.hypothesize sig-{nanoid}` — Form a hypothesis from this signal
- `/forge.clarify sig-{nanoid}` — Refine this signal if it needs more context
{If cluster detected: - `/forge.ai.analyze` — Analyze the signal cluster}
```

**DO NOT** output the full YAML file contents in the report unless the user asks to see it.

### 8. Post-Execution Checks

**Check for extension hooks (after signal capture)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_signal` key.
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally.
- Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
- For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
  - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
  - If the hook defines a non-empty `condition`, skip the hook and leave condition evaluation to the HookExecutor implementation
- For each executable hook, output the following based on its `optional` flag:
  - **Optional hook** (`optional: true`):
    ```
    ## Extension Hooks

    **Optional Hook**: {extension}
    Command: `/{command}`
    Description: {description}

    Prompt: {prompt}
    To execute: `/{command}`
    ```
  - **Mandatory hook** (`optional: false`):
    ```
    ## Extension Hooks

    **Automatic Hook**: {extension}
    Executing: `/{command}`
    EXECUTE_COMMAND: {command}
    ```
- If no hooks are registered or `.forge/extensions.yml` does not exist, skip silently

## Signal Schema (Reference)

```yaml
forge_type: signal
id: sig-{nanoid}
version: "1.0.0"
created_at: {ISO8601}
created_by: {user}
status: raw

signal:
  category: user_pain | metric_anomaly | competitive | technical_debt | strategic | regulatory | team_observation | experiment_result
  source:
    type: interview | support_ticket | analytics | stakeholder | monitoring | competitor_analysis | team_retro | ab_test | team_observation
    reference: "{URL or ID}"
    confidence: 0.0-1.0
  observation: |
    Plain language description of what was observed.
    Be specific. No interpretation yet.
  evidence:
    - type: quote | metric | screenshot | log | recording
      content: "{evidence}"
      timestamp: {ISO8601}
  affected_dimensions:
    - users: "{user segment}"
      frequency: always | often | sometimes | rarely
      severity: critical | high | medium | low
  raw_tags: []

context:
  business_area: []
  technical_area: []
  time_sensitivity: urgent | high | medium | low | backlog

links:
  decisions: []
  features: []
  experiments: []
```

## Quick Guidelines

- **Signal-First**: Every feature MUST start with a signal
- **No Interpretation Yet**: Describe what was observed, not why it happened — if the observation says "because" or "so that", it has interpretation mixed in
- **Be Specific**: "47 support tickets" not "lots of tickets"
- **DO NOT ask the user to create files or run commands you can execute yourself**
- **DO NOT output raw YAML in the report unless requested**
- **DO NOT skip validation** — always run the quality checklist
- **Auto-enrich aggressively**: Infer missing fields from keywords rather than asking the user for every field
- **Only ask the user when**: (1) arguments are empty, (2) category/severity is genuinely ambiguous, (3) a [NEEDS_CLARIFICATION] is unresolvable
