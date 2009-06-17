Global
	string carpeta;
	fp;
Begin
	set_mode(100,100,32);
	//CREAMOS FPGS Y cargar_fpgs.pr-
	fp = fopen("cargar_fpgs.pr-", O_WRITE);
	fputs(fp,"Global");
	cd("..\fpg-sources");
	While((carpeta=glob("*")) != "")
		if(carpeta!="." and carpeta!=".." and carpeta!=".svn")
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
			fputs(fp,"	fpg_"+carpeta+";");
		end
	End
	fputs(fp,"End");
	fputs(fp," ");
	fputs(fp,"Process cargar_fpgs();");
	fputs(fp,"Begin");
	frame;
	While((carpeta=glob("*")) != "")
		if(carpeta!="." and carpeta!=".." and carpeta!=".svn")
			fputs(fp,'	fpg_'+carpeta+'=load_fpg("'+carpeta+'.fpg");');
		end
	end
	fputs(fp,"End");
	fclose(fp);
End