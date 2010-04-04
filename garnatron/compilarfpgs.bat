@echo off
rd /s /q fpg
mkdir fpg
ECHO CREANDO FPGS...
cd fpg-sources
..\..\bennu-win\bgdc -Ca pxlfpg.prg
..\..\bennu-win\bgdi pxlfpg bombas
..\..\bennu-win\bgdi pxlfpg bosses
..\..\bennu-win\bgdi pxlfpg enemigos
..\..\bennu-win\bgdi pxlfpg explosiones
..\..\bennu-win\bgdi pxlfpg menu
..\..\bennu-win\bgdi pxlfpg nave