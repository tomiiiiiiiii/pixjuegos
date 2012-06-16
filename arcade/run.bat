cd arcade
arcade.exe arcade
cd ..
set /p next= < next.txt
if %next% == "salir" exit
cd %next%
%next%.exe arcade
cd ..
run.bat
