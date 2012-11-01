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
	ataca_area=8;
	coge_objeto=9;
	quieto_objeto=10;
	camina_objeto=11;
	salta_objeto=12;
	lanza_objeto=13;
	ataca_fuerte=14;
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
	
	coordenadas=c_scroll;
	
	struct nivel;
		struct emboscadas[20];
			x_evento;
			x_minima;
			x_maxima;
			struct enemigos[30];
				pos_x;
				pos_y;
				tipo;
			end
		end
	end
End

Local
	ancho;
	alto;
	altura;
	accion;
	herida;
	id_col;
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
include "niveles.pr-";

Begin
	//La resolución del monitor será esta:
	scale_resolution=12800720;
	
	full_screen=true;
	
	//Pero internamente trabajaremos con esto:
	set_mode(640,360,32);
		
	fpg_ripolles=load_fpg("fpg\ripolles.fpg");
	fpg_nivel=load_fpg("fpg\nivel1.fpg");
	fpg_general=load_fpg("fpg\general.fpg");
	fpg_objetos=load_fpg("fpg\objetos.fpg");
	
	//configuramos controladores
	configurar_controles();
	
	//A 30 imágenes por segundo
	set_fps(30,0);
	
	ripolles(1);
	ripolles(2);
	
	start_scroll(0,fpg_nivel,1,0,0,0);
	scroll[0].camera=camara();
	
	loop
		if(p[1].botones[b_salir]) exit(); end
		frame;
	end
End

Process camara();
Private
	suma_x;
Begin
	loop
		suma_x=0;
		j=0;
		from i=1 to 4;
			if(p[i].juega)
				suma_x+=p[i].identificador.x;
				j++;
			end
		end
		if(j>0) x=suma_x/j; end
		frame;
	end
End

Process ripolles(jugador);
Private
	pulsando_salto;
	pulsando_ataque1;
	hacia_que_lado;
Begin
	file=fpg_ripolles;
	ctype=coordenadas;
	x=50+50*jugador;
	y_base=130+40*jugador;
	altura=-300;
	accion=quieto;
	controlador(jugador);
	p[jugador].juega=1;
	p[jugador].identificador=id;
	write_int(0,0,10*(jugador-1),0,&p[jugador].vida);
	loop
		if(key(_1)) lleva_objeto=rand(1,5); end
		if(flags==0)
			hacia_que_lado=1;
		else
			hacia_que_lado=-1;
		end

		if(herida==0 and (accion==herido_leve or accion==herido_grave))
			accion=quieto;
		end
		
		if(accion==defiende and !p[jugador].botones[b_3])
			accion=quieto;
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
							if(p[jugador].botones[b_3])
								accion=ataca_area;
								p[jugador].vida-=30;
							else
								accion=ataca_suelo;
							end
						else
							accion=lanza_objeto;
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
					if(p[jugador].botones[b_3] and !p[jugador].botones[b_1])
						accion=defiende;
						if(lleva_objeto)
							objeto(x,y_base+40,altura-100,lleva_objeto,0);
							lleva_objeto=0;
						end
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

				//reducción de inercias
				friccioname();
				
			else //EN EL AIRE (SALTO)
				//ataque aereo
				if(p[jugador].botones[b_1]) 
					if(pulsando_ataque1==0)
						pulsando_ataque1=1;
						if(lleva_objeto==0)
							accion=ataca_aire;
						else
							accion=lanza_objeto;
						end					
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
				else
					y+=gravedad;
				end
			end
		else //está siendo herido
			if(accion!=herido_leve and accion!=herido_grave) //escisión!
				if(lleva_objeto)
					objeto(x,y_base+40,altura-100,lleva_objeto,0);
					lleva_objeto=0;
				end
				p[jugador].vida-=herida;
				herida=herida/1.5;
				if(flags==1)
					x_inc+=herida;
				else
					x_inc-=herida;
				end
				if(herida<15)
					accion=herido_leve;
				else
					accion=herido_grave;
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

		if(herida==0 and altura==0)
			if(accion==quieto and (x_inc!=0 or y_inc!=0))
				accion=camina;
			elseif(accion==camina and x_inc==0 and y_inc==0)
				accion=quieto;
			end
		end
		
		//pon animacion correspondiente a mi acción
		pon_animacion();
		
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
					objeto_portado(x+(-30*hacia_que_lado),y-25,lleva_objeto);
				else
					if(anim==4)
						objeto(x,y_base+40,altura-100,lleva_objeto,x_inc+(10*hacia_que_lado));
					end
				end
				if(anim==7) 
					lleva_objeto=0; 
					accion=quieto; 
				end
			else
				objeto_portado(x,y-50,lleva_objeto);
			end
		end		
		
		if(accion==ataca_suelo)
			if(anim<4)
				ataque(x+(15*hacia_que_lado),y-15,fpg_general,1,15,20);
			else
				ataque(x+(45*hacia_que_lado),y-15,fpg_general,1,10,20);
			end
			if(anim==7)
				accion=quieto; 
			end
		end

		if(accion==ataca_aire)
			ataque(x+(40*hacia_que_lado),y,fpg_general,1,30,15);
		end
		if(accion==ataca_area)
			ataque(x,y,file,graph,40,20);
			if(anim==31)
				accion=quieto;
			end
		end
		sombra();
		frame;
	end
