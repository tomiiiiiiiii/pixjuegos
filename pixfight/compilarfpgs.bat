@echo off
ECHO CREANDO FPGS...
cd fpg-sources
..\bennu\bgdc -Ca pxlfpg.prg
..\bennu\bgdi pxlfpg raruto
..\bennu\bgdi pxlfpg pix
..\bennu\bgdi pxlfpg tux