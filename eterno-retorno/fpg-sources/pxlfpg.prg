Begin
	from y=1 to 999;
		set_mode(100,100,32);
		if(argv[y]!="")
			write(0,0,-10+(y*10),0,argv[y]);
			cd(argv[y]);
			file=fpg_new();
			from x=0 to 999;
				If(file_exists(itoa(x)+".png"))
					fpg_add(file,x,0,load_png(itoa(x)+".png"));
				end
			End
			save_fpg(file,"../../fpg/"+argv[y]+".fpg");
			cd("..");
		else
			exit();
		end
	end
End