# All paths below are relative to the repository root.
Set-Location $PSScriptRoot

# Path to GCTRealMate
$gctPath = ".\sd_base\vBrawl\GCTRealMate.exe"
$enterFile = ".\sd_base\vBrawl\enter.txt"

# Code Menu Builder paths
$builderDir       = ".\Code Menu Builder"
$builderExeName    = "PowerPC Assembly Functions - Offline.exe"
$builderExeNetName = "PowerPC Assembly Functions - Netplay.exe"
$menuOutputDir    = "$builderDir\Code_Menu_Output"
$cmAddonsSrc      = "$menuOutputDir\CM_Addons"

# Deploy destinations. Both menus go to pf\menu3 and Source\CodeMenu.
# Like P+Ex, only the offline build's CM_Addons is deployed; both CodeMenu.asm
# and Net-CodeMenu.asm include Source/CM_Addons/.
$cmnuDstDir       = ".\sd_base\vBrawl\pf\menu3"
$codeMenuAsmDstDir = ".\sd_base\vBrawl\Source\CodeMenu"
$cmAddonsDst      = ".\sd_base\vBrawl\Source\CM_Addons"

# Check if GCTRealMate exists
if (-not (Test-Path $gctPath)) {
    Write-Host "`nError: Cannot find GCTRealMate.exe" -ForegroundColor Red
    pause
    exit
}
if (-not (Test-Path "$builderDir\$builderExeName")) {
    Write-Host "`nError: Cannot find $builderExeName" -ForegroundColor Red
    pause
    exit
}
if (-not (Test-Path "$builderDir\$builderExeNetName")) {
    Write-Host "`nError: Cannot find $builderExeNetName" -ForegroundColor Red
    pause
    exit
}

# The builder blocks on "Press any key to exit" via _getch(), which reads the
# console directly and ignores redirected stdin. Launch it, wait until its .cmnu
# is freshly rewritten (= real work finished), then terminate.
function Invoke-CodeMenuBuilder([string]$ExeName, [string]$CmnuName) {
    $cmnuSrcFull = [System.IO.Path]::GetFullPath("$menuOutputDir\$CmnuName")
    $preRunTime = Get-Date
    Push-Location $builderDir
    $proc = Start-Process -FilePath ".\$ExeName" -NoNewWindow -PassThru
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
        Write-Host "  Warning: builder did not produce $CmnuName within $timeoutSec s, terminating." -ForegroundColor Yellow
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
    $proc.WaitForExit()
}

function Copy-BuilderFile([string]$FileName, [string]$DstDir) {
    $src = "$menuOutputDir\$FileName"
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination "$DstDir\$FileName" -Force
        Write-Host "  Replaced $FileName" -ForegroundColor Green
    } else {
        Write-Host "  Error: $src not found!" -ForegroundColor Red
    }
}

function Copy-BuilderAddons([string]$Dst) {
    if (-not (Test-Path $cmAddonsSrc)) {
        Write-Host "  Error: $cmAddonsSrc not found!" -ForegroundColor Red
        return
    }
    if (Test-Path $Dst) { Remove-Item -Path $Dst -Recurse -Force }
    Copy-Item -Path $cmAddonsSrc -Destination $Dst -Recurse -Force
    Write-Host "  Replaced CM_Addons" -ForegroundColor Green
}

# AddonAliases.asm holds addresses of addon lines inside the menu file. The shared
# CM_Addons comes from the offline build, so warn if the netplay menu's layout differs.
function Test-NetplayAddonAliases {
    $netAliases = "$menuOutputDir\CM_Addons\AddonAliases.asm"
    $offAliases = "$cmAddonsDst\AddonAliases.asm"
    if (-not ((Test-Path $netAliases) -and (Test-Path $offAliases))) { return }
    if ((Get-FileHash $netAliases).Hash -eq (Get-FileHash $offAliases).Hash) {
        Write-Host "  Netplay addon aliases match the offline ones" -ForegroundColor Green
    } else {
        Write-Host "  Warning: netplay AddonAliases.asm differs from the offline one. dnet.cmnu has a" -ForegroundColor Yellow
        Write-Host "           different layout, so its addon lines may point at the wrong menu lines." -ForegroundColor Yellow
    }
}

Write-Host "`n###################################################################################################`n"
Write-Host "`n`nRunning Code Menu Builder (Offline)`n"
Invoke-CodeMenuBuilder $builderExeName "data.cmnu"

Write-Host "`nDeploying offline Code Menu Builder output:"
Copy-BuilderAddons $cmAddonsDst
Copy-BuilderFile "data.cmnu" $cmnuDstDir
Copy-BuilderFile "CodeMenu.asm" $codeMenuAsmDstDir

Write-Host "`n###################################################################################################`n"
Write-Host "`n`nRunning Code Menu Builder (Netplay)`n"
Invoke-CodeMenuBuilder $builderExeNetName "dnet.cmnu"

Write-Host "`nDeploying netplay Code Menu Builder output:"
Copy-BuilderFile "dnet.cmnu" $cmnuDstDir
Copy-BuilderFile "Net-CodeMenu.asm" $codeMenuAsmDstDir
Test-NetplayAddonAliases

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
