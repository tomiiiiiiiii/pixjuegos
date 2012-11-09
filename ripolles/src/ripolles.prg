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
	ancho_nivel;
	//estructuras de los personajes
	struct p[100];
		botones[7];
		vida=50;
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
	fpg_enemigo1;
	fpg_enemigo2;
	fpg_enemigo3;
	fpg_enemigo4;
	enemigos;
	id_camara;
	
	ancho_pantalla=640;
	alto_pantalla=360;
	
	coordenadas=c_scroll;

	anterior_emboscada;
	en_emboscada;
	
	struct emboscada[20];
		x_evento;
		x_minima;
		x_maxima;
		struct enemigo[30];
			pos_x;
			pos_y;
			tipo;
			x_trigger;
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
	//scale_resolution=12800720;
	
	//full_screen=true;
	
	//Pero internamente trabajaremos con esto:
	set_mode(ancho_pantalla,alto_pantalla,32);
		
	fpg_ripolles=load_fpg("fpg\ripolles.fpg");
	fpg_enemigo1=load_fpg("fpg\enemigo1.fpg");
	fpg_enemigo2=load_fpg("fpg\enemigo2.fpg");
	fpg_enemigo3=load_fpg("fpg\enemigo2.fpg");
	fpg_enemigo4=load_fpg("fpg\enemigo4.fpg");
	fpg_nivel=load_fpg("fpg\nivel1.fpg");
	fpg_general=load_fpg("fpg\general.fpg");
	fpg_objetos=load_fpg("fpg\objetos.fpg");
	
	//configuramos controladores
	configurar_controles();
	
	//A 30 imágenes por segundo
	set_fps(30,0);

	carga_nivel(1);
	
	ancho_nivel=graphic_info(fpg_nivel,1,G_WIDTH);
	start_scroll(0,fpg_nivel,1,0,0,0);
	id_camara=scroll[0].camera=camara();
	
	personaje(1,0);
	//personaje(2);
	//personaje(3);
/*	from i=1 to 20;
		emboscada[]
	end*/
	/*enemigo(10,1);
	enemigo(11,2);
	enemigo(12,3);
	enemigo(13,4);*/
		
	loop
		if(p[1].botones[b_salir]) exit(); end
		frame;
	end
End

Process camara();
Private
	suma_x;
Begin
	from i=1 to 30;
		if(emboscada[en_emboscada+1].enemigo[i].tipo!=0)			
			enemigo(10+i,emboscada[en_emboscada+1].enemigo[i].tipo,emboscada[en_emboscada+1].enemigo[i].pos_x,emboscada[en_emboscada+1].enemigo[i].pos_y,emboscada[en_emboscada+1].enemigo[i].x_trigger);
		end
	end

	loop
		suma_x=0;
		j=0;
		from i=1 to 4;
			if(p[i].juega)
				suma_x+=p[i].identificador.x;
				j++;
			end
		end
		if(j>0)
			if(distancia_jugador(personaje_mas_avanzado()>ancho_pantalla/4))
				x_inc=6;
			else
				x_inc=3;
			end
			if(x<suma_x)
				x+=x_inc;
				if(x>suma_x) x=suma_x; end
			elseif(x>suma_x)
				x-=x_inc;
				if(x<suma_x) x=suma_x; end
			end
			//x=suma_x/j; 
		end
		
		if(x<ancho_pantalla/2) x=ancho_pantalla/2; end
		if(x>ancho_nivel-(ancho_pantalla/2)) x=ancho_nivel-(ancho_pantalla/2); end
		if(en_emboscada>0)
			if(x<emboscada[en_emboscada].x_minima) x=emboscada[en_emboscada].x_minima; end
			if(x>emboscada[en_emboscada].x_maxima) x=emboscada[en_emboscada].x_maxima; end
			if(enemigos==0)
				from i=1 to 30;
					if(emboscada[en_emboscada+1].enemigo[i].tipo!=0)
						enemigo(10+i,emboscada[en_emboscada+1].enemigo[i].tipo,emboscada[en_emboscada+1].enemigo[i].pos_x,emboscada[en_emboscada+1].enemigo[i].pos_y,emboscada[en_emboscada+1].enemigo[i].x_trigger);
					end
				end
				anterior_emboscada=en_emboscada;
				en_emboscada=0;
			end
		else
			if(x=>emboscada[anterior_emboscada+1].x_evento and emboscada[anterior_emboscada+1].x_evento!=0)
				en_emboscada=anterior_emboscada+1;
			end
		end
		frame;
	end
End

Process personaje(jugador,tipo);
Private
	pulsando_salto;
	pulsando_ataque1;
	hacia_que_lado;
	ia;
	inercia_max;
	fuerza_ataque;
