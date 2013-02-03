import "mod_blendop";
//import "mod_debug";
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
import "mod_wm";

Const
	//-------DIRECCIONES
	ARRIBA=0;
	DERECHA=1;
	ABAJO=2;
	IZQUIERDA=3;

	//-----ACCION DEL PERSONAJE O enemigo
	QUIETO=0;
	ATACANDO=1;
	CON_OBJETO=2;
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
	
	//-----ENEMIGOS
	GOLEM=1;
	ARAÑA=2;
	FANTASMA=3;
	MAGO=4;
	MURCIELAGO=5;
	SANDRO=6;
	TORO=7;
	KAMIKAZE_FUEGO=8;
	KAMIKAZE_HIELO=9;
	KAMIKAZE_RAYO=10;
	ESQUELETO=11;
	ARQUERO=12;
	NINJA=13;
	ELEMENTAL_FUEGO=14;
	ELEMENTAL_HIELO=15;
	ELEMENTAL_RAYO=16;
	CICLOPE=17;
	ARAÑA_GIGANTE=18;
	SANDRO_REY=19;

	XP_BASE=40;
	
Global
	ancho_pantalla=1280;
	alto_pantalla=720;
	bpp=32;

	min_nivel_x;
	borde_nivel_x;
	min_nivel_y;
	borde_nivel_y;
	
	struct p[8];
		vida=100;
		nivel=1;
		ataque=1;
		defensa=1;
		velocidad=1;
		suerte=1;
		experiencia=0;
		xp_anterior=xp_base;
		xp_siguiente;
		botones[7];
		juega;
		id;
		fpg;
		control;
		armas[2];
		objeto;
	end
	struct enemigos[900];
		vida;
		id;
		tipo;
		resistencia;
		debilidad;
		ataque;
		defensa;
		velocidad;
		experiencia;
	end
	
	posibles_jugadores;
	joysticks[4];
	njoys;
	nivel=1;	
	personaje;
	fpg_general;
	fpg_armas;
	fpg_armas2;
	fpg_enemigos;
	fpg_objetos;
	fpg_mapa;
	sonidos[100];
	primera_vez=1;
	cancion;
	fnt_puntos;
	fnt_texto;
	fnt_stats;
	fnt_criticos;
	arcade_mode;
	jugadores=1;
	size_mapa;
	centro;
	num_zonas;
	struct zonas[12][12];
		tipo=2;
		premio;
		id;
	end
	id_camara;
	id_jefe;
	jefe_muerto;

	ready;
	
Local
	ataque;
	defensa;
	suerte;
	tipo_ataque;
	x_inc;
	y_inc;
	inc_max;
	anim;
	direccion;
	accion;
	jugador;
	i;
	j;
	k;
	num_enemigo;
	tipo;
	knockback;
	retraso;
	jefe;
	
include "..\..\common-src\controles.pr-";
include "..\..\common-src\resolucioname.pr-";

Begin
	if(argc>0) if(argv[1]=="arcade") arcade_mode=1; end end
	cancion=load_song("isaac.ogg");
	play_song(cancion,-1);
	full_screen=true;
	if(arcade_mode) 
		full_screen=true; 
		scale_resolution=08000600; 
	else
		resolucioname(1280,720,1);
	end

	gamepad_boton_separacion=80;
	gamepad_boton_size=80;
	gamepad_botones=2;

	//full_screen=0; //DEBUG
	set_mode(1280,720,bpp);
	
	configurar_controles();
	rand_seed(time());
	carga_fpgs();
	carga_sonidos();
	set_fps(60,3);
	fade(0,0,0,0);
	frame;
	fnt_puntos=load_fnt("tiempo.fnt");
	fnt_texto=load_fnt("menu.fnt");
	fnt_stats=load_fnt("stats.fnt");
	fnt_criticos=load_fnt("criticos.fnt");
	//put_screen(fpg_general,11);
	
	mazmorra();
End

Function carga_fpgs();
Begin
	fpg_general=load_fpg("general.fpg");
	fpg_armas=load_fpg("armas.fpg");
	fpg_armas2=load_fpg("armas.fpg");
	from x=1 to 4; p[x].fpg=load_fpg("personaje"+x+".fpg"); end
	fpg_objetos=load_fpg("objetos.fpg");
	fpg_mapa=load_fpg("mapas.fpg");
	fpg_enemigos=load_fpg("enemigos.fpg");
End

Function carga_sonidos();
Begin
	from i=1 to 21;
		sonidos[i]=load_wav(i+".wav");
	end
End

Function sonido(num);
Begin
	play_wav(sonidos[num],0);
End

Process sombra();
Begin
	file=fpg_general;
	z=50;
	graph=10;
	alpha=200;
	loop
		while(!estoy_visible()) graph=0; frame; end
		graph=10;
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

Process mazmorra();
Private
	distancia_jefe;
	txt_distancia_jefe;
