function init { git init }
function status { git status }
function add { git add . }
function fetch { git fetch --all }
function fetch-prune { git fetch --all --prune }
function fetch-prune-all { git fetch --all --prune --prune-tags }
function branch { git branch }
function branch-remote { git branch -r }
function diff { git diff }
function pull { git pull }
function switch($branch){ git checkout $branch }
function del($branch){ git branch -D $branch }
function del-remote($branch, $remote = "origin"){ git push $remote --delete $branch }
function clean { git clean -fd }
function reset { git reset }
function reset-hard { git reset --hard HEAD}
function unindex ($name) { git rm -rf --cached $name }

function clone ($repository, $target, $depth = 0) { 
    if ($depth -gt 0) {
        git clone --depth $depth $repository $target
    } else {
        git clone $repository $target
    }
}

function rename($newName, $oldName) {
    git branch -m $oldName $newName
}

function restore {
    param (
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$names
    )
    
    if ($names.Count -eq 0) {
        git restore .
    } else {
        git restore $names
    }
}

function commit {
    param (
      [string]$Message
    )
    git add .
    git commit -m $Message
}

function push {
    param (
        [string]$Message,
        [string]$Remote = "origin"
    )

    $branchName = git rev-parse --abbrev-ref HEAD

    $branchExists = (git ls-remote --heads $Remote $branchName)

    git add .
    git commit -m $Message

    if ($branchExists -and $branchExists.Trim()) {
        Write-Host "Remote branch $branchName exists." -ForegroundColor Green
        git push
    } else {
        Write-Host "Remote branch $branchName doesn't exists. Creating new remote branch..." -ForegroundColor Green
        git push -u $Remote $branchName
    }
}

function log($deep = -1) { 
    if ($deep -gt 0) {
        $deep = $deep * -1
    }
    git log $deep 
}

function exists {
    param (
        [string]$Name,
        [string]$Remote = ""
    )

    $branchExists = 'false'

    if ($Remote -and $Remote.Trim()) {
        Write-Host "Check remote branch for existing..." -NoNewLine
        $branchExists = (git ls-remote --heads $Remote $Name)
    } else {
        Write-Host "Check local branch for existing..." -NoNewLine
        $branchExists = (git branch --list | Select-String -Pattern $Name -Quiet) 
    }

    return ($branchExists -ne $null)
}

function new { 
    param (
        [string]$Name,
        [string]$From = "master"
    )

    $branchExists = (git branch --list | Select-String -Pattern $From -Quiet) 

    if ($branchExists) {
        git checkout $From
        git pull
        git checkout -b $Name
    } else {
        Write-Host "Source branch $From doesn't exist."
    }
}

function feature { 
    param (
        [string]$Name,
        [string]$From = "master"
    )

    $branchExists = (git branch --list | Select-String -Pattern $From -Quiet) 

    if ($branchExists) {
        $new_branch = "feature/" + $Name 
        git checkout $From
        git pull
        git checkout -b $new_branch
    } else {
        Write-Host "Source branch $From doesn't exist."
    }
}

function review { 
    param (
        [string]$Name,
        [string]$From = "master"
    )

    $branchExists = (git branch --list | Select-String -Pattern $From -Quiet) 

    if ($branchExists) {
        $new_branch = "review/" + $Name 
        git checkout $From
        git pull
        git checkout -b $new_branch
    } else {
        Write-Host "Source branch $From doesn't exist."
    }
}
