@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g dx.prg
move dx.dcb ..
cd ..
echo Exportando...
mkdir export
mkdir export\fpg
mkdir export\fpg\personajes
mkdir export\fnt
mkdir export\niveles
copy fpg\*.fpg export\fpg
copy fpg\personajes\*.fpg export\fpg\personajes
copy fnt\*.fnt export\fnt
copy niveles\*.pang export\niveles
copy ..\bennu-win\*.dll export
copy ..\bennu-win\bgdi.exe export\dx.exe
copy dx.dcb export
cd export
echo DEBES ELEGIR EL dx.EXE
..\..\bennu-win\pakator 
move dx_exe_pak.exe ..\
cd ..
echo LISTO!!
exit
pause