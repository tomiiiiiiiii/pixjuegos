Program ripolles;

import "mod_blendop";
#IFDEF DEBUG
	import "mod_debug";
#ENDIF
#IFDEF OUYA
	import "mod_iap";
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
import "mod_time";
import "mod_timers";
import "mod_video";
import "mod_wm";
#IFDEF OUYA
	import "mod_iap";
#ENDIF

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
	obj_rosquilleta=1;
	obj_papelera=2;
	obj_canya=3;
	obj_rollo=4;
	obj_casco=5;
	obj_mesa=6;
	obj_silla=7;
	obj_naranja_dura=8;
	obj_naranja=9;
	obj_hamburguesa=10;
	obj_pescado=100;

	//modos de movimiento
	encerrandome=0;
	sin_encerrarme=1;
End

Global
	game_fps=40;

	color_arena;
	mini_boss;
	contador;
	num_zona;
	cajas_colision;
	
	con_puntos=1;

	objetos_aleatorios[4]=obj_rollo,obj_naranja_dura,obj_naranja,obj_naranja_dura,obj_hamburguesa;

	evento_hamburguesa;

	mov_camara_moto=0;

	mata_textos_menu;
	
	mapa_nivel;
	
	#IFNDEF GLOBAL_RESOLUTION
	global_resolution=-2;
	#ENDIF
	
	string textos[100];
	ready=0;

	retraso_jukebox=500;
	jukeboxing=0;
	
	pocos_recursos=0;

	en_moto=0;
	
	arcade_mode;
	
	string savegamedir;
	string developerpath="/.PiXJuegos/Ripolles/";
	string lang_suffix="";
	
	anterior_cancion;
	id_cancion;

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
		velocidad_extra;
		fuerza_extra;
		combo;
		bonus;
	end
	
	Struct ops;
		lenguaje=-1;
		musica=1;
		sonido=1;
		ventana=1;
		dificultad=1; //0,1,2
		matajefes=0;
		donacion=0;
		tutorial=1;
		trucos=0;
		truco_pato=-1;
		truco_fuego_amigo=-5;
		truco_hamburguesas=-1;
		truco_good_vs_evil=-1;
		disclaimer=0;
	End	
	
	fpg_pato;
	fpg_pato1bici;
	fpg_pato2;
	fpg_pato2bici;
	fpg_pato3;
	fpg_pato3bici;
	fpg_pato4;
	fpg_pato4bici;
	fpg_ripolles1;
	fpg_ripolles2;
	fpg_ripolles3;
	fpg_ripolles4;
	fpg_ripolles1bici;
	fpg_ripolles2bici;
	fpg_ripolles3bici;
	fpg_ripolles4bici;
	fpg_menu;
	fpg_fondo_menu;
	fpg_nivel;
	fpg_general;
	fpg_objetos;
	fpg_enemigo1;
	fpg_enemigo2;
	fpg_enemigo3;
	fpg_enemigo4;
	fpg_enemigo5;
	fpg_enemigo6;
	fpg_enemigo7;
	fpg_vaca;
	fpg_jefe;
	fpg_cutscenes;
	fpg_lang;
	fpg_texto;
	fpg_texto_azul;
	fpg_texto_rojo;
	fpg_texto_gris;
	fpg_tiempo;
	fpg_puntos[4];
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
	renacimiento;
	mata_enemigos;
	ganando;
	ganando_moto;
	
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
		//tema de ataques: 
			//-2: 		ataque que golpea a todos, no defendible; 
			//-1: 		ataque que golpe a todos, defendible
			// 0:  		ataque generico protas a enemigos
			// 1-9: 	ataque protas a enemigos
			//10-99: 	enemigos general
			//100: 		jefe
	
	y_inc;
	x_inc;
	z_juego;
	angle_inc;
	y_base;
	i; j;
	tipo;
	atacante;
	combo;
End

include "../../common-src/controles.pr-";
include "../../common-src/savepath.pr-";
include "../../common-src/lenguaje.pr-";
include "../../common-src/mod_text2.pr-";
include "jefe1.pr-";
include "jefe2.pr-";
include "jefe3.pr-";
include "jefe4.pr-";
include "jefe5.pr-";
include "niveles.pr-";
include "menu.pr-";
include "cutscenes.pr-";
include "personaje.pr-";
include "enemigo.pr-";
include "traducciones.pr-";
include "en_moto.pr-";

Begin
	if(argc>0) if(argv[1]=="arcade") arcade_mode=1; end end
	sound_freq=44100;
	sound_mode=mode_stereo;

	rand_seed(time());
	
	savepath();
	
	if(os_id==1003)
		savegamedir="/data/data/com.pixjuegos.ripolles/files/";
		mkdir(savegamedir);
	end
	
	carga_opciones();
	#IFDEF DEBUG	
		ops.musica=0;
		ops.sonido=1;
		ops.ventana=1;
		full_screen=0;
		//scale_resolution=09600540;
	#ENDIF

	//temporal
	ops.lenguaje=-1;
	
	if(ops.lenguaje==-1)
		switch(lenguaje_sistema())
			case "es": ops.lenguaje=1; end
			case "ca": ops.lenguaje=2; end
			default: ops.lenguaje=0; end
		end	
	end

	//if(os_id==1003) ops.lenguaje=0; end
	
	switch(ops.lenguaje)
		case 1: lang_suffix="es"; end
		case 2: lang_suffix="ca"; end
		default: lang_suffix="en"; end
	end
	
	carga_textos();

	//La resoluci??n del monitor ser?? esta:
	if(os_id==os_caanoo or os_id==10 or os_id==os_gp2x or os_id==os_gp2x_wiz or os_id==os_gp32 or os_id==os_dc)
		panoramico=0;
		//scale_resolution=03200240;
		ancho_pantalla=480;
		alto_pantalla=360;
		bpp=16;
	elseif(os_id==os_wii)
		scale_resolution=06400480;
		bpp=16;	
	elseif(os_id==1003 or os_id==1002) //m??viles
