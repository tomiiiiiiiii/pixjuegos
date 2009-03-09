Program fenix_heroes;
Const
	filtro=0;
	hires=0;
Local
	BUG;
	anim;
	grav;
	toca_down;
		toca_down_left;
		toca_down_right;
	toca_left;
		toca_left_down;
		toca_left_up;
	toca_right;
		toca_right_down;
		toca_right_up;
	toca_up;
		toca_up_left;
		toca_up_right;
	tipo; //0=mario & luigi, 1=seta, ...
	item;
	inercia;
	ancho_queco;
	alto_queco;
Global
	struct opciones;
		musica=1;
	end
	ayuda=1;
	sonido_muneco;
	anillos;
	personaje=1; //0: mario, 1: sonic
	g_anim;
	fpgs[10];
	fnts[10];
	estado=1;
	snd[50];
	mapa_scroll;
	mapa_durezas;
	id_jugador;
	id_pasivo;
	puntos;
	vidas;
	mundo=1;
	bonus=0;

	tiempo;
	turno;

	//tiles
	suelo;
	para_sonic;
	para_mario;
	tiles[50];
	enemigos[50];
	adornos[50];
	bloque_info;
	//tiles
	
	alto_pantalla;
	ancho_pantalla;

	
	cambiar=1;
	ready;
	num_mov;
	saltando;
	rodando;
	combo;
	invencibilidad;
	ant_flags;

	blanco;
	negro;
	foto;

	struct movs[30];
		la_x;
		la_y;
		el_graph;
		las_flags;
	end

Begin
	dump_type=1;
	restore_type=1;
	full_screen=1;
	scale_mode=SCALE_SCALE2X;
    set_mode(320,240,32,MODE_WAITVSYNC);
	frame;
	set_fps(60,99);
	carga_fpgs();
	carga_wavs();
//	carga_fnts();
	carga_pngs();
	frame;
	anim_global();
	jugar();
End

include "interfaz.pix";
include "pruebas.pix";

Process anim_global();
Begin
	Loop
		g_anim+=2;
		If(g_anim=>89) g_anim=0; End
		Frame;
	End
End

Process carga_pngs();
Begin
	blanco=load_png("blanco.png");
	negro=load_png("negro.png");
End

Process carga_fpgs();
Begin
	fpgs[1]=load_fpg("./fpg/sonic.fpg");
	fpgs[0]=load_fpg("./fpg/mario.fpg");
	fpgs[2]=load_fpg("./fpg/anillo.fpg");
	fpgs[3]=load_fpg("./fpg/enemigos.fpg");
	fpgs[4]=load_fpg("./fpg/tiles.fpg");
	fpgs[5]=load_fpg("./fpg/items.fpg");
End

Process carga_wavs();
Private
	i;
Begin
	While(i<24)
		snd[i]=load_wav("./wav/"+itoa(i)+".wav");
		i++;
	End
End

Process carga_fnts();
Begin
	fnts[0]=load_fnt("./fnt/menu.fnt");
//	fnts[1]=load_fnt("./fnt/marcad.fnt");
End

Process pon_mod(i);
Begin
	if(opciones.musica)
		stop_song();
		play_song(load_song("./mod/"+itoa(i)+".it"),-1);
	end
End

Process sonido(i);
Begin
	sonido_muneco=play_wav(snd[i],0);
End

Process otro_sonido(i);
Begin
	//play_wav(snd[i],0);
End

Process mario(x,y);
Private
	subiendo;
	x_out;
	y_out;
	doble_salto;
	pulsando_alt;
	pulsando_control;
Begin
	id_jugador=id;
	file=fpgs[0];
	flags=1;
	ctype=c_scroll;
	graph=16;
	ancho_queco=graphic_info(file,graph,g_wide);
	alto_queco=graphic_info(file,graph,g_height);
	Loop
		if(key(_esc)) exit(); end
		while(ready==0) frame; end
		if(key(_space) and collision(id_pasivo) and saltando==0 and cambiar==1) 
			while(key(_space)) frame; end 
			if(estado!=0) id_jugador=sonic(x,y); else id_jugador=sonic(x,y-10); end
			personaje=1; 
			delete_text(all_text); 
			marcadores(); 
			return;
		end
// durezas
		toca_down=map_get_pixel(0,mapa_durezas,x,y+alto_queco/2);
			toca_down_left=map_get_pixel(0,mapa_durezas,x-ancho_queco/2,y+alto_queco/2);
			toca_down_right=map_get_pixel(0,mapa_durezas,x+ancho_queco/2,y+alto_queco/2);
		toca_left=map_get_pixel(0,mapa_durezas,x-ancho_queco/2,y);
			toca_left_down=map_get_pixel(0,mapa_durezas,x-ancho_queco/2,y+4);
			toca_left_up=map_get_pixel(0,mapa_durezas,x-ancho_queco/2,y-4);
		toca_right=map_get_pixel(0,mapa_durezas,x+ancho_queco/2,y);
			toca_right_down=map_get_pixel(0,mapa_durezas,x+ancho_queco/2,y+4);
			toca_right_up=map_get_pixel(0,mapa_durezas,x+ancho_queco/2,y-4);
		toca_up=map_get_pixel(0,mapa_durezas,x,y-alto_queco/2);
			toca_up_left=map_get_pixel(0,mapa_durezas,x-ancho_queco/2+1,y-alto_queco/2);
			toca_up_right=map_get_pixel(0,mapa_durezas,x+ancho_queco/2-1,y-alto_queco/2);
