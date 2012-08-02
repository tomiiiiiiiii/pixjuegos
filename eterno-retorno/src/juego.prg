import "mod_blendop";
import "mod_debug";
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
import "mod_time";
import "mod_timers";
import "mod_video";
Const
	//-----ACCION DEL PERSONAJE O JEFE
	QUIETO=0;
	ATACANDO=1;
	OBJETO=2;
	HERIDO=3;
	ANDANDO=4;
	
	//------TIPOS DE ATAQUE
	FUEGO=1;
	HIELO=2;
	RAYO=3;
	CORTANTE=4;
	PUNZANTE=5;
	IMPACTO=6;
	
	//------ARMAS
	PALO=1;
	ESPADA=2;
	FLORETE=3;
	PORRA=4;
	SHURIKEN=5;
	ARCO=6;
	FLECHA=7;
	TIRACHINAS=8;
	PIEDRA=9;
	LANZA=10;
	METRALLETA=11;
	BALAS=12;
	PISTOLA_LASER=13;
	RAYO_LASER=14;
	LANZALLAMAS=15;
	LLAMAS=16;
	BOMBAS=17;
	HACHA=18;
	BAZOOKA=19;
	MISIL_BAZOOKA=20;
	BOOMERANG=21;
	MARTILLO=22;
	RAYOS=23;
	KATANA=24;
	BOLA_HIELO=25;
	KUNAI=26;
	BOLA_RAYOS=27;
	AGUJAS_HIELO=28;
	
	//-----ACCESORIOS
	BOTAS_ALADAS=1;
	PENDIENTES_FUEGO=2;
	COLLAR_HIELO=3;
	BRAZALETES_RAYO=4;
	ARMADURA_GELATINA=5;
	ARMADURA_MALLA=6;
	ARMADURA_PESADA=7;
	BOTAS_HIERRO=8;
	ANILLO_PODER=9;
	CONTRATO=10;
	CASCO_REFORZADO=11;
	CORONA=100;
		
Global
	struct p[8];
		botones[7];
		id;
		control;
		armas[2];
		objetos[1];
	end
	posibles_jugadores;
	joysticks[4];
	njoys;

	jodido;
	victorias;
	id_mazmorra;
	anterior_mazmorra;
	personaje;
	fpg_general;
	fpg_armas;
	fpg_armas2;
	fpg_personaje;
	fpg_jefe;
	fpg_objetos;
	premios_salas[6][2]; //num sala; cogido, tipo e id
	jefes_salas[6][2]; //arma1, arma2, objeto
	jefes_muertos[10];
	sonidos[100];
	primera_vez=1;
	vida[100];
	cancion;
	fuente;
	arcade_mode;
	jugadores=1;
Local
	ataque;
	tipo_ataque;
	x_inc;
	y_inc;
	anim;
	direccion;
	accion;
	jugador;
	i;
	j;
Begin
	if(argc>0) if(argv[1]=="arcade") arcade_mode=1; end end
	cancion=load_song("isaac.ogg");
	play_song(cancion,-1);
	full_screen=true;
	if(arcade_mode) full_screen=true; scale_resolution=08000600; end
	set_mode(1280,720,32);
	
	configurar_controles();
	rand_seed(time());
	fpg_general=load_fpg("general.fpg");
	fpg_armas=load_fpg("armas.fpg");
	fpg_armas2=load_fpg("armas.fpg");
	fpg_personaje=load_fpg("personaje.fpg");
	fpg_objetos=load_fpg("objetos.fpg");
	fpg_jefe=load_fpg("jefe.fpg");
	carga_sonidos();
	set_fps(60,3);
	fade(0,0,0,8);
	frame;
	fuente=load_fnt("fuente.fnt");
	from jugador=0 to 100;
		vida[jugador]=30;
		if(jugadores==2) vida[jugador]=60; end
	end
	put_screen(fpg_general,11);
	p[1].armas[1]=1;
	p[2].armas[1]=1;
	
	rolear_premios();
	rolear_jefes();
	vida[1]=50;
	vida[2]=50;
	mazmorra(0);
End

Function carga_sonidos();
Begin
	from i=1 to 20;
		sonidos[i]=load_wav(i+".wav");
	end
End

Function sonido(num);
Begin
	play_wav(sonidos[num],0);
End

Function rolear_jefes();
Begin
	from i=0 to 6;
		jefes_salas[i][0]=1;
		jefes_salas[i][1]=1;
		jefes_salas[i][2]=0;
	end
End

Function rolear_premios();
Private
	int num_armas;
	int num_objetos;
Begin
	repeat
		num_armas=0;
		num_objetos=0;
		i=1;
		while(i<7)
			premios_salas[i][1]=rand(1,2);//tipo
			premios_salas[i][0]=0;//no cogido
			if(premios_salas[i][1]==1)
				premios_salas[i][2]=rand(2,28); //arma
			else
				premios_salas[i][2]=rand(1,11); //objeto
			end
			from j=1 to 6;
				if(premios_salas[i][1]==1 and 
				(premios_salas[i][2]==FLECHA or premios_salas[i][2]==PIEDRA or premios_salas[i][2]==BALAS or premios_salas[i][2]==RAYO_LASER or premios_salas[i][2]==LLAMAS or premios_salas[i][2]==MISIL_BAZOOKA))
					i--;
					break;
				end
				if(premios_salas[i][1]==premios_salas[j][1] and premios_salas[i][2]==premios_salas[j][2] and i!=j)
					i--;
					break;
				end
			end
			i++;
		end
		from i=1 to 6;
			if(premios_salas[i][1]==1) num_armas++; else num_objetos++; end
		end
	until(num_armas>0 and num_objetos>0)
End

Process jefe(jugador,enemigo);
Private
	id_arma;
	anterior_id_arma;
	id_cuerpo;
	id_piernas;
	retraso;
	id_colision;
	angulo;
	persigue;
