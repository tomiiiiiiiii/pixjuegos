/* Bienvenido al código fuente de PiX Pang DX*/

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


//constantes, variables globales y locales
include "variables.pr-";

//proceso de inicio
include "main.pr-";

//manejador de teclas, por SplinterGU 2010
//include "key_event.pr-";

//resolucioname
include "../../common-src/resolucioname.pr-";

//centralización de joysticks y teclados
include "../../common-src/controles.pr-";

//personajes de los jugadores
include "personaje.pr-";

//bolas y relacionados
include "bolas.pr-";

//creación, cargado, guardado del nivel
include "nivel.pr-";

//disparos y relacionados
include "disparo.pr-";

//items y relacionados
include "items.pr-";

//explosión bien bonita creada por Carles
include "../../common-src/explosion.pr-";

//cosas que no caben en otros sitios: grafico, prepara_grafico, dibuja_fondo
include "misc.pr-";