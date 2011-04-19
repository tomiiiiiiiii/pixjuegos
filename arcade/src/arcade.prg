Global
	opcion=1;
	
	njoys;
	posibles_jugadores;
	debuj;
	struct p[5];
		botones[7];
		control;
	end
	joysticks[10];
Local
	i;j;
Begin
	configurar_controles();
	controlador(0);
	inicio();
End

Process inicio();
Begin
	full_screen=1;
	set_mode(800,600,32);
	set_fps(50,9);
	load_fpg("fpg/arcade.fpg");
	
	flecha(0); flecha(1);
	actual();
End

Process actual();
Begin
	x=400;
	y=300;
	z=1;
	if(opcion>5) opcion=1; end
	if(opcion<1) opcion=5; end
	//flecha(0); flecha(1);
	graph=opcion;
	loop
		if(p[0].botones[0]) enmovimiento(0); enmovimiento(1); opcion--; break; end
		if(p[0].botones[1]) enmovimiento(2); enmovimiento(3); opcion++; break; end
		if(p[0].botones[4]) from size=100 to 120; alpha-=10; frame; end ejecutar(); end
		if(key(_esc)) say("salir"); exit(); end
		frame;
	end
End

Process ejecutar();
Private
	string argumentos;
	string juego;
Begin
	let_me_alone();
	argumentos='arcade';
	switch(opcion)
		case 1: juego="pixbros"; end
		case 2: juego="pixpang"; end
		case 3: juego="garnatron"; end
		case 4: juego="pixfrogger"; end
		case 5: juego="pixdash"; end
	end
	say(juego);
	exit();
	//chdir("../"+juego);
	//exec(_P_WAIT,"./"+juego,1,&argumentos);
	//chdir("../arcade");
	//exec(_P_NOWAIT,"./arcade",1,&argumentos);
End

Process flecha(flags);
Private
	inercia;
Begin
	graph=6;
	y=300;
	z=-1;
	if(flags==0) x=700; end
	if(flags==1) x=100; end
	while(exists(father))
		inercia++;
		if(flags==0)
			x+=inercia;
		else
			x-=inercia;
		end
		frame;
	end
End

Process enmovimiento(tipo);
Begin
	y=300;
	switch(tipo)
		case 0: flecha(1); graph=opcion; x=400; end
		case 1: graph=opcion-1; x=-400; end
		case 2: flecha(0); graph=opcion; x=400; end
		case 3: graph=opcion+1; x=1200; end
	end

	if(graph>5) graph=1; end
	if(graph<1) graph=5; end

	loop
		switch(tipo)
			case 0:
				if(x<1200) x+=((1200-x)/10)+5; else x=1200; break; end
			end
			case 1:
				if(x<400) x+=((400-x)/10)+5; else x=400; break; end
			end
			case 2:
				if(x>-400) x+=((-400-x)/10)-5; else x=-400; break; end //ESTE FUNCIONA
			end
			case 3:
				if(x>400) x-=((x-400)/10)+5; else x=400; break; end
			end
		end
		frame;
	end
	if(tipo==1 or tipo==3) actual(); end
End

include "../../common-src/controles.pr-";