Begin
	ready=0;
	fade(0,0,0,8);
	while(fading) frame; end
	let_me_alone();
	delete_text(all_text);
	stop_scroll(0);
	frame(3000);
	fade(100,100,100,8);

	from i=0 to 300;
		enemigos[i].vida=0;
		enemigos[i].id=0;
		enemigos[i].tipo=0;
		enemigos[i].resistencia=0;
		enemigos[i].debilidad=0;
		enemigos[i].ataque=0;
		enemigos[i].defensa=0;
		enemigos[i].velocidad=0;
	end
	
	from i=1 to 8;
		p[i].vida=100;
		p[i].id=0;
		p[i].xp_siguiente=p[i].xp_anterior*1.25;
	end
	
	id_camara=0;

	jefe_muerto=0;
	size_mapa=nivel+2;

	centro=(size_mapa/2)+1;
	
	zonas[centro][centro].tipo=1;
		
	from i=1 to 99;
		if(map_exists(fpg_mapa,100+i) and map_exists(fpg_mapa,200+i))
			num_zonas=i;
		end
	end
	
	from i=1 to size_mapa;
		from j=1 to size_mapa;
			if(!(i==centro and j==centro))
				zonas[i][j].tipo=rand(2,num_zonas);
				if(rand(0,1)==1)
					premio((i*1280)-640,(j*720)-360,1,rand(1,28));
				else
					premio((i*1280)-640,(j*720)-360,2,rand(1,11));
				end
			end
			adorno_en_scroll((i*1280)-640,(j*720)-360,fpg_mapa,100+zonas[i][j].tipo,0);
		end
	end

	switch(rand(0,3))
		case ARRIBA: puerta(centro*1280-640,-31,ARRIBA); end
		case DERECHA: puerta((size_mapa*1280)+31,(centro*720)-360,DERECHA); end
		case ABAJO: puerta(centro*1280-640,(size_mapa*720)+11,ABAJO); end
		case IZQUIERDA: puerta(-31,(centro*720)-360,IZQUIERDA); end
	end
	
	jefe_muerto=0;
	
	borde_nivel_x=size_mapa*ancho_pantalla-30;
	min_nivel_x=30;
	borde_nivel_y=size_mapa*alto_pantalla-30;
	min_nivel_y=30;
	
	from i=1 to 200;
		enemigos[i].vida=0;
		enemigos[i].tipo=0;
	end
	
	k=0;
	from i=1 to size_mapa;
		from j=1 to size_mapa;
			if(!(i==centro and j==centro))
				from x=1 to 5;
					enemigos[k].id=enemigo(rand(1280*(i-1),1280*i),rand(720*(j-1),720*j),zonas[i][j].tipo-1,k++);
				end
			end
		end
	end

	//titulo
	if(nivel==1)
		adorno_en_scroll_fadeout((centro*1280)-640,(centro*720)-550,fpg_general,1,0); //arriba izquierda
	end

	//num nivel
	adorno_en_scroll((centro*1280)-640,(centro*720)-360,0,write_in_map(fnt_texto,"B"+nivel,4),0); //arriba izquierda
	
	//jefe
	enemigo(rand(40,(size_mapa*1280)-40),rand(40,(size_mapa*720)-40),100+rand(1,19),k++);
	
	//4 esquinas
	adorno_en_scroll(-41,-41,fpg_mapa,4,0); //arriba izquierda
	adorno_en_scroll(borde_nivel_x+71,-41,fpg_mapa,4,-90000); //arriba derecha
	adorno_en_scroll(-41,borde_nivel_y+71,fpg_mapa,4,90000); //abajo izquierda
	adorno_en_scroll(borde_nivel_x+71,borde_nivel_y+71,fpg_mapa,4,180000); //abajo derecha
	
	//bordes
	from i=0 to size_mapa-1;
		adorno_en_scroll(-41,(alto_pantalla/2)+(i*alto_pantalla),fpg_mapa,3,0);
		adorno_en_scroll(borde_nivel_x+71,(alto_pantalla/2)+(i*alto_pantalla),fpg_mapa,3,180000);
		
		adorno_en_scroll((ancho_pantalla/2)+(i*ancho_pantalla),-41,fpg_mapa,2,0);
		adorno_en_scroll((ancho_pantalla/2)+(i*ancho_pantalla),borde_nivel_y+71,fpg_mapa,2,180000);
	end
	
	start_scroll(0,fpg_mapa,1,0,0,15);
	scroll[0].camera=camara();
	//scroll[0].camera=id_jefe;
	
	p[1].juega=1;	
	from i=1 to 8;
		if(p[i].juega) personaje(i); end
	end

	//fade(100,100,100,8);

	controlador(0);
	
	from i=1 to 300;
		join_in();
		frame;
	end

	//distancia hasta el jefe
	txt_distancia_jefe=write_int(fnt_puntos,ancho_pantalla/2,50,4,&distancia_jefe);
	
	ready=1;
	loop
		if(p[jugador].botones[B_SALIR])
			ready=0;
			while(p[jugador].botones[B_SALIR])
				mensaje_rapido("Mantén la tecla ESC o el botón BACK para salir");
				j++;
				if(j==180) exit(); end
				frame;
			end
			while(!p[jugador].botones[B_SALIR])
				mensaje_rapido("Pausa");
				frame;
			end
			while(p[jugador].botones[B_SALIR])
				mensaje_rapido("Pausa");
				frame;
			end
			ready=1;
			j=0;
		end
		
		if(exists(id_jefe))
			if(exists(id_camara))
				x=id_camara.x;
				y=id_camara.y;
				distancia_jefe=get_dist(id_jefe)/100;
			end
		elseif(txt_distancia_jefe!=-1)
			delete_text(txt_distancia_jefe);
			txt_distancia_jefe=-1;
		end

		num_personajes();
		join_in();
		if(todos_muertos())
			fade(50,50,50,4);
			set_fps(15,0);
			graph=49; 
			mensaje("GAME OVER");
			from alpha=255 to 0 step -5; frame; end 
			fade_music_off(100); 
			while(!key(_esc)) frame; end
			exit();
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

Process personaje(jugador);
Private
	pulsando;
	id_colision;
	x_dest;
	y_dest;
Begin
	retraso=10;
	while(!exists(id_camara)) frame; end
	x=id_camara.x;
	y=id_camara.y;
	ctype=c_scroll;
	p[jugador].id=id;
	switch(jugador)
		case 1: x-=30; y-=30; end
		case 2: x+=30; y-=30; end
		case 3: x-=30; y+=30; end
		case 4: x+=30; y+=30; end
	end
	if(jugador==1 or jugador==3) x-=30; y-=30; else x+=30; y+=30; end
	if(jugador==3 or jugador==4) x-=30; y-=30; else x+=30; y+=30; end
	if(p[jugador].armas[1]==0) p[jugador].armas[1]=1; end
	controlador(jugador);
	file=p[jugador].fpg;
	graph=7;
	priority=1;
	personaje_piernas();
	personaje_cuerpo();
	pon_hud();
	sombra();
	if(p[jugador].objeto==CONTRATO) ayudante(); end
	
	while(comprueba_dureza(x,y))
		x+=rand(-3,3);
		y+=rand(-3,3);
	end
	
	loop
		while(!ready)
			accion=quieto;
			frame; 
		end
		p[jugador].id=id;
		
		sube_nivel();
		ataque=p[jugador].ataque;
		defensa=p[jugador].defensa;
		inc_max=(p[jugador].velocidad/3)+4;
		suerte=p[jugador].suerte;
		
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
		if(accion==CON_OBJETO) //cogiendo objeto
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
				case 0: graph=37; y_inc=20-anim; end
				case 1: graph=40; x_inc=-(20-anim); end
				case 2: graph=43; y_inc=-(20-anim); end
				case 3: graph=40; x_inc=20-anim; flags=1;end
			end
			if(p[jugador].objeto==BOTAS_HIERRO)
				x_inc/=2;
				y_inc/=2;
			end
			if(anim<20)
				if(p[jugador].objeto==BOTAS_HIERRO) 
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
			if(id_colision=collision(type enemigo))
				accion=HERIDO;
				i=id_colision.ataque-p[jugador].defensa;
				if(i<1) i=1; end
				p[jugador].vida-=i; 
				vida_quitada(i,0);
			end
			if(id_colision=collision(type arma))
				if(id_colision.num_enemigo>0)
					accion=HERIDO; 
					if((p[jugador].objeto==PENDIENTES_FUEGO and id_colision.tipo_ataque==FUEGO) or
						(p[jugador].objeto==COLLAR_HIELO and id_colision.tipo_ataque==HIELO) or
						(p[jugador].objeto==BRAZALETES_RAYO and id_colision.tipo_ataque==RAYO) or
						(p[jugador].objeto==ARMADURA_GELATINA and id_colision.tipo_ataque==PUNZANTE) or
						(p[jugador].objeto==ARMADURA_MALLA and id_colision.tipo_ataque==CORTANTE) or
						(p[jugador].objeto==ARMADURA_PESADA and id_colision.tipo_ataque==IMPACTO))
						//NO FOUL?
					elseif(p[jugador].objeto==CASCO_REFORZADO)
						i=(id_colision.ataque-p[jugador].defensa)-p[jugador].nivel;
						if(i<1) i=1; end
						p[jugador].vida-=i;
						vida_quitada(i,0);
					else
						i=id_colision.ataque-p[jugador].defensa;
						if(i<1) i=1; end
						p[jugador].vida-=i;
						vida_quitada(i,0);
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
			if(id_colision=collision(type explosion))
				accion=HERIDO;
				if(p[jugador].objeto==ARMADURA_PESADA)
					//NO FOUL?
				elseif(p[jugador].objeto==CASCO_REFORZADO)
					p[jugador].vida-=id_colision.ataque-p[jugador].defensa-p[jugador].nivel;
					vida_quitada(id_colision.ataque-p[jugador].defensa-p[jugador].nivel,0);
				else
					p[jugador].vida-=id_colision.ataque-p[jugador].defensa;
					vida_quitada(id_colision.ataque-p[jugador].defensa,0);
				end
			end
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
			limita_inercia();
		end
		if(p[jugador].objeto==BOTAS_ALADAS and accion!=HERIDO)
			nube();
			x_inc*=2;
			y_inc*=2;
		end

		if(accion==ATACANDO)
			x_dest=x+(x_inc/2);
			y_dest=y+(y_inc/2);
		else
			x_dest=x+x_inc;
			y_dest=y+y_inc;
		end
		
		mueveme(x,x_dest,y,y_dest);

		if(p[jugador].objeto==BOTAS_ALADAS and accion!=HERIDO)
			x_inc/=2;
			y_inc/=2;
		end
		if((x_inc!=0 or y_inc!=0) and accion==QUIETO) 
			accion=ANDANDO; 
		end
		if((x_inc==0 and y_inc==0) and accion==ANDANDO) 
			accion=QUIETO;
		end
		
		//bordes nivel
		if(x<min_nivel_x) if(accion==HERIDO) direccion=1; end x=min_nivel_x; end
		if(x>borde_nivel_x) if(accion==HERIDO) direccion=3; end x=borde_nivel_x; end
		if(y<min_nivel_y) if(accion==HERIDO) direccion=2; end y=min_nivel_y; end
		if(y>borde_nivel_y) if(accion==HERIDO) direccion=0; end y=borde_nivel_y; end

		//bordes camara
		if(x<id_camara.x-(ancho_pantalla/2)) if(accion==HERIDO) direccion=1; end x_inc+=5; end
		if(x>id_camara.x+(ancho_pantalla/2)) if(accion==HERIDO) direccion=3; end x_inc-=5; end
		if(y<id_camara.y-(alto_pantalla/2)) if(accion==HERIDO) direccion=2; end y_inc+=5; end
		if(y>id_camara.y+(alto_pantalla/2)) if(accion==HERIDO) direccion=0; end y_inc-=5; end
		
		if(p[jugador].vida=<0)
			graph=49;
			p[jugador].armas[1]=1;
			p[jugador].armas[2]=0;
			p[jugador].objeto=0;
			if(jugadores>1)
				loop
					if(id_colision=collision(type personaje)) if(id_colision.jugador!=jugador and p[id_colision.jugador].vida>0) break; end end
					if(id_colision=collision(type personaje_cuerpo)) if(id_colision.jugador!=jugador and p[id_colision.jugador].vida>0) break; end end
					if(id_colision=collision(type personaje_piernas)) if(id_colision.jugador!=jugador and p[id_colision.jugador].vida>0) break; end end
					frame;
				end
				p[jugador].vida=100;
				accion=con_objeto;
				alpha=255;
			else
				while(1) frame; end 
			end
		end
		frame;
	end	
