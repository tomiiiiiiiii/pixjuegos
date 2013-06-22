@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g -DDEBUG=1 pixdash.prg
move pixdash.dcb ..
pause
cd ..
..\bennu-win\bgdi pixdash.dcb
pause
exit