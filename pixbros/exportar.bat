@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc pixbros.prg
move pixbros.dcb ..
cd ..
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
copy niveles\*.png export\niveles
copy niveles\*.lvl export\niveles
copy ..\bennu-win\*.dll export
copy ..\bennu-win\bgdi.exe export\pixbros.exe
copy pixbros.dcb export
cd export
echo DEBES ELEGIR EL PIXbros.EXE
..\..\bennu-win\pakator 
move pixbros_exe_pak.exe ..\
cd ..
rd /s /q export
echo LISTO!!
exit
pause