@echo ============================= Running Python tests =============================
@python RunTests.py -b
@IF errorlevel 1 (
	@echo ============================= Failed Python tests ==============================
	@pause
	@exit /b %errorlevel%
)
::@echo ============================= Running Lua tests ================================
::@luac RunTests.lua
::@IF errorlevel 1 (
::	@echo ============================= Failed Lua tests =================================
::	@pause
::	@exit /b %errorlevel%
::)
@echo ============================= Passed all tests =================================
@pause