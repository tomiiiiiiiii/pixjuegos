@echo off
mkdir fpg
ECHO CREANDO FPGS...
cd fpg-sources
..\..\bennu-win\bgdc -Ca pxlfpg.prg
..\..\bennu-win\bgdi pxlfpg enemigos
..\..\bennu-win\bgdi pxlfpg menu
..\..\bennu-win\bgdi pxlfpg powerups
..\..\bennu-win\bgdi pxlfpg pix
..\..\bennu-win\bgdi pxlfpg pux
..\..\bennu-win\bgdi pxlfpg pax
..\..\bennu-win\bgdi pxlfpg pex
..\..\bennu-win\bgdi pxlfpg moneda
..\..\bennu-win\bgdi pxlfpg tiles
..\..\bennu-win\bgdi pxlfpg premios
..\..\bennu-win\bgdi pxlfpg general