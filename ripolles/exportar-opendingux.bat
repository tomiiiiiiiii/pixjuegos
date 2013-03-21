@echo off

cd src
echo Compilando...
..\..\bennu-win\bgdc ripolles.prg
move ripolles.dcb ..
pause
cd ..

rd /s /q export-opendingux
echo Compilamos FPGs en 16 bits
call compilarfpgs.bat 16

echo Compilamos FNTs en 16 bits
call compilarfnts.bat 16

echo exportando...
mkdir export-opendingux
mkdir export-opendingux\ripolles\fpg
mkdir export-opendingux\ripolles\ogg
mkdir export-opendingux\ripolles\fnt
mkdir export-opendingux\ripolles\wav

mkdir export-opendingux\ripolles\bgd-runtime
copy ..\bennu-opendingux\bgd-runtime\*.so export-opendingux\ripolles\bgd-runtime
copy ..\bennu-opendingux\bgd-runtime\bgdi export-opendingux\ripolles\bgd-runtime

cd wav
FOR %%G IN (*.wav) DO ..\..\utils\ffmpeg.exe -i %%G -ar 22050 ..\export-opendingux\ripolles\wav\%%G > NUL
cd ..

copy ogg\*.ogg export-opendingux\ripolles\ogg
copy fpg\*.fpg export-opendingux\ripolles\fpg
copy fnt\*.fnt export-opendingux\ripolles\fnt
copy recursos\opendingux\ripolles.dpe export-opendingux\ripolles
copy recursos\opendingux\ripolles export-opendingux\ripo
copy ripolles.dcb export-opendingux\ripolles
copy loading.png export-opendingux\ripolles

echo LISTO!!
pause