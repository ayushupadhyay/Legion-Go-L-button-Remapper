@echo off
title Legion Go L button Remapper - Setup
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Setup.ps1" -Mode Install
if errorlevel 1 pause
