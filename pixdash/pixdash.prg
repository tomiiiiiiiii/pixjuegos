Program plataformas;
Global                 
	suelo;
	ancho_pantalla=1280;
	alto_pantalla=1024;
	ancho_nivel;
	alto_nivel;
	Struct botones;
		int p[8][6];
	End
	struct p[8];
		control;
		puntos;
		vidas;
		personaje;
	end
	jugadores=2;
	num_lakitu=0;
	tiles[100];
	adornos[100];
	enemigos[100];
	mapa_scroll;
	durezas;
	fpg_tiles;
	tilesize=40;
	fondo;
	flash;
	fuente;
End 

Local
	jugador;
	powerup;
	gravedad;
	ancho;
	alto;
	string accion;
	i;
	tiempo_powerup;
	saltando;
End
	
Begin
	play_song(load_song("kirby.ogg"),-1);
	p[2].control=1;
	p[3].control=2;
	p[4].control=3;
	set_fps(50,0);
	full_screen=true;
	set_mode(ancho_pantalla,alto_pantalla,16);	    
	fpg_tiles=load_fpg("tiles.fpg");
	fuente=load_fnt("fuente.fnt");
//	durezas=load_png("3copia.png");
//	ancho_nivel=graphic_info(file,durezas,g_width);
//	alto_nivel=graphic_info(file,durezas,g_height);
//	suelo=map_get_pixel(0,durezas,0,0);
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	fondo=load_png("fondo.png");
	carga_nivel(load_png("nivel1.png"));
	marcadores();
	if(jugadores==2)
		define_region(1,0,0,ancho_pantalla,alto_pantalla/2);
		define_region(2,0,alto_pantalla/2,ancho_pantalla,alto_pantalla);

		start_scroll(0,0,mapa_scroll,fondo,1,0);
		scroll[0].camera=prota(1);
		start_scroll(1,0,mapa_scroll,fondo,2,0);
		scroll[1].camera=prota(2);

		graph=new_map(ancho_pantalla,alto_pantalla,16);
		drawing_color(200);
		drawing_map(0,graph);
		draw_box(0,alto_pantalla/2-5,ancho_pantalla,alto_pantalla/2+5);

		flash=new_map(ancho_pantalla,alto_pantalla/2,8);
		drawing_color(suelo);
		drawing_map(0,flash);
		draw_box(0,0,ancho_pantalla,alto_pantalla/2);
	else
		define_region(1,0,0,ancho_pantalla/2,alto_pantalla/2);
		define_region(2,ancho_pantalla/2,0,ancho_pantalla,alto_pantalla/2);
		define_region(3,0,alto_pantalla/2,ancho_pantalla/2,alto_pantalla);
		define_region(4,ancho_pantalla/2,alto_pantalla/2,ancho_pantalla,alto_pantalla);

		start_scroll(0,0,mapa_scroll,fondo,1,0);
		scroll[0].camera=prota(1);
		start_scroll(1,0,mapa_scroll,fondo,2,0);
		scroll[1].camera=prota(2);
		start_scroll(2,0,mapa_scroll,fondo,3,0);
		scroll[2].camera=prota(3);
		start_scroll(3,0,mapa_scroll,fondo,4,0);
		scroll[3].camera=prota(4);

		graph=new_map(ancho_pantalla,alto_pantalla,16);
		drawing_color(200);
		drawing_map(0,graph);
		draw_box(0,alto_pantalla/2-5,ancho_pantalla,alto_pantalla/2+5);
		draw_box(ancho_pantalla/2-5,0,ancho_pantalla/2+5,alto_pantalla);
		
		flash=new_map(ancho_pantalla/2,alto_pantalla/2,8);
		drawing_color(suelo);
		drawing_map(0,flash);
		draw_box(0,0,ancho_pantalla,alto_pantalla/2);
		mouse.graph=flash;
	end
	//enemigo(rand(4000,ancho_nivel),rand(0,275),8); //lakitu
	//from i=1 to 5; powerups(100*i,20,i); end
	loop
		if(rand(0,200)==0) enemigo(rand(1500,ancho_nivel),rand(0,alto_nivel),7); end //BILLBALAS
		if(rand(0,30)==0) enemigo(rand(1500,ancho_nivel),rand(0,alto_nivel),rand(1,4)); end //NORMALACOS
		if(rand(0,200)==0) enemigo(rand(0,ancho_nivel),rand(0,alto_nivel),rand(5,6)); end //ESPINIS
		if(rand(0,50)==0) powerups(rand(0,ancho_nivel),rand(0,alto_nivel),rand(1,5)); end
		if(num_lakitu==0 and rand(0,0)==0) enemigo(rand(4000,ancho_nivel),rand(0,275),8); num_lakitu=num_lakitu+1; end
		frame;
	end
