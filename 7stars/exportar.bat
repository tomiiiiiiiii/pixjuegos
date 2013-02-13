@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc 7stars.prg
move 7stars.dcb ..
cd ..
echo Exportando...
mkdir export
mkdir export\fpg
mkdir export\ogg
mkdir export\fnt
mkdir export\niveles
mkdir export\wav
copy fpg\*.fpg export\fpg
copy ogg\*.ogg export\ogg
copy wav\*.wav export\wav
copy niveles\*.txt export\niveles
copy fnt\*.fnt export\fnt
copy ..\bennu-win\*.dll export
copy ..\bennu-win\bgdi.exe export\7stars.exe
copy 7stars.dcb export
cd export
echo DEBES ELEGIR EL 7stars.EXE
..\..\utils\pakator 
move 7stars_exe_pak.exe ..\
cd ..
echo LISTO!!
exit
pause