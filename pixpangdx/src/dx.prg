Const
	resolucion_x=1920;
	resolucion_y=1080;
	
	bloques_x=50;
	bloques_y=30;
	bloques_max=100;
	bolas_max=100;
	
	tamanyo_bloque_min=30;
	bits=16;

	app_data=1;
Global
	area_juego_x;
	area_juego_y;
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
	//mini_mapa_durezas; //fichero de bloques, deprecado!
	fondo; //grafico de fondo
	
	struct nivel;
		string nombre;
		tiempo;
		struct bolas[bolas_max];
			char x,y,tipo,tamanyo,lado,regalo;
		end
		struct bloques[bloques_max]; //qué tipos de bloques hay? :S
			char x1,x2,y1,y2,tipo,regalo,destructible;
			int color;
		end
	end
	num_bloques;
	num_bolas;
	
	struct opciones;
		int lenguaje=-1; 	// 0 = castellano, 1 = inglés
		int musica=1;
		int sonido=1;
		int pantalla_completa=0;
		int dificultad=2; //1:fácil, 2:normal, 3:difícil, 4:muy difícil 5:imposible
	End
	
	velocidad_bolas=200; //velocidad de las bolas (cuanto menos, mayor velocidad)
	
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
	
	posibles_jugadores;
	njoys;
	
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
	area_juego_x=bloques_x*tamanyo_bloque_min;
	area_juego_y=bloques_y*tamanyo_bloque_min;
	
	borde_arriba=(resolucion_y/2)-(area_juego_y/2);
	borde_abajo=(resolucion_y/2)+(area_juego_y/2);
	borde_izquierda=(resolucion_x/2)-(area_juego_x/2);
	borde_derecha=(resolucion_x/2)+(area_juego_x/2);

	full_screen=0;
	if(!mode_is_ok(1920,1080,32,MODE_FULLSCREEN))
		if(!mode_is_ok(1280,720,32,MODE_FULLSCREEN))
			scale_resolution=10240576;
		else
			scale_resolution=12800720;
		end
	end
	set_mode(resolucion_x,resolucion_y,bits,WAITVSYNC);
	set_fps(60,0);
	frame;
	
	configurar_controles();
	
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

	//debuj();
	carga_nivel(1);
	//pinta();
end

Process debuj();
Begin
	x=1;
	
	/**/
	write(fnt,0,y+=40,0,"F1-Recrea personajes");
	write(fnt,0,y+=40,0,"F2-Pause");
	write(fnt,0,y+=40,0,"F3-Item reloj");
	write(fnt,0,y+=40,0,"F4-Pantalla completa");
	write(fnt,0,y+=40,0,"F10-Guardar durezas");
	/**/

	loop 
		if(key(_F10)) guarda_nivel("niveltemp.pang"); while(key(_F10)) frame; end end
		if(key(_F1)) personaje(1);personaje(2); while(key(_F1)) frame; end end
		if(key(_F2)) if(ready) ready=0; else ready=1; end while(key(_F2)) frame; end end
		if(key(_F3)) item_reloj(5); while(key(_F3)) frame; end end
		if(key(_F4)) if(full_screen==1) full_screen=0; else full_screen=1; end set_mode(resolucion_x,resolucion_y,bits,WAITVSYNC); while(key(_F4)) frame; end end

		//if(bolas==0) bola(1000,borde_arriba+150,x++,120,0,0); end
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
	string animacion; //0: quieto, 1:andar, 2:disparar, 3:enescaleras
	toca_suelo;
	disparando;
	retraso_disparo;
	invencibilidad; //para cuando pierdes la protección
	anim;
