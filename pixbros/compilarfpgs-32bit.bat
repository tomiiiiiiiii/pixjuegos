@echo off
ECHO CREANDO FPGS...
cd fpg-sources
..\..\bennu-win\bgdc -Ca pxlfpg.prg
..\..\bennu-win\bgdi pxlfpg enemigos 32
..\..\bennu-win\bgdi pxlfpg general 32
..\..\bennu-win\bgdi pxlfpg intro-de 32
..\..\bennu-win\bgdi pxlfpg intro-en 32 
..\..\bennu-win\bgdi pxlfpg intro-es 32
..\..\bennu-win\bgdi pxlfpg intro-fr 32
..\..\bennu-win\bgdi pxlfpg intro-it 32
..\..\bennu-win\bgdi pxlfpg intro-jp 32
..\..\bennu-win\bgdi pxlfpg items 32
..\..\bennu-win\bgdi pxlfpg jefes 32
..\..\bennu-win\bgdi pxlfpg menu 32
..\..\bennu-win\bgdi pxlfpg menu-de 32
..\..\bennu-win\bgdi pxlfpg menu-en 32
..\..\bennu-win\bgdi pxlfpg menu-es 32
..\..\bennu-win\bgdi pxlfpg menu-fr 32
..\..\bennu-win\bgdi pxlfpg menu-it 32
..\..\bennu-win\bgdi pxlfpg menu-jp 32
..\..\bennu-win\bgdi pxlfpg pax 32
..\..\bennu-win\bgdi pxlfpg pix 32
..\..\bennu-win\bgdi pxlfpg pux 32
exit