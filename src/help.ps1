# Help
function help {
    param (
        [switch]$Git,
        [switch]$Linux,
        [switch]$Binder,
        [switch]$Utils,
        [switch]$Vars
    )

    $none = -not ($Git -or $Linux -or $Binder -or $All)

    Write-Host ""
    Write-Host "=== Pimenov's PowerShell Extensions ===" -ForegroundColor Cyan
    Write-Host ""

    if ($Git -or $All -or $none) {
        Write-Host "Git Helper Functions:" -ForegroundColor Yellow
        Write-Host "  init                      - Initialize git repository"
        Write-Host "  status                    - Show git status"
        Write-Host "  add [file]                - Add files to staging (default: all files)"
        Write-Host "  branch                    - List branches"
        Write-Host "  diff                      - Show git diff"
        Write-Host "  pull                      - Pull from remote"
        Write-Host "  del-branch <branch>       - Delete local branch"
        Write-Host "  del-remote <branch>       - Delete remote branch"
        Write-Host "  clean                     - Clean untracked files"
        Write-Host "  reset                     - Reset changes"
        Write-Host "  reset-hard                - Hard reset to HEAD"
        Write-Host "  unindex <name>            - Remove file from index"
        Write-Host "  fetch                     - Fetch all remotes"
        Write-Host "  fetch-remote [remote]     - Fetch specific remote (default: origin)"
        Write-Host "  fetch-prune [remote]      - Fetch and prune remote (default: origin)"
        Write-Host "  fetch-prune-tags          - Fetch and prune tags from all remotes"
        Write-Host "  fetch-prune-all           - Fetch, prune branches and tags from all remotes"
        Write-Host "  fetch-branch <branch>     - Fetch specific branch from remote"
        Write-Host "  checkout <branch>         - Checkout branch with smart search"
        Write-Host "  list <pattern>            - Search for local branches matching pattern"
        Write-Host "  list-remote <pattern>     - Search for remote branches matching pattern"
        Write-Host "  new <name> [from]         - Create new branch (default from: master)"
        Write-Host "  rename <old> <new>        - Rename branch"
        Write-Host "  exists <name> [remote]    - Check if branch exists"
        Write-Host "  merge <branch> [-Verbose] - Merge source branch into target"
        Write-Host "  clone <repo> <target>     - Clone repository"
        Write-Host "  check [remote]            - Check if remote is reachable"
        Write-Host "  update [branch]           - Update current or specified branch"
        Write-Host "  upstream <branch>         - Set upstream for branch"
        Write-Host "  commit [message]          - Add all and commit with message"
        Write-Host "  push <message> [remote]   - Commit and push changes"
        Write-Host "  restore [files...]        - Restore files (default: all)"
        Write-Host "  log [depth]               - Show git log"
        Write-Host ""

        Write-Host "Git Workflow Functions:" -ForegroundColor Yellow
        Write-Host "  feature <name> [from]   - Create feature branch"
        Write-Host "  review <name> [from]    - Create review branch"
        Write-Host "  hotfix <name> [from]    - Create hotfix branch"
        Write-Host "  release <name> [from]   - Create release branch"
        Write-Host ""
    }

    if ($Linux -or $All -or $none) {
        Write-Host "Linux-style File Operations:" -ForegroundColor Green
        Write-Host "  ls [path] [pattern]     - List directory contents"
        Write-Host "  la [path] [pattern]     - List all files"
        Write-Host "  lf [path] [pattern]     - List all files including hidden"
        Write-Host "  lr [path] [pattern]     - List files recursively"
        Write-Host "  pwd                     - Show current directory"
        Write-Host "  cat <file>              - Display file contents"
        Write-Host "  touch <path>            - Create new file"
        Write-Host "  tail <file> [-Lines n]  - Show last n lines of file"
        Write-Host "  grep <pattern> [file]   - Search for pattern in file or input"
        Write-Host "  rn <path> <newName>     - Rename file or directory"
        Write-Host "  du [directory]          - Show disk usage"
        Write-Host "  df [path] [-h|-k|-m]    - Show disk free space"
        Write-Host "  search <path> <file>    - Search for files recursively"
        Write-Host "  which <path> <file>     - Alias for search"
        Write-Host ""
    }

    if ($Utils -or $All -or $none) {
        Write-Host "Utility Functions:" -ForegroundColor Magenta
        Write-Host "  clear                   - Clear screen"
        Write-Host "  markdown <path>         - Display markdown file"
        Write-Host "  notepad <file>          - Open file in Notepad++"
        Write-Host ""
    }

    if ($Binder -or $All -or $none) {
        Write-Host "Binder Project Functions:" -ForegroundColor Blue
        Write-Host "  b-clean                 - Clean binder project"
        Write-Host "  b-init-front            - Initialize frontend sources"
        Write-Host "  b-init-back             - Initialize backend sources"
        Write-Host "  b-init-all              - Initialize all sources"
        Write-Host "  b-init-remote           - Initialize remote sources"
        Write-Host "  b-install               - Install binder project"
        Write-Host ""
    }

    if ($Vars -or $All -or $none) {
        Write-Host "Environment Variables:" -ForegroundColor Cyan
        Write-Host "  SHOW_PROMPT_TIME        - Set to 'YES' to show time and uptime in prompt"
        Write-Host ""
    }
}

