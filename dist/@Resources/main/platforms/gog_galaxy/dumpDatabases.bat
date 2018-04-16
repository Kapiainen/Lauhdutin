@echo off
cls
echo Dumping parts of the GOG Galaxy databases %1 and %2
cd "%~dp0"
cd ..\..\..\cache
if not exist "%cd%\gog_galaxy" mkdir "%cd%\gog_galaxy"
cd gog_galaxy
set "completed="%cd%\completed.txt""
if exist %completed% del %completed%
set "index="%cd%\index.txt""
if exist %index% del %index%
set "galaxy="%cd%\galaxy.txt""
if exist %galaxy% del %galaxy%
cd ..\..\
set "sqlite="%cd%\sqlite3.exe""
start /B "" %sqlite% %1 "select productId, localpath from Products;" > %index%
start /B "" %sqlite% %2 "select productId, title, images from LimitedDetails;" > %galaxy%
echo "" > %completed%
::pause