Begin
	persigue=enemigo;
	file=fpg_jefe;
	graph=7;
	x=640;
	y=200;
	z=-10;
	ctype=p[1].id.ctype;
	if(jodido)
		switch(jugador-10)
			case 1: x=80; y=600; end
			case 2: x=80; y=400; end
			case 3: x=80; y=200; end
			case 4: x=1200; y=600; end
			case 5: x=1200; y=400; end
			case 6: x=1200; y=200; end
		end
	end
	priority=1;
	id_cuerpo=personaje_cuerpo();
	id_piernas=personaje_piernas();
	sombra();
	if(jefes_salas[jugador-10][2]==CONTRATO) ayudante(); end
	if(jugador==10) ponle_corona(0); end
	vida_personaje(jugador);	
	while(fading) frame; end
	while(retraso<30) retraso++; frame; end
	while(vida[jugador]>0)
		if(accion==QUIETO)
			anim=0;
			switch(direccion)
				case 0: graph=1; end
				case 1: graph=4; end
				case 2: graph=7; end
				case 3: graph=4; flags=1; end
			end
		end
		if(accion==ANDANDO)
			anim=0;
			switch(direccion)
				case 0: graph=10; end
				case 1: graph=16; end
				case 2: graph=22; end
				case 3: graph=16; flags=1; end
			end
		end
		if(accion==ATACANDO) //atacando
			anim=0;
			switch(direccion)
				case 0: graph=28; end
				case 1: graph=31; end
				case 2: graph=34; end
				case 3: graph=31; flags=1; end
			end
			if(!exists(son)) accion=QUIETO; end
		end
		if(accion==OBJETO) //cogiendo objeto
			sonido(5);
			graph=46; 
			flags=0;
			anim=0;
			direccion=2;
			while(anim<60) anim++; frame; end
			anim=0;
			accion=QUIETO;
		end
		if(accion==HERIDO) //recibiendo daño
			if(anim==0) sonido(2); end
			switch(direccion)
				case 0: graph=37; y_inc=30-anim; end
				case 1: graph=40; x_inc=-(30-anim); end
				case 2: graph=43; y_inc=-(30-anim); end
				case 3: graph=40; x_inc=30-anim; flags=1;end
			end
			nube();
			if(jefes_salas[jugador-10][2]==BOTAS_HIERRO)
				x_inc/=2;
				y_inc/=2;
			end
			if(anim<30)
				if(jefes_salas[jugador-10][2]==BOTAS_HIERRO) 
					anim+=3;
				else
					anim++;
				end
			else
				anim=0;
				accion=QUIETO;
			end
		end

		if(accion!=HERIDO)
			if(id_colision=collision(type arma))
				if(id_colision.jugador==1 or id_colision.jugador==2)
					persigue=id_colision.jugador;
					accion=HERIDO;
					id_colision.accion=-1;
					if((jefes_salas[jugador-10][2]==PENDIENTES_FUEGO and id_colision.tipo_ataque==FUEGO) or
						(jefes_salas[jugador-10][2]==COLLAR_HIELO and id_colision.tipo_ataque==HIELO) or
						(jefes_salas[jugador-10][2]==BRAZALETES_RAYO and id_colision.tipo_ataque==RAYO) or
						(jefes_salas[jugador-10][2]==ARMADURA_GELATINA and id_colision.tipo_ataque==PUNZANTE) or
						(jefes_salas[jugador-10][2]==ARMADURA_MALLA and id_colision.tipo_ataque==CORTANTE) or
						(jefes_salas[jugador-10][2]==ARMADURA_PESADA and id_colision.tipo_ataque==IMPACTO))
						//NO FOUL?
					elseif(jefes_salas[jugador][2]==CASCO_REFORZADO)
						vida[jugador]-=id_colision.ataque-1;
					else
						vida[jugador]-=id_colision.ataque;
					end
					switch(id_colision.direccion)
						case 0: direccion=2; end
						case 1: direccion=3; end
						case 2: direccion=0; end
						case 3: direccion=1; end
					end
				end
			end
			if(id_colision=collision(type explosion))
				accion=HERIDO; 
				if(jefes_salas[jugador-10][2]==ARMADURA_PESADA)
					//NO FOUL?
				elseif(jefes_salas[jugador-10][2]==CASCO_REFORZADO)
					vida[jugador]-=id_colision.ataque-1;
				else
					vida[jugador]-=id_colision.ataque;
				end
			end
		end
		if(vida[1]=<0 and jugadores==2) persigue=2; end
		if(vida[2]=<0 or jugadores==1) persigue=1; end
		if(p[persigue].id.x<x and accion!=HERIDO)
			flags=1;
			direccion=3;
			x_inc-=3;
		elseif(p[persigue].id.x>x and accion!=HERIDO)
			flags=0;
			direccion=1;
			flags=0;
			x_inc+=3; 
		else
			if(x_inc>0) 
				x_inc-=2;
				if(x_inc<0) x_inc=0; end
			elseif(x_inc<0)
				x_inc+=2;
				if(x_inc>0) x_inc=0; end
			end
		end
		if(p[persigue].id.y<y and accion!=HERIDO)
			direccion=0;
			y_inc-=3;
		elseif(p[persigue].id.y>y and accion!=HERIDO)
			direccion=2;
			y_inc+=3; 
		else
			if(y_inc>0) 
				y_inc-=2;
				if(y_inc<0) y_inc=0; end
			elseif(y_inc<0)
				y_inc+=2;
				if(y_inc>0) y_inc=0; end
			end
		end	
		angulo=get_angle(p[persigue].id);
		if(angulo<45000) direccion=1;
		elseif(angulo<135000) direccion=0;
		elseif(angulo<225000) direccion=3;
		elseif(angulo<320000) direccion=2;
		else direccion=1;
		end
		if(accion!=HERIDO and retraso=>10)
			if(rand(0,5)==5)
				retraso=0;
				if(rand(0,1)==1)
					arma(jefes_salas[jugador-10][0]);
				else
					arma(jefes_salas[jugador-10][1]);
				end
			end
		end
		if(retraso<10) retraso++; end
		if(accion!=HERIDO)
			if(x_inc>6) x_inc=6; end
			if(x_inc<-6) x_inc=-6; end
			if(y_inc>6) y_inc=6; end
			if(y_inc<-6) y_inc=-6; end
		end
		if(p[persigue].id.accion==HERIDO)
			x_inc=-x_inc;
			y_inc=-y_inc;
			if(x>900) x_inc=-8; end
			if(x<200) x_inc=+8; end
			if(y>500) y_inc=-8; end
			if(y<240) y_inc=+8; end
		end
		if(jefes_salas[jugador-10][2]==BOTAS_ALADAS and accion!=HERIDO)
			nube();
			x_inc*=2;
			y_inc*=2;
		end
		if(accion==ATACANDO)
			x+=x_inc/2;
			y+=y_inc/2;
		else
			x+=x_inc;
			y+=y_inc;
		end
		if(jefes_salas[jugador-10][2]==BOTAS_ALADAS and accion!=HERIDO)
			x_inc/=2;
			y_inc/=2;
		end
		if((x_inc!=0 or y_inc!=0) and accion==QUIETO) 
			accion=ANDANDO;
		end
		if((x_inc==0 and y_inc==0) and accion==ANDANDO)
			accion=QUIETO;
		end
		if(x<80) x=80; end
		if(x>1200) x=1200; end
		if(y<80) y=80; end
		if(y>600) y=600; end
		frame;
	end
	while(exists(type arma))
		signal(type arma, s_kill);
	end
	timer[0]=0;
	if(!jodido)
		while(timer[0]<100)
			vida[1]++;
			vida[2]++;
			frame(1000); 
		end
	end
	graph=49;
	signal(id_cuerpo,s_kill);
	signal(id_piernas,s_kill);
	if(!jodido)
		fade(50,50,50,4);
		set_fps(15,0);
	end
	from alpha=255 to 0 step -15; frame; end
	if(!jodido)
		set_fps(60,3);
		fade(100,100,100,4);
	end
	if(enemigo==2) return; end
	jefes_muertos[id_mazmorra-1]=1;
	if(jugador!=10)
		premio(premios_salas[id_mazmorra-1][1],premios_salas[id_mazmorra-1][2]);
	else
		premio(2,100);
		if(victorias=>7)
			puerta(9);
		end
	end

	p[persigue].id.accion=QUIETO;
	frame;