Begin
	if(p[jugador].jugando) return; end // POR QUÉ? xD
	p[jugador].jugando=1;
	file=p[jugador].fpg;
	graph=11;
	prepara_proceso_grafico();
	controlador(jugador);
	//x=borde_izquierda+(area_juego_x/2);
	x=borde_izquierda+(area_juego_x/2)-(tamanyo_bloque_min/2);
	y=borde_abajo-alto;
	p[jugador].id=id;
	personaje_colisionador();
	loop
		while(ready==0) accion=0; frame; end
		while(bolas==0) graph=41; frame; end
		if(!(p[jugador].botones[0] and p[jugador].botones[1]) and (p[jugador].botones[0] or p[jugador].botones[1]) and retraso_disparo==0)
			animacion="andar";
			if(p[jugador].botones[0]) flags=1; x_destino-=tamanyo_bloque_min/3; else
				if(p[jugador].botones[1]) flags=0; x_destino+=tamanyo_bloque_min/3; end 
			end
		else
			animacion="quieto";
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
			retraso_disparo=-5;
		end
		y_destino=gravedad;
		while(x_destino!=0)
			if(x_destino>0)
				from i=y-alto+10 to y+alto-51;
					if(map_get_pixel(0,mapa_durezas,x+ancho,i)!=color.negro) toca_suelo=1; end
				end
				if(toca_suelo) 
					break; 
				else
					x++;
					x_destino--;
				end
			else
				from i=y-alto+10 to y+alto-51;
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
		if(retraso_disparo<0) graph=31; retraso_disparo++; end
		if(anim<6) anim++; else anim=0; end
		switch(animacion)
			case "quieto": graph=11; end
			case "andar": 
				if(graph<21 or graph>24) anim=0; graph=21; end
				if(anim==5)
					if(graph<24) 
						graph++; 
					else 
						graph=21; 
					end
				end
			end
		end
		frame;
	end
	
	//muerteeeeeee
	ready=0;
	gravedad=rand(-30,-40);
	lado=rand(0,1);
	x_destino=rand(16,40);
	graph=51;
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

include "bolas.pr-";

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

/*
durezas:
*/
Process pinta();
Private
	x1;
	y1;
	mapa_temporal;
	id_grafico;
	bloque_x;
	bloque_y;
	modo=1; //1: durezas, 2:bloques, 3:bolas, ...
	punto_verde;
	micolor;
	regalo;
	destructible;
	pulsando;
