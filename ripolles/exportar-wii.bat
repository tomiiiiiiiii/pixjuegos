@echo off
rd /s /q export-wii
echo Compilamos FPGs en 16 bits
call compilarfpgs.bat 16
echo exportando...
mkdir export-wii
mkdir export-wii\fpg
mkdir export-wii\ogg
mkdir export-wii\fnt
mkdir export-wii\wav

cd wav
FOR %%G IN (*.wav) DO ..\..\utils\ffmpeg.exe -i %%G -ar 48000 ..\export-wii\wav\%%G
cd ..

copy ogg\*.ogg export-wii\ogg
copy fpg\*.fpg export-wii\fpg
copy fnt\*.fnt export-wii\fnt
copy src\* export-wii\
copy ..\common-src\* export-wii\
copy src\ripolles.prg export-wii\boot.prg
copy ..\bennu-wii\bgdi.elf export-wii\boot.elf
copy recursos\wii\icon.png export-wii\
copy recursos\wii\meta.xml export-wii\
copy loading.png export-wii
copy loading2.png export-wii
echo LISTO!!
pause

echo Queda pendiente compilar el DCB en la Wii... Suerte! :D
pause
