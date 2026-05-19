# FORGE — Feature-Oriented Requirements & Governance Engine

## A Living Systems Methodology for Modern Software Development

---

```markdown
# FORGE Methodology
### Feature-Oriented Requirements & Governance Engine
**Version 1.0.0** | **Status: Active** | **License: MIT**

> "A spec is a snapshot. FORGE is a nervous system."

---

## Table of Contents

1. [Philosophy](#1-philosophy)
2. [Core Principles](#2-core-principles)
3. [FORGE Architecture](#3-forge-architecture)
4. [The Signal Layer](#4-the-signal-layer)
5. [Artifact Types](#5-artifact-types)
6. [Lifecycle States](#6-lifecycle-states)
7. [The Decision Mesh](#7-the-decision-mesh)
8. [Cognitive Contracts](#8-cognitive-contracts)
9. [Drift Detection](#9-drift-detection)
10. [The Forge Graph](#10-the-forge-graph)
11. [Integration Protocols](#11-integration-protocols)
12. [AI Augmentation Layer](#12-ai-augmentation-layer)
13. [Governance Rituals](#13-governance-rituals)
14. [Tooling Ecosystem](#14-tooling-ecosystem)
15. [Migration from Legacy Specs](#15-migration-from-legacy-specs)
16. [Examples](#16-examples)
17. [Anti-Patterns](#17-anti-patterns)
18. [Glossary](#18-glossary)

---

## 1. Philosophy

### Why Specs Fail

Traditional specification documents are **dead on arrival**. The moment a PRD, 
RFC, or spec is committed, it begins to rot. Teams write specs that:

- Nobody reads after sprint 1
- Don't reflect what was actually built
- Create false confidence in alignment
- Have no mechanism for detecting when reality has diverged
- Treat requirements as static truth instead of evolving hypotheses

**Spec-kit and similar tools made documentation prettier. FORGE makes it alive.**

### The FORGE Thesis

Software is not built from requirements — it is grown from **signals**. Every 
user complaint, every metric spike, every architectural decision, every 
stakeholder conversation is a signal. FORGE provides the framework to:

1. **Capture** signals at the source without ceremony
2. **Connect** signals to decisions, features, and code
3. **Propagate** changes through a living dependency graph
4. **Detect** when implementation drifts from intent
5. **Govern** with velocity instead of bureaucracy
6. **Learn** from every build cycle to improve the next

### The Three Laws of FORGE

```
LAW I:   Every artifact must be traceable to a signal.
LAW II:  Every decision must be reversible or explicitly marked terminal.
LAW III: The system must always know what it doesn't know.
```

---

## 2. Core Principles

### 2.1 Living Over Static

FORGE artifacts are **versioned, interconnected nodes** in a graph — not 
documents. They have:
- Confidence scores that decay over time
- Owners that rotate
- Automatic staleness detection
- Bidirectional links to code, tests, and telemetry

### 2.2 Signal-First Capture

Before any feature is written, a **Signal** must exist. Signals are 
lightweight — they can be captured in 30 seconds. They replace the idea of 
"tickets" and "requests" with something richer: a structured observation about 
the world.

### 2.3 Hypothesis Framing

Every feature is a **hypothesis**, not a requirement. This is not semantics — 
it fundamentally changes how teams think:

| Traditional Requirement | FORGE Hypothesis |
|------------------------|------------------|
| "Add dark mode" | "We believe users churning after 6pm will reduce by 12% if we add dark mode, validated when 30-day retention for that cohort improves" |
| "Fix login bug" | "We believe SSO failure rate >2% is causing enterprise trial abandonment, validated when conversion from trial increases" |
| "Improve performance" | "We believe P95 latency >800ms on the dashboard is the primary reason NPS detractors cite 'slowness', validated when P95 <200ms and NPS detractor rate drops" |

### 2.4 Consent-Based Governance

Governance in FORGE is not approval chains — it is **consent**. The difference:

- **Approval**: "You need permission to proceed"
- **Consent**: "Anyone can block with a specific, resolvable objection"

This shifts governance from bottleneck to collaboration.

### 2.5 The Unknown is a First-Class Citizen

FORGE treats unknowns explicitly. Every artifact carries an `unknowns` field. 
Unknown unknowns are surfaced through **divergence signals** from the FORGE Graph.

---

## 3. FORGE Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         FORGE SYSTEM                            │
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐  │
│  │  SIGNAL  │───▶│ DECISION │───▶│ FEATURE  │───▶│ RELEASE  │  │
│  │  LAYER   │    │  MESH    │    │  GRAPH   │    │ MANIFEST │  │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘  │
│       │               │               │               │         │
│       ▼               ▼               ▼               ▼         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              FORGE RUNTIME (Continuous)                  │   │
│  │  • Drift Detection    • Confidence Scoring               │   │
│  │  • Graph Traversal    • Staleness Alerts                 │   │
│  │  • AI Augmentation    • Telemetry Binding                │   │
│  └─────────────────────────────────────────────────────────┘   │
│       │               │               │               │         │
│       ▼               ▼               ▼               ▼         │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐  │
│  │  CODE    │    │  TESTS   │    │ TELEMETRY│    │  PEOPLE  │  │
│  │  LAYER   │    │  LAYER   │    │  LAYER   │    │  LAYER   │  │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Layer Descriptions

| Layer | Purpose | Owned By |
|-------|---------|---------|
| Signal Layer | Raw observations from users, metrics, stakeholders | Anyone |
| Decision Mesh | Structured choices with context and reversibility | Decision owners |
| Feature Graph | Interconnected feature hypotheses | Feature leads |
| Release Manifest | What ships, when, and why | Release steward |
| FORGE Runtime | Continuous analysis and alerting | System (automated) |
| Code Layer | Implementation artifacts | Engineers |
| Tests Layer | Behavioral contracts | Engineers |
| Telemetry Layer | Real-world feedback loops | Data/Platform |
| People Layer | Human context, expertise, accountability | Team leads |

---

## 4. The Signal Layer

Signals are the **atomic unit of FORGE**. Everything starts here.

### 4.1 Signal Schema

```yaml
# signal.forge.yaml
forge_type: signal
id: sig-{nanoid}
version: "1.0.0"
created_at: ISO8601
created_by: {user-id}
status: raw | validated | linked | archived

