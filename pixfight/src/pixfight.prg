Program pixfight;
import "libnet";

Const
	//RED
   PUERTO_SERVIDOR = 52000; // Puerto donde escucha el servidor
   MAX_JUGADORES   = 8;     // M�ximo de jugadores que pueden jugar a la vez
   NUM_CONTROLES   = 7;     // N�mero de controles por jugador (2 flechas + 2 botones)
   MAX_SONIDOS     = 32;    // N�mero m�ximo de sonidos por frame
   MAX_PROCESOS    = 35;    // N�mero m�ximo de procesos en pantalla
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

// Mensaje de conexi�n/desconexi�n
// Cuando un cliente se conecta, manda un ConnectMessage con index=-1. El servidor le responde
// entonces con un indice positivo si hay hueco en el juego o con un -1 si ya no se puede entrar
// Cuando el cliente se desconecta, manda un ConnectMessage con el �ndice que el servidor le
// devolvi� al conectarse
type ConnectMessage_t
   int index;
end;

// Mensaje de env�o de controles
// Este es el mensaje con el que el cliente le manda al servidor el estado de sus controles
// cada vez que cambian (o cada cierto tiempo)
type ControlsMessage_t
   int index;                       // El �ndice que nos devolvi� el servidor al conectarnos
   int controles[NUM_CONTROLES-1];  // El estado de nuestros controles
end;

// Informaci�n necesaria para pintar un proceso en pantalla
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
   ProcessInfo_t processInfo[MAX_PROCESOS];   // Informaci�n de los procesos en pantalla
end;

// Mensaje referente a sonidos y musica
type SoundMessage_t
   int musica;                // Qu� m�sica est� sonando
   int aspiradora;            // Aspiradora on/off
   int nSonidos;              // N�mero de sonidos nuevos desde �ltimo mensaje
   int sonidos[MAX_SONIDOS];
end;

// Informaci�n que el servidor guarda sobre cada cliente
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
	velocidadnet=300;
	cliente=0;
//  --------

	//suelo=400;
	dureza_suelo;
	dureza_plataforma;
	dureza_imposible;
	durezas_nivel;
	tiempoescudo[8];
	Struct botones;
		int p[8][6];
	End
	struct p[8];
		porcentual; vidas=5; puntos; control; juega; identificador; personaje;
	end
	ready=1;
	limites[3]; //arriba,derecha,abajo,izquierda
	
Local
	ancho;
	alto;
	string accion;
	string ataque;
	jugador;
	gravedad;
	da�o;
	atacante;
	direccion_golpe;
	i;
	j;
	foo;
	var;
Begin
	//full_screen=true;
	set_mode(1024,600,32);
	cargar_fpgs();
	p[1].personaje=5; p[1].control=0; personaje(1);

//	personaje(3);
//	personaje(4);

	durezas_nivel=load_png("nivelmask.png");
	put_screen(0,load_png("nivelmask.png"));
	dureza_suelo=map_get_pixel(0,durezas_nivel,0,0);
	dureza_plataforma=map_get_pixel(0,durezas_nivel,1,0);
	dureza_imposible=map_get_pixel(0,durezas_nivel,2,0);
	set_fps(50,0);

	//play_song(load_song("1.ogg"),-1);

	limites[0]=-300;
	limites[1]=1224;
	limites[2]=800;
	limites[3]=-300;

	if(cliente) net_cliente("pruebas.panreyes.es"); return; end
	
	loop
		if(servidor_iniciado)
			if(nConectados>0)
				from i=1 to nConectados;
					if(!exists(p[i+1].identificador)) p[i+1].personaje=rand(0,5); p[i+1].control=-1; personaje(i+1); end
				end
				if(nConectados<8)
					from i=nConectados+1 to 8;
						if(exists(p[i+1].identificador)) signal(p[i+1].identificador,s_kill); end
					end
				end
			end
		end
		if(key(_1) and servidor_iniciado==0) net_servidor(); end
		if(key(_2)) while(key(_2)) frame; end conectarse(); end
		if(key(_3)) while(key(_3)) frame; end p[2].personaje=1; p[2].control=1; personaje(2); end
		if(keY(_4))
				while(key(_4)) frame; end
				from i=3 to 8; p[i].personaje=rand(0,5); p[i].control=5; personaje(i); end
		end
		if(key(_esc)) exit(); end
		frame;
	end
