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
	puntos;
	
	string savegamedir;
	string developerpath="/.PiXJuegos/PiXBros/";
	
	joysticks[10];
	posibles_jugadores;
	njoys;
	//estructuras de los personajes
	struct p[5];
		botones[7];
		vida=500; 
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
	fpg_general;
	fpg_objetos;
End

Local
	ancho;
	alto;
	altura;
	accion;
	herida;
	rango;
	lleva_objeto;
	animacion;
	anim; //contador
	animacion_anterior;
	gravedad;
	jugador;
	y_inc;
	x_inc;
	y_base;
	i; j;
End

include "../../common-src/controles.pr-";
include "../../common-src/savepath.pr-";

Begin
	//La resoluci�n del monitor ser� esta:
	scale_resolution=12800720;
	
	//Pero internamente trabajaremos con esto:
	set_mode(640,360,32);
		
	fpg_ripolles=load_fpg("fpg\ripolles.fpg");
	fpg_nivel=load_fpg("fpg\nivel1.fpg");
	fpg_general=load_fpg("fpg\general.fpg");
	fpg_objetos=load_fpg("fpg\objetos.fpg");
	
	//configuramos controladores
	configurar_controles();
	
	//A 30 im�genes por segundo
	set_fps(30,0);
	
	ripolles(1);
	ripolles(2);
	
	put_screen(fpg_nivel,1);
	
	loop
		if(p[1].botones[b_salir]) exit(); end
		frame;
	end
End

Process ripolles(jugador);
Private
	pulsando_salto;
	pulsando_ataque1;
	pulsando_ataque2;
	hacia_que_lado;
Begin
	file=fpg_ripolles;
	x=200;
	y_base=200;
	accion=quieto;
	controlador(jugador);
	write_int(0,0,10*(jugador-1),0,&p[jugador].vida);
	loop
		if(flags==0)
			hacia_que_lado=1;
		else
			hacia_que_lado=-1;
		end

		if(herida==0 and (accion==herido_leve or accion==herido_grave))
			accion=quieto;
			animacion=quieto;
		end
		
		if(accion==defiende and !p[jugador].botones[b_3])
			accion=quieto;
			animacion=quieto;
			x_inc=0;
			y_inc=0;
		end
		
		if(herida==0)
			if(altura==0) //EN EL SUELO
				if((accion==quieto or accion==camina))
					//ataque suelo o lanzar objeto
					if(p[jugador].botones[b_1] and pulsando_ataque1==0)
						pulsando_ataque1=1;
						if(lleva_objeto==0)
							accion=ataca_suelo;
							animacion=ataca_suelo;
						else
							accion=lanza_objeto;
							animacion=lanza_objeto;					
						end
					end

					//movimiento
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
					
					//defenderse
					if(p[jugador].botones[b_3])
						accion=defiende;
						animacion=defiende;
					end
				end	
														
				//salto
				if(p[jugador].botones[b_2])
					if(pulsando_salto==0)
						pulsando_salto=1;
						gravedad=-24;
						altura=1;
					end
				else
					pulsando_salto=0;
				end

				//reducci�n de inercias
				friccioname();
				
			else //EN EL AIRE (SALTO)
				//ataque aereo
				if(p[jugador].botones[b_1]) 
					if(pulsando_ataque1==0)
						pulsando_ataque1=1;
						accion=ataca_aire;
						animacion=ataca_aire;
					end
				end

				if(accion!=ataca_aire)
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
				end

				gravedad+=2;
				altura+=gravedad;
				if(altura>1)
					altura=0;
					gravedad=0;
					accion=quieto;
					if(x_inc!=0 or y_inc!=0)
						animacion=camina;
					else
						animacion=quieto;
					end
				else
					y+=gravedad;
				end
			end
		else //est� siendo herido
			if(accion!=herido_leve and accion!=herido_grave) //escisi�n!
				p[jugador].vida-=herida;
				herida=herida/2;
				if(flags==1)
					x_inc+=herida;
				else
					x_inc-=herida;
				end
				if(herida<15)
					accion=herido_leve;
					animacion=herido_leve;
				else
					accion=herido_grave;
					animacion=herido_grave;
					gravedad=-herida;
					altura=-1;
				end
			else
				herida--;
			end

			gravedad+=2;
			altura+=gravedad;
			if(altura>1)
				altura=0;
				gravedad=0;
				graph=73;
				friccioname();
			else
				y+=gravedad;
			end

		end
		
		if(!p[jugador].botones[b_1]) pulsando_ataque1=0; end
		
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

		if(herida==0)
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
					if(accion!=ataca_aire)
						animacion=salta;
					end
				end
			end
		end
		
		if(y_base<135) y_base=135; end
		if(y_base>305) y_base=305; end
			
		mueveme();
		animame();
		
		if(herida==0)
			cuerpo();
		end
		
		if(lleva_objeto!=0)
			if(accion==lanza_objeto)
				if(anim<4)
					objeto_portado(x+(-10*hacia_que_lado),y-25,lleva_objeto);
				else
					if(anim==4) objeto_lanzado(x+(10*hacia_que_lado),y-25,lleva_objeto); end
				end
				if(anim==7) lleva_objeto=0; accion=quieto; animacion=quieto; end
			else
				objeto_portado(x,y-50,lleva_objeto);
			end
		end		
		
		if(accion==ataca_suelo)
			if(anim<4)
				ataque(x+(15*hacia_que_lado),y-15,1,15,20);
			else
				ataque(x+(45*hacia_que_lado),y-15,1,10,20);
			end
			if(anim==7)
				accion=quieto; 
				animacion=quieto;
			end
		end

		if(accion==ataca_aire)
			if(accion==ataca_aire)
				ataque(x+(40*hacia_que_lado),y,1,30,15);
			end
		end
				
		frame;
	end
