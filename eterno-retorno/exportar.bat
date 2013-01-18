@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc juego.prg
move juego.dcb ..
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
copy ..\bennu-win\bgdi.exe export\juego.exe

copy juego.dcb export
cd export
echo DEBES ELEGIR EL juego.EXE
..\..\bennu-win\pakator 
move juego_exe_pak.exe ..\eterno-retorno.exe
cd ..
echo LISTO!!
exit
pause