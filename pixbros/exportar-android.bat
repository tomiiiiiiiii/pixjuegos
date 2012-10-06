@echo off
call ..\utils\entorno.bat pixbros

rd /s /q export
echo Compilando...
cd src
..\..\bennu-win\bgdc pixbros.prg
move pixbros.dcb ..\main.dcb
cd ..
pause

echo Compilando fpgs....
rem start /wait compilarfpgs.bat 16

rem cd fpg
rem ren *.fpg *.fpg.gz
rem ..\..\utils\gzip -d *.fpg.gz
rem cd ..

echo Exportando...
mkdir export
echo Copiando base de bennu-android...
xcopy /r/e/y ..\bennu-android .\export

rem echo Generamos local.properties
rem echo sdk.dir=%dirbase%/utils/android-sdk > export\local.properties

echo Creando carpetas...
mkdir export\assets\fpg
mkdir export\assets\ogg
mkdir export\assets\fnt
mkdir export\assets\wav
mkdir export\assets\niveles

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
copy fnt\*.fnt export\assets\fnt /y
copy fpg\*.fpg export\assets\fpg /y
copy ogg\*.ogg export\assets\ogg /y
copy wav\*.wav export\assets\wav /y
copy niveles\*.png export\assets\niveles /y
copy niveles\*.lvl export\assets\niveles /y
copy main.dcb export\assets /y
echo Exportado correctamente. Ahora se instalará en el móvil...
pause
cd export
if exist c:\pixjuegos.keystore call ant release install
if not exist c:\pixjuegos.keystore call ant debug install
pause