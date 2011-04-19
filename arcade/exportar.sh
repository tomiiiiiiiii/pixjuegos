#!/bin/sh
@echo off
echo Generando FPGS
mkdir fpg
cd fpg-sources
../../bennu-linux/bgdc pxlfpg.prg
../../bennu-linux/bgdi pxlfpg arcade
cd ..

cd src
echo Compilando...
../../bennu-linux/bgdc arcade.prg
mv arcade.dcb ..
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
cp ../bennu-linux/bgdi export/arcade
cp arcade.dcb export
cp arcade.sh export
chmod +x export/*.so export/arcade
echo LISTO!!
