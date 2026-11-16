@echo off
rem Home Launcher - double-click to start it.
rem Each time, this makes (or refreshes) the Home Launcher shortcut in this folder and in the Start menu,
rem then starts Home Launcher from it. After the first run you can use the shortcut, the Start menu or
rem a pinned taskbar button instead: they start Home Launcher without a console window.
rem The execution-policy bypass applies to Home Launcher's own run only; no Windows settings are changed.
rem If Home Launcher doesn't open, run   "Home Launcher.cmd" debug   to start it in this window and see any errors.
setlocal
set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if /i "%~1"=="debug" (
    "%PS%" -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0Home-Launcher.ps1"
    pause
    exit /b
)
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0New-HomeLauncherShortcut.ps1" -Launch
if errorlevel 1 pause
