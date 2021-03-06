@echo off
call ..\utils\entorno.bat pixfrogger2

rd /s /q export
echo Compilando...
cd src
..\..\bennu-win-old\bgdc client.prg
move client.dcb ..\main.dcb
cd ..
rem pause

rem echo Compilando fpgs....
rem call compilarfpgs.bat 16
rem call ..\scripts\descomprimefpgs.bat

rem echo Compilando fnts...
rem cd fnt-sources
rem copy ..\..\utils\pxlfnt.dcb . /y
rem ..\..\bennu-win\bgdi pxlfnt 16 puntos-md
rem del /f pxlfnt.dcb
rem cd ..

echo Exportando...
mkdir export
echo Copiando base de bennu-android...
xcopy /r/e/y ..\bennu-android-4.1 .\export

echo Creando carpetas...
mkdir export\assets\fpg
mkdir export\assets\fnt
mkdir export\assets\wav

echo Copiando recursos de android...
copy recursos\android\xdpi.png export\res\drawable-xhdpi\icon.png /y
copy recursos\android\hdpi.png export\res\drawable-hdpi\icon.png /y
copy recursos\android\ldpi.png export\res\drawable-ldpi\icon.png /y
copy recursos\android\mdpi.png export\res\drawable-mdpi\icon.png /y

copy recursos\android-client\strings.xml export\res\values\strings.xml /y
copy recursos\android-client\AndroidManifest.xml export\ /y
copy recursos\android-client\build.xml export\ /y

mkdir export\src\com
xcopy /r/e/y recursos\android-client\com export\src\com

if exist c:\pixjuegos.build.properties copy c:\pixjuegos.build.properties export\build.properties /y

echo Copiando el juego...
copy load-md-portrait.png export\assets /y
copy fnt\textos2.fnt export\assets\fnt /y
copy fpg\pixfrogger-md.fpg export\assets\fpg /y
copy wav\*.wav export\assets\wav /y
copy main.dcb export\assets /y
echo Exportado correctamente. Ahora se instalar? en el m?vil...
cd export
if exist c:\pixjuegos.keystore call ant release install
if not exist c:\pixjuegos.keystore call ant debug install
pause