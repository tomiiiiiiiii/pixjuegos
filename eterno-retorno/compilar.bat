@echo off
cd src
..\..\bennu-win\bgdc -g juego.prg
move juego.dcb ..
cd ..
..\bennu-win\bgdi juego.dcb
pause