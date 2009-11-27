Const
	resolucion_x=1920;
	resolucion_y=1080;
	
	borde_arriba=65;
	borde_abajo=1015;
	borde_izquierda=160;
	borde_derecha=1760;
	
	area_juego_x=1600;
	area_juego_y=950;
Global	
	
	mapa_durezas; //mapa de durezas para las colisiones
	fondo; //grafico de fondo
	
	velocidad_bolas=115; //velocidad de las bolas (cuando menos, mayor velocidad)
	
	bolas; //número de bolas en pantalla

	ready; //pausa el juego si está a 0
	
	regiones; //para los disparos
	
	joysticks[4]; //aquí se almacenarán los joysticks funcionales
	
	dinamita;
	bola_pang;
	
	struct p[4]; //players, jugadores
		id; //guardamos el id aquí también, nunca está de más
		jugando; //si están jugando o no, esto lo dirá
		botones[8]; //controladores y joysticks
		control; //el número indica su controlador: 0, teclado, =>1 joystick
		fpg; //su fpg de su personaje
		disparos; //controlamos que no disparen más de dos veces
		vidas; //su número de vidas
		vidas_bonus; //vidas conseguidas por punttos
		puntos; //puntos conseguidos
		bonus; //puntos a sumar si destruye más bolas que los otros jugadores
		arma; //0: gancho, 1: doble gancho, 2: gancho enganchable, 3: metralleta
		item; //por usar, para saltos y cosas
		proteccion; //la protección clásica, aunque ahora podremos tener varias capas!
		fases_ganadas; //número de fases ganadas a los otros jugadores durante la partida
		bolas_destruidas; //bolas destruidas en el nivel
		items_recogidos; //items_recogidos en el nivel
	end
	
	fpg_general;
Local
	gravedad;
	inercia;
	estado;
	accion;
	tipo;
	ancho;
	alto;
	x_destino;
	y_destino;
	lado;
	i;
	jugador;
	primera_caida; //de las bolas, para la dinamita y la bola pang
Begin

	//full_screen=1;
	scale_resolution=12800720;
	set_mode(resolucion_x,resolucion_y,32,WAITVSYNC);
	set_fps(60,9);
	frame;

	fpg_general=load_fpg("pixpang.fpg");
	p[1].fpg=load_fpg("pix.fpg");
	
	mapa_durezas=new_map(1920,1080,32);
	
	drawing_map(0,mapa_durezas);
	//posiciones caretos
	if(p[1].jugando) grafico(p[1].fpg,1,resolucion_x/28,resolucion_y/12,-2,0); end
	if(p[2].jugando) grafico(p[2].fpg,1,resolucion_x-(resolucion_x/28),resolucion_y/12,-2,1); end
	if(p[3].jugando) grafico(p[3].fpg,1,resolucion_x/28,resolucion_y-(resolucion_y/12),-2,0); end
	if(p[4].jugando) grafico(p[4].fpg,1,resolucion_x-(resolucion_x/28),resolucion_y-(resolucion_y/12),-2,1); end
	
	//marcas limitadoras de marcadores
	drawing_color(rgb(128,128,128));
	draw_line(0,resolucion_y/2,borde_izquierda,resolucion_y/2);
	draw_line(borde_derecha,resolucion_y/2,resolucion_x,resolucion_y/2);

	//bordes del borde de la zona de juego
	draw_line(borde_izquierda,borde_arriba,borde_derecha,borde_arriba);
	draw_line(borde_izquierda,borde_abajo,borde_derecha,borde_abajo);
	//draw_line(borde_izquierda,borde_arriba,borde_izquierda,borde_abajo);
	//draw_line(borde_derecha,borde_arriba,borde_derecha,borde_abajo);
	draw_line(borde_izquierda,0,borde_izquierda,resolucion_y);
	draw_line(borde_derecha,0,borde_derecha,resolucion_y);

	//un fondo con lineas
	fondo=new_map(area_juego_x,area_juego_y,32);
	drawing_map(0,fondo);
	from y=0 to area_juego_y step 25;
		draw_line(0,y,area_juego_x,y);
	end
	from x=0 to area_juego_x step 25;
		draw_line(x,0,x,area_juego_y);
	end
	put_screen(0,fondo);
	
	grafico(0,load_png("bordes.png"),resolucion_x/2,resolucion_y/2,-1,0);
	grafico(0,mapa_durezas,resolucion_x/2,resolucion_y/2,1,0);	

	//PRINCIPAL
	
	personaje(1);
	pinta();
	raton();
	ready=1;
	x=1;
	bola(1000,400,10,100,0,0);
	loop 
		if(bolas==0) bola(1000,400,x++,100,0,0); end
		frame; 
	end
