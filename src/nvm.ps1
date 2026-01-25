# Fix path for nvm in Linux
function Initialize-NvmPath {
    $ENV:NVM_DIR = "$HOME/.nvm"
    $bashPathWithNvm = bash -c 'source $NVM_DIR/nvm.sh && echo $PATH'
    $env:PATH = $bashPathWithNvm
}

function nvm {
    $quotedArgs = ($args | ForEach-Object { "'$_'" }) -join ' '
    $command = 'source $NVM_DIR/nvm.sh && nvm {0}' -f $quotedArgs
    bash -c $command
}

if ($IsLinux) {
    if (Test-Path "$HOME/.nvm/nvm.sh") {
        Initialize-NvmPath
    }
}
