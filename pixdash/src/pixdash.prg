Program plataformas;

//comentar las dos siguientes líneas para Wii
#ifndef WII
 #ifdef LINUX
  import "image";
 #endif
 #ifndef LINUX
  import "mod_image";
 #endif
 import "mod_sys"; 
#endif



Global     
	arcade_mode=0;
	editor_de_niveles=0;
	descarga_niveles=0;
	
	app_data=0; //temporal, hasta que se puedan descargar niveles desde linux
	suelo;
	dur_pinchos;
	dur_muelle;
	ancho_pantalla=1280;
	alto_pantalla=720;
	ancho_nivel;
	alto_nivel;
	Struct ops; 
		pantalla_completa=0;
		sonido=1;
		musica=1;
		resolucion;
	End

	modo_juego=1; //0: COMPETITIVO, 1: COOPERATIVO
	id_cam;
	id_carganivel;
	separados[8]; //en modo cooperativo para saber cuántas sub-regiones necesitamos
	num_separados;
	
	struct p[8];
		botones[7];
		identificador;
		control;
		puntos;
		personaje;
		tiempos[10];
		combo;
		mejorcombo;
		monedas;
		powerupscogidos;
		enemigosmatados;
		pixismatados;
		muertes;
	end
	
	joysticks[4];
	
	posiciones[4];
	jugadores=2;
	tiles[100];
	powerups[100];
	enemigos[100];
	mapa_scroll;
	durezas;
	fpg_tiles;
	fpg_enemigos;
	fpg_powerups;
	fpg_menu;
	fpg_moneda;
	fpg_durezas;
	wavs[20];
	tilesize=40;
	fondo;
	flash;
	fuente;
	fuente_peq;
	num_enemigos;
	max_num_enemigos;
	num_nivel=1;
	ready;
	slowmotion;
	foto;
	njoys;
	posibles_jugadores;
	// COMPATIBILIDAD CON XP/VISTA/LINUX (usuarios)
	string savegamedir;
	string developerpath="\.PiXJuegos\PiXDash\";
	
	string paqueteniveles="";
	string nivel_titulo[50];
	string nivel_descripcion[50];
	string dir_juego;
	string ruta_navegador; //porque no funciona correctamente la funcion navegador devolviendo un string
End 

Local
	jugador;
	powerup;
	gravedad;
	inercia;
	ancho;
	alto;
	string accion;
	i; j;
	tiempo_powerup;
	saltando;
End

Process prota(jugador);
Private 
	pulsando;
	x_destino;
	y_destino;
	string animacion;
	anim;
	id_colision;
	doble_salto;
	saltogradual;
	posicion;
Begin
	p[jugador].identificador=id;
	//controlador(jugador);
	x=100;
	y=100; //coordenadas del jugador
	//size=125; //tamaño
	graph=1;
	ctype=c_scroll; //las corrdenadas son del scroll, no de la pantalla
	switch(jugador) // los gráficos de cada jugador
		case 1: file=load_fpg("fpg/pix.fpg"); end
		case 2: file=load_fpg("fpg/pux.fpg"); end
		case 3: file=load_fpg("fpg/pax.fpg"); end
		case 4: file=load_fpg("fpg/pex.fpg"); end
	end
	ancho=18;
	alto=29;
	loop
		while(ready==0) frame; end
		if(p[jugador].botones[1]) flags=0; inercia+=2; end //la inercia sube al ir hacia la derecha
		if(p[jugador].botones[0]) flags=1; inercia-=2; end //la inercia baja al ir hacia la izquierda
		if(p[jugador].botones[4] and pulsando==0 and saltando==0) saltando=1; sonido(5); saltogradual=1; gravedad=-15; pulsando=1; y--; end 
		//al saltar suena el sonido correspondiente y se aplica la gravedad, y el salto gradual si saltamos poco 
		if(p[jugador].botones[4] and pulsando==0 and powerup==3 and tiempo_powerup>0 and doble_salto==0) saltogradual=1; doble_salto=1; gravedad=-15; pulsando=1; y--; end
		//e l doblesalto si disponemos del power-up 3
		if(p[jugador].botones[4] and saltogradual<5 and saltogradual!=0) gravedad-=4; saltogradual++; end
		if(saltogradual>0 and p[jugador].botones[4]==0 and gravedad<-10) saltogradual=0; gravedad=-10; end
		if(!p[jugador].botones[4] and pulsando==1) pulsando=0; saltogradual=0; end
		if(map_get_pixel(0,durezas,x,y+alto)==suelo or map_get_pixel(0,durezas,x-(ancho/3),y+alto)==suelo or map_get_pixel(0,durezas,x+(ancho/3),y+alto)==suelo and gravedad>0) gravedad=0; saltando=0; doble_salto=0; else saltando=1; gravedad++; end //al tocar el suelo, gravedad es 0
		if(x>ancho_nivel) 
			p[i].tiempos[num_nivel]=timer[1];
			if(jugadores==1) num_nivel++; carga_nivel(); end
			if(jugadores==2) 
				if(posiciones[1]==0) posicion=1; posiciones[1]=jugador; bomba();
				elseif(posiciones[2]==0) posicion=2; posiciones[2]=jugador; end
			end
			if(jugadores==3) 
				if(posiciones[1]==0) posicion=1; posiciones[1]=jugador; bomba();
				elseif(posiciones[2]==0) posicion=2; posiciones[2]=jugador;
				elseif(posiciones[3]==0) posicion=3; posiciones[3]=jugador; end
			end
			if(jugadores==4) 
				if(posiciones[1]==0) posicion=1; posiciones[1]=jugador; bomba();
				elseif(posiciones[2]==0) posicion=2; posiciones[2]=jugador;
				elseif(posiciones[3]==0) posicion=3; posiciones[3]=jugador;
				elseif(posiciones[4]==0) posicion=4; posiciones[4]=jugador; end
			end
			
