@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g dx.prg
move dx.dcb ..
cd ..
echo Exportando...
mkdir export
mkdir export\fpg
mkdir export\fnt
copy fpg\*.fpg export\fpg
copy fnt\*.fnt export\fnt
copy ..\bennu-win\*.dll export
copy ..\bennu-win\bgdi.exe export\dx.exe
copy dx.dcb export
cd export
echo DEBES ELEGIR EL dx.EXE
..\..\bennu-win\pakator 
move dx_exe_pak.exe ..\
cd ..
rd /s /q export
echo LISTO!!
exit
pause