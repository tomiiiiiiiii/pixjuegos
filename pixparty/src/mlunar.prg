Process mlunar();
Begin
	file=fpg_minijuego=load_fpg("mlunar.fpg");
	nave(1);
	nave(2);
	nave(3);
	nave(4);
	put_screen(fpg_minijuego,5);
	
	while(!ready) frame; end
	while(p[1].posicion==0 or p[2].posicion==0 or p[3].posicion==0 or p[4].posicion==0)
		frame;
	end
	wait(2);
	ready=0;
End

Process nave(jugador);
Begin
	file=fpg_minijuego;
	controlador(jugador);
	graph=jugador;
	switch(jugador)
		case 1: x=220; end
		case 2: x=480; end
		case 3: x=1280-480; end
		case 4: x=1280-220; end
	end
	//x=200*jugador;
	y=80;
	z=-3;
	grav=-10;
	while(!ready) frame; end
	while(y<563)
		if(y<30) y=30; grav=abs(grav); end
		if(p[jugador].botones[4]) grav-=2; fuego(); end
		y+=grav/5;
		grav++;
		frame;
	end
	if(grav>10)
		p[jugador].posicion=4;
		graph=6; suena(2);
		while(alpha>0) alpha-=5; y+=grav/5; frame; end
	else 
		posiciona(jugador);
	end
	loop
		frame;
	end
End

Process fuego();
Begin
	file=fpg_minijuego;
	x=father.x; y=father.y+40; z=father.z+1;
	graph=7;
	size_y=rand(70,100);
	frame;
End