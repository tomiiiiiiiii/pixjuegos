@echo off

cd src
echo Compilando...
..\..\bennu-win\bgdc -D GLOBAL_RESOLUTION=1 ripolles.prg
move ripolles.dcb ..
pause
cd ..

rd /s /q export-caanoo
echo Compilamos FPGs en 16 bits
call compilarfpgs.bat 16
echo Compilamos FNTs en 16 bits
call compilarfnts.bat 16

echo exportando...
mkdir export-caanoo
mkdir export-caanoo\ripolles\fpg
mkdir export-caanoo\ripolles\ogg
mkdir export-caanoo\ripolles\fnt
mkdir export-caanoo\ripolles\wav

mkdir export-caanoo\ripolles\bgd-runtime
copy ..\bennu-caanoo\bgd-runtime\*.so export-caanoo\ripolles\bgd-runtime
copy ..\bennu-caanoo\bgd-runtime\bgdi export-caanoo\ripolles\bgd-runtime

cd wav
FOR %%G IN (*.wav) DO ..\..\utils\ffmpeg.exe -i %%G -ar 22050 ..\export-caanoo\ripolles\wav\%%G > NUL
cd ..

copy ogg\*.ogg export-caanoo\ripolles\ogg
copy fpg\*.fpg export-caanoo\ripolles\fpg
copy recursos\caanoo\ripolles.png export-caanoo\ripolles
copy recursos\caanoo\ripolles.gpe export-caanoo\ripolles
copy recursos\caanoo\ripolles.ini export-caanoo\
copy ripolles.dcb export-caanoo\ripolles
copy loading.png export-caanoo\ripolles
copy loading2.png export-caanoo\ripolles

echo LISTO!!
pause