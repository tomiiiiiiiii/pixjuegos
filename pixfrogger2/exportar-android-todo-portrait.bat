@echo off
call ..\utils\entorno.bat pixfrogger2

rd /s /q export
echo Compilando...
cd src
..\..\bennu-win-old\bgdc pixfrogger.prg
move pixfrogger.dcb ..\main.dcb
cd ..
pause

echo Compilando fpgs....
cd fpg-sources
copy /y ..\..\utils\pxlfpg.dcb .
..\..\bennu-win\bgdi pxlfpg 16 pixfrogger-hd-portrait pixfrogger-md-portrait pixfrogger-ld-portrait

del /f pxlfpg.dcb
cd ..\fpg
ren pixfrogger-hd-portrait.fpg pixfrogger-hd-portrait.fpg.gz
ren pixfrogger-md-portrait.fpg pixfrogger-md-portrait.fpg.gz
ren pixfrogger-ld-portrait.fpg pixfrogger-ld-portrait.fpg.gz
..\..\utils\gzip -d pixfrogger-hd-portrait.fpg.gz
..\..\utils\gzip -d pixfrogger-md-portrait.fpg.gz
..\..\utils\gzip -d pixfrogger-ld-portrait.fpg.gz
cd ..

echo Compilando fnts...
cd fnt-sources
copy ..\..\utils\pxlfnt.dcb . /y
..\..\bennu-win\bgdi pxlfnt 16 puntos-hd puntos-ld puntos-md
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

copy recursos\android\strings.xml export\res\values\strings.xml /y
copy recursos\android\AndroidManifest.xml export\ /y
copy recursos\android\build.xml export\ /y

mkdir export\src\com
xcopy /r/e/y recursos\android\com export\src\com

echo Copiando el juego...
copy load-ld-portrait.png export\assets /y
copy load-md-portrait.png export\assets /y
copy load-hd-portrait.png export\assets /y
copy fnt\puntos-hd.fnt export\assets\fnt /y
copy fnt\puntos-md.fnt export\assets\fnt /y
copy fnt\puntos-ld.fnt export\assets\fnt /y
copy fpg\pixfrogger-hd-portrait.fpg export\assets\fpg /y
copy fpg\pixfrogger-md-portrait.fpg export\assets\fpg /y
copy fpg\pixfrogger-ld-portrait.fpg export\assets\fpg /y
copy ogg\*.ogg export\assets\ogg /y
copy wav\*.wav export\assets\wav /y
copy main.dcb export\assets /y
echo Exportado correctamente. Ahora se instalará en el móvil...
cd export
if exist c:\pixjuegos.keystore call ant release install
if not exist c:\pixjuegos.keystore call ant debug install
pause
adb shell am start -n com.pixjuegos.pixfrogger/com.pixjuegos.pixfrogger.PiXFrogger