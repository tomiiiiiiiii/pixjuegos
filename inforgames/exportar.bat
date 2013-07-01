@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc inforgames.prg
move inforgames.dcb ..
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
copy ..\bennu-win\bgdi.exe export\inforgames.exe
copy inforgames.dcb export
cd export
echo DEBES ELEGIR EL inforgames.EXE
..\..\bennu-win\pakator 
move inforgames_exe_pak.exe ..\inforgames.exe
cd ..
rd /s /q export
echo LISTO!!
exit
pause