End

Function pon_animacion();
Begin
	if(father.herida==0)
		if(father.altura==0)
			if(father.accion==quieto)
				if(father.lleva_objeto>0)
					father.animacion=quieto_objeto;
				else
					father.animacion=quieto;
				end
			end
			if(father.accion==camina)
				if(father.lleva_objeto>0)
					father.animacion=camina_objeto;
				else
					father.animacion=camina;
				end
			end
			if(father.accion==ataca_suelo)
				father.animacion=ataca_suelo;
			end
			if(father.accion==ataca_area)
				father.animacion=ataca_area;
			end
			if(father.accion==defiende)
				father.animacion=defiende;
			end
		else //en el aire
			if(father.lleva_objeto>0)
				father.animacion=salta_objeto;
			else
				if(father.accion==ataca_aire)
					father.animacion=ataca_aire;
				else
					father.animacion=salta;
				end
			end
		end
	else //herido:
		if(father.accion==herido_leve)
			father.animacion=herido_leve;
		else
			father.animacion=herido_grave;
		end
	end
End

Function mueveme();
Begin
		father.y_base+=father.y_inc;
		father.y=father.y_base+father.altura;
		father.z=-father.y_base;

		if(father.x<0 and father.x_inc<0) father.x_inc*=-1; end

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
			father.graph=1;
		end
		case camina:
			if(anim<6) 
				father.graph=11;
			elseif(anim<12)
				father.graph=12;
			elseif(anim<18)
				father.graph=13;
			elseif(anim<24)
				father.graph=14;
			else 
				father.graph=13;
			end
			anim_max=30;
		end
		case salta:
			if(father.gravedad<0) //sube
				father.graph=21;
			else //baja
				father.graph=22;
			end
		end
		case ataca_suelo:
			if(anim<4) 
				father.graph=31;
			else
				father.graph=32;
			end
			anim_max=8;
		end
		case ataca_aire:
			father.graph=42;
		end
		case defiende:
			father.graph=51;
		end
		case herido_leve:
			father.graph=61;
		end
		case herido_grave:
			if(father.altura==0)
				father.graph=73;
			elseif(father.gravedad<=0) //sube
				father.graph=71;
			elseif(father.gravedad>0) //baja
				father.graph=72;
			end
		end
		case ataca_area:
			if(anim<4) 
				father.graph=81;
			elseif(anim<8)
				father.graph=82;
			elseif(anim<12)
				father.graph=83;
			elseif(anim<16)
				father.graph=84;
			elseif(anim<20) 
				father.graph=81;
			elseif(anim<24)
				father.graph=82;
			elseif(anim<28)
				father.graph=83;
			else
				father.graph=84;
			end
			anim_max=32;
		end
		case coge_objeto:
			father.graph=9;
		end
		case quieto_objeto:
			father.graph=101;
		end
		case camina_objeto:
			if(anim<6) 
				father.graph=111;
			elseif(anim<12)
				father.graph=112;
			elseif(anim<18)
				father.graph=113;
			elseif(anim<24)
				father.graph=114;
			else 
				father.graph=113;
			end
			anim_max=30;
		end
		case salta_objeto:
			if(father.gravedad<0) //sube
				father.graph=121;
			else //baja
				father.graph=122;
			end
		end
		case lanza_objeto:
			if(anim<4)
				father.graph=131;
			else
				father.graph=132;
			end
		end
		case ataca_fuerte:
			father.graph=14;
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
End

Process cuerpo();
Private
	dist_z;
Begin
	jugador=father.jugador;
	ctype=coordenadas;
	x=father.x;
	y=father.y;
	z=father.z-1;
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

Process ataque(x,y,file,graph,herida,rango);
Begin
	jugador=father.jugador;
	flags=father.flags;
	z=father.z;
	priority=1;
	ctype=coordenadas;
	frame;
End

Process objeto_portado(x,y,graph);
Begin
	z=father.z-1;
	file=fpg_objetos;
	ctype=coordenadas;
	frame;
End

Process objeto(x,y_base,altura,graph,x_inc);
Begin
	y=y_base+altura;
	z=y_base-1;
	file=fpg_objetos;
	x_inc=x_inc*2;
	flags=father.flags;
	jugador=father.jugador;
	ctype=coordenadas;
	loop
		aplica_gravedad();
		if(altura==0)
			friccioname();
		end
		mueveme();
		if(x_inc!=0)
			ataque(x,y,file,graph,abs(x_inc),40);
		end
		z--;
		frame;
	end
End

Function aplica_gravedad();
Begin
	if(father.altura<0)
		father.gravedad+=2;
		father.altura+=father.gravedad;
		if(father.altura>1)
			father.altura=0;
			father.gravedad=0;
		else
			father.y+=father.gravedad;
		end
	end
End

Process sombra();
Begin
	y=father.y_base+55;
	z=father.z+10;
	x=father.x;
	altura=father.altura;
	ctype=coordenadas;
	file=fpg_general;
	graph=3;
	alpha=200+altura;
	size=100+(altura/3);
	frame;
End