# FORGE: Quick Signal Capture (PowerShell)
# Usage: .\scripts\powershell\signal-capture.ps1 -Observation "users can't find export" -Source "support_ticket" -Severity "high"
# Outputs JSON: { "signal_id": "sig-{nanoid}", "signal_path": ".forge/signals/sig-{nanoid}.yaml" }

param(
    [string]$Observation = "",
    [string]$Source = "team_observation",
    [string]$Severity = "medium",
    [string]$Category = "user_pain",
    [string]$Tags = "",
    [switch]$Json = $false
)

$ErrorActionPreference = "Stop"
$ROOT_DIR = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

if (-not $Observation) {
    if ($Json) {
        Write-Output '{"error": "Missing required -Observation argument"}'
    } else {
        Write-Error "Missing required -Observation argument"
    }
    exit 1
}

# Generate nanoid
$chars = "abcdefghijklmnopqrstuvwxyz0123456789"
$nanoid = -join ((1..8) | ForEach-Object { Get-Random -Maximum $chars.Length | ForEach-Object { $chars[$_] } })
$signalId = "sig-$nanoid"
$signalDir = Join-Path $ROOT_DIR ".forge\signals"
$timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")

New-Item -ItemType Directory -Path $signalDir -Force | Out-Null
$signalFile = Join-Path $signalDir "$signalId.yaml"

# Create signal YAML
@"
forge_type: signal
id: ${signalId}
version: "1.0.0"
created_at: ${timestamp}
created_by: cli
status: raw

signal:
  category: ${Category}
  source:
    type: ${Source}
    reference: ""
    confidence: 0.8
  observation: |
    ${Observation}
  evidence: []
  affected_dimensions:
    - users: ""
      frequency: sometimes
      severity: ${Severity}
  raw_tags: [${Tags}]

context:
  business_area: []
  technical_area: []
  time_sensitivity: medium

links:
  decisions: []
  features: []
  experiments: []
"@ | Out-File -FilePath $signalFile -Encoding utf8

if ($Json) {
    $output = @{
        signal_id = $signalId
        signal_path = $signalFile
        observation = $Observation
    }
    Write-Output ($output | ConvertTo-Json -Compress)
} else {
    Write-Host "Signal created: $signalId"
    Write-Host "Path: $signalFile"
}
