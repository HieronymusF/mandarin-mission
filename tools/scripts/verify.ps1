[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("mobile", "core", "content", "api", "docs", "all")]
    [string]$Scope,
    [switch]$BuildApk,
    [switch]$BuildContainer
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Command
    )

    Write-Host "==> $Label"
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "$Label failed with exit code $LASTEXITCODE"
    }
}

function Invoke-MobileChecks {
    Push-Location (Join-Path $repoRoot "apps/mobile")
    try {
        Invoke-Checked "Flutter format" { dart format --output=none --set-exit-if-changed lib test }
        Invoke-Checked "Flutter analyze" { flutter analyze }
        Invoke-Checked "Flutter tests" { flutter test }
        if ($BuildApk) {
            Invoke-Checked "Debug APK" { flutter build apk --debug }
        }
    }
    finally {
        Pop-Location
    }
}

function Invoke-CoreChecks {
    Push-Location (Join-Path $repoRoot "packages/learning_core")
    try {
        Invoke-Checked "Learning core format" { dart format --output=none --set-exit-if-changed . }
        Invoke-Checked "Learning core analyze" { dart analyze --fatal-infos }
        Invoke-Checked "Learning core tests" { dart test }
    }
    finally {
        Pop-Location
    }
}

function Invoke-ContentChecks {
    Push-Location (Join-Path $repoRoot "packages/learning_core")
    try {
        Invoke-Checked "Course content validation" { dart run bin/validate_content.dart ../../content/fixtures }
    }
    finally {
        Pop-Location
    }
}

function Invoke-ApiChecks {
    Push-Location (Join-Path $repoRoot "services/api")
    try {
        Invoke-Checked "Go formatting" {
            $unformatted = @(gofmt -l .)
            if ($LASTEXITCODE -ne 0) { throw "gofmt failed with exit code $LASTEXITCODE" }
            if ($unformatted.Count -gt 0) {
                throw "Unformatted Go files: $($unformatted -join ', ')"
            }
        }
        Invoke-Checked "Go vet" { go vet ./... }
        Invoke-Checked "Go tests" { go test ./... }
        if ($BuildContainer) {
            Invoke-Checked "API container" { docker build -t mandarin-mission-api:test . }
        }
    }
    finally {
        Pop-Location
    }
}

function Invoke-DocsChecks {
    $validator = Join-Path $env:USERPROFILE ".agents/skills/repo-docs/scripts/validate_repo_docs.py"
    if (-not (Test-Path $validator)) {
        $validator = Join-Path $env:USERPROFILE ".codex/skills/repo-docs/scripts/validate_repo_docs.py"
    }
    if (-not (Test-Path $validator)) {
        throw "repo-docs validator not found in the known user skill locations"
    }
    Invoke-Checked "Repo docs validator" { python $validator (Join-Path $repoRoot "repo-docs") --repo-root $repoRoot }
}

switch ($Scope) {
    "mobile" { Invoke-MobileChecks }
    "core" { Invoke-CoreChecks }
    "content" { Invoke-ContentChecks }
    "api" { Invoke-ApiChecks }
    "docs" { Invoke-DocsChecks }
    "all" {
        Invoke-CoreChecks
        Invoke-ContentChecks
        Invoke-MobileChecks
        Invoke-ApiChecks
        Invoke-DocsChecks
    }
}

Write-Host "Verification completed for scope: $Scope"
