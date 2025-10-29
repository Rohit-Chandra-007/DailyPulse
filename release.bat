@echo off
echo Building release APK...
flutter build apk --release

echo Renaming APK...
set VERSION=v1.0.0
copy build\app\outputs\flutter-apk\app-release.apk build\app\outputs\flutter-apk\DailyPulse-%VERSION%.apk

echo Creating GitHub release...
gh release create %VERSION% build\app\outputs\flutter-apk\DailyPulse-%VERSION%.apk --title "DailyPulse %VERSION%" --notes "Release notes here"

echo Done!

