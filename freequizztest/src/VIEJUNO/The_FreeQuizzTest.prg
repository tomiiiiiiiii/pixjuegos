program The_FreeQuizzTest;
const
	WINDOW_WIDTH=1024;
	WINDOW_HEIGHT=768;
	//FileManager.inc
	MAX_CHARS_PER_LINE=50;
	MAX_QUIZZES=100;
	MAX_QUIZZ_LINES=3;
	MAX_ANSWERS=4;
	MAX_ANSWER_LINES=2;
	//SoundManager.inc
	//Lista de músicas (eMusicIdx)
	MUSIC_INTRO=0;
	MUSIC_QUIZZ=1;
	MUSIC_QUIT=2;
	MAX_MUSICS=3;
	//Lista de sonidos (eSoundIdx)
	SOUND_BIG_BUZZ=0;
	SOUND_SELECTION_0=1;
	SOUND_SELECTION_1=2;
	SOUND_SELECTION_2=3;
	SOUND_SELECTION_3=4;
	SOUND_ANSWER_RIGHT=5;
	SOUND_ANSWER_WRONG=6;
	SOUND_TIME_CLICK=7;
	SOUND_TIME_CLACK=8;
	SOUND_TIME_FINISHED=9;
	SOUND_QUIZZES_DONE=10;
	MAX_SOUNDS=11;
	MAX_PLAYERS=4;
	//Tiempo por pregunta para el Quizz en monojugador
	QUIZZ_TIME=10;
end	
global
	WINDOW_HOR_CENTER=WINDOW_WIDTH*0.5;
	WINDOW_VER_CENTER=WINDOW_HEIGHT*0.5;
	Struct GlobalOptions; 
		bFullScreen=false;
		bSound=true;
		bMusic=true;
		//iLanguage=-1;
		string SoundPath="Sounds/";
		string MusicPath="Musics/";
		string ImagesPath="Images/";
		string QuizzPath="Quizzs/";
		string Fonts="Fonts/";
		bUsingBuzz=true;
	End
	
	string szTempString="";
	string szMessage="";

	//FileManager.inc
	//Habrá MAX_QUIZZES preguntas. Cada pregunta constará de
	Struct Quizzes[MAX_QUIZZES];
		//La pregunta en sí podrá ocupar hasta tres líneas
		string Question_Line[MAX_QUIZZ_LINES]="";
		//Cada respuesta podrá ocupar hasta dos líneas
		string Answer_Number[MAX_ANSWERS][MAX_ANSWER_LINES]="";
		iCorrectAnswer=-2;
	End
	iNumQuizzes=0;

	//Data about the current player
	Struct PlayerInfo;
		//iPlayer == -2 significa que no se permite modificar la elección del player
		//iPlayer == -1 significa que se permite y nadie la ha modificado aún
		//iPlayer == 0..3 significa que el jugador del 0 al 3 ha pulsado el botón primero
		iPlayer = -1;
		//iChoice == -1 significa que no se ha hecho ninguna elección
		//iChoice == 0..3 significa que el jugador ha hecho alguna de las eleccioens
		iChoice = -1;
		iMaxScore=0;
		iMaxScorePlayer=-1;
		//TODO: cargar y guardar los hiscores
		/*
		iHiScore=0;
		iHiScorePlayer=-1;
		szHiScorePlayerName="";
		*/
	End
	
	//Data about the players
	Struct PlayersInfo[MAX_PLAYERS];
		iScore=0;
		iWriteIDScore;
	End
	
	iNumPlayers=MAX_PLAYERS;

	//SoundManager.inc
	musics[MAX_MUSICS];
	string szMusics[MAX_MUSICS];
	wavs[MAX_SOUNDS];
	string szSounds[MAX_SOUNDS];
	iIDCurrentMusic=-1;
	
	//Fuentes
	Font_Numbers=0;
	Font_Big_Letters=0;
	Font_Little_Letters=0;