End

Process sombra();
Begin
	file=fpg_general;
	z=50;
	graph=10;
	alpha=200;
	loop
		if(exists(father))
			x=father.x;
			y=father.y+36;
			ctype=father.ctype;
		else
			break;
		end
		frame; 
	end
End

Process nube();
Begin
	if(father.x_inc==0 and father.y_inc==0 and father.ataque==0) return; end
	graph=9;
	file=fpg_general;
	ctype=father.ctype;
	x=father.x;
	y=father.y+37;
	size=40;
	z=49;
	from alpha=255 to 0 step -20; size+=10; angle=rand(0,360)*1000; frame; end
End

Process ponle_corona(aquien);
Begin
	graph=100;
	file=fpg_objetos;
	size=60;
	z=-50;
	loop
		if(aquien==0)
			if(!exists(father)) break; end
			alpha=father.alpha;
			x=father.x;
			y=father.y-30;
		else
			if(!exists(aquien)) break; end
			x=aquien.x;
			y=aquien.y-30;
		end
		frame;
	end
End


Process mazmorra(tipo);
	//mazmorras:
	// -1: UBERJODIDO
	// 0: general
	// 1: jefe final
	// 2: subjefe 1 - arriba izq 
	// 3: subjefe 2 - centro izq
	// 4: subjefe 3 - abajo  izq
	// 5: subjefe 4 - arriba der
	// 6: subjefe 5 - centro der
	// 7: subjefe 6 - abajo  der
Private
	posicion;
Begin
	if(tipo==-1) 
		jodido=1; 
		tipo=1; 
		put_screen(fpg_general,13);
		from i=0 to 99;
			vida[i]=30*jugadores;
		end
		vida[1]=100;
		vida[2]=100;
	end
	delete_text(all_text);
	frame;
	graph=get_screen();
	x=640;
	y=360;
	z=-10;
	let_me_alone();
	anterior_mazmorra=id_mazmorra;
	id_mazmorra=tipo;
	fade(0,0,0,8);
	while(fading) frame; end
	unload_map(0,graph);
	graph=0;
	stop_scroll(0);
	timer[0]=0;
	while(timer[0]<50) frame; end
	fade(100,100,100,8);
	if(tipo==0)
		if(anterior_mazmorra==1)
			start_scroll(0,0,12,0,0,0);
		else
			start_scroll(0,0,3,0,0,0);
		end
		posicion=0;
		scroll.camera=personaje(posicion,1);
		if(jugadores==2) personaje(posicion,2); end
		if(primera_vez) primera_vez=0; titulo(); end
		if(anterior_mazmorra!=1)
			from i=1 to 6; puerta(i); end
			if((p[1].armas[2]!=0 or p[2].armas[2]!=0) and (p[1].objetos[1]!=0 or p[2].objetos[1]!=0))
				puerta(10);
			end
		end
		if(victorias=>7 and anterior_mazmorra==1)
			puerta(11);
		end
	elseif(tipo==1)
		posicion=3;
		personaje(posicion,1);
		if(jugadores==2) personaje(posicion,2); end
	elseif(tipo>1 and tipo<5)
		posicion=1;
		personaje(posicion,1);
		if(jugadores==2) personaje(posicion,2); end
		puerta(7);
	else
		posicion=2;
		personaje(posicion,1);
		if(jugadores==2) personaje(posicion,2); end
		puerta(8);
	end
	if(tipo!=0)
		if(jefes_muertos[id_mazmorra-1]==0)
			jefe(id_mazmorra-1+10,1);
			if(jugadores==2) jefe(id_mazmorra-1+10,2); end
		elseif(jefes_muertos[id_mazmorra-1]==1)
			premio(premios_salas[id_mazmorra-1][1],premios_salas[id_mazmorra-1][2]);
		end
		if(jodido)
			from i=1 to 6;
				if(jugadores==1)
					jefe(i+10,1);
				else
					jefe(i+10,rand(1,2));
				end
			end
		end
	end
	pon_hud(1);
	if(jugadores==2) pon_hud(2); end
	if(jugadores==1 and posibles_jugadores>1) controlador(2); end
	loop
		if(jugadores==1 and p[2].botones[4] and p[2].botones[5]) jugadores=2; personaje(posicion,2); end
		if(jodido and !exists(type jefe))
			victorias++;
			from i=0 to 6;
				vida[i+10]=30*jugadores;
				jefe(i+10,rand(1,jugadores));
			end
		end
		frame;
	end
End

Process titulo();
Begin
	file=fpg_general;
	ctype=c_scroll;
	graph=1;
	x=800;
	y=2400;
	z=15;
	while(fading) frame; end
	from alpha=0 to 255; frame; end
	from anim=0 to 300; frame; end
	from alpha=255 to 0 step -2; frame; end
End

Process personaje(posicion,jugador);
Private
	pulsando;
	id_colision;
	retraso=10;