End

Process personaje_cuerpo();
Begin
	file=father.file;
	z=1;
	jugador=father.jugador;
	graph=father.graph+1;
	x=father.x;
	y=father.y;
	ctype=c_scroll;
	while(exists(father))
		while(!ready) frame; end
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
		elseif(father.accion==ATACANDO or father.accion==CON_OBJETO or father.accion==HERIDO)
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
	graph=father.graph+2;
	x=father.x;
	y=father.y;
	ctype=c_scroll;
	while(exists(father))
		while(!ready) frame; end
		if(father.accion==QUIETO or father.accion==CON_OBJETO or father.accion==HERIDO or father.accion==ATACANDO)
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

Process pon_hud();
Begin
	jugador=father.jugador;
	hud_arma(1);
	hud_arma(2);
	hud_arma(3);
	vida_personaje();
	pon_stats();
	graph=6;
	z=-9;
	if(jugador==1 or jugador==3) x=280; else x=1000; end
	if(jugador==1 or jugador==2) y=50; else y=680; end
	loop
		frame; 
	end
End

Function pon_stats();
Private
	align;
Begin
	jugador=father.jugador;
	switch(jugador)
		case 1:
			x=20;
			y=20;
			align=0;
		end
		case 2:
			x=1140;
			y=20;
			align=2;
		end
		case 3:
			x=20;
			y=580;
			align=0;
		end
		case 4:
			x=1140;
			y=580;
			align=2;
		end
	end
	write(fnt_stats,x,y,0,"Nivel");
	write_int(fnt_stats,x+120,y,0,&p[jugador].nivel);
	y+=20;
	write(fnt_stats,x,y,0,"Ataque");
	write_int(fnt_stats,x+120,y,0,&p[jugador].ataque);
	y+=20;
	write(fnt_stats,x,y,0,"Defensa");
	write_int(fnt_stats,x+120,y,0,&p[jugador].defensa);
	y+=20;
	write(fnt_stats,x,y,0,"Velocidad");
	write_int(fnt_stats,x+120,y,0,&p[jugador].velocidad);
	y+=20;
	write(fnt_stats,x,y,0,"Suerte");
	write_int(fnt_stats,x+120,y,0,&p[jugador].suerte);
	y+=20;
	write(fnt_stats,x,y,0,"XP");
	write_int(fnt_stats,x,y+15,align,&p[jugador].experiencia);
	write(fnt_stats,x+60,y+15,0,"/");
	write_int(fnt_stats,x+120,y+15,align,&p[jugador].xp_siguiente);
	y+=20;
End

Process vida_personaje();
Begin
	z=-12;
	jugador=father.jugador;
	if(jugador==1 or jugador==3) x=280; else x=1000; end
	if(jugador==1 or jugador==2) y=100; else y=620; end
	graph=7;
	loop
		if(p[jugador].vida>0)
			size_x=100/100*p[jugador].vida;
		else
			size_x=0;
		end
		frame;
	end
End

Process hud_arma(num);
Begin
	jugador=father.jugador;
	z=-10;
	y=50;
	if(jugador==1 or jugador==2) y=50; else y=680; end
	if(jugador==1 or jugador==3)
		switch(num)
			case 1: x=180; file=fpg_armas2; end
			case 2: x=280; file=fpg_armas2; end
			case 3: x=380; file=fpg_objetos; end
		end
	else
		switch(num)
			case 1: x=900; file=fpg_armas2; end
			case 2: x=1000; file=fpg_armas2; end
			case 3: x=1100; file=fpg_objetos; end
		end
	end
	loop
		if(num<3) 
			graph=p[jugador].armas[num];
			if(graph==RAYOS)
				graph=230;
			end
		else 
			graph=p[jugador].objeto; 
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
	id_enemigo;
Begin
	//1:espada
	//2:...
	if(father.accion==ATACANDO OR father.accion==CON_OBJETO OR father.accion==HERIDO) return; end
	file=fpg_armas;
	ctype=father.ctype;
	direccion=father.direccion;
	num_enemigo=father.num_enemigo;
	suerte=father.suerte;
	
	if(tipo==BAZOOKA)
		father.accion=HERIDO;
	else
		father.accion=ATACANDO;
	end
	jugador=father.jugador;
	if(tipo==ARCO or tipo==TIRACHINAS or tipo==METRALLETA or tipo==PISTOLA_LASER or tipo==LANZALLAMAS or tipo==BAZOOKA)
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

	if(jugador>0)
		if(p[jugador].objeto==ANILLO_PODER) ataque*=2; end
		ataque+=p[jugador].ataque;
	end

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
	 or tipo==LLAMAS or tipo==MISIL_BAZOOKA or tipo==BOOMERANG or tipo==BOLA_HIELO or tipo==KUNAI or 
	 tipo==BOLA_RAYOS or tipo==BALAS)
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
				id_enemigo=enemigo_mas_cercano();
				if(exists(id_enemigo))
					if(direccion==1 or direccion==3)
						if(id_enemigo.y<y) y-=2; elseif(id_enemigo.y>y) y+=2; end
					else
						if(id_enemigo.x<x) x-=4; elseif(id_enemigo.x>x) x+=4; end
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
			if((x<0 or x>borde_nivel_x or y<0 or y>borde_nivel_y or comprueba_dureza(x,y)) and tipo!=BOOMERANG)
				if(tipo==MISIL_BAZOOKA)
					sonido(15);
					explosion();
				end
				if(father.accion==ATACANDO) father.accion=QUIETO; end 
				return; 
			end
			if((x<0 or x>borde_nivel_x or y<0 or y>borde_nivel_y or comprueba_dureza(x,y)) and tipo==BOOMERANG)
				if(anim<100) anim=100; end
			end
			frame;
		end
	end
	if(exists(father))
		if(father.accion==ATACANDO) father.accion=QUIETO; end
	end
