program prueba;
import "mod_image";
global
	wii; //si estamos en la wii, esto debe ser 1
	buzz; //si jugamos con buzzers, esto debe ser 1
	joy_buzz; //este es el numero del joy de los buzzers
	wavs[11]; //1:bigbuzz,2:done,3:right,4:wrong,5:select1,6:select2,
				//7:select3,8:select4,9:tfinish,10:timeclac,11:timeclic
	fnts[3]; //1:puntos,2:textos,3:letreros
	
	struct jugador[4]; //datos de los jugadores
		botones[4]; //[botones: (rojo 0, resto 1-4)] 		
		boton_suelto;
		rebote; //si ha fallado, rebota
		puntos;
		juega; //si juega
	end
	
	correcta=1; //num respuesta correcta
	ready; //servirá para que pause el texto ssi alguien pulsa el botón
	jugadores; //de 1 a 4
	
	string txt_respuestas[4]; //0: pregunta, 1-4 respuestas
	id_txt_pregunta[2]; //ids de los writes de los textos de las preguntas
	id_txt_respuesta[4]; //ids de los writes de los textos de las preguntas
	id_txt_puntos[4];
	
	boton;
	
	posicion_fichero;
	string fichero="0"; //nombre del quizz a cargar
local
	i;

//MAIN	
begin
	//estamos en la Wii?
	if(os_id==1000) wii=1; end
	
	//seteo de pantalla
	full_screen=1; //pantalla completa por defecto
	set_fps(60,0); //60fps nos dará un buen control sobre el juego
	if(wii) scale_resolution=06400480; end //resolución de la Wii
	set_mode(1024,768,16);
	
	frame; //inicializamos previo a cargar recursos gráficos
	
	//cargamos recursos: fpg, fnt, wav
	load_fpg("quizz.fpg");
	from i=1 to 4; fnts[i]=load_fnt(i+".fnt"); end
	from i=1 to 11; wavs[i]=load_wav(i+".wav"); end

	//para unificar los difrentes controles
	controlador(); 

	//PRUEBAS!!!!!!!!!!!!!!!
	txt_respuestas[0]="¿De qué color es el lago pipicaca?";
	txt_respuestas[1]="Verde";
	txt_respuestas[2]="Amarillo";
	txt_respuestas[3]="Rojo";
	txt_respuestas[4]="Aún más rojo";

	//intro & elección de jugadores
	presentacion();
End

// PRESENTACIÓN Y ELECCIÓN DE JUGADORES
Process presentacion();
Private
	grav;
Begin
	//colocamos en el centro la imagen de presentación
	x=512; y=384; z=-1;
	graph=23;
	
	//y una música de introducción, en bucle
	musica("aperture");
	
	//que haga un fade in para aparecer
	from alpha=0 to 255 step 2; frame; end

	//vamos poniendo el fondo del juego, que no se verá hasta que se aparte el grafico de la presentación
	put_screen(0,21);

	write(fnts[3],512,600,4,"Pulsa intro para continuar...");
	
	//si hay Buzzers o mandos de Wii podrá haber más de un jugador
	if(wii or buzz)
		write(fnts[3],512,520,4,"¡Pulsar un botón de cada mando para jugar!");
		loop
			if(jugadores>0 and key(_enter)) break; end
			from i=1 to 4; if(jugador[i].botones[0] and !jugador[i].juega) jugador[i].juega=1; jugadores++; para_jugar(i); end end
			frame;
		end
	else //sino, sólo 1
		jugadores=1;
		jugador[1].juega=1;
		while(!key(_enter)) frame; end
	end
	delete_text(all_text);
	//para que desaparezcanlos botoncicos de los jugadores
	ready=1;

	//quitamos la música en medio segundo
	fade_music_off(50);

	//transición chula
	set_center(0,23,1024,0);
	x=1024;
	y=0;
	while(angle<90000) angle+=(grav/2)*300; grav++; frame; end
	
	musica("quizz");
	
	ronda();
end

//NUEVA RONDA/PREGUNTA
process ronda();
Private;
	num_rebotes;
	j;
