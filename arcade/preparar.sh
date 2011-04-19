#!/bin/sh
mkdir ../release

sh exportar.sh
mv export ../release/arcade

cd ../pixbros
sh exportar.sh
mv export ../release/pixbros

cd ../pixpang
sh exportar.sh
mv export ../release/pixpang

cd ../pixfrogger
sh exportar.sh
mv export ../release/pixfrogger

cd ../pixdash
sh exportar.sh
mv export ../release/pixdash

cd ../garnatron
sh exportar.sh
mv export ../release/garnatron