/*		
	el escalado lo hace bennugd autom??ticamente, esto ya no es necesario
	#IFNDEF OUYA
		if(graphic_info(0,0,g_width)==1024 and graphic_info(0,0,g_height)==552)
			ancho_pantalla=665; //archos gamepad
			alto_pantalla=360;
		else
			scale_resolution=graphic_info(0,0,g_width)*10000+graphic_info(0,0,g_height);
		end
		#ENDIF*/
		//bpp=16;	
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
		//windows?
	end
	
	if(ops.ventana==0)
		full_screen=true;
	else
		full_screen=false;
	end
	
	if(arcade_mode)
		scale_resolution=08000600;
		full_screen=true;
	end

	//Pero internamente trabajaremos con esto:
	#IFDEF DEBUG
	full_screen=True;
	#ENDIF
	set_mode(ancho_pantalla*abs(global_resolution),alto_pantalla*abs(global_resolution),bpp);
	resolution=global_resolution;
	
	//gr??fico para mientras se carga
	graph=load_png("loading.png");
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	
	if(!panoramico) size=75; end
	z=-520;
	
	#IFNDEF DEBUG
	from alpha=0 to 255 step 20; frame; end
	#ENDIF
	timer[0]=0;

	//configuramos controladores
	configurar_controles();
	controlador(0);
	
	//cargamos recursos
	carga_fpgs();
	carga_wavs();

	//configuramos los espacios de las fuentes
	ops_fuentes[fpg_texto].margen=-4*abs(global_resolution);
	ops_fuentes[fpg_texto].espacio=30*abs(global_resolution);
	ops_fuentes[fpg_texto_azul].margen=-4*abs(global_resolution);
	ops_fuentes[fpg_texto_azul].espacio=30*abs(global_resolution);
	ops_fuentes[fpg_texto_rojo].margen=-4*abs(global_resolution);
	ops_fuentes[fpg_texto_rojo].espacio=30*abs(global_resolution);
	ops_fuentes[fpg_texto_gris].margen=-4*abs(global_resolution);
	ops_fuentes[fpg_texto_gris].espacio=30*abs(global_resolution);

	//recolocamos el centro de los objetos
	recoloca_centros();
	
	//A 30 im??genes por segundo
	set_fps(game_fps,0);

	//disclaimer tocapelotas
	#IFNDEF OUYA
	if(ops.disclaimer==0)
		graph=load_png("loading2.png");
		x=ancho_pantalla/2;
		y=alto_pantalla/2;
		from i=0 to 400; frame; end
		ops.disclaimer=1;
		guarda_opciones();
	end
	#ENDIF
	
	#IFNDEF DEBUG
	loop
		if(timer[0]>500 or key(_esc) or key(_enter) or p[0].botones[b_1] or p[0].botones[b_2] or p[0].botones[b_3]) break; end
		frame; 
	end
	from alpha=255 to 0 step -20; frame; end
	
	fade_off();
	while(fading) frame; end
	#ENDIF
	
	#IFDEF TACTIL
	if(file_exists(savegamedir+"turbo.dat"))
		carga_partida_rapida();
		return;
	end
	#ENDIF
	
	if(atoi(ftime("%d",time()))==14 and atoi(ftime("%m",time()))==2)
		ops.truco_pato=1;
	end
	
	//test
	#IFDEF DEBUG
	modo_matajefes=10;
	modo_juego=modo_historia;
	p[1].juega=1;
	p[1].vidas=5;
	p[2].juega=0;
	p[2].vidas=5;

	nivel=3;
	cutscene_principio();
	//jugar();
	return;
	#ENDIF
	
	//iniciamos el men??
	menu(-1);

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
	fpg_ripolles1bici=load_fpg("fpg/ripolles1bici.fpg");
	fpg_pato=load_fpg("fpg/pato.fpg");
	fpg_pato1bici=load_fpg("fpg/pato1bici.fpg");
	fpg_puntos[1]=load_fpg("fpg/puntos1.fpg");
	if(posibles_jugadores>1) //ahorro de recursos!
		fpg_ripolles2=load_fpg("fpg/ripolles2.fpg");
		fpg_ripolles3=load_fpg("fpg/ripolles3.fpg");
		fpg_ripolles4=load_fpg("fpg/ripolles4.fpg");
		fpg_ripolles2bici=load_fpg("fpg/ripolles2bici.fpg");
		fpg_ripolles3bici=load_fpg("fpg/ripolles3bici.fpg");
		fpg_ripolles4bici=load_fpg("fpg/ripolles4bici.fpg");

		fpg_pato2=load_fpg("fpg/pato2.fpg");
		fpg_pato3=load_fpg("fpg/pato3.fpg");
		fpg_pato4=load_fpg("fpg/pato4.fpg");
		fpg_pato2bici=load_fpg("fpg/pato2bici.fpg");
		fpg_pato3bici=load_fpg("fpg/pato3bici.fpg");
		fpg_pato4bici=load_fpg("fpg/pato4bici.fpg");

		fpg_puntos[2]=load_fpg("fpg/puntos2.fpg");
		fpg_puntos[3]=load_fpg("fpg/puntos3.fpg");
		fpg_puntos[4]=load_fpg("fpg/puntos4.fpg");
	end
	fpg_enemigo1=load_fpg("fpg/enemigo1.fpg");
	fpg_enemigo2=load_fpg("fpg/enemigo2.fpg");
	fpg_enemigo3=load_fpg("fpg/enemigo3.fpg");
	fpg_enemigo4=load_fpg("fpg/enemigo4.fpg");
	fpg_enemigo5=load_fpg("fpg/enemigo5.fpg");
	fpg_enemigo6=load_fpg("fpg/enemigo6.fpg");
	fpg_enemigo7=load_fpg("fpg/enemigo7.fpg");
	fpg_vaca=load_fpg("fpg/vaca.fpg");
	
	recoloca_centros_personaje(fpg_ripolles1);
	recoloca_centros_personaje(fpg_ripolles2);
	recoloca_centros_personaje(fpg_ripolles3);
	recoloca_centros_personaje(fpg_ripolles4);
	recoloca_centros_personaje(fpg_ripolles1bici);
	recoloca_centros_personaje(fpg_ripolles2bici);
	recoloca_centros_personaje(fpg_ripolles3bici);
	recoloca_centros_personaje(fpg_ripolles4bici);
	recoloca_centros_personaje(fpg_pato);
	recoloca_centros_personaje(fpg_pato2);
	recoloca_centros_personaje(fpg_pato3);
	recoloca_centros_personaje(fpg_pato4);
	recoloca_centros_personaje(fpg_pato1bici);
	recoloca_centros_personaje(fpg_pato2bici);
	recoloca_centros_personaje(fpg_pato3bici);
	recoloca_centros_personaje(fpg_pato4bici);
	
	recoloca_centros_personaje(fpg_enemigo1);
	recoloca_centros_personaje(fpg_enemigo2);
	recoloca_centros_personaje(fpg_enemigo3);
	recoloca_centros_personaje(fpg_enemigo4);
	recoloca_centros_personaje(fpg_enemigo5);
	recoloca_centros_personaje(fpg_enemigo6);
	recoloca_centros_personaje(fpg_enemigo7);
	recoloca_centros_personaje(fpg_vaca);

	//grayscale_fpg(fpg_enemigo5);
	
	fpg_general=load_fpg("fpg/general.fpg");
	fpg_objetos=load_fpg("fpg/objetos.fpg");
	fpg_menu=load_fpg("fpg/menu.fpg");
	fpg_fondo_menu=load_fpg("fpg/fondo_menu.fpg");
	fpg_texto=load_fpg("fpg/fnt1.fpg");
	fpg_texto_azul=load_fpg("fpg/fnt1azul.fpg");
	fpg_texto_rojo=load_fpg("fpg/fnt1rojo.fpg");
	fpg_texto_gris=load_fpg("fpg/fnt1gris.fpg");
	fpg_tiempo=load_fpg("fpg/tiempo.fpg");
	fpg_lang=load_fpg("fpg/"+lang_suffix+".fpg");
End

Function grayscale_fpg(file)
Private
    int blendTable;
Begin
    blendTable = blendop_new();
    blendop_grayscale(blendTable,2);
	blendop_tint(blendTable,0.7,20,20,20);
	from i=1 to 999;
		if(graphic_info(file,i,G_HEIGHT)>0)
			blendop_apply(file,i,blendTable);
		end
	end
End

Process jugar();
Private
	txt_pausa[2];
