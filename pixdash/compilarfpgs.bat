@echo off
ECHO CREANDO FPGS...
cd fpg-sources
bgdc -Ca pxlfpg.prg
bgdc -Ca tilesfpg.prg
bgdi pxlfpg enemigos
rem bgdi tilesfpg tiles
bgdi pxlfpg powerups