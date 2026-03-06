@echo off

set /p MESSAGE=Enter commit message: 

if "%MESSAGE%"=="" set MESSAGE=update web app

echo.
echo Adding files...
git add .

echo.
echo Commiting...
git commit -m "%MESSAGE%"

echo.
echo Pushing to GitHub...
git push origin main

echo.
echo Building Flutter web...
flutter build web --release

echo.
echo Deploying to Firebase...
firebase deploy --only hosting

echo.
echo Done!

pause