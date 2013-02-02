Program pixpang;

import "mod_image";

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
import "mod_multi";
import "mod_proc";
import "mod_rand";
import "mod_regex";
import "mod_screen";
import "mod_sound";
import "mod_string";
import "mod_say";
import "mod_sys";
import "mod_text";
import "mod_time";
import "mod_timers";
import "mod_video";
import "mod_wm";

Global
	arcade_mode=0;

	cancionsonando;

	max_grav=-250;
	turbo;
	salto;
	fondotemporal;
	
	string fichero_lng[30];
	Struct ops;
		lenguaje; 	// 0 = castellano, 1 = inglés
		op_music=1;
		op_sombras=1;
		op_sonido=1;
		ventana=0;
		dificultad=1; //la normal
	End
	Struct pantalla;
		bx[200];
		by[200];
		btipo[200];
		br[200];
		btime;
	End
	
	ancho_pantalla=800;
	alto_pantalla=600;
	
	njoys;
	posibles_jugadores;
	debuj;
	struct p[5];
		botones[7];
		vidas=10;
		arma;
		bolas;
		bonus;
		puntos;
		proteccion;
		estrella;
		disparos[2];
		muere;
		control;
		id;
		fpg;
		personaje;
	end
	joysticks[10];
	
	players;
	ganando;
	animglobal;
	ready;
	prisa;
	//escenario;
	fnt1;
	fnt2;
	fnt3;
	fnt4;
	reloj;
	relojarena;
	dinamita;
	time_puesto=120;
	bolas;
	matabolas;
	velocidad=200;
	graph_fondo;
	num_disp;
	bola_estrella=0;
        String prompt="_";
        String entry;
	inputText;
	iniciando;
	cont;
	zbolas;
	parpadea;
	modo_juego;
	segundos;
	mundo;
	id_titulo;
	id_lang;
	cocos;
	borrar;
	id_bolas[400];
	mundo_alcanzado;
	partida_rapida;
	vidajefefuera;
	secs;
	screenshot;
	mapadurezas;
// sonidos
	s[16];
// cosas raras
	contaor;
	cheto_diox;
	cheto_epilepsia;
	cheto_borracho;
	cheto_ayudante;
	cheto_salto;
	cheto_viejuno;
	cheto_choca;
	cheto_avaricioso;
	jefe=0;
	pixel_mola;
	raton;
	transicion;
	fpg_lang;
	fpg_jefe;
	fpg_menu;
	fpg_menu2;
	fpg_bloquesmask;
	img_pixpang;
	txt_fondos[1];
	filerecs;
	ahora_toca;
	color_texto[8];
	que_toca;
	tour_levels;
	
	margen_novato;
	// COMPATIBILIDAD CON XP/VISTA/LINUX (usuarios)
	string savegamedir;
	string developerpath="/.PiXJuegos/PiXPang/";
	
	cancion_cargada;

End

Local
	i;
	j;
	ancho;
	alto;
	jugador;
	accion;
End

include "../../common-src/lenguaje.pr-";
include "../../common-src/savepath.pr-";
include "../../common-src/controles.pr-";
	
Private
    lee_archivo;
    guarda_archivo;
    intejer;
    num;
    pit;
	
Begin  
	if(argc>0) if(argv[1]=="arcade") arcade_mode=1; end end

	gamepad_boton_separacion=50;
	gamepad_boton_size=80;
	
	borrar=new_map(1,1,8);
	Alpha_steps=64;
	
	set_title("PiX Pang");
	
	savepath();
	if(os_id==1003)
		savegamedir="/data/data/com.pixjuegos.pixpang/files";
	end
	carga_opciones();
	full_screen=!ops.ventana;
	
	switch(lenguaje_sistema())
		case "es": ops.lenguaje=0; end
		default: ops.lenguaje=1; end
	end
	
	if(ops.ventana==0 or arcade_mode==1) Full_screen=true; else full_screen=false; end
	
	if(os_id==9) //caanoo
		ops.op_sombras=0;
		scale_resolution=03200240; set_mode(800,600,16); 
	elseif(os_id==1003) //android
		ops.op_sombras=0;
		scale_resolution_aspectratio = SRA_PRESERVE;
		scale_resolution=graphic_info(0,0,g_width)*10000+graphic_info(0,0,g_height);
		say("---------- THIS IS MAY SCALE!!!!:"+SCALE_RESOLUTION);
		set_mode(800,600,16);
	else
		set_mode(800,600,32,WAITVSYNC);
	end
	
	load_fpg("fpg/pixpang.fpg");
	fpg_menu=load_fpg("fpg/menu.fpg");
	fpg_bloquesmask=load_fpg("fpg/bloquesmask.fpg");
	
	if((atoi(ftime("%d",time()))>23 and atoi(ftime("%m",time()))==12) or (atoi(ftime("%d",time()))<8 and atoi(ftime("%m",time()))==1)) 
		p[1].fpg=load_fpg("fpg/pixxmas.fpg"); 
		p[2].fpg=load_fpg("fpg/puxxmas.fpg");
	else 
		p[1].fpg=load_fpg("fpg/pix.fpg"); 
		p[2].fpg=load_fpg("fpg/pux.fpg"); 
	end
	set_center(p[1].fpg,601,10,0);
	set_center(p[1].fpg,602,10,0);
	set_center(p[1].fpg,603,10,0);
	set_center(p[1].fpg,604,12,0);
	set_center(p[1].fpg,605,12,0);

	set_center(p[2].fpg,601,10,0);
	set_center(p[2].fpg,602,10,0);
	set_center(p[2].fpg,603,10,0);
	set_center(p[2].fpg,604,12,0);
	set_center(p[2].fpg,605,12,0);


	img_pixpang=950;
	fnt1=load_fnt("fnt/textos.fnt");
	fnt2=load_fnt("fnt/conta.fnt");
	fnt3=load_fnt("fnt/textos2.fnt");

// joysticks
	configurar_controles();
//

// caca
	//fondotemporal=load_png("fondos/temporal.png");
//
	carga_sonidos();
	set_fps(60,9);
	
	logo_pixjuegos();
End

include "muneco.pr-";
include "disparos.pr-";
include "bola.pr-";

Process marcadores();
Begin
	If(modo_juego==2) 
		grafico(350,539,403,-1,0,fpg_lang); 
		write(fnt1,400,560,1,"Level    "+itoa(mundo+1));
	End
	vidas();
	If(players==1)
	    If(modo_juego==2) armap1(); grafico(234,560,402,-1,0,0); End
	    If(modo_juego==2) grafico(666,560,404,-1,1,fpg_lang); End 
		write_int(fnt1,190,540,5,&p[1].puntos); 
	end
	If(players==2)
	    If(modo_juego==2) armap2(); grafico(566,560,402,-1,0,0); End
	    grafico(134,560,404,-1,1,fpg_lang); 
		write_int(fnt1,615,540,3,&p[2].puntos);
	End
	If(players==3)
	    If(modo_juego==2) armap1(); armap2(); grafico(234,560,402,-1,0,0); grafico(566,560,402,-1,0,0); End
		write_int(fnt1,190,540,5,&p[1].puntos); 
		write_int(fnt1,615,540,3,&p[2].puntos);
	End
	escenario();
