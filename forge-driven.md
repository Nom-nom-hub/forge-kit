# FORGE-Driven Development (FDD)

## The Signal Inversion

For decades, code has been king. Requirements served code—they were the hopes and dreams we documented before the "real work" of coding began. We wrote PRDs to guide development, created user stories to inform backlogs, drew wireframes to visualize UI. But these were always subordinate to the code itself. Code was truth. Everything else was, at best, good intentions.

FORGE-Driven Development inverts this power structure. Code doesn't serve requirements—**signals and hypotheses drive everything**. The signal isn't a guide for implementation; it's the first-class artifact that generates hypotheses, decisions, features, and experiments. Technical plans aren't documents that inform coding; they're precise definitions that produce code. This isn't an incremental improvement to how we build software. It's a fundamental rethinking of what drives development.

The gap between observation and implementation has plagued software development since its inception. We've tried to bridge it with better bug reports, more detailed requirements, stricter processes. These approaches fail because they accept the gap as inevitable. They try to narrow it but never eliminate it. FDD eliminates the gap by making signals and hypotheses executable—they don't just inform decisions, they **generate** them.

This transformation is now possible because AI can understand, synthesize, and act on complex signals. But raw AI generation without structure produces chaos. FDD provides that structure through a signal-driven workflow: capture what you observe, hypothesize why, decide what to do, and generate features/experiments systematically.

In this new world, maintaining software means evolving your understanding. The intent of the development team is expressed through signals (what we observe), hypotheses (what we think is happening), and decisions (what we choose to do). The **lingua franca** of development moves to observation-level awareness, and code is the last-mile expression of those insights.

Updating apps with new features or creating a new parallel implementation means following the signal → hypothesis → decide → feature → experiment → release → retrospect pipeline. This process is therefore cyclical: signals feed hypotheses, which feed decisions, which produce features and experiments, which generate new signals through retrospectives.

## The FDD Workflow in Practice

The workflow begins with a signal—an observation, anomaly, pattern, metric, or piece of feedback. Often vague and incomplete. Through iterative dialogue with AI, this signal becomes a structured artifact with identified source, severity, category, and context. The AI asks clarifying questions, identifies related signals, and helps surface the underlying pattern. What might take days of meetings and issue triage in traditional development happens in minutes of focused signal work.

When a developer observes a production anomaly, they capture it as a signal. The signal is auto-categorized, enriched with context, and clustered with related observations. From this signal, the AI formulates testable hypotheses—possible explanations that can be validated or refuted. The best hypothesis becomes the basis for a decision, which then generates a feature specification or experiment design.

Throughout this workflow, consistency validation continuously improves quality. AI analyzes signals for ambiguity, contradictions, and gaps—not as a one-time gate, but as an ongoing refinement. Hypotheses are validated against signals. Decisions are validated against hypotheses. Features and experiments are validated against decisions.

The feedback loop extends beyond implementation. Release manifests don't just document what shipped—they set up the next retrospective. Retrospectives don't just reflect on what happened—they generate new signals for the next cycle. This iterative dance between observation, understanding, decision, and action is where true understanding emerges and where the traditional SDLC transforms into a continuous learning system.

## Core Principles

**Signals as the Primary Artifact**: The signal becomes the first-class unit of development. Everything—hypotheses, decisions, features, experiments—traces back to a signal.

**Hypothesis-Driven Exploration**: Every signal generates testable hypotheses. Understanding precedes action. You don't fix what you observe until you have a theory about why it's happening.

**Consent-Based Decisions**: Decisions are made through a lightweight consent protocol—alternatives are generated, trade-offs are articulated, and the best option is selected with clear rationale.

**Continuous Retrospection**: Every release cycles back through retrospective. Successes and failures generate new signals, closing the feedback loop.

**Research-Driven Context**: Research agents gather critical context throughout the signal → hypothesis pipeline, investigating technical options, performance implications, and organizational constraints.

## The FDD Commands

The FDD methodology is operationalized through a set of AI agent commands that automate the signal → hypothesis → decide → feature → experiment → release → retrospect workflow:

### The `/forge.signal` Command

Captures an observation as a structured signal artifact with auto-enrichment:

1. **ID Generation**: Creates a unique signal ID (`sig-{8-char-nanoid}`)
2. **Auto-Categorization**: Infers severity, category, and type from the description
3. **Clustering Check**: Scans existing signals for related observations
4. **Templated Output**: Creates a YAML file at `.forge/signals/<id>.yml`

