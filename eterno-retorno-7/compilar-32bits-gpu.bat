@echo off
cd src
..\..\bennu-win\bgdc eterno-retorno-7.prg
move eterno-retorno-7.dcb ..
cd ..
pause
..\bennu-win-gpu\bgdi eterno-retorno-7.dcb
pause