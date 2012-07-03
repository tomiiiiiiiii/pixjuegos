@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc pixheroes.prg
move pixheroes.dcb ..
cd ..
echo Exportando...
mkdir export
mkdir export\fpg
mkdir export\mod
mkdir export\fnt
mkdir export\wav
copy *.png export\
copy fpg\*.fpg export\fpg
copy mod\*.it export\mod
copy wav\*.wav export\wav
copy fnt\*.fnt export\fnt
copy ..\bennu-win\*.dll export
copy ..\bennu-win\bgdi.exe export\pixheroes.exe
copy pixheroes.dcb export
cd export
echo DEBES ELEGIR EL PIXheroes.EXE
..\..\bennu-win\pakator 
move pixheroes_exe_pak.exe ..\pixheroes.exe
cd ..
rd /s /q export
echo LISTO!!
exit
pause