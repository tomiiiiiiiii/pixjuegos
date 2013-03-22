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
import "mod_flic";
import "mod_m7";
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
import "mod_sort";
import "mod_sound";
import "mod_string";
import "mod_sys";
import "mod_text";
import "mod_time";
import "mod_timers";
import "mod_video";
import "mod_wm";

Global
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
		resolucion;
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
		string nombres[10]="PoX", "PeX", "PaX", "PuX", "PiX", "Nico", "Ana", "Nibbler337", "PiXeL", "Carles Vicent";
		puntuacion[10]=1000,2000,3000,4000,5000,6000,7000,8000,9000,10000;
		puntos[5];
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
End

Local
	jugador;
	estado;
	patron;
	id_texto;
	inmunidad;
	i,j; //para controles.pr-
End

include "..\..\common-src\controles.pr-";
include "..\..\common-src\input_text.pr-";
include "..\..\common-src\savepath.pr-";
include "..\..\common-src\resolucioname.pr-";

//-----------------------------------------------------------------------
// introduccion del juego
//-----------------------------------------------------------------------
BEGIN
	if(argc>0) if(argv[1]=="arcade") arcade_mode=1; end end
	
	set_fps(40,10);
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
		savegamedir="/data/data/com.pixjuegos.garnatron/files";
		ops.particulas=0;
	end
	
	
	carga_opciones();
	
	if(guardar)
		guarda_opciones();
		if(file_exists(savegamedir+"save.dat"))
			archivo=fopen(savegamedir+"save.dat",o_read);
			fread(archivo,save);
			fclose(archivo);
		end
	end

	if(arcade_mode==1)
		ops.p_completa=1;
		ops.particulas=0;
	end
	
	//-------------------------------------------------Iniciando variables
	
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
		ancho_pantalla=1024;
		alto_pantalla=552;
		resolucioname(ancho_pantalla,alto_pantalla,1);
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
		set_mode(ancho_pantalla,alto_pantalla,bpp,WAITVSYNC);
	else
		full_screen=false;
		set_mode(ancho_pantalla,alto_pantalla,bpp,WAITVSYNC);
	end

	//----------------------------------------------------------imagen cargando
	file=fpg_menu;
	graph=1;
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	z=10;

	frame;
	//--------------------------------------------------------Cargando archivos
	fpg_menu=load_fpg("fpg/menu.fpg"); frame;
	fpg_nave=load_fpg("fpg/nave.fpg"); frame;
	fpg_bombas=load_fpg("fpg/bombas.fpg"); frame;
	fpg_enemigos=load_fpg("fpg/enemigos.fpg"); frame;
	fpg_bosses=load_fpg("fpg/bosses.fpg"); frame;
	fpg_explosiones=load_fpg("fpg/explosiones.fpg"); frame;

	say("----------------- FPGS CARGADOS!");
	
	s_disparo=load_wav("wav/laser.wav"); frame;
	s_laser1=load_wav("wav/laser9.wav"); frame;
	s_laser2=load_wav("wav/onda01.wav"); frame;
	s_laser3=load_wav("wav/laser6.wav"); frame;
	s_misil=load_wav("wav/bomba5.wav"); frame;
	s_explosion=load_wav("wav/explos.wav"); frame;
	s_explosion_grande=load_wav("wav/explosg.wav"); frame;

	say("----------------- WAVS CARGADOS!");
	
	fuente[0]=load_fnt("fnt/fuente.fnt"); frame;
	fuente[1]=load_fnt("fnt/garna1.fnt"); frame;
	fuente[2]=load_fnt("fnt/garna2.fnt"); frame;
	fuente[3]=load_fnt("fnt/garna3.fnt"); frame;
	fuente[4]=load_fnt("fnt/garna4.fnt"); frame;

	say("----------------- FNTS CARGADOS!");
	
	frame;

	configurar_controles();

	start_scroll(0,fpg_menu,8,0,1,15); //numero,file,grafico,fondo,region,loop

	musica(1);
	graph=2;
	
	say("----------------- INICIALIZANDO COSICAS!");
	
	from alpha=0 to 255 step 10; frame; end
	timer[2]=0;

	while(timer[2]<200)
		frame;
	end

	from alpha=255 to 0 step -10; frame; end

	clear_screen();

	//jugadores=4;
	historia(1);
	//fase(5);
	//juego(1);
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

		letra("PiX Juegos  presenta",ancho_pantalla/2,alto_pantalla/2,4);
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
				id_nave[1]=nave01(-450,alto_pantalla/2,1);
				id_nave[1].angle=-90000;
				escudo[1]=5;
			end
			case 2: 
				id_nave[1]=nave01(-350,alto_pantalla/3,1);
				id_nave[1].angle=-90000;
				escudo[1]=5;
				id_nave[2]=nave01(-450,2*alto_pantalla/3,2);
				id_nave[2].angle=-90000;
				escudo[2]=5;
			end
			case 3: 
				id_nave[1]=nave01(-250,alto_pantalla/4,1);
				id_nave[1].angle=-90000;
				escudo[1]=5;
				id_nave[2]=nave01(-350,alto_pantalla/2,2);
				id_nave[2].angle=-90000;
				escudo[2]=5;
				id_nave[3]=nave01(-450,3*alto_pantalla/4,3);
				id_nave[3].angle=-90000;
				escudo[3]=5;
			end
			case 4:
				id_nave[1]=nave01(-150,alto_pantalla/5,1);
				id_nave[1].angle=-90000;
				escudo[1]=5;
				id_nave[2]=nave01(-250,2*alto_pantalla/5,2);
				id_nave[2].angle=-90000;
				escudo[2]=5;
				id_nave[3]=nave01(-350,3*alto_pantalla/5,3);
				id_nave[3].angle=-90000;
				escudo[3]=5;
				id_nave[4]=nave01(-450,4*alto_pantalla/5,4);
				id_nave[4].angle=-90000;
				escudo[4]=5;
			end
		end
		
		letra("Autores",200,200,1);
		timer[2]=0;
		while(timer[2]<600)
			if(id_nave[1].x<1600)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end
	
		letra("Programado por",ancho_pantalla-200,200,3);
		letra("Carles Vicent",ancho_pantalla-200,230,3);
		timer[2]=0;
		while(timer[2]<400)
			if(id_nave[1].x<1600)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end
	
		letra("Ayudante",ancho_pantalla-200,alto_pantalla-200,0);
		letra("PiXeL",ancho_pantalla-200,alto_pantalla-200+30,0);
		timer[2]=0;
		while(timer[2]<400)
			if(id_nave[1].x<1600)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end
	
		letra("Graficos",200,alto_pantalla-200,2);
		letra("Carles Vicent",200,alto_pantalla-200+30,2);
		letra("DaniGM",200,alto_pantalla-200+60,2);
		timer[2]=0;
		while(timer[2]<400)
			if(id_nave[1].x<1600)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end

		letra("Sonido",ancho_pantalla-200,200,3);
		letra("no me acuerdo",ancho_pantalla-200,230,3);
		timer[2]=0;
		while(timer[2]<400)
			if(id_nave[1].x<1600)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end
	
		letra("Musica",ancho_pantalla-200,alto_pantalla-200,0);
		letra("Chewrafa",ancho_pantalla-200,alto_pantalla-200+30,0);
		timer[2]=0;
		while(timer[2]<400)
			if(id_nave[1].x<1600)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end
		
		letra("Gracias a:",200,200,1);
		letra("Pablo",200,230,1);
		letra("Nerea",200,260,1);
		letra("Nicolas",200,290,1);
		letra("Ana",200,320,1);
		timer[2]=0;
		while(timer[2]<400)
			if(id_nave[1].x<1600)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end

		letra("Hecho en Bennu",ancho_pantalla-200,200,3);
		timer[2]=0;
		while(timer[2]<400)
			if(id_nave[1].x<1600)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end

		letra("Creado por PiX Juegos",ancho_pantalla-200,alto_pantalla-200,0);
		timer[2]=0;
		while(timer[2]<600)
			if(id_nave[1].x<1600)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end

		letra("Gracias por jugar",ancho_pantalla/2,alto_pantalla/2,4);
		timer[2]=0;
		while(timer[2]<600)
			if(id_nave[1].x<1600)
				from jugador=1 to jugadores;
					id_nave[jugador].x+=1;
				end
			end
			scroll.x0+=3;
			frame;
		end

		delete_text(all_text);
		highscores(puntos[1],puntos[2],puntos[3],puntos[4]);
	end