End

Function mueveme();
Begin
		father.y_base+=father.y_inc;
		father.y=father.y_base+father.altura;
		father.z=-father.y_base;

		if(father.altura==0)
			father.x+=father.x_inc;
		else
			father.x+=father.x_inc*1.4;
		end
End

Function friccioname();
Begin
	if(father.x_inc>0)
		father.x_inc--;
	elseif(father.x_inc<0)
		father.x_inc++;
	end
	if(father.y_inc>0)
		father.y_inc--;
	elseif(father.y_inc<0)
		father.y_inc++;
	end
End

Function animame();
Private
	papi_graph; //no utilizamos la variable GRAPH porque convertir�a a la funci�n en un pseudoproceso
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
	jugador=father.jugador;
	
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
			if(anim<4) 
				papi_graph=31;
			else
				papi_graph=32;
			end
			anim_max=8;
		end
		case ataca_aire:
			papi_graph=42;
		end
		case defiende:
			papi_graph=51;
		end
		case herido_leve:
			papi_graph=61;
		end
		case herido_grave:
			if(father.altura==0)
				papi_graph=73;
			elseif(father.gravedad<=0) //sube
				papi_graph=71;
			elseif(father.gravedad>0) //baja
				papi_graph=72;
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
	dist_z;
Begin
	jugador=father.jugador;
	//ctype=c_scroll;
	x=father.x;
	y=father.y;
	z=father.z;
	file=fpg_general;
	graph=2;
	alpha=0;
	rango=20;
	if(id_col=collision(type ataque))
		if(id_col.jugador!=jugador)
			if(id_col.z>z)
				dist_z=id_col.z-z;
			else
				dist_z=z-id_col.z;
			end
			if(id_col.rango=>dist_z)
				if(father.accion==defiende and ((father.flags==0 and x<id_col.x) or (father.flags==1 and x>id_col.x)))
					//destello();
				else
					father.herida=id_col.herida;
					if(id_col.flags==0)
						father.flags=1;
					else
						father.flags=0;
					end
				end
			end
		end
	end
	if(id_col=collision(type cuerpo))
		if(id_col.z>z)
			dist_z=id_col.z-z;
		else
			dist_z=z-id_col.z;
		end
		if(id_col.rango=>dist_z)
			if(id_col<id) //manda este
				if(x<id_col.x)
					id_col.father.x_inc+=3;
					father.x_inc-=3;
					father.flags=0;
					id_col.flags=1;
				else
					id_col.father.x_inc-=3;
					father.x_inc+=3;
					father.flags=1;
					id_col.flags=0;
				end
			end
		end
	end
	frame;
End

Process ataque(x,y,graph,herida,rango);
Begin
	jugador=father.jugador;
	flags=father.flags;
	file=fpg_general;
	z=father.z;
	priority=1;
	//ctype=c_scroll;
	frame;
End

Process objeto_portado(x,y,graph);
Begin
	z=father.z-1;
	file=fpg_objetos;
	//ctype=c_scroll;
	frame;
End

Process objeto_lanzado(x,y,graph);
Begin
	flags=father.flags;
End