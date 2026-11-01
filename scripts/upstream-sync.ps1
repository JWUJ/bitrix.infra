# Upstream Synchronization Helper for bitrix.infra
# Checks differences between local master and paskal/bitrix.infra

[CmdletBinding()]
param(
    [switch]$NoFetch,
    [switch]$ShowDiff,
    [string]$UpstreamBranch = "upstream/master"
)

Write-Host "=== Upstream Sync Check (paskal/bitrix.infra) ===" -ForegroundColor Cyan

if (-not $NoFetch) {
    Write-Host "`n[1/3] Fetching latest commits from upstream..." -ForegroundColor Yellow
    git fetch upstream
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Could not fetch upstream. Check network connection or GitHub access."
    }
}

# Update mirror branch upstream-master
git branch -f upstream-master upstream/master 2>$null

# Count commits
$behindCount = (git rev-list --count "master..$UpstreamBranch").Trim()
$aheadCount = (git rev-list --count "$UpstreamBranch..master").Trim()

Write-Host "`n[2/3] Branch Status:" -ForegroundColor Cyan
Write-Host "  Commits in upstream not in master: $behindCount" -ForegroundColor $(if ([int]$behindCount -gt 0) { "Yellow" } else { "Green" })
Write-Host "  Local commits in master not in upstream: $aheadCount" -ForegroundColor White

if ([int]$behindCount -gt 0) {
    Write-Host "`n[3/3] New commits in ${UpstreamBranch}:" -ForegroundColor Green
    git log master..$UpstreamBranch --oneline --decorate -n 25

    if ($ShowDiff) {
        Write-Host "`nModified files:" -ForegroundColor Magenta
        git diff --stat master..$UpstreamBranch
    }

    $today = Get-Date -Format "yyyy-MM-dd"
    Write-Host "`n--- Integration Recommendations ---" -ForegroundColor Cyan
    Write-Host "1. Selective cherry-pick (recommended for infrastructure fixes):"
    Write-Host "   git cherry-pick <commit-hash>`n" -ForegroundColor Gray
    Write-Host "2. Batch merge in a dedicated sync branch:"
    Write-Host "   git checkout -b sync/upstream-$today" -ForegroundColor Gray
    Write-Host "   git merge upstream/master" -ForegroundColor Gray
    Write-Host "   # Test configurations, then merge to master:" -ForegroundColor Gray
    Write-Host "   git checkout master; git merge sync/upstream-$today`n" -ForegroundColor Gray
} else {
    Write-Host "`n[3/3] Repository is up to date with upstream!" -ForegroundColor Green
}
