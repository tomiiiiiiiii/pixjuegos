@echo off
set PROYECTO=quizz
cd src
echo Compilando...
..\..\bennu-win\bgdc quizz.prg
move quizz.dcb ..
cd ..
echo Exportando...
mkdir export
mkdir export\fpg
mkdir export\xm
mkdir export\fnt
mkdir export\wav
mkdir export\quizz
copy fpg\*.fpg export\fpg
copy xm\*.xm export\xm
copy wav\*.wav export\wav
copy fnt\*.fnt export\fnt
copy quizz\*.txt export\quizz

copy ..\bennu-win\*.dll export
copy ..\bennu-win\bgdi.exe export\quizz.exe

copy quizz.dcb export

cd export
echo DEBES ELEGIR EL quizz.EXE
..\..\bennu-win\pakator 
move quizz_exe_pak.exe ..\
cd ..
rd /s /q export
echo LISTO!!
exit
pause