program pixfrogger;

//import "mod_debug";
import "mod_dir";
import "mod_draw";
import "mod_grproc";
import "mod_map";
import "mod_mouse";
import "mod_multi";
import "mod_proc";
import "mod_rand";
import "mod_say";
import "mod_screen";
import "mod_scroll";
import "mod_sound";
import "mod_string";
import "mod_text";
import "mod_timers";
import "mod_video";
import "mod_wm";
import "mod_file";
import "mod_joy";
import "mod_math";
import "mod_sys";
import "mod_regex";
import "mod_key";

#ifdef RED
import "fsock";
#endif

Global
	#ifdef RED
		en_red=1;
	#else
		en_red=0;
	#endif
	estado_red=-1;
	net_clients;
	
	
	
	arcade_mode=0;
	bpp=32;
	frameskip=1;
	fpg_general=0;
	matabotones;
	ready=1;
	jue;
	anterior_camino;
	primera_ronda;
	string portrait_txt;
	Struct ops; 
		pantalla_completa=1;
		sonido=1;
		musica=1;
		dificultad=2;
		objetivo=10;
		lenguaje;
	End
	elecc;
	elecy;
	scroll_y;
	rana_id[32];
	rana_juega[32];
	rana_viva[32];
	rana_puntos[32];
	string rana_msg[32];
	puntos_win=10;
	llegada;
	fnt_puntos;
	fnt_textos;
	music;
	njoys;
	buzz;
	string joyname;
	buzz_joys[8];
	wavs[50];
	boton[32]; //0: cualquier boton,1-8: ranas,9:salir
	boton_salir;
	posibles_jugadores;
	id_camara;
	num_jugadores=0;
	distancia_sombra=10;
	
	ancho_pantalla=1280;
	alto_pantalla=1024;
	panoramico=0;
	portrait=0;
	alto_camino=75;
	pos_inicio=100;
	num_caminos;
	meta=0;
	tactil=0;

	string version="";
	
	#ifdef FREE
	free_version=1;
	#else
	free_version=0;
	#endif
	
	// COMPATIBILIDAD CON XP/VISTA/LINUX (usuarios)
	string savegamedir;
	string developerpath="/.PiXJuegos/PiXFrogger/";
		
End //global

Local
	i; // la variable maestra
	ancho;
	alto;
	jugador;
	pos_y;
	opcion;
	id_boton;
	no_matar;
End //local

//cosas comunes de los pixjuegos
include "../../common-src/lenguaje.pr-";
include "../../common-src/savepath.pr-";

Private
	graph_loading;

begin
	//averiguamos el path para guardar datos
	if(os_id==1003)
		tactil=1;
		bpp=16;
		if(free_version)
			savegamedir="/data/data/com.pixjuegos.pixfrogger.free/files";
		else
			savegamedir="/data/data/com.pixjuegos.pixfrogger/files";
		end
	else
		savepath();
	end
	
	//cargamos las opciones actuales
	carga_opciones();

	prueba_pantalla();
	
	if(!tactil)
		//arcade mode?
		if(argc>0) if(argv[1]=="arcade") arcade_mode=1; end end

		//detectamos buzzers
		detecta_buzzers();

		//TEST DEBUG:
		if(en_red)
			posibles_jugadores=32;
			ops.dificultad=4;
		end
		
		//seteamos la distancia hasta la meta bien lejos en caso de muchos jugadores
		if(posibles_jugadores=>16)
			pos_inicio=500;
		end
		
		//detectamos el lenguaje a utilizar (en/es)
		switch(lenguaje_sistema())
			case "es": ops.lenguaje=0; end
			default: ops.lenguaje=1; end
		end
	
		//ajustes de rendimiento
		alpha_steps=64;
	
		//en modo arcade, pantalla completa y escalado
		if(arcade_mode) ops.pantalla_completa=true; scale_resolution=08000600; end
	
		//seteamos el modo de vídeo
		full_screen=ops.pantalla_completa;
	else
		//ajustes de rendimiento
		alpha_steps=32;
	end
		
	set_mode(ancho_pantalla,alto_pantalla,bpp);
	set_fps(25,frameskip);
	set_title("PiX Frogger");
	
	if(portrait) portrait_txt="-portrait"; end
	if(free_version)
		graph_loading=load_png("free-"+version+portrait_txt+".png");
	else
		graph_loading=load_png("load-"+version+portrait_txt+".png");
	end
	
	timer[0]=0;
	put_screen(0,graph_loading);
	frame; //tengo que hacer 2 frames para que lo de arriba funcione :|
	frame;
	unload_map(0,graph_loading);
	
	//cargamos los recursos a utilizar durante todo el juego
	carga_sonidos();
	
	if(posibles_jugadores=>16)
		distancia_sombra=4;
		version="ld";
		fpg_general=load_fpg("fpg/pixfrogger-ld-32players.fpg");
		fnt_puntos=load_fnt("fnt/puntos-ld.fnt");
		fnt_textos=load_fnt("fnt/textos.fnt");
	else
		fpg_general=load_fpg("fpg/pixfrogger-"+version+portrait_txt+".fpg");
		fnt_puntos=load_fnt("fnt/puntos-"+version+".fnt");

		if(version=="hd" and fpg_general==-1)
			version="md";
			fpg_general=load_fpg("fpg/pixfrogger-"+version+portrait_txt+".fpg");
			fnt_puntos=load_fnt("fnt/puntos-"+version+".fnt");
		end

		if(version=="md" and fpg_general==-1)
			version="ld";
			fpg_general=load_fpg("fpg/pixfrogger-"+version+portrait_txt+".fpg");
			fnt_puntos=load_fnt("fnt/puntos-"+version+".fnt");
		end
	end

	if(version=="md") distancia_sombra=7; end
	if(version=="ld") distancia_sombra=4; end
		
	if(free_version)
		while(timer[0]<600) frame; end
	end
	
	if(fpg_general==-1) say("No he encontrado un fpg válido..."); exit(); end
	
	music=load_song("ogg/1.ogg");
	
	//averiguamos el alto del camino y el número de caminos
	alto_camino=graphic_info(0,200,g_height);
	num_caminos=(alto_pantalla/alto_camino)+2;
	
	//empezamos, ponemos el logo
	if(!tactil)
		logo_pixjuegos();
	else
		//ponemos el menú directamente
		if(ops.musica)
			play_song(music,-1);
		end
		if(!tactil)
			menu();
		else
			menu_tactil();
		end
	end
end

Function prueba_pantalla();
Private
	float proporcion;
