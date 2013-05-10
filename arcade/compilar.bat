@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc arcade.prg
move arcade.dcb ..
pause
cd ..
..\bennu-win\bgdi arcade.dcb

pause
exit