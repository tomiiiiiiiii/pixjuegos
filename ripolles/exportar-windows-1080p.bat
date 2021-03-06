@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -D GLOBAL_RESOLUTION=-3 ripolles.prg
move ripolles.dcb ..
cd ..

call compilarfpgs 32

echo Exportando...
mkdir export
mkdir export\fpg
mkdir export\ogg
mkdir export\fnt
mkdir export\wav
copy loading.png export\
copy loading2.png export\
copy fpg\*.fpg export\fpg
copy ogg\*.ogg export\ogg
copy wav\*.wav export\wav
copy fnt\*.fnt export\fnt
copy ..\bennu-win\*.dll export
copy ..\bennu-win\bgdi.exe export\ripolles.exe
copy ripolles.dcb export
cd export
echo DEBES ELEGIR EL ripolles.EXE
..\..\bennu-win\pakator 
move ripolles_exe_pak.exe ..\ripolles.exe
cd ..
echo LISTO!!
exit