### The `/forge.hypothesize` Command

Formulates a testable hypothesis from a signal:

1. **Signal Loading**: Reads the linked signal's context and metadata
2. **Hypothesis Formulation**: Generates If-Then-Because statements
3. **Validation Criteria**: Defines 2-5 testable criteria (at least one disproving)
4. **Link Updates**: Updates the signal with a back-reference to the hypothesis

### The `/forge.decide` Command

Records a consent-based decision:

1. **Context Loading**: Loads linked signals and hypotheses
2. **Alternative Generation**: Produces 2-4 concrete alternatives with trade-offs
3. **Consent Protocol**: Presents alternatives to the user for selection
4. **Link Updates**: Updates all linked artifacts

### The `/forge.feature` Command

Generates a feature specification from a decision:

1. **ICE Scoring**: Assesses Impact, Confidence, and Ease for the feature
2. **User Journey Generation**: Creates GIVEN/WHEN/THEN scenarios
3. **Scope Definition**: Documents includes, excludes, and deferred items
4. **Observability Specs**: Defines metrics and monitoring requirements

### The `/forge.experiment` Command

Designs an experiment to validate a hypothesis:

1. **Auto-Detection**: Determines experiment type (A/B, canary, shadow, feature flag)
2. **Variant Design**: Sets up variants with traffic allocation
3. **Metric Definition**: Defines success metrics, guardrails, and duration
4. **Stop Conditions**: Sets early-stop criteria for significance

### The `/forge.release` Command

Creates a release manifest:

1. **Release Narrative**: Documents what changed and why
2. **Rollout Strategy**: Defines staged rollout with monitoring windows
3. **Communications Plan**: Drafts release notes and stakeholder comms

### The `/forge.retrospect` Command

Runs a retrospective that generates new signals:

1. **Hypothesis Review**: Checks which hypotheses were confirmed/refuted
2. **Signal Generation**: Creates new signals from learnings
3. **Decision Validity Check**: Validates past decisions against outcomes

## Template-Driven Quality: How Structure Constrains LLMs

The power of FDD commands lies in how the templates guide LLM behavior toward higher-quality artifacts. The templates act as sophisticated prompts that constrain the LLM's output in productive ways:

### 1. Preventing Premature Solutions

The signal template explicitly instructs:
```
- ✅ Focus on WHAT was observed and WHY it matters
- ❌ Avoid generating fixes or solutions
```

This constraint forces the LLM to maintain proper abstraction levels. When an LLM might naturally jump to "fix by upgrading the database connection pool," the template keeps it focused on "users experienced elevated latency during peak hours."

### 2. Forcing Testable Hypotheses

The hypothesis template mandates falsifiability:
```
validation_criteria:
  - criterion: <testable-statement>
    type: confirm | disprove
```

This prevents the common LLM behavior of generating untestable or circular hypotheses. Every hypothesis must include at least one criterion that could disprove it.

### 3. Structured Consent for Decisions

The decide template forces trade-off articulation:

```yaml
alternatives:
  - option: <option-1>
    tradeoffs: <tradeoffs>
  - option: <option-2>
    tradeoffs: <tradeoffs>
selected: <selected-option>
rationale: |
  <reason-for-selection>
```

This prevents decisions without documented reasoning and ensures alternatives are never skipped.

### 4. ICE Scoring for Features

The feature template enforces impact assessment:

```
ICE Scores:
  Impact: 1-10
  Confidence: 1-10
  Ease: 1-10
  Total: I + C + E = <score>
```

This prevents the LLM from treating all features equally and forces explicit prioritization.

### 5. Validation Checklists

Every template includes automated quality gates that the LLM must pass before completing:

```markdown
- [ ] At least one disprove criterion
- [ ] YAML is well-formed
- [ ] All linked artifacts updated
```

These checklists act as "unit tests" for the artifact, catching gaps that might otherwise slip through.

## The Transformation

This isn't about replacing developers or automating creativity. It's about amplifying human capability by automating the mechanical translation from observation to implementation. It's about creating a tight feedback loop where signals, hypotheses, decisions, and code evolve together, each iteration bringing deeper understanding and better alignment between intent and implementation.

Software development needs better tools for maintaining alignment between observation and action. FDD provides the methodology for achieving this alignment through executable signals that generate understanding rather than merely documenting it.
