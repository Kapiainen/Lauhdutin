@echo off
cls
echo Downloading and parsing GOG community profile
cd "%~dp0"
set "profilejs="%cd%\profile.js""
cd ..\..\..\cache
if not exist "%cd%\gog_galaxy" mkdir "%cd%\gog_galaxy"
cd gog_galaxy
set "completed="%cd%\completed.txt""
if exist %completed% del %completed%
cd ..\..\
set "phantomjs="%cd%\phantomjs.exe""
start /B /W "" %phantomjs% %profilejs% %1
echo "" > %completed%
::pause
