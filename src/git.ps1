# Git helper functions
function init { git init }
function status { git status }
function add($file = '.') { git add $file }
function fetch { git fetch --all }
function fetch-prune { git fetch --all --prune }
function fetch-prune-all { git fetch --all --prune --prune-tags }
function branch { git branch }
function diff { git diff }
function pull { git pull }
function del-branch($branch){ git branch -D $branch }
function del-remote($branch, $remote = "origin"){ git push $remote --delete $branch }
function clean { git clean -fd }
function reset { git reset }
function reset-hard { git reset --hard HEAD}
function unindex ($name) { git rm -rf --cached $name }

function list {
    param (
        [string]$branch
    )

    Write-Host " "
    Write-Host "Searching for similar branches for '$branch'... " -NoNewLine
    $matchingBranches = @(git branch --list "*$branch*" | ForEach-Object { $_.Trim().TrimStart('* ') } | Where-Object { $_ -ne '' })
    
    if ($matchingBranches.Count -eq 1) {
        Write-Host "Found one matching branch!" -ForegroundColor Magenta
        Write-Host " "
        Write-Host "$($matchingBranches[0])" -ForegroundColor Green
        Write-Host " "
    } elseif ($matchingBranches.Count -gt 1) {
        Write-Host "Found multiple branches matching!" -ForegroundColor Yellow
        Write-Host " "
        $matchingBranches | ForEach-Object {
            Write-Host "$_" -ForegroundColor Cyan
        }
        Write-Host " "
        return
    } else {
        Write-Host " "
        Write-Host "No matching branches found." -ForegroundColor Red
        Write-Host " "
    }
}

function list-remote {
    param (
        [string]$branch,
        [string]$remote = "origin"
    )

    Write-Host " "

    if (check $remote -ne 0) {
        Write-Host "Remote '$remote' is not reachable." -ForegroundColor Red
        return
    }

    Write-Host "Searching for similar remote branches for '$branch'... " -NoNewLine
    $matchingBranches = @(git ls-remote --heads $remote "*$branch*" | ForEach-Object { ($_ -split "`t")[1].Replace("refs/heads/", "").Trim() } | Where-Object { $_ -ne '' })
    
    if ($matchingBranches.Count -eq 1) {
        Write-Host "Found one matching remote branch!" -ForegroundColor Magenta
        Write-Host " "
        Write-Host "$remote/$($matchingBranches[0])" -ForegroundColor Green
        Write-Host " "
    } elseif ($matchingBranches.Count -gt 1) {
        Write-Host "Found multiple remote branches matching!" -ForegroundColor Yellow
        Write-Host " "
        $matchingBranches | ForEach-Object {
            Write-Host "$remote/$_" -ForegroundColor Cyan
        }
        Write-Host " "
        return
    } else {
        Write-Host " "
        Write-Host "No matching remote branches found." -ForegroundColor Red
        Write-Host " "
    }
}

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

    Write-Host "Checking remote " -NoNewLine
    Write-Host "$remoteUrl..." -ForegroundColor Cyan

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
            Write-Host " "
            $matchingBranches | ForEach-Object {
                Write-Host "checkout $_" -ForegroundColor Cyan
            }
            Write-Host " "
            return
        } else {
            Write-Host "Branch '$branch' does not exist locally. Fetching from remote..." -ForegroundColor Cyan
            if (check -ne 0) {
                Write-Host "Remote is not reachable. Cannot fetch branch." -ForegroundColor Red
                return
            }
            Write-Host "Fetching branch '$branch' from remote..." -ForegroundColor Cyan
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

    Write-Host "Checking out branch '$branch'..." -ForegroundColor Magenta
    git checkout $branch 
}

