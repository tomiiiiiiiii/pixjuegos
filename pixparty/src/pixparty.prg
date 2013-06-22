Program scnj;

import "mod_blendop";
//import "mod_debug";
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
	ready;
	bpp=32;
	njoys;
	posibles_jugadores;
	debuj;
	ancho_pantalla;
	alto_pantalla;
	struct p[5];
		botones[10];
		copas;
		chupitos;
		control; 
		juega;
		id;
		casilla;
		posicion;
	end
	struct p4j[4];
		id;
	end
	struct casillas[100];
		x;
		y;
		tipo;
	end
	joysticks[10];
	ogg;
	
	fpg_general;
	fpg_minijuego;
	toma_pantalla;
	
	juego_actual=1;
	contador_casillas;
	turno=1;
	espera_evento;
	
	posiciones[4];
	mini_juegos_jugados[20];
	txt[10];
	h1; h2; h3;
	sonidos[10];
End //global

Local
	i; j;
	grav;
End

include "../../common-src/controles.pr-";
include "../../common-src/resolucioname.pr-";
include "mlunar.prg";
include "mfrogger.prg";
include "mpisarcabezas.prg";
include "mplataformas.prg";
include "mpong.prg";
include "mscorched.prg";

Begin
	full_screen=true;
	//scale_resolution=10240600;
	resolucioname(1280,720,1);
	set_mode(1280,720,bpp);
	set_fps(40,1);
	
	x=640; y=360; z=-512;
	graph=load_png("loading.png");
	from alpha=0 to 255 step 10; frame; end
	configurar_controles();
	
	
	from i=1 to 2; 
		sonidos[i]=load_wav(i+".wav");
	end
	
	fpg_general=load_fpg("scnj.fpg");
	h1=load_fnt("h1.fnt");
	
	while(timer[0]<400) frame; end
	from alpha=255 to 0 step -10; frame; end
	unload_map(0,graph);
	graph=0;
	fade_off();
	while(fading) frame; end
	alpha=255;
	fade_on();
	musica(1);
	controlador(0);
	//menu
	i=1;
	graph=100;
	x=640;
	y=360;
	z=-10;
	loop //i elegiendo, j elegido
		if(!exists(type opcion)) opcion(); end
		if(p[0].botones[2] and i>1) while(p[0].botones[2]) frame; end i--; end
		if(p[0].botones[3] and i<4) while(p[0].botones[3]) frame; end i++; end
		if(p[0].botones[4]) 
			while(p[0].botones[4]) frame; end
			j=i;
		end
		switch(j)
			case 1: //jugar
				break; 
			end
			case 2: //ayuda
/*				graph=102;
				while(graph!=107 and !key(_esc))
					if(p[0].botones[4])
						while(p[0].botones[4]) frame; end
						graph++;
					end
					frame;
				end
				while(p[0].botones[4]) frame; end
				j=0;
				graph=100;*/
				graph=102;
				while(!p[0].botones[4]) frame; end
				while(p[0].botones[4]) frame; end
				j=0;
				graph=100;
			end
			case 3: //creditos
				graph=101;
				while(!p[0].botones[4]) frame; end
				while(p[0].botones[4]) frame; end
				j=0;
				graph=100;
			end
			case 4: //salir
				exit();
			end
		end
		frame;
	end	
	//fin menu
	transicion(1);
	pon_tablero();
End

Function ayuda();
Begin
End

Function creditos();
Begin
	x=640;
	y=360;
	z=-11;
End

Process opcion();
Begin
	z=-11;
	graph=99;
	x=460;
	while(exists(father))
		if(father.i==0 or father.j!=0) break; end
		switch(father.i)
			case 1: y=495; end
			case 2: y=560; end
			case 3: y=615;end
			case 4: y=660; end
		end
		angle+=3000;
		frame;
	end
End

