@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc pixdash.prg
move pixdash.dcb ..
cd ..
call compilarfpgs

echo Exportando...
mkdir export
mkdir export\fpg
mkdir export\ogg
mkdir export\fnt
mkdir export\wav
mkdir export\bin
mkdir export\fondos
mkdir export\niveles
copy fpg\*.fpg export\fpg
copy ogg\*.ogg export\ogg
copy wav\*.wav export\wav
copy fnt\*.fnt export\fnt
copy bin\*.dll export\bin
copy bin\*.exe export\bin
xcopy /r/e/y niveles export\niveles
rd /s /q export\niveles\test
copy ..\bennu-win\*.dll export
copy ..\bennu-win\bgdi.exe export\pixdash.exe
copy pixdash.dcb export
copy fondos\*.png export\fondos
copy fondos\*.jpg export\fondos
cd export
echo DEBES ELEGIR EL PIXDASH.EXE
..\..\bennu-win\pakator 
move pixdash_exe_pak.exe ..\
cd ..
echo LISTO!!
exit
pause