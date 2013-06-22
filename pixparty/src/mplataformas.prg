Process mplataformas();
Begin
	file=fpg_minijuego=load_fpg("mplataformas.fpg");
	queco(1);
	queco(2);
	queco(3);
	queco(4);
	start_scroll(0,fpg_minijuego,8,0,0,0);
	scroll.camera=camara();
	while(!ready) frame; end
	while(p[1].posicion==0 or p[2].posicion==0 or p[3].posicion==0 or p[4].posicion==0)
		frame;
	end
	wait(2);
	ready=0;
End

Process camara();
Begin
	loop
		frame;
	end
End

Process queco(jugador);
Private
	inercia;
	saltando;
	y_destino;
	x_destino;
	dureza;
	salto_extra;
	id_col;
Begin
	file=fpg_minijuego;
	controlador(jugador);
	while(!ready) frame; end
	graph=jugador;
	ctype=c_scroll;
	x=200;
	y=100;
	z=-3;
	grav=0;
	dureza=map_get_pixel(fpg_minijuego,5,1,700);
	loop
		if(x>scroll.camera.x) scroll.camera.x=x; end
		j=0;
		from i=1 to 4; if(p[i].posicion>0) j++; end end
		if(j==3) desposiciona(jugador); loop frame; end end
		
		if(map_get_pixel(fpg_minijuego,5,x,y+30)==dureza)
			if(grav=>0) grav=0; salto_extra=15; 
				if(inercia>0)
					if(inercia>30) inercia=30; end
					inercia--;
					if(inercia<0) inercia=0; end
				elseif(inercia<0)
					if(inercia<-30) inercia=-30; end
					inercia++;
					if(inercia>0) inercia=0; end
				end
			end
			if(p[jugador].botones[4] and saltando==0 and grav==0) saltando=1; grav=-13; end
		else
			grav++;
		end
		if(!p[jugador].botones[4]) saltando=0; end
		if(p[jugador].botones[4] and saltando and salto_extra>0 and grav=>-salto_extra) salto_extra--; grav--; end
		if(map_get_pixel(fpg_minijuego,5,x,y+30)==dureza and grav<0) grav++; end
		if(inercia>0)
			if(inercia>40) inercia=40; end
			inercia--;
			if(inercia<0) inercia=0; end
		elseif(inercia<0)
			if(inercia<-40) inercia=-40; end
			inercia++;
			if(inercia>0) inercia=0; end
		end
		
		y_destino=y+(grav);
		if(y_destino>y)
			from y=y to y_destino;
				if(map_get_pixel(fpg_minijuego,5,x,y+30)==dureza)
					break; 
				else
					y++;
				end
			end
		elseif(y_destino<y)
			y=y_destino;
		end
		
		if(p[jugador].botones[0] and map_get_pixel(fpg_minijuego,5,x-25,y)!=dureza) x-=3; inercia-=3; flags=1;
		elseif(p[jugador].botones[1] and map_get_pixel(fpg_minijuego,5,x+25,y)!=dureza) x+=3; inercia+=3; flags=0; end
		if(map_get_pixel(fpg_minijuego,5,x+25,y)!=dureza) x+=inercia/5; end
		if(grav==0)
	
		end
		if(x<0) x=0; end
		if(x<scroll.camera.x-640 or y>720)
			graph=6; suena(2); suena(2);
			grav=0;
			while(alpha>0) alpha-=5; frame; end
			desposiciona(jugador);
			loop frame; end
		end
		if(x>10217) 
			posiciona(jugador);	
			alpha=128;
			loop frame; end
		end
		frame;
	end
End