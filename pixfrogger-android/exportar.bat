@echo off
rd /s /q export
echo Compilando...
..\bennu-win\bgdc main.prg
echo Exportando...
mkdir export
xcopy /r/e/y ..\bennu-android .\export
mkdir export\assets\fpg
mkdir export\assets\ogg
mkdir export\assets\fnt
mkdir export\assets\wav
copy recursos\android\hdpi.png export\bin\res\drawable-hdpi\icon.png /y
copy recursos\android\ldpi.png export\bin\res\drawable-ldpi\icon.png /y
copy recursos\android\mdpi.png export\bin\res\drawable-mdpi\icon.png /y

copy recursos\android\hdpi.png export\res\drawable-hdpi\icon.png /y
copy recursos\android\ldpi.png export\res\drawable-ldpi\icon.png /y
copy recursos\android\mdpi.png export\res\drawable-mdpi\icon.png /y

copy recursos\android\strings.xml export\res\values\strings.xml /y
copy recursos\android\AndroidManifest.xml export\ /y
copy recursos\android\build.xml export\ /y

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