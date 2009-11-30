Const
	resolucion_x=1920;
	resolucion_y=1080;
	
	area_juego_x=1560;
	area_juego_y=960;
	
	tamanyo_bloque_min=30;
	bits=16;
Global
	borde_arriba;
	borde_abajo;
	borde_izquierda;
	borde_derecha;
	
	struct color;
		negro;
		blanco;
		verde;
		rojo;
		azul;
		amarillo;
		gris;
	end

	mapa_durezas; //mapa de durezas para las colisiones
	mini_mapa_durezas; //fichero de bloques
	fondo; //grafico de fondo
	
	velocidad_bolas=200; //velocidad de las bolas (cuando menos, mayor velocidad)
	
	bolas; //número de bolas en pantalla

	ready; //pausa el juego si está a 0
	
	region_ocupada[30]; //para los disparos
	
	joysticks[4]; //aquí se almacenarán los joysticks funcionales
	
	dinamita;
	bola_pang;
	reloj; //paralizamos las bolas. aquí meteremos el tiempo en segs*60
	ancla;
	
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
	fnt;
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
	borde_arriba=(resolucion_y/2)-(area_juego_y/2);
	borde_abajo=(resolucion_y/2)+(area_juego_y/2);
	borde_izquierda=(resolucion_x/2)-(area_juego_x/2);
	borde_derecha=(resolucion_x/2)+(area_juego_x/2);

	full_screen=0;
	scale_resolution=10240576;
	set_mode(resolucion_x,resolucion_y,bits,WAITVSYNC);
	set_fps(60,9);
	frame;
	
	preparar_controladores();
	
	color.negro=rgb(0,0,0);
	color.blanco=rgb(255,255,255);
	color.verde=rgb(0,255,0);
	color.rojo=rgb(255,0,0);
	color.azul=rgb(0,0,255);
	color.amarillo=rgb(255,255,0);
	color.gris=rgb(128,128,128);
	
	fpg_general=load_fpg("pixpang.fpg");
	fnt=load_fnt("fnt.fnt");
	
	p[1].fpg=load_fpg("pix.fpg");
	p[2].fpg=load_fpg("pixmorao.fpg");
	
	
	mapa_durezas=new_map(1920,1080,bits);
	drawing_map(0,mapa_durezas);
	drawing_color(color.negro);
	draw_box(0,0,resolucion_x,resolucion_y);
	
	if(fexists("durezastemp.png")) 
		mini_mapa_durezas=load_png("durezastemp.png");
		crea_mapa_durezas();
	end
		
	//bordes de la zona de juego
	drawing_color(color.blanco);
	draw_line(borde_izquierda,borde_arriba,borde_derecha,borde_arriba);
	draw_line(borde_izquierda,borde_abajo,borde_derecha,borde_abajo);
	draw_line(borde_izquierda,borde_arriba,borde_izquierda,borde_abajo);
	draw_line(borde_derecha,borde_arriba,borde_derecha,borde_abajo);

	//posiciones caretos
	if(p[1].jugando) grafico(p[1].fpg,1,resolucion_x/28,resolucion_y/12,-2,0); end
	if(p[2].jugando) grafico(p[2].fpg,1,resolucion_x-(resolucion_x/28),resolucion_y/12,-2,1); end
	if(p[3].jugando) grafico(p[3].fpg,1,resolucion_x/28,resolucion_y-(resolucion_y/12),-2,0); end
	if(p[4].jugando) grafico(p[4].fpg,1,resolucion_x-(resolucion_x/28),resolucion_y-(resolucion_y/12),-2,1); end
	
	dibuja_fondo();
	
	//grafico(0,load_png("bordes.png"),resolucion_x/2,resolucion_y/2,-1,0);
	//grafico(0,fondo,resolucion_x/2,resolucion_y/2,1,0);	
	//grafico(0,mapa_durezas,resolucion_x/2,resolucion_y/2,3,0);	

	//PRINCIPAL
	
	from x=1 to 4; personaje(x); end
	pinta();
	//raton();
	ready=1;
	x=1;
	//bola(1000,borde_arriba+150,9,120,0,0);
	loop 
		if(key(_F10)) save_png(0,mini_mapa_durezas,"durezastemp.png"); while(key(_F10)) frame; end end
		if(key(_F1)) personaje(1);personaje(2); while(key(_F1)) frame; end end
		if(key(_F2)) if(ready) ready=0; else ready=1; end while(key(_F2)) frame; end end
		if(key(_F3)) item_reloj(5); while(key(_F3)) frame; end end
		if(key(_F4)) 
			if(scale_resolution==10240576) 
				scale_resolution=12800720;
			elseif(scale_resolution==12800720)
				scale_resolution=0;
			elseif(scale_resolution==0)
				scale_resolution=10240576;
			end
			set_mode(resolucion_x,resolucion_y,bits,WAITVSYNC);
			while(key(_F4)) frame; end
		end
		if(key(_F5)) if(full_screen==1) full_screen=0; else full_screen=1; end set_mode(resolucion_x,resolucion_y,bits,WAITVSYNC); while(key(_F5)) frame; end end

		if(bolas==0) bola(1000,borde_arriba+150,x++,120,0,0); end
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
	invencibilidad; //para cuando pierdes la protección
