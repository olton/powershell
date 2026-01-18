function extract-vscode-extensions {
    param (
        [string]$File = "vscode-extensions",
        [switch]$Install
    )

    $ext = if ($Install) { ".ps1" } else { ".txt" }
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
