Program pixfight;
import "net";

Const
	//RED
   PUERTO_SERVIDOR = 52000; // Puerto donde escucha el servidor
   MAX_JUGADORES   = 8;     // Máximo de jugadores que pueden jugar a la vez
   NUM_CONTROLES   = 7;     // Número de controles por jugador (2 flechas + 2 botones)
   MAX_SONIDOS     = 32;    // Número máximo de sonidos por frame
   MAX_PROCESOS    = 35;    // Número máximo de procesos en pantalla
   TIEMPO_ESPERA   = 1000;  // Timeout de espera de jugadores
End
   type _IPaddress
    int host;
    word port;
	end;

type _UDPpacket
    int channel;
    byte pointer data;
    int len;
    int maxlen;
    int status;
    _IPaddress address;
end;

// Mensaje de conexión/desconexión
// Cuando un cliente se conecta, manda un ConnectMessage con index=-1. El servidor le responde
// entonces con un indice positivo si hay hueco en el juego o con un -1 si ya no se puede entrar
// Cuando el cliente se desconecta, manda un ConnectMessage con el índice que el servidor le
// devolvió al conectarse
type ConnectMessage_t
   int index;
end;

// Mensaje de envío de controles
// Este es el mensaje con el que el cliente le manda al servidor el estado de sus controles
// cada vez que cambian (o cada cierto tiempo)
type ControlsMessage_t
   int index;                       // El índice que nos devolvió el servidor al conectarnos
   int controles[NUM_CONTROLES-1];  // El estado de nuestros controles
end;

// Información necesaria para pintar un proceso en pantalla
type ProcessInfo_t
   int x;
   int y;
   int z;
   int angle;
   int flags;
   int alpha;
   int size_x;
   int size_y;
   int file;
   int graph;
end;

// Mensaje de pintado
// Este es el mensaje con el que el servidor informa a los clientes del estado de los procesos
// en pantalla
type ScreenMessage_t
   int           mundo;
   ProcessInfo_t processInfo[MAX_PROCESOS];   // Información de los procesos en pantalla
end;

// Mensaje referente a sonidos y musica
type SoundMessage_t
   int musica;                // Qué música está sonando
   int aspiradora;            // Aspiradora on/off
   int nSonidos;              // Número de sonidos nuevos desde último mensaje
   int sonidos[MAX_SONIDOS];
end;

// Información que el servidor guarda sobre cada cliente
type ClientData_t
   int               id;       // Identificador del proceso que lo maneja
   _IPaddress        address;  // IP y puerto donde el cliente escucha
   ControlsMessage_t c;        // Estado de sus controles
end;
//------------------------- FIN CONSTANTES RED   
Global
	//RED
   int                       id_servidor = 0;
   int                       nConectados = 0;
   int                       n;
   int                       procc;
   _UDPpacket        pointer pReceivePacket;
   _UDPpacket        pointer pSendPacket;
   ConnectMessage_t          pConnect;
   ControlsMessage_t         pControl;
   ScreenMessage_t           pScreen;
   SoundMessage_t            pSounds;
   ClientData_t              clientes[MAX_JUGADORES-1];

    _UDPpacket pointer pcontroles;
	_UDPpacket pointer pprocesillos;

	net=1;
	servidor_iniciado;
	struct procesillos[3];
	//	x,y,z,angle,flags,alpha,size_x,size_y,file,graph;
		x,y,file,graph;
	end
	velocidadnet=200;
//  --------

	//suelo=400;
	dureza_suelo;
	dureza_plataforma;
	durezas_nivel;
	fpg_raruto;
	tiempoescudo[8];
	Struct botones;
		int p[8][6];
	End
	struct p[8];
		porcentual; vidas=5; puntos; control; juega; identificador;
	end
	ready=1;
	//RED
	
Local
	ancho;
	alto;
	string accion;
	string ataque;
	jugador;
	gravedad;
	daño;
	atacante;
	direccion_golpe;
	i;
