@echo off
ECHO CREANDO FPGS...
rd /s /f fpg
mkdir fpg
cd fpg-sources
..\..\bennu-win\bgdc pxlfpg.prg
..\..\bennu-win\bgdi pxlfpg pixpang
..\..\bennu-win\bgdi pxlfpg pix