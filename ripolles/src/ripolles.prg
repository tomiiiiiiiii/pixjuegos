Program ripolles;

import "mod_blendop";
//import "mod_debug";
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

include "../../common-src/lenguaje.pr-";
include "../../common-src/savepath.pr-";

Const
	quieto=0;
	camina=1;
	salta=2;
	ataca_suelo=3;
	ataca_aire=4;
	defiende=5;
	herido_leve=6;
	herido_grave=7;
	ataque_area=8;
	coge_objeto=9;
	quieto_objeto=10;
	camina_objeto=11;
	num_mundos=29;
	
	muere=-1;
End

Global
	string savegamedir;
	string developerpath="/.PiXJuegos/PiXBros/";
End

Local
	ancho;
	alto;
	accion;
	animacion;
	cont_animacion;
	animacion_anterior;
	gravedad;
	i; j;
End

Begin
End