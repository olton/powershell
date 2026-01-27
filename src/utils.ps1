function errors {
    param (
        [int]$Count = 5
    )
    $Error | Select-Object -First $Count
}

function last-error {
    $Error[0] | Format-List * -Force
}

function markdown {
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть шлях до markdown файлу")]
        [string]$Path
    )
    Show-Markdown -Path $Path
}

#Set-Alias -Name edit -Value notepad
#Remove-Alias -Name edit -Force -ErrorAction SilentlyContinue

function notepad {
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть шлях до файлу")]
        [string]$File
    )
    & "C:\Program Files\Notepad++\notepad++.exe" $File
} 
