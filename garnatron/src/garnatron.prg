//-----------------------------------------------------------------------
// TITULO: Garnatron
// AUTOR:  Carles Vicent
// FECHA:  19/02/05
//-----------------------------------------------------------------------

PROGRAM space2;

Global

pausa;
distancia;

id_nave;

vidas=3;
escudo=5;
poder=1;
fuerza=1;
energia=20;
habil=1;


struct opciones;
	struct teclado;	//controles teclado
		arriba;		
		derecha;
		abajo;
		izquierda;
		disparar1;
		disparar2;
		cambiar_sig;
		cambiar_ant;
		pausa;
		salir;
	end
	struct gamepad	//controles gamepad
		arriba;		
		derecha;
		abajo;
		izquierda;
		disparar1;
		disparar2;
		cambiar_sig;
		cambiar_ant;
		pausa;
		salir;
	end
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
		nivel1;
		vidas1;
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
      
fuente1;
fuente2;

s_disparo;
s_laser1;
s_laser2;
s_laser3;
s_misil;
s_explosion;
s_explosion_grande;

s_aceptar;
s_mover;
s_cancelar;

archivo;

disparos_sonando;

string savegamedir;
string developerpath="/.PiXJuegos/Garnatron/";


Local
	estado;
	patron;
	id_texto;
	i,j; //para controles.pr-

//-----------------------------------------------------------------------
// introduccion del juego
//-----------------------------------------------------------------------


BEGIN
set_fps(40,0);

if(!mode_is_ok(800,600,32,MODE_FULLSCREEN))
	scale_resolution=06400480; //compatible con Wii
	if(!mode_is_ok(640,480,32,MODE_FULLSCREEN))
		scale_resolution=03200240; //compatible con GP2X
	end
end
set_mode(800,600,32,WAITVSYNC);

dump_type=-1;
restore_type=-1;
ALPHA_STEPS=128;

file=fpg_menu;
graph=1;
x=400;
y=300;
z=10;

frame;
fpg_menu=load_fpg("./fpg/menu.fpg"); frame;
fpg_nave=load_fpg("./fpg/nave.fpg"); frame;
fpg_bombas=load_fpg("./fpg/bombas.fpg"); frame;
fpg_enemigos=load_fpg("./fpg/enemigos.fpg"); frame;
fpg_bosses=load_fpg("./fpg/bosses.fpg"); frame;
fpg_explosiones=load_fpg("./fpg/explosiones.fpg"); frame;

s_disparo=load_wav("./wav/laser.wav"); frame;
s_laser1=load_wav("./wav/laser9.wav"); frame;
s_laser2=load_wav("./wav/onda01.wav"); frame;
s_laser3=load_wav("./wav/laser6.wav"); frame;
s_misil=load_wav("./wav/bomba5.wav"); frame;
s_explosion=load_wav("./wav/explos.wav"); frame;
s_explosion_grande=load_wav("./wav/explosg.wav"); frame;

fuente1=load_fnt(".\fnt\fuente.fnt"); frame;




	opciones.teclado.arriba=72;
	opciones.teclado.derecha=77;
	opciones.teclado.abajo=80;
	opciones.teclado.izquierda=75;
	opciones.teclado.disparar1=31;
	opciones.teclado.disparar2=17;
	opciones.teclado.cambiar_sig=32;
	opciones.teclado.cambiar_ant=30;
	opciones.teclado.pausa=28;
	opciones.teclado.salir=1;

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
	
	if(file_exists(savegamedir+"opciones.dat"))
		archivo=fopen(savegamedir+"opciones.dat",o_read);
		fread(archivo,opciones);
		fclose(archivo);
	end

	save.nivel1=1;
	save.vidas1=3;

	if(file_exists(savegamedir+"save.dat"))
		archivo=fopen(savegamedir+"save.dat",o_read);
		fread(archivo,save);
		fclose(archivo);
	end

frame;

//select_joy(0);
configurar_controles();

start_scroll(0,fpg_menu,7,8,1,15); //numero,file,grafico,fondo,region,loop
musica(1);
graph=2;

from alpha=0 to 255 step 10; frame; end
timer[2]=0;

while(timer[2]<200)
	if(scan_code)
		break;
	end
	frame;
end

from alpha=255 to 0 step -10; frame; end

clear_screen();
historia(1);
//(juego(4);
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
	define_region(1,0,75,800,450);
	fade_on();
	timer[2]=0;
	
	escapable();
	
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

		letra("PiX Juegos  presenta",400,300,4);
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
		
		pausa=1;
		id_nave=nave01(-100,300);
		id_nave.angle=-90000;
		while(id_nave.x<100)
			id_nave.x+=2;
			scroll.x0+=3;
			frame;
		end
	
		letra("Autores",160,120,1);
		timer[2]=0;
		while(timer[2]<600)
			if(id_nave.x<320) id_nave.x+=1; end
			scroll.x0+=3;
			frame;
		end
	
		letra("Programado por",480,120,3);
		letra("Carles Vicent",480,150,3);
		timer[2]=0;
		while(timer[2]<400)
			if(id_nave.x<320) id_nave.x+=1; end
			scroll.x0+=3;
			frame;
		end
	
		letra("Ayudante",480,360,0);
		letra("PiXeL",480,390,0);
		timer[2]=0;
		while(timer[2]<400)
			scroll.x0+=3;
			frame;
		end
	
		letra("Graficos",160,360,2);
		letra("Carles Vicent",160,390,2);
		letra("DaniGM",160,420,2);
	
		timer[2]=0;
		while(timer[2]<400)
			scroll.x0+=3;
			frame;
		end

		letra("Sonido",480,120,3);
		letra("no me acuerdo",480,150,3);
		timer[2]=0;
		while(timer[2]<400)
			scroll.x0+=3;
			frame;
		end
	
		letra("Musica",480,360,0);
		letra("Danner",480,390,0);
		timer[2]=0;
		while(timer[2]<400)
			scroll.x0+=3;
			frame;
		end
		
		letra("Gracias a:",160,120,1);
		letra("Nicolas",160,150,1);
		letra("Gnomwer",160,180,1);
		letra("Ana",160,210,1);	
		timer[2]=0;
		while(timer[2]<400)
			scroll.x0+=3;
			frame;
		end

		letra("Hecho en Bennu",480,120,3);
		timer[2]=0;
		while(timer[2]<400)
			scroll.x0+=3;
			frame;
		end

		letra("Creado por PiX Juegos",480,360,0);
		timer[2]=0;
		while(timer[2]<600)
			if(id_nave.x<850) id_nave.x+=1; end
			scroll.x0+=3;
			frame;
		end

		letra("Gracias por jugar",400,300,4);
		timer[2]=0;
		while(timer[2]<600)
			if(id_nave.x<850) id_nave.x+=2; end
			scroll.x0+=3;
			frame;
		end

		delete_text(all_text);
		menu(0);
	end

