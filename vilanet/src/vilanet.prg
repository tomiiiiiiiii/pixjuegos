program vilanet;

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

global
	//Para opciones de música y sonido
	Struct ops; 
		sonido=1;
		musica=1;
	End
	music;
	wavs[10];

	//MODO DE PANTALLA Y FPS
	ancho_pantalla=480;
	alto_pantalla=800;
	frameskip=2;
	_fps=25;
	
	//UI
	matabotones;
	id_boton_menu;
	opcion_menu;

	ready;
	doble_clic;
	dificultad;
	distancia;
	obstaculos_en_pantalla;
	puntos;
	fuente;
	
Private
	graph_loading;
	
Local
	i;
	accion;
begin
	//establecemos la pantalla a utilizar y su tamaño
	frame;
	if(os_id==1003) //para comprobar en android
		//con esto averiguamos sus dimensiones en Android
		ancho_pantalla=graphic_info(0,0,g_width);
		alto_pantalla=graphic_info(0,0,g_height);
	end
	if(ancho_pantalla!=480 or alto_pantalla!=800) 
		scale_resolution=ancho_pantalla*10000+alto_pantalla; 
		ancho_pantalla=480;
		alto_pantalla=800;
	end
	say("--------------------- "+scale_resolution);
	
	if(os_id!=1003) scale_resolution=02400400; end
	
	//inicializamos el modo gráfico, fps y nombre de la ventana
	set_mode(480,800,16);
	set_fps(_fps,frameskip);
	
	//ponemos el gráfico de "cargando"...
	graph_loading=load_png("loading.png");
	put_screen(0,graph_loading);
	frame; //tengo que hacer 2 frames para que lo de arriba funcione :|
	frame;
	unload_map(0,graph_loading);
	
	//cargamos los recursos a utilizar durante todo el juego
	carga_sonidos();
	
	//cargamos el fpg de gráficos
	load_fpg("fpg/vilanet.fpg");
	
	//la fuente
	fuente=load_fnt("fpg/1.fnt");
	
	//si no estamos en android, ponemos algo para localizar el cursor
	if(os_id!=1003)
		mouse.graph=71;
	end
	
	//y finalmente el menú
	menu_tactil();
	
	//juego();
end

Process menu_tactil();
Private
	menu_actual=0;
	cambia_menu=1;
	jugadores=1;
Begin
	//ponemos el fondo
	put_screen(0,1);

	stop_scroll(0);
	
	id_boton_menu=0;
	opcion_menu=0;

	delete_text(all_text);	
	
	//ponemos la canción de fondo del juego
	music=load_song("ogg/1.ogg");
	if(ops.musica)
		play_song(music,-1);
	end

	loop
		//botón esc o back
		if(scan_code==102 or key(_esc))
			if(menu_actual!=1)
				cambia_menu=1; 
				sonido(1);
			else
				matabotones=1;
				fade_music_off(500);
				while(is_playing_song()) frame; end
				exit();
			end
		end

		if(!focus_status)
			matabotones=1;
			fade_music_off(500);
			while(is_playing_song()) frame; end
			exit();
		end

		if(opcion_menu!=0)
			sonido(1);
			if(menu_actual==1) //principal: 1 jugar, 2 opciones, 3 creditos, 4 salir
				switch(opcion_menu)
					case 1: juego(); return; end
					case 2: cambia_menu=3; end
					case 3: cambia_menu=4; end
					case 4: exit(); end
					case 5: //donate???!!! :O
						exec(_P_NOWAIT, "market://details?id=com.pixjuegos.pixfrogger", 0, 0);						
						exit(); 
					end
				end
			end
			if(menu_actual==3) //opciones: 1 sonido, 2 musica, 3 volver
				switch(opcion_menu)
					case 3: cambia_menu=1; end
				end
			end
			if(menu_actual==4) //creditos: 1 volver
				cambia_menu=1;
			end
			opcion_menu=0;
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
				pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*4)-(alto_pantalla/14),601,100,255,1,2); //jugar
				pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*5)-(alto_pantalla/14),603,100,255,3,3); //creditos
				pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*6)-(alto_pantalla/14),604,100,255,4,4); //salir
			end
			if(menu_actual==4) //creditos
				pon_creditos();
				//pon_enlace(ancho_pantalla/2,(alto_pantalla/7)*6,706,"http://www.pixjuegos.com");
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
	x=30;
	y=30;
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
	x=ancho_pantalla-30;
	y=30;
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
		if(mouse.left)
			if(collision_box(type mouse))
				if(graph>600 and graph<605) graph+=10; end
				
				while(mouse.left and collision_box(type mouse)) frame; end
				
				if(collision_box(type mouse))
					opcion_menu=mi_opcion;
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

