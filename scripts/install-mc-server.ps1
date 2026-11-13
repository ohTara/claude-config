<#
.SYNOPSIS
    Install Minecraft PaperMC server on Windows with Podman (rootless)
    Adapted from the Pop!_OS version for Windows environment

.DESCRIPTION
    Sets up a Minecraft PaperMC server using Podman containers with:
    - Rootless Podman for security
    - Automatic backups (optional cloud sync via rclone)
    - Systemd-style service management via Podman generate systemd
    - Memory limits suitable for low-RAM hosts (800MB default)

.PARAMETER BackupRemote
    Optional rclone remote for cloud backups (e.g., "gdrive:mc-backups")

.PARAMETER MemoryLimit
    Memory limit for the container (default: 800m)

.PARAMETER ServerPort
    Minecraft server port (default: 25565)

.PARAMETER RconPort
    RCON port (default: 25575)

.EXAMPLE
    # Basic install
    ./scripts/install-mc-server.ps1

.EXAMPLE
    # With Google Drive backup
    ./scripts/install-mc-server.ps1 -BackupRemote "gdrive:mc-backups"

.EXAMPLE
    # Custom memory and ports
    ./scripts/install-mc-server.ps1 -MemoryLimit "1g" -ServerPort 25565 -RconPort 25575
#>

param(
    [string] $BackupRemote = "",
    [string] $MemoryLimit = "800m",
    [int] $ServerPort = 25565,
    [int] $RconPort = 25575,
    [switch] $DryRun,
    [switch] $Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($Help) {
    Get-Help $PSCommandPath -Detailed
    return
}

# ──────────────────────────────────────────────────────────────────────────────
# Config
$ServerName = "paper"
$ContainerName = "mc-paper"
$DataDir = Join-Path $env:USERPROFILE "mc-server"
$BackupDir = Join-Path $DataDir "backups"
$ComposeFile = Join-Path $DataDir "docker-compose.yml"
$ServiceFile = Join-Path $env:USERPROFILE ".config\systemd\user\mc-paper.service"
$PodmanSocket = "podman.socket"

Write-Host "=== Minecraft PaperMC Server Setup (Podman Rootless) ===" -ForegroundColor Cyan
Write-Host "Data directory: $DataDir"
Write-Host "Memory limit: $MemoryLimit"
Write-Host "Server port: $ServerPort"
Write-Host "RCON port: $RconPort"
if ($BackupRemote) { Write-Host "Backup remote: $BackupRemote" }
Write-Host ""

# ──────────────────────────────────────────────────────────────────────────────
# Verify Podman
if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "Podman not found. Run install-windows.ps1 first to install Podman."
}

# Enable podman socket for rootless
if (-not $DryRun) {
    Write-Host "Enabling Podman user socket..."
    & podman system service --time=0 $PodmanSocket > $null 2>&1 &
    Start-Sleep 2
}

# ──────────────────────────────────────────────────────────────────────────────
# Create directory structure
$dirs = @($DataDir, $BackupDir, (Join-Path $DataDir "world"), (Join-Path $DataDir "plugins"), (Join-Path $DataDir "config"))
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        Write-Host "Creating directory: $dir"
        if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    }
}

# ──────────────────────────────────────────────────────────────────────────────
# Generate docker-compose.yml
$composeContent = @"
version: '3.8'