end

process escapable();
Begin
	controlador(0);
	loop
		if(p[0].botones[7]) while(p[0].botones[7]) frame; end menu(0); end
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
	id_texto=write(fuente1,texto_x,texto_y,4,texto);
	Frame;        
	If(lao==1) texto_x+=1; end
	if(lao==0) texto_x-=1; End
	if(lao==2) texto_y-=1; End
	if(lao==3) texto_y+=1; End

	delete_text(id_texto);
	Until(timercred=>145)
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
	reinicio_variables();
	file=fpg_menu;

	define_region(1,0,0,800,600);

	objeto(400,75,9,file,100,16);
	sombra(9,400,75,file,2);
	
	
	controlador(0);
//	musica(1);

	z=-20;
	graph=6;
	x=120;
	y=100;
	
	//ponemos el menú actual
	switch(num_menu)
		case 0: //general
			write(fuente1,x,y+=60,3,"Jugar");
			write(fuente1,x,y+=60,3,"Continuar");
			write(fuente1,x,y+=60,3,"Opciones");
			write(fuente1,x,y+=60,3,"Ayuda");
			write(fuente1,x,y+=60,3,"Creditos");
			write(fuente1,x,y+=60,3,"Salir");
			num_opciones=6;
			volver_a_menu=0;
		end
		case 1: //opciones
			write(fuente1,x,y+=60,3,"Video");
			write(fuente1,x,y+=60,3,"Control");
			write(fuente1,x,y+=60,3,"Volver");
			num_opciones=3;
			volver_a_menu=0;
		end
		case 2: //video
			write(fuente1,x,y+=60,3,"Pantalla completa");
			write(fuente1,x,y+=60,3,"Ventana");
			write(fuente1,x,y+=60,3,"Volver");
			num_opciones=3;
			volver_a_menu=0;
		end
		case 3: //control
			write(fuente1,x,y+=60,3,"Teclado");
			write(fuente1,x,y+=60,3,"Mando");
			write(fuente1,x,y+=60,3,"Volver");
			num_opciones=3;
			volver_a_menu=0;
		end
	end
	
	x=70;
	y=800;
	
	loop
		if(opcion_actual>num_opciones) opcion_actual=1;	end
		if(opcion_actual<1)	opcion_actual=num_opciones;	end
		
		scroll.x0+=3;
		
		y_objetivo=100+(opcion_actual*60);
		if(y!=y_objetivo) y+=(y_objetivo-y)/2; end

		if(p[0].botones[4])
			
			suena(s_aceptar);
			
			while(p[0].botones[4]) frame; end
			switch(num_menu)
				case 0: //general
					switch(opcion_actual)
						case 1:
							vidas=3;
							juego(1);
						end
						case 2:
							vidas=save.vidas1;
							juego(save.nivel1);
						end
						case 3:
							menu(1);
						end
						case 4: 
							//ayuda();
						end
						case 5:
							historia(2);
						end
						case 6:
							archivo=fopen(savegamedir+"opciones.dat", O_WRITE);
							fwrite(archivo,opciones);
							fclose(archivo);
							exit();
						end
					end
				end
				case 1: //opciones
					switch(opcion_actual)
						case 1:
							menu(2);
						end
						case 2:
							menu(3);
						end
						case 3:
							menu(0);
						end
					end
				end
				case 2: //video
					switch(opcion_actual)
						case 1: 
							full_screen=true;
							set_mode(800,600,32);
						end
						case 2: 
							full_screen=false;
							set_mode(800,600,32);
						end
						case 3:
							menu(1);
						end
					end
				end
				case 3: //control
					switch(opcion_actual)
						case 1: 
							
							id_texto=write(fuente1,400,400,4,"Pulse tecla para arriba");
							repeat
								opciones.teclado.arriba=scan_code;
								frame;
							until(opciones.teclado.arriba<>0);
							while(scan_code<>0) frame; end
							delete_text(id_texto);
	
							id_texto=write(fuente1,400,400,4,"Pulse una tecla para derecha");
							Repeat
								opciones.teclado.derecha=scan_code;
								frame;
							until(opciones.teclado.derecha<>0);
							while(scan_code<>0) frame; end
							delete_text(id_texto);

							id_texto=write(fuente1,400,400,4,"Pulse una tecla para abajo");
							Repeat
								opciones.teclado.abajo=scan_code;
								frame;
							until(opciones.teclado.abajo<>0);
							while(scan_code<>0) frame; end
							delete_text(id_texto);
	
							id_texto=write(fuente1,400,400,4,"Pulse una tecla para izquierda");
							Repeat
								opciones.teclado.izquierda=scan_code;
								frame;
							until(opciones.teclado.izquierda<>0);
							while(scan_code<>0) frame; end
							delete_text(id_texto);
	
							id_texto=write(fuente1,400,400,4,"Pulse una tecla para diparar");
							Repeat
								opciones.teclado.disparar1=scan_code;
								frame;
							until(opciones.teclado.disparar1<>0);
							while(scan_code<>0) frame; end
							delete_text(id_texto);

							id_texto=write(fuente1,400,400,4,"Pulse una tecla para disparar una bomba");
							Repeat
								opciones.teclado.disparar2=scan_code;
								frame;
							until(opciones.teclado.disparar2<>0);
							while(scan_code<>0) frame; end
							delete_text(id_texto);

							id_texto=write(fuente1,400,400,4,"Pulse una tecla para cambiar arma siguiente");
							Repeat
								opciones.teclado.cambiar_sig=scan_code;
								frame;
							until(opciones.teclado.cambiar_sig<>0);
							while(scan_code<>0) frame; end
							delete_text(id_texto);

							id_texto=write(fuente1,400,400,4,"Pulse una tecla para cambiar arma anterior");
							Repeat
								opciones.teclado.cambiar_ant=scan_code;
								frame;
							until(opciones.teclado.cambiar_ant<>0);
							while(scan_code<>0) frame; end
							delete_text(id_texto);

							id_texto=write(fuente1,400,400,4,"Pulse una tecla para pausa");
							Repeat
								opciones.teclado.pausa=scan_code;
								frame;
							until(opciones.teclado.pausa<>0);
							while(scan_code<>0) frame; end
							delete_text(id_texto);

							id_texto=write(fuente1,400,400,4,"Pulse una tecla para salir");
							Repeat
								opciones.teclado.salir=scan_code;
								frame;
							until(opciones.teclado.salir<>0);
							while(scan_code<>0) frame; end
							delete_text(id_texto);

							frame;
							
							archivo=fopen(savegamedir+"opciones.dat", O_WRITE);
							fwrite(archivo,opciones);
							fclose(archivo);
							
						end
						case 2: 
							select_joy(0);
							frame;
							id_texto=write(fuente1,400,400,4,"Presiona arriba y luego pulsa un boton");

							while(!get_joy_button(0) and !get_joy_button(1) 
							and !get_joy_button(2) and !get_joy_button(3)
							and !get_joy_button(4) and !get_joy_button(5)
							and !get_joy_button(6) and !get_joy_button(7)
							and !get_joy_button(8) and !get_joy_button(9)
							and !get_joy_button(10) and !get_joy_button(11)) 
								opciones.gamepad.arriba=get_joy_position(1);
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

							id_texto=write(fuente1,400,400,4,"Presiona derecha y luego pulsa un boton");

							while(!get_joy_button(0) and !get_joy_button(1) 
							and !get_joy_button(2) and !get_joy_button(3)
							and !get_joy_button(4) and !get_joy_button(5)
							and !get_joy_button(6) and !get_joy_button(7)
							and !get_joy_button(8) and !get_joy_button(9)
							and !get_joy_button(10) and !get_joy_button(11))

								opciones.gamepad.derecha=get_joy_position(0);
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

							id_texto=write(fuente1,400,400,4,"Presiona abajo y luego pulsa un boton");

							while(!get_joy_button(0) and !get_joy_button(1) 
							and !get_joy_button(2) and !get_joy_button(3)
							and !get_joy_button(4) and !get_joy_button(5)
							and !get_joy_button(6) and !get_joy_button(7)
							and !get_joy_button(8) and !get_joy_button(9)
							and !get_joy_button(10) and !get_joy_button(11))
								opciones.gamepad.abajo=get_joy_position(1);
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

							id_texto=write(fuente1,400,400,4,"Presiona izquierda y luego pulsa un boton");
					
							while(!get_joy_button(0) and !get_joy_button(1) 
							and !get_joy_button(2) and !get_joy_button(3)
							and !get_joy_button(4) and !get_joy_button(5)
							and !get_joy_button(6) and !get_joy_button(7)
							and !get_joy_button(8) and !get_joy_button(9)
							and !get_joy_button(10) and !get_joy_button(11))
								opciones.gamepad.izquierda=get_joy_position(0);
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

							id_texto=write(fuente1,400,400,4,"Pulsa un boton para disparar");
							opciones.gamepad.disparar1=0;
							repeat
								from a=0 to 11;
									if(get_joy_button(a))
										opciones.gamepad.disparar1=a;
										break;
									end
								end
								frame;
							until(get_joy_button(opciones.gamepad.disparar1));
							while(get_joy_button(opciones.gamepad.disparar1))
								frame;
							end
							delete_text(id_texto);

							id_texto=write(fuente1,400,400,4,"Pulsa un boton para disparar una bomba");
							opciones.gamepad.disparar2=0;
							repeat
								from a=0 to 11;
									if(get_joy_button(a))
										opciones.gamepad.disparar2=a;
										break;
									end
								end
								frame;
							until(get_joy_button(opciones.gamepad.disparar2));
							while(get_joy_button(opciones.gamepad.disparar2))
								frame;
							end
							delete_text(id_texto);

							id_texto=write(fuente1,400,400,4,"Pulsa un boton para cambiar arma siguiente");
							opciones.gamepad.cambiar_sig=0;
							repeat
								from a=0 to 11;
									if(get_joy_button(a))
										opciones.gamepad.cambiar_sig=a;
										break;
									end
								end
								frame;
							until(get_joy_button(opciones.gamepad.cambiar_sig));
							while(get_joy_button(opciones.gamepad.cambiar_sig))
								frame;
							end
							delete_text(id_texto);

							id_texto=write(fuente1,400,400,4,"Pulsa un boton para cambiar arma anterior");
							opciones.gamepad.cambiar_ant=0;
							repeat
								from a=0 to 11;
									if(get_joy_button(a))
										opciones.gamepad.cambiar_ant=a;
										break;
									end
								end
								frame;
							until(get_joy_button(opciones.gamepad.cambiar_ant));
							while(get_joy_button(opciones.gamepad.cambiar_ant))
								frame;
							end
							delete_text(id_texto);

							id_texto=write(fuente1,400,400,4,"Pulsa un boton para pausa");
							opciones.gamepad.pausa=0;
							repeat
								from a=0 to 11;
									if(get_joy_button(a))
										opciones.gamepad.pausa=a;
										break;
									end
								end
								frame;
							until(get_joy_button(opciones.gamepad.pausa));
							while(get_joy_button(opciones.gamepad.pausa))
								frame;
							end
							delete_text(id_texto);

							id_texto=write(fuente1,400,400,4,"Pulsa un boton para salir");
							opciones.gamepad.salir=0;
							repeat
								from a=0 to 11;
									if(get_joy_button(a))
										opciones.gamepad.salir=a;
										break;
									end
								end
								frame;
							until(get_joy_button(opciones.gamepad.salir));
							while(get_joy_button(opciones.gamepad.salir))
								frame;
							end
							delete_text(id_texto);

							frame;
							
							archivo=fopen(savegamedir+"opciones.dat", O_WRITE);
							fwrite(archivo,opciones);
							fclose(archivo);
						end
						case 3:
							menu(1);
						end
						
					end
				end
			end
		end
		if(p[0].botones[5] and volver_a_menu!=num_menu)
			delete_text(all_text);
			
			suena(s_aceptar);
			
			while(p[0].botones[4]) frame; end
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

