@echo off
cd src
bgdc -Ca -g pixpang.prg
move pixpang.dcb ..\
cd ..
pause
bgdi pixpang.dcb
pause