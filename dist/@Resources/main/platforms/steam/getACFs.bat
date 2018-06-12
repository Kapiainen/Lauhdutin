@echo off
cls
echo Getting the names of Steam's ACF files in %1
cd "%~dp0"
cd ..\..\..\cache
if not exist "%cd%\steam" mkdir "%cd%\steam"
if not exist "%cd%\steam_shortcuts" mkdir "%cd%\steam_shortcuts"
cd steam
set "output="%cd%\output.txt""
set "acfs="%~1appmanifest_*.acf""
for %%F in (%acfs%) do (
	echo %%~nF%%~xF >> %output%
)
set "rainmeter="%~2\Rainmeter.exe""
start /B "" %rainmeter% !CommandMeasure "Script" "OnGotACFs()" %3
::pause