Begin
	if(os_id==0) //Windows
		if((mode_is_ok(1920,1080,16,MODE_FULLSCREEN) or mode_is_ok(1366,768,16,MODE_FULLSCREEN)) or 
		(mode_is_ok(1280,720,16,MODE_FULLSCREEN) and !mode_is_ok(1280,1024,16,MODE_FULLSCREEN))) //Si soporta resoluciones panorámicas altas o no soporta alguna resolución no panorámica, es panorámico...
			panoramico=1;
			ancho_pantalla=1280; alto_pantalla=720;
		else
			panoramico=0;
			if(mode_is_ok(640,480,16,MODE_FULLSCREEN))
				ancho_pantalla=640; alto_pantalla=480;
			elseif(mode_is_ok(320,240,16,MODE_FULLSCREEN))
				ancho_pantalla=320; alto_pantalla=240;
			end
		end
	end
	if(os_id==1003) //ANDUROID
		frame;
		ancho_pantalla=graphic_info(0,0,g_width);
		alto_pantalla=graphic_info(0,0,g_height);
		proporcion=(float) alto_pantalla/ancho_pantalla;
		say("---------------------------------"+ancho_pantalla);
		say("---------------------------------"+alto_pantalla);
	end

	
	//TTTTTTTTTTTTTTTTTTEEEEEEEEEEEEESSSSSSSSSSSSSSSSSSTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
		
	/*tactil=1;
	ancho_pantalla=800;
	alto_pantalla=1280;
	mouse.graph=71;
	full_screen=0;
	panoramico=0;
	bpp=16;
	scale_resolution=04800800;*/
	
	//********************************************************************************
	
	
	
	
	if(alto_pantalla>ancho_pantalla) portrait=1; else portrait=0; end
	
	if(version=="") 
		if((ancho_pantalla=>1200 and portrait==0) or (alto_pantalla=>1200 and portrait==1))
			version="hd";
		elseif((ancho_pantalla=>600 and portrait==0) or (alto_pantalla=>600 and portrait==1))
			version="md";
		else
			version="ld";
		end
	end
		
	if(os_id==1003)
		scale_resolution=ancho_pantalla*10000+alto_pantalla;
		if(portrait)
			if(version=="hd" and ancho_pantalla!=720)
				ancho_pantalla=720; alto_pantalla=ancho_pantalla*proporcion;
			end
			if(version=="md" and ancho_pantalla!=480)
				ancho_pantalla=480; alto_pantalla=ancho_pantalla*proporcion;
			end
			if(version=="ld" and ancho_pantalla!=240)
				ancho_pantalla=240; alto_pantalla=ancho_pantalla*proporcion;
			end
		else
			if(version=="hd" and ancho_pantalla!=1280) scale_resolution=12800720; end
			if(version=="md" and ancho_pantalla!=800) scale_resolution=08000480; end
			if(version=="ld" and ancho_pantalla!=400) scale_resolution=04000240; end
		end
	end

End

Process pon_fondo(graph);
Begin
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	z=100;
	loop
		frame(10000);
	end
End

Process menu_tactil();
Private
	menu_actual=0;
	cambia_menu=1;
	jugadores=1;
Begin
	from i=0 to posibles_jugadores; rana_puntos[i]=0; end
	delete_text(all_text);
	primera_ronda=1;
	dump_type=0; restore_type=0;
	
	//ponemos el fondo y el logo, pa empezar
	if(portrait)
		//pon_fondo(701);
		put_screen(0,701);
	else
		//pon_fondo(3);
		put_screen(0,3);
	end
	stop_scroll(0);
	
	controlador(0);
		
	if(portrait)
		posibles_jugadores=2;
	else
		posibles_jugadores=4;
	end
	
	loop
		num_jugadores=0;
		from i=1 to posibles_jugadores;
			if(rana_juega[i]) num_jugadores++; end
		end

		if(boton_salir)
			if(menu_actual!=1)
				cambia_menu=1; sonido(1);
			else
				matabotones=1;
				fade_music_off(500);
				while(is_playing_song()) frame; end
				salir();
			end
		end

		if(!focus_status and tactil)
			matabotones=1;
			fade_music_off(500);
			set_fps(1,frameskip);
			while(is_playing_song()) frame; end
			salir();
		end

		if(opcion!=0)
			sonido(3);
			if(menu_actual==1) //principal: 1 jugar, 2 opciones, 3 creditos, 4 salir
				switch(opcion)
					case 1: 
						//-----
						cambia_menu=2; 
					end
					case 2: cambia_menu=3; end
					case 3: cambia_menu=4; end
					case 4: salir(); end
					case 5: //donate/network
						#ifdef RED
							inicio_cliente();
							return;
						#else
							exec(_P_NOWAIT, "market://details?id=com.pixjuegos.pixfrogger", 0, 0);						
							salir(); 
						#endif
					end
				end
			end
			if(menu_actual==2) //jugar: 1 jugadores, 2 dificultad, 3 puntos para ganar, 4 jugar, 5 volver
				switch(opcion)
					case 1: 
						//no utilizado al final
					end
					case 2:
						//no utilizado al final
					end
					case 3:
						//no utilizado al final
					end
					case 4:
						x=ancho_pantalla/2;
						y=alto_pantalla/2;
						dump_type=0;
						restore_type=0;
						frame;
						graph=get_screen();
						alpha=255;
						net_let_me_alone();
						juego();
						z=-100;
						from alpha=255 to 0 step -15; frame; end
						unload_map(0,graph);
						return;
					end
					case 5:
						cambia_menu=1;
					end
				end
			end
			if(menu_actual==3) //opciones: 1 sonido, 2 musica, 3 volver
				switch(opcion)
					case 3: cambia_menu=1; end
				end
			end
			if(menu_actual==4) //creditos: 1 volver
				cambia_menu=1;
			end
			opcion=0;
		end

		if(cambia_menu!=0)
			matabotones=1;
			while(exists(type pon_boton_menu)) frame; end
			frame;
			menu_actual=cambia_menu;
			cambia_menu=0;
			matabotones=0;
			if(!exists(type boton_sonido)) boton_sonido(); end
			if(!exists(type boton_musica)) boton_musica(); end
			if(menu_actual==1)
				pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*2)-(alto_pantalla/14),2,100,255,0,1); //logo
				//pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*4)-(alto_pantalla/14),601,100,255,1,2); //jugar
				//pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*5)-(alto_pantalla/14),602,100,255,2,4); //opciones
				pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*4)-(alto_pantalla/14),601,100,255,1,2); //jugar
				pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*5)-(alto_pantalla/14),603,100,255,3,3); //creditos
				pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*6)-(alto_pantalla/14),604,100,255,4,4); //salir
				if(free_version and !en_red)
					pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*7)-(alto_pantalla/14),606,100,255,5,4); //netplay
				end
				if(en_red)
					pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*7)-(alto_pantalla/14),605,100,255,5,4); //donate
				end
			end
			if(menu_actual==2) //jugar: opciones
				from i=0 to posibles_jugadores; rana_juega[i]=0; end
				pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*1)-(alto_pantalla/14),641,100,255,0,1); //jugadores
				tactil_elige_rana(1); tactil_elige_rana(2);
				
				pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*3)-(alto_pantalla/14),642,100,255,0,1); //texto dificultad
				from i=1 to 4; boton_dificultad(i); end
				
				pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*5)-(alto_pantalla/14),643,100,255,0,1); //texto objetivo
				boton_puntos_objetivo(1,5);
				boton_puntos_objetivo(2,10);
				boton_puntos_objetivo(3,20);
				boton_puntos_objetivo(4,50);
				
				//boton jugarS
				pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*7)-(alto_pantalla/14),602,100,255,4,1); //jugar/demo
			end
			if(menu_actual==4) //creditos
				pon_creditos();
				pon_enlace(ancho_pantalla/2,(alto_pantalla/7)*6,706,"http://www.pixjuegos.com");
				//pon_enlace(ancho_pantalla/4*3,((alto_pantalla/7)*5)-(alto_pantalla/14),704,"http://www.twitter.com/pixjuegos");
				//pon_enlace(ancho_pantalla/4*3,((alto_pantalla/7)*6)-(alto_pantalla/14),705,"http://www.facebook.com/pixjuegos");
			end
		end

		frame;
	end
End

Process pon_creditos();
Begin
	graph=703;
	x=ancho_pantalla/2;
	y=(alto_pantalla/7)*3;
	alpha=0;
	while(!matabotones)
		if(alpha<255) alpha+=10; end
		frame;
	end
	from alpha=255 to 0 step -15; end
End

Process pon_enlace(x,y,graph,string url);
Begin
	alpha=0;
	while(!matabotones)
		if(alpha<255) alpha+=10; end
		if(mouse.left)
			if(collision_box(type mouse))
				frame;
				while(mouse.left and collision_box(type mouse)) frame; end
				if(collision_box(type mouse))
					exec(_P_NOWAIT, url, 0, 0);
				end
			end
		end
		frame;
	end
End

