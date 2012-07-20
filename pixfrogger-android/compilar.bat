@echo off
echo Compilando...
REM ..\bennu-win\bgdc -D FAKE_SOUND=1 main.prg
..\bennu-win\bgdc main.prg
pause
..\bennu-win\bgdi main.dcb
pause
exit