Begin
	if(net) net_init(); end
	net_servidor();
	//full_screen=true;
	set_mode(1024,600,16);
	fpg_raruto=load_fpg("fpg/raruto.fpg");
//	from i=1 to 7; 	p[i].control=5; personaje(i); end
	p[1].control=0; personaje(1);
	from i=2 to 8; 	personaje(i); end
/*	p[2].control=1; personaje(2);
	p[3].control=5; personaje(3);*/
	//personaje(5);
	durezas_nivel=load_png("nivel.png");
	put_screen(0,durezas_nivel);
	dureza_suelo=map_get_pixel(0,durezas_nivel,0,0);
	dureza_plataforma=map_get_pixel(0,durezas_nivel,1,0);
	set_fps(50,0);
	loop
		if(key(_2)) let_me_alone(); delete_text(all_text); net_cliente("localhost"); return; end
		if(key(_esc)) exit(); end
		frame;
	end
End

Process personaje(jugador);
Private
	x_inc;
	bufferteclas[2];
	tiempoteclas;
	velocidad=4;
	anim; //para movs
	anim2; //para ataques
	doblesalto;
	teclasuelta[10];
	pacorrer;
	ataque2_suelto;
	ataque1_suelto;
	escudo_suelto;
	arriba_suelto;
	izquierda_suelto;
	derecha_suelto;
	abajo_suelto;
	x_destino;
	y_destino;
	fuerza_ataque;
	tiempo_paralizado;
	flags_antes;
	id_col;
Begin
	if(jugador==1) controlador(jugador); end
	p[jugador].identificador=id;
	x=512-256+(64*jugador);
	y=100;
	file=fpg_raruto;
	graph=1;
	ancho=graphic_info(file,graph,g_width)/2;
	alto=graphic_info(file,graph,g_height)/2;
	tiempoescudo[jugador]=300;
	write_int(0,80+jugador*80,50,0,&p[jugador].porcentual);
	loop