Process boton_sonido();
Begin
	switch(version)
		case "ld":
			x=20;
			y=20;
		end
		case "md":
			x=30;
			y=30;
		end
		case "hd":
			x=40;
			y=40;
		end
	end
	while(!matabotones)
		if(ops.sonido)
			graph=621;
		else
			graph=622;
		end
		if(mouse.left)
			if(collision_box(type mouse))
				frame;
				while(mouse.left and collision_box(type mouse)) frame; end
				if(collision_box(type mouse))
					if(ops.sonido) 
						ops.sonido=0;
						ops.musica=0;
						stop_song();
					else
						ops.musica=1;
						ops.sonido=1;
						play_song(music,-1);
					end
				end
			end
		end
		frame;
	end
End

Process boton_musica();
Begin
	switch(version)
		case "ld":
			x=ancho_pantalla-20;
			y=20;
		end
		case "md":
			x=ancho_pantalla-30;
			y=30;
		end
		case "hd":
			x=ancho_pantalla-40;
			y=40;
		end
	end
	while(!matabotones)
		if(ops.musica)
			graph=623;
		else
			graph=624;
		end
		if(mouse.left)
			if(collision_box(type mouse))
				frame;
				while(mouse.left and collision_box(type mouse)) frame; end
				if(collision_box(type mouse))
					if(ops.musica) 
						ops.musica=0;
						stop_song();
					else
						ops.musica=1;
						play_song(music,-1);
					end
				end
			end
		end
		frame;
	end
End

Process tactil_elige_rana(jugador);
Begin
	y=((alto_pantalla/7)*2)-(alto_pantalla/14);
	size=40;
	switch(posibles_jugadores)
		case 2:
			if(jugador==1) x=((ancho_pantalla/2)-(ancho_pantalla/8)); end
			if(jugador==2) x=((ancho_pantalla/2)+(ancho_pantalla/8)); end
		end
	end
	graph=500+jugador;
	if(rana_juega[jugador])
		from alpha=0 to 255 step 16; frame; end
	else
		from alpha=0 to 128 step 8; frame; end
	end
	while(!matabotones)
		if(rana_juega[jugador])
			alpha=255;
		else
			alpha=128;
		end
		if(mouse.left)
			if(collision_box(type mouse))
				frame;
				while(collision_box(type mouse) and mouse.left) frame; end
				if(collision_box(type mouse))
					if(rana_juega[jugador])
						rana_juega[jugador]=0;
						sonido(2);
					else
						rana_juega[jugador]=1;
						sonido(4);
					end
				end
			end
		end
		frame;
	end
	if(alpha==255)
		from alpha=255 to 0 step -16; frame; end
	else
		from alpha=128 to 0 step 8; frame; end
	end
End

Process boton_dificultad(dificultad);
Begin
	y=((alto_pantalla/7)*4)-(alto_pantalla/14);
	x=(ancho_pantalla/12)+(ancho_pantalla/6*dificultad);
	graph=630+dificultad;
	if(ops.dificultad==dificultad)
		from alpha=0 to 255 step 16; frame; end
	else
		from alpha=0 to 100 step 8; frame; end
	end
	while(!matabotones)
		if(ops.dificultad==dificultad)
			alpha=255;
		else
			alpha=100;
		end
		if(collision_box(type dedo))
			while(collision_box(type dedo)) frame; end
			ops.dificultad=dificultad;
			sonido(2);
		end
		frame;
	end
	if(alpha==255)
		from alpha=255 to 0 step -16; frame; end
	else
		from alpha=100 to 0 step 8; frame; end
	end
End

Process boton_puntos_objetivo(posicion,puntos);
Begin
	y=((alto_pantalla/7)*6)-(alto_pantalla/14);
	x=(ancho_pantalla/12)+(ancho_pantalla/6*posicion);
	graph=write_in_map(fnt_puntos,puntos,4);
	if(ops.objetivo==puntos)
		from alpha=0 to 255 step 16; frame; end
	else
		from alpha=0 to 100 step 8; frame; end
	end
	//mouse.graph=graph;
	while(!matabotones)
		if(ops.objetivo==puntos)
			alpha=255;
		else
			alpha=100;
		end
		if(collision_box(type dedo))
			while(collision_box(type dedo)) frame; end
			ops.objetivo=puntos;
			sonido(2);
		end
		frame;
	end
	if(alpha==255)
		from alpha=255 to 0 step -16; frame; end
	else
		from alpha=128 to 0 step 8; frame; end
	end	
End

//efecto_entrada: 0: fadein, 1: aparece por arriba, 2: aparece por la derecha, 3: aparece por abajo, 4: aparece por la izquierda
//efecto_salida: 0: fadeoff, 1: aparece por arriba, 2: aparece por la derecha, 3: aparece por abajo, 4: aparece por la izquierda
Process pon_boton_menu(x_out,y_out,graph,size_out,alpha_out,mi_opcion,efecto);
Private
	framess=5;
	demo_button=0;
Begin
	x=x_out;
	y=y_out;
	z=-101;
	alpha=alpha_out;
	size=size_out;
	if(graph==602) demo_button=1; end
	switch(efecto)
		case 0: from alpha=0 to alpha_out step 20; frame; end end
		case 1: y=-alto_pantalla/2; while(y<y_out) y+=((y_out-y)/framess)+10; frame; end end
		case 2: x=ancho_pantalla*1.5; while(x>x_out) x-=((x-x_out)/framess)+10; frame; end end
		case 3: y=alto_pantalla*1.5; while(y>y_out) y-=((y-y_out)/framess)+10; frame; end end
		case 4: x=-ancho_pantalla/2; while(x<x_out) x+=((x_out-x)/framess)+10; frame; end end
	end
	x=x_out;
	y=y_out;
	size=size_out;
	alpha=alpha_out;
	loop
		if(demo_button)
			if(num_jugadores>0)
				graph=601;
			else
				graph=602;
			end
		end
		if(mouse.left)
			if(collision_box(type mouse))
				if(graph>600 and graph<605) graph+=10; end
				
				while(mouse.left and collision_box(type mouse)) frame; end
				
				if(collision_box(type mouse))
					father.opcion=mi_opcion;
					father.id_boton=id;
					frame;
				end
				if(graph>610 and graph<615) graph-=10; end
			end
		end
		if(matabotones) break; end
		frame;
	end
	switch(efecto)
		case 0: from alpha=alpha to 0 step -20; frame; end end
		case 1: while(y>-alto_pantalla/2) y-=((y-(-alto_pantalla/2))/framess)+10; frame; end end
		case 2: while(x<ancho_pantalla*1.5) x+=(((ancho_pantalla*1.5)-x)/framess)+10; frame; end end
		case 3: while(y<alto_pantalla*1.5) y+=(((alto_pantalla*1.5)-y)/framess)+10; frame; end end
		case 4: while(x>-ancho_pantalla/2) x-=((x-(-ancho_pantalla/2))/framess)+10; frame; end end
	end
End


function detecta_buzzers();
Begin
	//encontramos buzzers
	njoys=number_joy();
	posibles_jugadores=4;
	
	if(njoys>0)
		from i=0 to njoys-1;
			joyname=lcase(JOY_NAME(i));
			if(find(joyname,"buzz")=>0)
				buzz++;
				if(buzz==1)
					buzz_joys[1]=i;
					posibles_jugadores=8;
				elseif(buzz==2)
					buzz_joys[2]=i;
				elseif(buzz==3)
					buzz_joys[3]=i;
				elseif(buzz==4)
					buzz_joys[4]=i;
					posibles_jugadores=16;
				elseif(buzz==5)
					buzz_joys[5]=i;
				elseif(buzz==6)
					buzz_joys[6]=i;
				elseif(buzz==7)
					buzz_joys[7]=i;
				elseif(buzz==8)
					buzz_joys[8]=i;
					posibles_jugadores=32;
					break; //YA TENEMOS BASTANTES (32 jugadores :|, redios)
				end
			end
		end
	end
end

function reset();
Begin
	delete_text(0);
	stop_wav(-1);
	stop_song();
	stop_scroll(0);
	clear_screen();
End

