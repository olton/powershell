# Shell functions from linux

Set-Alias -Name which -Value search

Remove-Alias -Name pwd -Force -ErrorAction SilentlyContinue
Remove-Alias -Name cat -Force -ErrorAction SilentlyContinue
Remove-Alias -Name ls -Force -ErrorAction SilentlyContinue

function search {
    param (
        [string]$path,
        [string]$file
    )
    Get-ChildItem -Path $path -Recurse -Force -Include "*$file*" -ErrorAction SilentlyContinue
}

function ls($path) { 
    Get-ChildItem -Name -Path $path -ErrorAction SilentlyContinue
 }

function la($path = ".", $pattern) { 
    Get-ChildItem -Path $path -Filter $pattern -ErrorAction SilentlyContinue
}

function lf($path = ".", $pattern) { 
    Get-ChildItem -Path $path -Filter $pattern -Force -ErrorAction SilentlyContinue
}

function lr($path = ".", $pattern) { 
    Get-ChildItem -Path $path -Filter $pattern -Force -Recurse -ErrorAction SilentlyContinue
}

function tail {
    param (
        [string]$path,
        [int]$Lines = 10,
        [switch]$f
    )

    Get-Content -Path $path -Tail $Lines -Wait:$f
}

function pwd { Get-Location }
function cat($file){ Get-Content $file }
function touch($path){ New-Item -Path $path -ItemType File }
function clear { cls }

function grep {
    param(
        [string]$search,
        [string]$where
    )

    $content = if ($where) {
        Get-Content $where
    } else {
        $input
    }
    
    $content | Select-String -Pattern $search
}

function du {
    param([string]$Directory) 

    $dir = $Directory ? $Directory : (Get-Location).Path

    Write-Host "Calculating disk usage for directory: $dir..." -ForegroundColor Cyan

    Get-ChildItem $dir -ErrorAction SilentlyContinue | 
    % { $f = $_ ; 
        Get-ChildItem -r $_.FullName -ErrorAction SilentlyContinue | 
        Measure-Object -property length -sum | 			
            select @{Name="Name";Expression={$f}},@{Name="Sum (Mb)"; Expression={"{0:N1}" -f ($_.sum / 1MB)}}} |
    Format-Table Name, @{Label="Sum (Mb)"; Expression={$_."Sum (Mb)"}; Align="Right"} -AutoSize
}

function df {
    param(
        [string]$Path,
        [switch]$h,
        [switch]$k,
        [switch]$m,
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

        if ($h) {
            $usedFormatted = Format-Size $used
            $freeFormatted = Format-Size $free
            $totalFormatted = Format-Size $total
        } elseif ($m) {
            $usedFormatted = "{0:F1} MB" -f ($used / 1MB)
            $freeFormatted = "{0:F1} MB" -f ($free / 1MB)
            $totalFormatted = "{0:F1} MB" -f ($total / 1MB)
        } elseif ($k) {
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

function rn {
	param (
		[string]$path,
		[string]$newName
	)
	
	Rename-Item -Path $path -NewName $newName
}
