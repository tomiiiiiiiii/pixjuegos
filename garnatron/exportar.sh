#!/bin/sh
@echo off
echo Generando FPGS
mkdir fpg
cd fpg-sources
ECHO CREANDO FPGS...
cd fpg-sources
../../bennu-linux/bgdc pxlfpg.prg
../../bennu-linux/bgdi pxlfpg bombas
../../bennu-linux/bgdi pxlfpg bosses
../../bennu-linux/bgdi pxlfpg enemigos
../../bennu-linux/bgdi pxlfpg explosiones
../../bennu-linux/bgdi pxlfpg menu
../../bennu-linux/bgdi pxlfpg nave
cd ..

cd src
echo Compilando...
../../bennu-linux/bgdc garnatron.prg
mv garnatron.dcb ..
cd ..
echo Exportando...
mkdir export
mkdir export/fpg
mkdir export/ogg
mkdir export/fnt
mkdir export/wav
cp fpg/*.fpg export/fpg
cp ogg/*.ogg export/ogg
cp wav/*.wav export/wav
cp fnt/*.fnt export/fnt
cp ../bennu-linux/*.so export
cp ../bennu-linux/bgdi export/garnatron
cp garnatron.dcb export
chmod +x export/*.so export/garnatron
echo LISTO!!