Begin
	evento_hamburguesa=0;
	resolution=global_resolution;
	let_me_alone();
	if(pocos_recursos)
		unload_fpg(fpg_menu);
	end
	set_fps(game_fps,0);
	clear_screen();
	delete_text(all_text);
	ganando=0;
	en_emboscada=0;

	averigua_jugadores();
	
	if(partida_cargada==0)
		anterior_emboscada=0;
	end
	
	enemigos=0;
	enemigos_matados=0;
	if(fpg_nivel>0) unload_fpg(fpg_nivel); end
	if(fpg_jefe>0) unload_fpg(fpg_jefe); end
	if(mapa_nivel>0) unload_map(0,mapa_nivel); end

	if(ops.truco_fuego_amigo==1) fuego_amigo=1; else fuego_amigo=0; end
	
	if(fuego_amigo or ops.truco_pato==1 or ops.truco_hamburguesas==1)
		con_puntos=0;
	else
		con_puntos=1;
	end
	
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

	ancho_nivel/=abs(global_resolution);
	alto_nivel/=abs(global_resolution);
	
	if(!en_moto)
		start_scroll(0,fpg_nivel,1,0,0,0);
		id_camara=scroll[0].camera=camara();
	else //nivel especial con scroll c??clico
		camara_en_moto();
	end
	
	if(ops.truco_good_vs_evil==1)
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

	//write_int_size(fpg_texto_azul,0,0,0,&fps,50);
	
	loop
		if(modo_juego!=modo_historia) jukebox(); end
		averigua_jugadores();
		if(jugadores==0 or (modo_juego==modo_battleroyale and jugadores==1) or (ganando==1 and modo_juego==modo_historia))
			break;
		end
		
      	if(p[0].botones[b_salir] and ready)
			while(p[0].botones[b_salir]) frame; end

			/*txt_pausa[1]=write(fpg_texto,ancho_pantalla/2,(alto_pantalla/2)-30,4,textos[0]);
			txt_pausa[2]=write(fpg_texto,ancho_pantalla/2,alto_pantalla/2,4,textos[1]);
		
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
			ready=1;*/
			
			ready=0;
			txt_pausa[1]=write_size(fpg_texto_azul,ancho_pantalla/2,60,4,"PAUSA",160);
			txt_pausa[1].alpha=0;
			menu(-2);
			from i=0 to 255 step 20; txt_pausa[1].alpha=i; frame; end
			while(exists(type menu)) frame; end
			from i=255 to 0 step -20; txt_pausa[1].alpha=i; frame; end
			delete_text(txt_pausa[1]);
			ready=1;
		end

		#IFDEF DEBUG
		if(key(_x))
			while(key(_x)) frame; end
			write_int(fpg_texto,200,200,2,&p[1].identificador.x);
		end
		if(key(_t))
			while(key(_t)) frame; end
			vaca(99);
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
		if(key(_b)) 
			while(key(_b)) frame; end
			if(cajas_colision)
				cajas_colision=0;
			else
				cajas_colision=1;
			end
		end
		#ENDIF
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
			case 5:
				fade_off();
 				while(fading) frame; end
				final_del_juego();
				return;
			end
			default:
				nivel++;
				//nivel=4;
				fade_off();
				while(fading) frame; end
				jugar();
				return;
			end
		end
	end

	x=ancho_pantalla/2;
	y=(alto_pantalla/2)-(13*4);
	z=-256;
	i=0;

	if(modo_juego==modo_supervivencia and ops.truco_hamburguesas<0)
		if(timer[0]>60*3*100) //si ha aguantado m??s de 3 minutos, le damos el cheto hamburguesa
			ops.truco_hamburguesas=0; //modo matajefes disponible
			guarda_opciones();
			truco_descubierto(textos[3]);
			while(exists(type truco_descubierto)) frame; end
		end
	end
	
	if(modo_juego==modo_battleroyale)
		if(ops.truco_fuego_amigo<0)
			ops.truco_fuego_amigo++;
			guarda_opciones();
			if(ops.truco_fuego_amigo==0)
				truco_descubierto(textos[2]);
				while(exists(type truco_descubierto)) frame; end
			end
		end
	
		from i=1 to 9;
			if(p[i].juega)
				truco_descubierto(textos[49]+i+textos[50]);
				while(exists(type truco_descubierto)) frame; end
				break; 
			end
		end
	else
		truco_descubierto(textos[51]);
		while(exists(type truco_descubierto)) frame; end
	end
	fade_off();
	while(fading) frame; end
	delete_text(all_text);
	y=alto_pantalla/2;
	timer[0]=0;
	let_me_alone();
	stop_scroll(0);
	menu(-1);
End

Function recoloca_centros();
Begin
	//todos los objetos deben tener el centro en su base
	x=10*abs(global_resolution);
	from i=1 to 998;
		if(graphic_info(fpg_objetos,i,G_HEIGHT)>0)
			set_center(fpg_objetos,i,graphic_info(fpg_objetos,i,G_WIDTH)/2,graphic_info(fpg_objetos,i,G_HEIGHT)-x);
		end
	end
	
	//bloqueadores centro en base:
	from i=101 to 106;
		set_center(fpg_general,i,graphic_info(fpg_objetos,i,G_WIDTH)/2,graphic_info(fpg_objetos,i,G_HEIGHT)-x);
	end
	
	//las barras de vida deben tener su centro en la izquierda
	set_center(fpg_general,25,0,graphic_info(fpg_general,25,G_HEIGHT)/2);
	set_center(fpg_general,26,0,graphic_info(fpg_general,26,G_HEIGHT)/2);
	set_center(fpg_general,27,0,graphic_info(fpg_general,27,G_HEIGHT)/2);
	
	//enemigos inclusive
	set_center(fpg_general,51,0,0);
	set_center(fpg_general,52,0,0);
End

Function recoloca_centros_personaje(file);
Begin
	//todos los objetos deben tener el centro en su base
	x=57*abs(global_resolution);
	from i=1 to 998;
		if(graphic_info(file,i,G_HEIGHT)>0)
			set_center(file,i,graphic_info(file,i,G_WIDTH)/2,graphic_info(file,i,G_HEIGHT)-x);
		end
	end
End

Process camara();
Private
	suma_x;
	x_inc_max;
Begin
	resolution=global_resolution;
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
				from j=1 to jugadores;
					enemigo(siguiente_enemigo_libre(),emboscada[en_emboscada+1].enemigo[i].tipo,emboscada[en_emboscada+1].enemigo[i].pos_x,emboscada[en_emboscada+1].enemigo[i].pos_y,emboscada[en_emboscada+1].x_evento,emboscada[en_emboscada+1].enemigo[i].flags);
				end
			end
		end
	end
	
	x_inc_max=15;
	y_inc=5;
	//y_base=alto_nivel-alto_pantalla;
	
	if(en_moto)
		scroll[0].camera=0;
		scroll[0].x1=320;
		loop
			scroll[0].x1+=10;
			frame;
		end
		return;
	end
	
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

		x+=((suma_x-x)/7);
		
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
					if(emboscada[en_emboscada].evento_especial=>101 and emboscada[en_emboscada].evento_especial<=105)
							pon_musica(12);
					end
					switch(emboscada[en_emboscada].evento_especial)
						case 101: //1er jefe
							jefe1(emboscada[en_emboscada].x_evento);
						end
						case 102: //2er jefe
							jefe2(emboscada[en_emboscada].x_evento);
						end
						case 103: //3er jefe
							jefe3(emboscada[en_emboscada].x_evento);
						end
						case 104: //4?? jefe
							jefe4(emboscada[en_emboscada].x_evento);
						end
						case 105: //5?? jefe
							jefe5(emboscada[en_emboscada].x_evento);
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
	resolution=global_resolution;
	ctype=coordenadas;
	x=father.x;
	y=father.y;
	size=father.size;
	z=father.z;
	graph=father.graph;
	file=father.file;
	alpha=father.alpha/2;
	angle=father.angle;
	flags=father.flags;
/*	while(alpha>0)
		while(!ready) frame; end
		alpha-=50; 
		frame; 
	end*/
	frame(300);
End

Function inercia_maxima(max_x,max_y);
Private
	max_angle=20;
Begin
	if(nivel==4 and father.altura==0)
		if(father.x>7064 and father.x<8817)
			if(map_get_pixel(fpg_nivel,2,(father.x-7064)*abs(global_resolution),(father.y-180+53)*abs(global_resolution))==color_arena)
				max_x=max_x/3;
				max_y=max_y/3;
			end
		end
	end
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
	if(father.angle_inc>0)
		if(father.angle_inc>max_angle) father.angle_inc=max_angle; end
	elseif(father.angle_inc<0)
		if(father.angle_inc<-max_angle) father.angle_inc=-max_angle; end
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
		if(father.tipo>100)
			father.animacion=herido_leve;
		else
			father.animacion=herido_grave;
		end
	end
End

