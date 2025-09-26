@echo off
echo Starting SetupX Flutter Application...
echo.
echo SetupX - Windows Development Environment Setup Tool
echo Version: 1.0.0
echo Platform: Windows x64
echo.
echo Loading application...
echo.

REM Run the SetupX application
setupx.exe

REM Keep window open if there's an error
if %ERRORLEVEL% neq 0 (
    echo.
    echo Application exited with error code: %ERRORLEVEL%
    echo Press any key to close...
    pause >nul
)
