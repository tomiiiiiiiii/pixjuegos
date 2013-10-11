@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -D DEBUG=1 -g pixbros.prg
move pixbros.dcb ..
pause
cd ..
..\bennu-win\bgdi pixbros.dcb

pause
exit