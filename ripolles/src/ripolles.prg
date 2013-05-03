Program ripolles;

import "mod_blendop";
#IFDEF DEBUG
	import "mod_debug";
#ENDIF
import "mod_dir";
import "mod_draw";
import "mod_file";
import "mod_grproc";
import "mod_joy";
import "mod_key";
import "mod_map";
import "mod_math";
import "mod_mouse";
import "mod_proc";
import "mod_rand";
import "mod_regex";
import "mod_say";
import "mod_screen";
import "mod_scroll";
import "mod_sound";
import "mod_string";
import "mod_sys";
//import "mod_text";
import "mod_timers";
import "mod_video";
import "mod_wm";

Const
	//animaciones y acciones
	quieto=0;
	camina=1;
	salta=2;
	ataca_suelo=3;
	ataca_aire=4;
	defiende=5;
	herido_leve=6;
	herido_grave=7;
	ataca_area=8;
	coge_objeto=9;
	quieto_objeto=10;
	camina_objeto=11;
	salta_objeto=12;
	lanza_objeto=13;
	ataca_fuerte=14;
	ataca_uppercut=15;
	corre=16;
	corre_objeto=17;
	cogido=18;
	muere=-1;
	
	//objetos
	rosquilleta=1;
	papelera=2;
	canya=3;
	rollo=4;
	casco=5;
		
	//modos de movimiento
	encerrandome=0;
	sin_encerrarme=1;
End

Global
	ready=0;

	retraso_jukebox=500;
	jukeboxing=0;
	
	pocos_recursos=0;
	good_vs_evil=0;

	
	puntos;

	arcade_mode;
	
	string savegamedir;
	string developerpath="/.PiXJuegos/Ripolles/";
	string lang_suffix="";
	
	anterior_cancion;

	panoramico=1;
	
	joysticks[10];
	posibles_jugadores;
	njoys;
	ancho_nivel;
	alto_nivel;
	//estructuras de los personajes
	struct p[100];
		botones[7];
		vida;
		vidas;
		puntos;
		control;
		juega;
		identificador;
	end
	
	Struct ops;
		lenguaje=-1;
		musica=1;
		sonido=1;
		ventana=1;
		dificultad=1; //0,1,2
		truco_pato=-1;
		truco_matajefes=0;
		truco_fuego_amigo=-5;
		truco_sin_bandos=-1;
	End	
	
	fpg_pato;
	fpg_ripolles1;
	fpg_ripolles2;
	fpg_ripolles3;
	fpg_ripolles4;
	fpg_menu;
	fpg_nivel;
	fpg_general;
	fpg_objetos;
	fpg_enemigo1;
	fpg_enemigo2;
	fpg_enemigo3;
	fpg_enemigo4;
	fpg_enemigo5;
	fpg_jefe;
	fpg_cutscenes;
	fpg_lang;
	fpg_texto;
	fpg_tiempo;
	wavs[50];
	
	enemigos;
	id_camara;
	
	jugadores;

	nivel;
		
	ancho_pantalla=640;
	alto_pantalla=360;
	bpp=32;
	
	coordenadas=c_scroll;

	modo_juego;
	
	anterior_emboscada;
	en_emboscada;

	enemigos_matados;
	fuego_amigo=0;
	sin_bandos=0;
	renacimiento;
	mata_enemigos;
	ganando;
	
	struct emboscada[20];
		x_evento;
		evento_especial;
		max_x;
		min_x;
		struct enemigo[30];
			pos_x;
			pos_y;
			tipo;
			flags;
		end
	end

	partida_cargada;
	
	//modos de juego (alguno puede variar al ser desbloqueable)
	modo_historia=1;
	modo_supervivencia=2;
	modo_matajefes=-1;
	modo_battleroyale=-1;
	modo_good_vs_evil=-1;
End

Local
	ancho;
	alto;
	altura;
	accion;
	herida;
	id_col;
	rango;
	lleva_objeto;
	animacion;
	anim; //contador
	animacion_anterior;
	gravedad;
	jugador;
	y_inc;
	x_inc;
	y_base;
	i; j;
	tipo;
End

include "../../common-src/controles.pr-";
include "../../common-src/savepath.pr-";
include "../../common-src/lenguaje.pr-";
include "../../common-src/mod_text2.pr-";
include "jefe1.pr-";
include "jefe4.pr-";
include "niveles.pr-";
include "menu.pr-";
include "cutscenes.pr-";
include "personaje.pr-";
include "enemigo.pr-";

Begin

	fpg_texto_margen=-4;
	fpg_texto_espacio=30;

	if(argc>0) if(argv[1]=="arcade") arcade_mode=1; end end

	savepath();
	
	if(os_id==1003)
		savegamedir="/data/data/com.pixjuegos.ripolles/files/";
		mkdir(savegamedir);
	end
	
	carga_opciones();
	
	if(ops.lenguaje==-1)
		switch(lenguaje_sistema())
			case "es": ops.lenguaje=1; end
			default: ops.lenguaje=0; end
		end	
	end

	if(os_id==1003) ops.lenguaje=0; end

	switch(ops.lenguaje)
		case 1: lang_suffix="es"; end
		default: lang_suffix="en"; end
	end

	//La resolución del monitor será esta:
	if(os_id==os_caanoo or os_id==10 or os_id==os_gp2x or os_id==os_gp2x_wiz or os_id==os_gp32 or os_id==os_dc)
		panoramico=0;
		//scale_resolution=03200240;
		ancho_pantalla=480;
		alto_pantalla=360;
		bpp=16;
	elseif(os_id==os_wii)
		scale_resolution=06400480;
		bpp=16;	
	elseif(os_id==1003 or os_id==1002) //móviles
		if(graphic_info(0,0,g_width)==1024 and graphic_info(0,0,g_height)==552)
			ancho_pantalla=665; //archos gamepad
			alto_pantalla=360;
		else
			scale_resolution=graphic_info(0,0,g_width)*10000+graphic_info(0,0,g_height);
		end
		bpp=16;	
	elseif(os_id==1010) //pandora
		scale_resolution=08000480;
		bpp=16;
	elseif(os_id==1001) //psp
		scale_resolution=04800272;
		alto_pantalla=360;
		ancho_pantalla=633;
		pocos_recursos=1;
		bpp=16;
	else
		scale_resolution=12800720;
		//graph_mode=mode_2xscale;
	end
	
	if(ops.ventana==0)
		full_screen=true;
	else
		full_screen=false;
	end
	
	if(arcade_mode)
		bpp=32;
		scale_resolution=08000600;
		full_screen=true;
	end
	
	//Pero internamente trabajaremos con esto:
	set_mode(ancho_pantalla,alto_pantalla,bpp);

	//gráfico para mientras se carga
	graph=load_png("loading.png");
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	if(!panoramico) size=75; end
	z=-520;
	
	from alpha=0 to 255 step 20; frame; end
	timer[0]=0;

	//configuramos controladores
	configurar_controles();
	controlador(0);
	
	//cargamos recursos
	carga_fpgs();
	carga_wavs();

	//recolocamos el centro de los objetos
	recoloca_centros();
	
	//A 30 imágenes por segundo
	set_fps(30,0);
	
	loop
		if(timer[0]>500 or key(_esc) or key(_enter) or p[0].botones[b_1] or p[0].botones[b_2] or p[0].botones[b_3]) break; end
		frame; 
	end
	from alpha=255 to 0 step -20; frame; end
	
	fade_off();
	while(fading) frame; end
	
	#IFDEF TACTIL
	if(file_exists(savegamedir+"turbo.dat"))
		carga_partida_rapida();
		return;
	end
	#ENDIF
	
	//iniciamos el menú
	//test_text();
	//fade_on();
	menu(-1);
	return;
