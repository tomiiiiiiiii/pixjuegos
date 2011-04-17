Global
	struct p[4]; //players, jugadores
		id; //guardamos el id aquí también, nunca está de más
		botones[8]; //controladores y joysticks
		control; //el número indica su controlador: 0, teclado, =>1 joystick
	end
	posibles_jugadores;
	njoys;
	joysticks[2];
	salud_guerrero=255;
	salud_ingeniero=255;
	salud_presidente=255;
	id_guerrero;
	id_ingeniero;
	id_presidente;
	fnt_cuentaatras;
	fnt_textos;
	terroristas;
	zona;
	sonidos[5];
Local
	i;
	accion;
	ancho;
	alto;
Begin
	full_screen=1;
	set_mode(1024,600,16);
	set_fps(40,9);
	set_title("ULTIMO MINUTO");

	fnt_cuentaatras=load_fnt("cuentaatras.fnt");
	fnt_textos=load_fnt("textos.fnt");
	load_fpg("ultimo.fpg");

	configurar_controles();
	controlador(0);

	sonidos[1]=load_wav("herido.wav");
	logos();
End

Process pasos();
Private
	anim;
Begin
	priority=1;
	ctype=c_scroll;
	while(exists(father))
		x=father.x;
		y=father.y;
		z=father.z+2;
		angle=father.angle;
		switch(father.accion)
			case 0:
				flags=0;
				graph=51;
			end
			case 1:
				if((anim==4 and father.id==id_presidente) or (anim==2 and father.id!=id_presidente))
					if(graph<56)
						graph++;
					else
						if(flags==2) flags=0; else flags=2; end
						graph=51;
					end
					anim=0;
				else
					anim++;
				end
			end
		end
		frame;
	end
End

Process ataque_guerrero();
Private
	anim;
	base;
Begin
	priority=1;
	ctype=c_scroll;
	father.accion=2;
	base=61;
	graph=base;
	while(graph<base+5)
		x=father.x;
		y=father.y;
		z=father.z+1;
		angle=father.angle;
		if(anim==2)
			graph++;
			anim=0;
		else
			anim++;
		end
		frame;
	end
	father.accion=0;
End

Process ataque_terrorista();
Private
	anim;
	base;
Begin
	priority=1;
	ctype=c_scroll;
	father.accion=2;
	base=71;
	graph=base;
	while(exists(father) and graph<base+5)
		x=father.x;
		y=father.y;
		z=father.z+1;
		angle=father.angle;
		if(anim==2)
			graph++;
			anim=0;
		else
			anim++;
		end
		frame;
	end
	if(exists(father)) father.accion=0; end
End

Process empujon();
Private
	anim;
	base;
Begin
	priority=1;
	ctype=c_scroll;
	father.accion=2;
	base=81;
	graph=base;
	while(graph<base+3)
		x=father.x;
		y=father.y;
		z=father.z+1;
		angle=father.angle;
		if(anim==3)
			graph++;
			anim=0;
		else
			anim++;
		end
		frame;
	end
	father.accion=0;
End

Process logos();
Begin
	x=512;
	y=300;
	play_song(load_song("intro.ogg"),-1);
	graph=1;
	from alpha=0 to 255 step 10; frame; end
	frame(15000);
	from alpha=255 to 0 step -10; frame; end
	intro();
End

Process intro();
Private
	id_menu;
Begin
	x=512;
	y=300;
	graph=101;
	from alpha=0 to 255 step 5; frame; end
	timer=0;
	while(timer<500) frame; end
	alpha=100;
	while(accion!=1)
		accion=0;
		id_menu=pon_grafico(300,300,4,0);
		elegir();
		signal(id_menu,s_kill);
		if(accion==2) creditos(); end
		if(accion==3) exit(); end
		frame;
	end
	from alpha=255 to 0 step -10; frame; end
	graph=102;
	from alpha=0 to 255 step 5; frame; end
	timer=0;
	while(timer<4000) frame; end
	from alpha=255 to 0 step -5; frame; end	
	inicio();
End

Function elegir();
Private
	miopcion;