Function mueveme(forma);
Begin
	father.y_base+=father.y_inc;
	father.y=father.y_base+father.altura;
	father.z=-father.y_base;
	father.z_juego=father.z;

	if(father.y_base<135)
		father.y_base=135; 
		if(father.y_inc<0) father.y_inc=0; end
	elseif(father.y_base>305) 
		father.y_base=305; 
		if(father.y_inc>0) father.y_inc=0; end
	end

	//rebote en bordes
	if(en_moto==0)
		if((father.x<30 and father.x_inc<0) or (father.x>ancho_nivel-30 and father.x_inc>0)) 
			father.x_inc*=-1; 
		end
	end
	
	if(forma==encerrandome)
		if(father.x<id_camara.x-((ancho_pantalla/2)-50))
			if(father.x_inc<0) father.x_inc*=-1; end
			father.x=id_camara.x-((ancho_pantalla/2)-50); 
		end
		if(father.x>id_camara.x+((ancho_pantalla/2)-50)) 
			if(father.x_inc>0) father.x_inc*=-1; end
			father.x=id_camara.x+((ancho_pantalla/2)-50); 
		end
	end

	if(father.angle_inc!=0)
		father.angle+=father.angle_inc*1000;
	end
	
	if(father.altura==0)
		father.x+=father.x_inc;
	else
		father.x+=father.x_inc*1.4;
	end
End

Function friccioname();
Begin
	if(evento_hamburguesa==13) return; end
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
	if(father.angle_inc>0)
		father.angle_inc--;
	elseif(father.angle_inc<0)
		father.angle_inc++;
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
			if(en_moto)
				if(father.angle_inc<0) //sube
					father.graph=21;
				else //baja
					father.graph=22;
				end
			else			
				if(father.gravedad<0) //sube
					father.graph=21;
				else //baja
					father.graph=22;
				end
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
			if(father.tipo==0)
				father.graph=81+((anim/2)%4);
				anim_max=24;
			else
				if(anim<15 or anim>185)
					father.graph=81;
				elseif(anim<30 or anim>170)
					father.graph=82+((anim/2)%4);
				else
					father.graph=86+((anim/2)%2);
				end
				anim_max=999;
			end
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
	end
	if(anim=>anim_max) anim=0; end

	father.animacion_anterior=animacion;
	father.animacion=animacion;
	if(anim<=anim_max)
		father.anim=anim;
	else
		father.anim=0;
	end
	
	if(!esta_en_pantalla_margen(father)) father.graph=0; end
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
Private
	offset_y;
Begin
	priority=-1;
	resolution=global_resolution;
	jugador=father.jugador;
	ctype=coordenadas;

	if(father.tipo>100)
		size_y=250;
		size_x=80;
		offset_y=-40;
	end
	
	file=fpg_general;
	graph=2;
	size=father.size;
	while(exists(father))
		if(father.accion==muere) return; end
		x=father.x;
		y=father.y-20+(size-100)+offset_y;
		y_base=father.y_base;
		z=father.z-1;
		rango=(father.rango*size)/100;
	
		if(!cajas_colision) alpha=0; else alpha=255; end
		
		if(id_col=collision(type obstaculo))
			if(en_rango(z,id_col.z,id_col.rango))
				if(id_col.x>x)
					father.x_inc-=3;
				elseif(id_col.x<x)
					father.x_inc+=3;
				end
				if(id_col.y_base>y_base)
					father.y_inc-=2;
				elseif(id_col.y_base<y_base)
					father.y_inc+=2;
				end
			end
		end

		if(father.accion!=herido_leve and father.accion!=herido_grave and father.accion!=ataca_area and father.accion!=muere and father.accion!=cogido)
			//ataque
			while(id_col=collision_box(type ataque))
				if(id_col.jugador!=jugador and 													//si no es el mismo jugador
				(!(father.tipo==0 and id_col.jugador==0)) and 									//para evitar los golpes que s??lo deben golpear a los enemigos
				(fuego_amigo or 																//si hay fuego amigo, recibimos golpes de todos
				(jugador=>1 and jugador<=9 and (id_col.jugador>9 or id_col.jugador<0)) or		//ataque enemigo a jugador
				(jugador=>10 and id_col.jugador<10))) 											//ataque jugador->enemigo, ataque total
					if(en_rango(z,id_col.z,id_col.rango))
						//if(father.accion==defiende and ((father.flags==0 and x<id_col.x) or (father.flags==1 and x>id_col.x)))
						if(father.accion==defiende and id_col.jugador!=-2)
							//destello();
							if(id_col.x>x)
								father.x_inc=-5;
							else
								father.x_inc=5;
							end
						else
							father.herida=id_col.herida;
							#IFDEF DEBUG
							muestra_golpe(father.herida);
							#ENDIF
							if(id_col.tipo==1) //debemos volar
								if(father.altura==0)
									father.altura=-5;
								end
							end
							id_col.herida=id_col.herida/2;
							if(id_col.jugador>0 and id_col.jugador<4)
								id_col.combo++;
							end
							efecto_golpe(id_col);
							father.atacante=id_col.jugador;
							if(id_col.flags==0)
								father.flags=1;
							else
								father.flags=0;
							end
						end
					end
				end
			end
			
			//collision entre cuerpos
			if(father.accion==defiende and father.altura!=0)
				//si se defiende y est?? en el aire, no choca
			else
				if(id_col=collision(type cuerpo))
					if(en_rango(z,id_col.z,rango))
						if(id_col<id) //manda este
							if(evento_hamburguesa==1 and !collision_box(type explosion))
								//explosi??n
								explosion(father.x,father.y_base,altura,size);
							end

							if(x<id_col.x)
								if(id_col.father.accion!=herido_leve and id_col.father.accion!=herido_grave and id_col.father.accion!=ataca_area and id_col.father.accion!=muere and id_col.father.accion!=cogido)
									id_col.father.x_inc+=3;
									id_col.father.y_inc+=2;
									if(id_col.father.accion==quieto)
										if(!en_moto) id_col.father.flags=1; end
									end
									father.x_inc-=3;
									father.y_inc-=2;
									if(father.accion==quieto)
										if(!en_moto) father.flags=0; end
									end
								end
							else
								if(id_col.father.accion!=herido_leve and id_col.father.accion!=herido_grave and id_col.father.accion!=ataca_area and id_col.father.accion!=muere and id_col.father.accion!=cogido)
									id_col.father.x_inc-=3;
									id_col.father.y_inc-=2;
									if(id_col.father.accion==quieto)
										if(!en_moto) id_col.father.flags=0; end
									end
									father.x_inc+=3;
									father.y_inc+=2;
									if(father.accion==quieto)
										if(!en_moto) father.flags=1; end
									end
								end
							end
						end
					
						if(en_moto and father.altura<0)
							if(id_col.altura==0)
								father.gravedad=-15;
							end
						end
					end
				end
			end
		end
		frame;
	end
End

Process ataque(x,y,file,graph,herida,rango,jugador,tipo);
Begin
	resolution=global_resolution;
	flags=father.flags;
	z=father.z;
	priority=-1;
	ctype=coordenadas;
	if(!cajas_colision) alpha=0; end
	if(jugador>0 and jugador<5)
		if(p[jugador].combo>2)
			herida+=p[jugador].combo*3;
		end
	end
	frame;
	if(combo!=0 and exists(father)) father.combo+=combo; end
End

Process objeto_portado(x,y,graph);
Begin
	resolution=global_resolution;
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

Process objeto(x,y_base,altura,graph,x_inc,flags);
Private
	retraso_colision;
Begin
	if(ops.truco_hamburguesas!=1 and graph==obj_hamburguesa) return; end
	resolution=global_resolution;
	y=y_base+altura+40;
	z=y_base-1;
	file=fpg_objetos;
	x_inc=x_inc*1.5;
	if(exists(father))
		if(father.jugador!=0)
			jugador=father.jugador;
		end
	end
	ctype=coordenadas;
	while(!exists(id_camara)) frame; end
	if(graph==100) x_inc*=1.3; end
	loop
		while(!ready) frame; end
		if(!estoy_en_pantalla_margen() and altura==0 and x_inc==0)
			i=graph;
			graph=0;
			while(!estoy_en_pantalla_margen()) frame; end
			graph=i;
		end
		if(combo!=0)
			p[jugador].combo+=combo;
			combo=0;
		end
		//al poco de lanzarlo dejar?? de estar asociado al jugador y podr?? da??ar al mismo y a los compa??eros
		/*if(jugador>0)
			j++;
			if(j>10) jugador=0; end
		end*/
		
		aplica_gravedad();
		if(altura>0) altura=0; end
		if(altura==0)
			if(x_inc!=0)
				nube_humo(x,y,z,0,0,size);
			end
			friccioname();
			if(en_moto)
				x_inc=(-mov_camara_moto/2)-1;
				if(x<-100) break; end
			end
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
			ataque(x,y,file,graph,abs(x_inc)*3,40,jugador,0);
		end
		
		z--;
		sombra_objeto();
		frame;
	end
