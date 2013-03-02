/* fsock example
Mini BennuGD WebServer by SplinterGU
*/
import "fsock"
import "mod_screen"
import "mod_video"
import "mod_map"
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
End;

PROCESS main();
Begin
    // Get the real screen resolution we're running at
    width = graphic_info(0, 0, G_WIDTH);
    height = graphic_info(0, 0, G_HEIGHT);
    //set_mode(width, height, 16);
	set_title("Mini BennuGD Client");
	set_fps(25,1);
	
	carga_sonidos();
	
	fuente=load_fnt("puntos-md.fnt");
	fpg_general=load_fpg("pixfrogger-md.fpg");
	
	fsock_init(0); // init fsock library
    write(0, 0, 0, 0, "Toca la pantalla para unirte a la partida");
    while(!key(_esc) or (os_id==1003 and focus_status!=1))
        if(multi_info(0,"ACTIVE")>0 or mouse.left)
			delete_text(all_text);
            client();
			break;
        end
        FRAME;
    end
end;

Process mi_rana();
Begin
	x=width/4;
	y=height/4;
	size=175;
	graph=500+(jugador%4);
	if(graph==500) graph=504; end
	
	write(fuente,(width/4)*3,height/4,4,jugador);
	write_int(fuente,width/2,height/4,4,&puntos);
	
	from alpha=0 to 255 step 10; size-=3; frame; end
	loop
		if(multi_info(0, "ACTIVE") > 0)
			angle-=6000;
		else
			angle=0;
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
    if(tcpsock_connect(socket,"192.168.1.148","8080")!=0)
        say("No se ha podido conectar con el servidor.");
        return;
    end
	say("Socket creado...");

    while(!key(_esc) or (os_id==1003 and focus_status!=1))
		if(esperando==0)
			if(estado==0)
				dat="CON";
				tcpsock_send(socket, &dat, len(dat));
				say("Conectando...");
			end
			if(estado==1)
				dat="WAI";
				tcpsock_send(socket, &dat, len(dat));
			end
			if(estado==2)
				if(multi_info(0,"ACTIVE")>0) //pulsa el botón
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
			switch(estado)
				case 0: //conectando
					if(msg!="ERR")
						jugador=atoi(msg);
						say("Jugador adquirido: "+msg);
						mi_rana();
						estado=2;
					else
						say("No se ha podido conectar");
					end
				end
				case 1: //esperando para jugar
					if(msg=="WAI")
						//-- a seguir esperando
					else
						/*if(msg[0]=="T")
						timer[0]=atoi(substr(msg,1));
						segundos_restantes=(1000-timer[0])/60;
						*/
					end					
				end
				case 2: //jugando
					if(msg=="DEA")
						has_muerto();
					end
					if(msg=="WIN")
						has_ganado();
					end
					if(msg=="FIN")
						game_over();
					end
					if(msg[0]=="S")
						puntos=atoi(substr(msg,1));
					end
				end
			end
        end
        FRAME;
    end
	say("Quitting!");
onexit
	fsock_quit(); // Now close the fsock lib
end

Process has_muerto();
Begin
	//sonido croac
	sonido(4);
End

Process has_ganado();
Begin
	//fanfarría del ganador
	sonido(7);
End

Process game_over();
Begin
	//gracias por jugar
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