# Core Signal Data
signal:
  category: user_pain | metric_anomaly | competitive | technical_debt | 
             strategic | regulatory | team_observation | experiment_result
  
  source:
    type: interview | support_ticket | analytics | stakeholder | 
          monitoring | competitor_analysis | team_retro | ab_test
    reference: "{URL or ID}"
    confidence: 0.0-1.0  # How trustworthy is this source?
  
  observation: |
    Plain language description of what was observed.
    Be specific. No interpretation yet.
  
  evidence:
    - type: quote | metric | screenshot | log | recording
      content: "{evidence content}"
      timestamp: ISO8601
  
  affected_dimensions:
    - users: "{user segment}"
      frequency: always | often | sometimes | rarely
      severity: critical | high | medium | low
  
  raw_tags: []  # Unstructured, anything goes

# Context
context:
  business_area: []
  technical_area: []
  time_sensitivity: urgent | high | medium | low | backlog
  
# AI Analysis (populated by FORGE Runtime)
ai_analysis:
  similar_signals: []       # IDs of related signals
  suggested_category: ""
  pattern_match: ""         # Known pattern this resembles
  divergence_from: []       # Signals this contradicts
  confidence_score: 0.0-1.0

# Links (populated as signal evolves)
links:
  decisions: []
  features: []
  experiments: []
```

### 4.2 Signal Capture Modes

**Quick Capture** (30 seconds, mobile-friendly):
```
/forge signal "users can't find the export button" --source=support --severity=high
```

**Structured Capture** (full schema via CLI/UI):
```
forge signal create --interactive
```

**Automated Capture** (from monitoring):
```yaml
# forge-monitor.yaml
watches:
  - metric: error_rate
    threshold: ">2%"
    window: "5m"
    auto_signal: true
    category: metric_anomaly
    severity: critical
```

**Integration Capture** (from existing tools):
```yaml
# Jira, Zendesk, Datadog, Mixpanel connectors
integrations:
  zendesk:
    auto_signal_tags: ["bug", "feature-request"]
    min_occurrences: 3
    dedup_window: "7d"
```

### 4.3 Signal Clustering

The FORGE Runtime automatically clusters signals using semantic similarity:

```
Signal Cluster: "Navigation Confusion"
├── sig-a3kx: "Can't find settings" (support, 47 occurrences)
├── sig-b7mq: "Where is the dashboard?" (interview, 3 users)
├── sig-c9np: "Navigation usability score: 2.1/5" (NPS analysis)
└── sig-d2vw: "Sidebar clicks dropped 40%" (analytics)

Cluster confidence: 0.87
Suggested hypothesis: Information architecture is causing user abandonment
Estimated affected users: ~2,400/month
```

---

## 5. Artifact Types

FORGE has seven core artifact types. Each is a node in the FORGE Graph.

### 5.1 Signal (SIG)
*Described in Section 4*

### 5.2 Hypothesis (HYP)

A formalized belief derived from one or more signals.

```yaml
forge_type: hypothesis
id: hyp-{nanoid}
version: "1.0.0"

hypothesis:
  statement: |
    We believe [SPECIFIC CHANGE] for [SPECIFIC USERS] will result in 
    [MEASURABLE OUTCOME] because [REASONING FROM SIGNALS].
  
  # The condition under which this hypothesis is proven true
  validation_criteria:
    primary_metric:
      name: ""
      current_baseline: 0
      target: 0
      direction: increase | decrease
      timeframe: ""
    
    secondary_metrics: []
    
    guardrail_metrics:
      # Metrics that must NOT regress
      - name: ""
        threshold: ""
    
    minimum_sample: 0
    confidence_level: 0.95

  # What would prove this WRONG
  falsification_criteria:
    - ""
  
  # Explicit unknowns
  unknowns:
    known_unknowns:
      - assumption: ""
        risk: high | medium | low
        how_to_resolve: ""
    
    # Areas where we don't know what we don't know
    # (populated by AI analysis and team retrospectives)
    acknowledged_blind_spots:
      - ""

signals: []      # Signal IDs that informed this
decisions: []    # Decision IDs that shaped this
features: []     # Feature IDs implementing this

owner: {user-id}
reviewers: []
status: draft | active | testing | validated | invalidated | archived

confidence_score: 0.0-1.0  # Decays without validation evidence
last_confidence_update: ISO8601
```

### 5.3 Decision (DEC)

Every significant choice is a first-class artifact.

```yaml
forge_type: decision
id: dec-{nanoid}
version: "1.0.0"

decision:
  title: ""
  statement: |
    We have decided to [DECISION] in the context of [SITUATION].
  
  # Why THIS option over others
  rationale: ""
  
  # Explicitly document what was NOT chosen and why
  alternatives_considered:
    - option: ""
      why_rejected: ""
      could_revisit_if: ""
  
  # Is this reversible?
  reversibility:
    type: reversible | partially_reversible | terminal
    reversal_cost: trivial | low | medium | high | extreme
    reversal_condition: ""  # Under what circumstances should this be revisited
  
  # Explicit constraints that forced this decision
  constraints:
    - type: technical | business | regulatory | time | resource
      description: ""
  
  # What assumptions must hold for this to remain valid
  assumptions:
    - assumption: ""
      invalidated_by: ""  # What metric/signal would break this
      monitoring: ""      # How we watch for invalidation
  
  # Consent record — who reviewed, who objected, how resolved
  consent_record:
    process: consent | approval | unilateral | delegated
    participants: []
    objections:
      - from: {user-id}
        objection: ""
        resolution: ""
        resolved_at: ISO8601
    consented_at: ISO8601
  
  # Auto-expiry: force reconsideration
  review_trigger:
    date: ISO8601           # Scheduled review
    metric_threshold: ""    # Automatic review if this threshold hit
    event: ""              # Manual trigger description