// horizontal
		If((key(_left) AND !key(_right) and !key(_down)) OR (!key(_down) and !key(_left) AND key(_right)) OR (inercia>0 OR inercia<0))
			If(estado==0)
				If(anim<=45) graph=4; End
				If(anim>45) graph=5; End
				If(inercia>20 AND key(_left)) graph=3; End
				If(inercia<-20 AND key(_right)) graph=3; End
			End
			If(estado==1)
				If(anim<=45) graph=17; End
				If(anim>45) graph=18; End
				If(inercia>20 AND key(_left)) graph=16; End
				If(inercia<-20 AND key(_right)) graph=16; End
			End
			If(estado==2)
				If(anim<=45) graph=33; End
				If(anim>45) graph=34; End
				If(inercia>20 AND key(_left)) graph=31; End
				If(inercia<-20 AND key(_right)) graph=31; End
			End
			If(key(_left) AND toca_left!=suelo AND !key(_down) and !key(_right)) if(inercia==0 and saltando==0) inercia=-15; end inercia-=2; If(saltando==0) flags=0; End End
			If(key(_right) AND toca_right!=suelo AND !key(_down) and !key(_left)) if(inercia==0 and saltando==0) inercia=15; end inercia+=2; If(saltando==0) flags=1; End End
		End
		If(inercia>0 AND (!key(_right) or (key(_left) and key(_right)))) inercia--; End
		If(inercia<0 AND (!key(_left) or (key(_left) and key(_right)))) inercia++; End
		If(((!key(_left) AND !key(_right) AND !key(_down)) or (key(_left) and key(_right) and (inercia>-4 AND inercia<4))) AND subiendo==0 AND (inercia>-4 AND inercia<4) OR (key(_left) AND key(_right)))
			If(estado==0) graph=7; End
			If(estado==1) graph=20; End
			If(estado==2) graph=36; End
		End
		If(inercia<-50 AND !key(_alt)) inercia=-50; End
		If(inercia>50 AND !key(_alt)) inercia=50; End
		If(inercia<-80) inercia=-80; End
		If(inercia>80) inercia=80; End
		x_out=x+inercia/20;
		While((toca_right!=suelo and toca_right_down!=suelo and toca_right_up!=suelo) AND x<x_out)
			toca_right=map_get_pixel(0,mapa_durezas,x+ancho_queco/2,y);
			toca_right_down=map_get_pixel(0,mapa_durezas,x+ancho_queco/2,y+4);
			toca_right_up=map_get_pixel(0,mapa_durezas,x+ancho_queco/2,y-4);
			x++;
		End
		While(x>x_out AND (toca_left!=suelo and toca_left_down!=suelo and toca_left_up!=suelo))
			toca_left=map_get_pixel(0,mapa_durezas,x-ancho_queco/2,y);
			toca_left_down=map_get_pixel(0,mapa_durezas,x-ancho_queco/2,y+4);
			toca_left_up=map_get_pixel(0,mapa_durezas,x-ancho_queco/2,y-4);
			x--;
		End		
		While(x<8) x++; End
		While(x>ancho_pantalla-8) x--; End
// vertical
		If(toca_down==suelo) grav=0; saltando=0; doble_salto=0; angle=0; End
		If(key(_control) AND subiendo==0 AND pulsando_control==0 and(toca_down==suelo OR toca_down_left==suelo OR toca_down_right==suelo) AND saltando==0)
			sonido(8);
			saltando=1;
			If(inercia>60) grav=-70; Else grav=-40; End
			y-=2;
		End
		If(key(_control) AND saltando==1)
			grav-=10;
			If(grav<-90 AND inercia<60) saltando=-1; End
			If(grav<-110 AND inercia>60) saltando=-1; End
		End
		If(toca_up==suelo AND saltando!=0 AND grav<40) saltando=-1; grav=40; End
		If(saltando==1 AND (!key(_control) OR grav<-140)) saltando=-1; End
		If(toca_down!=suelo AND subiendo!=1 AND saltando!=1)
			if(key(_down) and saltando==0 and inercia==0)
				//fcaca	
			else
				grav+=4;
				saltando=-1;
				if(doble_salto==0 and key(_control) and pulsando_control==0) grav=-100; sonido(21); doble_salto=1; end
			end
		End
		if(key(_alt) and !key(_down) and rodando==0 and inercia==0 and pulsando_alt==0 and saltando==0) 
			rodando=1;
			if(flags==0) inercia=-100; else inercia=+100; end
		end
		if(rodando==1)
			puño_fuego();
			inercia--;
		end
		If(key(_alt)) anim+=8; pulsando_alt=1; Else anim+=4; pulsando_alt=0; End
		y_out=y+grav/20;
		While(toca_down!=suelo AND y<y_out)
			toca_down=map_get_pixel(0,mapa_durezas,x,y+alto_queco/2);
			y++;
		End
