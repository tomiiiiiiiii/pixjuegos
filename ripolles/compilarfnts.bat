@echo off
set bits=%1
if "%bits%"==""; set bits=32
mkdir fnt
ECHO COMPILANDO FNTS...
cd fnt-sources
copy ..\..\utils\pxlfnt.dcb . /y
..\..\bennu-win\bgdi pxlfnt %bits% tiempo
del /f pxlfnt.dcb
cd ..