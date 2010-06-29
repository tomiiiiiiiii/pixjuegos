@echo off
echo Exportando para Wii...
mkdir export
mkdir export\fpg
mkdir export\ogg
mkdir export\fnt
mkdir export\wav
mkdir export\fondos

copy src\*.pr- export\
copy src\bgdc.imp export\
copy src\pixdash.prg export\boot.prg
copy fpg\*.fpg export\fpg

cd ogg
FOR %%i in (*.ogg) DO CALL ..\..\bennu-wii\vlc\vlc.exe -I dummy %%i --sout=#transcode{acodec=vorb,ab=96,channels=2,samplerate=32000}:duplicate{dst=std{access=file,mux=ogg,dst='..\export\ogg\%%i'} vlc://quit
cd ..\wav
FOR %%i in (*.wav) DO CALL ..\..\bennu-wii\vlc\vlc.exe -I dummy %%i --sout=#transcode{vcodec=none,acodec=s16l,ab=96,channels=2,samplerate=32000}:duplicate{dst=std{access=file,mux=wav,dst='..\export\wav\%%i'} vlc://quit
cd ..

copy fnt\*.fnt export\fnt

copy ..\bennu-wii\bgdi.elf export\boot.elf

copy fondos\*.png export\fondos

cd fondos
FOR %%i in (*.jpg) DO CALL ..\bin\convert.exe %%i ..\export\fondos\%%i.png
cd ..
echo Exportación finalizada...
pause
echo Ahora mete la tarjeta SD en el PC y copia la carpeta export a \apps\ . Luego renómbrala a pixdash.
pause
echo Ahora mete la tarjeta SD en la Wii y abre el homebrew channel (wiiload debe estar configurado)
wiiload ..\bennu-wii\bgdc.elf WII=1 \apps\pixdash\boot.prg
echo Listo!