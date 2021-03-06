//-----------------------------------------------------------------------
// TITULO: Garnatron
// AUTOR:  Carles Vicent
// FECHA:  19/02/05
//-----------------------------------------------------------------------

PROGRAM Garnatron;
import "mod_blendop";
//import "mod_cd";
#IFDEF debug
import "mod_debug";
#ENDIF
//import "mod_mem";
import "mod_effects";
//import "mod_flic";
//import "mod_m7";
import "mod_path";
import "mod_grproc";
import "mod_dir";
import "mod_draw";
import "mod_file";
import "mod_joy";
import "mod_key";
import "mod_map";
import "mod_math";
import "mod_mouse";
//import "mod_multi"; //ya la carga controles si es necesaria
import "mod_proc";
import "mod_rand";
import "mod_regex";
import "mod_say";
import "mod_screen";
import "mod_scroll";
//import "mod_sort";
import "mod_sound";
import "mod_string";
import "mod_sys";
import "mod_text";
//import "mod_time";
import "mod_timers";
import "mod_video";
import "mod_wm";

Global
	sin_opciones=0;

	pausa;
	distancia;

	jugadores=1;
	id_nave[5];

	escudo[5]=0,5,5,5,5;
	poder[5]=0,1,1,1,1;
	fuerza[5]=0,1,1,1,1;
	energia[5]=0,20,20,20,20;
	habil[5]=0,1,1,1,1;
	puntos[5];

	string textos[200];
	
	arcade_mode=0;

	guardar=1;

	struct ops;
		struct teclado;	//controles teclado
			arriba=72;			//Arriba
			derecha=77;			//Derecha
			abajo=80;			//Abajo
			izquierda=75;		//Izquierda
			disparar=30;		//A
			bomba=31;			//S
			cambiar=32;			//D
		end
		struct gamepad	//controles gamepad
			arriba;		
			derecha;
			abajo;
			izquierda;
			disparar=0;			//0
			bomba=1;			//1
			cambiar=2;			//2
		end
		particulas=1;
		p_completa;
		resolucion=1;
		lenguaje=0;
	end
	
	//------ inicio controles.pr-
		njoys;
		posibles_jugadores;
		debuj;
		struct p[5];
			botones[7];
			control;
		end
		joysticks[10];
	//------ fin controles.pr-

	struct save;
		nivel=1;
		poder[5]=0,1,1,1,1;
		puntos[5];
	end
	
	struct puntuaciones[10];
		string nombres;
		puntos;
	end
		
	vida_boss;
	id_boss01;
	id_boss02;
	id_boss03;
	id_boss04;
	id_boss05;

	juego;

	opcion;
		  
	fpg_menu;
	fpg_nave;
	fpg_bombas;
	fpg_enemigos;
	fpg_bosses;
	fpg_explosiones;
		  
	fuente[5];

	s_disparo;
	s_laser1;
	s_laser2;
	s_laser3;
	s_misil;
	s_explosion;
	s_explosion_grande;

	s_aceptar;
	s_mover;
	s_cambiar_arma;

	cargada;
	
	archivo;

	disparos_sonando;

	string savegamedir;
	string developerpath="/.PiXJuegos/Garnatron/";

	ancho_pantalla;	//1024, 1280, 1920
	alto_pantalla;		//768, 720, 1080
	bpp=32;
	
	global_resolution;
End

Local
	accion;
	jugador;
	estado;
	patron;
	id_texto;
	inmunidad;
	i,j; //para controles.pr-
End

//include "..\..\common-src\mod_text2.pr-";
include "..\..\common-src\controles.pr-";
include "..\..\common-src\input_text.pr-";
include "..\..\common-src\savepath.pr-";
include "..\..\common-src\resolucioname.pr-";
include "..\..\common-src\lenguaje.pr-";

include "traducciones.pr-";

