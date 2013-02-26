@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc pixfrogger.prg
move pixfrogger.dcb ..
cd ..

call compilarfpgs

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
copy ..\bennu-win\bgdi.exe export\pixfrogger.exe
copy pixfrogger.dcb export
cd export
echo DEBES ELEGIR EL PIXfrogger.EXE
..\..\bennu-win\pakator 
move pixfrogger_exe_pak.exe ..\pixfrogger.exe
cd ..
echo LISTO!!
exit
pause