End

Process prota(jugador);
Private 
	pulsando;
	INERCIA;
	x_destino;
	y_destino;
	string animacion;
	anim;
	id_colision;
	doble_salto;
	saltogradual;
Begin
	controlador(jugador);
	x=20;
	y=0;
	size=125;
	graph=1;
	ctype=c_scroll;
	switch(jugador)
		case 1: file=load_fpg("pikachu.fpg"); end
		case 2: file=load_fpg("mjackson.fpg"); end
		case 3: file=load_fpg("aladdin.fpg"); end
		case 4: file=load_fpg("pix.fpg"); end
	end
	//ctype=c_screen;
	ancho=graphic_info(file,graph,g_width)/2;
	alto=graphic_info(file,graph,g_height)/2;
	loop
		if(botones.p[jugador][1]) flags=0; inercia+=2; end
		if(botones.p[jugador][0]) flags=1; inercia-=2; end
		if(botones.p[jugador][4] and pulsando==0 and saltando==0) saltando=1; sonido("pikachu-brinca"); saltogradual=1; gravedad=-15; pulsando=1; y--; end
		if(botones.p[jugador][4] and pulsando==0 and powerup==3 and tiempo_powerup>0 and doble_salto==0) saltogradual=1; doble_salto=1; gravedad=-15; pulsando=1; y--; end
		if(botones.p[jugador][4] and saltogradual<5 and saltogradual!=0) gravedad-=4; saltogradual++; end
		if(!botones.p[jugador][4] and pulsando==1) pulsando=0; saltogradual=0; end
		if(map_get_pixel(0,durezas,x,y+alto)==suelo) gravedad=0; saltando=0; doble_salto=0; else saltando=1; gravedad++; end
		if(x>ancho_nivel) p[jugador].puntos+=50; sonido("mjackson-gana"); x=0; y=0; ANGLE=180000; end 
		if(inercia>0) inercia--; end
		if(inercia<0) inercia++; end
		if(inercia>20) inercia=20; end
		if(inercia<-20) inercia=-20; end
		if(powerup==5)
			inercia*=2;
		end
		//x=x+inercia;
		x_destino=x+(inercia/2);
		if(x_destino>x) 
			from x=x to x_destino step 1; if(map_get_pixel(0,durezas,x+ancho,y+alto/2)==suelo) inercia=0; break; end end
		elseif(x_destino<x)
			from x=x to x_destino step -1; if(map_get_pixel(0,durezas,x-ancho,y+alto/2)==suelo) inercia=0; break; end end
		end
		
		if(powerup==4)
			if(size<=220)
				size=size+5;
				ancho=(graphic_info(file,graph,g_width)/2)*size/100;
				alto=(graphic_info(file,graph,g_height)/2)*size/100;
			end
		else
			if(size>125)
				size=size-5;
				ancho=(graphic_info(file,graph,g_width)/2)*size/100;
				alto=(graphic_info(file,graph,g_height)/2)*size/100;
			end
		end
		
		if(powerup==5)
			inercia/=2;
		end

		if(y>alto_nivel) powerup=0; accion="muerte"; end
		if(x<10) x=10; end
		//y=y+gravedad;
		y_destino=y+(gravedad/2);
		if(y_destino>y) 
			from y=y to y_destino step 1; if(map_get_pixel(0,durezas,x,y+alto)==suelo) gravedad=0; break; end end
		elseif(y_destino<y)
			from y=y to y_destino step -1; if(map_get_pixel(0,durezas,x,y-alto)==suelo) gravedad=10; break; end end
		end
		while(map_get_pixel(0,durezas,x,y+alto-1)==suelo) y--; end
		if(gravedad==0)
			if(inercia!=0) animacion="andar"; else animacion="quieto"; end
		else
			animacion="salto";
		end
		if(accion=="muerte") 
			if(powerup!=2)
				graph=2;
				gravedad=-20;
				flash_muerte(jugador);
				sonido("pikachu-muere");
				while(y<alto_nivel+150)
					gravedad++;
					y+=gravedad/2;
					frame;
				end			
				x=0; y=0; 
				p[jugador].puntos=p[jugador].puntos*0.90;
				tiempo_powerup=0; 
				powerup=0; 
				accion="";
			else 
				accion=""; 
			end 
		end
		if(id_colision=collision(type prota)) if(id_colision.y>y) id_colision.gravedad=20; gravedad=-20; end end
		switch(animacion)
			case "": animacion="quieto"; graph=1; end
			case "quieto": graph=1; end
			case "andar": 
				if(graph=>11 and graph<14) 
					if(anim<5) anim++; else anim=0; graph++; end
				else
					graph=11; 
				end
			end
			case "salto":
				if(gravedad<0) graph=3; else graph=5; end
			end
		end
		if(tiempo_powerup>0) tiempo_powerup--; else powerup=0; end
		frame;	
	end      