process lista(graph);
begin
	file=fpg_menu;
	x=-200;
	y=300;
	z=-10;
	loop
		x+=(x-200)/-10;
		frame;
	end
end

process logo(graph);
begin
	file=fpg_menu;
	x=1200;
	y=300;
	z=-10;
	loop
		x+=(x-500)/-10;
		frame;
	end
end

function reinicio_variables();
begin
	delete_text(all_text);
end

//-----------------------------------------------------------------------
// proceso que crea un boton
//-----------------------------------------------------------------------

process boton(x,y,string texto,int a);

begin
	file=fpg_menu;
	size_x=300;
	z=-100;
	loop
		if(opcion==a)
			graph=20;
			id_texto=write(fuente1,x,y,4,texto);
		else
			graph=44;
			id_texto=write(fuente1,x,y,4,texto);
		end
		frame;
		delete_text(id_texto);
	end
end

//-----------------------------------------------------------------------
// proceso que crea un efecto
//-----------------------------------------------------------------------

process sombra(graph,x,y,file,cosa);
begin

z=-10;
if(cosa==1)	//alarma
	from size = 20 to 150 step 10;
		angle+=30000;
    	frame;
	end
end
if(cosa==2)	//titulo
	angle=father.angle;
	from alpha=255 to 0 step -20;
	//	if(exists(father))
	//		x=father.x;
	//		y=father.y;
			size+=3;
	//	end
    		frame;
	end
