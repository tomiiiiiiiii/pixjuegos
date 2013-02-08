rd /s /q ..\release
mkdir ..\release

copy run.bat ..\release

start /wait exportar.bat
move export ..\release\arcade

cd ..\pixbros
start /wait exportar.bat
move export ..\release\pixbros

cd ..\pixpang
start /wait exportar.bat
move export ..\release\pixpang

cd ..\pixfrogger
start /wait exportar.bat
move export ..\release\pixfrogger

cd ..\pixdash
start /wait exportar.bat
move export ..\release\pixdash

cd ..\garnatron
start /wait exportar.bat
move export ..\release\garnatron

cd ..\eterno-retorno
start /wait exportar.bat
move export ..\release\eterno-retorno

cd ..\ripolles
start /wait exportar.bat
move export ..\release\ripolles

cd ..\eterno-retorno-3
start /wait exportar.bat
move export ..\release\eterno-retorno-3

pause