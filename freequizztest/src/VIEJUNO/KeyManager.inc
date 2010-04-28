const
	PLAYER1_SELECTOR=_2;
	PLAYER1_SELECTION1=_1;
	PLAYER1_SELECTION2=_q;
	PLAYER1_SELECTION3=_a;
	PLAYER1_SELECTION4=_z;
	PLAYER2_SELECTOR=_5;
	PLAYER2_SELECTION1=_4;
	PLAYER2_SELECTION2=_r;
	PLAYER2_SELECTION3=_f;
	PLAYER2_SELECTION4=_v;
	PLAYER3_SELECTOR=_8;
	PLAYER3_SELECTION1=_7;
	PLAYER3_SELECTION2=_u;
	PLAYER3_SELECTION3=_j;
	PLAYER3_SELECTION4=_m;
	PLAYER4_SELECTOR=_0;
	PLAYER4_SELECTION1=_9;
	PLAYER4_SELECTION2=_o;
	PLAYER4_SELECTION3=_l;
	PLAYER4_SELECTION4=_point;
end

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Process InitInputs();
Private
	iNumJoysticks;
	string sJoystickName;
	string sBUZZ="buzz";
	bBuzz=false;
Begin
	iNumJoysticks=NUMBER_JOY();
	if(iNumJoysticks>0)
		sJoystickName=lcase(JOY_NAME(0));
		bBuzz = substr(sJoystickName,9,12)==sBUZZ;
		bBuzz = bBuzz or substr(sJoystickName,8,11)==sBUZZ;
		if(bBuzz)
			GlobalOptions.bUsingBuzz=true;
		end
	end
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Process HandlePlayer(iPlayer, bPressBigButtonNeeded);
Private
	PLAYERN_SELECTIONM[4][5];
End
Private
	abPlayerSelector[5]=false,false,false,false,false;
	bKeyAlreadyPressed=false;
	iSelectAux;
End
Begin
	PLAYERN_SELECTIONM[0][0]=PLAYER1_SELECTOR;
	PLAYERN_SELECTIONM[0][1]=PLAYER1_SELECTION1;
	PLAYERN_SELECTIONM[0][2]=PLAYER1_SELECTION2;
	PLAYERN_SELECTIONM[0][3]=PLAYER1_SELECTION3;
	PLAYERN_SELECTIONM[0][4]=PLAYER1_SELECTION4;
	PLAYERN_SELECTIONM[1][0]=PLAYER2_SELECTOR;
	PLAYERN_SELECTIONM[1][1]=PLAYER2_SELECTION1;
	PLAYERN_SELECTIONM[1][2]=PLAYER2_SELECTION2;
	PLAYERN_SELECTIONM[1][3]=PLAYER2_SELECTION3;
	PLAYERN_SELECTIONM[1][4]=PLAYER2_SELECTION4;
	PLAYERN_SELECTIONM[2][0]=PLAYER3_SELECTOR;
	PLAYERN_SELECTIONM[2][1]=PLAYER3_SELECTION1;
	PLAYERN_SELECTIONM[2][2]=PLAYER3_SELECTION2;
	PLAYERN_SELECTIONM[2][3]=PLAYER3_SELECTION3;
	PLAYERN_SELECTIONM[2][4]=PLAYER3_SELECTION4;
	PLAYERN_SELECTIONM[3][0]=PLAYER4_SELECTOR;
	PLAYERN_SELECTIONM[3][1]=PLAYER4_SELECTION1;
	PLAYERN_SELECTIONM[3][2]=PLAYER4_SELECTION2;
	PLAYERN_SELECTIONM[3][3]=PLAYER4_SELECTION3;
	PLAYERN_SELECTIONM[3][4]=PLAYER4_SELECTION4;
	loop
		//En cada ejecución, nuestro mando podrá ser procesado en distinto orden con respecto a los demás mandos
		//De esta forma, aleatorizamos las comprobaciones de los mismos.
		Priority=Rand(-4,-1);
		if(!bKeyAlreadyPressed)
			if(GlobalOptions.bUsingBuzz)
				abPlayerSelector[0]=get_joy_button(iPlayer*5,0);
				for(iSelectAux=1; iSelectAux<5 and !abPlayerSelector[iSelectAux-1]; ++iSelectAux)
					abPlayerSelector[iSelectAux]=get_joy_button(iPlayer*5,iSelectAux);
				end
			else
				abPlayerSelector[0]=key(PLAYERN_SELECTIONM[iPlayer][0]);
				for(iSelectAux=1; iSelectAux<5 and !abPlayerSelector[iSelectAux-1]; ++iSelectAux)
					abPlayerSelector[iSelectAux]=key(PLAYERN_SELECTIONM[iPlayer][iSelectAux]);
				end
			end
			//Si no hace falta pulsar el botón estamos en los menús o en modo monojugador; el player siempre será el del proceso creado
			if(!bPressBigButtonNeeded)
				PlayerInfo.iPlayer=iPlayer;
			end
			//Si ningún jugador ha seleccionado nada y nosotros hemos pulsado el buzzer
			if(PlayerInfo.iPlayer==-1 and abPlayerSelector[0])
				//Marcamos el jugador seleccionador como el nuestro
				PlayerInfo.iPlayer=iPlayer;
			//Si ya habíamos pulsado nosotros el buzzer y teníamos el testigo
			else
				if(PlayerInfo.iPlayer==iPlayer)
					//Si no habíamos efectuado ninguna elección
					if(PlayerInfo.iChoice==-1)
						for (iSelectAux=0; iSelectAux<=3 and (PlayerInfo.iChoice==-1); ++iSelectAux)
							if(abPlayerSelector[iSelectAux+1])
								PlayerInfo.iChoice=iSelectAux;
							end
						end
					end
				end
			//TODO:? si iPlayer==-2 (si no se permite el uso del mando) y un player pulsa, quizá se podría implementar un tiempo de
			//penalización durante el cual, este mando no se compruebe.
			end
		else
		
			//Reseteamos todas las posibles entradas
			from iSelectAux=0 to 4;
				abPlayerSelector[iSelectAux]=false;
			end
			//Comprobamos si seguimos pulsando alguna tecla
			if(GlobalOptions.bUsingBuzz)
				bKeyAlreadyPressed=get_joy_button(iPlayer*5,0);
				for(iSelectAux=1; iSelectAux<5 and !bKeyAlreadyPressed; ++iSelectAux)
					bKeyAlreadyPressed=bKeyAlreadyPressed or get_joy_button(iPlayer*5,iSelectAux);
				end
			else
				bKeyAlreadyPressed=key(PLAYERN_SELECTIONM[iPlayer][0]);
				for(iSelectAux=1; iSelectAux<5 and !bKeyAlreadyPressed; ++iSelectAux)
					bKeyAlreadyPressed=key(PLAYERN_SELECTIONM[iPlayer][iSelectAux]);
				end
			end
		end
		/*
		write(0,10+iPlayer*80,10,0,"iPlayer: ");
		write_int(0,64+iPlayer*80,10,0,OFFSET iPlayer);
		from iSelectAux=0 to 4
			if(abPlayerSelector[iSelectAux])
				write_int(0,10+iPlayer*80,20+10*iSelectAux,0,OFFSET iSelectAux);
			end
		end
		*/
		frame;
	end
End