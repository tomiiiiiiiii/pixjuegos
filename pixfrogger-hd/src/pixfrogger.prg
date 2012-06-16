program pixfrogger;
global
	arcade_mode=0;
	tbase=75; //altura de todo
	final=-2325;
	jue;
	pantc;
	boton[8];
	Struct ops; 
		pantalla_completa=1;
		sonido=1;
		musica=1;
		lenguaje;
	End
	elecc;
	elecy;
	wy;
	ran[8];
	ranviva[8];
	ranpuntos[8];
	llegada;
	ler;
	music;
	njoys;
	buzz;
	string joyname;
	buzz_joy[2];
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
				if(buzz_joy[1]==0)
					buzz_joy[1]=i;
				else
					buzz_joy[2]=i;
				end
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
	set_mode(1280,720,32,WAITVSYNC);
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
	x=640;
	y=360;
	z=-10;
	from alpha=50 to 255 step 5; 
		if(get_joy_button(0,8) or key(_esc) or key(_enter)) break; end
		frame; 
	end
	timer[0]=0;
	while(timer[0]<300) if(scan_code!=0) break; end frame; end
	while(scan_code!=0) frame; end
	if(ops.musica)
		play_song(music,99);
	end
	//while(key(_enter))frame; end
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
	from i=1 to 8; ranviva[i]=0; ranpuntos[i]=0; end
	elecc=0;
	put_screen(0,3);
	
	if(arcade_mode)
		write(0,320,240,4,"Pulsa disparo para jugar");
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
	x=640;
	y=360;
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
	x=-400;
	y=500;
	z=-10;
	graph=gr;
	if(ops.lenguaje==1)
		if(graph==4) graph=911; end
		if(graph==13) graph=913; end
	end
	alpha=0;
	loop
		if(gr!=13) x+=(x-350)/-10; else x+=(x-350)/-10; end
		if(alpha<255) alpha+=15; end
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
		y+=(y-150)/-10;
		frame;
	end
end

process movi(gr)
private
	con;
begin
	x=640;
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
		//x=(cos(osc)*5)+40;
		x=100;
		elecy=y;
		y=280+(elecc*110);
		frame;
	end
end

process back(graph)
private
	keytime;
begin
	x=640;
	y=360;
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
	from i=1 to 8;
		ran[i]=0;
	end
	x=640;
	y=360;
	if(ops.lenguaje==1) 
		if(buzz) graph=915; else graph=910; end
	else 
		if(buzz) graph=909; else graph=908; end
	end
	z=100;
	controlador();
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
		from i=1 to 8;
			if(boton[i])
				if(ran[i]==0)
					sonido(4);
					rana_elec(138+(140*(i-1)),540,500+(i),1);
					ran[i]=1;
				end
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
	if(tipo) size=130; end
	while(exists(father))
		if(alpha<240) alpha+=5; end
		if(tipo and size>70) size-=8; end
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
	from i=1 to 8;
		if(ranpuntos[i]!=0) write_int(ler,400+((i-1)*70),700,4,&ranpuntos[i]); end
	end
	indicador();
	from i=-1 to 14; 
		piso(x,i*tbase);
	end
	from i=1 to 8;
		if(ran[i]) rana(i); else rana(i+10); end
	end
	frame(1000);
	controlador();
	loop
		if(ranviva[1]+ranviva[2]+ranviva[3]+ranviva[4]+ranviva[5]+ranviva[6]+ranviva[7]+ranviva[8]==1)
			graph=get_screen();
			x=640;
			y=360;
			z=-3;
			let_me_alone();
			from i=1 to 8;
				if(ranviva[i]==1) ganador=i; end
			end
			rana_elec(640,300,500+ganador,0);
			rana_elec(640,480,520,0);
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
		if(ranviva[1]+ranviva[2]+ranviva[3]+ranviva[4]+ranviva[5]+ranviva[6]+ranviva[7]+ranviva[8]==0)
			graph=get_screen();
			x=640;
			y=360;
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
			x=640; y=360; z=-100;
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
	if(!exists(father))
		//break;
		return;
	else
		x=father.x+(father.x/30)-10;
		y=father.y+5;

		if(father.graph==50 or father.graph==52 or father.graph==54 or father.graph==56 or
		father.graph==58 or father.graph==60 or father.graph==62 or father.graph==64)
			graph=900;
		end

		if(father.graph==51 or father.graph==53 or father.graph==55 or father.graph==57 or
		father.graph==59 or father.graph==61 or father.graph==63 or father.graph==65)
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
END

process rana(jugador);
private
	qy;
	up;
	gr;
	id_obst;
	gr_antes;
begin
	y=750;

	qy=tbase*10;
	priority=2;
	if(jugador<10)
		ranviva[jugador]=1; 
		x=400+((jugador-1)*70);
		gr=50+((jugador-1)*2);
	else
		ranviva[jugador-10]=1; 
		x=400+((jugador-11)*70);
		gr=50+((jugador-11)*2);
	end
	graph=gr;
	loop
		if(up>0)
			up--;
		end
		if(y<0)
			qy+=tbase;
		end
		if(y>700)
			qy-=tbase;
		end
		if(qy==final) llegada=jugador; end
		if(jugador>10)
			graph=gr;
				if(rand(0,100)>90 or collision (type obstc))
				graph=gr+1;
				
				qy-=tbase;
				if(collision(type obstcc))
					qy+=tbase;
					graph=gr;
				end
				frame(200);
			end
		end
		
		//POSIBLES FORMAS DE PERDER: NOS ATROPELLAN O GANA OTRO
		gr_antes=graph; //guardamos el gráfico actual
		graph=71; //y ponemos este para colisionar!
		if(collision(type obstcc) or (llegada!=jugador and llegada!=0))
			graph=gr_antes;
			golp(x,y,graph);
			sonido(4);
			break;
		end
		graph=gr_antes;

		if(boton[jugador] and up==0)
			graph=gr+1;
			qy-=tbase;
			up=4;
		else
			if(up<3) graph=gr; end
		end
		if(y<300)
			wy+=5;
		end
		if(y<100)
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
	y=-tbase;
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
			if(x>1400)
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
				x=1400;
			end
			if(collision(type obstc) and x>1280)
				x=rand(1400,1700);
			end
		end
		y=wy+qy;
		if(y>800)
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
	x=640;
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
		if(y>800)
			qy=qy-1200;
			gr=rand(200,201);
			if(qy>-100)
				gr=200;
			end
			if(qy==final) gr=206; end
			if(qy<final) gr=204; end
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
		x=(wy/7)+430;
		frame;
	end
end

process bandera()
begin
	graph=210;
	x=640;
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

Process controlador()
Begin
	loop
		if(buzz)
			from i=1 to 4;
				boton[i]=get_joy_button(buzz_joy[1],(i-1)*5);
				if(buzz_joy[2]!=0)
					boton[i+4]=get_joy_button(buzz_joy[2],(i-1)*5);
				else
					boton[5]=key(_q);
					boton[6]=key(_z);
					boton[7]=key(_p);
					boton[8]=key(_up);
				end
			end
		elseif(arcade_mode)
			boton[1]=get_joy_button(0,1);
			boton[2]=get_joy_button(0,3);
			boton[3]=get_joy_button(1,1);
			boton[4]=get_joy_button(1,3);
		else
			boton[1]=key(_q);
			boton[2]=key(_z);
			boton[3]=key(_p);
			boton[4]=key(_up);
		end
		frame;
	end
End