Begin
	//no estamos pulsando ningún botón
	boton=0;
	
	//actualizamos marcadores
	marcadores();

	pon_pregunta();
	
	//reiniciamos los rebotes
	from i=1 to 4; jugador[i].rebote=0; end
	
	x=512; y=200; z=-1;
	ready=1;
	loop
		from i=1 to 4; 
		  if(jugador[i].juega)
			if(jugador[i].botones[0] and jugador[i].rebote==0)
				parpadeo();
				graph=30+i; // Esto será un icono de "JUGADOR 1" y cosas asín...
				
				sonido(1);
				ready=0;

				frame(2000);
				from alpha=255 to 50 step -20; size-=5; frame; end
				size=0;
				
				tiempo();
				
				while(boton==0 and exists(type tiempo))
					from j=1 to 4;
						if(jugador[i].botones[j]) boton=j; end
					end
					frame; 
				end
				
				if(boton!=0) sonido(boton+4); end
						
				size=100;
				alpha=255;
				graph=3;
				x=512;
				y=718-((boton-1)*78);
				if(boton!=0) frame(6000); end //hacemos un parón para intrigar, a menos que se haya acabado el tiempo
				
				if(boton==correcta)
					jugador[i].puntos++; 
					sonido(3);
					parpadeo();
					graph=4;
					frame(4000);
					ronda();
					return;
				else //rebote!
					parpadeo();
					jugador[i].rebote=1;
								
					//put_screen(0,24);
					sonido(4);
		
					num_rebotes=0;
					from i=1 to 4; if(jugador[i].rebote or !jugador[i].juega) num_rebotes++; end end
					if(num_rebotes==4) //fail...
						//podríamos dar la solución... o no?
						ronda(); 
						return; 
					end					
					
					ready=1;
					boton=0;
					graph=0;
					size=100;
					alpha=255;
					x=512;
					y=200;
				end
		    end
		  end
		end
		frame;
	end
End

process parpadeo();
begin

	graph=25;
	x=512; y=384;
	z=-5;
	frame(300);
end

Process pon_pregunta();
Private
	lineas; //numero de lineas para ordenar el texto, cada 40 caracteres
	num_letras_juntas;
	string txt_pregunta[2];
	string txt_respuesta[4];
	num_caracter;
	todolleno;
	id_fichero;
	j;
	string ejecutar;
