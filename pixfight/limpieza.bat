@echo off
rd /s /q fpg
del /f *.dcb
cd src
del /f *.dcb
del /f cargar_fpgs.pr-
cd ..
rd /s /q pixfight-export
del /f pixfight_exe_pak.exe
exit