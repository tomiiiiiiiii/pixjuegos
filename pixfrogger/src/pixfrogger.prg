program pixfrogger;

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
import "mod_screen";
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
	ran1;
	ran2;
	ran3;
	ran4;
	pantc;
	Struct ops; 
		pantalla_completa=1;
		sonido=1;
		musica=1;
		lenguaje;
	End
	elecc;
	elecy;
	wy;
	ranviva[4];
	ranpuntos[4];
	llegada;
	ler;
	music;
	njoys;
	buzz;
	string joyname;
	buzz_joy;
	//SONIDO.INC
	wavs[50];

	// COMPATIBILIDAD CON XP/VISTA/LINUX (usuarios)
	string savegamedir;
	string developerpath="/.PiXJuegos/PiXFrogger/";
Local
	i; // la variable maestra
End

include "../../common-src/lenguaje.pr-";
include "../../common-src/savepath.pr-";

begin
	if(argc>0) if(argv[1]=="arcade") arcade_mode=1; end end

	njoys=number_joy();
	if(njoys>0)
		from i=0 to njoys-1;
			joyname=lcase(JOY_NAME(i));
			if(find(joyname,"buzz")=>0)
				buzz=1;
				buzz_joy=i;
			end
		end
	end

	savepath();
	
	carga_opciones();
	
	switch(lenguaje_sistema())
		case "es": ops.lenguaje=0; end
		default: ops.lenguaje=1; end
	end	
	
	full_screen=ops.pantalla_completa;
	carga_sonidos();
	alpha_steps=255;	
	if(arcade_mode) full_screen=true; scale_resolution=08000600; end
	set_mode(640,480,32,WAITVSYNC);
	set_fps(30,0);
	ler=load_fnt("fnt/puntos.fnt");
	load_fpg("fpg/pixfrogger.fpg");
	music=load_song("ogg/1.ogg");
	set_title("PiX Frogger");
	sound_freq=44100;
	ops.sonido=1;
	 
	logo_pixjuegos(); 
	loop
		frame;
	end
end

process logo_pixjuegos();
begin
	delete_text(0);
	graph=1;
	x=320;
	y=240;
	z=-10;
	from alpha=50 to 255 step 5; 
		if(get_joy_button(0,8) or key(_esc)) break; end
		frame; 
	end
	timer[0]=0;
	while(timer[0]<300) if(scan_code!=0) break; end frame; end
	while(scan_code!=0) frame; end
	if(ops.musica)
		play_song(music,99);
	end
	menu();
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
	from i=1 to 4; ranviva[i]=0; ranpuntos[i]=0; end
	elecc=0;
	put_screen(0,3);
	
	if(arcade_mode)
		write(0,320,240,4,"Pulsa el boton 1 para jugar");
		while(get_joy_button(0,0)) frame; end
		while(!get_joy_button(0,0)) 
			if(get_joy_button(0,8) or key(_esc)) exit(); end
			frame; 
		end
		delete_text(all_text);
		
		put_screen(0,6);
		while(get_joy_button(0,0)) frame; end
		while(!get_joy_button(0,0)) 
			if(get_joy_button(0,8) or key(_esc)) exit(); end
			frame; 
		end
		while(get_joy_button(0,0)) frame; end
		
		put_screen(0,3);
		elecpersonaje();
		return;
	end
	
	lista(4);
	logo(2);
	machango();
	x=320;
	y=240;
	keytime=10;
	loop
		if(keytime>0)
			keytime--;
		end
		//elige algo
		if(key(_enter)and keytime==0)
			sonido(3);
			if(elecc==0)
				let_me_alone();
				wy=0;
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
	x=320;
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
		if(elecc==0)
			y=190;
		end
		if(elecc==1)
			y=245;
		end
		if(elecc==2)
			y=245+55;
		end
		if(elecc==3)
			y=245+55+55;
		end
		if(elecc==4)
			y=245+55+55+55;
		end
		frame;
	end
end

process back(graph)
private
	keytime;
