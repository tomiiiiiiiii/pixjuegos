@echo off
mkdir fpg
cd src
echo Creamos FPGS...
REM ESTO DE DEBAJO NO TIENE QUE FALLAR...
..\bennu\bgdc -Ca pxlfpg.prg > null
..\bennu\bgdi pxlfpg
del pxlfpg.dcb /f
del null /f