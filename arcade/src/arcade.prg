import "mod_blendop";
import "mod_debug";
import "mod_dir";
import "mod_draw";
import "mod_file";
import "mod_grproc";
import "mod_joy";
import "mod_key";
import "mod_map";
import "mod_math";
import "mod_proc";
import "mod_rand";
import "mod_regex";
import "mod_say";
import "mod_screen";
import "mod_scroll";
import "mod_sound";
import "mod_string";
import "mod_sys";
import "mod_text";
import "mod_timers";
import "mod_video";
import "mod_wm";

Global
	arcade_mode=0;

	ancho_pantalla=800;
	alto_pantalla=600;
	
	opcion=1;
	
	njoys;
	posibles_jugadores;
	debuj;
	struct p[5];
		botones[7];
		control;
	end
	joysticks[10];
	sonidos[1];

	juegos[]=0,7,3,2,1,4,5;
	num_juegos=6;
	
	cancion;
	
Local
	i;j;
	
include "../../common-src/controles.pr-";
Begin
	configurar_controles();
	controlador(0);
	inicio();
	sonidos[0]=load_wav("1.wav"); //mover
	sonidos[1]=load_wav("2.wav"); //elegir
	musica(juegos[1]);
	loop
		timer[0]=0;
		while(timer[0]<6000)
			frame;
		end
		cambiar_opcion(1);
	end
End

Function suena(id_sonido);
Begin
	play_wav(sonidos[id_sonido],0);
End

Function musica(id_musica);
Begin
	if(is_playing_song()) stop_song(); end
	frame;
	if(cancion!=0) unload_song(cancion); end
	cancion=load_song(id_musica+".ogg");
	play_song(cancion,-1);
End

Process inicio();
Begin
	full_screen=1;
	set_mode(800,600,32);
	set_fps(50,9);
	load_fpg("fpg/arcade.fpg");
	
	flecha(0); flecha(1);
	actual();
End

Process actual();
Begin
	x=400;
	y=300;
	z=1;
	//flecha(0); flecha(1);
	graph=juegos[opcion];
	while(timer[0]<6000)
		if(p[0].botones[b_izquierda]) cambiar_opcion(0); break; end
		if(p[0].botones[b_derecha]) cambiar_opcion(1); break; end
		if(p[0].botones[b_1] or p[0].botones[b_2] or p[0].botones[b_3]) suena(1); from size=100 to 120; alpha-=10; frame; end ejecutar(); end
		if(key(_esc)) say("salir"); exit(); end
		frame;
	end
End

Function cambiar_opcion(tipo);
Begin
	timer[0]=0;
	suena(0); 
	if(tipo==1) 
		enmovimiento(2); enmovimiento(3);	
		opcion++; 
	else
		enmovimiento(0); enmovimiento(1);
		opcion--; 
	end
	if(opcion>num_juegos) opcion=1; end
	if(opcion<1) opcion=num_juegos; end
	musica(juegos[opcion]);
End

Process ejecutar();
Private
	string argumentos;
	string juego;
Begin
	let_me_alone();
	argumentos='arcade';
	switch(juegos[opcion])
		case 1: juego="pixbros"; end
		case 2: juego="pixpang"; end
		case 3: juego="garnatron"; end
		case 4: juego="pixfrogger"; end
		case 5: juego="pixdash"; end
		case 6: juego="eterno-retorno"; end
		case 7: juego="ripolles"; end
		case 8: juego="eterno-retorno-3"; end
	end
	say(juego);
	exit();
	//chdir("../"+juego);
	//exec(_P_WAIT,"./"+juego,1,&argumentos);
	//chdir("../arcade");
	//exec(_P_NOWAIT,"./arcade",1,&argumentos);
End

Process flecha(flags);
Private
	inercia;
Begin
	graph=100;
	y=300;
	z=-1;
	if(flags==0) x=700; end
	if(flags==1) x=100; end
	while(exists(father))
		inercia++;
		if(flags==0)
			x+=inercia;
		else
			x-=inercia;
		end
		frame;
	end
End

Process enmovimiento(tipo);
Begin
	y=300;
	switch(tipo)
		case 0: flecha(1); graph=juegos[opcion]; x=400; end
		case 1: graph=juegos[resuelve_opcion(opcion-1)]; x=-400; end
		case 2: flecha(0); graph=juegos[opcion]; x=400; end
		case 3: graph=juegos[resuelve_opcion(opcion+1)]; x=1200; end
	end	
	loop
		switch(tipo)
			case 0:
				if(x<1200) x+=((1200-x)/10)+5; else x=1200; break; end
			end
			case 1:
				if(x<400) x+=((400-x)/10)+5; else x=400; break; end
			end
			case 2:
				if(x>-400) x+=((-400-x)/10)-5; else x=-400; break; end //ESTE FUNCIONA
			end
			case 3:
				if(x>400) x-=((x-400)/10)+5; else x=400; break; end
			end
		end
		frame;
	end
	if(tipo==1 or tipo==3) actual(); end
End

Function salir_android();
Begin End

Function resuelve_opcion(a);
Begin
	if(a==0)
		return num_juegos;
	elseif(a==num_juegos+1)
		return 1;
	else
		return a;
	end
End