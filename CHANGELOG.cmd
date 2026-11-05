@echo off
setlocal EnableExtensions

if not exist ".git" (
  echo [ERROR] Khong phai thu muc Git repository.
  exit /b 1
)

set "VERSION=%~1"
if "%VERSION%"=="" set "VERSION=Unreleased"

for /f "delims=" %%D in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "TODAY=%%D"

set "RANGE="
for /f "delims=" %%T in ('git describe --tags --abbrev^=0 2^>nul') do set "LAST_TAG=%%T"
if defined LAST_TAG set "RANGE=%LAST_TAG%..HEAD"

set "TEMP_FILE=%TEMP%\changelog_%RANDOM%.tmp"
>"%TEMP_FILE%" echo # Changelog
>>"%TEMP_FILE%" echo.
>>"%TEMP_FILE%" echo ## [%VERSION%] - %TODAY%
>>"%TEMP_FILE%" echo.
>>"%TEMP_FILE%" echo ### Changes
>>"%TEMP_FILE%" echo.

set "HAS_CHANGES="
for /f "delims=" %%C in ('git log --pretty^="- %%h %%s" %RANGE% 2^>nul') do (
  >>"%TEMP_FILE%" echo %%C
  set "HAS_CHANGES=1"
)
if not defined HAS_CHANGES >>"%TEMP_FILE%" echo - No commits found.

if exist "CHANGELOG.md" (
  for %%S in (CHANGELOG.md) do if %%~zS GTR 0 (
    >>"%TEMP_FILE%" echo.
    type "CHANGELOG.md" >>"%TEMP_FILE%"
  )
)

move /y "%TEMP_FILE%" "CHANGELOG.md" >nul
if errorlevel 1 (
  echo [ERROR] Khong the ghi CHANGELOG.md.
  exit /b 1
)

echo [OK] Da cap nhat CHANGELOG.md voi phien ban %VERSION%.
endlocal
exit /b 0