Begin
	//posiciones: 
	//0. inicio mazmorra general
	//1. derecha mazmorra subjefe
	//2. izquierda mazmorra subjefe
	//3. abajo mazmorra jefe
	p[jugador].id=id;
	controlador(jugador);
	file=fpg_personaje;
	graph=7;
	priority=1;
	personaje_piernas();
	personaje_cuerpo();
	sombra();
	switch(posicion)
		case 0:
	// 1: jefe final
	// 2: subjefe 1 - arriba izq 
	// 3: subjefe 2 - centro izq
	// 4: subjefe 3 - abajo  izq
	// 5: subjefe 4 - arriba der
	// 6: subjefe 5 - centro der
	// 7: subjefe 6 - abajo  der
			if(anterior_mazmorra<5) x=120; else x=1160; end
			if(anterior_mazmorra==2 or anterior_mazmorra==5) y=360; end
			if(anterior_mazmorra==3 or anterior_mazmorra==6) y=1080; end
			if(anterior_mazmorra==4 or anterior_mazmorra==7) y=1800; end
			if(anterior_mazmorra==1) x=640; y=120; direccion=2; end
			if(anterior_mazmorra==0) x=640; y=2700; direccion=0; end
			ctype=c_scroll;
		end
		case 1:
			x=1160;
			y=360;
			direccion=3;
		end
		case 2:
			x=120;
			y=360;
			direccion=1;
		end
		case 3:
			x=640;
			y=600;
			direccion=0;
		end
	end
	if(p[jugador].objetos[1]==CONTRATO) ayudante(); end
	loop
		if(p[jugador].botones[7]) exit(); end
		if(accion==QUIETO)
			anim=0;
			switch(direccion)
				case 0: graph=1; end
				case 1: graph=4; end
				case 2: graph=7; end
				case 3: graph=4; flags=1; end
			end
		end
		if(accion==ANDANDO)
			anim=0;
			switch(direccion)
				case 0: graph=10; end
				case 1: graph=16; end
				case 2: graph=22; end
				case 3: graph=16; flags=1; end
			end
		end
		if(accion==ATACANDO) //atacando
			anim=0;
			switch(direccion)
				case 0: graph=28; end
				case 1: graph=31; end
				case 2: graph=34; end
				case 3: graph=31; flags=1; end
			end
			if(!exists(son)) accion=QUIETO; end
		end
		if(accion==OBJETO) //cogiendo objeto
			sonido(5);
			graph=46; 
			flags=0;
			anim=0;
			direccion=2;
			while(anim<60) anim++; frame; end
			anim=0;
			accion=QUIETO;
		end
		if(accion==HERIDO) //recibiendo daño
			if(anim==0) sonido(2); end
			nube();
			switch(direccion)
				case 0: graph=37; y_inc=30-anim; end
				case 1: graph=40; x_inc=-(30-anim); end
				case 2: graph=43; y_inc=-(30-anim); end
				case 3: graph=40; x_inc=30-anim; flags=1;end
			end
			if(p[jugador].objetos[1]==BOTAS_HIERRO)
				x_inc/=2;
				y_inc/=2;
			end
			if(anim<30)
				if(p[jugador].objetos[1]==BOTAS_HIERRO) 
					anim+=3;
				else
					anim++;
				end
			else
				anim=0;
				accion=QUIETO;
			end
		end

		if(retraso<10 and accion!=ATACANDO) retraso++; end
		if(accion!=HERIDO)
			//say("antes:"+vida[jugador]);
			if(id_colision=collision(type jefe))
				accion=HERIDO; 
				vida[jugador]-=1;
			end
			if(id_colision=collision(type arma))
				if(id_colision.jugador!=jugador)
					accion=HERIDO; 
					if((p[jugador].objetos[1]==PENDIENTES_FUEGO and id_colision.tipo_ataque==FUEGO) or
						(p[jugador].objetos[1]==COLLAR_HIELO and id_colision.tipo_ataque==HIELO) or
						(p[jugador].objetos[1]==BRAZALETES_RAYO and id_colision.tipo_ataque==RAYO) or
						(p[jugador].objetos[1]==ARMADURA_GELATINA and id_colision.tipo_ataque==PUNZANTE) or
						(p[jugador].objetos[1]==ARMADURA_MALLA and id_colision.tipo_ataque==CORTANTE) or
						(p[jugador].objetos[1]==ARMADURA_PESADA and id_colision.tipo_ataque==IMPACTO))
						//NO FOUL?
					elseif(p[jugador].objetos[1]==CASCO_REFORZADO)
						vida[jugador]-=id_colision.ataque-1;
					else
						vida[jugador]-=id_colision.ataque;
					end				
					id_colision.accion=-1;
					switch(id_colision.direccion)
						case 0: direccion=2; end
						case 1: direccion=3; end
						case 2: direccion=0; end
						case 3: direccion=1; end
					end
				end
			end
			//say("desp1:"+vida[jugador]);
			if(id_colision=collision(type explosion))
				accion=HERIDO;
				if(p[jugador].objetos[1]==ARMADURA_PESADA)
					//NO FOUL?
				elseif(p[jugador].objetos[1]==CASCO_REFORZADO)
					vida[jugador]-=id_colision.ataque-1;
				else
					vida[jugador]-=id_colision.ataque;
				end
			end
			//say("desp2:"+vida[jugador]);
		end
		if(p[jugador].botones[0] and accion!=HERIDO)
			flags=1;
			direccion=3;
			x_inc-=3;
		elseif(p[jugador].botones[1] and accion!=HERIDO)
			flags=0;
			direccion=1;
			flags=0;
			x_inc+=3; 
		else
			if(x_inc>0) 
				x_inc-=2;
				if(x_inc<0) x_inc=0; end
			elseif(x_inc<0)
				x_inc+=2;
				if(x_inc>0) x_inc=0; end
			end
		end
		if(p[jugador].botones[2] and accion!=HERIDO)
			direccion=0;
			y_inc-=3;
		elseif(p[jugador].botones[3] and accion!=HERIDO)
			direccion=2;
			y_inc+=3; 
		else
			if(y_inc>0) 
				y_inc-=2;
				if(y_inc<0) y_inc=0; end
			elseif(y_inc<0)
				y_inc+=2;
				if(y_inc>0) y_inc=0; end
			end
		end	
		if((p[jugador].botones[4] and accion!=HERIDO and (pulsando==0 or p[jugador].armas[1]==METRALLETA)) and retraso==10)
			retraso=0;
			pulsando=1;
			arma(p[jugador].armas[1]);
		end
		if((p[jugador].botones[5] and accion!=HERIDO and (pulsando==0 or p[jugador].armas[2]==METRALLETA)) and retraso==10)
			retraso=0;
			pulsando=1;
			arma(p[jugador].armas[2]); 
		end
		if(!key(_x) and !key(_z) and !mouse.left and !mouse.right)
			pulsando=0;
		end
		if(accion!=HERIDO)
			if(x_inc>8) x_inc=8; end
			if(x_inc<-8) x_inc=-8; end
			if(y_inc>8) y_inc=8; end
			if(y_inc<-8) y_inc=-8; end
		end
		if(p[jugador].objetos[1]==BOTAS_ALADAS and accion!=HERIDO)
			nube();
			x_inc*=2;
			y_inc*=2;
		end
		if(accion==ATACANDO)
			x+=x_inc/2;
			y+=y_inc/2;
		else
			x+=x_inc;
			y+=y_inc;
		end
		if(p[jugador].objetos[1]==BOTAS_ALADAS and accion!=HERIDO)
			x_inc/=2;
			y_inc/=2;
		end
		if((x_inc!=0 or y_inc!=0) and accion==QUIETO) 
			accion=ANDANDO; 
		end
		if((x_inc==0 and y_inc==0) and accion==ANDANDO) 
			accion=QUIETO;
		end
		if(x<80) if(accion==HERIDO) direccion=1; end x=80; end
		if(x>1200) if(accion==HERIDO) direccion=3; end x=1200; end
		if(y<80) if(accion==HERIDO) direccion=2; end y=80; end
		if(ctype==c_scroll)
			if(y>2760) y=2760; end
			if(collision(type puerta))
				if(x>600 and x<680 and y==80)
					mazmorra(1);
				end
				if(x==80)
					if(y<380 and y>340)
						mazmorra(2);
					end
					if(y<1100 and y>1060)
						mazmorra(3);
					end
					if(y<1820 and y>1780)
						mazmorra(4);
					end
				end
				if(x==1200)
					if(y<380 and y>340)
						mazmorra(5);
					end
					if(y<1100 and y>1060)
						mazmorra(6);
					end
					if(y<1820 and y>1780)
						mazmorra(7);
					end
				end
			end
		else //sin scroll
			if(collision(type puerta))
				if(jefes_muertos[id_mazmorra-1] and !exists(type jefe))
					mazmorra(0);
				end
				if(id_mazmorra==1) mazmorra(0); end
			end
			if(y>600) if(accion==HERIDO) direccion=0; end y=600; end
		end
		if(vida[jugador]=<0)
			if(jugadores==2)
				if(vida[1]>0 or vida[2]>0)
					graph=49;
					while(1) frame; end 
				end
			end
			fade(50,50,50,4);
			set_fps(15,0);
			graph=49; 
			from alpha=255 to 0 step -5; frame; end 
			set_fps(60,3);
			fade_music_off(100); 
			fade(0,0,0,16); 
			while(fading) frame; end 
			break; 
		end
		frame;
	end
	let_me_alone();
	timer[0]=0;
	while(timer[0]<300) frame; end
	if(jodido) fin(); return; end
	play_song(cancion,-1);
	p[1].armas[1]=1; 
	p[1].armas[2]=0; 
	p[1].objetos[1]=0;
	p[2].armas[1]=1; 
	p[2].armas[2]=0; 
	p[2].objetos[1]=0;
	rolear_premios();
	from jugador=0 to 10;
		jefes_muertos[jugador]=0;
	end
	from jugador=0 to 99;
		vida[jugador]=30;
	end
	vida[1]=50;
	vida[2]=50;
	id_mazmorra=0;
	mazmorra(0);