# Update function to pull latest changes from a specified branch and merge into current branch
# If no branch is specified, it pulls latest changes for the current branch
function update {
    param (
        [string]$branch = ''
    )
    
    if (check -ne 0) {
        Write-Host "Remote is not reachable. Update aborted." -ForegroundColor Red
        return
    }

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
	
    if (check $origin -ne 0) {
        Write-Host "Cannot set upstream because remote '$origin' is not reachable." -ForegroundColor Red
        return
    }

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

    Write-Host " "

    $changes = git diff --shortstat

    if (-not $changes -or $changes.Trim() -eq '') {
        Write-Host " "
        Write-Host "Tree is clean. No changes to push." -ForegroundColor Yellow
        Write-Host " "
        return
    }

    Write-Host "Changes found. Starting commit and push..." -ForegroundColor Cyan

    if (check $Remote -ne 0) {
        Write-Host " "
        Write-Host "Cannot push, because remote '$Remote' is not reachable." -ForegroundColor Red
        Write-Host " "
        return
    }

    Write-Host "Getting current branch name..." 
    $branchName = git rev-parse --abbrev-ref HEAD

    Write-Host "Current branch is: " -NoNewLine
    Write-Host $branchName -ForegroundColor Yellow

    Write-Host "Preparing to push changes to remote '$Remote'..."
    Write-Host "Commit message: " -NoNewLine
    Write-Host $Message -ForegroundColor Magenta
    Write-Host "Changes:" -NoNewLine
    Write-Host ($changes ? $changes : "No changes") -ForegroundColor Magenta

    Write-Host "Adding changes and committing..."
    $null = git add .
    $null = git commit -m $Message

    Write-Host "Checking if remote branch '$branchName' exists on '$Remote'..."
    $branchExists = (git ls-remote --heads $Remote $branchName)

    if ($branchExists -and $branchExists.Trim()) {
        Write-Host "Remote branch $branchName exists. Pushing changes..."
        git push 2>&1 | Out-Null
    } else {
        Write-Host "Remote branch $branchName doesn't exists. Creating new remote branch and pushing changes..."
        $null = git push -u $Remote $branchName
    }

    Write-Host " "    
    Write-Host "Push operation completed." -ForegroundColor Green
    Write-Host " "    
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

    Write-Host " "

    if (!$Name -or $Name.Trim() -eq '') {
        Write-Host "Branch name cannot be empty." -ForegroundColor Red
        Write-Host "Use " -NoNewLine
        Write-Host "new branch_name [from_branch]" -ForegroundColor Cyan -NoNewLine
        Write-Host " to create a new branch."
        Write-Host " "
        return
    }

    if (exists -Name $Name) {
        Write-Host "Branch $Name already exists." -ForegroundColor Red
        Write-Host " "
        return
    }

    if ($From -eq $Name) {
        Write-Host "Source branch and new branch name cannot be the same." -ForegroundColor Red
        Write-Host " "
        return
    }

    $null = fetch
    $branchExists = (git branch --list | Select-String -Pattern $From -Quiet) # "^\*?\s*$From$"

    if ($branchExists) {
        Write-Host "Source branch $From exists."
        Write-Host "Checking out to $From..."
        git checkout $From
        if (check -eq 0) {
            Write-Host "Remote is reachable. Pulling latest changes from '$From'..." -ForegroundColor Cyan
            git pull
        }
    } else {
        Write-Host "Source branch $From doesn't exist."
        Write-Host "Created new branch $Name from current." -ForegroundColor Green
    }

    $null = git checkout -b $Name
    Write-Host "Branch $Name created successfully." -ForegroundColor Green

    Write-Host " "
}

function create {
    param (
        [string]$Type,
        [string]$Name,
        [string]$From = "master"
    )

    Write-Host " "

    $new_name = "$Type/$Name"
    $null = fetch
    $branchExists = (git branch --list | Select-String -Pattern $From -Quiet) # "^\*?\s*$From$"

    if ($branchExists) {
        Write-Host "Source branch $From exists."
        Write-Host "Creating new branch $new_name from $From..." -ForegroundColor Cyan
        Write-Host "Checking out to $From..."
        git checkout $From
        if (check -eq 0) {
            Write-Host "Remote is reachable. Pulling latest changes from '$From'..." -ForegroundColor Yellow
            git pull
        }
    } else {
        Write-Host "Source branch $From doesn't exist."
        Write-Host "Creating new branch $new_name from current." -ForegroundColor Magenta
    }

    $null = git checkout -b $new_name
    Write-Host "Branch $new_name created successfully." -ForegroundColor Green

    Write-Host " "
}

function feature { 
    param (
        [string]$Name,
        [string]$From = "master"
    )

    create -Type "feature" -Name $Name -From $From
}

function review { 
    param (
        [string]$Name,
        [string]$From = "master"
    )

    create -Type "review" -Name $Name -From $From
}

function hotfix { 
    param (
        [string]$Name,
        [string]$From = "master"
    )

    create -Type "hotfix" -Name $Name -From $From
}

function release { 
    param (
        [string]$Name,
        [string]$From = "master"
    )

    create -Type "release" -Name $Name -From $From
}

function merge {
    param (
        [string]$Source,
        [string]$Target
    )

    Write-Host "Merging branch '$Source' into '$Target'..." -ForegroundColor Cyan

    $null = git checkout $Target
    $null = git pull origin $Target

    $null = git merge $Source

    Write-Host "Merge completed." -ForegroundColor Green
    Write-Host " "
}
