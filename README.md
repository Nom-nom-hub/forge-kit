<div align="center">
    <h1>🔥 Forge Kit</h1>
    <h3><em>Build what matters. Know what you built. Learn what it means.</em></h3>
</div>

<p align="center">
    <strong>An open source toolkit for the FORGE methodology — a living systems approach to software development where requirements are signals, features are hypotheses, and decisions are first-class artifacts.</strong>
</p>

<p align="center">
    <a href="#"><img src="https://img.shields.io/github/v/release/Nom-nom-hub/forge-kit" alt="Latest Release"/></a>
    <a href="#"><img src="https://img.shields.io/github/stars/Nom-nom-hub/forge-kit?style=social" alt="GitHub stars"/></a>
    <a href="./LICENSE"><img src="https://img.shields.io/github/license/Nom-nom-hub/forge-kit" alt="License"/></a>
</p>

---

## Table of Contents

- [🤔 What is FORGE?](#-what-is-forge)
- [⚡ Get Started](#-get-started)
- [📽️ Video Overview](#️-video-overview)
- [🧩 Community Extensions](#-community-extensions)
- [🎨 Community Presets](#-community-presets)
- [🤖 Supported AI Coding Agent Integrations](#-supported-ai-coding-agent-integrations)
- [🔧 Forge CLI Reference](#-forge-cli-reference)
- [📚 Core Philosophy](#-core-philosophy)
- [🛠️ Core vs. Extensions vs. Presets](#️-core-vs-extensions-vs-presets)
- [📖 Learn More](#-learn-more)
- [ Support](#-support)
- [📄 License](#-license)

## 🤔 What is FORGE?

FORGE (Feature-Oriented Requirements & Governance Engine) is a **living systems methodology** for modern software development. Traditional specs are static — they rot the moment they're written. FORGE treats every requirement as a **signal**, every feature as a **hypothesis**, and every decision as a **first-class artifact** in a living graph.

**The Three Laws of FORGE:**
```
LAW I:   Every artifact must be traceable to a signal.
LAW II:  Every decision must be reversible or explicitly marked terminal.
LAW III: The system must always know what it doesn't know.
```

### Why FORGE over Traditional Specs?

| Dimension | Traditional Spec | FORGE |
|-----------|-----------------|-------|
| **Atomic unit** | Requirement | Signal |
| **Feature framing** | "Build this" | "Test this hypothesis" |
| **Documents** | Static files | Living graph nodes |
| **Staleness** | Undetected | Continuously scored |
| **Decisions** | Meeting notes | First-class artifacts with consent records |
| **Governance** | Approval chains | Consent protocol |
| **AI role** | None | Analyst, Critic, Navigator, Writer |
| **Drift** | Invisible | Continuously measured |
| **Unknowns** | Ignored | First-class field on every artifact |

## ⚡ Get Started

### 1. Install Forge CLI

Requires **[uv](https://docs.astral.sh/uv/)**:

```bash
uv tool install forge-cli --from git+https://github.com/Nom-nom-hub/forge-kit.git@v0.1.0
```

### 2. Initialize a project

```bash
forge init my-forge-project --integration copilot
cd my-forge-project
```

### 3. Capture your first signal

```bash
/forge.signal Users report they can't find the export button --source=support --severity=high
```

### 4. Form a hypothesis

```bash
/forge.hypothesize --from-signals sig-abc123
```

### 5. Make a decision

```bash
/forge.decide "Add export to primary navigation" --type architectural
```

### 6. Create a feature

```bash
/forge.feature --from-hypothesis hyp-xyz789
```

## 🔧 Available Slash Commands

After running `forge init`, your AI coding agent will have access to these slash commands:

### Core Commands

| Command | Description |
|---------|-------------|
| `/forge.signal` | Capture a new signal (observation from users, metrics, etc.) |
| `/forge.hypothesize` | Form a hypothesis from one or more signals |
| `/forge.decide` | Record a decision with consent protocol |
| `/forge.feature` | Create a feature from a hypothesis |
| `/forge.experiment` | Design and run an experiment |
| `/forge.release` | Create a release manifest |
| `/forge.retrospect` | Generate retrospective signals |

### Quality Commands

| Command | Description |
|---------|-------------|
| `/forge.check` | Check drift, orphans, staleness across the FORGE graph |
| `/forge.clarify` | Identify underspecified areas in signals/hypotheses |
| `/forge.analyze` | Cross-artifact consistency and coverage analysis |
| `/forge.graph` | Query the FORGE graph (lineage, impact, health) |

### AI Commands

| Command | Description |
|---------|-------------|
| `/forge.ai.analyze` | AI analysis of signals, hypotheses, decisions |
| `/forge.ai.critique` | AI critique of a hypothesis or decision |
| `/forge.ai.blind-spots` | AI detection of unknown unknowns |

## 🧩 Making Forge Kit Your Own: Extensions & Presets

Forge Kit can be tailored through two complementary systems — **extensions** and **presets**:

| Priority | Component Type | Location |
|---------:|---------------|----------|
| ⬆ 1 | Project-Local Overrides | `.forge/templates/overrides/` |
| 2 | Presets — Customize core & extensions | `.forge/presets/templates/` |
| 3 | Extensions — Add new capabilities | `.forge/extensions/templates/` |
| ⬇ 4 | Forge Kit Core — Built-in FORGE commands & templates | `.forge/templates/` |

## 🤖 Supported AI Coding Agent Integrations

Forge Kit works with 30+ AI coding agents — both CLI tools and IDE-based assistants. Run `forge integration list` to see all available integrations.

## 📚 Core Philosophy

FORGE is built on these principles:

- **Living Over Static**: Artifacts are versioned, interconnected graph nodes with confidence scores, automatic staleness detection, and bidirectional links.
- **Signal-First Capture**: Before any feature, a Signal must exist. Signals are lightweight — 30-second capture.
- **Hypothesis Framing**: Every feature is a hypothesis, not a requirement.
- **Consent-Based Governance**: Governance is not approval chains — it's consent. Anyone can block with a specific, resolvable objection.
- **The Unknown is First-Class**: Every artifact carries an `unknowns` field.

##  Support

For support, please open a [GitHub issue](https://github.com/Nom-nom-hub/forge-kit/issues/new).

## 📄 License

This project is licensed under the terms of the MIT open source license. See [LICENSE](./LICENSE).