/*			if(jugadores<=2)
				if(jugador==1) write(fuente,ancho_pantalla/2,alto_pantalla/4,4,posicion); pon_tiempo(p[i].tiempos[num_nivel],1,ancho_pantalla/2,(alto_pantalla/4)+50); end
				if(jugador==2) write(fuente,ancho_pantalla/2,(alto_pantalla/4)*3,4,posicion); pon_tiempo(p[i].tiempos[num_nivel],1,ancho_pantalla/2,((alto_pantalla/4)*3)+50); end
				end
			if(jugadores>2)
				if(jugador==1) write(fuente,ancho_pantalla/4,alto_pantalla/4,4,posicion); pon_tiempo(p[i].tiempos[num_nivel],1,ancho_pantalla/4,(alto_pantalla/4)+50); end
				if(jugador==2) write(fuente,(ancho_pantalla/4)*3,alto_pantalla/4,4,posicion); pon_tiempo(p[i].tiempos[num_nivel],1,(ancho_pantalla/4)*3,(alto_pantalla/4)+50); end
				if(jugador==3) write(fuente,ancho_pantalla/4,(alto_pantalla/4)*3,4,posicion); pon_tiempo(p[i].tiempos[num_nivel],1,ancho_pantalla/4,((alto_pantalla/4)*3)+50); end
				if(jugador==4) write(fuente,(ancho_pantalla/4)*3,(alto_pantalla/4)*3,4,posicion); pon_tiempo(p[i].tiempos[num_nivel],1,(ancho_pantalla/4)*3,((alto_pantalla/4)*3)+50); end
			end*/
			
			graph=0;
			loop
				accion="ganando";
				frame; 
			end //aquí se queda!
		end //al ganar mike canta y nos damos la vuelta xD
		if(inercia>0 and gravedad==0) inercia--; end
		if(inercia<0 and gravedad==0) inercia++; end
		if(p[jugador].botones[5])
			if(inercia>20) inercia=20; end
			if(inercia<-20) inercia=-20; end
		else
			if(inercia>10) inercia=10; end
			if(inercia<-10) inercia=-10; end
		end
		if(gravedad>40) gravedad=40; end
		if(powerup==5) 
			inercia*=2;
		end //si tenemos el chute de velocidad la inercia se dobla
		//x=x+inercia;
		x_destino=x+(inercia/2);
		if(x_destino>x) 
			from x=x to x_destino step 1; if(map_get_pixel(0,durezas,x+ancho,y+alto/2)==suelo) inercia=0; break; end end
		elseif(x_destino<x)
			from x=x to x_destino step -1; if(map_get_pixel(0,durezas,x-ancho,y+alto/2)==suelo) inercia=0; break; end end
		end //calculamos donde se para si tiene inercia y dejas de correr
		
		if(powerup==5)
			inercia/=2;
		end

		if(y>alto_nivel)
			powerup=0;
			accion="muerte";
		end //si caes por un bujero y mueres

		if(map_get_pixel(0,durezas,x,y)==dur_pinchos or map_get_pixel(0,durezas,x,y+alto)==dur_pinchos or map_get_pixel(0,durezas,x,y-alto)==dur_pinchos or
			map_get_pixel(0,durezas,x-ancho,y)==dur_pinchos or map_get_pixel(0,durezas,x+ancho,y)==dur_pinchos) accion="muerte"; end
		if(map_get_pixel(0,durezas,x,y)==dur_muelle or map_get_pixel(0,durezas,x,y+alto)==dur_muelle or map_get_pixel(0,durezas,x,y-alto)==dur_muelle or
			map_get_pixel(0,durezas,x-ancho,y)==dur_muelle or map_get_pixel(0,durezas,x+ancho,y)==dur_muelle) doble_salto=0; gravedad=-40; y--; end
	
		if(x<10) x=10; end //pa no salirse de la pantalla por la izquierda
		//y=y+gravedad;
		y_destino=y+(gravedad/2);
		if(y_destino>y)  
			from y=y to y_destino step 1; 
				if(map_get_pixel(0,durezas,x,y+alto)==suelo) gravedad=0; break; end 
				if(map_get_pixel(0,durezas,x-ancho/3,y+alto)==suelo) gravedad=0; break; end 
				if(map_get_pixel(0,durezas,x+ancho/3,y+alto)==suelo) gravedad=0; break; end 
			end
		elseif(y_destino<y)
			from y=y to y_destino step -1; 
				if(map_get_pixel(0,durezas,x,y-alto)==suelo) gravedad=10; break; end 
				if(map_get_pixel(0,durezas,x-ancho/3,y-alto)==suelo) gravedad=10; break; end 
				if(map_get_pixel(0,durezas,x+ancho/3,y-alto)==suelo) gravedad=10; break; end 
			end
		end
		while(map_get_pixel(0,durezas,x,y+alto-1)==suelo) y--; end
		while(map_get_pixel(0,durezas,x-ancho/3,y+alto-1)==suelo) y--; end
		while(map_get_pixel(0,durezas,x+ancho/3,y+alto-1)==suelo) y--; end
		if(saltando==0 and gravedad==0) //animaciones al andar o estar quieto
			if(inercia!=0) animacion="andar"; else animacion="quieto"; end
		else
			animacion="salto"; //animación al saltar
		end
		if(accion=="muerte") //animación de muerte
			if(powerup!=2)
				tiempo_powerup=0; 
				powerup=0; 
				graph=2;
				gravedad=-20;
				flash_muerte(jugador);
				sonido(6);
				if(ready==1) ready=0; frame(3000); end
				if(y<alto_nivel)
					while(y<alto_nivel+150)
						gravedad++;
						if(gravedad>50) break; end
						y+=gravedad/2;
						frame;
					end			
				end
				alpha=128;
				while(x>100 or y>100)
					if(x>100) x-=x/10; end
					if(y>100) y-=y/10; end
					frame;
				end
				alpha=255;
				x=100; y=100; 
				//p[jugador].puntos=p[jugador].puntos*0.90;
				accion="";
				gravedad=0;
				inercia=0;
				ready=1;
			else 
				accion=""; 
			end 
		end
		if(modo_juego==0 and (id_colision=collision(type prota))) 
			if(id_colision.accion!="muerte")
				if(id_colision>id)
					if(id_colision.y>y)
						id_colision.gravedad=20; gravedad=-20;
					else
						id_colision.gravedad=20; gravedad=-20;
					end
				end
				if(id_colision.x<x) 
					inercia+=5;
				else
					inercia-=5;
				end
			end
		end
		switch(animacion)
			case "": animacion="quieto"; graph=1; end
			case "quieto": graph=1; end
			case "andar": 
				if(graph=>11 and graph<13) 
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
		if(slowmotion==0 or powerup==4) frame; else frame(300); end
	end      