//		While(y>y_out AND (toca_up!=suelo AND toca_up_left!=suelo AND toca_up_right!=suelo))
		While(y>y_out AND (toca_up!=suelo))
			toca_up=map_get_pixel(0,mapa_durezas,x,y-alto_queco/2);		
//			toca_up_left=map_get_pixel(0,mapa_durezas,x-ancho_queco/2+1,y-alto_queco/2);
//			toca_up_right=map_get_pixel(0,mapa_durezas,x+ancho_queco/2-1,y-alto_queco/2);
			y--;
		End
		If(y>alto_pantalla) estado=-1; End
		If((anim>89 OR inercia==0) and saltando==0) anim=0; End
		If(saltando!=0)
			If(estado==0) graph=2; End
			If(estado==1) graph=15; End
			If(estado==2) graph=30; End
			if(doble_salto==1) angle=anim*4000; end
		End
		If(key(_down) and saltando==0)
			If(estado==1) graph=14; End
			If(estado==2) graph=29; End
		End
		If(estado==-1) Break; End
		if(invencibilidad<180) alpha=128; if(item==-1) item=0; end invencibilidad++; end
		if(invencibilidad==180) alpha=255; end
		If(saltando!=0 and key(_control) and key(_left) and flags==1 and pulsando_control==0 and toca_right==suelo)
			grav=-80;
			flags=0;
			inercia=-100;
			sombra2();
		end
		If(saltando!=0 and key(_control) and key(_right) and flags==0 and pulsando_control==0 and toca_left==suelo)
			grav=-80;
			flags=1;
			inercia=100;
			sombra2();
		end
//
include "./masmario.pix";
//
		//////////////////////
		while(map_get_pixel(0,mapa_durezas,x,y+alto_queco/2-2)==suelo)
			y--;
		end
		//////////////////
		if(rodando==1 and inercia==0 or !key(_alt) or saltando!=0) rodando=0; end
		if(key(_control)) pulsando_control=1; else pulsando_control=0; end
//		if(key(_s)) while(key(_s)) frame; end team_blast(); end
		If((inercia>0 AND toca_right==suelo) OR ((inercia<0 AND toca_left==suelo))) inercia=0; End
		Frame;	
		movs[num_mov].la_x=x;
		movs[num_mov].la_y=y;
		movs[num_mov].el_graph=graph;
		movs[num_mov].las_flags=flags;
	End
	ready=0;
	angle=0;
	sonido(4);
	stop_song();
	graph=1;
	Frame(1000);
	grav=-80;
	While(y<alto_pantalla+20)
		size++;
		angle+=500;
		y+=grav/20;
		grav+=3;
		Frame;
	End
	grav=0;
	frame(10000);
	foto=get_screen();
	frame(5000);
	if(bonus==1) combo=0; loop frame; end end
	jugar();
End

Process puño_fuego();
Begin
	file=father.file;
	ctype=c_scroll;
	graph=100;
	if(father.flags==0) flags=1; else flags=0; end
	if(flags==1) x=father.x-10; else x=father.x+10; end
	if(estado!=0) size_y=rand(150,190); else size_y=rand(100,140); end
	y=father.y;
	from alpha=100 to 0 step -10; frame; end
End

Process sonic(x,y);
Private
	subiendo;
	x_out;
	y_out;
	pulsando_alt;
	pulsando_control;
Begin
	id_jugador=id;
	file=fpgs[1];
	ctype=c_scroll;
	write_int(0,0,0,0,offset anim);
	graph=12;
	ancho_queco=graphic_info(file,graph,g_wide);
	alto_queco=graphic_info(file,graph,g_height);
	Loop
		if(key(_esc)) exit(); end
		while(ready==0) frame; end
		if(key(_space) and collision(id_pasivo) and saltando==0 and rodando==0 and cambiar==1) 
			while(key(_space)) frame; end 
			if(estado!=0) id_jugador=mario(x,y); else id_jugador=mario(x,y+10); end
			personaje=0; 
			delete_text(all_text); 
			marcadores(); 
			return; 
		end
// durezas
		toca_down=map_get_pixel(0,mapa_durezas,x,y+alto_queco/2);
			toca_down_left=map_get_pixel(0,mapa_durezas,x-ancho_queco/2,y+alto_queco/2);
			toca_down_right=map_get_pixel(0,mapa_durezas,x+ancho_queco/2,y+alto_queco/2);
		toca_left=map_get_pixel(0,mapa_durezas,x-ancho_queco/2,y);
			toca_left_down=map_get_pixel(0,mapa_durezas,x-ancho_queco/2,y+4);
			toca_left_up=map_get_pixel(0,mapa_durezas,x-ancho_queco/2,y-4);
		toca_right=map_get_pixel(0,mapa_durezas,x+ancho_queco/2,y);
			toca_right_down=map_get_pixel(0,mapa_durezas,x+ancho_queco/2,y+4);
			toca_right_up=map_get_pixel(0,mapa_durezas,x+ancho_queco/2,y-4);
		toca_up=map_get_pixel(0,mapa_durezas,x,y-alto_queco/2);
			toca_up_left=map_get_pixel(0,mapa_durezas,x-ancho_queco/2+1,y-alto_queco/2);
			toca_up_right=map_get_pixel(0,mapa_durezas,x+ancho_queco/2-1,y-alto_queco/2);
