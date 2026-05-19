# FORGE: Setup Feature Directory Structure (PowerShell)
# Usage: .\scripts\powershell\setup-feature.ps1 -Name "export-shortcut" -FeatureId "fea-x7kp"
# Outputs JSON: { "feature_directory": ".forge/features/fea-x7kp", "spec_directory": "specs/fea-x7kp-export-shortcut" }

param(
    [string]$Name = "",
    [string]$FeatureId = "",
    [switch]$Json = $false
)

$ErrorActionPreference = "Stop"
$ROOT_DIR = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

if (-not $FeatureId) {
    if ($Json) {
        Write-Output '{"error": "Missing required -FeatureId argument"}'
    } else {
        Write-Error "Missing required -FeatureId argument"
    }
    exit 1
}

if (-not $Name) {
    $Name = $FeatureId -replace "^fea-", ""
}

$FeatureDir = Join-Path $ROOT_DIR ".forge\features\$FeatureId"
$SpecDir = Join-Path $ROOT_DIR "specs"

New-Item -ItemType Directory -Path $FeatureDir -Force | Out-Null
New-Item -ItemType Directory -Path $SpecDir -Force | Out-Null

if ($Json) {
    $output = @{
        feature_directory = $FeatureDir
        spec_directory = $SpecDir
    }
    Write-Output ($output | ConvertTo-Json -Compress)
} else {
    Write-Host "Feature directory: $FeatureDir"
    Write-Host "Spec directory: $SpecDir"
}
