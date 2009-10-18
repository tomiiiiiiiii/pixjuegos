@echo off
echo Precompilando...
rd /s /q fpg
mkdir fpg
cd src
..\..\bennu-win\bgdc precompilar.prg
..\..\bennu-win\bgdi precompilar
del precompilar.dcb /f
del null /f
echo Compilando...
..\..\bennu-win\bgdc -g pixfight.prg
move pixfight.dcb ..
pause
cd ..
exit