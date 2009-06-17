Global
	string carpetas[100];
	string carpeta;
	string prg;
	numjuegos;
	i;
	txt;
Begin
	set_mode(100,100,16);

    While((carpeta=glob("*")) != "")
	if(carpeta!="." and carpeta!="..")
		cd(carpeta);
		file=fpg_new();
		from x=0 to 999;
			If(file_exists(itoa(x)+".png"))
				graph=load_png(itoa(x)+".png")
				fpg_add(file,x,0,graph);
				unload_map(file,graph);
			end
		End
		save_fpg(file,"../../fpg/"+carpeta+".fpg");
		unload_fpg(file);
		cd("..");
	end
    End
End