End

include "cargar_fpgs.pr-";

Process conectarse();
Private
	string ip="pruebas.panreyes.es";
	char prompt="_";
	inputtext;
Begin	
	let_me_alone(); 
	delete_text(all_text); 
	Loop
	    If(scan_code==_backspace) scan_code=0; ip=substr(ip, 0, -1); End
	    If(scan_code==_enter) net_cliente(ip); return; End  
	    If(ascii>=32)
	        ip+=chr(ascii) ;
		scan_code=0;
	    End
	    if(i<20)
		    inputText=write(0, x, y, 0, ip + prompt); 
	    else
		    inputText=write(0, x, y, 0, ip); 
	    end
	    Frame;
	    delete_text(inputText) ;
	End
End 

Process personaje(jugador);
Private
	x_inc;
	bufferteclas[2];
	tiempoteclas;
	velocidad=6;
	anim; //para movs
	anim2; //para ataques
	doblesalto; //-1:no se puede hacer , 0:preparado , 1:reci�n realizado
	teclasuelta[10];
	//pacorrer;
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
	margen=10; //para los combos
Begin
	controlador(jugador);
	p[jugador].identificador=id;
	x=512-256+(64*jugador);
	y=100;
	switch(p[jugador].personaje)
		case 0: file=fpg_raruto; end
		case 1: file=fpg_pix; end
		case 2: file=fpg_tux; end
		case 3: file=fpg_zap; end
		case 4: file=fpg_aladdin; end
		case 5: file=fpg_bubsy; end
	end
	graph=1;
	ancho=graphic_info(file,graph,g_width)/2;
	alto=graphic_info(file,graph,g_height)/2;
	if(alto<22) alto=22; end
	tiempoescudo[jugador]=300;
	write_int(0,80+jugador*80,50,0,&p[jugador].porcentual);
	loop //INICIO LOOP PRINCIPAL PERSONAJES

	//-----------------
	if(!botones.p[jugador][0]) 
		if(izquierda_suelto<margen) izquierda_suelto++; end
	else
		if(izquierda_suelto>0) izquierda_suelto--; end
	end
	if(!botones.p[jugador][1]) 
		if(derecha_suelto<margen) derecha_suelto++; end
	else
		if(derecha_suelto>0) derecha_suelto--; end
	end
	if(!botones.p[jugador][2]) 
		if(arriba_suelto<margen) arriba_suelto++; end
	else
		if(arriba_suelto>0) arriba_suelto--; end
	end
	if(!botones.p[jugador][3]) 
		if(abajo_suelto<margen) abajo_suelto++; end
	else
		if(abajo_suelto>0) abajo_suelto--; end
	end
	if(!botones.p[jugador][4]) 
		if(ataque1_suelto<margen) ataque1_suelto++; end
	else
		if(ataque1_suelto>0) ataque1_suelto--; end
	end
	if(!botones.p[jugador][5]) 
		if(ataque2_suelto<margen) ataque2_suelto++; end
	else
		if(ataque2_suelto>0) ataque2_suelto--; end
	end
	if(!botones.p[jugador][6]) 
		if(escudo_suelto<margen) escudo_suelto++; end
	else
		if(escudo_suelto>0) escudo_suelto--; end
	end
	//--FIN CONTROLES


	switch(p[jugador].personaje) //SWITCH PERSONAJES
		case 0: include "raruto.pr-"; end //RARUTO
		case 1: include "raruto.pr-"; end //PIX
		case 2: include "raruto.pr-"; end //PIX
		case 3: include "raruto.pr-"; end //ZAP
		case 4: include "raruto.pr-"; end //ALADDIN
		case 5: include "raruto.pr-"; end //BUBSY
	end //FIN SWITCH PERSONAJES

	//PRINCIPIO COSAS GENERALES PREVIAS A FRAME
	if(tiempoescudo[jugador]<299 and ataque!="escudo") tiempoescudo[jugador]+=2; end
	while(map_get_pixel(0,durezas_nivel,x,y+alto)==dureza_imposible) y--; end
	//FINAL COSAS GENERALES PREVIAS A FRAME
	frame;
	end //FIN LOOP PRINCIPAL PERSONAJES
End

include "raruto_proc.pr-";

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