end
Private
	bWantToQuit=false;
begin
	iNumPlayers=1;
	InitInputs();
	szMusics[MUSIC_INTRO]="Aperture.xm";
	szMusics[MUSIC_QUIZZ]="QuizzParty.xm";
	szMusics[MUSIC_QUIT]="HastaLuego.xm";
	szSounds[SOUND_BIG_BUZZ]="BigBuzz";
	szSounds[SOUND_SELECTION_0]="Selection0";
	szSounds[SOUND_SELECTION_1]="Selection1";
	szSounds[SOUND_SELECTION_2]="Selection2";
	szSounds[SOUND_SELECTION_3]="Selection3";
	szSounds[SOUND_ANSWER_RIGHT]="AnswerRight";
	szSounds[SOUND_ANSWER_WRONG]="AnswerWrong";
	szSounds[SOUND_TIME_CLICK]="TimeClick";
	szSounds[SOUND_TIME_CLACK]="TimeClack";
	szSounds[SOUND_TIME_FINISHED]="TimeFinished";
	szSounds[SOUND_QUIZZES_DONE]="QuizzesDone";
	InitSounds();

	InitFileManager();
	
	//Init fonts
	Font_Numbers=load_fnt(GlobalOptions.Fonts+"7segment_30.fnt");
	Font_Big_Letters=load_fnt(GlobalOptions.Fonts+"bluestone_30.fnt");
	Font_Little_Letters=load_fnt(GlobalOptions.Fonts+"AlMateen_12.fnt");
	scale_resolution=10240600;
	set_mode(WINDOW_WIDTH,WINDOW_HEIGHT,16,MODE_FULLSCREEN);
	set_fps(25,0);
	Intro();

	loop
		while(!key(_esc))
			frame;
			if(get_ID(type WantToQuit)!=0)
				PlayerInfo.iChoice=-1;
			end
		end
		while(key(_esc))
			frame;
			if(get_ID(type WantToQuit)!=0)
				bWantToQuit=true;
				PlayerInfo.iChoice=-1;
			end
		end
		if(!bWantToQuit)
			bWantToQuit=false;
			delete_text(ALL_TEXT);
			let_me_alone();
			WantToQuit();
		end
	end
end

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
process Intro();
Private
	IDBuzzer;
	HandlePlayer IDHandlePlayer;
begin
	IDHandlePlayer=HandlePlayer(0, true);
	delete_text(all_text);
	put_screen(0,load_png(GlobalOptions.ImagesPath+"TheFreeQuizzTest.png"));
	graph=load_png(GlobalOptions.ImagesPath+"Black.png");
	size=20000;
	from alpha=100 to 0 step -10;
		frame;
	end
	PlayMusic(MUSIC_INTRO, true, false);
	PlayerInfo.iPlayer=-1;
	IDBuzzer=BuzzBumpIcon(300,600);
	while(PlayerInfo.iPlayer==-1)
		frame;
	end
	PlaySound(SOUND_BIG_BUZZ);
	while(PlayerInfo.iPlayer!=-1)
		frame;
		PlayerInfo.iPlayer=-1;
	end
	StopMusic(true);
	from alpha=0 to 100 step 10;
		frame;
	end
	signal(IDBuzzer, s_kill);
	signal(IDHandlePlayer, s_kill);
	GameModeSingle();
end

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Process BuzzBumpIcon(iPosx,iPosy);
Begin
	x=iPosx;
	y=iPosy;
	graph = load_png(GlobalOptions.ImagesPath+"Buzzer.png");
	loop
		from size=90 to 100 step 2;
			frame;
		end
		from size=99 to 91 step -2;
			frame;
		end
	end
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
process GameModeSingle();
begin
	PlayersInfo[0].iScore=0;
	
	PlayMusic(MUSIC_QUIZZ, true, true);

	TestQuizzes();
	
	loop
		frame;
		PlayerInfo.iChoice=-1;
	end