End

Process flash_muerte(jugador);
Begin
	if(jugadores==2)
		x=ancho_pantalla/2;
		if(jugador==1) y=alto_pantalla/4; end
		if(jugador==2) y=(alto_pantalla/4)*3; end
	else
		if(jugador==1) x=ancho_pantalla/4; y=alto_pantalla/4; end
		if(jugador==2) x=(ancho_pantalla/4)*3; y=alto_pantalla/4; end
		if(jugador==3) x=ancho_pantalla/4; y=(alto_pantalla/4)*3; end
		if(jugador==4) x=(ancho_pantalla/4)*3; y=(alto_pantalla/4)*3; end
	end
	from i=0 to 2;
		graph=flash;
		frame;
		graph=0;
		frame;
	end
End

// tipos: 1: goomba, 2:paragoomba, 3:koopatroopa, 4:paratroopa, 5:spiky, 6:spiky-goomba, 7:billbala, 8:lakitu, 9:huevo de spyki
Process enemigo(x,y,tipo);
Private
		id_colision;
Begin
   ctype=c_scroll;
   switch(tipo)
 	  	case 1: graph=load_png("goomba.png"); end 
	   	case 2: graph=load_png("paragoomba.png"); end
		case 3: graph=load_png("koopatroopa.png"); end
		case 4: graph=load_png("paratroopa.png"); end
		case 5: graph=load_png("spiky.png"); end
		case 6: graph=load_png("spikygoomba.png"); end
		case 7: graph=load_png("billbala.png"); end	
		case 8: graph=load_png("lakitu.png"); num_lakitu=num_lakitu+1; end
		case 9: graph=load_png("spikyegg.png"); end
   end
   ancho=graphic_info(file,graph,g_width)/2;
   alto=graphic_info(file,graph,g_height)/2;
   loop
		if(map_get_pixel(0,durezas,x+ancho,y)==suelo and tipo!=8) flags=0; end //giramos cuando chocamos por la derecha, menos lakitu que no choca
		if(map_get_pixel(0,durezas,x-ancho,y)==suelo and tipo!=8 or x=<10) if(tipo==7) break; end flags=1; end //giramos cuando chocamos, o nos salimos, por la izquierda. aunque billbala muere
		if(map_get_pixel(0,durezas,x,y-alto)==suelo) gravedad=10; y++; end //si chocamos arriba, nos vamos pabajo. pd: s�lo chocan los para-algo
		if(tipo==7) flags=0; x-=6; end //billbala siempre va hacia la izquierda
		if(tipo==8 and rand(0,200)==0) enemigo(x,y,9); end //lakitu tirando pinchones
		if(flags==0) 
			if(tipo!=8) 
				x-=2; 
			else 
				x-=6; 
			end 
		else  
			if(tipo!=8) 
				x+=2; 
			else 
				x+=6; 
			end 
		end	//si miramos pa un lao, andamos pa ese, sino viceversa, menos lakitu
		if(tipo==8 and rand(0,300)==0) if(flags==0) flags=1; else flags=0; end end //cuando mira lakitu pa la derecha al azar
		if(tipo==8 and x>1441) flags=1; end
		if(map_get_pixel(0,durezas,x,y+alto)==suelo) //el malo toc� el suelo?
			if(tipo==9) enemigo(x,y, tipo-4); break; end 
			if(tipo==2 or tipo==4) gravedad=-40; y--; else gravedad=0; end //saltos para los para-algo, sino quietos nel suelo
		else 
			gravedad++; //pos no lo toc�
		end //gravedad
		if(y>alto_nivel) break; end //si caemos por un bujero, morimos
		while(map_get_pixel(0,durezas,x,y+alto-1)==suelo) y--; end //corregimos atravesamiento de suelos...
		if(id_colision=collision(type prota)) //chocamos con el prota
			if(id_colision.y<y and id_colision.saltando==1 and tipo!=5 and tipo!=6 and tipo!=9 and id_colision.accion!="muerte") //si el prota est� m�s arriba, el malo muere. a menos que sean spikis o sus huevos! y que no est� muriendo el prota xD
				p[id_colision.jugador].puntos++;
				id_colision.gravedad=-20; //rebota el prota
				while(size>0 and tipo!=2 and tipo!=4)  //animacion de la muerte, salvo que sean para-algo
					size=size-5; 
					angle+=7000;
					frame; 
				end
				if(tipo==2 or tipo==4) enemigo(x,y,tipo-1); end
				frame;
				if(tipo=8) num_lakitu=num_lakitu-1; end
				break; //suicidamos al malo
			else //el prota choc� por debajo de la altura del enemigo
				if(id_colision.powerup==1) 
					p[id_colision.jugador].puntos++;
					id_colision.gravedad=-20; //rebota el prota
					while(size>0 and tipo!=2 and tipo!=4)  //animacion de la muerte, salvo que sean para-algo
						size=size-5; 
						angle+=7000;
						frame; 
					end
					if(tipo==2 or tipo==4) enemigo(x,y,tipo-1); end
					frame;
					if(tipo=8) num_lakitu=num_lakitu-1; end
					break; //suicidamos al malo
				else
					id_colision.accion="muerte"; //el prota muere
				end
			end
		end
		if(tipo!=7 and tipo!=8) y=y+(gravedad/4); end //gravedad barata. a billbala y a lakitu no les afecta
		frame;
    end	
