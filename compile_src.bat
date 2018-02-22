@echo off
cd "%~dp0\\src"
@echo -- MoonScript files in \src --
moonc -t "..\dist\@Resources" "."
