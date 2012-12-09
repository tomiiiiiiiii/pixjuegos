@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g bp.prg
move bp.dcb ..
cd ..
echo Exportando...
mkdir export
mkdir export\fpg
mkdir export\fnt
mkdir export\ogg
mkdir export\wav
copy fpg\*.fpg export\fpg
copy fnt\*.fnt export\fnt
copy ogg\*.ogg export\ogg
copy wav\*.wav export\wav
copy ..\bennu-win\*.dll export
copy ..\bennu-win\bgdi.exe export\bp.exe
copy bp.dcb export
cd export
echo DEBES ELEGIR EL bp.EXE
..\..\bennu-win\pakator 
move bp_exe_pak.exe ..\
cd ..
echo LISTO!!
exit
pause