Begin
	if(p[jugador].jugando) return; end // POR QUÉ? xD
	p[jugador].jugando=1;
	file=p[jugador].fpg;
	graph=11;
	prepara_proceso_grafico();
	controlador();
	//x=borde_izquierda+(area_juego_x/2);
	x=borde_izquierda+(area_juego_x/2)-(tamanyo_bloque_min/2);
	y=borde_abajo-alto;
	p[jugador].id=id;
	personaje_colisionador();
	loop
		while(ready==0) accion=0; frame; end
		if(!(p[jugador].botones[0] and p[jugador].botones[1]) and (p[jugador].botones[0] or p[jugador].botones[1]))
			if(p[jugador].botones[0]) x_destino-=tamanyo_bloque_min/3; else
				if(p[jugador].botones[1]) x_destino+=tamanyo_bloque_min/3; end 
			end
		else
			animacion=0;
		end
		if(map_get_pixel(0,mapa_durezas,x,y+alto)!=color.negro) 
			gravedad=0;
		else
			gravedad++; 
		end
		if(!p[jugador].botones[4]) disparando=0; end
		if(p[jugador].botones[4] and disparando==0 AND 
			(((p[jugador].arma==0 OR p[jugador].arma==2) and p[jugador].disparos<1) OR
			(p[jugador].arma==1 and p[jugador].disparos<2) OR
			p[jugador].arma==3)) //Comprobamos que se pueda disparar teniendo en cuenta la arma, y si ha soltado el gatillo antes de volver a darle
			disparo(p[jugador].arma); 
			disparando=1; 
		end
		y_destino=gravedad;
		while(x_destino!=0)
			if(x_destino>0)
				from i=y-alto to y+alto-51;
					if(map_get_pixel(0,mapa_durezas,x+ancho,i)!=color.negro) toca_suelo=1; end
				end
				if(toca_suelo) 
					break; 
				else
					x++;
					x_destino--;
				end
			else
				from i=y-alto to y+alto-51;
					if(map_get_pixel(0,mapa_durezas,x-ancho,i)!=color.negro) toca_suelo=1; end
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
			if(map_get_pixel(0,mapa_durezas,x-(ancho/2),i)!=color.negro or
			map_get_pixel(0,mapa_durezas,x,i)!=color.negro or
			map_get_pixel(0,mapa_durezas,x+(ancho/2),i)!=color.negro)
				y=i-alto;
			end
		end
		while(y_destino!=0)
			if(y_destino>0)
				if(map_get_pixel(0,mapa_durezas,x-(ancho/2),y+alto)!=color.negro or
				map_get_pixel(0,mapa_durezas,x,y+alto)!=color.negro or
				map_get_pixel(0,mapa_durezas,x+(ancho/2),y+alto)!=color.negro) 
					break; 
				else
					y++;
					y_destino--;
				end
			else
				if(map_get_pixel(0,mapa_durezas,x,y-alto)!=color.negro) 
					break; 
				else
					y--;
					y_destino++;
				end
			end
		end
		if(invencibilidad>0) alpha=128; invencibilidad--; else alpha=255; end //cuando perdemos la protección tenemos 3 segundos de invencibilidad
		if(accion==-1) //algo nos ha atacado
			if(invencibilidad==0)
				if(p[jugador].proteccion==0) 
					break; 
				else
					p[jugador].proteccion--;
					invencibilidad=3*60;
				end			
			end
			accion=0;
		end
		
		x_destino=0;
		y_destino=0;
		frame;
	end
	
	//muerteeeeeee
	ready=0;
	gravedad=rand(-30,-40);
	lado=rand(0,1);
	x_destino=rand(16,40);
	while(y<resolucion_y)
		y+=gravedad;
		gravedad++;
		if(x>borde_derecha) lado=0; end
		if(x<borde_izquierda) lado=1; end
		if(lado==1) x+=x_destino; else x-=x_destino; end
		frame;
	end
	
	p[jugador].jugando=0;
	p[jugador].id=0;
	p[jugador].vidas--;
	p[jugador].bonus=0;
	from i=1 to 4; if(p[i].jugando==1) item_reloj(3); break; end end
	ready=1;
