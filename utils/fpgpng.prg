import "mod_say";

Begin
	set_mode(100,100,32);
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