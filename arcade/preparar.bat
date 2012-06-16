rd /s /q ..\release
mkdir ..\release

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