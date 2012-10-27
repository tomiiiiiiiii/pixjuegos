Program ripolles;

import "mod_blendop";
import "mod_debug";
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
	posibles_jugadores;
	njoys;
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
	
	fpg_ripolles;
	fpg_nivel;
End

Local
	ancho;
	alto;
	altura;
	accion;
	lleva_objeto;
	animacion;
	anim; //contador
	animacion_anterior;
	gravedad;
	jugador;
	y_inc;
	x_inc;
	i; j;
End

include "../../common-src/controles.pr-";
include "../../common-src/savepath.pr-";

Begin
	//La resolución del monitor será esta:
	scale_resolution=12800720;
	
	//Pero internamente trabajaremos con esto:
	set_mode(640,360,32);
	
	fpg_ripolles=load_fpg("fpg\ripolles.fpg");
	fpg_nivel=load_fpg("fpg\nivel1.fpg");
	
	//A 30 imágenes por segundo
	set_fps(30,0);
	
	ripolles(1);
	
	put_screen(fpg_nivel,1);
	
	loop
		if(key(_esc)) exit(); end
		frame;
	end
End

Process ripolles(jugador);
Private
	y_base;
	pulsando_salto;
Begin
	file=fpg_ripolles;
	x=200;
	y_base=200;
	accion=quieto;
	controlador(jugador);
	loop		
		if(altura==0) //EN EL SUELO
			if((accion==quieto or accion==camina))
				if(p[jugador].botones[b_arriba] xor p[jugador].botones[b_abajo])
					if(p[jugador].botones[b_arriba])
						y_inc-=3;
					else //izquierda
						y_inc+=3;
					end
				end
				if(p[jugador].botones[b_izquierda] xor p[jugador].botones[b_derecha])
					if(p[jugador].botones[b_izquierda])
						x_inc-=3;
						flags=1;
					else //derecha
						x_inc+=3;
						flags=0;
					end
				end
			end

			if(p[jugador].botones[b_2])
				if(pulsando_salto==0)
					pulsando_salto=1;
					gravedad=-24;
					altura=1;
				end
			else
				pulsando_salto=0;
			end

			if(x_inc>0)
				x_inc--;
			elseif(x_inc<0)
				x_inc++;
			end
			if(y_inc>0)
				y_inc--;
			elseif(y_inc<0)
				y_inc++;
			end
		else //EN EL AIRE (SALTO)
			if(p[jugador].botones[b_arriba] xor p[jugador].botones[b_abajo])
				if(p[jugador].botones[b_arriba])
					y_inc-=1;
				else //izquierda
					y_inc+=1;
				end
			end
			if(p[jugador].botones[b_izquierda] xor p[jugador].botones[b_derecha])
				if(p[jugador].botones[b_izquierda])
					x_inc-=1;
					flags=1;
				else //derecha
					x_inc+=1;
					flags=0;
				end
			end
			
			gravedad+=2;
			altura+=gravedad;
			if(altura>1) 
				altura=0;
				gravedad=0;
				if(x_inc!=0 or y_inc!=0)
					animacion=camina;
				else
					animacion=quieto;
				end
			else
				y+=gravedad;
			end
		end

		if(x_inc>0)
			if(x_inc>6) x_inc=6; end
		elseif(x_inc<0)
			if(x_inc<-6) x_inc=-6; end
		end
		if(y_inc>0)
			if(y_inc>3) y_inc=3; end
		elseif(y_inc<0)
			if(y_inc<-3) y_inc=-3; end
		end

		if(altura==0)
			if((x_inc!=0 or y_inc!=0) and accion==quieto)
				accion=camina;
				if(lleva_objeto>0)
					animacion=camina_objeto;
				else
					animacion=camina;
				end
			elseif(accion==camina and x_inc==0 and y_inc==0)
				accion=quieto;
				if(lleva_objeto>0)
					animacion=quieto_objeto;
				else
					animacion=quieto;
				end
			end
		else
			if(lleva_objeto>0)
				animacion=salta_objeto;
			else
				animacion=salta;
			end
		end
		
		if(y_base<135) y_base=135; end
		if(y_base>305) y_base=305; end
		
		y_base+=y_inc;
		y=y_base+altura;
		z=y;
		
		if(altura==0)
			x+=x_inc;
		else
			x+=x_inc*1.4;
		end
		
		animame();
		frame;
	end
End

Function animame();
Private
	papi_graph; //no utilizamos la variable GRAPH porque convertiría a la función en un pseudoproceso
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
		
	//por defecto, para las animaciones que no utilicen el contador,
	//para evitar una cuenta infinita
	anim_max=10;
	
	switch(animacion)
		case quieto:
			papi_graph=1;
		end
		case camina:
			if(anim<6) 
				papi_graph=11;
			elseif(anim<12)
				papi_graph=12;
			elseif(anim<18)
				papi_graph=13;
			elseif(anim<24)
				papi_graph=14;
			else 
				papi_graph=13;
			end
			anim_max=30;
		end
		case salta:
			if(father.gravedad<0) //sube
				papi_graph=21;
			else //baja
				papi_graph=22;
			end
		end
		case ataca_suelo:
			papi_graph=3;
		end
		case ataca_aire:
			papi_graph=4;
		end
		case defiende:
			papi_graph=5;
		end
		case herido_leve:
			papi_graph=6;
		end
		case herido_grave:
			if(father.gravedad<0) //sube
				papi_graph=71;
			elseif(father.gravedad>0) //baja
				papi_graph=72;
			elseif(father.gravedad==0) //baja
				papi_graph=73;
			end
		end
		case ataque_area:
			papi_graph=8;
		end
		case coge_objeto:
			papi_graph=9;
		end
		case quieto_objeto:
			papi_graph=101;
		end
		case camina_objeto:
			if(anim<6) 
				papi_graph=111;
			elseif(anim<12)
				papi_graph=112;
			elseif(anim<18)
				papi_graph=113;
			elseif(anim<24)
				papi_graph=114;
			else 
				papi_graph=113;
			end
			anim_max=30;
		end
		case salta_objeto:
			if(father.gravedad<0) //sube
				papi_graph=121;
			else //baja
				papi_graph=122;
			end
		end
		case lanza_objeto:
			papi_graph=13;
		end
		case ataque_fuerte:
			papi_graph=14;
		end
	end
	if(anim=>anim_max) anim=0; end

	father.animacion_anterior=animacion;
	father.animacion=animacion;
	if(anim<=anim_max)
		father.anim=anim;
	else
		father.anim=0;
	end
	father.graph=papi_graph;
End

Process cuerpo();
Private
	id_col;
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

Process ataque(x,y,graph);
Begin
	jugador=father.jugador;
	ctype=c_scroll;
	frame;
End