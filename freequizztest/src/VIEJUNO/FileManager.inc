/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
const
	ERROR_FILE_NOT_FOUND=0;
	ERROR_MORE_THAN_ONE_RIGHT_ANSWER=1;
	ERROR_LESS_THAN_MAX_ANSWERS_FOUND=2;
	ERROR_NOT_RIGHT_ANSWER_FOUND=3;
	NUM_MAX_ERRORS=4;
end

Function InitFileManager();
Begin
	LoadOptions();
	LoadQuestions();
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Function LoadOptions();
Begin
//TODO: consultar el idioma y dejar los textos en carpetas distintas por cada idioma; cargar los archivos dependiendo del idioma, cargar también el archivo de mensajes.
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Function LoadQuestions();
Private
	string szQuizzName="";
	iIDFile;
End
Begin
	szQuizzName=GlobalOptions.QuizzPath+"FreeQuizzTest_000.txt";
	if(file_exists(szQuizzName))
		iIDFile=fopen(szQuizzName,o_read);
	else
		szMessage=szQuizzName;
		ELError(ERROR_FILE_NOT_FOUND, szMessage);
	end
	
	iNumQuizzes=0;
	//Hacemos una primera carga
	LoadNextQuestion(iIDFile, iNumQuizzes);
	//Mientras no se haya acabado el archivo o alcancemos el máximo de preguntas posibles
	while(feof(iIDFile)==false and iNumQuizzes<MAX_QUIZZES)
		//Si la pregunta anterior fue correcta, incrementamos el contador
		if(Quizzes[iNumQuizzes].Question_Line[0]!="")
			PrintQuizz(iNumQuizzes);
			iNumQuizzes++;
		end
		//Y cargamos la siguiente pregunta
		LoadNextQuestion(iIDFile,iNumQuizzes);
	end
	
	fclose(iIDFile);
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Function LoadNextQuestion(iIDFile,iNumQuizz);
Private
	//Usamos una cadena para especificar los símbolos a ignorar
	//(Sólo serán válidas las preguntas de archivo del tipo
	//Blablablabla
	//--OpciónIncorrecta
	//-*OpciónCorrecta
	//
	//Ignoraremos las cadenas que comiencen por
	//#Pregunta (pregunta de introducir respuesta)
	//?rutaimagen#Pregunta (pregunta con imagen)
	//$idyoutube#Pregunta (pregunta con vídeo de youtube)
	//@ruta_audio#Pregunta
	//- respuesta a pregunta
	//TODO: quizá en el futuro se pueda soportar lo anterior
	string acNonWantedSigns="#?$@-";
	iNonWantedSignsLength=0;
	string szTempString="";
	bool bOK=true;
	int iChar;
End
Begin
	iNonWantedSignsLength=len(acNonWantedSigns);
	ResetQuizz(iNumQuizz);
	
	if(feof(iIDFile)==false)
		szTempString=fgets(iIDFile);
		for(iChar=0; bOK && iChar<iNonWantedSignsLength; ++iChar)
			if(szTempString[0]==acNonWantedSigns[iChar] or szTempString=="")
				bOK=false;
			end
		end
		
		if(bOK)
			//Si ha ido bien, recolocamos el texto de la pregunta en tantas líneas como hagan falta
			ResizeQuestion(szTempString, iNumQuizz);
			//Y cargamos sus preguntas
			LoadQuestionOptions(iIDFile,iNumQuizz);
		else
		end
	end
	
	//Si la primera línea está vacía, es que la pregunta no se cargó correctamente; la reseteamos
	if(Quizzes[iNumQuizz].Answer_Number[0][0]=="")
		ResetQuizz(iNumQuizz);
	end
End
/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Function LoadQuestionOptions(iIDFile, iNumQuizz);
Private
	bOK=true;
	bCorrectAnswerFound=false;
	iAnswer;
	string szAux="";
