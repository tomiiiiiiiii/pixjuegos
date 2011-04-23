#!/bin/bash
xrandr -s 800x600
/usr/lib/vino/vino-server &

cd /pixjuegos/release/arcade
juego=`./arcade`
if [ $juego = "salir" ]; then
   exit
fi
cd ../$juego
./$juego arcade
cd ../arcade
./arcade.sh
