@echo off
cd fpg-sources
bgdc -g -Ca pxlfpg.prg
bgdi pxlfpg pixfrogger
cd ..
cd src
bgdc -g -Ca pixfrogger.prg
move pixfrogger.dcb ..\
cd ..
pause
bgdi pixfrogger