@echo off
cd src
echo Compilando...
..\bennu\bgdc -g pixdash.prg
move pixdash.dcb ..
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
copy fnt\*.fnt export\fnt
copy niveles\nivel*.png export\niveles
copy niveles\nivel*.ogg export\niveles
copy niveles\fondo*.png export\niveles
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