Program pixbros;

import "mod_blendop";
import "mod_dir";
import "mod_draw";
import "mod_file";
import "mod_grproc";
import "mod_joy";
import "mod_key";
import "mod_map";
import "mod_math";
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

Const
	piensa=1;
	anda=2;
	baja=3;
	sube=4;
	atrapado=5;
	chutado=6;
	disparando=7;
	chilena=8;
	cae=9;
	gira=10;
	dispara=11;
	especial=12;
	muere=-1;
	num_mundos=29;
End

Global
	arcade_mode=0;
	
	bitscolor=32;
	njoys;
	posibles_jugadores;
	debuj;
	struct p[5];
		botones[7];
		vidas=5; puntos; velocidad=0; lejos=0; tocho=0; invencibilidad; muneco; control; juega; identificador;
	end
	joysticks[10];
	hayjefe;
	Struct ops;
		byte lenguaje=100; 	// 0 = inglés, 1 = español, 2 = italiano, 3 = alemán, 4 = francés, 5 = japones
		byte musica=1;
		byte sonido=1;
		int ventana=1;
		byte dificultad=1; //0,1,2
	End
	string lang_suffix;
	wavs[50]; //sonidos del juego
	fpg_intro;
	fpg_general;
	fpg_items;
	fpg_enemigos;
	fpg_menu;
	fpg_menu2;
	fpg_pix;
	fpg_pux;
	fpg_pax;
	fpg_jefes;
	fnt_puntos;
	fnt_texto1;
	fnt_intro;

	mundo=1;
	ready=1;

	cancionsonando;

	tiempo_hurry;
	tiempo_burbujas;
	burbujasrayo;
	burbujasagua;
	burbujasfuego;
	rebotesmax;
	muneco1x;
	muneco1y;
	muneco2x;
	muneco2y;
	muneco3x;
	muneco3y;

	grafnivel;
	masknivel;
	color_colision;
	color_pendiente;
	id_muneco1; id_muneco1_col;
	id_muneco2; id_muneco2_col;
	id_muneco3; id_muneco3_col;
	menu_elec; //eleccion en el menu principal
	matabichos;

	string savegamedir;
	string developerpath="/.PiXJuegos/PiXBros/";

	tipo_nivel; //0=sin scroll, 1=con scroll
	ancho_nivel;
	alto_nivel;

	gravedad=3; //STANDARD 3, 5 NIVEL MARIO
	//modos especiales
	modo_fraticidio;
Local
	caca084a;
	caca084b;
	ancho;
	alto;
	grav;
	saltando;
	incx;
	incy;
	accion;
	jugador;
	id_enemigo;
	nieve;
	anim;
	i;
	j;
	duracion;
	tipo;
Private
	string env_lang;
	string argumentos[10];
	fp;
	string cadena_lenguaje;
	string cadena_lenguaje_bien;
	int primera_letra_lenguaje;
Begin
	if(argc>0) if(argv[1]=="arcade") arcade_mode=1; end end

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
		load(savegamedir+"opciones.dat",ops);
		full_screen=!ops.ventana;
	end

//	if(ops.lenguaje==100)
		//PODEMOS ADIVINAR EL LENGUAJE! :D
		if(os_id==0) //windows
			//qué lenguaje lleva este windows?
			if(!fexists(getenv("TEMP")+"\lang.txt")) exec(1,"language.bat",0,0); end
			fp=fopen(getenv("TEMP")+"\lang.txt",O_READ);
			if(fp) 
				cadena_lenguaje=fgets(fp);
				fclose(fp);
			end
			primera_letra_lenguaje=find(cadena_lenguaje,"0",0);
			cadena_lenguaje_bien=""+cadena_lenguaje[primera_letra_lenguaje]+cadena_lenguaje[primera_letra_lenguaje+1]+cadena_lenguaje[primera_letra_lenguaje+2]+cadena_lenguaje[primera_letra_lenguaje+3];
			ops.lenguaje=0;
			switch(cadena_lenguaje_bien)
				case "0c0a": ops.lenguaje=1; end
				case "040a": ops.lenguaje=1; end
				case "0410": ops.lenguaje=2; end
				case "0407": ops.lenguaje=3; end
				case "040c": ops.lenguaje=4; end
			end
		end
		if(os_id==1) //linux
			// Aportado por Miry: Se pone aquí para evitar que use el lenguaje ya asignado en una versión anterior
			env_lang=getenv("LANG");
			env_lang=""+env_lang[0]+env_lang[1];
			ops.lenguaje=0;
			switch(env_lang)
				case "es": ops.lenguaje=1; end
				case "it": ops.lenguaje=2; end
				case "de": ops.lenguaje=3; end
				case "fr": ops.lenguaje=4; end
			end
			//-------------------
		end
		if(os_id==os_caanoo)
			fp=fopen("/mnt/ubifs/usr/gp2x/common.ini",O_READ);
			if(fp)
				while(!feof(fp))
					cadena_lenguaje=fgets(fp);
					if(find(cadena_lenguaje,"language")>-1)
						env_lang=""+cadena_lenguaje[11]+cadena_lenguaje[12];
						break;
					end
				end
				fclose(fp);
			end
			ops.lenguaje=0;
			switch(env_lang)
				case "es": ops.lenguaje=1; end
				case "it": ops.lenguaje=2; end
				case "de": ops.lenguaje=3; end
				case "fr": ops.lenguaje=4; end
			end
		end
//	end
	switch(ops.lenguaje)
		case 0:	lang_suffix="en"; end
		case 1:	lang_suffix="es"; end
		case 2:	lang_suffix="it"; end
		case 3:	lang_suffix="de"; end
		case 4:	lang_suffix="fr"; end
	end	
	if(os_id==os_caanoo or os_id==os_wii) bitscolor=16; end
	if(os_id==os_caanoo) scale_resolution=03200240; end
	if(arcade_mode) full_screen=true; scale_resolution=08000600; end
	set_mode(640,480,bitscolor);
	set_fps(40,9);
	frame;

	configurar_controles();
	
	fpg_general=load_fpg("fpg/general.fpg");
	fpg_menu=load_fpg("fpg/menu.fpg");
	if(lang_suffix!="") fpg_menu2=load_fpg("fpg/menu-"+lang_suffix+".fpg"); end
	fpg_items=load_fpg("fpg/items.fpg");
	fpg_enemigos=load_fpg("fpg/enemigos.fpg");
	fpg_pix=load_fpg("fpg/pix.fpg");
	fpg_pux=load_fpg("fpg/pux.fpg");
	fpg_pax=load_fpg("fpg/pax.fpg");
	if(lang_suffix!="") fpg_intro=load_fpg("fpg/intro-"+lang_suffix+".fpg"); end
	fpg_jefes=load_fpg("fpg/jefes.fpg");
	fnt_puntos=load_fnt("fnt/puntos.fnt");
	fnt_texto1=load_fnt("fnt/texto1.fnt");
	fnt_intro=load_fnt("fnt/intro.fnt");
	carga_sonidos();
	frame;
	set_center(fpg_pix,8,26,33);
	set_center(fpg_pux,8,26,33);
	set_center(fpg_pax,8,26,33);
	if(ops.lenguaje==100)
		elige_lenguaje(); 
	end
	logo_pixjuegos();
end

process logo_pixjuegos();
begin
	let_me_alone();
	delete_text(0);
	x=320;
	y=240;
	z=-10;
	controlador(0);
	from i=0 to 2;
		if(!(os_id!=os_wii and i==1))
			graph=30+i;
			while(p[0].botones[4] or p[0].botones[5]) frame; end
			from alpha=50 to 255 step 5;
				if(p[0].botones[4] or p[0].botones[5]) break; end 
				frame;
			end
			timer[0]=0;
			while(timer[0]<300) 
				if(p[0].botones[4] or p[0].botones[5]) break; end 
				frame; 
			end
			while(p[0].botones[4] or p[0].botones[5]) frame; end
			from alpha=alpha to 0 step -20;
				frame;
			end
		end
	end
	
	intro();
end

process nivel();
private
	descriptor_nivel;
	char char_mander; //jajajajaja
	string string_mander; // ¬¬
	datosvarios[5];
	ii;
	screenshotpantalla;
