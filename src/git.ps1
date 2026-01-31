# Git helper functions
function init { 
    param (
        [string]$Branch = "main",
        [string]$Template = "",
        [string]$Directory = ""
    )

    $template = $([string]::IsNullOrEmpty($Template) ? "" : "--template=$Template")
    $directory = $([string]::IsNullOrEmpty($Directory) ? "" : $Directory)

    Write-Host " "
    Write-Host "Initializing new git repository with initial branch '$Branch'..." -NoNewLine
    $null = git init --initial-branch=$Branch  $template $directory  
    Write-Host "OK" -ForegroundColor Green
    Write-Host " "
}

function status { git status }

function add { 
    param (
        [string]$File = "."
    )
    Write-Host " "
    Write-Host "Adding file(s) to staging area..." -NoNewLine
    $null = git add $File 
    Write-Host "OK" -ForegroundColor Green
    Write-Host " "
}

function branch { git branch }
function diff { git diff }
function pull { git pull }

function del-branch { 
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть назву гілки")]
        [string]$Branch
    )
    Write-Host " "
    Write-Host "Deleting local branch '$Branch'..." -NoNewLine
    $null = git branch -D $Branch 
    Write-Host "OK" -ForegroundColor Green
    Write-Host " "
}

function del-remote { 
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть назву гілки")]
        [string]$Branch,
        [string]$Remote = "origin"
    )
    Write-Host " "
    Write-Host "Deleting remote branch '$Branch' from remote '$Remote'..." -NoNewLine
    $null = git push $Remote --delete $Branch 
    Write-Host "OK" -ForegroundColor Green
    Write-Host " "
}

function clean { git clean -fd }
function reset { git reset }
function reset-hard { git reset --hard HEAD}

function unindex { 
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть шлях до файлу(ів)")]
        [string]$Name
    )
    Write-Host " "
    Write-Host "Removing file(s) from index (staging area)..." -NoNewLine
    git rm -rf --cached $Name 
    Write-Host "OK" -ForegroundColor Green
    Write-Host " "
}

function clear-index { 
    Write-Host " "
    Write-Host "Clearing entire index (staging area)..." -NoNewLine
    $null = git rm --cached -r . -f 
    Write-Host "OK" -ForegroundColor Green
    Write-Host " "
}

function current {
    param (
        [switch]$Verbose
    )

    $currentBranch = git rev-parse --abbrev-ref HEAD

    if ($Verbose) {
        Write-Host "Getting current branch name..."
        Write-Host "Current branch is: " -NoNewLine
        Write-Host $currentBranch -ForegroundColor Yellow
    }

    return $currentBranch
}

function fetch { 
    Write-Host " "
    Write-Host "Fetching all remotes..." -NoNewLine
    $null =git fetch --all 
    Write-Host "OK" -ForegroundColor Green
    Write-Host " "
}

function fetch-remote { 
    param (
        [string]$Remote = "origin"
    )

    Write-Host " "
    Write-Host "Fetching from remote '$Remote'..." -NoNewLine
    $null = git fetch $Remote
    Write-Host "OK" -ForegroundColor Green
    Write-Host " "
}

function fetch-prune { 
    param (
        [string]$Remote = "origin"
    )

    Write-Host " "
    Write-Host "Fetching from remote '$Remote' with prune..." -NoNewLine
    $null = git fetch $Remote --prune
    Write-Host "OK" -ForegroundColor Green
    Write-Host " "
}

function fetch-prune-tags { 
    Write-Host " "
    Write-Host "Fetching all remotes with prune tags..." -NoNewLine
    $null = git fetch --all --prune-tags 
    Write-Host "OK" -ForegroundColor Green
    Write-Host " "
}

function fetch-prune-all { 
    Write-Host " "
    Write-Host "Fetching all remotes with prune and prune tags..." -NoNewLine
    $null = git fetch --all --prune --prune-tags 
    Write-Host "OK" -ForegroundColor Green
    Write-Host " "
}

function fetch-branch {
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть назву гілки")]
        [string]$Branch,
        [string]$Remote = "origin"
    )

    Write-Host " "

    if (check $Remote -ne 0) {
        Write-Host "Remote '$Remote' is not reachable." -ForegroundColor Red
        return
    }

    Write-Host "Fetching branch '$Branch' from remote '$Remote'..." -ForegroundColor Cyan
    $null = git fetch $Remote $Branch
    Write-Host "Fetch completed." -ForegroundColor Green
    Write-Host " "
    return
}