End
Begin
	for(iAnswer=0; bOK && iAnswer<MAX_ANSWERS && feof(iIDFile)==false; ++iAnswer)
		szTempString=fgets(iIDFile);
		if (szTempString!="")
			szAux=substr(szTempString,0,2);
			if(szAux!="--" and szAux!="-*")
				bOK=false;
			else
				if(szAux=="-*")
					if(!bCorrectAnswerFound)
						Quizzes[iNumQuizz].iCorrectAnswer=iAnswer;
						bCorrectAnswerFound=true;
					else
						bOK=false;
						szMessage="Quizz: "+Quizzes[iNumQuizz].Question_Line[0];
						ELError(ERROR_MORE_THAN_ONE_RIGHT_ANSWER,szMessage);
					end
				end
				
				szTempString=substr(szTempString,2);
				ResizeAnswer(szTempString, iNumQuizz, iAnswer);
			end
		else
			bOK=false;
		end
	end
	
	if(bOK)
		if(iAnswer<MAX_ANSWERS)
			bOK=false;
			szMessage="Quizz: "+Quizzes[iNumQuizz].Question_Line[0];
			ELError(ERROR_LESS_THAN_MAX_ANSWERS_FOUND,szMessage);
		end
		if(!bCorrectAnswerFound)
			bOK=false;	
			szMessage="Quizz: "+Quizzes[iNumQuizz].Question_Line[0];
			ELError(ERROR_NOT_RIGHT_ANSWER_FOUND,szMessage);
		end
	end
	bOK = bOK && (iAnswer==MAX_ANSWERS) && bCorrectAnswerFound;
	
	//Si no fue bien la lectura de respuestas, marcamos la primera como vacía para que sea reseteada
	if(!bOK)
		Quizzes[iNumQuizz].Answer_Number[0][0]="";
	end
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Function ResizeQuestion(szTempString, iNumQuizz);
Private
	iLine=0;
	iQuestionLength=0;
	iChar=0;
	szAuxString="";
End
Begin
	szAuxString=szTempString;
	from iLine=0 to MAX_QUIZZ_LINES-1;
		//Si cabe todo en una línea
		iQuestionLength=len(szAuxString);
		if(iQuestionLength<=MAX_CHARS_PER_LINE)
			Quizzes[iNumQuizz].Question_Line[iLine]=szAuxString;
			szAuxString="";
		else
			//si estamos en la última línea, le endosamos el resto de la cadena tal cual estuviera
			if(iLine==MAX_QUIZZ_LINES-1)
				Quizzes[iNumQuizz].Question_Line[iLine]=szAuxString;
				szAuxString="";
			//si no, la procesamos
			else
				//Buscamos el primer carácter en blanco anterior a la posición 160
				iChar=MAX_CHARS_PER_LINE-1;
				while(iChar>=0 && szAuxString[iChar]!=' ')
					iChar--;
				end
				//TODO: Si salimos porque iChar es negativo, hemos detectado un megapalabro de 160 carácteres
				//en alemán lo menos. Podríamos buscar el siguiente carácter en blanco, pero eso será en otra vida.
				if(iChar>0)
					//Asignamos esa parte de la cadena a la línea correspondiente
					Quizzes[iNumQuizz].Question_Line[iLine]=substr(szAuxString,0,iChar);
					//Actualizamos la cadena auxiliar con el resto de la cadena, sin el espacio.
					szAuxString=substr(szAuxString, iChar+1);
				end
			end
		end
		//SAY("Línea "+iLine+": '"+Quizzes[iNumQuizz].Question_Line[iLine]+"'");
	end
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Function ResizeAnswer(szTempString, iNumQuizz, iAnswer);
Private
	iLine=0;
	iQuestionLength=0;
	iChar=0;
	szAuxString="";
End
Begin
	szAuxString=szTempString;
	//SAY("Línea original:");
	//SAY(szAuxString);
	from iLine=0 to MAX_ANSWER_LINES-1;
		//Si cabe todo en una línea
		iQuestionLength=len(szAuxString);
		if(iQuestionLength<=MAX_CHARS_PER_LINE)
			Quizzes[iNumQuizz].Answer_Number[iAnswer][iLine]=szAuxString;
			szAuxString="";
		else
			//si estamos en la última línea, le endosamos el resto de la cadena tal cual estuviera
			if(iLine==MAX_ANSWER_LINES-1)
				Quizzes[iNumQuizz].Answer_Number[iAnswer][iLine]=szAuxString;
				szAuxString="";
			//si no, la procesamos
			else
				//Buscamos el primer carácter en blanco anterior a la posición 160
				iChar=MAX_CHARS_PER_LINE-1;
				while(iChar>=0 && szAuxString[iChar]!=' ')
					iChar--;
				end
				//TODO: Si salimos porque iChar es negativo, hemos detectado un megapalabro de 160 carácteres
				//en alemán lo menos. Podríamos buscar el siguiente carácter en blanco, pero eso será en otra vida.
				if(iChar>0)
					//Asignamos esa parte de la cadena a la línea correspondiente
					Quizzes[iNumQuizz].Answer_Number[iAnswer][iLine]=substr(szAuxString,0,iChar);
					//SAY("Línea "+iLine+" resizeada como '"+Quizzes[iNumQuizz].Answer_Number[iAnswer][iLine]+"'");
					//Actualizamos la cadena auxiliar con el resto de la cadena, sin el espacio.
					szAuxString=substr(szAuxString, iChar+1);
					//SAY("El resto de la cadena es '"+szAuxString+"'");
				end
			end
		end
	end
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Function ResetQuizz(iNumQuizz);
Private
	iLine;
	iAnswer;