End

Process grafico(x,y,graph,z,intparpadeo,file);
Private
	exgraph;
Begin
	exgraph=graph;
	Loop
		if(ops.op_sombras==0)
			If(intparpadeo==1) If(graph==exgraph) graph=borrar; Else graph=exgraph; End End
		else
			if(intparpadeo==1) 
				graph=exgraph;
				from alpha=255 to 0 step -3; frame; end
				from alpha=0 to 255 step 3; frame; end
			end
		end
	Frame(2000);
	End
End

Process escenario();
Begin
	x=400;
	y=300;
	grafico(400,559,7,1,0,0);
	If(modo_juego==1 OR modo_juego==-1) 
		grafico(400,300,2,2,0,0);
		write(fnt2,300,540,3,"Level ");
		write_int(fnt2,460,540,3,&mundo);
	    If(modo_juego==1) 
			barra_nivel(); 
		End
	End
	If(modo_juego==2) 
		grafico(400,300,1,2,0,0);
	End
	Loop
		Frame;
	End
End

Process barra_nivel();
Private
   energia=0;
Begin
   graph=444;
   set_center(file,graph,0,15);
   // Se asignan las coordenadas
   x=305; y=580; z=0;
   grafico(400,580,443,-1,0,0);
   Loop
	  size_x=(((p[1].bolas+p[2].bolas))-((mundo)*5))*20;
	  if(size_x>100) size_x=100; end
      Frame;
   End
End

Process musica(cancion); //
Private
	string formato="ogg";
Begin
	if(os_id!=os_win32 and os_id!=os_linux) formato="mp3"; end

	/*If(cancion==-1)
		if(is_playing_song()) 
			fade_music_off(250);
			while(is_playing_song()) frame; end
		end
		if(cancion_cargada>0) unload_song(cancion_cargada); end
		cancion_cargada=0;
		return;
	end*/
	If(cancion_cargada>0) 
		If(is_playing_song()) stop_song(); End
		unload_song(cancion_cargada); 
		cancion_cargada=0;
	End
	if(cancion==-1) return; end
	
	if(modo_juego==2 and cancion==0) 
		cancion=mundo+1;
		while(cancion>6) cancion-=6; end
	end
	
	cancion_cargada=load_song("ogg/"+cancion+"."+formato);
	
	If(ops.op_music==1)
		If(cancion!=20 AND cancion!=18)
			play_song(cancion_cargada,-1);
		Else
			play_song(cancion_cargada,0);
		End
	End
	
	//pSounds.musica = cancion;
End

Process vidas();
Begin
    caravida(1);
	if(players==1 or players==3)
		caravida(1);
		write(fnt2,106,548,0,"x"); 
		write_int(fnt2,136,548,0,&p[1].vidas); 
	end
	if(players==2 or players==3)
		caravida(2);
		write(fnt2,694,548,2,"x");
		write_int(fnt2,664,548,2,&p[2].vidas); 
	end
		
	Loop
		from i=1 to 2;
			If(p[i].vidas>99) p[i].vidas=99; End
			z=-1;
		end
		Frame;
	End
End

Process caravida(jugador);
Begin
	file=p[jugador].fpg;
	graph=921;
	z=-3;
	y=550;	
	if(jugador==1)
		x=-50;
	else
		x=850;
		flags=1;
	end

	Loop
		if(jugador==1)
			if(p[1].muere==0)
				if(x<50) x+=2; end
			else
				if(x>-50) x-=2; end
			end
		else
			if(p[2].muere==0)
				if(x>750) x-=2; end
			else
				if(x<850) x+=2; end
			end
		end
		Frame;
	End
End

Process vidajefe();
Private
	escrito;
	id_textuales[1];
Begin
    vidajefe2();
     id_textuales[0]=write(fnt2,694,48,2,"x");
     id_textuales[1]=write_int(fnt2,664,48,2,OFFSET contaor);
    While(!vidajefefuera)
	Frame;
    End
    delete_text(id_textuales[0]);
    delete_text(id_textuales[1]);
End

Process vidajefe2();
Begin
	file=fpg_jefe;
	graph=100;
	z=-3;
	y=50;
	x=850;
	vidajefefuera=0;
	While(!vidajefefuera)
		If(x>750) x-=2; Frame; End
		Frame;
	End
	While(x<850) x+=2; Frame; End
	Frame;
End


Process anim_global();
Begin
	Loop
		If(animglobal<60) animglobal++;
			Else animglobal=0;
		End
		Frame;
	End
End

Function carga_sonidos();
Private
	flipando;
Begin
	from flipando=0 to 18;
		//if(file_exists(load_wav("wav/"+flipando+".wav")))
			s[flipando]=load_wav("wav/"+flipando+".wav");
	//	end
	end
End

Process suena(sonido);
Private
	l;
	id_sonido;
Begin
    If(ops.op_sonido==1)
	l=(father.x*255)/800;
	id_sonido=play_wav(s[sonido],0); 
	set_panning(id_sonido,255-l,l);
    End
End

Process tiempo_nivel(segs);
Private
	txt_tiempo;
Begin
	If(segs==-1) Return; End
	segs=segs*60;
	txt_tiempo=write_int(fnt2,460,539,4,OFFSET segundos);
	Loop
		If(ready==1 AND reloj==0) segs--; End
		segundos=segs/60;
		If(segundos<21 AND prisa==0) prisa=1; hayprisa(); End
		If(segs<1) break; End
		Frame;
	End
	p[1].muere=1;
	p[2].muere=1;
	ready=0;
	delete_text(txt_tiempo);
	write(fnt2,460,539,4,"0");
End

Process hayprisa();
Begin
	if(jefe==0) musica(24); end
	if(modo_juego==1 and jefe==0 and bola_estrella==0) bola(rand(60,740),0,17,rand(0,1)); end
	If(modo_juego==2) grafico(348,538,103,-2,0,fpg_lang); End
End

Process armap1(); //1=normal, 2=2 tiros, 3=gancho, 4=metralleta
Begin
	x=234;
	y=560;
	z=-2;
	Loop
		If(p[1].arma==1) 
			graph=borrar;
		End
		If(p[1].arma==2)
			graph=411;
		End
		If(p[1].arma==3)
			graph=412;
		End
		If(p[1].arma==4)
			graph=413;
		End
		Frame;
	End
End

Process armap2(); //1=normal, 2=2 tiros, 3=gancho, 4=metralleta
Begin
	x=566;
	y=560;
	z=-2;
	Loop
		If(p[2].arma==1) 
			graph=borrar;
		End
		If(p[2].arma==2)
			graph=411;
		End
		If(p[2].arma==3)
			graph=412;
		End
		If(p[2].arma==4)
			graph=413;
		End
		Frame;
	End
End

Process itemreloj(eltiempo);
Private
	segundox;
	rolex;
Begin
	if(p[1].estrella or p[2].estrella) return; end
	secs=eltiempo;
	suena(9);
	secs=secs*60;
	rolex=write_int(fnt2,400,200,4,&segundox);
	While(secs=>1)
		reloj=1;
		if(p[1].estrella or p[2].estrella) secs=1; parpadea=0; end
		
		If(ready==1) 
			secs--;
		else
			while(ready==0) frame; end
		End
		segundox=secs/60;
		If(segundox<2) parpadea=1; End
		Frame;
	End
	delete_text(rolex); 
	reloj=0; parpadea=0;
