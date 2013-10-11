@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc vilanet2013.prg
move vilanet2013.dcb ..
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
copy ..\bennu-win\bgdi.exe export\vilanet2013.exe
copy loading.png export
copy vilanet2013.dcb export
cd export
echo DEBES ELEGIR EL vilanet2013.EXE
..\..\bennu-win\pakator 
move vilanet2013_exe_pak.exe ..\vilanet2013.exe
cd ..
echo LISTO!!
exit
pause