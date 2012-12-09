@echo off
echo Hacemos limpieza...
start /b /wait limpieza.bat > null
del /f null
echo Compilando...
start /b /wait compilar.bat
del /f null
echo Exportando...
mkdir pixfight-export
mkdir pixfight-export\fpg
mkdir pixfight-export\ogg
copy fpg\*.fpg pixfight-export\fpg
copy ogg\*.ogg pixfight-export\ogg
copy ..\bennu-win\*.dll pixfight-export
copy ..\bennu-win\bgdi.exe pixfight-export\pixfight.exe
copy pixfight.dcb pixfight-export
copy nivelmask.png pixfight-export
cd pixfight-export
echo DEBES ELEGIR EL PIXFIGHT.EXE
..\..\bennu-win\pakator 
move pixfight_exe_pak.exe ..\
cd ..
echo LISTO!!
exit