Begin
	if(jugador>10)
		ia=1;
	end
	ctype=coordenadas;
	if(jugador<10)
		x=50+50*jugador;
		y_base=130+40*jugador;
		controlador(jugador);
		file=fpg_ripolles;
		inercia_max=6;
		fuerza_ataque=10;
		altura=-300;
	else
		x=rand(0,640);
		y_base=rand(100,360);
		switch(tipo)
			case 1:
				inercia_max=3;
				fuerza_ataque=10;
			end
			case 2:
				inercia_max=4;
				fuerza_ataque=15;
			end
			case 3:
				inercia_max=2;
				fuerza_ataque=20;
			end
			case 4:
				inercia_max=5;
				fuerza_ataque=25;
			end
		end
	end
	accion=quieto;
	p[jugador].juega=1;
	p[jugador].identificador=id;
	//write_int(0,0,10*(jugador-1),0,&p[jugador].vida);
	//write_int(0,0,10*(jugador-1),0,&x);
	loop
		if(p[jugador].vida<1) accion=muere; herida=100; end
		
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
								if(accion==quieto and x_inc==0 and (id_col=collision(type objeto)))
									if(id_col.y>y+35)
										lleva_objeto=id_col.graph;
										accion=coge_objeto;
										signal(id_col,s_kill);
									else
										accion=ataca_suelo;
									end
								else
									accion=ataca_suelo;
								end
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
							objeto(x,y_base,altura-100,lleva_objeto,0);
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
			//no herido, común de suelo y aire
			if(accion!=herido_leve and accion!=herido_grave and accion!=muere)
				inercia_maxima(inercia_max,3); 
			end
		else //está siendo herido
			if(accion!=herido_leve and accion!=herido_grave and accion!=muere) //escisión!
				if(lleva_objeto)
					objeto(x,y_base,altura-100,lleva_objeto,0);
					lleva_objeto=0;
				end
				p[jugador].vida-=herida;
				if(herida<20 and altura==0)
					accion=herido_leve;
					herida=15; //más retraso
					if(flags==1)
						x_inc=herida*0.8;
					else
						x_inc=-herida*0.8;
					end
				else
					accion=herido_grave;
					if(herida>15)
						gravedad=-herida;
					else
						gravedad=-15;
					end
					if(flags==1)
						x_inc=herida/4;
					else
						x_inc=-herida/4;
					end
					altura=-1;
				end

			else
				if(altura==0)
					herida--;
				end
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
		
		if(herida==0 and altura==0)
			if(accion==quieto and (x_inc!=0 or y_inc!=0))
				accion=camina;
			elseif(accion==camina and x_inc==0 and y_inc==0)
				accion=quieto;
			end
		end
		
		//pon animacion correspondiente a mi acción
		pon_animacion();
		
		//gestiones comunes de los personajes en juego
		mueveme();
		animame();
		cuerpo();
		sombra();
		
		//gestion del objeto portado o siendo cogido
		if(lleva_objeto!=0)
			if(accion==lanza_objeto)
				if(anim<4)
					objeto_portado(x+(-30*hacia_que_lado),y-25,lleva_objeto);
				else
					if(anim==4)
						objeto(x,y_base,altura-100,lleva_objeto,x_inc+(10*hacia_que_lado));
					end
				end
				if(anim==7)
					lleva_objeto=0; 
					accion=quieto; 
				end
			elseif(accion==coge_objeto)
				if(anim<4)
					objeto_portado(x+(-20*hacia_que_lado),y+35,lleva_objeto);
				else
					if(anim==7)
						accion=quieto;
					end
				end
			else
				objeto_portado(x,y-34,lleva_objeto);
			end
		end		
		
		//gestión de los ataques (puntos de colisión de los ataques
		if(accion==ataca_suelo)
			if(anim<4)
				ataque(x+(15*hacia_que_lado),y-15,fpg_general,1,fuerza_ataque,20);
			else
				ataque(x+(45*hacia_que_lado),y-15,fpg_general,1,fuerza_ataque*1.5,20);
			end
			if(anim==7)
				accion=quieto; 
			end
		end
		if(accion==ataca_aire)
			ataque(x+(40*hacia_que_lado),y,fpg_general,1,fuerza_ataque*2,15);
		end
		if(accion==ataca_area)
			ataque(x,y,file,graph,fuerza_ataque*2.5,20);
			if(anim==23)
				accion=quieto;
			end
		end
		frame;
	end
End

