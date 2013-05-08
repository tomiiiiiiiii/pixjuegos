@echo off
set bits=%1
if "%bits%"==""; set bits=16
call ..\scripts\compilarfpgs.bat %bits% cutscenes enemigo1 enemigo2 enemigo3 enemigo4 enemigo5 general jefe1 jefe2 jefe3 jefe4 menu nivel1 nivel2 nivel3 nivel4 nivel5 nivel_survival1 nivel_battleroyale1 nivel_matajefes1 objetos
call ..\scripts\compilarfpgs.bat %bits% ripolles1 ripolles2 ripolles3 ripolles4 pato cat es en en-ouya fnt1 tiempo