services:
  paper:
    image: ghcr.io/papermc/paper:1.21
    container_name: $ContainerName
    restart: unless-stopped
    memory: $MemoryLimit
    cpus: '2'
    environment:
      - EULA=TRUE
      - MEMORY=$MemoryLimit
      - TZ=Europe/Rome
      - PAPER_FLAGS=--paper-settings
    ports:
      - "$ServerPort:25565/tcp"
      - "$ServerPort:25565/udp"
      - "$RconPort:25575/tcp"
    volumes:
      - ./world:/data/world
      - ./plugins:/data/plugins
      - ./config:/data/config
      - ./backups:/data/backups
    healthcheck:
      test: ["CMD-SHELL", "mc-monitor status --host localhost --port 25565 || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
"@

if ($BackupRemote) {
    $composeContent += @"

  backup:
    image: ghcr.io/carlosonunez/rclone:latest
    container_name: mc-backup
    restart: "no"
    profiles: ["backup"]
    environment:
      - RCLONE_CONFIG=$RCLONE_CONFIG
    volumes:
      - ./backups:/data/backups:ro
      - $env:USERPROFILE/.config/rclone:/config/rclone:ro
    entrypoint: ["rclone", "sync", "/data/backups", "$BackupRemote", "--progress", "--transfers=4"]
"
}

Write-Host "Generating docker-compose.yml..."
if (-not $DryRun) {
    [IO.File]::WriteAllText($ComposeFile, $composeContent, [Text.UTF8Encoding]::new($false))
}
else {
    Write-Host "[DRY-RUN] Would write docker-compose.yml to $ComposeFile"
}

# ──────────────────────────────────────────────────────────────────────────────
# Generate server.properties template
$serverProps = Join-Path $DataDir "config\server.properties"
if (-not (Test-Path $serverProps)) {
    $propsContent = @"
# Minecraft PaperMC server.properties
# Generated on $(Get-Date -Format 'yyyy-MM-dd HH:mm')

enable-jmx-monitoring=false
rcon.port=$RconPort
level-seed=
gamemode=survival
enable-command-block=false
enable-query=false
generator-settings={}
enforce-secure-profile=true
level-name=world
motd=PaperMC Server on Windows (Podman)
query.port=25565
pvp=true
generate-structures=true
difficulty=easy
network-compression-threshold=256
max-tick-time=60000
require-resource-pack=false
use-native-transport=true
max-players=20
online-mode=true
enable-status=true
allow-flight=false
broadcast-rcon-to-ops=true
view-distance=10
server-ip=
resource-pack-prompt=
max-build-height=256
server-port=$ServerPort
enable-rcon=false
sync-chunk-writes=true
op-permission-level=4
prevent-proxy-connections=false
resource-pack=
entity-broadcast-range-percentage=100
simulation-distance=10
rcon.password=changeme
player-idle-timeout=0
force-gamemode=false
rate-limit=0
hardcore=false
white-list=false
broadcast-console-to-ops=true
spawn-npcs=true
spawn-animals=true
function-permission-level=2
level-type=minecraft:normal
spawn-monsters=true
enforce-whitelist=false
spawn-protection=16
resource-pack-sha1=
max-world-size=29999984
"@
    Write-Host "Generating server.properties..."
    if (-not $DryRun) { [IO.File]::WriteAllText($serverProps, $propsContent, [Text.UTF8Encoding]::new($false)) }
}

# ──────────────────────────────────────────────────────────────────────────────
# Generate paper.yml template (PaperMC config)
$paperYml = Join-Path $DataDir "config\paper.yml"
if (-not (Test-Path $paperYml)) {
    $paperContent = @"
# PaperMC Configuration
# https://docs.papermc.io/paper/reference/paper-yml

verbose: false
config-version: 22

settings:
  allow-permanent-chunk-loaders: false
  load-permanent-chunk-loaders-on-startup: false
  max-auto-save-chunks-per-tick: 24
  optimize-explosions: true
  use-faster-eigencraft-redstone: true
  nether-ceiling-void-damage-height: 127
  disable-chest-cat-detection: true
  disable-end-credits: true
  disable-relative-projectile-velocity: false
  disable-sprint-interruption-on-attack: false
  update-pathfinding-on-block-update: false
  fix-curing-zombie-villager-discount: true
  maps-item-frame-cursor-limit: 128
  enable-teleportation-suffocation-check: true
  prevent-tnt-from-spawning-in-end-crystals: true
  end-portal-teleport-cooldown: 0

world-settings:
  default:
    verbose: false
    optimize-explosions: true
    use-faster-eigencraft-redstone: true
    max-auto-save-chunks-per-tick: 24
    prevent-moving-into-unloaded-chunks: true
    nether-ceiling-void-damage-height: 127
    disable-chest-cat-detection: true
    disable-end-credits: true
    update-pathfinding-on-block-update: false
    fix-curing-zombie-villager-discount: true
    maps-item-frame-cursor-limit: 128
    enable-teleportation-suffocation-check: true
    prevent-tnt-from-spawning-in-end-crystals: true
    end-portal-teleport-cooldown: 0
"@
    Write-Host "Generating paper.yml..."
    if (-not $DryRun) { [IO.File]::WriteAllText($paperYml, $paperContent, [Text.UTF8Encoding]::new($false)) }
}

# ──────────────────────────────────────────────────────────────────────────────
# Generate systemd service file (for Podman generate systemd)
$serviceContent = @"
[Unit]
Description=Minecraft PaperMC Server (Podman)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=podman-compose -f $ComposeFile up
ExecStop=podman-compose -f $ComposeFile down
Restart=on-failure
RestartSec=10
TimeoutStartSec=120
TimeoutStopSec=60

# Resource limits
MemoryLimit=$MemoryLimit
CPUQuota=200%

[Install]
WantedBy=default.target
"@

$serviceDir = Split-Path $ServiceFile
if (-not (Test-Path $serviceDir)) {
    if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $serviceDir | Out-Null }
}

