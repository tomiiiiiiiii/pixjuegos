@echo off
REM GENERAL:
set DPI1=90
REM CUTSCENES:
set DPI2=180
REM JEFE5:
set DPI3=58
REM PUNTOS:
set DPI4=45

copy loading-360p.png loading.png /y

exportar-svgs-a-png-720p.bat

rem ANTERIOR INVENTO
rem cd fpg-sources
rem for /f "delims=" %%i in ('dir /b') do call :a %%i

rem PAUSE

rem GOTO :EOF
rem :a
rem echo %1
rem cd %1
rem for /f "delims=" %%j in ('dir /b *.png') do ..\..\..\utils\imagemagick\convert %%j -resize 50%% png32:%%j
rem cd ..
rem GOTO :EOF