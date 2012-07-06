Program pixfight;
import "libnet";
import "mod_blendop";
import "mod_cd";
import "mod_debug";
import "mod_dir";
import "mod_draw";
import "mod_effects";
import "mod_file";
import "mod_flic";
import "mod_grproc";
import "mod_joy";
import "mod_key";
import "mod_m7";
import "mod_map";
import "mod_math";
import "mod_mem";
import "mod_mouse";
import "mod_path";
import "mod_proc";
import "mod_rand";
import "mod_regex";
import "mod_say";
import "mod_screen";
import "mod_scroll";
import "mod_sort";
import "mod_sound";
import "mod_string";
import "mod_sys";
import "mod_text";
import "mod_time";
import "mod_timers";
import "mod_video";
import "mod_wm";

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
	velocidadnet=300;
	cliente=0;
//  --------

	//suelo=400;
	dureza_suelo;
	dureza_plataforma;
	dureza_imposible;
	durezas_nivel;
	tiempoescudo[8];
	struct p[8];
		porcentual; vidas=5; puntos; control; juega; identificador; personaje; botones[8];
	end
	ready=1;
	limites[3]; //arriba,derecha,abajo,izquierda
	numpersonajes;
	posibles_jugadores;
	joysticks[8];
	njoys;
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
	j;
	foo;
	var;
Begin
	//full_screen=true;
	if(!mode_is_ok(1024,600,16,MODE_FULLSCREEN))
		scale_resolution=12800720;
		if(!mode_is_ok(1280,720,16,MODE_FULLSCREEN))
			scale_resolution=06400480;
			if(!mode_is_ok(1280,720,16,MODE_FULLSCREEN))
				scale_resolution=03200240;
			end
		end
	end
	set_mode(1024,600,16);
	cargar_fpgs();
	configurar_controles();
	p[1].personaje=7; p[1].control=0; personaje(1);

//	personaje(3);
//	personaje(4);

	durezas_nivel=load_png("nivelmask.png");
	put_screen(0,load_png("nivelmask.png"));
	dureza_suelo=map_get_pixel(0,durezas_nivel,0,0);
	dureza_plataforma=map_get_pixel(0,durezas_nivel,1,0);
	dureza_imposible=map_get_pixel(0,durezas_nivel,2,0);
	set_fps(50,0);

	play_song(load_song("1.ogg"),-1);

	limites[0]=-300;
	limites[1]=1224;
	limites[2]=800;
	limites[3]=-300;

	//if(cliente) net_cliente("pruebas.panreyes.es"); return; end
	//zoom();
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
		if(key(_3)) while(key(_3)) frame; end p[2].personaje=1; p[2].control=-1; personaje(2); end
		if(keY(_4))
				while(key(_4)) frame; end
				from i=3 to 8; p[i].personaje=rand(0,numpersonajes); p[i].control=5; personaje(i); end
		end
		if(p[0].botones[7]) exit(); end
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

include "personaje.pr-";

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

include "../../common-src/controles.pr-";

include "net.pr-";

Process zoom();
Private
	camara_x;
	camara_y;
	min_x; max_x;
	min_y; max_y;
Begin
	x=512;
	y=300;
	z=-512;
	size=200;
	frame; //esto evita que se cuelge por el get_screen antes del primer frame
	loop
		if(key(_t)) size++; end
		if(key(_g)) size--; end
		graph=get_screen();

		from i=1 to 8;
			if(exists(p[i].identificador))
				min_x=p[i].identificador.x;
				max_x=p[i].identificador.x;
				min_y=p[i].identificador.y;
				max_y=p[i].identificador.y;
				break;
			end
		end
		from i=1 to 8;
			if(exists(p[i].identificador))
				if(p[i].identificador.x<min_x) min_x=p[i].identificador.x; end
				if(p[i].identificador.x>max_x) max_x=p[i].identificador.x; end
				if(p[i].identificador.y<min_y) min_y=p[i].identificador.y; end
				if(p[i].identificador.y>max_y) max_y=p[i].identificador.y; end
			end
			if(max_x>824) max_x=824; end
			if(max_y>500) max_y=500; end
			if(min_x<200) min_x=200; end
			if(min_y<0) min_y=0; end
			camara_x=(min_x+max_x)/2;
			camara_y=(min_y+max_y)/2;
		end

		if(min_x!=max_x) size=300+((min_x-max_x))/3; size-=(max_y-min_y)/20; end
		set_center(0,graph,camara_x,camara_y);
		if(size<100) size=100; end
		if(size>250) size=250; end
		frame;
		unload_map(0,graph);
	end
End