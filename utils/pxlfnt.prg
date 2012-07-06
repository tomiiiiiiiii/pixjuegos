import "mod_screen";
import "mod_video";
import "mod_map";
import "mod_dir";
import "mod_file";
import "mod_string";
import "mod_grproc";
import "mod_say";

Begin
	set_mode(100,100,argv[1]);
	from x=2 to argc;
		procesa(argv[x]);
		say(argv[x]);
	end
End

Function procesa(string fntname);
Private
	fuente;
Begin
	cd(fntname);
	fuente=fnt_new(CHARSET_ISO8859,argv[1]);
	from x=0 to 999;
		If(file_exists(itoa(x)+".png"))
			glyph_set(fuente,x,0,load_png(itoa(x)+".png"));
		end
	End
	save_fnt(fuente,"../../fnt/"+fntname+".fnt");
	cd("..");
End