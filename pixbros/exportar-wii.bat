@echo off
echo Compila el codigo en Wii y coloca aqui el pixbros.dcb
pause
echo Compilamos FPGs en 16 bits
start /wait compilarfpgs.bat 16
echo exportando...
mkdir export-wii
mkdir export-wii\fpg
mkdir export-wii\ogg
mkdir export-wii\fnt
mkdir export-wii\wav
mkdir export-wii\niveles
copy fpg\*.fpg export-wii\fpg
REM copy ogg\*.mp3 export-wii\ogg
cd ogg
FOR %%G IN (*.ogg) DO ..\..\utils\ffmpeg.exe -i %%G -ar 44100 -ab 128k ..\export-wii\ogg\%%G.mp3
cd ..\export-wii\ogg\
ren *.ogg.mp3 *.
ren *.ogg *.
ren *. *.mp3
cd ..\..

copy wav\*.wav export-wii\wav
copy fnt\*.fnt export-wii\fnt
copy niveles\*.png export-wii\niveles
copy niveles\*.lvl export-wii\niveles
copy ..\bennu-wii\bgdi.elf export-wii\boot.elf
copy pixbros.dcb export-wii\boot.dcb
copy recursos\wii\icon.png export-wii\
copy recursos\wii\meta.xml export-wii\
echo LISTO!!
pause