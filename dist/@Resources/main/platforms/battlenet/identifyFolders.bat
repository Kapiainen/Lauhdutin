@echo off
cls
echo Identifying Battle.net game folders in %1
cd "%~dp0"
cd ..\..\..\cache
if not exist "%cd%\battlenet" mkdir "%cd%\battlenet"
cd battlenet
set "output="%cd%\output.txt""
if exist %output% del %output%
echo BITS:%PROCESSOR_ARCHITECTURE% > %output%
dir %1 /b /o:n /a:d >> %output%
set "rainmeter="%~2\Rainmeter.exe""
start /B "" %rainmeter% !CommandMeasure "Script" "OnBattlenetIdentifiedFolders()" %3
::pause
