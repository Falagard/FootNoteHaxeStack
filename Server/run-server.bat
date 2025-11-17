@echo off
echo Starting Server...
echo.

REM Check if the executable exists
if not exist "Export\hl\bin\HaxeStackStarterServer.exe" (
    echo Error: HaxeStackStarterServer.exe not found!
    echo Please build the project first using: lime build hl
    pause
    exit /b 1
)

REM Change to the Export/hl/bin directory
cd Export\hl\bin

REM Run the server
echo Server running at http://127.0.0.1:8000
echo Press Ctrl+C to stop the server
echo.
HaxeStackStarterServer.exe

REM If the server exits, pause so we can see any error messages
pause