End

Process direccion_raton();
Begin
	x=father.x;
	y=father.y;
	ctype=father.ctype;
	if(get_angle(mouse)>-45000 and get_angle(mouse)<=45000)
		father.direccion=1;
	elseif(get_angle(mouse)>45000 and get_angle(mouse)<=135000)
		father.direccion=2;
	elseif(get_angle(mouse)>135000 and get_angle(mouse)<=225000)
		father.direccion=3;
	else
		father.direccion=0;
	end
End

Process personaje_cuerpo();
Begin
	file=father.file;
	z=1;
	jugador=father.jugador;
	while(exists(father))
		ctype=father.ctype;
		if(father.accion==QUIETO)
			graph=father.graph+1;
			anim++;
			if(anim<15)
				y=father.y-1;
			elseif(anim<30)
				y=father.y-2;
			elseif(anim<45)
				y=father.y-1;
			elseif(anim<60)
				y=father.y;
			else
				anim=0;
			end
		elseif(father.accion==ATACANDO or father.accion==OBJETO or father.accion==HERIDO)
			graph=father.graph+1;
			y=father.y;
		else
			anim++;
			y=father.y;
			if(anim<10) 
				graph=father.graph+1;
			elseif(anim<20) 
				graph=father.graph+2;
			else
				anim=0;
			end
		end
		x=father.x;
		flags=father.flags;
		frame;
	end
End

Process personaje_piernas();
Begin
	file=father.file;
	z=2;
	jugador=father.jugador;
	while(exists(father))
		ctype=father.ctype;
		if(father.accion==QUIETO or father.accion==OBJETO or father.accion==HERIDO or father.accion==ATACANDO)
			anim=0;
			graph=father.graph+2;
		else
			anim++;
			if(anim<10) 
				graph=father.graph+3;
			elseif(anim<20) 
				graph=father.graph+4;
			elseif(anim<30)
				graph=father.graph+5;
			elseif(anim<40)
				graph=father.graph+4;
			else
				anim=0;
			end
		end
		x=father.x;
		y=father.y-1;
		flags=father.flags;
		frame;
	end
End

Process pon_hud(jugador);
Begin
	hud_arma(1);
	hud_arma(2);
	hud_arma(3);
	vida_personaje(1);
	if(jugadores==2) vida_personaje(2); end
	if(victorias>0)
		hud_corona();
	end
	graph=6;
	z=-9;
	x=1000;
	y=50;
	if(jugador==2) y=680; end
	loop frame; end
End

Process hud_corona();
Begin
	x=80;
	y=60;
	z=-50;
	file=fpg_objetos;
	graph=CORONA;
	write(fuente,120,60,3,"x "+victorias);
	loop
		frame;
	end
End

Process vida_personaje(jugador);
Begin
	z=-12;
	y=100;
	if(jugador==1 or jugador==2)
		x=1000;
		graph=7;
		if(jugador==2) y=650; end
	else
		x=280;
		graph=8;
	end
	if(jodido)
		if(jugador!=1)
			return;
		end
		x=640;
	end
	loop
		if(jugadores==2 and jugador>9)
			size_x=100/60*vida[jugador];
		else
			size_x=100/30*vida[jugador];
		end
		frame;
	end
