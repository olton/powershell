# Custom Prompt
# Set to "YES" to show time in prompt, "NO" to hide
$Env:SHOW_PROMPT_TIME = "NO"

function prompt {
    $uptime = Get-Uptime -ErrorAction SilentlyContinue
    $username = $env:USERNAME + ":"
    $currentBranch = current
    $folder = Split-Path -Path (Get-Location) -Leaf
    $nodeVersion = if (Get-Command node -ErrorAction SilentlyContinue) { 
        (node -v).Trim() 
    } else { 
        $null 
    }
    $gitVersion = if (Get-Command git -ErrorAction SilentlyContinue) { 
        (git --version).Trim() 
    } else { 
        $null 
    }
    $packageJson = Test-Path package.json -PathType Leaf
    $currentTime = $(Get-Date -Format "dddd dd-MM-yyyy HH:mm")
    $currentBranchIsModified = $false

    $gitStatus = git status --porcelain 2>$null
    $countModifiedFiles = (git status -s | Measure-Object -Line).Lines
    $modifiedInfo = git diff --shortstat

    if ($gitVersion -and $gitStatus -and $gitStatus.Trim()) {
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
        Write-Host "🌵 git:" -NoNewLine -ForegroundColor White
        Write-Host $currentBranch -NoNewLine -ForegroundColor Magenta
        if ($currentBranchIsModified) {
            Write-Host " [M:$countModifiedFiles]" -NoNewLine -ForegroundColor Red
        }
    }

    if ($packageJson -and $nodeVersion) {
        Write-Host " [👽 $nodeVersion] " -NoNewLine -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "└─❯" -NoNewLine -ForegroundColor Yellow
    return " "
}
