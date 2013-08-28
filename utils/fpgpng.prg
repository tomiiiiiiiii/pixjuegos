import "mod_dir";
import "mod_draw";
import "mod_file";
import "mod_grproc";
import "mod_joy";
import "mod_key";
import "mod_map";
import "mod_math";
import "mod_mouse";
import "mod_proc";
import "mod_rand";
import "mod_regex";
import "mod_say";
import "mod_screen";
import "mod_sound";
import "mod_string";
import "mod_sys";
import "mod_text";
import "mod_time";
import "mod_timers";
import "mod_video";
import "mod_wm";
Private
	folder;
	string nombre;
Begin
	set_mode(100,100,32);
	frame;
	if(argc<2)
		folder=diropen("fpg\*.fpg");
		loop
			nombre=dirread(folder);
			if(nombre=="") break; end
			nombre=substr(nombre,0,len(nombre)-4);
			say(nombre);
			exporta_fpg(nombre);
		end
		say("out:"+nombre);
	else
		from x=1 to argc-1;
			nombre=argv[x];
			say(nombre);
			exporta_fpg(nombre);
		end
	end
	say("Bye!");
End

Function exporta_fpg(string nombre);
Begin
	file=load_fpg("fpg\"+nombre+".fpg");
	mkdir("fpg-sources\"+nombre);
	from graph=1 to 999;
		If(graphic_info(file,graph,G_WIDE)>0)
			save_png(file,graph,"fpg-sources\"+nombre+"\"+graph+".png");
		end
	End
End