end

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Function PrintScores();
Private
	iPointsVerOffset=255;
	iPointsTotalHorOffset=132;
	iPointsHorOffset=267;
	iPlayer;
End
Begin
	from iPlayer=0 to 3; //iNumPlayers-1
		PlayersInfo[iPlayer].iWriteIDScore=write(Font_Numbers,iPointsTotalHorOffset,iPointsVerOffset,2,""+PlayersInfo[iPlayer].iScore);
		iPointsTotalHorOffset+=iPointsHorOffset;
	end
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Process QuizzCurrentChoice();
Public
	iChoice=-1;
Private
	iLastChoice=0;
	iTotalVertOffset=482;
	iVertOffset=78;
Begin
	iLastChoice=iChoice;	
	graph = load_png(GlobalOptions.ImagesPath+"CurrentChoice.png");
	x=WINDOW_HOR_CENTER;
	y=-200;
	loop
		if(iLastChoice!=iChoice)
			iLastChoice=iChoice;
			if(iChoice==-1)
				//Sacamos la imagen fuera de la pantalla
				y=-200;
			else
				y=iTotalVertOffset+iVertOffset*iChoice;
			end
		end
		frame;
	end
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Process QuizzRightChoice();
Public
	iChoice=-1;
Private
	iLastChoice=0;
	iTotalVertOffset=482;
	iVertOffset=78;
Begin
	iLastChoice=iChoice;	
	graph = load_png(GlobalOptions.ImagesPath+"RightChoice.png");
	x=WINDOW_HOR_CENTER;
	y=-200;
	loop
		if(iLastChoice!=iChoice)
			iLastChoice=iChoice;
			if(iChoice==-1)
				//Sacamos la imagen fuera de la pantalla
				y=-200;
			else
				y=iTotalVertOffset+iVertOffset*iChoice;
			end
		end
		frame;
	end
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Process QuizzCurrentPlayer();
Public
	iPlayer=-1;
Private
	iLastPlayer=-1;
	iHorOffset=104;
	iVertOffset=384;
Begin
	iLastPlayer=iPlayer;	
	x=iHorOffset;
	y=-200;
	loop
		if(iLastPlayer!=iPlayer)
			iLastPlayer=iPlayer;
			if(iPlayer==-1)
				//Sacamos la imagen fuera de la pantalla
				y=-200;
			else
				graph = load_png(GlobalOptions.ImagesPath+"BorderPlayer"+(iPlayer+1)+".png");
				y=iVertOffset;
				PlaySound(SOUND_BIG_BUZZ);
			end
		end
		frame;
	end
End

/////////////////////////////////////////////////////////////////////
/// La función recibirá el tiempo en segundos
/////////////////////////////////////////////////////////////////////
Process QuizzTimer(iInitTime, bPlaySound);
Public
	iMinutes=0;
	iSeconds=0;
	bTimeFinished=false;
Private
	iTime;
begin
	iMinutes=iInitTime/60;
	iSeconds=iInitTime%60;
	iTime=get_timer();
	loop
		if(get_timer()>1000+iTime)
			if(iSeconds!=0 || iMinutes!=0)
				if(bPlaySound)
					if(iSeconds%2==0)
						PlaySound(SOUND_TIME_CLICK);
					else
						PlaySound(SOUND_TIME_CLACK);
					end
				end
				iSeconds--;
			else
				bTimeFinished=true;
			end
			if(iSeconds<0)
				iMinutes--;
				iSeconds=59;
			end
			iTime=get_timer();
		end
		frame;
	end
end

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Function int PrintTime(iMinutes, iSeconds, iIDWriteTime);
Private
	iPointsHorOffset=870;
	iPointsVerOffset=370;
	szFinalTime="";