begin
	x=320;
	y=240;
	z=-512;
	graph=get_screen();
	ready=0;
	hayjefe=0;
	if(tipo_nivel==1) stop_Scroll(0); end
	delete_text(0);
	let_me_alone();
	stop_wav(0);
	guardar_partida();
	frame;
	unload_map(0,masknivel);
	unload_map(0,grafnivel);
	frame;
	masknivel=load_png("niveles/nivel"+mundo+"mask.png");
	grafnivel=load_png("niveles/nivel"+mundo+".png");
	ancho_nivel=graphic_info(0,grafnivel,g_width);
	alto_nivel=graphic_info(0,grafnivel,g_height);

	if(ancho_nivel>640 or alto_nivel>480)
		tipo_nivel=1;
		start_scroll(0,0,grafnivel,0,0,0);
		scroll.camera=camara();
	else
		tipo_nivel=0;
		put_screen(0,grafnivel);
	end

	color_pendiente=map_get_pixel(0,masknivel,1,0);
	color_colision=map_get_pixel(0,masknivel,0,0);
	descriptor_nivel=fopen("niveles/nivel"+mundo+"desc.lvl",O_READ);
	tiempo_hurry=atoi(fgets(descriptor_nivel))*60;
	tiempo_burbujas=atoi(fgets(descriptor_nivel))*60;
	burbujasrayo=atoi(fgets(descriptor_nivel));
	burbujasagua=atoi(fgets(descriptor_nivel));
	burbujasfuego=atoi(fgets(descriptor_nivel));
	rebotesmax=atoi(fgets(descriptor_nivel));
	frame;
	repeat
		i=0;
		string_mander=fgets(descriptor_nivel);
		if(string_mander[0]!="/")
			if(string_mander[0]=="m" and string_mander[1]=="u" and string_mander[2]=="n" and string_mander[3]=="e" and string_mander[4]=="c" and string_mander[5]=="o")
				datosvarios[0]=atoi(string_mander[7]);
				if(datosvarios[0]==1)
					muneco1x=atoi(""+string_mander[9]+string_mander[10]+string_mander[11]);
					muneco1y=atoi(""+string_mander[13]+string_mander[14]+string_mander[15]);
					from ii=1 to 3;
						if(p[ii].muneco==1 and p[ii].juega) id_muneco1=muneco1(ii); end
					end
				end
				if(datosvarios[0]==2)
					muneco2x=atoi(""+string_mander[9]+string_mander[10]+string_mander[11]);
					muneco2y=atoi(""+string_mander[13]+string_mander[14]+string_mander[15]);
					from ii=1 to 3;
						if(p[ii].muneco==2 and p[ii].juega) id_muneco2=muneco2(ii); end
					end
				end
				if(datosvarios[0]==3)
					muneco3x=atoi(""+string_mander[9]+string_mander[10]+string_mander[11]);
					muneco3y=atoi(""+string_mander[13]+string_mander[14]+string_mander[15]);
					from ii=1 to 3;
						if(p[ii].muneco==3 and p[ii].juega) id_muneco3=muneco3(ii); end
					end
				end
			end
			if(string_mander[0]=="e" and string_mander[1]=="n" and string_mander[2]=="e" and string_mander[3]=="m" and string_mander[4]=="i" and string_mander[5]=="g" and string_mander[6]=="o")
				datosvarios[0]=atoi(""+string_mander[8]+string_mander[9]);
				datosvarios[1]=atoi(""+string_mander[11]+string_mander[12]+string_mander[13]);
				datosvarios[2]=atoi(""+string_mander[15]+string_mander[16]+string_mander[17]);
				enemigo(datosvarios[0],datosvarios[1],datosvarios[2]);
			end
		end
	until(feof(descriptor_nivel))
	fclose(descriptor_nivel);
	frame;
	marcadores();
	frame;
	//transiciones
//	if(!net) set_center(0,graph,640,0); x=640; y=0; loop grav++; angle+=grav*1000; if(angle>90000) break; end frame;	end end
//	set_center(0,graph,640,0); x=640; y=0; loop grav++; angle+=grav*1000; if(angle>90000) break; end frame;	end 
	switch(rand(0,5))
		case 0:
			set_center(0,graph,640,0); x=640; y=0; loop grav++; angle+=grav*1000; if(angle>90000) break; end frame;	end
		end
		case 1:
			x=320; y=240;
			while(alpha>5) alpha-=5; frame; end
		end
		case 2:
			x=320; y=240;
			while(y<480+240) grav++; y+=grav; frame; end
		end
		case 3:
			x=320; y=240;
			size_y=101;
			while(size_y!=1) size_y-=10; frame; end
			while(size_x!=0) size_x-=10; frame; end
		end
	end
	frame;
	if(mundo==10 or mundo==20 or mundo==30 or mundo==40 or mundo==50)
		musica(100);
		jefe(mundo/10);
	else
		if(mundo=>1 and mundo<10) musica(1); end
		if(mundo=>11 and mundo<20) musica(3); end
		if(mundo=>21 and mundo<30) musica(4); end
		if(mundo=>31 and mundo<40) musica(5); end
	end
	//screenshotpantalla=get_screen();
	//save_png(0,screenshotpantalla,savegamedir+"partida.png");
	//unload_map(0,screenshotpantalla);
	ready=1;
	frame;
	unload_map(0,graph);
	/* utilizando el controlador masivo 0 no es necesario tener uno para cada jugador
	if(posibles_jugadores>1)
		if(p[1].juega==0) controlador(1); end
		if(p[2].juega==0) controlador(2); end
		if(p[3].juega==0) controlador(3); end
	end*/
	controlador(0);
	loop
		if(posibles_jugadores>1)
			if(p[1].juega==0 and p[1].botones[4]==1 and p[1].botones[5]==1) elecpersonaje_ingame(1); end
			if(p[2].juega==0 and posibles_jugadores and p[2].botones[4]==1 and p[2].botones[5]==1) elecpersonaje_ingame(2); end
			if(p[3].juega==0 and posibles_jugadores>2 and p[3].botones[4]==1 and p[3].botones[5]==1) elecpersonaje_ingame(3); end
		end
		if(!exists(type enemigo) and !exists(type item) and !exists(type enemigo_lanzado) and !exists(type boladeenemigos) and hayjefe==0)
			if(mundo<num_mundos) mundo++; else ganar(); end
			nivel();
		end
		from ii=1 to 3;
			if(p[ii].juega)
				if(!exists(p[ii].identificador))
					if(p[ii].vidas>0)
						switch(p[ii].muneco)
							case 1:	id_muneco1=muneco1(ii);	end
							case 2:	id_muneco2=muneco2(ii);	end
							case 3:	id_muneco3=muneco3(ii);	end
						end
						p[ii].vidas--;
					else
						p[ii].juega=0;
					end
				end
			end
		end
		if(p[1].juega==0 and p[2].juega==0 and p[3].juega==0)
			frame(3000);
			game_over();
		end
      	if(p[0].botones[7])
			while(p[0].botones[7]) frame; end
			let_me_alone();
			clear_screen();
			menu();
			return;
	    end
		if(key(_k) and debuj)
			matabichos=1;
		else
			matabichos=0;
		end
		frame;
	end
end

Process camara();
Private
	xxx[3];
	yyy[3];
	jugadores;
Begin
	loop
		jugadores=0;
		from i=1 to 3;
			if(p[i].juega)
				jugadores++;
				if(exists(p[i].identificador))
					xxx[i]=p[i].identificador.x;
					yyy[i]=p[i].identificador.y;
				end
			end
		end
		xxx[0]=xxx[1]+xxx[2]+xxx[3];
		yyy[0]=yyy[1]+yyy[2]+yyy[3];
		switch(jugadores)
			case 1:
				x=xxx[0];
				y=yyy[0];
			end			
			case 2:
				x=xxx[0]/2;
				y=yyy[0]/2;
			end
			case 3:
				x=xxx[0]/3;
				y=yyy[0]/3;
			end
		end
		frame;
	end
End

