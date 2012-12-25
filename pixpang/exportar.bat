@echo off
rd /s /q export
cd src
echo Compilando...
..\..\bennu-win\bgdc pixpang.prg
move pixpang.dcb ..
cd ..

call compilarfpgs 32

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
copy ogg\*.ogg export\ogg
copy ogg\monstruos\*.* export\ogg\monstruos
copy wav\*.wav export\wav
copy fnt\*.fnt export\fnt
copy tour\*.pang export\tour
copy fondos\*.png export\fondos
copy fondos\*.jpg export\fondos
copy fondos\monstruos\*.png export\fondos\monstruos
copy ..\bennu-win\*.dll export
copy ..\bennu-win\bgdi.exe export\pixpang.exe
copy pixpang.dcb export
cd export
echo DEBES ELEGIR EL PIXpang.EXE
..\..\utils\pakator 
move pixpang_exe_pak.exe ..\
cd ..
echo LISTO!!
exit
pause