Begin
	//importante! las respuestas deben ir ordenadas de abajo a arriba!

	//leemos la siguiente pregunta y sus respuestas
	id_fichero=fopen("quizz/"+fichero+".txt",O_READ);
	if(posicion_fichero!=0) fseek(id_fichero,posicion_fichero,0); end
	from i=0 to 4; 
		txt_respuestas[i]=""; //vaciamos la anterior
		while((txt_respuestas[i]=="" or txt_respuestas[i][0]=="#") and !feof(id_fichero)) 
			txt_respuestas[i]=fgets(id_fichero); 
		end //y buscamos lineas con contenido
		
		if(feof(id_fichero))
			final();
			return;
		end
		
		if(txt_respuestas[i][0]=="$" or txt_respuestas[i][0]=="?") //pregunta con cosas...
			from j=1 to len(txt_respuestas[i]);
				if(txt_respuestas[i][j]=="#") break; else ejecutar+=""+txt_respuestas[i][j]; end
			end
			txt_respuestas[i]=substr(txt_respuestas[i],j+1);
		end
		
		if(txt_respuestas[i][0]=="-") //respuestas!
			if(txt_respuestas[i][1]=="*") //correcta!
				correcta=i;
			end
			txt_respuestas[i]=substr(txt_respuestas[i],2);
		end
	end

	posicion_fichero=ftell(id_fichero);
	fclose(id_fichero);
	
	//para la pregunta hay una línea seguro...
	lineas=1;
	
	loop
		//vamos borrando y poniendo textos continuamente
		from i=1 to 4; if(id_txt_respuesta[i]!=0) delete_text(id_txt_respuesta[i]); end end
		from i=1 to 4; if(id_txt_pregunta[i]!=0) delete_text(id_txt_pregunta[i]); end end
		
		//txt_pregunta[1]=txt_respuestas[0];
		if(num_caracter<=len(txt_respuestas[0])) //si no hemos rellenado la pregunta del todo aún
			i=num_caracter;
			num_letras_juntas=0;
			
			while(txt_respuestas[0][i]!=" " and i<=len(txt_respuestas[0])) 
				i++; 
				num_letras_juntas++; 
			end
			
			//comprobamos si tenemos que saltar linea, aunque si hay una palabra salvajemente larga, pasamos.
			if(num_caracter+num_letras_juntas=>40 and num_letras_juntas<40) lineas=2; end
		
			if(lineas==1) txt_pregunta[1]+=""+txt_respuestas[0][num_caracter]; end
			if(lineas==2) txt_pregunta[2]+=""+txt_respuestas[0][num_caracter]; end
		else //si ya hemos rellenado la pregunta
			//nos servirá para comprobar si ya hemos metido los textos del todo.
			todolleno=2;
		end
		
		//si hay 1 linea de texto la Y será 384. Sino, en la linea 1 será 369 y en la segunda 396
		if(lineas==1) id_txt_pregunta[1]=write(fnts[2],512,384,4,txt_pregunta[1]); end
		if(lineas==2) 
			id_txt_pregunta[1]=write(fnts[2],512,369,4,txt_pregunta[1]); 
			id_txt_pregunta[2]=write(fnts[2],512,396,4,txt_pregunta[2]);
		end
		
		from i=1 to 4;
			if(len(txt_respuesta[i])!=len(txt_respuestas[i])) txt_respuesta[i]+=""+txt_respuestas[i][num_caracter]; else todolleno++; end
			id_txt_respuesta[i]=write(fnts[2],295,713-((i-1)*78),3,txt_respuesta[i]);
		end
		
		//si ya hemos metido todos los textos del todo, no hace falta que continuemos borrando y reescribiendo
		//if(todolleno==6 or !exists(father)) break; end
		if(!exists(father)) break; end
		
		while(!ready) frame; end
		frame(500);
		num_caracter++;
	end
End

Process controlador();
Private
	j;
Begin
	//Comprobamos si hay algun buzz controller puesto.
	//Como ya está claro que los controladores Buzz tienen más nombres que una ..
	//sólo comprobaremos si tiene 20 botones. xD
	from i=0 to joy_number();
		if(joy_numbuttons(i)==20) joy_buzz=i; buzz=1; end
	end
	
	loop
		if(key(_esc)) final(); end
		if(buzz)
			from i=1 to 4; //jugadores
				from j=0 to 4; //botones
					if(jugador[i].boton_suelto and get_joy_button(joy_buzz,((i-1)*5)+(j))) //comprobamos todos los botones de todos.
						jugador[i].botones[j]=1;
						jugador[i].boton_suelto=0;
					else
						jugador[i].botones[j]=0;
					end
				end
				if(!(get_joy_button(joy_buzz,((i-1)*5)) or get_joy_button(joy_buzz,(((i-1)*5)+1)) 
				or get_joy_button(joy_buzz,(((i-1)*5)+2)) or get_joy_button(joy_buzz,(((i-1)*5)+3)) 
				or get_joy_button(joy_buzz,(((i-1)*5)+4))))
					jugador[i].boton_suelto=1;
				end
			end
		else
			if(wii)
				//con Wiimotes??
			else
				//con teclado? one player only!
				if(jugador[1].boton_suelto)
					if(key(_1)) jugador[1].botones[4]=1; jugador[1].boton_suelto=0; end
					if(key(_q)) jugador[1].botones[3]=1; jugador[1].boton_suelto=0; end
					if(key(_a)) jugador[1].botones[2]=1; jugador[1].boton_suelto=0; end
					if(key(_z)) jugador[1].botones[1]=1; jugador[1].boton_suelto=0; end
					if(key(_enter)) jugador[1].botones[0]=1; jugador[1].boton_suelto=0; end
				else
					from i=0 to 4; jugador[1].botones[i]=0; end
					if(!(key(_1) or key(_q) or key(_a) or key(_z) or key(_enter))) jugador[1].boton_suelto=1; end
				end
			end
		end
		frame;
	end
