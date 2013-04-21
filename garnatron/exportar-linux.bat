@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc garnatron.prg
move garnatron.dcb ..
cd ..

call compilarfpgs 32

echo Exportando...
mkdir export
mkdir export\fpg
mkdir export\ogg
mkdir export\fnt
mkdir export\wav
mkdir export\niveles
copy fpg\*.fpg export\fpg
copy ogg\*.ogg export\ogg
copy wav\*.wav export\wav
copy fnt\*.fnt export\fnt
copy niveles\*.csv export\niveles

mkdir export\lib
copy ..\bennu-linux\lib\* export\lib
copy ..\bennu-linux\bgdi export\bgdi
copy ..\bennu-linux\run.sh export\garnatron.sh
copy garnatron.dcb export\main.dcb

echo LISTO!!
exit