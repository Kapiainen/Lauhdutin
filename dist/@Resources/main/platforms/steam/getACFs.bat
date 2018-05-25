@echo off
cls
echo Getting the names of Steam's ACF files in %1
cd "%~dp0"
cd ..\..\..\cache
if not exist "%cd%\steam" mkdir "%cd%\steam"
if not exist "%cd%\steam_shortcuts" mkdir "%cd%\steam_shortcuts"
cd steam
set "completed="%cd%\completed.txt""
if exist %completed% del %completed%
set "output="%cd%\output.txt""
set "acfs="%~1appmanifest_*.acf""
for %%F in (%acfs%) do (
	echo %%~nF%%~xF >> %output%
)
echo "" > %completed%
::pause
