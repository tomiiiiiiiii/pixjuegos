@echo off
rd /s /q fpg
del /f *.dcb
cd src
del /f *.dcb
del /f cargar_fpgs.pr-
del /f personaje1.pr-
del /f personaje2.pr-
del /f personaje3.pr-
cd ..
rd /s /q pixfight-export
del /f pixfight_exe_pak.exe
exit