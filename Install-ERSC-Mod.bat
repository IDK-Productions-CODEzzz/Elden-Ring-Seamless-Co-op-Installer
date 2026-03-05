@echo off

:: ==========================================
:: AUTO-ELEVATE TO ADMINISTRATOR
:: ==========================================
:: Silently test for admin rights by checking the net session command
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    :: Exit this non-admin instance so the elevated one can take over
    exit /b
)

:: When elevated, Windows changes the working directory to System32.
:: This command forces it back to the folder where this .bat file actually lives.
cd /d "%~dp0"
:: ==========================================

title Seamless Co-op Installer Helper
color 0A

echo ==========================================
echo    Seamless Co-op Installer Helper
echo ==========================================
echo.

:: Run the search function
call :SearchForZip
if %ERRORLEVEL% NEQ 0 (
    echo Press any key to exit...
    pause >nul
    exit /b
)

:: Run the extraction function
call :ExtractZip
if %ERRORLEVEL% NEQ 0 (
    echo Press any key to exit...
    pause >nul
    exit /b
)

:: Run the settings deletion function
call :DeleteSettingsFile
if %ERRORLEVEL% NEQ 0 (
    echo Press any key to exit...
    pause >nul
    exit /b
)

:: Run the file moving function
call :MoveModFiles
if %ERRORLEVEL% NEQ 0 (
    echo Press any key to exit...
    pause >nul
    exit /b
)

:: If we get here, everything installed perfectly!
echo.
echo ==========================================
echo    INSTALLATION COMPLETE!
echo ==========================================
echo Your Seamless Co-op mod is installed and ready to go.
echo.
echo Press any key to close this window...
pause >nul
exit /b

:: ==========================================
:: FUNCTIONS BELOW THIS LINE
:: ==========================================

:SearchForZip
echo Searching for the Seamless Co-op .zip file...
set "FOUND_FILE="

for /f "delims=" %%F in ('dir /b /a-d "*Seamless Co-op*.zip" 2^>nul ^| findstr /v /i "Nightreign"') do (
    set "FOUND_FILE=%%F"
    goto :FileFound
)

echo.
echo [ERROR] Could not find the Seamless Co-op .zip file!
echo Please ensure the downloaded mod .zip is in the exact same folder as this script.
echo.
exit /b 1

:FileFound
echo.
echo [SUCCESS] Found mod file: "%FOUND_FILE%"
echo.
exit /b 0

:ExtractZip
echo Preparing to extract files...

:GenerateDirName
set "TEMP_EXTRACT_DIR=SeamlessTemp_%RANDOM%%RANDOM%"
if exist "%TEMP_EXTRACT_DIR%\" goto GenerateDirName

echo Creating temporary folder: "%TEMP_EXTRACT_DIR%"
mkdir "%TEMP_EXTRACT_DIR%"

echo Extracting "%FOUND_FILE%". This might take a moment...
tar -xf "%FOUND_FILE%" -C "%TEMP_EXTRACT_DIR%"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Failed to extract the .zip file. The archive might be corrupted.
    exit /b 1
)

echo.
echo [SUCCESS] Extraction complete! Files are safely stored in "%TEMP_EXTRACT_DIR%".
exit /b 0

:DeleteSettingsFile
echo.
echo Checking for existing settings file...
set "EXISTING_SETTINGS=C:\Program Files (x86)\Steam\steamapps\common\ELDEN RING\Game\SeamlessCoop\ersc_settings.ini"
set "TEMP_SETTINGS=%TEMP_EXTRACT_DIR%\SeamlessCoop\ersc_settings.ini"

:: If the settings file does NOT exist in the game folder, this is a new install.
if not exist "%EXISTING_SETTINGS%" (
    echo [INFO] No existing settings found. First-time install detected.
    echo Keeping the default settings file in the extraction folder.
    exit /b 0
)

:: If we pass the check above, the file exists in the game folder, meaning this is an update.
echo [INFO] Existing settings file found. Preparing to remove default settings to prevent overwrite...

if not exist "%TEMP_SETTINGS%" (
    echo [ERROR] Could not find "ersc_settings.ini" in the extracted files.
    echo It looks like the mod author may have overhauled how the mod is distributed.
    echo Please seek further assistance or check for an updated script.
    call :CleanupTemp
    exit /b 1
)

del /f /q "%TEMP_SETTINGS%" 2>nul

if exist "%TEMP_SETTINGS%" (
    echo [ERROR] Permission denied! The script lacks permission to delete the file.
    echo Make sure the file isn't open in another program, or try running the script as Administrator.
    call :CleanupTemp
    exit /b 1
)

echo [SUCCESS] Default settings file successfully removed from temp folder.
exit /b 0

:MoveModFiles
echo.
echo Moving mod files into the Elden Ring directory...
set "GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\ELDEN RING\Game"

if not exist "%GAME_DIR%\" (
    echo [ERROR] Directory not found: "%GAME_DIR%"
    echo The base Elden Ring game does not appear to be installed in the default location.
    call :CleanupTemp
    exit /b 1
)

xcopy /E /Y /H "%TEMP_EXTRACT_DIR%\*" "%GAME_DIR%\" >nul 2>nul

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Permission denied! Could not move files to the game directory.
    echo Please ensure Elden Ring is completely closed and try running this script as Administrator.
    call :CleanupTemp
    exit /b 1
)

call :CleanupTemp

echo [SUCCESS] Mod files successfully integrated into your game!
exit /b 0

:CleanupTemp
echo Cleaning up temporary files to keep things tidy...
if exist "%TEMP_EXTRACT_DIR%\" (
    rd /s /q "%TEMP_EXTRACT_DIR%" 2>nul
)
exit /b 0