function list {
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть назву гілки, або її частину")]
        [string]$Branch
    )

    Write-Host " "
    Write-Host "Searching for similar branches for '$Branch'... " -NoNewLine
    $matchingBranches = @(git branch --list "*$Branch*" | ForEach-Object { $_.Trim().TrimStart('* ') } | Where-Object { $_ -ne '' })
    
    if ($matchingBranches.Count -eq 1) {
        Write-Host "Found one matching branch!" -ForegroundColor Magenta
        Write-Host " "
        Write-Host "$($matchingBranches[0])" -ForegroundColor Green
        Write-Host " "
        return
    } elseif ($matchingBranches.Count -gt 1) {
        Write-Host "Found multiple branches matching!" -ForegroundColor Yellow
        Write-Host " "
        $matchingBranches | ForEach-Object {
            Write-Host "$_" -ForegroundColor Cyan
        }
        Write-Host " "
        return
    }

    Write-Host " "
    Write-Host "No matching branches found." -ForegroundColor Red
    Write-Host " "
    return
}

function list-remote {
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть назву гілки, або її частину")]
        [string]$Branch,
        [string]$Remote = "origin"
    )

    Write-Host " "

    if (check $Remote -ne 0) {
        Write-Host "Remote '$Remote' is not reachable." -ForegroundColor Red
        return
    }

    Write-Host "Searching for similar remote branches for '$Branch'... " -NoNewLine
    $matchingBranches = @(git ls-remote --heads $Remote "*$Branch*" | ForEach-Object { ($_ -split "`t")[1].Replace("refs/heads/", "").Trim() } | Where-Object { $_ -ne '' })
    
    if ($matchingBranches.Count -eq 1) {
        Write-Host "Found one matching remote branch!" -ForegroundColor Magenta
        Write-Host " "
        Write-Host "$($matchingBranches[0])" -ForegroundColor Green
        Write-Host " "
        return
    } elseif ($matchingBranches.Count -gt 1) {
        Write-Host "Found multiple remote branches matching!" -ForegroundColor Yellow
        Write-Host " "
        $matchingBranches | ForEach-Object {
            Write-Host "$_" -ForegroundColor Cyan
        }
        Write-Host " "
        return
    }

    Write-Host " "
    Write-Host "No matching remote branches found." -ForegroundColor Red
    Write-Host " "
    return
}

# Check function to verify if the remote repository is reachable
function check {
    param (
        [string]$Remote = "origin"
    )

    $remoteUrl = git config --get "remote.$Remote.url"
    if (-not $remoteUrl -or $remoteUrl.Trim() -eq '') {
        Write-Host " "
        Write-Host "Remote url is not set for '$Remote'!" -ForegroundColor Red
        Write-Host " "
        return -1
    }

    Write-Host " "
    Write-Host "Checking remote " -NoNewLine
    Write-Host "$remoteUrl..." -ForegroundColor Cyan

    git ls-remote --exit-code -h "$remoteUrl" | Out-Null
    $code = $LASTEXITCODE

    if ($code -eq 0) {
        Write-Host "✅ Success: The remote server is online and reachable." -ForegroundColor Green
    } else {
        Write-Host "❌ Error: Could not reach the remote server." -ForegroundColor Red
    }

    Write-Host " "
    return $code
}

# Enhanced checkout function with branch existence check and suggestions
function checkout { 
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть назву гілки")]
        [string]$Branch
    )

    $hasChanges = git status --porcelain

    if ($hasChanges -and $hasChanges.Trim()) {
        Write-Host "You have uncommitted changes in your working directory." -ForegroundColor Yellow
        Write-Host "Please commit or stash your changes before switching branches." -ForegroundColor Yellow
        Write-Host " "
        status
        return
    }

    Write-Host " "
    Write-Host "Checking out branch '$Branch'..." -ForegroundColor Cyan
    $branchExists = git branch --list $Branch

    if (-not $branchExists -or $branchExists.Trim() -eq '') {
        Write-Host "Branch '$Branch' does not exist locally. Searching for similar branches..." -ForegroundColor Magenta
        $matchingBranches = @(git branch --list "*$Branch*" | ForEach-Object { $_.Trim().TrimStart('* ') } | Where-Object { $_ -ne '' })
        
        if ($matchingBranches.Count -eq 1) {
            Write-Host "Found one matching branch. Checking out..." -ForegroundColor Magenta
            $Branch = $matchingBranches[0]
            git checkout $Branch 
            Write-Host "Switched to branch '$Branch'." -ForegroundColor Green
            Write-Host " "
            return
        } elseif ($matchingBranches.Count -gt 1) {
            Write-Host "Found multiple branches matching '$Branch':" -ForegroundColor Yellow
            Write-Host " "
            $matchingBranches | ForEach-Object {
                Write-Host "checkout $_" -ForegroundColor Cyan
            }
            Write-Host " "
            return
        } else {
            Write-Host "Branch '$Branch' does not exist locally. Fetching from remote..." -ForegroundColor Cyan
            if (check -ne 0) {
                Write-Host "Remote is not reachable. Cannot fetch branch." -ForegroundColor Red
                return
            }
            Write-Host "Fetching branch info from remote..." -ForegroundColor Cyan
            git fetch origin
            git checkout $Branch
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Branch '$Branch' does not exist on remote either." -ForegroundColor Red
                Write-Host " "
                return
            }
            Write-Host "Switched to branch '$Branch'." -ForegroundColor Green
            Write-Host " "
            return
        }
    } else {
        git checkout $Branch 
        Write-Host "Switched to branch '$Branch'." -ForegroundColor Green
        Write-Host " "
        return
    }   
}

