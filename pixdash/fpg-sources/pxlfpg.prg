import "mod_say";

Begin
	set_mode(100,100,16);
	from x=1 to argc;
		procesa(argv[x]);
		say(argv[x]);
	end
End

Function procesa(string fpgname);
Begin
	cd(fpgname);
	file=fpg_new();
	from x=0 to 999;
		If(file_exists(itoa(x)+".png"))
			fpg_add(file,x,0,load_png(itoa(x)+".png"));
		end
	End
	save_fpg(file,"../../fpg/"+fpgname+".fpg");
	cd("..");
End