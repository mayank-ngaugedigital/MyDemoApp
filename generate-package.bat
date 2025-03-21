 @echo off
SETLOCAL ENABLEDELAYEDEXPANSION

echo ^<?xml version="1.0" encoding="UTF-8"?^> > package.xml
echo ^<Package xmlns="http://soap.sforce.com/2006/04/metadata"^> >> package.xml

REM Get changed files using git show --name-only
for /f "tokens=*" %%i in ('git show --name-only --pretty^=') do (
    set "filePath=%%i"
    set "fileName=%%~ni"
    set "metaType=%%~dpi"

    if /i "!metaType!"=="\force-app\main\default\classes\" (
        echo   ^<members^>!fileName!^</members^> >> package.xml
        echo   ^<name^>ApexClass^</name^> >> package.xml
    )
    
    if /i "!metaType!"=="\force-app\main\default\triggers\" (
        echo   ^<members^>!fileName!^</members^> >> package.xml
        echo   ^<name^>ApexTrigger^</name^> >> package.xml
    )

    if /i "!metaType!"=="\force-app\main\default\lwc\" (
        echo   ^<members^>!fileName!^</members^> >> package.xml
        echo   ^<name^>LightningComponentBundle^</name^> >> package.xml
    )
)

echo ^<version^>63.0^</version^> >> package.xml
echo ^</Package^> >> package.xml

echo Package.xml generated successfully!
ENDLOCAL
