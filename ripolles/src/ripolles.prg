Program ripolles;

import "mod_blendop";
//import "mod_debug";
import "mod_dir";
import "mod_draw";
import "mod_file";
import "mod_grproc";
import "mod_joy";
import "mod_key";
import "mod_map";
import "mod_math";
import "mod_proc";
import "mod_rand";
import "mod_regex";
import "mod_say";
import "mod_screen";
import "mod_scroll";
import "mod_sound";
import "mod_string";
import "mod_sys";
import "mod_text";
import "mod_timers";
import "mod_video";
import "mod_wm";

Const
	//animaciones y acciones
	quieto=0;
	camina=1;
	salta=2;
	ataca_suelo=3;
	ataca_aire=4;
	defiende=5;
	herido_leve=6;
	herido_grave=7;
	ataque_area=8;
	coge_objeto=9;
	quieto_objeto=10;
	camina_objeto=11;
	salta_objeto=12;
	lanza_objeto=13;
	ataque_fuerte=14;
	muere=-1;
	
	//objetos
	rosquilleta=1;
	papelera=2;
	canya=3;
	rollo=4;
	casco=5;
End

Global
	vida;
	puntos;
	
	string savegamedir;
	string developerpath="/.PiXJuegos/PiXBros/";
	joysticks[10];
	//estructuras de los personajes
	struct p[5];
		botones[7];
		vidas=5; 
		puntos; 
		control; 
		juega;
		identificador;
	end
	
	Struct ops;
		musica=1;
		sonido=1;
		ventana=1;
		byte dificultad=1; //0,1,2
	End	
End

Local
	ancho;
	alto;
	accion;
	animacion;
	anim; //contador
	animacion_anterior;
	gravedad;
	jugador;
	i; j;
End

include "../../common-src/savepath.pr-";

Begin
	//La resolución del monitor será esta:
	scale_resolution=12800720;
	
	//Pero internamente trabajaremos con esto:
	set_mode(640,360,32);
End

Function animame();
Private
	papi_graph;
	anim_max;
Begin
	animacion_anterior=father.animacion_anterior;
	animacion=father.animacion;
	if(animacion!=animacion_anterior)
		anim=0;
		animacion_anterior=animacion;
	else
		anim=father.anim;
		anim++;
	end
		
	switch(father.accion)
		case quieto;
			papi_graph=1;
			anim_max=10; //para evitar una cuenta infinita
		end
		case camina;
			papi_graph=1;
			anim_max;
		end
		case salta;
			papi_graph=2;
		end
		case ataca_suelo;
			papi_graph=3;
		end
		case ataca_aire;
			papi_graph=4;
		end
		case defiende;
			papi_graph=5;
		end
		case herido_leve;
			papi_graph=6;
		end
		case herido_grave;
			papi_graph=7;
		end
		case ataque_area;
			papi_graph=8;
		end
		case coge_objeto;
			papi_graph=9;
		end
		case quieto_objeto;
			papi_graph=10;
		end
		case camina_objeto;
			papi_graph=11;
		end
		case salta_objeto;
			papi_graph=12;
		end
		case lanza_objeto;
			papi_graph=13;
		end
		case ataque_fuerte;
			papi_graph=14;
		end
		muere=-1;
	end
End

Process cuerpo();
Begin
	jugador=father.jugador;
	ctype=c_scroll;
	x=father.x;
	y=father.y;
	//graph=;
	alpha=0;
	while(id_col=collision(type ataque))
		if(id_col.jugador!=jugador)
			
		end
	end
	frame;
End

Process ataque();
Begin
	jugador=father.jugador;
	frame;
End