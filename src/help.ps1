# Help
function help {
    param (
        [switch]$Git,
        [switch]$Linux,
        [switch]$Binder,
        [switch]$Utils,
        [switch]$Vars,
        [switch]$Certs,
        [switch]$All
    )

    $none = -not ($Git -or $Linux -or $Binder -or $Utils -or $Vars -or $Certs -or $All)

    Write-Host ""
    Write-Host "=== Pimenov's PowerShell Extensions ===" -ForegroundColor Cyan
    Write-Host ""

    if ($Git -or $All -or $none) {
        Write-Host "Git Helper Functions:" -ForegroundColor Yellow
        Write-Host "  init                         - Initialize git repository"
        Write-Host "  status                       - Show git status"
        Write-Host "  add <file>                   - Add files to staging"
        Write-Host "  branch                       - List branches"
        Write-Host "  diff                         - Show git diff"
        Write-Host "  pull                         - Pull from remote"
        Write-Host "  del-branch <branch>          - Delete local branch"
        Write-Host "  del-remote <branch>          - Delete remote branch"
        Write-Host "  clean                        - Clean untracked files"
        Write-Host "  reset                        - Reset changes"
        Write-Host "  reset-hard                   - Hard reset to HEAD"
        Write-Host "  unindex <name>               - Remove file from index"
        Write-Host "  clear-index                  - Remove all files from index"
        Write-Host "  current [-Verbose]           - Get current branch name"
        Write-Host "  fetch                        - Fetch all remotes"
        Write-Host "  fetch-remote [remote]        - Fetch specific remote (default: origin)"
        Write-Host "  fetch-prune [remote]         - Fetch and prune remote (default: origin)"
        Write-Host "  fetch-prune-tags             - Fetch and prune tags from all remotes"
        Write-Host "  fetch-prune-all              - Fetch, prune branches and tags from all remotes"
        Write-Host "  fetch-branch <branch>        - Fetch specific branch from remote (origin)"
        Write-Host "  checkout <branch>            - Checkout branch with smart search"
        Write-Host "  list <pattern>               - Search for local branches matching pattern"
        Write-Host "  list-remote <pattern>        - Search for remote branches matching pattern"
        Write-Host "  create <type> <name> [from]  - Create new branch (default from: master)"
        Write-Host "  rename <newName> [oldName]   - Rename branch"
        Write-Host "  exists <name> [remote]       - Check if branch exists"
        Write-Host "  merge <branch> [-Verbose]    - Merge source branch into target"
        Write-Host "  clone <repo> <target> [depth] - Clone repository"
        Write-Host "  clone-one <repo> <target>    - Clone repository with depth 1"
        Write-Host "  check [remote]               - Check if remote is reachable (default: origin)"
        Write-Host "  update [branch]              - Pull changes for current or update from specified branch"
        Write-Host "  upstream <branch> [origin]   - Set upstream for branch"
        Write-Host "  commit [message]             - Add all and commit with message"
        Write-Host "  push <message> [remote]      - Commit and push changes to remote (default: origin)"
        Write-Host "  restore-from <name> [source] - Restore files (default source: master)"
        Write-Host "  restore [files...]           - Restore files (default: all)"
        Write-Host "  log [depth]                  - Show git log"
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
        Write-Host "  ls [path] [pattern] [-C]     - List directory contents"
        Write-Host "  la [path] [pattern]          - List all files"
        Write-Host "  lf [path] [pattern]          - List all files including hidden"
        Write-Host "  lr [path] [pattern]          - List files recursively"
        Write-Host "  pwd                          - Show current directory"
        Write-Host "  cat <file>                   - Display file contents"
        Write-Host "  touch <path>                 - Create new file"
        Write-Host "  tail <file> [-Lines n] [-F]  - Show last n lines of file"
        Write-Host "  rn <path> <newName>          - Rename file or directory"
        Write-Host "  du [directory] [-K|-M]       - Show disk usage"
        Write-Host "  df [path] [-H|-K|-M|-T]      - Show disk free space"
        Write-Host "  search <path> <file>         - Search for files recursively"
        Write-Host "  which                        - Alias for search"
        Write-Host ""
        
        Write-Host "Enhanced grep Function:" -ForegroundColor Green
        Write-Host "  grep <pattern> [file]        - Search for pattern in file or pipeline input"
        Write-Host "    -IgnoreCase                - Ignore case when searching"
        Write-Host "    -CaseSensitive             - Force case-sensitive search"
        Write-Host "    -Regex                     - Use regular expressions"
        Write-Host "    -Invert                    - Show non-matching lines"
        Write-Host "    -Count                     - Count matching lines"
        Write-Host "    -LineNumber                - Show line numbers"
        Write-Host "    -Context <n>               - Show n lines around matches"
        Write-Host "    -Quiet                     - Return boolean (true if found)"
        Write-Host "    -Recurse                   - Search in directories recursively"
        Write-Host "    -Include <patterns>        - Include files matching pattern"
        Write-Host "    -Exclude <patterns>        - Exclude files matching pattern"
        Write-Host ""
        Write-Host "  Examples:"
        Write-Host "    cat file.txt | grep 'error'"
        Write-Host "    grep 'function' script.ps1 -LineNumber"
        Write-Host "    grep 'TODO' -Where . -Recurse -Include '*.ps1'"
        Write-Host "    Get-Process | grep 'chrome' -Count"
        Write-Host ""
    }

    if ($Utils -or $All -or $none) {
        Write-Host "Utility Functions:" -ForegroundColor Magenta
        Write-Host "  clear                        - Clear screen"
        Write-Host "  markdown <path>              - Display markdown file"
        Write-Host "  notepad <file>               - Open file in Notepad++"
        Write-Host "  errors [count]               - Show last n errors (default: 5)"
        Write-Host "  last-error                   - Show details of last error"
        Write-Host "  extract-vscode-extensions [file] [-Install] [-Linux] - Export VS Code extensions"
        Write-Host ""
    }

    if ($Certs -or $All -or $none) {
        Write-Host "Certificate Functions:" -ForegroundColor Cyan
        Write-Host "  get-localhost-conf [path]    - Create localhost.conf for SSL certificates"
        Write-Host "  create-localhost-cert [options] - Create self-signed localhost certificate"
        Write-Host "    -Path <path>               - Directory for certificate files"
        Write-Host "    -Name <name>               - Certificate file name (default: cert)"
        Write-Host "    -Key <name>                - Private key file name (default: key)"
        Write-Host "    -Import                    - Import certificate to store"
        Write-Host "    -Admin                     - Import to system store (requires admin)"
        Write-Host "    -Verbose                   - Show detailed output"
        Write-Host ""
    }

    if ($Binder -or $All -or $none) {
        Write-Host "Binder Project Functions:" -ForegroundColor Blue
        Write-Host "  b-clean                      - Clean binder project"
        Write-Host "  b-init-front                 - Initialize frontend sources"
        Write-Host "  b-init-back                  - Initialize backend sources"
        Write-Host "  b-init-all                   - Initialize all sources"
        Write-Host "  b-init-remote                - Initialize remote sources"
        Write-Host "  b-install                    - Install binder project"
        Write-Host ""
    }

    if ($Vars -or $All -or $none) {
        Write-Host "Environment Variables:" -ForegroundColor Cyan
        Write-Host "  SHOW_PROMPT_TIME             - Set to 'YES' to show time and uptime in prompt"
        Write-Host ""
        
        Write-Host "Additional Tools:" -ForegroundColor Yellow
        Write-Host "  nvm                          - Node Version Manager (Linux only)"
        Write-Host ""
        
        Write-Host "Custom Prompt Features:" -ForegroundColor Yellow
        Write-Host "  🫀 Username                  - Current user"
        Write-Host "  📂 Folder                    - Current directory"
        Write-Host "  🌵 Git Branch                - Current git branch with modification status"
        Write-Host "  👽 Node Version              - Node.js version (if package.json exists)"
        Write-Host "  💻 Uptime                    - System uptime (if SHOW_PROMPT_TIME=YES)"
        Write-Host "  ⌚ Date/Time                 - Current date and time (if SHOW_PROMPT_TIME=YES)"
        Write-Host ""
    }

    Write-Host "Usage: help [-Git] [-Linux] [-Utils] [-Certs] [-Binder] [-Vars] [-All]" -ForegroundColor Gray
    Write-Host ""
}
