@echo off
setlocal enabledelayedexpansion

echo ^<?xml version="1.0" encoding="UTF-8"?^> > package.xml
echo ^<Package xmlns="http://soap.sforce.com/2006/04/metadata"^> >> package.xml

REM Get changed files
for /f "tokens=*" %%i in ('git diff --name-only origin/main HEAD') do (
    set "filePath=%%i"
    for %%a in (!filePath!) do set "fileName=%%~na"
    for %%a in (!filePath!) do set "metaType=%%~dpa"

    if "!metaType!"=="\force-app\main\default\classes\" (
        echo   ^<members^>!fileName!^</members^> >> package.xml
        echo   ^<name^>ApexClass^</name^> >> package.xml
    )
    
    if "!metaType!"=="\force-app\main\default\triggers\" (
        echo   ^<members^>!fileName!^</members^> >> package.xml
        echo   ^<name^>ApexTrigger^</name^> >> package.xml
    )
    
    if "!metaType!"=="\force-app\main\default\lwc\" (
        echo   ^<members^>!fileName!^</members^> >> package.xml
        echo   ^<name^>LightningComponentBundle^</name^> >> package.xml
    )
)

echo ^<version^>63.0^</version^> >> package.xml
echo ^</Package^> >> package.xml

echo Package.xml generated successfully!
