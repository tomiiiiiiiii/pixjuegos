rem @echo off
set bits=%1
if "%bits%"==""; set bits=32
ECHO CREANDO FPGS...
cd fpg-sources
copy ..\..\utils\pxlfpg.dcb . /y
..\..\bennu-win\bgdi pxlfpg %bits% pixpang
..\..\bennu-win\bgdi pxlfpg %bits% antuan carles danigm1 danigm2 gaucho mafrune oldpix oldpux pix pux xmaspix xmaspux
del /f pxlfpg.dcb

cd ..\fpg
ren *.fpg *.fpg.gz
..\..\utils\gzip -d *.fpg.gz

cd ..
exit