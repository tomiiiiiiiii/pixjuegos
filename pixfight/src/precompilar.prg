Global
	string carpeta;
	fp[4];
	numpersonajes;
Begin
	set_mode(100,100,32);
	//CREAMOS FPGS Y cargar_fpgs.pr-
	fp[0]=fopen("cargar_fpgs.pr-", O_WRITE);
	fp[1]=fopen("personaje1.pr-", O_WRITE);
	fp[2]=fopen("personaje2.pr-", O_WRITE);
	fp[3]=fopen("personaje3.pr-", O_WRITE);
	fputs(fp[0],"Global");
	cd("..\personajes");
	While((carpeta=glob("*")) != "")
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
	While((carpeta=glob("*")) != "")
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