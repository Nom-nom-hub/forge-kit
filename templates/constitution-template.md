# [PROJECT_NAME] FORGE Constitution

## Core Principles

### Article I: Signal-First
Every feature MUST start with a Signal. No feature shall be implemented without a traceable lineage to one or more signals.

### Article II: Hypothesis Framing
Every feature is a hypothesis, not a requirement. Features MUST include:
- A specific, testable hypothesis statement
- Validation criteria with measurable metrics
- Falsification criteria (what would prove this wrong)

### Article III: Consent Over Approval
Governance is consent-based, not approval-based:
- Anyone can block with a specific, resolvable objection
- Objections must include what will break, under what conditions, and a proposed resolution
- "I don't like this" is not a valid objection without specificity

### Article IV: Decisions Are Artifacts
Every significant choice is recorded as a Decision artifact:
- All decisions must be reversible or explicitly marked terminal
- Alternatives considered must be documented
- Assumptions must be monitored for invalidation

### Article V: Unknowns Are First-Class
Every artifact MUST carry an `unknowns` field:
- Known unknowns must be tracked with resolution plans
- The system should always know what it doesn't know

### Article VI: Drift Detection
Implementation drift from intent is continuously measured:
- Spec drift: Implementation vs. Feature artifact
- Hypothesis drift: Shipped features without measurement
- Decision drift: Code violating recorded decisions
- Signal drift: Reality changed but artifacts not updated

### Article VII: Telemetry Binding
Every hypothesis MUST be bound to measurable metrics:
- Primary metric for validation
- Guardrail metrics to prevent regressions
- Auto-alerts on missing telemetry data

## Governance

- All PRs/reviews must verify FORGE compliance
- Complexity must be justified in Complexity Tracking
- Constitution amendments require documented rationale, review, and backwards-compatibility assessment

**Version**: 1.0.0 | **Ratified**: [DATE] | **Last Amended**: [DATE]