End

Process personaje_colisionador();
Private
	id_collision;
Begin
	graph=401;
	alpha=0;
	while(exists(father))
		x=father.x;
		y=father.y;
		if((id_collision=collision(type bola)) and reloj==0) 
			if(p[father.jugador].proteccion>0) id_collision.accion=-1; end
			father.accion=-1; 
		end
		while(!ready) frame; end
		frame;
	end
End

/*-----------------------------------------------
  === TIPOS DE BOLAS ===
* Bolas estándar, tipo 1
* Bolas con mayor rebote, tipo 2
* Bolas sin gravedad (rombos?) que rebotan cambiando su dirección en 90º, tipo 3
* Bolas con gravedad contraria (botan en el techo!), tipo 4
* Bola estrella: lo destruye todo, tipo 5, no decrece!
* Bola reloj: paraliza las bolas durante 7 segundos, tipo 6, no decrece!
* Bolas perseguidoras: cuando botan, se dirigen hacia el personaje más cercano, tipo 7
* Bolas sin movimiento lateral: solo botan, tipo 8
* Bolas pesadas: rebotan cada vez menos, tipo 9
* Bolas bomba: tienen una onda expansiva que destruye las bolas a su alrededor, tipo 10, no decrece!
* Bolas mutantes: recorren todos los anteriores tipos, tipo 20*/
//----------------------------------------------------------------
Process bola(x,y,tipo,tamanyo,lado,regalo);
Private
	rebote;
	id_jugador;
	tipo_mutante;
	lado_y; //para la bola rombo
	distancias[4]; //para los cálculos de la bola perseguidora
	id_perseguir; // id a perseguir
