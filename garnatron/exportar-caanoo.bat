@echo off

cd src
echo Compilando...
..\..\bennu-win\bgdc garnatron.prg
move garnatron.dcb ..
pause
cd ..

rd /s /q export-caanoo
echo Compilamos FPGs en 16 bits
call compilarfpgs.bat 16

echo exportando...
mkdir export-caanoo
mkdir export-caanoo\garnatron\fpg
mkdir export-caanoo\garnatron\ogg
mkdir export-caanoo\garnatron\fnt
mkdir export-caanoo\garnatron\wav
mkdir export-caanoo\garnatron\niveles

mkdir export-caanoo\garnatron\bgd-runtime
copy ..\bennu-caanoo\bgd-runtime\*.so export-caanoo\garnatron\bgd-runtime
copy ..\bennu-caanoo\bgd-runtime\bgdi export-caanoo\garnatron\bgd-runtime

cd wav
FOR %%G IN (*.wav) DO ..\..\utils\ffmpeg.exe -i %%G -ar 22050 ..\export-caanoo\garnatron\wav\%%G > NUL
cd ..

copy ogg\*.ogg export-caanoo\garnatron\ogg
copy fpg\*.fpg export-caanoo\garnatron\fpg
copy fnt\*.fnt export-caanoo\garnatron\fnt
copy niveles\*.csv export-caanoo\garnatron\niveles
copy recursos\caanoo\garnatron.png export-caanoo\garnatron
copy recursos\caanoo\garnatron-icon.png export-caanoo\garnatron
copy recursos\caanoo\garnatron.gpe export-caanoo\garnatron
copy recursos\caanoo\garnatron.ini export-caanoo\
copy garnatron.dcb export-caanoo\garnatron

echo LISTO!!
pause