// horizontal
		If((key(_left) AND !key(_right) and !key(_down)) OR (!key(_down) and !key(_left) AND key(_right)) OR (inercia>0 OR inercia<0))
			If(anim<=30) graph=5; End
			If(anim>30 AND anim<=60) graph=6; End
			If(anim>60) graph=7; End
			If(inercia>20 AND key(_left)) graph=56; if(saltando==0 and rodando==0 and !is_playing_wav(sonido_muneco)) sonido(15); end End
			If(inercia<-20 AND key(_right)) graph=56; if(saltando==0 and rodando==0 and !is_playing_wav(sonido_muneco)) sonido(15); end End
			If(key(_left) AND toca_left!=suelo and rodando==0 and !key(_right)) inercia-=2; If(saltando==0) flags=1; End End
			If(key(_right) AND toca_right!=suelo and rodando==0 and !key(_left)) inercia+=2; If(saltando==0) flags=0; End End
		End
		If(inercia>0 AND (!key(_right) or (key(_left) and key(_right)))) inercia--; End
		If(inercia<0 AND (!key(_left) or (key(_left) and key(_right)))) inercia++; End
		if(!key(_down) and graph==71) graph=12; end
		If(key(_down) and saltando==0)
			if(inercia==0)
				graph=71;
				if(collision(id_pasivo)) end
				if(key(_control) and collision(id_pasivo) and pulsando_control==0) 
					sonido(18);
					y+=6;
					while(key(_down))
						graph=16;
						angle=rand(0,360)*1000;
						frame;
						movs[num_mov].la_x=x;
						movs[num_mov].la_y=y;
						movs[num_mov].el_graph=graph;
						movs[num_mov].las_flags=flags;
						rodando=1;
						while(ready==0) frame; end
					end
					sonido(19);
					if(flags==0) inercia=180; else inercia=-180; end 
				end
			else
				if(rodando==0)
					y+=6;
					sonido(18);
					rodando=1;
					inercia=(inercia*11)/10;
				end
			end
		End
		if(rodando==1)
			if(saltando!=0 or inercia==0) rodando=0; y-=6; end
		end
		If(!key(_left) AND !key(_right) AND !key(_down) AND subiendo==0 AND (inercia>-4 AND inercia<4) OR (key(_left) AND key(_right)))
			if(anim>20 and (graph<12 or graph>15)) graph=12; anim=0; end
			if(anim>80 and graph>11 and graph<15) graph++; anim=0; end
			if(anim>80 and graph==15) graph=12; anim=0; end
		End
		If(inercia<-200) inercia=-200; End
		If(inercia>200) inercia=200; End
		x_out=x+inercia/20;
		While((toca_right!=suelo and toca_right_down!=suelo and toca_right_up!=suelo) AND x<x_out)
			toca_right=map_get_pixel(0,mapa_durezas,x+ancho_queco/2,y);
			toca_right_down=map_get_pixel(0,mapa_durezas,x+ancho_queco/2,y+4);
			toca_right_up=map_get_pixel(0,mapa_durezas,x+ancho_queco/2,y-4);
			x++;
		End
		While(x>x_out AND (toca_left!=suelo and toca_left_down!=suelo and toca_left_up!=suelo))
			toca_left=map_get_pixel(0,mapa_durezas,x-ancho_queco/2,y);
			toca_left_down=map_get_pixel(0,mapa_durezas,x-ancho_queco/2,y+4);
			toca_left_up=map_get_pixel(0,mapa_durezas,x-ancho_queco/2,y-4);
			x--;
		End		
		While(x<scroll.camera.x-152 OR x<8) x++; inercia=0; End
// vertical
		If(toca_down==suelo) grav=0; saltando=0; End
		If((key(_control) and !key(_down)) AND subiendo==0 and pulsando_control==0 AND (toca_down==suelo OR toca_down_left==suelo OR toca_down_right==suelo) AND saltando==0)
			sonido(17);
			saltando=1;
			If(inercia>100) grav=-120; Else grav=-60; End
			y-=2;
		End
		If((key(_control) and !key(_down)) AND saltando==1)
			grav-=10;
			If(grav<-90 AND inercia<60) saltando=-1; End
			If(grav<-110 AND inercia>60) saltando=-1; End
		End
		If(toca_up==suelo AND saltando!=0 AND grav<40) saltando=-1; grav=40; End
		If(saltando==1 AND (!key(_control) OR grav<-140)) saltando=-1; End
		If(toca_down!=suelo AND subiendo!=1 AND saltando!=1)
			if(key(_down) and saltando==0 and inercia==0)
				//fcaca	
			else
				saltando=-1;
				rodando=0;
				grav+=4;
			end
		End
		y_out=y+grav/20;
		While(toca_down!=suelo AND y<y_out)
			toca_down=map_get_pixel(0,mapa_durezas,x,y+alto_queco/2);
			y++;
		End
		While(y>y_out AND (toca_up!=suelo))
			toca_up=map_get_pixel(0,mapa_durezas,x,y-alto_queco/2);		
