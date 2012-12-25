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
	set_mode(100,100,32);
	frame;
	mkdir(argv[1]);
	cd(argv[1]);
	file=load_fpg("..\..\fpg\"+argv[1]+".fpg");
	say(1);
	from graph=1 to 999;
		//say(2);
		If(graphic_info(file,graph,G_WIDE)>0)
			say(3);
			save_png(file,graph,itoa(graph)+".png");
		end
	End
	say("Bye!");
End