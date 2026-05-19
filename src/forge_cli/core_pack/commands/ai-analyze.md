---
description: "AI-powered analysis of FORGE artifacts — cluster related signals, suggest hypothesis framings, detect patterns, and surface unknown unknowns."
handoffs:
  - label: Form Hypothesis
    agent: forge.hypothesize
    prompt: Form a hypothesis from the AI analysis results
    send: true
  - label: Capture Signal
    agent: forge.signal
    prompt: Capture a new signal from the patterns detected
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before AI analysis)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_ai_analyze` key.
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

## AI Analysis Types

| Type | Description | Best For |
|------|-------------|----------|
| `cluster` | Group related signals by semantic similarity | Signal triage |
| `suggest-hypothesis` | Suggest hypothesis framings from signal clusters | Hypothesis creation |
| `patterns` | Identify known patterns in signals | Strategic insights |
| `blind-spots` | Detect unknown unknowns | Risk mitigation |

## Outline

**IMPORTANT**: You are the AI agent executing this workflow. Do all scanning, clustering, and reasoning yourself. Be transparent about confidence levels.

### 1. Determine Analysis Type

**Parse `$ARGUMENTS`** for:
- Analysis type: `cluster`, `suggest-hypothesis`, `patterns`, `blind-spots`
- Artifact IDs to focus on

If no type specified: Run comprehensive analysis across all artifacts.

### 2. Setup and Load

Ensure `.forge/` exists. If not: ERROR "No FORGE project found. Run `/forge.init` first."

**If analysis type is `cluster`**:
- Read ALL signals from `.forge/signals/` directory
- Extract: `observation`, `signal.category`, `signal.affected_dimensions`, `signal.source.type`
- Skip invalid YAML files with a warning

**If analysis type is `suggest-hypothesis`**:
- Read ALL signals from `.forge/signals/`
- Also read any existing hypotheses from `.forge/hypotheses/` for context

**If analysis type is `patterns`**:
- Read all signals that are NOT in `raw` status (have been processed)
- Read all experiment results from `.forge/experiments/`

**If analysis type is `blind-spots`**:
- Read ALL artifacts from all directories

### 3. Execute Analysis

**Signal Clustering**:
1. Extract keywords from each signal's `observation` (remove stop words: "the", "a", "an", "is", "are", "was", "were", "can't", "cannot")
2. Group signals by overlapping keywords AND same `signal.category`
3. For each cluster:
   - Derive cluster name from the most common keywords
   - Count signals in cluster
   - Generate a suggested hypothesis draft
   - Rate confidence (0.0-1.0) based on cluster size (larger = more confident)

**Hypothesis Suggestions**:
For each signal cluster, generate a draft hypothesis:
```
We believe [CHANGE derived from common theme] for [USERS from affected_dimensions]
will result in [OUTCOME from cluster pattern] because [REASONING from signals].
```

**Pattern Detection**:
Compare signals against common FORGE patterns:
- `navigation-friction`: Signals about finding things, menus, buttons
- `onboarding-friction`: Signals about first-time use, setup
- `performance-sensitivity`: Signals about speed, latency, load times
- `data-quality`: Signals about wrong data, missing data, confusion about data
- `workflow-blocker`: Signals about inability to complete a task
- `expectation-surprise`: Signals where user behavior doesn't match expectations

For each match: {pattern: count, signals: [ids]}

**Blind Spot Detection**:
For each artifact, scan for these patterns:
- Unstated assumptions: "This assumes [X] without evidence"
- Missing perspectives: "[Stakeholder] is not represented in this artifact"
- External risks: "[External factor] could invalidate this"
- Scale blind spots: "This breaks at [scale]"
- Temporal blind spots: "This doesn't account for [timeframe] changes"

### 4. Present Results

```
## AI Analysis Results

{analysis type}

### Signal Clusters
| # | Cluster | Count | Signals | Suggested Hypothesis | Confidence |
|---|---------|-------|---------|---------------------|------------|
| 1 | Navigation Confusion | 3 | sig-a3kx, sig-b7mq... | We believe... | 0.85 |

### Pattern Matches
| Pattern | Count | Signals |
|---------|-------|---------|
| navigation-friction | 3 | sig-a3kx, sig-b7mq, sig-c9np |

### Unknown Unknowns
| Artifact | Blind Spot | Likelihood | Impact |
|----------|------------|------------|--------|
| hyp-b2mp | Assumes export is primary CSAT driver | Medium | High |

### Confidence Notes
- [x] High confidence in cluster membership (clear keyword overlap)
- [ ] Medium confidence in hypothesis suggestions (plausible but untested)
- [ ] Low confidence in blind spots (by definition, unknown unknowns)

---

**Next steps**:
- `/forge.hypothesize` — Form a hypothesis from clustered signals
- `/forge.signal` — Capture any blind spots as new signals
- `/forge.ai.critique` — Get targeted critique of specific artifacts
```

## Quick Guidelines

- **AI Insights Are Suggestions**: All AI-generated findings are suggestions, not facts — confidence levels communicate certainty
- **Clusters Guide, Don't Decide**: Signal clusters indicate correlation, not causation — always form a hypothesis before acting
- **Patterns Are Heuristics**: Pattern detection uses keyword matching — a strong match doesn't guarantee the pattern is correct
- **Blind Spots Are Inherent**: By definition, unknown unknowns can't be comprehensive — the analysis finds structural patterns, not hidden truths
- **DO NOT treat AI suggestions as definitive** — always present confidence levels and invite user judgment
- **DO NOT skip the confidence statement** — users need to know what they can trust

### 5. Post-Execution Checks

**Check for extension hooks (after AI analysis)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_ai_analyze` key.
- Filter out disabled hooks and process executable hooks using the same pattern as Pre-Execution Checks.
