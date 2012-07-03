rem @echo off
set bits=%1
if "%bits%"==""; set bits=32
ECHO CREANDO FPGS...
cd fpg-sources
copy ..\..\utils\pxlfpg.dcb . /y
..\..\bennu-win\bgdi pxlfpg %bits% enemigos general items jefes pax pix pux
..\..\bennu-win\bgdi pxlfpg %bits% intro-de intro-en intro-es intro-fr intro-it intro-jp
..\..\bennu-win\bgdi pxlfpg %bits% menu menu-de menu-en menu-es menu-fr menu-it menu-jp
del /f pxlfpg.dcb
exit