//			toca_up_left=map_get_pixel(0,mapa_durezas,x-ancho_queco/2+1,y-alto_queco/2);
//			toca_up_right=map_get_pixel(0,mapa_durezas,x+ancho_queco/2-1,y-alto_queco/2);
			y--;
		End
		If(y>alto_pantalla) estado=-1; End
//		If(anim>89 OR (inercia==0 and saltando==0)) anim=0; End
		If(anim>89) anim=0; End
		If(saltando!=0)
			graph=16;
			angle=anim*4000;
		else
			angle=0;
		end
		If(estado==-1) Break; End
		if(invencibilidad<180) alpha=128; if(item==-1) item=0; end invencibilidad++; end
		if(invencibilidad==180) alpha=255; end
//
include "./massonic.pix";
//
		if(key(_control)) pulsando_control=1; else pulsando_control=0; end
		if(collision(id_pasivo)) end //bug con la siguiente linea
		if(key(_alt) and collision(id_pasivo) and timer[9]>200 and saltando!=0 and pulsando_alt==0)
			timer[9]=0;
			sonido(18);
			while(timer[9]<100)
				graph=16;
				grav=-80;
				angle=rand(0,360)*1000;
				frame;
				movs[num_mov].la_x=x;
				movs[num_mov].la_y=y;
				movs[num_mov].el_graph=graph;
				movs[num_mov].las_flags=flags;
			end
			sonido(19);
			rodando=1;
			if(flags==0) inercia+=250; else inercia-=250; end
		end
		if(key(_alt) and rodando==0 and !exists(type persigue_anillos)) persigue_anillos(); end
		If(key(_alt)) pulsando_alt=1; anim+=8; Else pulsando_alt=0; anim+=8; End
		if(rodando==1) graph=16; angle=rand(0,360)*1000; end

		//////////////////////
		while(map_get_pixel(0,mapa_durezas,x,y+alto_queco/2-2)==suelo)
			y--;
		end
		if(rodando==1)
			y+=6;
		end
		//////////////////

		If((inercia>0 AND toca_right==suelo) OR ((inercia<0 AND toca_left==suelo)) or (inercia<2 and inercia>-2)) inercia=0; End
		if(inercia>100 or inercia<-100) sombra2(); end
		if(inercia>160 or inercia<-160) tiempo_bala(); end
		if(invencibilidad<0) graph=53; end
		Frame;	
		movs[num_mov].la_x=x;
		movs[num_mov].la_y=y;
		movs[num_mov].el_graph=graph;
		movs[num_mov].las_flags=flags;
	End
	ready=0;
	graph=53;
	sonido(20);
	Frame(2000);
	grav=y;
	from size=100 to 400 step 10; angle+=5000; if(y>grav-100) y-=2; else y+=2; end frame; end
	grav=0;
	from alpha=255 to 0 step -25; frame; end
	foto=get_screen();
	frame(5000);
	if(bonus==1) combo=0; loop frame; end end
	jugar();
End

Process persigue_anillos();
Private
	id_anillo;
	struct ani;
		la_x;
		la_y;
	end
Begin
	file=fpgs[4];
	graph=501;
	ctype=c_scroll;
	if(father.flags==0) x=father.x+(father.ancho_queco/2); end
	if(father.flags==1) x=father.x-(father.ancho_queco/2); end
	y=father.y;
	size_y=400;
	size_x=300;
	alpha=0;
	if(!collision(type anillo)) return; end
	toca_down=map_get_pixel(0,mapa_durezas,x,y);
	if(toca_down==suelo) return; end
	loop
		tiempo_bala();
		if(id_anillo=collision(type anillo))
			toca_down=map_get_pixel(0,mapa_durezas,x,y);
			if(toca_down==suelo) return; end
			if(father.flags==0) x=father.x+(father.ancho_queco/2); end
			if(father.flags==1) x=father.x-(father.ancho_queco/2); end
			y=father.y;
			ani.la_x=id_anillo.x;
			ani.la_y=id_anillo.y;
			father.x=ani.la_x;
			father.y=ani.la_y;
			if(father.flags==0) x=father.x+(father.ancho_queco/2); end
			if(father.flags==1) x=father.x-(father.ancho_queco/2); end
			y=father.y;
			father.grav=0;
			father.inercia=0;
			frame(100);
		else
			break;
		end
		if(father.flags==0) x=father.x+(father.ancho_queco/2); end
		if(father.flags==1) x=father.x-(father.ancho_queco/2); end
		y=father.y;
		frame(100);
	end
	father.grav=0;
	father.inercia=0;
	if(father.flags==0) father.inercia=80; else father.inercia=-80; end
End

Process jugador_pasivo();
Private
	cambiado;
