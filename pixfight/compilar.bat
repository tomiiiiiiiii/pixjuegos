@echo off
cd src
echo Creamos FPGS...
REM ESTO DE DEBAJO NO TIENE QUE FALLAR...
..\bennu\bgdc -Ca pxlfpg.prg > null
..\bennu\bgdi pxlfpg
del pxlfpg.dcb /f
del null /f
echo Compilamos...
..\bennu\bgdc -g pixfight.prg
move pixfight.dcb ..
pause
cd ..
Ejecutamos...
.\bennu\bgdi pixfight