end

//-----------------------------------------------------------------------
// proceso escapable por PiXeL, pulsa escape y va al menu
//-----------------------------------------------------------------------

process escapable();
Begin
	controlador(0);
	loop
		if(p[0].botones[7]) while(p[0].botones[7]) frame; end highscores(puntos[1],puntos[2],puntos[3],puntos[4]); end
		frame;
	end
End

//-----------------------------------------------------------------------
// proceso letra por PiXeL
//-----------------------------------------------------------------------

Process letra(String texto,Int texto_x,Int texto_y,Int lao);
Private
    timercred;    
Begin
	
    Repeat
	timercred++;
	id_texto=write(fuente[0],texto_x,texto_y,4,texto);
	Frame;        
	If(lao==1) texto_x+=1; end
	if(lao==0) texto_x-=1; End
	if(lao==2) texto_y-=1; End
	if(lao==3) texto_y+=1; End

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
		write(fuente[0],ancho_pantalla/2,alto_pantalla/2,4,"Pulsa el boton 2 para empezar");
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
	y=200;
	
	//ponemos el menú actual
	switch(num_menu)
		case 0: //general
			boton(x,y+=60,"Jugar",1);
			boton(x,y+=60,"Continuar",2);
			boton(x,y+=60,"Opciones",3);
			boton(x,y+=60,"Clasificacion",4);
			boton(x,y+=60,"Ayuda",5);
			boton(x,y+=60,"Salir",6);
			num_opciones=6;
			volver_a_menu=0;
		end
		case 1: //opciones
			boton(x,y+=60,"Video",1);
			boton(x,y+=60,"Control",2);
			if(ops.particulas==0)
				boton(x,y+=60,"Particulas: No",3);
			else
				boton(x,y+=60,"Particulas: Si",3);
			end
			boton(x,y+=60,"Volver",4);
			num_opciones=4;
			volver_a_menu=0;
		end
		case 2: //video
			boton(x,y+=60,"Pantalla completa",1);
			boton(x,y+=60,"Ventana",2);
			boton(x,y+=60,"1024x768",3);
			boton(x,y+=60,"1280x720",4);
			boton(x,y+=60,"1920x1080",5);
			boton(x,y+=60,"Volver",6);
			num_opciones=6;
			volver_a_menu=0;
		end
		case 3: //control
			boton(x,y+=60,"Teclado",1);
			boton(x,y+=60,"Mando",2);
			boton(x,y+=60,"Restablecer",3);
			boton(x,y+=60,"Volver",4);
			num_opciones=4;
			volver_a_menu=0;
		end
		case 4: //jugadores, juego nuevo
			boton(x,y+=60,"1 Jugador",1);
			boton(x,y+=60,"2 Jugadores",2);
			num_opciones=3;
			if(posibles_jugadores>2)
				num_opciones++;
				boton(x,y+=60,"3 Jugadores",3);
			end
			if(posibles_jugadores>3)
				num_opciones++;
				boton(x,y+=60,"4 Jugadores",4);
			end
			boton(x,y+=60,"Volver",num_opciones);
			volver_a_menu=0;
		end
		case 5: //jugadores, continuar
			boton(x,y+=60,"1 Jugador",1);
			boton(x,y+=60,"2 Jugadores",2);
			num_opciones=3;
			if(posibles_jugadores>2)
				num_opciones++;
				boton(x,y+=60,"3 Jugadores",3);
			end
			if(posibles_jugadores>3)
				num_opciones++;
				boton(x,y+=60,"4 Jugadores",4);
			end
			boton(x,y+=60,"Volver",num_opciones);
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

		if(p[0].botones[5])
			
			suena(s_aceptar);
			
			while(p[0].botones[5]) scroll.x0+=3; frame; end
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
							highscores(0,0,0,0);
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
						case 3:	//particulas
							if(ops.particulas==0)
								ops.particulas=1;
							else
								ops.particulas=0;
							end
							menu(1);
						end
						case 4:	//volver
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
							set_mode(ancho_pantalla,alto_pantalla,bpp,WAITVSYNC);
						end
						case 2: 
							full_screen=false;
							ops.p_completa=0;
							set_mode(ancho_pantalla,alto_pantalla,bpp,WAITVSYNC);
						end
						case 3:
							ops.resolucion=0;
							ancho_pantalla=1024;
							alto_pantalla=768;
							set_mode(ancho_pantalla,alto_pantalla,bpp,WAITVSYNC);
							menu(2);
						end
						case 4:
							ops.resolucion=1;
							ancho_pantalla=1280;
							alto_pantalla=720;
							set_mode(ancho_pantalla,alto_pantalla,bpp,WAITVSYNC);
							menu(2);
						end
						case 5:
							ops.resolucion=2;
							ancho_pantalla=1920;
							alto_pantalla=1080;
							set_mode(ancho_pantalla,alto_pantalla,bpp,WAITVSYNC);
							menu(2);
						end
						case 6:
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
							
							id_texto=write(fuente[0],ancho_pantalla/2,400,4,"Pulse tecla para arriba");
							repeat
								ops.teclado.arriba=scan_code;
								frame;
								scroll.x0+=3;
							until(ops.teclado.arriba<>0);
							while(scan_code<>0) frame; scroll.x0+=3; end
							delete_text(id_texto);
	
							id_texto=write(fuente[0],ancho_pantalla/2,400,4,"Pulse una tecla para derecha");
							Repeat
								ops.teclado.derecha=scan_code;
								frame;
								scroll.x0+=3;
							until(ops.teclado.derecha<>0);
							while(scan_code<>0) frame; scroll.x0+=3; end
							delete_text(id_texto);

							id_texto=write(fuente[0],ancho_pantalla/2,400,4,"Pulse una tecla para abajo");
							Repeat
								ops.teclado.abajo=scan_code;
								frame;
								scroll.x0+=3;
							until(ops.teclado.abajo<>0);
							while(scan_code<>0) frame; scroll.x0+=3; end
							delete_text(id_texto);
	
							id_texto=write(fuente[0],ancho_pantalla/2,400,4,"Pulse una tecla para izquierda");
							Repeat
								ops.teclado.izquierda=scan_code;
								frame;
								scroll.x0+=3;
							until(ops.teclado.izquierda<>0);
							while(scan_code<>0) frame; scroll.x0+=3; end
							delete_text(id_texto);
	
							id_texto=write(fuente[0],ancho_pantalla/2,400,4,"Pulse una tecla para diparar");
							Repeat
								ops.teclado.disparar=scan_code;
								frame;
								scroll.x0+=3;
							until(ops.teclado.disparar<>0);
							while(scan_code<>0) frame; scroll.x0+=3; end
							delete_text(id_texto);

							id_texto=write(fuente[0],ancho_pantalla/2,400,4,"Pulse una tecla para disparar una bomba");
							Repeat
								ops.teclado.bomba=scan_code;
								frame;
								scroll.x0+=3;
							until(ops.teclado.bomba<>0);
							while(scan_code<>0) frame; scroll.x0+=3; end
							delete_text(id_texto);

							id_texto=write(fuente[0],ancho_pantalla/2,400,4,"Pulse una tecla para cambiar arma");
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
/*	--------------------------------------------------------- Asignación de los botones de mobimiento
							select_joy(0);
							frame;
							id_texto=write(fuente[0],400,400,4,"Presiona arriba y luego pulsa un boton");

							while(!get_joy_button(0) and !get_joy_button(1) 
							and !get_joy_button(2) and !get_joy_button(3)
							and !get_joy_button(4) and !get_joy_button(5)
							and !get_joy_button(6) and !get_joy_button(7)
							and !get_joy_button(8) and !get_joy_button(9)
							and !get_joy_button(10) and !get_joy_button(11)) 
								ops.gamepad.arriba=get_joy_position(1);
								frame;
							end
							while(get_joy_button(0) or get_joy_button(1) 
							or get_joy_button(2) or get_joy_button(3)
							or get_joy_button(4) or get_joy_button(5)
							or get_joy_button(6) or get_joy_button(7)
							or get_joy_button(8) or get_joy_button(9)
							or get_joy_button(10) or get_joy_button(11))
								frame;
							end
							delete_text(id_texto);

							id_texto=write(fuente[0],400,400,4,"Presiona derecha y luego pulsa un boton");

							while(!get_joy_button(0) and !get_joy_button(1) 
							and !get_joy_button(2) and !get_joy_button(3)
							and !get_joy_button(4) and !get_joy_button(5)
							and !get_joy_button(6) and !get_joy_button(7)
							and !get_joy_button(8) and !get_joy_button(9)
							and !get_joy_button(10) and !get_joy_button(11))

								ops.gamepad.derecha=get_joy_position(0);
								frame;
							end
							while(get_joy_button(0) or get_joy_button(1) 
							or get_joy_button(2) or get_joy_button(3)
							or get_joy_button(4) or get_joy_button(5)
							or get_joy_button(6) or get_joy_button(7)
							or get_joy_button(8) or get_joy_button(9)
							or get_joy_button(10) or get_joy_button(11))
								frame;
							end
							delete_text(id_texto);

							id_texto=write(fuente[0],400,400,4,"Presiona abajo y luego pulsa un boton");

							while(!get_joy_button(0) and !get_joy_button(1) 
							and !get_joy_button(2) and !get_joy_button(3)
							and !get_joy_button(4) and !get_joy_button(5)
							and !get_joy_button(6) and !get_joy_button(7)
							and !get_joy_button(8) and !get_joy_button(9)
							and !get_joy_button(10) and !get_joy_button(11))
								ops.gamepad.abajo=get_joy_position(1);
								frame;
							end
							while(get_joy_button(0) or get_joy_button(1) 
							or get_joy_button(2) or get_joy_button(3)
							or get_joy_button(4) or get_joy_button(5)
							or get_joy_button(6) or get_joy_button(7)
							or get_joy_button(8) or get_joy_button(9)
							or get_joy_button(10) or get_joy_button(11))
								frame;
							end
							delete_text(id_texto);

							id_texto=write(fuente[0],400,400,4,"Presiona izquierda y luego pulsa un boton");
					
							while(!get_joy_button(0) and !get_joy_button(1) 
							and !get_joy_button(2) and !get_joy_button(3)
							and !get_joy_button(4) and !get_joy_button(5)
							and !get_joy_button(6) and !get_joy_button(7)
							and !get_joy_button(8) and !get_joy_button(9)
							and !get_joy_button(10) and !get_joy_button(11))
								ops.gamepad.izquierda=get_joy_position(0);
								frame;
							end
							while(get_joy_button(0) or get_joy_button(1) 
							or get_joy_button(2) or get_joy_button(3)
							or get_joy_button(4) or get_joy_button(5)
							or get_joy_button(6) or get_joy_button(7)
							or get_joy_button(8) or get_joy_button(9)
							or get_joy_button(10) or get_joy_button(11))
								frame;
							end
							delete_text(id_texto);
---------------------------------------------------------	*/
							id_texto=write(fuente[0],ancho_pantalla/2,400,4,"Pulsa un boton para disparar");
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

							id_texto=write(fuente[0],ancho_pantalla/2,400,4,"Pulsa un boton para disparar una bomba");
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

							id_texto=write(fuente[0],ancho_pantalla/2,400,4,"Pulsa un boton para cambiar arma");
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
			end
		end
		if(p[0].botones[4] and volver_a_menu!=num_menu)
			delete_text(all_text);
			
			suena(s_aceptar);
			
			while(p[0].botones[5]) scroll.x0+=3; frame; end
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
	loop
		if(opcion==a)
			graph=10;
			id_texto=write(fuente[0],x,y,4,texto);
		else
			graph=11;
			id_texto=write(fuente[0],x,y,4,texto);
		end
		frame;
		delete_text(id_texto);
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
	graph=4;
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	while(not p[0].botones[5])
		scroll.x0+=3;
		frame;
	end
	while(p[0].botones[5])
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
// proceso highscores
//-----------------------------------------------------------------------

