<#
.SYNOPSIS
    Create a FORGE signal-driven feature branch with sequential or timestamp numbering.
.DESCRIPTION
    Creates and switches to a new git feature branch for the given signal or feature
    description. Supports sequential (001-signal-name) or timestamp numbering.
.PARAMETER Json
    Output results in JSON format.
.PARAMETER DryRun
    Compute branch name without creating the branch.
.PARAMETER AllowExistingBranch
    Switch to the branch if it already exists instead of failing.
.PARAMETER ShortName
    Custom short name (2-4 words) for the branch.
.PARAMETER Number
    Specify branch number manually (overrides auto-detection).
.PARAMETER Timestamp
    Use timestamp prefix (YYYYMMDD-HHMMSS) instead of sequential numbering.
.PARAMETER Description
    Feature or signal description.
.EXAMPLE
    .\create-signal-branch.ps1 "Capture auth latency spike"
    .\create-signal-branch.ps1 -Json -ShortName "auth-signal" "User login latency"
    .\create-signal-branch.ps1 -Timestamp -Json "Memory leak signal"
#>

param(
    [switch]$Json,
    [switch]$DryRun,
    [switch]$AllowExistingBranch,
    [string]$ShortName = "",
    [string]$Number = "",
    [switch]$Timestamp,
    [Parameter(Position=0, Mandatory=$true)]
    [string]$Description
)

$Description = $Description.Trim()
if ([string]::IsNullOrEmpty($Description)) {
    Write-Error "Description cannot be empty."
    exit 1
}

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
    try {
        $ProjectRoot = git rev-parse --show-toplevel 2>$null
    } catch {
        Write-Error "Could not determine project root."
        exit 1
    }
}

Set-Location $ProjectRoot
$SignalsDir = Join-Path $ProjectRoot ".forge" "signals"

# Determine if git is available
$HasGit = $false
try {
    $null = git rev-parse --is-inside-work-tree 2>$null
    $HasGit = $true
} catch {}

# Check for GIT_BRANCH_NAME env var override
$EnvBranchName = [Environment]::GetEnvironmentVariable("GIT_BRANCH_NAME")
if ($EnvBranchName) {
    $BranchName = $EnvBranchName
    if ($BranchName -match '^\d{8}-\d{6}-') {
        $FeatureNum = $matches[0]
        $BranchSuffix = $BranchName.Substring($FeatureNum.Length + 1)
    } elseif ($BranchName -match '^\d+-') {
        $FeatureNum = $matches[0].TrimEnd('-')
        $BranchSuffix = $BranchName.Substring($FeatureNum.Length + 1)
    } else {
        $FeatureNum = $BranchName
        $BranchSuffix = $BranchName
    }
} else {
    # Generate short name if not provided
    if (-not $ShortName) {
        $StopWords = @('i','a','an','the','to','for','of','in','on','at','by','with','from','is','are','was','were','be','been','being','have','has','had','do','does','did','will','would','should','could','can','may','might','must','shall','this','that','these','those','my','your','our','their','want','need','add','get','set')
        $Words = $Description.ToLower() -split '[^a-z0-9]' | Where-Object { $_ -and $_ -notin $StopWords -and $_.Length -ge 3 }
        $Meaningful = $Words | Select-Object -First 3
        if ($Meaningful) {
            $ShortName = $Meaningful -join '-'
        } else {
            $ShortName = ($Description.ToLower() -replace '[^a-z0-9]','-') -replace '-+','-' -trim '-'
        }
    } else {
        $ShortName = $ShortName.ToLower() -replace '[^a-z0-9]','-' -replace '-+','-' -trim '-'
    }
    $BranchSuffix = $ShortName

    if ($Timestamp -and $Number) {
        Write-Warning "[forge] --Number is ignored when --Timestamp is used"
        $Number = ""
    }

    if ($Timestamp) {
        $FeatureNum = Get-Date -Format "yyyyMMdd-HHmmss"
        $BranchName = "$FeatureNum-$BranchSuffix"
    } else {
        if (-not $Number) {
            # Find highest existing number
            $Highest = 0
            if (Test-Path $SignalsDir) {
                Get-ChildItem $SignalsDir -Directory | ForEach-Object {
                    if ($_.Name -match '^(\d{3,})-') {
                        $Num = [int]$matches[1]
                        if ($Num -gt $Highest) { $Highest = $Num }
                    }
                }
            }
            if ($HasGit) {
                git fetch --all --prune 2>$null
                $Branches = git branch -a 2>$null
                foreach ($b in $Branches) {
                    $b = $b.TrimStart('*', ' ')
                    $b = $b -replace '^remotes/[^/]+/',''
                    if ($b -match '^(\d{3,})-') {
                        $Num = [int]$matches[1]
                        if ($Num -gt $Highest) { $Highest = $Num }
                    }
                }
            }
            $Number = [string]($Highest + 1)
        }
        $FeatureNum = [int]$Number
        $Padded = $FeatureNum.ToString("D3")
        if ($FeatureNum -ge 1000) { $Padded = $FeatureNum.ToString() }
        $BranchName = "$Padded-$BranchSuffix"
    }
}

# GitHub enforces 244-byte limit
$ByteLength = [System.Text.Encoding]::UTF8.GetByteCount($BranchName)
if ($EnvBranchName -and $ByteLength -gt 244) {
    Write-Error "GIT_BRANCH_NAME must be 244 bytes or fewer. Provided value is $ByteLength bytes."
    exit 1
} elseif ($ByteLength -gt 244) {
    $PrefixLength = $FeatureNum.ToString().Length + 1
    $MaxSuffix = 244 - $PrefixLength
    $BranchSuffix = $BranchSuffix.Substring(0, [Math]::Min($MaxSuffix, $BranchSuffix.Length)).TrimEnd('-')
    $BranchName = "$FeatureNum-$BranchSuffix"
    Write-Warning "[forge] Branch name truncated to 244 bytes."
}

if (-not $DryRun) {
    if ($HasGit) {
        try {
            git checkout -q -b $BranchName 2>&1 | Out-Null
            $BranchExists = git branch --list $BranchName
            if (-not $?) {
                if ($BranchExists) {
                    if ($AllowExistingBranch) {
                        git checkout -q $BranchName 2>&1 | Out-Null
                    } else {
                        Write-Error "Branch '$BranchName' already exists."
                        exit 1
                    }
                } else {
                    Write-Error "Failed to create branch '$BranchName'."
                    exit 1
                }
            }
        } catch {
            Write-Warning "[forge] Warning: Git repository not detected; skipped branch creation for $BranchName"
        }
    } else {
        Write-Warning "[forge] Warning: Git repository not detected; skipped branch creation for $BranchName"
    }
    Write-Host "# To persist: `$env:FORGE_FEATURE = '$BranchName'"
}

if ($Json) {
    $Output = @{ BRANCH_NAME = $BranchName; FEATURE_NUM = $FeatureNum.ToString() }
    if ($DryRun) { $Output.DRY_RUN = $true }
    ConvertTo-Json -InputObject $Output -Compress
} else {
    Write-Host "BRANCH_NAME: $BranchName"
    Write-Host "FEATURE_NUM: $FeatureNum"
}
