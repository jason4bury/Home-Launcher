@echo off
rem Starts the Home Launcher from source (no exe needed).
rem Bypasses the execution policy for this run only; nothing machine-wide changes.
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File "%~dp0src\Home-Launcher.ps1"