End
Begin
	if(iIDWriteTime>=0)
		delete_text(iIDWriteTime);
	end
	if(iMinutes<10)
		szFinalTime="0";
	end
	szFinalTime+=iMinutes+"-";
	if(iSeconds<10)
		szFinalTime+="0";
	end
	szFinalTime+=iSeconds;
	iIDWriteTime=write(Font_Numbers,iPointsHorOffset,iPointsVerOffset,0,szFinalTime);
	return iIDWriteTime;
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Process TestQuizzes();
Private
	iNumQuizz=0;
	iPlayer=-1;
	iChoice=-1;
	string szResult="";
	RESULT_TIME=2000;
	iTime;
	QuizzRightChoice IDRightChoice;
	QuizzCurrentChoice IDCurrentChoice;
	QuizzCurrentPlayer IDCurrentPlayer;
	iRightChoice=-1;
	QuizzTimer IDTimer;
	iIDWriteTime=-1;
	iIDWritePlayer=-1;
	HandlePlayer IDHandlePlayer;
End
Begin
	IDHandlePlayer=HandlePlayer(0, false);
	priority=1;
	put_screen(0,load_png(GlobalOptions.ImagesPath+"QuizzBackground.png"));
	graph=load_png(GlobalOptions.ImagesPath+"Black.png");
	size=20000;
	from alpha=100 to 0 step -10;
		frame;
	end
	iNumQuizz=0;
	PlayerInfo.iChoice=-1;
	PlayerInfo.iPlayer=-1;
	PlayerInfo.iMaxScore=0;
	PlayerInfo.iMaxScorePlayer=-1;
	delete_text(ALL_TEXT);
	IDRightChoice=QuizzRightChoice();
	IDCurrentChoice=QuizzCurrentChoice();
	IDCurrentPlayer=QuizzCurrentPlayer();
	IDTimer=QuizzTimer(QUIZZ_TIME*iNumQuizzes, true);
	PrintQuizz(iNumQuizz);
	PrintScores();
	iIDWriteTime=PrintTime(IDTimer.iMinutes, IDTimer.iSeconds, iIDWriteTime);
	loop
		while(PlayerInfo.iPlayer<0)
			iIDWriteTime=PrintTime(IDTimer.iMinutes, IDTimer.iSeconds, iIDWriteTime);
			if(IDTimer.bTimeFinished) break; end
			frame;
		end
		if(IDTimer.bTimeFinished) break; end
		iPlayer=PlayerInfo.iPlayer;
		IDCurrentPlayer.iPlayer=iPlayer;
		PlaySound(SOUND_BIG_BUZZ);
		write(Font_Little_Letters,104,384,4,"Jugador "+(iPlayer+1));
		while(PlayerInfo.iChoice==-1)
			iIDWriteTime=PrintTime(IDTimer.iMinutes, IDTimer.iSeconds, iIDWriteTime);
			if(IDTimer.bTimeFinished) break; end
			frame;
		end
		if(IDTimer.bTimeFinished) break; end
		iChoice=PlayerInfo.iChoice;
		IDCurrentChoice.iChoice=iChoice;
		PlaySound(iChoice+1);
		while(PlayerInfo.iChoice!=-1)
			iIDWriteTime=PrintTime(IDTimer.iMinutes, IDTimer.iSeconds, iIDWriteTime);
			if(IDTimer.bTimeFinished) break; end
			frame;
		end
		if(IDTimer.bTimeFinished) break; end
		iRightChoice=Quizzes[iNumQuizz].iCorrectAnswer;
		IDRightChoice.iChoice=iRightChoice;
		if(iChoice==iRightChoice)
			PlaySound(SOUND_ANSWER_RIGHT);
			PlayersInfo[iPlayer].iScore++;
			if(PlayersInfo[iPlayer].iScore>PlayerInfo.iMaxScore)
				PlayerInfo.iMaxScore=PlayersInfo[iPlayer].iScore;
				PlayerInfo.iMaxScorePlayer=iPlayer;
			end
		else
			PlaySound(SOUND_ANSWER_WRONG);
		end
		iTime=get_timer();
		while(get_timer()<(RESULT_TIME+iTime))
			iIDWriteTime=PrintTime(IDTimer.iMinutes, IDTimer.iSeconds, iIDWriteTime);
			if(IDTimer.bTimeFinished) break; end
			frame;
		end
		if(IDTimer.bTimeFinished) break; end
		
		PlayerInfo.iPlayer=-1;
		PlayerInfo.iChoice=-1;
		IDRightChoice.iChoice=-1;
		IDCurrentChoice.iChoice=-1;
		IDCurrentPlayer.iPlayer=-1;
		iChoice=-1;
		iRightChoice=-1;
		iNumQuizz++;
		if(iNumQuizz>=MAX_QUIZZES or iNumQuizz>=iNumQuizzes)//Quizzes[iNumQuizz].Question_Line[0]=="")
			break;
		else
			delete_text(ALL_TEXT);
			PrintQuizz(iNumQuizz);
			PrintScores();
			iIDWriteTime=PrintTime(IDTimer.iMinutes, IDTimer.iSeconds,iIDWriteTime);
		end
	end
	if(IDTimer.bTimeFinished)
		PlaySound(SOUND_TIME_FINISHED);
	else
		PlaySound(SOUND_QUIZZES_DONE);
	end
	signal(IDRightChoice, s_kill);
	signal(IDCurrentChoice, s_kill);
	signal(IDCurrentPlayer, s_kill);
	signal(IDTimer, s_kill);
	signal(IDHandlePlayer, s_kill);
	PlayerInfo.iPlayer=-1;
	PlayerInfo.iChoice=-1;
	StopMusic(true);
	delete_text(ALL_TEXT);
	from alpha=0 to 100 step 10;
		frame;
	end
	if(PlayerInfo.iMaxScore>0)
		Scores();
	else
		WantToQuit();
	end
