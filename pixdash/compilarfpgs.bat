@echo off
ECHO CREANDO FPGS...
cd fpg-sources
bgdc -Ca pxlfpg.prg
bgdi pxlfpg enemigos
bgdi pxlfpg menu
bgdi pxlfpg powerups
bgdi pxlfpg pix
bgdi pxlfpg pux
bgdi pxlfpg pax
bgdi pxlfpg pex