Function inercia_maxima(max_x,max_y);
Begin
	if(father.x_inc>0)
		if(father.x_inc>max_x) father.x_inc=max_x; end
	elseif(father.x_inc<0)
		if(father.x_inc<-max_x) father.x_inc=-max_x; end
	end
	if(father.y_inc>0)
		if(father.y_inc>max_y) father.y_inc=max_y; end
	elseif(father.y_inc<0)
		if(father.y_inc<-max_y) father.y_inc=-max_y; end
	end
End

Function pon_animacion();
Begin
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
	if(father.accion==ataca_suelo)
		father.animacion=ataca_suelo;
	end
	if(father.accion==ataca_area)
		father.animacion=ataca_area;
	end
	if(father.accion==defiende)
		father.animacion=defiende;
	end
	if(father.accion==coge_objeto)
		father.animacion=coge_objeto;
	end
	if(father.accion==lanza_objeto)
		father.animacion=lanza_objeto;
	end
	if(father.accion==herido_leve)
		father.animacion=herido_leve;
	end
	if(father.accion==herido_grave)
		father.animacion=herido_grave;
	end
	if(father.accion==muere)
		father.animacion=muere;
	end
End

Function mueveme();
Begin
		father.y_base+=father.y_inc;
		father.y=father.y_base+father.altura;
		father.z=-father.y_base;

		if(father.y_base<135) father.y_base=135; end
		if(father.y_base>305) father.y_base=305; end
	
		if((father.x<30 and father.x_inc<0) or (father.x>ancho_nivel-30 and father.x_inc>0)) father.x_inc*=-1; end

		if(father.jugador<10)
			if(father.x<id_camara.x-300) father.x=id_camara.x-300; end
			if(father.x>id_camara.x+300) father.x=id_camara.x+300; end
		end
		
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
			if(anim<2) 
				father.graph=81;
			elseif(anim<4)
				father.graph=82;
			elseif(anim<6)
				father.graph=83;
			elseif(anim<8)
				father.graph=84;
			elseif(anim<10) 
				father.graph=81;
			elseif(anim<12)
				father.graph=82;
			elseif(anim<14)
				father.graph=83;
			elseif(anim<16)
				father.graph=84;
			elseif(anim<18) 
				father.graph=81;
			elseif(anim<20)
				father.graph=82;
			elseif(anim<22)
				father.graph=83;
			else
				father.graph=84;
			end
			anim_max=24;
		end
		case coge_objeto:
			if(anim<4) 
				father.graph=91;
			else
				father.graph=92;
			end
			anim_max=8;
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
		case muere:
			father.graph=72;
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

Function en_rango(z1,z2,rango);
Private
	dist_z;
Begin
	if(z1>z2)
		dist_z=z1-z2;
	else
		dist_z=z2-z1;
	end	
	if(rango>dist_z) 
		return 1; 
	else
		return 0;
	end
End

Process cuerpo();
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
	size=80;
	if(father.accion!=herido_leve and father.accion!=herido_grave and father.accion!=ataca_area)
		if(id_col=collision(type ataque))
			if(id_col.jugador!=jugador)
				if(en_rango(z,id_col.z,rango))
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
			if(en_rango(z,id_col.z,rango))
				if(id_col<id) //manda este
					if(x<id_col.x)
						if(id_col.father.accion!=herido_grave)
							id_col.father.x_inc+=3;
							id_col.father.y_inc+=2;
							if(id_col.father.accion==quieto)
								id_col.father.flags=1;
							end
						end
						father.x_inc-=3;
						father.y_inc-=2;
						if(father.accion==quieto)
							father.flags=0;
						end
					else
						if(id_col.father.accion!=herido_grave)
							id_col.father.x_inc-=3;
							id_col.father.y_inc-=2;
							if(id_col.father.accion==quieto)
								id_col.father.flags=0;
							end
						end
						father.x_inc+=3;
						father.y_inc+=2;
						if(father.accion==quieto)
							father.flags=1;
						end
					end
				end
			end
		end
	else
		if(father.accion==herido_grave and father.x_inc!=0)
			ataque(x,y,fpg_general,1,abs(father.x_inc),40);
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
	alpha=0;
	frame;
End

Process objeto_portado(x,y,graph);
Begin
	z=father.z-1;
	flags=father.flags;
	file=fpg_objetos;
	if(flags)
		x-=5;
	else
		x+=5;
	end
	ctype=coordenadas;
	frame;
End

Process objeto(x,y_base,altura,graph,x_inc);
Begin
	y=y_base+altura+50;
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
		y+=50; //parche para alinear el objeto con el suelo
		if(x_inc!=0)
			ataque(x,y,file,graph,abs(x_inc),40);
		end
		z--;
		sombra();
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
	alpha=father.alpha+altura;
	size=100+(altura/3);
	frame;
End

Function jugador_mas_cercano();
Private
	dist_x;
	dist_x_ganador=1000;
