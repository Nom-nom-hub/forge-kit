# Feature Specification: Interactive forge init

**ID**: fea-d5e1f8a2
**Status**: Draft | **ICE**: 8/7/9 (avg: 8/10)

## Tagline
Arrow-key-selectable model and script-type prompts when running `forge init` interactively, with full backward-compatible flag support for CI and power users.

## Linked Hypothesis
We believe adding interactive selection prompts for `--integration` (model) and `--script-type` to `forge init` for developers running in a terminal will result in eliminating the "Command not found" confusion for new users because the current CLI requires remembering flag names and available values, creating a barrier to first-time usage.

## Signals Driving This Feature
- **sig-7622aaae**: Terminal shows "Command not found" when running `forge init` without `--integration` flag, making it unclear what the correct usage is.

## Scope

### Includes
- Interactive model picker — arrow-key select from 13 AI coding agents when `--integration` is omitted
- Interactive script-type picker — choose between bash and powershell when `--script-type` is omitted
- Non-interactive fallback — CI/piped usage defaults to copilot+bash (identical to previous behavior)
- Explicit flags bypass prompts entirely — `--integration` and `--script-type` work as before
- Context file creation — integration-specific rules file installed in agent's expected location
- Script type stored in `forge.config.yaml` under `project.script_type`

### Excludes
- In-browser or web-based setup wizard — CLI-only interactive mode
- Persistent user preferences across projects — each `forge init` is independent
- Telemetry or analytics on prompt selections
- Multi-select or batch project initialization

### Deferred
- Custom prompt themes or branding — not needed for MVP
- Search/filter within integration picker — 13 options manageable without search
- Help text preview in the picker — `--help` flag shows full descriptions

## User Journeys

### Journey 1: New developer trying forge for the first time
```
GIVEN I am in my terminal and have just run `forge init my-project`
WHEN the CLI detects I'm in an interactive terminal without passing --integration
THEN I see "🔥 Which AI coding agent are you using?" with arrow-key-selectable options
AND after selecting, I see "🔥 Which scripting environment?" with bash/powershell options
AND the project is initialized with my chosen settings
```

**Acceptance Criteria:**
| ID | Description | Type |
|----|-------------|------|
| ac-001 | Running `forge init my-project` in a TTY shows the model picker as the first prompt | functional |
| ac-002 | Selecting an integration followed by a script type completes initialization and installs the correct context file | functional |
| ac-003 | `forge.config.yaml` contains `script_type` matching the user's selection | functional |

### Journey 2: Power user with known preferences
```
GIVEN I know my setup (Copilot + bash)
WHEN I run `forge init my-project --integration copilot --script-type bash`
THEN the project initializes immediately without any interactive prompts
AND the output shows the integration and script type I chose
```

**Acceptance Criteria:**
| ID | Description | Type |
|----|-------------|------|
| ac-004 | Passing `--integration` and `--script-type` flags skips all interactive prompts | functional |
| ac-005 | Passing `--integration` only keeps the default `--script-type=bash` without prompting | functional |

### Journey 3: CI/CD pipeline
```
GIVEN a CI pipeline that runs `forge init my-project` (no TTY)
WHEN the command executes in a non-TTY environment (piped, CI runner)
THEN the project initializes with default values (copilot, bash) without any prompts
AND the exit code is 0
```

**Acceptance Criteria:**
| ID | Description | Type |
|----|-------------|------|
| ac-006 | Running `forge init` in a non-TTY environment defaults to copilot+bash without interactive prompts | functional |
| ac-007 | Exit code is 0 on successful init, even in non-TTY mode | functional |

## Technical Surface Area

### Components Affected
- `src/forge_cli/cli.py` — CLI command definition, interactive prompt logic
- `src/forge_cli/prompts.py` (new) — questionary-based selection menus
- `src/forge_cli/commands/init.py` — `run_init()` accepts `script_type` parameter
- `pyproject.toml` — `questionary` dependency added

### API Changes
- `forge init` — `--integration` default changed from `"copilot"` to `None` (prompts when TTY)
- `forge init` — `--script-type` (`-s`) new option for bash/powershell selection

### Schema Changes
- `forge.config.yaml` — added `project.script_type` field

### Performance Budget
- Target startup latency: <300ms including questionary import
- Current: ~50ms (import overhead without questionary)

### Accessibility
- Keyboard navigable — questionary supports arrow keys + Enter by default
- No color-only indicators — options are readable without color

## Observability

### Events to Track
- `forge_init_interactive` — `forge init` was run with interactive prompts
- `forge_init_flags` — `forge init` was run with explicit `--integration`/`--script-type` flags
- `forge_init_noninteractive` — `forge init` was run in non-TTY mode (CI/pipe)

### Dashboards
- CLI Usage — ratio of interactive vs. flag-based vs. CI inits