End


Process proteccion(num_muneco);
Private
	rolling;
	algo;
Begin
	if(p[num_muneco].id<1) return; end
	if(num_muneco==1) graph=514; else graph=515; end
	while(p[num_muneco].proteccion)
		if(exists(p[num_muneco].id))
			x=p[num_muneco].id.x;
			y=p[num_muneco].id.y+10;
			z=p[num_muneco].id.z-1;
		end
		alpha=100+rolling;
		size_x=100+(rolling/6);
		size_y=100-(rolling/4);
		if(algo==false)
			if(rolling<100) rolling++; else algo=true; end
		else
			if(rolling>0) rolling--; else algo=false; end
		end
		frame;
	end
	from alpha=255 to 0 step -5; frame; end
End

Process estrella();
Private
	rolling;
	algo;
	tiempo_estrella;
	segundox;
	rolex;
	tenia_protec[1];
Begin
	if(p[1].estrella) return; end
	p[1].estrella=1;
	p[2].estrella=1;
	suena(9);
	 
	tiempo_estrella=5*60;
	turbo=1;
	salto=1;
	tenia_protec[0]=p[1].proteccion;
	tenia_protec[1]=p[2].proteccion;
	p[1].proteccion=0;
	p[2].proteccion=0;
	switch(players)
		case 1:
			sub_estrella(1);
		end
		case 2: 
			sub_estrella(2);
		end
		case 3:
			if(exists(p[1].id)) sub_estrella(1); end
			if(exists(p[2].id)) sub_estrella(2); end
		end
	end
	rolex=write_int(fnt2,400,200,4,&segundox);
	while(tiempo_estrella>2 and ganando==0)
		if(ready==1) 
			tiempo_estrella--;
			else
			while(ready==0) frame; end		 
		end
		segundox=tiempo_estrella/60;
		frame;
	end
	delete_text(rolex);
	suena(12);
	if(tenia_protec[0]) suena(11); p[1].proteccion=1; proteccion(1); end
	if(tenia_protec[1]) suena(11); p[2].proteccion=1; proteccion(2); end
	p[1].estrella=0;
	p[2].estrella=0;
	turbo=0;
	salto=0;
End

Process sub_estrella(num_muneco);
Private
	rolling;
	algo;
Begin
	graph=519;
	if(p[num_muneco].id<1) return; end
	while(p[num_muneco].estrella==1)
		if(exists(p[num_muneco].id))
			x=p[num_muneco].id.x;
			y=p[num_muneco].id.y;
			z=p[num_muneco].id.z-1;
		end
		alpha=100+rolling;
		size_x=100+(rolling/6);
		size_y=100-(rolling/4);
		angle+=5000;
		frame;
		if(algo==false)
			if(rolling<100) rolling++; else algo=true; end
		else
			if(rolling>0) rolling--; else algo=false; end
		end
	end
	from alpha=255 to 0 step -5; frame; end
End

Process ganar();
Begin
	if(ready==0) Return; End
	ganando=1;
	ready=0;
	If(modo_juego==2)
		If(players==1 OR players==3) cuadro_ganar(1); End
		If(players==2 OR players==3) cuadro_ganar(2); End
		mundo++;
	End
	musica(20);
	stage_clear();
	timer[5]=0;
	if(modo_juego==2) frame(15000); faderaro(-2); end
	While(modo_juego!=2 and timer[5]<500) Frame; End
	If(modo_juego==1 OR modo_juego==3)
		faderaro(img_pixpang);
		let_me_alone();
	End
	If(modo_juego==2) 
		If(mundo==tour_levels+1) menu(); else inicio(); End 
	end
	if(modo_juego==1) menu(); end
End

Process cuadro_ganar(num);
Begin
	graph=406;
	y=345;
	 
	If(num==1) 
		if(p[1].muere) p[1].bonus=0; return; end
		x=210; 
		If(p[1].bolas>p[2].bolas and p[1].muere==0) 
			grafico(310,323,408,-2,0,fpg_lang); 
			grafico(120,363,410,-2,0,fpg_lang); 
			write_int(fnt1,250,363,4,OFFSET p[1].bonus); 
		Else
			grafico(310,323,407,-2,0,fpg_lang);
			p[1].bonus=0;
			grafico(200,363,409,-2,0,fpg_lang);
		End
		write_int(fnt1,140,323,4,OFFSET p[1].bolas); 
	End
	If(num==2) 
		if(p[2].muere) p[2].bonus=0; return; end
		x=590; 
		If(p[2].bolas>p[1].bolas and p[2].muere==0) 
			grafico(680,363,410,-2,0,fpg_lang); 
			write_int(fnt1,550,363,4,OFFSET p[2].bonus); 
			grafico(490,323,408,-2,0,fpg_lang);
		Else
			p[2].bonus=0;
			grafico(600,363,409,-2,0,fpg_lang); 
			grafico(490,323,407,-2,0,fpg_lang);
		End
		write_int(fnt1,660,323,4,OFFSET p[2].bolas); 
	End
	While(ganando==1) Frame; End
End

Process stage_clear();
Begin
	y=162;
	x=400;
	file=fpg_lang;
	graph=414;
	if(ops.op_sombras)
		from alpha=0 to 255 step 5; frame; end
	end
	While(ganando==1)
		Frame;
	End
End

Process sombra(graph,x,y,flags,num);
Begin
	flags+=4;
	file=father.file;
	size=father.size;
	size_x=father.size_x;
	size_y=father.size_y;
	angle=father.angle;
	Frame;
	sombra2(graph,x,y,flags);
End

Process sombra2(graph,x,y,flags);
Begin
	flags+=4;
	file=father.file;
	size=father.size;
	size_x=father.size_x;
	size_y=father.size_y;
	angle=father.angle;
	Frame(100);
End

Process relojarena();
Private
	cont_arena;
	velocidad_antes;
Begin
	if(relojarena==1) return; else relojarena=1; end
	velocidad_antes=velocidad;
	suena(13);
	From velocidad=velocidad_antes To velocidad_antes*2 Step 5; Frame; End
	While(cont_arena<200)
		cont_arena++;
		Frame;
	End
	suena(14);
	From velocidad=velocidad_antes*2 To velocidad_antes Step -5; Frame; End
	relojarena=0;
End

Process fondos_panic();
Private
	png_fondo;
	cambiado;  
	id_fondo;