Process pon_tablero();
Begin
	let_me_alone();
	delete_text(all_text);
	stop_scroll(0);
	if(fpg_minijuego>0) unload_fpg(fpg_minijuego); end
	escapable();
	put_screen(fpg_general,1);
	//grafico();
	graph=2;
	
	//RANDOM MADNESS?
		
	//avatares
	grafico(106,178,fpg_general,31,0);
	grafico(1280-106,178,fpg_general,32,1);
	grafico(106,520,fpg_general,33,0);
	grafico(1280-106,520,fpg_general,34,1);
	
	//copas y chupitos
	grafico(280,60,fpg_general,26,0);
	grafico(910,60,fpg_general,26,0);
	grafico(280,660,fpg_general,26,0);
	grafico(910,660,fpg_general,26,0);
	
	grafico(435,60,fpg_general,27,0);
	grafico(748,60,fpg_general,27,0);
	grafico(435,660,fpg_general,27,0);
	grafico(748,660,fpg_general,27,0);
	
	write(h1,320,60,3,p[1].copas);
	write(h1,485,60,3,p[1].chupitos);
	write(h1,950,60,3,p[2].copas);
	write(h1,788,60,3,p[2].chupitos);
	
	write(h1,320,660,3,p[3].copas);
	write(h1,485,660,3,p[3].chupitos);
	write(h1,950,660,3,p[4].copas);
	write(h1,788,660,3,p[4].chupitos);
	
	//casillas
	contador_casillas=0;
	casilla(270,560,0);
	casilla(355,582,3);
	casilla(433,589,1);
	casilla(510,595,5);
	casilla(587,601,4);
	casilla(666,598,1);
	casilla(738,583,1);
	casilla(801,542,3);
	casilla(846,484,1);
	casilla(868,415,3);
	casilla(866,343,1);
	casilla(847,276,1);
	casilla(810,216,5);
	casilla(751,169,2);
	casilla(681,153,1);
	casilla(611,159,1);
	casilla(551,193,4);
	casilla(511,247,5);
	casilla(490,308,1);
	casilla(488,375,3);
	casilla(510,438,1);
	casilla(561,477,5);
	casilla(625,484,4);
	casilla(687,462,1);
	casilla(736,415,1);
	casilla(752,350,2);
	casilla(718,292,1);
	casilla(655,264,4);
	casilla(590,282,3);
	casilla(577,348,2);
	casilla(600,348,0);
	controlador(1);
	controlador(2);
	controlador(3);
	controlador(4);
	
	ficha(1);
	ficha(2);
	ficha(3);
	ficha(4);
	
	transicion(2);
	musica(2);
	wait(1);
	
	i=1;
	repeat
		switch(i)
			case 1: turno_anuncio_evento("Player one's turn"); end
			case 2: turno_anuncio_evento("Player two's turn"); end
			case 3: turno_anuncio_evento("Player three's turn"); end
			case 4: turno_anuncio_evento("Player four's turn"); end
		end
		turno(i);
		i++;
	until(i>posibles_jugadores or i==5)
//	turno(1);
//	turno(2);
//	turno(3);
//	turno(4);
	
	wait(3);
	
	transicion(1);
	minijuego();
End

Process minijuego();
Begin
	musica(3);
	let_me_alone();
	clear_screen();
	delete_text(all_text);
	ready=0;	
	
	from i=1 to 4; p[i].posicion=0; end
	
	//preparacion minijuego
	
	//splash
	graph=900+juego_actual;
	x=640; y=360; z=-10;
	
	transicion(2);

	switch(juego_actual)
		case 1:	mlunar(); end
		case 2: mfrogger(); end
		case 3: mpisarcabezas(); end
		case 4: mplataformas(); end
		case 5: mpong(); end
		//case 6: mscorched(); end
	end
	
	wait(5);
	from alpha=255 to 0 step -10; frame; end
	graph=0;
	juego_actual++;
	//juego_actual=6;
	if(juego_actual>5) juego_actual=1; end
	
	//listos, empezamos!
	
	preparado();
	
	while(ready) frame; end
	//ganador
	oscurece();
	grafico_aparece(640-330,280,fpg_general,31,0);
	grafico_aparece(640-110,280,fpg_general,32,0);
	grafico_aparece(640+110,280,fpg_general,33,0);
	grafico_aparece(640+330,280,fpg_general,34,0);

	from i=1 to 4; if(p[i].posicion==1) p[i].copas++; else p[i].chupitos++; end end
	
	if(p[1].posicion==1) grafico_aparece(640-330,470,fpg_general,26,0);	else grafico_aparece(640-330,470,fpg_general,27,0);	end
	if(p[2].posicion==1) grafico_aparece(640-110,470,fpg_general,26,0);	else grafico_aparece(640-110,470,fpg_general,27,0);	end
	if(p[3].posicion==1) grafico_aparece(640+110,470,fpg_general,26,0);	else grafico_aparece(640+110,470,fpg_general,27,0);	end
	if(p[4].posicion==1) grafico_aparece(640+330,470,fpg_general,26,0);	else grafico_aparece(640+330,470,fpg_general,27,0);	end
	
	wait(3);
	transicion(1);
	pon_tablero();	