End

Function carga_wavs();
Begin
	from i=1 to 50;
		wavs[i]=load_wav("wav/"+i+".wav");
	end
End

Function carga_fpgs();
Begin
	fpg_ripolles1=load_fpg("fpg/ripolles1.fpg");
	fpg_pato=load_fpg("fpg/pato.fpg");
	if(posibles_jugadores>1) //ahorro de recursos!
		fpg_ripolles2=load_fpg("fpg/ripolles2.fpg");
		fpg_ripolles3=load_fpg("fpg/ripolles3.fpg");
		fpg_ripolles4=load_fpg("fpg/ripolles4.fpg");
	end
	fpg_enemigo1=load_fpg("fpg/enemigo1.fpg");
	fpg_enemigo2=load_fpg("fpg/enemigo2.fpg");
	fpg_enemigo3=load_fpg("fpg/enemigo3.fpg");
	fpg_enemigo4=load_fpg("fpg/enemigo4.fpg");
	fpg_enemigo5=load_fpg("fpg/enemigo5.fpg");
	fpg_general=load_fpg("fpg/general.fpg");
	fpg_objetos=load_fpg("fpg/objetos.fpg");
	fpg_menu=load_fpg("fpg/menu.fpg");
	fpg_texto=load_fpg("fpg/fnt1.fpg");
	fpg_tiempo=load_fpg("fpg/tiempo.fpg");
	#IFDEF OUYA
		fpg_lang=load_fpg("fpg/"+lang_suffix+"-ouya.fpg");
	#ELSE
		fpg_lang=load_fpg("fpg/"+lang_suffix+".fpg");
	#ENDIF
End

Process jugar();
Private
	txt_pausa[2];
Begin
	let_me_alone();
	if(pocos_recursos)
		unload_fpg(fpg_menu);
	end
	set_fps(30,5);
	clear_screen();
	delete_text(all_text);
	ganando=0;
	en_emboscada=0;

	if(partida_cargada==0)
		anterior_emboscada=0;
	end
	
	enemigos=0;
	enemigos_matados=0;
	if(fpg_nivel>0) unload_fpg(fpg_nivel); end

	if(ops.truco_fuego_amigo==1) fuego_amigo=1; else fuego_amigo=0; end
	if(ops.truco_sin_bandos==1) sin_bandos=1; else sin_bandos=0; end
	
	switch(modo_juego)
		case modo_historia:
			carga_nivel(nivel);
			muestra_nivel();
		end
		case modo_supervivencia:
			supervivencia();
		end
		case modo_battleroyale:
			battleroyale();
		end
		case modo_matajefes:
			matajefes();
		end
	end
	
	ancho_nivel=graphic_info(fpg_nivel,1,G_WIDTH);
	alto_nivel=graphic_info(fpg_nivel,1,G_HEIGHT);
	
	start_scroll(0,fpg_nivel,1,0,0,8);
	id_camara=scroll[0].camera=camara();
	
	if(good_vs_evil)
		jugadores=2;
		p[3].juega=0;
		p[4].juega=0;
	end
	
	from i=1 to posibles_jugadores;
		if(p[i].juega==1)
			personaje(i,0);
		end
	end

	fade_on();
	while(fading) frame; end

	partida_cargada=1;
	frame;
	partida_cargada=0;
	
	ready=1;
	
	controlador(0);
	
	loop
		if(modo_juego!=modo_historia) jukebox(); end
		averigua_jugadores();
		if(jugadores==0 or (modo_juego==modo_battleroyale and jugadores==1) or (ganando==1 and modo_juego==modo_historia))
			break;
		end
		
      	if(p[0].botones[b_salir] and ready)
			while(p[0].botones[b_salir]) frame; end
			
			#IFDEF OUYA
				switch(ops.lenguaje)
					case 0:
						txt_pausa[1]=write(fpg_texto,ancho_pantalla/2,(alto_pantalla/2)-30,4,"PAUSE");
						txt_pausa[2]=write(fpg_texto,ancho_pantalla/2,alto_pantalla/2,4,"Press Button A to exit");
					end
					case 1:
						txt_pausa[1]=write(fpg_texto,ancho_pantalla/2,(alto_pantalla/2)-30,4,"PAUSA");
						txt_pausa[2]=write(fpg_texto,ancho_pantalla/2,alto_pantalla/2,4,"Pulsa el botón A para salir");
					end
					case 2:
						txt_pausa[1]=write(fpg_texto,ancho_pantalla/2,(alto_pantalla/2)-30,4,"PAUSA");
						txt_pausa[2]=write(fpg_texto,ancho_pantalla/2,alto_pantalla/2,4,"Pulsa el botón A para salir");
					end
				end
			#ELSE
				switch(ops.lenguaje)
					case 0:
						txt_pausa[1]=write(fpg_texto,ancho_pantalla/2,(alto_pantalla/2)-30,4,"PAUSE");
						txt_pausa[2]=write(fpg_texto,ancho_pantalla/2,alto_pantalla/2,4,"Press Button 3 to exit");
					end
					case 1:
						txt_pausa[1]=write(fpg_texto,ancho_pantalla/2,(alto_pantalla/2)-30,4,"PAUSA");
						txt_pausa[2]=write(fpg_texto,ancho_pantalla/2,alto_pantalla/2,4,"Pulsa el botón 3 para salir");
					end
					case 2:
						txt_pausa[1]=write(fpg_texto,ancho_pantalla/2,(alto_pantalla/2)-30,4,"PAUSA");
						txt_pausa[2]=write(fpg_texto,ancho_pantalla/2,alto_pantalla/2,4,"Pulsa el botón 3 para salir");
					end
				end
			#ENDIF

			sonido(1,0);
			ready=0;
			frame(3000);
			while(!p[0].botones[b_salir])
				if(p[0].botones[b_3]) while(p[0].botones[b_3]) frame; end menu(-1); end
				frame; 
			end
			while(p[0].botones[b_salir]) frame; end
			delete_text(txt_pausa[1]);
			delete_text(txt_pausa[2]);
			sonido(2,0);
			ready=1;
		end

		if(key(_1))
			if(p[1].juega==0) personaje(1,0); end
			p[1].vida=100;
		end
		if(key(_2))
			if(p[2].juega==0) personaje(2,0); end
			p[2].vida=100;
		end
		if(key(_3))
			if(p[3].juega==0) personaje(3,0); end
			p[3].vida=100;
		end
		if(key(_4))
			if(p[4].juega==0) personaje(4,0); end
			p[4].vida=100;
		end
		if(key(_k)) 
			while(key(_k)) frame; end 
			mata_enemigos=1; 
			frame; 
			mata_enemigos=0; 
		end
		frame;
	end

	ready=0;
	
	if(jugadores>0)
		ganando=1;
	end
	frame(5000);

	if(modo_juego==modo_historia and jugadores>0)
		from i=1 to jugadores;
			if(p[i].juega)
				p[i].vida++;
			end
		end
		nivel_superado();
		while(exists(type nivel_superado)) frame; end
		switch(nivel)
			case 1:
				nivel=4;
				fade_off();
				while(fading) frame; end
				jugar();
				return;
			end
			case 4:
				fade_off();
 				while(fading) frame; end
				final_del_juego();
				return;
			end
		end
	end

	x=ancho_pantalla/2;
	y=(alto_pantalla/2)-(13*4);
	z=-256;
	file=fpg_lang;
	i=0;

	if(modo_juego==modo_battleroyale)
		if(ops.truco_fuego_amigo<0)
			ops.truco_fuego_amigo++; //jugador secreto Pato disponible
			guarda_opciones();
			if(ops.truco_fuego_amigo==0)
				switch(ops.lenguaje)
					case 0: truco_descubierto("Friendly fire unlocked!"); end
					case 1: truco_descubierto("Fuego amigo desbloqueado!"); end
					case 2: truco_descubierto("Fuego amigo desbloqueado!"); end
				end
				while(exists(type truco_descubierto)) frame; end
			end
		end
	
		from i=1 to 9;
			if(p[i].juega)
				graph=30+i; 
				if(graph==31 and ops.truco_pato==1) graph=36; end
				break; 
			end
		end
		write(0,0,0,0,i);
	else
		if(ops.truco_pato==1)
			graph=35;
		else
			graph=30;
		end
	end
	
	if(modo_juego==modo_supervivencia and ops.truco_sin_bandos<0)
		if(timer[0]>60*5) //si ha aguantado más de 5 minutos, le damos el cheto "sin bandos"
			ops.truco_sin_bandos=0; //modo matajefes disponible
			guarda_opciones();
			switch(ops.lenguaje)
				case 0: truco_descubierto("No bands unlocked!"); end
				case 1: truco_descubierto("Sin bandos desbloqueado!"); end
				case 2: truco_descubierto("Sin bandos desbloqueado!"); end
			end
			while(exists(type truco_descubierto)) frame; end
		end
	end
	
	delete_text(all_text);
	from alpha=0 to 255 step 20; y+=4; frame; end
	y=alto_pantalla/2;
	timer[0]=0;
	let_me_alone();
	stop_scroll(0);
	while(timer[0]<100)
		frame; 
	end
	controlador(i);
	while(p[i].botones[b_1] or p[i].botones[b_2] or p[i].botones[b_3]) frame; end
	while(!(p[i].botones[b_1] or p[i].botones[b_2] or p[i].botones[b_3])) frame; end
	from alpha=255 to 0 step -20; y+=4; frame; end
	menu(-1);
