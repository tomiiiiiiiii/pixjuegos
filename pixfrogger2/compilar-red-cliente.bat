@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc client.prg
move client.dcb ..
pause
cd ..
..\bennu-win\bgdi client.dcb

pause
exit