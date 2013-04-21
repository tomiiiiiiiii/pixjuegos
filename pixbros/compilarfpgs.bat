@echo off
set bits=%1
if "%bits%"==""; set bits=32
REM call ..\scripts\compilarfpgs.bat %bits% enemigos general items jefes pax pix pux intro-de intro-en intro-es intro-fr intro-it intro-jp menu menu-de menu-en menu-es menu-fr menu-it menu-jp intro
call ..\scripts\compilarfpgs.bat %bits% enemigos general items jefes pax pix pux intro menu