End

Process Scores();
Private
	iHorOffset=40;
	IDBuzzer;
	HandlePlayer IDHandlePlayer;
Begin
	IDHandlePlayer=HandlePlayer(PlayerInfo.iMaxScorePlayer, true);
	//TODO: almacenar las cadenas de mensajes en un array y enumerarlas
	put_screen(0,load_png(GlobalOptions.ImagesPath+"QuizzBackgroundScore.png"));
	graph=load_png(GlobalOptions.ImagesPath+"Black.png");
	size=20000;
	from alpha=100 to 0 step -10;
		frame;
	end
	delete_text(ALL_TEXT);
	write(Font_Big_Letters,WINDOW_HOR_CENTER,WINDOW_VER_CENTER/2-iHorOffset,4,"¡Enhorabuena,  jugador  "+(PlayerInfo.iMaxScorePlayer+1)+"!");
	write(Font_Big_Letters,WINDOW_HOR_CENTER,WINDOW_VER_CENTER/2+iHorOffset,4,"Has conseguido  "+PlayerInfo.iMaxScore+"  puntos.");
	IDBuzzer=BuzzBumpIcon(WINDOW_HOR_CENTER,WINDOW_VER_CENTER+WINDOW_VER_CENTER/2);
	PlayerInfo.iPlayer=-1;
	PlayerInfo.iChoice=-1;
	while(PlayerInfo.iPlayer==-1)
		frame;
	end
	PlaySound(SOUND_BIG_BUZZ);
	while(PlayerInfo.iPlayer!=-1)
		frame;
		PlayerInfo.iPlayer=-1;
	end
	signal(IDBuzzer, s_kill);
	signal(IDHandlePlayer, s_kill);
	delete_text(ALL_TEXT);
	from alpha=0 to 100 step 10;
		frame;
	end
	
	WantToQuit();
	
	//TODO:
	//	if(PlayerInfo.iMaxScore>PlayerInfo.iHiScore)... else... "la fuerza está contigo, pero aún no eres un jedi..."