End

Process ayudante();
Private
	id_enemigo;
Begin
	tipo=FANTASMA;
	retraso=30;
	file=fpg_armas;
	alpha=0;
	graph=30;
	ctype=c_scroll;
	jugador=father.jugador;
	if(exists(p[jugador].id))
		x=p[jugador].id.x;
		y=p[jugador].id.y;
	end
	loop
		while(!ready) frame; end
/*		if(!en_pantalla())
			if(exists(p[jugador].id))
				//alpha=0;
				x=p[jugador].id.x;
				y=p[jugador].id.y;
			end
		end*/
		if(p[jugador].objeto!=CONTRATO) break; end
		if(p[jugador].vida=<0) break; end
		if(alpha<160) alpha+=5; end
		if(alpha=>160)
			if(!exists(id_enemigo))
				id_enemigo=enemigo_mas_cercano();
			else
				persigue_enemigo(id_enemigo);
				mueveme(x,x+x_inc,y,y+y_inc);

				limita_inercia();
				
				friccion();
			end
		end
		if(retraso<140)
			retraso++; 
		else
			retraso=0;
			if(exists(id_enemigo))
				if(collision(id_enemigo))
					enemigos[id_enemigo.num_enemigo].vida-=p[jugador].ataque;
					vida_quitada(p[jugador].ataque,0);
				end
			end
		end

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
				
		frame;
	end
	from alpha=160 to 0 step -10; frame; end
End

Process explosion();
Begin
	ataque=father.ataque*2;
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

Process puerta(x,y,direccion);
Begin
	ctype=c_scroll;
	switch(direccion)
		case ARRIBA: end
		case DERECHA: angle=-90000; end
		case ABAJO: angle=180000; end
		case IZQUIERDA: angle=90000; end
	end
	graph=4;
	file=fpg_general;
	z=10;
	loop
		if(jefe_muerto)
			graph=4; 
			if(collision(type personaje))
				nivel_superado();
				loop frame; end
			end
		else 
			graph=5; 
		end
		frame;
	end
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

Process premio(x,y,tipo,num); //tipos: 1 ARMA, 2 OBJETO
Private
	id_arma;
	id_col;
	sala;
Begin
	ctype=c_scroll;
	z=-10;
	sala=father.jugador;
	
	loop
		if(comprueba_dureza(x,y) or comprueba_dureza(x-15,y) or comprueba_dureza(x,y-15) or comprueba_dureza(x+15,y) or comprueba_dureza(x,y+15))
			x+=rand(-3,3);
			y+=rand(-3,3);
		else
			break;
		end
	end
	
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
			ayuda_cambio_arma();
			if(tipo==2 or p[jugador].botones[4] or p[jugador].botones[5])  //hay que pulsar botón para coger un arma
				accion=1;
			end
		end
		if(accion==1)
			if(tipo==1)
				if(p[jugador].botones[b_1])
					i=p[jugador].armas[1];
					p[jugador].armas[1]=num;
				elseif(p[jugador].botones[b_2])
					i=p[jugador].armas[2];
					p[jugador].armas[2]=num;
				end
			else
				i=p[jugador].objeto;
				p[jugador].objeto=num;
			end
			p[jugador].id.accion=CON_OBJETO;
			from anim=0 to 60;
				x=id_col.x-20;
				y=id_col.y-40;
				frame; 
			end
			y+=60;
			graph=0;
			if(tipo==2 and num==CONTRATO) ayudante(); end
			if(i==0) break; end
			graph=num=i;
			alpha=128;
			while(collision(type personaje) or collision(type personaje_cuerpo) or collision(type personaje_piernas)) frame; end
			frame(9000);
			from alpha=128 to 255; frame; end
			accion=0;
		end
		frame;
	end
End

Process ayuda_cambio_arma();
Begin
	file=fpg_general;
	ctype=c_scroll;
	x=father.x;
	y=father.y;
	z=-200;
	graph=2;
	z=10;
	frame;
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

Process camara();
Private
	cam_min_x;
	cam_min_y;
	cam_max_x;
	cam_max_y;
	dest_x;
	dest_y;
Begin
	id_camara=id;
	cam_min_x=(ancho_pantalla/2)-82;
	cam_min_y=(alto_pantalla/2)-82;
	cam_max_x=(size_mapa*ancho_pantalla)-((ancho_pantalla/2)-82);
	cam_max_y=(size_mapa*alto_pantalla)-((alto_pantalla/2)-82);

	x=(centro*ancho_pantalla)-(ancho_pantalla/2);
	y=(centro*alto_pantalla)-(alto_pantalla/2);
	
	loop
		if(jugador==0)
			dest_x=centro_personajes(1);
			dest_y=centro_personajes(2);
		else
			if(exists(p[jugador].id))
				dest_x=p[jugador].id.x;
				dest_y=p[jugador].id.y;
			end
		end

		if(dest_x!=-1 and dest_y!=-1)
			x+=(dest_x-x)/20;
			y+=(dest_y-y)/20;
		end
		
		//bordes
		if(x<cam_min_x) 
			x=cam_min_x; 
		elseif(x>cam_max_x) 
			x=cam_max_x; 
		end
		if(y<cam_min_y) 
			y=cam_min_y; 
		elseif(y>cam_max_y) 
			y=cam_max_y; 
		end
		
		frame;
	end
End

Function desaparezco();
Begin
	if(get_dist(id_camara)>ancho_pantalla*1.8)
		return 1;
	else 
		return 0;
	end
End

Function todos_muertos();
Begin
	from i=1 to 8;
		if(p[i].vida>0 and p[i].juega)
			return 0;
		end
	end
	return 1;
End

Function enemigo_mas_cercano();
Private
	dist_mas_cercano=10000;
	dist_actual;
Begin
	x=father.x;
	y=father.y;
	if(!exists(type enemigo))
		return 0;
	else
		from i=1 to 200;
			if(exists(enemigos[i].id) and enemigos[i].vida>0 and get_dist(enemigos[i].id)<1000)
				dist_actual=get_dist(enemigos[i].id);
				if(dist_actual<dist_mas_cercano)
					dist_mas_cercano=dist_actual;
					j=i;
				end
			end
		end
	end
	return enemigos[j].id;
End

Process nivel_superado();
Begin
	nivel++;
	mazmorra();
End

Function centro_personajes(tipo); //1:x, 2:y
Private
	suma;
	dividendo;
Begin
	from i=1 to 8;
		if(p[i].juega and p[i].vida>0 and exists(p[i].id))
			if(tipo==1)
				suma+=p[i].id.x;
			else
				suma+=p[i].id.y;
			end
			dividendo++;
		end
	end
	if(dividendo==0)
		return -1;
	end
	return suma/dividendo;
End

Process adorno_en_scroll(x,y,file,graph,angle);
Private
	graph_orig;
Begin
	z=500;
	ctype=c_scroll;
	graph_orig=graph;
	loop
		frame(10000);
	end
End

Process adorno_en_scroll_fadeout(x,y,file,graph,angle);
Private
	graph_orig;
Begin
	z=500;
	ctype=c_scroll;
	graph_orig=graph;
	from alpha=0 to 255 step 3; frame; end
	frame(20000);
	from alpha=255 to 0 step -3; frame; end
End

Function comprueba_dureza(x,y);
Private
	zona_x;
	zona_y;