process juego()
Private
	retraso=100;
	retraso_esquiador;
	anterior;
	nuevo;
begin
	//graph=get_screen();
	let_me_alone();
	clear_screen();
	controlador();
	puntos=0;
	distancia=0;
	obstaculos_en_pantalla=0;
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	start_scroll(0,0,11,0,0,15);
	scroll[0].camera=camara();
	prota();
	ready=0;
	write_int(fuente,ancho_pantalla,0,2,&puntos);
	
	//ponemos la canción de fondo del juego
	music=load_song("ogg/2.ogg");
	play_song(music,-1);
	ready=1;
	loop
		distancia++;
		if(exists(type prota)) puntos+=1+(dificultad/3); end
		while(alpha>0) alpha-=5; frame; end
		//perdida del foco en el juego
		if(!focus_status)
			let_me_alone();
			if(ops.musica)
				fade_music_off(1000);
			end
			set_fps(1,0);
			timer[0]=0;
			while(!focus_status)
				if(timer[0]>60000) exit(); end
				frame;
			end
			if(ops.musica)
				play_song(music,-1);
			end		
			set_fps(_fps,frameskip);
			juego();
			return;
		end
		
		dificultad=6+(distancia/100);
		
	//	if(rand(0,100)=<dificultad)
			if(obstaculos_en_pantalla<5)
				if(retraso>50-dificultad*2)
					repeat
						nuevo=rand(1,5);
					until(nuevo!=anterior)
					obstaculo(nuevo,rand(15,19));
					anterior=nuevo;
					retraso=0;
				else
					retraso++;
				end
			end
	//	end
		if(retraso_esquiador>100)
			retraso_esquiador=rand(-100,0);
			esquiador(rand(1,5));
		else
			retraso_esquiador++;
		end
	
		//botón esc, salir
		if(scan_code==102 or key(_esc))
			while(scan_code==102 or key(_esc)) frame; end
			let_me_alone();
			graph=get_screen();
			x=ancho_pantalla/2; y=alto_pantalla/2; z=-100;
			menu_tactil();
			from alpha=255 to 0 step -15; frame; end
			unload_map(0,graph);
			return;
		end
		frame;
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

//hace una capa de emulación del táctil para pc y gestiona el boton de volver
Process controlador();
Begin	
	loop
		if(mouse.left)
			dedo(mouse.x,mouse.y); 
		end
		for(i=0; i<10; i++)
			if(multi_info(i, "ACTIVE") > 0)
				dedo(multi_info(i, "X"),multi_info(i, "Y"));
			end
		end
		frame;
	end
End

Process dedo(x,y);
Begin
	priority=1;
	graph=71;
	alpha=0;
	frame;
End

Process prota();
Private
	retraso;
	anim;