process logo_pixjuegos();
begin
	//reiniciamos todo, por si las moscas
	reset();
	net_let_me_alone();
	controlador(0);
	
	//boton_sonido(ancho_pantalla-30,30);	
	
	//ponemos el logo de pixjuegos
	if(portrait)
		graph=702;
	else
		graph=1;
	end
	
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	z=-10;

	//aparece
	from alpha=50 to 255 step 5; 
		if(scan_code!=0 or (tactil and mouse.left)) break; end
		frame; 
	end

	//permanece 3 segundos
	timer[0]=0;
	while(timer[0]<300) if(scan_code!=0 or (tactil and mouse.left)) break; end frame; end
	while(scan_code!=0 or (tactil and mouse.left)) frame; end
	
	//ponemos la canción del juego
	if(ops.musica)
		play_song(music,-1);
	end
	
	//ponemos el menú
	if(!tactil)
		menu();
	else
		menu_tactil();
	end
	
	//desaparece
	from alpha=alpha to 0 step -10;
		frame; 
	end
end

process menu()
private
	tec;
	keytime;
	tec2;
begin
	delete_text(all_text);
	from i=1 to posibles_jugadores; rana_viva[i]=0; rana_puntos[i]=0; end
	elecc=0;
	primera_ronda=1;
	dump_type=0; restore_type=0;
	put_screen(0,3);
	if(en_red and estado_red>0)
		estado_red=-1;
	end
	if(!exists(type controlador)) controlador(0); end
	if(arcade_mode)
		//modo arcade
		write(0,ancho_pantalla/2,alto_pantalla/2,4,"Pulsa el botón 1 para jugar");
		while(boton[0]) frame; end
		while(!boton[0]) 
			if(boton_salir) salir(); end
			frame; 
		end
		delete_text(all_text);
		
		//ayuda
		put_screen(0,6);
		while(boton[0]) frame; end
		while(!boton[0]) 
			if(boton_salir) salir(); end
			frame; 
		end
		while(boton[0]) frame; end
		
		//elección de personajes
		put_screen(0,3);
		elecpersonaje();
		return;
	end
	
	lista_opciones(4);
	logo_pixfrogger();
	flecha_opcion();
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	keytime=10;
	loop
		if(keytime>0)
			keytime--;
		end
		//elige algo
		if(key(_enter) and keytime==0)
			sonido(3);
			if(elecc==0)
				net_let_me_alone();
				scroll_y=0;
				elecpersonaje();
				break;
			end
			if(elecc==1)
				net_let_me_alone();
				back(3);
				logo_pixfrogger();
				opcion();
				break;
			end
			if(elecc==2)
				net_let_me_alone();
				back(5);
				break;
			end
			if(elecc==3)
				guarda_opciones();
				salir();
			end
		end
		if(key(_down))
			if(tec==0)
				elecc++;
				sonido(2);
				tec=1;
			end
		else
			tec=0;
		end
		if(key(_up))
			if(tec2==0)
				elecc--;
				sonido(2);
				tec2=1;
			end
		else
			tec2=0;
		end
		if(elecc==4)
			elecc=0;
		end
		if(elecc==-1)
			elecc=3;
		end
		frame;
	end
end

process lista_opciones(gr)
begin
	x=-(ancho_pantalla/4);
	y=alto_pantalla/2;
	if(gr==13)
		y=276;
	end
	if(gr==914)
		y=220;
	end
	z=-10;
	graph=gr;
	if(ops.lenguaje==1)
		if(graph==4) graph=911; end
		if(graph==13) graph=913; end
	end
	loop
		if(gr!=13) 
			x+=(x-(ancho_pantalla/4))/-10; 
		else 
			x+=(x-(ancho_pantalla/4))/-10; 
		end
		frame;
	end
end

//aparece en los menús
process logo_pixfrogger()
begin
	x=(ancho_pantalla/8)*5;
	y=-(alto_pantalla/8);
	z=-10;
	graph=2;
	
	loop
		y+=(y-(alto_pantalla/4))/-10;
		frame;
	end
end

//animación que muestra un gráfico que va desde arriba del todo al centro
process grafico_al_centro(gr)
private
	con;
begin
	x=ancho_pantalla/2;
	y=-140;
	z=-15;
	graph=gr;
	loop
		con++;
		if(con>100)
			break;
		end
		y+=(y-240)/-10;
		frame;
	end
end

//flecha de las opciones
process flecha_opcion()
private
	osc;
begin
	z=-20;
	graph=500;
	loop
		osc+=10000;
		if(osc>350000)
			osc=0;
		end
		//x=(cos(osc)*5)+20;
		elecy=y;
		y=190+elecc*55;
		frame;
	end
end

process back(graph)
private
	keytime;
begin
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	keytime=10;
	if(graph==5 and ops.lenguaje==1) graph=912; end
	if(!exists(type controlador)) controlador(0); end
	loop
		if(boton_salir)
			while(boton_salir) frame; end
			net_let_me_alone();
			sonido(1);
			menu();
			break;
		end
		//ayuda y tal
		if(graph==5 or graph==912)
			if(key(_esc) and keytime==0)
				sonido(3);
				net_let_me_alone();
				menu();
				break;
				keytime=10;
			end
			if(keytime>0)
				keytime--;
			end
		end
		frame;
	end
end

process opcion();
private
	tec;
	tec2;
	tecenter;
begin
	elecc=0;
	lista_opciones(13);
	flecha_opcion();
	scroll_y=-100;
	tecenter=1;
	loop
		if(boton_salir)
			net_let_me_alone();
			menu();
			break;
		end
		if(key(_enter))
			if(tecenter==0)
				sonido(3);
				if(elecc==0)
					if(ops.pantalla_completa==0)
						ops.pantalla_completa=1;
						full_screen=1;
						set_mode(ancho_pantalla,alto_pantalla,32,WAITVSYNC);
					else
						ops.pantalla_completa=0;
						full_screen=0;
						set_mode(ancho_pantalla,alto_pantalla,32,WAITVSYNC);
					end
				end
				if(elecc==1)
					if(ops.sonido==1)
						ops.sonido=0;
					else
						ops.sonido=1;
						sonido(3);
					end
				end
				if(elecc==2)
					if(ops.musica==1)
						stop_song();
						ops.musica=0;
					else
						play_song(music,99);
						ops.musica=1;
					end
				end
				if(elecc==3)
					net_let_me_alone();
					stop_song();
					while(key(_enter)) frame; end
					elige_lenguaje();
					return;
				end
			end
			tecenter=1;
		else
			tecenter=0;
		end
		//enter
		if(key(_down))
			if(tec==0)
				sonido(2);
				elecc++;
				tec=1;
			end
		else
			tec=0;
		end
		if(key(_up))
			if(tec2==0)
				sonido(2);
				elecc--;
				tec2=1;
			end
		else
			tec2=0;
		end
		if(elecc==4)
			elecc=0;
		end
		if(elecc==-1)
			elecc=3;
		end
		frame;
	end
end

process elecpersonaje()
private
	dand;
	j;
	continua;
begin
	jue=0;
	from j=0 to posibles_jugadores;
		rana_juega[j]=0;
	end
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	if(ops.lenguaje==1) 
		if(buzz) graph=915; else graph=910; end
	else 
		if(buzz) graph=60; else graph=59; end
	end
	z=100;
	if(!exists(type controlador)) controlador(0); end
	panoramico=1;
	if(en_red)
		if(estado_red==-1)
			estado_red=0;
		else
			estado_red=1;
		end
	end
	loop
		if(en_red==0 or continua==1)
			dand++;
		end
		if(en_red and key(_space) and continua==0)
			continua=1;
			dand=100;
		end
		if(dand==100)
			grafico_al_centro(11);
		end
		if(dand==200)
			grafico_al_centro(12);
		end
		if(dand==250 or (dand>100 and key(_enter)))
			graph=get_screen();
			net_let_me_alone();
			juego();
			z=-100;
			from alpha=255 to 0 step -15; frame; end
			unload_map(0,graph);
			return;
		end
		
		from i=1 to posibles_jugadores;
			if(boton[i] and rana_juega[i]==0)
				sonido(4);
				pon_rana(i);
				rana_juega[i]=1;
				dand=0;
			end
		end
		
		if(boton_salir)
			while(boton_salir) frame; end
			net_let_me_alone();
			if(!tactil)
				menu();
			else
				menu_tactil();
			end
			break;
		end
		frame;
	end
