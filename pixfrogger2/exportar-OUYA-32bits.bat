@echo off
call ..\utils\entorno.bat pixfrogger2

set run=com.pixjuegos.pixfrogger/.PiXFrogger

rd /s /q export
echo Compilando...
cd src
..\..\bennu-win-old\bgdc -D OUYA=1 pixfrogger.prg
move pixfrogger.dcb ..\main.dcb
cd ..
pause

echo Compilando fpgs....
call compilarfpgs.bat 32
call ..\scripts\descomprimefpgs.bat

echo Compilando fnts...
cd fnt-sources
copy ..\..\utils\pxlfnt.dcb . /y
..\..\bennu-win\bgdi pxlfnt 32 puntos-hd puntos-ld puntos-md
del /f pxlfnt.dcb
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
copy recursos\android\xhdpi.png export\res\drawable-xhdpi\icon.png /y
copy recursos\android\ouya_icon.png export\res\drawable-xhdpi\ouya_icon.png /y

copy recursos\android\strings.xml export\res\values\strings.xml /y
copy recursos\android\AndroidManifest.ouya.xml export\AndroidManifest.xml /y
copy recursos\android\SDLActivity.ouya.java export\src\org\libsdl\app\SDLActivity.java /y
copy recursos\android\build.xml export\ /y

mkdir export\src\com
xcopy /r/e/y recursos\android\com export\src\com

echo Copiando el juego...
copy fpg\pixfrogger-ouya.fpg export\assets\fpg\pixfrogger-hd.fpg /y
copy fpg\pixfrogger-ouya-8players.fpg export\assets\fpg /y
copy fpg\puntos-hd.fpg export\assets\fpg /y
copy fpg\textos-hd.fpg export\assets\fpg /y
copy ogg\*.ogg export\assets\ogg /y
copy wav\*.wav export\assets\wav /y
copy main.dcb export\assets /y
echo Exportado correctamente. Ahora se instalará en el móvil...
cd export
call ..\..\scripts\genera-apk.bat
pause