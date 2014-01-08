program borderpolice;

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
	arboles;
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
	inmigrantes;
	nivel;
	
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
	full_screen=true;
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
	load_fpg("fpg/borderpolice.fpg");
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
	musica(2);
	
	//ponemos el fondo
	put_screen(0,1);
	
	id_boton_menu=0;
	opcion_menu=0;
	
	loop
		//botón esc o back
		if(scan_code==102 or key(_esc) or mouse.right)
			while(scan_code==102 or key(_esc) or mouse.right) frame; end
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

		if(os_id==1003)
			if(!focus_status)
				matabotones=1;
				fade_music_off(500);
				while(is_playing_song()) frame; end
				exit();
			end
		end
		
		if(opcion_menu!=0)
			sonido(3);
			if(menu_actual==1) //principal: 1 jugar, 2 opciones, 3 creditos, 4 salir
				switch(opcion_menu)
					case 1: juego(); return; end
					case 2: cambia_menu=3; end
					case 3: cambia_menu=4; end
					case 4: exit(); end
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
				//pon_enlace(550,320,706,"http://www.pixjuegos.com");
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
		if(key(mouse.right) or key(_esc)) break; end
		if(alpha<255) alpha+=10; end
		frame;
	end
	from alpha=255 to 0 step -15; end
End

Process pon_enlace(x,y,graph,string url);
Begin
	alpha=0;
	z=-10;
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
						stop_wav(all_sound);
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
						musica(2);
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
	inmigrantes=0;

	
	graph=get_screen();
	let_me_alone();
	musica(1);
	
	clear_screen();
	controlador();
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	
	put_screen(0,10);
	
	write(fuente,10,10,0,"Score: ");
	write_int(fuente,120,10,0,&puntos);

	write(fuente,10,480,6,"Inmigrant population:    %");
	write_int(fuente,430,480,8,&inmigrantes);
	
	//write_int(fuente,10,100,6,&nivel);
	
	while(alpha>0) alpha-=10; frame; end
	timer[0]=0;
	
	arboles=0;
	while(arboles<30)
		arbol(rand(0,800),rand(130,480));
	end
	valla();
	loop
		if(mouse.left)
			while(mouse.left) frame; end
		end
		contador++;
		nivel=timer[0]/1500;
		if(nivel>10) nivel=10; end
		if(inmigrantes=>100) gameover(); return; end
		if(key(_space)) set_fps(0,0); end
		if(contador>14-nivel or !exists(type inmigrante))
			if(rand(0,5)==0 or !exists(type inmigrante))
				inmigrante();
				contador=0;
			end
		else
			contador++;
		end
		//perdida del foco en el juego
		if(os_id==1003)
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
	priority=1;
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
	graph=3;
	if(collision(type arbol)) return; end
	graph=71;
	alpha=0;
	frame(200);
End

Process gameover();
Begin
	next_music="gameover";

	musica(3);

	delete_text(all_text);
	texto_fade_in(ancho_pantalla/2,200,"THE SPANISH HAVE");
	texto_fade_in(ancho_pantalla/2,250,"CONQUERED YOUR COUNTRY!");
	while(exists(type texto_fade_in)) frame; end
	delete_text(all_text);
	x=ancho_pantalla/2;
	y=(alto_pantalla/2);
	z=-10;
	graph=501;
	write(fuente,ancho_pantalla/2,100,4,"Score: "+puntos);
	if(ops.musica)
		play_song(load_song("ogg/3.ogg"),-1);
	end
	while(mouse.left) frame; end
	opcion_menu=0;
	if(os_id==1003)
		pon_enlace(ancho_pantalla/4,(alto_pantalla/7)*1,707,"https://twitter.com/intent/tweet?text=I've scored "+puntos+" points in Border Police! @pixjuegos http://play.google.com/store/apps/details?id=com.pixjuegos.borderpolice");
		pon_enlace((ancho_pantalla/4)*3,(alto_pantalla/7)*1,708,"http://www.facebook.com/dialog/feed?app_id=489131254450948&link=https://play.google.com/store/apps/details?id=com.pixjuegos.borderpolice&picture=http://www.pixjuegos.com/images/borderpolice-logo.png&name=BorderPolice%20-%20 My score&caption=I've scored "+puntos+" on Border Police! I dare you to beat me!&description=Get it for free on Google Play!&redirect_uri=http://www.pixjuegos.com");
	end
	pon_boton_menu(ancho_pantalla/2,((alto_pantalla/7)*6)-(alto_pantalla/14),604,100,255,4,4); //salir
	while(opcion_menu!=4) frame; end
	let_me_alone();
	delete_text(all_text);
	menu_tactil();
end

Function musica(number);
Begin
	//if(!is_playing_song())
	if(ops.musica)
		unload_song(music);
		music=load_song(number+".ogg");
		play_song(load_song(number+".ogg"),-1);
	end
End

Process inmigrante();
Private
	x_inc;
	y_inc;
	estado; //0: empezando, 1: subiendo, 2: cayendo, 3: huyendo
	anim;
Begin
	graph=101;
	x=rand(20,780);
	y=-20;
	z=1;
	loop
		if(exists(type gameover)) return; end
		if(rand(0,100)==0 or y_inc==0)
			x_inc=rand(-3-nivel,3+nivel);
			y_inc=rand(1,3)+nivel;
		end

		if(x<20 or x>780) x_inc=-x_inc; end
		if(y>500) inmigrantes++; break; end
		
		anim++;
		if(anim==8) anim=0; end

		if(estado==0 or estado==3) //camina
			if(anim<4) graph=31; else graph=32; end
		elseif(estado==1) //sube
			if(anim<4) graph=21; else graph=22; end
		elseif(estado==2) //cae
			z=-10;
			graph=31;
		end

		if(estado==3) z=-y/2; end
		
		switch(estado)
			case 0:
				y++;
				if(y>80) estado++; end
			end
			case 1:
				if(anim%2==1) y--; end
				if(y<40) estado++; end
			end
			case 2:
				y+=3;
				if(y>100) estado++; end
			end
			case 3:
				x+=x_inc;
				y+=y_inc;
			end
		end

		if(collision(type dedo))
			if(estado>2)
				puntos+=100*(nivel+1); 
				sonido(4);
			else
				puntos-=500;
				if(puntos<0) puntos=0; end
				graph=51; //x roja
				sonido(16);
			end
			from alpha=255 to 0 step -15; frame; end
			return;
		end
		frame;
	end
End

Process arbol(x,y);
Begin
	z=-y/2;
	graph=102;
	size=200;
	if(collision(type arbol)) return; end
	arboles++;
	size=100;
	while(not exists(type gameover))
		frame;
	end
End

Process valla();
Begin
	graph=41;
	x=400;
	y=80;
	loop frame; end
End

Process texto_fade_in(x,y,string texto);
Begin
	graph=write_in_map(fuente,texto,4);
	from alpha=0 to 255 step 10; frame; end
	from i=0 to 60; frame; end
	from alpha=255 to 0 step -30; frame; end
	unload_map(0,graph);
End