begin
	x=320;
	y=240;
	keytime=10;
	if(graph==5 and ops.lenguaje==1) graph=912; end
	loop
		if((arcade_mode and get_joy_button(0,8)) or key(_esc))
			while(get_joy_button(0,8) or key(_esc)) frame; end
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
	wy=-100;
	tecenter=1;
	loop
		if(key(_esc))
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
						set_mode(640,480,32,WAITVSYNC);
					else
						ops.pantalla_completa=0;
						full_screen=0;
						set_mode(640,480,32,WAITVSYNC);
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
begin
	jue=0;
	ran1=0;
	ran2=0;
	ran3=0;
	ran4=0;
	x=320;
	y=240;
	if(ops.lenguaje==1) 
		if(buzz) graph=915; else graph=910; end
	else 
		if(buzz) graph=60; else graph=59; end
	end
	z=100;
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
		if((key(_q) and buzz==0) or (get_joy_button(buzz_joy,0) and buzz) or (get_joy_button(0,0) and arcade_mode))
			if(ran1==0)
				sonido(4);
				rana_elec(138,380,501,1);
				ran1=1;
			end
		end
		if((key(_z) and buzz==0) or (get_joy_button(buzz_joy,5) and buzz) or (get_joy_button(0,3) and arcade_mode))
			if(ran2==0)
				sonido(4);
				rana_elec(258,380,502,1);
				ran2=1;
			end
		end
		if((key(_p) and buzz==0) or (get_joy_button(buzz_joy,10) and buzz) or (get_joy_button(1,0) and arcade_mode))
			if(ran3==0)
				sonido(4);
				rana_elec(378,380,503,1);
				ran3=1;
			end
		end
		if((key(_up) and buzz==0) or (get_joy_button(buzz_joy,15) and buzz) or (get_joy_button(1,3) and arcade_mode))
			if(ran4==0)
				sonido(4);
				rana_elec(498,380,504,1);
				ran4=1;
			end
		end
		if((arcade_mode and get_joy_button(0,8)) or key(_esc))
			let_me_alone();
			while(key(_esc)) frame; end
			menu();
			break;
		end
		frame;
	end
end

process rana_elec(x,y,graph,tipo);
begin
	z=-15;
	alpha=60;
	while(exists(father))
		if(alpha<240) alpha+=5; end
		if(tipo and size>40) size-=8; end
		frame;
	end
end

process juego()
private
	ganador;
	dand;
begin
	llegada=0;
	wy=0;
	priority=1;
	delete_text(all_text);
	if(ranpuntos[1]!=0) write_int(ler,200,470,4,&ranpuntos[1]); end
	if(ranpuntos[2]!=0) write_int(ler,250,470,4,&ranpuntos[2]); end
	if(ranpuntos[3]!=0) write_int(ler,390,470,4,&ranpuntos[3]); end
	if(ranpuntos[4]!=0) write_int(ler,440,470,4,&ranpuntos[4]); end
	indicador();
	from i=-1 to 10; 
		piso(x,i*50);
	end
	if(ran1==1)	ran(1); else ran(11); end
	if(ran2==1)	ran(2);	else ran(12); end
	if(ran3==1)	ran(3);	else ran(13); end
	if(ran4==1)	ran(4);	else ran(14); end
	frame(1000);
	loop
		if(ranviva[1]+ranviva[2]+ranviva[3]+ranviva[4]==1)
			graph=get_screen();
			x=320;
			y=240;
			z=-3;
			let_me_alone();
			from i=1 to 4;
				if(ranviva[i]==1) ganador=i; end
			end
			rana_elec(320,200,500+ganador,0);
			rana_elec(320,380,505,0);
			ranpuntos[ganador]++;
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
		if(ranviva[1]+ranviva[2]+ranviva[3]+ranviva[4]==0)
			graph=get_screen();
			x=320;
			y=240;
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
		if((get_joy_button(0,8) and arcade_mode) or key(_esc))
			let_me_alone();
			while((get_joy_button(0,8) and arcade_mode) or key(_esc)) frame; end
			graph=get_screen();
			x=320; y=240; z=-100;
			menu();
			from alpha=255 to 0 step -15; frame; end
			unload_map(0,graph);
			break;
		end
		frame;
	end
end

// lo siento gnomwer xD
process bac();
begin
	z=father.z+5;
	flags=father.flags;
//	LOOP
		if(!exists(father))
			//break;
			return;
		else
			x=father.x+(father.x/30)-10;
			y=father.y+5;

			if(father.graph==50 or father.graph==52 or father.graph==54 or father.graph==56)
				graph=900;
			end
	
			if(father.graph==51 or father.graph==53 or father.graph==55 or father.graph==57)
				graph=901;
			end
		
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
//	END
END

process ran(jugador);
private
	qy;
	up;
	gr;
	id_obst;
	gr_antes;
