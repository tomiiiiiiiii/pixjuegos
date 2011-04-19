#!/bin/sh
juego=`./arcade`
cd ../$juego
./$juego arcade
cd ../arcade
./arcade.sh
