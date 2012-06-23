Program plataformas;

//comentar las dos siguientes líneas para Wii
#ifndef WII
 #ifdef LINUX
  import "image";
 #endif
 #ifndef LINUX
  import "mod_image";
 #endif
#endif
import "mod_sys"; 

Global     
	arcade_mode=0;
	editor_de_niveles=0;
	descarga_niveles=0;
	cancion_mundo=0;
	app_data=0; //temporal, hasta que se puedan descargar niveles desde linux
	suelo;
	dur_pinchos;
	dur_muelle_arriba;
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

	modo_juego=0; //0: COMPETITIVO, 1: COOPERATIVO
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
		total_monedas;
		total_powerups;
		total_enemigos;
		total_muertes;
		total_mayorcombo;
		premios[5];
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
	fpg_premios;
	fpg_general;
	wavs[20];
	sonidos_niveles[20];
	tilesize=40;
	fondo;
	flash;
	fuente;
	fuente_peq;
	fuente_grande;
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
	string developerpath="/.PiXJuegos/PiXDash/";
	
	string paqueteniveles="";
	string nivel_titulo;
	string nivel_descripcion;
	string dir_juego;
	string ruta_navegador; //porque no funciona correctamente la funcion navegador devolviendo un string
End 

Local
	jugador;
	powerup;
	powerup_id;
	gravedad;
	inercia;
	ancho;
	alto;
	string accion;
	i; j;
	tiempo_powerup;
	saltando;
End

function int csv_int(string estring,int num_campo);
private
	string temp;
	w;
	campo_actual;
begin
	from w=0 to len(estring);
		if(estring[w]!=",")
			temp+=""+estring[w];
		else
			if(campo_actual==num_campo)
				break;
			else
				temp="";
				campo_actual++;
			end
		end
	end
	return atoi(temp);
end

function string hasta_la_coma(string estring,int num_campo);
private
	string temp;
	w;
	campo_actual;
begin
	from w=0 to len(estring);
		if(estring[w]!=",")
			temp+=""+estring[w];
		else
			if(campo_actual==num_campo)
				break;
			else
				temp="";
				campo_actual++;
			end
		end
	end
	return temp;
end

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
	id_col;
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
		if(p[jugador].botones[1]) //la inercia sube al ir hacia la derecha
			flags=0;
			if(p[jugador].botones[4])
				if(inercia<20) inercia+=2; end
			else
				if(inercia<10) inercia+=2; end
			end
		end
		if(p[jugador].botones[0]) //la inercia baja al ir hacia la izquierda
			flags=1;
			if(p[jugador].botones[4])
				if(inercia>-20) inercia-=2; end
			else
				if(inercia>-10) inercia-=2; end
			end
		end

		if(p[jugador].botones[5] and pulsando==0 and saltando==0) saltando=1; sonido(5,jugador); saltogradual=1; gravedad=-15; pulsando=1; y--; end 
		//al saltar suena el sonido correspondiente y se aplica la gravedad, y el salto gradual si saltamos poco 
		if(p[jugador].botones[5] and pulsando==0 and powerup==3 and tiempo_powerup>0 and doble_salto==0) sombra_doble_salto(); sonido(12,jugador); saltogradual=1; doble_salto=1; gravedad=-15; pulsando=1; y--; end
		//e l doblesalto si disponemos del power-up 3
		if(p[jugador].botones[5] and saltogradual<5 and saltogradual!=0) gravedad-=4; saltogradual++; end
		if(saltogradual>0 and p[jugador].botones[5]==0 and gravedad<-10 and accion!="lanzado") saltogradual=0; gravedad=-10; end
		if(!p[jugador].botones[5] and pulsando==1) pulsando=0; saltogradual=0; end
		if((map_get_pixel(0,durezas,x,y+alto)==suelo or map_get_pixel(0,durezas,x-(ancho/3),y+alto)==suelo or map_get_pixel(0,durezas,x+(ancho/3),y+alto)==suelo) and gravedad=>0)
			if(accion=="lanzado") accion=""; end
			gravedad=0; 
			saltando=0; 
			doble_salto=0; 
		else
			if(gravedad=>0)
				if(id_col=collision(type plataforma))
					if(id_col.y>y+20)
						if(accion=="lanzado") accion=""; end
						gravedad=0;
						saltando=0;
						doble_salto=0;
					else
						saltando=1; 
						gravedad++;
					end
				else
					saltando=1; 
					gravedad++;
				end
			else
				saltando=1; 
				gravedad++;
			end
		end //al tocar el suelo, gravedad es 0
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
			switch(posicion)
				case 1: p[jugador].puntos+=6; sonido(17,jugador); end
				case 2: p[jugador].puntos+=4; end
				case 3: p[jugador].puntos+=2; end
				case 4: p[jugador].puntos++; end
			end
			if(jugadores>1 and modo_juego==0) miposicion(jugador,posicion); end
			if(jugadores<=2)
				if(jugador==1) pon_tiempo(p[i].tiempos[num_nivel],1,(ancho_pantalla/4)*3,(alto_pantalla/4)-100,jugador); end
				if(jugador==2) pon_tiempo(p[i].tiempos[num_nivel],1,(ancho_pantalla/4)*3,((alto_pantalla/4)*3)-100,jugador); end
			end
			if(jugadores>2)
				if(jugador==1) pon_tiempo(p[i].tiempos[num_nivel],1,(ancho_pantalla/8)*3,(alto_pantalla/4)-100,jugador); end
				if(jugador==2) pon_tiempo(p[i].tiempos[num_nivel],1,(ancho_pantalla/8)*7,(alto_pantalla/4)-100,jugador); end
				if(jugador==3) pon_tiempo(p[i].tiempos[num_nivel],1,(ancho_pantalla/8)*3,((alto_pantalla/4)*3)-100,jugador); end
				if(jugador==4) pon_tiempo(p[i].tiempos[num_nivel],1,(ancho_pantalla/8)*7,((alto_pantalla/4)*3)-100,jugador); end
			end
			
			graph=0;
			loop
				accion="ganando";
				frame; 
			end //aquí se queda!
		end //al ganar mike canta y nos damos la vuelta xD
		if(gravedad==0)
			if(inercia>0) inercia--; end
			if(inercia<0) inercia++; end