End

Function recoloca_centros();
Begin
	//todos los objetos deben tener el centro en su base
	from i=1 to 998;
		if(graphic_info(fpg_objetos,i,G_HEIGHT)>0)
			set_center(fpg_objetos,i,graphic_info(fpg_objetos,i,G_WIDTH)/2,graphic_info(fpg_objetos,i,G_HEIGHT)-10);
		end
	end
	
	//las barras de vida deben tener su centro en la izquierda
	set_center(fpg_general,25,0,graphic_info(fpg_general,25,G_HEIGHT)/2);
	set_center(fpg_general,26,0,graphic_info(fpg_general,26,G_HEIGHT)/2);
	set_center(fpg_general,27,0,graphic_info(fpg_general,27,G_HEIGHT)/2);
	
	//enemigos inclusive
	set_center(fpg_general,51,0,0);
	set_center(fpg_general,52,0,0);
End

Process camara();
Private
	suma_x;
Begin
	if(modo_juego!=1)
		x=ancho_pantalla/2;
		y=alto_pantalla/2;
		loop frame; end 
	end

	if(partida_cargada)
		x=emboscada[anterior_emboscada].min_x;
	else
		from i=1 to 30;
			if(emboscada[en_emboscada+1].enemigo[i].tipo!=0)
				enemigo(10+i,emboscada[en_emboscada+1].enemigo[i].tipo,emboscada[en_emboscada+1].enemigo[i].pos_x,emboscada[en_emboscada+1].enemigo[i].pos_y,emboscada[en_emboscada+1].x_evento,emboscada[en_emboscada+1].enemigo[i].flags);
			end
		end
	end
	
	x_inc=15;
	y_inc=5;
	//y_base=alto_nivel-alto_pantalla;
	
	loop
		while(!ready) frame; end
		suma_x=0;
		j=0;
		from i=1 to 4;
			if(exists(p[i].identificador))
				suma_x+=p[i].identificador.x;
				j++;
			end
		end

		if(j>0)
			suma_x=suma_x/j;
		else
			suma_x=x;
		end
		
		if(en_emboscada>0)
			if(!panoramico and emboscada[en_emboscada].min_x==emboscada[en_emboscada].max_x)
				emboscada[en_emboscada].min_x=emboscada[en_emboscada].min_x-80;
				emboscada[en_emboscada].max_x=emboscada[en_emboscada].max_x+80;
			end
			if(suma_x<emboscada[en_emboscada].min_x)
				suma_x=emboscada[en_emboscada].min_x;
			elseif(suma_x>emboscada[en_emboscada].max_x)
				suma_x=emboscada[en_emboscada].max_x;
			end
		end

		if(suma_x!=0)
			if(x<suma_x)
				x+=x_inc;
				if(x>suma_x) x=suma_x; end
			elseif(x>suma_x)
				x-=x_inc;
				if(x<suma_x) x=suma_x; end
			end
		end
		
		if(x<ancho_pantalla/2) x=ancho_pantalla/2; end
		if(x>ancho_nivel-(ancho_pantalla/2)) x=ancho_nivel-(ancho_pantalla/2); end
		if(en_emboscada>0)
			if(enemigos==0)
				from i=1 to 30;
					if(emboscada[en_emboscada+1].enemigo[i].tipo!=0)
						enemigo(10+i,emboscada[en_emboscada+1].enemigo[i].tipo,emboscada[en_emboscada+1].enemigo[i].pos_x,emboscada[en_emboscada+1].enemigo[i].pos_y,emboscada[en_emboscada+1].x_evento,emboscada[en_emboscada+1].enemigo[i].flags);
					end
				end
				anterior_emboscada=en_emboscada;
				en_emboscada=0;
				gogogo();
			end
		else
			if(personaje_mas_avanzado()>0)
				if(p[personaje_mas_avanzado()].identificador.x=>emboscada[anterior_emboscada+1].x_evento and emboscada[anterior_emboscada+1].x_evento!=0)
					en_emboscada=anterior_emboscada+1;
					switch(emboscada[en_emboscada].evento_especial)
						case 101: //1er jefe
							pon_musica(12);
							jefe1(emboscada[en_emboscada].x_evento);
						end
						case 104: //4º jefe
							pon_musica(12);
							jefe4(emboscada[en_emboscada].x_evento);
						end
						case 111: //evil ripolles
							from i=1 to jugadores;
								enemigo(11+i,5,id_camara.x-(ancho_pantalla/2)-100,150+(i*20),0,1);
							end
						end	
					end
				end
			end
		end
		frame;
	end
