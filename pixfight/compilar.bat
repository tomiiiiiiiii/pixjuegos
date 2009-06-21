@echo off
cd src
echo Compilamos...
..\bennu\bgdc -g pixfight.prg
move pixfight.dcb ..
pause
cd ..
echo Ejecutamos...
.\bennu\bgdi pixfight
pause