Begin
	x1=-1;
	y1=-1;
	graph=punto_verde=new_map(10,10,bits);
	micolor=color.verde;
	drawing_color(micolor);
	drawing_map(0,graph);
	draw_box(0,0,10,10);
	drawing_map(0,mapa_durezas);
	frame;
	raton();
	loop
		if(key(_1)) //pintamos plataformas
			modo=1; file=0; graph=punto_verde; size=100; tipo=1;
		elseif(key(_2)) //pintamos... algo? :S
			modo=2; graph=0; size=100; tipo=1;
		elseif(key(_3)) //ponemos bolas
			modo=3; file=fpg_general; graph=11; size=100; tipo=1;
		end
		
		switch(modo)
			case 1:
				if(key(_space))
					while(key(_space)) frame; end
					switch(micolor)
						case color.verde: micolor=color.rojo; end
						case color.rojo: micolor=color.azul; end
						case color.azul: micolor=color.amarillo; end
						case color.amarillo: micolor=color.verde; end
					end
					drawing_color(micolor);
					drawing_map(0,graph);
					draw_box(0,0,10,10);
					drawing_map(0,mapa_durezas);
				end
			end
			case 3:
				if(key(_space))
					while(key(_space)) frame; end
					if(tipo==20) tipo=0; end //a cero porque aquí abajo nos ponen a 1
					if(tipo<10 and tipo!=20) tipo++; else tipo=20; end
					graph=tipo+10;
				end
				if(key(_c_minus) and size>25)
					while(key(_c_minus)) frame; end
					size-=25;
				end
				if(key(_c_plus) and size<100)
					while(key(_c_plus)) frame; end
					size+=25;
				end
			end
		end
		
		if(key(_A) and (map_get_pixel(0,mapa_durezas,x-tamanyo_bloque_min,y)==color.negro or pulsando==0))
			bloque_x--; 
		elseif(key(_D) and (map_get_pixel(0,mapa_durezas,x+tamanyo_bloque_min,y)==color.negro or pulsando==0)) 
			bloque_x++; 
		end
		if(key(_W) and (map_get_pixel(0,mapa_durezas,x,y-tamanyo_bloque_min)==color.negro or pulsando==0)) 
			bloque_y--; 
		elseif(key(_S) and (map_get_pixel(0,mapa_durezas,x,y+tamanyo_bloque_min)==color.negro or pulsando==0)) bloque_y++; end
		
		if(bloque_x<0) bloque_x=0; end
		if(bloque_y<0) bloque_y=0; end
		if(bloque_x>area_juego_x/tamanyo_bloque_min-1) bloque_x=area_juego_x/tamanyo_bloque_min-1; end
		if(bloque_y>area_juego_y/tamanyo_bloque_min-1) bloque_y=area_juego_y/tamanyo_bloque_min-1; end
		
		x=tamanyo_bloque_min/2+borde_izquierda+bloque_x*tamanyo_bloque_min;
		y=tamanyo_bloque_min/2+borde_arriba+bloque_y*tamanyo_bloque_min;
		
		switch(modo)
			case 1:
				if(key(_enter) and num_bloques<bloques_max and pulsando==0 and map_get_pixel(0,mapa_durezas,x,y)==color.negro)
					num_bloques++;
					nivel.bloques[num_bloques].x1=bloque_x; //queda más bonito si empezamos desde el 1
					nivel.bloques[num_bloques].y1=bloque_y;
					nivel.bloques[num_bloques].tipo=tipo;
					nivel.bloques[num_bloques].regalo=regalo;
					pulsando=1;
					nivel.bloques[num_bloques].color=micolor; //cuando haya selección de color
				end
				if(pulsando==1 and !key(_enter))
						if(bloque_x=>nivel.bloques[num_bloques].x1 and bloque_y=>nivel.bloques[num_bloques].y1)
							nivel.bloques[num_bloques].x2=bloque_x;
							nivel.bloques[num_bloques].y2=bloque_y;
						else
							nivel.bloques[num_bloques].x2=nivel.bloques[num_bloques].x1;
							nivel.bloques[num_bloques].y2=nivel.bloques[num_bloques].y1;
							nivel.bloques[num_bloques].x1=bloque_x;
							nivel.bloques[num_bloques].y1=bloque_y;
						end
						say("bloque "+itoa(nivel.bloques[num_bloques].x1)+","+itoa(nivel.bloques[num_bloques].y1)+","+itoa(nivel.bloques[num_bloques].x2)+","+itoa(nivel.bloques[num_bloques].y2)+","+itoa(nivel.bloques[num_bloques].tipo)+","+itoa(nivel.bloques[num_bloques].regalo)+","+itoa(nivel.bloques[num_bloques].color)+","+itoa(nivel.bloques[num_bloques].destructible));
						pulsando=0;
						carga_nivel(0);
				end
				if(key(_backspace) and num_bloques>0 and pulsando==0)
					nivel.bloques[num_bloques].x1=0;
					nivel.bloques[num_bloques].y1=0;
					nivel.bloques[num_bloques].x2=0;
					nivel.bloques[num_bloques].y2=0;
					nivel.bloques[num_bloques].tipo=0;
					nivel.bloques[num_bloques].regalo=0;
					nivel.bloques[num_bloques].color=0;
					num_bloques--;
					while(key(_backspace)) frame; end
					carga_nivel(0);
				end
			end
			case 3:
				if(key(_enter))
					while(key(_enter)) frame; end
					num_bolas++;
					nivel.bolas[num_bolas].x=bloque_x;
					nivel.bolas[num_bolas].y=bloque_y;
					nivel.bolas[num_bolas].tipo=tipo;
					nivel.bolas[num_bolas].tamanyo=size;
					nivel.bolas[num_bolas].lado=lado;
					nivel.bolas[num_bolas].regalo=regalo;
					say("bola "+bloque_x+","+bloque_y+","+tipo+","+size+","+lado+","+regalo);
					carga_nivel(0);
				end
				if(key(_backspace) and num_bolas>0)
					while(key(_backspace)) frame; end
					nivel.bolas[num_bolas].x=0;
					nivel.bolas[num_bolas].y=0;
					nivel.bolas[num_bolas].tipo=0;
					nivel.bolas[num_bolas].tamanyo=0;
					nivel.bolas[num_bolas].lado=0;
					nivel.bolas[num_bolas].regalo=0;
					num_bolas--;
					carga_nivel(0);
				end
			end
		end
		frame(400);
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
Private
	enganchado;