//-----------------------------------------------------------------------
// introduccion del juego
//-----------------------------------------------------------------------
BEGIN
	if(argc>0) if(argv[1]=="arcade") arcade_mode=1; end end
	
	set_fps(0,0);
	set_title("Garnatron");
	//--------------------------------------------------Cargando opciones
	
	if(os_id<1000)
		if(os_id==0) //windows
			savegamedir=getenv("APPDATA")+developerpath;
			if(savegamedir==developerpath) //windows 9x/me
				savegamedir=cd();
			else
				crear_jerarquia(savegamedir);
			end
		end
		if(os_id==1) //linux
			savegamedir=getenv("HOME")+developerpath;
			crear_jerarquia(savegamedir);
		end
	end
	
	if(os_id==1003)
		sin_opciones=1;
		savegamedir="/data/data/com.pixjuegos.garnatron/files/";
		mkdir(savegamedir);
		ops.particulas=0;
	end

	if(os_id==os_caanoo)
		sin_opciones=1;
		savegamedir="";
		ops.particulas=0;
	end
	
	if(os_id==os_wii)
		guardar=0;
		savegamedir="";
		ops.particulas=0;
		sin_opciones=1;
	end
	
	switch(lenguaje_sistema())
		case "es": ops.lenguaje=1; end
		case "ca": ops.lenguaje=2; end
		case "fr": ops.lenguaje=3; end
		default: ops.lenguaje=0; end
	end	
	
	carga_opciones();
	
	if(guardar)
		guarda_opciones();
		if(file_exists(savegamedir+"save.dat"))
			archivo=fopen(savegamedir+"save.dat",o_read);
			fread(archivo,save);
			fclose(archivo);
		else
			archivo=fopen(savegamedir+"save.dat",o_write);
			fwrite(archivo,save);
			fclose(archivo);
		end
	end
	//-------------------------------- lee puntuaciones
	lee_puntuaciones();

	if(arcade_mode==1)
		ops.p_completa=1;
		ops.particulas=0;
	end
	
	//-------------------------------------------------Iniciando variables
	
	carga_textos();
	
	gamepad_boton_separacion=75;
	gamepad_boton_size=60;
	
	key_b_arriba=ops.teclado.arriba;		//Arriba
	key_b_derecha=ops.teclado.derecha;		//Derecha
	key_b_abajo=ops.teclado.abajo;			//Abajo
	key_b_izquierda=ops.teclado.izquierda;	//Izquierda
	key_b_1=ops.teclado.disparar;			//A
	key_b_2=ops.teclado.bomba;				//S
	key_b_3=ops.teclado.cambiar;			//D

	//dump_type=-1;
	//restore_type=-1;
	ALPHA_STEPS=128;
	
	//-----------------------------------------------------------------Panalla
	
	if(os_id==1003)
		//android
		bpp=16;
		#IFDEF OUYA
			bpp=32;
			ancho_pantalla=1280;
			alto_pantalla=720;
			ops.particulas=0;
		#ELSE
			//si tiene un tama?o suficiente, lo ejecutamos con su resoluci?n nativa
			if(graphic_info(0,0,g_width)>800 and graphic_info(0,0,g_height)>550)
				ancho_pantalla=graphic_info(0,0,g_width);
				alto_pantalla=graphic_info(0,0,g_height);
			else //sino, escalado
				ancho_pantalla=1280;
				alto_pantalla=720;
				scale_resolution=graphic_info(0,0,g_width)*10000+graphic_info(0,0,g_height);
			end
		#ENDIF
		ops.p_completa=1;
		//resolucioname(ancho_pantalla,alto_pantalla,1);
	elseif(os_id==os_caanoo)
		ancho_pantalla=800;
		alto_pantalla=600;
		bpp=16;
	else
		switch(ops.resolucion)
			case 0:
				ancho_pantalla=1024;
				alto_pantalla=768;
				resolucioname(ancho_pantalla,alto_pantalla,0);
			end
			case 1:
				ancho_pantalla=1280;
				alto_pantalla=720;
				resolucioname(ancho_pantalla,alto_pantalla,1);
			end
			case 2:
				ancho_pantalla=1920;
				alto_pantalla=1080;
				resolucioname(ancho_pantalla,alto_pantalla,1);
			end
		end
	end
	
	if(ops.p_completa)
		full_screen=true;
	else
		full_screen=false;
	end
	set_mode(ancho_pantalla,alto_pantalla,bpp);

	//----------------------------------------------------------imagen cargando
	file=fpg_menu;
	//graph=1;
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	z=10;

	fuente[0]=load_fnt("fnt/fuente.fnt"); frame;

	write(fuente[0],ancho_pantalla/2,alto_pantalla/2,4,textos[0]);
	
	write(fuente[0],ancho_pantalla/2,(alto_pantalla/2)+100,4,"Garnatron on GPU - ALPHA version");

	frame;
	//--------------------------------------------------------Cargando archivos
	fpg_menu=load_fpg("fpg/menu.fpg"); frame;
	fpg_nave=load_fpg("fpg/nave.fpg"); frame;
	fpg_bombas=load_fpg("fpg/bombas.fpg"); frame;
	fpg_enemigos=load_fpg("fpg/enemigos.fpg"); frame;
	fpg_bosses=load_fpg("fpg/bosses.fpg"); frame;
	fpg_explosiones=load_fpg("fpg/explosiones.fpg"); frame;

	s_disparo=load_wav("wav/laser.wav"); frame;
	s_laser1=load_wav("wav/laser9.wav"); frame;
	s_laser2=load_wav("wav/onda01.wav"); frame;
	s_laser3=load_wav("wav/laser6.wav"); frame;
	s_misil=load_wav("wav/bomba5.wav"); frame;
	s_explosion=load_wav("wav/explos.wav"); frame;
	s_explosion_grande=load_wav("wav/explosg.wav"); frame;
	
	fuente[1]=load_fnt("fnt/garna1.fnt"); frame;
	fuente[2]=load_fnt("fnt/garna2.fnt"); frame;
	fuente[3]=load_fnt("fnt/garna3.fnt"); frame;
	fuente[4]=load_fnt("fnt/garna4.fnt"); frame;
	
	frame;
	delete_text(all_text);

	configurar_controles();
	
	if(posibles_jugadores>=5) posibles_jugadores=4; end

	start_scroll(0,fpg_menu,8,0,1,15); //numero,file,grafico,fondo,region,loop

	musica(1);
	graph=2;
	
	from alpha=0 to 255 step 10; frame; end
	timer[2]=0;

	while(timer[2]<200)
		frame;
	end

	from alpha=255 to 0 step -10; frame; end

	clear_screen();

	//jugadores=4;
	historia(1);
	//fase(6);
	frame;