signals: []
hypotheses: []
features: []

owner: {user-id}
status: proposed | active | superseded | reversed | archived
superseded_by: ""   # DEC ID if replaced
```

### 5.4 Feature (FEA)

Not a ticket. Not a user story. A feature in FORGE is a **delivery container** 
that connects hypotheses to code.

```yaml
forge_type: feature
id: fea-{nanoid}
version: "1.0.0"

feature:
  name: ""
  tagline: ""  # One sentence, human-readable
  
  # The hypothesis this tests
  hypothesis: hyp-{id}
  
  # Scope definition using Impact/Confidence/Ease scoring
  scope:
    ice_score:
      impact: 1-10
      confidence: 1-10
      ease: 1-10
      computed: null  # Auto-calculated
    
    # What this feature IS
    includes:
      - ""
    
    # Explicit exclusions (prevents scope creep)
    excludes:
      - ""
    
    # Deferred items (linked to future features)
    deferred:
      - item: ""
        reason: ""
        linked_signal: ""
  
  # User journey definition
  journeys:
    - persona: ""
      journey: |
        GIVEN [context]
        WHEN [action]
        THEN [outcome]
        AND [side effect]
      
      # Acceptance criteria as executable specs
      acceptance_criteria:
        - id: ac-001
          description: ""
          type: functional | performance | accessibility | security
          automated: true | false
          test_reference: ""  # Link to test file/ID
  
  # Technical surface area
  technical:
    components_affected: []
    apis_changed: []
    data_schema_changes: []
    performance_budget:
      metric: ""
      current: ""
      target: ""
    security_review_required: true | false
    accessibility_requirements: []
  
  # Feature flag configuration
  feature_flag:
    key: ""
    rollout_strategy: boolean | percentage | segment | schedule
    rollout_plan:
      - stage: "internal"
        percentage: 100
        duration: "3d"
      - stage: "beta"
        percentage: 20
        duration: "7d"
      - stage: "general"
        percentage: 100
        duration: null
    kill_switch: true
  
  # Observability requirements
  observability:
    events_to_track: []
    dashboards: []
    alerts: []
    slo_impact: []
  
  # Dependencies
  dependencies:
    upstream_features: []
    downstream_features: []
    external_dependencies: []
    blocking_decisions: []

signals: []
decisions: []
hypothesis: ""

owner: {user-id}
contributors: []
status: ideation | scoping | building | review | staged | live | deprecated

timeline:
  target_start: ISO8601
  target_completion: ISO8601
  actual_start: ISO8601
  actual_completion: ISO8601

# Runtime populated
health:
  implementation_coverage: 0.0-1.0  # % of ACs with passing tests
  drift_score: 0.0-1.0              # How far implementation is from spec
  telemetry_coverage: 0.0-1.0       # % of events being tracked
  staleness_score: 0.0-1.0          # How stale this artifact is
```

### 5.5 Experiment (EXP)

A time-boxed test of a hypothesis with rigorous structure.

```yaml
forge_type: experiment
id: exp-{nanoid}
version: "1.0.0"

experiment:
  type: ab_test | multivariate | canary | shadow | chaos | usability
  
  hypothesis: hyp-{id}
  feature: fea-{id}
  
  design:
    variants:
      - id: control
        description: "Current behavior"
        traffic_allocation: 0.5
      - id: treatment_a
        description: "New behavior"
        traffic_allocation: 0.5
    
    targeting:
      segments: []
      exclusions: []
      sample_size_required: 0
      power: 0.8
      significance_level: 0.05
  
  metrics:
    primary: ""
    secondary: []
    guardrails: []
  
  duration:
    minimum: ""
    maximum: ""
    stop_conditions:
      - type: significance_reached | sample_reached | harm_detected | time_limit
        threshold: ""
  
  results:
    status: not_started | running | paused | completed | stopped_early
    stop_reason: ""
    data:
      variant_results: {}
      statistical_significance: null
      practical_significance: null
      confidence_interval: []
    
    conclusion: inconclusive | validated | invalidated | needs_more_data
    recommendation: ""
    next_action: ""

owner: {user-id}
status: designing | approved | running | completed | archived
```

### 5.6 Release Manifest (REL)

A release is not a deployment — it is a **narrative**.

```yaml
forge_type: release
id: rel-{nanoid}
version: "1.0.0"

release:
  name: ""
  codename: ""  # Optional human-friendly name
  
  # The story of this release
  narrative: |
    What problem does this release solve?
    Who benefits and how?
    What does the world look like after this ships?
  
  features: []          # FEA IDs included
  experiments: []       # EXP IDs included
  decisions: []         # DEC IDs that shaped this release
  
  # What hypotheses does this release test?
  hypotheses_under_test: []
  
  # Rollout strategy
  rollout:
    strategy: big_bang | progressive | canary | dark_launch | feature_flagged
    stages:
      - name: ""
        gate_criteria: []
        rollback_trigger: []
  
  # Communications plan
  communications:
    internal_announcement: ""
    customer_announcement: ""
    documentation_updates: []
    support_briefing: ""
  
  # Readiness checklist
  readiness:
    - category: engineering
      checks:
        - item: "All ACs have passing automated tests"
          required: true
          status: pending | passed | failed | waived
          waiver_reason: ""
    - category: security
      checks: []
    - category: observability
      checks: []
    - category: documentation
      checks: []
    - category: support
      checks: []
  
  # Post-release monitoring
  monitoring_window:
    duration: "72h"
    on_call: {user-id}
    escalation: {user-id}
    auto_rollback_conditions: []

