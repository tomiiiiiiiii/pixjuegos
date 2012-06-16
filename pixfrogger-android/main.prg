#ifdef FAKE_SOUND
#define stop_wav(a);
#define key(a);
#define get_joy_button(a,b);
#define stop_song(a);
#define set_channel_volume(a,b);
#define set_song_volume(a);
#define unload_wav(a);
#define unload_song(a);
#define load_wav(a) 0
#define load_song(a) 0
#define play_wav(a, b);
#define play_song(a, b);
#define fade_music_off(a);
#define pause_song(a)
#define resume_song(a)
#define ALL_SOUND 0
#endif


import "mod_grproc.dll";
//import "mod_joy.dll";
//import "mod_key.dll";
import "mod_say.dll";
import "mod_map.dll";
import "mod_mouse.dll";
import "mod_proc.dll";
import "mod_rand.dll";
import "mod_screen.dll";
//import "mod_sound.dll";
import "mod_string.dll";
import "mod_text.dll";
import "mod_timers.dll";
import "mod_video.dll";
import "mod_multi.dll";

global
	arcade_mode=0;
	tbase=33; //altura de todo
	final=-2325;
	jue;
	pantc;
	boton[8];
	Struct ops; 
		pantalla_completa=1;
		sonido=1;
		musica=1;
		lenguaje=0;
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

//include "../../common-src/lenguaje.pr-";
//include "../../common-src/savepath.pr-";

begin
	alpha_steps=32;
	set_mode(533,320,32);
	set_fps(25,0);
	ler=load_fnt("puntos.fnt");
	i=load_png("3.png");
	put_screen(0,i);
	frame;
	timer[0]=0;
	load_fpg("pixfrogger.fpg");
	while(timer[0]<300) frame; end
	clear_screen();
	unload_map(0,i);
	
	//music=load_song("1.ogg");
	 
	elecpersonaje();
	say(6);
	loop
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
	put_screen(0,910);
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
			x=266; y=160;
			graph=get_screen();
			let_me_alone();
			juego();
			z=-100;
			from alpha=255 to 0 step -15; frame; end
			unload_map(0,graph);
			clear_screen();
			break;
		end
		from i=1 to 4;
			if(boton[i])
				if(ran[i]==0)
					sonido(4);
					rana_elec(138+(140*(i-1)),270,500+(i),1);
					ran[i]=1;
				end
			end
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
	from i=1 to 4;
		if(ranpuntos[i]!=0) write_int(ler,140+((i-1)*70),460,4,&ranpuntos[i]); end
	end
	from i=-1 to 16;
		piso(x,i*tbase);
	end
	from i=1 to 4;
		if(ran[i]) rana(i); else rana(i+10); end
	end
	frame(1000);
	controlador();
	loop
		if(ranviva[1]+ranviva[2]+ranviva[3]+ranviva[4]+ranviva[5]+ranviva[6]+ranviva[7]+ranviva[8]==1)
			graph=get_screen();
			x=266; y=160;
			z=-3;
			let_me_alone();
			from i=1 to 8;
				if(ranviva[i]==1) ganador=i; end
			end
			rana_elec(266,140,500+ganador,0);
			rana_elec(266,220,520,0);
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
			x=266;
			y=160;
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
	y=300;
	qy=tbase*10;
	priority=2;
	if(jugador<10)
		ranviva[jugador]=1; 
		x=170+((jugador-1)*40);
		gr=50+((jugador-1)*2);
	else
		ranviva[jugador-10]=1; 
		x=170+((jugador-11)*70);
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
		if(y>320)
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
		if(y<120)
			wy+=4;
		end
		if(y<50)
			wy+=6;
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
	x=rand(-50,850);
	if(collision(type obstc))
		return;
	end
	z=-10;
	bac();
	loop
		obstcc(x,y);
		if(tip==0 or tip==2)
			if(tip==0)
				x+=rand(5,10);
			else
				x+=3;
			end
			if(x>570)
				x=-50;//rand(-10,-1500);
			end
		else
			if(tip==1)
				x-=rand(5,10);
			else
				x-=3;
			end
			if(x<-50)
				x=570;
			end
		end
		y=wy+qy;
		if(y>350)
			break;
		end
		
		frame;
	end
end

process obstcc(x,y)
begin
	z=59;
	//graph=99;
	graph=father.graph;
	size_y=70;
	frame;
	//frame(200);
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
	x=266;
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
		if(y>350)
			qy=qy-550;
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

Process controlador()
Begin
	loop
		boton[1]=mouse.left;
		//boton[1]=multi_numpointers();
		frame;
	end
End

Process carga_sonidos();
Begin
	from i=1 to 50;
		wavs[i]=load_wav(i+".wav");
	end
End

Process sonido(num);
Begin
	if(ops.sonido)
		play_wav(wavs[num],0);
	end
End

process movi(gr)
private
	con;
begin
	x=266;
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