End

Process controlador(jugador);
Private
	distancia;
	gamepads;
Begin
	from i=0 to 5;
		botones.p[jugador][i]=0;
	end
	Loop
		if(!exists(father)) return; end
		if(p[jugador].control==-1) return; end
		If(p[jugador].control==0)  // teclado
			If(key(_left)) botones.p[jugador][0]=1; Else botones.p[jugador][0]=0; End
			If(key(_right)) botones.p[jugador][1]=1; Else botones.p[jugador][1]=0; End
			If(key(_up)) botones.p[jugador][2]=1; Else botones.p[jugador][2]=0; End
			If(key(_down)) botones.p[jugador][3]=1; Else botones.p[jugador][3]=0; End
			If(key(_up)) botones.p[jugador][4]=1; Else botones.p[jugador][4]=0; End
			If(key(_s)) botones.p[jugador][5]=1; Else botones.p[jugador][5]=0; End
			If(key(_d)) botones.p[jugador][6]=1; Else botones.p[jugador][6]=0; End
		End
		If(p[jugador].control==1)  // teclado
			If(key(_a)) botones.p[jugador][0]=1; Else botones.p[jugador][0]=0; End
			If(key(_d)) botones.p[jugador][1]=1; Else botones.p[jugador][1]=0; End
			If(key(_w)) botones.p[jugador][2]=1; Else botones.p[jugador][2]=0; End
			If(key(_down)) botones.p[jugador][3]=1; Else botones.p[jugador][3]=0; End
			If(key(_w)) botones.p[jugador][4]=1; Else botones.p[jugador][4]=0; End
			If(key(_s)) botones.p[jugador][5]=1; Else botones.p[jugador][5]=0; End
			If(key(_d)) botones.p[jugador][6]=1; Else botones.p[jugador][6]=0; End
		End
		If(p[jugador].control==2)  // joystick
			If(get_joy_position(0,0)<-10000) botones.p[jugador][0]=1; Else botones.p[jugador][0]=0; End
			If(get_joy_position(0,0)>10000) botones.p[jugador][1]=1; Else botones.p[jugador][1]=0; End
			If(get_joy_position(0,1)<-7500) botones.p[jugador][2]=1; Else botones.p[jugador][2]=0; End
			If(get_joy_position(0,1)>7500) botones.p[jugador][3]=1; Else botones.p[jugador][3]=0; End
			If(get_joy_position(0,1)<-7500) botones.p[jugador][4]=1; Else botones.p[jugador][4]=0; End
			If(get_joy_button(0,1)) botones.p[jugador][5]=1; Else botones.p[jugador][5]=0; End
			If(get_joy_button(0,2)) botones.p[jugador][6]=1; Else botones.p[jugador][6]=0; End
		End
		If(p[jugador].control==3)  // joystick
			If(get_joy_position(0,2)<-10000) botones.p[jugador][0]=1; Else botones.p[jugador][0]=0; End
			If(get_joy_position(0,2)>10000) botones.p[jugador][1]=1; Else botones.p[jugador][1]=0; End
			If(get_joy_position(0,3)<-7500) botones.p[jugador][2]=1; Else botones.p[jugador][2]=0; End
			If(get_joy_position(0,3)>7500) botones.p[jugador][3]=1; Else botones.p[jugador][3]=0; End
			If(get_joy_position(0,3)<-7500) botones.p[jugador][4]=1; Else botones.p[jugador][4]=0; End
			If(get_joy_button(0,1)) botones.p[jugador][5]=1; Else botones.p[jugador][5]=0; End
			If(get_joy_button(0,2)) botones.p[jugador][6]=1; Else botones.p[jugador][6]=0; End
		End