Process disparo1();
Begin
	if(tipo_nivel==1) ctype=c_scroll; end	
	sonido(4);
	x=father.x;
	y=father.y+10;
	jugador=father.jugador;
	flags=!father.flags;
	z=-1;
	graph=2;
	grav=-10;
	if(!p[jugador].tocho) size=80; end
	loop
		if(i>25 and p[jugador].tocho) break;  end
		if(i>15 and !p[jugador].tocho) break; end

		if(grav==0) incy=0; else incy=grav; end
		if(p[jugador].lejos)
			if(flags==1)
				incx=20;
			else
				incx=-20;
			end
		else
			if(flags==1)
				incx=10;
			else
				incx=-10;
			end
		end
		if(incx!=0)
			while(incx>0 and map_get_pixel(0,masknivel,x+1,y)!=color_colision)
				incx--;
				x++;
			end
			while(incx<0 and map_get_pixel(0,masknivel,x-1,y)!=color_colision)
				incx++;
				x--;
			end
			incx=0;
		end

		if(incy!=0)
			while(incy>0 and map_get_pixel(0,masknivel,x,y+(alto/2))!=color_colision)
				incy--;
				y++;
			end
			while(incy<0)
				incy++;
				y--;
			end
			incy=0;
		end

		if(id_enemigo=collision(type enemigo))
			if(id_enemigo.accion!=atrapado and id_enemigo!=muere)
				if(id_enemigo.tipo==5 and id_enemigo.i==0)
					id_enemigo.i=1;
					tronco(id_enemigo.x,id_enemigo.y);
					explosion_con_humo(id_enemigo.x,id_enemigo.y);
					id_enemigo.y-=200;
					id_enemigo.accion=cae;
				else
					boladenieve(id_enemigo);
					signal(id,s_kill);
				end
			end
		end

		if(id_enemigo=collision(type boladenieve))
			if(id_enemigo.accion!=muere or id_enemigo.accion!=atrapado)
				if(p[jugador].tocho)
					id_enemigo.nieve+=2;
					id_enemigo.i=0;
				else
					id_enemigo.nieve++;
					id_enemigo.i=0;
				end
				signal(id,s_kill);
			end
		end

	// CON TRES PARES DE HUEVOS: PODEMOS METER EN BOLAS DE NIEVE A LOS OTROS PERSONAJES!!!!
		if(modo_fraticidio)
			if(id_enemigo=collision(type muneco2))
				if(id_enemigo.accion!=atrapado and id_enemigo!=muere)
					boladenieve(id_enemigo);
					signal(id,s_kill);
				end
			end
	
			if(id_enemigo=collision(type muneco3))
				if(id_enemigo.accion!=atrapado and id_enemigo!=muere)
					boladenieve(id_enemigo);
					signal(id,s_kill);
				end
			end
		end
	/// ---------------------------------------

		if(grav>0 and (map_get_pixel(0,masknivel,x,y)==color_colision or map_get_pixel(0,masknivel,x+1,y)==color_colision or map_get_pixel(0,masknivel,x-1,y)==color_colision) or map_get_pixel(0,masknivel,x,y)==color_pendiente) signal(id,s_kill); end
		i++;
		grav+=2;
		frame;
	end
End

Process boladenieve(id_enemigo);
Private
	id_bola;
	id_col;
	combo;
	muneco1_enganchado;
	muneco2_enganchado;
	muneco3_enganchado;
	rebotes;
	graf;
	ipendiente;
	lanzada;
	pendientes_y;
	cambio_y;
