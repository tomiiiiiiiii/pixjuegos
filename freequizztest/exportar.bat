@echo off
set PROYECTO=quizz
cd src
echo Compilando...
..\..\bennu-win\bgdc quizz.prg
move quizz.dcb ..
cd ..

call compilarfpgs.bat 16
echo Exportando...
mkdir export
mkdir export\fpg
mkdir export\xm
mkdir export\fnt
mkdir export\wav
mkdir export\quizz
mkdir export\quizz\base
mkdir export\vlc

copy fpg\*.fpg export\fpg
copy xm\*.xm export\xm
copy wav\*.wav export\wav
copy fnt\*.fnt export\fnt
copy quizz\base\*.* export\quizz\base

rem copy ..\bennu-win\*.dll export
copy ..\bennu-win\mod_file.dll export
copy ..\bennu-win\mod_grproc.dll export
copy ..\bennu-win\mod_joy.dll export
copy ..\bennu-win\mod_key.dll export
copy ..\bennu-win\mod_map.dll export
copy ..\bennu-win\mod_proc.dll export
copy ..\bennu-win\mod_screen.dll export
copy ..\bennu-win\mod_sound.dll export
copy ..\bennu-win\mod_string.dll export
copy ..\bennu-win\mod_text.dll export
copy ..\bennu-win\mod_timers.dll export
copy ..\bennu-win\mod_video.dll export
copy ..\bennu-win\mod_wm.dll export
copy ..\bennu-win\mod_vlc.dll export
copy ..\bennu-win\libbgdrtm.dll export
copy ..\bennu-win\libblit.dll export
copy ..\bennu-win\libdraw.dll export
copy ..\bennu-win\libfont.dll export
copy ..\bennu-win\libgrbase.dll export
copy ..\bennu-win\libimage.dll export
copy ..\bennu-win\libjoy.dll export
copy ..\bennu-win\libkey.dll export
copy ..\bennu-win\libmouse.dll export
copy ..\bennu-win\libpng-3.dll export
copy ..\bennu-win\librender.dll export
copy ..\bennu-win\libsdlhandler.dll export
copy ..\bennu-win\libtext.dll export
copy ..\bennu-win\libvideo.dll export
copy ..\bennu-win\libwm.dll export
copy ..\bennu-win\SDL.dll export
copy ..\bennu-win\SDL_mixer.dll export
copy ..\bennu-win\vorbis.dll export
copy ..\bennu-win\vorbisfile.dll export
copy ..\bennu-win\ogg.dll export
copy ..\bennu-win\libvlc.dll export
copy ..\bennu-win\libvlccore.dll export

copy vlc\*.dll export\vlc
copy vlc\*.dat export\vlc
copy ..\bennu-win\bgdi.exe export\quizz.exe

copy quizz.dcb export

cd export
echo DEBES ELEGIR EL quizz.EXE
..\..\bennu-win\pakator 
move quizz_exe_pak.exe ..\
cd ..
echo LISTO!!
exit
pause