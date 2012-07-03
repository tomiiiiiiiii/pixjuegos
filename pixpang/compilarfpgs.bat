@echo off
ECHO CREANDO FPGS...
rd /s /q fpg
mkdir fpg
mkdir fpg\monstruos
cd fpg-sources
copy /y ..\..\utils\pxlfpg.dcb .
..\..\bennu-win\bgdi pxlfpg 32 antuan bloquesmask carles ceferino danigm1 danigm2 eng mafrune menu menu-en menu-es mpang paf pang pix pixpang pixxmas pux puxxmas spang1 spang2

del /f pxlfpg.dcb
cd monstruos
..\..\..\bennu-win\bgdc pxlfpg.prg
..\..\..\bennu-win\bgdi pxlfpg fantasma
..\..\..\bennu-win\bgdi pxlfpg fmars
..\..\..\bennu-win\bgdi pxlfpg gusano
..\..\..\bennu-win\bgdi pxlfpg maskara
..\..\..\bennu-win\bgdi pxlfpg ultraball