Begin
	zona_x=(x/1280)+1;
	zona_y=(y/720)+1;
	if(map_get_pixel(fpg_mapa,200+zonas[zona_x][zona_y].tipo,x%1280,y%720)!=map_get_pixel(fpg_mapa,200+zonas[zona_x][zona_y].tipo,1,1))
		return 1;
	end
	return 0;
End

Function mueveme(x,x_dest,y,y_dest);
Begin
	if(father.tipo==FANTASMA or father.tipo==MURCIELAGO or father.jefe)
		if(x<x_dest)
			while(x<x_dest) x++; end
		elseif(x>x_dest)
			while(x>x_dest) x--; end
		end
		if(y<y_dest)
			while(y<y_dest) y++; end
		elseif(y>y_dest)
			while(y>y_dest) y--; end
		end
	else
		if(x<x_dest)
			while(x<x_dest and !comprueba_dureza(x+20,y)) x++; end
		elseif(x>x_dest)
			while(x>x_dest and !comprueba_dureza(x-20,y)) x--; end
		end
		if(y<y_dest)
			while(y<y_dest and !comprueba_dureza(x,y+30)) y++; end
		elseif(y>y_dest)
			while(y>y_dest and !comprueba_dureza(x,y-10)) y--; end
		end
	end
	if(x<min_nivel_x) x=min_nivel_x; end
	if(x>borde_nivel_x) x=borde_nivel_x; end
	if(y<min_nivel_y) y=min_nivel_y; end
	if(y>borde_nivel_y) y=borde_nivel_y; end

	father.x=x;
	father.y=y;
End

Process enemigo(x,y,tipo,num_enemigo);
Private
	x_dest;
	y_dest;
	x_orig;
	y_orig;
	xp;
	id_colision;
	id_personaje;
	ultimo_atacante;
	graph_base;
	sin_lados;
	sin_ataque;
	kamikaze;
	soy_jefe;
