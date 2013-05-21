@echo off
echo Eliminando fpg-sources
rd /s /q fpg-sources
mkdir fpg-sources
echo Copiando bitmaps 720p...
xcopy /r/e/y recursos\bitmaps-720p fpg-sources

echo Exportamos gráficos SVG...
cd recursos\scripts-svg-720p
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
..\..\..\utils\imagemagick\convert %1 +level-colors blue,white ..\fnt1azul\%1
goto :eof

:b
..\..\..\utils\imagemagick\convert %1 +level-colors red,white ..\fnt1rojo\%1
goto :eof

:c
..\..\..\utils\imagemagick\convert %1 +level-colors rgb(100,100,100),white ..\fnt1gris\%1
goto :eof