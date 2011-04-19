#!/bin/sh
@echo off
echo Generando FPGS
mkdir fpg
cd fpg-sources
../../bennu-linux/bgdc pxlfpg.prg
../../bennu-linux/bgdi pxlfpg enemigos 32
../../bennu-linux/bgdi pxlfpg general 32
../../bennu-linux/bgdi pxlfpg intro-de 32
../../bennu-linux/bgdi pxlfpg intro-en 32 
../../bennu-linux/bgdi pxlfpg intro-es 32
../../bennu-linux/bgdi pxlfpg intro-fr 32
../../bennu-linux/bgdi pxlfpg intro-it 32
../../bennu-linux/bgdi pxlfpg intro-jp 32
../../bennu-linux/bgdi pxlfpg items 32
../../bennu-linux/bgdi pxlfpg jefes 32
../../bennu-linux/bgdi pxlfpg menu 32
../../bennu-linux/bgdi pxlfpg menu-de 32
../../bennu-linux/bgdi pxlfpg menu-en 32
../../bennu-linux/bgdi pxlfpg menu-es 32
../../bennu-linux/bgdi pxlfpg menu-fr 32
../../bennu-linux/bgdi pxlfpg menu-it 32
../../bennu-linux/bgdi pxlfpg menu-jp 32
../../bennu-linux/bgdi pxlfpg pax 32
../../bennu-linux/bgdi pxlfpg pix 32
../../bennu-linux/bgdi pxlfpg pux 32
cd ..

cd src
echo Compilando...
../../bennu-linux/bgdc pixbros.prg
mv pixbros.dcb ..
cd ..
echo Exportando...
mkdir export
mkdir export/fpg
mkdir export/ogg
mkdir export/fnt
mkdir export/wav
mkdir export/niveles
cp fpg/*.fpg export/fpg
cp ogg/*.ogg export/ogg
cp wav/*.wav export/wav
cp fnt/*.fnt export/fnt
cp niveles/*.lvl export/niveles
cp niveles/*.png export/niveles
cp ../bennu-linux/*.so export
cp ../bennu-linux/bgdi export/pixbros
cp pixbros.dcb export
chmod +x export/*.so export/pixbros
echo LISTO!!
