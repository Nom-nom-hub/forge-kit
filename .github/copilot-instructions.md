# Forge Kit Slash Commands

This project uses the FORGE methodology. The following slash commands are available.
Full command templates are stored in `.forge/templates/commands/`.

- `/forge.ai-analyze` — AI-powered analysis of FORGE artifacts — cluster related signals, suggest hypothesis framings, detect patterns, and surface unknown unknowns.
- `/forge.ai-blind-spots` — AI detection of unknown unknowns in FORGE artifacts — identifies hidden assumptions, external factors, missing stakeholders, and data gaps.
- `/forge.ai-critique` — AI critique of FORGE artifacts — evaluates hypothesis falsifiability, decision quality, feature completeness, and flags weaknesses with recommendations.
- `/forge.analyze` — Run cross-artifact consistency and coverage analysis across FORGE artifacts. Checks links, hypothesis coverage, decision health, and identifies gaps before implementation.
- `/forge.check` — Check FORGE graph health — drift detection, orphaned artifacts, staleness, decision compliance, and full health reporting.
- `/forge.checklist` — Generate FORGE quality checklists — 'unit tests for requirements writing.' Validates artifact completeness, clarity, consistency, and coverage across any FORGE domain.
- `/forge.clarify` — Identify and reduce ambiguity in FORGE artifacts through structured, sequential questioning. Maximum 5 questions per session, each with recommended answers.
- `/forge.constitution` — Create or update the FORGE constitution — the governing principles that guide all development decisions. Defines signal-first, hypothesis framing, consent, and drift detection principles.
- `/forge.decide` — Record a FORGE decision with context, alternatives, reversibility assessment, and consent protocol. Every significant choice becomes a first-class, traceable artifact.
- `/forge.experiment` — Design a FORGE experiment — a time-boxed test of a hypothesis with rigorous variant design, metric configuration, and stop conditions. Transforms a feature hypothesis into a measurable, executable experiment.
- `/forge.feature` — Create a FORGE feature from a hypothesis — the delivery container connecting hypotheses to code. Defines scope, user journeys, acceptance criteria, and technical surface area.
- `/forge.graph` — Query the FORGE artifact graph — trace lineages, predict impacts, find orphans, check health, and detect conflicts across all artifacts.
- `/forge.hypothesize` — Form a FORGE hypothesis from one or more signals. Transforms raw observations into a testable belief with validation criteria, falsification conditions, and known unknowns.
- `/forge.release` — Create a FORGE release manifest — a narrative connecting features and experiments to a release story. Defines rollout strategy, readiness gates, and monitoring window.
- `/forge.retrospect` — Run a FORGE retrospective — review releases, hypothesis outcomes, decision validity, and generate new signals from learnings. Closes the feedback loop by transforming outcomes into new signals.
- `/forge.signal` — Capture a FORGE signal — the atomic observation unit that drives all development. Validates, enriches, and persists the signal as a first-class artifact.
