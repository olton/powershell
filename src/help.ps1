function help {
    Write-Host "PowerShell Helper Functions`n"
    Write-Host "Available Commands:`n"
    Write-Host "1. Git Commands - A set of Git helper functions (log, exists, new, feature, review)"
    Write-Host "2. Linux Commands - Linux-like commands for PowerShell (ls, cat, df, etc.)"
    Write-Host "3. Utils - Utility functions (uptime, format-size, markdown, etc.)`n"
    
    Write-Host "Git functions:" -ForegroundColor Cyan
    Write-Host "Linux-like commands:" -ForegroundColor Cyan
    Write-Host "Utility functions:" -ForegroundColor Cyan
    return "`n"
}