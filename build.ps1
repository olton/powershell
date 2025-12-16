$package = Get-Content -Path "package.json" | ConvertFrom-Json
$dist = $package.target
$profile = Join-Path -Path $dist -ChildPath "Microsoft.PowerShell_profile.ps1"

# Перевіряємо, чи існує тека dist, якщо ні - створюємо
if (!(Test-Path -Path $dist)) {
    New-Item -ItemType Directory -Path $dist | Out-Null
}

# Очищаємо старий файл профілю, якщо він існує
if (Test-Path -Path $profile) {
    Remove-Item -Path $profile
}

# Отримуємо всі .ps1 файли з папки src
$files = Get-ChildItem -Path "src" -Filter "*.ps1"

# Збираємо вміст файлів
foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    Add-Content -Path $profile -Value "`n# Source: $($file.Name)"
    Add-Content -Path $profile -Value $content
}

Write-Host "Профіль успішно зібрано: $profile" -ForegroundColor Green