Begin
	x=400;
	y=260;
	z=512;
	Loop
		If(p[1].bolas+p[2].bolas=>0 AND cont==0) texto_fondos("1.Ashura"); png_fondo=load_image(".\fondos\3.jpg"); cont=1; End
		If(p[1].bolas+p[2].bolas=>50 AND cont==1) If(p[1].bolas+p[2].bolas<100) texto_fondos("2.Alejandro"); png_fondo=load_image(".\fondos\1.jpg"); End  cambiado=0; cont=2; End // alejo
		If(p[1].bolas+p[2].bolas=>100 AND cont==2) If(p[1].bolas+p[2].bolas<150) texto_fondos("3.HH Sigmar MC"); png_fondo=load_image(".\fondos\2.jpg"); End cambiado=0; cont=3; End // carlos
		If(p[1].bolas+p[2].bolas=>150 AND cont==3) If(p[1].bolas+p[2].bolas<200) texto_fondos("4.Donan"); png_fondo=load_image(".\fondos\10.jpg"); End cambiado=0; cont=4; End // carlos
		If(p[1].bolas+p[2].bolas=>200 AND cont==4) If(p[1].bolas+p[2].bolas<250) texto_fondos("5.Donan 2"); png_fondo=load_image(".\fondos\4.jpg"); End cambiado=0; cont=5; End // donan
		If(p[1].bolas+p[2].bolas=>250 AND cont==5) If(p[1].bolas+p[2].bolas<300) texto_fondos("6.Donan 3"); png_fondo=load_image(".\fondos\5.jpg"); End cambiado=0; cont=6; End // donan
		If(p[1].bolas+p[2].bolas=>300 AND cont==6) If(p[1].bolas+p[2].bolas<350) texto_fondos("7.SiNk!"); png_fondo=load_image(".\fondos\6.jpg"); End cambiado=0; cont=7; End // carlos166
		If(p[1].bolas+p[2].bolas=>350 AND cont==7) If(p[1].bolas+p[2].bolas<400) texto_fondos("8.Wakroo"); png_fondo=load_image(".\fondos\7.jpg"); End cambiado=0; cont=8; End // carlos166
		If(p[1].bolas+p[2].bolas=>400 AND cont==8) If(p[1].bolas+p[2].bolas<450) texto_fondos("9.Wakroo 2"); png_fondo=load_image(".\fondos\8.jpg"); End cambiado=0; cont=9; End // santi
		If(p[1].bolas+p[2].bolas=>450 AND cont==9) If(p[1].bolas+p[2].bolas<500) texto_fondos("10.Wakroo 3"); png_fondo=load_image(".\fondos\9.jpg"); End cambiado=0; cont=10; End // dani el negro
		If(p[1].bolas+p[2].bolas=>500 AND cont==10) If(p[1].bolas+p[2].bolas<550) texto_fondos("11.Aryadna y Emilio"); png_fondo=load_image(".\fondos\30.jpg"); End cambiado=0; cont=11; End // donan 3
		If(p[1].bolas+p[2].bolas=>550 AND cont==11) If(p[1].bolas+p[2].bolas<600) texto_fondos("12.???????"); png_fondo=load_image(".\fondos\11.jpg"); End cambiado=0; cont=12; End // ???
		if(jefe!=0)
			If(exists(id_fondo)) signal(id_fondo,s_kill); End
			return;
		end
		If(cambiado==0) 
			If(exists(id_fondo)) signal(id_fondo,s_kill); End
			If(ops.op_sombras==1) alpha=0; End
			graph=png_fondo;
			If(ops.op_sombras==1) dump_type=1; restore_type=1; End
			While(alpha<255	AND ops.op_sombras==1)
				alpha+=15;
				Frame;
			End
			dump_type=0;
			restore_type=0;
			id_fondo=pon_fondo(png_fondo);
			cambiado=1; 
			graph=borrar;
		End
		Frame;
	End
End

/*process fondos_panic();
begin
	pon_fondo(fondotemporal);
	loop
		cont=((p[1].bolas+p[2].bolas)/50)+1;
		frame;
	end
end

process fondos_tour();
begin
	pon_fondo(fondotemporal);
end*/

Process fondos_tour();
Private
	png_fond;
