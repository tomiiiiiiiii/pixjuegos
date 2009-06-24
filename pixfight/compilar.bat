@echo off
echo Precompilando...
rd /s /q fpg
mkdir fpg
cd src
..\bennu\bgdc -Ca precompilar.prg > null
..\bennu\bgdi precompilar
del precompilar.dcb /f
del null /f
echo Compilando...
..\bennu\bgdc -g pixfight.prg
move pixfight.dcb ..
pause
cd ..
exit