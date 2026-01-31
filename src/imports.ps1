# Installing Terminal-Icons
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Force -Scope CurrentUser
}
Import-Module -Name Terminal-Icons

# PSReadLine configuration for predictive suggestions
if (-not (Get-Module -ListAvailable -Name PSReadLine)) {
    Install-PSResource -Name PSReadLine -Force -Scope CurrentUser
}

if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    
    # Увімкнення автодоповнення команд
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    
    # Клавіші для навігації по пропозиціях
    Set-PSReadLineKeyHandler -Key "Ctrl+f" -Function ForwardWord
    Set-PSReadLineKeyHandler -Key "Ctrl+RightArrow" -Function AcceptNextSuggestionWord
    Set-PSReadLineKeyHandler -Key "RightArrow" -Function AcceptSuggestion
}
