# Shell functions from linux

Set-Alias -Name which -Value search

Remove-Alias -Name pwd -Force -ErrorAction SilentlyContinue
Remove-Alias -Name cat -Force -ErrorAction SilentlyContinue
Remove-Alias -Name ls -Force -ErrorAction SilentlyContinue

function search {
    param (
        [string]$Path = ".",
        [Parameter(Mandatory, HelpMessage = "Введіть назву файлу або її частину")]
        [string]$File,
        [int]$Depth = 0  # 0 = без обмежень
    )
    
    if (-not (Test-Path $Path)) {
        Write-Warning "Шлях '$Path' не існує"
        return
    }
    
    $params = @{
        Path = $Path
        Recurse = $true
        Force = $true
        File = $true
        Filter = "*$File*"
        ErrorAction = 'SilentlyContinue'
    }
    
    # Додаємо обмеження глибини якщо вказано
    if ($Depth -gt 0) {
        $params.Depth = $Depth
    }
    
    Get-ChildItem @params | Select-Object -ExpandProperty FullName
}

function ls { 
    param (
        [string]$Path = ".",
        [string]$Pattern = "*",
        [switch]$C
    )

    Write-Host " "
    Write-Host "Listing items..."
    Write-Host " "

    # Check if Terminal-Icons is available
    if (Get-Module -Name Terminal-Icons) {
        # Use Get-ChildItem with Format-TerminalIcons for icon support
        Get-ChildItem -Path $Path -Filter "*$Pattern*" -ErrorAction SilentlyContinue | 
        Format-TerminalIcons | 
        ForEach-Object {
            if ($C) {
                Write-Host $_ 
            } else {
                Write-Host "$_ " -NoNewLine
            }
        }
    } else {
        # Fallback to your original implementation
        Get-ChildItem -Name -Path $Path -Filter "*$Pattern*" -ErrorAction SilentlyContinue | 
        ForEach-Object {
            $item = Get-Item -Path (Join-Path -Path $Path -ChildPath $_) -ErrorAction SilentlyContinue
            if ($item) {
                $isDir = $item.PSIsContainer
                $color = if ($isDir) { "White" } else { "Cyan" }
                Write-Host "$_ " -ForegroundColor $color -NoNewLine:(-not $C)
            }
        }
    }

    if (-not $C) {
        Write-Host ""
    }
    Write-Host " "
}

function la { 
    param (
        [string]$Path = ".", 
        [string]$Pattern = "*"
    )
    Get-ChildItem -Path $Path -Filter "*$Pattern*" -ErrorAction SilentlyContinue
}

function lf { 
    param (
        [string]$Path = ".", 
        [string]$Pattern = "*"
    )
    Get-ChildItem -Path $Path -Filter "*$Pattern*" -Force -ErrorAction SilentlyContinue
}

function lr { 
    param (
        [string]$Path = ".", 
        [string]$Pattern = "*"
    )
    Get-ChildItem -Path $Path -Filter "*$Pattern*" -Force -Recurse -ErrorAction SilentlyContinue
}

function tail {
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть шлях до файлу")]
        [string]$Path,
        [int]$Lines = 10,
        [switch]$F
    )

    Get-Content -Path $Path -Tail $Lines -Wait:$F
}

function pwd { Get-Location }
function cat($file){ Get-Content $file }
function touch($path){ New-Item -Path $path -ItemType File }
function clear { cls }

