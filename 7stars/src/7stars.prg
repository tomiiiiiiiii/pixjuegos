program seven_stars;

import "mod_blendop";
//import "mod_cd";
import "mod_debug";
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
import "mod_multi";
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


global
	vidas;
	magia=1;
	pausa;	
	vida_jefe;
	vida_jefe_max;
	fase;
	estrellas;
	id_chica;
	id_jefe;
	fuente;
	puntos;
	
	joysticks[10];
	posibles_jugadores;
	njoys;
	struct p[100];
		botones[7];
		control;
	end
	
	ancho_pantalla=1024;
	alto_pantalla=768;
end
	
local
	vida;
	i; j;
end

include "../../common-src/controles.pr-";
	
begin
full_screen=false;
set_mode(1024,768,32);
set_fps(30,0);
fuente=load_fnt("./fnt/fuente.fnt");
load_fpg("./fpg/ficher.fpg");
menu();
end

//menu
process menu();

private
	ancho1;
	ancho2=1024;
	id2;
	opcion=1;
	gatillo;
	angulo;

begin
	fade_off();
	clear_screen();
	musica(1);
	configurar_controles();
//	id2=cosa(512,300,-1);
	id2=ondular(512,300,-1,19,10,1000,10000);
	id2.alpha=0;
	frame;
	fade_on();
	while(id2.alpha<255)
		id2.alpha+=2;
		frame;
	end
	graph=14;
	alpha=0;
	x=200;
	y=384;
	z=-5;
	while(alpha<255)
		id2.x+=2;
		alpha+=2;
		frame;
	end
	start_scroll(0,0,rand(1,7),0,1,3);
	start_scroll(1,0,14+rand(1,4),0,3,3);
	start_scroll(2,0,rand(1,7),0,2,3);
	scroll[0].z=-1;
	scroll[2].z=-1;	
	while(ancho1<1024)
		define_region(1,0,0,ancho1,100);
		define_region(2,0,668,ancho1,100);
		define_region(3,ancho2,100,1024-ancho2,568);
		scroll[0].x0-=10;
		scroll[1].x0+=10;
		scroll[2].x0-=10;
		ancho1+=10;
		ancho2-=10;
		frame;
	end
	satelite(1);
	satelite(2);
	satelite(3);
	satelite(4);
	satelite(5);
	satelite(6);
	satelite(7);
	opcion(1);
	opcion(2);
	graph=55;
	controlador(0);
	loop
		scroll[0].x0-=10;
		scroll[1].x0+=10;
		scroll[2].x0-=10;
		x=500+get_distx(angulo,25);
		angulo+=10000;
		if(opcion==1)
			y=550;
		end
		if(opcion==2)
			y=600;
		end
		if(gatillo==1 and scan_code==0) gatillo=0; end
		if(gatillo==0)
			if(p[0].botones[b_arriba] and opcion==2)
				opcion=1;
				gatillo=1;
			end
			if(p[0].botones[b_abajo] and opcion==1)
				opcion=2;
				gatillo=1;
			end

			if(p[0].botones[b_1] or key(_enter))
				if(opcion==1)
          graph=0;
					stop_scroll(0);
					stop_scroll(1);
					stop_scroll(2);
					intro(1);
 				end
				if(opcion==2)
					exit();
				end
			end
		end
		frame;
	end
end


process cosa(x,y,z);

begin
	graph=19;
	loop
		frame;
	end
end



process ondular(x,y,z,grafico,radio,omega,delta);

private
	angulo;
	altura;
	desfase;
begin
	loop
		graph=new_map(radio*2+graphic_info(0,grafico,g_wide),graphic_info(0,grafico,g_height),32);

		angulo=desfase;
		from altura=0 to graphic_info(0,grafico,g_height);
			map_block_copy(0,graph,radio+get_distx(angulo,radio),altura,grafico,0,altura,graphic_info(0,grafico,g_wide),1,128);
			angulo+=omega;
		end
		desfase+=delta;
		if(angulo>360000) angulo=0; end
		if(desfase>360000) desfase=0; end
		frame;
		unload_map(0,graph);
	end
end

process opcion(a);
begin

	if(a==1)
		graph=57;
		x=700;
		y=550;
		z=-10;
	end
	if(a==2)
		graph=56;
		x=700;
		y=600;
		z=-10;
	end
	loop frame; end

end

//musica

PROCESS musica(cancion);
PRIVATE
cargada;

BEGIN
FADE_MUSIC_OFF(0); 
timer[1]=0;
unload_song(cargada);
	if(cancion==1)
	cargada=load_song("./musica/bionicle.ogg");
	end
	