/*		If(p[jugador].control==3)  // joystick 2
			If(get_joy_position(1,0)<-10000) botones.p[jugador][0]=1; Else botones.p[jugador][0]=0; End
			If(get_joy_position(1,0)>10000) botones.p[jugador][1]=1; Else botones.p[jugador][1]=0; End
			If(get_joy_position(1,1)<-7500) botones.p[jugador][2]=1; Else botones.p[jugador][2]=0; End
			If(get_joy_position(1,1)>7500) botones.p[jugador][3]=1; Else botones.p[jugador][3]=0; End
			If(get_joy_button(1,0) OR get_joy_button(1,1)) botones.p[jugador][4]=1; Else botones.p[jugador][4]=0; End
			If(get_joy_button(1,2) OR get_joy_button(1,3)) botones.p[jugador][5]=1; Else botones.p[jugador][5]=0; End
		End
		If(p[jugador].control==4)  // joystick 3
			If(get_joy_position(2,0)<-10000) botones.p[jugador][0]=1; Else botones.p[jugador][0]=0; End
			If(get_joy_position(2,0)>10000) botones.p[jugador][1]=1; Else botones.p[jugador][1]=0; End
			If(get_joy_position(2,1)<-7500) botones.p[jugador][2]=1; Else botones.p[jugador][2]=0; End
			If(get_joy_position(2,1)>7500) botones.p[jugador][3]=1; Else botones.p[jugador][3]=0; End
			If(get_joy_button(2,0) OR get_joy_button(2,1)) botones.p[jugador][4]=1; Else botones.p[jugador][4]=0; End
			If(get_joy_button(2,2) OR get_joy_button(2,3)) botones.p[jugador][5]=1; Else botones.p[jugador][5]=0; End
		End*/
/*		If(p[jugador].control=>3)
			from i=0 to 7; 
				botones.p[jugador][i]=rand(0,1);
			end
		end*/
		frame;
	End
End

Process powerups(x,y,tipo);
Private
	id_colision;
