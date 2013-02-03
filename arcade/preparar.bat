rd /s /q ..\release
mkdir ..\release

copy run.bat ..\release

start /wait exportar.bat
move export ..\release\arcade
pause

cd ..\pixbros
start /wait exportar.bat
move export ..\release\pixbros
pause

cd ..\pixpang
start /wait exportar.bat
move export ..\release\pixpang
pause

cd ..\pixfrogger
start /wait exportar.bat
move export ..\release\pixfrogger
pause

cd ..\pixdash
start /wait exportar.bat
move export ..\release\pixdash
pause

cd ..\garnatron
start /wait exportar.bat
move export ..\release\garnatron
pause

cd ..\eterno-retorno
start /wait exportar.bat
move export ..\release\eterno-retorno
pause

cd ..\ripolles
start /wait exportar.bat
move export ..\release\ripolles
pause

cd ..\eterno-retorno-3
start /wait exportar.bat
move export ..\release\eterno-retorno-3
pause