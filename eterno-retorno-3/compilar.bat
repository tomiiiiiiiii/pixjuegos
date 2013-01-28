@echo off
cd src
..\..\bennu-win-old\bgdc -g eterno-retorno-3.prg
move eterno-retorno-3.dcb ..
cd ..
pause
..\bennu-win-old\bgdi eterno-retorno-3.dcb
pause