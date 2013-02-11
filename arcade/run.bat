@echo off

if "%bennu%"=="" call :patheame

set PATH=%PATH%;%bennu%

cd arcade
bgdi arcade > next.txt
set /p next= < next.txt
cd ..

echo Next: %next%

if %next%=="salir" goto :eof
cd %next%
bgdi %next% arcade
cd ..
run.bat

:patheame
cd bennu-win
cd > tmp
set /p bennu= < tmp
del /f tmp
cd ..