//		else
			//if(inercia>0) inercia-=0.3; end
			//if(inercia<0) inercia+=0.3; end
			//if(inercia<0.3 or inercia>-0.3) inercia=0; end
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
		if(map_get_pixel(0,durezas,x,y)==dur_muelle_arriba or map_get_pixel(0,durezas,x,y+alto)==dur_muelle_arriba or map_get_pixel(0,durezas,x,y-alto)==dur_muelle_arriba or
			map_get_pixel(0,durezas,x-ancho,y)==dur_muelle_arriba or map_get_pixel(0,durezas,x+ancho,y)==dur_muelle_arriba) doble_salto=0; gravedad=-40; y--; end
	
		if(x<10) x=10; end //pa no salirse de la pantalla por la izquierda

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
			if(p[jugador].combo!=0) 
				if(p[jugador].combo>p[jugador].mejorcombo)
					p[jugador].mejorcombo=p[jugador].combo;
				end
				p[jugador].combo=0;
			end
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
				sonido(6,jugador);
				frame(3000);
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
				p[jugador].muertes++;
				accion="";
				gravedad=0;
				inercia=0;
				//ready=1;
			else 
				accion=""; 
			end 
		end
		if(modo_juego==0 and (id_colision=collision(type prota))) 
			if(id_colision.accion!="muerte")
				if(id_colision>id)
					sonido(13,jugador);
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
		if(inercia>25 or inercia<-25) sombra(20); end
		if(y<-20) flecha_personaje(); end
		if(y<-1000) y=-1000; end
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
Process enemigo(x,y,tipo,flags);
Private
	id_colision;
	x_original;
	y_original;
	anim_base;
	frames_anim;
	anim;
	spikys;
	x_destino;
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
		if(tipo==8 and rand(0,200)==0 and spikys<10) spikys++; enemigo(x,y,9,0); end //lakitu tirando pinchones
		if(accion!="lanzado")
			if(flags==0) 
				if(tipo!=8) 
					inercia=-2; 
				else 
					inercia=-6; 
				end //los malos andan pa un lao
			else  
				if(tipo!=8) 
					inercia=2; 
				else 
					inercia=6; 
				end 
			end	//si miramos pa un lao, andamos pa ese, sino viceversa
		else
			//..
		end
		if(tipo==8 and rand(0,300)==0) if(flags==0) flags=1; else flags=0; end end //cuando mira lakitu pa la derecha al azar
		if(map_get_pixel(0,durezas,x,y+alto)==suelo and tipo!=8 and gravedad>0) //el malo tocó el suelo? lakitu no choca wei!
			if(accion=="lanzado") accion=""; end
			if(tipo==9) enemigo(x,y, tipo-4,0); break; end //los huevos de spiky tocan el suelo, mueren y llaman a los spikys
			if(tipo==2 or tipo==4 or tipo==10) gravedad=-40; y--; else gravedad=0; end //saltos para los para-algo, sino quietos nel suelo
		else 
			gravedad++; //pos no lo tocó
		end //gravedad
		if(y>alto_nivel or y<0) break; end //si cae por un bujero, muere
		while(map_get_pixel(0,durezas,x,y+alto-1)==suelo and tipo!=7 and tipo!=8) y--; end //corregimos atravesamiento de suelos...

		if(alpha==255 and (id_colision=collision(type prota))) //chocamos con el prota
			if(id_colision.y<y-(alto/2) and id_colision.saltando==1 and tipo!=5 and tipo!=6 and tipo!=9 and tipo!=10 and id_colision.accion!="muerte") //si el prota está más arriba, el malo muere. a menos que sean spikis o sus huevos! y que no esté muriendo el prota xD
				p[id_colision.jugador].enemigosmatados++;
				p[id_colision.jugador].combo++;
				if(p[id_colision.jugador].botones[5])
					id_colision.gravedad=-30; //rebota mucho el prota
				else
					id_colision.gravedad=-20; //rebota el prota
				end
				if(tipo!=2 and tipo!=4)  //animacion de la muerte, salvo que sean para-algo
					explotalo(x,y,z,255,0,file,graph,60);
				end
				if(tipo==2 or tipo==4) accion="renacer"; enemigo(x,y,tipo-1,0); end //los para-algo llamando a los correspondientes malos cuando los pisas
				frame;
				break; //suicidamos al malo
			else //el prota chocó por debajo de la altura del enemigo
				if(id_colision.powerup==1) 
					p[id_colision.jugador].enemigosmatados++;
					p[id_colision.jugador].combo++;
					if(p[id_colision.jugador].botones[5])
						id_colision.gravedad=-30; //rebota mucho el prota
					else
						id_colision.gravedad=-20; //rebota el prota
					end
					if(tipo!=2 and tipo!=4)  //animacion de la muerte, salvo que sean para-algo
						explotalo(x,y,z,255,0,file,graph,60);
					end
					if(tipo==2 or tipo==4) enemigo(x,y,tipo-1,0); end
					frame;
					break; //suicidamos al malo
				else
					id_colision.accion="muerte"; //el prota muere
				end
			end
		end
		
		//gestión de inercia
		x_destino=x+(inercia/2);
		if(x_destino>x)
			from x=x to x_destino step 1; if(map_get_pixel(0,durezas,x+ancho,y+alto/2)==suelo) inercia=0; break; end end
		elseif(x_destino<x)
			from x=x to x_destino step -1; if(map_get_pixel(0,durezas,x-ancho,y+alto/2)==suelo) inercia=0; break; end end
		end //calculamos donde se para si tiene inercia y dejas de correr
		
		if(map_get_pixel(0,durezas,x,y)==dur_pinchos or map_get_pixel(0,durezas,x,y+alto)==dur_pinchos or map_get_pixel(0,durezas,x,y-alto)==dur_pinchos or
		map_get_pixel(0,durezas,x-ancho,y)==dur_pinchos or map_get_pixel(0,durezas,x+ancho,y)==dur_pinchos) 
			explotalo(x,y,z,255,0,file,graph,60);
			break; 
		end
		if(map_get_pixel(0,durezas,x,y)==dur_muelle_arriba or map_get_pixel(0,durezas,x,y+alto)==dur_muelle_arriba or map_get_pixel(0,durezas,x,y-alto)==dur_muelle_arriba or
			map_get_pixel(0,durezas,x-ancho,y)==dur_muelle_arriba or map_get_pixel(0,durezas,x+ancho,y)==dur_muelle_arriba) gravedad=-40; y--; end

		if(tipo!=7 and tipo!=8) y=y+(gravedad/4); end //gravedad barata. a billbala y a lakitu no les afecta
		if(slowmotion==0) frame; else frame(300); end
		//frame;
    end	
	if(tipo==7) enemigo(x_original,y_original,tipo,0); end
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
	alpha=0;
	while(collision(type prota)) frame(3000); end
    loop
		if(alpha<255) alpha+=5; end
		if(!alguiencerca()) frame(10000); end
		if(map_get_pixel(0,durezas,x,y+alto)!=suelo) y+=6; end 
		if(map_get_pixel(0,durezas,x,y+alto)==dur_pinchos) break; end 
		while(map_get_pixel(0,durezas,x,y+alto-1)==suelo) y--; end //colisiones con el suelo
		if(y>alto_nivel) break; end //al caer poir un bujero los power-ups desaparecen
		if(id_colision=collision(type prota)) //al tocarlos el prota
			sonido(16,0);
			if(id_colision.accion!="muerte")
				p[id_colision.jugador].powerupscogidos++;
				if(modo_juego==0)
					id_colision.powerup=tipo; //se activa el power-up
					id_colision.tiempo_powerup=10*50; //se ajusta el tiempo del power-up
					id_colision.powerup_id=id;
				end
				if(modo_juego==1)
					from i=1 to jugadores;
						p[i].identificador.powerup_id=id;
						p[i].identificador.powerup=tipo; //se activa el power-up
						p[i].identificador.tiempo_powerup=10*50; //se ajusta el tiempo del power-up
					end
				end
				tiempo_powerup=10*50;
				
				while(alpha>0 and id_colision.powerup==tipo and id_colision.powerup_id==id and x<ancho_nivel) //la animación en la que aparece detrás del prota
					x=id_colision.x;
					y=id_colision.y;
					alpha=30+(tiempo_powerup/2);
					if(tiempo_powerup<30)
						if(_mod(tiempo_powerup,3)==3)
							if(alpha==255) alpha=128; else alpha=255; end
						end
					end
					tiempo_powerup--;
					z=1;
					if(tipo==4) slowmotion=1; end
					frame;
				end
				if(id_colision.powerup_id==id and x<ancho_nivel) sonido(15,0); end
				if(tipo==4) slowmotion=0; end
				break;
			end
		end
		frame;
	end
	if(x<ancho_nivel) explotalo(x,y,z,255,0,file,graph,60); end
	powerups(x_orig,y_orig,tipo);
