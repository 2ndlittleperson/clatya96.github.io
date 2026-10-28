# Applies scripts\remote.config to this repository's git remotes.
# Run from anywhere:  powershell -File scripts\set-remote.ps1

$ErrorActionPreference = 'Stop'

$repoRoot   = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $PSScriptRoot 'remote.config'

if (-not (Test-Path $configPath)) {
    Write-Host "Config not found: $configPath" -ForegroundColor Red
    exit 1
}

# Parse KEY=value lines into a hashtable.
$cfg = @{}
foreach ($line in Get-Content $configPath) {
    $trimmed = $line.Trim()
    if ($trimmed -eq '' -or $trimmed.StartsWith('#')) { continue }
    $split = $trimmed.Split('=', 2)
    if ($split.Count -eq 2) { $cfg[$split[0].Trim()] = $split[1].Trim() }
}

function Set-Remote($name, $gitHost, $user, $repo) {
    if ([string]::IsNullOrWhiteSpace($gitHost)) {
        # Host blank means "don't want this remote" - remove it if present.
        $existing = & git -C $repoRoot remote
        if ($existing -contains $name) {
            & git -C $repoRoot remote remove $name
            Write-Host "removed  $name" -ForegroundColor DarkYellow
        }
        return
    }

    if ([string]::IsNullOrWhiteSpace($user) -or [string]::IsNullOrWhiteSpace($repo)) {
        Write-Host "Skipping '$name': user or repo is empty." -ForegroundColor Yellow
        return
    }

    $url      = "https://$gitHost/$user/$repo.git"
    $existing = & git -C $repoRoot remote

    if ($existing -contains $name) {
        & git -C $repoRoot remote set-url $name $url
        Write-Host "updated  $name -> $url" -ForegroundColor Green
    } else {
        & git -C $repoRoot remote add $name $url
        Write-Host "added    $name -> $url" -ForegroundColor Green
    }
}

Set-Remote 'origin' $cfg['GITHUB_HOST'] $cfg['GITHUB_USER'] $cfg['GITHUB_REPO']

$altName = $cfg['ALT_REMOTE_NAME']
if ([string]::IsNullOrWhiteSpace($altName)) { $altName = 'github-com' }
Set-Remote $altName $cfg['ALT_GITHUB_HOST'] $cfg['ALT_GITHUB_USER'] $cfg['ALT_GITHUB_REPO']

Write-Host ''
Write-Host 'Remotes now configured:'
& git -C $repoRoot remote -v