end
if(cosa==3) //destello
	z=-90;
    	frame(700);
end
if(cosa==4) //laser3
	flags=4;
	from size = 100 to 500 step 20;
	alpha--;
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
// controla el juego
//-----------------------------------------------------------------------

process juego(nivel);

private

gatillo;
id_texto1;
id_texto2;
direccion=1;
jefe;
n;

Begin
file=fpg_menu;
fade_off();
delete_text(all_text);
let_me_alone();
x=400;
y=300;
z=-100;


	save.nivel1=nivel;
	save.vidas1=vidas;


archivo=fopen(savegamedir+"save.dat",o_write);
fwrite(archivo,save);
fclose(archivo);

ctype=c_screen;
define_region(1,0,0,800,600);
pausa=1;
n=1;
energia=20;
escudo=5;
opcion=0;
distancia=0;

if(nivel==1)
	musica(1);
	graph=20;
	direccion=1;
	size=200;
	id_texto=write(fuente1,x,y,4,"AREA: 1");
	fade_on();
	timer[2]=0;
	while(timer[2]<300)
		if(direccion==1) graph++; else graph--; end
		if(graph==20) direccion=1; end
		if(graph==44) direccion=0; end
		scroll.y0-=5;
		frame;
	end
	delete_text(id_texto);
	graph=0;
	id_nave=nave01(400,700);
	poder=1;
	fuerza=1;
	marcador();
	while(id_nave.y>300)
		id_nave.y-=10;
		scroll.y0-=5;
		frame;
	end
	while(id_nave.y<550)
		id_nave.y+=10;
		scroll.y0-=5;
		frame;
	end
	pausa=0;
	LOOP



		if(p[0].botones[7] and gatillo==0)
			gatillo=1;
			if(pausa==0)
				pausa=1;
				graph=20;
				size=300;
				direccion=1;
				id_texto=write(fuente1,x,y,4,"¿Salir de la partida?");
				boton(400,500,"",1);
				id_texto1=write(fuente1,400,500,4,"No");
				boton(400,550,"",2);
				id_texto2=write(fuente1,400,550,4,"Si");
				opcion=1;
			else
				pausa=0;
				graph=0;;
				delete_text(id_texto);
				signal(type boton,s_kill);
				delete_text(0);
			end
		end

		if(not p[0].botones[7] and not p[0].botones[2] and not p[0].botones[3] and gatillo==1) gatillo=0; end

		if(pausa==1)
				
			if(direccion==1) graph++; else graph--; end
			if(graph==20) direccion=1; end
			if(graph==44) direccion=0; end
			if(p[0].botones[2] and gatillo==0 and opcion>1)
				gatillo=1;
				opcion--;
			end
			if(p[0].botones[3] and gatillo==0 and opcion<2)
				gatillo=1;
				opcion++;
			end
			if(p[0].botones[4])
				if(opcion==1) opcion=0; pausa=0; graph=0; delete_text(id_texto); delete_text(id_texto1); delete_text(id_texto2); signal(type boton,s_kill); end
				if(opcion==2) opcion=0; while(p[0].botones[4]) frame; end menu(0); break; end
			end

		end
		if(pausa==0)
			scroll.y0-=5;
			if(distancia<4000) distancia++; end
			if(distancia==100*n)
				if(n==1 or n==19)
					enemigo(50,-50,1,0);
					enemigo(110,-60,1,0);
					enemigo(50,-150,1,0);
					enemigo(110,-160,1,0);
				end
				if(n==2 or n==20)
					enemigo(750,-50,1,0);
					enemigo(690,-60,1,0);
					enemigo(750,-150,1,0);
					enemigo(690,-160,1,0);
				end
				if(n==3 or n==21)
					enemigo(50,-50,2,8);
					enemigo(750,-50,2,1);
				end
				if(n==4 or n==22)
					enemigo(360,-50,2,1);
					enemigo(440,-50,2,8);
				end
				if(n==5 or n==23)
					enemigo(70,-50,1,1);
					enemigo(130,-60,1,1);
					enemigo(70,-150,1,0);
					enemigo(130,-160,1,0);
				end
				if(n==6 or n==24)
					enemigo(730,-50,1,1);
					enemigo(670,-60,1,1);
					enemigo(730,-150,1,0);
					enemigo(670,-160,1,0);
				end
				if(n==7 or n==25)
					enemigo(360,-50,2,1);
					enemigo(440,-50,2,8);
				end
				if(n==8 or n==26)
					enemigo(50,-50,2,8);
					enemigo(750,-50,2,1);
				end
				if(n==9 or n==27)
					enemigo(70,-100,1,1);
					enemigo(130,-40,1,1);
					enemigo(190,-100,1,1);
				end
				if(n==10 or n==28)
					enemigo(730,-100,1,1);
					enemigo(670,-40,1,1);
					enemigo(610,-100,1,1);
				end
				if(n==11 or n==29)
					enemigo(70,-50,2,12);
					enemigo(130,-50,2,12);
				end
				if(n==12 or n==30)
					enemigo(730,-50,2,5);
					enemigo(670,-50,2,5);
				end
				if(n==13 or n==31)
					enemigo(70,-50,2,12);
					enemigo(130,-50,2,12);
				end
				if(n==14 or n==32)
					enemigo(730,-50,2,5);
					enemigo(670,-50,2,5);
				end
				if(n==15 or n==33)
					enemigo(70,-80,1,1);
					enemigo(130,-60,1,0);
					enemigo(190,-40,1,1);
					enemigo(610,-40,1,1);
					enemigo(670,-60,1,0);
					enemigo(730,-80,1,1);
				end
				if(n==16 or n==34)
					mina(120,-50,2);
					mina(240,-50,2);
					mina(360,-50,2);
					mina(480,-50,2);
					mina(600,-50,2);
				end
				if(n==18 or n==36)
					mina(100,-50,2);
					mina(250,-50,2);
					mina(400,-50,2);
					mina(550,-50,2);
					mina(700,-50,2);
				end
				if(n==7) bono(400,-50,3); end
				if(n==17) bono(400,-50,2); end
				if(n==27) bono(400,-50,1); end
				if(n==37) bono(400,-50,2); end
				if(n==38 and jefe==0) jefe=1; musica(2); id_boss01=boss(1); end
			n++;
			end
			if(jefe==1 and vida_boss<1) 
				graph=20;
				direccion=1;
				size=200;
				id_texto=write(fuente1,x,y,4,"AREA: 1");
				id_texto1=write(fuente1,x-5,y+15,4,"completada");
				timer[2]=0;
				while(timer[2]<500)
					if(direccion==1) graph++; else graph--; end
					if(graph==20) direccion=1; end
					if(graph==44) direccion=0; end
					scroll.y0-=5;
					frame;
				end
				juego(2);
				break;
			end
			if(vidas<0)
				delete_text(all_text);
				signal(id_nave,s_kill);
				graph=20;
				direccion=1;
				size=200;
				id_texto=write(fuente1,x,y,4,"Fin de");
				id_texto1=write(fuente1,x-5,y+15,4,"la partida");
				timer[2]=0;
				while(timer[2]<500)
					if(direccion==1) graph++; else graph--; end
					if(graph==20) direccion=1; end
					if(graph==44) direccion=0; end
					scroll.y0-=5;
					frame;
				end
			menu(0);
			break;
			end
		end
	FRAME;
