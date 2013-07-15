program inforgames;

#IFDEF DEBUG
	import "mod_debug";
#ENDIF
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
import "mod_time";

global
	//Para opciones de música y sonido
	Struct ops; 
		sonido=1;
		musica=1;
	End
	music;
	wavs[20];

	string next_music="";
	
	//MODO DE PANTALLA Y FPS
	ancho_pantalla=480;
	alto_pantalla=800;
	frameskip=2;
	_fps=25;
	
	//UI
	matabotones;
	id_boton_menu;
	opcion_menu;
	
	fuente;
	puntos;
	hormigas_muertas;
	
	num_hormigas;
	combo;
	id_trozos[6];
	id_trozos_centros[6];
	trozos;
	
	mi_canal;
	mi_sonido;

	hormigas_atacando;

Private
	graph_loading;
	
Local
	i;
	accion;
	fuerza;
	
begin
	rand_seed(time());
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

	//if(os_id==os_win32) scale_resolution=02400400; end
	//if(os_id==os_win32) scale_resolution=04000240; end
	ancho_pantalla=800; alto_pantalla=480;
	//inicializamos el modo gráfico, fps y nombre de la ventana
	set_mode(ancho_pantalla,alto_pantalla,16);
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
	load_fpg("fpg/inforgames.fpg");
	set_center(0,20,0,75);
	
	//la fuente
	fuente=load_fnt("fnt/1.fnt");
	
	//si no estamos en android, ponemos algo para localizar el cursor
	if(os_id!=1003)
		mouse.graph=71;
	end
	
	//y finalmente el menú
	menu_tactil();
end

Process menu_tactil();
Private
	menu_actual=0;
	cambia_menu=1;
	jugadores=1;
Begin
	next_music="menu";
	musica_fondo();
	
	//ponemos el fondo
	put_screen(0,1);
	
	id_boton_menu=0;
	opcion_menu=0;
	
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
			sonido(3);
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
				pon_boton_menu(ancho_pantalla/4,(alto_pantalla/2),2,100,255,0,1); //logo
				pon_boton_menu(ancho_pantalla/4*3,((alto_pantalla/6)*2),601,100,255,1,2); //jugar
				pon_boton_menu(ancho_pantalla/4*3,((alto_pantalla/6)*3),603,100,255,3,3); //creditos
				pon_boton_menu(ancho_pantalla/4*3,((alto_pantalla/6)*4),604,100,255,4,4); //salir
			end
			if(menu_actual==4) //creditos
				pon_creditos();
				pon_enlace(550,320,706,"http://www.pixjuegos.com");
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
	y=alto_pantalla/2;
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
						stop_wav(mi_canal);
					else
						ops.musica=1;
						ops.sonido=1;
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

process juego();
private
	contador;
begin
	puntos=0;
	hormigas_muertas=0;
	num_hormigas=0;
	
	graph=get_screen();
	let_me_alone();
	
	next_music="tranquilo";
	musica_fondo();
	
	clear_screen();
	controlador();
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	
	put_screen(0,10);
	
	trozos=6;
	
	from i=1 to 6;
		id_trozos[i]=trozo_tarta(i);
	end
	
	write(fuente,10,10,0,"Score: ");
	write_int(fuente,10,40,0,&puntos);
	
	while(alpha>0) alpha-=10; frame; end
	contador=5*_fps;
	loop
		contador++;
		if(trozos<1) gameover(); return; end
		if(key(_space)) set_fps(0,0); end
		//if(num_hormigas<(contador+(num_hormigas/10))/(_fps*3) and rand(0,10)==0) hormiga(); end
		if(num_hormigas<2+(hormigas_muertas/2) and rand(0,30)==0) hormiga(); end
		//perdida del foco en el juego
		if(!focus_status)
			let_me_alone();
			if(ops.musica)
				fade_music_off(1000);
			end
			set_fps(1,0);
			timer[0]=0;
			while(is_playing_song())
				frame;
			end
			exit();
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
	from i=1 to 20;
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
Private
	pulsando[9];
	pulsandome;
Begin	
	loop
		if(mouse.left)
			if(pulsandome==0)
				pulsandome=1;
				dedo(mouse.x,mouse.y);
			end
		else
			pulsandome=0;
		end

		for(i=0; i<10; i++)
			if(multi_info(i, "ACTIVE") > 0)
				if(pulsando[i]==0)
					pulsando[i]=1;
					dedo(multi_info(i, "X"),multi_info(i, "Y"));
				end
			else
				pulsando[i]=0;
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

Process gameover();
Begin
	next_music="gameover";

	delete_text(all_text);
	write(fuente,ancho_pantalla/2,150,4,"Score: "+puntos);
	x=ancho_pantalla/2;
	y=(alto_pantalla/2);
	graph=501;
	z=-10;
	if(ops.musica)
		play_song(load_song("ogg/3.ogg"),-1);
	end
	while(mouse.left) frame; end
	opcion_menu=0;
	pon_enlace(ancho_pantalla/4,(alto_pantalla/7)*1,707,"https://twitter.com/intent/tweet?text=I've scored "+puntos+" points in Infor Ant Games! @pixjuegos http://play.google.com/store/apps/details?id=com.pixjuegos.inforantgames");
	pon_enlace((ancho_pantalla/4)*3,(alto_pantalla/7)*1,708,"http://www.facebook.com/dialog/feed?app_id=489131254450948&link=https://play.google.com/store/apps/details?id=com.pixjuegos.inforantgames&picture=http://www.pixjuegos.com/images/inforantgames-logo.png&name=InforAntGames%20-%20 My score&caption=I've scored "+puntos+" on InforAntGames! I dare you to beat me!&description=Get it for free on Google Play!&redirect_uri=http://www.pixjuegos.com");
	pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*6)-(alto_pantalla/14),604,100,255,4,4); //salir
	while(opcion_menu!=4) frame; end
	let_me_alone();
	delete_text(all_text);
	menu_tactil();
