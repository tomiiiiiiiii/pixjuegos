@echo off
echo Compilando...
..\bennu-win\bgdc -D FAKE_SOUND=1 main.prg
pause
..\bennu-win\bgdi main.dcb
pause
exit