play_song(cargada,-1);
frame;
END

//intro

process intro(historia);
begin
	delete_text(0); 
	let_me_alone();
	clear_screen();
	controlador(0);
	if(historia==1)
		write(fuente,512,350,4,"Instrucciones:");
		write(fuente,512,400,4,"Flechas de direccion: movimiento");
		write(fuente,512,450,4,"Control: disparo");	
		puntos=0;
		vidas=10;
		fase=1;
		frame(5000);
		while(!p[0].botones[b_1])
    	frame;
    end
    if(p[0].botones[b_1]) frame; end
		mundo(fase);
	end
	if(historia==2)
		write(fuente,512,350,4,"Felicidades, has conseguido pasarte el juego");
		write(fuente,512,400,4,"Gracias por jugar.");
		write(fuente,512,450,4,"Tu puntuacion: "+puntos);
		frame(5000);
    while(!p[0].botones[b_1])
    	frame;
    end
    if(scan_code) frame; end
    delete_text(0);
    menu();
  end
	if(historia==3)
		write(fuente,512,350,4,"Fin del juego");
		write(fuente,512,400,4,"Tu puntuacion: "+puntos);
		frame(5000);
    while(!p[0].botones[b_1])
    	frame;
    end
    if(scan_code) frame; end
    delete_text(0);
    menu();
	end
end

	
//niveles


process mundo(nivel);

private
	avance;
	n;
	jefe;
	texto;
	gatillo;

begin 
	fade_off();
	delete_text(0);
	let_me_alone();
	pausa=0;
	n=1;
	id_chica=chica();
	magia();
	vidas();
	id_chica.x=300;
	id_chica.y=384;
	write_var(fuente,150,50,4,vidas);	
	start_scroll(0,0,14+nivel,0,0,3);
	frame;
	fade_on();
	controlador(0);
	loop
		if(pausa==0)
			scroll[0].x0+=5;
			avance++;
			if(nivel==1)
			  if(avance==n*120)
					enemigos(1100,rand(250,700),1);
					enemigos(1100,rand(250,700),2);
					n++;
				end
				if(avance>2000 and jefe==0)
					id_jefe=jefe();
					jefe=1;
				end
				if(jefe==1 and !exists(id_jefe))
					fase++;
					stop_scroll(0);
					mundo(fase);
				end
			end
			if(nivel==2)
			  if(avance==n*100)
					enemigos(1100,rand(250,700),1);
					enemigos(1100,rand(250,700),2);
					n++;
				end
				if(avance>3000 and jefe==0)
					id_jefe=jefe();
					jefe=1;
				end
				if(jefe==1 and !exists(id_jefe))
					fase++;
					stop_scroll(0);
					mundo(fase);
				end				
			end
			if(nivel==3)
			  if(avance==n*80)
					enemigos(1100,rand(250,700),1);
					enemigos(1100,rand(250,700),2);
					n++;
				end
				if(avance>4000 and jefe==0)
					id_jefe=jefe();
					jefe=1;
				end
				if(jefe==1 and !exists(id_jefe))
					fase++;
					stop_scroll(0);
					mundo(fase);
				end			
			end
			if(nivel==4)
			  if(avance>n*60)
					enemigos(1100,rand(250,700),1);
					enemigos(1100,rand(250,700),2);
					n++;
				end
				if(avance==5000 and jefe==0)
					id_jefe=jefe();
					jefe=1;
				end
				if(jefe==1 and !exists(id_jefe))
					stop_scroll(0);
					intro(2);
				end			
			end
		end
		if(gatillo==0 and key(_enter))
			if(pausa==0)
				pausa=1;
			else
				pausa=0;
			end
			gatillo=1;
		end
		if(not key(_enter) and gatillo==1) gatillo=0; end
		if(p[0].botones[b_salir])
			stop_scroll(0);
			let_me_alone();
			delete_text(0);
			clear_screen();
			menu();
			signal(id,s_kill);
		end
		texto=write(fuente,1000,50,2,"puntos: "+puntos);
		frame;
		delete_text(texto);	
	end

end

//prota

process chica();

private
	gatillo;
	intervalo;
	vulnerable;

