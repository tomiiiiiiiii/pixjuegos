@echo off
call ..\utils\entorno.bat pixdash

rd /s /q export
echo Compilando...
cd src
..\..\bennu-win-old\bgdc -DANDROID=1 pixdash.prg
move pixdash.dcb ..\main.dcb
cd ..

echo Compilando fpgs....
call compilarfpgs.bat 16

call ..\scripts\descomprimefpgs.bat
cd fpg
ren durezas.fpg.gz durezas.fpg
cd ..

echo Exportando...
mkdir export
echo Copiando base de bennu-android...
xcopy /r/e/y ..\bennu-android-4.1 .\export

rem echo Generamos local.properties
rem echo sdk.dir=%dirbase%/utils/android-sdk > export\local.properties

echo Creando carpetas...
mkdir export\assets\fpg
mkdir export\assets\ogg
mkdir export\assets\fnt
mkdir export\assets\wav
mkdir export\assets\tour
mkdir export\assets\niveles
mkdir export\assets\fondos

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
copy fnt\*.fnt export\assets\fnt /y
copy fpg\*.fpg export\assets\fpg /y
copy ogg\*.ogg export\assets\ogg /y
copy wav\*.wav export\assets\wav /y
REM FALTAN FONDOS EN PNG?

cd fondos
FOR %%i in (*.jpg) DO CALL ..\bin\convert.exe %%i ..\export\assets\fondos\%%i.png
cd ..

xcopy /r/e/y niveles export\assets\niveles
copy main.dcb export\assets /y
echo Exportado correctamente. Ahora se instalará en el móvil...

cd export
..\..\scripts\genera-apk.bat
pause