End

Process estela();
Begin
	ctype=coordenadas;
	x=father.x;
	y=father.y;
	size=father.size;
	z=father.z;
	graph=father.graph;
	file=father.file;
	alpha=father.alpha;
	angle=father.angle;
	flags=father.flags;
	while(alpha>0)
		while(!ready) frame; end
		alpha-=50; 
		frame; 
	end
End

Function inercia_maxima(max_x,max_y);
Begin
	if(father.x_inc>0)
		if(father.x_inc>max_x) father.x_inc=max_x; end
	elseif(father.x_inc<0)
		if(father.x_inc<-max_x) father.x_inc=-max_x; end
	end
	if(father.y_inc>0)
		if(father.y_inc>max_y) father.y_inc=max_y; end
	elseif(father.y_inc<0)
		if(father.y_inc<-max_y) father.y_inc=-max_y; end
	end
End

Function pon_animacion();
Begin
	if(father.altura==0)
		if(father.accion==quieto)
			if(father.lleva_objeto!=0)
				father.animacion=quieto_objeto;
			else
				father.animacion=quieto;
			end
		end
		if(father.accion==camina)
			if(father.lleva_objeto!=0)
				father.animacion=camina_objeto;
			else
				father.animacion=camina;
			end
		end
		if(father.accion==corre)
			if(father.lleva_objeto!=0)
				father.animacion=corre_objeto;
			else
				father.animacion=corre;
			end
		end

	else //en el aire
		if(father.lleva_objeto!=0)
			father.animacion=salta_objeto;
		else
			if(father.accion==ataca_aire)
				father.animacion=ataca_aire;
			elseif(father.accion==ataca_uppercut)
				father.animacion=ataca_uppercut;
			else
				father.animacion=salta;
			end
		end
	end
	if(father.accion==ataca_suelo)
		father.animacion=ataca_suelo;
	end
	if(father.accion==ataca_fuerte)
		father.animacion=ataca_fuerte;
	end
	if(father.accion==ataca_area)
		father.animacion=ataca_area;
	end
	if(father.accion==defiende)
		father.animacion=defiende;
	end
	if(father.accion==coge_objeto)
		father.animacion=coge_objeto;
	end
	if(father.accion==lanza_objeto)
		father.animacion=lanza_objeto;
	end
	if(father.accion==herido_leve)
		father.animacion=herido_leve;
	end
	if(father.accion==herido_grave)
		father.animacion=herido_grave;
	end
	if(father.accion==muere)
		father.animacion=muere;
	end
End

Function mueveme(forma);
Begin
		father.y_base+=father.y_inc;
		father.y=father.y_base+father.altura;
		father.z=-father.y_base;

		if(father.y_base<135) father.y_base=135; end
		if(father.y_base>305) father.y_base=305; end
	
		if((father.x<30 and father.x_inc<0) or (father.x>ancho_nivel-30 and father.x_inc>0)) father.x_inc*=-1; end

		if(forma==encerrandome)
			if(father.x<id_camara.x-((ancho_pantalla/2)-50)) father.x=id_camara.x-((ancho_pantalla/2)-50); end
			if(father.x>id_camara.x+((ancho_pantalla/2)-50)) father.x=id_camara.x+((ancho_pantalla/2)-50); end
		end
		
		if(father.altura==0)
			father.x+=father.x_inc;
		else
			father.x+=father.x_inc*1.4;
		end		
End

Function friccioname();
Begin
	if(father.x_inc>0)
		father.x_inc--;
	elseif(father.x_inc<0)
		father.x_inc++;
	end
	if(father.y_inc>0)
		father.y_inc--;
	elseif(father.y_inc<0)
		father.y_inc++;
	end
End

Function animame();
Private
	anim_max;
