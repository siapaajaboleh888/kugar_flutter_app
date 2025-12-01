@echo off
cd /d C:\Users\LENOVO\Herd\kugar_flutter_app
timeout /t 2 /nobreak
start chrome "http://localhost:55000"
flutter run -d chrome --web-port=55000 --no-devtools