Begin
	ctype=c_scroll;
	
	file=fpg_enemigos;
	
	x_orig=x;
	y_orig=y;
		
	if(tipo>100)
		jefe=1;
		id_jefe=id;
		soy_jefe=1; 
		tipo=tipo-100; 
		size=250; 
		sonido_jefe();
	end
				
	graph_base=(tipo-1)*50;
	
	//si el enemigo de esta zona no ha sido creado aún, cambiamos de tipo de enemigo
	while(!map_exists(fpg_enemigos,graph_base+1))
		tipo=rand(1,19);
		graph_base=(tipo-1)*50;
	end
	graph=graph_base+1;

	//comprobamos si existen gráficos de lados
	if(map_exists(fpg_enemigos,graph_base+6))
		sin_lados=0;
	else
		sin_lados=1;
	end
	
	//comprobamos si existen gráficos de ataque
	if(map_exists(fpg_enemigos,graph_base+16))
		sin_ataque=0;
	else
		sin_ataque=1;
	end
	
	switch(tipo)
		case GOLEM:
			enemigos[num_enemigo].debilidad=HIELO;
			enemigos[num_enemigo].resistencia=IMPACTO;
			enemigos[num_enemigo].vida=7;
			enemigos[num_enemigo].ataque=7;
			enemigos[num_enemigo].defensa=4;
			enemigos[num_enemigo].velocidad=2;
			enemigos[num_enemigo].experiencia=15;
		end
		case ARAÑA: 
			enemigos[num_enemigo].debilidad=IMPACTO;
			enemigos[num_enemigo].resistencia=PUNZANTE;
			enemigos[num_enemigo].vida=2;
			enemigos[num_enemigo].ataque=2;
			enemigos[num_enemigo].defensa=1;
			enemigos[num_enemigo].velocidad=5;
			enemigos[num_enemigo].experiencia=5;
		end
		case FANTASMA: 
			enemigos[num_enemigo].debilidad=FUEGO;
			enemigos[num_enemigo].resistencia=CORTANTE;
			enemigos[num_enemigo].vida=4;
			enemigos[num_enemigo].ataque=3;
			enemigos[num_enemigo].defensa=2;
			enemigos[num_enemigo].velocidad=3;
			enemigos[num_enemigo].experiencia=7;
		end
		case MAGO: 
			enemigos[num_enemigo].debilidad=IMPACTO;
			enemigos[num_enemigo].resistencia=FUEGO;
			enemigos[num_enemigo].vida=4;
			enemigos[num_enemigo].ataque=4;
			enemigos[num_enemigo].defensa=1;
			enemigos[num_enemigo].velocidad=2;
			enemigos[num_enemigo].experiencia=6;
		end
		case MURCIELAGO: 
			enemigos[num_enemigo].debilidad=RAYO;
			enemigos[num_enemigo].resistencia=PUNZANTE;
			enemigos[num_enemigo].vida=3;
			enemigos[num_enemigo].ataque=5;
			enemigos[num_enemigo].defensa=1;
			enemigos[num_enemigo].velocidad=4;
			enemigos[num_enemigo].experiencia=5;
		end
		case SANDRO: 
			enemigos[num_enemigo].debilidad=0;
			enemigos[num_enemigo].resistencia=0;
			enemigos[num_enemigo].vida=3;
			enemigos[num_enemigo].ataque=3;
			enemigos[num_enemigo].defensa=2;
			enemigos[num_enemigo].velocidad=2;
			enemigos[num_enemigo].experiencia=4;
		end
		case TORO: 
			enemigos[num_enemigo].debilidad=HIELO;
			enemigos[num_enemigo].resistencia=IMPACTO;
			enemigos[num_enemigo].vida=5;
			enemigos[num_enemigo].ataque=4;
			enemigos[num_enemigo].defensa=2;
			enemigos[num_enemigo].velocidad=3;
			enemigos[num_enemigo].experiencia=5;
		end
		case KAMIKAZE_FUEGO:
			enemigos[num_enemigo].debilidad=RAYO;
			enemigos[num_enemigo].resistencia=FUEGO;
			enemigos[num_enemigo].vida=4;
			enemigos[num_enemigo].ataque=6;
			enemigos[num_enemigo].defensa=1;
			enemigos[num_enemigo].velocidad=4;
			enemigos[num_enemigo].experiencia=3;
			kamikaze=1;
		end
		case KAMIKAZE_HIELO: 
			enemigos[num_enemigo].debilidad=FUEGO;
			enemigos[num_enemigo].resistencia=HIELO;
			enemigos[num_enemigo].vida=4;
			enemigos[num_enemigo].ataque=6;
			enemigos[num_enemigo].defensa=1;
			enemigos[num_enemigo].velocidad=4;
			enemigos[num_enemigo].experiencia=3;
			kamikaze=1;
		end
		case KAMIKAZE_RAYO: 
			enemigos[num_enemigo].debilidad=HIELO;
			enemigos[num_enemigo].resistencia=RAYO;
			enemigos[num_enemigo].vida=4;
			enemigos[num_enemigo].ataque=6;
			enemigos[num_enemigo].defensa=1;
			enemigos[num_enemigo].velocidad=4;
			enemigos[num_enemigo].experiencia=3;
			kamikaze=1;
		end
		case ESQUELETO: 
			enemigos[num_enemigo].debilidad=IMPACTO;
			enemigos[num_enemigo].resistencia=CORTANTE;
			enemigos[num_enemigo].vida=2;
			enemigos[num_enemigo].ataque=3;
			enemigos[num_enemigo].defensa=2;
			enemigos[num_enemigo].velocidad=2;
			enemigos[num_enemigo].experiencia=3;
		end
		case ARQUERO: 
			enemigos[num_enemigo].debilidad=CORTANTE;
			enemigos[num_enemigo].resistencia=PUNZANTE;
			enemigos[num_enemigo].vida=4;
			enemigos[num_enemigo].ataque=4;
			enemigos[num_enemigo].defensa=1;
			enemigos[num_enemigo].velocidad=3;
			enemigos[num_enemigo].experiencia=6;
		end
		case NINJA: 
			enemigos[num_enemigo].debilidad=PUNZANTE;
			enemigos[num_enemigo].resistencia=CORTANTE;
			enemigos[num_enemigo].vida=4;
			enemigos[num_enemigo].ataque=4;
			enemigos[num_enemigo].defensa=1;
			enemigos[num_enemigo].velocidad=3;
			enemigos[num_enemigo].experiencia=6;
		end
		case ELEMENTAL_FUEGO: 
			enemigos[num_enemigo].debilidad=RAYO;
			enemigos[num_enemigo].resistencia=FUEGO;
			enemigos[num_enemigo].vida=5;
			enemigos[num_enemigo].ataque=6;
			enemigos[num_enemigo].defensa=3;
			enemigos[num_enemigo].velocidad=4;
			enemigos[num_enemigo].experiencia=10;
		end
		case ELEMENTAL_HIELO: 
			enemigos[num_enemigo].debilidad=FUEGO;
			enemigos[num_enemigo].resistencia=HIELO;
			enemigos[num_enemigo].vida=5;
			enemigos[num_enemigo].ataque=6;
			enemigos[num_enemigo].defensa=3;
			enemigos[num_enemigo].velocidad=4;
			enemigos[num_enemigo].experiencia=10;
		end
		case ELEMENTAL_RAYO: 
			enemigos[num_enemigo].debilidad=HIELO;
			enemigos[num_enemigo].resistencia=RAYO;
			enemigos[num_enemigo].vida=5;
			enemigos[num_enemigo].ataque=6;
			enemigos[num_enemigo].defensa=3;
			enemigos[num_enemigo].velocidad=4;
			enemigos[num_enemigo].experiencia=10;
		end
		case CICLOPE: 
			enemigos[num_enemigo].debilidad=PUNZANTE;
			enemigos[num_enemigo].resistencia=IMPACTO;
			enemigos[num_enemigo].vida=18;
			enemigos[num_enemigo].ataque=10;
			enemigos[num_enemigo].defensa=3;
			enemigos[num_enemigo].velocidad=3;
			enemigos[num_enemigo].experiencia=50;
		end
		case ARAÑA_GIGANTE: 
			enemigos[num_enemigo].debilidad=IMPACTO;
			enemigos[num_enemigo].resistencia=CORTANTE;
			enemigos[num_enemigo].vida=13;
			enemigos[num_enemigo].ataque=8;
			enemigos[num_enemigo].defensa=2;
			enemigos[num_enemigo].velocidad=3;
			enemigos[num_enemigo].experiencia=30;
		end
		case SANDRO_REY: 
			enemigos[num_enemigo].debilidad=0;
			enemigos[num_enemigo].resistencia=0;
			enemigos[num_enemigo].vida=13;
			enemigos[num_enemigo].ataque=7;
			enemigos[num_enemigo].defensa=2;
			enemigos[num_enemigo].velocidad=2;
			enemigos[num_enemigo].experiencia=35;
		end
	end

	//si es jefe, lo chutamos
	if(soy_jefe)
		enemigos[num_enemigo].vida=enemigos[num_enemigo].vida*10;
		enemigos[num_enemigo].ataque=enemigos[num_enemigo].ataque*2;
		enemigos[num_enemigo].velocidad=enemigos[num_enemigo].velocidad*1.5;
		enemigos[num_enemigo].experiencia=enemigos[num_enemigo].experiencia*4;
	end
	
	//calculo de vida real
	enemigos[num_enemigo].vida=enemigos[num_enemigo].vida*((1+jugadores)*nivel*0.4);

	//calculo de stats dependiendo del nivel
	enemigos[num_enemigo].ataque=enemigos[num_enemigo].ataque+(enemigos[num_enemigo].ataque*nivel*0.5);
	enemigos[num_enemigo].vida=enemigos[num_enemigo].vida+(enemigos[num_enemigo].vida*nivel*0.5);
	enemigos[num_enemigo].defensa=enemigos[num_enemigo].defensa+(enemigos[num_enemigo].defensa*nivel*0.5);
	enemigos[num_enemigo].velocidad=(enemigos[num_enemigo].velocidad-2)+(nivel/2);
	enemigos[num_enemigo].experiencia=enemigos[num_enemigo].experiencia+((nivel-1)*0.4);
	
	if(enemigos[num_enemigo].velocidad<2) enemigos[num_enemigo].velocidad=2; end
	
	ataque=enemigos[num_enemigo].ataque;
	
	inc_max=enemigos[num_enemigo].velocidad;
	
	while(!exists(id_camara)) frame; end
	
	loop
		x=rand(x_orig-620,x_orig+620);
		y=rand(y_orig-340,y_orig+340);
		if(!comprueba_dureza(x,y) and !en_pantalla()) break; end
	end
		
	while(!estoy_visible())
		graph=0;
		frame(4000);
	end
	
	sombra();
	
	while(enemigos[num_enemigo].vida>0)
		while(!ready) frame; end
		x_dest=x+x_inc;
		y_dest=y+y_inc;
			
		mueveme(x,x_dest,y,y_dest);	
		
		if(accion!=HERIDO)
			if(!exists(id_personaje) or id_personaje==0)
				id_personaje=personaje_mas_cercano();
			else
				persigue_prota(id_personaje);
				mira_al_id(id_personaje);
			end
			limita_inercia();					
	
			if(kamikaze)
				if(collision(type personaje))
					explosion();
					break;
				end
			end
			
			if(tipo==TORO)
				if(exists(id_personaje))
					if(abs(id_personaje.x-x)<30)
						inc_max=enemigos[num_enemigo].velocidad*2;
					elseif(abs(id_personaje.y-y)<30)
						inc_max=enemigos[num_enemigo].velocidad*2;
					end
				else
					inc_max=enemigos[num_enemigo].velocidad;
				end
			end
			
			if(!sin_ataque)
				if(get_dist(id_personaje)<100)
					accion=ATACANDO;
					retraso=30;
				end
			end
			
			if(id_colision=collision(type arma))
				ultimo_atacante=id_colision.jugador;
				accion=HERIDO; 
				knockback=10+(inc_max*5);
				if(knockback>20) knockback=0; end
								
				if(enemigos[num_enemigo].resistencia==id_colision.tipo_ataque and id_colision.tipo_ataque!=0)
					knockback=knockback/2;
					//No recibe daño, pero si KNOCKBACK
				else
					i=id_colision.ataque-enemigos[num_enemigo].defensa;
					if(i<1) i=1; end
					enemigos[num_enemigo].vida-=i;
					if(rand(0,100)<id_colision.suerte) 
						vida_quitada(i*2,1);
					else
						vida_quitada(i,0);
					end
				end
				id_colision.accion=-1;
				switch(id_colision.direccion)
					case ARRIBA: direccion=ABAJO; end
					case DERECHA: direccion=IZQUIERDA; end
					case ABAJO: direccion=ARRIBA; end
					case IZQUIERDA: direccion=DERECHA; end
				end
			end

			if(id_colision=collision(type explosion))
				accion=HERIDO;
				enemigos[num_enemigo].vida-=id_colision.ataque;
				vida_quitada(id_colision.ataque,0);
				knockback=30;
			end	
			
			if(id_colision=collision(type enemigo))
				if(id_colision>id)
					if(id_colision.x>x)
						id_colision.x_inc++;
						id_colision.y_inc++;
						x_inc--;
						y_inc--;
					else
						id_colision.x_inc--;
						id_colision.y_inc--;
						x_inc++;
						y_inc++;
					end
				end
			end
		end

		friccion();
			
		//animacion:
		if(accion==HERIDO)
			nube();
			id_personaje=personaje_mas_cercano();
			if(knockback>0)
				switch(direccion)
					case ARRIBA: y_inc=knockback/2; end
					case DERECHA: x_inc=-knockback/2; end
					case ABAJO: y_inc=-knockback/2; end
					case IZQUIERDA: x_inc=knockback/2; end
				end

				knockback--;
			else
				accion=QUIETO;
			end
		elseif(accion==ATACANDO)
			if(not sin_ataque)
				if(sin_lados)
					graph=graph_base+16;
				else
					switch(direccion)
						case ARRIBA: graph=graph_base+16; end
						case DERECHA: graph=graph_base+21; end
						case ABAJO: graph=graph_base+26; end
						case IZQUIERDA: graph=graph_base+21; flags=1; end
					end
				end
			end
			if(retraso>0)
				retraso--;
			else
				accion=QUIETO;
			end
		else //QUIETO
			accion=QUIETO;
			if(x_inc!=0 or y_inc!=0)
				//comprobamos si está entre la animación actual
				if(sin_lados)
					if(!(graph=>graph_base+1 and graph=<graph_base+5))
						anim=9;
					end
				else
					switch(direccion)
						case ARRIBA:
							if(!(graph=>graph_base+11 and graph=<graph_base+15))
								anim=9;
							end
						end
						case DERECHA:
							if(!(graph=>graph_base+6 and graph=<graph_base+10))
								anim=9;
							end
						end
						case ABAJO:
							if(!(graph=>graph_base+1 and graph=<graph_base+5))
								anim=9;
							end
						end
						case IZQUIERDA:
							if(!(graph=>graph_base+6 and graph=<graph_base+10))
								anim=9;
							end
						end
					end
				end
				
				if(anim>8)
					anim=0;

					//animamos!
					graph++;
					
					//comprobamos si está dentro de la animación, y si no fuera así, seteamos.
					if(sin_lados)
						if((!(graph=>graph_base+1 and graph=<graph_base+5)) or !map_exists(fpg_enemigos,graph))
							graph=graph_base+1;
						end
					else
						switch(direccion)
							case ARRIBA:
								if(!(graph=>graph_base+11 and graph=<graph_base+15) or !map_exists(fpg_enemigos,graph))
									graph=graph_base+11;
								end
							end
							case DERECHA:
								if(!(graph=>graph_base+6 and graph=<graph_base+10) or !map_exists(fpg_enemigos,graph))
									graph=graph_base+6;
									flags=0;
								end
							end
							case ABAJO:
								if(!(graph=>graph_base+1 and graph=<graph_base+5) or !map_exists(fpg_enemigos,graph))
									graph=graph_base+1;
								end
							end
							case IZQUIERDA:
								if(!(graph=>graph_base+6 and graph=<graph_base+10) or !map_exists(fpg_enemigos,graph))
									graph=graph_base+6;
									flags=1;
								end
							end
						end
					end

					/*//comprobamos si ha llegado al límite de la animación
					if(sin_lados)
						if(graph==graph_base+6 or !map_exists(fpg_enemigos,graph))
							graph=graph_base+1;
						end
					else
						switch(direccion)
							case ARRIBA: 
								if(graph==graph_base+6 or !map_exists(fpg_enemigos,graph))
									graph=graph_base+1;
								end
							end
							case DERECHA: 
								if(graph==graph_base+26 or !map_exists(fpg_enemigos,graph))
									graph=graph_base+21; 
								end
								flags=0;
							end
							case ABAJO: 
								if(graph==graph_base+31 or !map_exists(fpg_enemigos,graph))
									graph=graph_base+26; 
								end
							end
							case IZQUIERDA: 
								if(graph==graph_base+26 or !map_exists(fpg_enemigos,graph))
									graph=graph_base+21; 
								end
								flags=1;
							end
						end
					end*/
				else
					anim++;
				end
			else //fin en movimiento
				if(sin_lados)
					graph=graph_base+1;
				else
					switch(direccion)
						case ARRIBA: graph=graph_base+11; end
						case DERECHA: graph=graph_base+6; end
						case ABAJO: graph=graph_base+1; end
						case IZQUIERDA: graph=graph_base+6; end
					end
				end
			end
		end		
		frame;
	end
	//from alpha=255 to 0 step -10; frame; end
	explotalo();
	explotalo();
	explotalo();
	graph=0;
	if(soy_jefe)
		frame(3000);
		jefe_muerto=1;
	end
	//sube_experiencia((int) enemigos[num_enemigo].experiencia*0.3);
	sube_experiencia((enemigos[num_enemigo].experiencia*60)/100);
	p[ultimo_atacante].experiencia+=enemigos[num_enemigo].experiencia*0.5;