Begin
	id_pasivo=id;
	z=1;
	ctype=c_scroll;
	alpha=180;
	loop
		while(cambiar==0) frame; end
		graph=movs[num_mov+1].el_graph;
		if(graph!=0)
			cambiado=0;
			if(personaje==0) //aqui sonic
				if(movs[num_mov+1].la_x!=0 and movs[num_mov+1].la_y!=0)
					x=movs[num_mov+1].la_x;
					if(estado==0) y=movs[num_mov+1].la_y-10; else y=movs[num_mov+1].la_y; end 
					if(movs[num_mov+1].las_flags==1) flags=0; else flags=1; end
				end
				file=fpgs[1];
				angle=0;
				if((graph==14 or graph==29) and cambiado==0) graph=71; cambiado=1; end
				if((graph==2 or graph==15 or graph==30) and cambiado==0) graph=16; angle=anim*4000; cambiado=1; end
				if((graph==3 or graph==16 or graph==31) and cambiado==0) graph=56; cambiado=1; end
				if((graph==4 or graph==17 or graph==33) and cambiado==0) graph=5; cambiado=1; end
				if((graph==5 or graph==18 or graph==34) and cambiado==0) graph=6; cambiado=1; end
				if((graph==6 or graph==19 or graph==35) and cambiado==0) graph=7; cambiado=1; end
				if((graph==7 or graph==20 or graph==36) and cambiado==0) graph=12; cambiado=1; end
			end
			if(personaje==1) //aqui mario
				if(movs[num_mov+1].la_x!=0 and movs[num_mov+1].la_y!=0)
					x=movs[num_mov+1].la_x;
					y=movs[num_mov+1].la_y;
					if(movs[num_mov+1].las_flags==1) flags=0; else flags=1; end
				end
				file=fpgs[0];
				angle=0;
				if(graph==16 and cambiado==0) graph=15; cambiado=1; end
				if(graph==56 and cambiado==0) graph=16; cambiado=1; end
				if(graph==5 or graph==6 or graph==7 and cambiado==0) if(anim>45) graph=17; else graph=18; end cambiado=1; end
				if(graph==71 and cambiado==0) graph=14; cambiado=1; end
				if((graph==12 or graph==13 or graph==14 or graph==15) and cambiado==0) graph=20; cambiado=1; end
			end
		else
			if(num_mov>=29)
			cambiado=0;
			if(personaje==0) //aqui sonic
				if(movs[num_mov].la_x!=0 and movs[num_mov].la_y!=0)
					x=movs[num_mov].la_x;
					if(estado==0) y=movs[num_mov+1].la_y-10; else y=movs[num_mov].la_y; end 
					if(movs[num_mov].las_flags==1) flags=0; else flags=1; end
				end
				file=fpgs[1];
				angle=0;
				if((graph==14 or graph==29) and cambiado==0) graph=71; cambiado=1; end
				if((graph==2 or graph==15 or graph==30) and cambiado==0) graph=16; angle=anim*4000; cambiado=1; end
				if((graph==3 or graph==16 or graph==31) and cambiado==0) graph=56; cambiado=1; end
				if((graph==4 or graph==17 or graph==33) and cambiado==0) graph=5; cambiado=1; end
				if((graph==5 or graph==18 or graph==34) and cambiado==0) graph=6; cambiado=1; end
				if((graph==6 or graph==19 or graph==35) and cambiado==0) graph=7; cambiado=1; end
				if((graph==7 or graph==20 or graph==36) and cambiado==0) graph=12; cambiado=1; end
			end
			if(personaje==1) //aqui mario
				if(movs[num_mov].la_x!=0 and movs[num_mov].la_y!=0)
					x=movs[num_mov].la_x;
					y=movs[num_mov].la_y;
					if(movs[num_mov].las_flags==1) flags=0; else flags=1; end
				end
				file=fpgs[0];
				angle=0;
				if(graph==16 and cambiado==0) graph=15; cambiado=1; end
				if(graph==56 and cambiado==0) graph=16; cambiado=1; end
				if(graph==5 or graph==6 or graph==7 and cambiado==0) if(anim>45) graph=17; else graph=18; end cambiado=1; end
				if(graph==71 and cambiado==0) graph=14; cambiado=1; end
				if((graph==12 or graph==13 or graph==14 or graph==15) and cambiado==0) graph=20; cambiado=1; end
			end
			end
		end
		while(ready==0) frame; end
		while(estado==-1) frame; end
		if(anim<89) anim+=4; else anim=0; end
		frame;
		if(num_mov>29) num_mov=0; else num_mov++; end
	end
End

Process sombra();
Begin
	sombra2();
	ctype=c_scroll;
	while(grav<15 and (id_jugador.inercia>40 or id_jugador.inercia<-40))
		file=father.file;
		graph=father.graph;
		angle=father.angle;
		flags=father.flags;
		x=father.x;
		y=father.y;
		z=father.z+1;
		alpha=128;
		sombra2();
		frame(2000);
		grav++;
	end
	from alpha=128 to 0 step -16; frame; end
End