end

//-----------------------------------------------------------------------
// proceso historia
//-----------------------------------------------------------------------

process historia(cosa);

private id2;

begin
	file=fpg_menu;
	let_me_alone();
	clear_screen();
	delete_text(all_text);
	fade_off();
	define_region(1,0,80,ancho_pantalla,alto_pantalla-160);
	fade_on();
	timer[2]=0;
	
	if(cosa==1)
	
		while(timer[2]<200)
			if(scan_code) 
				while(scan_code) scroll.x0+=3; frame; end
				menu(0); 
				delete_text(all_text); 
			end
			scroll.x0+=3;
			
			frame;
		end

		letra(textos[10],ancho_pantalla/2,alto_pantalla/2,4);
		timer[2]=0;
		while(timer[2]<600)
			if(scan_code) 
				while(scan_code) scroll.x0+=3; frame; end			
				menu(0); 
				delete_text(all_text); 
			end
			scroll.x0+=3;
			frame;
		end
	
		delete_text(all_text);
		menu(0);
	end

	if(cosa==2) //creditos
		musica(1);
		escapable();
		pausa=1;
		switch(jugadores)
			case 1:
				escudo[1]=5;
				id_nave[1]=nave01(-450,alto_pantalla/2,1);
				id_nave[1].angle=-90000;
			end
			case 2: 
				escudo[1]=5;
				id_nave[1]=nave01(-350,alto_pantalla/3,1);
				id_nave[1].angle=-90000;
				escudo[2]=5;
				id_nave[2]=nave01(-450,2*alto_pantalla/3,2);
				id_nave[2].angle=-90000;
			end
			case 3: 
				escudo[1]=5;
				id_nave[1]=nave01(-250,alto_pantalla/4,1);
				id_nave[1].angle=-90000;
				escudo[2]=5;
				id_nave[2]=nave01(-350,alto_pantalla/2,2);
				id_nave[2].angle=-90000;
				escudo[3]=5;
				id_nave[3]=nave01(-450,3*alto_pantalla/4,3);
				id_nave[3].angle=-90000;
			end
			case 4:
				escudo[1]=5;
				id_nave[1]=nave01(-150,alto_pantalla/5,1);
				id_nave[1].angle=-90000;
				escudo[2]=5;
				id_nave[2]=nave01(-250,2*alto_pantalla/5,2);
				id_nave[2].angle=-90000;
				escudo[3]=5;
				id_nave[3]=nave01(-350,3*alto_pantalla/5,3);
				id_nave[3].angle=-90000;
				escudo[4]=5;
				id_nave[4]=nave01(-450,4*alto_pantalla/5,4);
				id_nave[4].angle=-90000;
			end
		end
		letra(textos[11],400,200,1);
		timer[2]=0;
		while(timer[2]<600)
			if(id_nave[1].x<1800)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end
		
		letra(textos[12],ancho_pantalla-200,200,3);
		letra("Carles Vicent",ancho_pantalla-200,230,3);
		timer[2]=0;
		while(timer[2]<400)
			if(id_nave[1].x<1800)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end
	
		letra(textos[13],ancho_pantalla-400,alto_pantalla-200,0);
		letra("PiXeL",ancho_pantalla-400,alto_pantalla-200+30,0);
		timer[2]=0;
		while(timer[2]<400)
			if(id_nave[1].x<1800)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end
	
		letra(textos[14],200,alto_pantalla-200,2);
		letra("Carles Vicent",200,alto_pantalla-200+30,2);
		letra("DaniGM",200,alto_pantalla-200+60,2);
		timer[2]=0;
		while(timer[2]<400)
			if(id_nave[1].x<1800)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end

		letra(textos[15],400,200,1);
		letra("DIV 2 Games Studio",400,230,1);
		timer[2]=0;
		while(timer[2]<400)
			if(id_nave[1].x<1800)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end
	
		letra(textos[16],ancho_pantalla-200,200,3);
		letra("Chewrafa",ancho_pantalla-200,200+30,3);
		timer[2]=0;
		while(timer[2]<400)
			if(id_nave[1].x<1800)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end
		
		letra(textos[17],ancho_pantalla-400,alto_pantalla-290,0);
		letra("Carles Vicent",ancho_pantalla-400,alto_pantalla-260,0);
		letra("PiXeL",ancho_pantalla-400,alto_pantalla-230,0);
		letra("Jacques Olivier",ancho_pantalla-400,alto_pantalla-200,0);
		timer[2]=0;
		while(timer[2]<400)
			if(id_nave[1].x<1800)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end
		
		letra(textos[18],200,alto_pantalla-320,2);
		letra("Pablo",200,alto_pantalla-290,2);
		letra("Nerea",200,alto_pantalla-260,2);
		letra("Nicolas",200,alto_pantalla-230,2);
		letra("Ana",200,alto_pantalla-200,2);
		timer[2]=0;
		while(timer[2]<400)
			if(id_nave[1].x<1800)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end

		letra(textos[19],400,200,1);
		timer[2]=0;
		while(timer[2]<400)
			if(id_nave[1].x<1800)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end

		letra(textos[20],ancho_pantalla-200,200,3);
		timer[2]=0;
		while(timer[2]<600)
			if(id_nave[1].x<1800)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end

		letra(textos[21],ancho_pantalla/2,alto_pantalla/2,4);
		timer[2]=0;
		while(timer[2]<600)
			if(id_nave[1].x<1800)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end

		delete_text(all_text);
		if(os_id==os_caanoo)
			menu(0);
		else
			nuevo_highscore(puntos[1],puntos[2],puntos[3],puntos[4]);
		end
	end

