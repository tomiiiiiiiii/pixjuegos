program pixfrogger;

import "mod_debug";
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
import "mod_text";
import "mod_timers";
import "mod_video";
import "mod_wm";

global
	arcade_mode=0;

	jue;
	anterior_camino;
	Struct ops; 
		pantalla_completa=1;
		sonido=1;
		musica=1;
		lenguaje;
	End
	elecc;
	elecy;
	scroll_y;
	rana_id[8];
	rana_juega[8];
	rana_viva[8];
	rana_puntos[8];
	llegada;
	ler;
	music;
	njoys;
	buzz;
	string joyname;
	buzz_joy;
	buzz_joy2;
	wavs[50];
	boton[9]; //0: cualquier boton,1-8: ranas,9:salir
	posibles_jugadores;
	
	ancho_pantalla=1280;
	alto_pantalla=720;
	panoramico=0;
	alto_camino=50;
	pos_inicio=50;
	num_caminos;
	meta=0;

	// COMPATIBILIDAD CON XP/VISTA/LINUX (usuarios)
	string savegamedir;
	string developerpath="/.PiXJuegos/PiXFrogger/";
Local
	i; // la variable maestra
	ancho;
	alto;
	jugador;
	pos_y;	
End

//cosas comunes de los pixjuegos
include "../../common-src/lenguaje.pr-";
include "../../common-src/savepath.pr-";

begin
	//arcade mode?
	if(argc>0) if(argv[1]=="arcade") arcade_mode=1; end end

	//encontramos buzzers
	njoys=number_joy();
	if(njoys>0)
		from i=0 to njoys-1;
			joyname=lcase(JOY_NAME(i));
			if(find(joyname,"buzz")=>0)
				buzz++;
				if(buzz==1)
					buzz_joy=i;
				elseif(buzz==2)
					buzz_joy2=i;
					break; //ya tenemos bastantes...
				end
			end
		end
	end

	//averiguamos el path para guardar datos
	savepath();
	
	//cargamos las opciones actuales
	carga_opciones();
	
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
	//full_screen=ops.pantalla_completa;
	set_mode(ancho_pantalla,alto_pantalla,32,WAITVSYNC);
	set_fps(30,0);
	set_title("PiX Frogger");
	
	num_caminos=(alto_pantalla/alto_camino)+1;
	
	//cargamos los recursos a utilizar durante todo el juego
	carga_sonidos();
	ler=load_fnt("fnt/puntos.fnt");
	load_fpg("fpg/pixfrogger.fpg");
	music=load_song("ogg/1.ogg");
	
	//empezamos, ponemos el logo
	logo_pixjuegos(); 
end

function reset();
Begin
	delete_text(0);
	stop_wav(-1);
	stop_song();
	clear_screen();
End

process logo_pixjuegos();
begin
	//reiniciamos todo, por si las moscas
	reset();
	let_me_alone();
	controlador();
	
	//ponemos el logo de pixjuegos
	graph=1;
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	z=-10;

	//aparece
	from alpha=50 to 255 step 5; 
		if(scan_code!=0) break; end
		frame; 
	end

	//permanece 3 segundos
	timer[0]=0;
	while(timer[0]<300) if(scan_code!=0) break; end frame; end
	while(scan_code!=0) frame; end
	
	//ponemos la canción del juego
	if(ops.musica)
		play_song(music,-1);
	end
	
	//ponemos el menú
	menu();
	
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
	from i=1 to 4; rana_viva[i]=0; rana_puntos[i]=0; end
	elecc=0;
	put_screen(0,3);
	if(!exists(type controlador)) controlador(); end
	if(arcade_mode)
		//modo arcade
		write(0,ancho_pantalla/2,alto_pantalla/2,4,"Pulsa el botón 1 para jugar");
		while(boton[0]) frame; end
		while(!boton[0]) 
			if(boton[9]) exit(); end
			frame; 
		end
		delete_text(all_text);
		
		//ayuda
		put_screen(0,6);
		while(boton[0]) frame; end
		while(!boton[0]) 
			if(boton[9]) exit(); end
			frame; 
		end
		while(boton[0]) frame; end
		
		//elección de personajes
		put_screen(0,3);
		elecpersonaje();
		return;
	end
	
	lista(4);
	logo(2);
	machango();
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
				let_me_alone();
				scroll_y=0;
				elecpersonaje();
				break;
			end
			if(elecc==1)
				let_me_alone();
				back(3);
				logo(2);
				opcion();
				break;
			end
			if(elecc==2)
				let_me_alone();
				back(5);
				break;
			end
			if(elecc==3)
				guarda_opciones();
				exit(0);
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