begin
    graph=59;
    z=-100;
    flags=4;
	
    loop
    	if(pausa==0)
    		if(p[0].botones[b_arriba] and y>200) y-=10; angle=15000; end
    		if(p[0].botones[b_abajo] and y<700) y+=10; angle=-30000; end
    		if(p[0].botones[b_derecha] and x<824) x+=10; end
    		if(p[0].botones[b_izquierda] and x>100) x-=10; end
    		if(scan_code==0) angle=0; end
    		intervalo++;
    		if(intervalo>2)
    			if(angle==0)
    				estrellita(x-30,y+35,65+rand(1,7),z+1,10,0);
    			end
    			if(angle==15000)
    				estrellita(x-30,y+55,65+rand(1,7),z+1,10,0);
    			end
    			if(angle==-30000)    			
    				estrellita(x-40,y+7,65+rand(1,7),z+1,10,0);    			
    			end
    			intervalo=0;
    		end
    		
    		if(p[0].botones[b_1])
    			gatillo=1;	
    		else
    			gatillo=0;
    		end
    		
    		if(gatillo==1 and intervalo>1 and magia<26)
    			magia++;
    		end
    		if(gatillo==0 and magia>1)
    			if(magia>11 and magia<22)
    				estrella(x,y,100);
    			elseif(magia>21)
    				estrella(x,y,200);
    			else
    				estrella(x,y,25);
    			end		
    			magia=1;
    		end
    		
    		if(flags==4)
    		   vulnerable++;
    		end
    		if(vulnerable>100)
    			flags=0;
    		end
    		if(flags==0)
    			if(collision(type tiro) or collision(type enemigos) or collision(type jefe))
    				vidas--;
    				flags=4;
    				vulnerable=0;
    			end
    		end
    		if(vidas==0)
    			stop_scroll(0);
    			intro(3);
    		end	
    	end
    	frame;
    end
end

//disparo

process estrella(x,y,size);

private
	id2;

begin
	graph=65+rand(1,7);
	z=-255;
	loop
		if(pausa==0)
			x+=20;
			if(size>25)
				estrellita(x,y+rand(-20,20),65+rand(1,7),z+1,25,1);
			end
			if(id2=collision(type enemigos))
				if(size==100)
					signal(id2,s_kill);
					explosion(id2.x,id2.y);
					puntos+=10;
					signal(id,s_kill);
				elseif(size==200)
					signal(id2,s_kill);
					explosion(id2.x,id2.y);
					puntos+=20;
				else
					id2.vida--;
					estrellita(x,y,61,z-1,0,2);
					puntos+=1;
					signal(id,s_kill);
          
				end
			end
			if(collision(type jefe))
				if(size==200)
				   id_jefe.vida-=10;
				   estrellita(x,y,61,z-1,100,2);
				   puntos+=3;
				end
				if(size==100)
				   id_jefe.vida-=5;
				   estrellita(x,y,61,z-1,50,2);
				   puntos+=2;
				end				
				if(size==25)
				   id_jefe.vida-=1;
				   estrellita(x,y,61,z-1,0,2);
				   puntos+=1;
				end
				signal(id,s_kill);

			end            
			if(out_region(id,0))
				signal(id,s_kill);
			end
		end
		frame;
	end
end

//contadores

process magia();
begin
	x=75;
	y=50;
	z=-200;
	loop
			graph=25+magia;
			frame;
	end
end

process vidas();
begin
	graph=73;
	x=200;
	y=50;
	z=-200;
	loop
		frame;
	end
end

process barra1();
begin
	graph=74;
	x=500;
	y=50;
	z=-200;
	alpha=0;
	loop 
		if(alpha<255)
			alpha+=2;
		end
		frame;
	end
end

process barra2();
begin
	graph=75;
	region=1;
	x=500;
	y=50;
	z=-201;
	alpha=0;
	loop
			if(alpha<255)
				alpha+=2;
			end
				define_region(1,x-95,y-10,190*vida_jefe/vida_jefe_max,20);
			frame;
		end
end


//enemigos

process enemigos(x,y,tipo);

private
	grafico[3];
	intervalo;
	a;

begin

	if(tipo==1)
		grafico[0]=graph=20;
		grafico[1]=graph=21;
		grafico[2]=graph=22;
		vida=2;
		z=-17;
	end
	if(tipo==2)
		grafico[0]=23;
		grafico[1]=24;
		grafico[2]=25;
		vida=5;
		z=-18;
	end	
	loop 
		if(pausa==0)
			graph=grafico[a];
			intervalo++;
			if(tipo==1)
				if(intervalo>10)
					intervalo=0;
					a++;
				end
				if(a==3)
					a=0;
				end
				x-=9+fase;
			end			
			if(tipo==2)
				switch(intervalo) 
					case 0..9:
						a=0;
					end
					case 10..19:
						a=1;
					end
					case 20..29:
						a=2;
					end
					case 30..39:
						a=1;
					end
				end
				if(intervalo>40) tiro(x-30,y+20,3); intervalo=0; end
				x-=5+fase;
			end
			if(vida<1) explosion(x,y); break; end
			if(x<-50) break; end			
		end	
	  frame;
	 end
	 signal(id,s_kill);
