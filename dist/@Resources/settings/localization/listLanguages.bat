@echo off
cls
echo Listing languages that are available
cd "%~dp0"
cd ..\..
if not exist "%cd%\Shortcuts" mkdir "%cd%\Shortcuts"
if not exist "%cd%\cache" mkdir "%cd%\cache"
cd cache
if not exist "%cd%\custom" mkdir "%cd%\custom"
set "output="%cd%\languages.txt""
cd ..\Languages
dir /a:-d /o:n /b > %output%
::pause
