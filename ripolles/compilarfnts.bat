@echo off
mkdir fnt
ECHO COMPILANDO FNTS...
cd fnt-sources
copy ..\..\utils\pxlfnt.dcb . /y
..\..\bennu-win\bgdi pxlfnt 32 tiempo
del /f pxlfnt.dcb
pause