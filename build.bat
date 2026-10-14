@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
cls
cd /d "%~dp0"

:: =============================================
:: Configuration
:: =============================================
set "GCT=sd_base\vBrawl\GCTRealMate.exe"
set "ENTER=sd_base\vBrawl\enter.txt"
set "FIGHTER_DIR=sd_base\vBrawl\rsbe\pf\fighter"

echo.
echo +==================================================+
echo ^|                  vBrawl Builder                  ^|
echo +==================================================+
echo.

:: Check GCTRealMate
if not exist "%GCT%" (
    echo [ERROR] GCTRealMate.exe not found! >&2
    echo         Expected in: %GCT%
    goto :finalpause
)

:: 1. Main codes
echo.
echo ================================
echo [1/4] Building RSBE01...
echo ================================
"%GCT%" "sd_base\vBrawl\RSBE01.txt" < "%ENTER%"
echo.

echo.
echo ================================
echo [2/4] Building BOOST...
echo ================================
"%GCT%" "sd_base\vBrawl\BOOST.txt" < "%ENTER%"
echo.

echo.
echo ================================
echo [3/4] Building Codes NETPLAY...
echo ================================
"%GCT%" "sd_base\vBrawl\NETPLAY.txt" < "%ENTER%"
echo.

echo.
echo ================================
echo [4/4] Building Codes NETBOOST...
echo ================================
"%GCT%" "sd_base\vBrawl\NETBOOST.txt" < "%ENTER%"
echo.

:vdsstep
:: 2. VDS Sync
if exist "tools\VSDsync\VSDSync.exe" (
    echo Syncing with VDS Sync...
    "tools\VSDsync\VSDSync.exe" < "%ENTER%"
    echo.
    echo Complete!
) else (
    echo [WARNING] VDS Sync not found - skipping.
)

:: =============================================
:: FINAL PAUSE - THIS IS WHAT KEEPS THE WINDOW OPEN
:: =============================================
:finalpause
echo.
echo +==================================================+
echo ^|            ALL DONE! PRESS ENTER TO EXIT         ^|
echo +==================================================+
echo.
pause >nul
endlocal
exit /b 0