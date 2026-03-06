@echo off

git add .
git commit -m "update web app"
git push origin main
flutter build web --release
firebase deploy --only hosting

pause