Process sombra2();
Begin
	ctype=c_scroll;
	file=father.file;
	graph=father.graph;
	angle=father.angle;
	flags=father.flags;
	x=father.x;
	y=father.y;
	z=father.z+1;
	alpha=128;
	if(timer[8]<4) return; end
	timer[8]=0;
	frame(1000);
	from alpha=128 to 0 step -16; frame; end
End

Process tiempo_bala();
Begin
	if(timer[7]<10) return; end
	timer[7]=0;
	graph=get_screen();
	z=-1;
	x=160;
	y=120;
	from alpha=128 to 0 step -16; frame; end
	unload_map(0,graph);
End

Process enemigo(x,y,tipo);
Private
	grafs[3]; // 0 y 1 movimiento, 2 muerte, 3 ataque
	direccion;
	txt_puntos;
	enem_puntos;
	id_col;
Begin
	ctype=c_scroll;
	file=fpgs[3];
	If(tipo==1) grafs[0]=1; grafs[1]=1; grafs[2]=2; enem_puntos=100; End // el goomba de toa la vida
	If(tipo==2) grafs[0]=11; grafs[1]=11; grafs[2]=12; End // el goomba 2
	If(tipo==3) grafs[0]=21; grafs[1]=21; grafs[2]=22; End // el goomba 3
//
	If(tipo==4) grafs[0]=3; grafs[1]=4; grafs[2]=0; End // tortuga voladora
	If(tipo==5) grafs[0]=5; grafs[1]=6; grafs[2]=0; enem_puntos=100; y-=4; End // tortuga 
	If(tipo==6) grafs[0]=7; grafs[1]=8; grafs[2]=0; enem_puntos=200; End // tortuga ostiada
	If(tipo==7) grafs[0]=13; grafs[1]=14; grafs[2]=0; End // tortuga voladora2
	If(tipo==8) grafs[0]=15; grafs[1]=16; grafs[2]=0; End // tortuga 2
	If(tipo==9) grafs[0]=17; grafs[1]=18; grafs[2]=0; End // tortuga ostiada2
	If(tipo==10) grafs[0]=23; grafs[1]=24; grafs[2]=0; End // tortuga voladora
	If(tipo==11) grafs[0]=25; grafs[1]=26; grafs[2]=0; End // tortuga 
	If(tipo==12) grafs[0]=27; grafs[1]=29; grafs[2]=0; End // tortuga ostiada
//
	If(tipo==13) grafs[0]=10; grafs[1]=10; grafs[2]=9; grafs[3]=9; End // medusa, agua
//
	If(tipo==14) grafs[0]=19; grafs[1]=20; grafs[2]=0; End // carnivora 1
	If(tipo==15) grafs[0]=30; grafs[1]=31; grafs[2]=0; End // carnivora 2
//
	If(tipo==16) grafs[0]=32; grafs[1]=32; grafs[2]=33; grafs[3]=33; End // lakituu!!!
//
	If(tipo==17) grafs[0]=34; grafs[1]=35; grafs[2]=0; grafs[3]=36; End // bixo del martillo
	If(tipo==18) grafs[0]=43; grafs[1]=44; grafs[2]=0; grafs[3]=45; End // bixo del martillo2
//
	If(tipo==19) grafs[0]=38; grafs[1]=39; grafs[2]=0; End // tortuga caparazon1
	If(tipo==20) grafs[0]=40; grafs[1]=40; grafs[2]=0; End // tortuga caparazon1
	If(tipo==21) grafs[0]=47; grafs[1]=48; grafs[2]=0; End // tortuga caparazon2
	If(tipo==22) grafs[0]=49; grafs[1]=49; grafs[2]=0; End // tortuga caparazon2
	
	if(tipo==5 or tipo==8 or tipo==11)
		frame(1000);
	end
	if(tipo==6 or tipo==9 or tipo==12 or tipo==20 or tipo==22)
		graph=grafs[0];
		frame(1000);
		loop
			if(exists(id_jugador)) 
				if(collision(id_jugador))
					inercia=id_jugador.inercia;
					break;
				end
			end
			frame;
		end
		if(id_jugador.x<x) direccion=1; x+=6; else direccion=0; x-=6; end
	end
	ancho_queco=graphic_info(file,grafs[0],g_wide);
	alto_queco=graphic_info(file,grafs[0],g_height);
	Loop
		z=-2;
		while(ready==0 and item!=-1) frame; end
//		ancho_queco=graphic_info(file,graph,g_wide);
//		alto_queco=graphic_info(file,graph,g_height);
		toca_down=map_get_pixel(0,mapa_durezas,x,y+alto_queco/2);
		toca_left=map_get_pixel(0,mapa_durezas,x-ancho_queco/2,y);
		toca_right=map_get_pixel(0,mapa_durezas,x+ancho_queco/2,y);
		toca_up=map_get_pixel(0,mapa_durezas,x,y-alto_queco/2);
		if(toca_left==suelo or x<1) direccion=1; end
		if(toca_right==suelo) direccion=0; end
		include "./goomba.pix";
		include "./koopa.pix";
		If(anim<29) graph=grafs[0]; Else graph=grafs[1]; End
		anim++;
		If(anim>59) anim=0; End
		if(y>alto_pantalla) return; end
		if(exists(id_jugador)) while(id_jugador.x<x-320 or id_jugador.x>x+320) frame(2000); end end
		Frame;		
	End