End

Process flash_muerte(region);
Begin
	x=ancho_pantalla/2;
	y=alto_pantalla/2;
	z=-5;
	
	from i=0 to 2;
		graph=flash;
		frame;
		graph=0;
		frame;
	end 
End //el flashazo de cuando muere el prota

// tipos: 1: goomba, 2:paragoomba, 3:koopatroopa, 4:paratroopa, 5:spiky, 6:spiky-goomba, 7:billbala, 8:	lakitu, 9:huevo de spiky, 10:spikyparabuzzy
Process enemigo(x,y,tipo);
Private
	id_colision;
	x_original;
	y_original;
	anim_base;
	frames_anim;
	anim;
	spikys;
Begin
   ctype=c_scroll;
   file=fpg_enemigos;
   x_original=x;
   y_original=y;
   if(tipo==6) tipo=5; end
   anim_base=tipo*10;
   loop
		if(map_exists(fpg_enemigos,(anim_base)+i+1) and i<9) i++; else break; end
   end
   frames_anim=i;
   graph=anim_base+1;
   ancho=graphic_info(file,graph,g_width)/2;
   alto=graphic_info(file,graph,g_height)/2;
   if(tipo==7) alpha=0; frame(rand(2000,10000)); angle=20000; from alpha=0 to 255 step 3; angle+=4000; frame; end angle=0; alpha=255; end
   if(exists(father) and father.accion=="renacer") alpha=200; end
   loop
		if(!alguiencerca()) frame(10000); end
		if(anim<10) anim++; else anim=0; if(graph<anim_base+frames_anim) graph++; else graph=anim_base+1; end end
		while(ready==0) frame; end
		if(alpha<255) alpha+=5; end
		if(map_get_pixel(0,durezas,x+ancho,y)==suelo) flags=0; end //giramos cuando chocamos por la derecha
		if(map_get_pixel(0,durezas,x-ancho,y)==suelo or x=<10) if(tipo==7) explotalo(x,y,z,255,0,file,graph,60); break; end flags=1; end //giramos cuando chocamos, o nos salimos, por la izquierda. aunque billbala muere
		if(map_get_pixel(0,durezas,x,y-alto)==suelo and tipo!=7) gravedad=10; y++; end //si chocamos arriba, nos vamos pabajo. pd: sólo chocan los para-algo
		if(tipo==7) flags=0; x-=6; end //billbala siempre va hacia la izquierda
		if(tipo==8 and rand(0,200)==0 and spikys<10) spikys++; enemigo(x,y,9); end //lakitu tirando pinchones
		if(flags==0) 
			if(tipo!=8) 
				x-=2; 
			else 
				x-=6; 
			end //los malos andan pa un lao
		else  
			if(tipo!=8) 
				x+=2; 
			else 
				x+=6; 
			end 
		end	//si miramos pa un lao, andamos pa ese, sino viceversa
		if(tipo==8 and rand(0,300)==0) if(flags==0) flags=1; else flags=0; end end //cuando mira lakitu pa la derecha al azar
		if(map_get_pixel(0,durezas,x,y+alto)==suelo and tipo!=8 and gravedad>0) //el malo tocó el suelo? lakitu no choca wei!
			if(tipo==9) enemigo(x,y, tipo-4); break; end //los huevos de spiky tocan el suelo, mueren y llaman a los spikys
			if(tipo==2 or tipo==4 or tipo==10) gravedad=-40; y--; else gravedad=0; end //saltos para los para-algo, sino quietos nel suelo
		else 
			gravedad++; //pos no lo tocó
		end //gravedad
		if(y>alto_nivel or y<0) break; end //si cae por un bujero, muere
		while(map_get_pixel(0,durezas,x,y+alto-1)==suelo and tipo!=7 and tipo!=8) y--; end //corregimos atravesamiento de suelos...

		if(alpha==255 and (id_colision=collision(type prota))) //chocamos con el prota
			if(id_colision.y<y-(alto/2) and id_colision.saltando==1 and tipo!=5 and tipo!=6 and tipo!=9 and tipo!=10 and id_colision.accion!="muerte") //si el prota está más arriba, el malo muere. a menos que sean spikis o sus huevos! y que no esté muriendo el prota xD
				//p[id_colision.jugador].puntos++;
				id_colision.gravedad=-20; //rebota el prota
				if(tipo!=2 and tipo!=4)  //animacion de la muerte, salvo que sean para-algo
					explotalo(x,y,z,255,0,file,graph,60);
				end
				if(tipo==2 or tipo==4) accion="renacer"; enemigo(x,y,tipo-1); end //los para-algo llamando a los correspondientes malos cuando los pisas
				frame;
				break; //suicidamos al malo
			else //el prota chocó por debajo de la altura del enemigo
				if(id_colision.powerup==1) 
					//p[id_colision.jugador].puntos++;
					id_colision.gravedad=-20; //rebota el prota
					while(size>0 and tipo!=2 and tipo!=4)  //animacion de la muerte, salvo que sean para-algo
						size=size-5; 
						angle+=7000;
						frame; 
					end
					if(tipo==2 or tipo==4) enemigo(x,y,tipo-1); end
					frame;
					break; //suicidamos al malo
				else
					id_colision.accion="muerte"; //el prota muere
				end
			end
		end
		if(map_get_pixel(0,durezas,x,y)==dur_pinchos or map_get_pixel(0,durezas,x,y+alto)==dur_pinchos or map_get_pixel(0,durezas,x,y-alto)==dur_pinchos or
		map_get_pixel(0,durezas,x-ancho,y)==dur_pinchos or map_get_pixel(0,durezas,x+ancho,y)==dur_pinchos) 
			explotalo(x,y,z,255,0,file,graph,60);
			break; 
		end
		if(map_get_pixel(0,durezas,x,y)==dur_muelle or map_get_pixel(0,durezas,x,y+alto)==dur_muelle or map_get_pixel(0,durezas,x,y-alto)==dur_muelle or
			map_get_pixel(0,durezas,x-ancho,y)==dur_muelle or map_get_pixel(0,durezas,x+ancho,y)==dur_muelle) gravedad=-40; y--; end

		if(tipo!=7 and tipo!=8) y=y+(gravedad/4); end //gravedad barata. a billbala y a lakitu no les afecta
		if(slowmotion==0) frame; else frame(300); end
		//frame;
    end	
	if(tipo==7) enemigo(x_original,y_original,tipo); end
	num_enemigos--;