END
end

if(nivel==2)
	musica(1);
	graph=20;
	direccion=1;
	size=200;
	id_texto=write(fuente1,x,y,4,"AREA: 2");
	fade_on();
	timer[2]=0;
	while(timer[2]<300)
		if(direccion==1) graph++; else graph--; end
		if(graph==20) direccion=1; end
		if(graph==44) direccion=0; end
		scroll.y0-=5;
		frame;
	end
	delete_text(id_texto);
	graph=0;
	id_nave=nave01(400,700);
	fuerza=2;
	marcador();
	while(id_nave.y>300)
		id_nave.y-=10;
		scroll.y0-=5;
		frame;
	end
	while(id_nave.y<550)
		id_nave.y+=10;
		scroll.y0-=5;
		frame;
	end
	pausa=0;
	LOOP



		if(p[0].botones[7] and gatillo==0)
			gatillo=1;
			if(pausa==0)
				pausa=1;
				graph=20;
				size=300;
				direccion=1;
				id_texto=write(fuente1,x,y,4,"¿Salir de la partida?");
				boton(400,500,"",1);
				id_texto1=write(fuente1,400,500,4,"No");
				boton(400,550,"",2);
				id_texto2=write(fuente1,400,550,4,"Si");
				opcion=1;
			else
				pausa=0;
				graph=0;;
				delete_text(id_texto);
				signal(type boton,s_kill);
				delete_text(0);
			end
		end

		if(not p[0].botones[7] and not p[0].botones[2] and not p[0].botones[3] and gatillo==1) gatillo=0; end

		if(pausa==1)
				
			if(direccion==1) graph++; else graph--; end
			if(graph==20) direccion=1; end
			if(graph==44) direccion=0; end
			if(p[0].botones[2] and gatillo==0 and opcion>1)
				gatillo=1;
				opcion--;
			end
			if(p[0].botones[3] and gatillo==0 and opcion<2)
				gatillo=1;
				opcion++;
			end
			if(p[0].botones[4])
				if(opcion==1) opcion=0; pausa=0; graph=0; delete_text(id_texto); delete_text(id_texto1); delete_text(id_texto2); signal(type boton,s_kill); end
				if(opcion==2) opcion=0; while(p[0].botones[4]) frame; end menu(0); break; end
			end

		end
		if(pausa==0)
			scroll.y0-=5;
			if(distancia<4000) distancia++; end
			if(distancia==100*n)
				if(n==1 or n==19)
					enemigo(50,-50,2,8);
					enemigo(750,-50,2,1);
				end
				if(n==2 or n==20)
					enemigo(360,-50,2,1);
					enemigo(440,-50,2,8);
				end
				if(n==3 or n==21)
					enemigo(200,-50,3,0);
				end
				if(n==4 or n==22)
					enemigo(600,-50,3,0);
				end
				if(n==5 or n==23)
					enemigo(70,-50,2,12);
					enemigo(130,-50,2,12);
				end
				if(n==6 or n==24)
					enemigo(730,-50,2,5);
					enemigo(670,-50,2,5);
				end
				if(n==7 or n==25)
					enemigo(70,-50,2,12);
					enemigo(130,-50,2,12);
				end
				if(n==8 or n==26)
					enemigo(730,-50,2,5);
					enemigo(670,-50,2,5);
				end
				if(n==10 or n==28)
					enemigo(70,-80,1,1);
					enemigo(130,-60,1,1);
					enemigo(190,-40,1,1);
					enemigo(610,-40,1,1);
					enemigo(670,-60,1,1);
					enemigo(730,-80,1,1);
				end
				if(n==11 or n==29)
					enemigo(50,-50,2,7);
					enemigo(750,-50,2,14);
				end
				if(n==12 or n==30)
					enemigo(360,-50,2,14);
					enemigo(440,-50,2,7);
				end
				if(n==13 or n==31)
					enemigo(50,-50,2,7);
					enemigo(750,-50,2,14);
				end
				if(n==15 or n==33)
					enemigo(200,-50,3,0);
				end
				if(n==16 or n==34)
					enemigo(600,-50,3,0);
				end
				if(n==17 or n==35)
					enemigo(200,-50,3,0);
				end
				if(n==18 or n==36)
					enemigo(600,-50,3,0);
				end
				if(n==7) bono(400,-50,3); end
				if(n==17) bono(400,-50,2); end
				if(n==27) bono(400,-50,1); end
				if(n==37) bono(400,-50,2); end
				if(n==38 and jefe==0) jefe=1; musica(2); id_boss01=boss(2); end
			n++;
			end
			if(jefe==1 and vida_boss<1) 
				graph=20;
				direccion=1;
				size=200;
				id_texto=write(fuente1,x,y,4,"AREA: 2");
				id_texto1=write(fuente1,x-5,y+15,4,"completada");
				timer[2]=0;
				while(timer[2]<500)
					if(direccion==1) graph++; else graph--; end
					if(graph==20) direccion=1; end
					if(graph==44) direccion=0; end
					scroll.y0-=5;
					frame;
				end
				juego(3);
				break;
			end	
			if(vidas<0)
				delete_text(all_text);
				signal(id_nave,s_kill);
				graph=20;
				direccion=1;
				size=200;
				id_texto=write(fuente1,x,y,4,"Fin de");
				id_texto1=write(fuente1,x-5,y+15,4,"la partida");
				timer[2]=0;
				while(timer[2]<500)
					if(direccion==1) graph++; else graph--; end
					if(graph==20) direccion=1; end
					if(graph==44) direccion=0; end
					scroll.y0-=5;
					frame;
				end
			menu(0);
			break;
			end
		end
	FRAME;
