#!/bin/sh
@echo off
cd src
echo Compilando...
../../bennu-linux/bgdc dx.prg
mv dx.dcb ..
cd ..
echo Exportando...
mkdir export
mkdir export/fpg
mkdir export/fpg/personajes
mkdir export/fnt
mkdir export/niveles
cp fpg/*.fpg export/fpg
cp fpg/personajes/*.fpg export/fpg/personajes
cp fnt/*.fnt export/fnt
cp niveles/*.pang export/niveles
cp ../bennu-linux/*.so export
cp ../bennu-linux/bgdi export/dx
cp dx.dcb export
chmod +x export/*.so export/dx
echo LISTO!!
