@echo off
cls
echo Downloading and parsing GOG community profile
cd "%~dp0"
set "profilejs="%cd%\profile.js""
cd ..\..\..\cache
if not exist "%cd%\gog_galaxy" mkdir "%cd%\gog_galaxy"
cd gog_galaxy
cd ..\..\
set "phantomjs="%cd%\phantomjs.exe""
start /B /W "" %phantomjs% %profilejs% %1
set "rainmeter="%~2\Rainmeter.exe""
start /B "" %rainmeter% !CommandMeasure "Script" "OnDownloadedGOGCommunityProfile()" %3
::pause