End

Function aplica_gravedad();
Begin
	if(father.altura<0)
		if(evento_hamburguesa==7)
			father.gravedad+=1;
		else
			father.gravedad+=2;
		end
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
	priority=-1;
	resolution=global_resolution;
	i=53;
	ctype=coordenadas;
	file=fpg_general;
	graph=3;
	while(exists(father))
		y=father.y_base+i;
		z=200;
		x=father.x;
		alpha=father.alpha+father.altura-50;
		size=100+(father.altura/3);
		frame;
	end
End

Process sombra_definida(file,graph);
Begin
	resolution=global_resolution;
	y=father.y_base+(father.alto/2);
	z=father.z+10;
	x=father.x;
	ctype=coordenadas;
	file=fpg_general;
	alpha=father.alpha+altura-50;
	size=100+(altura/3);
	frame;
	while(!ready and !ganando) frame; end
End

Process sombra_objeto();
Begin
	resolution=global_resolution;
	i=5*abs(global_resolution);
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
	hasta=4;
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

Function objeto_mas_cercano();
Private
	dist_x;
	dist_x_ganador=320;
	id_objeto_temp;
	id_objeto;
Begin
	x=father.x;
	y=father.y;
	while(id_objeto_temp=get_id(type objeto))
		if(esta_en_pantalla(id_objeto_temp))
			dist_x=abs(x-id_objeto_temp.x);
			if(id_objeto_temp.graph==obj_papelera or id_objeto_temp.graph==obj_canya or id_objeto_temp.graph==obj_mesa
			 or id_objeto_temp.graph==obj_silla or id_objeto_temp.graph==obj_naranja_dura)
				if(dist_x<dist_x_ganador)
					id_objeto=id_objeto_temp;
					dist_x_ganador=dist_x;
				end
			end
		end
	end
	return id_objeto;
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

Function estoy_en_pantalla_margen();
Begin
	if(exists(id_camara))
		if(father.x>id_camara.x-(ancho_pantalla/2)-200 and father.x<id_camara.x+(ancho_pantalla/2)+200)
			return 1;
		else
			return 0;
		end
	else
		return 1;
	end
End

Function esta_en_pantalla(id_prueba);
Begin
	if(!exists(id_prueba)) return 0; end
	if(exists(id_camara))
		if(id_prueba.x>id_camara.x-(ancho_pantalla/2) and id_prueba.x<id_camara.x+(ancho_pantalla/2))
			return 1;
		else
			return 0;
		end
	else
		if(x>0 and x<640)
			return 1;
		else
			return 0;
		end
	end
End

Function esta_en_pantalla_margen(id_prueba);
Begin
	if(!exists(id_prueba)) return 0; end
	if(exists(id_camara))
		if(id_prueba.x>id_camara.x-(ancho_pantalla/2)-200 and id_prueba.x<id_camara.x+(ancho_pantalla/2)+200)
			return 1;
		else
			return 0;
		end
	else
		if(x>0 and x<640)
			return 1;
		else
			return 0;
		end
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

Process tram();
Begin
	resolution=global_resolution;
	enemigos++;
	file=fpg_general;
	graph=10;
	x=ancho_pantalla/2;
	y=alto_pantalla/3;
	alto=graphic_info(file,1,G_HEIGHT);
	from alpha=0 to 255 step 40; size+=2; frame; end
	while(!ready) frame; end
	from alpha=255 to 0 step -40; size-=2; frame; end
	while(!ready) frame; end
	from alpha=0 to 255 step 40; size+=2; frame; end
	while(!ready) frame; end
	from alpha=255 to 0 step -40; size-=2; frame; end
	while(!ready) frame; end
	from alpha=0 to 255 step 40; size+=2; frame; end
	while(!ready) frame; end
	from alpha=255 to 0 step -40; size-=2; frame; end

	ctype=coordenadas;
	x=id_camara.x+(ancho_pantalla*1.5);
	y=195;
	z=-y-25;
	graph=11;
	flags=1;
	alpha=255;
	while(x>id_camara.x-ancho_pantalla)
		while(!ready) frame; end
		x-=20;
		ataque(x,y+75,file,graph,30,38,-2,1);
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

Process avioncete();
Begin
	resolution=global_resolution;
	enemigos++;
	file=fpg_general;
	advertencia();
	ctype=coordenadas;
	x=id_camara.x+ancho_pantalla;
	y=160+(rand(0,1)*90);
	y_base=y;
	z=-y;
	altura=0;
	graph=13;
	flags=1;
	alpha=255;
	sombra();
	son.file=fpg_general;
	son.graph=16;
	son.flags=1;
	while(x>id_camara.x-ancho_pantalla)
		while(!ready) frame; end
		x-=20;
		altura--;
		ataque(x,y+65,file,graph,30,38,-2,1);
		if(x<id_camara.x+50)
			graph=14;
			altura-=6;
		end
		y=y_base+altura;
		frame;
	end
	enemigos--;
End

Function salir();
Begin
	guarda_opciones();
	full_screen=0;
	//set_mode(320,240,32);
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
		if(i!=anterior_cancion or !is_playing_song())
			//if(is_playing_song()) fade_music_off(400); end
			stop_song();
			if(id_cancion>0) 
				unload_song(id_cancion); 
				id_cancion=0; 
			end
			//timer[1]=0;
			//while(timer[1]<40) frame; end
			anterior_cancion=i;
			id_cancion=load_song("ogg/"+i+"."+formato);
			if(exists(type menu))
				play_song(id_cancion,0);
			else
				play_song(id_cancion,-1);
			end
		end
	else
		anterior_cancion=0;
	end
End

Function sonido(i,veces);
Private
	id_sonido;
Begin
	if(ops.sonido)
		id_sonido=play_wav(wavs[i],veces);
		if(!exists(type menu))
			if(coordenadas==c_scroll and exists(id_camara))
				j=(((father.x-(id_camara.x-(ancho_pantalla/2)))*255))/ancho_pantalla;
			else
				j=(father.x*255)/ancho_pantalla;
			end
			set_panning(id_sonido,255-j,j);
		end
		return id_sonido;
	end
	return 0;
End

Process marcador(jugador);
Private
	txt_vidas;
	txt_puntos;
	puntos;
	vida_anterior;
	id_vida;
Begin
	resolution=global_resolution;
	file=fpg_general;
	if(ops.truco_pato==1 and jugador==1)
		graph=28;
	else
		graph=20+jugador;
	end
	
	x=20+90+((jugador-1)*150);
	y=40;
	z=-509;
	size=80;
	txt_vidas=write_int_size(fpg_texto,x-50,y,4,&p[jugador].vidas,80);
	if(con_puntos) txt_puntos=write_int(fpg_puntos[jugador],x-30,y-25,0,&puntos); end
	id_vida=vida(x-23,y+1,p[jugador].vida-1,25);
	id_vida.size_y=80;
	while(p[jugador].juega)
		if(!exists(p[jugador].identificador)) break; end
		if(con_puntos)
			if(puntos!=p[jugador].puntos)
				puntos+=((p[jugador].puntos-puntos)/10)+2;
				txt_puntos.rand_y=4;
				if(puntos=>p[jugador].puntos)
					puntos=p[jugador].puntos;
					txt_puntos.rand_y=0;
				end
			end
		end
		if(vida_anterior!=p[jugador].vida-1)
			vida_anterior=p[jugador].vida-1;
			if(exists(id_vida))
				id_vida.size_x=(p[jugador].vida-1)*0.8;
			end
		end
		frame;
	end
	delete_text(txt_vidas);
	delete_text(txt_puntos);
	from alpha=255 to 0 step -25; y-=2; frame; end