END
end

if(nivel==3)
	musica(1);
	graph=20;
	direccion=1;
	size=200;
	id_texto=write(fuente1,x,y,4,"AREA: 3");
	fade_on();
	timer[2]=0;
	while(timer[2]<300)
		if(direccion==1) graph++; else graph--; end
		if(graph==20) direccion=1; end
		if(graph==44) direccion=0; end
		scroll.y0-=5;
		frame;
	end
	delete_text(id_texto);
	graph=0;
	id_nave=nave01(400,700);
	fuerza=3;
	marcador();
	while(id_nave.y>300)
		id_nave.y-=10;
		scroll.y0-=5;
		frame;
	end
	while(id_nave.y<550)
		id_nave.y+=10;
		scroll.y0-=5;
		frame;
	end
	pausa=0;
	LOOP



		if(p[0].botones[7] and gatillo==0)
			gatillo=1;
			if(pausa==0)
				pausa=1;
				graph=20;
				size=300;
				direccion=1;
				id_texto=write(fuente1,x,y,4,"¿Salir de la partida?");
				boton(400,500,"",1);
				id_texto1=write(fuente1,400,500,4,"No");
				boton(400,550,"",2);
				id_texto2=write(fuente1,400,550,4,"Si");
				opcion=1;
			else
				pausa=0;
				graph=0;;
				delete_text(id_texto);
				signal(type boton,s_kill);
				delete_text(0);
			end
		end

		if(not p[0].botones[7] and not p[0].botones[2] and not p[0].botones[3] and gatillo==1) gatillo=0; end

		if(pausa==1)
				
			if(direccion==1) graph++; else graph--; end
			if(graph==20) direccion=1; end
			if(graph==44) direccion=0; end
			if(p[0].botones[2] and gatillo==0 and opcion>1)
				gatillo=1;
				opcion--;
			end
			if(p[0].botones[3] and gatillo==0 and opcion<2)
				gatillo=1;
				opcion++;
			end
			if(p[0].botones[4])
				if(opcion==1) opcion=0; pausa=0; graph=0; delete_text(id_texto); delete_text(id_texto1); delete_text(id_texto2); signal(type boton,s_kill); end
				if(opcion==2) opcion=0; while(p[0].botones[4]) frame; end menu(0); break; end
			end

		end
		if(pausa==0)
			scroll.y0-=5;
			if(distancia<4000) distancia++; end
			if(distancia==50*n)

				if(n>1 and n<7)

					asteroide(300,-100,50,290000,6);
					asteroide(400,-100,50,270000,7);
					asteroide(500,-100,50,250000,6);
					asteroide(600,-100,50,240000,5);
				end
				if(n>6 and n<12)
					asteroide(200,-100,100,300000,4);
					asteroide(300,-100,100,270000,5);
					asteroide(500,-100,100,250000,5);

				end
				if(n>11 and n<17)

					asteroide(500,-100,150,270000,5);
					asteroide(600,-100,150,240000,4);
				end
				if(n>16 and n<22)
					asteroide(200,-100,100,270000,6);
					asteroide(500,-100,100,290000,5);
					asteroide(600,-100,100,250000,6);
				end
				if(n>21 and n<37)

					asteroide(300,-100,50,290000,6);
					asteroide(400,-100,50,240000,5);
					asteroide(500,-100,50,250000,6);
					asteroide(600,-100,50,270000,7);
				end
				if(n==7) bono(400,-50,3); end
				if(n==17) bono(400,-50,2); end
				if(n==27) bono(400,-50,1); end
				if(n==37) bono(400,-50,2); end
				if(n==38 and jefe==0) jefe=1; musica(2); id_boss01=boss(3); end
			n++;
			end
			if(jefe==1 and vida_boss<1)
				timer[2]=0;
				while(timer[2]<100) frame; end 
				graph=20;
				direccion=1;
				size=200;
				id_texto=write(fuente1,x,y,4,"AREA: 3");
				id_texto1=write(fuente1,x-5,y+15,4,"completada");
				timer[2]=0;
				while(timer[2]<500)
					if(direccion==1) graph++; else graph--; end
					if(graph==20) direccion=1; end
					if(graph==44) direccion=0; end
					scroll.y0-=5;
					frame;
				end
				juego(4);
				break;
			end	
			if(vidas<0)
				delete_text(all_text);
				signal(id_nave,s_kill);
				graph=20;
				direccion=1;
				size=200;
				id_texto=write(fuente1,x,y,4,"Fin de");
				id_texto1=write(fuente1,x-5,y+15,4,"la partida");
				timer[2]=0;
				while(timer[2]<500)
					if(direccion==1) graph++; else graph--; end
					if(graph==20) direccion=1; end
					if(graph==44) direccion=0; end
					scroll.y0-=5;
					frame;
				end
			menu(0);
			break;
			end
		end
	FRAME;
