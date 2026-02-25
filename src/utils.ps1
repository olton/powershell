# Usefulness functions
function Format-Size {
    param([long]$Bytes)
    
    if ($Bytes -ge 1TB) {
        return "{0:F1} TB" -f ($Bytes / 1TB)
    } elseif ($Bytes -ge 1GB) {
        return "{0:F1} GB" -f ($Bytes / 1GB)
    } elseif ($Bytes -ge 1MB) {
        return "{0:F1} MB" -f ($Bytes / 1MB)
    } elseif ($Bytes -ge 1KB) {
        return "{0:F1} KB" -f ($Bytes / 1KB)
    } else {
        return "{0} B" -f $Bytes
    }
}

function extract-vscode-extensions {
    param (
        [string]$File = "vscode-extensions",
        [switch]$Install,
        [switch]$Linux
    )

    $ext = if ($Install) { 
        if ($Linux) { 
            ".sh" 
            } 
        else {
            ".ps1" 
        }
    } else { ".txt" }
    $outputFile = "$File$ext"
    
    Write-Host " "
    Write-Host "Extracting installed VSCode extensions to '$outputFile'..." -NoNewLine
    if ($Install) {
        code --list-extensions | % { "code --install-extension $_" } | Set-Content $outputFile -Encoding UTF8
    } else {
        code --list-extensions | Out-File -FilePath $outputFile -Encoding UTF8
    }
    Write-Host "Done." -ForegroundColor Green
    Write-Host " "
}

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