Begin
	ctype=c_scroll;
   switch(tipo)
 	  	case 1: graph=load_png("saltodanya.png"); end 
	   	case 2: graph=load_png("escudo.png"); end
		case 3: graph=load_png("doblesalto.png"); end
		case 4: graph=load_png("grande.png"); end
		case 5: graph=load_png("velocidad.png"); end
   end
   ancho=graphic_info(file,graph,g_width)/2;
   alto=graphic_info(file,graph,g_height)/2;
   loop
		if(map_get_pixel(0,durezas,x,y+alto)!=suelo) y+=6; end
		while(map_get_pixel(0,durezas,x,y+alto-1)==suelo) y--; end
		if(y>alto_nivel) break; end
		if(id_colision=collision(type prota)) 
			if(id_colision.accion!="muerte")
				p[id_colision.jugador].puntos++;
				id_colision.powerup=tipo; 
				id_colision.tiempo_powerup=10*50; 
	//			while(size>0) 
	//				size=size-5;
	//				frame;				
	//			end 
	//			break; 
				tiempo_powerup=10*50;
				while(alpha>0 and id_colision.powerup==tipo)
					x=id_colision.x;
					y=id_colision.y;
					alpha=tiempo_powerup/2;
					tiempo_powerup--;
					z=1;
					frame;
				end
				break;
			end
		end
		frame;
   end	
End

Function carga_nivel(mapa);
PRIVATE
	pos_x;
	pos_y;
	tile;
	pers_x;
	pers_y;
BEGIN
	//ancho del gr�fico peque�ito
	ancho=GRAPHIC_INFO(0,mapa,G_WIDE);
	alto=GRAPHIC_INFO(0,mapa,G_HEIGHT);

	from i=0 to 9; tiles[i]=map_get_pixel(0,mapa,i,alto-3); end
	from i=1 to 9; enemigos[i]=map_get_pixel(0,mapa,i,alto-2); end

	
//	adornos[0]=map_get_pixel(0,mapa,0,alto_mapa-1);
	alto_nivel=(alto-3)*tilesize;
	ancho_nivel=ancho*tilesize;

	mapa_scroll=new_map(ancho*tilesize,(alto-3)*tilesize,8);
	//LO VISIBLE:
	repeat
		pos_x=x*tilesize;
		pos_y=y*tilesize;
		tile=map_get_pixel(0,mapa,x,y);
		if(tile==tiles[0]) MAP_PUT(fpg_tiles,mapa_scroll,1,pos_x+(tilesize/2),pos_y+(tilesize/2)); end
		from i=1 to 9; if(tile==enemigos[i]) enemigo(pos_x+(tilesize/2),pos_y+(tilesize/2),i); end end
		if(x<ancho)
			x++;
		else
			y++; x=0;
		end
	until(y=>alto-3)

	x=0; y=0;
	durezas=new_map(ancho*tilesize,(alto-3)*tilesize,8);
	suelo=map_get_pixel(fpg_tiles,501,0,0);
	//LO INVISIBLE (PERO TOCABLE)
	repeat
		pos_x=x*tilesize;
		pos_y=y*tilesize;
		tile=map_get_pixel(0,mapa,x,y);
		if(tile==tiles[0]) tile=1; else tile=0; end
		tile=tile+500;
		if(tile==500) tile=0; end
		if(tile!=0) MAP_PUT(fpg_tiles,durezas,tile,pos_x+(tilesize/2),pos_y+(tilesize/2)); end
		if(x<ancho)
			x++;
		else
			y++; x=0;
		end
	until(y=>alto-3)
END

Process sonido(string sonidaco);
Begin
	play_wav(load_wav("wav\"+sonidaco+".wav"),0);
End

Process marcadores();
Begin
	if(jugadores==2)
		write_int(fuente,ancho_pantalla/2,20,1,&p[1].puntos);
		write_int(fuente,ancho_pantalla/2,(alto_pantalla/2)+20,1,&p[2].puntos);
	end
	if(jugadores=>3)
		write_int(fuente,ancho_pantalla/4,20,1,&p[1].puntos);
		write_int(fuente,(ancho_pantalla/4)*3,20,1,&p[2].puntos);
		write_int(fuente,ancho_pantalla/4,(alto_pantalla/2)+20,1,&p[3].puntos);
		if(jugadores==4) write_int(fuente,(ancho_pantalla/4)*3,(alto_pantalla/2)+20,1,&p[4].puntos); end
	end
End