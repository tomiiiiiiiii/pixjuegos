@echo off
cd src
..\bennu\bgdc -g pixfight.prg
move pixfight.dcb ..
pause
cd ..
.\bennu\bgdi pixfight
pause