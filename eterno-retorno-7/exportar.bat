@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc eterno-retorno-7.prg
move eterno-retorno-7.dcb ..
cd ..

echo Exportando...
mkdir export
mkdir export\fpg
mkdir export\ogg
mkdir export\fnt
mkdir export\wav

call compilarfpgs.bat 16

copy fpg\*.fpg export\fpg
copy ogg\*.ogg export\ogg
copy wav\*.wav export\wav
copy fnt\*.fnt export\fnt

copy ..\bennu-win\*.dll export
copy ..\bennu-win\bgdi.exe export\eterno-retorno-7.exe

copy eterno-retorno-7.dcb export
cd export
echo DEBES ELEGIR EL eterno-retorno-7.EXE
..\..\bennu-win\pakator 
move eterno-retorno-7_exe_pak.exe ..\eterno-retorno.exe
cd ..
echo LISTO!!
exit
pause