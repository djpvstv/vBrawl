# Path to GCTRealMate
$gctPath = ".\sd_base\vBrawl\GCTRealMate.exe"
$enterFile = ".\sd_base\vBrawl\enter.txt"

# Check if GCTRealMate exists
if (-not (Test-Path $gctPath)) {
    Write-Host "`nError: Cannot find GCTRealMate.exe" -ForegroundColor Red
    pause
    exit
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