End

Function preparado();
Begin
	suena(1);
	txt[0]=write(h1,640,360,4,"Ready");
	wait(1);
	delete_text(txt[0]);
	txt[0]=write(h1,640,360,4,"Steady");
	wait(1);
	delete_text(txt[0]);
	ready=1;
	x=640; y=360; z=-5;
	graph=write_in_map(h1,"GO",4);
	musica(rand(1,5));
	from alpha=255 to 0 step -5; size+=2; frame; end
End

Function wait(secs);
Begin
	timer[0]=0; 
	while(timer[0]<secs*100) frame; end
End

Function anuncio_ganador();
Begin
End

Function casilla(x,y,tipo);
Begin
	casillas[contador_casillas].x=x;
	casillas[contador_casillas].y=y;
	
	//desafio desactivado
	if(tipo==4) tipo=1; end
	
	casillas[contador_casillas].tipo=tipo;
	
	
	
	contador_casillas++;
	
	grafico(x,y,fpg_general,tipo+20,0);
End

Function turno(jugador);
Begin
	file=fpg_general;
	x=1280/2;
	y=720/2;
	z=-6;
	while(p[jugador].botones[4] or p[jugador].botones[5] or p[jugador].botones[6]) frame; end
	while(!p[jugador].botones[4] and !p[jugador].botones[5] and !p[jugador].botones[6])
		graph=rand(11,16);
		frame;
	end
	wait(1);
	//sonido
	p[jugador].casilla+=graph-10;
	from alpha=255 to 0 step -15; frame; size--; end
	espera_evento=1;
	while(espera_evento==1) frame; end
	//from alpha=255 to 0 step -15; frame; end
	while(espera_evento!=0) frame; end
End

Process ficha(jugador);
Private
	casilla_anterior;
	n_cas_x;
	n_cas_y;
Begin
	file=fpg_general;
	graph=jugador+5;
	
	z=-3;
	x=casillas[p[jugador].casilla].x;
	y=casillas[p[jugador].casilla].y;
	
	casilla_anterior=p[jugador].casilla;
	loop
		if(casilla_anterior!=p[jugador].casilla and casilla_anterior<contador_casillas)
			if(p[jugador].casilla<0)
				p[jugador].casilla=0;
			elseif(p[jugador].casilla>contador_casillas)
				p[jugador].casilla=contador_casillas;
			end	
			
			i=0;
			
			while(casilla_anterior+i!=p[jugador].casilla)
				if(casilla_anterior+i<p[jugador].casilla)
					i++;
				else
					i--;
				end
				n_cas_x=casillas[casilla_anterior+i].x;
				n_cas_y=casillas[casilla_anterior+i].y;
				while(x!=n_cas_x or y!=n_cas_y)
					if(x!=n_cas_x)
						if(x>n_cas_x)
							//x-=3;
							x-=((x-n_cas_x)/15)+2;
							if(x<n_cas_x+2)
								x=n_cas_x;
							end
						else
							x+=((n_cas_x-x)/15)+2;
							if(x>n_cas_x-2)
								x=n_cas_x;
							end
						end
					end
					if(y!=n_cas_y)
						if(y>n_cas_y)
							y-=((y-n_cas_y)/15)+2;
							if(y<n_cas_y+2)
								y=n_cas_y;
							end
						else
							y+=((n_cas_y-y)/15)+2;
							if(y>n_cas_y-2)
								y=n_cas_y;
							end
						end
					end
					frame;
				end //while movimiento ficha
			end //fin movimientos ficha
			
			casilla_anterior=p[jugador].casilla;
			
			//eventos de casillas
			if(espera_evento!=-1) //acaba de suceder un evento, ignoramos!
				switch(casillas[p[jugador].casilla].tipo)
					case 1: //normal
						espera_evento=0;
					end
					case 2: //retraso
						espera_evento=-1;
						p[jugador].casilla-=3;
						process_anuncio_evento("Go back 3 spaces");
						if(p[jugador].casilla<0)
							espera_evento=0;
							p[jugador].casilla=0;
						end
					end
					case 3: //avance
						espera_evento=-1;
						p[jugador].casilla+=3;
						process_anuncio_evento("Advance 3 spaces");
						if(p[jugador].casilla>contador_casillas)
							espera_evento=0;
							p[jugador].casilla=contador_casillas;
						end
					end
					case 4: //desafio
						espera_evento=-1;
						anuncio_evento("Challenge");
						frame(2000);
						espera_evento=0;
					end
					case 5: //comodin
						espera_evento=-1;
						//anuncio_evento("Random event");
						switch(rand(1,3))
							case 1: //manda chupitos
								anuncio_evento("Give "+rand(2,4)+" shots!");
							end
							case 2: //recibe chupitos
								anuncio_evento("Have "+rand(2,4)+" shots!");
							end
							case 3: //evento raro!
								switch(rand(0,3))
									case 0: anuncio_evento("Stay hopping!"); end
									case 1: anuncio_evento("Hands in your back!"); end
									case 2: anuncio_evento("Tongue out!"); end
									case 3: anuncio_evento("Can't talk!"); end
								end
							end
						end
						//anuncio_evento("Comodin!");
						frame(2000);
						espera_evento=0;
					end
				end
			else //acaba de suceder un evento
				espera_evento=0;
			end
			
		end //if movimiento ficha
		frame;
	end