Begin
	graph=5;
	x=190;
	y=225;
	miopcion=1;
	while(!key(_enter))
		if(key(_down) and miopcion<3) while(key(_down)) frame; end miopcion++; y+=75; end
		if(key(_up) and miopcion>1) while(key(_up)) frame; end miopcion--; y-=75; end
		frame;
	end
	father.accion=miopcion;
End

Process inicio();
Begin
	terroristas=0;
	start_scroll(0,0,3,0,0,0);
	delete_text(all_text);
	guerrero();
	presidente();
	ingeniero();
	colisiones();
	cuenta_atras();
	salud_guerrero=255;
	salud_ingeniero=255;
	salud_presidente=255;
	pon_grafico(70,80,41,0);
	pon_grafico(165,80,42,0);
	pon_grafico(260,80,43,0);
	pon_grafico(70,130,45,0);
	pon_grafico(70,130,44,1);
	pon_grafico(165,130,45,0);
	pon_grafico(165,130,44,2);
	pon_grafico(260,130,45,0);
	pon_grafico(260,130,44,3);
	cambio_salud();
	scroll[0].camera=camara();
	play_song(load_song("juego.ogg"),0);
End

Process camara();
Private
	cabina;
	randomx;
Begin
	y=300;

	from x=0 to 4;
		terrorista(rand(640,800),rand(100,500),rand(0,360)*1000);
	end
	from x=5 to 9;
		terrorista(rand(1000,2000),rand(200,400),rand(0,360)*1000);
	end
	from x=10 to 14;
		terrorista(rand(2000,2400),rand(200,400),rand(0,360)*1000);
	end
	terroristas=5;
	loop
		if(key(_esc)) salir(); end
		if(id_guerrero.x>2048 and id_presidente.x>2048 and id_ingeniero.x>2048) cabina=1; end
		if(key(_j)) minijuego_final(); break; end	
		if(cabina==1) 
			if(x<2560) 
				x+=4; 
			else
				terroristas=0;
				minijuego_final(); 
				break; 
			end
		else 
			x=(id_guerrero.x+id_presidente.x+id_ingeniero.x)/3; 
		end
		if(x<512) x=512; end
		if(terroristas<10)
			while((randomx>x-512 and randomx<x+512) or randomx<100 or randomx>2400)
				randomx=rand(x-800,x+800);
			end
			terrorista(randomx,rand(50,550),rand(0,360)*1000);
		end
		frame;
	end
	loop
		if(rand(0,50)==1) terrorista(2000,rand(100,500),rand(0,360)*1000); end
		frame;
	end
End

Process minijuego_final();
Private
	txt;
	caracter;
	tecla_pulsada;
	veces=10;
	txt_error;
Begin
	id_ingeniero.accion=2;
	while(veces>0)
		caracter=rand(2,10);
		txt=write(fnt_textos,512,200,0,"PULSA "+(caracter-1));
		timer[2]=0;
		tecla_pulsada=0;
		while(tecla_pulsada==0 or tecla_pulsada<2 or tecla_pulsada>10 or timer[2]>300) 
			tecla_pulsada=scan_code;
			frame; 
		end
		while(scan_code!=0) frame; end
		if(caracter!=tecla_pulsada)
			veces=10;
			txt_error=write(fnt_textos,512,240,0,"ERROR");
		else
			veces--;
		end
		delete_text(txt);
		if(txt_error!=0)
			timer[2]=0;
			while(timer[2]<200) frame; end
			delete_text(txt_error);
			txt_error=0;
		end
	end
	final();
End

Process colisiones();
Begin
	ctype=c_scroll;
	graph=2;
	x=1536; y=300;
	loop
		frame;
	end
End

Process presidente();
Private
	movimiento;
	id_ataque;
	sonido;
