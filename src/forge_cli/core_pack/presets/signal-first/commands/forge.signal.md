---
description: "Signal-first — capture a signal with minimal ceremony"
handoffs: ["forge.hypothesize", "forge.decide"]
scripts:
  sh: scripts/bash/signal-capture.sh
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

**IMPORTANT**: You are the AI agent. You are the one who runs the signal capture. Do not ask the user to do any of these steps themselves.

## Outline

### Phase 1: Capture

1. **Generate ID**: Create a signal ID using the format `sig-{8-char-nanoid}` (lowercase alphanumeric).

2. **Parse flags** from `$ARGUMENTS`:
   - `--source` or `-s`: Signal source (user, event, audit, system, research)
   - `--severity` or `-S`: Severity (observation, concern, warning, critical)
   - `--category` or `-c`: Category (ux, performance, security, reliability, process, business, technical, other)
   - `--tags` or `-t`: Comma-separated tags
   - `--type` or `-T`: Signal type (observation, anomaly, pattern, metric, feedback)

3. **Auto-enrich** from the description text:
   - Infer category from keywords (e.g., "slow" → performance, "crash" → reliability, "login" → security)
   - Infer severity from language intensity (e.g., words like "blocks", "impossible", "broken" → critical)
   - Set defaults for unspecified flags

4. **Create the signal file** at `.forge/signals/<id>.yml`:
   ```yaml
   id: <id>
   created: <ISO-8601-timestamp>
   source: <parsed-or-inferred-source>
   severity: <parsed-or-inferred-severity>
   category: <parsed-or-inferred-category>
   type: <parsed-or-inferred-type>
   tags: [<parsed-tags>]
   description: |
     <user-description>
   
   context: |
     <relevant-project-or-execution-context>
   
   linked_hypotheses: []
   linked_decisions: []
   ```

5. **Run clustering check** (optional): Scan `.forge/signals/` for existing signals with overlapping tags or categories. If found, note the connection in the signal's context field: `Related to: <existing-signal-id>`.

### Phase 2: Validation

6. **Quality validation**: Check the generated signal against:
   - [ ] ID follows `sig-{8-char-nanoid}` format
   - [ ] Source is specified (auto-inferred if not given)
   - [ ] Severity is set (auto-inferred if not given)
   - [ ] Description is non-empty and meaningful
   - [ ] All required YAML fields are present and non-null
   - [ ] Timestamps use ISO-8601 format
   
   If any validation fails, fix the issue and repeat validation once.

### Phase 3: Completion

7. **Output** a completion report:
   ```
   ✓ Signal captured: <id>
     Source: <source> | Severity: <severity> | Category: <category>
     Description: <truncated-to-80-chars>
     Linked to: <existing-signal-id or "none">
   ```

## Post-Execution Checks

**Check for extension hooks (after signal)**: Check if `.forge/extensions.yml` exists in the project root. If it exists, read it and look for entries under the `hooks.after_signal` key. Filter out disabled hooks and process executable hooks using the same pattern as Pre-Execution Checks.

## Quick Guidelines

- **One signal per capture** — Don't bundle observations
- **Be specific** — "User clicked X then saw Y" not "Something went wrong"
- **No solutions** — Signals describe what happened, not what to do about it
- **DO NOT** modify existing signal files unless updating linked_hypotheses or linked_decisions
- **DO NOT** generate a hypothesis from a signal — that's a separate command