Begin
	if(tipo_nivel==1) ctype=c_scroll; end	
	nieve=1;
	file=fpg_general;
	graph=20;
	id_enemigo.accion=atrapado;
	x=id_enemigo.x;
	alto=graphic_info(file,graph,g_height);
	y=id_enemigo.y+id_enemigo.alto/2-alto/2-1;
	alpha=0;
	loop
		if(nieve<0) nieve=0; end
		if(nieve>8) nieve=8; end
		alpha=0;
		ancho=graphic_info(file,graph,g_width);
		alto=graphic_info(file,graph,g_height);
		z=-2;
		while(accion==atrapado)
			id_enemigo.x=x;
			id_enemigo.y=y+(alto/2)-(id_enemigo.alto/2);
			id_enemigo.grav=0;
			id_enemigo.alpha=0;
			id_enemigo.size=size;
			boladenievegraph(graf);
			frame;
		end
		if(accion!=chutado)
			id_enemigo.size=100;
			id_enemigo.x=x;
			id_enemigo.y=y+(alto/2)-(id_enemigo.alto/2);
			id_enemigo.grav=0;
			rebotes=0;
			if(accion==muere) break; end
			if(i==60 and ops.dificultad==0 or
			i==30 and ops.dificultad==1 or
			i==20 and ops.dificultad==2) nieve--; i=0; else i++; end
			if(id_bola=collision(type boladenieve))
				if(fget_dist(x,y,id_bola.x,id_bola.y)<50 and id>id_bola)
					if(id_bola.x=<x)
						id_bola.incx-=3;
						incx+=3;
					else
						id_bola.incx+=3;
						incx-=3;
					end
				end
			end
			switch(nieve);
				case -3..0:
					id_enemigo.accion=piensa;
					graf=0;
					return;
				end
				case 1:
					graf=12;
				end
				case 2:
					graf=13;
				end
				case 3:
					graf=14;
				end
				case 4:
					graf=15;
				end
				case 5..10:
					id_enemigo.size=0;
					graf=16;
					if(collision(type muneco1))
						if(id_muneco1.y<y-((alto/5)*4) and id_muneco1.grav>0)
							id_muneco1.y=y-((alto/5)*4)-2;
							id_muneco1.grav=0;
							id_muneco1.saltando=0;
						elseif(id_muneco1.x<x)
							id_muneco1.x=x-(ancho/5)*4;
							incx=4;
						elseif(id_muneco1.x>x)
							id_muneco1.x=x+(ancho/5)*4;
							incx=-4;
						end
						if(id_muneco1.y>y and id_muneco1.saltando==1 and id_muneco1.grav<0)
							grav=-10;
							y-=2;
						end
						if(p[id_muneco1.jugador].botones[4] and ((id_muneco1.flags==0 and id_muneco1.x<x) or (id_muneco1.flags==1 and id_muneco1.x>x)))
							if(id_muneco1.flags==1)
								flags=0;
							else
								flags=1;
							end
							accion=chutado;
							if(grav!=0 and id_muneco1.saltando)
								flags=!flags;
								id_muneco1.accion=chilena;
								grav-=15;
							end
						end
					end
					if(collision(type muneco2))
						if(id_muneco2.y<y)
							id_muneco2.y=y-alto+1;
							id_muneco2.grav=0;
							id_muneco2.saltando=0;
						elseif(id_muneco2.y>y and id_muneco2.saltando==1 and id_muneco2.grav<0)
							grav=-10;
							y-=2;
						elseif(id_muneco2.x<x and id_muneco2.x>x-(ancho/5)*3)
							id_muneco2.x=x-(ancho/5)*3;
						elseif(id_muneco2.x>x and id_muneco2.x<x+(ancho/5)*3)
							id_muneco2.x=x+(ancho/5)*3;
						end
					end
					if(collision(type muneco3))
						if(id_muneco3.y<y)
							id_muneco3.y=y-alto+1;
							id_muneco3.grav=0;
							id_muneco3.saltando=0;
						elseif(id_muneco3.y>y and id_muneco3.saltando==1 and id_muneco3.grav<0)
							grav=-10;
							y-=2;
						elseif(id_muneco3.x<x and id_muneco3.x>x-(ancho/5)*3)
							id_muneco3.x=x-(ancho/5)*3;
						elseif(id_muneco3.x>x and id_muneco3.x<x+(ancho/5)*3)
							id_muneco3.x=x+(ancho/5)*3;
						end
					end
				end
			end
		else
			id_enemigo.x=x;
			id_enemigo.y=y;
			id_enemigo.grav=0;

			if(lanzada<20) lanzada++; end
			//if(x>ancho_nivel-(ancho/2)) flags=0; if(y<alto_nivel-65) rebotes++; else accion=muere; end x=ancho_nivel-ancho/2; end
			//if(x<18+ancho/2) flags=1; if(y<alto_nivel-65) rebotes++; else accion=muere; end x=18+ancho/2; end

			if(flags==1) incx=12; else incx=-12; end
			if(collision(type muneco1) and lanzada>5)
				if(p[id_muneco1.jugador].invencibilidad==0 and id_muneco1.accion!=atrapado and id_muneco1.accion!=chilena and id_muneco1.accion!=muere)
					muneco1_enganchado=1;
				end
			end
	 		if(collision(type muneco2))
				if(p[id_muneco2.jugador].invencibilidad==0 and id_muneco2.accion!=atrapado and id_muneco2.accion!=muere)
				muneco2_enganchado=1;
				end
			end
	 		if(collision(type muneco3))
				if(p[id_muneco3.jugador].invencibilidad==0 and id_muneco3.accion!=atrapado and id_muneco3.accion!=muere)
				muneco3_enganchado=1;
				end
			end
			
			if(id_bola=collision(type boladenieve))
				if(id_bola.nieve=>5 and id_bola.accion!=muere)
					id_bola.flags=flags;
					id_bola.accion=chutado;
				end
				if(id_bola.nieve<5)
					id_bola.accion=muere;
					combo++;
				end
			end
			
			if(id_bola=collision(type enemigo))
				if(id_bola.accion!=atrapado)
					if(id_bola.tipo==5 and id_bola.i==0)
						id_bola.i=1;
						tronco(id_bola.x,id_bola.y);
						explosion_con_humo(id_bola.x,id_bola.y);
						id_bola.y-=200;
						id_bola.accion=cae;
					else
						id_bola.accion=muere;
						enemigo_lanzado(id_bola.x,id_bola.y,id_bola.tipo,rand(0,1));
					end
				end
			end
			
			while(id_bola=collision(type burbuja))
				if(id_bola.accion!=atrapado)
					id_bola.accion=muere;
				else
					break;
				end
			end
		end

			//pendientes
			from pendientes_y=y to y+alto;
				if(map_get_pixel(0,masknivel,x,pendientes_y+(alto/2))==color_pendiente) 
					y=pendientes_y;
					break;
				end
			end

			// inicio movimiento!
			if(map_get_pixel(0,masknivel,x,y+(alto/2))==color_colision or map_get_pixel(0,masknivel,x,y+(alto/2))==color_pendiente)
				if(grav>15)
					grav=-10;
					y-=2;
				else
					grav=0;
				end
				saltando=0;
			else
				grav+=2;
				saltando=1;
			end

			incy=grav;

			if(grav<0) grav++; end
			if(grav>16) grav=16; end
			if(grav!=0) cambio_y=0; end
			
			//if(flags==1 and (map_get_pixel(0,masknivel,x+(ancho/2),y)==color_colision or map_get_pixel(0,masknivel,x+1,y)==color_colision) or x>ancho_nivel-ancho/2)
			if(flags==1 and (map_get_pixel(0,masknivel,x+(ancho/2),y)==color_colision or map_get_pixel(0,masknivel,x+1,y)==color_colision))
					//if(y<alto_nivel-65) rebotes++; else accion=muere; end
					rebotes++;
					cambio_y++;
					flags=0;
			end
			//if(flags==0 and (map_get_pixel(0,masknivel,x-(ancho/2),y)==color_colision or map_get_pixel(0,masknivel,x-1,y)==color_colision) or x<18+ancho/2)
			if(flags==0 and (map_get_pixel(0,masknivel,x-(ancho/2),y)==color_colision or map_get_pixel(0,masknivel,x-1,y)==color_colision))
					//if(y<alto_nivel-65) rebotes++; else accion=muere; end
					rebotes++;
					cambio_y++;
					flags=1;
			end

			if(rebotes>rebotesmax or cambio_y==2)
				frame;
				break;
			end

			if(incx!=0)
				while(incx>0 and map_get_pixel(0,masknivel,x+1,y)!=color_colision)
					incx--;
					x++;
					if(map_get_pixel(0,masknivel,x,y+(alto/2)+1)==color_pendiente)
						y++;
					end
					if(map_get_pixel(0,masknivel,x,y+(alto/2)-1)==color_pendiente)
						y--;
					end
				end
				while(incx<0 and map_get_pixel(0,masknivel,x-1,y)!=color_colision)
					incx++;
					x--;
					if(map_get_pixel(0,masknivel,x,y+(alto/2)+1)==color_pendiente)
						y++;
					end
					if(map_get_pixel(0,masknivel,x,y+(alto/2)-1)==color_pendiente)
						y--;
					end
				end
				incx=0;
			end
			if(incy!=0)
				while(incy>0 and map_get_pixel(0,masknivel,x,y+(alto/2))!=color_colision)
					incy--;
					y++;
				end
				while(incy<0)
					incy++;
					y--;
				end
				incy=0;
			end
			if(y>alto_nivel-alto/2) y=-alto/2; end
			// fin movimiento!

			if(muneco1_enganchado)
				if(id_muneco1.accion!=muere) 
					id_muneco1.x=x;	id_muneco1.y=y;	id_muneco1.grav=0; id_muneco1.accion=atrapado;
					if(flags==0) id_muneco1.angle+=15000; else id_muneco1.angle-=15000; end
					if(p[id_muneco1.jugador].botones[5])
						id_muneco1.grav=-20; id_muneco1.y-=2; muneco1_enganchado=0;
						p[id_muneco1.jugador].invencibilidad=-60; id_muneco1.accion=0;
					end
				else
					muneco1_enganchado=0;
				end
			end
			if(muneco2_enganchado)
				if(id_muneco2.accion!=muere) 
					id_muneco2.x=x;	id_muneco2.y=y;	id_muneco2.grav=0; id_muneco2.accion=atrapado;
					if(flags==0) id_muneco2.angle+=15000; else id_muneco2.angle-=15000; end
					if(p[id_muneco2.jugador].botones[5])
						id_muneco2.grav=-20; id_muneco2.y-=2; muneco2_enganchado=0;
						p[id_muneco2.jugador].invencibilidad=-60; id_muneco2.accion=0;
					end
				else
					muneco2_enganchado=0;
				end
			end
			if(muneco3_enganchado)
				if(id_muneco3.accion!=muere) 
					id_muneco3.x=x;	id_muneco3.y=y;	id_muneco3.grav=0; id_muneco3.accion=atrapado;
					if(flags==0) id_muneco3.angle+=15000; else id_muneco3.angle-=15000; end
					if(p[id_muneco3.jugador].botones[5])
						id_muneco3.grav=-20; id_muneco3.y-=2; muneco3_enganchado=0;
						p[id_muneco3.jugador].invencibilidad=-60; id_muneco3.accion=0;
					end
				else
					muneco3_enganchado=0;
				end
			end


		boladenievegraph(graf);
		frame;
	end
	if(id_enemigo!=0)
		if(id_enemigo.accion!=muere)
			id_enemigo.accion=muere;
		end
	end
	if(muneco1_enganchado)
		id_muneco1.x=x;	id_muneco1.y=y-2;
		id_muneco1.grav=-20; muneco1_enganchado=0;
		p[id_muneco1.jugador].invencibilidad=-60; id_muneco1.accion=0;
	end
	if(muneco2_enganchado)
		id_muneco2.x=x;	id_muneco2.y=y-2;
		id_muneco2.grav=-20; muneco2_enganchado=0;
		p[id_muneco2.jugador].invencibilidad=-60; id_muneco2.accion=0;
	end
	if(muneco3_enganchado)
		id_muneco3.x=x;	id_muneco3.y=y-2;
		id_muneco3.grav=-20; muneco3_enganchado=0;
		p[id_muneco3.jugador].invencibilidad=-60; id_muneco3.accion=0;
	end
	frame;
End

Process burbuja(id_enemigo);
Private
	id_bola;
Local
	direccion; //1: arriba, 2: derecha, 3: izquierda, 4: abajo
	petar;
