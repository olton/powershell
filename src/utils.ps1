function markdown($path){
    Show-Markdown -Path $path
}

function Format-Size {
    param([long]$bytes)

    if ($bytes -ge 1TB) {
        return "{0:F1} TB" -f ($bytes / 1TB)
    } elseif ($bytes -ge 1GB) {
        return "{0:F1} GB" -f ($bytes / 1GB)
    } elseif ($bytes -ge 1MB) {
        return "{0:F1} MB" -f ($bytes / 1MB)
    } elseif ($bytes -ge 1KB) {
        return "{0:F1} KB" -f ($bytes / 1KB)
    } else {
        return "{0} B" -f $bytes
    }
}