end

Process hormiga();
Private
	vida;
	velocidad;
	doblar;
	id_trozo;
	graph_base;
	tipo;
	lado;
	anim;
	atacando;
Begin
	num_hormigas++;
	tipo=rand(1,3);
	//tipo=1; //temp
	if(hormigas_muertas>30)
		tipo+=(hormigas_muertas/30)*10;
	end
	if(tipo>10)
		doblar=tipo/10;
		while(tipo>10) tipo-=10; end
	end
	
	graph_base=101+(tipo-1)*5;
	graph=graph_base;
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	angle=rand(0,360)*1000;
	advance(ancho_pantalla*0.8);
	z=-100;

	if(y<-100) y=-100; end
	if(y>alto_pantalla+100) y=alto_pantalla+100; end
	
	switch(tipo);
		case 1: //negras
			velocidad=3;
			fuerza=1;
			vida=2;
		end
		case 2: //rojas
			velocidad=4;
			fuerza=3;
			vida=1;
		end
		case 3: //sh
			velocidad=8;
			fuerza=5;
			vida=3;
		end
	end
	if(doblar>0)
		velocidad=velocidad*doblar;
		fuerza=fuerza*doblar;
		vida=vida*doblar;
	end

	id_trozo=id_trozos[trozo_cercano()];
	
	while(accion!=-1)
		if(trozos==0) return; end
		if(anim<10)
			anim+=velocidad;
		else
			anim=0;
			if(graph<graph_base+3) graph++; else graph=graph_base; end
		end
		if(!exists(id_trozo)) id_trozo=id_trozos[trozo_cercano()]; end
		if(collision(id_trozo))
			if(!atacando) 
				atacando=1;
				hormigas_atacando++;
			end
			id_trozo.fuerza+=fuerza;
			if(collision(type dedo))
				vida--;
				if(vida<1) accion=-1; end
			end
			angle=get_angle(id_trozo);
		else
			if(exists(id_trozo))
				angle=get_angle(id_trozo);
			end
			advance(velocidad);
			if(collision(type dedo))
				vida--;
				if(vida<1) accion=-1; end
			end
		end
		frame;
	end
	if(accion==-1)
		num_hormigas--;
		hormigas_muertas++;
		doblar++;
		puntos+=tipo*doblar*50;
		graph=graph_base+4;
		sonido(rand(4,5));
		frame(2000);
		from alpha=255 to 0 step -10; frame; end
	end
	if(atacando)
		hormigas_atacando--;
	end
End

Process trozo_tarta(num);
Private
	id_sound;
Begin
	graph=20;
	angle=(360/6)*num*1000;
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	id_trozos_centros[num]=centro_trozo();
	loop
		if(!is_playing_wav(id_sound) and collision(type hormiga))
			id_sound=play_wav(wavs[6],0);
		end
		if(x<-100 or x>ancho_pantalla+100 or y<-100 or y>alto_pantalla+100)
			break;
		end
		if(fuerza>20)
			advance(2);
			fuerza-=20;
		end
		frame;
	end
	trozos--;
	sonido(9);
	return;
	graph=0;
	loop frame; end
End

Process centro_trozo();
Begin
	angle=father.angle;
	while(exists(father))
		x=father.x;
		y=father.y;
		advance(75);
		frame;
	end
End

Process explosion();
Begin
End

Function trozo_cercano();
Private
	menor_distancia=10000;
	posible;
Begin
	x=father.x;
	y=father.y;
	from i=1 to 6;
		if(exists(id_trozos_centros[i]) and get_dist(id_trozos_centros[i])<menor_distancia)
			posible=i;
			menor_distancia=get_dist(id_trozos_centros[i]);
		end
	end
	return posible;
End

Process musica_fondo();
Begin
	loop
		while(!ops.musica) frame; end
		if(next_music!="menu" and next_music!="gameover")
			if(hormigas_atacando>0 and hormigas_atacando<5)
				next_music="ataque";
			elseif(hormigas_atacando>4)
				next_music="peligro";
			else
				next_music="tranquilo";
			end
		end
		if(!is_playing_wav(mi_canal))
			switch(next_music)
				case "menu": mi_sonido=11; end
				case "tranquilo": mi_sonido=12; end
				case "ataque": mi_sonido=13; end
				case "peligro": mi_sonido=14; end
				case "gameover": mi_sonido=15; end
			end
			if(ops.musica)
				mi_canal=play_wav(wavs[mi_sonido],0,7);
			end
		end
		frame(20);
	end
End

Function cambia_musica();
Begin
	/*from i=1 to 6;
		if(exists(id_trozos_centros[i]))
			if(id_trozos_centros[i].x<200 or id_trozos_centros[i].x>600 or 
			id_trozos_centros[i].y<100 or id_trozos_centros[i].y>300)
				next_music="peligro";
			end
		end
	end
	if(next_music!="peligro")
		from i=1 to 6;
		if(exists(id_trozos_centros[i]))
			if(id_trozos_centros[i].x<200 or id_trozos_centros[i].x>600 or 
			id_trozos_centros[i].y<100 or id_trozos_centros[i].y>300)
				next_music="peligro";
			end
		end	
	end*/
End