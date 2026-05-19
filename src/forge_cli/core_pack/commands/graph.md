---
description: "Query the FORGE artifact graph — trace lineages, predict impacts, find orphans, check health, and detect conflicts across all artifacts."
handoffs:
  - label: Check Health
    agent: forge.check
    prompt: Run a health check on the graph issues found
    send: true
  - label: Run Analysis
    agent: forge.analyze
    prompt: Analyze the relationships shown in the graph query
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before graph query)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_graph` key.
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally.
- Filter out hooks where `enabled` is explicitly `false`.
- Process hooks using the standard pattern.

## Outline

**IMPORTANT**: You are the AI agent executing this workflow. Do all scanning, relationship mapping, and rendering yourself.

### 1. Determine Query Type

**Parse `$ARGUMENTS`** for query type and target:
- `lineage <id>` — Show complete lineage of an artifact from signals → hypothesis → feature → experiment
- `impact <id>` — Show everything affected by changing an artifact
- `orphans` — Find artifacts with no links
- `health` — Full graph health report (same as `/forge.check`)
- `conflicts` — Find contradicting signals or decisions
- `query <id>` — Show direct relationships of an artifact

**If no query type specified**: Default to `health`.
**If no ID specified for lineage/impact/query**: Find the most recently created artifact and use it.
**If artifact not found with given ID**: ERROR "Artifact {id} not found. Available IDs: ..."

### 2. Build Relationship Map

Scan all `.forge/` directories and read every `.yaml` file. Build an internal relationship map:

For each artifact, extract link references:
- **Signal**: `links.hypotheses[]`, `links.decisions[]`, `links.features[]`
- **Hypothesis**: `signals[]`, `decisions[]`, `features[]`, `experiments[]`
- **Decision**: `signals[]`, `hypotheses[]`, `features[]`
- **Feature**: `signals[]`, `decisions[]`, `hypothesis`, `dependencies.upstream_features[]`, `dependencies.downstream_features[]`
- **Experiment**: `hypothesis`, `feature`
- **Release**: `features[]`, `experiments[]`
- **Retro**: `release`, `generated_signals[]`, `hypothesis_outcomes[].hypothesis`

**Edge Types** for visualization:
```
INFORMED_BY     SIG ──────────────▶ HYP
SHAPED_BY       DEC ──────────────▶ FEA
TESTS           FEA ──────────────▶ HYP
IMPLEMENTS      Code ─────────────▶ FEA
VERIFIES        Test ─────────────▶ FEA (via AC)
MEASURES        Metric ───────────▶ HYP
GENERATED       RSP ──────────────▶ SIG
SUPERSEDES      DEC ──────────────▶ DEC
BLOCKS          FEA ──────────────▶ FEA
CONTRADICTS     SIG ──────────────▶ SIG
VALIDATES       EXP ──────────────▶ HYP
INVALIDATES     EXP ──────────────▶ HYP
DEPENDS_ON      FEA ──────────────▶ FEA
```

### 3. Execute Query

**Lineage Query** (trace upstream from artifact to its sources):
```
fea-x7kp lineage:
  sig-a3kx ──[INFORMED_BY]──▶ hyp-b2mp ──[TESTS]──▶ fea-x7kp
  sig-c9np ──[INFORMED_BY]──▶ hyp-b2mp               │
                                                       ├──[SHAPED_BY]─── dec-p4qw
  sig-d2vw ──[INFORMED_BY]──▶ hyp-m9rs ──────────────┘
```

**Impact Query** (trace downstream — what would change if this artifact changed):
```
dec-p4qw impact:
  ┌──[SHAPED_BY]──▶ fea-x7kp
  │                            
  └──[SHAPED_BY]──▶ fea-y2nq
```

**Orphans Query**:
```
Orphans (3 found):
  sig-x9np — created 92 days ago, never linked
  hyp-c4vw — created 45 days ago, no feature or experiment
  dec-k2mq — created 180 days ago, past review trigger, no update
```

**Conflicts Query**:
Scan for contradicting signals (same category, opposing observations):
- Same `category` but observations that suggest opposite conclusions
- Decisions with same `decision.type` but incompatible choices
- Hypothesis outcomes that contradict their linked signals

### 4. Visualize Results

Present structured output.

### 5. Report Completion with Recommendations

Based on query results, suggest specific actions:
```
## Graph Query Complete

**Query**: {type}
**Artifact**: {id} (if applicable)

{results}

---

**Recommendations**:
- {specific, actionable recommendation}
- Run `/forge.clarify` to resolve conflicts
- Run `/forge.check --orphans` for detailed orphan analysis
```

## Quick Guidelines

- **Read-Only Queries**: Graph queries do NOT modify artifacts — they only read and visualize relationships
- **Edge Types Matter**: Use the correct edge type (INFORMED_BY vs SHAPED_BY vs TESTS) to communicate relationship semantics
- **Orphans Are Warning Signals**: Unlinked artifacts are a sign of incomplete workflow — flag them prominently
- **Conflicts Need Resolution**: Contradicting signals and decisions should be resolved before proceeding
- **DO NOT modify artifacts during graph queries**
- **DO NOT skip orphan detection in health queries**

### 6. Post-Execution Checks

**Check for extension hooks (after graph query)**:
- Check if `.forge/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.after_graph` key.
- Filter out disabled hooks and process executable hooks using the same pattern as Pre-Execution Checks.
