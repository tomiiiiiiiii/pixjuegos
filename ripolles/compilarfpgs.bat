@echo off

if not exist fpg-sources\cutscenes\84.png goto :nopngs

set bits=%1
if "%bits%"==""; set bits=32
call ..\scripts\compilarfpgs.bat %bits% enemigo1 enemigo2 enemigo3 enemigo4 enemigo5 enemigo6 enemigo7 jefe2 jefe4 general objetos menu
call ..\scripts\compilarfpgs.bat %bits% ripolles1 ripolles2 ripolles3 ripolles4 pato fnt1 fnt1azul fnt1rojo fnt1gris tiempo cat es en
call ..\scripts\compilarfpgs.bat %bits% ripolles1bici ripolles2bici ripolles3bici ripolles4bici 

set bits=16
call ..\scripts\compilarfpgs.bat %bits% cutscenes jefe1 nivel1 nivel3 nivel3 nivel4 nivel5 nivel_survival1 nivel_battleroyale1 nivel_matajefes1 fondo_menu

goto :eof

:nopngs
echo Es necesario exportar los PNGs antes de compilar FPGs. 
echo Ejecuta exportar-svgs 360 o 720 y luego vuelve a compilarfpgs.
pause
exit