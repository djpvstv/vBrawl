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
set "BUILDER_EXE=PowerPC Assembly Functions - Offline.exe"
set "BUILDER_EXE_NET=PowerPC Assembly Functions - Netplay.exe"
set "CM_OUTPUT=%BUILDER_DIR%\Code_Menu_Output"
set "CM_ADDONS_SRC=%CM_OUTPUT%\CM_Addons"

:: Both menus go to pf\menu3 and Source\CodeMenu. Like P+Ex, only the offline
:: build's CM_Addons is deployed; both CodeMenu.asm and Net-CodeMenu.asm include it.
set "CM_CMNU_DST_DIR=sd_base\vBrawl\pf\menu3"
set "CM_ASM_DST_DIR=sd_base\vBrawl\Source\CodeMenu"
set "CM_ADDONS_DST=sd_base\vBrawl\Source\CM_Addons"

echo.
echo +==================================================+
echo ^|                  vBrawl Builder                  ^|
echo +==================================================+
echo.

:: Check GCTRealMate and both builders
if not exist "%GCT%" (
    echo [ERROR] GCTRealMate.exe not found! >&2
    echo         Expected in: %GCT%
    goto :finalpause
)
if not exist "%BUILDER_DIR%\%BUILDER_EXE%" (
    echo [ERROR] %BUILDER_EXE% not found in %BUILDER_DIR%! >&2
    goto :finalpause
)
if not exist "%BUILDER_DIR%\%BUILDER_EXE_NET%" (
    echo [ERROR] %BUILDER_EXE_NET% not found in %BUILDER_DIR%! >&2
    goto :finalpause
)

:: 1. Offline Code Menu
echo.
echo ===========================================
echo [1/7] Running Code Menu Builder (Offline)...
echo ===========================================
call :runbuilder "%BUILDER_EXE%" "data.cmnu"
echo.
echo Deploying offline Code Menu Builder output:
call :copyaddons "%CM_ADDONS_DST%"
call :copyfile "data.cmnu" "%CM_CMNU_DST_DIR%"
call :copyfile "CodeMenu.asm" "%CM_ASM_DST_DIR%"
echo.

:: 2. Netplay Code Menu
echo.
echo ===========================================
echo [2/7] Running Code Menu Builder (Netplay)...
echo ===========================================
call :runbuilder "%BUILDER_EXE_NET%" "dnet.cmnu"
echo.
echo Deploying netplay Code Menu Builder output:
call :copyfile "dnet.cmnu" "%CM_CMNU_DST_DIR%"
call :copyfile "Net-CodeMenu.asm" "%CM_ASM_DST_DIR%"
:: AddonAliases.asm holds addresses of addon lines inside the menu file. The shared
:: CM_Addons comes from the offline build, so warn if the netplay menu's layout differs.
if exist "%CM_ADDONS_SRC%\AddonAliases.asm" if exist "%CM_ADDONS_DST%\AddonAliases.asm" (
    fc /b "%CM_ADDONS_SRC%\AddonAliases.asm" "%CM_ADDONS_DST%\AddonAliases.asm" >nul 2>&1
    if errorlevel 1 (
        echo   [WARNING] Netplay AddonAliases.asm differs from the offline one. dnet.cmnu has a
        echo             different layout, so its addon lines may point at the wrong menu lines.
    ) else (
        echo   Netplay addon aliases match the offline ones
    )
)
echo.

:: 3. Main codes
echo.
echo ================================
echo [3/7] Building RSBE01...
echo ================================
"%GCT%" "sd_base\vBrawl\RSBE01.txt" < "%ENTER%"
echo.

echo.
echo ================================
echo [4/7] Building BOOST...
echo ================================
"%GCT%" "sd_base\vBrawl\BOOST.txt" < "%ENTER%"
echo.

echo.
echo ================================
echo [5/7] Building Codes NETPLAY...
echo ================================
"%GCT%" "sd_base\vBrawl\NETPLAY.txt" < "%ENTER%"
echo.

echo.
echo ================================
echo [6/7] Building Codes NETBOOST...
echo ================================
"%GCT%" "sd_base\vBrawl\NETBOOST.txt" < "%ENTER%"
echo.

:vdsstep
:: 7. VDS Sync
echo.
echo ================================
echo [7/7] VDS Sync...
echo ================================
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

:: =============================================
:: Subroutines
:: =============================================

:: :runbuilder "<exe name>" "<cmnu name>"
:: The builder blocks on _getch "Press any key", which ignores redirected stdin.
:: Delete its old .cmnu, start it, poll until the new .cmnu appears, then kill it.
:runbuilder
set "RB_EXE=%~1"
set "RB_CMNU=%CM_OUTPUT%\%~2"
if exist "%RB_CMNU%" del /q "%RB_CMNU%"
pushd "%BUILDER_DIR%"
start "" /B "%RB_EXE%"
popd
set /a rb_tries=0
:rbwait
if %rb_tries% GEQ 120 goto :rbtimeout
if exist "%RB_CMNU%" (
    timeout /t 1 /nobreak >nul
    taskkill /F /IM "%RB_EXE%" >nul 2>&1
    exit /b 0
)
timeout /t 1 /nobreak >nul
set /a rb_tries+=1
goto :rbwait
:rbtimeout
echo   [WARNING] Builder did not produce %~2 within 120 s, terminating.
taskkill /F /IM "%RB_EXE%" >nul 2>&1
exit /b 1

:: :copyfile "<file name in Code_Menu_Output>" "<destination dir>"
:copyfile
if exist "%CM_OUTPUT%\%~1" (
    copy /Y "%CM_OUTPUT%\%~1" "%~2\%~1" >nul
    echo   Replaced %~1
) else (
    echo   [ERROR] %CM_OUTPUT%\%~1 not found!
)
exit /b 0

:: :copyaddons "<destination dir>"
:copyaddons
if exist "%CM_ADDONS_SRC%" (
    if exist "%~1" rmdir /S /Q "%~1"
    xcopy /E /I /Y /Q "%CM_ADDONS_SRC%" "%~1" >nul
    echo   Replaced CM_Addons
) else (
    echo   [ERROR] %CM_ADDONS_SRC% not found!
)
exit /b 0
