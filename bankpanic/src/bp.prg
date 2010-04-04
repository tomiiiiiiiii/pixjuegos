/*graficos:
1.reloj
2.fondo
3.puertaconsuelo
4.banqueroconrejas
*/

Global
	puerta_actual=2;
	struct puertas[12]; //0 no existe
		distancia;
		tipo; //1: bueno, 2: malo, 3: niñobonus, 4:rehenluegomalo, 5:atado, 6:malodisfrazado, 7:primerobuenoyluegomaloaprovechapuertaabierta
		toques;
		pagado;
	end
	ready;
	nivel=1;
	tiempo_margen;
	x_central; //para cuando movemos las puertas
	fnt;
	moviendo;
	todo_pagado;
	puntos;
	vidas=5;
	id_txt[5];
	disparando;
	sonidos[5];
End

Begin
	rand_seed(time());
	full_screen=1;
	set_mode(640,480,32);
	load_fpg("bp.fpg");
	fnt=load_fnt("oeste.fnt");
	play_song(load_song("2.ogg"),0);
	sonidos[1]=load_wav("1.wav");
	sonidos[2]=load_wav("2.wav");
	
	put_screen(0,903);
	while(!key(_enter)) frame; end
	intro();
End

Process pon_nivel(inicio);
Private
	id_puerta;
	nopagado;
Begin
	let_me_alone();
	delete_text(all_text);
	play_song(load_song("1.ogg"),-1);
	ready=1;
	moviendo=0;
	todo_pagado=0;
	tiempo_margen=60-nivel*2;

	write_int(fnt,0,0,0,&puntos);
	write_int(fnt,0,20,0,&vidas);
	
	if(inicio==0) //si inicio=1:reiniciamos el nivel porque perdimos una vida. no tocamos estas variables
		puerta_actual=5;
		//algunos aparecerán pagados
		from x=1 to 12-nivel;
			if(rand(0,nivel)==0) puertas[x].pagado=1; end
		end
		
		//ponemos enemigos y distancias
		from x=1 to 12;
			if(rand(0,4)==0 and puertas[x].pagado==0)
				puertas[x].distancia=rand(2,5)*90;
				puertas[x].tipo=rand(1,4);
				if(nivel>2) puertas[x].toques=rand(10,25)/10; else puertas[x].toques=1; end
			end
		end
	end
	
	from x=1 to 12;
		marcador(x);
	end
	
	//puertas
	from x=puerta_actual-3 to puerta_actual+3;
		puerta(x);
	end

	//fondos puertas
	grafico(14,120,260,5);
	grafico(14,320,260,5);
	grafico(14,520,260,5);
	
	reloj();
	tiempo();
	
	//panel marcadores
	grafico(2,320,55,-10);
	set_fps(28+(nivel*2),0);
	
	//mirillas
	grafico(26,320,240,-10);
	grafico(26,120,240,-10);
	grafico(26,520,240,-10);

	loop
	  if(ready==1)
		if(key(_left)) 
			moviendo=1;
			from x_central=0 to 200 step 10; frame; end
			puerta_actual--;
		elseif(key(_right)) 
			moviendo=1;
			from x_central=0 to -200 step -10; frame; end
			puerta_actual++;
		end
		if(moviendo)
			while(id_puerta=get_id(type puerta))
				signal(id_puerta,s_kill);
			end
			if(puerta_actual>12) puerta_actual-=12; end
			if(puerta_actual<1) puerta_actual+=12; end
			//delete_text(all_text);
			from x=1 to 5;
				delete_text(id_txt[x]);
			end
			x_central=0;
			from x=puerta_actual-3 to puerta_actual+3;
				puerta(x);
			end
			moviendo=0;
		end
		nopagado=0;
		from x=1 to 12;
			if(puertas[x].tipo==0 and (rand(0,100)==0 or puertas[x].pagado==0))
				puertas[x].distancia=rand(2,5)*90;
				puertas[x].tipo=rand(1,4);
				if(nivel>2) puertas[x].toques=rand(10,25)/10; else puertas[x].toques=1; end
			end
		end

		from x=1 to 12; if(!puertas[x].pagado) nopagado=1; end end
		if(nopagado==0) break; end
	  end
	  if(!exists(type disparo) and disparando==0)
		if(key(_A)) disparo(120,240);
		elseif(key(_S)) disparo(320,240);
		elseif(key(_D)) disparo(520,240); end
	  end
	  if(!key(_A) and !key(_S) and !key(_D)) disparando=0; end
	  frame;
	end
	todo_pagado=1;
	from x=1 to 12;
		puertas[x].pagado=0;
		puertas[x].tipo=0;
		puertas[x].distancia=0;
		puertas[x].toques=0;
	end
	nivel++;
	pon_nivel(0);
