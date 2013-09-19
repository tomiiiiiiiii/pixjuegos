@echo off

if not exist fpg-sources\pato1\1.png goto :nopngs

set bits=%1
if "%bits%"==""; set bits=32
call ..\scripts\compilarfpgs.bat %bits% enemigo1 enemigo2 enemigo3 enemigo4 enemigo5 enemigo6 enemigo7 vaca 
call ..\scripts\compilarfpgs.bat %bits% fnt1 fnt1azul fnt1rojo fnt1gris puntos1 puntos2 puntos3 puntos4 tiempo 
call ..\scripts\compilarfpgs.bat %bits% general objetos menu cat es en
call ..\scripts\compilarfpgs.bat %bits% ruzafa1 ruzafa2 ruzafa3 ruzafa4 ruzafa1bici ruzafa2bici ruzafa3bici ruzafa4bici
call ..\scripts\compilarfpgs.bat %bits% pato1 pato2 pato3 pato4 pato1bici pato2bici pato3bici pato4bici
set bits=16
call ..\scripts\compilarfpgs.bat %bits% cutscenes jefe1 jefe2 jefe3 jefe4 jefe5 nivel1 nivel2 nivel3 nivel4 nivel5 nivel_survival1 nivel_battleroyale1 nivel_matajefes1 fondo_menu

goto :eof

:nopngs
echo Es necesario exportar los PNGs antes de compilar FPGs. 
echo Ejecuta exportar-svgs 360 o 720 y luego vuelve a compilarfpgs.
pause
exit