# Update function to pull latest changes from a specified branch and merge into current branch
# If no branch is specified, it pulls latest changes for the current branch
function update {
    param (
        [string]$Branch = ''
    )
    
    if (check -ne 0) {
        Write-Host "Remote is not reachable. Update aborted." -ForegroundColor Red
        return
    }

    $hasChanges = git status --porcelain
    If ($hasChanges -and $hasChanges.Trim()) {
        Write-Host "You have uncommitted changes in your working directory." -ForegroundColor Yellow
        Write-Host "Please commit or stash your changes before pulling updates." -ForegroundColor Yellow
        Write-Host " "
        status
        return
    }

    if (-not $Branch -or $Branch.Trim() -eq '') {
        Write-Host "Pulling latest changes for current branch" -ForegroundColor Cyan
        pull
        return
    }

    $currentBranch = current
    $branchExists = git branch --list $Branch
    
    if ($branchExists) {
        Write-Host "Switching to branch '$Branch'..." -ForegroundColor Cyan
        git checkout $Branch
        
        Write-Host "Pulling latest changes from '$Branch'..." -ForegroundColor Cyan
        git pull origin $Branch
        
        Write-Host "Switching back to '$currentBranch'..." -ForegroundColor Cyan
        git checkout $currentBranch
        
        Write-Host "Merging '$Branch' into '$currentBranch'..." -ForegroundColor Cyan
        git merge $Branch
        
        Write-Host "Done!" -ForegroundColor Green
        return
    } else {
        Write-Host "Branch '$Branch' does not exist locally." -ForegroundColor Red
        Write-Host "Update aborted." -ForegroundColor Red
        return
    }
}

function upstream {
	param (
      [Parameter(Mandatory, HelpMessage = "Введіть назву гілки")]
	  [string]$Branch,
	  [string]$Origin = 'origin'
	)
	
    if (check $Origin -ne 0) {
        Write-Host "Cannot set upstream because remote '$Origin' is not reachable." -ForegroundColor Red
        return
    }

    Write-Host " "
    Write-Host "Setting upstream for branch '$Branch' to remote '$Origin'..." -ForegroundColor Green
	git push --set-upstream $Origin $Branch
    Write-Host " "
    return
}

function clone { 
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть URL репозиторію")]
        [string]$Repository, 
        [Parameter(Mandatory, HelpMessage = "Введіть цільову теку (для поточної теки використайте '.')")]
        [string]$Target, 
        [int]$Depth = 0
    )

    if ($Depth -gt 0) {
        git clone --depth $Depth $Repository $Target
    } else {
        git clone $Repository $Target
    }
}

function clone-one {
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть URL репозиторію")]
        [string]$Repository, 
        [Parameter(Mandatory, HelpMessage = "Введіть цільову теку (для поточної теки використайте '.')")]
        [string]$Target
    )

    clone -Repository $Repository -Target $Target -Depth 1
}

function rename {
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть нову назву гілки")]
        [string]$NewName,
        [string]$OldName
    )

    $currentBranch = current

    git branch -m $OldName $NewName
}

function restore-from {
    param (
        [string]$Name,
        [string]$Source = "master"
    )

    if (-not $Name -or $Name.Trim() -eq '') {
        Write-Host "File name cannot be empty." -ForegroundColor Red
        return
    }

    Write-Host "Restoring file '$Name' from '$Source'..." -ForegroundColor Cyan
    git restore --source=$Source $Name
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to restore file '$Name' from '$Source'." -ForegroundColor Red
        return
    }
    Write-Host "File '$Name' restored successfully." -ForegroundColor Green
}

