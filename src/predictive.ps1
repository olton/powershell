# PSReadLine configuration for predictive suggestions
if (-not (Get-Module -ListAvailable -Name PSReadLine)) {
    Write-Host "Installing PSReadLine module..." -ForegroundColor Yellow
    Install-Module -Name PSReadLine -Force -Scope CurrentUser
}

if (Get-Module -ListAvailable -Name PSReadLine) {
    Write-Host "Configuring PSReadLine for predictive suggestions..." -ForegroundColor Yellow -NoNewLine
    Import-Module PSReadLine
    
    # Увімкнення автодоповнення команд
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle InlineView
    Set-PSReadLineOption -EditMode Windows
    
    # Клавіші для навігації по пропозиціях
    Set-PSReadLineKeyHandler -Key "Ctrl+f" -Function ForwardWord
    Set-PSReadLineKeyHandler -Key "Ctrl+RightArrow" -Function AcceptNextSuggestionWord
    Set-PSReadLineKeyHandler -Key "RightArrow" -Function AcceptSuggestion
    Write-Host "OK" -ForegroundColor Green
}
