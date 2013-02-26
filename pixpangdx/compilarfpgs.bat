@echo off
set bits=%1
if "%bits%"==""; set bits=32
call ..\scripts\compilarfpgs.bat %bits% pixpang antuan carles danigm1 danigm2 gaucho mafrune oldpix oldpux pix pux xmaspix xmaspux