Begin
	ctype=c_scroll;
	graph=11;
	angle=270000;
	x=150;
	y=250;
	id_presidente=id;
	pasos();
	loop
		if(collision(type ataque_terrorista))
			if(!is_playing_wav(sonido)) sonido=play_wav(sonidos[1],0); end
			salud_presidente-=3; 
			cambio_salud(); 
		end
		movimiento=0;
		if(exists(id_guerrero))
			if(get_dist(id_guerrero)>60)
				angle=get_angle(id_guerrero); 
				advance(3);
				movimiento=1;
			end
		end
		if(movimiento)
			accion=1;
			graph=12;
			if(collision(type colisiones)) advance(-3); end
			graph=11;
		else accion=0; end
		frame;
	end
End

Process ingeniero();
Private	
	movimiento;
	pulsando;
	id_ataque;
Begin
	ctype=c_scroll;
	graph=21;
	angle=0;
	controlador(2);
	id_ingeniero=id;
	x=100;
	y=150;
	pasos();
	loop
		if(collision(type ataque_terrorista)) salud_ingeniero--; cambio_salud(); end
		movimiento=0;
		if(p[2].botones[5]) 
			if(pulsando==0) empujon(); pulsando=1; end
		else
			pulsando=0;
		end
		while(accion==2) frame; end
		if(p[2].botones[4])
			if(p[2].botones[0]) 
				accion=2; 
				angle+=90000; 
				advance(5);
				graph=12;
				if(collision(type colisiones) or collision(type terrorista)) advance(-5); end
				graph=21;
				angle-=90000;
			elseif(p[1].botones[1]) 
				accion=1; 
				angle-=90000; 
				advance(5);
				graph=12;
				if(collision(type colisiones) or collision(type terrorista)) advance(-5); end
				graph=21;
				angle+=90000; 
			end
			movimiento=0;
		else
			if(p[2].botones[0]) accion=1; angle+=10000; 
			elseif(p[2].botones[1]) accion=1; angle-=10000; end
		end
		if(p[2].botones[2]) accion=1; movimiento=5; advance(5);
		elseif(p[2].botones[3]) accion=1; movimiento=-5; advance(-5); end
			
		if(p[2].botones[0]+p[2].botones[2]+p[2].botones[2]+p[2].botones[3]==0) accion=0; end
		
		graph=12;
		if(collision(type colisiones) or collision(type terrorista)) advance(-movimiento); end
		graph=21;
		frame;
	end
End

Process guerrero();
Private
	movimiento;
	pulsando;
	id_ataque;
Begin
	ctype=c_scroll;
	graph=31;
	angle=0;
	controlador(1);
	id_guerrero=id;
	x=150;
	y=250;
	pasos();
	loop
		if(collision(type ataque_terrorista)) salud_guerrero--; cambio_salud(); end
		movimiento=0;
		if(p[1].botones[5]) 
			if(pulsando==0) ataque_guerrero(); pulsando=1; end
		else
			pulsando=0;
		end
		while(accion==2) frame; end
		if(p[1].botones[4])
			if(p[1].botones[0]) 
				accion=1; 
				angle+=90000; 
				advance(5);
				graph=12;
				if(collision(type colisiones) or collision(type terrorista)) advance(-5); end
				graph=31;
				angle-=90000;
			elseif(p[1].botones[1]) 
				accion=1; 
				angle-=90000; 
				advance(5);
				graph=12;
				if(collision(type colisiones) or collision(type terrorista)) advance(-5); end
				graph=31;
				angle+=90000; 
			end
			movimiento=0;
		else
			if(p[1].botones[0]) accion=1; angle+=10000; 
			elseif(p[1].botones[1]) accion=1; angle-=10000; end
		end
		if(p[1].botones[2]) accion=1; movimiento=5; advance(5);
		elseif(p[1].botones[3]) accion=1; movimiento=-5; advance(-5); end
			
		if(p[1].botones[0]+p[1].botones[1]+p[1].botones[2]+p[1].botones[3]==0) accion=0; end
		
		graph=12;
		if(collision(type colisiones) or collision(type terrorista)) advance(-movimiento); end
		graph=31;
		frame;
	end
End

Process pon_grafico(x,y,graph,region);
Begin
	z=-1;
	loop frame; end
End

