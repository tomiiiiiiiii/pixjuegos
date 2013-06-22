Process mfrogger();
Begin
	file=fpg_minijuego=load_fpg("mfrogger.fpg");
	rana(1);
	rana(2);
	rana(3);
	rana(4);
	
	from i=1 to 8; 
		coche(i,rand(-2,2),rand(50,80),rand(11,12)); 
	end
	put_screen(fpg_minijuego,5);
	
	while(!ready) frame; end
	while(p[1].posicion==0 or p[2].posicion==0 or p[3].posicion==0 or p[4].posicion==0)
		frame;
	end
	wait(2);
	ready=0;
End

Process rana(jugador);
Begin
	file=fpg_minijuego;
	controlador(jugador);
	graph=jugador;
	x=55; y=360+((jugador-2)*64); z=-3;
	while(!ready) frame; end
	loop
		if(p[jugador].botones[0] and x>55) x-=8; end
		if(p[jugador].botones[1] and x<1250) x+=8; end
		if(p[jugador].botones[2]) y-=8; end
		if(p[jugador].botones[3]) y+=8; end
		if(collision(type coche))
			//p[jugador].posicion=4;
			graph=6; suena(2);
			while(alpha>0) alpha-=5; frame; end
			//break;
			graph=jugador;
			x=55; y=360+((jugador-2)*64); z=-3;
			alpha=255;
		end
		if(p[jugador].posicion==4)
			graph=6; suena(2);
			while(alpha>0) alpha-=5; frame; end
			loop frame; end
		end
		if(x>1280-56)
			from i=1 to 4; p[i].posicion=4; end
			p[jugador].posicion=1;
			//posiciona(jugador); 
			loop frame; end
		end
		frame;
	end
End

Process coche(posicion,velocidad,distancia,graph);
Begin
	file=fpg_minijuego;
	//while(!ready) frame; end
	x=64+(posicion*128);
	if(velocidad==0) velocidad=1; end
	if(velocidad>0) y=-100; else y=1000; flags=2; end
	//distancia=40+(velocidad*20);
	if(graph==11)
		distancia=90+abs(velocidad*5);
	else
		distancia=60+abs(velocidad*5);
	end
	while(y<1200 and y>-200)
		y+=velocidad*3;
		if(i==distancia)
			coche(posicion,velocidad,distancia,graph); 
		end
		i++;
		if(!ready) frame(30); else frame; end
	end
End