begin
	y=400;
	x=100;

	qy=450;
	priority=2;
	if(jugador<10) ranviva[jugador]=1; else ranviva[jugador-10]=1; end
	if(jugador==1 or jugador==11)
		x=200;
		gr=50;
	end
	if(jugador==2 or jugador==12)
		x=250;
		gr=52;
	end
	if(jugador==3 or jugador==13)
		x=390;
		gr=54;
	end
	if(jugador==4 or jugador==14)
		x=440;
		gr=56;
	end

	graph=gr;
	loop
		if(up>0)
			up--;
		end
		if(y<0)
			qy+=50;
		end
		if(y>480)
			qy-=50;
		end
		if(qy==-2200) llegada=jugador; end
		if(jugador==11 or jugador==12 or jugador==13 or jugador==14)
			graph=gr;
				if(rand(0,100)>90 or collision (type obstc))
				graph=gr+1;
				
				qy-=50;
				if(collision(type obstcc))
					qy+=50;
					graph=gr;
					//angle+=10000;
				end
				frame(200);
			end
		end
		
		//POSIBLES FORMAS DE PERDER: NOS ATROPELLAN O GANA OTRO
		gr_antes=graph; //guardamos el gr?fico actual
		graph=61; //y ponemos este para colisionar!
		if(collision(type obstcc) or (llegada!=jugador and llegada!=0))
			graph=gr_antes;
			golp(x,y,graph);
			explotalo(x,y,z,alpha,angle,file,graph,60);
			sonido(4);
			break;
		end
		graph=gr_antes;


		if((
			(jugador==1 and ((key(_q) and buzz==0) or (get_joy_button(buzz_joy,0) and buzz) or (get_joy_button(0,0) and arcade_mode)))
			or 
			(jugador==2 and ((key(_z) and buzz==0) or (get_joy_button(buzz_joy,5) and buzz) or (get_joy_button(0,3) and arcade_mode)))
			or 
			(jugador==3 and ((key(_p) and buzz==0) or (get_joy_button(buzz_joy,10) and buzz) or (get_joy_button(1,0) and arcade_mode)))
			or 
			(jugador==4 and ((key(_up) and buzz==0) or (get_joy_button(buzz_joy,15) and buzz) or (get_joy_button(1,3) and arcade_mode)))
		   )
				and up==0)
			graph=gr+1;
			qy-=50;
			up=4;
		else
			if(up<3) graph=gr; end
		end
		if(y<300)
			wy+=5;
		end
		y=wy+qy;
		bac();
		frame;
	end
	if(jugador<10) ranviva[jugador]=0; else ranviva[jugador-10]=0; end
end

process obstc(qy,tip)
private
	gr;
begin
	if(tip==0 or tip==1)
		gr=rand(100,104);
	end
	if(tip==2 or tip==3)
		gr=rand(105,106);
	end
	flags=tip;
	graph=gr;
	y=-50;
	x=rand(0,900);
	if(collision(type obstc))
				x=rand(-10,-1500);
			end
	z=-10;
		bac();
	loop
		obstcc(x,y);
		if(tip==0 or tip==2)
			if(tip==0)
				x+=rand(10,15);
			else
				x+=5;
			end
			if(x>1000)
				x=-100;//rand(-10,-1500);
			end
			if(collision(type obstc) and x<0)
				x=rand(-10,-1500);
			end
		else
			if(tip==1)
				x-=rand(10,15);
			else
				x-=5;
			end
			if(x<-100)
				x=1000;//rand(900,1500);
			end
			if(collision(type obstc) and x>640)
				x=rand(900,1500);
			end
		end
		y=wy+qy;
		if(y>550)
			break;
		end
		
		frame;
	end
end

process obstcc(x,y)
begin
	z=59;
	graph=99;
	frame(200);
end

process golp(x,y,graph)
private
	iy;
begin
	iy=-10;
	loop
		angle+=30000;
		iy+=1;
		y+=iy;
		if(y>1000)
		break;
		end
		frame;
	end
end

process piso(x,qy)
private
	gr;
begin
	z=50;
	x=320;
	gr=200;
	if(rand(0,1)==1)
		gr=202;
	end
	if(rand(0,1)==1)
		gr=204;
	end
	graph=gr;
	loop
		y=qy+wy;
		if(y>550)
			qy=qy-600;
			gr=rand(200,201);
			if(qy>-100)
				gr=200;
			end
			if(qy==-2200) gr=206; end
			if(qy<-2200) gr=204; end
			if(gr==200)
				if(rand(0,1)==1)
					gr=202;
					if(rand(0,1)==1)
						gr=204;
					end
				end
			end
			if(gr==201)
				gr=rand(0,3);
				obstc(qy,gr);
				obstc(qy,gr);
				gr=201;
			end
			if(gr==201)
				if(pantc==200 or pantc==202 or pantc==205)
					gr=203;
				end
			end
			if(gr==200 or gr==204 or gr==202)
				if(pantc==201 or pantc==203)
					gr=205;
				end
			end
			graph=gr;
			pantc=gr;
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
		x=(wy/10)+190;
		frame;
	end
end

process bandera()
begin
	graph=210;
	x=320;
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
	let_me_alone();
	while(key(_enter)) frame; end
	logo_pixjuegos();
end

include "sonido.inc";

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
	ancho;
	alto;
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