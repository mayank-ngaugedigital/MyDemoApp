@echo off
setlocal enabledelayedexpansion

:: Navigate to repository folder
cd /d %~dp0

:: Get the list of modified and added files from Git
git diff --name-only HEAD~1 HEAD > changed_files.txt

:: Start creating package.xml
echo ^<?xml version="1.0" encoding="UTF-8"?^> > manifest/package.xml
echo ^<Package xmlns="http://soap.sforce.com/2006/04/metadata"^> >> manifest/package.xml

:: Loop through changed files and add them to package.xml
for /f "tokens=*" %%F in (changed_files.txt) do (
    set "filename=%%F"
    echo Adding: !filename!
    echo   ^<types^> >> manifest/package.xml
    echo     ^<members^>!filename!^</members^> >> manifest/package.xml
    echo     ^<name^>ApexClass^</name^> >> manifest/package.xml
    echo   ^</types^> >> manifest/package.xml
)

:: Close the XML file
echo   ^<version^>55.0^</version^> >> manifest/package.xml
echo ^</Package^> >> manifest/package.xml

:: Cleanup
del changed_files.txt

echo package.xml generated successfully!
exit /b 0
