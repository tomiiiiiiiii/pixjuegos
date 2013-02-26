@echo off
set bits=%1
if "%bits%"==""; set bits=32
call ..\scripts\compilarfpgs.bat %bits% pixfrogger-hd pixfrogger-md pixfrogger-ld pixfrogger-hd-portrait pixfrogger-md-portrait pixfrogger-ld-portrait pixfrogger-ld-32players