End

Process hud_arma(num);
Begin
	jugador=father.jugador;
	z=-10;
	y=50;
	switch(num)
		case 1: x=900; file=fpg_armas2; end
		case 2: x=1000; file=fpg_armas2; end
		case 3: x=1100; file=fpg_objetos; end
	end
	if(jugador==2) y=680; end
	loop
		if(num<3) 
			graph=p[jugador].armas[num];
			if(graph==RAYOS)
				graph=230;
			end
		else 
			graph=p[jugador].objetos[1]; 
		end
		
		frame;
	end
End

Process arma(tipo);
Private
	separacion;
	velocidad;
	cambiada_accion;
	id_sonido;
	id_jefe;
Begin
	//1:espada
	//2:...
	if(father.accion==ATACANDO OR father.accion==OBJETO OR father.accion==HERIDO) return; end
	file=fpg_armas;
	ctype=father.ctype;
	direccion=father.direccion;
	if(tipo==BAZOOKA)
		father.accion=HERIDO;
	else
		father.accion=ATACANDO;
	end
	jugador=father.jugador;
	if(tipo==ARCO or tipo==TIRACHINAS or tipo==METRALLETA or tipo==PISTOLA_LASER
	or tipo==LANZALLAMAS or tipo==BAZOOKA)
		arma_pistola(tipo);
		tipo++;
	end
	graph=tipo;	
	switch(tipo)
		case PALO: sonido(4); ataque=2; tipo_ataque=0; velocidad=1; end
		case ESPADA: sonido(4); ataque=3; tipo_ataque=CORTANTE; velocidad=3; end
		case FLORETE: sonido(4); ataque=3; tipo_ataque=PUNZANTE; velocidad=3; end
		case PORRA: sonido(4); ataque=3; tipo_ataque=IMPACTO; velocidad=3; end
		case SHURIKEN: ataque=1; tipo_ataque=CORTANTE; velocidad=5; end
		case ARCO: end //ARCO!!!!!!
		case FLECHA: sonido(7); ataque=4; tipo_ataque=PUNZANTE; velocidad=4; end
		case TIRACHINAS: end //TIRACHINAS!!!!
		case PIEDRA: sonido(12); ataque=2; tipo_ataque=IMPACTO; velocidad=4; end
		case LANZA: sonido(4); ataque=3; tipo_ataque=PUNZANTE; velocidad=2; end
		case METRALLETA: end //METRALLETA!!!!
		case BALAS: sonido(13); ataque=1; tipo_ataque=PUNZANTE; velocidad=7; end
		case PISTOLA_LASER: end //PISTOLA LASER!!!!!
		case RAYO_LASER: sonido(10); ataque=8; tipo_ataque=FUEGO; velocidad=2; set_center(file,graph,graphic_info(file,graph,G_X_CENTER),graphic_info(file,graph,G_HEIGHT)); end
		case LANZALLAMAS: end //LANZALLAMAS!!!!
		case LLAMAS: sonido(17); ataque=4; tipo_ataque=FUEGO; velocidad=6; end
		case BOMBAS: ataque=0; tipo_ataque=IMPACTO; velocidad=1; end
		case HACHA: sonido(4); ataque=3; tipo_ataque=CORTANTE; velocidad=2; set_center(file,graph,graphic_info(file,graph,G_X_CENTER),graphic_info(file,graph,G_HEIGHT)); end
		case BAZOOKA: end //BAZOOKA!!!!!!!
		case MISIL_BAZOOKA: sonido(14); ataque=5; tipo_ataque=IMPACTO; velocidad=7; end
		case BOOMERANG: ataque=3; tipo_ataque=CORTANTE; velocidad=2; end
		case MARTILLO: sonido(4); ataque=4; tipo_ataque=IMPACTO; velocidad=1; set_center(file,graph,graphic_info(file,graph,G_X_CENTER),graphic_info(file,graph,G_HEIGHT)); end
		case RAYOS: sonido(16); ataque=2; tipo_ataque=RAYO; velocidad=5; set_center(file,graph,graphic_info(file,graph,G_X_CENTER),graphic_info(file,graph,G_HEIGHT)); end
		case KATANA: sonido(4); ataque=4; tipo_ataque=CORTANTE; velocidad=5; set_center(file,graph,graphic_info(file,graph,G_X_CENTER),graphic_info(file,graph,G_HEIGHT)); end
		case BOLA_HIELO: sonido(20); ataque=2; tipo_ataque=HIELO; velocidad=4; end
		case KUNAI: ataque=1; tipo_ataque=PUNZANTE; velocidad=5; end
		case BOLA_RAYOS: sonido(16); ataque=3; tipo_ataque=RAYO; velocidad=2; end
		case AGUJAS_HIELO: sonido(19); ataque=4; tipo_ataque=HIELO; velocidad=1; end
	end
	if(jugador<3 and p[jugador].objetos[1]==ANILLO_PODER) ataque+=2; end
	if(jugador>3 and jefes_salas[jugador-10][2]==ANILLO_PODER) ataque+=2; end
	//CORTA DISTANCIA
	if(tipo==PALO or tipo==ESPADA or tipo==FLORETE or tipo==PORRA or tipo==LANZA 
	or tipo==HACHA or tipo==MARTILLO or tipo==KATANA)
		while(anim<30 and exists(father))
			anim+=velocidad;
			if(tipo==HACHA or tipo==MARTILLO or tipo==KATANA)
				separacion=20;
			else
				separacion=50;
			end
			if(father.direccion==0)
				z=5;
				angle=0;
				flags=0;
				x=father.x;
				y=father.y-separacion;
			elseif(father.direccion==1)
				z=5;
				angle=270000;
				flags=0;
				x=father.x+separacion;
				y=father.y;
			elseif(father.direccion==2)
				angle=180000;
				flags=0;
				x=father.x;
				y=father.y+separacion;
			elseif(father.direccion==3)
				z=5; 
				angle=270000;
				flags=1;
				x=father.x-separacion;
				y=father.y;
			end
			if(tipo==HACHA or tipo==MARTILLO or tipo==KATANA)
				if(direccion!=1)
					angle+=45000/15*(anim-15);
				else
					angle-=45000/15*(anim-15);
				end
			end
			frame;
		end
	end
	//LASER
	if(tipo==RAYO_LASER or tipo==RAYOS)
		direccion=father.direccion;
		while(anim<60 and exists(father))
			x=father.x;
			y=father.y;
			if(anim>20) graph=0; end
			if(anim==60) break; end
			switch(direccion)
				case 0: z=5; y-=45; angle=0; end
				case 1: z=-1; x+=30;angle=270000; end
				case 2: y+=30; angle=180000; end
				case 3: x-=30; angle=90000; end
			end
			anim++;
			frame;
		end
	end
	//AGUJAS_HIELO
	if(tipo==AGUJAS_HIELO)
		alpha=255;
		size=100;
		while(anim<70 and exists(father))
			alpha-=5;
			size+=6;
			x=father.x;
			y=father.y;
			z=-50;
			anim++;
			frame;
		end
	end
	//BOMBAS
	if(tipo==BOMBAS)
		x=father.x;
		y=father.y;
		z=-10;
		while(anim<150 and exists(father))
			size=100+anim/8;
			anim++;
			frame;
		end
		sonido(1);
		explosion();
	end
	//LARGA DISTANCIA
	if(tipo==SHURIKEN or tipo==FLECHA or tipo==PIEDRA
	 or tipo==LLAMAS or tipo==MISIL_BAZOOKA or tipo==BOOMERANG or tipo==BOLA_HIELO or tipo==KUNAI or tipo==BOLA_RAYOS or tipo==BALAS)
		x=father.x;
		y=father.y;
		direccion=father.direccion;
		if(tipo==BOOMERANG) id_sonido=play_wav(sonidos[9],10); end
		loop
			if(!exists(father)) break; end
			if(tipo==BOOMERANG or tipo==SHURIKEN or tipo==BOLA_HIELO)
				angle+=20000; 
			else
				switch(direccion)
					case 0: angle=0; end
					case 1: angle=270000; end
					case 2: angle=180000; end
					case 3: angle=90000; end
				end
			end
			if(tipo==MISIL_BAZOOKA)
				nube();
			end
			if(tipo==BOLA_RAYOS)
				if(jugador<10)
					if(exists(type jefe))
						id_jefe=get_id(type jefe);
						if(direccion==1 or direccion==3)
							if(id_jefe.y<y) y-=2; elseif(id_jefe.y>y) y+=2; end
						else
							if(id_jefe.x<x) x-=4; elseif(id_jefe.x>x) x+=4; end
						end
					end
				else
					id_jefe=p[1].id;
					if(direccion==1 or direccion==3)
						if(id_jefe.y<y) y--; elseif(id_jefe.y>y) y++; end
					else
						if(id_jefe.x<x) x--; elseif(id_jefe.x>x) x++; end
					end
				end
			end
			if(tipo==BOOMERANG)
				switch(direccion)
					case 0: x=father.x; end
					case 1: y=father.y; end
					case 2: x=father.x; end
					case 3: y=father.y; end
				end
				if(anim<100) 
					switch(direccion)
						case 0: y-=velocidad*5; end
						case 1: x+=velocidad*5; end
						case 2: y+=velocidad*5; end
						case 3: x-=velocidad*5; end
					end
				else
					switch(direccion)
						case 0: y+=velocidad*5; end
						case 1: x-=velocidad*5; end
						case 2: y-=velocidad*5; end
						case 3: x+=velocidad*5; end
					end
					if(collision(father))
						if(father.accion==ATACANDO) father.accion=QUIETO; end 
						stop_wav(id_sonido);
						return;
					end
				end
			else
				switch(direccion)
					case 0: y-=velocidad*3; end
					case 1: x+=velocidad*3; end
					case 2: y+=velocidad*3; end
					case 3: x-=velocidad*3; end
				end
			end
			if(accion==-1)
				if(tipo==BOOMERANG and anim<100) anim=100; end
				if(tipo==SHURIKEN or tipo==FLECHA or tipo==PIEDRA or tipo==BALAS or tipo==LLAMAS or tipo==MISIL_BAZOOKA
					or tipo==BOLA_HIELO or tipo==KUNAI or tipo==BOLA_RAYOS)
					if(tipo==MISIL_BAZOOKA) sonido(15); explosion(); end
					if(father.accion==ATACANDO) father.accion=QUIETO; end
					cambiada_accion=1;
					return;
				end
			end
			
			anim+=velocidad;
			if(tipo==BALAS and anim>10 and father.accion==ATACANDO) father.accion=QUIETO; end
			if(anim>300)
				if(cambiada_accion==0)	
					if(father.accion==ATACANDO) father.accion=QUIETO; end
					cambiada_accion=1;
				end
			end
			if(ctype==c_scroll)
				if((x<80 or x>1200 or y<80 or y>2800) and tipo!=BOOMERANG)
					if(tipo==MISIL_BAZOOKA)
						sonido(15);
						explosion();
					end
					if(father.accion==ATACANDO) father.accion=QUIETO; end 
					return; 
				end
				if((x<80 or x>1200 or y<80 or y>2800) and tipo==BOOMERANG)
					if(anim<100) anim=100; end
				end
			else
				if((x<80 or x>1200 or y<80 or y>640) and tipo!=BOOMERANG)
					if(tipo==MISIL_BAZOOKA)
						sonido(15);
						explosion();
					end
					if(father.accion==ATACANDO) father.accion=QUIETO; end 
					return; 
				end
				if((x<80 or x>1200 or y<80 or y>640) and tipo==BOOMERANG)
					if(anim<100) anim=100; end
				end
			end
			frame;
		end
	end
	if(father.accion==ATACANDO) father.accion=QUIETO; end
