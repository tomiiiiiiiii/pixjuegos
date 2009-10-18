@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g pixbros.prg
move pixbros.dcb ..
pause
cd ..
..\..\bennu-win\bgdi pixbros.dcb

pause
exit