@echo off
set bits=%1
if "%bits%"==""; set bits=32
call ..\scripts\compilarfpgs.bat %1 bp