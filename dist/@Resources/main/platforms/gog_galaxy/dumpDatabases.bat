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
:: index.db has been removed and the data has been moved into galaxy.db.
:: This is just to support the scenarios where the client has not been
:: updated and where the client has been updated.
if exist %1 (
	start /B "" %sqlite% %1 "select productId, localpath from Products;" > %index%
) else (
	start /B "" %sqlite% %2 "select productId, installationPath from InstalledBaseProducts;" > %index%
)
start /B "" %sqlite% %2 "select productId, title, images, links from LimitedDetails;" > %galaxy%
echo "" > %completed%
::pause