Write-Host "Generating systemd service file..."
if (-not $DryRun) { [IO.File]::WriteAllText($ServiceFile, $serviceContent, [Text.UTF8Encoding]::new($false)) }

# ──────────────────────────────────────────────────────────────────────────────
# Generate management scripts
$startScript = Join-Path $DataDir "start-server.ps1"
$startContent = @"
<#
.SYNOPSIS
    Start Minecraft PaperMC server
#>
param([switch] \$Detach = \$true)
cd \"$DataDir\"
if (\$Detach) {
    podman-compose up -d
    Write-Host \"Server started in background. Logs: podman-compose logs -f\"
}
else {
    podman-compose up
}
"@

$stopScript = Join-Path $DataDir "stop-server.ps1"
$stopContent = @"
<#
.SYNOPSIS
    Stop Minecraft PaperMC server
#>
cd \"$DataDir\"
podman-compose down
Write-Host \"Server stopped.\"
"@

$backupScript = Join-Path $DataDir "backup-server.ps1"
$backupContent = @"
<#
.SYNOPSIS
    Backup Minecraft world
#>
param(
    [string] \$Remote = \"$BackupRemote\"
)
cd \"$DataDir\"
\$timestamp = Get-Date -Format \"yyyyMMdd-HHmmss\"
\$backupName = \"world-\$timestamp.tar.gz\"
Write-Host \"Creating backup: \$backupName\"
podman-compose exec -T paper tar -czf \"/data/backups/\$backupName\" -C /data world
Write-Host \"Backup created: \$backupName\"

if (\$Remote) {
    Write-Host \"Uploading to \$Remote...\"
    rclone copy \"$BackupDir/\$backupName\" \"\$Remote/\"
    Write-Host \"Upload complete.\"
}
"@

$logsScript = Join-Path $DataDir "logs-server.ps1"
$logsContent = @"
<#
.SYNOPSIS
    View Minecraft server logs
#>
param([switch] \$Follow = \$true)
cd \"$DataDir\"
if (\$Follow) { podman-compose logs -f paper }
else { podman-compose logs --tail=100 paper }
"@

foreach ($script in @($startScript, $stopScript, $backupScript, $logsScript)) {
    $content = switch ($script) {
        $startScript { $startContent }
        $stopScript { $stopContent }
        $backupScript { $backupContent }
        $logsScript { $logsContent }
    }
    if (-not (Test-Path $script)) {
        Write-Host "Generating $(Split-Path $script -Leaf)..."
        if (-not $DryRun) { [IO.File]::WriteAllText($script, $content, [Text.UTF8Encoding]::new($false)) }
    }
}

# ──────────────────────────────────────────────────────────────────────────────
# Generate podman-compose wrapper (since podman-compose may not be installed)
$podmanComposeWrapper = Join-Path $env:USERPROFILE ".local\bin\podman-compose.ps1"
$wrapperContent = @"
<#
.SYNOPSIS
    podman-compose wrapper using podman play kube
    Place in ~/\.local\bin\podman-compose.ps1 and ensure it's in PATH