Function cambio_salud();
Begin
	define_region(1,70-43,120,salud_presidente/3,20);
	define_region(2,165-43,120,salud_ingeniero/3,20);
	define_region(3,260-43,120,salud_guerrero/3,20);
	if(salud_ingeniero=<0 or salud_guerrero=<0 or salud_presidente=<0) play_wav(load_wav("muerte.wav"),0); gameover(); end
End

Process terrorista(x,y,angle);
Private
	movimiento;
	id_ataque;
	id_empujon;
	id_miataque;
Begin
	terroristas++;
	ctype=c_scroll;
	graph=91;
	if(collision(type colisiones)) terroristas--; return; end
	pasos();
	loop
		if(collision(type ataque_guerrero)) break; end
		if(id_empujon=collision(type empujon))
			angle=get_angle(id_empujon);
			advance(-140);
		end
		movimiento=0;
		if(get_dist(id_presidente)>40 and get_dist(scroll[0].camera)<600)
			angle=get_angle(id_presidente); 
			advance(4);
			movimiento=1;
		end
		if(movimiento)
			accion=1;
			graph=12;
			if(collision(type colisiones)) advance(-4); end
			graph=91;
		else accion=0; end
		if(!exists(id_miataque)) 
			if(get_dist(id_presidente)<100 or get_dist(id_guerrero)<100 or get_dist(id_ingeniero)<100)
				id_miataque=ataque_terrorista();
			end
		end
		frame;
	end
	explotalo(x,y,z,alpha,angle,file,92,10);
	terroristas--;
End

Process cuenta_atras();
Private
	decimas;
	segundos;
	minutos;
	txt_tiempo;
	bucle;
	mi_tiempo;
	string string_tiempo;
	tiempo;
Begin
	x=800;
	y=100;
	timer=0;
	while(timer<6000)
		tiempo=6000-timer;
		decimas=tiempo; while(decimas=>100) decimas-=100; end
		segundos=tiempo/100; while(segundos=>60) segundos-=60; end
	
		if(decimas<10 and segundos<10) string_tiempo="0"+itoa(segundos)+"'' 0"+itoa(decimas); end
		if(decimas>9 and segundos<10) string_tiempo="0"+itoa(segundos)+"'' "+itoa(decimas); end
		if(decimas<10 and segundos>9) string_tiempo=""+itoa(segundos)+"'' 0"+itoa(decimas); end
		if(decimas>9 and segundos>9) string_tiempo=""+itoa(segundos)+"'' "+itoa(decimas); end
		txt_tiempo=write(fnt_cuentaatras,x,y,4,string_tiempo);
		frame;
		delete_text(txt_tiempo);
	end
	play_wav(load_wav("explosion.wav"),0); 
	gameover();
End

Process gameover();
Begin
	x=512;
	y=300;
	let_me_alone();
	stop_scroll(0);
	delete_text(all_text);
	play_song(load_song("perder.ogg"),0);
	graph=104;
	timer=0;
	while(timer<800) frame; end
	from alpha=255 to 0 step -10; frame; end
	inicio();
End

Process final();
Private
	sonando;
Begin
	x=512;
	y=300;
	let_me_alone();
	stop_scroll(0);
	stop_song();
	sonando=play_wav(load_wav("freno.wav"),0);
	while(is_playing_wav(sonando)) frame; end
	frame(6000);
	graph=105;
	timer=0;
	while(timer<500) frame; end
	from alpha=255 to 0 step -10; frame; end
	salir();
End

Process suena(sonido);
Begin
	play_wav(sonidos[sonido],0);
End

Function creditos();
Begin
	x=512;
	y=300;
	graph=103;
	timer=0;
	while(timer<500) frame; end
	from alpha=255 to 0 step -10; frame; end
End

Process salir();
Begin
	x=512;
	y=300;
	let_me_alone();
	delete_text(all_text);
	play_song(load_song("menu.ogg"),-1);
	stop_scroll(0);
	graph=103;
	timer=0;
	while(timer<500) frame; end
	from alpha=255 to 0 step -10; frame; end
End

include "explosion.pr-";
include "controles.pr-";