End

Function personaje_mas_cercano();
Private
	dist_mas_cercano=10000;
	dist_actual;
Begin
	x=father.x;
	y=father.y;
	if(!exists(type personaje))
		return 0;
	else
		from i=1 to 8;
			if(p[i].juega and p[i].vida>0 and exists(p[i].id))
				dist_actual=get_dist(p[i].id);
				if(dist_actual<dist_mas_cercano and (dist_actual<500 or (dist_actual<1000 and father.jefe)))
					dist_mas_cercano=dist_actual;
					j=i;
				end
			end
		end
	end
	return p[j].id;
End

Function persigue_prota(id_prota);
Begin
	if(exists(id_prota))
		if(id_prota.accion!=HERIDO)
			if(p[id_prota.jugador].vida>0 and p[id_prota.jugador].juega)
				if(id_prota.x<father.x)
					father.x_inc-=2;
				elseif(id_prota.x>father.x) 
					father.x_inc+=2;
				end
				if(id_prota.y<father.y)
					father.y_inc-=2;
				elseif(id_prota.y>father.y) 
					father.y_inc+=2;
				end
			end
		else
			if(p[id_prota.jugador].vida>0 and p[id_prota.jugador].juega)
				if(id_prota.x<father.x)
					father.x_inc+=2;
				elseif(id_prota.x>father.x) 
					father.x_inc-=2;
				end
				if(id_prota.y<father.y)
					father.y_inc+=2;
				elseif(id_prota.y>father.y) 
					father.y_inc-=2;
				end
			end
		end
	end
End

Function persigue_enemigo(id_enemigo);
Begin
	if(exists(id_enemigo))
		if(enemigos[id_enemigo.num_enemigo].vida>0)
			if(id_enemigo.x<father.x)
				father.x_inc-=2;
			elseif(id_enemigo.x>father.x)
				father.x_inc+=2;
			end
			if(id_enemigo.y<father.y)
				father.y_inc-=2;
			elseif(id_enemigo.y>father.y) 
				father.y_inc+=2;
			end
		end
	end
End

Function persigue_id(id_enemigo);
Begin
	if(exists(id_enemigo))
		if(id_enemigo.x<father.x)
			father.x_inc-=2;
		elseif(id_enemigo.x>father.x)
			father.x_inc+=2;
		end
		if(id_enemigo.y<father.y)
			father.y_inc-=2;
		elseif(id_enemigo.y>father.y) 
			father.y_inc+=2;
		end
	end
End

Function num_personajes();
Begin
	jugadores=0;
	from i=1 to 8;
		if(p[i].juega) jugadores++; end
	end
End

Function join_in();
Begin
	from i=1 to 8;
		if(p[i].juega==0 and (p[i].botones[4] or p[i].botones[5] or p[i].botones[6]))
			p[i].juega=1;
			personaje(i);
		end
	end
End

Function en_pantalla();
Begin
	if(father.x<id_camara.x-(ancho_pantalla/2) or father.y<id_camara.y-(alto_pantalla/2) or 
	father.x>id_camara.x+(ancho_pantalla/2) or father.y<id_camara.y+(alto_pantalla/2))
		return 0;
	else
		return 1;
	end