#>
param(
    [string] \$Command = \"up\",
    [string[]] \$Args
)

\$composeFile = \"\$Args[0]\"
if (-not \$composeFile) { throw \"Usage: podman-compose.ps1 -f <compose-file> <command>\" }

switch (\$Command) {
    \"up\" {
        \$detached = \$Args -contains \"-d\" -or \$Args -contains \"--detach\"
        \$kubeFile = \"\$env:TEMP\mc-kube-\$([guid]::NewGuid()).yaml\"
        podman kube generate --service \$composeFile | Out-File \$kubeFile -Encoding utf8
        if (\$detached) { podman kube play --detach \$kubeFile }
        else { podman kube play \$kubeFile }
        Remove-Item \$kubeFile -Force -ErrorAction SilentlyContinue
    }
    \"down\" {
        \$kubeFile = \"\$env:TEMP\mc-kube-\$([guid]::NewGuid()).yaml\"
        podman kube generate --service \$composeFile | Out-File \$kubeFile -Encoding utf8
        podman kube down \$kubeFile
        Remove-Item \$kubeFile -Force -ErrorAction SilentlyContinue
    }
    \"logs\" {
        \$follow = \$Args -contains \"-f\" -or \$Args -contains \"--follow\"
        \$service = \$Args | Where-Object { \$_ -notmatch '^-' } | Select-Object -Last 1
        if (-not \$service) { \$service = \"paper\" }
        if (\$follow) { podman logs -f \$service }
        else { podman logs --tail=100 \$service }
    }
    \"exec\" {
        \$service = \$Args[1]
        \$cmd = \$Args[2..(\$Args.Count-1)] -join \" \"
        podman exec -it \$service \$cmd
    }
    default { throw \"Unknown command: \$Command\" }
}
"@

if (-not (Test-Path $podmanComposeWrapper)) {
    Write-Host "Generating podman-compose wrapper..."
    if (-not $DryRun) { [IO.File]::WriteAllText($podmanComposeWrapper, $wrapperContent, [Text.UTF8Encoding]::new($false)) }
}

# ──────────────────────────────────────────────────────────────────────────────
# Setup rclone if backup remote provided
if ($BackupRemote -and (-not $DryRun)) {
    if (-not (Get-Command rclone -ErrorAction SilentlyContinue)) {
        Write-Host "Installing rclone..."
        & scoop install rclone 2>$null || & winget install Rclone.Rclone 2>$null || Write-Warning "Could not install rclone automatically. Install manually: https://rclone.org/install/"
    }
    $rcloneConfig = Join-Path $env:USERPROFILE ".config\rclone\rclone.conf"
    if (-not (Test-Path $rcloneConfig)) {
        Write-Warning "rclone not configured. Run 'rclone config' to set up '$BackupRemote' remote."
    }
}

# ──────────────────────────────────────────────────────────────────────────────
# Start server
if (-not $DryRun) {
    Write-Host ""
    Write-Host "Starting Minecraft PaperMC server..." -ForegroundColor Green
    cd $DataDir
    try {
        & podman-compose -f $ComposeFile up -d
        Write-Host "Server started! Connect to: localhost:$ServerPort" -ForegroundColor Green
        Write-Host ""
        Write-Host "Management commands:"
        Write-Host "  Start:   $startScript"
        Write-Host "  Stop:    $stopScript"
        Write-Host "  Logs:    $logsScript"
        Write-Host "  Backup:  $backupScript"
        Write-Host ""
        Write-Host "Config files in: $DataDir\config"
        Write-Host "World data in:   $DataDir\world"
        Write-Host "Backups in:      $BackupDir"
    }
    catch {
        Write-Error "Failed to start server: $($_.Exception.Message)"
        Write-Host "Try manually: cd $DataDir; podman-compose -f $ComposeFile up -d"
    }
}
else {
    Write-Host ""
    Write-Host "[DRY-RUN] Would start server with: podman-compose -f $ComposeFile up -d"
}

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Cyan