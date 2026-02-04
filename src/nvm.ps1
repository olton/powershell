# Enable nvm cross-platform
function Initialize-NvmPath {
    if ($IsLinux -or $IsMacOS) {
        $ENV:NVM_DIR = "$HOME/.nvm"
        if (Test-Path "$HOME/.nvm/nvm.sh") {
            $bashPathWithNvm = bash -c 'source $NVM_DIR/nvm.sh && echo $PATH'
            $env:PATH = $bashPathWithNvm
        }
    } elseif ($IsWindows) {
        # Check for nvm-windows installation
        $nvmWindowsPath = "$env:APPDATA\nvm"
        if (Test-Path $nvmWindowsPath) {
            $env:NVM_HOME = $nvmWindowsPath
            $env:NVM_SYMLINK = "$env:APPDATA\nodejs"
            if ($env:PATH -notlike "*$nvmWindowsPath*") {
                $env:PATH = "$nvmWindowsPath;$env:PATH"
            }
        }
    }
}

function nvm {
    if ($IsLinux -or $IsMacOS) {
        # Linux/macOS implementation using bash
        $quotedArgs = ($args | ForEach-Object { "'$_'" }) -join ' '
        $command = 'source $NVM_DIR/nvm.sh && nvm {0}' -f $quotedArgs
        bash -c $command
    } elseif ($IsWindows) {
        # Windows implementation
        $nvmExe = Get-Command "nvm.exe" -ErrorAction SilentlyContinue
        if ($nvmExe) {
            & nvm.exe $args
        } else {
            Write-Host "nvm is not installed on Windows." -ForegroundColor Red
            Write-Host "Please install nvm-windows from: https://github.com/coreybutler/nvm-windows" -ForegroundColor Yellow
            Write-Host "Or use alternative: scoop install nvm" -ForegroundColor Cyan
        }
    } else {
        Write-Host "Unsupported operating system for nvm function." -ForegroundColor Red
    }
}

# Initialize nvm for all platforms
if ($IsLinux -or $IsMacOS) {
    if (Test-Path "$HOME/.nvm/nvm.sh") {
        Initialize-NvmPath
    }
} elseif ($IsWindows) {
    Initialize-NvmPath
}