Begin
	bolas++;
	primera_caida=-20;
	file=fpg_general;
	if(tipo==20) tipo_mutante=1; tipo=1; end
	graph=tipo+10;
	if(tipo==4) // bola gravedad negativa
		gravedad=10;	
	else
		gravedad=-10;
	end
	
	ancho=(graphic_info(file,graph,g_width)/2)*tamanyo/100;
	alto=(graphic_info(file,graph,g_height)/2)*tamanyo/100;
	size=tamanyo;
	loop
		while(ready==0) frame; end
		while(reloj>0) //cuando hay un item reloj que paraliza las bolas cerca, no nos movemos
			if((tipo==3 or gravedad>0) and primera_caida<1) primera_caida++; end //retraso en la muerte de las recien nacidas bola con dinamita o bola pang
			if(id_jugador=collision(type disparo)) if(id_jugador.accion!=-1) id_jugador.accion=-1; accion=-1; end end //salimos del while y pasamos una variable para...
			if((((dinamita and tamanyo>20) or bola_pang) and primera_caida) or collision(type bomba)) accion=-1; end
			if(accion==-1) break; end
			frame;
		end
		if(accion==-1) break; end //...luego salir del loop

		if(gravedad>50) gravedad=50; end
		if(gravedad<-50) gravedad=-50; end
		
		if(tipo_mutante) graph=tipo+10; end
		if(tipo!=8) //bola sin desplazamiento lateral
			x_destino += lado ? 9 : -9; //WOW xD. Pd: 1 derecha, 0 izquierda
		end
		if((tipo==3 or gravedad>0) and primera_caida<1) primera_caida++; end //retraso en la muerte de las recien nacidas bola con dinamita o bola pang
			
		if(tipo==3) //movimiento rombo
			rebote=0;
			if(lado_y) //para abajo
				gravedad=8;
				if(map_get_pixel(0,mapa_durezas,x-(ancho/2),y+(alto/2))!=color.negro OR
				map_get_pixel(0,mapa_durezas,x,y+alto)!=color.negro OR
				map_get_pixel(0,mapa_durezas,x+(ancho/2),y+(alto/2))!=color.negro) //toca el suelo
					lado_y=0;
				end
			else //arriba
				gravedad=-8;
				if(map_get_pixel(0,mapa_durezas,x-(ancho/2),y-(alto/2))!=color.negro OR
				map_get_pixel(0,mapa_durezas,x,y-alto)!=color.negro OR
				map_get_pixel(0,mapa_durezas,x+(ancho/2),y-(alto/2))!=color.negro) //toca el suelo
					lado_y=1;
				end
			end
		end
			
		//GESTION DE GRAVEDAD PARA TODAS LAS BOLAS QUE NO SEAN ROMBOS (!TIPO3 o TIPO10 Y NOTOCASUELO)
		if(tipo!=3 AND
		map_get_pixel(0,mapa_durezas,x-(ancho/2),y+(alto/2))!=color.negro OR
		map_get_pixel(0,mapa_durezas,x,y+alto)!=color.negro OR
		map_get_pixel(0,mapa_durezas,x+(ancho/2),y+(alto/2))!=color.negro)  //toca el suelo
			if(tipo==7) //bola perseguidora
				id_perseguir=0;
				from i=1 to 4;
					distancias[i]=0;
					if(p[i].jugando and p[i].id!=0 and exists(p[i].id))
						distancias[i]=get_dist(p[i].id);
					end
				end
				if(distancias[1]!=0 and 
				(distancias[1]=<distancias[2] or distancias[2]==0) and
				(distancias[1]=<distancias[3] or distancias[3]==0) and
				(distancias[1]=<distancias[4] or distancias[4]==0)) id_perseguir=1; end
				if(distancias[2]!=0 and 
				(distancias[2]=<distancias[1] or distancias[1]==0) and
				(distancias[2]=<distancias[3] or distancias[3]==0) and
				(distancias[2]=<distancias[4] or distancias[4]==0)) id_perseguir=2; end
				if(distancias[3]!=0 and 
				(distancias[3]=<distancias[1] or distancias[1]==0) and
				(distancias[3]=<distancias[2] or distancias[2]==0) and
				(distancias[3]=<distancias[4] or distancias[4]==0)) id_perseguir=3; end
				if(distancias[4]!=0 and 
				(distancias[4]=<distancias[1] or distancias[1]==0) and
				(distancias[4]=<distancias[2] or distancias[2]==0) and
				(distancias[4]=<distancias[3] or distancias[3]==0)) id_perseguir=4; end
				
				if(id_perseguir!=0) if(p[id_perseguir].id.x<x) lado=0; else lado=1; end end
			end //fin bola perseguidora!

			if(tipo==4)
				gravedad=-gravedad;
			else
				if(tipo_mutante) if(tipo<10) tipo++; else tipo=1; end end
				if(y==borde_abajo-alto) //el rebote (con la variable) sólo se produce en las plataformas
					if(tipo==2) //bola mayor rebote
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
				if(tipo!=4) rebote=0; end //todos pierden el rebote al tocar el suelo salvo la bola con gravedad negativa!
			end
		else
			if(map_get_pixel(0,mapa_durezas,x-(ancho/2),y-(alto/2))!=color.negro OR
			map_get_pixel(0,mapa_durezas,x,y-alto)!=color.negro OR
			map_get_pixel(0,mapa_durezas,x+(ancho/2),y-(alto/2))!=color.negro)  //toca el techo
				if(tipo==4) //bola con gravedad negativa!
					if(tipo_mutante) if(tipo<10) tipo++; else tipo=1; end end
					if(y==borde_arriba+alto)
						gravedad=45-(tamanyo/15);
					else
						gravedad=-rebote;
					end
					rebote=0;
				else
					gravedad=-gravedad;
					rebote=gravedad;
				end
			else
				if(tipo==4) //bola de gravedad al revés!
					gravedad--;
					if(gravedad<0) rebote--; end
				else
					gravedad++;
					if(gravedad>0) rebote++; end
				end
			end
		end
		//------------------------
		
		x_destino=x_destino;
		y_destino=gravedad;
		
		
		while(x_destino!=0)
			if(x_destino>0)
				if(map_get_pixel(0,mapa_durezas,x+(ancho/2),y-(alto/2))!=color.negro or
					map_get_pixel(0,mapa_durezas,x+ancho,y)!=color.negro or 
					map_get_pixel(0,mapa_durezas,x+(ancho/2),y+(alto/2))!=color.negro) //colision derecha 
					lado=0;
					break; 
				else
					x++;
					x_destino--;
				end
			else
				if(map_get_pixel(0,mapa_durezas,x-(ancho/2),y-(alto/2))!=color.negro or
					map_get_pixel(0,mapa_durezas,x-ancho,y)!=color.negro or 
					map_get_pixel(0,mapa_durezas,x-(ancho/2),y+(alto/2))!=color.negro) //colision derecha
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
				if(map_get_pixel(0,mapa_durezas,x-(ancho/2),y+(alto/2))!=color.negro or
				  map_get_pixel(0,mapa_durezas,x,y+alto)!=color.negro or
				  map_get_pixel(0,mapa_durezas,x+(ancho/2),y+(alto/2))!=color.negro) //toca el suelo
					break; 
				else
					y++;
					y_destino--;
				end
			else
				if(map_get_pixel(0,mapa_durezas,x-(ancho/2),y-(alto/2))!=color.negro or
				  map_get_pixel(0,mapa_durezas,x,y-alto)!=color.negro or
				  map_get_pixel(0,mapa_durezas,x+(ancho/2),y-(alto/2))!=color.negro) //toca el suelo
					break; 
				else
					y--;
					y_destino++;
				end
			end
		end
		
		if(id_jugador=collision(type disparo)) if(id_jugador.accion!=-1) id_jugador.accion=-1; break; end end
		if((((dinamita and tamanyo>20) or bola_pang) and primera_caida) or collision(type bomba)) break; end
		frame(velocidad_bolas);
	end
	
	if(tipo==5) //bola pang
		explotalo(x,y,z,size,file,graph,60);
		graph=0;
		bola_pang=1;
		while(bolas>1) frame; end
		bola_pang=0;
		//from i=0 to 3*60; frame; end
		return;
	end
	
	if(tipo==6) //bola reloj
		item_reloj(7);
	end
	if(tipo==10) //bola bomba
		bomba(x-(ancho*2),y,tamanyo);
		bomba(x+(ancho*2),y,tamanyo);
	end

	if(tamanyo>20 and tipo!=5 and tipo!=6 and tipo!=10) 
		if(tipo_mutante)
			bola(x-(ancho/2),y,20,tamanyo-25,0,regalo);
			bola(x+(ancho/2),y,20,tamanyo-25,1,regalo);
		else
			bola(x-(ancho/2),y,tipo,tamanyo-25,0,regalo);
			bola(x+(ancho/2),y,tipo,tamanyo-25,1,regalo);
		end
	end
	
	if(id_jugador!=0)
		if(exists(id_jugador))
			p[id_jugador.jugador].bolas_destruidas++;
			p[id_jugador.jugador].puntos+=100*tamanyo;
		end
	end

	//animacion de explosion
	explotalo(x,y,z,size,file,graph,60);
	
	//prueba
	item_drop(x,y,rand(1,23));
	//item_drop(x,y,regalo);
	
	bolas--;
