@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc garnatron.prg
move garnatron.dcb ..
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
copy ..\bennu-win\bgdi.exe export\garnatron.exe
copy garnatron.dcb export
cd export
echo DEBES ELEGIR EL garnatron.EXE
..\..\bennu-win\pakator 
move garnatron_exe_pak.exe ..\
cd ..
echo LISTO!!
exit
pause