Begin
	if(!exists(father)) return; end
	jugador=father.jugador;
	file=father.file;
	graph=101+arma_temp;
	prepara_proceso_grafico();
	set_center(file,graph,ancho,0);
	x=father.x;
	y=father.y;
	if(arma_temp==2) enganchado=-180; end
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
			map_get_pixel(0,mapa_durezas,x+ancho,y)!=color.negro or
			x<borde_izquierda or x>borde_derecha)
				break;
			else
				y--;
				y_destino++;
			end
		end
		x+=x_destino;
		if(arma_temp==2 and enganchado<0 and y_destino!=0) enganchado++; y_destino=0; end
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
	//temporal:
	if(ancho=<1) return; end
	loop
		if(x<borde_izquierda+ancho) x=borde_izquierda+ancho; end
		if(x>borde_derecha-ancho) x=borde_derecha-ancho; end
		if(y<borde_arriba+ancho) y=borde_arriba+ancho; end
		if(y>borde_abajo-ancho) y=borde_abajo-ancho; end
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
	priority=-1;
	while(p[jugador].proteccion>0 and exists(p[jugador].id))
		x=p[jugador].id.x;
		y=p[jugador].id.y;
		frame;
	end
	explotalo(x,y,z,size,file,graph,60);
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
		if(reloj>7*60) reloj=7*60; end //tampoco hay que ser variciosos
		tiempo_en_segundos=(reloj/60)+1;
		reloj--;
		frame;
	end
	delete_text(txt_reloj);
End

/*Function preparar_controladores();
Begin
	p[2].control=1;
	p[3].control=2;
	p[4].control=3;
	
	joysticks[0]=0;
	joysticks[1]=1;
	joysticks[2]=2;
	joysticks[3]=3;
End*/

include "controles.pr-";

include "explosion.pr-";

Function dibuja_fondo();
Begin
	put_screen(0,mapa_durezas);
	//put_screen(0,load_png("bordes.png"));
	//fondo cuadriculado
	drawing_map(0,BACKGROUND);
	drawing_color(rgb(20,20,20));
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
	
	drawing_color(color.gris);
	draw_box(0,0,resolucion_x,borde_arriba);
	draw_box(0,borde_abajo,resolucion_x,resolucion_y);
	
	drawing_color(color.verde);
	draw_box(0,0,borde_izquierda,resolucion_y/2);
	drawing_color(color.amarillo);
	draw_box(0,resolucion_y/2,borde_izquierda,resolucion_y);
	drawing_color(color.azul);
	draw_box(borde_derecha,0,resolucion_x,resolucion_y/2);
	drawing_color(color.rojo);
	draw_box(borde_derecha,resolucion_y/2,resolucion_x,resolucion_y);
	//raw_box ( <INT x0> , <INT y0> , <INT x1> , <INT y1> )
End

/* formato del fichero:
//nombre nombre
//tiempo segundos
//bola x,y,tamanyo,regalo
//[...]
//bloque x1,y1,x2,y2,tipo,regalo
//[...]

struct nivel;
	string nombre;
	tiempo;
	struct bolas[100];
		x;
		y;
		tipo;
		tamanyo;
		lado;
		regalo;
	end
	struct bloques[100];
		x1; x2;
		y1; y2;
		tipo;
		regalo;
	end
end
*/

Function carga_nivel(num_nivel);
Private
	fichero;
	string linea;
	string txt_temp;
	string michar;
	valor;