end

//-----------------------------------------------------------------------
// proceso escapable por PiXeL, pulsa escape y va al menu
//-----------------------------------------------------------------------

process escapable();
Begin
	controlador(0);
	loop
		if(p[0].botones[7]) while(p[0].botones[7]) frame; end nuevo_highscore(puntos[1],puntos[2],puntos[3],puntos[4]); end
		frame;
	end
End

//-----------------------------------------------------------------------
// proceso letra por PiXeL
//-----------------------------------------------------------------------
Process letra(String texto,Int x,Int y,Int lao);
Private
    timercred;    
Begin
    Repeat
		id_texto=write(fuente[0],x,y,4,texto);
		timercred++;
		if(lao==0) x--; End
		if(lao==1) x++; end
		if(lao==2) y--; End
		if(lao==3) y++; End
		frame;
		delete_text(id_texto);
	Until(timercred=>170)
End


//-----------------------------------------------------------------------
// menu del juego
//-----------------------------------------------------------------------
process menu(num_menu);

private
	y_objetivo;
	opcion_actual=1;
	num_opciones;
	pulsando;
	volver_a_menu;
	a;

begin
	
	let_me_alone();
	clear_screen();
	delete_text(all_text);
	file=fpg_menu;
	define_region(1,0,0,ancho_pantalla,alto_pantalla);
	sombra(9,ancho_pantalla/2,75,file,2);
	objeto(ancho_pantalla/2,75,9,file,100,16);
	controlador(0);
	controlador(1);
	
	//modo arcade
	if(arcade_mode==1 and num_menu==0)
		write(fuente[0],ancho_pantalla/2,alto_pantalla/2,4,textos[100]);
		while(not p[0].botones[b_2])
			scroll.x0+=3;
			if(p[0].botones[b_salir]) exit(); end
			frame;
		end
		
		while(p[0].botones[b_2]) scroll.x0+=3; frame; end
		ayuda();
	end
	
	z=-20;
	graph=0;
	x=ancho_pantalla/2;
	if(alto_pantalla<600)
		y=120;
	else
		y=200;
	end
	
	//ponemos el men? actual
	switch(num_menu)
		case 0: //general
			boton(x,y+=60,textos[110],1);
			boton(x,y+=60,textos[111],2);
		//	if(!sin_opciones)
				boton(x,y+=60,textos[112],3);
				boton(x,y+=60,textos[113],4);
				boton(x,y+=60,textos[114],5);
				boton(x,y+=60,textos[115],6);
				num_opciones=6;
		/*	else
				boton(x,y+=60,textos[113],3);
				boton(x,y+=60,textos[114],4);
				boton(x,y+=60,textos[115],5);
				num_opciones=5;
			end*/
			volver_a_menu=0;
		end
		case 1: //opciones
			if(!sin_opciones)
				boton(x,y+=60,textos[130],1);
				boton(x,y+=60,textos[131],2);
				num_opciones=5;
			else
				num_opciones=3;
			end
			boton(x,y+=60,textos[132],3);
			if(ops.particulas==0)
				boton(x,y+=60,textos[133]+textos[1],4);
			else
				boton(x,y+=60,textos[133]+textos[2],4);
			end
			boton(x,y+=60,textos[101],5);
			num_opciones=5;
			volver_a_menu=0;
		end
		case 2: //video
			boton(x,y+=60,textos[140],1);
			boton(x,y+=60,textos[141],2);
			boton(x,y+=60,textos[142],3);
			boton(x,y+=60,textos[143],4);
			boton(x,y+=60,textos[101],5);
			num_opciones=5;
			volver_a_menu=0;
		end
		case 3: //control
			boton(x,y+=60,textos[150],1);
			boton(x,y+=60,textos[151],2);
			boton(x,y+=60,textos[152],3);
			boton(x,y+=60,textos[101],4);
			num_opciones=4;
			volver_a_menu=0;
		end
		case 4: //jugadores, juego nuevo
			boton(x,y+=60,"1 "+textos[120],1);
			boton(x,y+=60,"2 "+textos[121],2);
			num_opciones=3;
			if(posibles_jugadores>2)
				num_opciones++;
				boton(x,y+=60,"3 "+textos[121],3);
			end
			if(posibles_jugadores>3)
				num_opciones++;
				boton(x,y+=60,"4 "+textos[121],4);
			end
			boton(x,y+=60,+textos[101],num_opciones);
			volver_a_menu=0;
		end
		case 5: //jugadores, continuar
			boton(x,y+=60,"1 "+textos[120],1);
			boton(x,y+=60,"2 "+textos[121],2);
			num_opciones=3;
			if(posibles_jugadores>2)
				num_opciones++;
				boton(x,y+=60,"3 "+textos[121],3);
			end
			if(posibles_jugadores>3)
				num_opciones++;
				boton(x,y+=60,"4 "+textos[121],4);
			end
			boton(x,y+=60,+textos[101],num_opciones);
			volver_a_menu=0;
		end
		case 6: //idioma
			boton(x,y+=60,textos[170],1);
			boton(x,y+=60,textos[171],2);
			boton(x,y+=60,textos[172],3);
			boton(x,y+=60,textos[173],4);
			boton(x,y+=60,textos[101],5);
			num_opciones=5;
			volver_a_menu=0;
		end
	end
	
	x=ancho_pantalla/2;
	y=800;
	
	loop
		if(opcion_actual>num_opciones) opcion_actual=1;	end
		if(opcion_actual<1)	opcion_actual=num_opciones;	end
		opcion=opcion_actual;
		
		scroll.x0+=3;
		
		y_objetivo=200+(opcion_actual*60);
		if(y!=y_objetivo) y+=(y_objetivo-y)/2; end

		if(p[0].botones[b_aceptar])
			
			suena(s_aceptar);
			
			while(p[0].botones[b_aceptar]) scroll.x0+=3; frame; end
			switch(num_menu)
				case 0: //general
					switch(opcion_actual)
						case 1:
							if(posibles_jugadores>1)
								menu(4);
							else
								jugadores=1;
								puntos[1]=0;
								poder[1]=1;
								fase(1);
							end
						end
						case 2:
							if(posibles_jugadores>1)
								menu(5);
							else
								jugadores=1;
								puntos[1]=save.puntos[1];
								poder[1]=save.poder[1];
								fase(save.nivel);
							end
						end
						case 3:
							menu(1);
						end
						case 4: 
							highscores();
						end
						case 5:
							ayuda();
						end
						case 6:
							exit();
						end
					end
				end
				case 1: //opciones
					switch(opcion_actual)
						case 1:	//video
							menu(2);
						end
						case 2:	//controles
							menu(3);
						end
						case 3:	//idioma
							menu(6);
						end
						case 4:	//particulas
							if(os_id!=1003)
								if(ops.particulas==0)
									ops.particulas=1;
								else
									ops.particulas=0;
								end
							end
							menu(1);
						end
						case 5:	//volver
							if(guardar)
								guarda_opciones();
							end
							menu(0);
						end
					end
				end
				case 2: //video
					switch(opcion_actual)
						case 1: 
							full_screen=true;
							ops.p_completa=1;
							set_mode(ancho_pantalla,alto_pantalla,bpp);
						end
						case 2: 
							full_screen=false;
							ops.p_completa=0;
							set_mode(ancho_pantalla,alto_pantalla,bpp);
						end
						case 3:
							ops.resolucion=0;
							ancho_pantalla=1024;
							alto_pantalla=768;
							set_mode(ancho_pantalla,alto_pantalla,bpp);
							menu(2);
						end
						case 4:
							ops.resolucion=1;
							ancho_pantalla=1280;
							alto_pantalla=720;
							set_mode(ancho_pantalla,alto_pantalla,bpp);
							menu(2);
						end
				//		case 5:
				//			ops.resolucion=2;
				//			ancho_pantalla=1920;
				//			alto_pantalla=1080;
				//			set_mode(ancho_pantalla,alto_pantalla,bpp);
				//			menu(2);
				//		end
						case 5:
							menu(1);
						end
					end
				end
				case 3: //control
					switch(opcion_actual)
						case 1: //teclado
							
							let_me_alone();
							clear_screen();
							delete_text(all_text);
							
							id_texto=write(fuente[0],ancho_pantalla/2,400,4,textos[160]);
							repeat
								ops.teclado.arriba=scan_code;
								frame;
								scroll.x0+=3;
							until(ops.teclado.arriba<>0);
							while(scan_code<>0) frame; scroll.x0+=3; end
							delete_text(id_texto);
	
							id_texto=write(fuente[0],ancho_pantalla/2,400,4,textos[161]);
							Repeat
								ops.teclado.derecha=scan_code;
								frame;
								scroll.x0+=3;
							until(ops.teclado.derecha<>0);
							while(scan_code<>0) frame; scroll.x0+=3; end
							delete_text(id_texto);

							id_texto=write(fuente[0],ancho_pantalla/2,400,4,textos[162]);
							Repeat
								ops.teclado.abajo=scan_code;
								frame;
								scroll.x0+=3;
							until(ops.teclado.abajo<>0);
							while(scan_code<>0) frame; scroll.x0+=3; end
							delete_text(id_texto);
	
							id_texto=write(fuente[0],ancho_pantalla/2,400,4,textos[163]);
							Repeat
								ops.teclado.izquierda=scan_code;
								frame;
								scroll.x0+=3;
							until(ops.teclado.izquierda<>0);
							while(scan_code<>0) frame; scroll.x0+=3; end
							delete_text(id_texto);
	
							id_texto=write(fuente[0],ancho_pantalla/2,400,4,textos[164]);
							Repeat
								ops.teclado.disparar=scan_code;
								frame;
								scroll.x0+=3;
							until(ops.teclado.disparar<>0);
							while(scan_code<>0) frame; scroll.x0+=3; end
							delete_text(id_texto);

							id_texto=write(fuente[0],ancho_pantalla/2,400,4,textos[165]);
							Repeat
								ops.teclado.bomba=scan_code;
								frame;
								scroll.x0+=3;
							until(ops.teclado.bomba<>0);
							while(scan_code<>0) frame; scroll.x0+=3; end
							delete_text(id_texto);

							id_texto=write(fuente[0],ancho_pantalla/2,400,4,textos[166]);
							Repeat
								ops.teclado.cambiar=scan_code;
								frame;
								scroll.x0+=3;
							until(ops.teclado.cambiar<>0);
							while(scan_code<>0) frame; scroll.x0+=3; end
							delete_text(id_texto);

							frame;
							
							key_b_arriba=ops.teclado.arriba;
							key_b_derecha=ops.teclado.derecha;
							key_b_abajo=ops.teclado.abajo;
							key_b_izquierda=ops.teclado.izquierda;
							key_b_1=ops.teclado.disparar;
							key_b_2=ops.teclado.bomba;
							key_b_3=ops.teclado.cambiar;
							
							if(guardar)
								guarda_opciones();
							end
							menu(1);
						end
						case 2: //gamepad
							let_me_alone();
							clear_screen();
							delete_text(all_text);

							id_texto=write(fuente[0],ancho_pantalla/2,400,4,textos[167]);
							repeat
								from a=0 to 11;
									if(get_joy_button(0,a))
										ops.gamepad.disparar=a;
										break;
									end
								end
								frame;
								scroll.x0+=3;
							until(get_joy_button(0,ops.gamepad.disparar));
							while(get_joy_button(0,ops.gamepad.disparar))
								frame;
								scroll.x0+=3;
							end
							delete_text(id_texto);

							id_texto=write(fuente[0],ancho_pantalla/2,400,4,textos[168]);
							repeat
								from a=0 to 11;
									if(get_joy_button(0,a))
										ops.gamepad.bomba=a;
										break;
									end
								end
								frame;
								scroll.x0+=3;
							until(get_joy_button(0,ops.gamepad.bomba));
							while(get_joy_button(0,ops.gamepad.bomba))
								frame;
								scroll.x0+=3;
							end
							delete_text(id_texto);

							id_texto=write(fuente[0],ancho_pantalla/2,400,4,textos[169]);
							repeat
								from a=0 to 11;
									if(get_joy_button(0,a))
										ops.gamepad.cambiar=a;
										break;
									end
								end
								frame;
								scroll.x0+=3;
							until(get_joy_button(0,ops.gamepad.cambiar));
							while(get_joy_button(0,ops.gamepad.cambiar))
								frame;
								scroll.x0+=3;
							end
							delete_text(id_texto);

							frame;
							
							if(guardar)
								guarda_opciones();
							end
							menu(1);
						end
						case 3: //restabecer

							ops.teclado.arriba=72;			//Arriba
							ops.teclado.derecha=77;			//Derecha
							ops.teclado.abajo=80;			//Abajo
							ops.teclado.izquierda=75;		//Izquierda
							ops.teclado.disparar=30;		//A
							ops.teclado.bomba=31;			//S
							ops.teclado.cambiar=32;			//D

							ops.gamepad.disparar=0;			//0
							ops.gamepad.bomba=1;			//1
							ops.gamepad.cambiar=2;			//2
							
							key_b_arriba=ops.teclado.arriba;
							key_b_derecha=ops.teclado.derecha;
							key_b_abajo=ops.teclado.abajo;
							key_b_izquierda=ops.teclado.izquierda;
							key_b_1=ops.teclado.disparar;
							key_b_2=ops.teclado.bomba;
							key_b_3=ops.teclado.cambiar;
							
							if(guardar)
								guarda_opciones();
							end
							menu(1);
						end
						case 4:
							menu(1);
						end
					end
				end
				case 4: //numero jugadores, juego nuevo
					jugadores=opcion_actual;
					if(jugadores>num_opciones-1) jugadores=num_opciones-1; end
					from jugador=1 to jugadores;
						puntos[jugador]=0;
						poder[jugador]=1;
					end
					if(num_opciones==opcion_actual)
						menu(0);
						return;
					else
						fase(1);
					end
				end
				case 5: //numero jugadores, continuar
					jugadores=opcion_actual;
					if(jugadores>num_opciones-1) jugadores=num_opciones-1; end
					from jugador=1 to jugadores;
						puntos[jugador]=save.puntos[1];
						poder[jugador]=save.poder[1];
					end
					if(num_opciones==opcion_actual)
						menu(0);
						return;
					else
						fase(save.nivel);
					end
				end
				case 6: //idioma
					switch(opcion_actual)
						case 1:	//ingles
							ops.lenguaje=0;
							carga_textos();
							menu(6);
						end
						case 2:	//espa?ol
							ops.lenguaje=1;
							carga_textos();
							menu(6);
						end
						case 3:	//catalan
							ops.lenguaje=2;
							carga_textos();
							menu(6);
						end
						case 4:	//catalan
							ops.lenguaje=3;
							carga_textos();
							menu(6);
						end
						case 5:	//volver
							menu(1);
						end
					end
				end
			end
		end
		if(num_menu==1)//en Android no hay algunas opciones
			if(sin_opciones)
				while(opcion_actual<3)
					opcion_actual++; 
				end 
			end
		end
		if(p[0].botones[b_cancelar] and volver_a_menu!=num_menu)
			delete_text(all_text);
			
			suena(s_aceptar);
			
			while(p[0].botones[b_aceptar]) scroll.x0+=3; frame; end
			menu(volver_a_menu);
			
		end
		if(p[0].botones[3])
			if(!pulsando)
				opcion_actual++;
				suena(s_mover);
				pulsando=1;
			end
		elseif(p[0].botones[2])
			if(!pulsando)
				opcion_actual--;
				suena(s_mover);
				pulsando=1;
			end
		else
			pulsando=0;
		end

		frame;
	end
