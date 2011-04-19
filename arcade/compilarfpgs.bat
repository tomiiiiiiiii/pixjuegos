@echo off
ECHO CREANDO FPGS...
cd fpg-sources
..\..\bennu-win\bgdc -Ca pxlfpg.prg
..\..\bennu-win\bgdi pxlfpg arcade