Begin
	ready=0;
	num_bolas=0;
	if(num_nivel>0) //si se pasa el 0 no cargaremos el nivel. recrearemos el nivel con las variables en memoria
		num_bloques=0;
		let_me_alone();
		delete_text(all_text);
		bolas=0;
		//CARGA DE LA ESTRUCTURA NIVEL
		fichero=fopen("niveles/"+num_nivel+".pang",O_READ);
		if(!fichero) exit("[ERROR] No se pudo cargar el nivel."); end
		while(!feof(fichero))
			linea=fgets(fichero);
			if(""+linea[0]+linea[1]+linea[2]+linea[3]+linea[4]+linea[5]=="nombre")
				nivel.nombre=substr(linea,7);
			end
			if(""+linea[0]+linea[1]+linea[2]+linea[3]+linea[4]+linea[5]=="tiempo")
				nivel.tiempo=substr(linea,7);
			end
			if(""+linea[0]+linea[1]+linea[2]+linea[3]=="bola")
				num_bolas++;
				linea=substr(linea,5);
				michar="";
				valor=0;
				from i=0 to len(linea);
					if(""+linea[i]=="," or i==len(linea))
						if(valor==0) nivel.bolas[num_bolas].x=atoi(michar); end
						if(valor==1) nivel.bolas[num_bolas].y=atoi(michar); end
						if(valor==2) nivel.bolas[num_bolas].tipo=atoi(michar); end
						if(valor==3) nivel.bolas[num_bolas].tamanyo=atoi(michar); end
						if(valor==4) nivel.bolas[num_bolas].lado=atoi(michar); end
						if(valor==5) nivel.bolas[num_bolas].regalo=atoi(michar); break; end
						michar="";
						valor++;
					else
						michar+=""+linea[i];
					end
				end
			end
			if(""+linea[0]+linea[1]+linea[2]+linea[3]+linea[4]+linea[5]=="bloque")
				num_bloques++;
				linea=substr(linea,7);
				michar="";
				valor=0;
				from i=0 to len(linea);
					if(""+linea[i]=="," or i==len(linea))
						if(valor==0) nivel.bloques[num_bloques].x1=atoi(michar); end
						if(valor==1) nivel.bloques[num_bloques].y1=atoi(michar); end			
						if(valor==2) nivel.bloques[num_bloques].x2=atoi(michar); end
						if(valor==3) nivel.bloques[num_bloques].y2=atoi(michar); end
						if(valor==4) nivel.bloques[num_bloques].tipo=atoi(michar); end
						if(valor==5) nivel.bloques[num_bloques].regalo=atoi(michar); end
						if(valor==6) nivel.bloques[num_bloques].color=atoi(michar); end
						if(valor==7) nivel.bloques[num_bloques].destructible=atoi(michar); end
						michar="";
						valor++;
					else
						michar+=""+linea[i];
					end
				end
			end
		end
		fclose(fichero);
		//FIN DE LA CARGA DE LA ESTRUCTURA NIVEL
	end
	
	if(mapa_durezas>0 and map_exists(0,mapa_durezas)) unload_map(0,mapa_durezas); end
	mapa_durezas=new_map(resolucion_x,resolucion_y,bits);
	drawing_map(0,mapa_durezas);
	drawing_color(color.negro);
	draw_box(0,0,resolucion_x,resolucion_y);
	from i=1 to num_bloques;
		if(nivel.bloques[i].x1!=0)
			drawing_color(nivel.bloques[i].color);
			//le quitamos 1 a x1 que le sumamos al añadir el bloque
			draw_box(borde_izquierda+(nivel.bloques[i].x1)*tamanyo_bloque_min,
			borde_arriba+(nivel.bloques[i].y1)*tamanyo_bloque_min,
			borde_izquierda+(nivel.bloques[i].x2)*tamanyo_bloque_min+tamanyo_bloque_min,
			borde_arriba+(nivel.bloques[i].y2)*tamanyo_bloque_min+tamanyo_bloque_min);
			//borde_izquierda+(nivel.bloques[i].x2-1)*tamanyo_bloque_min,
			//borde_arriba+(nivel.bloques[i].y2-1)*tamanyo_bloque_min);
		end
	end
	drawing_color(color.blanco);
	draw_rect(borde_izquierda,borde_arriba,borde_derecha,borde_abajo);
	
	dibuja_fondo();			
	
	if(num_nivel==0) ready=1; bola_pang=1; while(bolas>0) frame; end ready=0; bola_pang=0; end
	i=1;
	while(nivel.bolas[i].tipo!=0 and i<bolas_max)	
		bola((borde_izquierda+(tamanyo_bloque_min/2)+(nivel.bolas[i].x*tamanyo_bloque_min)),
		(borde_arriba+(tamanyo_bloque_min/2)+(nivel.bolas[i].y*tamanyo_bloque_min)),
		nivel.bolas[i].tipo,
		nivel.bolas[i].tamanyo,
		nivel.bolas[i].lado,
		nivel.bolas[i].regalo);
		num_bolas++;
		i++;
	end
	
	if(num_nivel!=0)
		//posiciones caretos
		if(p[1].jugando) grafico(p[1].fpg,1,resolucion_x/28,resolucion_y/12,-2,0); end
		if(p[2].jugando) grafico(p[2].fpg,1,resolucion_x-(resolucion_x/28),resolucion_y/12,-2,1); end
		if(p[3].jugando) grafico(p[3].fpg,1,resolucion_x/28,resolucion_y-(resolucion_y/12),-2,0); end
		if(p[4].jugando) grafico(p[4].fpg,1,resolucion_x-(resolucion_x/28),resolucion_y-(resolucion_y/12),-2,1); end
		
		//PRINCIPAL
		personaje(1);
		pinta();
		debuj();
		//raton();
	end
	ready=1;
End

Function guarda_nivel(string fichero);
Begin
End