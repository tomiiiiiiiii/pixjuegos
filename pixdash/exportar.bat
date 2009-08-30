@echo off
cd src
echo Compilando...
..\bennu\bgdc pixdash.prg
move pixdash.dcb ..
cd ..
echo Exportando...
mkdir export
mkdir export\fpg
mkdir export\ogg
mkdir export\fnt
mkdir export\niveles
mkdir export\wav
mkdir export\bin
copy fpg\*.fpg export\fpg
copy ogg\*.ogg export\ogg
copy wav\*.wav export\wav
copy fnt\*.fnt export\fnt
copy bin\*.dll export\bin
copy bin\*.exe export\bin
copy bennu\*.dll export
copy bennu\bgdi.exe export\pixdash.exe
copy pixdash.dcb export
cd export
echo DEBES ELEGIR EL PIXDASH.EXE
..\bennu\pakator 
move pixdash_exe_pak.exe ..\
cd ..
rd /s /q export
echo LISTO!!
exit
pause