process lista(gr)
begin
	x=-200;
	y=300;
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
		if(gr!=13) x+=(x-150)/-10; else x+=(x-200)/-10; end
		frame;
	end
end

process logo(gr)
begin
	x=400;
	y=-140;
	z=-10;
	graph=gr;
	
	loop
		y+=(y-90)/-10;
		frame;
	end
end

process movi(gr)
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

process machango()
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
		x=(cos(osc)*5)+20;
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
	if(!exists(type controlador)) controlador(); end
	loop
		if(boton[9])
			while(boton[9]) frame; end
			let_me_alone();
			sonido(1);
			menu();
			break;
		end
		//ayuda y tal
		if(graph==5 or graph==912)
			if(key(_enter) and keytime==0)
				sonido(3);
				let_me_alone();
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
	lista(13);
	machango();
	scroll_y=-100;
	tecenter=1;
	loop
		if(boton[9])
			let_me_alone();
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
					let_me_alone();
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
begin
	jue=0;
	from j=0 to 8;
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
	if(!exists(type controlador)) controlador(); end
	if(buzz>0 and panoramico) posibles_jugadores=8; else posibles_jugadores=4; end
	//if(os_id) //anndorid
	panoramico=1;
	loop
		dand++;
		if(dand==100)
			movi(11);
		end
		if(dand==200)
			movi(12);
		end
		if(dand==250)
			graph=get_screen();
			let_me_alone();
			juego();
			z=-100;
			from alpha=255 to 0 step -15; frame; end
			unload_map(0,graph);
			break;
		end
		
		from i=1 to posibles_jugadores;
			if(boton[i] and rana_juega[i]==0)
				sonido(4);
				pon_rana(i);
				rana_juega[i]=1;
				dand=0;
			end
		end
		
		if(boton[9])
			while(boton[9]) frame; end
			let_me_alone();
			menu();
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
begin
	clear_screen();
	controlador();
	llegada=0;
	scroll_y=0;
	priority=1;
	delete_text(all_text);
	if(rana_puntos[1]!=0) write_int(ler,200,470,4,&rana_puntos[1]); end
	if(rana_puntos[2]!=0) write_int(ler,250,470,4,&rana_puntos[2]); end
	if(rana_puntos[3]!=0) write_int(ler,390,470,4,&rana_puntos[3]); end
	if(rana_puntos[4]!=0) write_int(ler,440,470,4,&rana_puntos[4]); end
	indicador();
	start_scroll(0,0,0,0,0,15);
	scroll[0].camera=camara();
	from i=pos_inicio-num_caminos to pos_inicio;
		camino(i);
	end
	from i=1 to posibles_jugadores;
		rana(i,rana_juega[i]);
	end
	frame(1000);
	loop
		if(rana_viva[1]+rana_viva[2]+rana_viva[3]+rana_viva[4]==1)
			graph=get_screen();
			x=ancho_pantalla/2;
			y=alto_pantalla/2;
			z=-3;
			let_me_alone();
			from i=1 to 4;
				if(rana_viva[i]==1) ganador=i; end
			end
			//hay que crear otro proceso para colocar gráficos
			gana_rana(ganador);
			gana_rana_you_win();
			//rana_elec(320,200,500+ganador,0);
			//rana_elec(320,380,916,0);
			rana_puntos[ganador]++;
			timer[0]=0;
			while(timer[0]<300) frame; end
			alpha=60;
			dand=100;
			loop
				dand++;
				if(dand==100)
					movi(11);
				end
				if(dand==200)
					movi(12);
				end
				if(dand==250)
					let_me_alone();
					juego();
					z=-10;
					from alpha=255 to 0 step -15; frame; end
					unload_map(0,graph);
					signal(id,s_kill);
				end			
			end
		end
		if(rana_viva[1]+rana_viva[2]+rana_viva[3]+rana_viva[4]==0)
			graph=get_screen();
			x=ancho_pantalla/2;
			y=alto_pantalla/2;
			z=-3;
			let_me_alone();
			alpha=60;
			dand=100;
			juego();
			z=-10;
			from alpha=255 to 0 step -15; frame; end
			unload_map(0,graph);
			signal(id,s_kill);
		end
		if(boton[9])
			while(boton[9]) frame; end
			let_me_alone();
			graph=get_screen();
			x=ancho_pantalla/2; y=alto_pantalla/2; z=-100;
			menu();
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
	if(!exists(father))
		return;
	else
		x=father.x+(father.x/30)-10;
		y=father.y+5;

		//if(father.graph==50 or father.graph==52 or father.graph==54 or father.graph==56)
		if(father.graph>=50 and father.graph=<80)
			if(father.graph%2==0)
				graph=900;
			else
				graph=901;
			end
		end
		
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
		FRAME;
	end
