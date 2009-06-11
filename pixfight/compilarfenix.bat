@echo off
cd src
..\fenix\fxc -g pixfight.prg
type ..\fenix\stdout.txt
move pixfight.dcb ..
pause
cd ..
.\fenix\fxi pixfight
pause