End

Process grafico(x,y,file,graph,flags);
Begin
	loop
		frame;
	end
End

Process grafico_aparece(x,y,file,graph,flags);
Begin
	z=-10;
	from alpha=0 to 255 step 10; frame; end
	loop
		frame;
	end
End

Process oscurece();
Begin
	graph=new_map(1280,720,32);
	drawing_map(0,graph);
	drawing_color(rgb(5,5,5));
	draw_box(0,0,1280,720);
	x=640; y=360;
	z=-7;
	from alpha=0 to 180 step 10; frame; end
	loop frame; end
End

Function anuncio_evento(string texto);
Private
	angle_inc;
Begin
	x=640; y=240; z=-5;
	graph=write_in_map(h1,texto,4);
	size=200;
	from alpha=0 to 255 step 20; size-=8; frame; end
	size=100;
	wait(3);
	grav=-5;
	angle_inc=rand(-5,5)*1000;
	while(y<720) y+=grav; grav++; angle+=angle_inc; frame; end
End

Function turno_anuncio_evento(string texto);
Private
angle_inc;
Begin
	x=640; y=240; z=-5;
	graph=write_in_map(h1,texto,4);
	from alpha=0 to 255 step 20; frame; end
	wait(2);
	from alpha=255 to 0 step -20; frame; end
End

Process process_anuncio_evento(string texto);
Private
angle_inc;
Begin
	x=640; y=240; z=-5;
	graph=write_in_map(h1,texto,4);
	from alpha=0 to 255 step 20; frame; end
	wait(2);
	from alpha=255 to 0 step -20; frame; end
End

Function transicion(tipo);
Begin
	z=-100;
	if(tipo==1)
		toma_pantalla=get_screen();
	end
	
	if(tipo==2)
		graph=toma_pantalla;
		switch(rand(0,3))
			case 0:
				set_center(0,graph,1280,0); x=1280; y=0; loop grav++; angle+=grav*1000; if(angle>90000) break; end frame;	end
			end
			case 1:
				x=640; y=360;
				while(alpha>5) alpha-=5; frame; end
			end
			case 2:
				x=640; y=360;
				while(y<720*1.5) grav++; y+=grav; frame; end
			end
			case 3:
				x=640; y=360;
				size_y=101;
				while(size_y!=1) size_y-=10; frame; end
				while(size_x!=0) size_x-=10; frame; end
			end
		end
	end
	frame;
End

Process escapable();
Begin
	loop
		if(key(_esc)) exit(); end
		frame;
	end
end

Function posiciona(jugador);
Private
	yacogido;
Begin
	from j=1 to 4; //miramos las 4 posiciones
		yacogido=0;
		from i=1 to 4; //en los 4 jugadores
			if(p[i].posicion==j) yacogido=1; end
		end
		if(yacogido==0) break; end
	end
	p[jugador].posicion=j;
End

Function desposiciona(jugador);
Private
	yacogido;
Begin
	from j=4 to 1 step -1; //miramos las 4 posiciones
		yacogido=0;
		from i=1 to 4; //en los 4 jugadores
			if(p[i].posicion==j) yacogido=1; end
		end
		if(yacogido==0) break; end
	end
	p[jugador].posicion=j;
End

Function suena(tipo);
Begin
	play_wav(sonidos[tipo],0);
End

Function musica(tipo);
Begin
	//fade_music_off(100);
	//while(is_playing_song()) frame; end
	stop_song();
	unload_song(ogg);
	ogg=load_song("ogg/"+tipo+".ogg");
	play_song(ogg,-1);
End

Function salir_android();
Begin
	exit();
End