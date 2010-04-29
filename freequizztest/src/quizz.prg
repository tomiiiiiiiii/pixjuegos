program prueba;
const
	wii=0;
	buzz=1;
global
	wavs[11]; //1:bigbuzz,2:done,3:right,4:wrong,5:select1,6:select2,7:select3,8:select4,9:tfinish,10:timeclac,11:timeclic
	fnts[4]; //1: 7segment_30, 2:almateen_12, 3:bluestone_30, 4:conta
	
	struct jugador[4];
		botones[4]; //[botones: (rojo 0, resto 1-4)] 		
		boton_suelto;
		rebote; //si ha fallado, rebota
		puntos;
		acertadas; //estadisticas??
		erroneas; //estadisticas??
		juega;
	end
	
	sonido; //id del sonido reproduciendose
	correcta=1;
	ready; //servirá para que pause el texto ssi alguien pulsa el botón
	jugadores; //desde 1 a 4
	
	txts[4]; //0: pregunta, 1-4 respuestas
	id_txts[4]; //ids de los writes de los textos de las preguntas
	
local
	i;
	
begin
	//say();
	//seteo de pantalla
	full_screen=1;
	if(wii) scale_resolution=06400480; end //Wii? Por qué no? :D
	set_fps(60,0);
	set_mode(1024,768,32);
	frame; //lo inicializamos previo a cargar recursos gráficos
	
	//cargamos recursos: fpg, fnt, wav
	load_fpg("quizz.fpg");
	from i=1 to 4; fnts[i]=load_fnt(i+".fnt"); end
	from i=1 to 11; wavs[i]=load_wav(i+".wav"); end

	//Por ahora si no hay buzzers, sólo jugará 1
//	if(buzz) jugadores=4; else jugadores=1; end
	
	//para los controles
	controlador(); 
	
	presentacion();
End

Process presentacion();
Private
	grav;
Begin
	x=512; y=384; z=-1;
	graph=23;
	
	put_screen(0,21);
	play_song(load_song("aperture.xm"),-1);

	loop
		if(jugadores>0 and key(_enter)) break; end
		from i=1 to 4; if(jugador[i].botones[0] and !jugador[i].juega) jugador[i].juega=1; jugadores++; para_jugar(i); end end
		frame;
	end
	//para que desaparezcanlos botoncicos de los jugadores
	ready=1;

	//quitamos la música en medio segundo
	fade_music_off(50);

	//transición chula
	set_center(0,23,1024,0);
	x=1024;
	y=0;
	while(angle<90000) angle+=(grav/2)*300; grav++; frame; end
	
	play_song(load_song("quizz.xm"),-1);
	
	ronda();
end

process ronda();
Private;
	boton; //para comprobaciones
	num_rebotes;
	j;
Begin
	//reiniciamos los rebotes
	from i=1 to 4; jugador[i].rebote=0; end
	
	//quitamos los textos de la anterior pregunta
	from i=0 to 4; delete_text(id_txts[i]); end
	
	
	x=512; y=200; z=-1;
	ready=1;
	loop
		from i=1 to 4; 
		  if(jugador[i].juega)
			if(jugador[i].botones[0] and jugador[i].rebote==0)
				parpadeo();
				graph=30+i; // Esto será un icono de "JUGADOR 1" y cosas asín...
				
				play_wav(wavs[1],0);
				ready=0;

				frame(2000);
				from alpha=255 to 50 step -20; size-=5; frame; end
				size=0;
				
				while(boton==0)
					from j=1 to 4;
						if(jugador[i].botones[j]) boton=j; end
					end
					frame; 
				end
				
				play_wav(wavs[boton+4],0);
						
				size=100;
				alpha=255;
				graph=3;
				x=512;
				y=718-((boton-1)*78);
				frame(6000);
				
				if(boton==correcta)
					jugador[i].puntos++; 
					sonido=play_wav(wavs[3],0);
					parpadeo();
					graph=4;
					while(is_playing_wav(sonido)) frame; end
					frame(3000);
					ronda();
					return;
				else //rebote!
					parpadeo();
					jugador[i].rebote=1;
								
					//put_screen(0,24);
					sonido=play_wav(wavs[4],0);
		
					num_rebotes=0;
					from i=1 to 4; if(jugador[i].rebote or !jugador[i].juega) num_rebotes++; end end
					if(num_rebotes==4) //fail...
						//podríamos dar la solución... o no?
						ronda(); 
						return; 
					end
					
					
					ready=1;
					boton=0;
					graph=0;
					size=100;
					alpha=255;
					x=512;
					y=200;
				end
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
	frame(300);
end

Process pon_pregunta();
Begin
	//importante! las respuestas deben aparecer de abajo arriba!
	loop
		while(!ready) frame; end
		frame;
	end
End

Process controlador();
Private
	j;
Begin
	loop
		if(buzz)
			from i=1 to 4;
				from j=0 to 4;
					if(jugador[i].boton_suelto and get_joy_button(0,((i-1)*5)+(j))) //comprobamos todos los botones de todos.
						jugador[i].botones[j]=1;
						jugador[i].boton_suelto=0;
					else
						jugador[i].botones[j]=0;
					end
				end
				if(!(get_joy_button(0,((i-1)*5)) or get_joy_button(0,(((i-1)*5)+1)) or get_joy_button(0,(((i-1)*5)+2)) or get_joy_button(0,(((i-1)*5)+3)) or get_joy_button(0,(((i-1)*5)+4))))
					jugador[i].boton_suelto=1;
				end
			end
		else
			//con teclado?
		end
		frame;
	end
End

Process para_jugar(num);
Begin
	x=512-500+(num*200);
	y=600;
	z=-2;
	graph=30+num;
	size=30;
	alpha=200;
	while(ready==0)
		if(size<50) size+=2; end
		if(alpha<255) alpha+=5; end
		frame;
	end
	from size=50 to 40 step -2; alpha-=5; frame; end
End