End

Process grafico(file,graph,x,y,z,flags);
Begin
	prepara_proceso_grafico();
	loop frame; end
End

Process personaje(jugador);
Private
	animacion; //0: quieto, 1:andar, 2:disparar, 3:enescaleras
	toca_suelo;
	disparando;
Begin
	file=p[jugador].fpg;
	graph=11;
	prepara_proceso_grafico();
	controlador();
	x=borde_izquierda+(area_juego_x/2);
	y=borde_abajo-alto;
	p[jugador].id=id;
	loop
		while(ready==0) frame; end
		if(!(p[jugador].botones[0] and p[jugador].botones[1]) and (p[jugador].botones[0] or p[jugador].botones[1]))
			if(p[jugador].botones[0]) x_destino-=8; else
				if(p[jugador].botones[1]) x_destino+=8; end 
			end
		else
			animacion=0;
		end
		if(map_get_pixel(0,mapa_durezas,x,y+alto)!=0) 
			gravedad=0;
		else
			gravedad++; 
		end
		if(!p[jugador].botones[4]) disparando=0; end
		if(p[jugador].botones[4] and disparando==0 AND 
			(((p[jugador].arma==0 OR p[jugador].arma==2) and p[jugador].disparos<1) OR
			(p[jugador].arma==1 and p[jugador].disparos<2) OR
			p[jugador].arma==3)) //Comprobamos que se pueda disparar teniendo en cuenta la arma, y si ha soltado el gatillo antes de volver a darle
			disparo(); 
			disparando=1; 
		end
		y_destino=gravedad;
		while(x_destino!=0)
			if(x_destino>0)
				from i=y-alto to y+alto-51;
					if(map_get_pixel(0,mapa_durezas,x+ancho,i)!=0) toca_suelo=1; end
				end
				if(toca_suelo) 
					break; 
				else
					x++;
					x_destino--;
				end
			else
				from i=y-alto to y+alto-51;
					if(map_get_pixel(0,mapa_durezas,x-ancho,i)!=0) toca_suelo=1; end
				end
				if(toca_suelo) 
					break; 
				else
					x--;
					x_destino++;
				end
			end
		end
		toca_suelo=0;
		from i=y+alto-51 to y+alto;
			if(map_get_pixel(0,mapa_durezas,x-(ancho/2),i)!=0 or
			map_get_pixel(0,mapa_durezas,x,i)!=0 or
			map_get_pixel(0,mapa_durezas,x+(ancho/2),i)!=0)
				y=i-alto;
			end
		end
		while(y_destino!=0)
			if(y_destino>0)
				if(map_get_pixel(0,mapa_durezas,x-(ancho/2),y+alto)!=0 or
				map_get_pixel(0,mapa_durezas,x,y+alto)!=0 or
				map_get_pixel(0,mapa_durezas,x+(ancho/2),y+alto)!=0) 
					break; 
				else
					y++;
					y_destino--;
				end
			else
				if(map_get_pixel(0,mapa_durezas,x,y-alto)!=0) 
					break; 
				else
					y--;
					y_destino++;
				end
			end
		end
		x_destino=0;
		y_destino=0;
		frame;
	end
End

