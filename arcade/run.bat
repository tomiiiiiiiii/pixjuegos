cd arcade
arcade.exe arcade > next.txt
set /p next= < next.txt
cd ..
if %next% == "salir" exit
cd %next%
%next%.exe arcade
cd ..
run.bat