End

Process bomba(x,y,size);
Begin
	graph=31;
	while(alpha>0)
		alpha-=5;
		frame;
	end
End

Function prepara_proceso_grafico();
Begin
	father.ancho=graphic_info(father.file,father.graph,g_width)/2;
	father.alto=graphic_info(father.file,father.graph,g_height)/2;
End

Process pinta();
Private
	x1;
	y1;
	mapa_temporal;
	id_grafico;
Begin
	if(mini_mapa_durezas==0) mini_mapa_durezas=new_map(area_juego_x/tamanyo_bloque_min,area_juego_y/tamanyo_bloque_min,bits); end
	graph=new_map(10,10,bits);
	drawing_color(color.verde);
	drawing_map(0,graph);
	draw_box(0,0,10,10);
	drawing_map(0,mapa_durezas);
	x=borde_izquierda;
	y=borde_arriba;
	mapa_temporal=new_map(1920,1080,bits);
	grafico(0,mapa_temporal,resolucion_x/2,resolucion_y/2,-3,0);
	loop
		x=mouse.x*2/tamanyo_bloque_min*tamanyo_bloque_min;
		y=mouse.y*2/tamanyo_bloque_min*tamanyo_bloque_min;
		
		if(x<borde_izquierda) x=borde_izquierda; end
		if(x>borde_derecha) x=borde_derecha; end
		if(y>borde_abajo) y=borde_abajo; end
		if(y<borde_arriba) y=borde_arriba; end
		
		if(x1!=0) //para que se vea el cuadro rojo que vamos a colocar
			drawing_color(color.rojo);
			draw_rect(x1,y1,x,y);
		end
		if(mouse.left or mouse.right)
			if(x1==0)
				x1=x; y1=y;
				while(mouse.left or mouse.right) frame; end
			elseif(y1!=y and x1!=x) //no se pueden hacer líneas
				drawing_map(0,mapa_durezas);
				if(mouse.left) //metemos la dureza
					drawing_color(color.verde);
				else //quitamos la dureza
					drawing_color(color.negro);
				end
				draw_box(x1,y1,x,y);
				
				drawing_map(0,mini_mapa_durezas);
				draw_box((x1-borde_izquierda)/tamanyo_bloque_min,(y1-borde_arriba)/tamanyo_bloque_min,((x-borde_izquierda)/tamanyo_bloque_min)-1,((y-borde_arriba)/tamanyo_bloque_min)-1);
				
				drawing_map(0,mapa_durezas);
				drawing_color(color.blanco);
				//recreamos los bordes (no nos fiemos de los usuarios NUNCA!
				draw_line(borde_izquierda,borde_arriba,borde_derecha,borde_arriba);
				draw_line(borde_izquierda,borde_abajo,borde_derecha,borde_abajo);
				draw_line(borde_izquierda,borde_arriba,borde_izquierda,borde_abajo);
				draw_line(borde_derecha,borde_arriba,borde_derecha,borde_abajo);
				
				//borramos el rectángulo del mapa temporal
				drawing_color(0);
				drawing_map(0,mapa_temporal);
				draw_rect(x1,y1,x,y);
				
				dibuja_fondo();				
				
				x1=0; y1=0;
				while(mouse.left or mouse.right) frame; end
			end
		end
		frame;
		if(x1!=0) //limpieza del cuadro rojo
			drawing_map(0,mapa_temporal);
			drawing_color(0);
			draw_rect(x1,y1,x,y);
		end
	end
