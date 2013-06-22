Process mpisarcabezas();
Begin
	file=fpg_minijuego=load_fpg("mpisarcabezas.fpg");
	personaje(1);
	personaje(2);
	personaje(3);
	personaje(4);
	put_screen(fpg_minijuego,5);
	
	while(!ready) frame; end
	while(p[1].posicion==0 or p[2].posicion==0 or p[3].posicion==0 or p[4].posicion==0)
		frame;
	end
	wait(2);
	ready=0;
End

Process personaje(jugador);
Private
	inercia;
	saltando;
	y_destino;
	dureza;
	salto_extra;
	id_col;
Begin
	file=fpg_minijuego;
	controlador(jugador);
	while(!ready) frame; end
	graph=jugador;
	switch(jugador)
		case 1: x=220; end
		case 2: x=480; end
		case 3: x=1280-480; end
		case 4: x=1280-220; end
	end
	y=600;
	z=-3;
	grav=0;
	dureza=map_get_pixel(fpg_minijuego,5,1279,719);
	loop
		j=0;
		from i=1 to 4; if(p[i].posicion>0) j++; end end
		if(j==3) desposiciona(jugador); loop frame; end end
		
		if(id_col=collision(type personaje))
			if(id_col.y<y and id_col.grav>0)
				id_col.grav=-15;
				graph=6; suena(2);
				grav=0;
				while(alpha>0) alpha-=5; frame; end
				desposiciona(jugador);
				loop frame; end
			end
		end
		if(map_get_pixel(fpg_minijuego,5,x,y+30)==dureza and map_get_pixel(fpg_minijuego,5,x,y+26)!=dureza)
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
				if(map_get_pixel(fpg_minijuego,5,x,y+30)==dureza and map_get_pixel(fpg_minijuego,5,x,y+26)!=dureza)
					break; 
				else
					y++;
				end
			end
		elseif(y_destino<y)
			y=y_destino;
		end
		
		if(p[jugador].botones[0]) x-=3; inercia-=3; flags=1;
		elseif(p[jugador].botones[1]) x+=3; inercia+=3; flags=0; end
		x+=inercia/5;
		if(grav==0)
	
		end
		if(x>1280) x=0; elseif(x<0) x=1280; end
		frame;
	end
End