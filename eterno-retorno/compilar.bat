@echo off
cd src
..\..\bennu-win\bgdc -g eterno-retorno.prg
move eterno-retorno.dcb ..
cd ..
..\bennu-win\bgdi eterno-retorno.dcb
pause