end

process pon_rana(jugador);
begin
	z=-15;
	alpha=60;
	graph=500+jugador;
	y=(alto_pantalla*3)/4;
	if(panoramico)
		switch(posibles_jugadores)
			case 2:	x=(ancho_pantalla/16)*3+((ancho_pantalla/16)*jugador*2); end
			case 4:	x=(ancho_pantalla/16)*3+((ancho_pantalla/16)*jugador*2); end
			case 8:	x=(ancho_pantalla/32)*2.5+((ancho_pantalla/32)*jugador*3); end
			case 16: x=(ancho_pantalla/64)*2.5+((ancho_pantalla/64)*jugador*3); end
			case 32: x=(ancho_pantalla/128)*2.5+((ancho_pantalla/128)*jugador*3); end
		end
	else
		switch(posibles_jugadores)
			case 2:	x=(ancho_pantalla/16)*3+((ancho_pantalla/16)*jugador*2); end
			case 4:	x=(ancho_pantalla/32)+((ancho_pantalla/16)*jugador*3); end
		end
	end
	while(exists(father))
		if(boton[jugador]) angle=rand(-10,10)*1000; else angle=0; end
		if(alpha<240) alpha+=5; end
		if(size>50) size-=8; end
		frame;
	end
end

process juego()
private
	ganador;
	dand;
	ranas_vivas_antes;
	ranas_vivas;
	botones_pulsados;
	j;
begin
	if(en_red)
		estado_red=2;
		primera_ronda=1;
	end
	if(tactil or primera_ronda) ready=0; end
	
	clear_screen();
	controlador(1);
	llegada=0;
	scroll_y=0;
	priority=1;
	delete_text(all_text);
	indicador();
	dump_type=-1;
	restore_type=-1;
	start_scroll(0,0,-1,-1,0,15);
	scroll[0].camera=camara();
	from i=pos_inicio-num_caminos+1 to pos_inicio;
		camino(i);
	end
	from i=1 to posibles_jugadores;
		rana(i,rana_juega[i]);
	end
	while(exists(father)) frame; end
	num_jugadores=0;
	from i=1 to posibles_jugadores;
		if(rana_juega[i]) num_jugadores++; end
	end
	if(primera_ronda and num_jugadores>0)
		//3 2 1 YA:
		x=ancho_pantalla/2;
		y=alto_pantalla/2;
		graph=521;
		size=100;
		from alpha=0 to 255 step 20; frame; end
		while(botones_pulsados<num_jugadores)
			botones_pulsados=0;
			from i=1 to posibles_jugadores;
				if(boton[i]) botones_pulsados++; end
			end
			if(key(_enter)) botones_pulsados=100; end 
			if(boton_salir)
				while(boton_salir) frame; end
				x=ancho_pantalla/2;
				y=alto_pantalla/2;
				z=-3;
				alpha=255;
				graph=get_screen();
				net_let_me_alone();
				
				if(tactil)
					menu_tactil();
				else
					menu();
				end
				return;
			end
			frame;
		end
		from alpha=255 to 0 step -20; frame; end
		alpha=255;
		
		from i=3 to 1 step -1;
			timer[0]=0;
			graph=650+i;
			sonido(5);
			if(en_red)
				from j=1 to 32;
					rana_msg[j]="P5";
				end
			end	
			while(timer[0]<100) alpha-=4; size++; frame; end
			size=100;
			alpha=255;
		end
		sonido(6);
		if(en_red)
			from j=1 to 32;
				rana_msg[j]="P6";
			end
		end
		graph=650;
		primera_ronda=0;
	end

	ready=1;
	loop
		if(alpha>0) 
			alpha-=10; 
			size+=3; 
		else
			size=100;
		end
		//perdida del foco en el juego
		if(!focus_status and tactil)
			primera_ronda=1;
			net_let_me_alone();
			stop_scroll(0);
			if(ops.musica)
				fade_music_off(1000);
			end
			set_fps(1,frameskip);
			timer[0]=0;
			while(!focus_status)
				if(timer[0]>60000) salir(); end
				frame;
			end
			if(ops.musica)
				play_song(music,-1);
			end		
			set_mode(ancho_pantalla,alto_pantalla,bpp);
			set_fps(25,frameskip);
			juego();
			return;
		end
	
		//contamos el número de ranas vivas actuales
		ranas_vivas=0;
		from i=1 to posibles_jugadores;
			if(rana_viva[i]) ranas_vivas++; end
		end
		
		//si solo queda una rana, será la ganadora
		if(ranas_vivas==1)
		
			from i=1 to posibles_jugadores;
				if(rana_viva[i]==1) ganador=i; end
			end

			if(en_red)
				rana_msg[ganador]="WIN";
			end
			
			//delete_text(all_text);
						
			rana_puntos[ganador]++;
		
			dump_type=0;
			restore_type=0;
			frame;
			graph=get_screen();
			x=ancho_pantalla/2;
			y=alto_pantalla/2;
			z=-3;
			alpha=255;
			net_let_me_alone();
			stop_scroll(0);
			delete_text(all_text);
			
			if(tactil)
				if(rana_puntos[ganador]!=ops.objetivo)
					//gana la ronda
					gana_rana(ganador);
					gana_rana_you_win();
				else
					//gana el juego
					sonido(7);
					gana_rana(ganador);
					gana_rana_wins_match();
					
					opcion=0;
					
					pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*6)-(alto_pantalla/14),604,100,255,4,4); //salir
					
					while(opcion!=4)
						if(boton_salir) while(boton_salir) frame; end break; end
						frame;	
					end

					net_let_me_alone();
					graph=get_screen();

					menu_tactil();
					from alpha=255 to 0 step -15; frame; end
					return;
				end
			else
				//gana la ronda
				if(posibles_jugadores>8)
					gana_rana_player();
				End
				gana_rana(ganador);
				gana_rana_you_win();
			end
			timer[0]=0;
			while(timer[0]<300) 
				frame; 
				if(key(_enter)) break; end
			end
			
			net_let_me_alone();
			juego();
			z=-10;
			from alpha=255 to 0 step -15; frame; end
			unload_map(0,graph);
			return;
		end
		
		//si han muerto todas las ranas a la vez, reset! 
		if(ranas_vivas==0)
			dump_type=0;
			restore_type=0;
			frame;
			graph=get_screen();
			x=ancho_pantalla/2;
			y=alto_pantalla/2;
			z=-3;
			net_let_me_alone();
			alpha=60;
			dand=100;
			juego();
			z=-10;
			from alpha=255 to 0 step -15; frame; end
			unload_map(0,graph);
			signal(id,s_kill);
		end
		
		//esto aún no tengo claro de para qué lo voy a usar...
		ranas_vivas_antes=ranas_vivas;
		
		//botón esc, salir
		if(boton_salir)
			dump_type=0;
			restore_type=0;
			while(boton_salir) frame; end
			net_let_me_alone();
			graph=get_screen();
			x=ancho_pantalla/2; y=alto_pantalla/2; z=-100;
			
			if(!tactil)
				menu();
			else
				menu_tactil();
			end
			
			from alpha=255 to 0 step -15; frame; end
			unload_map(0,graph);
			break;
		end
		frame;
	end
end

