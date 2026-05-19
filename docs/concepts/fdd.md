# What is FORGE-Driven Development?

FORGE-Driven Development (FDD) **flips the script** on traditional software development. For decades, code has been king — requirements were just scaffolding we built and discarded once the "real work" of coding began. FDD changes this: **signals become executable**, directly generating hypotheses, decisions, features, and experiments rather than just informing them.

## Core Philosophy

FORGE-Driven Development is a structured process that emphasizes:

- **Signal-driven development** where observations define the "*what*" before the "*why*" or "*how*"
- **Hypothesis-first exploration** using falsifiable statements to guide investigation
- **Consent-based decisions** with explicit alternatives and trade-off articulation
- **Multi-step refinement** rather than one-shot code generation from prompts
- **Heavy reliance** on advanced AI model capabilities for signal interpretation and pattern recognition

## Development Phases

| Phase | Focus | Key Activities |
|-------|-------|----------------|
| **Signal Capture** | Observe | <ul><li>Note anomalies, patterns, metrics, feedback</li><li>Auto-categorize and cluster</li><li>Build signal inventory</li></ul> |
| **Hypothesis Formulation** | Understand | <ul><li>Generate testable If-Then-Because statements</li><li>Define validation criteria</li><li>Link to signals</li></ul> |
| **Decision Making** | Choose | <ul><li>Generate alternatives with trade-offs</li><li>Consent-based selection</li><li>Document rationale</li></ul> |
| **Feature Definition** | Specify | <ul><li>ICE score prioritization</li><li>User journey generation</li><li>Scope and surface area definition</li></ul> |
| **Experiment Design** | Validate | <ul><li>Variant design with traffic allocation</li><li>Metric and guardrail definition</li><li>Stop conditions</li></ul> |
| **Release & Retrospect** | Learn | <ul><li>Release manifest and rollout strategy</li><li>Hypothesis review and decision validation</li><li>New signal generation from learnings</li></ul> |

## Why FDD Matters Now

Three trends make FDD not just possible but necessary:

First, **AI capabilities** have reached a threshold where natural language signals can reliably generate hypotheses and feature specifications. This isn't about replacing developers—it's about amplifying their observational capabilities by automating the mechanical pattern recognition from signal to implementation.

Second, **software complexity** continues to grow exponentially. Modern systems integrate dozens of services, frameworks, and dependencies. Keeping all these pieces aligned with original intent through manual processes becomes increasingly difficult. FDD provides systematic alignment through signal-driven generation.

Third, **the pace of change** accelerates. Requirements change far more rapidly today than ever before. Traditional development treats new observations as disruptions. Each signal requires manually tracing impact through documentation, design, and code. FDD transforms new signals from obstacles into normal workflow—they generate new hypotheses, which inform new decisions, which produce new features.

## The FORGE Loop

The core of FDD is the FORGE loop:

```
Signal → Hypothesize → Decide → Feature → Experiment → Release → Retrospect → Signal
```

This closed feedback loop ensures that:
- Every action traces back to an observation
- Every hypothesis is testable and falsifiable
- Every decision has documented alternatives and rationale
- Every release generates learning for the next cycle
- Nothing is built without understanding why

## Experimental Goals

Our research and experimentation focus on:

### Signal-First Development

- Validate that signal-first workflows produce better outcomes than requirement-first approaches
- Measure the reduction in "why was this built?" questions from signal-linked artifacts

### Hypothesis Quality

- Measure hypothesis accuracy rates across different signal types
- Identify patterns that lead to high-confidence vs low-confidence hypotheses

### Decision Rationale

- Track decision satisfaction rates when alternatives are documented
- Measure the impact of trade-off articulation on long-term decision quality