End

/*
armas: 
	0-disparo único
	1-doble disparo
	2-gancho
	3-metralleta
	 31..34-disparitos metralleta
*/
Process disparo(arma_temp);
Begin
	if(!exists(father)) return; end
	jugador=father.jugador;
	file=father.file;
	graph=101+arma_temp;
	prepara_proceso_grafico();
	set_center(file,graph,ancho,0);
	x=father.x;
	y=father.y;
	if(arma_temp==3) graph=0; disparo(31); disparo(32); disparo(33); disparo(34); frame; end
	if(arma_temp<10) //no subdisparos
		p[jugador].disparos++;
		from i=1 to 30;
			if(region_ocupada[i]==0) region_ocupada[i]=1; region=i; break; end
		end
		define_region(region,0,0,resolucion_x,y+father.alto);
	end
	switch(arma_temp)
		case 31: x_destino=-8; end
		case 32: x_destino=-2; end
		case 33: x_destino=+2; end
		case 34: x_destino=+8; end
	end
	loop
		if(arma_temp==3) break; end
		while(!ready) frame; end
		if(arma_temp<10) y_destino=-10; else y_destino=-20; end //la metralleta va más rápido
		while(y_destino!=0)
			if(map_get_pixel(0,mapa_durezas,x-ancho,y)!=color.negro or
			map_get_pixel(0,mapa_durezas,x,y)!=color.negro or
			map_get_pixel(0,mapa_durezas,x+ancho,y)!=color.negro)
				break;
			else
				y--;
				y_destino++;
			end
		end
		x+=x_destino;
		if(y_destino!=0 or accion==-1) break; end //tocó techo o tocamos una bola
		frame; 
	end
	if(arma_temp<10) //no subdisparos
		p[jugador].disparos--;
		region_ocupada[region]=0;
	end
End

Process raton();
Begin
	graph=new_map(5,5,bits);
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

/* TIPOS DE ITEMS
1.Vida
2.Reloj
3.Proteccion
4.Ancla
5.Dinamita
6.???
11.14.Comida
15-19.??? (probablemente más comida)
21.Doble disparo
22.Gancho
23.Metralleta
24.???
*/
Process item_drop(x,y,tipo);
Private
	id_jugador;
