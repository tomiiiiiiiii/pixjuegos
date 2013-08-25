@echo off
IF NOT "%DPI1%."=="." goto :goon
REM GENERAL:
set DPI1=180
REM CUTSCENES:
set DPI2=360
REM JEFE5:
set DPI3=117
REM PUNTOS:
set DPI4=90

copy loading-720p.png loading.png /y

:goon

echo Creando ripolleses alternativos...
cd recursos\personajes
type Ripolles.svg | ..\..\..\utils\sed "s/ff7f2a/00af00/g" > ripolles2.svg
type Ripolles1bici.svg | ..\..\..\utils\sed "s/ff7f2a/00af00/g" > ripolles2bici.svg
type Ripolles.svg | ..\..\..\utils\sed "s/ff7f2a/00afff/g" > ripolles3.svg
type Ripolles1bici.svg | ..\..\..\utils\sed "s/ff7f2a/00afff/g" > ripolles3bici.svg
type Ripolles.svg | ..\..\..\utils\sed "s/ff7f2a/8d368f/g" > ripolles4.svg
type Ripolles1bici.svg | ..\..\..\utils\sed "s/ff7f2a/8d368f/g" > ripolles4bici.svg
cd ..\..

echo Creando fuentes de puntos de los jugadores
cd recursos\interfaz
type sistema.svg | ..\..\..\utils\sed "s/ffffff/ff7f2a/g" | ..\..\..\utils\sed "s/000000/ffffff/g" > puntos1.svg
type sistema.svg | ..\..\..\utils\sed "s/ffffff/00af00/g" | ..\..\..\utils\sed "s/000000/ffffff/g" > puntos2.svg
type sistema.svg | ..\..\..\utils\sed "s/ffffff/00afff/g" | ..\..\..\utils\sed "s/000000/ffffff/g" > puntos3.svg
type sistema.svg | ..\..\..\utils\sed "s/ffffff/8d368f/g" | ..\..\..\utils\sed "s/000000/ffffff/g" > puntos4.svg
cd ..\..

echo Eliminando fpg-sources
rd /s /q fpg-sources
mkdir fpg-sources
mkdir fpg-sources\ripolles1
mkdir fpg-sources\ripolles2
mkdir fpg-sources\ripolles3
mkdir fpg-sources\ripolles4
mkdir fpg-sources\ripolles1bici
mkdir fpg-sources\ripolles2bici
mkdir fpg-sources\ripolles3bici
mkdir fpg-sources\ripolles4bici
mkdir fpg-sources\pato
mkdir fpg-sources\patobici
mkdir fpg-sources\enemigo1
mkdir fpg-sources\enemigo2
mkdir fpg-sources\enemigo3
mkdir fpg-sources\enemigo4
mkdir fpg-sources\enemigo5
mkdir fpg-sources\enemigo6
mkdir fpg-sources\enemigo7
mkdir fpg-sources\vaca
mkdir fpg-sources\jefe1
mkdir fpg-sources\jefe2
mkdir fpg-sources\jefe3
mkdir fpg-sources\jefe4
mkdir fpg-sources\jefe5
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
mkdir fpg-sources\puntos1
mkdir fpg-sources\puntos2
mkdir fpg-sources\puntos3
mkdir fpg-sources\puntos4

echo Copiando bitmaps 720p...
xcopy /r/e/y recursos\bitmaps-720p fpg-sources

rem Si no exportamos a 720, redimensionamos esos bitmaps
IF "%DPI1%"=="180" goto :sigue
rem REDIMENSIÓN GRÁFICOS 1080 Y 720P: FUENTES Y OTROS
cd fpg-sources
for /f "delims=" %%i in ('dir /b') do call :redimensiona %%i
cd ..

:sigue
echo Exportamos gráficos SVG...
cd recursos\scripts-svg
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
cd ..\..

goto :eof


REM FUNCIONES:
:a
..\..\..\utils\imagemagick\convert %1 +level-colors blue,white png32:..\fnt1azul\%1
goto :eof

:b
..\..\..\utils\imagemagick\convert %1 +level-colors red,white png32:..\fnt1rojo\%1
goto :eof

:c
..\..\..\utils\imagemagick\convert %1 +level-colors rgb(100,100,100),white png32:..\fnt1gris\%1
goto :eof

:redimensiona
cd %1
echo Redimensionando %1...
IF "%DPI1%"=="90" for /f "delims=" %%j in ('dir /b *.png') do ..\..\..\utils\imagemagick\convert %%j -resize 50%% png32:%%j
IF "%DPI1%"=="270" for /f "delims=" %%j in ('dir /b *.png') do ..\..\..\utils\imagemagick\convert %%j -resize 150%% png32:%%j
cd ..
goto :eof