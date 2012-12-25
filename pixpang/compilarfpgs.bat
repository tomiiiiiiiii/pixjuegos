@echo off
ECHO CREANDO FPGS...
rd /s /q fpg
mkdir fpg
mkdir fpg\monstruos
cd fpg-sources
copy /y ..\..\utils\pxlfpg.dcb .
..\..\bennu-win\bgdi pxlfpg %1 antuan bloquesmask carles ceferino danigm1 danigm2 eng mafrune menu menu-en menu-es mpang paf pang pix pixpang pixxmas pux puxxmas spang1 spang2 fantasma fmars gusano maskara ultraball
cd ..\fpg
ren *.fpg *.fpg.gz
..\..\utils\gzip -d *.fpg.gz

cd ..
