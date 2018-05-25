@echo off
cd "%~dp0\\src"
@echo Compiling MoonScript source files...
@echo.
moonc -t "..\dist\@Resources" "."
@echo.
@echo Successfully compiled source files!
