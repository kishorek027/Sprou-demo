@echo off
echo Getting Facebook Key Hash...
echo.

set ANDROID_HOME=C:\Users\Kishore K\AppData\Local\Android\Sdk
set KEYTOOL=%ANDROID_HOME%\build-tools\34.0.0\keytool.exe
set KEYSTORE=%USERPROFILE%\.android\debug.keystore

echo Using keystore: %KEYSTORE%
echo.

"%KEYTOOL%" -exportcert -alias androiddebugkey -keystore "%KEYSTORE%" -storepass android -keypass android > temp_cert.der

echo Certificate exported. Converting to base64...

certutil -encode temp_cert.der temp_cert.b64 >nul

echo.
echo Your Facebook Key Hash is:
echo.

findstr /v "CERTIFICATE" temp_cert.b64 | findstr /v "-----"

echo.
echo Cleanup...
del temp_cert.der
del temp_cert.b64

echo Done!
pause 