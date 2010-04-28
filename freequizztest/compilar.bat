SET PROYECTO=quizz

@echo off
echo Compilando...
cd src
..\..\bennu-win\bgdc -g %proyecto%.prg
pause
move %proyecto%.dcb ..
cd ..
..\bennu-win\bgdi %proyecto%.dcb
pause
exit