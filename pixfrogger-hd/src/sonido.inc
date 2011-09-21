Process carga_sonidos();
Begin
	from i=1 to 50;
		wavs[i]=load_wav("wav/"+i+".wav");
	end
End

Process sonido(num);
Begin
	if(ops.sonido)
		play_wav(wavs[num],0);
	end
End