End

Process sonido_jefe();
Private
	canal;
	bpm;
	distancia_x;
	distancia;
	left;
	right;
	volumen;
Begin
	while(jefe_muerto==0)
		while(is_playing_wav(canal)) frame; end
		if(exists(id_jefe))
			if(exists(id_camara)) x=id_camara.x; y=id_camara.y; end
			canal=play_wav(sonidos[21],0);
			//stereo
			distancia=get_dist(id_jefe);
			volumen=128-(distancia/15);
			if(volumen<0) volumen=0; end
			//volumen
			set_wav_volume(sonidos[21],volumen);
		end
		frame;
	end
End

Function estoy_visible();
Begin
	if(exists(id_camara))
		if(father.x<id_camara.x-1280 or father.x>id_camara.x+1280 or father.y<id_camara.y-720 or father.y>id_camara.y+720)
			return 0;
		else
			return 1;
		end
	end
	return 0;
End

Process sube_nivel();
Begin
	jugador=father.jugador;
	if(p[jugador].experiencia=>p[jugador].xp_siguiente)
		while(p[jugador].experiencia=>p[jugador].xp_siguiente)
			p[jugador].experiencia-=p[jugador].xp_siguiente;
			p[jugador].xp_anterior=p[jugador].xp_anterior*1.25;
			p[jugador].xp_siguiente=p[jugador].xp_anterior*1.25;
			p[jugador].nivel++;
			p[jugador].vida+=15;
			j++;
		end
		p[jugador].id.accion=CON_OBJETO;
		mensaje("Jugador "+jugador+" sube nivel");
		id_camara.jugador=i;
		ready=0;
		i=elige_stats(j);
		while(exists(i)) frame; end
		id_camara.jugador=0;
		ready=1;
	end
End

Function sube_experiencia(cantidad);
Begin
	from i=1 to 8;
		if(p[i].juega and p[i].vida>0)
			p[i].experiencia+=cantidad;
		end
	end
End

Process mensaje(string texto);
Begin
	graph=write_in_map(fnt_texto,texto,4);
	y=300;
	x=ancho_pantalla/2;
	from alpha=0 to 255 step 5; y++; frame; end
	frame(10000);
	from alpha=255 to 0 step -10; y++; frame; end
	unload_map(0,graph);
End

Process mensaje_rapido(string texto);
Begin
	graph=write_in_map(fnt_stats,texto,4);
	y=alto_pantalla/2;
	x=ancho_pantalla/2;
	frame(100);
	unload_map(0,graph);
End

Process vida_quitada(puntos,critico);
Private
	mi_fuente;
Begin
	ctype=c_scroll;
	i=-30;
	z=-100;
	if(critico) mi_fuente=fnt_criticos; else mi_fuente=fnt_puntos; end
	graph=write_in_map(mi_fuente,puntos,4);
	if(puntos<50) size=50; end
	if(puntos>200) size=150; end
	if(puntos>500) size=200; end
	loop
		if(exists(father))
			x=father.x;
			y=father.y+i;
		else
			break;
		end
		j+=5;
		if(i<35) i++; end
		if(j<256) alpha=j; end
		if(j>500) break; end
		frame;
	end
	from alpha=255 to 0 step -10; y++; frame; end
End

Process explotalo();
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
	grafico;
	frames;
Begin
	ctype=c_scroll;
	x=father.x;
	y=father.y;
	z=father.z-1;
	alpha=father.alpha;
	angle=father.angle;
	file=father.file;
	grafico=father.graph;
	frames=60;
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

Process elige_stats(j);
Private
	puntos_pendientes;
Begin
	ctype=c_scroll;
	jugador=father.jugador;
	puntos_pendientes=3*j;
	file=fpg_general;

	icono_stat(ARRIBA);
	icono_stat(ABAJO);
	icono_stat(IZQUIERDA);
	icono_stat(DERECHA);
	
	alpha=0;
	
	accion=-1;
	
	z=100;
	graph=19;
	
	while(x<p[jugador].id.x or y<p[jugador].id.y)
		if(alpha<255) alpha+=5; end
		x+=(p[jugador].id.x-x)/10;
		y+=(p[jugador].id.y-y)/10;
		if(x<p[jugador].id.x) x++; end
		if(y<p[jugador].id.y) y++; end
		frame;
	end
	while(p[jugador].botones[B_2]) frame; end
	loop
		if(p[jugador].botones[B_ARRIBA]) 
			accion=ARRIBA; //ATAQUE
		elseif(p[jugador].botones[B_DERECHA]) 
			accion=DERECHA; //VELOCIDAD
		elseif(p[jugador].botones[B_ABAJO]) 
			accion=ABAJO; //ALEATORIO
		elseif(p[jugador].botones[B_IZQUIERDA]) 
			accion=IZQUIERDA; //DEFENSA
		end
		
		if(p[jugador].botones[B_2] and accion!=-1)
			while(p[jugador].botones[B_2]) frame; end
			switch(accion)
				case ARRIBA: 
					p[jugador].ataque++; 
					texto_sube_punto("ATAQUE +1");
				end
				case DERECHA: 
					p[jugador].velocidad++; 
					texto_sube_punto("VELOCIDAD +1");
				end
				case IZQUIERDA: 
					p[jugador].defensa++; 
					texto_sube_punto("DEFENSA +1");
				end
				case ABAJO: 
					p[jugador].suerte++; 
					texto_sube_punto("SUERTE +1");
				end
			end
			puntos_pendientes--;
			accion=-1;
			if(puntos_pendientes==0) break; end
		end
		frame;
	end
	from alpha=255 to 0 step -10; frame; end
End

Process icono_stat(accion); //ARRIBA: ataque, DERECHA: velocidad, IZQUIERDA: defensa, ABAJO: aleatorio
Begin
	ctype=c_scroll;
	z=-10;
	file=fpg_general;
	while(exists(father))
		switch(accion)
			case ARRIBA: x=father.x; y=father.y-120; graph=16; end
			case DERECHA: x=father.x+120; y=father.y; graph=17; end
			case IZQUIERDA: x=father.x-120; y=father.y; graph=15; end
			case ABAJO: x=father.x; y=father.y+120; graph=18; end
		end
		alpha=father.alpha;
		if(father.accion==accion)
			size=130;
			alpha=255;
		else
			size=100;
			alpha=120;
		end
		frame;
	end
End

Process texto_sube_punto(string texto);
Begin
	graph=write_in_map(fnt_stats,texto,4);
	y=alto_pantalla/2;
	x=ancho_pantalla/2;
	from alpha=0 to 255 step 20; y--; frame; end
	from i=1 to 50; y--; frame; end
	from alpha=255 to 0 step -5; y--; frame; end
	unload_map(0,graph);
End

Function mira_al_id(id_mira);
Private
	angulo;
Begin
	if(exists(id_mira))
		angulo=get_angle(id_mira);
		if(angulo<45000) direccion=1;
		elseif(angulo<135000) direccion=0;
		elseif(angulo<225000) direccion=3;
		elseif(angulo<320000) direccion=2;
		else direccion=1;
		end
	end
End

Function friccion();
Begin
	if(father.x_inc>0) father.x_inc--; end
	if(father.x_inc<0) father.x_inc++; end
	if(father.y_inc>0) father.y_inc--; end
	if(father.y_inc<0) father.y_inc++; end
End

Function limita_inercia();
Begin
	if(father.x_inc>father.inc_max) father.x_inc=father.inc_max; end
	if(father.x_inc<-father.inc_max) father.x_inc=-father.inc_max; end
	if(father.y_inc>father.inc_max) father.y_inc=father.inc_max; end
	if(father.y_inc<-father.inc_max) father.y_inc=-father.inc_max; end
End