# AGENTS.md

## About Forge Kit and Forge CLI

**Forge Kit** is a comprehensive toolkit for implementing the FORGE (Feature-Oriented Requirements & Governance Engine) methodology — a living systems approach where requirements are signals, features are hypotheses, and decisions are first-class artifacts in a living graph.

**Forge CLI** is the command-line interface that bootstraps projects with the Forge Kit framework. It sets up the necessary directory structures, templates, and AI agent integrations to support the FORGE workflow.

The toolkit supports multiple AI coding assistants, allowing teams to use their preferred tools while maintaining consistent project structure and development practices.

---

## Integration Architecture

Each AI agent is a self-contained **integration subpackage** under `src/forge_cli/integrations/<key>/`. The subpackage exposes a single class that declares all metadata and inherits setup/teardown logic from a base class. Built-in integrations are then instantiated and added to the global `INTEGRATION_REGISTRY` by `src/forge_cli/integrations/__init__.py` via `_register_builtins()`.

```
src/forge_cli/integrations/
├── __init__.py            # INTEGRATION_REGISTRY + _register_builtins()
├── base.py                # IntegrationBase, MarkdownIntegration, TomlIntegration, YamlIntegration, SkillsIntegration
├── manifest.py            # IntegrationManifest (file tracking)
├── claude/                # Example: SkillsIntegration subclass
│   └── __init__.py        #   ClaudeIntegration class
├── gemini/                # Example: TomlIntegration subclass
│   └── __init__.py
├── copilot/               # Example: IntegrationBase subclass (custom setup)
│   └── __init__.py
└── ...                    # One subpackage per supported agent
```

### Adding a New Integration

#### 1. Choose a base class

| Your agent needs… | Subclass |
|---|---|
| Standard markdown commands (`.md`) | `MarkdownIntegration` |
| TOML-format commands (`.toml`) | `TomlIntegration` |
| YAML recipe files (`.yaml`) | `YamlIntegration` |
| Skill directories (`forge-<name>/SKILL.md`) | `SkillsIntegration` |
| Fully custom output | `IntegrationBase` directly |

#### 2. Create the subpackage

Create `src/forge_cli/integrations/<package_dir>/__init__.py`:

**Minimal example — Markdown agent:**

```python
\"\"\"Windsurf IDE integration.\"\"\"

from ..base import MarkdownIntegration


class WindsurfIntegration(MarkdownIntegration):
    key = "windsurf"
    config = {
        "name": "Windsurf",
        "folder": ".windsurf/",
        "commands_subdir": "workflows",
        "install_url": None,
        "requires_cli": False,
    }
    registrar_config = {
        "dir": ".windsurf/workflows",
        "format": "markdown",
        "args": "$ARGUMENTS",
        "extension": ".md",
    }
    context_file = ".windsurf/rules/forge-rules.md"
```

#### Required fields

| Field | Location | Purpose |
|---|---|---|
| `key` | Class attribute | Unique identifier; for CLI-based integrations, must match the CLI executable name |
| `config` | Class attribute (dict) | Agent metadata: `name`, `folder`, `commands_subdir`, `install_url`, `requires_cli` |
| `registrar_config` | Class attribute (dict) | Command output config: `dir`, `format`, `args` placeholder, file `extension` |
| `context_file` | Class attribute (str or None) | Path to agent context/instructions file |

#### 3. Register it

In `src/forge_cli/integrations/__init__.py`, add one import and one `_register()` call inside `_register_builtins()`.

#### 4. Test it

```bash
forge init my-project --integration <key>
ls -R my-project/.forge/commands/
```

---

## Command File Formats

### Markdown Format

```markdown
---
description: "Command description"
---

Command content with {SCRIPT} and $ARGUMENTS placeholders.
```

### TOML Format

```toml
description = "Command description"

prompt = """
Command content with {SCRIPT} and {{args}} placeholders.
"""
```

### YAML Format

```yaml
version: 1.0.0
title: "Command Title"
description: "Command description"
prompt: |
  Command content with {SCRIPT} and {{args}} placeholders.
```

## Argument Patterns

- **Markdown/prompt-based**: `$ARGUMENTS`
- **TOML-based**: `{{args}}`
- **YAML-based**: `{{args}}`
- **Script placeholders**: `{SCRIPT}` (replaced with actual script path)
- **Agent placeholders**: `__AGENT__` (replaced with agent name)

---

*This documentation should be updated whenever new integrations are added.*
