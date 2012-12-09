@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc pixfrogger.prg
move pixfrogger.dcb ..
cd ..
echo Exportando...
mkdir export
mkdir export\fpg
mkdir export\ogg
mkdir export\fnt
mkdir export\wav
copy fpg\*.fpg export\fpg
copy ogg\*.ogg export\ogg
copy wav\*.wav export\wav
copy fnt\*.fnt export\fnt
REM copy ..\bennu-win\*.dll export
copy ..\bennu-win\mod_dir.dll export
copy ..\bennu-win\mod_draw.dll export
copy ..\bennu-win\mod_file.dll export
copy ..\bennu-win\mod_grproc.dll export
copy ..\bennu-win\mod_joy.dll export
copy ..\bennu-win\mod_key.dll export
copy ..\bennu-win\mod_map.dll export
copy ..\bennu-win\mod_math.dll export
copy ..\bennu-win\mod_mouse.dll export
copy ..\bennu-win\mod_proc.dll export
copy ..\bennu-win\mod_rand.dll export
copy ..\bennu-win\mod_regex.dll export
copy ..\bennu-win\mod_screen.dll export
copy ..\bennu-win\mod_sound.dll export
copy ..\bennu-win\mod_sys.dll export
copy ..\bennu-win\mod_text.dll export
copy ..\bennu-win\mod_timers.dll export
copy ..\bennu-win\mod_video.dll export
copy ..\bennu-win\mod_wm.dll export
copy ..\bennu-win\libeay32.dll export
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


copy ..\bennu-win\bgdi.exe export\pixfrogger.exe
copy pixfrogger.dcb export
cd export
echo DEBES ELEGIR EL PIXfrogger.EXE
..\..\bennu-win\pakator 
move pixfrogger_exe_pak.exe ..\pixfrogger.exe
cd ..
echo LISTO!!
exit
pause