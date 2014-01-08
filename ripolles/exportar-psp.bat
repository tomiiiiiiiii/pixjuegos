@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc ripolles.prg
move ripolles.dcb ..
cd ..

call compilarfpgs 16

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
copy ..\bennu-psp\eboot.pbp export\
copy ripolles.dcb export\eboot.dcb
mkdir PSP
mkdir PSP\GAME
move export PSP\GAME\RIPOLLES
mkdir export
move PSP export
echo LISTO!!
exit