end


//-----------------------------------------------------------------------
// proceso que crea un boton
//-----------------------------------------------------------------------

process boton(x,y,string texto,int a);

begin
	file=fpg_menu;
	z=-100;
	id_texto=write(fuente[0],x,y,4,texto);
	loop
		if(opcion==a)
			graph=10;
		else
			graph=11;
		end
		frame;
	end
end

//-----------------------------------------------------------------------
// proceso ayuda
//-----------------------------------------------------------------------

process ayuda();

begin
	let_me_alone();
	delete_text(all_text);
	controlador(0);
	file=fpg_menu;

	graph=5;

	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	
	write(fuente[0],ancho_pantalla/2 + 360,alto_pantalla/2 - 245,4,textos[114]); //T?tulo
	
	write(fuente[0],ancho_pantalla/2 - 430,alto_pantalla/2 - 250,4,textos[70]);
	write(fuente[0],ancho_pantalla/2 - 350,alto_pantalla/2 - 220,4,textos[71]);
	write(fuente[0],ancho_pantalla/2 - 170,alto_pantalla/2 - 250,4,textos[72]);
	write(fuente[0],ancho_pantalla/2 - 90,alto_pantalla/2 - 220,4,textos[73]);
	
	write(fuente[0],ancho_pantalla/2 + 20,alto_pantalla/2 - 170,3,textos[74]);
	write(fuente[0],ancho_pantalla/2 + 20,alto_pantalla/2 - 130,3,textos[75]);
	write(fuente[0],ancho_pantalla/2 + 20,alto_pantalla/2 - 90,3,textos[76]);
	write(fuente[0],ancho_pantalla/2 + 20,alto_pantalla/2 - 50,3,textos[77]);
	write(fuente[0],ancho_pantalla/2 + 20,alto_pantalla/2 - 10,3,textos[78]);
	
	write(fuente[0],ancho_pantalla/2 - 450,alto_pantalla/2 + 180,3,textos[79]); //Armas
	
	write(fuente[0],ancho_pantalla/2 - 190,alto_pantalla/2 + 180,5,textos[80]);
	write(fuente[0],ancho_pantalla/2 - 190,alto_pantalla/2 + 250,5,textos[81]);
	
	write(fuente[0],ancho_pantalla/2 + 90,alto_pantalla/2 + 180,5,textos[82]);
	write(fuente[0],ancho_pantalla/2 + 90,alto_pantalla/2 + 250,5,textos[83]);
	
	write(fuente[0],ancho_pantalla/2 + 370,alto_pantalla/2 + 180,5,textos[84]);
	write(fuente[0],ancho_pantalla/2 + 370,alto_pantalla/2 + 250,5,textos[85]);
	
	write(fuente[0],ancho_pantalla/2 + 20,alto_pantalla/2 + 50,3,textos[86]); //Bono
	
	write(fuente[0],ancho_pantalla/2 + 20,alto_pantalla/2 + 100,3,textos[87]);
	write(fuente[0],ancho_pantalla/2 + 180,alto_pantalla/2 + 100,3,textos[88]);
	write(fuente[0],ancho_pantalla/2 + 340,alto_pantalla/2 + 100,3,textos[89]);
	
	while(not p[0].botones[b_aceptar])
		scroll.x0+=3;
		frame;
	end
	while(p[0].botones[b_aceptar])
		scroll.x0+=3;
		frame;
	end
	if(arcade_mode==1)
		jugadores=2;
		poder[1]=1;
		poder[2]=1;
		puntos[1]=0;
		puntos[2]=0;
		menu(4);
	//	fase(1);
	else
		menu(0);
	end
	frame;
