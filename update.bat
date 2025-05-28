@echo off
cls

call pathconfig.bat

echo Checking for script updates with version files...

setlocal enabledelayedexpansion

:: Temp folder for remote versions
set "TMP_VERSIONS=%TEMP%\versions_remote"
if exist "%TMP_VERSIONS%" rd /s /q "%TMP_VERSIONS%"
mkdir "%TMP_VERSIONS%"

:: Ensure local versions folder exists
if not exist versions mkdir versions

:: list of script names (without extension) to check and update
set scripts_list=script1 script2 script3

set updated_count=0

for %%S in (%scripts_list%) do (
    echo Checking version for %%S ...
    powershell -Command "Invoke-WebRequest -UseBasicParsing -Uri '%BASE_URL%/versions/%%S.txt' -OutFile '%TMP_VERSIONS%\%%S.txt'" >nul 2>&1
    if errorlevel 1 (
        echo Failed to download remote version for %%S
    ) else (
        set /p REMOTE_VER=<"%TMP_VERSIONS%\%%S.txt"
        set "LOCAL_VER="
        if exist "versions\%%S.txt" set /p LOCAL_VER=<"versions\%%S.txt"

        if not "!REMOTE_VER!"=="!LOCAL_VER!" (
            echo Version mismatch or missing for %%S, updating script...
            powershell -Command "Invoke-WebRequest -UseBasicParsing -Uri '%BASE_URL%/scripts/%%S.bat' -OutFile 'scripts\%%S.bat'" >nul 2>&1
            if errorlevel 1 (
                echo Failed to download script %%S.bat
            ) else (
                copy /Y "%TMP_VERSIONS%\%%S.txt" "versions\%%S.txt" >nul
                set /a updated_count+=1
                echo Updated %%S.bat and version file.
            )
        ) else (
            echo %%S is up to date.
        )
    )
)

echo.
if %updated_count% EQU 0 (
    echo All scripts are up to date.
) else (
    echo %updated_count% script(s) updated.
)

pause
exit /b 0
