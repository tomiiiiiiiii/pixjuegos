#!/bin/bash
xrandr -s 800x600

cd /pixjuegos/release/arcade
juego=`./arcade`
if [ $juego = "salir" ]; then
   exit
fi
cd ../$juego
./$juego arcade
cd ../arcade
./arcade.sh
