@echo off
cls
echo Listing Steam user accounts found in %1
cd "%~dp0"
cd ..\..\..\cache
if not exist "%cd%\steam" mkdir "%cd%\steam"
if not exist "%cd%\steam_shortcuts" mkdir "%cd%\steam_shortcuts"
cd steam
set "users="%cd%\users.txt""
dir %1 /b /o:n /a:d > %users%
set "rainmeter="%~2\Rainmeter.exe""
start /B "" %rainmeter% !CommandMeasure "Script" "OnSteamUsersListed()" %3
::pause
