# build_and_deploy.ps1
$ErrorActionPreference = "Stop"

# === .env.deploy einlesen ===
$envFile = ".env.deploy"
if (-not (Test-Path $envFile)) {
    Write-Host "Fehler: .env.deploy nicht gefunden!" -ForegroundColor Red
    exit 1
}

$envVars = @{}
Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
        $envVars[$matches[1].Trim()] = $matches[2].Trim()
    }
}

# === Build ===
$Version = Get-Date -Format "yyyyMMddHHmmss"
$BuildDate = Get-Date -Format "o"

Write-Host "[1/3] Building commercia web, version: $Version" -ForegroundColor Cyan

flutter build web --release --dart-define=APP_VERSION=$Version

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# === version.json schreiben ===
$VersionJson = @{
    version = $Version
    buildDate = $BuildDate
} | ConvertTo-Json -Compress

$VersionJson | Out-File -FilePath "build/web/build_info.json" -Encoding utf8 -NoNewline

Write-Host "[2/3] Build erfolgreich. Version: $Version" -ForegroundColor Green

# === Platzhalter ersetzen ===
$AppName = "Commercia Aarau"
$AppShortName = "Commercia"

Write-Host "Setting app name: $AppName" -ForegroundColor Cyan

$indexPath = "build/web/index.html"
$manifestPath = "build/web/manifest.json"

(Get-Content $indexPath -Raw) `
    -replace '\{\{APP_NAME\}\}', $AppName `
    -replace '\{\{APP_SHORT_NAME\}\}', $AppShortName `
    | Set-Content $indexPath -NoNewline

(Get-Content $manifestPath -Raw) `
    -replace '\{\{APP_NAME\}\}', $AppName `
    -replace '\{\{APP_SHORT_NAME\}\}', $AppShortName `
    | Set-Content $manifestPath -NoNewline

# === Deploy via WinSCP ===
Write-Host "[3/3] Deploying to ServerTown..." -ForegroundColor Cyan

$winscpPath = "C:\Program Files (x86)\WinSCP\WinSCP.com"
if (-not (Test-Path $winscpPath)) {
    $winscpPath = "C:\Program Files\WinSCP\WinSCP.com"
}
if (-not (Test-Path $winscpPath)) {
    Write-Host "WinSCP nicht gefunden! Bitte installieren von winscp.net" -ForegroundColor Red
    exit 1
}

$localPath = (Resolve-Path "build/web").Path
$remotePath = $envVars["FTP_REMOTE_PATH"]
$protocol = $envVars["FTP_PROTOCOL"]
$ftpHost = $envVars["FTP_HOST"]
$user = $envVars["FTP_USER"]
$pass = $envVars["FTP_PASS"]

# WinSCP Script-Befehle
$winscpScript = @"
open ${protocol}://${user}:${pass}@${ftpHost}/
synchronize remote -delete -criteria=time "$localPath" "$remotePath"
exit
"@

$tempScript = [System.IO.Path]::GetTempFileName()
$winscpScript | Out-File -FilePath $tempScript -Encoding ascii

try {
    & $winscpPath /script=$tempScript /log="winscp.log"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Deployment failed! Check winscp.log" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Deployment erfolgreich!" -ForegroundColor Green
    Write-Host "Version $Version ist jetzt live." -ForegroundColor Green
}
finally {
    Remove-Item $tempScript -ErrorAction SilentlyContinue
}