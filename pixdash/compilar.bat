@echo off
cd src
echo Compilando...
..\bennu\bgdc -g pixdash.prg
move pixdash.dcb ..
pause
cd ..
bgdi pixdash.dcb

pause
exit