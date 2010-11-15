@echo off
echo Compila el codigo en Wii y coloca aqui el pixbros.dcb
pause
echo Compilamos FPGs en 16 bits
start /wait compilarfpgs-16bit.bat
echo exportando...
mkdir export-wii
mkdir export-wii\fpg
mkdir export-wii\ogg
mkdir export-wii\fnt
mkdir export-wii\wav
mkdir export-wii\niveles
copy fpg\*.fpg export-wii\fpg
copy ogg\*.mp3 export-wii\ogg
copy wav\*.wav export-wii\wav
copy fnt\*.fnt export-wii\fnt
copy niveles\*.png export-wii\niveles
copy niveles\*.lvl export-wii\niveles
copy ..\bennu-wii\bgdi.elf export-wii\boot.elf
copy pixbros.dcb export-wii\boot.dcb
copy recursos\pixbroswii.png export-wii\icon.png
copy recursos\wiimeta.xml export-wii\meta.xml
echo LISTO!!
pause