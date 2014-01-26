@echo off
cd src
..\..\bennu-win-old\bgdc -g eterno-retorno-7.prg
move eterno-retorno-7.dcb ..
cd ..
pause
..\bennu-win-old\bgdi eterno-retorno-7.dcb
pause