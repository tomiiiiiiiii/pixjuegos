@echo off
ECHO CREANDO FPGS...
cd fpg-sources
bgdc -Ca pxlfpg.prg
bgdi pxlfpg menu
bgdi pxlfpg menu-en
bgdi pxlfpg menu-es
bgdi pxlfpg chars1
bgdi pxlfpg charsxmas
bgdi pxlfpg eng
bgdi pxlfpg pixpang
cd monstruos
bgdc -Ca pxlfpg.prg
bgdi pxlfpg fantasma
bgdi pxlfpg fmars
bgdi pxlfpg gusano
bgdi pxlfpg maskara
bgdi pxlfpg ultraball