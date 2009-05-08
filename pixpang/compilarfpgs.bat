@echo off
ECHO CREANDO FPGS...
cd fpg-sources
bgdc -Ca pxlfpg.prg
bgdi pxlfpg menu
bgdi pxlfpg menu-en
bgdi pxlfpg menu-es
bgdi pxlfpg chars1
bgdi pxlfpg chars2
bgdi pxlfpg chars3
bgdi pxlfpg chars4
bgdi pxlfpg chars5
bgdi pxlfpg chars6
bgdi pxlfpg chars7
bgdi pxlfpg charsxmas
bgdi pxlfpg eng
bgdi pxlfpg pixpang
bgdi pxlfpg bloquesmask
cd monstruos
bgdc -Ca pxlfpg.prg
bgdi pxlfpg fantasma
bgdi pxlfpg fmars
bgdi pxlfpg gusano
bgdi pxlfpg maskara
bgdi pxlfpg ultraball