Begin
	animacion_anterior=father.animacion_anterior;
	animacion=father.animacion;
	if(animacion!=animacion_anterior)
		anim=0;
		animacion_anterior=animacion;
	else
		anim=father.anim;
		anim++;
	end
	jugador=father.jugador;
	
	//por defecto, para las animaciones que no utilicen el contador,
	//para evitar una cuenta infinita
	anim_max=10;
	
	switch(animacion)
		case quieto:
			father.graph=1;
		end
		case camina:
			if(anim<6) 
				father.graph=11;
			elseif(anim<12)
				father.graph=12;
			elseif(anim<18)
				father.graph=13;
			elseif(anim<24)
				father.graph=14;
			else 
				father.graph=13;
			end
			anim_max=30;
		end
		case salta:
			if(father.gravedad<0) //sube
				father.graph=21;
			else //baja
				father.graph=22;
			end
		end
		case ataca_uppercut:
			father.graph=171;
		end
		case ataca_suelo:
			if(anim<4) 
				father.graph=31;
			else
				father.graph=32;
			end
			anim_max=8;
		end
		case ataca_aire:
			father.graph=42;
		end
		case defiende:
			if(father.altura==0)
				father.graph=51;
			else
				father.graph=181;
			end
		end
		case herido_leve:
			father.graph=61;
		end
		case herido_grave:
			if(father.altura==0)
				if(father.herida<5)
					father.graph=73;
				else
					father.graph=151;
				end
			elseif(father.gravedad<=0) //sube
				father.graph=71;
			elseif(father.gravedad>0) //baja
				father.graph=72;
			end
		end
		case ataca_area:
			if(anim<2) 
				father.graph=81;
			elseif(anim<4)
				father.graph=82;
			elseif(anim<6)
				father.graph=83;
			elseif(anim<8)
				father.graph=84;
			elseif(anim<10) 
				father.graph=81;
			elseif(anim<12)
				father.graph=82;
			elseif(anim<14)
				father.graph=83;
			elseif(anim<16)
				father.graph=84;
			elseif(anim<18) 
				father.graph=81;
			elseif(anim<20)
				father.graph=82;
			elseif(anim<22)
				father.graph=83;
			else
				father.graph=84;
			end
			anim_max=24;
		end
		case coge_objeto:
			if(anim<4) 
				father.graph=91;
			else
				father.graph=92;
			end
			anim_max=8;
		end
		case quieto_objeto:
			father.graph=101;
		end
		case camina_objeto:
			if(anim<6) 
				father.graph=111;
			elseif(anim<12)
				father.graph=112;
			elseif(anim<18)
				father.graph=113;
			elseif(anim<24)
				father.graph=114;
			else 
				father.graph=113;
			end
			anim_max=30;
		end
		case corre:
			if(anim<4) 
				father.graph=191;
			elseif(anim<8)
				father.graph=192;
			elseif(anim<12)
				father.graph=193;
			else
				father.graph=194;
			end
			anim_max=16;
		end
		case corre_objeto:
			if(anim<4) 
				father.graph=201;
			elseif(anim<8)
				father.graph=202;
			elseif(anim<12)
				father.graph=203;
			else
				father.graph=204;
			end
			anim_max=16;
		end
		case salta_objeto:
			if(father.gravedad<0) //sube
				father.graph=121;
			else //baja
				father.graph=122;
			end
		end
		case lanza_objeto:
			if(anim<4)
				father.graph=131;
			else
				father.graph=132;
			end
		end
		case ataca_fuerte:
			if(anim<8)
				father.graph=141;
			elseif(anim<12)
				father.graph=142;
			else
				father.graph=143;
			end
			anim_max=16;
		end
		case muere:
			if(father.altura==0)
				if(father.herida<5)
					father.graph=73;
				else
					father.graph=151;
				end
			elseif(father.gravedad<=0) //sube
				father.graph=71;
			elseif(father.gravedad>0) //baja
				father.graph=72;
			end
		end
	end
	if(anim=>anim_max) anim=0; end

	father.animacion_anterior=animacion;
	father.animacion=animacion;
	if(anim<=anim_max)
		father.anim=anim;
	else
		father.anim=0;
	end
End

Function en_rango(z1,z2,rango);
Private
	dist_z;
Begin
	if(z1>z2)
		dist_z=z1-z2;
	else
		dist_z=z2-z1;
	end	
	if(rango>dist_z)
		return 1; 
	else
		return 0;
	end
End

Process cuerpo();
Begin
	jugador=father.jugador;
	ctype=coordenadas;
	x=father.x;
	y=father.y;
	z=father.z-1;
	file=fpg_general;
	graph=2;
	
	alpha=0;
	rango=20;
	size=80;
//	if((father.tipo==0 and father.accion!=herido_leve and father.accion!=herido_grave and father.accion!=ataca_area and father.accion!=muere) or (father.tipo!=0 and father.accion!=muere))
	if(father.accion!=herido_leve and father.accion!=herido_grave and father.accion!=ataca_area and father.accion!=muere)
		if(id_col=collision(type ataque))
			if(id_col.jugador!=jugador)
				if(!((jugador>10 and id_col.jugador>10 and id_col.jugador!=0) or (jugador<10 and id_col.jugador<10 and id_col.jugador!=0)) or fuego_amigo) //esta línea evita el fuego amigo
					if(en_rango(z,id_col.z,id_col.rango))
						//if(father.accion==defiende and ((father.flags==0 and x<id_col.x) or (father.flags==1 and x>id_col.x)))
						if(father.accion==defiende)
							//destello();
							if(id_col.x>x)
								father.x_inc=-5;
							else
								father.x_inc=5;
							end
						else
							father.herida=id_col.herida;
							efecto_golpe(id_col);
							if(id_col.flags==0)
								father.flags=1;
							else
								father.flags=0;
							end
						end
					end
				end
			end
		end
		if(father.accion==defiende and father.altura==0)
			if(id_col=collision(type cuerpo))
				if(en_rango(z,id_col.z,rango))
					if(id_col<id) //manda este
						if(x<id_col.x)
							if(id_col.father.accion!=herido_grave)
								id_col.father.x_inc+=3;
								id_col.father.y_inc+=2;
								if(id_col.father.accion==quieto)
									id_col.father.flags=1;
								end
							end
							father.x_inc-=3;
							father.y_inc-=2;
							if(father.accion==quieto)
								father.flags=0;
							end
						else
							if(id_col.father.accion!=herido_grave)
								id_col.father.x_inc-=3;
								id_col.father.y_inc-=2;
								if(id_col.father.accion==quieto)
									id_col.father.flags=0;
								end
							end
							father.x_inc+=3;
							father.y_inc+=2;
							if(father.accion==quieto)
								father.flags=1;
							end
						end
					end
				end
			end
		end
	else
		if(father.accion==herido_grave and father.x_inc!=0 and father.gravedad>0)
			ataque(father.x,father.y,father.file,father.graph,abs(father.x_inc),40,1);
		end
	end
	frame;
End

Process ataque(x,y,file,graph,herida,rango,jugador);
Begin
	flags=father.flags;
	z=father.z;
	priority=-1;
	ctype=coordenadas;
	alpha=0;
	frame;
End

Process objeto_portado(x,y,graph);
Begin
	z=father.z-1;
	flags=father.flags;
	file=fpg_objetos;
	if(flags)
		x-=5;
	else
		x+=5;
	end
	ctype=coordenadas;
	frame;
	while(!ready) frame; end
End

Process objeto(x,y_base,altura,graph,x_inc);
Private
	retraso_colision;
Begin
	y=y_base+altura+40;
	z=y_base-1;
	file=fpg_objetos;
	x_inc=x_inc*2;
	if(exists(father))
		flags=father.flags;
		jugador=father.jugador;
	end
	ctype=coordenadas;
	while(!exists(id_camara)) frame; end
	loop
		while(!ready) frame; end

		//al poco de lanzarlo dejará de estar asociado al jugador y podrá dañar al mismo y a los compañeros
		if(jugador>0)
			j++;
			if(j>10) jugador=0; end
		end
		
		aplica_gravedad();
		if(altura>0) altura=0; end
		if(altura==0)
			friccioname();
		end
		mueveme(sin_encerrarme);
		y+=40; //ajuste del centro del objeto
		
		if(retraso_colision<10) retraso_colision++; end
		
		if((id_col=collision(type objeto)) and retraso_colision==10)
			if(en_rango(z,id_col.z,40))
				if(id>id_col)
					if(id_col.x_inc!=0 or x_inc!=0)
						i=x_inc;
						x_inc=id_col.x_inc;
						id_col.x_inc=i;
						retraso_colision=0;
					end
				end
			end
		end
		
		if(x_inc!=0) //mientras se mueve, golpea
			ataque(x,y,file,graph,abs(x_inc)*2,40,jugador);
		end
		
		z--;
		sombra_objeto();
		frame;
	end