// lo siento gnomwer xD
process sombra();
begin	
	ctype=c_scroll;
	z=father.z+5;
	flags=father.flags;

	priority=1;
	
	//coches y camiones
	if(father.graph==100 or father.graph==101)
		graph=904;
	end
	if(father.graph==102)
		graph=906;
	end
	if(father.graph==103 or father.graph==104)
		graph=905;
	end
	if(father.graph==106)
		graph=903;
	end
	if(father.graph==105)
		graph=902;
	end

	while(exists(father))
		x=father.x+distancia_sombra;
		y=father.y+distancia_sombra;

		//ranas
		if(father.graph>=50 and father.graph=<80)
			if(father.graph%2==0)
				graph=900;
			else
				graph=901;
			end
		end
		FRAME;
	end
END

process rana(jugador,humano);
private
	retraso;
	gr;
	id_obst;
	gr_antes;
	id_col;
begin
	y=8000;
	rana_id[jugador]=id;
	switch(posibles_jugadores)
		case 2:
			x=(ancho_pantalla/2)-(alto_camino)-(alto_camino*1.5)+(alto_camino*(jugador)*1.5);
		end
		case 4:
			x=(ancho_pantalla/2)-(alto_camino)-(alto_camino*3)+(alto_camino*(jugador)*1.5);
		end
		case 8:
			x=(ancho_pantalla/2)-(alto_camino)-(alto_camino*6)+(alto_camino*(jugador)*1.5);
		end
		case 16:
			x=(ancho_pantalla/2)-(alto_camino)-(alto_camino*12)+(alto_camino*(jugador)*1.5);
		end
		case 32:
			x=(ancho_pantalla/2)-(alto_camino*0.75)-(alto_camino*18)+(alto_camino*(jugador)*1.25);
		end
	end
	
	if(rana_puntos[jugador]!=0) 
		write_int(fnt_puntos,x,alto_pantalla-(alto_camino/2),4,&rana_puntos[jugador]); 
	end
	
	z=-100;
	gr=50+((jugador-1)*2);
	if(posibles_jugadores<=8)
		gr=50+((jugador-1)*2);
	else
		gr=48+((jugador%4)*2);
		if(gr==48) gr=56; end
		
		//graph=gr=50+(rand(0,3)*2);
		num_jugador();
	end
	ctype=c_scroll;
	pos_y=pos_inicio-1;
	y=(alto_camino*pos_inicio)-(alto_camino/2);
	priority=rand(100,200);
	rana_viva[jugador]=1;
	graph=gr;

	if(!tactil and posibles_jugadores<16)
		sombra();
	end
	
	loop
		if(!humano and en_red and key(_k))
			rana_viva[jugador]=0;
			return;
		end
	
		if(retraso>0)
			retraso--;
		end
		if(y<id_camara.y-(alto_pantalla/2))
			pos_y++;
		end
		if(y>id_camara.y+alto_pantalla/2)
			pos_y--;
		end
		if(pos_y==meta and llegada==0)
			llegada=jugador; 
			if(en_red)
				rana_msg[jugador]="WIN";
			end
		end
		if(humano==0 and retraso==0 and ready)
			if(rand(0,5)<ops.dificultad or ops.dificultad==4)
				y-=alto_camino;
				if(!collision_box(type vehiculo))
					pos_y--;
					retraso=4;
				end
				y+=alto_camino;
			end
		end
		
		//POSIBLES FORMAS DE PERDER: NOS ATROPELLAN O GANA OTRO
		graph=71; //ponemos este para colisionar!
		if(id_col=collision_box(type vehiculo))
			if(id_col.y==y)
				break;
			end
		end
		if(llegada!=jugador and llegada!=0) break; end

		if(humano and ready)
			if(boton[jugador]and retraso==0)
				pos_y--;
				retraso=4;
			end
		end
		if(retraso>2) graph=gr+1; else graph=gr; end
		y=(pos_y*alto_camino)+(alto_camino/2);
		frame;
	end
	if(en_red)
		rana_msg[jugador]="DEA";
	end
	rana_golpeada(x,y,gr+1);
	if(!tactil)
		explotalo(x,y,z,alpha,angle,file,gr+1,60);
	end
	sonido(4);

	rana_viva[jugador]=0;
end

Process camara();
Begin
	id_camara=id;
	x=ancho_pantalla/2;
	y=(pos_inicio-(num_caminos/2))*alto_camino;
	ctype=c_scroll;
	loop
		scroll[0].x1=x;
		scroll[0].y1=y;
		from i=1 to posibles_jugadores;
			if(exists(rana_id[i]))
				if(rana_id[i].y<y)
					y-=alto_camino/10;
				end
				if(rana_id[i].y<y-(alto_pantalla/5))
					y-=alto_camino/5;
				end
			end
		end
		frame;
	end
End

Function en_pantalla_y();
Begin
	if(father.y>id_camara.y+(alto_pantalla/2)+(alto_camino/2))
		return 0;
	else
		return 1;
	end
End

process vehiculo(pos_y)
private
	gr;
	id_col;
	tipo;
	x_inc;
begin
	ctype=c_scroll;
	tipo=rand(0,3);
	if(tipo==0 or tipo==1)
		gr=rand(100,104);
	end
	if(tipo==2 or tipo==3)
		gr=rand(105,106);
	end
	flags=tipo;
	graph=gr;
	y=-50;
	x=rand(-alto_camino*4,(ancho_pantalla)+alto_camino*4);
	y=(pos_y*alto_camino)+(alto_camino/2);
	z=-10;
	if(tipo==0 or tipo==1)
		switch(version)
			case "hd": x_inc=rand(12,17); end
			case "md": x_inc=rand(8,12); end
			case "ld": x_inc=rand(5,8); end
		end
	else
		switch(version)
			case "hd": x_inc=7; end
			case "md": x_inc=5; end
			case "ld": x_inc=3; end
		end
	end
	if(!tactil)
		sombra();
	end
	loop
		if(!en_pantalla_y()) return; end
		if(tipo==0 or tipo==2)
			x+=x_inc;
			if(x>ancho_pantalla+(alto_camino*4))
				x=-alto_camino*4;
			end
		else
			x-=x_inc;
			if(x<-alto_camino*4)
				x=ancho_pantalla+(alto_camino*4);
			end
		end		
		frame;
	end
end

process rana_golpeada(x,y,graph)
private
	grav;
begin
	ctype=c_scroll;
	grav=-10;
	loop
		angle+=30000;
		grav+=1;
		y+=grav;
		if(y>id_camara.y+(alto_pantalla/2)+100) break;	end
		frame;
	end
end

process camino(pos_y)
Begin
	z=50;
	x=ancho_pantalla/2;
	ctype=c_scroll;

	//al principio todo es hierba
	graph=200;
	if(graph==200) //hierba
		if(anterior_camino==201 or anterior_camino==203)
			graph=205;
		end
		if(anterior_camino==200)
			graph=202;
		elseif(anterior_camino==202)
			graph=204;
		else 
			graph=200;
		end
	end
	anterior_camino=graph;
	
	y=(pos_y*alto_camino)+(alto_camino/2);
	
	loop
		if(!en_pantalla_y())
			pos_y-=num_caminos;
			y=(pos_y*alto_camino)+(alto_camino/2);

			graph=rand(200,201);
			if(pos_y==meta) graph=206; end //meta
			if(pos_y<meta) graph=200; end //hierba post meta
					
			if(graph==200) //hierba
				if(anterior_camino==201 or anterior_camino==203)
					graph=205;
				end
				if(anterior_camino==200)
					graph=202;
				elseif(anterior_camino==202)
					graph=204;
				else 
					graph=200;
				end
			end
			if(graph==201) //calzada
				if(anterior_camino==201 or anterior_camino==203)
					graph=201;
				elseif(anterior_camino==200 or anterior_camino==202 or anterior_camino==204 or anterior_camino==205)
					graph=203;
				end
				vehiculo(pos_y);
			end
			anterior_camino=graph;
		end
		frame;
	end
end

process indicador()
private
	ancho_bandera;
	base_x;
	max_y;