End

Process marcador_jefe();
Private
	max_vida;
	id_vida;
Begin
	resolution=global_resolution;
	max_vida=p[100].vida;
	file=fpg_general;
	graph=26;
	x=160;
	y=320;
	z=-510;
	id_vida=vida(x,y,i,27);
	size_y=80;
	while(p[100].vida>0)
		i=(p[100].vida*100)/max_vida;
		if(i!=j)
			j=i;
			if(exists(id_vida)) id_vida.size_x=i; end
		end
		frame;
	end
	from alpha=255 to 0 step -25; y-=2; frame; end
End

Process vida(x,y,size_x,graph);
Begin
	resolution=global_resolution;
	file=fpg_general;
	z=-511;
	size_y=80;
	while(accion!=muere and exists(father))
		frame;
	end
End

Process efecto_golpe(id_col);
Begin
	resolution=global_resolution;
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
	resolution=global_resolution;
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
	resolution=global_resolution;
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
					if(rand(0,1)) x=-100; else x=ancho_pantalla+100; end
					y=rand(100,300);
					if(rand(0,300)==0) //evil ripolles
						enemigo(i,5,x,y,0,0);
					elseif(rand(0,50)==0) //new enemies 6-7
						enemigo(i,rand(6,7),x,y,0,0);
					else //comunes 1-4
						enemigo(i,rand(1,4),x,y,0,0);
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
	string string_tiempo;
	tiempo;
	tiempo_antes;
Begin
	resolution=global_resolution;
	x=320;
	y=300;
	z=-512;
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
		graph=write_in_map_fixed(fpg_tiempo,string_tiempo,4,20*abs(global_resolution));
		frame;
		if(jugadores>0)
			if(ganando)
				tiempo_antes=timer[0];
				while(ganando) frame; end
				timer[0]=tiempo_antes;
			end

			unload_map(0,graph);
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

Function reinicio_variables(); //siempre lo buscas como S REINICIA_VARIABLES :D
Begin
	clear_screen();
	stop_scroll(0);
	enemigos_matados=0;
	id_camara=0;
	en_emboscada=0;
	en_moto=0;
	nivel=1;
	anterior_emboscada=0;
	fuego_amigo=0;
	ganando=0;
	evento_hamburguesa=0;
	enemigos=0;
	con_puntos=1;
	
	from i=1 to 10;
		p[i].vidas=9;
	end
	from i=0 to 100;
		p[i].juega=0;
		p[i].vida=0;
		p[i].identificador=0;
		p[i].velocidad_extra=0;
		p[i].fuerza_extra=0;
		p[i].puntos=0;
		p[i].combo=0;
		p[i].bonus=0;
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

Process matajefes();
Private
	id_jefe;
Begin
	resolution=global_resolution;
	fpg_nivel=load_fpg("nivel_matajefes1.fpg");
	timer[0]=0;
	pon_tiempo();
	from i=1 to jugadores; p[i].vidas=1; end
	pon_musica(12);
	
	while(timer[0]<300) frame; end
	id_jefe=jefe1(ancho_pantalla/2);
	while(!ganando) frame; end
	from alpha=255 to 0 step -15; id_jefe.alpha=alpha; frame; end
	signal(id_jefe,s_kill_tree);
	ganando=0;
	timer[2]=0;
	while(timer[2]<300) frame; end

	id_jefe=jefe2(id_camara.x);
	while(!ganando) frame; end
	//from alpha=255 to 0 step -15; id_jefe.alpha=alpha; frame; end
	from alpha=255 to 0 step -15; p[100].identificador.alpha=alpha; frame; end
	signal(p[100].identificador,s_kill_tree);
	ganando=0;
	timer[2]=0;
	while(timer[2]<300) frame; end
	
	
	id_jefe=jefe3(ancho_pantalla/2);
	while(!ganando) frame; end
	from alpha=255 to 0 step -15; id_jefe.alpha=alpha; frame; end
	signal(id_jefe,s_kill_tree);
	ganando=0;
	timer[2]=0;
	while(timer[2]<300) frame; end

	id_jefe=jefe4(id_camara.x);
	while(!ganando) frame; end
	//from alpha=255 to 0 step -15; id_jefe.alpha=alpha; frame; end
	from alpha=255 to 0 step -15; p[100].identificador.alpha=alpha; frame; end
	signal(p[100].identificador,s_kill_tree);
	ganando=0;
	timer[2]=0;
	while(timer[2]<300) frame; end
	
	id_jefe=jefe5(id_camara.x);
	while(!ganando) frame; end
	from alpha=255 to 0 step -15; id_jefe.alpha=alpha; frame; end
	timer[2]=0;
	while(timer[2]<300) frame; end
	
	//EVIL RIPO
	ganando=0;
	enemigos=0;
	enemigo(11,5,-100,150,0,1);
	if(jugadores>1) enemigo(12,5,ancho_pantalla+100,350,0,1); end
	if(jugadores>2) enemigo(13,5,-100,150,0,1); end
	if(jugadores>3) enemigo(14,5,ancho_pantalla+100,350,0,1); end
	
	while(enemigos>0) frame; end
	
	truco_descubierto(textos[5]);
	ganando=1;
	timer[2]=0;
	while(timer[2]<500) frame; end
	
	if(ops.truco_pato<0)
		ops.truco_pato=0; //modo matajefes disponible
		guarda_opciones();
		truco_descubierto(textos[6]);
		while(exists(type truco_descubierto)) frame; end
	end
	menu(-1);
End

Process battleroyale();
Begin
	resolution=global_resolution;
	fpg_nivel=load_fpg("nivel_battleroyale1.fpg");
	from i=1 to jugadores; p[i].vidas=2; end
	fuego_amigo=1;
End

Process muestra_nivel();
Begin
	resolution=global_resolution;
	graph=write_in_map(fpg_texto,textos[7]+nivel,4);
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
	resolution=global_resolution;
	switch(nivel)
		case 1: graph=write_in_map(fpg_texto,textos[8],4); end
		case 4: graph=write_in_map(fpg_texto,textos[11],4); end
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
	resolution=global_resolution;
	ready=0;
	graph=write_in_map(fpg_texto,textos[7]+nivel+textos[13],4);
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
	resolution=global_resolution;
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
	resolution=global_resolution;
	graph=write_in_map(fpg_texto,texto,4);
	x=ancho_pantalla/2;
	y=(alto_pantalla/2)-34;
	z=-512;
	size=80;
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
					case 2: pon_musica(2); end
					case 3: pon_musica(3); end
					case 4: pon_musica(4); end
					case 5: pon_musica(5); end
					case 6: pon_musica(12); end
					case 7: pon_musica(13); end
					case 8: pon_musica(15); end
					case 9: pon_musica(14); jukeboxing=0; end
				end
			end
		end
	end
End

Process mensaje_player(string mitexto);
Private
	offset_y;
	espera=60;
Begin
	resolution=global_resolution;
	ctype=coordenadas;
	graph=write_in_map(fpg_texto,mitexto,4);
	size=40;
	alpha=0;
	offset_y=-40;
	z=-512;
	while(exists(father))
		if(alpha<255)
			alpha+=14;
			offset_y--; 
		else
			if(espera>0)
				espera--;
			else
				break;
			end
		end
		y=father.y+offset_y;
		x=father.x;
		frame;
	end
	from alpha=255 to 0 step -15; y-=3; frame; end
End

Function pinta_ayuda(pagina);
Private
	num_paginas_total;