end

//jefes

process jefe();

private
	patron;
	angulo;
	n=1;
	
begin
	graph=53;
	vida=100*fase;
	vida_jefe_max=vida;
	//cola();
	barra1();
	barra2();
	x=1200;
	y=400;
	z=-19;
	loop
		if(pausa==0)
			vida_jefe=vida;
			y=400+get_disty(angulo,200);
			angulo+=1000*fase;
			if(x>900)x-=2; end
			if(vida>0)
				patron++;
			end
			if(patron==30*n)
				tiro(x-90,y+20,1);
				n++;
			end
			if(fase>2)
				if(patron==500)
					tiro(-90,20,4);
					n=1;
					patron=-200;
				end
			end
			if(vida<1)
      	break;
			end
		end
		frame;
	end 
	graph=0;
	from n=0 to 60;
		explosion(x+rand(-50,50),y+rand(-50,50));
		estrellita(x+rand(-50,50),y+rand(-50,50),65+rand(1,7),z,50,0);
		frame;
	end
end

//disparo enemigo

process tiro(x,y,tipo);

private
	x1;
	y1;

begin
	graph=61+tipo;
	z=-20;
	if(tipo==4) size=0; x1=x; y1=y; end
	loop
		if(pausa==0)
			if(tipo==1)
				angle=180000;
				advance(20);
			end 
			
			if(tipo==2)
				y=father.y;
				x-=56;
			end
			
			if(tipo==3)
				angle=180000;
				advance(30);
			end
			
			if(tipo==4)
				x=father.x+x1;
				y=father.y+y1;
				if(size<100)
					size+=10;
				end
				if(size==100)				
					tiro(x,y,2);
					alpha-=5;
				end
				if(alpha<0) 
					estrellita(x,y,61,z-1,0,2);
					signal(id,s_kill); 
				end
			end
				
			if(out_region(id,0))
				signal(id,s_kill);
			end 
			
		end
		frame;
	end
end

//explosiones

process explosion(x,y);

private
	inercia;

begin
	if(rand(1,2)==1)
		graph=58;
	else
		graph=60;
	end
	z=-255;
	estrellita(x+10,y+10,65+rand(1,7),z,10,0);
	estrellita(x-10,y+10,65+rand(1,7),z,10,0);
	estrellita(x+10,y-10,65+rand(1,7),z,10,0);
	estrellita(x-10,y-10,65+rand(1,7),z,10,0);
	loop
		if(pausa==0)
			y+=inercia;
			inercia++;
			if(y>800) break; end
		end
		frame;
	end
end

//sombra

process satelite(element);

private
	angulo;
begin
	graph=7+element;
	if(element==1)

		loop
			x=200;
			y=384+get_disty(angulo,150);
			z=father.z+get_disty(angulo+90000,3);
			angulo+=5000;
			frame;
		end
	end
	if(element==2)
		loop
			x=200+get_distx(angulo+90000,150);
			y=384+get_disty(angulo+180000,75);
			z=father.z+get_disty(angulo+90000,3);
			angulo+=5000;
			frame;
		end
	end
	if(element==3)

		loop
			x=200+get_distx(angulo+270000,150);
			y=384+get_disty(angulo+180000,75);
			z=father.z+get_disty(angulo+270000,3);
			angulo+=5000;
			frame;
		end
	end
	if(element==4)

		loop
			x=200;
			y=384+get_disty(angulo+180000,150);
			z=father.z+get_disty(angulo-90000,3);
			angulo+=5000;
			frame;
		end
	end
	if(element==5)

		loop
			x=200+get_distx(angulo-90000,150);
			y=384+get_disty(angulo,75);
			z=father.z+get_disty(angulo+90000,3);
			angulo+=5000;
			frame;
		end
	end
	if(element==6)

		loop
			x=200+get_distx(angulo+90000,150);
			y=384+get_disty(angulo,75);
			z=father.z+get_disty(angulo+270000,3);
			angulo+=5000;
			frame;
		end
	end
	if(element==7)

		loop
			x=200;
			y=384;
			z=-5;
			frame;
		end
	end
end

process estrellita(x,y,graph,z,size,tipo);

private
	inercia;

begin
	while(alpha>0)
		if(pausa==0)
			alpha-=20;
			angle+=30000;
			if(tipo==0)
 				y+=inercia;
  			x-=10;
  			inercia++;
  		end
  		if(tipo==1)
  			x+=1;
  			size--;
  		end
  		if(tipo==2)
  			size+=5;
  		end  		
  	end
  	frame;
	end
end