END
end

if(nivel==4)
	musica(1);
	graph=20;
	direccion=1;
	size=200;
	id_texto=write(fuente1,x,y,4,"AREA: 4");
	fade_on();
	timer[2]=0;
	while(timer[2]<300)
		if(direccion==1) graph++; else graph--; end
		if(graph==20) direccion=1; end
		if(graph==44) direccion=0; end
		scroll.y0-=5;
		frame;
	end
	delete_text(id_texto);
	graph=0;
	id_nave=nave01(400,700);
	fuerza=4;
	marcador();
	while(id_nave.y>300)
		id_nave.y-=10;
		scroll.y0-=5;
		frame;
	end
	while(id_nave.y<550)
		id_nave.y+=10;
		scroll.y0-=5;
		frame;
	end
	pausa=0;
	LOOP



		if(p[0].botones[7] and gatillo==0)
			gatillo=1;
			if(pausa==0)
				pausa=1;
				graph=20;
				size=300;
				direccion=1;
				id_texto=write(fuente1,x,y,4,"¿Salir de la partida?");
				boton(400,500,"",1);
				id_texto1=write(fuente1,400,500,4,"No");
				boton(400,550,"",2);
				id_texto2=write(fuente1,400,550,4,"Si");
				opcion=1;
			else
				pausa=0;
				graph=0;;
				delete_text(id_texto);
				signal(type boton,s_kill);
				delete_text(0);
			end
		end

		if(not p[0].botones[7] and not p[0].botones[2] and not p[0].botones[3] and gatillo==1) gatillo=0; end

		if(pausa==1)
				
			if(direccion==1) graph++; else graph--; end
			if(graph==20) direccion=1; end
			if(graph==44) direccion=0; end
			if(p[0].botones[2] and gatillo==0 and opcion>1)
				gatillo=1;
				opcion--;
			end
			if(p[0].botones[3] and gatillo==0 and opcion<2)
				gatillo=1;
				opcion++;
			end
			if(p[0].botones[4])
				if(opcion==1) opcion=0; pausa=0; graph=0; delete_text(id_texto); delete_text(id_texto1); delete_text(id_texto2); signal(type boton,s_kill); end
				if(opcion==2) opcion=0; while(p[0].botones[4]) frame; end menu(0); break; end
			end

		end
		if(pausa==0)
			scroll.y0-=5;
			if(distancia<4000) distancia++; end
			if(distancia==25*n)
				if(n==4 or n==57)
					enemigo(70,-50,2,8);
					enemigo(730,-50,2,1);
				end
				if(n==7 or n==60)
					enemigo(360,-50,2,1);
					enemigo(440,-50,2,8);
				end
				if(n==10 or n==63)
					enemigo(250,-50,3,0);
				end
				if(n==13 or n==66)
					enemigo(250,-50,3,0);
				end
				if(n==16 or n==69)
					enemigo(550,-50,3,0);
				end
				if(n==19 or n==72)
					enemigo(550,-50,3,0);
				end
				if(n==21 or n==75)
					enemigo(100,-50,4,0);
					enemigo(200,-50,4,0);
				end
				if(n==24 or n==78)
					enemigo(700,-50,4,0);
					enemigo(600,-50,4,0);
				end
				if(n==30 or n==84)
					enemigo(50,-50,2,12);
					enemigo(130,-50,2,12);
				end
				if(n==33 or n==87)
					enemigo(750,-50,2,5);
					enemigo(670,-50,2,5);
				end
				if(n==36 or n==90)
					enemigo(50,-50,2,12);
					enemigo(130,-50,2,12);
				end
				if(n==39 or n==93)
					enemigo(750,-50,2,5);
					enemigo(670,-50,2,5);
				end
				if(n==45 or n==99)
					enemigo(100,-50,4,0);
					enemigo(200,-50,4,0);
				end
				if(n==48 or n==102)
					enemigo(600,-50,4,0);
					enemigo(700,-50,4,0);
				end
				if(n==51 or n==105)
					enemigo(100,-50,4,0);
					enemigo(200,-50,4,0);
				end
				if(n==54 or n==108)
					enemigo(600,-50,4,0);
					enemigo(700,-50,4,0);
				end
				if(n==28) bono(400,-50,3); end
				if(n==56) bono(400,-50,2); end
				if(n==83) bono(400,-50,1); end
				if(n==111) bono(400,-50,2); end
				if(jefe==0) mina(30,5,1); mina(770,5,1); end
				if(n==114 and jefe==0) jefe=1; musica(2); id_boss01=boss(6); end
			n++;
			end
			if(jefe==1 and vida_boss<1) 
				timer[2]=0;
				while(timer[2]<100) frame; end
				graph=20;
				direccion=1;
				size=200;
				id_texto=write(fuente1,x,y,4,"AREA: 4");
				id_texto1=write(fuente1,x-5,y+15,4,"completada");
				timer[2]=0;
				while(timer[2]<500)
					if(direccion==1) graph++; else graph--; end
					if(graph==20) direccion=1; end
					if(graph==44) direccion=0; end
					scroll.y0-=5;
					frame;
				end
				juego(5);
				break;
			end	
			if(vidas<0)
				delete_text(all_text);
				signal(id_nave,s_kill);
				graph=20;
				direccion=1;
				size=200;
				id_texto=write(fuente1,x,y,4,"Fin de");
				id_texto1=write(fuente1,x-5,y+15,4,"la partida");
				timer[2]=0;
				while(timer[2]<500)
					if(direccion==1) graph++; else graph--; end
					if(graph==20) direccion=1; end
					if(graph==44) direccion=0; end
					scroll.y0-=5;
					frame;
				end
			menu(0);
			break;
			end
		end
	FRAME;
END
end