End

Process para_jugar(num);
Begin
	x=512-500+(num*200);
	y=600;
	z=-2;
	graph=30+num;
	size=30;
	alpha=200;
	while(ready==0)
		if(size<50) size+=2; end
		if(alpha<255) alpha+=5; end
		frame;
	end
	from size=50 to 40 step -2; alpha-=5; frame; end
End

Process musica(string cancion);
Begin
	play_song(load_song(cancion+".xm"),-1);
End

Process sonido(i);
Begin
	play_wav(wavs[i],0);
End

//actualizamos marcadores
Function marcadores();
Private
	string temp;
Begin
	//borramos lo que hubiera y los ponemos actualizados
	from i=1 to 4;
		if(id_txt_puntos[i]!=0) delete_text(id_txt_puntos[i]); end
		switch(i); 
			case 1: x=110; end 
			case 2: x=375; end
			case 3: x=640; end
			case 4: x=910; end
		end
		if(jugador[i].juega)
			if(jugador[i].puntos==0) temp="00"; end
			if(jugador[i].puntos<10) temp="0"+jugador[i].puntos; end
			if(jugador[i].puntos=>10) temp=jugador[i].puntos; end
			id_txt_puntos[i]=write(fnts[1],x,268,4,temp);
		else
			temp="X";
			id_txt_puntos[i]=write(fnts[3],x,268,4,temp);
		end
	end
End

Process final();
Private
	ganadores[4][2]; //2º[]-> 1:jugador,2:puntos
	aux[2]; //para intercambios
	temp;
	posicion;
	cambios;
	j;
Begin
	from i=1 to 4; 
		ganadores[i][1]=i; 
		ganadores[i][2]=jugador[i].puntos; 
	end

	loop
		cambios=0;
		from i=1 to 4; 
			from j=1 to 4;
				if(j<i and ganadores[i][2]>ganadores[j][2])
					aux[1]=ganadores[j][1];
					aux[2]=ganadores[j][2];
					ganadores[j][1]=ganadores[i][1];
					ganadores[j][2]=ganadores[i][2];
					ganadores[i][1]=aux[1];
					ganadores[i][2]=aux[2];
					cambios=1;
				end
			end
		end
		if(cambios==0) break; end
	end

	let_me_alone();
	delete_text(all_text);
	
	marcadores();
	musica("taluego");
	put_screen(0,22);
	write(fnts[3],512,150,4,"Resultados");
	
	if(ganadores[1][2]!=ganadores[2][2]) write(fnts[3],512,400,4,"Ganador jugador "+ganadores[1][1]); end
	if(ganadores[1][2]==ganadores[2][2] and ganadores[1][2]!=ganadores[3][2]) write(fnts[3],512,400,4,"Empate entre jugador "+ganadores[1][1]+" y jugador "+ganadores[2][1]); end
	if(ganadores[1][2]==ganadores[2][2] and ganadores[1][2]==ganadores[3][2] and ganadores[1][2]!=ganadores[4][2]) 
		write(fnts[3],512,400,4,"Empate entre los jugadores "+ganadores[1][1]+", "+ganadores[2][1]+" y "+ganadores[3][1]); 
	end
	if(ganadores[1][2]==ganadores[2][2] and ganadores[1][2]==ganadores[3][2] and ganadores[1][2]!=ganadores[4][2]) 
		write(fnts[3],512,400,4,"¡Todos empatados!"); 
	end
	
	while(!key(_enter)) frame; end	
End

Process tiempo();
Private
	id_txt;
	segundos;
Begin
	id_txt=write_int(fnts[3],100,384,4,&segundos);
	from i=360 to 1 step -1;
		segundos=i/60;
		if(boton!=0) break; end
		if(i%60==0) 
			if(i%2==0)
				sonido(11);
			else
				sonido(10);
			end
		end
		frame;
	end
	delete_text(id_txt);
End

Process imagen_en_pantalla(graph);
Begin
End