Begin
	if(tipo_nivel==1) ctype=c_scroll; end	
	if(id_enemigo!=0)
		y=id_enemigo.y;
		x=id_enemigo.x;
		z=id_enemigo.z-1;
		id_enemigo.accion=atrapado;
		if(id_enemigo==(type enemigo)) id_enemigo.alpha=128; end
		alpha=128;
	else
		y=father.y;
		x=father.x;
		z=father.z-1;
	end
	if(hayjefe and id_enemigo!=0) graph=4; else graph=3; end
	ancho=graphic_info(file,graph,g_width);
	alto=graphic_info(file,graph,g_height);

	loop
		duracion++;
		if(duracion>tiempo_burbujas-120)
			burbujaroja((120-(tiempo_burbujas-duracion))*2);
		end
		if(duracion==tiempo_burbujas)
			if(id_enemigo!=0)
				id_enemigo.accion=cae; id_enemigo.alpha=255; id_enemigo.angle=0;
				id_enemigo.grav=0; id_enemigo.incx=0; id_enemigo.incy=0;
				id_enemigo.size=100; frame; id_enemigo=0;
			end
			break;
		end
		//falta implementar las corrientes de aire
		switch(direccion)
			case 0:
				direccion=1;
			end
			case 1:
				if((map_get_pixel(0,masknivel,x,y-(alto/2))!=color_colision or map_get_pixel(0,masknivel,x-(ancho/2),y-(alto/2))!=color_colision or map_get_pixel(0,masknivel,x+(ancho/2),y-(alto/2))!=color_colision) or y>460)
					incy=-2;
				else
					if(x<ancho_nivel/2) direccion=2; else direccion=3; end
				end
			end
			case 2:
				if(map_get_pixel(0,masknivel,x,y-(alto/2))==color_colision or map_get_pixel(0,masknivel,x-(ancho/2),y-(alto/2))!=color_colision or map_get_pixel(0,masknivel,x+(ancho/2),y-(alto/2))==color_colision)
					if(map_get_pixel(0,masknivel,x+(ancho/2),y)!=color_colision or map_get_pixel(0,masknivel,x+(ancho/2),y-(alto/2)+1)!=color_colision or map_get_pixel(0,masknivel,x+(ancho/2),y+(alto/2)-1)!=color_colision)
						incx=2;
					else
						direccion=3;
					end
				else
					incx=2;
					direccion=1;
				end
			end
			case 3:
				if(map_get_pixel(0,masknivel,x,y-(alto/2))==color_colision or map_get_pixel(0,masknivel,x-(ancho/2),y-(alto/2))==color_colision or map_get_pixel(0,masknivel,x+(ancho/2),y-(alto/2))==color_colision)
					if(map_get_pixel(0,masknivel,x-(ancho/2),y)!=color_colision or map_get_pixel(0,masknivel,x-(ancho/2),y-(alto/2)+1)!=color_colision or map_get_pixel(0,masknivel,x-(ancho/2),y+(alto/2)-1)!=color_colision)
						incx=-2;
					else
						direccion=2;
					end
				else
					incx=-2;
					direccion=1;
				end
			end
			case 4:
				if(map_get_pixel(0,masknivel,x,y+(alto/2))!=color_colision or map_get_pixel(0,masknivel,x-(ancho/2),y+(alto/2))!=color_colision or map_get_pixel(0,masknivel,x+(ancho/2),y+(alto/2))!=color_colision)
					incy=2;
				else
					if(x<ancho_nivel/2) direccion=3; else direccion=2; end
				end
			end
		end
		if(id_bola=collision(type burbuja))
			if(id>id_bola.id)
				if(x>id_bola.x)
					incx+=2;
					id_bola.incx-=2;
				else
					incx-=2;
					id_bola.incx+=2;
				end
			end
		end
		if(id_bola=collision(type disparo2))
			if(id>id_bola.id)
				if(x>id_bola.x)
					incx+=2;
					id_bola.incx-=2;
				else
					incx-=2;
					id_bola.incx+=2;
				end
			end
		end

		if(collision(type muneco1))
			if(id_muneco1.accion!=muere and id_muneco1.accion!=atrapado)
				if(id_muneco1.y<y-alto/2 and p[id_muneco1.jugador].botones[5])
					id_muneco1.grav=-17;
				elseif(id_muneco1.x<x)
					incx=3;
				else
					incx=-3;
				end
			end
		end
		if(collision(type muneco3))
			if(id_muneco3.accion!=muere and id_muneco3.accion!=atrapado)
				if(id_muneco3.y<y-alto/2 and p[id_muneco3.jugador].botones[5])
					id_muneco3.grav=-17;
				elseif(id_muneco3.x<x)
					incx=3;
				else
					incx=-3;
				end
			end
		end
		if(collision(type muneco2))
			if(id_muneco2.y<y-alto/2)
				if(p[id_muneco2.jugador].botones[5])
					id_muneco2.grav=-17;
				else
					accion=muere;
				end
			elseif(id_muneco2.x<=x)
				if(fget_dist(x,y,id_muneco2.x,id_muneco2.y)<40)
					accion=muere;
				else
					incx=8;
				end
			else
				if(fget_dist(x,y,id_muneco2.x,id_muneco2.y)<40)
					accion=muere;
				else
					incx=-8;
				end
			end
		end

		if(id_enemigo!=0)
			id_enemigo.accion=atrapado;
			id_enemigo.x=x;
			id_enemigo.y=y;
			id_enemigo.alpha=128;
			id_enemigo.size=50;
			id_enemigo.angle+=1000;
			id_enemigo.grav=0;
			if(accion==muere)
				id_enemigo.accion=muere;
				enemigo_lanzado(id_enemigo.x,id_enemigo.y,id_enemigo.tipo,rand(1,0));
			end
		end
		if(accion==muere)
			if(hayjefe and id_enemigo!=0) burbujarayo(x,y,0); burbujarayo(x,y,1); burbujarayo(x,y,2); burbujarayo(x,y,3); end
			sonido(6);
			break;
		end
		from j=x to x-ancho/3 step -1;
			if(map_get_pixel(0,masknivel,j,y+(alto/2)-1)==color_colision) x+=x-j; break; end
		end
		from j=x to x+ancho/3 step 1;
			if(map_get_pixel(0,masknivel,j,y+(alto/2)-1)==color_colision) x-=j-x; break; end
		end
		if(incx!=0)
			while(incx>0 and (map_get_pixel(0,masknivel,x+(ancho/2),y)!=color_colision and map_get_pixel(0,masknivel,x+(ancho/2),y-(alto/2)+1)!=color_colision and map_get_pixel(0,masknivel,x+(ancho/2),y+(alto/2)-1)!=color_colision))
				incx--;
				x++;
			end
			while(incx<0 and (map_get_pixel(0,masknivel,x-(ancho/2),y)!=color_colision and map_get_pixel(0,masknivel,x-(ancho/2),y-(alto/2)+1)!=color_colision and map_get_pixel(0,masknivel,x-(ancho/2),y+(alto/2)-1)!=color_colision))
				incx++;
				x--;
			end
			incx=0;
		end
		if(incy!=0)
			while(incy>0 and (map_get_pixel(0,masknivel,x,y-(alto/2))!=color_colision and map_get_pixel(0,masknivel,x-(ancho/2),y-(alto/2))!=color_colision and map_get_pixel(0,masknivel,x+(ancho/2),y-(alto/2))!=color_colision))
				incy--;
				y++;
			end
			while(incy<0 and ((map_get_pixel(0,masknivel,x,y-(alto/2))!=color_colision and map_get_pixel(0,masknivel,x-(ancho/2),y-(alto/2))!=color_colision and map_get_pixel(0,masknivel,x+(ancho/2),y-(alto/2))!=color_colision) or y>460))
				incy++;
				y--;
			end
			incy=0;
		end
		if(y>alto_nivel-1+alto/2) y=-alto/2; end
		if(x>ancho_nivel-34) flags=0; x=ancho_nivel-34; end
		if(x<33) flags=1; x=33; end

		if(y<-alto/2) y=alto_nivel-1+alto/2; end
		frame;
	end
	from alpha=255 to 0 step -15; frame; end
	frame;
End

Process burbujarayo(x,y,direccion);
Private
	id_col;
Begin
	if(tipo_nivel==1) ctype=c_scroll; end	
	z=-10;
	file=fpg_general;
	graph=4;
	size=30;
	loop
		switch(direccion)
			case 0: x-=10; end
			case 1: x+=10; end
			case 2: y-=10; end
			case 3: y+=10; end
		end
		angle+=30000;
		if(x<-50 or x>ancho_nivel+50) break; end
		if(y<-50 or y>alto_nivel+50) break; end
		if(id_col=collision(type enemigo))
			if(id_col.accion!=atrapado and id_col.accion!=muere)
				id_col.accion=muere;
				enemigo_lanzado(id_col.x,id_col.y,id_col.tipo,rand(0,1));
				frame(500);
			end
		end
		if(anim>100)
			if(id_col=collision(type muneco1))
				id_col.accion=atrapado; anim=0;	frame(500);
				id_col.accion=0;
			end
			if(id_col=collision(type muneco2))
				id_col.accion=atrapado; anim=0;	frame(500);
				id_col.accion=0;
			end
			if(id_col=collision(type muneco3))
				id_col.accion=atrapado; anim=0;	frame(500);
				id_col.accion=0;
			end
		else
			anim++;
		end
		if(accion==muere) break; end
		sombra();
		frame;
	end
	from alpha=255 to 0 step -15; frame; end
End

Process burbujaroja(alpha);
Begin
	if(tipo_nivel==1) ctype=c_scroll; end	
	x=father.x;
	y=father.y;
	z=father.z-1;
	graph=1;
	frame;
End

Process boladenievegraph(graph); //este es el que se verá
Begin
	if(tipo_nivel==1) ctype=c_scroll; end	
	x=father.x;
	y=father.y;
	z=father.z;
	size=father.size;
	frame;
End

Process disparo2();
Private
	id_bola;
