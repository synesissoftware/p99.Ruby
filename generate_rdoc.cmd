@ECHO OFF

REM ########################################################################
REM File:     generate_rdoc.cmd
REM
REM Purpose:  Generates documentation
REM
REM Created:  14th August 2026
REM Updated:  30th August 2026
REM
REM ########################################################################

SETLOCAL
SET "ProjectDir=%~dp0"
SET "ProjectNameFile=%~dp0.sis\project_name.txt"
SET "ProjectName="
IF EXIST "%ProjectNameFile%" FOR /F "usebackq tokens=* delims=" %%A IN ("%ProjectNameFile%") DO IF NOT DEFINED ProjectName SET "ProjectName=%%A"
IF "%ProjectName%"=="" SET "ProjectName=Ruby project"
SET "DocDir=%SIS_RDOC_DOC_DIR%"
IF "%DocDir%"=="" SET "DocDir=doc"
SET "RDocArgs="

:parse_args
IF "%~1"=="" GOTO parsed_args
IF /I "%~1"=="--help" GOTO show_help
IF /I "%~1"=="--pwd" GOTO use_pwd
SET "RDocArgs=%RDocArgs% "%~1""
GOTO next_arg

:use_pwd
SET "ProjectDir=%CD%"

:next_arg
SHIFT
GOTO parse_args

:show_help
IF EXIST "%~dp0.sis\script_info_lines.txt" TYPE "%~dp0.sis\script_info_lines.txt"
ECHO Generates RDoc documentation for %ProjectName%
ECHO.
ECHO %~nx0 [ ... flags/options ... ]
ECHO.
ECHO Flags/options:
ECHO.
ECHO     --pwd
ECHO         operates in the caller's current directory instead of the
ECHO         script's directory
ECHO.
ECHO     -C
ECHO     --coverage-report
ECHO         generates an RDoc coverage report and fails if the report is
ECHO         less than 100%% documented
ECHO.
ECHO     --help
ECHO         displays this help and terminates
ECHO.
ECHO Environment variables:
ECHO.
ECHO     SIS_RDOC_DOC_DIR
ECHO         sets the generated-document directory (default: doc)
EXIT /B 0

:parsed_args

PUSHD "%ProjectDir%" || (
  ECHO %~nx0: project directory "%ProjectDir%" not found 1>&2
  EXIT /B 1
)

IF EXIST "%DocDir%" RMDIR /S /Q "%DocDir%"
rdoc ^
  --title "%ProjectName% API Reference" ^
  --op "%DocDir%" ^
  -x build_gem.cmd ^
  -x build_gem.sh ^
  -x generate_rdoc.cmd ^
  -x generate_rdoc.sh ^
  -x run_all_unit_tests.sh ^
  -x .*\.gemspec ^
  -x .*\.gem ^
  -x .*\.md ^
  -x Gemfile ^
  -x LICENSE ^
  -x Rakefile ^
  -x doc/ ^
  -x docs/ ^
  -x examples/ ^
  -x gems/ ^
  -x old-gems/ ^
  -x test/performance/ ^
  -x test/scratch/ ^
  -x tc_.*\.rb ^
  -x ts_all.rb ^
  %RDocArgs%

SET "RDocResult=%ERRORLEVEL%"
POPD
ENDLOCAL & EXIT /B %RDocResult%