End

Process flecha_personaje();
Begin
	ctype=father.ctype;
	flags=father.flags;
	file=father.file;
	z=father.z;
	x=father.x;
	y=50;
	graph=father.graph;
	size=70;
	angle=father.angle;
	flecha_personaje2();
	frame;
End

Process flecha_personaje2();
Begin
	ctype=father.ctype;
	file=fpg_general;
	z=father.z+1;
	x=father.x;
	y=50;
	graph=5;
	frame;
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
				sonido(4,id_colision.jugador);
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
	fp;
	string linea;
BEGIN
	id_carganivel=id;
	if(num_nivel!=1)
		from i=1 to 4;
			posiciones[i]=0;
			if(p[i].total_mayorcombo<p[i].mejorcombo) p[i].total_mayorcombo=p[i].mejorcombo; end
			p[i].total_monedas+=p[i].monedas;
			p[i].total_powerups+=p[i].powerupscogidos;
			p[i].total_enemigos+=p[i].enemigosmatados;
			p[i].total_muertes+=p[i].muertes;
			p[i].mejorcombo=0;
			p[i].combo=0;
			p[i].monedas=0;
			p[i].powerupscogidos=0;
			p[i].enemigosmatados=0;
			p[i].muertes=0;
			from j=1 to 5;
				p[i].premios[j]=0;
			end
		end
	else //nivel 1:
		i=1;
		while(fexists(savegamedir+"niveles\"+paqueteniveles+"\"+i+".wav"));
			sonidos_niveles[i]=load_wav(savegamedir+"niveles\"+paqueteniveles+"\"+i+".wav");
			i++;
		end
	end

	if(fexists(savegamedir+"niveles\"+paqueteniveles+"\nivel"+num_nivel+".txt"))
		i=1;
		fichero=fopen(savegamedir+"niveles\"+paqueteniveles+"\nivel"+num_nivel+".txt",O_READ);	
		nivel_titulo=fgets(fichero);
		nivel_descripcion=fgets(fichero);
		fclose(fichero);
		i=0;
	end

	if(!file_exists(savegamedir+"niveles\"+paqueteniveles+"\nivel"+num_nivel+".png"))  // FIN DE LA COMPETICION
		//resultados();
		menu(); 
		return; 
	end
	frame;
	if(num_nivel!=1) 
		foto=get_screen(); 
		put_screen(0,foto);
	end
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
	dur_muelle_arriba=map_get_pixel(fpg_durezas,504,0,0);
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
		
		from i=1 to 10; if(tile==enemigos[i]) enemigo(pos_x+(tilesize/2),pos_y+(tilesize/2),i,0); end end
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

//NUEVO: LISTA DE OBJETOS EN UN FICHERO APARTE
	if(fexists(savegamedir+"niveles\"+paqueteniveles+"\nivel"+num_nivel+".obj"))
		fp=fopen(savegamedir+"niveles\"+paqueteniveles+"\nivel"+num_nivel+".obj",O_READ);
		while(!feof(fp))
			linea=fgets(fp);
			if(hasta_la_coma(linea,0)=="plataforma")
				plataforma(tile_a_coordenada(csv_int(linea,1)),tile_a_coordenada(csv_int(linea,2)),csv_int(linea,3),tile_a_coordenada(csv_int(linea,4)),csv_int(linea,5));
			end
			if(hasta_la_coma(linea,0)=="muelle")
				muelle(tile_a_coordenada(csv_int(linea,1)),tile_a_coordenada(csv_int(linea,2)),csv_int(linea,3),csv_int(linea,4));
			end
			if(hasta_la_coma(linea,0)=="enemigo")
				enemigo(tile_a_coordenada(csv_int(linea,1)),tile_a_coordenada(csv_int(linea,2)),csv_int(linea,3),csv_int(linea,4));
			end
			if(hasta_la_coma(linea,0)=="powerup")
				powerups(tile_a_coordenada(csv_int(linea,1)),tile_a_coordenada(csv_int(linea,2)),csv_int(linea,3));
			end
			if(hasta_la_coma(linea,0)=="moneda")
				moneda(tile_a_coordenada(csv_int(linea,1)),tile_a_coordenada(csv_int(linea,2)));
			end
			if(hasta_la_coma(linea,0)=="sonido")
				sonador(tile_a_coordenada(csv_int(linea,1)),tile_a_coordenada(csv_int(linea,2)),csv_int(linea,3));
			end

			i++;
		end
		fclose(fp);
	end
//----

	flash=new_map(ancho_pantalla,alto_pantalla,8);
	drawing_color(suelo);
	drawing_map(0,flash);
	draw_box(0,0,ancho_pantalla,alto_pantalla);

	//si solo hay un jugador, no podrá ser modo competitivo
	if(jugadores==1) modo_juego=1; else modo_juego=0; end
	
	if(modo_juego==0) //competitivo: 4 pantallas
		if(jugadores<=2) //definir la pantalla partida y la división al ser 2 jugadores
			define_region(1,0,0,ancho_pantalla,alto_pantalla/2);
			define_region(2,0,alto_pantalla/2,ancho_pantalla,alto_pantalla);
	
			start_scroll(0,0,mapa_scroll,fondo,1,4);
			scroll[0].camera=prota(1);
			start_scroll(1,0,mapa_scroll,fondo,2,4);
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
	
			start_scroll(0,0,mapa_scroll,fondo,1,4);
			scroll[0].camera=prota(1);
			start_scroll(1,0,mapa_scroll,fondo,2,4);
			scroll[1].camera=prota(2);
			start_scroll(2,0,mapa_scroll,fondo,3,4);
			scroll[2].camera=prota(3);
			start_scroll(3,0,mapa_scroll,fondo,4,4);
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
	if(!cancion_mundo) stop_song(); end
	clear_screen();
	transicion();
	//TEXTO PRESENTACION NIVEL:
	write(fuente,ancho_pantalla/2,(alto_pantalla/4),4,nivel_titulo);
	write(fuente_peq,ancho_pantalla/2,(alto_pantalla/4)+50,4,nivel_descripcion);
	//3 2 1 YA:
	from i=3 to 1 step -1;
		timer[0]=0;
		graph=write_in_map(fuente_grande,i,4);
		sonido(10,0);
		if(key(_n)) while(key(_n)) frame; end num_nivel++; carga_nivel(); end
		while(timer[0]<100) alpha-=4; size++; frame; end
		size=100;
		alpha=255;
	end
	sonido(11,0);
	delete_text(all_text);
	graph=write_in_map(fuente_grande,"YA",4);
	if(modo_juego==0) marcadores(); end //marcadores de puntos en modo competición
	//texto=write(fuente_grande,ancho_pantalla/2,alto_pantalla/2,4,"YA");
	ready=1;
	timer[0]=0;
	timer[1]=0; //para contrarreloj
	if(ops.musica)
		if(fexists(savegamedir+"niveles\"+paqueteniveles+"\mundo.ogg")) //si existe cancion de mundo
			if(!is_playing_song())
				cancion_mundo=1;
				play_song(load_song(savegamedir+"niveles\"+paqueteniveles+"\mundo.ogg"),-1);
			end
		else
			if(fexists(savegamedir+"niveles\"+paqueteniveles+"\nivel"+num_nivel+".ogg")) //si existe 
				play_song(load_song(savegamedir+"niveles\"+paqueteniveles+"\nivel"+num_nivel+".ogg"),-1);
			else
				play_song(load_song("ogg\"+rand(1,5)+".ogg"),-1);
			end
		end
	end
	if(jugadores>1) 
		pon_tiempo(-1,0,(ancho_pantalla/4)*3,alto_pantalla/2,1);
	else
		pon_tiempo(-1,0,(ancho_pantalla/4)*3,60,1);
	end
	controlador(0);
	loop
		if(key(_n)) while(key(_n)) frame; end num_nivel++; carga_nivel(); end
		if(p[0].botones[7]) while(p[0].botones[7]) frame; end menu(); end
		if(timer[0]>100 and alpha>0)
			alpha-=5;
			size++;
			//delete_text(texto); texto=0; 
		end
		if(jugadores==3 and ((!exists(scroll[3].camera)) or scroll[3].camera==0 or rand(0,500)==333)) scroll[3].camera=get_id(type enemigo); end
//		if(jugadores==1 and ((!exists(scroll[1].camera)) or scroll[1].camera==0 or rand(0,500)==333)) scroll[1].camera=get_id(type enemigo); end
		frame;
	end 
END

//ganar, muerte, salto
Process sonido(numsonido,canal);
Begin
	if(numsonido==6) numsonido+=father.jugador-1; end
	if(ops.sonido) play_wav(wavs[numsonido],0,canal); end
End

Process pon_tiempo(tiempo,permanecer,x,y,jugador);
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
	from i=1 to 5; premio(i); end
	if(jugadores==2)
		write(fuente,20,20,0,"Puntos:");
		write(fuente,20,(alto_pantalla/2)+20,0,"Puntos:");
		write_int(fuente,190,20,0,&p[1].puntos);
		write_int(fuente,190,(alto_pantalla/2)+20,0,&p[2].puntos);
	end
	if(jugadores=>3)
		write(fuente,20,20,0,"Puntos:");
		write(fuente,(ancho_pantalla/2)+20,20,0,"Puntos:");
		write(fuente,20,(alto_pantalla/2)+20,0,"Puntos:");
		if(jugadores==4) write(fuente,(ancho_pantalla/2)+20,(alto_pantalla/2)+20,0,"Puntos:"); end
		
		write_int(fuente,190,20,0,&p[1].puntos);
		write_int(fuente,(ancho_pantalla/2)+190,20,0,&p[2].puntos);
		write_int(fuente,190,(alto_pantalla/2)+20,0,&p[3].puntos);
		if(jugadores==4) write_int(fuente,(ancho_pantalla/2)+190,(alto_pantalla/2)+20,0,&p[4].puntos); end
	end
	from i=1 to jugadores; cabeza(i); end
End

//1: >combo, 2: >monedas, 3: <powerups, 4: >enemigosmatados, 5: <muertes
Process premio(tipo);
Private
	jugador_anterior;
	id_col;
	x_destino;
	y_destino;
	contador;
	h;
	string texto_premio;
	x_texto;
	y_texto;
Begin
	file=fpg_premios;
	graph=tipo;
	i=tipo; //esto lo utilizaremos para ordenar los premios de un jugador
	z=-tipo;
	size=50;
	x=-100; y=-100;
	loop
		contador=0;
		jugador=0;
		switch(tipo)
			case 1:
				if(p[1].mejorcombo>p[2].mejorcombo and p[1].mejorcombo>p[3].mejorcombo and p[1].mejorcombo>p[4].mejorcombo) jugador=1; end
				if(p[2].mejorcombo>p[1].mejorcombo and p[2].mejorcombo>p[3].mejorcombo and p[2].mejorcombo>p[4].mejorcombo) jugador=2; end
				if(p[3].mejorcombo>p[1].mejorcombo and p[3].mejorcombo>p[2].mejorcombo and p[3].mejorcombo>p[4].mejorcombo) jugador=3; end
				if(p[4].mejorcombo>p[1].mejorcombo and p[4].mejorcombo>p[2].mejorcombo and p[4].mejorcombo>p[3].mejorcombo) jugador=4; end
			end
			case 2:
				if(p[1].monedas>p[2].monedas and p[1].monedas>p[3].monedas and p[1].monedas>p[4].monedas) jugador=1; end
				if(p[2].monedas>p[1].monedas and p[2].monedas>p[3].monedas and p[2].monedas>p[4].monedas) jugador=2; end
				if(p[3].monedas>p[1].monedas and p[3].monedas>p[2].monedas and p[3].monedas>p[4].monedas) jugador=3; end
				if(p[4].monedas>p[1].monedas and p[4].monedas>p[2].monedas and p[4].monedas>p[3].monedas) jugador=4; end
			end
			case 3:
				if(p[1].powerupscogidos<p[2].powerupscogidos and (p[1].powerupscogidos<p[3].powerupscogidos xor jugadores<3) and (p[1].powerupscogidos<p[4].powerupscogidos xor jugadores<4)) jugador=1; end
				if(p[2].powerupscogidos<p[1].powerupscogidos and (p[2].powerupscogidos<p[3].powerupscogidos xor jugadores<3) and (p[2].powerupscogidos<p[4].powerupscogidos xor jugadores<4)) jugador=2; end
				if(jugadores>2 and p[3].powerupscogidos<p[1].powerupscogidos and p[3].powerupscogidos<p[2].powerupscogidos and (p[3].powerupscogidos<p[4].powerupscogidos xor jugadores<4)) jugador=3; end
				if(jugadores==4 and p[4].powerupscogidos<p[1].powerupscogidos and p[4].powerupscogidos<p[2].powerupscogidos and p[4].powerupscogidos<p[3].powerupscogidos) jugador=4; end
			end
			case 4:
				if(p[1].enemigosmatados>p[2].enemigosmatados and p[1].enemigosmatados>p[3].enemigosmatados and p[1].enemigosmatados>p[4].enemigosmatados) jugador=1; end
				if(p[2].enemigosmatados>p[1].enemigosmatados and p[2].enemigosmatados>p[3].enemigosmatados and p[2].enemigosmatados>p[4].enemigosmatados) jugador=2; end
				if(p[3].enemigosmatados>p[1].enemigosmatados and p[3].enemigosmatados>p[2].enemigosmatados and p[3].enemigosmatados>p[4].enemigosmatados) jugador=3; end
				if(p[4].enemigosmatados>p[1].enemigosmatados and p[4].enemigosmatados>p[2].enemigosmatados and p[4].enemigosmatados>p[3].enemigosmatados) jugador=4; end
			end
			case 5:
				if(p[1].muertes<p[2].muertes and (p[1].muertes<p[3].muertes xor jugadores<3) and (p[1].muertes<p[4].muertes xor jugadores<4)) jugador=1; end
				if(p[2].muertes<p[1].muertes and (p[2].muertes<p[3].muertes xor jugadores<3) and (p[2].muertes<p[4].muertes xor jugadores<4)) jugador=2; end
				if(jugadores>2 and p[3].muertes<p[1].muertes and p[3].muertes<p[2].muertes and (p[3].muertes<p[4].muertes xor jugadores<4)) jugador=3; end
				if(jugadores==4 and p[4].muertes<p[1].muertes and p[4].muertes<p[2].muertes and p[4].muertes<p[3].muertes) jugador=4; end
			end
		end
	
		if(jugador!=jugador_anterior)
			sonido(14,0);
			if(jugadores==2)
				x_destino=ancho_pantalla-40;
				if(jugador==1)
					y_destino=(alto_pantalla/2)-30;
				else
					y_destino=alto_pantalla-30;
				end
			else
				if(jugador==1 or jugador==3)
					x_destino=(ancho_pantalla/2)-25;
				end
				if(jugador==2 or jugador==4)
					x_destino=ancho_pantalla-25;
				end
				if(jugador==1 or jugador==2)
					y_destino=(alto_pantalla/2)-25;
				end
				if(jugador==3 or jugador==4)
					y_destino=alto_pantalla-25;
				end
			end
			if(jugador==0)
				from alpha=255 to 50 step -10; size+=5; frame; end 
				x=-100; y=-100; alpha=255;
			else
				if(jugador_anterior!=0)
					while(x!=x_destino or y!=y_destino)
						if(x_destino<x)
							x-=5+((x-x_destino)/10);
							if(x_destino>x) x=x_destino; end
						else
							x+=5+((x_destino-x)/10);
							if(x_destino<x) x=x_destino; end
						end
						if(y_destino<y)
							y-=5+((y-y_destino)/10);
							if(y_destino>y) y=y_destino; end
						else
							y+=5+((y_destino-y)/10);
							if(y_destino<y) y=y_destino; end
						end
						frame;
					end
				else
					x=x_destino;
					y=y_destino;
					alpha=155;
					from size=100 to 50 step -1; alpha+=10; frame; end
				end
			end
		end
		jugador_anterior=jugador;
		if(x_destino==x and (id_col=collision(type premio)))
			if(id_col.i>tipo)
				if(jugadores==2) 
					x_destino=x-40; 
				else
					x_destino=x-35; 
				end
			end 
		end
		if(x_destino<x)
			x-=5+((x-x_destino)/10);
			if(x_destino>x) x=x_destino; end
		else
			x+=5+((x_destino-x)/10);
			if(x_destino<x) x=x_destino; end
		end
		if(jugador!=0 and p[jugador].identificador.accion=="ganando")
			from size=50 to 60 step 5; frame; end
			size=60;
			from j=1 to 5;
				if(p[jugador].premios[j]==0)
					p[jugador].premios[j]=tipo;
					switch(tipo)   //1: >combo, 2: >monedas, 3: <powerups, 4: >enemigosmatados, 5: <muertes
						case 1: texto_premio="Mayor combo realizado +2pts"; end
						case 2: texto_premio="Mas monedas recogidas +2pts"; end
						case 3: texto_premio="Menos estrellas recogidas +2pts"; end
						case 4: texto_premio="Mas enemigos aniquilados +2pts"; end
						case 5: texto_premio="Menos muertes +2pts"; end
					end
					if(jugadores==2)
						x_texto=ancho_pantalla/2;
						if(jugador==1)
							y_texto=alto_pantalla/4;
						else
							y_texto=(alto_pantalla/4)*3;
						end
					else
						if(jugador==1 or jugador==3)
							x_texto=ancho_pantalla/4;
						else
							x_texto=(ancho_pantalla/4)*3;
						end
						if(jugador==1 or jugador==2)
							y_texto=alto_pantalla/4;
						else
							y_texto=(alto_pantalla/4)*3;
						end
					end
					write(fuente,x_texto,y_texto+(30*j),4,texto_premio);
					p[jugador].puntos+=2;
					break;
				end
			end
			loop
				frame;
			end
		end
		frame;
	end
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
		contador=20*50; //20 segs, 50 fps
	else
		contador=5*50; //5 segs, 50 fps
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
		//app_data=1;
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
	carga_opciones();
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
	//if(arcade_mode) full_screen=true; ancho_pantalla=1280; alto_pantalla=1024; end
	full_screen=1; //TEMP
	//if(scale_resolution>10000000) scale_resolution=0; end //TEMP
	//set_mode(800,600,16,WAITVSYNC); //resolución y colores	    
	set_mode(ancho_pantalla,alto_pantalla,16,WAITVSYNC); //resolución y colores	    
	fpg_premios=load_fpg("fpg/premios.fpg"); //cargar el mapa de tiles
	fpg_enemigos=load_fpg("fpg/enemigos.fpg"); //cargar el mapa de tiles
	fpg_powerups=load_fpg("fpg/powerups.fpg"); //cargar el mapa de tiles
	fpg_menu=load_fpg("fpg/menu.fpg"); //cargar el mapa de tiles
	fpg_moneda=load_fpg("fpg/moneda.fpg");
	fpg_durezas=load_fpg("fpg/durezas.fpg");
	fpg_general=load_fpg("fpg/general.fpg");

	fuente=load_fnt("fnt/fuente_peq.fnt");
	fuente_peq=load_fnt("fnt/fuente_peq.fnt");
	fuente_grande=load_fnt("fnt/fuente_grande.fnt");

	i=1;
	while(fexists("wav\"+i+".wav"));
		wavs[i]=load_wav("wav\"+i+".wav");
		i++;
	end

//TEST:
		paqueteniveles="test";
		jugadores=1;
		carga_nivel();

	
/*	if(os_id!=1000) 
		//editor_de_niveles();
		if(argc>1 and argv[1]!="arcade") importar_paquete_offline(); end
		menu();
		//carga_nivel(); //cargar el nivel
	else
		paqueteniveles="nel";
		jugadores=1;
		carga_nivel();
	end*/
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
		start_scroll(1,0,mapa_scroll,fondo,1,4);
		//scroll[1].camera=id_cam;
		scroll[1].camera=father.id;

	    id_carganivel.graph=new_map(ancho_pantalla,alto_pantalla,16);
	  end
	  case 1:
		define_region(1,0,0,ancho_pantalla,alto_pantalla/2);
		start_scroll(1,0,mapa_scroll,fondo,1,4);
		scroll[1].camera=id_cam;
		
		define_region(2,0,alto_pantalla/2,ancho_pantalla,alto_pantalla);
		start_scroll(2,0,mapa_scroll,fondo,2,4);
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
	
			start_scroll(1,0,mapa_scroll,fondo,1,4);
			scroll[1].camera=p[1].identificador;
			start_scroll(2,0,mapa_scroll,fondo,2,4);
			scroll[2].camera=p[2].identificador;
			start_scroll(3,0,mapa_scroll,fondo,3,4);
			scroll[3].camera=p[3].identificador;
			if(jugadores==4) 
				start_scroll(4,0,mapa_scroll,fondo,4,4);
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
			//if(get_dist(p[i].identificador)<ancho_pantalla*1.5)
			if(p[i].identificador.x>x-(ancho_pantalla*1.5) or p[i].identificador.x<x+(ancho_pantalla*1.5))
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

	if(mode_is_ok(1280,1024,16,MODE_WAITVSYNC+MODE_FULLSCREEN)) //Si soporta 1280x720 nativamente...
        ancho_pantalla=1280; alto_pantalla=1024; scale_resolution=12801024;
    elseif(mode_is_ok(1280,720,16,MODE_WAITVSYNC+MODE_FULLSCREEN)) //Si soporta 1280x1024 nativamente...
        ancho_pantalla=1280; alto_pantalla=720; scale_resolution=12800720;
    elseif(mode_is_ok(1024,768,16,MODE_WAITVSYNC+MODE_FULLSCREEN)) //Si soporta 1024x768 nativamente...
        ancho_pantalla=1280; alto_pantalla=1024; scale_resolution=10240768;
    elseif(mode_is_ok(800,600,16,MODE_WAITVSYNC+MODE_FULLSCREEN)) //Si soporta 800x600 nativamente...
        ancho_pantalla=1280; alto_pantalla=1024; scale_resolution=08000600;
    elseif(mode_is_ok(640,480,16,MODE_WAITVSYNC+MODE_FULLSCREEN)) //Si soporta 640x480 nativamente... lo escalamos desde 1280x1024.
        ancho_pantalla=1280; alto_pantalla=1024; scale_resolution=06400480;
    else //WIZ!!?!???
        ancho_pantalla=1280; alto_pantalla=1024; scale_resolution=03200240; //Si soporta 320x240... puf, ¿cómo hemos llegado a esto?
    end
end

Process miposicion(jugador,graph);
Begin
	file=fpg_general;
	z=-5;
	if(jugadores==2)
		x=ancho_pantalla/2;
		if(jugador==1)
			y=alto_pantalla/4;
		else
			y=(alto_pantalla/4)*3;
		end
	else
		if(jugador==1 or jugador==3)
			x=ancho_pantalla/4;
		else
			x=(ancho_pantalla/4)*3;
		end
		if(jugador==1 or jugador==2)
			y=alto_pantalla/4;
		else
			y=(alto_pantalla/4)*3;
		end
	end
	y-=60;
	from alpha=0 to 255 step 20; frame; end
	loop
		frame;
	end
End

Process muelle(x,y,direccion,potencia); //direccion 1:arriba,2:der-arr,3:derecha,4:der-aba,5:abajo,6:izq-aba,7:izquierda,8:izq-arr
Private
	id_colision;
	x_inc;
	y_inc;
	graph_base;
Begin
	file=fpg_tiles;
	ctype=c_scroll;
	z=-1;
	if(direccion==1 or direccion==8) angle=90000; end
	if(direccion==2 or direccion==3) angle=0; end
	if(direccion==4 or direccion==5) angle=-90000; end
	if(direccion==6 or direccion==7) angle=-180000; end
	//if(direccion==1 or direccion==3 or direccion==5 or direccion==7) graph_base=11; else graph_base=15; end
	if(direccion==1 or direccion==3 or direccion==5 or direccion==7) graph=10; else graph=20; end
	if(direccion==1 or direccion==2 or direccion==8) y_inc=-potencia; end
	if(direccion==2 or direccion==3 or direccion==4) x_inc=potencia/2; end
	if(direccion==4 or direccion==5 or direccion==6) y_inc=potencia/2; end
	if(direccion==6 or direccion==7 or direccion==8) x_inc=-potencia/2; end
	if(direccion==3 or direccion==7) y_inc=0; end
	if(direccion==1 or direccion==5) x_inc=0; end
	//graph=graph_base;
	//angle=(-45*(direccion-1)*1000)+90000;
	//graph=10;
	loop
		if(id_colision=collision(type prota))
			if(id_colision.accion!="muerte")
				if(id_colision.gravedad==0)
					id_colision.y--;
				end
				id_colision.gravedad=y_inc;
				id_colision.inercia=x_inc;
				id_colision.accion="lanzado";
				sonido(18,id_colision.jugador);
			end
		end
		if(id_colision=collision(type enemigo))
			if(id_colision.accion!="muerte")
				id_colision.gravedad=y_inc*1.1;
				id_colision.inercia=x_inc*0.8;
				id_colision.accion="lanzado";
			end
		end
		frame;
	end
End

Process sonador(x,y,id_sonido); //direccion 1:arriba,2:der-arr,3:derecha,4:der-aba,5:abajo,6:izq-aba,7:izquierda,8:izq-arr
Private
	id_colision;
	id_canal;
Begin
	file=fpg_tiles;
	graph=1;
	alpha=0;
	ctype=c_scroll;
	priority=100;
	size=150;
	loop		
		if(collision(type prota))
			id_canal=play_wav(sonidos_niveles[id_sonido],0);
			while(is_playing_wav(id_canal)) frame(500); end
			while(collision(type prota)) frame(500); end
		end
		frame;
	end
End


Process sombra(paso);
Begin
	ctype=father.ctype;
	flags=father.flags;
	file=father.file;
	z=father.z+1;
	x=father.x;
	y=father.y;
	graph=father.graph;
	size=father.size;
	angle=father.angle;
	alpha=200;
	while(alpha>0)
		alpha-=paso;
		frame;
	end
End

Function _mod(valor,divisor);
Begin
	while(valor>divisor)
		valor-=divisor;
	end
	return valor;
End

Process sombra_doble_salto();
Begin
	ctype=c_scroll;
	file=fpg_tiles;
	z=father.z+1;
	x=father.x;
	y=father.y+40;
	graph=1;
	alpha=200;
	while(alpha>0)
		alpha-=5;
		frame;
	end
End

Process plataforma(x_inicial,y_inicial,direccion,distancia,velocidad);
Private
	lado;
	id_colision;
	x_destino;
	y_destino;
Begin
	ctype=c_scroll;
	file=fpg_tiles;
	graph=6;
	z=-1;
	x=x_inicial;
	y=y_inicial;

	if(direccion==1 or direccion==2 or direccion==8) y_destino=y_inicial-distancia; end
	if(direccion==2 or direccion==3 or direccion==4) x_destino=x_inicial+distancia; end
	if(direccion==4 or direccion==5 or direccion==6) y_destino=y_inicial+distancia; end
	if(direccion==6 or direccion==7 or direccion==8) x_destino=x_inicial-distancia; end
	
	engranaje(x_inicial,y_inicial);
	engranaje(x_destino,y_destino);
	drawing_map(0,mapa_scroll);
	drawing_color(rgb(0,0,0));
	draw_line(x_inicial+get_distx(fget_angle(x_inicial,y_inicial,x_destino,y_destino)+pi/2,6),y_inicial+get_disty(fget_angle(x_inicial,y_inicial,x_destino,y_destino)+pi/2,6),x_destino+get_distx(fget_angle(x_inicial,y_inicial,x_destino,y_destino)+pi/2,6),y_destino+get_disty(fget_angle(x_inicial,y_inicial,x_destino,y_destino)+pi/2,6));
	drawing_color(rgb(255,255,255));
	draw_line(x_inicial+get_distx(fget_angle(x_inicial,y_inicial,x_destino,y_destino)+pi/2,5),y_inicial+get_disty(fget_angle(x_inicial,y_inicial,x_destino,y_destino)+pi/2,5),x_destino+get_distx(fget_angle(x_inicial,y_inicial,x_destino,y_destino)+pi/2,5),y_destino+get_disty(fget_angle(x_inicial,y_inicial,x_destino,y_destino)+pi/2,5));
	drawing_color(rgb(0,0,0));
	draw_line(x_inicial+get_distx(fget_angle(x_inicial,y_inicial,x_destino,y_destino)+pi/2,4),y_inicial+get_disty(fget_angle(x_inicial,y_inicial,x_destino,y_destino)+pi/2,4),x_destino+get_distx(fget_angle(x_inicial,y_inicial,x_destino,y_destino)+pi/2,4),y_destino+get_disty(fget_angle(x_inicial,y_inicial,x_destino,y_destino)+pi/2,4));
	
	drawing_color(rgb(0,0,0));
	draw_line(x_inicial+get_distx(fget_angle(x_inicial,y_inicial,x_destino,y_destino)-pi/2,6),y_inicial+get_disty(fget_angle(x_inicial,y_inicial,x_destino,y_destino)-pi/2,6),x_destino+get_distx(fget_angle(x_inicial,y_inicial,x_destino,y_destino)-pi/2,6),y_destino+get_disty(fget_angle(x_inicial,y_inicial,x_destino,y_destino)-pi/2,6));
	drawing_color(rgb(255,255,255));
	draw_line(x_inicial+get_distx(fget_angle(x_inicial,y_inicial,x_destino,y_destino)-pi/2,5),y_inicial+get_disty(fget_angle(x_inicial,y_inicial,x_destino,y_destino)-pi/2,5),x_destino+get_distx(fget_angle(x_inicial,y_inicial,x_destino,y_destino)-pi/2,5),y_destino+get_disty(fget_angle(x_inicial,y_inicial,x_destino,y_destino)-pi/2,5));
	drawing_color(rgb(0,0,0));
	draw_line(x_inicial+get_distx(fget_angle(x_inicial,y_inicial,x_destino,y_destino)-pi/2,4),y_inicial+get_disty(fget_angle(x_inicial,y_inicial,x_destino,y_destino)-pi/2,4),x_destino+get_distx(fget_angle(x_inicial,y_inicial,x_destino,y_destino)-pi/2,4),y_destino+get_disty(fget_angle(x_inicial,y_inicial,x_destino,y_destino)-pi/2,4));
	
	loop
		if(lado==0)
			if(direccion==2 or direccion==3 or direccion==4) x+=velocidad; end
			if(direccion==8 or direccion==7 or direccion==6) x-=velocidad; end
			if(direccion==8 or direccion==1 or direccion==2) y-=velocidad; end
			if(direccion==4 or direccion==5 or direccion==6) y+=velocidad; end
			if((x_destino>x_inicial and x>x_destino) or 
			(x_destino<x_inicial and x<x_destino) or 
			(y_destino>y_inicial and y>y_destino) or 
			(y_destino<y_inicial and y<y_destino))
				x=x_destino;
				y=y_destino;
				lado=1;
			end
		else
			if(direccion==2 or direccion==3 or direccion==4) x-=velocidad; end
			if(direccion==8 or direccion==7 or direccion==6) x+=velocidad; end
			if(direccion==8 or direccion==1 or direccion==2) y+=velocidad; end
			if(direccion==4 or direccion==5 or direccion==6) y-=velocidad; end
			if((x_destino>x_inicial and x<x_inicial) or 
			(x_destino<x_inicial and x>x_inicial) or 
			(y_destino>y_inicial and y<y_inicial) or 
			(y_destino<y_inicial and y>y_inicial))
				x=x_inicial;
				y=y_inicial;
				lado=0;
			end
		end
		from jugador=1 to 4;
			if(exists(p[jugador].identificador))
				if(collision(p[jugador].identificador))
					if(p[jugador].identificador.y<y-20)
						if(p[jugador].identificador.gravedad>0) p[jugador].identificador.gravedad=0; end
						if(p[jugador].identificador.gravedad==0)
							p[jugador].identificador.y=y-38;
							p[jugador].identificador.saltando=0;
							
							if(((direccion==4 or direccion==5 or direccion==6) and lado==0) or (((direccion==1 or direccion==2 or direccion==8)) and lado==1)) //lado1
								p[jugador].identificador.y+=velocidad;
							end
							if(direccion==6 or direccion==7 or direccion==8)
								if(lado==1)
									p[jugador].identificador.x+=velocidad;
								else
									p[jugador].identificador.x-=velocidad;
								end
							end
							if(direccion==2 or direccion==3 or direccion==4)
								if(lado==1)
									p[jugador].identificador.x-=velocidad;
								else
									p[jugador].identificador.x+=velocidad;
								end
							end
						end
					end
				end
			end
		end

		frame;
	end
End

Process engranaje(x,y);
Begin
	file=fpg_tiles;
	ctype=c_scroll;
	graph=7;
	loop
		angle+=1000;
		frame;
	end
End

Function tile_a_coordenada(pos_tile);
Begin
	return (pos_tile*tilesize)+(tilesize/2);
End

include "../../common-src/controles.pr-";

//stubs necesarios temporalmente para Wii
#ifdef WII
function getenv(string basura); begin end
function exec(int basura1,string basura2,int basura3,pointer basura4); begin end
function set_title(string basura); begin end
function editor_de_niveles(); begin end
#endif