Begin
	if(tipo_nivel==1) ctype=c_scroll; end	
	x=father.x;
	y=father.y;
	jugador=father.jugador;
	flags=!father.flags;
	z=-1;
	graph=3;
	size=10;
	sonido(5);
	loop
		if(i>14 and p[jugador].tocho) burbuja(0); signal(id,s_kill); end
		if(i>8 and !p[jugador].tocho) burbuja(0); signal(id,s_kill); end

		if(p[jugador].lejos)
			if(flags==1)
				incx=20;
			else
				incx=-20;
			end
		else
			if(flags==1)
				incx=15;
			else
				incx=-15;
			end
		end

		if(incx!=0)
			while(incx>0 and map_get_pixel(0,masknivel,x+1,y)!=color_colision)
				incx--;
				x++;
			end
			while(incx<0 and map_get_pixel(0,masknivel,x-1,y)!=color_colision)
				incx++;
				x--;
			end
			incx=0;
		end

		if(incy!=0)
			while(incy>0 and map_get_pixel(0,masknivel,x,y+(alto/2))!=color_colision)
				incy--;
				y++;
			end
			while(incy<0 and map_get_pixel(0,masknivel,x,y+(alto/2))!=color_colision)
				incy++;
				y--;
			end
			incy=0;
		end
		if(id_enemigo=collision(type enemigo))
			if(id_enemigo.accion!=atrapado and id_enemigo.accion!=muere)
				if(id_enemigo.tipo==5 and id_enemigo.i==0)
					id_enemigo.i=1;
					tronco(id_enemigo.x,id_enemigo.y);
					explosion_con_humo(id_enemigo.x,id_enemigo.y);
					id_enemigo.y-=200;
					id_enemigo.accion=cae;
				else
					burbuja(id_enemigo);
					signal(id,s_kill);
				end
			end
		end

		//EL DISPARO DE PUX PUEDE ATRAPAR A LOS OTROS PERSONAJES!!! LOLLL
		if(modo_fraticidio)
			if(id_enemigo=collision(type muneco1))
				if(id_enemigo.accion!=atrapado and id_enemigo.accion!=muere)
					burbuja(id_enemigo);
					signal(id,s_kill);
				end
			end
	
			if(id_enemigo=collision(type muneco3))
				if(id_enemigo.accion!=atrapado and id_enemigo.accion!=muere)
					burbuja(id_enemigo);
					signal(id,s_kill);
				end
			end
		end
		//-----------------------------------------------------------------


		if((grav>0 and map_get_pixel(0,masknivel,x,y)==color_colision) or map_get_pixel(0,masknivel,x+1,y)==color_colision or map_get_pixel(0,masknivel,x-1,y)==color_colision) burbuja(0); signal(id,s_kill); end
		i++;
		if(size<100) size+=10; end
		frame;
	end
End

Process disparo3();
Private
	struct atrapados[10];
		identificador;
		toques;
	end
	aspirando;
	num_ids;
	id_col;
Begin
	if(tipo_nivel==1) ctype=c_scroll; end	
	sonido_aspiradora();
	size_x=10;
	x=father.x;
	y=father.y;
	file=fpg_general;
	graph=21;
	ancho=graphic_info(file,graph,g_width);
	alto=graphic_info(file,graph,g_height);
	from anim=21 to 25;
		set_center(file,anim,ancho+13,(alto/2)-10);
	end
	anim=0;
	loop
		if(father.accion==muere) accion=-2; end //los enemigos salen ilesos
		if(father.flags==1 or father.flags==5)
			flags=0+b_ablend;
		else
			flags=1+b_ablend;
		end
		if(anim<2) anim++; else anim=0; graph++; if(graph==26) graph=21; end end

		if(!p[father.jugador].botones[4]) accion=muere; end //esto es cuando se lanzan los enemigos
		if(!p[father.jugador].lejos)
			x=father.x;
		else
			if(flags==16) x=father.x+20; else x=father.x-20; end
		end
		y=father.y;
		if(p[father.jugador].lejos)
			 if(size_x<200) size_x+=20; end
		else
			 if(size_x<100) size_x+=10; end
		end
		if(id_col=collision(type enemigo))
			if(id_col.accion!=atrapado and id_col.accion!=muere)
				if(id_col.tipo==5 and id_col.i==0)
					id_col.i=1;
					tronco(id_col.x,id_col.y);
					explosion_con_humo(id_col.x,id_col.y);
					id_col.y-=200;
					id_col.accion=anda;
				else
					id_col.accion=atrapado;
					id_col.grav=0;
					atrapados[num_ids].identificador=id_col;
					atrapados[num_ids].identificador.accion=atrapado;
					atrapados[num_ids].toques=1;
					num_ids++;
				end
			end
		end
		//HERMANICIDIO LOL
		if(modo_fraticidio)		
			if(id_col=collision(type muneco1))
				if(id_col.accion!=atrapado and id_col.accion!=muere)
					if(id_col.tipo==5 and id_col.i==0)
						id_col.i=1;
						tronco(id_col.x,id_col.y);
						explosion_con_humo(id_col.x,id_col.y);
						id_col.y-=200;
						id_col.accion=anda;
					else
						id_col.accion=atrapado;
					id_col.grav=0;
						atrapados[num_ids].identificador=id_col;
						atrapados[num_ids].identificador.accion=atrapado;
						atrapados[num_ids].toques=1;
						num_ids++;
					end
				end
			end
	
			if(id_col=collision(type muneco2))
				if(id_col.accion!=atrapado and id_col.accion!=muere)
					if(id_col.tipo==5 and id_col.i==0)
						id_col.i=1;
						tronco(id_col.x,id_col.y);
						explosion_con_humo(id_col.x,id_col.y);
						id_col.y-=200;
						id_col.accion=anda;
					else
						id_col.accion=atrapado;
						id_col.grav=0;
						atrapados[num_ids].identificador=id_col;
						atrapados[num_ids].identificador.accion=atrapado;
						atrapados[num_ids].toques=1;
						num_ids++;
					end
				end
			end
		end
		//-----------------------------
		from i=0 to 10;
			if(atrapados[i].identificador!=0)
				if(atrapados[i].toques<30)
					if(!collision(atrapados[i].identificador))
						atrapados[i].identificador.angle=0;
						atrapados[i].identificador.size=100;
						atrapados[i].identificador.accion=anda;
						atrapados[i].identificador=0;
					else
						if(p[father.jugador].tocho) atrapados[i].toques+=2; else atrapados[i].toques++; end
					end
				else
					if(atrapados[i].identificador.size>3) atrapados[i].identificador.size-=7; atrapados[i].identificador.angle+=30000;
						if(accion==muere) accion=0; end //retrasamos el lanzamiento hasta que se atrape el enemigo del todo
						if(atrapados[i].identificador.x<x) atrapados[i].identificador.x+=(x-atrapados[i].identificador.x)/8; end
						if(atrapados[i].identificador.x>x) atrapados[i].identificador.x-=(atrapados[i].identificador.x-x)/8; end
					else
						atrapados[i].identificador.size=0;
						atrapados[i].identificador.x=x;
						atrapados[i].identificador.y=y;
					end
				end
			end
		end
		if(exists(id_muneco3))
			if(id_muneco3.accion==muere or id_muneco3.accion==atrapado) accion=-2; end //lo admito, soy la mierda programando xd
		else
			accion=-2;
		end
		if(accion==muere or accion==-2) break; end
		frame;
	end
	if(accion==-2) //enemigos ilesos
		from i=0 to 10;
			if(atrapados[i].identificador!=0)
				atrapados[i].identificador.size=100;
				atrapados[i].identificador.angle=0;
				atrapados[i].identificador.accion=anda;
				atrapados[i].identificador.y-=2;
			end
		end
	end
	if(accion==muere) //bola de enemigos
		//ZAS!
		flags=father.flags;
		from i=0 to 10;
			if(atrapados[i].identificador!=0)
				if(atrapados[i].toques<30)
					atrapados[i].identificador.size=100;
					atrapados[i].identificador.angle=0;
					atrapados[i].identificador.accion=anda;
					atrapados[i].identificador=0;
				end
			end
		end
		boladeenemigos(atrapados[0].identificador,atrapados[1].identificador,atrapados[2].identificador,atrapados[3].identificador,atrapados[4].identificador,atrapados[5].identificador,atrapados[6].identificador,atrapados[7].identificador,atrapados[8].identificador,atrapados[9].identificador,atrapados[10].identificador);
	end
End

Process boladeenemigos(atrapados0,atrapados1,atrapados2,atrapados3,atrapados4,atrapados5,atrapados6,atrapados7,atrapados8,atrapados9,atrapados10);
Private
	atrapados[10];
	atrapadosgraph[10];
	atrapadostipo[10];
	numatrapados;
	moviendoatrapado;
	angleatrapado;
	radio;
	rebotes;
	id_bola;
	ipendiente;
