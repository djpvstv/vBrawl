# Path to GCTRealMate
$gctPath = ".\sd_base\vBrawl\GCTRealMate.exe"
$enterFile = ".\sd_base\vBrawl\enter.txt"

# Code Menu Builder paths
$builderDir       = ".\Code Menu Builder"
$builderExe       = "$builderDir\PowerPC Assembly Functions.exe"
$menuOutputDir    = "$builderDir\Code_Menu_Output"
$cmAddonsSrc      = "$menuOutputDir\CM_Addons"
$cmAddonsDst      = ".\sd_base\vBrawl\Source\CM_Addons"
$cmnuSrc          = "$menuOutputDir\data.cmnu"
$cmnuDst          = ".\sd_base\vBrawl\pf\menu3\data.cmnu"
$codeMenuAsmSrc   = "$menuOutputDir\CodeMenu.asm"
$codeMenuAsmDst   = ".\sd_base\vBrawl\Source\CodeMenu\CodeMenu.asm"

# Check if GCTRealMate exists
if (-not (Test-Path $gctPath)) {
    Write-Host "`nError: Cannot find GCTRealMate.exe" -ForegroundColor Red
    pause
    exit
}
if (-not (Test-Path $builderExe)) {
    Write-Host "`nError: Cannot find PowerPC Assembly Functions.exe" -ForegroundColor Red
    pause
    exit
}

Write-Host "`n###################################################################################################`n"
Write-Host "`n`nRunning Code Menu Builder`n"
# The builder blocks on "Press any key to exit" via _getch(), which reads the
# console directly and ignores redirected stdin. Launch it, wait until data.cmnu
# is freshly rewritten (= real work finished), then terminate.
$cmnuSrcFull = [System.IO.Path]::GetFullPath($cmnuSrc)
$preRunTime = Get-Date
Push-Location $builderDir
$proc = Start-Process -FilePath ".\PowerPC Assembly Functions.exe" -NoNewWindow -PassThru
Pop-Location

$timeoutSec = 120
$sw = [System.Diagnostics.Stopwatch]::StartNew()
while ($sw.Elapsed.TotalSeconds -lt $timeoutSec) {
    if ($proc.HasExited) { break }
    if ((Test-Path $cmnuSrcFull) -and ((Get-Item $cmnuSrcFull).LastWriteTime -gt $preRunTime)) {
        Start-Sleep -Milliseconds 500
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        break
    }
    Start-Sleep -Milliseconds 250
}
if (-not $proc.HasExited) {
    Write-Host "  Warning: builder did not produce data.cmnu within $timeoutSec s, terminating." -ForegroundColor Yellow
    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
}
$proc.WaitForExit()

Write-Host "`nDeploying Code Menu Builder output:"
if (Test-Path $cmAddonsSrc) {
    if (Test-Path $cmAddonsDst) { Remove-Item -Path $cmAddonsDst -Recurse -Force }
    Copy-Item -Path $cmAddonsSrc -Destination $cmAddonsDst -Recurse -Force
    Write-Host "  Replaced CM_Addons" -ForegroundColor Green
} else {
    Write-Host "  Error: $cmAddonsSrc not found!" -ForegroundColor Red
}
if (Test-Path $cmnuSrc) {
    Copy-Item -Path $cmnuSrc -Destination $cmnuDst -Force
    Write-Host "  Replaced data.cmnu" -ForegroundColor Green
} else {
    Write-Host "  Error: $cmnuSrc not found!" -ForegroundColor Red
}
if (Test-Path $codeMenuAsmSrc) {
    Copy-Item -Path $codeMenuAsmSrc -Destination $codeMenuAsmDst -Force
    Write-Host "  Replaced CodeMenu.asm" -ForegroundColor Green
} else {
    Write-Host "  Error: $codeMenuAsmSrc not found!" -ForegroundColor Red
}

Write-Host "`n###################################################################################################`n"
Write-Host "`n`nBuilding RSBE01`n"
Start-Process -FilePath $gctPath ".\sd_base\vBrawl\RSBE01.txt" -RedirectStandardInput $enterFile -NoNewWindow -Wait

Write-Host "`n###################################################################################################`n"
Write-Host "`n`nBuilding BOOST`n"
Start-Process -FilePath $gctPath ".\sd_base\vBrawl\BOOST.txt" -RedirectStandardInput $enterFile -NoNewWindow -Wait

Write-Host "`n###################################################################################################`n"
Write-Host "`n`nBuilding NETPLAY`n"
Start-Process -FilePath $gctPath ".\sd_base\vBrawl\NETPLAY.txt" -RedirectStandardInput $enterFile -NoNewWindow -Wait

Write-Host "`n###################################################################################################`n"
Write-Host "`n`nBuilding NETBOOST`n"
Start-Process -FilePath $gctPath ".\sd_base\vBrawl\NETBOOST.txt" -RedirectStandardInput $enterFile -NoNewWindow -Wait

# Path to VDSSync
$vdsPath = ".\tools\VSDsync\VSDSync.exe"

if (Test-Path $vdsPath) {
    Write-Host "`n`nSyncing:"
    Start-Process -FilePath $vdsPath -RedirectStandardInput $enterFile -Wait
    Write-Host "`nComplete!"
} else {
    Write-Host "`nError: Cannot find VDSSync.exe"
}
