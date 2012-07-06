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
import "mod_screen";
import "mod_sound";
import "mod_string";
import "mod_say";
import "mod_sys";
import "mod_text";
import "mod_time";
import "mod_timers";
import "mod_video";
import "mod_wm";

Begin
	set_mode(100,100,argv[1]);
	from x=2 to argc-1;
		say(argv[x]);
		procesa(argv[x]);
	end
End

Function procesa(string fntname);
Private
	fuente;
Begin
	fuente=load_fnt("fnt/"+fntname+".fnt");
	from x=1 to 999;
		graph=get_glyph(fuente,x);
		if(graph>0)
			save_png(0,graph,x+".png");
		end
	End
End