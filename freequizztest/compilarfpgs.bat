@echo off
mkdir fpg
ECHO CREANDO FPGS...
cd fpg-sources
copy ..\..\utils\pxlfpg.dcb . /y
..\..\bennu-win\bgdi pxlfpg 32 quizz
del /f pxlfpg.dcb
pause