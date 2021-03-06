/* fsock example
Mini BennuGD WebServer by SplinterGU
*/
import "fsock"
import "mod_screen"
import "mod_video"
import "mod_map"
import "mod_draw"
import "mod_grproc"
import "mod_key"
import "mod_timers"
import "mod_text"
import "mod_proc"
import "mod_rand"
import "mod_file"
import "mod_string"
import "mod_sound"
import "mod_wm"
import "mod_time"
import "mod_regex"
import "mod_say"
import "mod_sys"
import "mod_multi"
import "mod_mouse"

GLOBAL
	wavs[50];
    clients=0;
    width=0;
    height=0;
	fuente;
	fpg_general;
	jugador;
	puntos;
	txt_puntos;
	string ip_servidor;
	txt_ip_servidor;
	conectar;
	margen_x;
	margen_y;
	boton_size_x;
	boton_size_y;
	dedo_map;
End
	
PROCESS main();
Begin
	if(os_id==1003)
		// Get the real screen resolution we're running at
		width = graphic_info(0, 0, G_WIDTH);
		height = graphic_info(0, 0, G_HEIGHT);
	else
		width=320;
		height=480;
		set_mode(width, height, 16);
	end
    
	set_title("Mini BennuGD Client");
	set_fps(25,1);
	
	carga_sonidos();
	
	fuente=load_fnt("textos2.fnt");
	fpg_general=load_fpg("pixfrogger-md.fpg");

	margen_x=width/4;
	margen_y=height/4;
	
	boton_size_x=width/6;
	boton_size_y=height/8;
	
	dedo_map=new_map(2,2,16);
	drawing_color(rgb(255,255,255));
	drawing_map(0,dedo_map);
	draw_box(0,0,1,1);
	
	if(os_id!=1003) mouse.graph=dedo_map; end
	
	fsock_init(0); // init fsock library
    write(fuente, width/2, height/2, 4, "TOCA PARA JUGAR");
    while(!key(_esc) or (os_id==1003 and focus_status!=1))
        if(multi_info(0,"ACTIVE")>0 or mouse.left)
			break;
        end
        FRAME;
    end
    while(multi_info(0,"ACTIVE")>0 or mouse.left)
		frame;
    end
	delete_text(all_text);

	consigue_ip();
	client();
end

Function consigue_ip();
Private
	i;
Begin
	ip_servidor="";
	txt_ip_servidor=write(fuente,width/2,(height/10)*2,4,ip_servidor+"_");
	write(fuente,width/2,(height/10),4,"Introduce IP");
	
	from i=-1 to 11; boton(i); end
	
	while(conectar==0)
		if(key(_esc) or (os_id==1003 and focus_status!=1)) exit(); end
		if(mouse.left) dedo(mouse.x,mouse.y); end
		for(i=0; i<10; i++)
			if(multi_info(i, "ACTIVE") > 0)
				dedo(multi_info(i, "X"),multi_info(i, "Y"));
			end
		end
		frame;
	end
End

Process dedo(x,y);
Begin
	priority=1;
	graph=dedo_map;
	alpha=0;
	frame;
End

Process boton(tipo);
Private
	i;
	pos_x;
	pos_y;
Begin
	//tipos 0-9:n?meros, 10:".",-1:retroceso,11:conectar
	size=80;
	//pintado de los botones
	if(tipo==11)
		graph=new_map(boton_size_x*3,boton_size_y,16);
	else
		graph=new_map(boton_size_x,boton_size_y,16);
	end
	drawing_map(0,graph);
	drawing_color(rgb(128,128,128));
	if(tipo==11)
		draw_box(0,0,boton_size_x*3,boton_size_y);
	else
		draw_box(0,0,boton_size_x,boton_size_y);
	end
	
	if(tipo=>0 and tipo=<9)
		i=write_in_map(fuente,itoa(tipo),4);
	elseif(tipo==10)
		i=write_in_map(fuente,".",4);
	elseif(tipo==-1)
		i=write_in_map(0,chr(17),4);
	elseif(tipo==11)
		i=write_in_map(fuente,"Conectar",4);
	end
	if(tipo==11)
		map_xput(0,graph,i,boton_size_x*3/2,boton_size_y/2,0,100,0);
	else
		map_xput(0,graph,i,boton_size_x/2,boton_size_y/2,0,100,0);
	end
	unload_map(0,i);
	
	//posicionamiento
	if(tipo=>1 and tipo=<9)
		pos_x=(tipo%3);
		if(pos_x==0) pos_x=3; end
		pos_y=((tipo-1)/3)+1;
	else
		switch(tipo)
			case -1:
				pos_x=1; pos_y=4;
			end
			case 0:
				pos_x=2; pos_y=4;
			end
			case 10:
				pos_x=3; pos_y=4;
			end
			case 11:
				pos_x=2; pos_y=5;
			end
		end
	end
	x=margen_x+((pos_x-1)*boton_size_x)+(boton_size_x/2);
	y=margen_y+((pos_y-1)*boton_size_y)+(boton_size_y/2);
	while(conectar==0)
		if(collision(type dedo))
			while(collision(type dedo) or mouse.left) frame; end
			if(len(ip_servidor)<15)
				if(tipo=>0 and tipo<=9)	ip_servidor=ip_servidor+""+itoa(tipo); end
				if(tipo==10) ip_servidor=ip_servidor+"."; end
			end
			if(tipo==-1 and ip_servidor!="") ip_servidor=substr(ip_servidor,0,len(ip_servidor)-1); end
			delete_text(txt_ip_servidor);
			txt_ip_servidor=write(fuente,width/2,(height/10)*2,4,ip_servidor+"_");
			if(tipo==11) conectar=1; end
		end
		frame;
	end
	unload_map(0,graph);
