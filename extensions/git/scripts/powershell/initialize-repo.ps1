<#
.SYNOPSIS
    Initialize a Git repository with an initial commit for FORGE workflow.
.DESCRIPTION
    Initializes a Git repository in the current project directory if one
    does not already exist. Uses configurable commit message from git-config.yml.
.EXAMPLE
    .\initialize-repo.ps1
#>

# Check if git is available
try {
    $null = Get-Command git -ErrorAction Stop
} catch {
    Write-Warning "[forge] Warning: Git is not installed. Skipping repository initialization."
    exit 0
}

# Skip if already inside a Git repository
try {
    $null = git rev-parse --is-inside-work-tree 2>$null
    Write-Host "[forge] Git repository already initialized."
    exit 0
} catch {}

$ProjectRoot = Get-Location

# Check for custom config
$ConfigFile = Join-Path $ProjectRoot ".forge" "extensions" "git" "git-config.yml"
$InitMessage = "[Forge Kit] Initial commit"

if (Test-Path $ConfigFile) {
    $Config = Get-Content $ConfigFile -Raw
    if ($Config -match 'init_commit_message:\s*"([^"]+)"') {
        $InitMessage = $matches[1]
    }
}

git init
git add .
git commit -m $InitMessage
Write-Host "✓ Git repository initialized"