Begin
	if(tipo_nivel==1) ctype=c_scroll; end	
	// puff -_-
	sonido(4);
	atrapados[0]=atrapados0;
	atrapados[1]=atrapados1;
	atrapados[2]=atrapados2;
	atrapados[3]=atrapados3;
	atrapados[4]=atrapados4;
	atrapados[5]=atrapados5;
	atrapados[6]=atrapados6;
	atrapados[7]=atrapados7;
	atrapados[8]=atrapados8;
	atrapados[9]=atrapados9;
	atrapados[10]=atrapados10;
	from i=0 to 10;
		if(atrapados[i]!=0)
			numatrapados++;
			atrapadosgraph[i]=atrapados[i].graph;
			atrapadostipo[i]=atrapados[i].tipo;
			atrapados[i].accion=muere;
		end
	end

	x=father.x; y=father.y; z=-1;
	if(father.flags==1) flags=0; else flags=1; end
	if(numatrapados==0) signal(id,s_kill); end
	radio=numatrapados*5;
	//if(numatrapados<3) radio=10; end
	//if(numatrapados==3) radio=15; end
	//if(numatrapados>3) radio=20; end

	angleatrapado=360000/numatrapados;

//	ancho=alto=radio*2;

	graph=new_map(radio*2,radio*2,8);
	drawing_map(0,graph);
	drawing_color(150);
	draw_fcircle(radio,radio,radio);
	alpha=0;
	loop
		moviendoatrapado=0;
		from i=0 to 10;
			if(atrapados[i]!=0)
				if(numatrapados>2)
					moviendoatrapado++;
					pon_graph_un_frame(fpg_enemigos,atrapadosgraph[i],x+get_distx(angle+(moviendoatrapado*angleatrapado),radio),y-get_disty(angle+(moviendoatrapado*angleatrapado),radio),angle+(moviendoatrapado*angleatrapado),0,-2);
				else
					pon_graph_un_frame(fpg_enemigos,atrapadosgraph[i],x,y,angle,0,-2);
				end
			end
		end
		ancho=graphic_info(file,graph,g_width);
		alto=graphic_info(file,graph,g_height);

//		z=-2;
//		if(x>622-ancho/2) flags=0; if(y<415) rebotes++; else accion=muere; end x=622-ancho/2; end
//		if(x<18+ancho/2) flags=1; if(y<415) rebotes++; else accion=muere; end x=18+ancho/2; end

		if(flags==1) incx=12; angle-=25000; else incx=-12; angle+=25000; end
		if(id_bola=collision(type enemigo))
			if(id_bola.accion!=atrapado)
				if(id_bola.tipo==5 and id_bola.i==0)
					id_bola.i=1;
					tronco(id_bola.x,id_bola.y);
					explosion_con_humo(id_bola.x,id_bola.y);
					id_bola.y-=200;
					id_bola.accion=cae;
				else
					id_bola.accion=muere;
					enemigo_lanzado(id_bola.x,id_bola.y,id_bola.tipo,rand(0,1));
				end
				numatrapados-=1;
				enemigo_lanzado(x,y,atrapadostipo[numatrapados],rand(0,1));
				atrapados[numatrapados]=0;
			end
		end
			if(map_get_pixel(0,masknivel,x,y+(alto/2)+1)==color_pendiente)
				y++;
			end
			if(map_get_pixel(0,masknivel,x,y+(alto/2)-1)==color_pendiente)
				y--;
			end

		// inicio movimiento!
		if(map_get_pixel(0,masknivel,x,y+(alto/2))==color_colision or map_get_pixel(0,masknivel,x,y+(alto/2))==color_pendiente)
			if(grav>20)
				grav=-10;
				y-=2;
			else
				grav=0;
			end
			saltando=0;
		else
			grav+=2;
			saltando=1;
		end

		incy=grav/2;

		if(grav<0) grav++; end

		if(flags==1 and (map_get_pixel(0,masknivel,x+(ancho/2),y)==color_colision or map_get_pixel(0,masknivel,x+1,y)==color_colision) or x>622-ancho/2)
				numatrapados-=1;
				enemigo_lanzado(x,y,atrapadostipo[numatrapados],rand(0,1));
				atrapados[numatrapados]=0;
				flags=0;
		end
		if(flags==0 and (map_get_pixel(0,masknivel,x-(ancho/2),y)==color_colision or map_get_pixel(0,masknivel,x-1,y)==color_colision) or x<18+ancho/2)
				numatrapados-=1;
				enemigo_lanzado(x,y,atrapadostipo[numatrapados],rand(0,1));
				atrapados[numatrapados]=0;
				flags=1;
		end

		if(numatrapados<1) break; end

		if(incx!=0)
			while(incx>0 and map_get_pixel(0,masknivel,x+1,y)!=color_colision)
				incx--;
				x++;
				if(map_get_pixel(0,masknivel,x,y+(alto/2)+1)==color_pendiente)
					y++;
				end
				if(map_get_pixel(0,masknivel,x,y+(alto/2)-1)==color_pendiente)
					y--;
				end
			end
			while(incx<0 and map_get_pixel(0,masknivel,x-1,y)!=color_colision)
				incx++;
				x--;
				if(map_get_pixel(0,masknivel,x,y+(alto/2)+1)==color_pendiente)
					y++;
				end
				if(map_get_pixel(0,masknivel,x,y+(alto/2)-1)==color_pendiente)
					y--;
				end
			end
			incx=0;
		end
		if(incy!=0)
			while(incy>0 and (map_get_pixel(0,masknivel,x,y+(alto/2))!=color_colision and map_get_pixel(0,masknivel,x,y+(alto/2))!=color_pendiente))
				incy--;
				y++;
			end
			while(incy<0)
				incy++;
				y--;
			end
			incy=0;
		end
		if(y>480-alto/2) y=-alto/2; end
		// fin movimiento!
		frame;
		if(accion==muere) break; end
	end
	unload_map(0,graph);
end


//-----------------------------------------------------------------------------------------
include "../../common-src/controles.pr-";

Process readyando();
Begin
	ready=0;
	frame(6000);
	ready=1;
End

Process item(tipo);
Private
	puntos;
	tiempoitem;
Begin
	if(tipo_nivel==1) ctype=c_scroll; end	
	x=father.x;
	y=father.y;
	file=fpg_items;
	switch(tipo)
		case 0: //?wauwauwau
			// tis is an eror
		end
		case 1: //comida
			graph=rand(5,10); //faltan 3
			puntos=400;
		end
		case 2: //comida grande
			return; //por ahora!
			graph=rand(16,20);
			puntos=2000;
		end
		case 3: //powerup: velocidad, rojo
			graph=1;
			puntos=1000;
		end
		case 4: //powerup: lejos, amarillo
			graph=2;
			puntos=1000;
		end
		case 5: //powerup: disparo "tocho", azul
			graph=3;
			puntos=1000;
		end
		case 6: //powerup: globo rompe todo, verde
			graph=4;
			puntos=1000;
		end
	end
	loop
		tiempoitem++;
		if(tiempoitem>240)
			alpha=255-(tiempoitem-240)*4;
			if(tiempoitem>300)
				break;
			end
		end

			//ESTO ES UN GRAN MOJÓN DE CÓDIGO. COPYRIGHT PIXEL xd
			if(collision(type muneco1))
				sonido(13);
				p[id_muneco1.jugador].puntos+=puntos;
				switch(tipo)
					case 3: p[id_muneco1.jugador].velocidad=1; end
					case 4: p[id_muneco1.jugador].lejos=1; end
					case 5: p[id_muneco1.jugador].tocho=1; end
					case 6: end
				end
				break;
			end
			if(collision(type muneco2))
				sonido(13);
				p[id_muneco2.jugador].puntos+=puntos;
				switch(tipo)
					case 3: p[id_muneco2.jugador].velocidad=1; end
					case 4: p[id_muneco2.jugador].lejos=1; end
					case 5: p[id_muneco2.jugador].tocho=1; end
					case 6: end
				end
				break;
			end
			if(collision(type muneco3) or collision(type disparo3))
				sonido(13);
				p[id_muneco3.jugador].puntos+=puntos;
				switch(tipo)
					case 3: p[id_muneco3.jugador].velocidad=1; end
					case 4: p[id_muneco3.jugador].lejos=1; end
					case 5: p[id_muneco3.jugador].tocho=1; end
					case 6: end
				end
				break;
			end
			//FIN DEL GRAN MOJÓN DE CÓDIGO xD
		frame;
	end