/*-----------------------------------------------
  === TIPOS DE BOLAS ===
* Bolas estándar, tipo 1
* Bolas con mayor rebote, tipo 2
* Bolas sin gravedad (rombos?) que rebotan cambiando su dirección en 90º, tipo 3
-* Bolas con gravedad contraria (botan en el techo!), tipo 4
-* Bola estrella: lo destruye todo, tipo 5, no decrece!
-* Bola reloj: paraliza las bolas durante 7 segundos, tipo 6, no decrece!
-* Bolas perseguidoras: cuando botan, se dirigen hacia ti, tipo 7
-* Bolas sin movimiento lateral: solo botan, tipo 8
* Bolas pesadas: rebotan cada vez menos, tipo 9
* Bolas suelo: van por suelos y paredes, tipo 10
-* Bolas bomba: tienen una onda expansiva que destruye las bolas a su alrededor, tipo 11, no decrece!
-* Bolas mutantes: recorren todos los anteriores tipos, tipo 20*/
//----------------------------------------------------------------
Process bola(x,y,tipo,tamanyo,lado,regalo);
Private
	rebote;
	id_jugador;
	invencibilidad;
	tipo_mutante;
	lado_y; //para la bola rombo
	no_toca_suelo; //para la bola suelo
Begin
	bolas++;