owner: {user-id}  # Release Steward
status: planning | staging | ready | live | post_mortem | closed
```

### 5.7 Retrospective Signal (RSP)

Learnings from retros feed back into the system as signals.

```yaml
forge_type: retrospective_signal
id: rsp-{nanoid}

retrospective:
  release: rel-{id}
  sprint: ""
  
  what_happened:
    delivered: []         # FEA IDs completed
    not_delivered: []     # FEA IDs missed
    unexpected: []        # Things not in the plan that happened
  
  hypothesis_outcomes:
    - hypothesis: hyp-{id}
      outcome: validated | invalidated | inconclusive | not_measurable
      evidence: ""
      new_signals_generated: []
  
  decision_reviews:
    - decision: dec-{id}
      still_valid: true | false
      new_information: ""
  
  system_health:
    process_pain_points: []
    tooling_issues: []
    communication_gaps: []
  
  generated_signals: []  # New SIG IDs created from this retro
  
  # What did we not know that we didn't know?
  unknown_unknowns_discovered: []
```

---

## 6. Lifecycle States

### 6.1 Unified State Machine

Every FORGE artifact follows a unified lifecycle:

```
                    ┌─────────┐
                    │  DRAFT  │
                    └────┬────┘
                         │ author ready
                         ▼
                    ┌─────────┐
              ┌────│ PROPOSED │────┐
              │    └────┬────┘    │
         objection       │ consent  archive
              │          ▼         │
              │    ┌─────────┐    │
              └───▶│ BLOCKED │    │
                   └────┬────┘    │
                  resolved│       │
                          ▼       ▼
                    ┌─────────┐  ┌─────────┐
                    │ ACTIVE  │  │ARCHIVED │
                    └────┬────┘  └─────────┘
                         │
              ┌──────────┼──────────┐
              ▼          ▼          ▼
         ┌────────┐ ┌─────────┐ ┌──────────┐
         │STALE   │ │TESTING  │ │SUPERSEDED│
         └───┬────┘ └────┬────┘ └──────────┘
             │           │
        refresh│    ┌────┴──────┐
               │    ▼           ▼
               │  ┌──────┐ ┌──────────┐
               └─▶│ACTIVE│ │VALIDATED │
                  └──────┘ │  or      │
                           │INVALIDATED│
                           └──────────┘
```

### 6.2 Staleness Rules

| Artifact Type | Goes Stale After | Warning At |
|---------------|-----------------|------------|
| Signal | 90 days without link | 60 days |
| Hypothesis | 30 days without experiment data | 21 days |
| Decision | Per `review_trigger` or 180 days | 14 days before |
| Feature | 45 days in `scoping` | 30 days |
| Experiment | 14 days without results | 10 days |
| Release Manifest | 30 days in `staging` | 20 days |

---

## 7. The Decision Mesh

Traditional RACI charts are static and ignored. The Decision Mesh is dynamic.

### 7.1 Decision Types

```
┌─────────────────────────────────────────────────────┐
│                   DECISION TYPES                    │
│                                                     │
│  TYPE A: Architectural                              │
│  ├── Affects: System design, data models, APIs      │
│  ├── Consent: Tech leads + affected teams           │
│  ├── Review trigger: Major version or 12 months     │
│  └── Documentation: Required ADR + FORGE DEC        │
│                                                     │
│  TYPE B: Product                                    │
│  ├── Affects: UX, features, pricing, positioning    │
│  ├── Consent: Product + design + affected squads    │
│  ├── Review trigger: Quarterly or metric threshold  │
│  └── Documentation: Required FORGE DEC              │
│                                                     │
│  TYPE C: Operational                                │
│  ├── Affects: Processes, tooling, team structure    │
│  ├── Consent: Team leads + affected members         │
│  ├── Review trigger: 6 months or team change        │
│  └── Documentation: Lightweight FORGE DEC           │
│                                                     │
│  TYPE D: Execution                                  │
│  ├── Affects: Implementation details, sprint scope  │
│  ├── Consent: Squad (delegated)                     │
│  ├── Review trigger: Release cycle                  │
│  └── Documentation: Code comments + brief DEC       │
└─────────────────────────────────────────────────────┘
```

### 7.2 Consent Protocol

```
1. PROPOSE   → Author creates DEC artifact and shares with participants
2. UNDERSTAND → 24-48h async read period (no discussion yet)
3. REACT     → Participants signal: ✅ Consent | 🔄 Need Info | 🚫 Object
4. RESOLVE   → Any objections must be specific and actionable
               Author modifies DEC or schedules sync to resolve
5. CLOSE     → All objections resolved or explicitly withdrawn
               DEC moves to ACTIVE with full consent record
```

**Consent Rule**: An objection must include:
- What specifically will break
- Under what conditions
- A proposed resolution (or "I need X to find one")

Objections like "I don't like this" are not valid without specificity.

---

## 8. Cognitive Contracts

A Cognitive Contract is FORGE's replacement for traditional API contracts and 
user stories. It captures the **mental model** that must be true for the system 
to work — for both machines and humans.

```yaml
forge_type: cognitive_contract
id: cc-{nanoid}

cognitive_contract:
  name: ""
  
  # The mental model the USER must have for this to work
  user_model:
    assumes_user_knows:
      - ""
    assumes_user_can:
      - ""
    must_not_confuse_with:
      - ""
  
  # The mental model the SYSTEM must have
  system_model:
    invariants:
      - ""  # Things that are always true
    preconditions:
      - ""  # Things that must be true before
    postconditions:
      - ""  # Things that will be true after
    side_effects:
      - ""  # Known effects on other system parts
  
  # The mental model ENGINEERS must have
  engineer_model:
    key_abstractions:
      - name: ""
        definition: ""
        do_not_confuse_with: ""
    
    failure_modes:
      - scenario: ""
        system_behavior: ""
        user_experience: ""
        recovery: ""
  
  # Verification
  contracts_verified_by:
    - type: unit_test | integration_test | e2e | manual | property_based
      reference: ""

