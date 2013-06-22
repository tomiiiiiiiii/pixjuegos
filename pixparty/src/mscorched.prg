Process mscorched();
Private
	x_inc;
	y_inc;
	id_col;
Begin
	file=fpg_minijuego=load_fpg("mscorched.fpg");

	tanque(1);
	tanque(2);
	tanque(3);
	tanque(4);
	
	put_screen(fpg_minijuego,5);
	
	while(!ready) frame; end

	while(p[1].posicion==0 or p[2].posicion==0 or p[3].posicion==0 or p[4].posicion==0)
		frame;
	end
	wait(2);
	ready=0;
End

Process tanque(jugador);
Begin
	file=fpg_minijuego;
	graph=jugador;
	controlador(jugador);
	z=-3;
	switch(jugador)
		case 1: x=147; y=448; end
		case 2: x=367; y=459; end
		case 3: x=858; y=454; end
		case 4: x=1055; y=433; end
	end
	while(!ready) frame; end
	loop
		j=0;
		from i=1 to 4; if(p[i].posicion>0) j++; end end
		if(j==3) desposiciona(jugador); loop frame; end end

		if(collision(type disparo)) 
			desposiciona(jugador);
			if(jugador==1 or jugador==3) y=360; end
			if(jugador==2 or jugador==4) x=640; end
			loop frame; end
		end
		frame;
	end
End

Process canon(jugador);
Private
	retraso=120;
Begin
	file=fpg_minijuego;
	graph=7;
	angle=-90000;
	set_center(fpg_minijuego,graph,0,17);
	while(p[jugador].posicion==0)
		while(retraso>0) retraso--; end
		if(p[jugador].botones[0] and angle>-170000) angle-=3000; end
		if(p[jugador].botones[1] and angle<20000) angle+=3000; end
		if(p[jugador].botones[2]) retraso=120; disparo(50,angle); end
		frame;
	end
End

Process disparo(potencia,angle);
Begin
	file=fpg_minijuego;
	graph=7;
	while(y<720)
		advance(potencia);
		if(potencia<10) y+=grav; grav++; end
		frame;
	end
End