End

Process mi_rana();
Begin
	x=width/2;
	y=(height/4)*3;
	graph=500+(jugador%4);
	if(graph==500) graph=504; end
	
	write(fuente,20,50,0,"Jugador: "+jugador);
	txt_puntos=write(fuente,20,120,0,"Victorias: "+puntos);

	sonido(4);
	
	loop
		if(multi_info(0, "ACTIVE") > 0)
			alpha=255;
		else
			alpha=128;
		end
		frame;
	end
End

process client()
private
    int socket, rlen; // socket_listen to listen to requests
    char dat[3]="   ";
    char msg[20];
	estado;
	esperando;
	tiempo_restante;
	segundos_restantes;
begin
    socket=tcpsock_open(); // new socket
	say("Creando socket...");
    if(tcpsock_connect(socket,ip_servidor,"8080")!=0)
        mensaje("Sin conexion");
		while(exists(son)) frame; end
        exit();
    end
	say("Socket creado...");

    while(focus_status==1)
		msg="";
		if(esperando==0)
			if(estado==0)
				dat="CON";
				tcpsock_send(socket, &dat, len(dat));
				say("Conectando...");
			end
			if(estado==1)
				if(multi_info(0,"ACTIVE")>0) //pulsa el bot?n
					if(jugador<10)
						dat="B0"+itoa(jugador);
					else
						dat="B"+itoa(jugador);
					end
				else
					if(jugador<10) //no pulsa, update
						dat="U0"+itoa(jugador);
					else
						dat="U"+itoa(jugador);
					end
				end
				tcpsock_send(socket, &dat, len(dat));
			end
			esperando=30;
		end
	
		if(esperando>0) esperando--; end
	
      	// In the real world, you'd loop here until you got the full package
        rlen=tcpsock_recv(socket, &msg, sizeof(msg));
        if(rlen>0)
			esperando=0;
			if(estado==0)
				if(msg!="ERR")
					jugador=atoi(msg);
					say("Jugador adquirido: "+msg);
					mi_rana();
					estado=1;
				else
					say("No se ha podido conectar");
				end
			else //ESTAMOS DENTRO
				if(msg=="DEA")
					has_muerto();
				end
				if(msg=="WIN")
					puntos++;
					delete_text(txt_puntos);
					txt_puntos=write(fuente,20,120,0,"Victorias: "+puntos);
					has_ganado();
				end
				if(msg=="FIN")
					game_over();
				end
				if(msg[0]=="P") //play_wav xD
					sonido(atoi(substr(msg,1)));
				end
			end
        end
        FRAME;
    end
	say("Quitting!");
onexit
	fsock_quit(); // Now close the fsock lib
end

Process mensaje(string texto);
Begin
	graph=write_in_map(fuente,texto,4);
	y=(height/2)-50;
	x=width/2;
	from alpha=0 to 255 step 10; y+=2; frame; end
	frame(5000);
	from alpha=255 to 0 step -10; y+=2; frame; end
	unload_map(0,graph);
End

Process has_muerto();
Begin
	//sonido croac
	sonido(4);
	mensaje("Has muerto");
End

Process has_ganado();
Begin
	//fanfarr?a del ganador
	sonido(7);
	mensaje("Has ganado");
End

Process game_over();
Begin
	//gracias por jugar
	let_me_alone();
	delete_text(all_text);
	mensaje("Gracias por jugar");
	while(exists(son)) frame; end
	exec(_P_NOWAIT, "market://details?id=com.pixjuegos.pixfrogger", 0, 0);
	exit();
End

Function carga_sonidos();
Private
	i;
Begin
	from i=1 to 7;
		wavs[i]=load_wav("wav/"+i+".wav");
	end
End

Function sonido(num);
Begin
	play_wav(wavs[num],0);
End