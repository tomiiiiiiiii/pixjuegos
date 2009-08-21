@echo off
cd src
echo Compilando...
..\bennu\bgdc -g pixdash.prg
move pixdash.dcb ..
pause
cd ..
bennu\bgdi pixdash.dcb

pause
exit