function restore {
    param (
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Names
    )
    
    if ($Names.Count -eq 0) {
        git restore .
    } else {
        git restore $Names
    }
}

function commit {
    param (
      [string]$Message = "Update files"
    )
    git add .
    git commit -m $Message
}

function push {
    param (
        [string]$Message,
        [string]$Remote = "origin",
        [switch]$Simple
    )

    Write-Host " "

    $changes = git diff --shortstat

    Write-Host "Pushing current changes..."

    if (check $Remote -ne 0) {
        Write-Host " "
        Write-Host "Cannot push, because remote '$Remote' is not reachable." -ForegroundColor Red
        Write-Host " "
        return
    }

    if ($Simple) {
        Write-Host "Using only push command..." -ForegroundColor Yellow
        git push
        Write-Host " "    
        Write-Host "Push operation completed." -ForegroundColor Green
        Write-Host " "   
        return
    }

    Write-Host "Getting current branch name..." 
    $branchName = current

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
    return
}

function log { 
    param (
        [int]$Deep = 1
    )
    if ($Deep -gt 0) {
        $Deep = $Deep * -1
    }
    git log $Deep 
}

function exists {
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть назву гілки")]
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

function create {
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть тип гілки")]
        [string]$Type,
        [Parameter(Mandatory, HelpMessage = "Введіть назву гілки")]
        [string]$Name,
        [string]$From = "master",
        [switch]$Force
    )

    Write-Host " "

    $new_name = $Type.trim() == '' ? $Name : "$Type/$Name"

    if (exists -Name $Name) {
        Write-Host "Branch $Name already exists." -ForegroundColor Red
        Write-Host " "
        return
    }

    Write-Host "Checking out to source branch '$From'..." -ForegroundColor Cyan
    checkout $From

    # if ($LASTEXITCODE -eq 3) {
    #     Write-Host "Cannot create branch because multiply source branches found." -ForegroundColor Red
    #     Write-Host " "
    #     return
    # }

    if ($LASTEXITCODE -ne 0 -and -not $Force) {
        Write-Host "Cannot create branch because source branch '$From' does not exist." -ForegroundColor Red
        Write-Host " "
        return
    }

    Write-Host "Creating new branch $new_name..." -ForegroundColor Cyan
    $null = git checkout -b $new_name
    Write-Host "Branch $new_name created successfully." -ForegroundColor Green

    Write-Host " "
    return
}

function feature { 
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть назву гілки")]
        [string]$Name,
        [string]$From = "master"
    )

    create -Type "new" -Name $Name -From $From
}

function feature { 
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть назву гілки")]
        [string]$Name,
        [string]$From = "master"
    )

    create -Type "feature" -Name $Name -From $From
}

function review { 
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть назву гілки")]
        [string]$Name,
        [string]$From = "master"
    )

    create -Type "review" -Name $Name -From $From
}

function hotfix { 
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть назву гілки")]
        [string]$Name,
        [string]$From = "master"
    )

    create -Type "hotfix" -Name $Name -From $From
}

function release { 
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть назву гілки")]
        [string]$Name,
        [string]$From = "master"
    )

    create -Type "release" -Name $Name -From $From
}

function merge {
    param (
        [Parameter(Mandatory, HelpMessage = "Введіть назву гілки яку потрібно злити в поточну")]
        [string]$Branch,
        [switch]$Verbose
    )

    if ((-not $Branch -or $Branch.Trim() -eq '')) {
        Write-Host "Branch name cannot be empty." -ForegroundColor Red
        Write-Host "Use " -NoNewLine
        Write-Host "merge <branch>" -ForegroundColor Cyan -NoNewLine
        Write-Host " to merge branches."
        Write-Host " "
        return
    }

    if (check -eq 0) {
        Write-Host "Pulling latest changes for current branch..." -ForegroundColor Cyan
        $null = git pull origin $(current)
    }

    Write-Host "Merging $Branch into current." -ForegroundColor Cyan
    if ($Verbose) {
        git merge $Branch --verbose
    } else {
        git merge $Branch
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Merge failed." -ForegroundColor Red
        Write-Host " "
        return
    }

    Write-Host "Merge completed." -ForegroundColor Green
    Write-Host " "
    return
}
