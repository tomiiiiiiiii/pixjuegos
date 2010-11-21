@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc pixbros.prg
move pixbros.dcb ..
cd ..
echo Compilamos FPGs en 16 bits
start /wait compilarfpgs-16bit.bat
echo exportando...
mkdir export-caanoo
mkdir export-caanoo\fpg
mkdir export-caanoo\ogg
mkdir export-caanoo\fnt
mkdir export-caanoo\wav
mkdir export-caanoo\niveles
copy fpg\*.fpg export-caanoo\fpg
REM copy ogg\*.mp3 export-caanoo\ogg

cd ogg
FOR %%G IN (*.ogg) DO ..\..\utils\ffmpeg.exe -i %%G -ar 22050 -ab 64k ..\export-caanoo\ogg\%%G.mp3
cd ..\export-caanoo\ogg\
ren *.ogg.mp3 *.
ren *.ogg *.
ren *. *.mp3
cd ..\..

copy wav\*.wav export-caanoo\wav
copy fnt\*.fnt export-caanoo\fnt
copy niveles\*.png export-caanoo\niveles
copy niveles\*.lvl export-caanoo\niveles
copy pixbros.dcb export-caanoo

copy recursos\caanoo\pixbros.gpe export-caanoo\
copy recursos\caanoo\pixbros.png export-caanoo\

mkdir export-caanoo\bgd-runtime
copy ..\bennu-caanoo\bgd-runtime\lib*.* export-caanoo\bgd-runtime
copy ..\bennu-caanoo\bgd-runtime\mod*.* export-caanoo\bgd-runtime
copy ..\bennu-caanoo\bgd-runtime\bgdi export-caanoo\bgd-runtime

mkdir game
copy recursos\pixbros.ini game\
move export-caanoo game
cd game
ren export-caanoo pixbros
cd ..
mkdir export-caanoo
move game export-caanoo

echo LISTO!!
pause