@echo off
rd /s /q pixfight-export
del /f pixfight_exe_pak.exe
mkdir pixfight-export
mkdir pixfight-export\fpg
mkdir pixfight-export\ogg
copy fpg\*.fpg pixfight-export\fpg
copy ogg\*.ogg pixfight-export\ogg
copy bennu\*.dll pixfight-export
copy bennu\bgdi.exe pixfight-export\pixfight.exe
copy pixfight.dcb pixfight-export
copy nivelmask.png pixfight-export
cd pixfight-export
echo DEBES ELEGIR EL EJECUTABLE PIXFIGHT.EXE
echo (este paso no se puede automatizar por ahora...)
..\bennu\pakator
move pixfight_exe_pak.exe ..\
cd ..
rd /s /q pixfight-export