/*	switch(tipo)
		case 1: graph=load_png("705.png"); end
		case 2: graph=load_png("705.png"); end
		case 3: graph=load_png("705.png"); end
		case 4: graph=load_png("705.png"); end
		case 5: graph=load_png("705.png"); end
		case 6: graph=load_png("705.png"); end
		case 7: graph=load_png("705.png"); end
		case 8: graph=load_png("705.png"); end
		case 9: graph=load_png("705.png"); end
		case 10: graph=load_png("705.png"); end
		case 20: graph=load_png("705.png"); end
	end*/
	file=fpg_general;
	graph=tipo+10;
	gravedad=-10;
	ancho=(graphic_info(file,graph,g_width)/2)*tamanyo/100;
	alto=(graphic_info(file,graph,g_height)/2)*tamanyo/100;
	size=tamanyo;
	loop
		while(ready==0) frame; end

		x_destino += lado ? 9 : -9; //WOW xD
		
		if((tipo==3 or gravedad>0) and primera_caida==0) primera_caida=1; end //retraso en la muerte de las recien nacidas bola con dinamita o bola pang
		
		if(tipo==3) //movimiento rombo
			rebote=0;
			if(lado_y) //para abajo
				gravedad=8;
				if(map_get_pixel(0,mapa_durezas,x-(ancho/2),y+(alto/2))!=0 OR
				map_get_pixel(0,mapa_durezas,x,y+alto)!=0 OR
				map_get_pixel(0,mapa_durezas,x+(ancho/2),y+(alto/2))!=0) //toca el suelo
					lado_y=0;
				end
			else //arriba
				gravedad=-8;
				if(map_get_pixel(0,mapa_durezas,x-(ancho/2),y-(alto/2))!=0 OR
				map_get_pixel(0,mapa_durezas,x,y-alto)!=0 OR
				map_get_pixel(0,mapa_durezas,x+(ancho/2),y-(alto/2))!=0) //toca el suelo
					lado_y=1;
				end
			end
		end
			
		//GESTION DE GRAVEDAD PARA TODAS LAS BOLAS QUE NO SEAN ROMBOS (!TIPO3 o TIPO10 Y NOTOCASUELO)
		if(tipo!=3 AND
		map_get_pixel(0,mapa_durezas,x-(ancho/2),y+(alto/2))!=0 OR
		map_get_pixel(0,mapa_durezas,x,y+alto)!=0 OR
		map_get_pixel(0,mapa_durezas,x+(ancho/2),y+(alto/2))!=0)  //toca el suelo
			if(y==borde_abajo-alto) //el rebote (con la variable) sólo se produce en las plataformas
				if(tipo==1) //bola mayor rebote
					gravedad=-30-(tamanyo/8); 
				elseif(tipo==9) //bola perdida rebote
					gravedad=-rebote*0.9; 
				else //el resto rebotan normal
					gravedad=-20-(tamanyo/6); 
				end
			else 
				if(tipo==9)//bola perdida rebote
					gravedad=-rebote*0.9; //rebotamos dependiendo de desde la altura que caemos
				else
					gravedad=-rebote; //rebotamos dependiendo de desde la altura que caemos
				end
			end 
			rebote=0;
		else
			if(map_get_pixel(0,mapa_durezas,x,y-alto)!=0) //toca el techo
				gravedad=-gravedad;
				rebote=gravedad;
			else
				gravedad++; 
				if(gravedad>0) rebote++; end
			end
		end
		//------------------------
		
		x_destino=(float)x_destino*100/velocidad_bolas;
		y_destino=(gravedad*100/velocidad_bolas);
		
		while(x_destino!=0)
			if(x_destino>0)
				if(map_get_pixel(0,mapa_durezas,x+(ancho/2),y-(alto/2))!=0 or
					map_get_pixel(0,mapa_durezas,x+ancho,y)!=0 or 
					map_get_pixel(0,mapa_durezas,x+(ancho/2),y+(alto/2))!=0) //colision derecha 
					lado=0;
					break; 
				else
					x++;
					x_destino--;
				end
			else
				if(map_get_pixel(0,mapa_durezas,x-(ancho/2),y-(alto/2))!=0 or
					map_get_pixel(0,mapa_durezas,x-ancho,y)!=0 or 
					map_get_pixel(0,mapa_durezas,x-(ancho/2),y+(alto/2))!=0) //colision derecha
					lado=1;
					break; 
				else
					x--;
					x_destino++;
				end
			end
		end

		while(y_destino!=0)
			if(y_destino>0)
				if(map_get_pixel(0,mapa_durezas,x-(ancho/2),y+(alto/2))!=0 or
				  map_get_pixel(0,mapa_durezas,x,y+alto)!=0 or
				  map_get_pixel(0,mapa_durezas,x+(ancho/2),y+(alto/2))!=0) //toca el suelo
					break; 
				else
					y++;
					y_destino--;
				end
			else
				if(map_get_pixel(0,mapa_durezas,x-(ancho/2),y-(alto/2))!=0 or
				  map_get_pixel(0,mapa_durezas,x,y-alto)!=0 or
				  map_get_pixel(0,mapa_durezas,x+(ancho/2),y-(alto/2))!=0) //toca el suelo
					break; 
				else
					y--;
					y_destino++;
				end
			end
		end
		if(id_jugador=collision(type disparo)) if(id_jugador.accion!=-1) id_jugador.accion=-1; break; end end
		if(((dinamita and tamanyo>20) or bola_pang) and primera_caida) break; end
		if(invencibilidad>0) alpha=128; invencibilidad--; else alpha=255; end //cuando perdemos la protección tenemos 3 segundos de invencibilidad
		frame;
	end
	if(tamanyo!=20) 
		bola(x,y,tipo,tamanyo-20,0,regalo);
		bola(x,y,tipo,tamanyo-20,1,regalo);
	end
	if(id_jugador!=0)
		p[id_jugador.jugador].bolas_destruidas++;
		p[id_jugador.jugador].puntos+=500;
	end
	bolas--;
End

Function prepara_proceso_grafico();
Begin
	father.ancho=graphic_info(father.file,father.graph,g_width)/2;
	father.alto=graphic_info(father.file,father.graph,g_height)/2;
End

Process pinta();
Private
	x1;y1;
