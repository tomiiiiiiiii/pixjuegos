@echo off
rd /s /q fpg
mkdir fpg
ECHO CREANDO FPGS...
cd fpg-sources
copy ..\..\utils\pxlfpg.dcb . /y
..\..\bennu-win\bgdi pxlfpg 32 bombas bosses enemigos explosiones menu nave
del /f pxlfpg.dcb