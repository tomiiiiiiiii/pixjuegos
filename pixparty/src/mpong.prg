Process mpong();
Private
	x_inc;
	y_inc;
	id_col;
Begin
	file=fpg_minijuego=load_fpg("mpong.fpg");
	x=640;
	y=360;
	palo(1);
	palo(2);
	palo(3);
	palo(4);
	
	put_screen(fpg_minijuego,7);
	
	while(!ready) frame; end
	z=-3;
	while(p[1].posicion==0 or p[2].posicion==0 or p[3].posicion==0 or p[4].posicion==0)
		graph=8;
		if(i==0) x_inc=0; y_inc=0; i=1; end
		if(x_inc==0 and y_inc==0)
			x=640; y=360;
			frame(2000);
			while(x_inc==0 or y_inc==0)
				x_inc=rand(-5,5); y_inc=rand(-5,5); 
			end
		end
		if(id_col=collision(type palo)) 
			if(x_inc>0) x_inc++; else x_inc--; end
			if(y_inc>0) y_inc++; else y_inc--; end
			if(id_col.graph==11 or id_col.graph==13) 
				x_inc=x_inc*-1; 
			end
			if(id_col.graph==12 or id_col.graph==14) 
				y_inc=y_inc*-1;
			end
		end
		x+=x_inc;
		y+=y_inc;
		frame;
	end
	wait(2);
	ready=0;
End

Process palo(jugador);
Begin
	file=fpg_minijuego;
	graph=10+jugador;
	controlador(jugador);
	z=-3;
	switch(jugador)
		case 1: x=300; y=360; end
		case 2: x=640; y=20; end
		case 3: x=978; y=360; end
		case 4: x=640; y=700; end
	end
	while(!ready) frame; end
	loop
		j=0;
		from i=1 to 4; if(p[i].posicion>0) j++; end end
		if(j==3) desposiciona(jugador); loop frame; end end
		
		if(jugador==1 or jugador==3)
			if(jugador==1 and father.x<x) father.i=0; from size_y=100 to 650 step 50;frame;end; size_y=650; end
			if(jugador==3 and father.x>x) father.i=0; from size_y=100 to 650 step 50;frame;end; size_y=650; end
			if(p[jugador].botones[2] and y>70) y-=10; end
			if(p[jugador].botones[3] and y<650) y+=10; end
		else
			if(jugador==2 and father.y<y) father.i=0; from size_x=100 to 650 step 50;frame;end; size_x=650; end
			if(jugador==4 and father.y>y) father.i=0; from size_x=100 to 650 step 50;frame;end; size_x=650; end
			if(p[jugador].botones[0] and x>350) x-=10; end
			if(p[jugador].botones[1] and x<928) x+=10; end
		end
		if(size_x==650 or size_y==650) 
			desposiciona(jugador);
			if(jugador==1 or jugador==3) y=360; end
			if(jugador==2 or jugador==4) x=640; end
			loop frame; end
		end
		frame;
	end
End