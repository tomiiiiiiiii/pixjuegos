@echo off
cd src
bgdc -Ca -g pixbros.prg
move pixbros.dcb ..\
cd ..
pause
bgdi pixbros.dcb
pause