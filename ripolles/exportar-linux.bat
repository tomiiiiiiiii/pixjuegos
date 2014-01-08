@echo off
rd /s /q export
cd src
echo Compilando...
..\..\bennu-win\bgdc ripolles.prg
move ripolles.dcb ..
cd ..

call compilarfpgs 32

echo Exportando...
mkdir export
mkdir export\fpg
mkdir export\ogg
mkdir export\fnt
mkdir export\wav
copy loading.png export\
copy loading2.png export\
copy fpg\*.fpg export\fpg
copy ogg\*.ogg export\ogg
copy wav\*.wav export\wav
copy fnt\*.fnt export\fnt

mkdir export\lib
copy ..\bennu-linux\lib\* export\lib
copy ..\bennu-linux\bgdi export\bgdi
copy ..\bennu-linux\run.sh export\ripolles.sh
copy ripolles.dcb export\main.dcb

echo LISTO!!
exit