Begin
	file=fpg_general;
	graph=100+tipo;
	prepara_proceso_grafico();
	loop
		while(!ready) frame; end
		y_destino=6;
		while(y_destino!=0)
			if(y_destino>0)
				if(map_get_pixel(0,mapa_durezas,x-(ancho/2),y+alto)!=color.negro or
				map_get_pixel(0,mapa_durezas,x,y+alto)!=color.negro or
				map_get_pixel(0,mapa_durezas,x+(ancho/2),y+alto)!=color.negro) 
					break; 
				else
					y++;
					y_destino--;
				end
			else
				if(map_get_pixel(0,mapa_durezas,x,y-alto)!=color.negro) 
					break; 
				else
					y--;
					y_destino++;
				end
			end
		end
		if(id_jugador=collision(type personaje)) jugador=id_jugador.jugador; break; end
		frame;
	end
	
	switch(tipo)
		case 1: p[jugador].vidas++; end
		case 2: item_reloj(rand(3,5)); end
		case 3: p[jugador].proteccion++; proteccion(jugador); end
		case 4: item_ancla(); end
		case 5: dinamita=1; from alpha=200 to 60 step -15; frame; end frame(5000); dinamita=0; return; end
		case 11..19: p[jugador].puntos+=(tipo-10)*1000; mostrar_puntos(x,y,(tipo-10)*1000); end
		case 21..23: p[jugador].arma=tipo-20; end
	end
	from alpha=200 to 60 step -15; frame; end
End

Process mostrar_puntos(x,y,puntos);
Private
	id_txt;
Begin
	id_txt=write(fnt,x,y,4,puntos);
	from i=0 to 3*60; frame; end
	delete_text(id_txt);
End

Process proteccion(jugador);
Begin
	file=p[jugador].fpg;
	graph=201;
	while(p[jugador].proteccion>0 and exists(p[jugador].id))
		x=p[jugador].id.x;
		y=p[jugador].id.y;
		frame;
	end
End

Process item_ancla();
Begin
	if(ancla) ancla+=3*60; return; end
	velocidad_bolas=300; //lentas
	ancla=5*60;
	while(ancla>0)
		ancla--;
		frame;
	end
	velocidad_bolas=200; //rapidas
End

Process item_reloj(tiempo_en_segundos);
Private
	txt_reloj;
Begin
	if(reloj>0) 
		reloj+=tiempo_en_segundos*60; return; 
	else
		reloj=tiempo_en_segundos*60;
	end
	
	txt_reloj=write_int(fnt,resolucion_x/2,resolucion_y/4,4,&tiempo_en_segundos);
	
	while(reloj>0)
		while(!ready) frame; end
		if(reloj>10*60) reloj=10*60; end //tampoco hay que ser variciosos
		tiempo_en_segundos=(reloj/60)+1;
		reloj--;
		frame;
	end
	delete_text(txt_reloj);
End

Function preparar_controladores();
Begin
	p[2].control=1;
	p[3].control=2;
	p[4].control=3;
End

include "explosion.pr-";

Function dibuja_fondo();
Begin
	put_screen(0,mapa_durezas);
	//fondo cuadriculado
	drawing_map(0,BACKGROUND);
	drawing_color(color.gris);
	from y=borde_arriba to borde_abajo step tamanyo_bloque_min;
		draw_line(borde_izquierda,y,borde_derecha,y);
	end
	from x=borde_izquierda to borde_derecha step tamanyo_bloque_min;
		draw_line(x,borde_arriba,x,borde_abajo);
	end
	
	//bordes de la zona de juego
	drawing_color(color.blanco);
	draw_line(borde_izquierda,borde_arriba,borde_derecha,borde_arriba);
	draw_line(borde_izquierda,borde_abajo,borde_derecha,borde_abajo);
	draw_line(borde_izquierda,borde_arriba,borde_izquierda,borde_abajo);
	draw_line(borde_derecha,borde_arriba,borde_derecha,borde_abajo);
End

Function crea_mapa_durezas();
Begin
	drawing_map(0,mapa_durezas);
	drawing_color(color.verde);
	from x=0 to area_juego_x/tamanyo_bloque_min-1;
		from y=0 to area_juego_y/tamanyo_bloque_min-1;
			if(map_get_pixel(0,mini_mapa_durezas,x,y)!=color.negro)
				draw_box(borde_izquierda+(x*tamanyo_bloque_min),borde_arriba+(y*tamanyo_bloque_min),borde_izquierda+((x+1)*tamanyo_bloque_min),borde_arriba+((y+1)*tamanyo_bloque_min));
			end
		end
	end
End