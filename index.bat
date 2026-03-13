@echo off
:: ==========================================
:: CONFIGURATION
:: ==========================================
:: Set to 1 to show console output and require key presses. 
:: Set to 0 for silent background execution.
set DEBUG_MODE=0

:: ==========================================
:: INITIALIZATION & SANITIZATION
:: ==========================================
set FILE_COUNT=%~1
set FILE_SIZE=%~2
set CONTENT_PATH=%~3
set FILE_EXT=%~x3
set MY_DEVICE=%MY_ADB_DEVICE%

:: Initial Debug Output
if "%DEBUG_MODE%"=="0" goto :SkipDebugOutput
    echo --- AUTO-PUSH SCRIPT STARTED ---
    echo File Count : [%FILE_COUNT%]
    echo File Size  : [%FILE_SIZE%]
    echo Content Path : [%CONTENT_PATH%]
    echo Extension  : [%FILE_EXT%]
    echo Device ID  : [%MY_DEVICE%]
    echo.
    pause

:SkipDebugOutput
:: ==========================================
:: PRE-FLIGHT CHECKS
:: ==========================================
if "%MY_DEVICE%"=="" (
    if "%DEBUG_MODE%"=="1" echo [ERROR] MY_ADB_DEVICE environment variable is not set. & pause
    exit /b
)

if "%FILE_COUNT%" NEQ "1" (
    if "%DEBUG_MODE%"=="1" echo [SKIP] Multiple files detected. & pause
    exit /b
)

if /I "%FILE_EXT%" NEQ ".mkv" (
    if "%DEBUG_MODE%"=="1" echo [SKIP] Not an MKV file. & pause
    exit /b
)

:: ==========================================
:: ADB CONNECTION CHECK
:: ==========================================
if "%DEBUG_MODE%"=="1" echo [STEP 1] Checking ADB natively for device %MY_DEVICE%...

set "DEVICE_FOUND=0"
for /f "skip=1 tokens=1,2" %%A in ('adb devices') do (
    if "%%A"=="%MY_DEVICE%" (
        if "%%B"=="device" set "DEVICE_FOUND=1"
    )
)

if "%DEVICE_FOUND%"=="0" (
    if "%DEBUG_MODE%"=="1" echo [ERROR] ADB check failed! Device not found or offline. & pause
    exit /b
)
if "%DEBUG_MODE%"=="1" echo [SUCCESS] Device confirmed! & echo.

:: ==========================================
:: FILE SIZE CHECK (2GB LIMIT)
:: ==========================================
if "%DEBUG_MODE%"=="1" echo [STEP 2] Verifying file size...

set "SIZE_STR=0000000000000000%FILE_SIZE%"
set "SIZE_STR=%SIZE_STR:~-15%"
set "MAX_SIZE=000002147483648"

if "X%SIZE_STR%" GEQ "X%MAX_SIZE%" (
    if "%DEBUG_MODE%"=="1" echo [ERROR] File is 2GB or larger. & pause
    exit /b
)
if "%DEBUG_MODE%"=="1" echo [SUCCESS] File size is acceptable. & echo.

:: ==========================================
:: EXECUTION
:: ==========================================
if "%DEBUG_MODE%"=="1" echo [STEP 3] Pushing file to %MY_DEVICE%... & pause

:: Push the file silently (unless adb throws its own error)
adb -s %MY_DEVICE% push "%CONTENT_PATH%" "/storage/emulated/0/Download/Quick Share"

:: Evaluate final result
if %errorlevel% equ 0 (
    if "%DEBUG_MODE%"=="1" echo. & echo [SUCCESS] File transferred to phone! & pause
) else (
    if "%DEBUG_MODE%"=="1" echo. & echo [ERROR] ADB transfer failed. Check your cable connection. & pause
)