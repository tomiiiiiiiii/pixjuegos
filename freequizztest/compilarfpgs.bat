@echo off
mkdir fpg
ECHO CREANDO FPGS...
cd fpg-sources
..\..\bennu-win\bgdc -Ca pxlfpg.prg
..\..\bennu-win\bgdi pxlfpg quizz
pause