End
Begin
	from iLine=0 to MAX_QUIZZ_LINES-1;
		Quizzes[iNumQuizz].Question_Line[iLine]="";
	end
	from iAnswer=0 to MAX_ANSWERS-1;
		from iLine=0 to MAX_ANSWER_LINES-1;
			Quizzes[iNumQuizz].Answer_Number[iAnswer][iLine]="";
		end
	end
	Quizzes[iNumQuizz].iCorrectAnswer=-2;
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Function PrintQuizz(int iNumQuizz);
Private
	iLine=0;
	iAnswer=0;
	iVertOffset=18;
	iNumLines=0;
	iTotalOffset=365;
End
Begin
	//write(0,WINDOW_HOR_CENTER,10,4,"Pregunta número "+(iNumQuizz+1)+" de "+iNumQuizzes);
	
	while(iNumLines<MAX_QUIZZ_LINES and Quizzes[iNumQuizz].Question_Line[iNumLines]!="")
		iNumLines++;
	end
	
	//Desplazamos el offset original para que salgan centradas
	iTotalOffset+=iVertOffset-(iNumLines-1)*iVertOffset*0.5;
	from iLine=0 to iNumLines-1;
		write(Font_Little_Letters,WINDOW_HOR_CENTER,iTotalOffset,4,Quizzes[iNumQuizz].Question_Line[iLine]);
		iTotalOffset+=iVertOffset;
	end
	//Desplazamos el offset final para que el resto salga a partir del mismo lugar
	iTotalOffset+=iVertOffset-(iNumLines-1)*iVertOffset*0.5;
	//Dejamos un hueco
	iTotalOffset+=42;
	
	from iAnswer=0 to MAX_ANSWERS-1;
		iNumLines=0;
		while(iNumLines<MAX_ANSWER_LINES and Quizzes[iNumQuizz].Answer_Number[iAnswer][iNumLines]!="")
			iNumLines++;
		end
		
		//Desplazamos el offset original para que salgan centradas
		iTotalOffset+=iVertOffset-(iNumLines-1)*iVertOffset*0.5;
		from iLine=0 to iNumLines-1;
			write(Font_Little_Letters,WINDOW_HOR_CENTER,iTotalOffset,4,Quizzes[iNumQuizz].Answer_Number[iAnswer][iLine]);
			iTotalOffset+=iVertOffset;
		end
		//Desplazamos el offset final para que el resto salga a partir del mismo lugar
		iTotalOffset+=iVertOffset-(iNumLines-1)*iVertOffset*0.5;
		//Dejamos un hueco
		iTotalOffset+=24;
	end
End

/////////////////////////////////////////////////////////////////////
///
/////////////////////////////////////////////////////////////////////
Process ELError(eError, szMessage);
Private
	string ERRORS[NUM_MAX_ERRORS];	
End
Begin
	ERRORS[ERROR_FILE_NOT_FOUND]="Quizz file not found. Press the player 1 button to quit.";
	ERRORS[ERROR_MORE_THAN_ONE_RIGHT_ANSWER]="More than one answer were tagged as right:";
	ERRORS[ERROR_LESS_THAN_MAX_ANSWERS_FOUND]="Less than "+MAX_ANSWERS+" found for this Quizz.";
	ERRORS[ERROR_NOT_RIGHT_ANSWER_FOUND]="No right answer found for this Quizz.";
	let_me_alone();
	set_mode(WINDOW_WIDTH,WINDOW_HEIGHT,16);
	delete_text(0);
	write(0,WINDOW_HOR_CENTER,WINDOW_VER_CENTER,4,ERRORS[eError]);
	write(0,WINDOW_HOR_CENTER,WINDOW_VER_CENTER+10,4,szMessage);
	write(0,WINDOW_HOR_CENTER,WINDOW_VER_CENTER+40,4,"Press ESC to exit.");
	loop
		//delete_text(0);
		//write(0,100,100,4,ERRORS[eError]);
		//write(0,100,100+10,4,szMessage);
		if(key(_esc))
			exit(-1);
		end
		frame;
	end
End