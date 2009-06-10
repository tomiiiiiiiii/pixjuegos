@echo off
ECHO CREANDO FPGS...
cd fpg-sources
bgdc -Ca pxlfpg.prg
bgdi pxlfpg raruto
bgdi pxlfpg pix