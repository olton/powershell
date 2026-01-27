# Перевірка та інсталяція модуля Terminal-Icons
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Write-Host "Installing Terminal-Icons module..." -ForegroundColor Yellow
    Install-Module -Name Terminal-Icons -Force -Scope CurrentUser
}
Import-Module -Name Terminal-Icons
