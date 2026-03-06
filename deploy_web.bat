@echo off

set /p MESSAGE=Enter commit message: 

if "%MESSAGE%"=="" set MESSAGE=update web app

echo.
echo Adding files...
git add .

echo.
echo Committing...
git commit -m "%MESSAGE%"

echo.
echo Pushing to GitHub...
git push origin main

echo.
echo Building Flutter web...
call flutter build web --release

echo.
echo Deploying to Firebase Hosting...
call firebase deploy --only hosting

echo.
echo Done!

pause