@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc borderpolice.prg
move borderpolice.dcb ..
cd ..
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
copy ..\bennu-win\bgdi.exe export\borderpolice.exe
copy borderpolice.dcb export
cd export
echo DEBES ELEGIR EL borderpolice.EXE
..\..\bennu-win\pakator 
move borderpolice_exe_pak.exe ..\borderpolice.exe
cd ..
echo LISTO!!
exit
pause