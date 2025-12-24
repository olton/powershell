# Git helper functions
function init { git init }
function status { git status }
function add($file = '.') { git add $file }
function fetch { git fetch --all }
function fetch-prune { git fetch --all --prune }
function fetch-prune-all { git fetch --all --prune --prune-tags }
function branch { git branch }
function branch-remote { git branch -r }
function diff { git diff }
function pull { git pull }
function del-branch($branch){ git branch -D $branch }
function del-remote($branch, $remote = "origin"){ git push $remote --delete $branch }
function clean { git clean -fd }
function reset { git reset }
function reset-hard { git reset --hard HEAD}
function unindex ($name) { git rm -rf --cached $name }

# Check function to verify if the remote repository is reachable
function check {
    param (
        [string]$remote = "origin"
    )

    $remoteUrl = git config --get "remote.$remote.url"
    if (-not $remoteUrl -or $remoteUrl.Trim() -eq '') {
        Write-Host "Remote url is not set for '$remote'!" -ForegroundColor Red
        return
    }

    Write-Host "Checking remote '$remoteUrl'..." -ForegroundColor Cyan

    git ls-remote --exit-code -h "$remoteUrl" | Out-Null
    $code = $LASTEXITCODE

    if ($code -eq 0) {
        Write-Host "✅ Success: The remote server is online and reachable." -ForegroundColor Green
    } else {
        Write-Host "❌ Error: Could not reach the remote server." -ForegroundColor Red
    }

    return $code
}

# Enhanced checkout function with branch existence check and suggestions
function checkout { 
    param (
        [string]$branch
    )

    $branchExists = git branch --list $branch

    if (-not $branchExists -or $branchExists.Trim() -eq '') {
        Write-Host "Branch '$branch' does not exist locally. Searching for similar branches..." -ForegroundColor Magenta
        $matchingBranches = @(git branch --list "*$branch*" | ForEach-Object { $_.Trim().TrimStart('* ') } | Where-Object { $_ -ne '' })
        
        if ($matchingBranches.Count -eq 1) {
            Write-Host "Found one matching branch: '$($matchingBranches[0])'. Checking out..." -ForegroundColor Green
            $branch = $matchingBranches[0]
        } elseif ($matchingBranches.Count -gt 1) {
            Write-Host "Found multiple branches matching '$branch':" -ForegroundColor Yellow
            $matchingBranches | ForEach-Object {
                Write-Host "checkout $_" -ForegroundColor Cyan
            }
            return
        } else {
            Write-Host "Branch '$branch' does not exist locally. Fetching from remote..." -ForegroundColor Cyan
            git fetch origin $branch 2>$null
            $branchExists = git branch --list $branch
            if (-not $branchExists -or $branchExists.Trim() -eq '') {
                Write-Host "Branch '$branch' does not exist on remote either!" -ForegroundColor Red
                return
            } else {
                Write-Host "Branch '$branch' found on remote. Checking out..." -ForegroundColor Green
                git checkout $branch
                return
            }
        }
    }

    git checkout $branch 
}

function update {
    param (
        [string]$branch = ''
    )
    
    if (-not $branch -or $branch.Trim() -eq '') {
        Write-Host "Pulling latest changes for current branch" -ForegroundColor Cyan
        pull
        return
    }

    $currentBranch = git rev-parse --abbrev-ref HEAD
    $branchExists = git branch --list $branch
    
    if ($branchExists) {
        Write-Host "Switching to branch '$branch'..." -ForegroundColor Cyan
        git checkout $branch
        
        Write-Host "Pulling latest changes from '$branch'..." -ForegroundColor Cyan
        git pull origin $branch
        
        Write-Host "Switching back to '$currentBranch'..." -ForegroundColor Cyan
        git checkout $currentBranch
        
        Write-Host "Merging '$branch' into '$currentBranch'..." -ForegroundColor Cyan
        git merge $branch
        
        Write-Host "Done!" -ForegroundColor Green
    } else {
        Write-Host "Branch '$branch' does not exist locally." -ForegroundColor Red
    }
}

function upstream {
	param (
	  [string]$branch,
	  [string]$origin = 'origin'
	)
	
	git push --set-upstream $origin $branch
}

function clone ($repository, $target, $depth = 0) { 
    if ($depth -gt 0) {
        git clone --depth $depth $repository $target
    } else {
        git clone $repository $target
    }
}

function rename($oldName, $newName) {
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