//	if(jugador==5) ataque="kunai"; end

	switch(accion)
		case "quieto":
			graph=1;
			x+=x_inc;
			if(botones.p[jugador][0] and !botones.p[jugador][1]) flags=1; x_inc-=2; accion="andar"; end
			if(botones.p[jugador][1] and !botones.p[jugador][0]) flags=0; x_inc+=2; accion="andar"; end
		end
		case "andar":
			if(ataque=="")
				if(botones.p[jugador][0] and !botones.p[jugador][1])
					x_inc-=2; 
					flags=1;
					if(x_inc>0) 
						graph=4; 
				else
						if(graph<11 or graph>13) 
							graph=11; 
							anim=-1; 
						else
							if(anim<10) 
								anim++; 
							else 
								anim=0;
								if(graph!=13) graph++; else graph=11; end
							end
						end
					end
				else
					if(pacorrer==0 and x_inc<0) 
						pacorrer=-10; 
					end
				end
				if(botones.p[jugador][1] and !botones.p[jugador][0])
					x_inc+=2; 
					flags=0;
					if(x_inc<0) 
						graph=4; 
					else
						if(graph<11 or graph>13) 
							graph=11; 
							anim=-1; 
						else
							if(anim<10) 
								anim++; 
							else 
								anim=0;
								if(graph!=13) graph++; else graph=11; end
							end
						end
					end
				else
					if(pacorrer==0 and x_inc>0) 
						pacorrer=10; 
					end
				end
				if(pacorrer==0)
					if((!botones.p[jugador][0] and !botones.p[jugador][1]) or (botones.p[jugador][0] and botones.p[jugador][1])) accion="quieto"; end
				else
					if(pacorrer<0) pacorrer++; if(botones.p[jugador][0]) accion="correr"; end end
					if(pacorrer>0) pacorrer--; if(botones.p[jugador][1]) accion="correr"; end end
				end
			else
				if(ataque=="escudo")
					if(botones.p[jugador][0] and !botones.p[jugador][1] and x_inc==0 and botones.p[jugador][6])
						x_inc=-20;
					end
					if(botones.p[jugador][1] and !botones.p[jugador][0] and x_inc==0 and botones.p[jugador][6])
						x_inc=20;
					end
					if(x_inc>0) if(flags==0) angle-=20000; else angle+=20000; end end
					if(x_inc<0) if(flags==1) angle-=20000; else angle+=20000; end end
					if(x_inc==0) angle=0; end
				end
			end
		end
		case "correr":
			if(ataque=="")
				if(botones.p[jugador][0] and !botones.p[jugador][1])
					x_inc-=2; 
					flags=1;
					if(x_inc>0) 
						graph=4; 
					else
						if(graph<11 or graph>13) 
							graph=11; 
							anim=-1; 
						else
							if(anim<5) 
								anim++; 
							else 
								anim=0;
								if(graph!=13) graph++; else graph=11; end
							end
						end
					end
				end
				if(botones.p[jugador][1] and !botones.p[jugador][0])
					x_inc+=2; 
					flags=0;
					if(x_inc<0) 
						graph=4; 
					else
						if(graph<11 or graph>13) 
							graph=11; 
							anim=-1; 
						else
							if(anim<5) 
								anim++; 
							else 
								anim=0;
								if(graph!=13) graph++; else graph=11; end
							end
						end
					end
				end
				if((!botones.p[jugador][0] and !botones.p[jugador][1]) or (botones.p[jugador][0] and botones.p[jugador][1])) accion="quieto"; end
			else
				accion="quieto";
			end
		end
		case "aire":
			if(ataque=="")
				if(botones.p[jugador][0] and x_inc>-velocidad*1.5) x_inc-=2; end
				if(botones.p[jugador][1] and x_inc<velocidad*1.5) x_inc+=2; end
				if(!botones.p[jugador][2] and doblesalto==-1) doblesalto=0; end
				if(botones.p[jugador][2] and doblesalto==0) doblesalto=1; gravedad=-15; end
				if(gravedad<0) graph=3; else graph=5; end
			else
				if(ataque=="escudo") ataque=""; end
			end
		end
		case "paralizado":
			graph=2;
			if(tiempo_paralizado<180) tiempo_paralizado++; else tiempo_paralizado=0; accion="quieto"; ataque=""; end
			if(flags==1) if(angle<90000) angle+=5000; end end
			if(flags==0) if(angle>-90000) angle-=5000; end end
		end
	end
	//-----------------------FIN MOVIMIENTOS, PRINCIPIO ATAQUES
	switch(ataque)
		case "kunai":
			anim2++;
			if(anim2<10) graph=21; end
			if(anim2==10) raruto_kunai(); graph=22; end
			if(anim2>10 and anim2<20) graph=22; end
			if(anim2==20) ataque=""; anim2=0; end
		end
		case "escudo":
			//accion="escudo";
			daño=0;
			atacante=0;
			flags=flags_antes;
			if((botones.p[jugador][6] and tiempoescudo[jugador]>0) or (x_inc!=0 and gravedad==0))
				graph=5;
				tiempoescudo[jugador]--;
			else
				if(tiempoescudo[jugador]>0)
					ataque="";
				else
					ataque="paralizado";
					accion="paralizado";
				end
			end
		end
		case "laser":
			graph=31;
			if(fuerza_ataque==0) fuerza_ataque=20; end
			if(botones.p[jugador][5] and fuerza_ataque<80) 
				i=0;
				fuerza_ataque++;
			else
				graph=31;
				if(i>10) 
					if(gravedad>0) gravedad=-7; end
					x_inc=x_inc/2;
					raruto_laser(fuerza_ataque*3);
					//frame(fuerza_ataque*12);
					fuerza_ataque=0;
					accion="quieto";
					ataque="";
				else
					i++;
				end
			end
		end
		case "contraataque":
			graph=1;
			from i=0 to 60;
				frame;
				if(daño>0) break; end
			end
			
			if(daño!=0 and atacante!=0 and exists(p[atacante].identificador)) 
				raruto_tronco();
				y=p[atacante].identificador.y;
				if(p[atacante].identificador.x<x) x=p[atacante].identificador.x-30; flags=0; 
				elseif(p[atacante].identificador.x=>x) x=p[atacante].identificador.x+30; flags=1; end
				ataque="kunai";
				atacante=0;
				daño=0;
			else
				ataque="";
			end
			accion="quieto";
		end
		case "dañorecibido":
			graph=2;
			if(botones.p[jugador][0] and x_inc>-4) x_inc-=2; end
			if(botones.p[jugador][1] and x_inc<4) x_inc+=2; end
			angle+=3000;
			if(gravedad=>0) 
				if(accion!="aire") angle=0; end
				from i=2 to 7; if(botones.p[jugador][i]) ataque=""; end end
			end
		end
		case "tercersalto":
			graph=3;
			from i=0 to 3; raruto_copia(); y-=alto*1.5; end
			gravedad=-10;
			ataque="cayendo";
		end
		case "cayendo":
			if(botones.p[jugador][0] and x_inc>-4) x_inc-=2; end
			if(botones.p[jugador][1] and x_inc<4) x_inc+=2; end
			if(accion=="aire")
				graph=2;
				if(flags==1) 
					if(angle<180000) angle+=3000; end
				else
					if(angle>-180000) angle-=3000; end
				end
			else
				ataque="";
			end
		end
	end
	//--------------------FIN ATAQUES
	//--------------------PRINCIPIO CONTROLES
		if(ataque=="")
			//BOTON ATAQUE 1
			if(botones.p[jugador][5] and ataque2_suelto>0) ataque="kunai"; end
	
			if(botones.p[jugador][5] and botones.p[jugador][0] and ataque2_suelto>0 and izquierda_suelto>0 and izquierda_suelto<5) flags=1; ataque="laser"; end
			if(botones.p[jugador][5] and botones.p[jugador][1] and ataque2_suelto>0 and derecha_suelto>0 and derecha_suelto<5) flags=0; ataque="laser"; end
	
			if(botones.p[jugador][6] and accion!="aire") ataque="escudo"; flags_antes=flags; escudo(); end	

			if(botones.p[jugador][5] and botones.p[jugador][3] and ataque2_suelto>0 and abajo_suelto>0 and abajo_suelto<5 and accion!="aire") ataque="contraataque"; end

			if(botones.p[jugador][5] and botones.p[jugador][2] and ataque2_suelto>0 and arriba_suelto>0 and arriba_suelto<5) 
				ataque="tercersalto"; 
			end

			//BOTON ATAQUE 2
		end
	//-----------------
		if(!botones.p[jugador][4]) 
			if(ataque1_suelto<5) ataque1_suelto++; end
		else
			if(ataque1_suelto>0) ataque1_suelto--; end
		end
		if(!botones.p[jugador][5]) 
			if(ataque2_suelto<5) ataque2_suelto++; end
		else
			if(ataque2_suelto>0) ataque2_suelto--; end
		end
		if(!botones.p[jugador][6]) 
			if(escudo_suelto<5) escudo_suelto++; end
		else
			if(escudo_suelto>0) escudo_suelto--; end
		end
		if(!botones.p[jugador][2]) 
			if(arriba_suelto<5) arriba_suelto++; end
		else
			if(arriba_suelto>0) arriba_suelto--; end
		end
		if(!botones.p[jugador][3]) 
			if(abajo_suelto<5) abajo_suelto++; end
		else
			if(abajo_suelto>0) abajo_suelto--; end
		end
		if(!botones.p[jugador][0]) 
			if(izquierda_suelto<5) izquierda_suelto++; end
		else
			if(izquierda_suelto>0) izquierda_suelto--; end
		end
		if(!botones.p[jugador][1]) 
			if(derecha_suelto<5) derecha_suelto++; end
		else
			if(derecha_suelto>0) derecha_suelto--; end
		end

		if(tiempoescudo[jugador]<299 and ataque!="escudo") tiempoescudo[jugador]+=2; end
		//--FIN CONTROLES
		//---------MOVIMIENTO Y MISC.
		
		if((accion=="andar" or accion=="quieto") and (id_col=collision(type personaje)))
			if((id_col.accion=="andar" or id_col.accion=="quieto") and fget_dist(x,y,id_col.x,id_col.y)<ancho)
				if(id_col.x>x) x_inc-=2; end
				if(id_col.x<x) x_inc+=2; end
			end
		end
		
		//en el aire!
		if(map_get_pixel(0,durezas_nivel,x,y+alto)!=dureza_suelo and map_get_pixel(0,durezas_nivel,x,y+alto)!=dureza_plataforma)
			accion="aire";
			gravedad++; 
		end
		//a la altura del suelo
		if((map_get_pixel(0,durezas_nivel,x,y+alto)==dureza_suelo or map_get_pixel(0,durezas_nivel,x,y+alto)==dureza_plataforma) and gravedad==0)
			if(x_inc<0) x_inc++; end
			if(x_inc>0) x_inc--; end
			if(accion=="quieto" or accion=="andar")
				if(botones.p[jugador][2] and ataque=="") gravedad=-15; accion="aire"; doblesalto=-1; end
			end
			if(accion=="correr")
				if(botones.p[jugador][2] and ataque=="") gravedad=-15; accion="aire"; doblesalto=-1; end //cuestionable
			end
		end
		//por debajo del suelo (cayendo?)
		if(accion!="correr" and accion!="aire" and ataque=="")
			if(x_inc>velocidad) x_inc=velocidad; end
			if(x_inc<-velocidad) x_inc=-velocidad; end
		else
			if(ataque=="" and accion!="aire")
				if(x_inc>velocidad*1.5) x_inc=velocidad*1.5; end
				if(x_inc<-velocidad*1.5) x_inc=-velocidad*1.5; end
			end
		end
		
		if(ataque=="")
			angle=0;
		end
		
		if(gravedad>10) gravedad=10; end
		y_destino=y+gravedad;
		x_destino=x+x_inc;		
		
		if(gravedad==0 and botones.p[jugador][3] and ataque=="") gravedad++; end
		if(gravedad>0) 
			if(x_inc<0) x_inc++; end
			if(x_inc>0) x_inc--; end

			from y=y to y_destino-1;
				if(map_get_pixel(0,durezas_nivel,x,y+alto)==dureza_suelo or (map_get_pixel(0,durezas_nivel,x,y+alto)==dureza_plataforma and !botones.p[jugador][3]))
					accion="quieto";
					gravedad=0; 
					angle=0;
					break;
				end
			end
		end
		if(gravedad<0) 
			from y=y to y_destino+1 step -1;
				if(map_get_pixel(0,durezas_nivel,x,y-alto)==dureza_suelo)
					accion="quieto";
					gravedad=0; 
					angle=0;
					break;
				end
			end
		end
		
		//x=x_destino;
		if(x_destino>x)
			from x=x to x_destino-1;
				from i=y-alto to y+(alto/4);
					if(map_get_pixel(0,durezas_nivel,x+ancho,i)==dureza_suelo) accion="quieto"; graph=1; break; end
				end
				if(map_get_pixel(0,durezas_nivel,x+ancho,y+alto)==dureza_suelo and map_get_pixel(0,durezas_nivel,x+ancho+1,y+alto)!=dureza_suelo) accion="quieto"; graph=1; break; end
			end
		elseif(x_destino<x)
			from x=x to x_destino+1 step -1;
				from i=y-alto to y+(alto/4);
					if(map_get_pixel(0,durezas_nivel,x-ancho,i)==dureza_suelo) accion="quieto"; graph=1; break; end
				end
				if(map_get_pixel(0,durezas_nivel,x-ancho,y+alto)==dureza_suelo and map_get_pixel(0,durezas_nivel,x-ancho-1,y+alto)!=dureza_suelo) accion="quieto"; graph=1; break; end
			end
		end