Begin
	graph=new_map(ancho_pantalla*abs(global_resolution),alto_pantalla*abs(global_resolution),graphic_info(fpg_texto,48,G_DEPTH));
	num_paginas_total=3;

	//TEMPORAL
	if(pagina<10)
		pon_texto_ayuda(fpg_texto,textos[35],320,20,100,30,1); //t??tulo ayuda
		pon_texto_ayuda(fpg_texto,pagina+"/"+num_paginas_total,600,350,70,30,4); //num pagina
	end
	
	switch(pagina)
		case 1: //ayuda 1
			pon_texto_ayuda(fpg_texto_gris,textos[36],50,60,85,30,0); //sub-t??tulo controles
			pon_texto_ayuda(fpg_texto_azul,textos[37],20,90,70,22,0); //texto en azul
			pon_texto_ayuda(fpg_texto,textos[38],120,90,70,22,0); //texto en blanco
			//pon_texto_ayuda(fpg_texto_gris,textos[39],50,255,85,30,0); //sub-t??tulo objetos			
		end
		case 2: //ayuda 2
			pon_texto_ayuda(fpg_texto_gris,textos[40],50,60,85,30,0); //sub-t??tulo multijugador
			pon_texto_ayuda(fpg_texto,textos[41],20,90,70,22,0); //texto en blanco
		end
		case 3: //ayuda 3
			pon_texto_ayuda(fpg_texto_gris,textos[42],50,60,85,30,0); //sub-t??tulo modos de juego
			pon_texto_ayuda(fpg_texto_azul,textos[43],20,90,70,22,0); //texto en azul
			pon_texto_ayuda(fpg_texto,textos[44],20,90,70,22,0); //texto en blanco
		end
		case 10: //creditos
			pon_texto_ayuda(fpg_texto,textos[18],450,10,100,30,1); //t??tulo cr??ditos
			pon_texto_ayuda(fpg_texto_azul,textos[45],60,40,80,25,0); //texto azul
			pon_texto_ayuda(fpg_texto,textos[48],320,80,80,25,4); //nombres
			pon_texto_ayuda(fpg_texto_gris,textos[47],340,320,100,30,4); //gracias por jugar
		end
	end
	return graph;
End

Function pon_texto_ayuda(file_fnt,string mi_cadena,int x,y,size,salto_espacio,centrado);
Private
	string actual;
	char caracter;
Begin
	x*=abs(global_resolution);
	y*=abs(global_resolution);
	salto_espacio*=abs(global_resolution);
	loop
		actual="";
		from i=j to len(mi_cadena)-1;
			if(mi_cadena[i]=="|")
				j=i+1;
				break;
			else
				actual+=""+mi_cadena[i];
			end
		end
		graph=write_in_map(file_fnt,actual,centrado);
		map_xputnp(0,father.graph,0,graph,x,y,0,size,size,0);
		unload_map(0,graph);
		y+=salto_espacio;
		if(i=>len(mi_cadena)-1) break; end
	end
End

Process funde_grafico_in(file,graph);
Begin
	resolution=global_resolution;
	x=father.x;
	y=father.y;
	ctype=coordenadas;
	angle=father.angle;
	size=father.size;
	z=father.z-10;
	flags=father.flags;
	from alpha=0 to 255 step 5; frame; end
	if(exists(father)) father.graph=graph; end
End

Process efecto_hamburguesa();
Private
	mi_evento_hamburguesa;
Begin
	resolution=global_resolution;
	evento_hamburguesa=rand(1,13);
	if(ops.truco_fuego_amigo==1 and evento_hamburguesa==10) evento_hamburguesa=1; end
	mi_evento_hamburguesa=evento_hamburguesa;
	x=ancho_pantalla/2;
	y=100;
	z=-512;
	mensaje_hamburguesa(textos[70+evento_hamburguesa]);
	switch(evento_hamburguesa)
		case 1: //enemigos explosivos
			i=30*30; //30 segundos
		end
		case 2: //toque de la muerte
			from i=1 to 100;
				if(p[i].vida>0) p[i].vida=1; end
			end
			i=0;
		end
		case 3: //everybody dies
			from i=1 to 100;
				if(p[i].vida>0) p[i].vida=0; end
			end
			i=0;
		end
		case 4: //tram
			tram();
		end
		case 5: //avion
			avioncete();
		end
		case 6: //cambio de bandos
			from i=1 to 100;
				if(p[i].vida>0 and exists(p[i].identificador))
					if(i>0 and i<5 and p[i].juega)
						p[i].identificador.tipo=rand(1,7);
					end
					if(i>9 and i<99)
						p[i].identificador.tipo=0;
					end
				end
			end
			i=0;
		end
		case 7: //gravedad lunar
			i=30*30;
		end
		case 8: //lluvia de naranjas
			from i=1 to 20;
				objeto(rand(id_camara.x-(ancho_pantalla/2),id_camara.x+(ancho_pantalla/2)),rand(135,305),rand(-200,-300),obj_naranja,0,0);
				frame(rand(400,1200));
			end
			i=0;
		end
		case 9: //objeto disparado fucking random
			if(rand(0,1))
				objeto(id_camara.x-ancho_pantalla,rand(135,305),rand(-20,-50),rand(1,6),100,0);
			else
				objeto(id_camara.x+ancho_pantalla,rand(135,305),rand(-20,-50),rand(1,6),-100,1);
			end
		end
		case 10: //activar fuego amigo
			fuego_amigo=1;
			i=30*30; //30 segundos
		end
		case 11: //todos con objetos
			from i=1 to 100;
				if(p[i].vida>0 and exists(p[i].identificador)) p[i].identificador.lleva_objeto=rand(2,3); end
			end
			i=0;
		end
		case 12: //everyone is super
			frame(500);
		end
		case 13: //sin fricci??n
			i=30*30;
		end
	end
	if(i>0)
		while(i>0 and evento_hamburguesa==mi_evento_hamburguesa)
			i--;
			graph=write_in_map_fixed(fpg_tiempo,i/30,4,20*abs(global_resolution));
			frame;
			while(!ready) frame; end
			unload_map(0,graph);
			graph=0;
		end
	end
	if(evento_hamburguesa==10) //
		fuego_amigo=0;
	end
	evento_hamburguesa=0;
End

Process mensaje_hamburguesa(string mitexto);
Begin
	resolution=global_resolution;
	graph=write_in_map(fpg_texto_azul,mitexto,4);
	size=70;
	alpha=0;
	x=ancho_pantalla/2;
	z=-512;
	from y=50 to 80; alpha+=20; frame; end
	frame(5000);
	from y=80 to 110; alpha-=20; frame; end
End

Process nube_humo(x,y,z,x_inc,y_inc,size);
Begin
	resolution=global_resolution;
	ctype=coordenadas;
	file=fpg_general;
	graph=17;
	z-=2;
	x_inc+=rand(-abs(x_inc)/3,abs(x_inc)/3);
	y_inc+=rand(-2,2);
	size_x=size;
	size_y=size;
	while(alpha>0)
		x+=x_inc;
		y+=y_inc;
		alpha-=20;
		size_y++;
		size_x--;
		frame;
	end
End

Function advertencia();
Begin
	resolution=global_resolution;
	file=fpg_general;
	graph=10;
	x=ancho_pantalla/2;
	y=alto_pantalla/3;
	from alpha=0 to 255 step 40; size+=2; frame; end
	while(!ready) frame; end
	from alpha=255 to 0 step -40; size-=2; frame; end
	while(!ready) frame; end
	from alpha=0 to 255 step 40; size+=2; frame; end
	while(!ready) frame; end
	from alpha=255 to 0 step -40; size-=2; frame; end
	while(!ready) frame; end
	from alpha=0 to 255 step 40; size+=2; frame; end
	while(!ready) frame; end
	from alpha=255 to 0 step -40; size-=2; frame; end
End

Process explosion(x,y_base,altura,size);
Begin
	resolution=global_resolution;
	file=fpg_general;
	ctype=coordenadas;
	y=y_base+altura;
	z=-y_base;
	sonido(15,0);
	from graph=61 to 75;
		ataque(x,y,file,graph,30,30,-1,1);
		frame;
	end
End

Process estatua_caida1(x);
Begin
	resolution=global_resolution;
	ctype=coordenadas;
	file=fpg_nivel;
	y=200;
	z=-y;
	graph=101;
	estatua_caida2();
	loop
		if(!estoy_en_pantalla_margen())
			i=graph;
			graph=0;
			while(!estoy_en_pantalla_margen()) frame; end
			graph=i;
		end
		frame;
	end