End

Process ayudante();
Private
	retraso=30;
	id_jefe;
	cambio_prota=300;
Begin
	file=fpg_armas;
	alpha=0;
	graph=30;
	ctype=father.ctype;
	jugador=father.jugador;
	while(!exists(type jefe)) 
		frame; 
		x=father.x;
		y=father.y;
	end
	while(exists(father))
		if(alpha<160) alpha+=5; end
		if(alpha=>160)
			if(jugador<10)
				id_jefe=get_id(type jefe);
			else
				if(jugadores==2)
					if(cambio_prota==300)
						id_jefe=p[rand(1,2)].id;
						cambio_prota=0;
					else
						cambio_prota++;
					end
				else
					id_jefe=p[1].id;
				end
			end
			if(exists(id_jefe))
				if(id_jefe.y<y) y-=2; elseif(id_jefe.y>y) y+=2; end
				if(id_jefe.x<x) x-=4; elseif(id_jefe.x>x) x+=4; end
				if(collision(id_jefe) and retraso==30) retraso=0; vida[id_jefe.jugador]--; end
			end
		end
		if(retraso<30) retraso++; end
		anim++;
		if(anim<10)
			graph=30;
		elseif(anim<20)
			graph=31;
		elseif(anim<30)
			graph=32;
		else 
			anim=0; 
		end
		if(!exists(type jefe)) break; end
		frame;
	end
	from alpha=160 to 0 step -10; frame; end
