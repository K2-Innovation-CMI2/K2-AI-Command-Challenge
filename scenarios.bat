@echo OFF

setlocal

set CMODIR=C:\Program Files (x86)\Matrix Games\Command Modern Operations

echo %CMODIR%

if "%1"=="push" (
	REM robocopy does not copy the root folder!
	REM Name has to be specified manually :\
	robocopy cmo_challenge_scripts "%CMODIR%\Lua\cmo_challenge_scripts" /S
	robocopy cmo_challenge_scenarios "%CMODIR%\Scenarios\cmo_challenge_scenarios" /S
) else (
	if "%1"=="pull" (
		robocopy "%CMODIR%\Lua\cmo_challenge_scripts" cmo_challenge_scripts /S
		robocopy "%CMODIR%\Scenarios\cmo_challenge_scenarios" cmo_challenge_scenarios /S
	) else (
		echo %1 is an unrecognized command...
	)
)

endlocal 
@echo ON