End

Process reloj();
Begin
	graph=1;
	x=320; y=42; z=-11;
	loop
		flags=(flags)?0:1;
		frame(3000);
	end
End

Process grafico(graph,x,y,z);
Begin
	loop frame; end
End

Process puerta(orig_num_puerta); //num_puerta 1-12, hueco -1,0,1 +margenes
Private
	hueco;
	num_puerta;
	id_grafico[3];
	i;
	temp;
Begin
	num_puerta=orig_num_puerta;
	hueco=num_puerta-puerta_actual;
	if(num_puerta<1) num_puerta+=12; end
	if(num_puerta>12) num_puerta-=12; end
	banquero(num_puerta);
	graph=11;
	x=320+(hueco)*200;
	y=260;
	z=1;

	if(hueco>=-2 and hueco<=2) id_txt[hueco+3]=write(fnt,x,187,4,num_puerta); end
	if(hueco>=-1 and hueco<=1) cuadropuerta(num_puerta); end
	loop
		x=320+(hueco)*200+x_central;
		move_text(id_txt[hueco+3],x,187);
		if(puertas[num_puerta].distancia==0 and hueco>=-1 and hueco<=1 and x_central==0 and puertas[num_puerta].tipo!=0 and rand(0,60)==0 and moviendo==0)
			break;
		end
		frame;
	end
	ready--;
	delete_text(id_txt[hueco+3]);
	graph=12;
//	frame(1000);
//	graph=13;
//	frame(1000);
	//resolución!
	switch(puertas[num_puerta].tipo)
		case 1 .. 2: //bueno
			i=puertas[num_puerta].tipo;
			id_grafico[1]=grafico(i*100+1,x,y,2);
			frame(400); //mostramos al que viene con la puerta medio abierta momentaneamente
			graph=13; //abrimos la puerta del todo
			//aparece
			from temp=0 to 10;
				if(collision(type disparo)) signal(id_grafico[1],s_kill); puertas[num_puerta].tipo=0; queja(puertas[num_puerta].tipo,x); loop frame; end end
				frame;
			end
			//mira para los lados
			if(rand(0,1)) 
				id_grafico[1].graph=i*100+2;
				from temp=0 to 10; 
					if(collision(type disparo)) signal(id_grafico[1],s_kill); puertas[num_puerta].tipo=0; queja(puertas[num_puerta].tipo,x); loop frame; end end
					if(temp<5) id_grafico[1].flags=0; else id_grafico[1].flags=1; end 
					frame;
				end
				from temp=0 to 10; 
					if(collision(type disparo)) signal(id_grafico[1],s_kill); puertas[num_puerta].tipo=0; queja(puertas[num_puerta].tipo,x); loop frame; end end
					if(temp<5) id_grafico[1].flags=0; else id_grafico[1].flags=1; end 
					frame;
				end
			end
			id_grafico[1].flags=0;
			//entrega la pasta
			id_grafico[1].graph=i*100+3;
			suena(2);
			from temp=0 to 20;
				if(collision(type disparo)) signal(id_grafico[1],s_kill); puertas[num_puerta].tipo=0; queja(puertas[num_puerta].tipo,x); loop frame; end end
				frame;
			end
			//y se va
			id_grafico[1].graph=i*100+4;
			tomapuntos(500,x,y);
			//frame(500);
		end
		case 3: //niñobonus!!
			id_grafico[1]=grafico(301,x,y,2);
			frame(400); //mostramos al que viene con la puerta medio abierta momentaneamente
			graph=13; //abrimos la puerta del todo
			//aparece
			temp=0;
			while(temp<30)
				if(collision(type disparo)) temp=0; tomapuntos((id_grafico[1].graph-300)*100,x,y); id_grafico[1].graph++; end
				if(id_grafico[1].graph==306) puertas[num_puerta].pagado=1; suena(2); frame(1000); break; end
				temp++;
				frame;
			end
		end
		case 4: //malo
			id_grafico[1]=grafico(401,x,y,2);
			frame(400); //mostramos al que viene con la puerta medio abierta momentaneamente
			graph=13; //abrimos la puerta del todo
			//aparece
			from temp=0 to 25;
				if(collision(type disparo)) temp=0; break; end
				frame;
			end
			if(temp>=25)
				//nos disparan
				id_grafico[1].graph=402;
				suena(1);
				disparo(x-35,y-5);
				frame(1000);
				puertas[num_puerta].tipo=0;
				game_over();
				return;
			else
				//le disparamos
				tomapuntos(500,x,y);
				id_grafico[1].graph=403;
				frame(2000);
			end
		end
	end
	//fin resolucion
	graph=12;
	frame(400);
	if(exists(id_grafico[1])) signal(id_grafico[1],s_kill); end
	if(puertas[num_puerta].tipo<3) puertas[num_puerta].pagado=1; end
	puertas[num_puerta].tipo=0;
	ready++;
	delete_text(id_txt[hueco+3]);
	puerta(orig_num_puerta);