End

Process sombra();
Begin
	if(tipo_nivel==1) ctype=c_scroll; end	
	flags=father.flags;
	if(father.flags!=4 and father.flags!=5) flags+=4; end
	graph=father.graph;
	file=father.file;
	size=father.size;
	x=father.x;
	y=father.y;
	size_x=father.size_x;
	size_y=father.size_y;
	angle=father.angle;
	Frame;
End

Process musica(num);
Private
	string formato="ogg";
Begin
	if(os_id==9 or os_id==1000) formato="mp3"; end
	if(ops.musica)
		if(num==cancionsonando) return; end
		cancionsonando=num;
		if(num<100)
			play_song(load_song("ogg/"+num+"."+formato),999);
		else
			play_song(load_song("ogg/"+num+"."+formato),1);
		end
	else
		if(is_playing_song()) stop_song(); end
		cancionsonando=0;
	end

End

Process carga_sonidos();
Begin
	from i=1 to 50;
		wavs[i]=load_wav("wav/"+i+".wav");
	end
End

Process sonido(num);
Begin
	if(ops.sonido)
		play_wav(wavs[num],0);
	end
End

Process sonido_aspiradora();
Private
	canal;
	tiempo;
Begin
	if(ops.sonido)
		canal=play_wav(wavs[8],0);
		while(exists(type disparo3) and is_playing_wav(canal))
			frame;
		end
		stop_wav(canal);
	else
		while(exists(type disparo3) and tiempo<200)
			tiempo++;
			frame;
		end
	end
	if(exists(father)) father.accion=-2; end
End

Process marcadores();
Private
	ids_grafs[9];
Begin
	if(debuj) write_int(0,0,0,0,&fps); end
	if(p[1].juega)
		ids_grafs[3]=pon_graph(fpg_general,26,90,40,-2);
		ids_grafs[3].alpha=200;
		switch(p[1].muneco)
			case 1:	ids_grafs[0]=pon_graph(fpg_pix,13,40,40,-3); end
			case 2:	ids_grafs[0]=pon_graph(fpg_pux,13,30,45,-3); end
			case 3:	ids_grafs[0]=pon_graph(fpg_pax,13,40,40,-3); end
		end
		write_int(fnt_puntos,70,46,0,&p[1].puntos);
		write(fnt_texto1,65,26,0,"x");
		write_int(fnt_texto1,80,26,0,&p[1].vidas);
	end
	if(p[2].juega)
		ids_grafs[4]=pon_graph(fpg_general,26,320,40,-2);
		ids_grafs[4].alpha=128;
		switch(p[2].muneco)
			case 1:	ids_grafs[1]=pon_graph(fpg_pix,13,280,40,-3); end
			case 2:	ids_grafs[1]=pon_graph(fpg_pux,13,260,45,-3); end
			case 3:	ids_grafs[1]=pon_graph(fpg_pax,13,280,40,-3); end
		end
		write_int(fnt_puntos,300,46,0,&p[2].puntos);
		write(fnt_texto1,295,26,0,"x");
		write_int(fnt_texto1,310,26,0,&p[2].vidas);

	end
	if(p[3].juega)
		ids_grafs[5]=pon_graph(fpg_general,26,560,40,-2);
		ids_grafs[5].alpha=128;
		switch(p[3].muneco)
			case 1:	ids_grafs[2]=pon_graph(fpg_pix,13,500,40,-3); end
			case 2:	ids_grafs[2]=pon_graph(fpg_pux,13,480,40,-3); end
			case 3:	ids_grafs[2]=pon_graph(fpg_pax,13,500,40,-3); end
		end
		write_int(fnt_puntos,530,46,0,&p[3].puntos);
		write(fnt_texto1,525,26,0,"x");
		write_int(fnt_texto1,540,26,0,&p[3].vidas);
	end
	loop
		//PiXeL says:
		//preparados, listos...YA!!! - Escuchando: Papa Roach - Blood Brothers XDDD
		IF((p[1].juega and !exists(ids_grafs[0])) or (!p[1].juega and exists(ids_grafs[0]))
		or (p[2].juega and !exists(ids_grafs[1])) or (!p[2].juega and exists(ids_grafs[1]))
		or (p[3].juega and !exists(ids_grafs[2])) or (!p[3].juega and exists(ids_grafs[2])))
			delete_text(all_text);
			marcadores();
			break;
		end
		frame;
	end
End

Process pon_graph(file,graph,x,y,z);
Begin
//	if(tipo_nivel==1) ctype=c_scroll; end	
	while(exists(father))
		frame;
	end
End

Process pon_graph_un_frame(file,graph,x,y,angle,flags,z);
Begin
	if(tipo_nivel==1) ctype=c_scroll; end	
	frame;
End

Process cargar_partida();
Private
	struct partida;
		mundo_actual;
	end
	string fichero="partida.dat";
Begin
	load(savegamedir+fichero,partida);
	mundo=partida.mundo_actual;
	back(0);
	elecpersonaje();
	//nivel();
End

Process borrar_partida();
Private
	string directorio_actual;
	string fichero="partida.dat";
Begin
	mundo=1;
	guardar_partida();
End

//código cedido por Devilish Games :)
Process guardar_partida();
Private
	struct partida;
		mundo_actual;
	end
	string fichero="partida.dat";
Begin
	partida.mundo_actual=mundo;
	save(savegamedir+fichero,partida);
End

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

Process reinicia_variables();
Begin
	from i=1 to 3;
		p[i].vidas=5;
		p[i].juega=0;
		p[i].puntos=0;
		p[i].velocidad=0;
		p[i].lejos=0;
		p[i].tocho=0;
		p[i].invencibilidad=0;
		p[i].muneco=0;
		p[i].identificador=0;
	end
	mundo=1;
	ready=1;
End

Process game_over();
Begin
	let_me_alone();
	delete_text(all_text);
	file=fpg_menu2;
	graph=4;
	x=320; y=240;
	musica(102);
	from alpha=0 to 255 step 40; frame; end
	clear_screen();
	timer[0]=0;
	while(timer[0]<500)
		frame;
	end
	from alpha=255 to 0 step -40; frame; end
	logo_pixjuegos();
End

Process ganar(); //esto se usará para cuando se pase de mundo
Begin
	let_me_alone();
	musica(101);
	delete_text(all_text);
	file=fpg_menu2;
	graph=5;
	x=320; y=240;
	from alpha=0 to 255 step 40; frame; end
	clear_screen();
	timer[0]=0;
	while(timer[0]<1000)
		frame;
	end
	from alpha=255 to 0 step -40; frame; end
	borrar_partida();
	logo_pixjuegos();
End

include "intro.pr-";
include "menu.pr-";
include "enemigo.pr-";
include "jefes.pr-";

Process shell(string caca);
Begin
    let_me_alone();
    if(is_playing_song())
        stop_song();
    end;
    exec(_P_WAIT, caca, 0, 0);
    exit();
End

Function contar_enemigos();
Begin
	while(get_id(type enemigo)) x++; end
	while(get_id(type enemigo_jefe)) x++; end
	return x;
End

Process colisionador();
Private
	id_col_bola;
Begin
	alpha=0;
	graph=27;
	jugador=father.jugador;
	while(exists(father))
		//colisiones
		if(accion!=muere and accion!=atrapado)
			if(id_col_bola=collision(type enemigo))
				if(id_col_bola.accion!=atrapado and p[jugador].invencibilidad==0 and id_col_bola.accion!=muere)
					father.accion=muere;
				end
			end
			if(id_col_bola=collision(type disparo))
				if(p[jugador].invencibilidad==0 and id_col_bola.accion!=muere)
					id_col_bola.accion=muere;
					father.accion=muere;
				end
			end
			if(id_col_bola=collision(type jefe))
				if(p[jugador].invencibilidad==0 and id_col_bola.accion!=muere)
					father.accion=muere;
				end
			end
			if(id_col_bola=collision(type enemigo_jefe))
				if(p[jugador].invencibilidad==0 and id_col_bola.accion!=muere)
					id_col_bola.accion=muere;
					father.accion=muere;
				end
			end
		end

		if(accion!=-10) father.accion=accion; accion=-10; end
		x=father.x;
		y=father.y;
		frame;
	end
End

Process muneco1(jugador);
Private
	num_muneco=1;
	include "muneco_general.pr-";
End

Process muneco2(jugador);
Private
	num_muneco=2;
	include "muneco_general.pr-";
End

Process muneco3(jugador);
Private
	num_muneco=3;
	include "muneco_general.pr-";
End
