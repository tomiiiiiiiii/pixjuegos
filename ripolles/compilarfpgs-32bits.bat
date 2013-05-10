@echo off
set bits=32
call ..\scripts\compilarfpgs.bat %bits% enemigo1 enemigo2 enemigo3 enemigo4 enemigo5 jefe4 general objetos
call ..\scripts\compilarfpgs.bat %bits% ripolles1 ripolles2 ripolles3 ripolles4 pato fnt1 tiempo

set bits=16
call ..\scripts\compilarfpgs.bat %bits% cutscenes jefe1 cat es en en-ouya menu nivel1 nivel4 nivel_survival1 nivel_battleroyale1 nivel_matajefes1