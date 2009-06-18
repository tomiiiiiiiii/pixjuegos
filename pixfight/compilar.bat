@echo off
echo LIMPIEZA...
cd fpg
del /f *.fpg
cd ..
del /f *.dcb
cd src
del /f *.dcb
cd ..

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