@echo off
setlocal EnableExtensions

set "VERSION=%~1"
if "%VERSION%"=="" set "VERSION=Unreleased"

if not exist ".git" (
  echo [ERROR] Khong phai thu muc Git repository.
  exit /b 1
)

set "OUTPUT=RELEASE_NOTES.md"
set "RANGE="
for /f "delims=" %%T in ('git describe --tags --abbrev^=0 2^>nul') do set "LAST_TAG=%%T"
if defined LAST_TAG set "RANGE=%LAST_TAG%..HEAD"

>"%OUTPUT%" echo # Release Notes - %VERSION%
>>"%OUTPUT%" echo.
>>"%OUTPUT%" echo ## Changes
>>"%OUTPUT%" echo.

set "HAS_CHANGES="
for /f "delims=" %%C in ('git log --pretty^="- %%h %%s" %RANGE% 2^>nul') do (
  >>"%OUTPUT%" echo %%C
  set "HAS_CHANGES=1"
)
if not defined HAS_CHANGES >>"%OUTPUT%" echo - No commits found.

>>"%OUTPUT%" echo.
>>"%OUTPUT%" echo ## Files Changed
>>"%OUTPUT%" echo.

set "HAS_FILES="
if defined LAST_TAG (
  for /f "delims=" %%F in ('git diff --name-only %LAST_TAG%..HEAD 2^>nul') do (
    >>"%OUTPUT%" echo - %%F
    set "HAS_FILES=1"
  )
) else (
  for /f "delims=" %%F in ('git ls-files 2^>nul') do (
    >>"%OUTPUT%" echo - %%F
    set "HAS_FILES=1"
  )
)
if not defined HAS_FILES >>"%OUTPUT%" echo - No files found.

>>"%OUTPUT%" echo.
echo [OK] Da tao %OUTPUT% voi phien ban %VERSION%.
endlocal
exit /b 0
