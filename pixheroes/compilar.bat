@echo off
cd fpg-sources
REM bgdc -g -Ca pxlfpg.prg
REM bgdi pxlfpg tiles
cd ..
cd src
bgdc -g -Ca pixheroes.prg
move pixheroes.dcb ..\
cd ..
pause
bgdi pixheroes