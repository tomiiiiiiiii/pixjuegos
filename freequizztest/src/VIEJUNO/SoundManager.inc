/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Process InitSounds();
Private
	i=0;
Begin
	sound_freq=44100;
	from i=0 to MAX_MUSICS-1;
		musics[i]=load_song(GlobalOptions.MusicPath+szMusics[i]);
	end
	from i=0 to MAX_SOUNDS-1;
		wavs[i]=load_wav(GlobalOptions.SoundPath+szSounds[i]+".wav");
	end
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Process EndSounds();
Private
	i=0;
Begin
	from i=0 to MAX_MUSICS-1;
		unload_song(musics[i]);
	end
	from i=0 to MAX_SOUNDS-1;
		unload_wav(wavs[i]);
	end
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Function PlayMusic(eMusic, int bRepeat, int bFadeIn);
Private
	iRepeats=-1;
	iFadeInTime=1000;
Begin
	if(iIDCurrentMusic!=-1)
		stop_song();
	end
	if(GlobalOptions.bMusic)
		iIDCurrentMusic=musics[eMusic];
		if(!bRepeat)
			iRepeats=0;
		end
		if(bFadeIn)
			fade_music_in(iIDCurrentMusic, iRepeats, iFadeInTime);
		else
			play_song(iIDCurrentMusic,iRepeats);
		end
	end	
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Function StopMusic(bFadeOut);
Private
	iFadeOutTime=1000;
Begin
	if(iIDCurrentMusic!=-1)
		if(bFadeOut)
			fade_music_off(iFadeOutTime);
		else
			stop_song();
		end		
	end
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Process PlaySound(eSoundIdx);
Begin
	if(GlobalOptions.bSound)
		play_wav(wavs[eSoundIdx],0);
	end
End