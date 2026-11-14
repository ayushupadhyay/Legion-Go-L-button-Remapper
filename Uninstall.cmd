@echo off
title Legion Go L button Remapper - Uninstall
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Setup.ps1" -Mode Uninstall
if errorlevel 1 pause