Begin
	If(mundo==0) png_fond=load_image(".\fondos\31.jpg"); End
	If(mundo==1) png_fond=load_image(".\fondos\29.jpg"); End
	If(mundo==2) png_fond=load_image(".\fondos\28.jpg"); End  
	If(mundo==3) png_fond=load_image(".\fondos\27.jpg"); End  
	If(mundo==4) png_fond=load_image(".\fondos\26.jpg"); End  
	If(mundo==5) png_fond=load_image(".\fondos\25.jpg"); End  
	If(mundo==6) png_fond=load_image(".\fondos\24.jpg"); End  
	If(mundo==7) png_fond=load_image(".\fondos\23.jpg"); End  
	If(mundo==8) png_fond=load_image(".\fondos\22.jpg"); End
	If(mundo==9) png_fond=load_image(".\fondos\21.jpg"); End  
	If(mundo==10) png_fond=load_image(".\fondos\20.jpg"); End
	If(mundo==11) png_fond=load_image(".\fondos\19.jpg"); End  
	If(mundo==12) png_fond=load_image(".\fondos\18.jpg"); End  
	If(mundo==13) png_fond=load_image(".\fondos\17.jpg"); End  
	If(mundo==14) png_fond=load_image(".\fondos\16.jpg"); End  
	If(mundo==15) png_fond=load_image(".\fondos\15.jpg"); End
	If(mundo==16) png_fond=load_image(".\fondos\14.jpg"); End  
	If(mundo==17) png_fond=load_image(".\fondos\13.jpg"); End 
	If(mundo==18) png_fond=load_image(".\fondos\12.jpg"); End  
	If(mundo==19) png_fond=load_image(".\fondos\11.jpg"); End  
	If(mundo>19) png_fond=load_image(".\fondos\"+itoa(mundo+12)+".jpg"); End
	//If(mundo=>100 AND mod_custom==1) png_fond=load_image(".\custom\fondos\"+itoa(mundo-99)+".jpg"); End
	If(png_fond<1) png_fond=load_image(".\fondos\"+rand(1,42)+".jpg"); End
	pon_fondo(png_fond);
	Frame;
End

Process pon_fondo(el_png);
Begin                                 
    y=260;
    z=512;
    x=400;
    graph=el_png;
    Frame;
    Loop
        Frame(4000)	;
    End
End

Process inicio();
Begin
	p[1].puntos+=p[1].bonus;
	p[1].bonus=0;
	p[2].puntos+=p[2].bonus;
	p[2].bonus=0;
	//frame;
	let_me_alone();
	//faderaro(0);
	if(modo_juego==2) faderaro(-1); end
	iniciando=1;
	ready=0;
	p[1].muere=0;
	p[2].muere=0;
	p[1].arma=1;
	p[2].arma=1;
	ganando=0;
	dinamita=0;
	bola_estrella=0;
	If(modo_juego==2) prisa=0; End
	relojarena=0;
	p[1].proteccion=0;
	p[2].proteccion=0;
	raton=0;
	matabolas=0;
	if(posibles_jugadores==1)
		players=1;
	end
	if(modo_juego==2)
		guardar_partida();
	end
	delete_text(all_text); // borra textos
	clear_screen();
	cont=0; // contador fondos
	timer[9]=0;
	While(timer[9]<150) Frame; End
	p[1].disparos[1]=0; p[1].disparos[2]=0; // reinicia p[1].disparos
	p[2].disparos[1]=0; p[2].disparos[2]=0; // reinicia p[2].disparos
	bolas=0; // indica q no hay bolas en pantalla
	If(modo_juego==2) musica(-1); end
	
	If(p[1].vidas=>0 AND p[2].vidas<0 AND players==3) players=1; End
	If(p[2].vidas=>0 AND p[1].vidas<0 AND players==3) players=2; End
	switch(players)
		case 1:	p[1].id=muneco(1); end
		case 2:	p[2].id=muneco(2); end
		case 3:	p[1].id=muneco(1); p[2].id=muneco(2); end
	end
	if(jefe!=0 and ops.dificultad<2)
		p[1].proteccion=1;
		p[2].proteccion=1;
		p[1].arma=2;
		p[2].arma=2;
	End
	If(modo_juego==1 and jefe==0) fondos_panic(); End
	If(modo_juego==2) pon_pantalla(mundo); End
	anim_global();
	marcadores();
	timer[9]=0;
	jugar();
	While(timer[9]<70) Frame; End
	if(modo_juego==2) tiempo_nivel(pantalla.btime); end
	if(jefe==0) readyando(); else
		switch(jefe)
			case 1: fantasma(); musica(24); end
			case 2: fantasma(); musica(24);  end
			case 3: fmars(); end
			case 4: jefe_gusano(); musica(24); end
			case 5: ultraball(); fondos_tour(); musica(24); end
			case 6: maskara(); musica(24); end
		end
	end
	p[1].muere=0;
	p[2].muere=0;
	p[1].disparos[1]=0; p[1].disparos[2]=0; // reinicia p[1].disparos
	p[2].disparos[1]=0; p[2].disparos[2]=0; // reinicia p[2].disparos
	ganando=0; 
	iniciando=0;
	reloj=0;
	transicion=0;
End

Process gameover();
Private
	id_input;
	otro_texto;
	tupapa;
Begin
	faderaro(img_pixpang);
	clear_screen();
	musica(-1);
	delete_text(all_text);
	let_me_alone();
	timer[9]=0;
	p[1].vidas=10;
	p[2].vidas=10;
	p[1].puntos=0;
	p[2].puntos=0;
	guardar_partida();
	While(timer[9]<100) Frame; End
	transicion=0;
	p[1].muere=0;
	p[2].muere=0;
	timer[9]=0;
	put_screen(fpg_menu2,4);
	musica(18);
	timer[9]=0;
	While(timer[9]<500 AND !p[0].botones[4]) Frame; end
	modo_juego=0;
	menu();
End

Process grafico_alpha(x,y,graph,flags);
Begin
	If(ops.op_sombras==1) alpha=0; End
	While(!key(_enter))
		If(alpha<250 AND ops.op_sombras==1) alpha+=5; End
		Frame;
	End
	While(alpha>10 AND ops.op_sombras==1)
		alpha-=5;
		Frame;
	End
End

Process readyando();
Begin
	ready=0;
	x=400;
	y=250;
	z=-256;
	timer[9]=0;
	if(ops.op_sombras==0) 
		While(timer[9]<300)
		    file=fpg_lang;
		    graph=415;
			ready=0;
		    if(animglobal<30 AND timer[9]>100) graph=borrar; End
		    Frame;
		End
		If(modo_juego==2 and jefe==0)
			musica(0);
		end
		ready=1;
	else
		// way to 2.0!!
		file=fpg_lang;
		graph=415;
		ready=0;
		from alpha=0 to 255 step 7; frame; end
		from alpha=255 to 0 step -7; frame; end
		from alpha=0 to 255 step 7; frame; end
		from alpha=255 to 0 step -7; frame; end
		from alpha=0 to 255 step 10; frame; end
		Frame(2000);
		If(modo_juego==2 and jefe==0)
			musica(0);
		end
		ready=1;
		from alpha=255 to 0 step -10; size++; frame; end
	End
End

Process items(x,y,item);
Private
	tuerestonto;
	aleatorio;
	toca;
	id_col;
Begin
	if(jefe!=0) return; end
	z=1;	
	If(item==0) graph=425; End // reloj arena
	If(item==1) graph=419; End // reloj
	If(item==2) aleatorio=rand(420,423); graph=aleatorio; End // piña
	If(item==3) graph=411; End // pistola doble
	If(item==4) graph=412; End // gancho
	If(item==5) graph=413; End // metralleta
	If(item==6) graph=424; size=150; End // protector
	If(item==7) graph=400; If(rand(0,2)!=1) Return; End End // vida
	If(item==8) graph=426; End // dinamita
	If(item==9) graph=519; End // estrella
	If(item==10) bola(x,y,19,rand(0,1)); bolas--; return; End // bola!!
	While(tuerestonto<(5*60))
	        If(item==7) 
			switch(players)
				case 3:
					If(animglobal<30) 
						file=p[1].fpg; 
						graph=400; 
					Else 
						file=p[2].fpg; 
						graph=400; 
					End 
				end
				case 2:
						file=p[2].fpg; 
						graph=400; 
				end
				case 1:
						file=p[1].fpg; 
						graph=400; 
				end			
			end
		End
		If(ready==1) tuerestonto+=3; End
		If(aleatorio==1 AND item==6) size+=3; If(size=>150) aleatorio=0; End End
		If(aleatorio==0 AND item==6) size-=3; If(size=<50) aleatorio=1; End End
		If(aleatorio==1 AND item==9) size++; angle+=15000; If(size=>70) aleatorio=0; End End
		If(aleatorio==0 AND item==9) size--; angle+=15000; If(size=<40) aleatorio=1; End End
		If(y<485 AND ready==1 and cheto_borracho==0)
			If(toca=collision(Type bloques))
				If(toca.y<y)
					y+=6; tuerestonto=0;
				End
			Else
					y+=6; tuerestonto=0;
			End
		End
		If(y>20 AND ready==1 and cheto_borracho==1)
			y-=6; tuerestonto=0;
		End
		if(item==2) //fruta recibe disparo
			id_col=collision(type disparos);
			if(!id_col)
				id_col=collision(type cachodisparo);
			end
			If(id_col)
				p[id_col.jugador].puntos+=2400; break;
			End
		end
		If(id_col=collision(type muneco))
			if(p[id_col.jugador].muere==0)
				If(item==0) relojarena(); End // reloj arena
				If(item==1 and jefe==0) If(reloj==0) itemreloj(rand(3,7)); else secs+=4*60; End End // reloj
				If(item==2) p[id_col.jugador].puntos+=2400; suena(10); End // piña
				If(item==3) p[id_col.jugador].arma=2; suena(3); End // pistola doble
				If(item==4) p[id_col.jugador].arma=3; suena(3); End // gancho
				If(item==5) p[id_col.jugador].arma=4; suena(3); End // metralleta
				If(item==6 and p[id_col.jugador].proteccion==0) p[id_col.jugador].proteccion=1; 
					if(p[id_col.jugador].estrella==0) proteccion(id_col.jugador); end 
					suena(11); 
				End // protector         
				If(item==9) estrella(); End // estrella!!
				If(item==7) p[id_col.jugador].vidas++; suena(6); End // vida
				If(item==8 AND dinamita==0) dinamita=1; suena(15); graph=borrar; Frame(4000); dinamita=0; End // dinamita
				accion=-1;
				Break;
			End
		End
		If(tuerestonto>(3*60)) If(flags==0) flags=4; Else flags=0; End End
		if(accion==-1) break; end
		Frame(200);
	End
End

Process pa_largar();
Begin
	Loop
		If(key(_alt) AND key(_x)) exit(0,0); End
		Frame;
	End
End

Process col_hielo(x,y);
Begin
	graph=438;
	alpha=0;
	loop
		frame;
	end
End

include "bloques.pr-";

Process coloca_raton();
Private
	tipo=1;
	cont_bloque;
	regalo;
	bloque_o_bola=1;
	lado_bola;
	ids_graficos[200];
Begin
	time_puesto=90;
	z=-3;
	raton=1;
	frame;
	write_int(fnt1,0,0,0,OFFSET cont_bloque);
	write_int(fnt1,450,539,4,OFFSET time_puesto);
	write_int(fnt1,800,0,2,OFFSET regalo);
	Loop
		If(x<400) lado_bola=0; Else lado_bola=1; End
		x=mouse.x;
		y=mouse.y;
		If(key(_down) AND time_puesto>40) time_puesto-=10; While(key(_down)) Frame; End End
		If(key(_up) AND time_puesto<250) time_puesto+=10; While(key(_up)) Frame; End End
		if(key(_left) and regalo>0) While(key(_left)) Frame; End regalo--; end
		if(key(_right) and regalo<11) While(key(_right)) Frame; End regalo++; end
		//regalo=rand(0,13);
		If(tipo<110 or tipo>113) size=100; End
		If(tipo==1)graph=427; End
		If(tipo==2) graph=428; End
		If(tipo==3) graph=429; End
		If(tipo==4) graph=430; End
		If(tipo==5) graph=431; End
		If(tipo==6) graph=432; End
		If(tipo==7) graph=433; End
		If(tipo==8) graph=434; End
		If(tipo==9) graph=435; End
		If(tipo==10) graph=436; End
		If(tipo==11) graph=437; End
		If(tipo==12) graph=438; End
		If(tipo==101) graph=701; End
		If(tipo==102) graph=702; End
		If(tipo==103) graph=703; End
		If(tipo==104) graph=704; End
		If(tipo==105) graph=705; End
		If(tipo==106) graph=711; End
		If(tipo==107) graph=713; End
		If(tipo==108) graph=715; End
		If(tipo==109) graph=716; End
		If(tipo==110) graph=801; size=33; End
		If(tipo==111) graph=801; size=66; End
		If(tipo==112) graph=801; size=100; End
		If(tipo==113) graph=717; End
		If(tipo==114) graph=718; End
		If(tipo==115) graph=719; End
		If(tipo==116) graph=720; End
		If(tipo==117) graph=721; End 
		If(tipo==118) tipo=119; End
		If(tipo==119) graph=723; End 
		if(tipo==120) graph=724; end 
 		if(tipo==121) graph=725; end 
		if(tipo==122) graph=726; end

		If(key(_space)) 
			While(key(_space)) Frame; End 
			If(bloque_o_bola==1) 
				tipo=101; bloque_o_bola=0; 
			Else 
				bloque_o_bola=1; tipo=1; 
			End 
		End
		If(key(_z) AND cont_bloque=>0) signal(ids_graficos[cont_bloque],s_kill); cont_bloque--; While(key(_z)) Frame; End End
		If(mouse.right==1) If((tipo<12 AND bloque_o_bola==1) OR (tipo<122 AND bloque_o_bola==0)) tipo++; Else If(bloque_o_bola==1) tipo=1; Else tipo=101; End End While(mouse.right==1) Frame; End End
		If(mouse.left==1) 
			If(tipo<100) 
				ids_graficos[cont_bloque]=bloques(x,y,regalo,tipo); 
			Else 
				ids_graficos[cont_bloque]=bola(x,y,tipo-100,lado_bola); 
			End
			pantalla.bx[cont_bloque]=x;
			pantalla.by[cont_bloque]=y;
			pantalla.btipo[cont_bloque]=tipo;
			pantalla.br[cont_bloque]=regalo;
			cont_bloque++;
			While(mouse.left==1) Frame; End 
		End
		pantalla.btime=time_puesto;
		If(cont_bloque==200) Break; End
		Frame;
	End
	raton=0;
End

Process pon_pantalla(num);
Private
	cont_bloque;
	tipo;
	regalo;
	lado_bola;
	el_input;
Begin
	if(mundo==4) jefe=2; end
	if(mundo==9) jefe=3; end
	if(mundo==14) jefe=4; end
	if(mundo==19) jefe=5; end
	if(mundo==79) jefe=6; end
	If((num=>0 and num<100) and jefe==0) load(".\tour\"+num+".pang",pantalla); end
	If(jefe!=0) 
		load(".\tour\mostro.pang",pantalla); 
	end
	if(jefe==0) fondos_tour(); end

	//if(mapadurezas) unload_map(0,mapadurezas); else mapadurezas=new_map(800,600,16); end
	
	While(cont_bloque<200)
		x=pantalla.bx[cont_bloque];
		y=pantalla.by[cont_bloque];
		regalo=pantalla.br[cont_bloque];
		tipo=pantalla.btipo[cont_bloque];
		If(x<400) lado_bola=0; Else lado_bola=1; End
		If(tipo<100) bloques(x,y,regalo,tipo); Else bola(x,y,tipo-100,lado_bola); End
		cont_bloque++;
	End
	frame;
	//save_png(0,mapadurezas,"c:\nivel.png");
	time_puesto=pantalla.btime;
	p[1].muere=0; 
	p[2].muere=0;
End

Process cocodrilo(lado); // a quien no le guste que no explote que se joda xD
Private
	id_bola;
	cont_giros;
	grav;
	id_col;
Begin
	cocos++;
	If(lado==0) x=0; flags=1; Else x=800; flags=0; End
	y=466;
	z=1;
	Loop
		While(ready==0 OR reloj==1) Frame; End
		If(ganando==1) Break; End
		If(animglobal<15) graph=312; End
		If(animglobal=>15 AND animglobal<30) graph=311; End
		If(animglobal=>30 AND animglobal<45) graph=310; End
		If(animglobal=>45) graph=311; End
		If(lado==0) x+=2; Else x-=2; End
		If(x=>770 AND lado==0 AND cont_giros<3) cont_giros++; lado=1; If(cheto_borracho==1) flags=1; Else flags=0; End End
		If(x=<30 AND lado==1 AND cont_giros<3) cont_giros++; lado=0; If(cheto_borracho==1) flags=0; Else flags=1; End End
		If(x>850 OR x<-50) Return; End

		if(id_col=collision(type disparos)) 
			if(id_col!=0)
				if(id_col.j<y-20) 
					id_col=0; 
				else 
					id_col.accion=-1; 
				end
			end
			break; 
		end
		Frame;
	End
	grav=rand(100,200);
	While(y<480)
		If(ops.op_sombras==1) sombra(graph,x,y,flags,1); End
		If(flags==0) x+=12; angle+=60000; End
		If(flags==1) x-=12; angle+=60000; End
		If(x=>755) flags=1; End
		If(x=<45) flags=0; End
		grav-=5;
		y-=grav/10;
		Frame;
	End
	cocos--;
End

Process volador();
Private
	inercia;
	y_destino;
	y_destino_final;
	lado;
	id_col;
Begin
	graph=300;
	x=rand(100,500);
	z=1;
	cocos++;
	y_destino_final=rand(100,400);
	Loop
		flags=lado;
		While(ready==0 OR reloj==1) Frame; End
		While(y<y_destino AND y<y_destino_final AND !collision(Type bola))
			inercia+=3;
			y+=inercia/2; 
			If(lado==1) x+=inercia*2; Else x-=inercia*2; End
			If(animglobal<15)
				graph=300; 
			End
			If(animglobal>14 AND animglobal<30) 
				graph=301;
			End
			If(animglobal>29 AND animglobal<45) 
				graph=300; 
			End
			If(animglobal>44 AND animglobal<60) 
				graph=301; 
			End
			Frame(400);
		End
		inercia=0;
		if(lado==1) x++; else x--; end
		If(collision(Type bola))
			If(lado==1) 
				While(x<850) x+=5; 
					If(animglobal<15) 
						graph=300; 
					End
					If(animglobal>14 AND animglobal<30) 
						graph=301;
					End
					If(animglobal>29 AND animglobal<45) 
						graph=300; 
					End
					If(animglobal>44 AND animglobal<60) 
						graph=301; 
					End
					Frame; 
				End 

			Else 
				While(x>-50) x+=5; 
					If(animglobal<15) 
						graph=300; 
					End
					If(animglobal>14 AND animglobal<30) 
						graph=301;
					End
					If(animglobal>29 AND animglobal<45) 
						graph=300; 
					End
					If(animglobal>44 AND animglobal<60) 
						graph=301; 
					End
					Frame;
				End
			End
			cocos--; 
			Return;
		End
		y_destino=y+30;
		If(animglobal<30) 
			graph=300;
		Else
			graph=301;
		End
		If(lado==1 AND (animglobal==60 OR y<y_destino_final)) lado=0; 
			ElseIf(lado==0 AND (animglobal==60 OR y<y_destino_final)) lado=1; 
		End
		if(id_col=collision(type disparos)) id_col.accion=-1; break; end

		Frame;
	End
	cocos--;
	While(size>0)
		size-=5;
		alpha-=10;
		angle+=25000;
		Frame;
	End
End

Process faderaro(graphh);
Private
	nosubida;
	grav;
Begin
	if(ops.op_sombras==0) return; end
	x=400;
	y=300;
	z=-512;
	if(graphh>0) graph=graphh; else
		If(graphh==0) graph=920; End
		if(graphh==-2) screenshot=get_screen(); nosubida=1; end
		if(graphh!=-1 and graph!=2) transicion=1; else graph=screenshot; nosubida=1; end
	end

	If(ops.op_sombras==1) alpha=0; End
	While(alpha<255 and transicion==1 and nosubida==0)
		alpha+=15;
		Frame;
	End
	alpha=255;
	While(transicion==1) Frame; End
	if(rand(0,1)==0)
		While(alpha>15 AND ops.op_sombras==1)
			alpha-=15;
			Frame;
		End
	else
		set_center(0,graph,800,0); x=800; y=0; loop grav++; angle+=grav*1000; if(angle>90000) break; end frame;	end
	end
	
	if(graph==screenshot and graph!=0)
		graph=0;
		unload_map(0,screenshot);
	end
End

Process escaleras(x,y);
Begin
	graph=429;
	z=3;
	Loop
		Frame;
	End
End

Process parpadeo();
Begin
	x=400; y=300;
	z=-511;
	graph=923;
	Frame(500);
End

Process nube();
Private
	tocante;
	velosidad;
	cosaxunga;
	rolling;
	algo;
	size_inicio;
Begin
	If(rand(0,1)==1) x=800; flags=1; Else x=0; flags=0; End
	if(cheto_borracho==0) y=rand(50,200); velosidad=rand(3,8); else y=rand(300,500); velosidad=rand(8,20); end
	graph=660;
	size_inicio=rand(70,100);
	If(ops.op_sombras==1) alpha=128; End
	While(flags==1 AND x>0)
		size_x=size_inicio+(rolling/6);
		size_y=size_inicio-(rolling/5);
		if(algo==false)
			if(rolling<100) rolling+=2; else algo=true; end
		else
			if(rolling>0) rolling-=2; else algo=false; end
		end
		x-=velosidad;
		If(tocante=collision(Type bola)) tocante.x-=velosidad; tocante.y--; End
		Frame(velocidad/2);
	End
	While(flags==0 AND x<800)
		size_x=size_inicio+(rolling/6);
		size_y=size_inicio-(rolling/5);
		if(algo==false)
			if(rolling<100) rolling+=2; else algo=true; end
		else
			if(rolling>0) rolling-=2; else algo=false; end
		end
		x+=velosidad;
		If(tocante=collision(Type bola)) tocante.x+=velosidad; tocante.y--; End
		Frame(velocidad/2);
	End
End

process logo_pixjuegos();
begin
	if(ops.lenguaje==0)
		fpg_menu2=load_fpg("fpg/menu-es.fpg");
		fpg_lang=load_fpg("fpg/eng.fpg");
	else
		fpg_menu2=load_fpg("fpg/menu-en.fpg");
		fpg_lang=load_fpg("fpg/eng.fpg");
	end
	delete_text(0);
	graph=951;
	x=400;
	y=300;
	z=-10;
	controlador(0);
	from alpha=50 to 255 step 5; 
		if(p[0].botones[7]) while(p[0].botones[7]) frame; end break; end
		frame; 
	end
	timer[0]=0;
	while(timer[0]<300) if(scan_code!=0) break; end frame; end
	while(scan_code!=0) frame; end
	menu();
	from alpha=alpha to 0 step -10;
		frame; 
	end
end

Function guardar_partida();
Begin
	save(savegamedir+"partida.dat",mundo);
End

process cargar_partida();
Begin
	let_me_alone();
	load(savegamedir+"partida.dat",mundo);
	modo_juego=2;
	if(posibles_jugadores==1)
		players=1; inicio();
	else
		menu_jugadores_continuar();
	end
End

include "menu.pr-";

// MONSTRUOS
include "monstruos/ultraball.pr-";
include "monstruos/fantasma.pr-";
include "monstruos/fmars.pr-";
include "monstruos/gusano.pr-";
include "monstruos/maskara.pr-";

process shell(string crap);
begin
end

Process explotalo(x,y,z,alpha,angle,file,graffico,frames);
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
	if(!ready) return; end
	ancho=graphic_info(file,graffico,g_width);
	alto=graphic_info(file,graffico,g_height);
	from b=0 to alto-1 step 5;
		from a=0 to ancho-1 step 5;
			if(map_get_pixel(file,graffico,a,b)!=0)
				particula[c].pixel=map_get_pixel(file,graffico,a,b);
				
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

Process texto_fondos(String creador);
Private
	timr;
Begin
	// desactivado por ahora
	return;
	// ...
	x=1100;
	y=40;                 
	If(txt_fondos[0]!=0) delete_text(txt_fondos[0]); End
	While(x>25)
		If(x>100) x-=5; End
		x-=5;
		Set_text_color(color_texto[0]);
		txt_fondos[0]=write(fnt1,x,y,0,creador);
		Frame;
		delete_text(txt_fondos[0]);
	End
	timr=0;
	While(timr<300)
		timr++;
		Set_text_color(color_texto[0]);
		txt_fondos[0]=write(fnt1,x,y,0,creador);
		Frame;
		delete_text(txt_fondos[0]);
	End
	While(x>-300)
		x-=5;
		Set_text_color(color_texto[0]);
		txt_fondos[0]=write(fnt1,x,y,0,creador);
		Frame;
		delete_text(txt_fondos[0]);
	End
	delete_text(txt_fondos[0]);
End

include "demo.pr-";

Function todos_muertos();
Begin
End

Function revive_muertos();
Begin

End

Process jugar();
Private
	txt_pausa;
	txt_fps;
	kindabolas;
	avaricioso;
Begin
	dump_type=0;
	restore_type=0;
	if(modo_juego==1) //panic mode
		p[1].arma=2;
		p[2].arma=2;
	else //tour mode
		p[1].bolas=0;
		p[2].bolas=0;
	end
	cocos=0;
	controlador(0);
	margen_novato=(5-ops.dificultad)*2;
	Loop
		If(pixel_mola==1 and ready==1)
			If(key(_m) AND raton==0) coloca_raton(); End
			If(key(_x)) matabolas=1; Else matabolas=0; End
			If(key(_r) AND reloj==0) reloj=1; itemreloj(5); End
			if(key(_e) and p[1].estrella==0) while(key(_e)) frame; end estrella(); end
			If(key(_c)) cocodrilo(rand(0,1)); End
			If(key(_v)) volador(); End
			If(key(_n)) nube(); End
			If(key(_f) AND txt_fps==0) txt_fps=write_int(fnt1,0,0,0,&fps); End

		End
		from i=1 to 2;
			if(!exists(p[i].id))
				p[i].muere=2; 
			end
		end
		if(modo_juego==1) //panic mode
			mundo=(p[1].bolas+p[2].bolas)/5;
			if(mundo>99) mundo=99; end
			If(mundo>30 AND rand(0,200)==0) nube(); End
			If(bolas=>13 AND prisa==0) prisa=1; hayprisa(); End
			If(bolas<8 AND prisa==1) prisa=0; timer[8]=0; musica(5); End
			If(mundo==99 AND bolas==0 AND ready==1) ganar(); Return; End
			If((bolas==0 OR timer[7]>1000 OR (bolas<5 and rand(0,1000)==0)) and jefe==0 AND (ganando==0 AND ready==1 AND p[1].bolas+p[2].bolas<500 and bola_estrella==0 and matabolas==0)) 
				timer[7]=0; 
				If(prisa==1) prisa=0; timer[8]=0; musica(5); End 
				if(mundo>20) kindabolas=rand(0,2); else kindabolas=rand(0,4); end 
				If(kindabolas==0) bola(rand(60,740),150,5,rand(0,1)); end 
				If(kindabolas==1) bola(rand(60,740),150,12,rand(0,1)); End 
				If(kindabolas==2) bola(rand(60,740),150,9,rand(0,1)); End 
				If(kindabolas==3) bola(rand(60,740),150,16,rand(0,1)); end 
				If(kindabolas==4) bola(-100,150,19,rand(0,1)); bola(900,150,rand(19,22),rand(0,1)); end
			End
			If(players==3)
				If(p[1].muere==2 AND p[2].muere==0) p[1].muere=0; If(p[1].vidas<0) inicio(); Else p[1].id=muneco(1); End End
				If(p[2].muere==2 AND p[1].muere==0) p[2].muere=0; If(p[2].vidas<0) inicio(); Else p[2].id=muneco(2); End End
				If(p[1].muere==2 AND p[2].muere==2 AND (p[1].vidas=>0 OR p[2].vidas=>0)) inicio(); End
				If(p[1].muere==2 AND p[1].vidas<0 AND p[2].muere==2 AND p[2].vidas<0) gameover(); End
			End
			If(players==2)
				If(p[2].muere==2 AND p[2].vidas=>0 AND iniciando==0) inicio(); End
				If(p[2].muere==2 AND p[2].vidas<0) gameover(); End
			End
			If(players==1)
				If(p[1].muere==2 AND p[1].vidas=>0 AND iniciando==0) inicio(); End
				If(p[1].muere==2 AND p[1].vidas<0) gameover(); End
			End           
			If(relojarena==0 and jefe==0) 
				switch(ops.dificultad)
					case 0:
						velocidad=450-(p[1].bolas/3+p[2].bolas/3); 
					end
					case 1:
						velocidad=400-(p[1].bolas/3+p[2].bolas/3); 
					end
					case 2:
						velocidad=350-(p[1].bolas/3+p[2].bolas/3); 
					end
					case 3:
						velocidad=300-(p[1].bolas/3+p[2].bolas/3); 
					end
				end
			End
		else //tour mode
			if(cheto_avaricioso) if(avaricioso<20) avaricioso++; else cocodrilo(rand(0,1)); avaricioso=0; end end
			If(players==1 AND p[2].botones[4]) players=3; suena(6); p[2].vidas=10; faderaro(-2); frame; inicio(); End
			If(players==2 AND p[1].botones[4]) players=3; suena(6); p[1].vidas=10; faderaro(-2); frame; inicio(); End
			If(bolas==0 AND ready==1 and jefe==0) ganar(); Break; End
			If(cocos<3 and rand(0,2000)==0 and jefe==0) If(rand(0,1)==0) cocodrilo(rand(0,1)); Else volador(); End End
			If(players==3)
				If(p[1].muere==2 AND p[2].muere==2 AND (p[1].vidas=>0 OR p[2].vidas=>0) AND iniciando==0) musica(-1); faderaro(-2); frame; inicio(); End
				If(p[1].muere==2 AND p[1].vidas<0 AND p[2].muere==2 AND p[2].vidas<0) gameover(); End
			End
			If(players==2)
				If(p[2].muere==2 AND p[2].vidas=>0 AND iniciando==0) musica(-1); faderaro(-2); frame; inicio(); End
				If(p[2].muere==2 AND p[2].vidas<0) gameover(); End
			End
			If(players==1)
				If(p[1].muere==2 AND p[1].vidas=>0 AND iniciando==0) musica(-1); faderaro(-2); frame; inicio(); End
				If(p[1].muere==2 AND p[1].vidas<0) gameover(); End
			End
			If(relojarena==0) 
				if(p[1].estrella)
					velocidad=100;
				else
					switch(ops.dificultad)			
						case 0:
							velocidad=400;
						end
						case 1:
							velocidad=300;
						end
						case 2:
							velocidad=250;
						end
						case 3:
							velocidad=200;
						end
					end
				end
			End

		end
		if(key(_p) and ready==1)
			txt_pausa=write(fnt1,400,300,4,"PAUSA");
			suena(8);
			ready=0;
			frame(3000);
			while(key(_p)) frame; end
			while(!key(_p)) frame; end
			while(key(_p)) frame; end
			delete_text(txt_pausa);
			ready=1;
			suena(2);
		end
		If(key(_d) AND key(_b) AND key(_g)) pixel_mola=1; End
		If(p[0].botones[7]) while(p[0].botones[7]) frame; end menu(); end
		If(key(_alt) AND key(_x)) exit(0,0); End
		If(zbolas<-200) zbolas=-1; End
		Frame;
	End
End