begin
	bandera();
	ancho_bandera=graphic_info(0,210,g_width);
	graph=50;
	angle=270000;
	size=50;
	y=22;
	z=-50;
	base_x=(ancho_pantalla/2)+(ancho_bandera/2);
	max_y=alto_camino*pos_inicio;
	loop
		if(exists(id_camara))
			x=base_x-((id_camara.y*ancho_bandera)/max_y);
		end
		frame;
	end
end

process bandera()
begin
	graph=210;
	x=ancho_pantalla/2;
	y=20;
	z=-25;
	loop
		frame;
	end
end

process elige_lenguaje();
private
	tec;
	keytime;
	tec2;
begin
	elecc=0;
	lista_opciones(914);
	flecha_opcion();
	loop
		if(elecc==2)
			elecc=0;
		end
		if(elecc==-1)
			elecc=1;
		end
		if(keytime>0)
			keytime--;
		end
		//elige algo
		if(key(_enter) and keytime==0)
			sonido(3);
			ops.lenguaje=elecc;
			break;
		end
		if(key(_down))
			if(tec==0)
				elecc++;
				sonido(2);
				tec=1;
			end
		else
			tec=0;
		end
		if(key(_up))
			if(tec2==0)
				elecc--;
				sonido(2);
				tec2=1;
			end
		else
			tec2=0;
		end
		frame;
	end
	while(key(_enter)) frame; end
	logo_pixjuegos();
end

Process explotalo(x,y,z,alpha,angle,file,grafico,frames);
Private
	a;
	b;
	c;
	tiempo;
	struct particula[10000];
		pixel;
		pos_x;
		pos_y;
		vel_y;
		vel_x;
	end
Begin
	ctype=c_scroll;
	ancho=graphic_info(file,grafico,g_width);
	alto=graphic_info(file,grafico,g_height);
	from b=0 to alto-1 step 3;
		from a=0 to ancho-1 step 3;
			if(map_get_pixel(file,grafico,a,b)!=0)
				particula[c].pixel=map_get_pixel(file,grafico,a,b);
				
				particula[c].pos_x=a-(ancho/2);
				particula[c].pos_y=b-(alto/2);
				particula[c].vel_x=((a-(ancho/2))/12)+rand(-1,1);
				particula[c].vel_y=((b-(alto/2))/12)+rand(-1,1);
				
			//	particula[c].vel_x=(a-(ancho/2))/12;
			//	particula[c].vel_y=(b-(alto/2))/12;
				
				c++;
			end
		end
	end
	a=c;
	while(tiempo<frames)
		graph=new_map(ancho*8,alto*8,32);
		from c=0 to a;
			map_put_pixel(0,graph,particula[c].pos_x+(ancho*8/2),particula[c].pos_y+(alto*8/2),particula[c].pixel);
			map_put_pixel(0,graph,particula[c].pos_x+(ancho*8/2)+1,particula[c].pos_y+(alto*8/2),particula[c].pixel);
			map_put_pixel(0,graph,particula[c].pos_x+(ancho*8/2),particula[c].pos_y+(alto*8/2)+1,particula[c].pixel);
			map_put_pixel(0,graph,particula[c].pos_x+(ancho*8/2)+1,particula[c].pos_y+(alto*8/2)+1,particula[c].pixel);
			particula[c].pos_x+=particula[c].vel_x;
			particula[c].pos_y+=particula[c].vel_y+tiempo-10;
			
		end
		tiempo++;
		frame;
		unload_map(0,graph);
	end
end

Function carga_sonidos();
Begin
	from i=1 to 7;
		wavs[i]=load_wav("wav/"+i+".wav");
	end
End

Function sonido(num);
Begin
	if(ops.sonido)
		play_wav(wavs[num],0);
	end
End

Process controlador(en_juego);
Private
	num_dedos;

    int socket_listen; // socket_listen to listen to requests
    int connection=0;
    int ipaddr, portaddr;

Begin
	if(en_juego)
		if(tactil)
			from i=1 to posibles_jugadores;
				if(rana_juega[i])
					pon_boton(i);
				end
			end
		end
	end
	
	loop
		if(!en_red)
			from i=0 to 9; boton[i]=0; end
		end
		boton_salir=0;
		if(!tactil and !en_red)
			if(arcade_mode)
				if(get_joy_button(0,8)) boton_salir=1; end
				if(get_joy_button(0,0)) boton[1]=1; end
				if(get_joy_button(0,3)) boton[2]=1; end
				if(get_joy_button(1,0)) boton[3]=1; end
				if(get_joy_button(1,3)) boton[4]=1; end
			end
			
			if(buzz==1)
				if(get_joy_button(buzz_joys[1],0)) boton[1]=1; end
				if(get_joy_button(buzz_joys[1],5)) boton[2]=1; end
				if(get_joy_button(buzz_joys[1],10)) boton[3]=1; end
				if(get_joy_button(buzz_joys[1],15)) boton[4]=1; end
				if(key(_q)) boton[5]=1; end
				if(key(_z)) boton[6]=1; end
				if(key(_p)) boton[7]=1; end
				if(key(_up)) boton[8]=1; end
			end
			if(buzz=>2)
				if(get_joy_button(buzz_joys[1],0)) boton[1]=1; end
				if(get_joy_button(buzz_joys[1],5)) boton[2]=1; end
				if(get_joy_button(buzz_joys[1],10)) boton[3]=1; end
				if(get_joy_button(buzz_joys[1],15)) boton[4]=1; end
				if(get_joy_button(buzz_joys[2],0)) boton[5]=1; end
				if(get_joy_button(buzz_joys[2],5)) boton[6]=1; end
				if(get_joy_button(buzz_joys[2],10)) boton[7]=1; end
				if(get_joy_button(buzz_joys[2],15)) boton[8]=1; end
			end
			if(buzz=>3)
				if(get_joy_button(buzz_joys[3],0)) boton[9]=1; end
				if(get_joy_button(buzz_joys[3],5)) boton[10]=1; end
				if(get_joy_button(buzz_joys[3],10)) boton[11]=1; end
				if(get_joy_button(buzz_joys[3],15)) boton[12]=1; end
			end
			if(buzz=>4)
				if(get_joy_button(buzz_joys[4],0)) boton[13]=1; end
				if(get_joy_button(buzz_joys[4],5)) boton[14]=1; end
				if(get_joy_button(buzz_joys[4],10)) boton[15]=1; end
				if(get_joy_button(buzz_joys[4],15)) boton[16]=1; end
			end
			if(buzz=>5)
				if(get_joy_button(buzz_joys[5],0)) boton[17]=1; end
				if(get_joy_button(buzz_joys[5],5)) boton[18]=1; end
				if(get_joy_button(buzz_joys[5],10)) boton[19]=1; end
				if(get_joy_button(buzz_joys[5],15)) boton[20]=1; end
			end
			if(buzz=>6)
				if(get_joy_button(buzz_joys[6],0)) boton[21]=1; end
				if(get_joy_button(buzz_joys[6],5)) boton[22]=1; end
				if(get_joy_button(buzz_joys[6],10)) boton[23]=1; end
				if(get_joy_button(buzz_joys[6],15)) boton[24]=1; end
			end
			if(buzz=>7)
				if(get_joy_button(buzz_joys[7],0)) boton[25]=1; end
				if(get_joy_button(buzz_joys[7],5)) boton[26]=1; end
				if(get_joy_button(buzz_joys[7],10)) boton[27]=1; end
				if(get_joy_button(buzz_joys[7],15)) boton[28]=1; end
			end
			if(buzz=>8)
				if(get_joy_button(buzz_joys[8],0)) boton[29]=1; end
				if(get_joy_button(buzz_joys[8],5)) boton[30]=1; end
				if(get_joy_button(buzz_joys[8],10)) boton[31]=1; end
				if(get_joy_button(buzz_joys[8],15)) boton[32]=1; end
			end
			
			//teclado
			if(buzz==0)
				if(key(_q)) boton[1]=1; end
				if(key(_z)) boton[2]=1; end
				if(key(_p)) boton[3]=1; end
				if(key(_up)) boton[4]=1; end
			end
			
			//deberíamos poner para 8 jugadores en teclado??
			/*if(key(_q)) boton[1]=1; else boton[1]=0; end
			if(key(_q)) boton[1]=1; else boton[1]=0; end
			if(key(_q)) boton[1]=1; else boton[1]=0; end
			if(key(_q)) boton[1]=1; else boton[1]=0; end*/
		end

		//tecla maestra
		if(key(_esc)) while(key(_esc)) frame; end boton_salir=1; end

		#IFDEF RED
		if(en_red)
			if(tactil)
				//cliente
			else
				//servidor
				if(estado_red==0)
					say("Inicio servidor...");
					fsock_init(0); // init fsock library
					estado_red=1; //a conectar jugadores
					socket_listen=tcpsock_open(); // new socket
					fsock_bind(socket_listen, 8080); // we'll listen @ port 8080
					tcpsock_listen(socket_listen, posibles_jugadores); // we'll listen for 32 clients
					fsock_fdzero(0);
					fsock_fdset(0,socket_listen);
				end
				if(estado_red==1)
					if(fsock_select(0,-1,-1,0)>0)
						connection=tcpsock_accept(socket_listen, &ipaddr, &portaddr);
						if(connection>0)
							say("Nuevo cliente conectando...");
							process_client(connection, ipaddr, portaddr);
						end
					end
					fsock_fdset (0, socket_listen); // We must reinclude after using select
				end
			end
		end
		#ENDIF
			
		if(tactil)
			if(mouse.left) dedo(mouse.x,mouse.y); end
			if(mouse.right) while(mouse.right) frame; end boton_salir=1; end
			if(scan_code==102 and os_id==1003) while(scan_code!=0) frame; end boton_salir=1; end

			for(i=0; i<10; i++)
				if(multi_info(i, "ACTIVE") > 0)
					dedo(multi_info(i, "X"),multi_info(i, "Y"));
				end
			end
		end
	
		if(key(_alt) and key(_enter)) 
			while(scan_code!=0) frame; end 
			if(full_screen) full_screen=0; else full_screen=1; end
			set_mode(ancho_pantalla,alto_pantalla,bpp);
		end
		
		from i=1 to posibles_jugadores;
			if(boton[i]) boton[0]=1; break; end
		end
		frame;
	end