End

Function aplica_gravedad();
Begin
	if(father.altura<0)
		father.gravedad+=2;
		father.altura+=father.gravedad;
		if(father.altura=>1)
			father.altura=0;
			father.gravedad=0;
		else
			father.y+=father.gravedad;
		end
	end
End

Process sombra();
Begin
	y=father.y_base+(father.alto/2);
	z=father.z+10;
	x=father.x;
	altura=father.altura;
	ctype=coordenadas;
	file=fpg_general;
	graph=3;
	alpha=father.alpha+altura-50;
	size=100+(altura/3);
	frame;
	while(!ready and !ganando) frame; end
End

Process sombra_objeto();
Begin
	y=father.y+5;
	z=father.z+10;
	x=father.x;
	altura=father.altura;
	ctype=coordenadas;
	file=fpg_general;
	graph=3;
	alpha=father.alpha+altura-50;
	size=100+(altura/3);
	frame;
	while(!ready) frame; end
End

Function jugador_mas_cercano();
Private
	dist_x;
	dist_x_ganador=1000;
	hasta;
Begin
	if(sin_bandos) hasta=99; else hasta=4; end
	from i=1 to hasta;
		if(p[i].juega and i!=father.jugador)
			if(p[i].identificador.accion!=muere and p[i].identificador.accion!=herido_leve and p[i].identificador.accion!=herido_grave)
				if(p[i].identificador.x<father.x)
					dist_x=father.x-p[i].identificador.x;
				else
					dist_x=p[i].identificador.x-father.x;
				end
				if(dist_x<dist_x_ganador)
					j=i;
					dist_x_ganador=dist_x;
				end
			end
		end
	end
	
	if(dist_x<ancho_pantalla)
		return j;
	else
		return 0;
	end
End

Function distancia_jugador(jugador);
Begin
	if(jugador!=0)
		if(p[jugador].identificador.x<father.x)
			return father.x-p[jugador].identificador.x;
		else
			return p[jugador].identificador.x-father.x;
		end	
	else
		return 1000;
	end
End

Function lado_jugador(jugador);
Begin
	if(p[jugador].identificador.x<father.x)
		return 1; //a la izquierda
	else
		return 0; //a la derecha
	end
End

Function estoy_en_pantalla();
Begin
	if(exists(id_camara))
		if(father.x>id_camara.x+(ancho_pantalla/2))
			return 0; 
		else
			return 1;
		end
	else
		return 1;
	end
End

Function personaje_mas_avanzado();
Private
	max_x;
Begin
	from i=1 to 4;
		if(exists(p[i].identificador))
			if(p[i].identificador.x>max_x)
				j=i;
				max_x=p[i].identificador.x;
			end
		end
	end
	return j;
End

Process tram(pos_x);
Begin
	enemigos++;
	file=fpg_general;
	graph=10;
	x=ancho_pantalla/2;
	y=alto_pantalla/3;
	from alpha=0 to 255 step 40; size+=2; frame; end
	from alpha=255 to 0 step -40; size-=2; frame; end
	from alpha=0 to 255 step 40; size+=2; frame; end
	from alpha=255 to 0 step -40; size-=2; frame; end
	from alpha=0 to 255 step 40; size+=2; frame; end
	from alpha=255 to 0 step -40; size-=2; frame; end

	ctype=coordenadas;
	x=pos_x+ancho_pantalla;
	y=160+(rand(0,1)*70);
	z=-y;
	graph=11;
	flags=1;
	alpha=255;
	while(x>id_camara.x-ancho_pantalla)
		while(!ready) frame; end
		x-=20;
		ataque(x,y+65,file,graph,30,38,jugador);
		if(anim==2) 
			anim=0;
			if(graph==11) graph=12; else graph=11; end
		else
			anim++;
		end
		frame;
	end
	enemigos--;
End

Process avioncete(pos_x);
Begin
	enemigos++;
	file=fpg_general;
	graph=10;
	x=ancho_pantalla/2;
	y=alto_pantalla/3;
	from alpha=0 to 255 step 40; size+=2; frame; end
	from alpha=255 to 0 step -40; size-=2; frame; end
	from alpha=0 to 255 step 40; size+=2; frame; end
	from alpha=255 to 0 step -40; size-=2; frame; end
	from alpha=0 to 255 step 40; size+=2; frame; end
	from alpha=255 to 0 step -40; size-=2; frame; end

	ctype=coordenadas;
	x=pos_x+ancho_pantalla;
	y=160+(rand(0,1)*70);
	z=-y;
	graph=13;
	flags=1;
	alpha=255;
	while(x>id_camara.x-ancho_pantalla)
		while(!ready) frame; end
		x-=20;
		y--;
		ataque(x,y+65,file,graph,30,38,jugador);
		if(x<id_camara.x)
			graph=14;
			y-=3;
		end
		frame;
	end
	enemigos--;
End

Function salir();
Begin
	guarda_opciones();
	full_screen=0;
	set_mode(320,240,32);
	exit();
End

Process pon_musica(i);
Private
	string formato="ogg";
Begin
	if(os_id==os_wii /*or os_id==os_caanoo*/ or os_id==10 or os_id==os_gp2x or os_id==os_gp2x_wiz or os_id==os_gp32 or os_id==os_dc) 
		//formato="mp3"; 
	end
	if(ops.musica)
		if(i!=anterior_cancion)
			fade_music_off(400);
			timer[1]=0;
			while(timer[1]<40) frame; end
			anterior_cancion=i;
			if(exists(type menu))
				play_song(load_song("ogg/"+i+"."+formato),0);
			else
				play_song(load_song("ogg/"+i+"."+formato),-1);
			end
		end
	else
		anterior_cancion=0;
	end
End

Function sonido(i,veces);
Begin
	if(ops.sonido)
		return play_wav(wavs[i],veces);
	end
	return 0;
End

Process marcador(jugador);
Private
	txt_marcador;
Begin
	file=fpg_general;
	if(ops.truco_pato==1 and jugador==1)
		graph=28;
	else
		graph=20+jugador;
	end
	
	x=90+((jugador-1)*150);
	y=30;
	z=-10;
	txt_marcador=write_int(fpg_texto,x-70,y,4,&p[jugador].vidas);
	while(p[jugador].juega)
		vida(x-29,y+2,p[jugador].vida-1,25);
		frame;
	end
	delete_text(txt_marcador);
	from alpha=255 to 0 step -25; y-=2; frame; end
End

Process marcador_jefe();
Private
	max_vida;
Begin
	max_vida=p[100].vida;
	file=fpg_general;
	graph=26;
	x=160;
	y=340;
	z=-10;
	while(p[100].vida>0)
		i=(p[100].vida*100)/max_vida;
		vida(x,y,i,27);
		frame;
	end
	from alpha=255 to 0 step -25; y-=2; frame; end