//------------------------
		if(x<-200 or x>1224 or y>800) x=512; y=100; x_inc=0; gravedad=0; ataque=""; accion="quieto"; daño=0; p[jugador].porcentual=0; p[jugador].vidas--; end
		
		if(daño>0) 
			if(direccion_golpe==0) 
//				x_inc+=daño/2*(p[jugador].porcentual/60);
				x_inc=(daño/3)*1+(p[jugador].porcentual/10);
			else
//				x_inc-=daño/2*(p[jugador].porcentual/60);
				x_inc=-((daño/3)*1+(p[jugador].porcentual/10));
			end
			gravedad=-(daño+(p[jugador].porcentual/60));
			if(gravedad<-15) gravedad=-15; end
			if(x_inc>15) ataque="dañorecibido"; end
			p[jugador].porcentual+=daño; 
			daño=0; 
			atacante=0; 
		end
	

		frame;
	end
End

Process escudo();
Begin
	jugador=father.jugador;
	file=father.file;
	graph=951;
	z=-1;
	alpha=128;
	while(exists(father))
		if(father.ataque!="escudo") break; end
		x=father.x;
		y=father.y;
		size=tiempoescudo[jugador]/3;
		frame;
	end
End

Process raruto_kunai();
Private
	id_col;
	fuerza;
	grav=-3;