End

#IFDEF RED
process process_client(int sock, int ipaddr, int portaddr)
private
    char msg[20];
    string hdrFields[128];
    string request[3];
    rlen, slen, n, pos, d1, d2, cnt;
	estado;
begin
	no_matar=1;
    net_clients++;

	//say("Connection from ip "+ fsock_get_ipstr(ipaddr) + ":" + portaddr);

    fsock_fdzero(1);
    fsock_fdset(1,sock);

    while(msg!="FIN")
    	// As every frame is executed separately, there's no problem with this
        if (fsock_select(1,-1,-1,0)>0 && fsock_fdisset(1,sock))
        	// In the real world, you'd loop here until you got the full package
            rlen=tcpsock_recv(sock,&msg,sizeof(msg));
            if(rlen<=0)
                break;
            end
			if(estado_red==-1) //-1: finalizando fsock
				msg="FIN";
			else
				if(estado_red==1) //permite conexiones
					if(msg=="CON")
						jugador=-1;
						from i=1 to 32;
							if(rana_juega[i]==0)
								jugador=i;
								boton[jugador]=1;
								break;
							end
						end
						if(jugador!=-1)
							estado=1;
							msg=""+jugador; //le devolvemos su número de jugador
							say("Nuevo jugador:"+jugador);
						else
							msg="ERR";
						end
					end
				end
				if(msg[0]=="B" or msg[0]=="U")
					jugador=atoi(""+msg[1]+msg[2]);
					if(msg[0]=="B")
						boton[jugador]=1;
					elseif(msg[0]=="U")
						boton[jugador]=0;
					end
					if(rana_msg[jugador]!="")
						msg=rana_msg[jugador];
						rana_msg[jugador]="";
					else
						if(rana_puntos[jugador]<10)
							msg="S0"+rana_puntos[jugador];
						else
							msg="S"+rana_puntos[jugador];
						end
					end
				End
			end
			if(msg=="")
				msg="NOP";
			end
			tcpsock_send(sock, &msg, sizeof(msg));
        end
        
        fsock_fdset(1,sock); // We must reinclude the socket after the select

        frame;
    end
onexit
	fsock_close(sock); // Close the socket
    net_clients--;
end
#ENDIF

Process dedo(x,y);
Begin
	priority=1;
	graph=71;
	alpha=0;
	frame;
End

Process pon_boton(jugador);
Begin
	priority=-1;
	graph=800+jugador;
	ancho=graphic_info(0,graph,g_width);

	if(posibles_jugadores==2)
		if(jugador==1) 
			x=(ancho_pantalla/32)+((ancho/2)*size)/100;
		else
			x=ancho_pantalla-((ancho_pantalla/32)+(((ancho/2)*size)/100));
		end
		y=alto_pantalla/6*5;
	elseif(posibles_jugadores==4)
		
	end
	
	if(rana_juega[jugador]==0) alpha=100; end
	loop
		boton[jugador]=0;
		if(collision_box(type dedo)) 
			boton[jugador]=1; 
			if(alpha<255) rana_juega[jugador]=1; net_let_me_alone(); juego(); return; end
		end
		frame;
	end
End

Process gana_rana(jugador);
Begin
	if(posibles_jugadores<16)
		graph=500+jugador;
	else
		graph=write_in_map(fnt_textos,jugador,4);
	end
	x=ancho_pantalla/2;
	y=(alto_pantalla/8)*3;
	z=-50;
	alpha=0;
	size=250;
	angle=60000;
	loop
		if(tactil and size<101)
			if(mouse.left and collision_box(type mouse))
				timer[0]=300;
			end
		end
		if(size>100)
			size-=((size-100)/8)+2;
			if(size<105) size=100; end
		end
		if(alpha<255) 
			alpha+=((255-alpha)/8)+2;
			if(alpha>255) alpha=255; end
		end
		if(angle>0) 
			angle+=(0-angle/8)-1000;
			if(angle<0) angle=0; end
		end
		frame;
	end
End

Process gana_rana_you_win();
Begin
	graph=520;
	x=ancho_pantalla/2;
	y=(alto_pantalla/2);
	z=-50;
	alpha=40;
	loop
		if(alpha<255) alpha+=10; y++; end
		frame;
	end
End

Process gana_rana_wins_match();
Begin
	graph=522;
	x=ancho_pantalla/2;
	y=(alto_pantalla/2);
	z=-50;
	alpha=40;
	loop
		if(alpha<255) alpha+=10; y++; end
		frame;
	end
End

Function salir();
Begin
	guarda_opciones();
	exit();
End

Process num_jugador();
Begin
	jugador=father.jugador;
	ctype=c_scroll;
	if(father.graph==52)
		set_text_color(rgb(0,0,0));
	else
		set_text_color(rgb(255,255,255));
	end
	graph=write_in_map(0,jugador,4);
	loop
		if(!exists(father)) break; end
		x=father.x;
		if(father.graph%2==1)
			y=father.y;
		else
			y=father.y+4;
		end
		z=father.z-1;
		frame;
	end
End

Process gana_rana_player();
Begin
	
End

Function net_let_me_alone();
Begin
	while(i=get_id(0))
		if(i.no_matar==0 and i!=father.id and i!=id)
			signal(i,s_kill);
		end
	end
End

//------------- CLIENTE PIXFROGGER EMBEBIDO EN EL PROPIO JUEGO
#ifdef RED
	include "net-client.pr-";
#endif