End

Process vida(x,y,size_x,graph);
Begin
	file=fpg_general;
	z=-11;
	frame;
End

Process efecto_golpe(id_col);
Begin
	x=id_col.x;
	y=id_col.y;
	z=-512;
	ctype=coordenadas;
	file=fpg_general;
	graph=rand(4,7);
	efecto_golpe2();
	angle=rand(0,3)*90000;
	from alpha=255 to 0 step -30; 
		while(!ready) frame; end
		size+=6; 
		frame; 
	end
End

Process efecto_golpe2();
Begin
	x=father.x;
	y=father.y;
	z=-513;
	ctype=coordenadas;
	file=fpg_general;
	graph=father.graph;
	while(graph==father.graph)
		graph=rand(4,7);
	end
	size=40;
	angle=rand(0,3)*90000;
	from alpha=255 to 0 step -30; 
		while(!ready) frame; end
		size+=6; 
		frame; 
	end
End

Process supervivencia();
Private
	timer_not_ready;
Begin
	fpg_nivel=load_fpg("nivel_survival1.fpg");
	from i=1 to jugadores; p[i].vidas=0; end

	timer[0]=0;
	pon_tiempo();
	from i=1 to jugadores; p[i].vidas=0; end
	
	loop
		if(!ready)
			timer_not_ready=timer[0];
			while(!ready) 
				timer[0]=timer_not_ready;
				frame; 
			end
		end
		if(jugadores>0)
			if(enemigos<(timer[0]/1000/jugadores)+1 and enemigos<20)
				i=10;
				loop
					i++;
					if((p[i].vida<1 and p[i].juega==0) or i>99)
						break;
					end
				end
				if(i!=100)
					if(rand(0,1))
						enemigo(i,rand(1,4),-100,rand(100,300),0,0);
					else
						enemigo(i,rand(1,4),ancho_pantalla+100,rand(100,300),0,0);
					end
				end
			end
		end
		frame;
	end
End

Process pon_tiempo();
Private
	decimas;
	segundos;
	minutos;
	txt_tiempo;
	string string_tiempo;
	tiempo;
	tiempo_antes;
Begin
	x=320;
	y=330;
	loop
		while(!ready) frame; end
		if(jugadores==0) return; end
		tiempo=timer[0];
		decimas=tiempo; while(decimas=>100) decimas-=100; end
		segundos=tiempo/100; while(segundos=>60) segundos-=60; end
		minutos=tiempo/6000;
	
		if(decimas<10 and segundos<10) string_tiempo=itoa(minutos)+":0"+itoa(segundos)+":0"+itoa(decimas); end
		if(decimas>9 and segundos<10) string_tiempo=itoa(minutos)+":0"+itoa(segundos)+":"+itoa(decimas); end
		if(decimas<10 and segundos>9) string_tiempo=itoa(minutos)+":"+itoa(segundos)+":0"+itoa(decimas); end
		if(decimas>9 and segundos>9) string_tiempo=itoa(minutos)+":"+itoa(segundos)+":"+itoa(decimas); end
		txt_tiempo=write_fixed(fpg_tiempo,x,y,4,string_tiempo,25);
		frame;
		if(jugadores>0)
			if(ganando)
				tiempo_antes=timer[0];
				while(ganando) frame; end
				timer[0]=tiempo_antes;
			end

			delete_text(txt_tiempo);
		end
	end
End

Function averigua_jugadores();
Begin
	from i=1 to posibles_jugadores;
		if(p[i].juega) j++; end
	end
	jugadores=j;
	return j;
End

Function reinicio_variables();
Begin
	clear_screen();
	stop_scroll(0);
	enemigos_matados=0;
	id_camara=0;
	en_emboscada=0;
	nivel=1;
	anterior_emboscada=0;
	sin_bandos=0;
	fuego_amigo=0;
	ganando=0;
	good_vs_evil=0;
	from i=1 to 10;
		p[i].vidas=5;
	end
	from i=0 to 100;
		p[i].juega=0;
		p[i].vida=0;
		p[i].identificador=0;
	end
	delete_text(all_text);
End

Process final_del_juego();
Begin
	if(ops.truco_pato<1) 
		cutscene_final();
	else
		creditos();
	end
End

Process creditos();
Private
	id_siguiente_imagen;
Begin
	fade_off();
	while(fading) frame; end
	let_me_alone();
	delete_text(all_text);
	stop_scroll(0);
	fpg_nivel=fpg_cutscenes=load_fpg("fpg/cutscenes.fpg");
	pon_musica(15);
	tv();
	fade_on();
	while(fading) frame; end
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	z=1;
	file=fpg_cutscenes;
	from i=34 to 40;
		id_siguiente_imagen=siguiente_imagen(i);
		while(id_siguiente_imagen.alpha<255) frame; end
		graph=i;
		id_siguiente_imagen.accion=-1;
		timer[0]=0;
		while(timer[0]<500) frame; end		
		frame;
	end
	//desbloqueamos el modo matajefes si no está desbloqueado
	if(ops.truco_matajefes==0)
		ops.truco_matajefes=1; //modo matajefes disponible
		guarda_opciones();
		switch(ops.lenguaje)
			case 0: truco_descubierto("Boss rush unlocked!"); end
			case 1: truco_descubierto("Modo matajefes disponible!"); end
			case 2: truco_descubierto("Modo matajefes disponible!"); end
		end

		while(exists(type truco_descubierto)) frame; end
 	end

	fade_off();
	while(fading) frame; end
	menu(-1);
	return;
End

Process siguiente_imagen(graph);
Begin
	file=fpg_cutscenes;
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	z=-1;
	from alpha=0 to 255 step 5; frame; end
	while(accion==0) frame; end
End

Process tv();
Begin
	graph=33;
	file=fpg_cutscenes;
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	z=-2;
	while(exists(father)) frame; end
End

Process matajefes();
Private
	id_jefe;
