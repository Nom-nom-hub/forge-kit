# FORGE Workflow Architecture

## Workflow Lifecycle

Each workflow defines a sequence of steps that guide the user through a FORGE process.

### Core Flow

```
Signal → Hypothesis → Decision → Feature → Experiment → Release → Retrospect
                                                                          │
                                                                          ▼
                                                                       Signal
```

### Branching Flows

- **Quick fix**: Signal → Decision → Feature → Release
- **Experiment**: Signal → Hypothesis → Experiment → Decision → Release
- **Strategic**: Signal → Hypothesis → Decision → Feature → Experiment → Release → Retrospect