end


//-----------------------------------------------------------------------
// proceso que crea un efecto
//-----------------------------------------------------------------------

process sombra(graph,x,y,file,cosa);
begin

z=-111;
if(cosa==1)	//alarma
	from size = 20 to 150 step 10;
		angle+=30000;
		alpha-=10;
    	frame;
	end
end
if(cosa==2)	//titulo
	from alpha=255 to 0 step -20;
		size+=3;
		frame;
	end
end
if(cosa==3) //destello
	z=-90;
    	frame(700);
end
if(cosa==4) //onda expasiva
	flags=4;
	from size = 100 to 500 step 20;
		alpha--;
		while(pausa!=0) frame; end
    	frame;
	end
end
if(cosa==5)	//marcadores
	flags=father.flags+16;
	from alpha=255 to 0 step -20;
		size+=3;
		while(pausa!=0) frame; end
		frame;
	end
end
end

process estela(x,y,angle,file,graph);
Begin
	z-=10;
	from alpha=255 to 0 step -20;
	while(pausa!=0) frame; end
	frame;
	end
end


//-----------------------------------------------------------------------
// procesos auxiliares
//-----------------------------------------------------------------------

process objeto(x,y,graph,file,size,flags);
begin
	z=-90;
	loop 
		frame;
	end
end


