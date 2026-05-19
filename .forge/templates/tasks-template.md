---
description: "Task list template for feature implementation"
---

# Tasks: [FEATURE_NAME]

**Input**: Design documents from `.forge/features/[fea-id]/`

**Prerequisites**: feature.md (required), hypothesis (required for validation criteria), plan.md, data-model.md, contracts/

## Format: `[ID] [P?] [Context] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- ** [Context]**: Signal (SIG), Hypothesis (HYP), Decision (DEC), Feature (FEA)
- Include exact file paths in descriptions

---

## Phase 1: Foundation (Shared Infrastructure)

**Purpose**: Project initialization, FORGE setup, and telemetry configuration

- [ ] T001 [P] Create `.forge/` directory with artifact subdirectories
- [ ] T002 [P] Initialize language/framework project structure
- [ ] T003 [P] Configure telemetry bindings for hypothesis metrics
- [ ] T004 [DEC] Verify all referenced decisions are active

**Checkpoint**: Foundation ready — signal-to-hypothesis lineage must be complete

---

## Phase 2: Signal & Hypothesis Validation

**Purpose**: Ensure the FORGE foundation is solid before building

- [ ] T005 Validate all signals linked to this feature are current (not stale)
- [ ] T006 [HYP] Verify hypothesis falsification criteria are defined
- [ ] T007 [HYP] Set up experiment configuration if needed
- [ ] T008 [DEC] Record any new decisions required by feature implementation

**Checkpoint**: Hypothesis is testable and validated

---

## Phase 3: Data Model & Contracts

**Purpose**: Define the data structures and API contracts

- [ ] T009 [P] [FEA] Define data models/entities in `.forge/features/[fea-id]/data-model.md`
- [ ] T010 [P] [FEA] Define API contracts in `.forge/features/[fea-id]/contracts/`
- [ ] T011 [CC] Create cognitive contract for user/system mental model

**Checkpoint**: Contracts defined and ready for implementation

---

## Phase 4: Core Feature Implementation

**Purpose**: Build the feature per acceptance criteria, organized by user journey

### Phase 4a: AC Implementation

<!-- Tasks are grouped by acceptance criteria. Each group is independently testable. -->

**AC-001: [Description]** <!-- functional | performance | accessibility | security -->

- [ ] T012 [P] [FEA] Implement AC-001 in [path]
- [ ] T013 [FEA] Test AC-001 validation

**AC-002: [Description]**

- [ ] T014 [P] [FEA] Implement AC-002 in [path]
- [ ] T015 [FEA] Wire AC-002 to feature flow

[Add more AC groups as needed]

### Phase 4b: Hypothesis Measurement Wiring

- [ ] T016 [HYP] Wire telemetry events for primary metric
- [ ] T017 [HYP] Wire telemetry events for guardrail metrics
- [ ] T018 [HYP] Set up dashboards and alerts

**Checkpoint**: Feature is functional and measurable

---

## Phase 5: Validation & Quality

**Purpose**: Ensure feature quality, drift detection, and readiness

- [ ] T019 [FEA] Write contract tests for API endpoints
- [ ] T020 [FEA] Run drift check: `forge check drift`
- [ ] T021 [FEA] Run orphan check: `forge check orphans`
- [ ] T022 [DEC] Verify decision compliance
- [ ] T023 [P] Update documentation

**Checkpoint**: Feature is validated and drift-free

---

## Phase 6: Release Preparation

**Purpose**: Prepare for release

- [ ] T024 [FEA] Update release manifest with this feature
- [ ] T025 [REL] Run readiness checklist
- [ ] T026 [REL] Create retrospective signal template
- [ ] T027 [FEA] Final drift score check (target: <0.2)

---

## Dependencies & Execution Order

### Phase Dependencies
- **Phase 1 (Foundation)**: No dependencies — can start immediately
- **Phase 2 (Validation)**: Depends on Phase 1
- **Phase 3 (Contracts)**: Depends on Phase 2
- **Phase 4 (Implementation)**: Depends on Phase 3
- **Phase 5 (Quality)**: Depends on Phase 4
- **Phase 6 (Release)**: Depends on Phase 5

### Within Each Phase
- Tasks marked [P] can run in parallel
- Tests (if included) MUST be written and FAIL before implementation
- Models before services, services before endpoints

### Parallel Opportunities
- All Phase 1 tasks marked [P] can run in parallel
- AC-implementation tasks within Phase 4a that affect different files can run in parallel
- Documentation updates (T023) can overlap with Phase 5
