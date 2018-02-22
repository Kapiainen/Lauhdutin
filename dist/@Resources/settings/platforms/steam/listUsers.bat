@echo off
cls
cd "%~dp0"
cd ..\..\..\cache
if not exist "%cd%\steam" mkdir "%cd%\steam"
if not exist "%cd%\steam_shortcuts" mkdir "%cd%\steam_shortcuts"
cd steam
set "completed=%cd%\completed.txt"
if exist %completed% del %completed%
set "users=%cd%\users.txt"
dir %1 /b /o:n /a:d > %users%
echo "" > %completed%
::pause