if(nivel==5)
	musica(2);
	graph=20;
	direccion=1;
	size=200;
	id_texto=write(fuente1,x,y,4,"AREA: Final");
	fade_on();
	timer[2]=0;
	while(timer[2]<300)
		if(direccion==1) graph++; else graph--; end
		if(graph==20) direccion=1; end
		if(graph==44) direccion=0; end
		scroll.y0-=5;
		frame;
	end
	delete_text(id_texto);
	graph=0;
	id_nave=nave01(400,700);
	fuerza=4;
	marcador();
	while(id_nave.y>300)
		id_nave.y-=10;
		scroll.y0-=5;
		frame;
	end
	while(id_nave.y<550)
		id_nave.y+=10;
		scroll.y0-=5;
		frame;
	end
	pausa=0;
	LOOP



		if(p[0].botones[7] and gatillo==0)
			gatillo=1;
			if(pausa==0)
				pausa=1;
				graph=20;
				size=300;
				direccion=1;
				id_texto=write(fuente1,x,y,4,"¿Salir de la partida?");
				boton(400,500,"",1);
				id_texto1=write(fuente1,400,500,4,"No");
				boton(400,550,"",2);
				id_texto2=write(fuente1,400,550,4,"Si");
				opcion=1;
			else
				pausa=0;
				graph=0;;
				delete_text(id_texto);
				signal(type boton,s_kill);
				delete_text(0);
			end
		end

		if(not p[0].botones[7] and not p[0].botones[2] and not p[0].botones[3] and gatillo==1) gatillo=0; end

		if(pausa==1)
				
			if(direccion==1) graph++; else graph--; end
			if(graph==20) direccion=1; end
			if(graph==44) direccion=0; end
			if(p[0].botones[2] and gatillo==0 and opcion>1)
				gatillo=1;
				opcion--;
			end
			if(p[0].botones[3] and gatillo==0 and opcion<2)
				gatillo=1;
				opcion++;
			end
			if(p[0].botones[4])
				if(opcion==1) opcion=0; pausa=0; graph=0; delete_text(id_texto); delete_text(id_texto1); delete_text(id_texto2); signal(type boton,s_kill); end
				if(opcion==2) opcion=0; while(p[0].botones[4]) frame; end menu(0); break; end
			end

		end
		if(pausa==0)
			scroll.y0-=5;
			if(jefe==0) jefe=1; id_boss01=boss(9); end
			if(jefe==1 and vida_boss<-99) 
				timer[2]=0;
				while(timer[2]<100) frame; end
				graph=20;
				direccion=1;
				size=200;
				id_texto=write(fuente1,x,y,4,"AREA: FINAL");
				id_texto1=write(fuente1,x-5,y+15,4,"completada");
				timer[2]=0;
				while(timer[2]<500)
					if(direccion==1) graph++; else graph--; end
					if(graph==20) direccion=1; end
					if(graph==44) direccion=0; end
					scroll.y0-=5;
					frame;
				end
				historia(2);
				break;
			end	
			if(vidas<0)
				delete_text(all_text);
				signal(id_nave,s_kill);
				graph=20;
				direccion=1;
				size=200;
				id_texto=write(fuente1,x,y,4,"Fin de");
				id_texto1=write(fuente1,x-5,y+15,4,"la partida");
				timer[2]=0;
				while(timer[2]<500)
					if(direccion==1) graph++; else graph--; end
					if(graph==20) direccion=1; end
					if(graph==44) direccion=0; end
					scroll.y0-=5;
					frame;
				end
			menu(0);
			break;
			end
		end
	FRAME;
END
end

END

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
PRIVATE
cargada;

BEGIN
FADE_MUSIC_OFF(0); 
timer[1]=0;
unload_song(cargada);
	if(cancion==1)
	cargada=load_song("./ogg/02.ogg");	//moto
	end
	if(cancion==2)
	cargada=load_song("./ogg/02.ogg");	//batalla
	end
	
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
	l=(father.x*255)/800;
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
		if(pausa==0) graph++; end
	frame;
	until(graph==12)
end
if(tipo==2)
	graph=20;
	repeat
		if(pausa==0) graph++; end
	frame;
	until(graph==31)
end
if(tipo==3)
	graph=1;
	suena(s_explosion_grande);
	repeat
		if(pausa==0) graph++; size+=20; end
	frame;
	until(graph==12)
end
if(tipo==4)
	graph=1;
	suena(s_explosion_grande);
	sombra(41,x,y,file,4);
	sombra(40,400,300,file,3);
	repeat
		if(pausa==0) graph++; size+=20; end
	frame;
	until(graph==12)
end
end

//-----------------------------------------------------------------------
// funcion para guardar archivos
//-----------------------------------------------------------------------

Function crear_jerarquia(string nuevo_directorio)                // Mejor Function que Process aquí
Private
	string directorio_actual="";
	string rutas_parciales[10];     // Sólo acepta la creación de un máximo de 10 directorios
	int i_max=0;
Begin
    directorio_actual = cd();                        // Recuperamos el directorio actual de trabajo, para volver luego a él
    if(chdir(nuevo_directorio) == 0)    // El directorio ya existe!
		cd(directorio_actual);
        return 0;
    end
    i_max = split("[\\/]", nuevo_directorio, &rutas_parciales, 10);
    chdir("/");
    while (i<i_max)
        while(rutas_parciales[i] == "")         // Se salta partes en blanco
                if(i++ >=i_max)
                       cd(directorio_actual);
                       return 0;
                end
        end
        if(chdir(rutas_parciales[i]) == -1)
                if(mkdir(rutas_parciales[i]) == -1)        // Error al intentar crear el directorio
                        cd(directorio_actual);
                        return -1;
                end
                chdir(rutas_parciales[i]);
        end;
        i++;
    end
    chdir(directorio_actual);
    return 0;
End

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
		from b=0 to alto-1 step 3;
		from a=0 to ancho-1 step 3;
			if(map_get_pixel(file,grafico,a,b)!=0)
				particula[c].pixell=map_get_pixel(file,grafico,a,b);
				
				particula[c].pos_x=a-(ancho/2);
				particula[c].pos_y=b-(alto/2);
				particula[c].vel_x=((a-(ancho/2))/12)+rand(-1,1);
				particula[c].vel_y=((b-(alto/2))/12)+rand(-1,1);

				c++;
			end
		end
	end
	a=c;
	size=200;
	while(tiempo<frames)
		graph=new_map(ancho*8,alto*8,32);
		from c=0 to a step 4;
			map_put_pixel(0,graph,particula[c].pos_x+(ancho*8/2),particula[c].pos_y+(alto*8/2),particula[c].pixell);
			
			particula[c].pos_x+=particula[c].vel_x;
			particula[c].pos_y+=particula[c].vel_y;
			
		end
		tiempo++;
		frame;
		unload_map(0,graph);
	end
end



include "nave.pr-"
include "bombas.pr-"
include "bosses.pr-"
include "enemigos.pr-"

include "../../common-src/controles.pr-";