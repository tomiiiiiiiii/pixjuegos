#!/bin/sh
@echo off
echo Generando FPGS
mkdir fpg
cd fpg-sources
../../bennu-linux/bgdc -Ca pxlfpg.prg
../../bennu-linux/bgdi pxlfpg enemigos
../../bennu-linux/bgdi pxlfpg menu
../../bennu-linux/bgdi pxlfpg powerups
../../bennu-linux/bgdi pxlfpg pix
../../bennu-linux/bgdi pxlfpg pux
../../bennu-linux/bgdi pxlfpg pax
../../bennu-linux/bgdi pxlfpg pex
../../bennu-linux/bgdi pxlfpg moneda
../../bennu-linux/bgdi pxlfpg tiles
cd ..

cd src
echo Compilando...
../../bennu-linux/bgdc pixdash.prg
mv pixdash.dcb ..
cd ..
echo Exportando...
mkdir export
mkdir export/fpg
mkdir export/ogg
mkdir export/fnt
mkdir export/wav
mkdir export/fondos
cp fpg/*.fpg export/fpg
cp ogg/*.ogg export/ogg
cp wav/*.wav export/wav
cp fnt/*.fnt export/fnt
cp fondos/*.png export/fondos
cp fondos/*.jpg export/fondos
cp ../bennu-linux/*.so export
cp ../bennu-linux/bgdi export/pixdash
#esta linea siguiente es temporal!
cp -r niveles export/
cp pixdash.dcb export
chmod +x export/*.so export/pixdash
echo LISTO!!
