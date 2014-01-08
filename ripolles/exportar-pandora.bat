@echo off

cd src
echo Compilando...
..\..\bennu-win-old\bgdc ripolles.prg
move ripolles.dcb ..
pause
cd ..

rd /s /q export-pandora
echo Compilamos FPGs en 16 bits
call compilarfpgs.bat 16
echo Compilamos FNTs en 16 bits
call compilarfnts.bat 16

echo exportando...
mkdir export-pandora
mkdir export-pandora\ripolles\fpg
mkdir export-pandora\ripolles\ogg
mkdir export-pandora\ripolles\fnt
mkdir export-pandora\ripolles\wav

mkdir export-pandora\ripolles\bgd-runtime
copy ..\bennu-pandora\bgd-runtime\*.so export-pandora\ripolles\bgd-runtime
copy ..\bennu-pandora\bgd-runtime\bgdi export-pandora\ripolles\bgd-runtime

copy wav\*.wav export-pandora\ripolles\wav
copy ogg\*.ogg export-pandora\ripolles\ogg
copy fpg\*.fpg export-pandora\ripolles\fpg
copy fnt\*.fnt export-pandora\ripolles\fnt
copy recursos\pandora\*.* export-pandora\ripolles\
copy ripolles.dcb export-pandora\ripolles
copy loading.png export-pandora\ripolles
copy loading2.png export-pandora\ripolles

..\bennu-pandora\tools\mksquashfs.exe export-pandora\ripolles ripolles.pnd
move ripolles.pnd export-pandora

echo LISTO!!
pause