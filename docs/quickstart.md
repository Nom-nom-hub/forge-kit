# Quickstart Guide

## 1. Install Forge CLI

```bash
uv tool install forge-cli --from git+https://github.com/Nom-nom-hub/forge-kit.git
```

## 2. Initialize a Project

```bash
forge init my-forge-project --integration copilot
cd my-forge-project
```

## 3. Capture a Signal

```bash
/forge.signal Users report they can't find the export button --source=support --severity=high
```

## 4. Form a Hypothesis

```bash
/forge.hypothesize --from-signals sig-abc123
```

## 5. Make a Decision

```bash
/forge.decide "Add export to primary navigation bar" --type architectural
```

## 6. Create a Feature

```bash
/forge.feature --from-hypothesis hyp-xyz789
```

## 7. Check Health

```bash
/forge.check health
```