Begin
	from i=1 to 4;
		if(p[i].juega and i!=father.jugador)
			if(p[i].identificador.x<father.x)
				dist_x=father.x-p[i].identificador.x;
			else
				dist_x=p[i].identificador.x-father.x;
			end
			if(dist_x<dist_x_ganador)
				j=i;
				dist_x_ganador=dist_x;
			end
		end
	end
	
	return j;
End

Function distancia_jugador(jugador);
Begin
	if(p[jugador].identificador.x<father.x)
		return father.x-p[jugador].identificador.x;
	else
		return p[jugador].identificador.x-father.x;
	end	
End

Function lado_jugador(jugador);
Begin
	if(p[jugador].identificador.x<father.x)
		return 1; //a la izquierda
	else
		return 0; //a la derecha
	end
End

Function estoy_en_pantalla();
Begin
	if(exists(id_camara))
		if(father.x>id_camara.x+(ancho_pantalla/2))
			return 0; 
		else
			return 1;
		end
	else
		return 1;
	end
End

Function personaje_mas_avanzado();
Private
	max_x;
Begin
	from i=1 to 4;
		if(p[i].juega)
			if(p[i].identificador.x>max_x)
				j=i;
				max_x=p[i].identificador.x;
			end
		end
	end
End

Process enemigo(jugador,tipo,x,y,x_trigger);
Private
	objetivo;
	e; //id enemigo
	o; //id objetivo
	piensa;
Begin
	e=personaje(jugador,tipo);
	e.x=x;
	e.y_base=y;
	enemigos++;
	
	while(!exists(id_camara)) frame; end
	
	switch(tipo)
		case 1: 
			e.file=fpg_enemigo1; 
			p[jugador].vida=50;
		end
		case 2: 
			e.file=fpg_enemigo2; 
			p[jugador].vida=80;
		end
		case 3: 
			e.file=fpg_enemigo3; 
			p[jugador].vida=100;
		end
		case 4: 
			e.file=fpg_enemigo4; 
			p[jugador].vida=120;
		end
	end
	
	while(!estoy_en_pantalla())	frame(2000); end
	while(id_camara.x<x_trigger) frame(2000); end
	
	loop
		x=e.x;
		y=e.y;
		accion=e.accion;
		from i=0 to 7; p[jugador].botones[i]=0;	end
		if(objetivo==0)
			objetivo=jugador_mas_cercano();
			//objetivo=1;
		else
			o=p[objetivo].identificador;
			if(e.accion==quieto or e.accion==camina)
				if(o.herida==0)
					if(distancia_jugador(objetivo)>60 or !en_rango(o.z,e.z,50))
						if(o.x_inc!=0 and distancia_jugador(objetivo)<150) //objetivo en movimiento
							//IA patrocinada por los fantasmas del Super Mario World
							if(lado_jugador(objetivo)) //a la izquierda
								if(o.flags==1) //se aleja o está lejos, vamos a por él!
									p[jugador].botones[b_izquierda]=1;
								else //viene a por nosotros, HUYAMOS!!
									p[jugador].botones[b_derecha]=1;
								end
							else //a la derecha
								if(o.flags==0) //se aleja, vamos a por él!
									p[jugador].botones[b_derecha]=1;
								else //viene a por nosotros, HUYAMOS!!
									p[jugador].botones[b_izquierda]=1;
								end							
							end
						else //objetivo quieto
							if(lado_jugador(objetivo)) //a la izquierda
								p[jugador].botones[b_izquierda]=1;
							else //a la derecha
								p[jugador].botones[b_derecha]=1;
							end						
						end
						
						if(!en_rango(o.z,e.z,20) and distancia_jugador(objetivo)<200)
							if(e.z<o.z)
								p[jugador].botones[b_arriba]=1;
							else
								p[jugador].botones[b_abajo]=1;
							end
						end
					else //tenemos al objetivo lo suficientemente cerca como para atacar
						if(rand(1,100)==1)
							p[jugador].botones[b_1]=1; 
						end
					end
				else	//objetivo herido: nos separamos
					/*if(lado_jugador(objetivo)) //a la izquierda
						p[jugador].botones[b_derecha]=1;
					else //a la derecha
						p[jugador].botones[b_izquierda]=1;
					end*/
				end
			end
			if(e.accion==quieto or e.accion==camina)
				e.flags=lado_jugador(objetivo); //a la izquierda
			end
			if(e.herida!=0) objetivo=0; end
			if(e.accion==muere)
				frame(3000);
				from i=255 to 0 step -15; e.alpha=i; frame; end
				enemigos--;
				signal(e,s_kill);
				return;
			end
		end
		frame;
	end	
End