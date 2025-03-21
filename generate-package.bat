@echo off
setlocal enabledelayedexpansion

:: Navigate to repository folder
cd /d %~dp0

:: Define output file paths
set "PACKAGE_FILE=manifest/package.xml"
set "CHANGED_FILES=changed_files.txt"

:: Get the list of modified and added files from Git
git diff --name-only HEAD~1 HEAD > %CHANGED_FILES%

:: Initialize metadata categories
set "APEX_CLASSES="
set "APEX_TRIGGERS="
set "VISUALFORCE_PAGES="
set "LIGHTNING_COMPONENTS="
set "OBJECTS="
set "LAYOUTS="
set "PROFILES="
set "PERMISSIONS="

:: Loop through changed files and categorize
for /f "tokens=*" %%F in (%CHANGED_FILES%) do (
    set "filename=%%F"
    echo Processing: !filename!

    :: Classify by file extension
    if "!filename:~-3!" == ".cls" set "APEX_CLASSES=!APEX_CLASSES!      <members>%%~nF</members>\n"
    if "!filename:~-3!" == ".trigger" set "APEX_TRIGGERS=!APEX_TRIGGERS!      <members>%%~nF</members>\n"
    if "!filename:~-3!" == ".page" set "VISUALFORCE_PAGES=!VISUALFORCE_PAGES!      <members>%%~nF</members>\n"
    if "!filename:~-3!" == ".cmp" set "LIGHTNING_COMPONENTS=!LIGHTNING_COMPONENTS!      <members>%%~nF</members>\n"
    if "!filename:~-3!" == ".object" set "OBJECTS=!OBJECTS!      <members>%%~nF</members>\n"
    if "!filename:~-3!" == ".layout" set "LAYOUTS=!LAYOUTS!      <members>%%~nF</members>\n"
    if "!filename:~-3!" == ".profile" set "PROFILES=!PROFILES!      <members>%%~nF</members>\n"
    if "!filename:~-3!" == ".permissionset" set "PERMISSIONS=!PERMISSIONS!      <members>%%~nF</members>\n"
)

:: Start creating package.xml
(
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<Package xmlns="http://soap.sforce.com/2006/04/metadata"^>

if defined APEX_CLASSES (
    echo   ^<types^>
    echo !APEX_CLASSES!
    echo     ^<name^>ApexClass^</name^>
    echo   ^</types^>
)

if defined APEX_TRIGGERS (
    echo   ^<types^>
    echo !APEX_TRIGGERS!
    echo     ^<name^>ApexTrigger^</name^>
    echo   ^</types^>
)

if defined VISUALFORCE_PAGES (
    echo   ^<types^>
    echo !VISUALFORCE_PAGES!
    echo     ^<name^>ApexPage^</name^>
    echo   ^</types^>
)

if defined LIGHTNING_COMPONENTS (
    echo   ^<types^>
    echo !LIGHTNING_COMPONENTS!
    echo     ^<name^>LightningComponentBundle^</name^>
    echo   ^</types^>
)

if defined OBJECTS (
    echo   ^<types^>
    echo !OBJECTS!
    echo     ^<name^>CustomObject^</name^>
    echo   ^</types^>
)

if defined LAYOUTS (
    echo   ^<types^>
    echo !LAYOUTS!
    echo     ^<name^>Layout^</name^>
    echo   ^</types^>
)

if defined PROFILES (
    echo   ^<types^>
    echo !PROFILES!
    echo     ^<name^>Profile^</name^>
    echo   ^</types^>
)

if defined PERMISSIONS (
    echo   ^<types^>
    echo !PERMISSIONS!
    echo     ^<name^>PermissionSet^</name^>
    echo   ^</types^>
)

echo   ^<version^>55.0^</version^>
echo ^</Package^>
) > %PACKAGE_FILE%

:: Cleanup
del %CHANGED_FILES%

echo package.xml generated successfully!
exit /b 0
