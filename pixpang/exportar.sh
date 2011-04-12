#!/bin/sh
@echo off
echo Generando FPGS
cd fpg-sources
../../bennu-linux/bgdc pxlfpg.prg
../../bennu-linux/bgdi pxlfpg menu
../../bennu-linux/bgdi pxlfpg menu-en
../../bennu-linux/bgdi pxlfpg menu-es
../../bennu-linux/bgdi pxlfpg chars1
../../bennu-linux/bgdi pxlfpg chars2
../../bennu-linux/bgdi pxlfpg chars3
../../bennu-linux/bgdi pxlfpg chars4
../../bennu-linux/bgdi pxlfpg chars5
../../bennu-linux/bgdi pxlfpg chars6
../../bennu-linux/bgdi pxlfpg chars7
../../bennu-linux/bgdi pxlfpg charsxmas
../../bennu-linux/bgdi pxlfpg eng
../../bennu-linux/bgdi pxlfpg pixpang
../../bennu-linux/bgdi pxlfpg bloquesmask

cd monstruos
../../../bennu-linux/bgdc pxlfpg.prg
../../../bennu-linux/bgdi pxlfpg fantasma
../../../bennu-linux/bgdi pxlfpg fmars
../../../bennu-linux/bgdi pxlfpg gusano
../../../bennu-linux/bgdi pxlfpg maskara
../../../bennu-linux/bgdi pxlfpg ultraball

cd src
echo Compilando...
../../bennu-linux/bgdc pixpang.prg
mv pixpang.dcb ..
cd ..
echo Exportando...
mkdir export
mkdir export/fpg
mkdir export/ogg
mkdir export/ogg/monstruos
mkdir export/fnt
mkdir export/wav
mkdir export/tour
mkdir export/fondos
mkdir export/fondos/monstruos
cp fpg/*.fpg export/fpg
cp ogg/*.ogg export/ogg
cp ogg/monstruos/*.* export/ogg/monstruos
cp wav/*.wav export/wav
cp fnt/*.fnt export/fnt
cp tour/*.pang export/tour
cp fondos/*.png export/fondos
cp fondos/monstruos/*.png export/fondos/monstruos
cp ../bennu-linux/*.so export
cp ../bennu-linux/bgdi export/pixpang
cp pixpang.dcb export
echo LISTO!!