@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc pixpang.prg
move pixpang.dcb ..
cd ..
echo Exportando...
mkdir export
mkdir export\fpg
mkdir export\ogg
mkdir export\ogg\monstruos
mkdir export\fnt
mkdir export\wav
mkdir export\tour
mkdir export\fondos
mkdir export\fondos\monstruos
copy fpg\*.fpg export\fpg
copy ogg\*.wav export\ogg
copy ogg\monstruos\*.* export\ogg\monstruos
copy wav\*.wav export\wav
copy fnt\*.fnt export\fnt
copy tour\*.pang export\tour
copy fondos\*.png export\fondos
copy fondos\monstruos\*.png export\fondos\monstruos
copy pixpang.dcb export
cd export
move export caanoo
echo LISTO!!
exit
pause