Begin
	graph=new_map(5,5,32);
	drawing_map(0,graph);
	draw_box(0,0,5,5);
	drawing_map(0,mapa_durezas);
	x=borde_izquierda;
	y=borde_arriba;
	loop
		if(key(_a) and x>borde_izquierda) x-=25; end
		if(key(_d) and x<borde_derecha) x+=25; end
		if(key(_w) and y>borde_arriba) y-=25; end
		if(key(_s) and y<borde_abajo) y+=25; end
		while(key(_a) or key(_s) or key(_d) or key(_w)) frame; end
		if(key(_enter)) 
			if(x1==0)
				x1=x; y1=y;
				while(key(_enter)) frame; end
			else
				draw_box(x1,y1,x,y);
				x1=0; y1=0;
				while(key(_enter)) frame; end
			end
		end
		frame; 
	end
End

Process disparo();
Private
	arma_temp;
Begin
	if(!exists(father)) return; end
	regiones++;
	jugador=father.jugador;
	arma_temp=p[jugador].arma;
	file=father.file;
	graph=101+arma_temp;
	prepara_proceso_grafico();
	set_center(file,graph,ancho,0);
	p[jugador].disparos++;
	x=father.x;
	y=father.y;
	region=regiones;
	define_region(region,x-ancho,borde_arriba,x+ancho,y+father.alto);	
	loop 
		y_destino=-10;
		while(y_destino!=0)
			if(map_get_pixel(0,mapa_durezas,x,y)!=0) 
				break;
			else
				y--;
				y_destino++;
			end
		end
		if(y_destino!=0 or accion==-1) break; end //tocó techo o tocamos una bola
		frame; 
	end
	p[jugador].disparos--;
	regiones--;
End

Process raton();
Begin
	graph=new_map(5,5,32);
	drawing_map(0,graph);
	draw_box(0,0,5,5);
	drawing_map(0,mapa_durezas);
	loop
		x=mouse.x;
		y=mouse.y;
		if(mouse.left) bola(x,y,rand(1,11),rand(20,100),0,0); while(mouse.left) frame; end end
		frame;
	end
End

Process controlador();
Private
	gamepads;
Begin
	from i=0 to 5;
		p[jugador].botones[i]=0;
	end
	jugador=father.jugador;
	Loop
		if(!exists(father)) return; end
		if(p[jugador].control==-1) return; end
		While(ready==0) Frame; End
		If(p[jugador].control==0)  // teclado
			If(key(_left)) p[jugador].botones[0]=1; Else p[jugador].botones[0]=0; End
			If(key(_right)) p[jugador].botones[1]=1; Else p[jugador].botones[1]=0; End
			If(key(_up)) p[jugador].botones[2]=1; Else p[jugador].botones[2]=0; End
			If(key(_down)) p[jugador].botones[3]=1; Else p[jugador].botones[3]=0; End
			If(key(_a)) p[jugador].botones[4]=1; Else p[jugador].botones[4]=0; End
			If(key(_s)) p[jugador].botones[5]=1; Else p[jugador].botones[5]=0; End
			If(key(_d)) p[jugador].botones[6]=1; Else p[jugador].botones[6]=0; End
		End
		If(p[jugador].control>0)  // joysticks
			If(get_joy_position(joysticks[p[jugador].control-1],0)<-10000) p[jugador].botones[0]=1; Else p[jugador].botones[0]=0; End
			If(get_joy_position(joysticks[p[jugador].control-1],0)>10000) p[jugador].botones[1]=1; Else p[jugador].botones[1]=0; End
			If(get_joy_position(joysticks[p[jugador].control-1],1)<-7500) p[jugador].botones[2]=1; Else p[jugador].botones[2]=0; End
			If(get_joy_position(joysticks[p[jugador].control-1],1)>7500) p[jugador].botones[3]=1; Else p[jugador].botones[3]=0; End
			If(get_joy_button(joysticks[p[jugador].control-1],0)) p[jugador].botones[4]=1; Else p[jugador].botones[4]=0; End
			If(get_joy_button(joysticks[p[jugador].control-1],1)) p[jugador].botones[5]=1; Else p[jugador].botones[5]=0; End
			If(get_joy_button(joysticks[p[jugador].control-1],2)) p[jugador].botones[6]=1; Else p[jugador].botones[6]=0; End
		End
		Frame;
	End
End