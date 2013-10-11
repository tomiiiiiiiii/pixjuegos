@echo off
set bits=%1
if "%bits%"==""; set bits=16
call ..\scripts\compilarfpgs.bat %bits%