Begin
	flags=B_VMIRROR;
	x=ancho_pantalla/2;
	y=alto_pantalla-70;
	z=-2;
	graph=5;
	loop
		if(anim<10-(dificultad/5))
			anim++;
		else
			if(graph<10) graph++; else graph=5; end
			anim=0;
		end
		if((os_id==1003 and mouse.left) or os_id!=1003)
			if(x<mouse.x) 
				x+=20;
				if(x>mouse.x) x=mouse.x; end
			elseif(x>mouse.x) 
				x-=20;
				if(x<mouse.x) x=mouse.x; end
			end
		end
		if(x<(ancho_pantalla/10)) x=ancho_pantalla/10; end
		if(x>ancho_pantalla-(ancho_pantalla/10)) x=ancho_pantalla-(ancho_pantalla/10); end
		if(retraso>100)
			if((os_id==1003 and mouse.left and mouse.y<(alto_pantalla/4)*3) or (os_id!=1003 and mouse.left))
				disparo();
				retraso=0;
			end
		else
			retraso++;
		end
		if(accion<0) break; end
		frame;
	end
	if(accion==-1) explosion(); end
	if(accion==-2) sonido(5); from size=100 to 0 step -10; frame; end end
	gameover();
End

Process disparo();
Begin
	x=father.x;
	y=father.y;
	z=-1;
	graph=4;
	size=200;
	while(y>-100)
		if(accion==-1) 
			from alpha=255 to 0 step -30; 
				size+=3; 
				frame; 
			end 
			break; 
		end
		y-=20;
		angle+=20000;
		frame;
	end
End

Process obstaculo(pos_x,graph);
Private
	id_col;
Begin
	y=-100;
	if(graph==18) pos_x=1; end
	if(graph==19) pos_x=5; end
	if(graph==18 or graph==19)
		y=-600;
	end
	x=((pos_x-1)*(480/5))+(480/10);
	z=-1;
	size=150;
	if(collision(type obstaculo))
		return;
	end
	size=100;
	obstaculos_en_pantalla++;
	loop
		if(id_col=collision(type prota))
			if(graph==18 or graph==19)
				id_col.accion=-2;
			else
				id_col.accion=-1;
			end
		end
		if(graph<18)
			if(id_col=collision(type disparo))
				if(graph==17) //explosion
					explosion();
				end
				id_col.accion=-1;
				if(graph==15 or graph==16) sonido(3); end
				break;
			end
			if(y>alto_pantalla+100) break; end
		else
			//barrancos
			if(y>alto_pantalla+600) break; end
		end
		y+=3+dificultad;
		frame;
	end
	//explosion
	from alpha=255 to 0 step -30; y+=3+dificultad; frame; end
	obstaculos_en_pantalla--;
End

Process explosion();
Private
	anim;
Begin
	sonido(4);
	x=father.x;
	y=father.y;
	z=-2;
	graph=22;
	while(graph<27)
		if(anim==4) graph++; anim=0; else anim++; end
		size+=10;
		alpha-=5;
		y+=3+dificultad;
		frame;
	end
		
End

Process esquiador(pos_x);
Private
	id_col;
Begin
	x=((pos_x-1)*(480/5))+(480/10);
	y=-100;
	z=0;
	graph=20;
	size=150;
	if(collision(type obstaculo))
		esquiador(rand(1,5));
		return;
	end
	size=100;
	if(collision(type obstaculo)) return; end
	while(y<alto_pantalla+100);
		if(graph==20)
			if(id_col=collision(type disparo))
				id_col.accion=-1;
				graph=21;
				sonido(2);
			end
			if(collision(type obstaculo))
				graph=21;
				sonido(3);
			end
			if(collision(type prota))
				puntos+=1000;
				sonido(2);
				break;
			end
			y+=6+dificultad;
		else
			y+=3+dificultad;
		end
		frame;
	end
End

Process camara();
Begin
	loop
		y-=3+dificultad;
		frame;
	end
End

Process gameover();
Begin
	delete_text(all_text);
	write(fuente,ancho_pantalla/2,(alto_pantalla/4)*3,4,puntos);
	x=ancho_pantalla/2;
	y=(alto_pantalla/2);
	graph=705;
	z=-10;
	if(ops.musica)
		play_song(load_song("ogg/3.ogg"),0);
	end
	while(is_playing_song()) frame; end
	let_me_alone();
	delete_text(all_text);
	menu_tactil();
end