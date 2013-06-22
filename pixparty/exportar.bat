@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc pixparty.prg
move pixparty.dcb ..
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



copy ..\bennu-win\bgdi.exe export\pixparty.exe
copy pixparty.dcb export
cd export
echo DEBES ELEGIR EL pixparty.EXE
..\..\bennu-win\pakator 
move pixparty_exe_pak.exe ..\pixparty.exe
cd ..
rd /s /q export
echo LISTO!!
exit
pause