End

//1: dañosalta, 2:escudo, 3:doblesalto, 4:slowmotion, 5:velocidad
Process powerups(x,y,tipo);
Private
	id_colision;
	x_orig;
	y_orig;
Begin
	ctype=c_scroll;
	file=fpg_powerups;
	graph=tipo;
	x_orig=x;
	y_orig=y;
    ancho=graphic_info(file,graph,g_width)/2;
    alto=graphic_info(file,graph,g_height)/2;
    priority=-1;
    loop
		if(!alguiencerca()) frame(10000); end
		if(map_get_pixel(0,durezas,x,y+alto)!=suelo) y+=6; end 
		if(map_get_pixel(0,durezas,x,y+alto)==dur_pinchos) break; end 
		while(map_get_pixel(0,durezas,x,y+alto-1)==suelo) y--; end //colisiones con el suelo
		if(y>alto_nivel) break; end //al caer poir un bujero los power-ups desaparecen
		if(id_colision=collision(type prota)) //al tocarlos el prota
			if(id_colision.accion!="muerte")
				//p[id_colision.jugador].puntos++; //gana puntos
				if(modo_juego==0)
					id_colision.powerup=tipo; //se activa el power-up
					id_colision.tiempo_powerup=10*50; //se ajusta el tiempo del power-up
				end
				if(modo_juego==1)
					from i=1 to jugadores;
						p[i].identificador.powerup=tipo; //se activa el power-up
						p[i].identificador.tiempo_powerup=10*50; //se ajusta el tiempo del power-up
					end
				end
				tiempo_powerup=10*50;
					
				while(alpha>0 and id_colision.powerup==tipo) //la animación en la que aparece detrás del prota
					x=id_colision.x;
					y=id_colision.y;
					alpha=tiempo_powerup/2;
					tiempo_powerup--;
					z=1;
					if(tipo==4) slowmotion=1; end
					frame;
				end
				if(tipo==4) slowmotion=0; end
				break;
			end
		end
		frame;
   end	
	while(size>0)  //animacion de la muerte, salvo que sean para-algo
		size=size-5; 
		angle+=7000;
		frame; 
	end
	powerups(x_orig,y_orig,tipo);
End

Process moneda(x,y)
Private
	anim;
	id_colision;
Begin
	ctype=c_scroll; 
	file=fpg_moneda;
	graph=1;
	loop
		if(!alguiencerca()) frame(10000); end
		if(anim<5) anim++; else graph++; anim=0; end
		if(graph==5) graph=1; end
		if(id_colision=collision(type prota)) 
			if(id_colision.accion!="muerte")
				sonido(4);
				p[id_colision.jugador].monedas++;
				break;
			end
		end
		frame;
	end
	from alpha=255 to 0 step -20; size++; frame; end
End

Process carga_nivel();
PRIVATE
	pos_x;
	pos_y;
	tile;
	pers_x;
	pers_y;
	mapa;
	texto;
	txt_tiempo;
	minutos;
	segundos;
	decimas;
	string string_tiempo;
	fichero;
