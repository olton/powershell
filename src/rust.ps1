# Enable rust in linux
if ($IsLinux -and Test-Path "$HOME/.cargo/env") {
    $cargoEnv = bash -c "source $HOME/.cargo/env && env"
    $cargoEnv | ForEach-Object {
        if ($_ -match "^PATH=(.*)$") {
            $env:PATH = $matches[1]
        }
    }
}