End

Process explosion();
Begin
	jugador=father.jugador;
	ataque=8;
	ctype=father.ctype;
	x=father.x;
	y=father.y;
	z=-50;
	alpha=1;
	file=fpg_armas;
	graph=29;
	size=30;
	while(anim<30)
		anim++;
		if(anim<15) 
			if(alpha<240) alpha+=30; end
		end
		alpha-=20;
		size+=6;
		frame;
	end
End

Process puerta(tipo);
Begin
	if(jodido) return; end
	if((tipo>0 and tipo<4) or tipo==8) x=40; angle=90000; end
	if((tipo>3 and tipo<7) or tipo==7) x=1240; angle=-90000; end
	if(tipo==1 or tipo==4 or tipo==7 or tipo==8) y=360; end
	if(tipo==2 or tipo==5) y=1080; end
	if(tipo==3 or tipo==6) y=1800; end
	if(tipo==9 or tipo==10) x=640; end
	if(tipo==9) y=680; angle=180000; end
	if(tipo==10) y=40; end
	if(tipo==11) x=640; y=2840; angle=180000; end
	if(tipo<7 or tipo==10 or tipo==11) ctype=c_scroll; end
	graph=4;
	file=fpg_general;
	z=10;
	loop
		if(tipo==9 and collision(type personaje_piernas)) mazmorra(0); end
		if(tipo==11 and collision(type personaje_piernas)) libertad(); end
		if(exists(type jefe)) graph=5; else graph=4; end
		frame;
	end
End

Process libertad();
Begin
	graph=get_screen();
	x=640; y=360; z=-1000;
	stop_scroll(0);
	let_me_alone();
	play_song(load_song("fin.ogg"),1);
	set_fps(10,0);
	fade(200,200,200,1);
	while(fading) frame; end
	frame(3000);
	set_fps(60,3);
	fade(0,0,0,2);
	timer[0]=0;
	while(timer[0]<500)
		frame;
	end
	mazmorra(-1);
End

Process arma_pistola(graph);
Begin
	ctype=father.ctype;
	file=fpg_armas;
	jugador=father.jugador;
	while(exists(father) and exists(father.father) and father.accion==ATACANDO)
		direccion=father.direccion;
		y=father.father.y;
		x=father.father.x;
		if(father.direccion==0)
			z=4;
			angle=0;
			flags=0;
			x=father.father.x;
			y=father.father.y-20;
		elseif(father.direccion==1)
			z=4;
			angle=270000;
			flags=0;
			x=father.father.x+20;
			y=father.father.y;
		elseif(father.direccion==2)
			angle=180000;
			flags=0;
			x=father.father.x;
			y=father.father.y+20;
		elseif(father.direccion==3)
			z=4;
			angle=270000;
			flags=1;
			x=father.father.x-20;
			y=father.father.y;
		end
		if(graph==TIRACHINAS) angle=0; end
		frame;
	end
End

Process premio(tipo,num); //tipos: 1 ARMA, 2 OBJETO
Private
	id_arma;
	id_col;
	sala;
Begin
	if(jodido) return; end
	x=640;
	y=240;
	z=-10;
	sala=father.jugador;
	if(tipo==1)
		file=fpg_armas2;
		if(num==FLECHA or num==PIEDRA or num==BALAS or num==RAYO_LASER or num==LLAMAS or num==MISIL_BAZOOKA)
			num--;
		end
		graph=num;
		if(graph==RAYOS)
			graph=230;
		end
	else
		file=fpg_objetos;
		graph=num;
	end
	loop
		if(id_col=collision(type personaje))
			jugador=id_col.jugador;
			if(tipo==1 and p[jugador].armas[2]!=0)
				//ayuda_cambio_arma();
				if(p[jugador].botones[4] or p[jugador].botones[5]) break; end
			else
				break;
			end
		end
		frame;
	end
	if(tipo==1)
		if(p[jugador].botones[4] and p[jugador].armas[2]!=0) p[jugador].armas[1]=num; else p[jugador].armas[2]=num; end
	else
		if(num!=100)
			p[jugador].objetos[1]=num;
		end
	end
	id_col.accion=OBJETO;
	from anim=0 to 60;
		if(exists(type arma))
			if(id_arma=get_id(type arma)) signal(id_arma,s_kill); end
		end
		x=id_col.x-20;
		y=id_col.y-40;
		frame; 
	end
	graph=0;
	jefes_muertos[id_mazmorra-1]=-1;
	if(num==100)
		ponle_corona(p[jugador].id);
		victorias++;
		vida[1]=50;
		hacerse_el_rey();
		frame(5000);
		fade_music_off(100);
		fade(0,0,0,4); 
		while(fading) frame; end
		frame;
		let_me_alone();
		timer[0]=0;
		while(timer[0]<300) frame; end
		play_song(cancion,-1);
		p[1].armas[1]=1; p[1].armas[2]=0; p[1].objetos[1]=0;
		p[2].armas[1]=1; p[2].armas[2]=0; p[2].objetos[1]=0;
		rolear_premios();
		from jugador=0 to 10;
			jefes_muertos[jugador]=0;
		end
		from jugador=0 to 99;
			vida[jugador]=30;
		end
		vida[1]=50;
		vida[2]=50;
		id_mazmorra=0;
		mazmorra(0);
	end
End

Process ayuda_cambio_arma();
Begin
	file=fpg_general;
	graph=2;
	x=640;
	y=480;
	z=10;
	frame;
End

Function hacerse_el_rey();
Begin
	jugador=father.jugador;
	from i=5 to 0 step -1;
		from j=0 to 2;
			jefes_salas[i+1][j]=jefes_salas[i][j];
		end
	end
	jefes_salas[0][0]=p[jugador].armas[1];
	jefes_salas[0][1]=p[jugador].armas[2];
	jefes_salas[0][2]=p[jugador].objetos[1];
End

Process fin();
Begin
	let_me_alone();
	stop_scroll(0);
	graph=14;
	file=fpg_general;
	x=640;
	y=360;
	z=-500;
	fade_music_off(300);
	clear_screen();
	from alpha=0 to 255 step 5; frame; end
	timer[0]=0;
	while(timer[0]<500) frame; end
	from alpha=255 to 0 step -5; frame; end
End

include "..\..\common-src\controles.pr-";