Begin
	file=father.file;
	graph=901;
	jugador=father.jugador;
	flags=father.flags;
	y=father.y;
	x=father.x;
	if(father.accion=="correr") fuerza=20; else fuerza=10; end
	loop
		if(flags==0) x+=fuerza; end
		if(flags==1) x-=fuerza; end
		//if(fuerza>0) fuerza--; end
		grav++;
		if(id_col=collision(type personaje))
			if(id_col.jugador!=jugador)
				//massivedamage
				id_col.daño+=fuerza/4;
				id_col.atacante=jugador;
				id_col.direccion_golpe=flags;
				break;
			end
		end
		frame;
	end
End

Process raruto_laser(size_y);
Private
	id_col;
	fuerza;
	grav=-3;
Begin
	file=father.file;
	z=-1;
	graph=902;
	jugador=father.jugador;
	flags=father.flags;
	y=father.y;
	x=father.x;
	if(size_y<30) return; end
	size_x=size_y*1.5;
	//raruto_laser(size_y-20);
	fuerza=size_y/5;
	loop
		if(flags==0) x+=fuerza; end
		if(flags==1) x-=fuerza; end
		if(fuerza>0) fuerza--; else break; end
		grav++;
		if(id_col=collision(type personaje))
			if(id_col.jugador!=jugador)
				//massivedamage
				//id_col.daño+=fuerza/12;
				id_col.daño+=fuerza;
				id_col.atacante=jugador;
				id_col.direccion_golpe=flags;
				break;
			end
		end
		frame;
	end
