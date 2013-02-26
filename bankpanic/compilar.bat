@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g bp.prg
move bp.dcb ..
pause
cd ..
..\bennu-win\bgdi bp.dcb
pause
exit