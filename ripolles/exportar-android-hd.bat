@echo off
call ..\utils\entorno.bat ripolles

rd /s /q export
echo Compilando...
cd src
..\..\bennu-win-old\bgdc -DTACTIL=1 ripolles.prg
move ripolles.dcb ..\main.dcb
cd ..
pause

call compilarfpgs 16
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
copy recursos\android\xhdpi.png export\res\drawable-xhdpi\icon.png /y
copy recursos\android\ouya_icon.png export\res\drawable-xhdpi\ouya_icon.png /y

copy recursos\android\strings.xml export\res\values\strings.xml /y
copy recursos\android\AndroidManifest.xml export\ /y
copy recursos\android\build.xml export\ /y

mkdir export\src\com
xcopy /r/e/y recursos\android\com export\src\com

echo Copiando el juego...
copy fpg\*.fpg export\assets\fpg /y
copy ogg\*.ogg export\assets\ogg /y
copy wav\*.wav export\assets\wav /y
copy fnt\*.fnt export\assets\fnt /y
copy main.dcb export\assets /y
copy loading.png export\assets /y
echo Exportado correctamente. Ahora se instalará en el móvil...


cd export
cmd /c if exist c:\pixjuegos.keystore ant release install
cmd /c if not exist c:\pixjuegos.keystore ant debug install
pause