//-----------------------------------------------------------------------
// Musica del juego
//-----------------------------------------------------------------------

PROCESS musica(cancion);
BEGIN
	//FADE_MUSIC_OFF(0); 
	timer[1]=0;
	unload_song(cargada);
	cargada=load_song("ogg/"+cancion+".ogg");
	play_song(cargada,-1);
	frame;
END

//-----------------------------------------------------------------------
// sonidos del juego
//-----------------------------------------------------------------------

Process suena(sonido);

Private
	l;
	id_sonido;
Begin
	l=(father.x*255)/ancho_pantalla;
	id_sonido=play_wav(sonido,0); 
	set_panning(id_sonido,255-l,l);
	Frame;
END
//-----------------------------------------------------------------------
// explosiones del juego
//-----------------------------------------------------------------------

process explosion(x,y,tipo,size);
begin
file=fpg_explosiones;
z=father.z-1;
region=1;
if(tipo==1)
	graph=1;
	suena(s_explosion);
	repeat
		if(pausa==0) graph++; alpha-=10; end
	frame;
	until(graph==12)
end
if(tipo==2)
	graph=20;
	repeat
		if(pausa==0) graph++; alpha-=10; end
	frame;
	until(graph==31)
end
if(tipo==3)
	graph=1;
	suena(s_explosion_grande);
	repeat
		if(pausa==0) graph++; alpha-=10; size+=20; end
	frame;
	until(graph==12)