End

Process raruto_copia();
Private
	angle_inc;
	ydestino;
Begin
	file=father.file;
	graph=rand(1,5);
	y=-1;
	x=father.x;
	y=father.y;
	angle_inc=rand(-5,5)*1000;
	ydestino=y+10;
	from y=y to ydestino; angle+=angle_inc; frame; end
	raruto_nube();
End

Process raruto_tronco();
Begin
	file=father.file;
	graph=903;
	y=-1;
	x=father.x;
	y=father.y;
	frame(2000);
	raruto_nube();
End

Process raruto_nube();
Begin
	file=father.file;
	graph=904;
	y=-1;
	x=father.x;
	y=father.y;
	from alpha=255 to 0 step -5;
		y--;
		size_y--;
		size_x+=2;
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
		x=father.x;
		y=father.y;
		while(p[jugador].control==-1) frame; end
		While(ready==0) Frame; End
		If(p[jugador].control==0)  // teclado
			If(key(_left)) botones.p[jugador][0]=1; Else botones.p[jugador][0]=0; End
			If(key(_right)) botones.p[jugador][1]=1; Else botones.p[jugador][1]=0; End
			If(key(_up)) botones.p[jugador][2]=1; Else botones.p[jugador][2]=0; End
			If(key(_down)) botones.p[jugador][3]=1; Else botones.p[jugador][3]=0; End
			If(key(_a)) botones.p[jugador][4]=1; Else botones.p[jugador][4]=0; End
			If(key(_s)) botones.p[jugador][5]=1; Else botones.p[jugador][5]=0; End
			If(key(_d)) botones.p[jugador][6]=1; Else botones.p[jugador][6]=0; End
		End
		If(p[jugador].control==1)  // joystick
			If(get_joy_position(0,0)<-10000) botones.p[jugador][0]=1; Else botones.p[jugador][0]=0; End
			If(get_joy_position(0,0)>10000) botones.p[jugador][1]=1; Else botones.p[jugador][1]=0; End
			If(get_joy_position(0,1)<-7500) botones.p[jugador][2]=1; Else botones.p[jugador][2]=0; End
			If(get_joy_position(0,1)>7500) botones.p[jugador][3]=1; Else botones.p[jugador][3]=0; End
			If(get_joy_button(0,0)) botones.p[jugador][4]=1; Else botones.p[jugador][4]=0; End
			If(get_joy_button(0,1)) botones.p[jugador][5]=1; Else botones.p[jugador][5]=0; End
			If(get_joy_button(0,2)) botones.p[jugador][6]=1; Else botones.p[jugador][6]=0; End
		End
		If(p[jugador].control==2)  // joystick 2
			If(get_joy_position(1,0)<-10000) botones.p[jugador][0]=1; Else botones.p[jugador][0]=0; End
			If(get_joy_position(1,0)>10000) botones.p[jugador][1]=1; Else botones.p[jugador][1]=0; End
			If(get_joy_position(1,1)<-7500) botones.p[jugador][2]=1; Else botones.p[jugador][2]=0; End
			If(get_joy_position(1,1)>7500) botones.p[jugador][3]=1; Else botones.p[jugador][3]=0; End
			If(get_joy_button(1,0) OR get_joy_button(1,1)) botones.p[jugador][4]=1; Else botones.p[jugador][4]=0; End
			If(get_joy_button(1,2) OR get_joy_button(1,3)) botones.p[jugador][5]=1; Else botones.p[jugador][5]=0; End
		End
		If(p[jugador].control==3)  // joystick 3
			If(get_joy_position(2,0)<-10000) botones.p[jugador][0]=1; Else botones.p[jugador][0]=0; End
			If(get_joy_position(2,0)>10000) botones.p[jugador][1]=1; Else botones.p[jugador][1]=0; End
			If(get_joy_position(2,1)<-7500) botones.p[jugador][2]=1; Else botones.p[jugador][2]=0; End
			If(get_joy_position(2,1)>7500) botones.p[jugador][3]=1; Else botones.p[jugador][3]=0; End
			If(get_joy_button(2,0) OR get_joy_button(2,1)) botones.p[jugador][4]=1; Else botones.p[jugador][4]=0; End
			If(get_joy_button(2,2) OR get_joy_button(2,3)) botones.p[jugador][5]=1; Else botones.p[jugador][5]=0; End
		End
		If(p[jugador].control=>5)
			from i=0 to 7; 
				botones.p[jugador][i]=rand(0,1);
			end
		end
		Frame;
	End
End

include "net.pr-";