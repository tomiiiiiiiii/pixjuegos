@echo off

cd src
echo Compilando...
..\..\bennu-win\bgdc ripolles.prg
move ripolles.dcb ..
pause
cd ..

rd /s /q export-dingux
echo Compilamos FPGs en 16 bits
call compilarfpgs.bat 16

echo Compilamos FNTs en 16 bits
call compilarfnts.bat 16

echo exportando...
mkdir export-dingux
mkdir export-dingux\ripolles\fpg
mkdir export-dingux\ripolles\ogg
mkdir export-dingux\ripolles\fnt
mkdir export-dingux\ripolles\wav

mkdir export-dingux\ripolles\bgd-runtime
copy ..\bennu-dingux\bgd-runtime\*.so export-dingux\ripolles\bgd-runtime
copy ..\bennu-dingux\bgd-runtime\bgdi export-dingux\ripolles\bgd-runtime

cd wav
FOR %%G IN (*.wav) DO ..\..\utils\ffmpeg.exe -i %%G -ar 22050 ..\export-dingux\ripolles\wav\%%G > NUL
cd ..

copy ogg\*.ogg export-dingux\ripolles\ogg
copy fpg\*.fpg export-dingux\ripolles\fpg
copy fnt\*.fnt export-dingux\ripolles\fnt
copy recursos\dingux\ripolles.dpe export-dingux\ripolles
copy recursos\dingux\ripolles export-dingux\ripo
copy ripolles.dcb export-dingux\ripolles
copy loading.png export-dingux\ripolles
copy loading2.png export-dingux\ripolles

echo LISTO!!
pause