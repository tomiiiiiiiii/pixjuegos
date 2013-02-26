@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc eterno-retorno.prg
move eterno-retorno.dcb ..
cd ..

call compilarfpgs 16

echo Exportando...
mkdir export
mkdir export\fpg
mkdir export\ogg
mkdir export\fnt
mkdir export\wav

copy fpg\*.fpg export\fpg
copy ogg\*.ogg export\ogg
copy wav\*.wav export\wav
copy fnt\*.fnt export\fnt

copy ..\bennu-win\*.dll export
copy ..\bennu-win\bgdi.exe export\eterno-retorno.exe

copy eterno-retorno.dcb export
echo LISTO!!
exit