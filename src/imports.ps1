# Installing Terminal-Icons
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Write-Host "Installing Terminal-Icons module..." -ForegroundColor Yellow -NoNewLine
    Install-Module -Name Terminal-Icons -Force -Scope CurrentUser
    Write-Host "OK" -ForegroundColor Green
}
Write-Host "Importing Terminal-Icons module..." -ForegroundColor Yellow -NoNewLine
Import-Module -Name Terminal-Icons
Write-Host "OK" -ForegroundColor Green