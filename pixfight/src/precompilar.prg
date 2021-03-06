import "mod_blendop";
import "mod_cd";
import "mod_debug";
import "mod_dir";
import "mod_draw";
import "mod_effects";
import "mod_file";
import "mod_flic";
import "mod_grproc";
import "mod_joy";
import "mod_key";
import "mod_m7";
import "mod_map";
import "mod_math";
import "mod_mem";
import "mod_mouse";
import "mod_path";
import "mod_proc";
import "mod_rand";
import "mod_regex";
import "mod_say";
import "mod_screen";
import "mod_scroll";
import "mod_sort";
import "mod_sound";
import "mod_string";
import "mod_sys";
import "mod_text";
import "mod_time";
import "mod_timers";
import "mod_video";
import "mod_wm";


Global
	string carpeta;
	fp[4];
	numpersonajes;
Begin
	set_mode(100,100,16);
	//CREAMOS FPGS Y cargar_fpgs.pr-
	fp[0]=fopen("cargar_fpgs.pr-", O_WRITE);
	fp[1]=fopen("personaje1.pr-", O_WRITE);
	fp[2]=fopen("personaje2.pr-", O_WRITE);
	fp[3]=fopen("personaje3.pr-", O_WRITE);
	fputs(fp[0],"Global");
	cd("..\personajes");
	loop
		carpeta=glob("*");
		if(carpeta=="") break; end
		if(carpeta!="." and carpeta!=".." and carpeta!=".svn")
			numpersonajes++;
			cd(carpeta);
			file=fpg_new();
			from x=0 to 999;
				If(file_exists(itoa(x)+".png"))
					graph=load_png(itoa(x)+".png");
					fpg_add(file,x,0,graph);
					unload_map(file,graph);
				end
			End
			save_fpg(file,"../../fpg/"+carpeta+".fpg");
			unload_fpg(file);
			cd("..");
			fputs(fp[0],"	fpg_"+carpeta+";");
		end
	End
	fputs(fp[0],"End");
	fputs(fp[0]," ");
	fputs(fp[0],"Process cargar_fpgs();");
	fputs(fp[0],"Begin");
	fputs(fp[0],"	numpersonajes="+numpersonajes+";");
	frame;
	x=0;
	glob(".."); //BUG!
	loop
		carpeta=glob("*");
		if(carpeta=="") break; end
		if(carpeta!="." and carpeta!=".." and carpeta!=".svn")
			x++;
			fputs(fp[0],'	fpg_'+carpeta+'=load_fpg("'+carpeta+'.fpg");');
			fputs(fp[1],'	case '+x+': file=fpg_'+carpeta+'; end');
			fputs(fp[2],'	case '+x+': include "../personajes/'+carpeta+'/'+carpeta+'.pr-"; end');
			fputs(fp[3],'include "../personajes/'+carpeta+'/'+carpeta+'_proc.pr-";');
		end
	end
	fputs(fp[0],"End");
	fclose(fp[0]);
	fclose(fp[1]);
	fclose(fp[2]);
	fclose(fp[3]);
End