End

Process tomapuntos(cuantos,x,y);
Begin
	puntos+=cuantos;
End

Process cuadropuerta(num_puerta);
Private
	hueco;
Begin
	graph=27;
	y=85;
	z=-15;
	if(num_puerta<=6)
		x=-10+num_puerta*45;
	else
		x=65+num_puerta*45;
	end
	while(exists(father))
		frame;
	end
End

Process banquero(num_puerta);
Begin
	z=-1;
	y=480-(175/2);
	while(exists(father))
		x=father.x;
		if(x==0 and x_central==0) 
			graph=0; 
		else 
			if(puertas[num_puerta].pagado) graph=5; else graph=4; end
		end
		frame;
	end
End

Process marcador(num_puerta);
Private
	id_caja;
	pagado;
Begin
	if(num_puerta<=6)
		x=-10+num_puerta*45;
	else
		x=65+num_puerta*45;
	end
	id_caja=grafico(21,x,85,-11);
	z=-11;
	graph=25;
	loop
		y=85-puertas[num_puerta].distancia/3;
		if(puertas[num_puerta].pagado and pagado==0) pagado=1; grafico(22,x,85,-15); end
		if(puertas[num_puerta].tipo!=0)
			if(puertas[num_puerta].distancia==0 or todo_pagado)
				id_caja.graph=24;
				graph=0;
			else
				id_caja.graph=21;
				graph=25;
				puertas[num_puerta].distancia--;
			end
		else
			id_caja.graph=21;
			graph=0;
		end
		//while(puertas[num_puerta].tipo==0) frame; end
		frame;
	end
End

Process disparo(x,y);
Begin
	disparando=1;
	graph=902;
	z=-15;
	suena(1);
	frame(200);
End

Process disparo_intro(x,y);
Begin
	disparando=1;
	graph=902;
	z=-15;
	suena(1);
	from alpha=255 to 100 step -40; size-=3; frame; end
End

Process game_over();
Begin
	let_me_alone();
	delete_text(all_text);
	put_screen(0,901);
	disparo(320,240);
	graph=501;
	x=320;
	y=320;
	frame(200);
	y=370;
	graph=504;
	frame(3000);
	vidas--;
	if(vidas>0) pon_nivel(1); end
	exit();
End

Process intro();
Begin
	put_screen(0,901);
	graph=501;
	x=320;
	y=320;
	frame(3000);
	write(fnt,320,140,4,"Nivel "+nivel);
	graph=502;
	disparo_intro(271,330);
	frame(5000);
	pon_nivel(0);
End

Process queja(tipo,x);
Begin
	//aqui meteremos al protestón
	game_over();
End

Process tiempo();
Private
	time=1800;
Begin
	grafico(905,512,465,-15);
	z=-16;
	graph=904;
	region=1;
	x=512;
	y=465;
	define_region(1,384,449,256,31);
	loop
		if(ready==1) time--; end
		define_region(1,384,449,(float)256/1800*time,31);
		frame;
	end
End

Process suena(sonido);
Begin
	play_wav(sonidos[sonido],0);
End