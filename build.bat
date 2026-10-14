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

set "BUILDER_DIR=Code Menu Builder"
set "BUILDER_EXE=%BUILDER_DIR%\PowerPC Assembly Functions.exe"
set "CM_OUTPUT=%BUILDER_DIR%\Code_Menu_Output"
set "CM_CMNU=%CM_OUTPUT%\data.cmnu"
set "CM_ASM=%CM_OUTPUT%\CodeMenu.asm"
set "CM_ADDONS_SRC=%CM_OUTPUT%\CM_Addons"
set "CM_CMNU_DST=sd_base\vBrawl\pf\menu3\data.cmnu"
set "CM_ASM_DST=sd_base\vBrawl\Source\CodeMenu\CodeMenu.asm"
set "CM_ADDONS_DST=sd_base\vBrawl\Source\CM_Addons"

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

:: 1. Code Menu Builder (blocks on _getch; delete-then-poll-then-kill)
echo .
echo ===================================
echo [1/6] Running Code Menu Builder...
echo ===================================
if exist "%CM_CMNU%" del /q "%CM_CMNU%"
pushd "%BUILDER_DIR%"
start "" /B "PowerPC Assembly Functions.exe"
popd

set /a cm_tries=0
:cmwait
if %cm_tries% GEQ 120 goto :cmtimeout
if exist "%CM_CMNU%" (
    timeout /t 1 /nobreak >nul
    taskkill /F /IM "PowerPC Assembly Functions.exe" >nul 2>&1
    goto :cmdeploy
)
timeout /t 1 /nobreak >nul
set /a cm_tries+=1
goto :cmwait

:cmtimeout
echo   [WARNING] Builder did not produce data.cmnu within 120 s, terminating.
taskkill /F /IM "PowerPC Assembly Functions.exe" >nul 2>&1

:cmdeploy
echo.
echo Deploying Code Menu Builder output:
if exist "%CM_ADDONS_SRC%" (
    if exist "%CM_ADDONS_DST%" rmdir /S /Q "%CM_ADDONS_DST%"
    xcopy /E /I /Y /Q "%CM_ADDONS_SRC%" "%CM_ADDONS_DST%" >nul
    echo   Replaced CM_Addons
) else (
    echo   [ERROR] %CM_ADDONS_SRC% not found!
)
if exist "%CM_CMNU%" (
    copy /Y "%CM_CMNU%" "%CM_CMNU_DST%" >nul
    echo   Replaced data.cmnu
) else (
    echo   [ERROR] %CM_CMNU% not found!
)
if exist "%CM_ASM%" (
    copy /Y "%CM_ASM%" "%CM_ASM_DST%" >nul
    echo   Replaced CodeMenu.asm
) else (
    echo   [ERROR] %CM_ASM% not found!
)
echo.

:: 2. Main codes
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