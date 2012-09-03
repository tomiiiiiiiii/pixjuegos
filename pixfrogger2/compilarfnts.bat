@echo off
mkdir fnt
ECHO COMPILANDO FNTS...
cd fnt-sources
copy ..\..\utils\pxlfnt.dcb . /y
..\..\bennu-win\bgdi pxlfnt 16 puntos-hd puntos-md puntos-ld
del /f pxlfnt.dcb
pause