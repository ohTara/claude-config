<#
.SYNOPSIS
    RTK Hook for PowerShell - Automatically wraps shell commands with RTK for token optimization
    Based on the RTK hook from free-claude-code

.DESCRIPTION
    This hook intercepts bash commands and rewrites them to use RTK (Rust Token Killer)
    for token-efficient output. Place this in your Claude Code hooks configuration.

    To enable: Add to ~/.claude/settings.json or project .claude/settings.json:
    {
      "hooks": {
        "PreToolUse": [
          {
            "matcher": "Bash",
            "hooks": [
              { "type": "command", "command": "pwsh -File ~/.claude/hooks/rtk-hook.ps1" }
            ]
          }
        ]
      }
    }
#>

param(
    [string] $ToolInput = ""
)

# Read stdin if no argument provided
if (-not $ToolInput) {
    $input = $null
    try { $input = [Console]::In.ReadToEnd() } catch { }
    if ($input) { $ToolInput = $input.Trim() }
}

if (-not $ToolInput) { exit 0 }

# Parse JSON input
$toolData = $ToolInput | ConvertFrom-Json
if (-not $toolData -or -not $toolData.command) { exit 0 }

$command = $toolData.command.Trim()

# Skip if already using rtk
if ($command -match '^\s*rtk\s') { exit 0 }

# Skip meta commands
$metaCommands = @('rtk gain', 'rtk discover', 'rtk proxy', 'rtk init', 'rtk --version', 'rtk --help')
foreach ($meta in $metaCommands) {
    if ($command -match "^$meta") { exit 0 }
}

# Skip commands that don't benefit from RTK
$skipPatterns = @(
    '^cd\s', '^pwd$', '^ls\s', '^dir\s', '^echo\s', '^export\s', '^set\s',
    '^source\s', '^\.\s', '^which\s', '^where\s', '^type\s', '^help\s',
    '^man\s', '^\?\s', '^clear$', '^cls$', '^history\s', '^exit$'
)

foreach ($pattern in $skipPatterns) {
    if ($command -match $pattern) { exit 0 }
}

# Skip interactive commands
$interactivePatterns = @('vim', 'nvim', 'nano', 'emacs', 'less', 'more', 'top', 'htop', 'btop', 'fzf', 'git commit', 'git rebase -i', 'git add -i')
foreach ($pattern in $interactivePatterns) {
    if ($command -match $pattern) { exit 0 }
}

# Skip if command contains pipes/redirects that RTK might not handle well
# Actually RTK handles pipes fine, so we'll let it through

# Rewrite command to use RTK
$rewrittenCommand = "rtk $command"

# Output the rewritten command as JSON for the hook system
$output = @{
    command = $rewrittenCommand
    description = $toolData.description
} | ConvertTo-Json -Depth 5 -Compress

Write-Output $output