@echo off
ECHO CREANDO FPGS...
cd fpg-sources
..\bennu\bgdc -Ca pxlfpg.prg
..\bennu\bgdi pxlfpg enemigos
..\bennu\bgdi pxlfpg menu
..\bennu\bgdi pxlfpg powerups
..\bennu\bgdi pxlfpg pix
..\bennu\bgdi pxlfpg pux
..\bennu\bgdi pxlfpg pax
..\bennu\bgdi pxlfpg pex
..\bennu\bgdi pxlfpg moneda
..\bennu\bgdi pxlfpg tiles