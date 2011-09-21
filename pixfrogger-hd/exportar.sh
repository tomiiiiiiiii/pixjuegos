#!/bin/sh
@echo off
echo Generando FPGS
mkdir fpg
cd fpg-sources
../../bennu-linux/bgdc pxlfpg.prg
../../bennu-linux/bgdi pxlfpg pixfrogger
cd ..

cd src
echo Compilando...
../../bennu-linux/bgdc pixfrogger.prg
mv pixfrogger.dcb ..
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
cp ../bennu-linux/bgdi export/pixfrogger
cp pixfrogger.dcb export
chmod +x export/*.so export/pixfrogger
echo LISTO!!
