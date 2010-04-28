program prueba;
const
	wii=0;
	buzz=1;
global
	wavs[11]; //1:bigbuzz,2:done,3:right,4:wrong,5:select1,6:select2,7:select3,8:select4,9:tfinish,10:timeclac,11:timeclic
	fnts[4]; //1: 7segment_30, 2:almateen_12, 3:bluestone_30, 4:conta
	
	struct jugador[4];
		char botones[5]; //[botones: (rojo 1, resto 2-5)] 		
		char boton_suelto;
		char rebote; //si ha fallado, rebota
		puntos;
		acertadas; //estadisticas??
		erroneas; //estadisticas??
	end
	
	sonido; //id del sonido reproduciendose
	correcta;
	ready; //servirá para que pause el texto ssi alguien pulsa el botón
	jugadores; //1 o 4
	
	txts[4]; //0: pregunta, 1-4 respuestas
	id_txts[4]; //ids de los writes de los textos de las preguntas
	
local
	i;
	
begin
	//seteo de pantalla
	full_screen=1;
	if(wii) scale_resolution=06400480; end //Wii? Por qué no? :D
	set_mode(1024,768,32);
	frame; //lo inicializamos previo a cargar recursos gráficos
	
	//cargamos recursos: fpg, fnt, wav
	load_fpg("quizz.fpg");
	from i=1 to 4; fnts[i]=load_fnt(i+".fnt"); end
	from i=1 to 11; wavs[i]=load_wav(i+".wav"); end
	
	//para los controles
	controlador(); 
	
	presentacion();
End

Process presentacion();
Begin
	x=512; y=384; z=-1;
	graph=23;
	
	put_screen(0,21);
	play_song(load_song("aperture.xm"),-1);
	while(!(key(_enter) or jugador[1].botones[1] or jugador[2].botones[1] or jugador[3].botones[1] or jugador[4].botones[1])) frame; end
	fade_music_off(100);
	from alpha=255 to 0 step -5; size-=10; angle+=5000; frame; end
	
	play_song(load_song("quizz.xm"),-1);
	
	ronda();
end

process ronda();
Private;
	boton; //para comprobaciones
	j;
Begin
	//reiniciamos los rebotes
	from i=1 to 4; jugador[x].rebote=0; end
	
	//quitamos los textos de la anterior pregunta
	from i=0 to 4; delete_text(id_txts[i]);
	
	
	x=512; y=384; z=-1;
	ready=1;
	loop
		from i=1 to 4; 
			if(jugador[i].botones[1] and jugador[i].rebote==0)
				parpadeo();
				graph=31;
				
				play_wav(wavs[1],0);
				ready=0;

				while(boton==0)
					from j=2 to 5;
						if(jugador[i].botones[j]) boton=j; end
					end
					frame; 
				end
				
				from alpha=255 to 50 step -20; size-=10; frame; end
				
				parpadeo();
				
				if(boton==correcta) 
					jugador[i].puntos++; 
					put_screen(0,4);
					sonido=play_wav(wavs[7],0);
					parpadeo();
					while(is_playing_wav(sonido)) frame; end
					frame(3000);

					ronda();
					return;
				else
					jugador[i].rebote=1;
					put_screen(0,24);
					sonido=play_wav(wavs[4],0);
					parpadeo();
				end
		    end
		end
		frame;
	end
End

process parpadeo();
begin
	graph=25;
	x=512; y=384;
	z=-5;
	frame;
end

Process pon_pregunta();
Begin
	loop
		while(!ready) frame; end
		frame;
	end
End

Process controlador();
Private
	j;
Begin
	//Por ahora si no hay buzzers, sólo jugará 1
	if(buzz) jugadores=4; else jugadores=1; end
	
	loop
		if(buzz)
			from i=1 to 4;
				from j=1 to 5;
					if(get_joy_button(0,(i-1*5)+(j-1))) //comprobamos todos los botones de todos.
						if(jugador[i].boton_suelto) //si ha soltado el botón, podrá volver a pulsarlo
							jugador[i].botones[j]=1; 
							jugador[i].boton_suelto=0; 
						else //si está aguantando el botón, no le hacemos caso
							jugador[i].botones[j]=0;
						end
					else //si lo ha soltado, ya podremos darle al botón de nuevo, pero seguimos sin hacerle caso
						jugador[i].boton_suelto=1;
						jugador[i].botones[j]=0;
					end
				end
			end
		else
			//con teclado?
		end
		frame;
	end
End