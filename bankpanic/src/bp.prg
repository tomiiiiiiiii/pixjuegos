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
	ready=1;
	nivel=1;
	tiempo_margen=60;
	x_central; //para cuando movemos las puertas
	fnt_nums;
End

Begin
	rand_seed(time());
	set_mode(640,480,32);
	load_fpg("bp.fpg");
	fnt_nums=load_fnt("nums.fnt");
	play_song(load_song("1.ogg"),-1);
	pon_nivel();
End

Process pon_nivel();
Private
	id_puerta;
	cambio_puertas;
	nopagado;
Begin
	let_me_alone();
	from x=1 to 12;
		if(rand(0,nivel)==0) puertas[x].pagado=1; end
	end
	from x=1 to 12;
		if(rand(0,4)==0 and puertas[x].pagado==0)
			puertas[x].distancia=rand(2,15)*90;
			puertas[x].tipo=rand(1,4);
			if(nivel>2) puertas[x].toques=rand(10,25)/10; else puertas[x].toques=1; end
		end
		marcador(x);
	end
	from x=puerta_actual-3 to puerta_actual+3;
		puerta(x);
	end

	reloj();
	
	//panel marcadores
	grafico(2,320,55,-10);
	set_fps(28+(nivel*2),0);
	
	grafico(26,320,240,-10);
	grafico(26,120,240,-10);
	grafico(26,520,240,-10);

	loop
		while(!ready) frame; end
		if(key(_left)) 
			from x_central=0 to 200 step 10; frame; end
			puerta_actual--;
			cambio_puertas=1;
		elseif(key(_right)) 
			from x_central=0 to -200 step -10; frame; end
			puerta_actual++;
			cambio_puertas=1;
		end
		if(cambio_puertas)
			while(id_puerta=get_id(type puerta))
				signal(id_puerta,s_kill);
			end
			if(puerta_actual>12) puerta_actual-=12; end
			if(puerta_actual<1) puerta_actual+=12; end
			delete_text(all_text);
			x_central=0;
			from x=puerta_actual-3 to puerta_actual+3;
				puerta(x);
			end
			cambio_puertas=0;
		end
		nopagado=0;
		from x=1 to 12;
			if(puertas[x].tipo==0 and rand(0,200)==0)
				puertas[x].distancia=rand(3,6)*90;
				puertas[x].tipo=rand(1,4);
				if(nivel>2) puertas[x].toques=rand(10,25)/10; else puertas[x].toques=1; end
			end
		end

		from x=1 to 12; if(!puertas[x].pagado) nopagado=1; end end
		if(nopagado==0) break; end
		frame;
	end
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
	id_txt;
	hueco;
	num_puerta;
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
	id_txt=write(fnt_nums,x,187,4,num_puerta);
	if(hueco>=-1 and hueco<=1) cuadropuerta(num_puerta); end
	loop
		x=320+(hueco)*200+x_central;
		move_text(id_txt,x,187);
		if(puertas[num_puerta].distancia==0 and hueco>=-1 and hueco<=1 and x_central==0 and puertas[num_puerta].tipo!=0 and rand(0,100)==0)
			break;
		end
		frame;
	end
	ready--;
	delete_text(id_txt);
	graph=12;
	frame(1000);
	graph=13;
	frame(1000);
	puertas[num_puerta].pagado=1;
	puertas[num_puerta].tipo=0;
	ready++;
	delete_text(id_txt);
	puerta(orig_num_puerta);
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
	if(num_puerta==0) num_puerta=12; end
	if(num_puerta==13) num_puerta=1; end
	//if(puertas[num_puerta].pagado) graph=4; else graph=5; end
	z=-1;
	graph=4;
	y=480-(175/2);
	while(exists(father))
		x=father.x;
		frame;
	end
End

Process marcador(num_puerta);
Private
	id_caja;
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
		y=85-puertas[num_puerta].distancia/6;
		if(puertas[num_puerta].pagado) id_caja.graph=22; end
		while(puertas[num_puerta].tipo==0) graph=0; frame; graph=25; end
		if(puertas[num_puerta].distancia==0)
			id_caja.graph=24; 
			graph=0;
		else
			puertas[num_puerta].distancia--;
		end

		frame;
	end
End