Begin
	fpg_nivel=load_fpg("nivel_matajefes1.fpg");
	timer[0]=0;
	pon_tiempo();
	from i=1 to jugadores; p[i].vidas=0; end
	pon_musica(12);
	
	while(timer[0]<300) frame; end
	id_jefe=jefe1(ancho_pantalla/2);
	while(!ganando) frame; end
	from alpha=255 to 0 step -15; id_jefe.alpha=alpha; frame; end
	signal(id_jefe,s_kill);
	ganando=0;
	timer[2]=0;
	while(timer[2]<300) frame; end

	/*
	id_jefe=jefe2(id_camara.x);
	while(!ganando) frame; end
	from alpha=255 to 0 step -15; id_jefe.alpha=alpha; frame; end
	timer[2]=0;
	while(timer[2]<300) frame; end

	id_jefe=jefe3(id_camara.x);
	while(!ganando) frame; end
	from alpha=255 to 0 step -15; id_jefe.alpha=alpha; frame; end
	timer[2]=0;
	while(timer[2]<300) frame; end

	*/

	id_jefe=jefe4(ancho_pantalla/2);
	while(!ganando) frame; end
	from alpha=255 to 0 step -15; id_jefe.alpha=alpha; frame; end
	timer[2]=0;
	while(timer[2]<300) frame; end

	/*
	id_jefe=jefe5(id_camara.x);
	while(!ganando) frame; end
	from alpha=255 to 0 step -15; id_jefe.alpha=alpha; frame; end
	timer[2]=0;
	while(timer[2]<300) frame; end

	*/
	
	ganando=0;
	enemigos=0;
	enemigo(11,5,-100,150,0,1);
	if(jugadores>1) enemigo(12,5,ancho_pantalla+100,350,0,1); end
	if(jugadores>2) enemigo(13,5,-100,150,0,1); end
	if(jugadores>3) enemigo(14,5,ancho_pantalla+100,350,0,1); end
	
	while(enemigos>0) frame; end
	
	switch(ops.lenguaje)
		case 0: truco_descubierto("Boss rush completed!"); end
		case 1: truco_descubierto("Modo matajefes superado!"); end
		case 2: truco_descubierto("Modo matajefes superado!"); end
	end
	ganando=1;
	timer[2]=0;
	while(timer[2]<500) frame; end
	
	if(ops.truco_pato<0)
		ops.truco_pato=0; //modo matajefes disponible
		guarda_opciones();
		switch(ops.lenguaje)
			case 0: truco_descubierto("Character PATO unlocked!"); end
			case 1: truco_descubierto("Personaje PATO desbloqueado!"); end
			case 2: truco_descubierto("Personaje PATO desbloqueado!"); end
		end
		while(exists(type truco_descubierto)) frame; end
	end
	menu(-1);
End

Process battleroyale();
Begin
	fpg_nivel=load_fpg("nivel_battleroyale1.fpg");
	from i=1 to jugadores; p[i].vidas=0; end
	fuego_amigo=1;
End

Process muestra_nivel();
Begin
	switch(ops.lenguaje)
		case 0: graph=write_in_map(fpg_texto,"Level "+nivel,4); end
		case 1: graph=write_in_map(fpg_texto,"Nivel "+nivel,4); end
		case 2: graph=write_in_map(fpg_texto,"Nivel "+nivel,4); end
	end
	x=ancho_pantalla/2;
	y=(alto_pantalla/2)-34;
	z=-512;
	from alpha=0 to 255 step 15; y++; frame; end
	muestra_nombre_nivel();
	frame(7000);
	from alpha=255 to 0 step -24; y+=2; frame; end
	unload_map(0,graph);
End

Process muestra_nombre_nivel();
Begin
	switch(ops.lenguaje)
		case 0: 
			switch(nivel)
				case 1: graph=write_in_map(fpg_texto,"Downtown",4); end
				case 4: graph=write_in_map(fpg_texto,"Airport",4); end
			end
		end
		case 1:
			switch(nivel)
				case 1: graph=write_in_map(fpg_texto,"Centro",4); end
				case 4: graph=write_in_map(fpg_texto,"Aeropuerto",4); end
			end
		end
		case 2:
			switch(nivel)
				case 1: graph=write_in_map(fpg_texto,"Centro",4); end
				case 4: graph=write_in_map(fpg_texto,"Aeropuerto",4); end
			end
		end
	end
	x=ancho_pantalla/2;
	y=father.y+20;
	z=-512;
	from alpha=0 to 255 step 15; y++; frame; end
	frame(5000);
	from alpha=255 to 0 step -24; y+=2; frame; end
	unload_map(0,graph);
End

Process nivel_superado();
Begin
	ready=0;
	switch(ops.lenguaje)
		case 0: graph=write_in_map(fpg_texto,"Level "+nivel+" completed",4); end
		case 1: graph=write_in_map(fpg_texto,"Nivel "+nivel+" superado",4); end
		case 2: graph=write_in_map(fpg_texto,"Nivel "+nivel+" superado",4); end
	end
	x=ancho_pantalla/2;
	y=(alto_pantalla/3)-34;
	z=-512;
	from alpha=0 to 255 step 15; y++; frame; end
	frame(15000);
	from alpha=255 to 0 step -24; y+=2; frame; end
	unload_map(0,graph);
End

Process gogogo();
Begin
	file=fpg_general;
	graph=8;
	y=60;
	z=-512;
	from i=1 to 3;
		x=ancho_pantalla-140;
		from alpha=0 to 255 step 30; x+=5; frame; end
		from alpha=255 to 0 step -30; x+=5; frame; end
	end
End

Process truco_descubierto(string texto);
Begin
	graph=write_in_map(fpg_texto,texto,4);
	x=ancho_pantalla/2;
	y=(alto_pantalla/2)-34;
	z=-512;
	from alpha=0 to 255 step 15; y++; frame; end
	frame(15000);
	from alpha=255 to 0 step -24; y+=2; frame; end
	unload_map(0,graph);
End

Function salir_android();
Begin
	#IFDEF TACTIL
	if(modo_juego==modo_historia)
		guarda_partida_rapida();
	end
	frame(500);
	#ENDIF
	exit();
End

Function guarda_partida_rapida();
Private
	struct partida;
		p1_vidas;
		p1_vida;
		nivel;
		anterior_emboscada;
	end
Begin
	partida.nivel=nivel;
	partida.anterior_emboscada=anterior_emboscada;
	partida.p1_vidas=p[1].vidas;
	partida.p1_vida=p[1].vida;

	save(savegamedir+"turbo.dat",partida);
	return;
End


Function carga_partida_rapida();
Private
	struct partida;
		p1_vidas;
		p1_vida;
		nivel;
		anterior_emboscada;
	end
Begin
	load(savegamedir+"turbo.dat",partida);
	fremove(savegamedir+"turbo.dat");

	partida_cargada=1;
	nivel=partida.nivel;
	p[1].vidas=partida.p1_vidas;
	p[1].vida=partida.p1_vida;
	anterior_emboscada=partida.anterior_emboscada;

	jugadores=1;
	p[1].juega=1;
	modo_juego=modo_historia;
	jugar();
	return;
End

Function jukebox();
Begin
	if(ops.musica)
		if(retraso_jukebox>0) 
			retraso_jukebox--; 
		else
			if(!is_playing_song() and retraso_jukebox==0)
				jukeboxing++;
				retraso_jukebox=500;
				switch(jukeboxing)
					case 1: pon_musica(1); end
					case 2: pon_musica(11); end
					case 3: pon_musica(12); end
					case 4: pon_musica(13); end
					case 5: pon_musica(15); end
					case 6: pon_musica(2); jukeboxing=0; end
				end
			end
		end
	end
End