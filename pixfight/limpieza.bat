@echo off
rd /s /q fpg
cd ..
del /f *.dcb
cd src
del /f *.dcb
cd ..
rd /s /q pixfight-export
del /f pixfight_exe_pak.exe