End

Process estatua_caida2();
Begin
	resolution=global_resolution;
	ctype=coordenadas;
	file=fpg_nivel;
	x=father.x+20;
	y=60;
	z=father.z+1;
	graph=102;
	set_center(fpg_nivel,102,(graphic_info(fpg_nivel,102,G_WIDTH)/4),graphic_info(fpg_nivel,102,G_HEIGHT)/2);
	sombra_estatua1();
	loop
		if(!estoy_en_pantalla_margen())
			i=graph;
			graph=0;
			while(!estoy_en_pantalla_margen()) frame; end
			graph=i;
		end
		if(id_col=collision(type ataque))
			if(en_rango(z,id_col.z,30))
				break;
			end
		end
		frame;
	end
	explosion(x,y,altura,size);
	x_inc=100;
	while(angle>-95000)
		angle-=gravedad*500;
		gravedad++;
		x_inc--;
		y+=gravedad/2;
		x+=x_inc/20;
		frame;
	end
	in_memoriam();
	loop
		if(!estoy_en_pantalla_margen())
			i=graph;
			graph=0;
			while(!estoy_en_pantalla_margen()) frame; end
			graph=i;
		end
		frame;
	end
End

Process sombra_estatua1();
Begin
	resolution=global_resolution;
	ctype=coordenadas;
	file=fpg_nivel;
	x=father.father.x+58;
	y=230;
	z=200;

	graph=103;
	while(father.angle==0)
		if(!estoy_en_pantalla_margen())
			i=graph;
			graph=0;
			while(!estoy_en_pantalla_margen()) frame; end
			graph=i;
		end
		frame;
	end
	sombra_estatua2();
	from alpha=255 to 0 step -10; frame; end
End

Process sombra_estatua2();
Begin
	resolution=global_resolution;
	ctype=coordenadas;
	file=fpg_nivel;
	graph=104;
	x=father.x+15;
	z=father.z+1;
	y=250;
	from alpha=0 to 255 step 10; frame; end
	loop
		if(!estoy_en_pantalla_margen())
			i=graph;
			graph=0;
			while(!estoy_en_pantalla_margen()) frame; end
			graph=i;
		end
		frame; 
	end
End


Process in_memoriam();
Begin
	resolution=global_resolution;
	ctype=coordenadas;
	x=father.father.x;
	y=father.father.y+100;
	graph=write_in_map(fpg_texto_azul,"IN MEMORIAM",4);
	from alpha=0 to 255 step 10; frame; end
	frame (10000);
	from alpha=255 to 0 step -10; frame; end
	unload_map(0,graph);
End

Function siguiente_enemigo_libre();
Begin
	from i=11 to 99;
		if(!exists(p[i].identificador))
			return i;
		end
	end
	exit("Error: Se ha excedido el n??mero m??ximo de enemigos");
End

Function pon_emboscada(x_trigger,x_inicio,x_fin);
Begin
	father.i++;
	father.j=0;
	emboscada[father.i].x_evento=x_trigger;
	emboscada[father.i].min_x=x_inicio;
	emboscada[father.i].max_x=x_fin;
End

Function pon_enemigo(x,y,tipo,flags);
Begin
	father.j++;
	emboscada[father.i].enemigo[father.j].tipo=tipo;
	emboscada[father.i].enemigo[father.j].pos_x=x;
	emboscada[father.i].enemigo[father.j].pos_y=y;
	emboscada[father.i].enemigo[father.j].flags=flags;
End

Function pon_evento_especial(x_trigger,x_inicio,x_fin,tipo);
Begin
	father.i++;
	father.j=0;
	emboscada[father.i].x_evento=x_trigger;
	emboscada[father.i].max_x=x_inicio;
	emboscada[father.i].min_x=x_fin;
	emboscada[father.i].evento_especial=tipo;
End

Process obstaculo(x,y_base,rango,file,graph);
Begin
	resolution=global_resolution;
	ctype=coordenadas;
	j=57*abs(global_resolution);
	set_center(file,graph,graphic_info(file,graph,G_WIDTH)/2,graphic_info(file,graph,G_HEIGHT)-j);
	mueveme(sin_encerrarme);
	loop
		if(!estoy_en_pantalla_margen())
			i=graph;
			graph=0;
			while(!estoy_en_pantalla_margen()) frame; end
			graph=i;
		end
		frame;
	end
End

Function jugador_aleatorio();
Begin
	while(j<5)
		i=rand(1,posibles_jugadores);
		if(p[i].identificador!=0 and exists(p[i].identificador))
			return i;
		end
		j++;
		frame;
	end
End

Process suma_puntos(jugador,puntos);
Private
	x_objetivo;
	y_objetivo;
	retraso;
Begin
	if(!con_puntos) return; end
	resolution=global_resolution;
	ctype=coordenadas;
	x=father.x;
	y=father.y;
	z=-512;

	if(jugador==0)
		from i=1 to 4;
			if(p[i].juega and p[i].vida>0 and exists(p[i].identificador))
				suma_puntos(i,puntos);
			end
		end
	elseif(jugador>0 and jugador<5)
		graph=write_in_map(fpg_puntos[jugador],puntos,4);
		alpha=50;
		if(puntos>9999) 
			retraso=60;
			size_y=200;
			size_x=190;
		else 
			retraso=20;
		end
		from i=1 to retraso; 
			y-=2;
			if(exists(father))
				x=father.x;
			end
			alpha+=10; 
			frame;
		end
		if(coordenadas==c_scroll)
			x-=id_camara.x-(ancho_pantalla/2);
			ctype=c_screen;
		end
		x_objetivo=90+((jugador-1)*150);
		y_objetivo=30;

		while(alpha>0)
			x+=((x_objetivo-x)/6);
			y+=((y_objetivo-y)/6);
			size-=4;
			if(y<50)
				alpha-=20;
			end
			frame;
		end	
		if(puntos>0)
			p[jugador].puntos+=puntos;
			puntos=0;
		end
	end
	if(graph>0) unload_map(0,graph); end
End

Process combo_player();
Begin
	priority=-1;
	resolution=global_resolution;
	ctype=coordenadas;
	jugador=father.jugador;
	z=-512;
	size=40;
	combo=2;
	while(exists(father) and accion!=muere)
		if(combo!=p[jugador].combo)
			combo=p[jugador].combo;
			if(graph>0) unload_map(0,graph); end
			if(combo>9)
				graph=write_in_map(fpg_texto,"XX",4);
			elseif(combo=>6)
				graph=write_in_map(fpg_texto_rojo,combo+"X",4);
			else
				graph=write_in_map(fpg_texto_azul,combo+"X",4);
			end
			size=(combo*7)+40;
		end
		x=father.x+rand(-combo/2,combo/2);
		y=father.y+20+rand(-combo/2,combo/2);
		frame;
	end
	from alpha=255 to 0 step -10; frame; end
End

Process muestra_golpe(herida);
Begin
	resolution=global_resolution;
	ctype=coordenadas;
	x=father.x;
	y=father.y;
	z=-512;
	graph=write_in_map(fpg_puntos[1],herida,4);
	frame(2000);
	from alpha=255 to 0 step -10; frame; end
	unload_map(0,graph);
End

Process faro();
Begin
	resolution=global_resolution;
	file=fpg_nivel;
	graph=11;
	flags=16;
	x=3124;
	y=34;
	z=200;
	ctype=coordenadas;
	loop
		if(!estoy_en_pantalla_margen())
			j=graph;
			graph=0;
			while(!estoy_en_pantalla_margen()) frame; end
			graph=j;
		end
		i++;
		if(i==300)
			i=0;
		else
			if(i<90 or (i>120 and i<210) or (i>240 and i<270))
				if(alpha<255) alpha+=40; end
			else
				if(alpha>0) alpha-=40; end
			end
		end
		frame;
	end
End