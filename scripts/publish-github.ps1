# Run from any path on Windows with git and gh available, after 'gh auth login'.
$ErrorActionPreference = "Stop"
$repo = "virtualhowto/Shedbuilt"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $root
function Check-Exit($description) {
    if ($LASTEXITCODE -ne 0) { throw "${description} failed with exit code $LASTEXITCODE" }
}
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw "Install GitHub CLI from https://cli.github.com/ first." }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "Install Git first." }
& gh auth status
Check-Exit "GitHub authentication"
if (-not (Test-Path ".git")) {
    & git init -b main
    Check-Exit "Git initialization"
}
& git add .
Check-Exit "Git staging"
& git diff --cached --quiet
if ($LASTEXITCODE -eq 1) {
    & git commit -m "feat: bootstrap Shedbuilt browser engineering lab and private preview"
    Check-Exit "Initial commit"
} elseif ($LASTEXITCODE -ne 0) {
    throw "Git status failed"
}
& gh repo view $repo *> $null
$exists = $LASTEXITCODE -eq 0
& git remote get-url origin *> $null
$hasOrigin = $LASTEXITCODE -eq 0
if ($exists) {
    if (-not $hasOrigin) {
        & git remote add origin "https://github.com/$repo.git"
        Check-Exit "Adding origin"
    }
    & git push -u origin main
    Check-Exit "Git push"
} else {
    if ($hasOrigin) { throw "Origin is already configured but $repo was not found. Inspect remotes manually." }
    & gh repo create $repo --private --source=. --remote=origin --push
    Check-Exit "Private GitHub repository creation"
}
Write-Host "Repository ready: https://github.com/$repo"
Write-Host "Next: configure Traefik/Authentik and approve a private preview deployment, following docs/GO-LIVE.md."