//
// despues de muerto
	y+=6;
	graph=grafs[2];
	if(key(_control)) id_jugador.grav=-120; else id_jugador.grav=-80; end
	combo++;
	enem_puntos=enem_puntos*(combo*2);
	enem_da_puntos(enem_puntos);
	puntos+=enem_puntos;
	otro_sonido(16);
	If((tipo==5 OR tipo==8 OR tipo==11) and item==-1)
		enemigo(x,y,tipo+1);
		return;
	End
	frame(1000);
End

Process enem_da_puntos(enem_puntos);
Private
	y_out;
Begin
	z=1;
	x=father.x;
	y=father.y;
	ctype=c_scroll;
	y_out=y-20;
	graph=write_in_map(0,enem_puntos,4);
	while(y>y_out)
		y--;
		frame(300);
	end
End

Process pierde_anillos();
Begin
	invencibilidad=-40;
	if(id_jugador.flags==0) id_jugador.inercia=-100; id_jugador.grav=-100; id_jugador.y-=8; end
	if(id_jugador.flags==1) id_jugador.inercia=100; id_jugador.grav=-100; id_jugador.y-=8; end
	if(anillos>20) anillos=20; end
	while(anillos>0)
		anillo_perdido(father.x,father.y-10);
		anillos--;
	end
End

Process anillo_perdido(x,y);
Private
	grav_est;
Begin
	grav_est=rand(-20,-40);
	while(inercia==0) inercia=rand(-2,2); end
	graph=59;
	file=fpgs[2];
	ancho_queco=graphic_info(file,graph,g_wide);
	alto_queco=graphic_info(file,graph,g_height);
	ctype=c_scroll;
	grav=grav_est;
	loop
		item++;
		toca_down=map_get_pixel(0,mapa_durezas,x,y+alto_queco/2);
		toca_up=map_get_pixel(0,mapa_durezas,x,y-alto_queco/2);
		toca_left=map_get_pixel(0,mapa_durezas,x-ancho_queco/2,y);
		toca_right=map_get_pixel(0,mapa_durezas,x+ancho_queco/2,y);
		if(toca_down==suelo) grav=grav_est+10; end
		if(toca_up==suelo) grav=40; end
		if(toca_left==suelo or toca_right==suelo) inercia=inercia*-1; end
		if(grav!=0) y+=grav/6; end
		grav++;
		x+=inercia;
		if(anim>20)
			anim=0;
			if(graph>65) graph=59; else graph++; end
		else
			anim++;
		end
		while(ready==0) frame; end
		if(collision(type mario) or collision(type sonic) and invencibilidad>60) anillos++; break; end
		if(item>500) return; end
		frame;
	end
	sonido(3);
	from alpha=255 to 0 step -40; frame; end
End

Process anillo(x,y);
Begin
	file=fpgs[2];
	graph=59;
	ctype=c_scroll;
	loop
		if(anim>20)
			anim=0;
			if(graph>65) graph=59; else graph++; end
		else
			anim++;
		end
		if(exists(id_jugador)) while(id_jugador.x<x-320 or id_jugador.x>x+320 or id_jugador.y<y-320 or id_jugador.y>y+320) frame(2000); end end
		while(ready==0) frame; end
		if(collision(type mario) or collision(type sonic)) anillos++; break; end
		frame;
	end
	sonido(3);
	from alpha=255 to 0 step -40; frame; end
End

Process marcadores();
Begin
	write_int(0,0,0,0,&fps);
	if(personaje==0)
		write(0,30,10,0,"MARIO"); write_int(0,30,18,0,OFFSET puntos);
		write(0,132,18,0,"x");	
		write_int(0,140,18,0,OFFSET anillos); 
		write(0,170,10,0,"WORLD");
		write_int(0,170,18,0,OFFSET mundo);
		write(0,230,10,0,"TIME");
		write_int(0,230,18,0,OFFSET tiempo);
		anillo_marcador();
	end
	if(personaje==1) //falta encontrar fuente
		write(fnts[1],5,5,0,"SCORE");
		write_int(fnts[1],50,5,0,offset puntos);
		write(fnts[1],5,20,0,"TIME");
		write_int(fnts[1],50,20,0,offset tiempo);
		write(fnts[1],5,35,0,"RINGS");
		write_int(fnts[1],50,35,0,offset anillos);
		write(fnts[1],25,220,0,"SONIC");
	end
End

Process anillo_marcador();
Begin
	file=fpgs[2];
	graph=59;
	size=50;
	x=128;
	y=22;
	while(personaje==0)
		if(collision(type anillo_marcador)) return; end
		if(anim>20)
			anim=0;
			if(graph>65) graph=59; else graph++; end
		else
			anim++;
		end
		frame;
	end
End

include "pantallas.pix";
include "tblast.pix";
include "transicion.pix";
