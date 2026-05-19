# Signal-First Workflow

A lightweight preset that strips the FORGE workflow down to a rapid signal → hypothesis → decide pipeline. Designed for teams who want the core FORGE methodology without the full ceremony of experiment tracking and release manifests.

## When to Use

Use Signal-First when you're:
- **Exploring unknowns** — rapid signal capture and hypothesis testing without full experiment scaffolding
- **Early stage projects** — before you need release manifests and retrospectives
- **Fast iteration cycles** — daily standups, quick decision loops, lightweight documentation

## Commands Included

| Command | Output | Description |
|---------|--------|-------------|
| `forge.signal` | `signals/<id>.yml` | Capture a signal with minimal fields — just what, observed, context |
| `forge.hypothesize` | `hypotheses/<id>.yml` + `signals/<id>.yml` update | Form hypothesis from signal with lightweight validation criteria |
| `forge.decide` | `decisions/<id>.yml` | Quick consent-based decision with signal-driven alternatives |

## What It Replaces

Signal-First overrides three core commands with lightweight variants:
- **forge.signal** — fewer fields, faster capture, auto-categorization
- **forge.hypothesize** — direct signal-to-hypothesis pipeline, no extra ceremony
- **forge.decide** — simplified consent protocol, minimal tracking

Full commands (feature, experiment, release, retrospect) remain available for when you need them.

## Hooks

| Event | Command | Optional | Description |
|-------|---------|----------|-------------|
| `before_signal` | `forge.git.commit` | Yes | Commit before signal capture |
| `after_signal` | `forge.git.commit` | Yes | Commit after signal capture |
| `before_hypothesize` | `forge.git.commit` | Yes | Commit before hypothesis |
| `after_hypothesize` | `forge.git.commit` | Yes | Commit after hypothesis |

## Installation

```bash
# Signal-First is a bundled preset — no download needed
forge preset add signal-first
```

## Development

```bash
# Test from local directory
forge preset add --dev ./presets/signal-first

# Verify commands resolve
forge preset resolve forge.signal

# Remove when done
forge preset remove signal-first
```

## License

MIT
