@echo off
set bits=%1
if "%bits%"==""; set bits=32
call ..\scripts\compilarfpgs.bat %bits% pixfrogger-ouya pixfrogger-ouya-8players pixfrogger-hd pixfrogger-md pixfrogger-ld pixfrogger-hd-portrait pixfrogger-md-portrait pixfrogger-ld-portrait pixfrogger-ld-32players puntos-hd puntos-md puntos-ld textos-hd textos-md textos-ld