BEGIN
	id_carganivel=id;
	if(num_nivel!=1)
		p[posiciones[1]].puntos+=6;
		p[posiciones[2]].puntos+=4;
		p[posiciones[3]].puntos+=2;
		p[posiciones[4]].puntos++;
		from i=1 to 4; posiciones[i]=0; end
	else
		if(os_id!=1000 and fexists(savegamedir+"niveles\"+paqueteniveles+"\descripciones.txt")) //la WII falla con fgets actualmente
			i=1;
			fichero=fopen(savegamedir+"niveles\"+paqueteniveles+"\descripciones.txt",O_READ);	
			while(!feof(fichero))
				nivel_titulo[i]=fgets(fichero);
				nivel_descripcion[i++]=fgets(fichero);
			end
			fclose(fichero);
			i=0;
		end
	end
	if(!file_exists(savegamedir+"niveles\"+paqueteniveles+"\nivel"+num_nivel+".png")) menu(); return; end // FIN DE LA COMPETICION
	frame;
	if(num_nivel!=1) foto=get_screen(); end
	set_mode(ancho_pantalla,alto_pantalla,16,WAITVSYNC);
	delete_text(all_text);
	
	rand_seed(num_nivel);
	ready=0;
	slowmotion=0;
	let_me_alone();
	if(num_nivel==1) frame(3000); end
	stop_scroll(0);
	stop_scroll(1);
	stop_scroll(2);
	stop_scroll(3);
	stop_scroll(4);
	unload_map(0,mapa_scroll);
	unload_map(0,durezas);

	mapa=load_png(savegamedir+"niveles\"+paqueteniveles+"\nivel"+num_nivel+".png"); 

	if(os_id==os_wii)
		if(fexists(savegamedir+"niveles\"+paqueteniveles+"\fondo"+num_nivel+".jpg.png"))
			fondo=load_png(savegamedir+"niveles\"+paqueteniveles+"\fondo"+num_nivel+".jpg.png"); //cargar el fondo. ponemos .jpg.png para saber que viene de un jpg
		else
			fondo=load_png("fondos\fondo"+rand(1,5)+".jpg.png"); //cargar el fondo
		end
	else
		if(fexists(savegamedir+"niveles\"+paqueteniveles+"\fondo"+num_nivel+".jpg"))
			fondo=load_image(savegamedir+"niveles\"+paqueteniveles+"\fondo"+num_nivel+".jpg"); //cargar el fondo
		else
			fondo=load_image("fondos\fondo"+rand(1,5)+".jpg"); //cargar el fondo
		end
	end


	if(fexists(savegamedir+"niveles\"+paqueteniveles+"\tiles.fpg"))
		fpg_tiles=load_fpg(savegamedir+"niveles\"+paqueteniveles+"\tiles.fpg");
	else
		fpg_tiles=load_fpg("fpg\tiles.fpg");
	end
	num_enemigos=0;

	//ancho del gráfico pequeñito
	ancho=GRAPHIC_INFO(0,mapa,G_WIDE);
	alto=GRAPHIC_INFO(0,mapa,G_HEIGHT);

	from i=0 to 9; tiles[i]=map_get_pixel(0,mapa,i,alto-3); end
	from i=1 to 10; enemigos[i]=map_get_pixel(0,mapa,i,alto-2); end
	from i=1 to 5; powerups[i]=map_get_pixel(0,mapa,i,alto-1); end
	
	alto_nivel=(alto-3)*tilesize;
	ancho_nivel=ancho*tilesize;
	
	max_num_enemigos=(alto_nivel*ancho_nivel)/100000;
	//BURRADA TEMPORAL PARA PRUEBAS CON MEMORIA DE LA WII
	if(os_id!=os_wii)
		mapa_scroll=new_map(ancho*tilesize,(alto-3)*tilesize,16);
		//LO VISIBLE:
		repeat
			pos_x=x*tilesize;
			pos_y=y*tilesize;
			tile=map_get_pixel(0,mapa,x,y);
			if(tile==tiles[0]) MAP_PUT(fpg_tiles,mapa_scroll,1,pos_x+(tilesize/2),pos_y+(tilesize/2)); end
			if(tile==tiles[1]) MAP_PUT(fpg_tiles,mapa_scroll,2,pos_x+(tilesize/2),pos_y+(tilesize/2)); end
			if(tile==tiles[2]) MAP_PUT(fpg_tiles,mapa_scroll,3,pos_x+(tilesize/2),pos_y+(tilesize/2)); end
			if(tile==tiles[3]) MAP_PUT(fpg_tiles,mapa_scroll,4,pos_x+(tilesize/2),pos_y+(tilesize/2)); end
			if(x<ancho)
				x++;
			else
				y++; x=0;
			end
		until(y=>alto-3)
	END

	x=0; y=0;
	durezas=new_map(ancho*tilesize,(alto-3)*tilesize,8);

	//BURRADA TEMPORAL PARA PRUEBAS CON MEMORIA DE LA WII
	if(os_id==os_wii) mapa_scroll=durezas; end

	suelo=map_get_pixel(fpg_durezas,501,0,0);
	dur_pinchos=map_get_pixel(fpg_durezas,502,0,0);
	dur_muelle=map_get_pixel(fpg_durezas,504,0,0);
	//LO INVISIBLE (PERO TOCABLE)
	repeat
		pos_x=x*tilesize;
		pos_y=y*tilesize;
		tile=map_get_pixel(0,mapa,x,y);
		if(tile==tiles[0]) tile=1; end
		if(tile==tiles[1]) tile=2; end
		if(tile==tiles[2]) tile=3; end
		if(tile==tiles[3]) tile=4; end
		if(tile==tiles[4]) moneda(pos_x+(tilesize/2),pos_y+(tilesize/2)); end
		
		from i=1 to 10; if(tile==enemigos[i]) enemigo(pos_x+(tilesize/2),pos_y+(tilesize/2),i); end end
		from i=1 to 5; if(tile==powerups[i]) powerups(pos_x+(tilesize/2),pos_y+(tilesize/2),i); end end

		tile=tile+500;
		if(tile==500) tile=0; end
		if(tile!=0) MAP_PUT(fpg_durezas,durezas,tile,pos_x+(tilesize/2),pos_y+(tilesize/2)); end
		if(x<ancho)
			x++;
		else
			y++; x=0;
		end
	until(y=>alto-3)

//BURRADA TEMPORAL PARA PRUEBAS CON MEMORIA DE LA WII
if(os_id!=os_wii)
	//EMPEZAMOS A PINTAR COSAS WACHIS!!!
	from y=0 to alto;
		from x=0 to ancho;
			//arriba
			if(map_get_pixel(0,mapa,x,y)==tiles[0])
				if(map_get_pixel(0,mapa,x,y-1)!=tiles[0])
					from j=0 to tilesize;
						from i=0 to tilesize/12;
							map_put_pixel(0,mapa_scroll,(x*tilesize)+j,(y*tilesize)+i,rgb(134,86,10));
						end
					end
				end
			end
			//izquierda
			if(map_get_pixel(0,mapa,x,y)==tiles[0])
				if(map_get_pixel(0,mapa,x-1,y)!=tiles[0])
					from j=0 to tilesize;
						from i=0 to tilesize/12;
							map_put_pixel(0,mapa_scroll,(x*tilesize)+i,(y*tilesize)+j,rgb(134,86,10));
						end
					end
				end
			end
			//derecha
			if(map_get_pixel(0,mapa,x,y)==tiles[0])
				if(map_get_pixel(0,mapa,x+1,y)!=tiles[0])
					from j=0 to tilesize;
						from i=0 to tilesize/12;
							map_put_pixel(0,mapa_scroll,((x+1)*tilesize)-i,(y*tilesize)+j,rgb(67,43,5));
						end
					end
				end
			end
			//abajo
			if(map_get_pixel(0,mapa,x,y)==tiles[0])
				if(map_get_pixel(0,mapa,x,y+1)!=tiles[0])
					from j=0 to tilesize;
						from i=0 to tilesize/12;
							map_put_pixel(0,mapa_scroll,(x*tilesize)+j,((y+1)*tilesize)-i,rgb(67,43,5));
						end
					end
				end
			end
		end
	end
	//FIN DE PINTAR COSAS WACHIS!!!
//BURRADA TEMPORAL PARA PRUEBAS CON MEMORIA DE LA WII
end //FIN IF WII

	flash=new_map(ancho_pantalla,alto_pantalla,8);
	drawing_color(suelo);
	drawing_map(0,flash);
	draw_box(0,0,ancho_pantalla,alto_pantalla);

	if(modo_juego==0) //competitivo: 4 pantallas
		if(jugadores<=2) //definir la pantalla partida y la división al ser 2 jugadores
			define_region(1,0,0,ancho_pantalla,alto_pantalla/2);
			define_region(2,0,alto_pantalla/2,ancho_pantalla,alto_pantalla);
	
			start_scroll(0,0,mapa_scroll,fondo,1,0);
			scroll[0].camera=prota(1);
			start_scroll(1,0,mapa_scroll,fondo,2,0);
			if(jugadores==2) scroll[1].camera=prota(2); end
	
			graph=new_map(ancho_pantalla,alto_pantalla,16);
			drawing_color(200);
			drawing_map(0,graph);
			draw_box(0,alto_pantalla/2-5,ancho_pantalla,alto_pantalla/2+5);
	
		end
		if(jugadores==3 or jugadores==4) //definirlo al ser 4
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
			if(jugadores==4) 
				scroll[3].camera=prota(4);
			end

			graph=new_map(ancho_pantalla,alto_pantalla,16);
			drawing_color(200);
			drawing_map(0,graph);
			draw_box(0,alto_pantalla/2-5,ancho_pantalla,alto_pantalla/2+5);
			draw_box(ancho_pantalla/2-5,0,ancho_pantalla/2+5,alto_pantalla);
			
		end
	end
	if(modo_juego==1) //cooperativo
		id_cam=cam_cooperativo();
		from i=1 to jugadores; prota(i); end
	end
	x=ancho_pantalla/2; 
	y=alto_pantalla/2;
	timer[0]=0;
	stop_song();
	transicion();
	//TEXTO PRESENTACION NIVEL:
	write(fuente,ancho_pantalla/2,(alto_pantalla/4),4,nivel_titulo[num_nivel]);
	write(fuente_peq,ancho_pantalla/2,(alto_pantalla/4)+50,4,nivel_descripcion[num_nivel]);
	//3 2 1 YA!:
	from i=3 to 1 step -1;
		timer[0]=0;
		texto=write(fuente,ancho_pantalla/2,alto_pantalla/2,4,i);
		sonido(1);
		while(timer[0]<100) frame; end
		delete_text(texto);
	end
	sonido(3);
	delete_text(all_text);
	if(modo_juego==0) marcadores(); end //marcadores de puntos en modo competición
	texto=write(fuente,ancho_pantalla/2,alto_pantalla/2,4,"¡YA!");
	ready=1;
	timer[0]=0;
	timer[1]=0; //para contrarreloj
	//if(ops.musica) play_song(load_song(savegamedir+"niveles\"+paqueteniveles+"\nivel"+num_nivel+".ogg"),-1); end
	if(ops.musica)
        if(fexists(savegamedir+"niveles\"+paqueteniveles+"\nivel"+num_nivel+".ogg"))
            play_song(load_song(savegamedir+"niveles\"+paqueteniveles+"\nivel"+num_nivel+".ogg"),-1);
        else
            play_song(load_song("ogg\"+rand(1,5)+".ogg"),-1);
        end
    end
	pon_tiempo(-1,0,(ancho_pantalla/4)*3,70);
	save_png(0,mapa_scroll,"c:\algo.png");
	controlador(0);
	loop
		if(key(_n)) while(key(_n)) frame; end num_nivel++; carga_nivel(); end
		if(p[0].botones[7]) while(p[0].botones[7]) frame; end menu(); end
		if(timer[0]>300 and texto!=0) delete_text(texto); texto=0; end
//		if(jugadores==3 and ((!exists(scroll[3].camera)) or scroll[3].camera==0 or rand(0,500)==333)) scroll[3].camera=get_id(type enemigo); end
//		if(jugadores==1 and ((!exists(scroll[1].camera)) or scroll[1].camera==0 or rand(0,500)==333)) scroll[1].camera=get_id(type enemigo); end
		frame;
	end 
END

//ganar, muerte, salto
Process sonido(numsonido);
Begin
	if(numsonido==6) numsonido+=father.jugador-1; end
	if(ops.sonido) play_wav(wavs[numsonido],0); end
End

Process pon_tiempo(tiempo,permanecer,x,y);
Private
	decimas;
	segundos;
	minutos;
	txt_tiempo;
	bucle;
	mi_tiempo;
	string string_tiempo;
Begin
	if(tiempo==-1) bucle=1; end
	loop
		if(bucle) mi_tiempo++; tiempo=mi_tiempo*2; end 
		decimas=tiempo; while(decimas=>100) decimas-=100; end
		segundos=tiempo/100; while(segundos=>60) segundos-=60; end
		minutos=tiempo/6000;
	
		if(decimas<10 and segundos<10) string_tiempo=itoa(minutos)+"' 0"+itoa(segundos)+"'' 0"+itoa(decimas); end
		if(decimas>9 and segundos<10) string_tiempo=itoa(minutos)+"' 0"+itoa(segundos)+"'' "+itoa(decimas); end
		if(decimas<10 and segundos>9) string_tiempo=itoa(minutos)+"' "+itoa(segundos)+"'' 0"+itoa(decimas); end
		if(decimas>9 and segundos>9) string_tiempo=itoa(minutos)+"' "+itoa(segundos)+"'' "+itoa(decimas); end
		txt_tiempo=write(fuente,x,y,4,string_tiempo);
		frame;
		while(!ready) frame; end
		if(!permanecer) delete_text(txt_tiempo); end
		if(!bucle) break; end
	end
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
	from i=1 to jugadores; cabeza(i); end
End

Process cabeza(jugador);
Begin
	y=alto_pantalla/2;
	while(!exists(p[jugador].identificador)) frame; end
	file=p[jugador].identificador.file;
	size=70;
	z=-512;
	loop
		graph=p[jugador].identificador.graph;
		flags=p[jugador].identificador.flags;
		if(ancho_nivel>alto_nivel)
			if(ancho_nivel>ancho_pantalla) x=p[jugador].identificador.x/(ancho_nivel/ancho_pantalla); else break; end
		else
			if(ancho_nivel>ancho_pantalla) x=p[jugador].identificador.y/(alto_nivel/ancho_pantalla); else break; end
		end
		frame;
	end
End

Process transicion();
Begin
	graph=foto;
	x=ancho_pantalla;
	z=-512;
	set_center(0,graph,ancho_pantalla,0);
	while(angle<90000) gravedad+=200; angle+=gravedad; alpha-=2; frame; end
	unload_map(0,graph);
End

Process bomba();
Private
	contador;
	segundos;
Begin
	if(modo_juego==0) 
		contador=60*50; //60 segs, 50 fps
	else
		contador=5*50; //60 segs, 50 fps
	end
	segundos=contador/50;
	write_int(fuente,ancho_pantalla/2,alto_pantalla/2,4,&segundos);
	while(contador>0 and posiciones[jugadores]==0)
		contador--;
		segundos=contador/50;
		frame;
	end
	timer[2]=0;
	delete_text(all_text);
	num_nivel++;
	carga_nivel();
End

include "menu.pr-";
include "navegador.pr-";
#ifndef WII
include "editorniveles.pr-";
#endif
include "explosion.pr-";

include "../../common-src/savepath.pr-";
include "../../common-src/lenguaje.pr-";

//PROCESS MAIN
Begin
	if(argc>0) if(argv[1]=="arcade") arcade_mode=1; end end
	if(os_id==os_win32)
		editor_de_niveles=1;
		descarga_niveles=1;
		app_data=1;
	end

	set_title("PiX Dash");
	
	// Código aportado por Devilish Games / Josebita
	if(app_data)
		savepath();
	else
		//lo tenemos justo delante!
		savegamedir="";
		developerpath="";
	end

	/* pal futuro
	switch(lenguaje_sistema())
		case "es": ops.lenguaje=1; lang_suffix="es"; end
		case "it": ops.lenguaje=2; lang_suffix="it"; end
		case "de": ops.lenguaje=3; lang_suffix="de"; end
		case "fr": ops.lenguaje=4; lang_suffix="fr"; end
		default: ops.lenguaje=0; lang_suffix="en"; end
	end	
	*/
	
	configurar_controles();

	set_fps(0,0); //imágenes por segundo
	probar_pantalla();
	if(arcade_mode) full_screen=true; scale_resolution=08000600;end
	set_mode(800,600,16); //resolución y colores	    
	fpg_enemigos=load_fpg("fpg/enemigos.fpg"); //cargar el mapa de tiles
	fpg_powerups=load_fpg("fpg/powerups.fpg"); //cargar el mapa de tiles
	fpg_menu=load_fpg("fpg/menu.fpg"); //cargar el mapa de tiles
	fpg_moneda=load_fpg("fpg/moneda.fpg");
	fpg_durezas=load_fpg("fpg/durezas.fpg");

	fuente=load_fnt("fnt/fuente_peq.fnt");
	fuente_peq=load_fnt("fnt/fuente_peq.fnt");

	i=1;
	while(fexists("wav\"+i+".wav"));
		wavs[i]=load_wav("wav\"+i+".wav");
		i++;
	end
	
	if(os_id!=1000) 
		//editor_de_niveles();
		if(argc>1) importar_paquete_offline(); end
		menu();
		//carga_nivel(); //cargar el nivel
	else
		paqueteniveles="nel";
		jugadores=1;
		carga_nivel();
	end
End

Process cam_cooperativo();
Private
	cuantos_seguimos;
	antes_x;
	antes_y;
	antes_separados;
Begin
	cambia_regiones();
	loop
		antes_x=x; antes_y=y; antes_separados=num_separados;
		x=0; y=0; cuantos_seguimos=0; 
		num_separados=0;
		from i=1 to 8;
		//objetivo: que quede centrado en los jugadores, haciendo caso al que vaya más adelantado y que si hay separación, que se creen subregiones! :D
			if(exists(p[i].identificador) and p[i].identificador.accion!="ganando")
			  if(p[i].identificador.x>antes_x-(ancho_pantalla*0.6))
				x+=p[i].identificador.x;
				y+=p[i].identificador.y;
				cuantos_seguimos++;
			  else
			    num_separados++;
				separados[num_separados]=i;
			  end
			end
		end
		if(cuantos_seguimos!=0) //ocurre en la carga, ¿y en algún momento más?
			x=x/cuantos_seguimos;
			y=y/cuantos_seguimos;
		end
		//esto se supone que adelantará la cámara en caso de que uno se adelante
		from i=1 to 8;
			while(exists(p[i].identificador) AND p[i].identificador.accion!="ganando" AND x+((ancho_pantalla/2)*0.6)<p[i].identificador.x) x++; end
		end
		if(num_separados!=antes_separados) cambia_regiones(); end
		//AQUI LO DEJASTE PENSANDO EN COMO HACER PARA QUE LA CAMARA FUERA SUAVE
		frame;
	end
End

Function cambia_regiones();
Begin
	from i=0 to 8; stop_scroll(i); end
	switch(num_separados)
	  case 0: //todos juntos!
	  	if(alto_nivel<alto_pantalla) 
			define_region(1,0,(alto_pantalla/2)-(alto_nivel/2),ancho_pantalla,alto_nivel); 
			define_region(2,0,(alto_pantalla/2)-(alto_nivel/2),ancho_pantalla,alto_nivel); 
			define_region(3,0,(alto_pantalla/2)-(alto_nivel/2),ancho_pantalla,alto_nivel); 
			define_region(4,0,(alto_pantalla/2)-(alto_nivel/2),ancho_pantalla,alto_nivel); 
		else
			define_region(1,0,0,ancho_pantalla,alto_pantalla); 
			define_region(2,0,0,ancho_pantalla,alto_pantalla); 
			define_region(3,0,0,ancho_pantalla,alto_pantalla); 
			define_region(4,0,0,ancho_pantalla,alto_pantalla); 
		end
		start_scroll(1,0,mapa_scroll,fondo,1,0);
		//scroll[1].camera=id_cam;
		scroll[1].camera=father.id;

	    id_carganivel.graph=new_map(ancho_pantalla,alto_pantalla,16);
	  end
	  case 1:
		define_region(1,0,0,ancho_pantalla,alto_pantalla/2);
		start_scroll(1,0,mapa_scroll,fondo,1,0);
		scroll[1].camera=id_cam;
		
		define_region(2,0,alto_pantalla/2,ancho_pantalla,alto_pantalla);
		start_scroll(2,0,mapa_scroll,fondo,2,0);
		scroll[2].camera=p[separados[1]].identificador;
		
		id_carganivel.graph=new_map(ancho_pantalla,alto_pantalla,16);
		drawing_color(200);
		drawing_map(0,id_carganivel.graph);
		draw_box(0,alto_pantalla/2-5,ancho_pantalla,alto_pantalla/2+5);
	  end
	  default:
			define_region(1,0,0,ancho_pantalla/2,alto_pantalla/2);
			define_region(2,ancho_pantalla/2,0,ancho_pantalla,alto_pantalla/2);
			define_region(3,0,alto_pantalla/2,ancho_pantalla/2,alto_pantalla);
			define_region(4,ancho_pantalla/2,alto_pantalla/2,ancho_pantalla,alto_pantalla);
	
			start_scroll(1,0,mapa_scroll,fondo,1,0);
			scroll[1].camera=p[1].identificador;
			start_scroll(2,0,mapa_scroll,fondo,2,0);
			scroll[2].camera=p[2].identificador;
			start_scroll(3,0,mapa_scroll,fondo,3,0);
			scroll[3].camera=p[3].identificador;
			if(jugadores==4) 
				start_scroll(4,0,mapa_scroll,fondo,4,0);
				scroll[4].camera=p[4].identificador;
			end

			id_carganivel.graph=new_map(ancho_pantalla,alto_pantalla,16);
			drawing_color(200);
			drawing_map(0,id_carganivel.graph);
			draw_box(0,alto_pantalla/2-5,ancho_pantalla,alto_pantalla/2+5);
			draw_box(ancho_pantalla/2-5,0,ancho_pantalla/2+5,alto_pantalla);
		end
	end
	//if(ready==1 and !exists(type bomba)) set_fps(20,0); frame(2000); set_fps(50,0); end
End

Function alguiencerca();
Begin
	x=father.x;
	y=father.y;
	from i=1 to 4; 
		if(exists(p[i].identificador))
			if(get_dist(p[i].identificador)<ancho_pantalla*1.5)
				return 1; //ALGUIEN ESTÁ CERCA!
			end
		end
	end
	return 0; //No hay nadie cerca. Congelamos para ahorrarnos CPU! :)
End

function probar_pantalla();
begin
	if(os_id==1000) 
		scale_resolution=06400480; 
		ancho_pantalla=1066;
		alto_pantalla=600;
		return;
	end

    if(arcade_mode) ancho_pantalla=1024; alto_pantalla=768; scale_resolution=0; return; end

    if(mode_is_ok(1920,1080,16,MODE_WAITVSYNC+MODE_FULLSCREEN)) //Si soporta 1360x760 nativamente...
        ancho_pantalla=1920; alto_pantalla=1080; scale_resolution=0;
    elseif(mode_is_ok(1360,768,16,MODE_WAITVSYNC+MODE_FULLSCREEN)) //Si soporta 1360x760 nativamente...
        ancho_pantalla=1360; alto_pantalla=768; scale_resolution=0;
    elseif(mode_is_ok(1280,1024,16,MODE_WAITVSYNC+MODE_FULLSCREEN)) //Si soporta 1280x720 nativamente...
        ancho_pantalla=1280; alto_pantalla=720; scale_resolution=0;
    elseif(mode_is_ok(1280,720,16,MODE_WAITVSYNC+MODE_FULLSCREEN)) //Si soporta 1280x1024 nativamente...
        ancho_pantalla=1280; alto_pantalla=1024; scale_resolution=0;
    elseif(mode_is_ok(1024,768,16,MODE_WAITVSYNC+MODE_FULLSCREEN)) //Si soporta 1024x768 nativamente...
        ancho_pantalla=1280; alto_pantalla=1024; scale_resolution=0;
    elseif(mode_is_ok(800,600,16,MODE_WAITVSYNC+MODE_FULLSCREEN)) //Si soporta 800x600 nativamente...
        ancho_pantalla=1280; alto_pantalla=1024; scale_resolution=0;
    elseif(mode_is_ok(640,480,16,MODE_WAITVSYNC+MODE_FULLSCREEN)) //Si soporta 640x480 nativamente... lo escalamos desde 1280x1024.
        ancho_pantalla=1280; alto_pantalla=1024; scale_resolution=06400480;
    else //WIZ!!?!???
        ancho_pantalla=1280; alto_pantalla=1024; scale_resolution=03200240; //Si soporta 320x240... puf, ¿cómo hemos llegado a esto?
    end
end

include "../../common-src/controles.pr-";

//stubs necesarios temporalmente para Wii
#ifdef WII
function getenv(string basura); begin end
function exec(int basura1,string basura2,int basura3,pointer basura4); begin end
function set_title(string basura); begin end
function editor_de_niveles(); begin end
#endif
