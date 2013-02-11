rd /s /q ..\release
mkdir ..\release

copy run.bat ..\release
copy run.sh ..\release

mkdir ..\release\bennu-win
xcopy /r/e/y ..\bennu-win ..\release\bennu-win
mkdir ..\release\bennu-linux
xcopy /r/e/y ..\bennu-linux ..\release\bennu-linux

call :prepara_juego arcade
call :prepara_juego pixbros
call :prepara_juego pixpang
call :prepara_juego pixfrogger
call :prepara_juego pixdash
call :prepara_juego garnatron
call :prepara_juego eterno-retorno
call :prepara_juego ripolles
call :prepara_juego eterno-retorno-3

pause
goto :eof

:prepara_juego
cd ..\%1
rd /s /q export
start /wait exportar.bat
move export ..\release\%1
del /f ..\release\%1\*.dll
del /f ..\release\%1\%1.exe
cd ..\arcade