feature: fea-{id}
```

---

## 9. Drift Detection

**Drift** is when implementation diverges from intent. FORGE detects four types:

### 9.1 Drift Types

```
┌─────────────────────────────────────────────────────────────┐
│                        DRIFT TYPES                          │
│                                                             │
│  🔴 SPEC DRIFT                                              │
│     Implementation doesn't match Feature artifact           │
│     Detection: Static analysis of code vs. ACs              │
│     Example: AC says "must work offline" but code           │
│     requires network for core flow                          │
│                                                             │
│  🟠 HYPOTHESIS DRIFT                                        │
│     Feature shipped but hypothesis not being measured        │
│     Detection: Telemetry coverage analysis                  │
│     Example: Feature live 30 days, zero experiment data     │
│                                                             │
│  🟡 DECISION DRIFT                                          │
│     Code violates a recorded decision                       │
│     Detection: ADR/DEC rules encoded as linting rules        │
│     Example: DEC says "no direct DB access from UI layer"   │
│     but new PR does exactly that                            │
│                                                             │
│  🔵 SIGNAL DRIFT                                            │
│     Reality has changed but artifacts haven't updated       │
│     Detection: Telemetry vs. hypothesis targets             │
│     Example: Hypothesis targets 15% improvement, actual     │
│     shows -3% — but no one updated the hypothesis           │
└─────────────────────────────────────────────────────────────┘
```

### 9.2 Drift Score Calculation

```
drift_score = weighted_average(
  spec_drift     * 0.35,
  hypothesis_drift * 0.30,
  decision_drift  * 0.20,
  signal_drift    * 0.15
)

Thresholds:
  0.0 - 0.2: Healthy    ✅
  0.2 - 0.4: Warning    ⚠️
  0.4 - 0.6: Critical   🔴
  0.6 - 1.0: Emergency  🚨 (auto-escalation triggered)
```

### 9.3 Drift Response Protocol

```yaml
# On drift detection
drift_response:
  - severity: warning
    actions:
      - notify: owner
      - create_signal: auto
      - staleness_flag: artifact
  
  - severity: critical
    actions:
      - notify: [owner, team_lead]
      - block_promotion: staging_to_production
      - require_decision: update_or_accept
  
  - severity: emergency
    actions:
      - notify: [owner, team_lead, vp_eng]
      - auto_rollback: if_live
      - require_postmortem: true
```

---

## 10. The Forge Graph

The FORGE Graph is the **nervous system** of the methodology. Every artifact is 
a node; every relationship is a typed, directional edge.

### 10.1 Graph Schema

```
Nodes: SIG | HYP | DEC | FEA | EXP | REL | RSP | CC | Code | Test | Metric

Edge Types:
  INFORMED_BY     SIG ──────────────▶ HYP
  SHAPED_BY       DEC ──────────────▶ FEA  
  TESTS           FEA ──────────────▶ HYP
  IMPLEMENTS      Code ─────────────▶ FEA
  VERIFIES        Test ─────────────▶ FEA (via AC)
  MEASURES        Metric ───────────▶ HYP
  GENERATED       RSP ──────────────▶ SIG
  SUPERSEDES      DEC ──────────────▶ DEC
  BLOCKS          FEA ──────────────▶ FEA
  CONTRADICTS     SIG ──────────────▶ SIG (detected by AI)
  VALIDATES       EXP ──────────────▶ HYP
  INVALIDATES     EXP ──────────────▶ HYP
  DEPENDS_ON      FEA ──────────────▶ FEA
```

### 10.2 Graph Traversal Queries

```bash
# Find everything that must be updated if a signal is updated
forge graph impact sig-a3kx --direction downstream

# Find all signals that have no linked hypothesis after 30 days
forge graph orphans --type signal --older-than 30d

# Show the full lineage of a feature
forge graph lineage fea-x7kp --full

# Find decisions that might be invalidated by new signals
forge graph conflicts --type decision --against sig-new

# Health check across the entire graph
forge graph health --report
```

### 10.3 Graph Visualization

```
Example: Feature fea-x7kp lineage

sig-a3kx ──[INFORMED_BY]──▶ hyp-b2mp ──[TESTS]──▶ fea-x7kp
sig-c9np ──[INFORMED_BY]──▶ hyp-b2mp              │
                                                    ├──[SHAPED_BY]─── dec-p4qw
sig-d2vw ──[INFORMED_BY]──▶ hyp-m9rs ──────────────┘
                                                    │
                                          ┌─────────┘
                                          ├──[IMPLEMENTS]─── commit:abc123
                                          ├──[VERIFIES]───── test:auth.spec.ts
                                          └──[MEASURES]───── metric:conversion_rate

Health: fea-x7kp
  Spec Drift: 0.12 ✅
  Hypothesis Drift: 0.31 ⚠️  (telemetry gap detected)
  Decision Drift: 0.00 ✅
  Signal Drift: 0.18 ✅
  Overall: 0.21 ⚠️
```

---

## 11. Integration Protocols

FORGE integrates at every level of the development stack.

### 11.1 VCS Integration

```yaml
# .forge/vcs-integration.yaml
git:
  commit_hooks:
    pre_commit:
      - validate_forge_references  # Commits must reference FEA or DEC
      - check_drift_score          # Warn if drift > 0.4
    
    commit_message_format: |
      type(fea-{id}): description
      
      forge: fea-{id} | dec-{id}
      closes: ac-{id}
    
  pr_integration:
    require_forge_links: true
    auto_update_feature_coverage: true
    drift_check_on_merge: true
    
    pr_template: |
      ## FORGE Links
      Feature: fea-{id}
      Acceptance Criteria Addressed: ac-{id}, ac-{id}
      Decisions Followed: dec-{id}
      
      ## Drift Check
      [ ] I've run `forge check drift` locally
      [ ] This PR does not violate any active decisions
      
      ## Observability
      [ ] New events tracked per FEA observability spec
      [ ] Dashboards updated if needed