end
if(tipo==4)
	graph=1;
	suena(s_explosion_grande);
	sombra(41,x,y,file,4);
	sombra(40,ancho_pantalla/2,alto_pantalla/2,file,3);
	repeat
		if(pausa==0) graph++; alpha-=10; size+=20; end
	frame;
	until(graph==12)
end
end

//-----------------------------------------------------------------------
// explosiones de particulas
//-----------------------------------------------------------------------

Process explotalo(x,y,z,alpha,angle,file,grafico,frames);
Private
	a;
	b;
	c;
	tiempo;
	ancho;
	alto;
	struct particula[10000];
		pixell;
		pos_x;
		pos_y;
		vel_y;
		vel_x;
	end
Begin
	ancho=graphic_info(file,grafico,g_width);
	alto=graphic_info(file,grafico,g_height);
		from b=0 to alto-1 step 7;
		from a=0 to ancho-1 step 7;
			if(map_get_pixel(file,grafico,a,b)!=0)
				particula[c].pixell=map_get_pixel(file,grafico,a,b);
				particula[c].pos_x=a-(ancho/2);
				particula[c].pos_y=b-(alto/2);
				particula[c].vel_x=((a-(ancho/2))/6);
				particula[c].vel_y=((b-(alto/2))/6);
				c++;
			end
		end
	end
	a=c;
	graph=new_map(ancho*2,alto*2,bpp);
	drawing_map(file,graph);
	while(tiempo<frames)
		map_clear(file,graph,0);
		from c=0 to a;
			drawing_color(particula[c].pixell);
			draw_line(
					particula[c].pos_x+(ancho*2/2),
					particula[c].pos_y+(alto*2/2),
					particula[c].pos_x+(ancho*2/2)+particula[c].vel_x,
					particula[c].pos_y+(alto*2/2)+particula[c].vel_y
					);
			particula[c].pos_x+=particula[c].vel_x;
			particula[c].pos_y+=particula[c].vel_y;
		end
		tiempo++;
		frame;
	end
	unload_map(file,graph);
end

//-----------------------------------------------------------------------
// includes
//-----------------------------------------------------------------------

include "niveles.pr-"
include "nave.pr-"
include "bombas.pr-"
include "bosses.pr-"
include "enemigos.pr-"
include "puntuaciones.pr-"

Function salir_android();
Begin
	//guardar_partida_instantanea();
	exit();
End