function grep {
    param(
        [Parameter(Mandatory, Position=0, HelpMessage = "Введіть строку для пошуку")]
        [string]$Search,
        
        [Parameter(Position=1)]
        [string]$Where,
        
        [Parameter(ValueFromPipeline = $true)]
        [object]$InputObject,
        
        [switch]$IgnoreCase,
        [switch]$CaseSensitive,
        [switch]$Regex,
        [switch]$Invert,
        [switch]$Count,
        [switch]$LineNumber,
        [int]$Context = 0,
        [switch]$Quiet,
        [switch]$Recurse,
        [string[]]$Include,
        [string[]]$Exclude
    )

    begin {
        # Ініціалізуємо масив для збору даних з pipeline
        $pipelineInput = @()
    }

    process {
        # Збираємо всі об'єкти з pipeline
        if ($InputObject -ne $null) {
            $pipelineInput += $InputObject
        }
    }

    end {
        # Явно конвертуємо параметр пошуку в рядок для уникнення інтерпретації як шляху
        $Search = [string]$Search
        
        # Визначаємо джерело контенту
        if ($Where) {
            # Перевіряємо чи це файл або директорія
            if (Test-Path $Where -PathType Container) {
                # Пошук у директорії
                $searchParams = @{
                    Path = $Where
                    Pattern = $Search
                    SimpleMatch = !$Regex
                }
                
                if ($Recurse) { $searchParams.Recurse = $true }
                if ($Include) { $searchParams.Include = $Include }
                if ($Exclude) { $searchParams.Exclude = $Exclude }
                if ($CaseSensitive) { $searchParams.CaseSensitive = $true }
                elseif ($IgnoreCase) { $searchParams.CaseSensitive = $false }
                if ($Context -gt 0) { $searchParams.Context = $Context, $Context }
                if ($Invert) { $searchParams.NotMatch = $true }
                
                $results = Select-String @searchParams
            }
            elseif (Test-Path $Where -PathType Leaf) {
                # Пошук у файлі
                $searchParams = @{
                    Path = $Where
                    Pattern = $Search
                    SimpleMatch = !$Regex
                }
                
                if ($CaseSensitive) { $searchParams.CaseSensitive = $true }
                elseif ($IgnoreCase) { $searchParams.CaseSensitive = $false }
                if ($Context -gt 0) { $searchParams.Context = $Context, $Context }
                if ($Invert) { $searchParams.NotMatch = $true }
                
                $results = Select-String @searchParams
            }
            else {
                Write-Error "Файл або директорія '$Where' не знайдена"
                return
            }
        }
        else {
            # Працюємо з pipeline input
            if ($pipelineInput.Count -eq 0) {
                Write-Warning "Немає вхідних даних для пошуку"
                return
            }
            
            $searchParams = @{
                Pattern = $Search
                SimpleMatch = !$Regex
            }
            
            if ($CaseSensitive) { $searchParams.CaseSensitive = $true }
            elseif ($IgnoreCase) { $searchParams.CaseSensitive = $false }
            if ($Context -gt 0) { $searchParams.Context = $Context, $Context }
            if ($Invert) { $searchParams.NotMatch = $true }
            
            # Конвертуємо input в рядки якщо потрібно
            $stringInput = $pipelineInput | ForEach-Object {
                if ($_ -is [string]) {
                    $_
                } else {
                    $_.ToString()
                }
            }
            
            $results = $stringInput | Select-String @searchParams
        }

        # Обробка результатів
        if ($Count) {
            return ($results | Measure-Object).Count
        }
        
        if ($Quiet) {
            return ($results.Count -gt 0)
        }
        
        if ($LineNumber -and $results) {
            $results | ForEach-Object {
                if ($_.Filename) {
                    Write-Host "$($_.Filename):$($_.LineNumber):" -NoNewline -ForegroundColor Yellow
                } else {
                    Write-Host "$($_.LineNumber):" -NoNewline -ForegroundColor Yellow
                }
                Write-Host " $($_.Line)"
            }
        } else {
            $results
        }
    }
}

