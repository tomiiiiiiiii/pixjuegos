@echo off
cd src
..\..\bennu-win\bgdc -g eternoretorno.prg
move eternoretorno.dcb ..
cd ..
..\bennu-win\bgdi eternoretorno.dcb
pause