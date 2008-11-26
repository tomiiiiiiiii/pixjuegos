@echo off
ECHO CREANDO FPGS...
cd fpg-sources
bgdc -Ca pxlfpg.prg
bgdi pxlfpg menu
bgdi pxlfpg menu-en
bgdi pxlfpg menu-es