process highscores(nuevo_j1,nuevo_j2,nuevo_j3,nuevo_j4);

private
	a;
	nueva_puntuacion[5];
	nuevo_aspirante[5]=0,-1,-1,-1,-1;

begin
	let_me_alone();
	delete_text(all_text);
	
	fuente_teclado=fuente[0];
	nueva_puntuacion[1]=nuevo_j1;
	nueva_puntuacion[2]=nuevo_j2;
	nueva_puntuacion[3]=nuevo_j3;
	nueva_puntuacion[4]=nuevo_j4;
	
	from jugador=1 to jugadores;
		from a=0 to 9;
			if(nueva_puntuacion[jugador]>=save.puntuacion[a])
				save.puntuacion[a-1]=save.puntuacion[a];
				save.nombres[a-1]=save.nombres[a];
				save.puntuacion[a]=nueva_puntuacion[jugador];
				save.nombres[a]="";
				nuevo_aspirante[jugador]=a;
			end
		end
		from a=jugador to 1 step -1;
			if(nueva_puntuacion[a]>=nueva_puntuacion[a-1])
				nuevo_aspirante[a-1]-=1;
			end
		end
	end
	
	from jugador=1 to jugadores;
		if(nuevo_aspirante[jugador]>-1)
			nueva_puntuacion[jugador]=1;
		else	
			nueva_puntuacion[jugador]=0;
		end
	end
	
	if(nuevo_aspirante[1]>-1 or nuevo_aspirante[2]>-1 or nuevo_aspirante[3]>-1 or nuevo_aspirante[4]>-1)
		write(fuente[0],ancho_pantalla/2,70,4,"¡Nuevo record! Introduce tu nombre");
		text_input(ancho_pantalla/2,400,15,nueva_puntuacion[1],nueva_puntuacion[2],nueva_puntuacion[3],nueva_puntuacion[4]);
		loop
			if(!exists(TYPE text_input)) break; end
			scroll.x0+=3;
			frame;
		end
		from jugador=1 to jugadores;
			if(nuevo_aspirante[jugador]>-1)
				save.nombres[nuevo_aspirante[jugador]]=texto_introducido[jugador];
			end
		end
		if(guardar)
			archivo=fopen(savegamedir+"save.dat",o_write);
			fwrite(archivo,save);
			fclose(archivo);
		end
		highscores(0,0,0,0);
	else
		x=ancho_pantalla/2;
		write(fuente[0],x,150,4,"Clasificación");
		
		timer[2]=0;
		while(timer[2]<50)
			scroll.x0+=3;
			frame;
		end
		
		
		y=500;
		from a=0 to 9;
			write(fuente[0],x-150,y,3,10-a + "º " + save.nombres[a]);
			write(fuente[0],x+150,y,5,save.puntuacion[a]);
			y-=30;
			scroll.x0+=3;
			timer[2]=0;
			while(timer[2]<50)
				scroll.x0+=3;
				frame;
			end
		end
		
		controlador(0);
		while(not p[0].botones[b_2])
			scroll.x0+=3;
			frame;
		end
		while(p[0].botones[b_2])
			scroll.x0+=3;
			frame;
		end
		menu(0);
	end
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
loop frame; end
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
	graph=new_map(ancho*2,alto*2,32);
	while(tiempo<frames)
		drawing_color(0);
		drawing_map(file,graph);
		draw_box(0,0,ancho*2,alto*2);
		from c=0 to a;
		//	map_put_pixel(file,graph,particula[c].pos_x+(ancho*2/2),particula[c].pos_y+(alto*2/2),particula[c].pixell);
		//	map_put_pixel(file,graph,particula[c].pos_x+(ancho*2/2)+1,particula[c].pos_y+(alto*2/2),particula[c].pixell);
		//	map_put_pixel(file,graph,particula[c].pos_x+(ancho*2/2),particula[c].pos_y+(alto*2/2)+1,particula[c].pixell);
		//	map_put_pixel(file,graph,particula[c].pos_x+(ancho*2/2)+1,particula[c].pos_y+(alto*2/2)+1,particula[c].pixell);
			
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
