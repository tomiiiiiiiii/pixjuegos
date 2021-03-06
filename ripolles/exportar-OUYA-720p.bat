@echo off
call ..\utils\entorno.bat ripolles

rd /s /q export
echo Compilando...
cd src
..\..\bennu-win\bgdc -D OUYA=1 ripolles.prg
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
mkdir export\res\drawable-es
mkdir export\res\drawable-ca
mkdir export\res\raw\
mkdir export\src\org\bennugd\
mkdir export\src\org\bennugd\iap

echo Copiando recursos de android...
copy recursos\android\hdpi.png export\res\drawable-hdpi\icon.png /y
copy recursos\android\ldpi.png export\res\drawable-ldpi\icon.png /y
copy recursos\android\mdpi.png export\res\drawable-mdpi\icon.png /y
copy recursos\android\xhdpi.png export\res\drawable-xhdpi\icon.png /y
copy recursos\android\ouya_icon.png export\res\drawable-xhdpi\ouya_icon.png /y
copy recursos\android\ouya_icon_es.png export\res\drawable-es\ouya_icon.png /y
copy recursos\android\ouya_icon_ca.png export\res\drawable-ca\ouya_icon.png /y
copy ..\claves-iap-ouya\ripolles.der export\res\raw\key.der /y
copy recursos\android\iap.java export\src\org\bennugd\iap\iap.java /y

copy recursos\android\strings.xml export\res\values\strings.xml /y
mkdir export\res\values-es
copy recursos\android\strings-es.xml export\res\values-es\strings.xml /y
copy recursos\android\AndroidManifest.xml export\AndroidManifest.xml /y

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
copy loading2.png export\assets /y
echo Exportado correctamente. Ahora se instalar? en el m?vil...

cd export
..\..\scripts\genera-apk.bat
pause