```

### 11.2 CI/CD Integration

```yaml
# .forge/pipeline.yaml
stages:
  forge_gate:
    position: before_deploy
    checks:
      - name: drift_check
        command: forge check drift --threshold 0.4
        on_failure: block
      
      - name: ac_coverage
        command: forge check acceptance-criteria --min-coverage 0.9
        on_failure: warn
      
      - name: observability_check
        command: forge check telemetry --feature $FEATURE_ID
        on_failure: warn
      
      - name: decision_compliance
        command: forge check decisions --changed-files $CHANGED_FILES
        on_failure: block
    
    release_manifest_gate:
      require: rel-{id}
      readiness_min_score: 0.95
```

### 11.3 Telemetry Integration

```yaml
# .forge/telemetry.yaml
providers:
  - type: datadog | mixpanel | amplitude | segment | custom
    config: {}

bindings:
  # Bind metrics to hypotheses for automatic validation
  - metric: "user.export.completed"
    hypothesis: hyp-b2mp
    role: primary_metric
    aggregation: count
    window: "7d"
    
  - metric: "page.load.p95"
    hypothesis: hyp-m9rs  
    role: guardrail
    threshold: "<800ms"
    alert_on_breach: true
```

### 11.4 IDE Integration

```json
// .vscode/forge.json
{
  "forge.enabled": true,
  "forge.linting": {
    "decision_violations": "error",
    "missing_forge_link": "warning",
    "stale_ac_reference": "warning"
  },
  "forge.inline_annotations": {
    "show_drift_score": true,
    "show_ac_status": true,
    "show_linked_hypothesis": true
  }
}
```

---

## 12. AI Augmentation Layer

FORGE is designed for AI-human collaboration, not AI replacement.

### 12.1 AI Roles in FORGE

```
┌─────────────────────────────────────────────────────────────┐
│                    AI AUGMENTATION ROLES                    │
│                                                             │
│  ANALYST                                                    │
│  • Cluster signals automatically                            │
│  • Detect contradicting signals                             │
│  • Suggest hypothesis framings                              │
│  • Identify patterns across the graph                       │
│                                                             │
│  CRITIC                                                     │
│  • Flag hypotheses with weak falsification criteria         │
│  • Identify decisions that contradict each other            │
│  • Point out missing unknowns                               │
│  • Question scope that doesn't connect to signals           │
│                                                             │
│  NAVIGATOR                                                  │
│  • "Given these signals, here are the related decisions"    │
│  • "This feature will affect these 3 other features"        │
│  • "Similar hypothesis hyp-x was invalidated because..."    │
│                                                             │
│  WRITER                                                     │
│  • Draft hypothesis from signals (human confirms)           │
│  • Generate acceptance criteria from hypothesis             │
│  • Summarize decision history for new team members          │
│  • Write release narratives from feature list               │
└─────────────────────────────────────────────────────────────┘
```

### 12.2 AI Confidence Transparency

All AI outputs carry explicit confidence and reasoning:

```yaml
ai_output:
  type: signal_cluster | hypothesis_draft | drift_detection | pattern_match
  
  content: ""
  confidence: 0.0-1.0
  
  reasoning:
    method: semantic_similarity | rule_based | llm | statistical
    evidence: []
    limitations: []
  
  human_action_required: true | false
  suggested_action: ""
  
  # AI must declare what it doesn't know
  ai_unknowns:
    - "Could not access telemetry data older than 90 days"
    - "Signal sig-x used ambiguous language — confidence reduced"
```

### 12.3 AI Interaction Protocol

```bash
# Ask AI to analyze a set of signals
forge ai analyze --signals sig-a,sig-b,sig-c --suggest hypothesis

# Ask AI to critique a hypothesis
forge ai critique hyp-b2mp

# Ask AI to find related decisions for a new feature
forge ai context --for fea-new

# Ask AI to generate AC from a hypothesis  
forge ai generate acceptance-criteria --from hyp-b2mp --draft-only

# Ask AI to detect unknown unknowns in a feature
forge ai blind-spots fea-x7kp
```

---

## 13. Governance Rituals

FORGE replaces heavyweight process with **lightweight rituals** — short, 
purposeful, time-boxed.

### 13.1 Signal Triage (Weekly, 30 min)

```
Purpose: Process raw signals before they go stale
Format:  Async-first, sync if needed

Agenda:
  1. Review new signals from past week (AI pre-clustered)
  2. Link signals to existing hypotheses or create new ones
  3. Archive signals that are duplicates or invalid
  4. Flag signals that contradict active decisions

Output:
  - All signals > 7 days old are linked or archived
  - New hypotheses drafted for clusters
  - Alerts sent for contradicting signals
```

### 13.2 Decision Review (Monthly, 45 min)

```
Purpose: Review decisions due for reconsideration
Format:  Sync with async prep

Agenda:
  1. AI report: decisions past review trigger date
  2. AI report: decisions whose assumptions have been invalidated
  3. For each: confirm | update | reverse | extend
  4. Review any objections that weren't resolved

Output:
  - All reviewed decisions updated with new review_trigger
  - Reversed decisions linked to new decisions
  - Invalidated assumptions documented
```

### 13.3 Hypothesis Health Check (Bi-weekly, 30 min)

```
Purpose: Validate that experiments are running and results are captured
Format:  Async with async output

Agenda:
  1. Review hypotheses with declining confidence scores
  2. Review experiments that have been running >max duration
  3. Review features live >30 days with no hypothesis outcome

Output:
  - Experiments acted on (conclude, extend, stop)
  - Dead hypotheses archived
  - Retroactive RSP created for features without outcomes
```

### 13.4 Forge Sync (Per Sprint/Cycle, 60 min)

```
Purpose: Full system health check and alignment
Format:  Sync, whole team

