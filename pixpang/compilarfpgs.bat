@echo off
ECHO CREANDO FPGS...
rd /s /f fpg
mkdir fpg
mkdir fpg\monstruos
cd fpg-sources
..\..\bennu-win\bgdc pxlfpg.prg
..\..\bennu-win\bgdi pxlfpg menu
..\..\bennu-win\bgdi pxlfpg menu-en
..\..\bennu-win\bgdi pxlfpg menu-es
..\..\bennu-win\bgdi pxlfpg pix
..\..\bennu-win\bgdi pxlfpg pux
..\..\bennu-win\bgdi pxlfpg chars2
..\..\bennu-win\bgdi pxlfpg chars3
..\..\bennu-win\bgdi pxlfpg chars4
..\..\bennu-win\bgdi pxlfpg chars5
..\..\bennu-win\bgdi pxlfpg chars6
..\..\bennu-win\bgdi pxlfpg chars7
..\..\bennu-win\bgdi pxlfpg charsxmas
..\..\bennu-win\bgdi pxlfpg eng
..\..\bennu-win\bgdi pxlfpg pixpang
..\..\bennu-win\bgdi pxlfpg bloquesmask
cd monstruos
..\..\..\bennu-win\bgdc pxlfpg.prg
..\..\..\bennu-win\bgdi pxlfpg fantasma
..\..\..\bennu-win\bgdi pxlfpg fmars
..\..\..\bennu-win\bgdi pxlfpg gusano
..\..\..\bennu-win\bgdi pxlfpg maskara
..\..\..\bennu-win\bgdi pxlfpg ultraball