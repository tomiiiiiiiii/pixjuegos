@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc vilanet.prg
move vilanet.dcb ..
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
copy ..\bennu-win\bgdi.exe export\vilanet.exe
copy vilanet.dcb export
cd export
echo DEBES ELEGIR EL vilanet.EXE
..\..\bennu-win\pakator 
move vilanet_exe_pak.exe ..\vilanet.exe
cd ..
rd /s /q export
echo LISTO!!
exit
pause