End

Process WantToQuit();
Private
	iTotalQuizzVertOffset=365+18;
	iTotalChoiceVertOffset=480;
	iChoiceVertOffset=78;
	iHorOffset=104;
	iVertOffset=384;
	iOffset=40;
	iPlayer=-1;
	iChoice=-1;
	QuizzCurrentPlayer IDCurrentPlayer;
	QuizzCurrentChoice IDCurrentChoice;
	QuizzTimer IDTimer;
	HandlePlayer IDHandlePlayer;
	iIDCounters=0;
Begin
	//Si ya existía un proceso de salida, no hacemos nada.
	while(get_ID(type WantToQuit)!=0)
		iIDCounters++;
	end
	if(iIDCounters==1)
		iIDCounters=get_ID(type GameModeSingle);
		while(iIDCounters!=0)
			signal(iIDCounters, s_kill);
			iIDCounters=get_ID(type GameModeSingle);
		end
		Priority=1;
		PlayMusic(MUSIC_QUIT, false, false);
		put_screen(0,load_png(GlobalOptions.ImagesPath+"QuizzBackground.png"));
		graph=load_png(GlobalOptions.ImagesPath+"Black.png");
		size=20000;
		alpha=0;
		from alpha=100 to 0 step -10;
			frame;
		end
		PlayerInfo.iPlayer=-1;
		PlayerInfo.iChoice=-1;
		IDHandlePlayer=HandlePlayer(0, false);
		IDCurrentPlayer=QuizzCurrentPlayer();
		IDCurrentPlayer.iPlayer=iPlayer;
		IDCurrentChoice=QuizzCurrentChoice();
		
		delete_text(ALL_TEXT);
		write(Font_Little_Letters,WINDOW_HOR_CENTER,iTotalChoiceVertOffset,4,"Jugar otra partida");
		iTotalChoiceVertOffset+=iChoiceVertOffset*3;
		write(Font_Little_Letters,WINDOW_HOR_CENTER,iTotalChoiceVertOffset,4,"Salir");
		while(PlayerInfo.iPlayer<0)
			frame;
		end
		iPlayer=PlayerInfo.iPlayer;
		IDCurrentPlayer.iPlayer=iPlayer;
		PlaySound(SOUND_BIG_BUZZ);
		write(Font_Little_Letters,iHorOffset,iVertOffset,4,"Jugador "+(iPlayer+1));
		while(iChoice!=0 && iChoice!=3)
			while(PlayerInfo.iChoice==-1)
				frame;
			end
			iChoice=PlayerInfo.iChoice;
			if(iChoice==0 || iChoice==3)
				IDCurrentChoice.iChoice=iChoice;
				PlaySound(iChoice+1);
				StopMusic(true);
			end
			while(PlayerInfo.iChoice!=-1)
				frame;
			end
		end
		IDTimer=QuizzTimer(1, false);
		while(!IDTimer.bTimeFinished)
			frame;
		end
		signal(IDTimer, s_kill);
		signal(IDCurrentPlayer, s_kill);
		signal(IDCurrentChoice, s_kill);
		signal(IDHandlePlayer, s_kill);
		delete_text(ALL_TEXT);
		if(iChoice==0)
			from alpha=0 to 100 step 10;
				frame;
			end
			GameModeSingle();
		else
		
			IDTimer=QuizzTimer(2, false);
			write(Font_Little_Letters,WINDOW_HOR_CENTER,iTotalQuizzVertOffset,4,"¡Hasta luego, y gracias por el pescado!");
			while(!IDTimer.bTimeFinished)
				frame;
			end
			delete_text(ALL_TEXT);
			from alpha=0 to 100 step 10;
				frame;
			end
			signal(IDTimer, s_kill);
			EndSounds();
			exit(0);
		end
	end
End

include "SoundManager.inc";
include "FileManager.inc";
include "KeyManager.inc";