END

process rana(jugador,humano);
private
	retraso;
	gr;
	id_obst;
	gr_antes;
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
	end
	z=-100;
	gr=50+((jugador-1)*2);
	ctype=c_scroll;
	pos_y=pos_inicio;
	y=(alto_camino*pos_inicio)-(alto_camino/2);
	priority=2;
	rana_viva[jugador]=1;
	graph=gr;
	loop
		if(retraso>0)
			retraso--;
		end
		if(y<scroll[0].y1)
			pos_y++;
		end
		if(y>scroll[0].y1+alto_pantalla/2)
			pos_y--;
		end
		if(pos_y==meta) llegada=jugador; end
		if(!humano)
			graph=gr;
			if(rand(0,100)>90 or collision (type vehiculo))
				graph=gr+1;
				y-=alto_camino;
				if(collision(type vehiculo_colisionador))
					y+=alto_camino;
					graph=gr;
				else
					pos_y++;
				end
			end
		end
		
		//POSIBLES FORMAS DE PERDER: NOS ATROPELLAN O GANA OTRO
		gr_antes=graph; //guardamos el gráfico actual
		graph=61; //y ponemos este para colisionar!
		if(collision(type vehiculo_colisionador) or (llegada!=jugador and llegada!=0))
			graph=gr_antes;
			rana_golpeada(x,y,graph);
			explotalo(x,y,z,alpha,angle,file,graph,60);
			sonido(4);
			break;
		end
		graph=gr_antes;

		if(humano)
			if(boton[jugador]and retraso==0)
				graph=gr+1;
				pos_y--;
				retraso=4;
			else
				if(retraso<3) graph=gr; end
			end
		end
		y=(pos_y*alto_camino)+(alto_camino/2);
		sombra();
		frame;
	end
	rana_viva[jugador]=0;
end

Process camara();
Begin
	x=ancho_pantalla/2;
	y=(pos_inicio-(num_caminos/2))*alto_camino;
	ctype=c_scroll;
	loop
		from i=1 to posibles_jugadores;
			if(exists(rana_id[i]))
				if(rana_id[i].y<y-(alto_pantalla/2)+200)
					y-=5;
				end
			end
		end
		frame;
	end
End

