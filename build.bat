@echo off
cls

call pathconfig.bat

echo Running build: creating folders and placeholders...

setlocal enabledelayedexpansion

:: List your scripts base names here (without .bat)
set scripts_list=script1 script2 script3

:: Create folders if missing
if not exist scripts mkdir scripts
if not exist versions mkdir versions

:: Create placeholder files if missing
for %%S in (%scripts_list%) do (
    if not exist "scripts\%%S.bat" (
        echo rem placeholder script for %%S > "scripts\%%S.bat"
        echo Created placeholder scripts\%%S.bat
    )
    if not exist "versions\%%S.txt" (
        echo 0 > "versions\%%S.txt"
        echo Created placeholder versions\%%S.txt with version 0
    )
)

echo.

:: Check for update.bat, download if missing
if not exist update.bat (
    echo update.bat not found locally, downloading from repo...
    powershell -Command "Invoke-WebRequest -UseBasicParsing -Uri '%BASE_URL%/update.bat' -OutFile 'update.bat'" >nul 2>&1
    if errorlevel 1 (
        echo Failed to download update.bat from repo.
        pause
        exit /b 1
    )
    echo update.bat downloaded successfully.
) else (
    echo update.bat found locally.
)

echo.
echo Running update.bat to download latest scripts...
call update.bat

pause
exit /b 0
