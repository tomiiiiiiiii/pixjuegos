@echo off
call ..\utils\entorno.bat pixpang

rd /s /q export
echo Compilando...
cd src
..\..\bennu-win\bgdc pixpang.prg
move pixpang.dcb ..\main.dcb
cd ..
pause

echo Compilando fpgs....
start /wait compilarfpgs.bat 16

cd fpg
ren *.fpg *.fpg.gz
..\..\utils\gzip -d *.fpg.gz
cd monstruos
ren *.fpg *.fpg.gz
..\..\utils\gzip -d *.fpg.gz
cd ..\..

echo Exportando...
mkdir export
echo Copiando base de bennu-android...
xcopy /r/e/y ..\bennu-android .\export

rem echo Generamos local.properties
rem echo sdk.dir=%dirbase%/utils/android-sdk > export\local.properties

echo Creando carpetas...
mkdir export\assets\fpg
mkdir export\assets\fpg\monstruos
mkdir export\assets\ogg
mkdir export\assets\fnt
mkdir export\assets\wav
mkdir export\assets\tour
mkdir export\assets\fondos
mkdir export\assets\fondos\monstruos

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
copy fpg\monstruos\*.fpg export\assets\fpg\monstruos /y
copy ogg\*.ogg export\assets\ogg /y
copy wav\*.wav export\assets\wav /y
copy tour\*.pang export\assets\tour /y
copy fondos\*.png export\assets\fondos /y
copy fondos\monstruos\*.png export\assets\fondos\monstruos /y
copy main.dcb export\assets /y
echo Exportado correctamente. Ahora se instalar� en el m�vil...
pause
cd export
if exist c:\pixjuegos.keystore call ant release install
if not exist c:\pixjuegos.keystore call ant debug install
pause