Function en_pantalla_y();
Begin
	if(father.y>scroll[0].y1+(alto_pantalla/2)+alto_camino)
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
	x=rand(0,900);
	y=(pos_y*alto_camino)+(alto_camino/2);
	z=-10;
	loop
		sombra();
		vehiculo_colisionador(x,y);
		if(!en_pantalla_y()) return; end
		if(tipo==0 or tipo==2)
			if(tipo==0)
				x+=rand(10,15);
			else
				x+=5;
			end
			if(x>ancho_pantalla+200)
				x=-200;
			end
		else
			if(tipo==1)
				x-=rand(10,15);
			else
				x-=5;
			end
			if(x<-200)
				x=ancho_pantalla+200;
			end
		end		
		frame;
	end
end

process vehiculo_colisionador(x,y)
begin
	ctype=c_scroll;
	z=59;
	graph=99;
	frame(100);
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
		if(y>scroll[0].y1+(alto_pantalla/2)+100) break;	end
		frame;
	end
end

process camino(pos_y)
Begin
	z=50;
	x=ancho_pantalla/2;
	ctype=c_scroll;
	
	//al principio todo es hierba
	graph=200+(rand(0,2)*2);
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
				else
					graph=200+(rand(0,2)*2);
				end
			else //calzada
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
begin
	bandera();
	graph=50;
	angle=270000;
	size=50;
	y=22;
	z=-50;
	loop
		x=(scroll_y/10)+190;
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
	lista(914);
	machango();
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
		if(key(_enter)and keytime==0)
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
	from i=1 to 50;
		wavs[i]=load_wav("wav/"+i+".wav");
	end
End

Function sonido(num);
Begin
	if(ops.sonido)
		play_wav(wavs[num],0);
	end
End

Process controlador();
Begin
	loop
		from i=0 to 9; boton[i]=0; end

		if(arcade_mode)
			if(get_joy_button(0,8)) boton[9]=1; end
			if(get_joy_button(0,0)) boton[1]=1; end
			if(get_joy_button(0,3)) boton[2]=1; end
			if(get_joy_button(1,0)) boton[3]=1; end
			if(get_joy_button(1,3)) boton[4]=1; end
		end
		
		if(buzz==1)
			if(get_joy_button(buzz_joy,0)) boton[1]=1; end
			if(get_joy_button(buzz_joy,5)) boton[2]=1; end
			if(get_joy_button(buzz_joy,10)) boton[3]=1; end
			if(get_joy_button(buzz_joy,15)) boton[4]=1; end
			if(key(_q)) boton[5]=1; end
			if(key(_z)) boton[6]=1; end
			if(key(_p)) boton[7]=1; end
			if(key(_up)) boton[8]=1; end
		end
		if(buzz==2)
			if(get_joy_button(buzz_joy,0)) boton[1]=1; end
			if(get_joy_button(buzz_joy,5)) boton[2]=1; end
			if(get_joy_button(buzz_joy,10)) boton[3]=1; end
			if(get_joy_button(buzz_joy,15)) boton[4]=1; end
			if(get_joy_button(buzz_joy2,0)) boton[5]=1; end
			if(get_joy_button(buzz_joy2,5)) boton[6]=1; end
			if(get_joy_button(buzz_joy2,10)) boton[7]=1; end
			if(get_joy_button(buzz_joy2,15)) boton[8]=1; end
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
		
		//tecla maestra
		if(key(_esc)) boton[9]=1; end
		
		from i=1 to 8;
			if(boton[i]) boton[0]=1; break; end
		end
		frame;
	end
End

Process gana_rana(jugador);
Begin
	graph=500+jugador;
	x=320;
	y=200;
	z=-50;
	alpha=40;
	size=190;
	angle=60000;
	loop
		if(size>100) size-=8; end
		if(alpha<255) alpha+=10; end
		if(angle>0) angle-=4000; end
		frame;
	end
End

Process gana_rana_you_win();
Begin
	graph=916;
	x=320;
	y=380;
	z=-50;
	alpha=40;
	loop
		if(alpha<255) alpha+=5; end
		frame;
	end
End