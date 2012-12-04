@echo off
call ..\utils\entorno.bat bankpanic-android

rd /s /q export
echo Compilando...
cd src
..\..\bennu-win\bgdc bp.prg
move bp.dcb ..\main.dcb
cd ..
pause

echo Compilando fpgs....
cd fpg-sources
copy /y ..\..\utils\pxlfpg.dcb .
..\..\bennu-win\bgdi pxlfpg 16 bp

del /f pxlfpg.dcb
cd ..\fpg
ren bp.fpg bp.fpg.gz
..\..\utils\gzip -d bp.fpg.gz
cd ..

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
copy recursos\android\AndroidManifest.xml export\ /y
copy recursos\android\build.xml export\ /y

mkdir export\src\com
xcopy /r/e/y recursos\android\com export\src\com

echo Copiando el juego...
copy loading.png export\assets /y
copy fnt\*.fnt export\assets\fnt /y
copy fpg\*.fpg export\assets\fpg /y
copy ogg\*.ogg export\assets\ogg /y
copy wav\*.wav export\assets\wav /y
copy main.dcb export\assets /y

echo Exportado correctamente. Ahora se instalará en el móvil...
pause
cd export
if exist c:\pixjuegos.keystore call ant release install
if not exist c:\pixjuegos.keystore call ant debug install
pause