Agenda:
  1. Graph health report (drift scores, orphan artifacts)
  2. Release manifest review for upcoming release
  3. Feature health (ACs, observability gaps)
  4. Open consent items
  5. Retro signal review

Output:
  - Prioritized action list
  - Assigned owners for unhealthy artifacts
  - Any new decisions needed
```

---

## 14. Tooling Ecosystem

### 14.1 FORGE CLI

```bash
# Initialize FORGE in a repo
forge init

# Create artifacts
forge signal create
forge hypothesis create --from-signals sig-a,sig-b
forge decision create --type architectural
forge feature create --from-hypothesis hyp-b2mp

# Check health
forge check drift
forge check orphans
forge check staleness
forge check decisions

# Graph operations
forge graph lineage fea-x7kp
forge graph impact sig-a3kx
forge graph health

# AI operations
forge ai analyze
forge ai critique hyp-b2mp
forge ai blind-spots fea-x7kp

# Reporting
forge report sprint
forge report release rel-{id}
forge report health --format=json|html|markdown
```

### 14.2 File System Layout

```
.forge/
├── forge.config.yaml          # Project-level config
├── signals/
│   ├── sig-a3kx.yaml
│   └── sig-b7mq.yaml
├── hypotheses/
│   └── hyp-b2mp.yaml
├── decisions/
│   └── dec-p4qw.yaml
├── features/
│   └── fea-x7kp.yaml
├── experiments/
│   └── exp-m2nr.yaml
├── releases/
│   └── rel-2024-q1.yaml
├── retrospectives/
│   └── rsp-sprint-42.yaml
├── cognitive-contracts/
│   └── cc-auth-flow.yaml
├── graph/
│   └── edges.json             # Graph edge index (auto-generated)
└── ai/
    └── cache/                 # AI analysis cache
```

### 14.3 forge.config.yaml

```yaml
# .forge/forge.config.yaml
version: "1.0.0"
project:
  id: ""
  name: ""
  team: ""

staleness:
  signal_days: 90
  hypothesis_days: 30
  decision_days: 180
  feature_days: 45

drift:
  warning_threshold: 0.2
  critical_threshold: 0.4
  emergency_threshold: 0.6
  auto_escalation: true

governance:
  consent_timeout_hours: 48
  decision_types:
    architectural: [tech-lead, affected-team-leads]
    product: [product-lead, design-lead]
    operational: [team-lead]
    execution: [squad]

ai:
  provider: openai | anthropic | local | custom
  model: ""
  auto_cluster_signals: true
  auto_draft_hypotheses: false  # Require explicit invocation
  confidence_threshold: 0.7
  
integrations:
  git:
    require_forge_links: true
  ci:
    drift_gate_enabled: true
  telemetry:
    provider: ""
```

---

## 15. Migration from Legacy Specs

### 15.1 Migration Path

```
Phase 1: SHADOW (Week 1-2)
  Run FORGE alongside existing process
  Import existing docs as raw signals
  Don't change anything yet
  
Phase 2: SIGNALS (Week 3-4)
  All new work captured as signals first
  Existing PRDs converted to hypotheses
  Begin using decision artifacts for new decisions
  
Phase 3: FEATURES (Month 2)
  New features get full FORGE treatment
  Existing features get lightweight FEA wrappers
  Begin graph construction
  
Phase 4: GOVERNANCE (Month 3)
  Introduce governance rituals
  CI integration enabled
  Telemetry bindings established
  
Phase 5: FULL FORGE (Month 4+)
  Legacy docs deprecated
  All artifacts in FORGE graph
  AI augmentation enabled
  Full drift detection active
```

### 15.2 Converting a PRD to FORGE

```bash
# Import a document as signals
forge import --from=prd --file=product-requirements.md --output=signals

# AI will:
# 1. Parse document sections
# 2. Create SIG artifacts for each requirement/observation
# 3. Suggest hypothesis framings
# 4. Flag assumptions and unknowns
# 5. Generate a migration report

# Review and confirm
forge import review --batch=import-2024-01-15
```

---

## 16. Examples

### 16.1 Complete Flow: "Users Can't Find Export"

**Step 1: Signal captured**
```yaml
# sig-a3kx.yaml
signal:
  category: user_pain
  source:
    type: support_ticket
    reference: "zendesk-bulk-2024-01"
    confidence: 0.9
  observation: |
    47 support tickets in the last 30 days mention inability to 
    locate the data export functionality. Tickets use terms like 
    "can't find", "where is", "download my data", "export button".
  evidence:
    - type: metric
      content: "47 tickets, avg CSAT 2.1/5 for affected users"
    - type: quote  
      content: "I've been looking for 20 minutes, where is the export?"
  affected_dimensions:
    - users: "enterprise tier, data analysts"
      frequency: often
      severity: high
```

**Step 2: Hypothesis formed**
```yaml
# hyp-b2mp.yaml
hypothesis:
  statement: |
    We believe making the export function discoverable via 
    the main navigation (not buried in settings) for enterprise 
    data analysts will reduce "can't find export" support tickets 
    by 80% and improve CSAT for this segment from 2.1 to 4.0+ 
    because the current location requires 4 clicks through 
    unintuitive menus.
  
  validation_criteria:
    primary_metric:
      name: "export_related_support_tickets_per_week"
      current_baseline: 11.75
      target: 2.35
      direction: decrease
      timeframe: "30 days post-launch"
    
    guardrail_metrics:
      - name: "navigation_bar_click_through_rate"
        threshold: "no regression >5%"
  
  falsification_criteria:
    - "Tickets don't decrease after 30 days AND users report finding it but still submitting tickets"
    - "CSAT improves but ticket volume stays same (different root cause)"
  
  unknowns:
    known_unknowns:
      - assumption: "Export is the primary cause of low CSAT (not other issues)"
        risk: high
        how_to_resolve: "Tag support tickets by primary complaint"
