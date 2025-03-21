@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

echo ^<?xml version="1.0" encoding="UTF-8"?^> > package.xml
echo ^<Package xmlns="http://soap.sforce.com/2006/04/metadata"^> >> package.xml

REM Initialize empty variables
set "apexClasses="
set "apexTriggers="
set "lightningComponents="

REM Get only changed files
for /f "tokens=*" %%i in ('git diff --name-only HEAD^ HEAD') do (
    set "filePath=%%i"
    
    REM Extract filename without extension
    for %%a in (!filePath!) do set "fileName=%%~na"

    REM Check for Apex Classes
    echo !filePath! | findstr /I /C:"force-app\main\default\classes\" >nul && (
        set "apexClasses=!apexClasses!   ^<members^>!fileName!^</members^> & echo Class: !fileName!"
    )

    REM Check for Apex Triggers
    echo !filePath! | findstr /I /C:"force-app\main\default\triggers\" >nul && (
        set "apexTriggers=!apexTriggers!   ^<members^>!fileName!^</members^> & echo Trigger: !fileName!"
    )

    REM Check for Lightning Web Components
    echo !filePath! | findstr /I /C:"force-app\main\default\lwc\" >nul && (
        set "lightningComponents=!lightningComponents!   ^<members^>!fileName!^</members^> & echo LWC: !fileName!"
    )
)

REM Write only changed files into package.xml
if defined apexClasses (
    echo !apexClasses! >> package.xml
    echo   ^<name^>ApexClass^</name^> >> package.xml
)

if defined apexTriggers (
    echo !apexTriggers! >> package.xml
    echo   ^<name^>ApexTrigger^</name^> >> package.xml
)

if defined lightningComponents (
    echo !lightningComponents! >> package.xml
    echo   ^<name^>LightningComponentBundle^</name^> >> package.xml
)

echo ^<version^>63.0^</version^> >> package.xml
echo ^</Package^> >> package.xml

echo Package.xml generated successfully with changed files only!
ENDLOCAL
