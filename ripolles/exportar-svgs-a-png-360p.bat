@echo off
echo Creando ripolleses alternativos...
cd recursos\personajes
type Ripolles.svg | ..\..\..\utils\sed "s/ff7f2a/00af00/g" > ripolles2.svg
type Ripolles.svg | ..\..\..\utils\sed "s/ff7f2a/00afff/g" > ripolles3.svg
type Ripolles.svg | ..\..\..\utils\sed "s/ff7f2a/8d368f/g" > ripolles4.svg
cd ..\..

echo Eliminando fpg-sources
rd /s /q fpg-sources
mkdir fpg-sources
mkdir fpg-sources\ripolles1
mkdir fpg-sources\ripolles2
mkdir fpg-sources\ripolles3
mkdir fpg-sources\ripolles4
mkdir fpg-sources\pato
mkdir fpg-sources\enemigo1
mkdir fpg-sources\enemigo2
mkdir fpg-sources\enemigo3
mkdir fpg-sources\enemigo4
mkdir fpg-sources\enemigo5
mkdir fpg-sources\jefe1
mkdir fpg-sources\jefe2
mkdir fpg-sources\jefe3
mkdir fpg-sources\jefe4
mkdir fpg-sources\general
mkdir fpg-sources\objetos
mkdir fpg-sources\tiempo
mkdir fpg-sources\cat 
mkdir fpg-sources\es 
mkdir fpg-sources\en 
mkdir fpg-sources\menu 
mkdir fpg-sources\nivel1 
mkdir fpg-sources\nivel2
mkdir fpg-sources\nivel3
mkdir fpg-sources\nivel4
mkdir fpg-sources\nivel5 
mkdir fpg-sources\nivel_survival1 
mkdir fpg-sources\nivel_battleroyale1 
mkdir fpg-sources\nivel_matajefes1

echo Copiando bitmaps 360p...
xcopy /r/e/y recursos\bitmaps-360p fpg-sources

echo Exportamos gráficos SVG...
cd recursos\scripts-svg-360p
for /f %%f in ('dir /b *.bat') do start %%f &

echo COLOREAMOS FNT1
cd ..\..\fpg-sources\
mkdir fnt1azul
mkdir fnt1gris
mkdir fnt1rojo
cd fnt1
for /f %%f in ('dir /b *.png') do call :a %%f
for /f %%f in ('dir /b *.png') do call :b %%f
for /f %%f in ('dir /b *.png') do call :c %%f

goto :eof

:a
..\..\..\utils\imagemagick\convert %1 +level-colors blue,white png32:..\fnt1azul\%1
goto :eof

:b
..\..\..\utils\imagemagick\convert %1 +level-colors red,white png32:..\fnt1rojo\%1
goto :eof

:c
..\..\..\utils\imagemagick\convert %1 +level-colors rgb(100,100,100),white png32:..\fnt1gris\%1
goto :eof