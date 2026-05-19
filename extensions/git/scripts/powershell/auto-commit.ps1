<#
.SYNOPSIS
    Config-driven auto-commit for FORGE workflow hooks.
.DESCRIPTION
    Reads git-config.yml to determine if auto-commit is enabled for the given
    event, then stages and commits all changes.
.PARAMETER EventName
    The hook event name (e.g., after_signal, before_hypothesize).
.EXAMPLE
    .\auto-commit.ps1 after_signal
#>

param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$EventName
)

# Determine project root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = $null
$dir = $ScriptDir
while ($dir -ne [System.IO.Path]::GetPathRoot($dir)) {
    if (Test-Path (Join-Path $dir ".forge") -PathType Container -or Test-Path (Join-Path $dir ".git") -PathType Container) {
        $ProjectRoot = $dir
        break
    }
    $dir = Split-Path -Parent $dir
}

if (-not $ProjectRoot) {
    try { $ProjectRoot = git rev-parse --show-toplevel 2>$null } catch { exit 0 }
}

Set-Location $ProjectRoot

# Check if git is available
try {
    $null = git rev-parse --is-inside-work-tree 2>$null
} catch { exit 0 }

# Check config file
$ConfigFile = Join-Path $ProjectRoot ".forge" "extensions" "git" "git-config.yml"
if (-not (Test-Path $ConfigFile)) { exit 0 }

# Parse config (simple YAML parsing)
$Config = Get-Content $ConfigFile -Raw

# Check default
$DefaultEnabled = $false
if ($Config -match "default:\s*(true|false)") {
    $DefaultEnabled = ($matches[1] -eq 'true')
}

# Check event-specific config
$EventEnabled = $DefaultEnabled
$CommitMsg = ""

# Find the event block and extract enabled/message
$Lines = Get-Content $ConfigFile
$inEvent = $false
for ($i = 0; $i -lt $Lines.Count; $i++) {
    $line = $Lines[$i]
    if ($line -match "^\s+${EventName}:") {
        $inEvent = $true
        continue
    }
    if ($inEvent) {
        if ($line -match "^\s+[a-z_]+:") {
            # Check if next line starts a new event
            if ($line -match "^\s+[a-z_]+:") {
                # Could be another event key or sub-key
                if ($line -match "^\s+  [a-z_]+:" -and $line -notmatch "^\s+  default:") {
                    # This is a new event, we've passed our block
                    break
                }
            }
            break
        }
        if ($line -match "enabled:\s*(true|false)") {
            $EventEnabled = ($matches[1] -eq 'true')
        }
        if ($line -match 'message:\s*"(.*)"') {
            $CommitMsg = $matches[1]
        }
    }
}

if (-not $EventEnabled) { exit 0 }

if (-not $CommitMsg) {
    $CommitMsg = switch ($EventName) {
        'after_signal'       { "[Forge Kit] Capture signal" }
        'after_hypothesize'  { "[Forge Kit] Formulate hypothesis" }
        'after_decide'       { "[Forge Kit] Record decision" }
        'after_feature'      { "[Forge Kit] Add feature specification" }
        'after_experiment'   { "[Forge Kit] Design experiment" }
        'after_release'      { "[Forge Kit] Create release manifest" }
        'after_retrospect'   { "[Forge Kit] Run retrospective" }
        'after_constitution' { "[Forge Kit] Add project constitution" }
        'after_check'        { "[Forge Kit] Quality check results" }
        'before_check'       { "[Forge Kit] Save progress before quality check" }
        'after_graph'        { "[Forge Kit] Graph update" }
        'before_graph'       { "[Forge Kit] Save progress before graph update" }
        'after_analyze'      { "[Forge Kit] Analysis results" }
        'before_analyze'     { "[Forge Kit] Save progress before analysis" }
        'after_clarify'      { "[Forge Kit] Clarification results" }
        'before_clarify'     { "[Forge Kit] Save progress before clarification" }
        'after_checklist'    { "[Forge Kit] Checklist results" }
        'before_checklist'   { "[Forge Kit] Save progress before checklist" }
        'after_ai_analyze'   { "[Forge Kit] AI analysis results" }
        'before_ai_analyze'  { "[Forge Kit] Save progress before AI analysis" }
        'after_ai_critique'  { "[Forge Kit] AI critique results" }
        'before_ai_critique' { "[Forge Kit] Save progress before AI critique" }
        'after_ai_blind_spots'  { "[Forge Kit] Blind spot detection results" }
        'before_ai_blind_spots' { "[Forge Kit] Save progress before blind spot detection" }
        default              { "[Forge Kit] Auto-commit" }
    }
}

# Check for changes
$Status = git status --porcelain
if (-not $Status) {
    Write-Host "[forge] Nothing to commit."
    exit 0
}

git add .
git commit -m $CommitMsg
Write-Host "[forge] Auto-committed: $CommitMsg"
