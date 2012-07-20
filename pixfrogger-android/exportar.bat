@echo off
rd /s /q export
echo Compilando...
cd src
..\..\bennu-win\bgdc pixfrogger-android.prg -g
move pixfrogger-android.dcb ..\main.dcb
cd ..

echo Compilando fpgs....
call compilarfpgs.bat

echo Exportando...
mkdir export
echo Copiando base de bennu-android...
xcopy /r/e/y ..\bennu-android .\export

echo Creando carpetas...
mkdir export\assets\fpg
mkdir export\assets\ogg
mkdir export\assets\fnt
mkdir export\assets\wav

echo Copiando recursos de android...
copy recursos\android\hdpi.png export\res\drawable-hdpi\icon.png /y
copy recursos\android\ldpi.png export\res\drawable-ldpi\icon.png /y
copy recursos\android\mdpi.png export\res\drawable-mdpi\icon.png /y

copy recursos\android\strings.xml export\res\values\strings.xml /y
rem copy recursos\android\AndroidManifest.xml export\ /y
copy recursos\android\build.xml export\ /y

echo Copiando el juego...
copy 3.png export\assets\3.png /y
copy fpg\*.fpg export\assets\fpg /y
copy ogg\*.ogg export\assets\ogg /y
copy wav\*.wav export\assets\wav /y
copy fnt\*.fnt export\assets\fnt /y
copy main.dcb export\assets /y
echo Exportado correctamente. Ahora se instalará en el móvil...
pause
cd export
ant debug install
pause