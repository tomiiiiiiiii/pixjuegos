@echo off
call ..\utils\entorno.bat vilanet2013

rd /s /q export
echo Compilando...
cd src
..\..\bennu-win\bgdc vilanet2013.prg
move vilanet2013.dcb ..\main.dcb
cd ..

echo Compilando fpgs....
call compilarfpgs.bat 16
call ..\scripts\descomprimefpgs.bat

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

echo Exportado correctamente. Ahora se instalar? en el m?vil...

cd export
..\..\scripts\genera-apk.bat
pause