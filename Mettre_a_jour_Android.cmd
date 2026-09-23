@echo off
setlocal
cd /d "%~dp0"
echo Alambik - creation d'une mise a jour Android sans effacer les sauvegardes
python tools\android_mises_a_jour.py exporter --cible test %*
set "RESULTAT=%ERRORLEVEL%"
if not "%RESULTAT%"=="0" goto fin
echo.
echo Envoyer Alambic.apk au telephone et l'ouvrir.
echo Ne pas desinstaller la version precedente.
:fin
echo.
pause
exit /b %RESULTAT%
