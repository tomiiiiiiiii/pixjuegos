@echo off
echo Compilando...
cd src
..\..\bennu-win\bgdc pixfrogger-android.prg -g
move pixfrogger-android.dcb ..\main.dcb
pause
cd ..
..\bennu-win\bgdi main.dcb
pause