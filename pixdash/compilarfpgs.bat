@echo off
set bits=%1
if "%bits%"==""; set bits=16
call ..\scripts\compilarfpgs.bat %bits% enemigos menu powerups pix pux pax pex moneda tiles tiles2 tiles3 tiles4 tiles5 premios general