# Disk usage
function du {
    param(
        [string]$Directory,
        [switch]$K,
        [switch]$M
    ) 

    $dir = $Directory ? $Directory : (Get-Location).Path

    Write-Host ""
    Write-Host "Calculating disk usage for directory: $dir..." -ForegroundColor Cyan

    # Визначаємо одиниці вимірювання
    $unit = if ($K) { 
        "KB" 
    } elseif ($M) { 
        "MB" 
    } else { 
        "B" 
    }

    $divisor = switch ($unit) {
        "KB" { 1KB }
        "MB" { 1MB }
        default { 1 }
    }

    # Оптимізована версія - обчислюємо розмір за один прохід
    $results = Get-ChildItem $dir -ErrorAction SilentlyContinue | ForEach-Object -Parallel {
        $folder = $_
        $using_divisor = $using:divisor
        $using_unit = $using:unit
        
        try {
            $size = (Get-ChildItem -Path $folder.FullName -Recurse -File -ErrorAction SilentlyContinue | 
                    Measure-Object -Property Length -Sum).Sum
            
            $formattedSize = if ($using_unit -eq "B") {
                "{0}" -f $size
            } else {
                "{0:N1}" -f ($size / $using_divisor)
            }
            
            [PSCustomObject]@{
                Name = $folder.Name
                "Size ($using_unit)" = $formattedSize
                SizeBytes = $size
            }
        }
        catch {
            [PSCustomObject]@{
                Name = $folder.Name
                "Size ($using_unit)" = "Error"
                SizeBytes = 0
            }
        }
    } -ThrottleLimit 8

    # Сортуємо по розміру (найбільші спочатку) та виводимо
    $results | Sort-Object SizeBytes -Descending | 
    Format-Table Name, @{Label="Size ($unit)"; Expression={$_."Size ($unit)"}; Align="Right"} -AutoSize

    Write-Host ""
}

# Disk free space
function df {
    param(
        [string]$Path,
        [switch]$H,
        [switch]$K,
        [switch]$M,
        [switch]$T
    )

    $drives = if ($Path) {
        $item = Get-Item $Path -ErrorAction SilentlyContinue
        if ($item) {
            $driveLetter = Split-Path -Path $item.FullName -Qualifier
            Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -eq $driveLetter + "\" -and $_.Name.Length -eq 1 }
        } else {
            Write-Host "Path not found: $Path" -ForegroundColor Red
            return
        }
    } else {
        Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -ne $null -and $_.Name.Length -eq 1 }
    }

    $results = $drives | ForEach-Object {
        $drive = $_
        $used = $drive.Used
        $free = $drive.Free
        $total = $used + $free
        $percentUsed = if ($total -gt 0) { [math]::Round(($used / $total) * 100, 1) } else { 0 }

        if ($H) {
            $usedFormatted = Format-Size $used
            $freeFormatted = Format-Size $free
            $totalFormatted = Format-Size $total
        } elseif ($M) {
            $usedFormatted = "{0:F1} MB" -f ($used / 1MB)
            $freeFormatted = "{0:F1} MB" -f ($free / 1MB)
            $totalFormatted = "{0:F1} MB" -f ($total / 1MB)
        } elseif ($K) {
            $usedFormatted = "{0:F0} KB" -f ($used / 1KB)
            $freeFormatted = "{0:F0} KB" -f ($free / 1KB)
            $totalFormatted = "{0:F0} KB" -f ($total / 1KB)
        } else {
            $usedFormatted = "{0} B" -f $used
            $freeFormatted = "{0} B" -f $free
            $totalFormatted = "{0} B" -f $total
        }

        $obj = [PSCustomObject]@{
            Filesystem = $drive.Root
            Size = $totalFormatted
            Used = $usedFormatted
            Available = $freeFormatted
            'Use%' = "$percentUsed%"
        }

        if ($T) {
            $volumeInfo = Get-Volume -DriveLetter $drive.Name -ErrorAction SilentlyContinue
            $fileSystem = if ($volumeInfo) { $volumeInfo.FileSystemType } else { "Unknown" }
            $obj | Add-Member -NotePropertyName "Type" -NotePropertyValue $fileSystem
        }

        $obj
    }

    $results | Format-Table -AutoSize
}

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

function rn {
	param (
        [Parameter(Mandatory, HelpMessage = "Введіть шлях до файлу/теки")]
		[string]$Path,
        [Parameter(Mandatory, HelpMessage = "Введіть нове ім'я файлу/теки")]
		[string]$NewName
	)
	
	Rename-Item -Path $Path -NewName $NewName
}