```

**Step 3: Decision made**
```yaml
# dec-p4qw.yaml
decision:
  title: "Add Export to primary navigation bar"
  statement: |
    We have decided to add an Export item to the primary 
    navigation bar rather than creating a dedicated data 
    management section, given time constraints and signal 
    strength.
  
  alternatives_considered:
    - option: "Dedicated 'Data' section in nav"
      why_rejected: "2x build time, unclear if needed beyond export"
      could_revisit_if: "3+ more data management features requested"
    
    - option: "Global search improvement to surface export"
      why_rejected: "Search usage by this segment is <10%"
  
  reversibility:
    type: reversible
    reversal_cost: low
    reversal_condition: "Nav bar becomes too crowded (>8 items)"
```

**Step 4: Feature created**
```yaml
# fea-x7kp.yaml
feature:
  name: "Export Navigation Shortcut"
  hypothesis: hyp-b2mp
  
  scope:
    includes:
      - "Export button in primary nav bar"
      - "Tooltip on hover explaining formats"
      - "Same export functionality as current settings flow"
    excludes:
      - "New export formats"
      - "Scheduled exports"
      - "Export history"
  
  journeys:
    - persona: "Enterprise data analyst"
      journey: |
        GIVEN I am logged in to any page
        WHEN I look at the navigation bar
        THEN I see an "Export" item clearly visible
        AND clicking it opens the export panel immediately
      
      acceptance_criteria:
        - id: ac-001
          description: "Export visible in nav on all authenticated pages"
          type: functional
          automated: true
        - id: ac-002
          description: "Export panel opens in <200ms"
          type: performance
          automated: true
```

---

## 17. Anti-Patterns

### ❌ Signal Dumping
**What**: Creating signals for everything without curation  
**Problem**: Graph becomes noise; real signals lost  
**Fix**: Weekly triage ritual; AI deduplication; require evidence

### ❌ Hypothesis Laundering
**What**: Writing hypotheses backwards from already-built features  
**Problem**: Defeats the purpose; creates false confidence  
**Fix**: Require hypothesis before feature creation date; git history audits

### ❌ Decision Hoarding
**What**: Making decisions unilaterally without recording them  
**Problem**: Hidden constraints; decision debt; repeated debates  
**Fix**: "If it affects more than your PR, write a DEC" rule

### ❌ Metric Theater
**What**: Adding telemetry but never checking it against hypotheses  
**Problem**: Hypothesis drift goes undetected  
**Fix**: Telemetry bindings required; auto-alerts on missing data

### ❌ Graph Abandonment
**What**: Creating artifacts but not linking them  
**Problem**: Orphan nodes; broken lineage; useless graph  
**Fix**: Orphan detection; links required before status promotion

### ❌ Consent Bypass
**What**: Moving decisions to ACTIVE without completing consent  
**Problem**: False alignment; re-litigation later  
**Fix**: System enforces consent record before status change

### ❌ Staleness Tolerance
**What**: Ignoring staleness warnings  
**Problem**: Artifacts become trusted but wrong  
**Fix**: Stale artifacts automatically downgrade confidence; CI gates

### ❌ AI Laundering
**What**: Accepting AI-drafted artifacts without review  
**Problem**: AI hallucinations become official methodology artifacts  
**Fix**: AI outputs are always `draft` requiring human confirmation

---

## 18. Glossary

| Term | Definition |
|------|-----------|
| **Artifact** | Any FORGE-typed document (SIG, HYP, DEC, FEA, EXP, REL, RSP, CC) |
| **Cognitive Contract** | Document capturing the mental model required for users, system, and engineers |
| **Confidence Score** | 0.0-1.0 measure of how much an artifact reflects current reality |
| **Consent** | Governance process where anyone can block with specific, resolvable objection |
| **Drift** | Divergence between what an artifact says and what actually exists |
| **Drift Score** | Weighted measure of all drift types for a feature |
| **FORGE Graph** | Directed graph of all artifacts and their typed relationships |
| **FORGE Runtime** | Continuous automated system monitoring the graph and detecting issues |
| **Hypothesis** | Formalized belief with specific validation and falsification criteria |
| **Lineage** | The complete upstream chain of signals → decisions → hypotheses → feature |
| **Orphan** | An artifact with no links after the expected link window |
| **Signal** | Atomic observation about the world, before any interpretation |
| **Signal Cluster** | AI-detected group of signals pointing to the same underlying issue |
| **Staleness** | State where an artifact hasn't been updated within its required window |
| **Unknown Unknown** | An area where the team doesn't know what they don't know |

---

## Contributing to FORGE

FORGE is itself governed by FORGE. All changes to this methodology:

1. Must start with a Signal (observation about a gap or problem)
2. Must be framed as a Hypothesis (what change will improve what outcome)
3. Must go through the Consent Protocol
4. Major changes require a DEC artifact
5. This document is auto-generated from FORGE artifacts in `/forge-meta`

---

*FORGE Methodology v1.0.0*  
*"Build what matters. Know what you built. Learn what it means."*
```

---

## Summary of What Makes FORGE Different

| Dimension | Traditional Spec / Spec-Kit | FORGE |
|-----------|----------------------------|-------|
| **Atomic unit** | Requirement | Signal |
| **Feature framing** | "Build this" | "Test this hypothesis" |
| **Documents** | Static files | Living graph nodes |
| **Staleness** | Undetected | Continuously scored |
| **Decisions** | Meeting notes / JIRA comment | First-class artifacts with consent records |
| **Governance** | Approval chains | Consent protocol |
| **AI role** | None | Analyst, Critic, Navigator, Writer |
| **Drift** | Invisible | Continuously measured, 4 types |
| **Unknowns** | Ignored | First-class field on every artifact |
| **Feedback loop** | Retro → Notion doc | RSP → new SIG → graph |
| **Code connection** | Manual | CI-enforced, git-linked |
| **Telemetry** | Separate system | Bound to hypotheses |