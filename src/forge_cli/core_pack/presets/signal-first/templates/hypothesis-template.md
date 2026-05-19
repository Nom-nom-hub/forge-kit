# Hypothesis Template (Signal-First Preset)

Formulate testable hypotheses from signals.

## Structure

```
If <signal-observation>
Then <predicted-cause-or-relationship>
Because <reasoning-trace>
```

## Fields

- **id**: `hyp-{8-char-nanoid}` — auto-generated
- **signal_id**: Linked signal ID
- **validation_criteria**: 2-5 testable statements (at least one must disprove)
