$Env:SHOW_PROMPT_TIME = "NO"

function prompt {
    $uptime = Get-Uptime -ErrorAction SilentlyContinue
    $username = $env:USERNAME + ":"
    $currentBranch = git rev-parse --abbrev-ref HEAD
    $folder = Split-Path -Path (Get-Location) -Leaf
    $nodeVersion = (node -v).Trim()
    $packageJson = Test-Path package.json -PathType Leaf
    $currentTime = $(Get-Date -Format "dddd dd-MM-yyyy HH:mm")
    $currentBranchIsModified = $false

    $status = git status --porcelain 2>$null
    if ($status -and $status.Trim()) {
        $currentBranchIsModified = $true
    }

    if ($Env:SHOW_PROMPT_TIME -eq "YES") {
        if ($uptime) {
            Write-Host "💻 Uptime: " -NoNewLine -ForegroundColor Gray
            Write-Host "$uptime, " -NoNewLine -ForegroundColor Magenta
        } else {
            Write-Host "💻 Uptime: Unknown " -NoNewLine -ForegroundColor Gray
        }
        Write-Host "⌚ $currentTime " -ForegroundColor Yellow
    }
    Write-Host "🫀 $username "  -NoNewLine -ForegroundColor Cyan
    Write-Host "📂 $folder " -NoNewLine -ForegroundColor Green

    if ($currentBranch) {
        Write-Host "🌵 $currentBranch" -NoNewLine -ForegroundColor White
        if ($currentBranchIsModified) {
            Write-Host "[M] " -NoNewLine -ForegroundColor Red
        }
    }

    if ($packageJson) {
        Write-Host "[👽 $nodeVersion] " -NoNewLine -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "└─❯" -NoNewLine -ForegroundColor Yellow
    return " "
}
