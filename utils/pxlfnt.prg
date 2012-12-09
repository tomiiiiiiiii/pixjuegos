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

Begin
	set_mode(100,100,argv[1]);
	from x=2 to argc-1;
		procesa(argv[x]);
		say(argv[x]);
	end
End

Function procesa(string fntname);
Private
	fuente;
Begin
	chdir(fntname);
	fuente=fnt_new(CHARSET_ISO8859,argv[1]);
	from x=0 to 999;
		If(file_exists(itoa(x)+".png"))
			glyph_set(fuente,x,0,load_png(itoa(x)+".png"));
		end
	End
	save_fnt(fuente,"../../fnt/"+fntname+".fnt");
	chdir("..");
End