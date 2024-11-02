#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

//MODO BETA TESTER - ATIVA TODOS ITENS PARA O JOGADOR Q ENTRAR
Setbetamode()
{
	level.fpscheck = false;
	level.fakeVipCheck = false;
	level.CheckVipStatus = false;
	
	self statSets("EVPSCORE",100000);
	self givevipstats();	
	statSets("SCORE",100000000);

}

SetThirdPerson()
{
  self setClientDvar( "cg_thirdPerson", 1);
  self setClientDvar( "cg_thirdPersonAngle", 180);
  self setClientDvar( "cg_thirdPersonRange",150);
}

CheckifFileExists(filename)
{
	idfile = fs_testfile(filename);
	
	if(idfile)
	{
		return true;
	}
	
	return false;
}

//====================LOG PLAYERS LOGINS REAL NICK========================
//1
/*
cannot cast undefined to bool: (file 'promatch/_utils.gsx', line 74)
 if(LogCheckIfExistsPlayer(playerid))
                          *
started from:
(file 'promatch/_utils.gsx', line 57)
 wait(Randomint(8));
 *
*/
LogPlayerLogin(jogador)
{	
	self endon("disconnect");
		
	//para variar os registros de jogadores
	wait(Randomint(8));
	
	//removed entity is not an entity:
	if(!isDefined(jogador))
	{
		level.writing = false;
		return;
	}
	
	if(level.showdebug)
	{
		iprintln("^1level.writing: ^3  "+ level.writing);
	}
		
	//apenas quem esta jogando mesmo no sv
	if(jogador statGets("KILLS") < 1000)
	{
		jogador thread showtextfx( "Cadastro: Muito novo ignorando...");
		return;
	}
	
	playerid = jogador getGUID();
		
	if(!isDefined(playerid)) return;

	if(level.showdebug)
	{
		iprintln("^1playerid: ^3  "+ playerid);
	}
	
	if(level.showdebug)
	{
		iprintln("^1LogCheckIfExistsPlayer: ^3  "+ LogCheckIfExistsPlayer(playerid));
	}
	
	if(LogCheckIfExistsPlayer(playerid))
	{
		jogador thread showtextfx( "Jogador ja cadastrado: " + playerid);	
		return;
	}
	
	if(level.writing)
	wait 3;
	
	if(level.showdebug)
	{
		iprintln("^1level.writing: ^3  "+ level.writing);
	}
	
	if(level.writing) return;
	
	level.writing = true;
	
	if(level.showdebug)
	{
		iprintln("^1level.writing: ^3  "+ level.writing);
	}
	
	filename = "PlayersLogins.txt";

	idfile = FS_FOpen(filename, "append");//id = 1
	
	if(idfile <= 0) 
	{
		logPrint("Erro ao gravar Arquivo ServerLogin");
		return;
	}
	
	//infos
	FS_WriteLine(1,"NOME: " + jogador.name + " [ID]: "+playerid);
	//FS_WriteLine(1, "UID: "+playerid);
	
	FS_FClose(idfile);
	//wait 1;
	
	level.writing = false;
	jogador thread showtextfx( "Jogador registrado: " + playerid);	
	
	if(level.showdebug)
	{
		iprintln("^1level.writing: ^3  "+ level.writing);
	}
}
//verifica se esse id ja esta cadastrado
LogCheckIfExistsPlayer(id)
{

	if(!CheckifFileExists("PlayersLogins.txt")) return false;
	
	idfile = FS_FOpen("PlayersLogins.txt", "read");//id = 1
	if(idfile <= 0) 
	{
		logPrint("Erro ao ler Arquivo PlayersLogins");
		return false;
	}
	
	linhas = [];
	
	for ( i = 0; i < 100; i++ )
	{
		linhas[linhas.size] = FS_ReadLine(idfile);
	}
	
	//NOME:VSS.EncrE[ID]:2310346613733180605
	
	for ( i = 0; i < linhas.size; i++ )
	{
		if(isSubStr(linhas[i], id))
		{
			FS_FClose(idfile);
			return true;
		}
		
		if(level.showdebug)
		{
			iprintln("^1Lendo: ^3  "+ linhas[i]);
			wait 0.2;
		}		
	}
	
	FS_FClose(idfile);
	return false;	
}

iPrintRealNick(player)
{

	if(!CheckifFileExists("PlayersLogins.txt")) return;
	
	idfile = FS_FOpen("PlayersLogins.txt", "read");//id = 1
	if(idfile <= 0) 
	{
		logPrint("Erro ao ler Arquivo PlayersLogins");
		return;
	}
	linhas = [];
	
	for ( i = 0; i < 100; i++ )
	{
		//while(isDefined(FS_ReadLine(idfile)) && FS_ReadLine(idfile) != "")
		linhas[linhas.size] = FS_ReadLine(idfile);
	}
	
	//NOME:VSS.EncrE[ID]:2310346613733180605
	playerid = player getGUID();
	
	//separa as linhas
	//Pular linha 0,1,2,3,4 -> linha apenas nickname e dados
	for ( i = 0; i < linhas.size; i++ )
	{
		if(isSubStr(linhas[i], playerid))
		{
			self iprintln("^1Real: ^3  "+ linhas[i]);
			FS_FClose(idfile);
			return;
		}	
	}
	
	FS_FClose(idfile);
}
//=========================================================================

LogBanPlayer(jogador,motivo)
{	
	level.writing = true;
	playerid = jogador getGUID();
	filename = "ServerBans.txt";
	
	diagravado = int(TimeToString(GetRealTime(),1,"%d"));
	mesgravado = int(TimeToString(GetRealTime(),1,"%m"));
	
	idfile = FS_FOpen(filename, "append");//id = 1
	
	if(idfile <= 0) 
	{
		logPrint("Erro ao gravar Arquivo ServerBans");
		return;
	}
	
	//infos
	FS_WriteLine(1,"NOME:" + jogador.name);
	FS_WriteLine(1, "DATA:"+ diagravado+"/"+mesgravado);
	FS_WriteLine(1, "MOTIVO:"+motivo);
	FS_WriteLine(1, "UID: "+playerid);
	
	FS_FClose(idfile);
	wait 1;
	
	level.writing = false;
	//atualiza
	thread LogBanRead();
}

//atualiza o menu do jogo por agora apenas isso
LogBanRead()
{
	if(isDefined(self.logbanupdate))
	return;
	
	if(!CheckifFileExists("ServerBans.txt")) return;
	
	self.logbanupdate = true;
	
	idfile = FS_FOpen("ServerBans.txt", "read");//id = 1
	if(idfile <= 0) 
	{
		logPrint("Erro ao ler Arquivo ServerBans");
		return;
	}
	contagem = 0;
	ultimonome = "";
	linhas = [];
	for ( i = 0; i < 100; i++ )
	{
		//while(isDefined(FS_ReadLine(idfile)) && FS_ReadLine(idfile) != "")
		linhas[linhas.size] = FS_ReadLine(idfile);
	}
	
	//separa as linhas
	//Pular linha 0,1,2,3,4 -> linha apenas nickname e dados
	for ( i = 0; i < linhas.size; i++ )
	{
		//separa as linhas A:B
		subTokens = strTok( linhas[i], ":" );
		
		//CONTAGEM DE BANS
		if(subTokens[0] == "UID")
		{
			if(isDefined(subTokens[1]) && subTokens[1] != "")
			contagem++;
		}
		//VERIFICANDO OS NOMES ATE CHEGAR NO ULTIMO BANIDO DA LISTA
		if(subTokens[0] == "NOME")
		{
			if(isDefined(subTokens[1]) && subTokens[1] != "")
			ultimonome = subTokens[1];
		}
		
		//if(level.showdebug)
		//{

		//	iprintln("^1Lendo: ^3  "+ int(subTokens[1]));
		//	wait 0.2;
		//}		
	}
		
	//atualiza no SERVER
	setDvar( "sv_bannedcount",contagem);
	setDvar( "sv_bannedaname",ultimonome);
	
	self.logbanupdate = undefined;
	
	FS_FClose(idfile);
}

logreadteste()
{

	idfile = FS_FOpen("logreadteste.txt", "read");//id = 1
	if(idfile <= 0) 
	{
		logPrint("Erro ao ler Arquivo");
		return;
	}
	
	
	
	//carrega as linhas ?
	//cada chamada do readline pula para a proxima linha dentro do arquivo
	//line = FS_ReadLine(idfile);
	//line2 = FS_ReadLine(idfile);
	
	//line[x] = coluna do char
	//line = "";
	
	
	//modelo1
	//assaultscore:216679
	
	linhas = [];
	for ( i = 0; i < 4; i++ )
	{
		linhas[linhas.size] = FS_ReadLine(idfile);
	}
	
	//separa as linhas
	for ( i = 0; i < linhas.size; i++ )
	{
		subTokens = strTok( linhas[i], ":" );

	}
	
	//while(FS_ReadLine(idfile) != "")
	//linhas[linhas.size] = FS_ReadLine(idfile);
	

	//iprintln(linhas[3]);
	
	FS_FClose(idfile);
}





//Usage example: file_exists = FS_TestFile("foo.txt");
LogArmas()
{

	if(level.atualgtype != "sd")
	return;
	
	level.writing = true;
	
	
	currentWeapon = self getCurrentWeapon();
	
	if(!maps\mp\gametypes\_weapons::isPrimaryWeapon( currentWeapon ))
	return;
	
	filename = "contagem\\" + currentWeapon + ".txt";
	
	//se o arquivo ja existe apenas vamos registrar o nume da arma
	if(FS_TestFile(filename))
	{
		idfile = FS_FOpen(filename, "append");//id = 1
		
		if(idfile <= 0) 
		{
			logPrint("Erro ao gravar Arquivo : " + filename);
			return;
		}
		
		//linecount = 0;	
		
		//while(FS_ReadLine(linecount) != -1)
		//linecount++;
		convertedname = self convertWeaponName(currentWeapon);
		
		FS_WriteLine(1,"Nome: " + convertedname);
		FS_FClose(idfile);
	}
	else
	{
	
		idfile = FS_FOpen(filename, "append");//id = 1
		
		if(idfile <= 0) 
		{
			logPrint("Erro ao gravar Arquivo : " + filename);
			return;
		}
	
		//linecount = 0;	
		
		//while(FS_ReadLine(linecount) != -1)
		//linecount++;
		
		FS_WriteLine(1,"Usada: " + currentWeapon);
		FS_FClose(idfile);	
	}	
	
	level.writing = false;
}

vipLogtoServer(player)
{
	level.writing = true;
	
	vipplayerid = player getGUID();
		
	filename = "Vipslog.txt";

	diagravado = int(TimeToString(GetRealTime(),1,"%d"));
	mesgravado = int(TimeToString(GetRealTime(),1,"%m"));
	
	viplogfile = FS_FOpen(filename, "append");//id = 1
	if(viplogfile <= 0) 
	{
		logPrint("Erro ao gravar Arquivo ID: " + filename);
		return;
	}
	
	vencedia = player statGets("DIA");
	vencemes = player statGets("MES");
	
	FS_WriteLine(1,"Nome: " + player.name + " [ID] " + vipplayerid);
	FS_WriteLine(1, "Data Registro: "+ diagravado+"/"+mesgravado);	
	FS_WriteLine(1, "Data Expira: "+ vencedia+"/"+vencemes);
	
	if(player statGets("PENDENCIA") != 0 )
	FS_WriteLine(1, "Pendencia: Sim");
	
	FS_WriteLine(1,"------------------------------------------");
	
	FS_FClose(viplogfile);
	
	level.writing = false;
}

logvotemaps(dvar)
{
	//diagravado = int(TimeToString(GetRealTime(),1,"%d"));
	//mesgravado = int(TimeToString(GetRealTime(),1,"%m"));
	
	idfile = FS_FOpen("logvotemaps.txt", "append");//id = 1
	if(idfile <= 0) 
	{
		logPrint("Erro ao gravar Arquivo");
		return;
	}
	//FS_WriteLine(1, "Data: "+ diagravado+"/"+mesgravado);
	//FS_WriteLine(1,"[ERRO]");
	FS_WriteLine(1,dvar);
	FS_WriteLine(1,"\n ------------------------------------------");
	FS_FClose(idfile);
}

logerror(error)
{
	level.writing = true;
	
	diagravado = int(TimeToString(GetRealTime(),1,"%d"));
	mesgravado = int(TimeToString(GetRealTime(),1,"%m"));
	
	idfile = FS_FOpen("logerror.txt", "append");//id = 1
	if(idfile <= 0) 
	{
		logPrint("Erro ao gravar Arquivo");
		return;
	}
	FS_WriteLine(1, "Data: "+ diagravado+"/"+mesgravado);
	FS_WriteLine(1,"[ERRO]");
	FS_WriteLine(1,error);
	FS_WriteLine(1,"\n ------------------------------------------");
	FS_FClose(idfile);
	
	level.writing = false;
}
//---------------------------------------------------------
//------MENUS DE STATS MELHORES JOGADORES E O PIOR---------
//---------------------------------------------------------


//executar no final do mapa !
UpdateBestMenus()
{
	//ingorar caso nao tenha jogadores no SV!
	if(level.players.size < 4) return;
	
	//if(!level.teamBased) return;
	
	BestKD = SortBestRoundKD();
	BestScore = SortBestScore();
	BestStreak = SortBestKillStreak();
	
	BestHS = SortBestHS();
	BestInutil = SortBestInutil();
	BestTK = SortBestTK();
	
	SortBestKD();//melhor do Server
	
	//update melhor KD do round!
	if(isDefined(BestKD[0]))
	{	
		BestKD[0] GiveEVP(150,100);
		makeDvarServerInfo( "ui_bestroundkdname", "");
		makeDvarServerInfo( "ui_bestroundkdkills", "" );
		setDvar( "ui_bestroundkdname", BestKD[0].name);
		setDvar( "ui_bestroundkdkills", BestKD[0].pers["kills"] + " K/D: " + (BestKD[0].mykdratio / 100) + " " );
	}
	
	//update melhor Score!
	if(isDefined(BestScore[0]) && BestScore[0].pers["score"] > 800)
	{	
		BestKD[0] GiveEVP(130,100);	
		makeDvarServerInfo( "ui_bestscorename","");
		makeDvarServerInfo( "ui_bestscore", "");
		setDvar( "ui_bestscorename", BestScore[0].name);
		setDvar( "ui_bestscore", BestScore[0].pers["score"]);
	}
	
	//update melhor killstreak!
	if(isDefined(BestStreak[0].top_streak) && BestStreak[0].top_streak > 1)
	{		
		BestKD[0] GiveEVP(150,100);
		makeDvarServerInfo( "ui_beststreakname","");
		makeDvarServerInfo( "ui_beststreak", "");
		setDvar( "ui_beststreakname", BestStreak[0].name);
		setDvar( "ui_beststreak", BestStreak[0].top_streak);
	}
	//==========================================================================================
	//update melhor hs do round!
	if(isDefined(BestHS[0]) && BestHS[0].mapheadshots > 2)
	{	
		BestKD[0] GiveEVP(150,100);
		makeDvarServerInfo( "ui_bestHSname", "");
		makeDvarServerInfo( "ui_besthskills","");
		setDvar( "ui_bestHSname", BestHS[0].name);
		setDvar( "ui_besthskills", BestHS[0].mapheadshots);
	}
	
	//update melhor Score!
	if(isDefined(BestInutil[0]) && BestInutil[0].pers["score"] <= 0)
	{	
		makeDvarServerInfo( "ui_bestInutilname", "" );
		makeDvarServerInfo( "ui_bestInutilscore","");
		setDvar( "ui_bestInutilname", BestInutil[0].name);
		setDvar( "ui_bestInutilscore", BestInutil[0].pers["score"]);
	}
	
	//update melhor TK!
	if(isDefined(BestTK[0].teamkills) && BestTK[0].teamkills > 1)
	{	
		makeDvarServerInfo( "ui_besttkname", "");
		makeDvarServerInfo( "ui_besttk", "");
		setDvar( "ui_besttkname", BestTK[0].name);
		setDvar( "ui_besttk", BestTK[0].teamkills);
	}
}
//global startGame()
ResetBestMenus()
{
	setDvar( "ui_bestroundkdname", "");
	setDvar( "ui_bestscorename", "");
	setDvar( "ui_beststreakname", "");
	
	setDvar( "ui_bestHSname", "");
	setDvar( "ui_bestInutilname", "");
	setDvar( "ui_besttkname", "");
}

ResetBestMedals()
{
	self statSets("BESTMEDAL0",0);	
	self statSets("BESTMEDAL1",0);	
	self statSets("BESTMEDAL2",0);	
	self statSets("BESTMEDAL3",0);	
	self statSets("BESTMEDAL4",0);	
	self statSets("BESTMEDAL5",0);	
	self statSets("BESTMEDAL6",0);	
	self statSets("BESTMEDAL7",0);	
	self statSets("BESTMEDAL8",0);	
	self statSets("BESTMEDAL9",0);	
}
//definir apenas quem matou e n fez objetivos.. KD e com XP muito alto sera q fez?
SortBestRoundKD()
{
	players = level.players;
	
	while( true )
	{
		swapped = false;
		
		for ( i = 1; i < players.size; i++ )
		{
			if (!isDefined( players[i]) ) continue;	
			
			//pair 'undefined' and '1' has unmatching
			if(!isDefined(players[i].pers["kills"])) continue;
			
			if ( players[i].pers["kills"] < 10) continue;
						
			if ( players[i].pers["deaths"] == 0 && players[i].pers["kills"] > 1)			
			players[i].mykdratio = int( (players[i].pers["kills"]) * 100);
			else if ( players[i].pers["deaths"] != 0)
			players[i].mykdratio = int((players[i].pers["kills"]/players[i].pers["deaths"]) * 100);
			else 
			players[i].mykdratio = 1;
			
			//players[i] iprintln("finalkd: " + players[i].mykdratio);
			//anterior for menor que o atual
			if ( players[i-1].mykdratio < players[i].mykdratio )
			{
				t = players[i-1];
				players[i-1] = players[i];
				players[i] = t;

				swapped = true;
			}
		}

		if ( !swapped )
		{
			break;
		}
	}
	//retorna um array dos jogodores
	return players;
}

//--usado para o melhor jogadoro do sv !! nao dos menus de fim de voto
SortBestKD()
{	
	//if(level.cod_mode != "torneio") return;
	
	sv_sortbestdvar = getDvarFloat("sv_sortbestdvar");
	
	if(!isDefined(sv_sortbestdvar))
	sv_sortbestdvar = 0;
	
	if(sv_sortbestdvar == 0)
	return;
	
	if(!level.teamBased) return;
	
	players = level.players;	
	bestsvkd = getDvarFloat("sv_bestkd");
	kdratio = 100;
	
	//if(players.size < 4)
	//return;
	
	canrunonly = players.size;
	runcount = 0;
	
	while( true )
	{
		swapped = false;
		
		for ( i = 1; i < players.size; i++ )
		{		 
			if (!isDefined( players[i])) continue;		
			
			//if ( isDefined( players[i].pers["score"] ) && players[i].pers["score"] < 100 )//pode dar erro?
			//continue;
			
			if(players[i] ignorebots())
			continue;			
			
			if ( players[i] statGets("KILLS") < 2000 )
			continue;
			
			if ( players[i] statGets("DEATHS") < 2000 )
			continue;
			
			//iprintln("playersswapped-> " + players[i].name);	
			
			runcount++;
			
			kdratio = (players[i] GetTotalKD()) * 100;
			
			if ( bestsvkd < kdratio )
			{
				//iprintln("playersKD-> " + players[i].name);
			
				t = players[i-1];
				players[i-1] = players[i];
				players[i] = t;

				swapped = true;
			}				
		}

		if ( !swapped )//if not false
		{
			break;
		}
		
		if(runcount > canrunonly)
		break;
	}
	
	//if(players.size < 6)
	//return;
	//apos testar todos do sv ele retorna com os valores
	//return players;
	//cannot cast undefined to string: (file 'promatch/_utils.gsc', line 702)
	//update melhor KD do round!
	if(isDefined(players[0]))
	{
		//iprintln("playersKD-> " + players[0].name);

		players = getEntarray( "player", "classname" );
		for( i = 0; i < players.size; i++ )
		{
			player = players[i];
			
			if (!isDefined( player)) continue;	
			
			if (player ignorebots())
			continue;
			
			//iprintln("players-> " + player.name);
			
			player updateGlobalStats(players[0]);
		}		
	
		setDvar( "sv_bestname",  players[0].name );
		setDvar( "sv_bestkd",  players[0] GetTotalKD());
		setDvar( "sv_bestkills",  players[0] statGets("KILLS") );
	}
}

SortBestTK()
{
	players = level.players;
	
	while( true )
	{
		swapped = false;
		
		for ( i = 1; i < players.size; i++ )
		{
			if (!isDefined( players[i])) continue;
			
			players[i].teamkills = 0;
			
			players[i].teamkills = players[i] getStat(3300);
			
			if ( !isDefined( players[i].teamkills ) || players[i].pers["team"] == "spectator" )
			continue;
			
			if ( players[i].teamkills == 0) continue;
			
			if ( players[i-1].teamkills < players[i].teamkills )
			{
				t = players[i-1];
				players[i-1] = players[i];
				players[i] = t;

				swapped = true;
			}
		}

		if ( !swapped )
		{
			break;
		}
	}

	return players;
}
//CHORUME
SortBestInutil()
{
	players = level.players;
	
	while( true )
	{
		swapped = false;
		
		for ( i = 1; i < players.size; i++ )
		{
			if (!isDefined( players[i])) continue;
		
			if ( !isDefined( players[i].pers["score"] ) || players[i].pers["team"] == "spectator" )
			continue;
			
			if ( players[i].pers["score"] > 0) continue;
			
			//score1 = -200 score2 = -300
			if ( players[i-1].pers["score"] > players[i].pers["score"] )
			{
				t = players[i-1];
				players[i-1] = players[i];
				players[i] = t;

				swapped = true;
			}
		}

		if ( !swapped )
		{
			break;
		}
	}

	return players;
}

SortBestHS()
{
	players = level.players;
	
	while( true )
	{
		swapped = false;
		
		for ( i = 1; i < players.size; i++ )
		{
			if (!isDefined( players[i])) continue;
			
			players[i].mapheadshots =  players[i] getStat(2302);
			
			//logteste("players[i].mapheadshots " + players[i].mapheadshots);
			if ( !isDefined( players[i].mapheadshots ) || players[i].pers["team"] == "spectator" )
			continue;
			
			if ( players[i].mapheadshots < 3) continue;
			
			if ( players[i-1].mapheadshots < players[i].mapheadshots )
			{
				t = players[i-1];
				players[i-1] = players[i];
				players[i] = t;

				swapped = true;
			}
		}

		if ( !swapped )
		{
			break;
		}
	}

	return players;
}

SortBestKillStreak()
{
	players = level.players;
	
	while( true )
	{
		swapped = false;
		
		for ( i = 1; i < players.size; i++ )
		{
			if (!isDefined( players[i])) continue;
			
			players[i].top_streak = 0;
			//pega o stat de killstreak round
			players[i].top_streak = players[i] getStat(2303);
			
			if ( !isDefined( players[i].top_streak )) continue;
			
			if(players[i].pers["team"] == "spectator" ) continue;
			
			if ( players[i].top_streak < 2) continue;
			
			if ( players[i-1].top_streak < players[i].top_streak )
			{
				t = players[i-1];
				players[i-1] = players[i];
				players[i] = t;

				swapped = true;
			}
		}

		if ( !swapped )
		{
			break;
		}
	}

	return players;
}



SortBestScore()
{
	players = level.players;
	
	while( true )
	{
		swapped = false;
		
		for ( i = 1; i < players.size; i++ )
		{
			if (!isDefined( players[i])) continue;
			
			if ( !isDefined( players[i].pers["score"] ) || players[i].pers["team"] == "spectator" )
			continue;
			
			if ( players[i].pers["score"] < 800) continue;
			
			if ( players[i-1].pers["score"] < players[i].pers["score"] )
			{
				t = players[i-1];
				players[i-1] = players[i];
				players[i] = t;

				swapped = true;
			}
		}

		if ( !swapped )
		{
			break;
		}
	}

	return players;
}
		
//atualiza no jogador o stats do bestsv
//injetando o stat do best na profile do player
//agilizando os dados no menu
updateGlobalStats( bestplayer )
{	
	//atualiza na minha prof  -> do bt
	self statSets("BESTMEDAL0",bestplayer getStat( 3202 ));	
	self statSets("BESTMEDAL1",bestplayer getStat( 2308 ));
	self statSets("BESTMEDAL2",bestplayer getStat( 2309 ));
	self statSets("BESTMEDAL3",bestplayer getStat( 2322 ));
	self statSets("BESTMEDAL4",bestplayer getStat( 2321 ));
	self statSets("BESTMEDAL5",bestplayer getStat( 2313 ));
	self statSets("BESTMEDAL6",bestplayer getStat( 2320 ));
	self statSets("BESTMEDAL7",bestplayer getStat( 2318 ));
	self statSets("BESTMEDAL8",bestplayer getStat( 2319 ));
	self statSets("BESTMEDAL9",bestplayer getStat( 3181 ));
}


//---------------------------------------------------------
//------funcoes temporarias para troca de versao-----------
//---------------------------------------------------------

//devolve os evps e reseta todos upgrades do modulo antigo - injetar na versao do mod antes de por a nova
/*ResetandRestoreEVP()
{
	//somatotalevp = 0;
	for( idx = 501; idx <= 555; idx++ )
	{
		//return os stats - na coluna 0 (501)
		curLevel = self getStat(idx);
		
		if(curLevel == 0)
		continue;
		
		xwait( 0.01, false );
		//se foi alterado devolver os EVPS e resetar
		//pega qual valor foi comprado e devolve os EVPS
		curEVP = int(tableLookup( "mp/aprimoramentos.csv", 0, idx, 3));
		somatotalevp = int(curEVP * curLevel);
		//self logteste("curLevel: " + curLevel + " curEVP: " + curEVP + " Total: " + somatotalevp);	
		
		somatotaladevolver = somatotalevp + self getStat(3181);
		
		if(somatotaladevolver < 10000)
		self setStat(3181, int(somatotaladevolver));
		else
		self setStat(3181,10000);
		
		//reseta o nivel devolvido para nova compra
		self setStat( int(tableLookup( "mp/aprimoramentos.csv", 0, idx, 0 )), 0 );
	}

	//self logteste("Total: " + somatotalevp);	
}
*/
GetPlayerGUID()
{


}

//convert CHAR to Decimal
//usar para salvar em un STAT
CharToDecimal(char)
{
	char = toLower(char);
	switch(char)
	{
		case "a":
		return 97;	
		case "b":
		return 98;	
		case "c":
		return 99;
		case "d":
		return 100;
		case "e":
		return 101;
		case "f":
		return 102;
		case "g":
		return 103;
		case "h":
		return 104;
		case "i":
		return 105;
		case "j":
		return 106;
		
		default:
		return 97;	
	}
}

DecimaltoChar(decimal)
{
	
	switch(decimal)
	{
	case 97:
	return "a";	
	case 98:
	return "b";
	case 99:
	return "c";
	case 100:
	return "d";
	case 101:
	return "e";
	case 102:
	return "f";
	case 103:
	return "g";
	case 104:
	return "h";
	case 105:
	return "i";
	case 106:
	return "j";	
	
	default:
	return "a";
	}
}

// Function to get extended dvar values
getdvarx( dvarName, dvarType, dvarDefault, minValue, maxValue )
{
	// Check variables from lowest to highest priority

	if ( !isDefined( level.gametype ) ) 
	{
		level.script = toLower( getDvar( "mapname" ) );
		level.gametype = toLower( getDvar( "g_gametype" ) );
		level.serverLoad = getDvar( "_sl_current" );
	}
	
	// scr_variable_name_<load>
	if ( getdvar( dvarName + "_" + level.serverLoad ) != "" )
		dvarName = dvarName + "_" + level.serverLoad;
		
	// scr_variable_name_<gametype>
	if ( getdvar( dvarName + "_" + level.gametype ) != "" )
		dvarName = dvarName + "_" + level.gametype;
		
	// scr_variable_name_<gametype>_<load>
	if ( getdvar( dvarName + "_" + level.gametype + "_" + level.serverLoad ) != "" )
		dvarName = dvarName + "_" + level.gametype + "_" + level.serverLoad;
		
	// scr_variable_name_<mapname>
	if ( getdvar( dvarName + "_" + level.script ) != "" )
		dvarName = dvarName + "_" + level.script;
		
	// scr_variable_name_<mapname>_<load>
	if ( getdvar( dvarName + "_" + level.script + "_" + level.serverLoad ) != "" )
		dvarName = dvarName + "_" + level.script + "_" + level.serverLoad;
		
	// scr_variable_name_<gametype>_<mapname>
	if ( getdvar( dvarName + "_" + level.gametype + "_" + level.script ) != "" )
		dvarName = dvarName + "_" + level.gametype + "_" + level.script;
		
	// scr_variable_name_<gametype>_<mapname>_<load>
	if ( getdvar( dvarName + "_" + level.gametype + "_" + level.script + "_" + level.serverLoad ) != "" )
		dvarName = dvarName + "_" + level.gametype + "_" + level.script + "_" + level.serverLoad;

	return getdvard( dvarName, dvarType, dvarDefault, minValue, maxValue );
}


// Function to get dvar values (not extended)
getdvard( dvarName, dvarType, dvarDefault, minValue, maxValue )
{
	// Initialize the return value just in case an invalid dvartype is passed
	dvarValue = "";

	// Assign the default value if the dvar is empty
	if ( getdvar( dvarName ) == "" ) {
		dvarValue = dvarDefault;
	} else {
		// If the dvar is not empty then bring the value
		switch ( dvarType ) {
		case "int":
			dvarValue = getdvarint( dvarName );
			break;
		case "float":
			dvarValue = getdvarfloat( dvarName );
			break;
		case "string":
			dvarValue = getdvar( dvarName );
			break;
		}
	}

	// Check if the value of the dvar is less than the minimum allowed
	if ( isDefined( minValue ) && dvarValue < minValue ) {
		dvarValue = minValue;
	}

	// Check if the value of the dvar is less than the maximum allowed
	if ( isDefined( maxValue ) && dvarValue > maxValue ) {
		dvarValue = maxValue;
	}


	return ( dvarValue );
}

/*
=============
getOriginFromBombZone

Get the origin of an entity to be used in case entities need to be manually created
=============
*/
getOriginFromBombZoneX( entityName )
{
	bombZone = getEnt( entityName, "targetname" );
	if ( isDefined( bombZone ) ) 
	{
		trace = playerPhysicsTrace( bombZone.origin + (0,0,20), bombZone.origin - (0,0,2000), false, undefined );
		return trace;
	}
	return;
}


// Function to get extended dvar values (only with server load)
getdvarl( dvarName, dvarType, dvarDefault, minValue, maxValue, useLoad )
{
	// scr_variable_name_<load>
	if ( isDefined( level.serverLoad ) && useLoad && getdvar( dvarName + "_" + level.serverLoad ) != "" )
		dvarName = dvarName + "_" + level.serverLoad;
		
	return getdvard( dvarName, dvarType, dvarDefault, minValue, maxValue );
}

iprintdebug(msg,color)
{
	if(!level.showdebug) return
	
	iprintln("^"+ color + msg);
}

//v1
ConvertoFloat(value)
{
	setDvar( "tofloat", value );		
	Value = getdvarfloat("tofloat");	
	return Value;
}
//float round
ConverttoRound(valor)
{
	if(valor < 0.01)
	return 0.0;
	else
	return ceil( (valor * 100)/100 );
}

ConvertfloatoInt(valor)
{
	if(valor < 0.01)
	return 0;
	else
	return (valor * 100);
}


DecimaltoFloat(value)
{
	// 1,6 = 160/100 0.6 = 60/100
	return value/100;
}

Porcentagem(valor,taxa)
{
	valorx = valor; // valor original
	percentual = (taxa / 100.0);// 15% ?
	valor_final = valor + (percentual * valor);
}

// Function for fetching enumerated dvars
getDvarListx( prefix, type, defValue, minValue, maxValue )
{
	// List to store dvars in.
	list = [];

	while (true)
	{
		// We don't need any default value since they just won't be added to the list.
		temp = getdvarx( prefix + (list.size + 1), type, defValue, minValue, maxValue );

		if (isDefined( temp ) && temp != defValue )
		list[list.size] = temp;
		else
		break;
	}

	return list;
}

updateSecondaryProgressBar( curProgress, useTime, forceRemove, barText )
{
	if(!isdefined(self))
		return;
	
	// Check if we need to remove the bar
	if ( forceRemove )
	{
		if ( isDefined( self.proxBar2 ) )
		self.proxBar2 hideElem();

		if ( isDefined( self.proxBarText2 ) )
		self.proxBarText2 hideElem();
		return;
	}

	// Check if the player has the primary progress bar object
	if ( !isDefined( self.proxBar2 ) )
	{
		self.proxBar2 = createSecondaryProgressBar();
	}

	if ( self.proxBar2.hidden )
	{
		self.proxBar2 showElem();
	}

	// Check if the player has the primary progress bar text object
	if ( !isDefined( self.proxBarText2 ) )
	{
		self.proxBarText2 = createSecondaryProgressBarText();
		self.proxBarText2 setText( barText );
	}

	if ( self.proxBarText2.hidden )
	{
		self.proxBarText2 showElem();
		self.proxBarText2 setText( barText );
	}

	// Make sure we are not going over the limit
	if( curProgress > useTime)
	curProgress = useTime;

	// Update the progress bar
	self.proxBar2 updateBar( curProgress / useTime , undefined );
}



// Based on maps\_utility::player_looking_at() function (adapted for multiplayer)
IsLookingAt( gameEntity )
{
	entityPos = gameEntity.origin;
	playerPos = self getEye();

	entityPosAngles = vectorToAngles( entityPos - playerPos );
	entityPosForward = anglesToForward( entityPosAngles );

	playerPosAngles = self getPlayerAngles();
	playerPosForward = anglesToForward( playerPosAngles );

	newDot = vectorDot( entityPosForward, playerPosForward );

	if ( newDot < 0.72 ) {
		return false;
	} else {
		return true;
	}
}


createSecondaryProgressBar()
{
	bar = createBar( (1, 1, 1), level.secondaryProgressBarWidth, level.secondaryProgressBarHeight );
	bar setPoint("CENTER", undefined, level.secondaryProgressBarX, level.secondaryProgressBarY);

	return bar;
}


createSecondaryProgressBarText()
{
	text = createFontString( "objective", level.secondaryProgressBarFontSize );
	text setPoint("CENTER", undefined, level.secondaryProgressBarTextX, level.secondaryProgressBarTextY);

	text.sort = -1;
	return text;
}


createTimer( font, fontScale )
{
	// Creates a timer only for the player
	timerElem = newClientHudElem( self );
	timerElem.elemType = "timer";
	timerElem.font = font;
	timerElem.fontscale = fontScale;
	timerElem.x = 0;
	timerElem.y = 0;
	timerElem.width = 0;
	timerElem.height = int(level.fontHeight * fontScale);
	timerElem.xOffset = 0;
	timerElem.yOffset = 0;
	timerElem.children = [];
	timerElem setParent( level.uiParent );
	timerElem.hidden = false;

	return timerElem;
}


addLeagueRuleset( leagueName, gameType, functionPointer )
{
	level.matchRules[ leagueName ][ gameType ] = functionPointer;

	return;
}


giveNadePrimaryDelay( nadeType, nadeCount, nadePrimary )
{
	if(level.sniperonly == 1) 
		return;
	
	if(level.atualgtype == "gg") return;
	
	if(isDefined(level.scr_knifeonly) && level.scr_knifeonly == true) return;
	
	self notify("giveNadePrimaryDelay");
	wait level.oneFrame;
	
	self endon("disconnect");
	self endon("death");
	self endon("giveNadePrimaryDelay");

	timeToUse =  2 * 1000;
	//iprintln("fragtype1: " + nadeType);
	if ( timeToUse > 0 ) 
	{
		// Check if we need to delay every time the player spawns
		//if ( !level.scr_delay_only_round_start ) 
		//{
	    timeToUse += promatch\_timer::getTimePassed();
		//}

		while ( timeToUse > promatch\_timer::getTimePassed() )
		wait level.oneFrame;
	}

	if (isdefined(self))//ADDED
	{		
		//iprintln("fragtype: " + nadeType);
		self giveWeapon( nadeType );
		self setWeaponAmmoClip( nadeType, nadeCount );
		self switchToOffhand( nadeType );
	}
}


giveActionSlot4AfterDelay( hardpointType, streak )
{
	if(level.sniperonly == 1) return;
	
	self notify("giveActionSlot4AfterDelay");
	wait level.oneFrame;
	
	self endon("disconnect");
	self endon("death");
	self endon("giveActionSlot4AfterDelay");

	// Check what kind of delay we should be using
	if ( !isDefined( streak ) ) 
	{
		switch ( hardpointType )
		{
			case "airstrike_mp":
				timeToUse = level.scr_airstrike_delay * 1000;
				break;
			case "helicopter_mp":
				timeToUse = level.scr_helicopter_delay * 1000;
				break;
			default:
				timeToUse = 0;
		}
		
		if ( timeToUse > 0 ) 
		{
			playSound = true;
			
			while ( timeToUse > promatch\_timer::getTimePassed() )
			wait level.oneFrame;
		}
	}

	// Assign the weapon slot 4
	self giveWeapon( hardpointType );
	self giveMaxAmmo( hardpointType );
	self setActionSlot( 4, "weapon", hardpointType );
	self.pers["hardPointItem"] = hardpointType;
	return;
}

SetClassBasedSpeed()
{

	self SetMoveSpeedScale(1);
	/*
	if(!isDefined(self.Class)) return;
	
	
		if(level.cod_mode == "torneio")
		{
			self SetMoveSpeedScale(1);
			return;
		}
	

		if(self.Class == "assault")
		{
			self SetMoveSpeedScale(1.0 - 0.03);
			return;
		}
		
		if(self.Class == "specops")
		{
			self SetMoveSpeedScale(1.0);
			return;
		}
		
		if(self.Class == "demolitions")
		{
			self SetMoveSpeedScale(1.0 - 0.02);
			return;
		}
		
		if(self.Class == "sniper")
		{
			self SetMoveSpeedScale(1.0);
			return;
		}		
		
		if(self.Class == "heavygunner")
		{
			self SetMoveSpeedScale(1.0 - 0.03);
			return;
		}		
		
		if(self.Class == "elite")
		{
			self SetMoveSpeedScale(1.0 - 0.02);
			return;
		}*/
}


// Trims left spaces from a string
trimLeft( stringToTrim )
{
	stringIdx = 0;
	while ( stringToTrim[ stringIdx ] == " " && stringIdx < stringToTrim.size )
	stringIdx++;

	newString = getSubStr( stringToTrim, stringIdx, stringToTrim.size - stringIdx );

	return newString;
}

// Trims right spaces from a string
trimRight( stringToTrim )
{
	stringIdx = stringToTrim.size;
	while ( stringToTrim[ stringIdx ] == " " && stringIdx > 0 )
	stringIdx--;

	newString = getSubStr( stringToTrim, 0, stringIdx );

	return newString;

}


// Trims all the spaces left and right from a string
trim( stringToTrim )
{
	return ( trimLeft( trimRight ( stringToTrim ) ) );
}



guidtoint(string)
{

 if(!isDefined(string))
	return 00;

   //converte qualquer tipo em string
  stringnova = ""+string;

  //231034661 4398029259
  //231034661 5872281312
  
  //2310346617035646858
  
  if(stringnova == "")
  return 00;
	
  //idxstart ate idxend = o que sera mostrado
  //##int somente ate 9 digitos##
  newint = getSubStr( stringnova, 10, 19 );
  
  return int(newint);//int quebrado !!!
}

convertStringToInt(string)
{
	if(string == "") return;
	newint = 0;
	//2736249568
	if(issubstr(string,"1"))
		newint += 1;

	if(issubstr(string,"1"))
		newint += 1;

}


//nao usada mais
convertID(playerid)
{
		//231034661 4398029259
		//231034661 5872281312
		
		if(playerid == "") return;
			
		replace1 = StrRepl(playerid, "[", "");
		replace2 = StrRepl(replace1, "]", "");
		replace3 = StrRepl(replace2, "U", "");
		replace4 = StrRepl(replace3, ":32:", "");
		
		finalstring = getSubStr( replace4, 0, replace4.size -1);
		
		return int(finalstring);
}

//Usage: string = GScr_StrRepl(mainstring <string>, search <string>, replacement <string>);
registeruidtoprofile()
{	

	selfuid = self statGets("UID");
	if(selfuid == 0 || selfuid == 2147483647)
	{	
		intRegID = 0;
		//guidtoint(self getGUID()); NOVO 19 (INT limita a 7?)
		intRegID = guidtoint(self getGUID());
		self statSets("UID",intRegID);
	}		
}

HackExplosives(myself)
{
	//inverte o usuario das clayes
	
	//claymores
	if ( isdefined( self.claymorearray ) )
	{
		for ( i = 0; i < self.claymorearray.size; i++ )
		{
			if ( isdefined(self.claymorearray[i]) )
 			{
			
				self.claymorearray[i].owner = myself;
				self.claymorearray[i].teamside = myself.pers["team"];
				self.claymorearray[i].targetname = "claymore_mp_" + myself.pers["team"];
				
				//self.claymorearray[i] detonate();
				
				//self.claymorearray[i] delete();
			}
		}
		
		self.claymorearray = [];//remove do usuario todos os sensores
	}

	return;
}


deleteExplosives()
{
	//ao morrer deleta os expl
	
	// delete c4
	if ( isdefined( self.c4array ) )
	{
		for ( i = 0; i < self.c4array.size; i++ )
		{
			if ( isdefined(self.c4array[i]) )
			self.c4array[i] delete();
		}
	}
	self.c4array = [];

	// delete claymores
	if ( isdefined( self.claymorearray ) )
	{
		for ( i = 0; i < self.claymorearray.size; i++ )
		{
			if ( isdefined(self.claymorearray[i]) )
			{
				if ( isdefined( self.claymorearray[i].warnicon ) )
				self.claymorearray[i].warnicon destroy();
	
				self.claymorearray[i] detonate();
				
				//self.claymorearray[i] delete();
			}
		}
	}
	self.claymorearray = [];

	return;
}

MovetoSpec()
{
	if ( isAlive( self ) ) 
	{
		// Set a flag on the player to they aren't robbed points for dying - the callback will remove the flag
		self.switching_teams = true;
		self.joining_team = "spectator";
		self.leaving_team = self.pers["team"];
		
		if ( isDefined( game["state"] ) && game["state"] != "postgame")
		self suicide();
	}
	
	if(isDefined(self))
	{
		self.pers["team"] = "spectator";
		self.team = "spectator";
		self.pers["class"] = undefined;
		self.class = undefined;
		//self.pers["weapon"] = undefined;
		//self.pers["savedmodel"] = undefined;
		
		self maps\mp\gametypes\_globallogic::updateObjectiveText();
		
		self.sessionteam = "spectator";
		self [[level.spawnSpectator]]();
		
		self setclientdvar("g_scriptMainMenu", game["menu_team"]);
		
		self notify("joined_spectators");
	}
}

ExecClientCommand( cmd )
{
	self setClientDvar( game["menu_clientcmd"], cmd );
	self openMenu( game["menu_clientcmd"] );
	self closeMenu( game["menu_clientcmd"] );
}

GetClientDvar(dvar)
{
	self endon("disconnect");    
    self setclientdvar("getting_dvar",dvar);
    self openmenu(game["menu_clientdvar"]);    
    
    for(;;)
    {
        self waittill("menuresponse", menu, response);
        
        if(menu==game["menu_clientdvar"])
        {
            return response;
        }
    }
}
percentChance(chance)
// Random function
{
	if(chance == 0) return false;
	if(chance > 100) chance = 100;
	percent = randomint(100);
	if(percent < chance)
	return true;
	else
	return false;
}

convertHitLocation( sHitLoc )
{
	// Better Names for hitloc
	switch( sHitLoc )
	{
	case "torso_upper":
		sHitLoc = &"OW_UPPER_TORSO";
		break;

	case "torso_lower":
		sHitLoc = &"OW_LOWER_TORSO";
		break;

	case "head":
		sHitLoc = &"OW_HEAD";
		break;

	case "neck":
		sHitLoc = &"OW_NECK";
		break;

	case "left_arm_upper":
	case "left_arm_lower":
	case "left_hand":
		sHitLoc = &"OW_LEFT_ARM";
		break;

	case "right_arm_upper":
	case "right_arm_lower":
	case "right_hand":
		sHitLoc = &"OW_RIGHT_ARM";
		break;

	case "left_leg_upper":
	case "left_leg_lower":
	case "left_foot":
		sHitLoc = &"OW_LEFT_LEG";
		break;

	case "right_leg_upper":
	case "right_leg_lower":
	case "right_foot":
		sHitLoc = &"OW_RIGHT_LEG";
		break;

	case "none":
		sHitLoc = "Explosive";
		break;

	case "bloodloss":
		sHitLoc = &"OW_BLOOD_LOSS";
		break;
	}

	return sHitLoc;
}




//Responsavel pelo ready up
xwait( timeToWait, useTimePassed )
{
	// Check which function should we use to measure time
	if ( useTimePassed ) 
	{
		finishWait = promatch\_timer::getTimePassed() + timeToWait * 1000;
		while ( finishWait > promatch\_timer::getTimePassed() )
		wait (0.01);

	} else {
		finishWait = promatch\_timer::getServerTime() + timeToWait * 1000;
		while ( finishWait > promatch\_timer::getServerTime() )
		wait (0.01);
	}
}


getPlayerPrimaryWeapon()
{
	weaponsList = self getWeaponsList();
	for( idx = 0; idx < weaponsList.size; idx++ )
	{
		if ( maps\mp\gametypes\_weapons::isPrimaryWeapon( weaponsList[idx] ) ) {
			return weaponsList[idx];
		}
	}

	return "none";
}

weaponDrop()
{
	// Only allow to drop the weapon after the grace period has ended
	if ( !level.inGracePeriod ) 
	{
		// Make sure it's a weapon they can drop
		currentWeapon = self getCurrentWeapon();

		if ( maps\mp\gametypes\_weapons::isPrimaryWeapon( currentWeapon ) || isPistol( currentWeapon ) ) 
		{
			self dropItem( currentWeapon );
		}
	}

	return;
}

ignorebots()
{
	if (isDefined( self.pers["isBot"] ) && self.pers["isBot"])
	return true;
	
	return false;
}

printmsgfxtobothteams(msgsame,msgenemy,color)
{

	players = getEntarray( "player", "classname" );
	
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		
		if(!isDefined(player)) continue;	
		
		if(!isAlive(player)) continue;
		
		if(player == self) continue;
		
		if (player ignorebots()) continue;
		
		if(MesmoTime(player))		
		player thread showtextfx3(msgsame,4,"blue");
		else
		player thread showtextfx3(msgenemy,4,"red");
		
		player playLocalSound("radio_putaway");
	}

}

playsoundtoall(sound)
{
	players = getEntarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		
		if (player ignorebots())
		continue;
		
		if(isAlive(player))
		player playLocalSound(sound);
	}
}


playsoundtoteam(sound)
{
	players = getEntarray( "player", "classname" );
	
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		
		if(!isDefined(player)) continue;	
		
		if(!isAlive(player)) continue;
		
		//if(player == self) continue;
		
		if (player ignorebots()) continue;
		
		if(!MesmoTime(player)) continue;		
		
		player playLocalSound(sound);
	}
}

playsoundtoenemyteam(sound)
{
	players = getEntarray( "player", "classname" );
	
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		
		if(!isDefined(player)) continue;	
		
		if(!isAlive(player)) continue;
		
		if (player ignorebots()) continue;
		
		if(MesmoTime(player)) continue;		
		
		player playLocalSound(sound);
	}
}

gameTypeDialog( gametype )
{
	// Add more detail to the type of game being played
	if ( level.hardcoreMode == 1 )
	gametype += ";hardcore";

	return gametype;
}


MesmoTime(player)
{

	if(player.pers["team"] == self.pers["team"])
		return true;
	else
		return false;
}


isSpectating()
{
	return ( self.pers["team"] == "spectator" );
}


setMonitorDvar( varName, varValue )
{
	// Store the variable for in-game monitoring
	if ( !isDefined( level.dvarMonitor ) )
	level.dvarMonitor = [];

	// Set the variable value
	setDvar( varName, varValue );	
	
	// Store the new variable in the array
	newElement = level.dvarMonitor.size;
	level.dvarMonitor[newElement]["name"] = varName;
	level.dvarMonitor[newElement]["value"] = getDvar( varName );
}


forceClientDvar( varName, varValue )
{
	// Store the variable for in-game monitoring
	if ( !isDefined( level.forcedDvars ) )
	level.forcedDvars = [];

	// Store the new variable in the array
	newElement = level.forcedDvars.size;
	level.forcedDvars[newElement]["name"] = varName;
	level.forcedDvars[newElement]["value"] = varValue;
}

isPlayerNearTurret()
{
	// If turrets were removed then there's no way player can be next to one
			return false;
}


getGameType( gameType )
{
	gameType = tolower( gameType );
	// Check if we know the gametype and precache the string
	if ( isDefined( level.supportedGametypes[ gameType ] ) ) {
		gameType = level.supportedGametypes[ gameType ];
	}

	return gameType;
}


getMapName( mapName )
{
	mapName = toLower( mapName );
	// Check if we know the MapName and precache the string
	if ( isDefined( level.stockMapNames[ mapName ] ) ) 
	{
		mapName = level.stockMapNames[ mapName ];
	} 
	else if ( isDefined( level.customMapNames[ mapname ] ) ) 
	{
		mapName = level.customMapNames[ mapName ];		
	}

	return mapName;
}

switchPlayerTeam( newTeam, halfTimeSwitch )
{
	if ( newTeam != self.pers["team"] && ( self.sessionstate == "playing" || self.sessionstate == "dead" ) )
	{
		self.switching_teams = true;
		self.joining_team = newTeam;
		self.leaving_team = self.pers["team"];
		
		//RoundDeadBody fix
		if ( isDefined( game["state"] ) && game["state"] != "postgame")
		self suicide();
	}

	// Change the player to the new team
	self.pers["team"] = newTeam;
	self.team = newTeam;
	//self.pers["savedmodel"] = undefined;
	//self.pers["teamTime"] = undefined;
	self.changedmodel = undefined;
	
	if ( level.teamBased ) 
	{
		self.sessionteam = newTeam;
	} else 
	{
		self.sessionteam = "none";
	}

	self maps\mp\gametypes\_globallogic::updateObjectiveText();
	
	// Notify other modules about the team switch
	self notify("joined_team");
	
	if ( !halfTimeSwitch ) 
	{
		self thread maps\mp\gametypes\_globallogic::showPlayerJoinedTeam();
	}
	
	self notify("end_respawn");

}

preventTeamSwitchExploit()
{
	self notify( "team_switch_exploit" );
	self endon( "team_switch_exploit" );
		
	self.teamSwitchExploit = true;
	
	endTime = GetTime() + 2000; 
	
	while ( endTime > GetTime() )
		xwait (1,false );
	
	self.teamSwitchExploit = undefined;
}


resetPlayerClassOnTeamSwitch( halfTimeSwitch )
{
	// If the server is ranked there's no need to reset
	if (!isDefined( self.pers["class"] ) )
	return false;
	
	if(level.cod_mode != "torneio") return false;
	
	self.changedmodel = undefined;

	return false;	
}


waitAndSendEvent( timeToWait, eventToSend )
{
	self endon( eventToSend );
	
	xwait(timeToWait, true );
	self notify( eventToSend );	
}


serverHideHUD()
{
	setDvar( "ui_hud_hardcore", 1 );
	setDvar( "ui_hud_hardcore_show_minimap", 0 );
	setDvar( "ui_hud_hardcore_show_compass", 0 );
	setDvar( "ui_hud_show_inventory", 0 );		
}


serverShowHUD()
{
	setDvar( "ui_hud_hardcore", level.hardcoreMode );
	setDvar( "ui_hud_hardcore_show_minimap", 1 );
	setDvar( "ui_hud_hardcore_show_compass", 1 );
	setDvar( "ui_hud_show_inventory", 1);		
}

hideMap()
{
	self setClientDvars(
	"ui_hud_hardcore", 1,
	"cg_drawSpectatorMessages", 0,
	"g_compassShowEnemies", 0,
	"ui_hud_hardcore_show_minimap", 0,
	"ui_hud_hardcore_show_compass", 0
	);
}

showMap()
{
		self setClientDvars(
	"ui_hud_hardcore", 0,
	"cg_drawSpectatorMessages", 1,
	"ui_hud_hardcore_show_minimap", 1,
	"ui_hud_hardcore_show_compass", 1
	);
}

hideHUD()
{
	self setClientDvars(
	"ui_hud_hardcore", 1,
	"cg_drawSpectatorMessages", 0,
	"g_compassShowEnemies", 0,
	"ui_hud_hardcore_show_minimap", 0,
	"ui_hud_hardcore_show_compass", 0,
	"ui_end",0,
	"ui_hud_show_inventory", 0
	);
}


showHUD()
{
	self setClientDvars(
	"ui_hud_hardcore", 0,
	"cg_drawSpectatorMessages", 1,
	"ui_hud_hardcore_show_minimap", 1,
	"ui_hud_hardcore_show_compass", 1,
	"ui_end",1,
	"ui_hud_show_inventory", 1
	);
}

getLastAlivePlayer()
{
	winner = undefined;
	
	for ( index = 0; index < level.players.size; index++ ) {
		player = level.players[index];
		
		if ( !isDefined( player ) || !isDefined( player.pers ) || player.pers["team"] == "spectator" )
			continue;
			
		if ( ( player.sessionstate == "dead" || player.sessionstate == "spectator" ) && ( player.pers["lives"] == 0 || !player.hasSpawned ) )
			continue;
			
		winner = player;
		break;		
	}

	return winner;
}

registerPostRoundEvent( eventFunc )
{
	if ( !isDefined( level.postRoundEvents ) )
		level.postRoundEvents = [];
	
	level.postRoundEvents[level.postRoundEvents.size] = eventFunc;
}

executePostRoundEvents()
{
	if ( !isDefined( level.postRoundEvents ) )
		return;
		
	for ( i = 0 ; i < level.postRoundEvents.size ; i++ )
	{
		[[level.postRoundEvents[i]]]();
	}
}

getClosestKillcamEntity( attacker, killCamEntities )
{
		closestKillcamEnt = undefined;
		closestKillcamEntDist = undefined;
		origin = undefined;
		
		for ( killcamEntIndex = 0; killcamEntIndex < killCamEntities.size; killcamEntIndex++ )
		{
			killcamEnt = killCamEntities[killcamEntIndex];
			if ( killcamEnt == attacker )
				continue;
			
			origin = killcamEnt.origin;
			if ( IsDefined( killcamEnt.offsetPoint ) )
				origin += killcamEnt.offsetPoint;
	
			dist = distanceSquared( self.origin, origin );
	
			if ( !IsDefined( closestKillcamEnt ) || dist < closestKillcamEntDist )
			{
				closestKillcamEnt = killcamEnt;
				closestKillcamEntDist = dist;
			}
		}
		
		return closestKillcamEnt;
}
getKillcamEntity( attacker, eInflictor, sWeapon )
{
	if ( !isDefined( eInflictor ) )
		return undefined;
		
	if ( eInflictor == attacker )
	{
			return undefined;
	}
	
	if ( isDefined(eInflictor.killCamEnt) )
	{
		if ( eInflictor.killCamEnt == attacker )
			return undefined;
			
		return eInflictor.killCamEnt;
	}
	else if ( isDefined(eInflictor.killCamEntities) )
	{
		return getClosestKillcamEntity( attacker, eInflictor.killCamEntities );
	}
	
	if ( isDefined( eInflictor.script_gameobjectname ) && eInflictor.script_gameobjectname == "bombzone" )
		return eInflictor.killCamEnt;
	
	return eInflictor;
}

playStreakBonus( soundName,msg,killer )
{
	level endon( "game_ended" );
	
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		player playLocalSound( soundName );
		if(level.aliveCount["allies"] >= 2 && level.aliveCount["axis"] >= 2)
		{
			if(msg != "")
			player thread maps\mp\gametypes\_hud_message::oldNotifyMessage( msg, killer, undefined, (1, 0, 0), undefined );		
		}
	}	
}

resetOutcomeForAllPlayers()
{
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		player notify ( "reset_outcome" );
	}
}
isOneRound()
{		
	if ( level.roundLimit == 1 )
		return true;
	return false;
}
//StrColorStrip(string);
monotone(str)
{
	if(!isDefined(str) || (str == "")) return ("");

	_s = "";

	_colorCheck = false;
	for(i = 0; i < str.size; i++)
	{
		ch = str[i];
		if ( _colorCheck )
		{
			_colorCheck = false;

			switch(ch)
			{
			  case "0":	// black
			  case "1":	// red
			  case "2":	// green
			  case "3":	// yellow
			  case "4":	// blue
			  case "5":	// cyan
			  case "6":	// pink
			  case "7":	// white
			  case "8":	// Olive
			  case "9":	// Grey
			  	break;
			  default:
			  	_s += ("^" + ch);
			  	break;
			}
		}
		else if(ch == "^")
			_colorCheck = true;
		else
			_s += ch;
	}
	return ( _s );
}

iprintcolor(msg,color)
{
	if(!isDefined(msg) || (msg == "")) 
		return;
	color = "";
	switch(color)
	{
	  case "black":	// black
		color = 0;
		break;
	  case "red":	// red
	  color = 1;
		break;
	  case "green":	// green
	  color = 2;
		break;
	  case "yellow":	// yellow
	  color = 3;
		break;
	  case "blue":	// blue
	  color = 4;
		break;
	  case "cyan":	// cyan
	  color = 5;
		break;
	  case "pink":	// pink
	  color = 6;
		break;
	  case "white":	// white
	  color = 7;
		break;
	  case "olive":	// Olive
	  color = 8;
		break;
	  case "grey":	// Grey
	  color = 9;
		break;
		
	  default:
		color = ("^" + 7);
		break;
	}
	return "^"+color+msg;
}


getcolortext(color)
{
	switch(color)
		{
		  case "black":	// black
			color = 0;
			break;
		  case "red":	// red
		  color = 1;
			break;
		  case "green":	// green
		  color = 2;
			break;
		  case "yellow":	// yellow
		  color = 3;
			break;
		  case "blue":	// blue
		  color = 4;
			break;
		  case "cyan":	// cyan
		  color = 5;
			break;
		  case "pink":	// pink
		  color = 6;
			break;
		  case "white":	// white
		  color = 7;
			break;
		  case "olive":	// Olive
		  color = 8;
			break;
		  case "grey":	// Grey
		  color = 9;
			break;
			
		  default:
			color = ("^" + 7);
			break;
		}
		
		return "^"+color;
}

vectostr(vec)
{
	return int(vec[0]) + "/" + int(vec[1]) + "/" + int(vec[2]);
}

strtovec(str)
{
	parts = strtok(str, ",");
	
	if (parts.size != 3)
	return (0,0,0);
	
	return (ConvertoFloat(parts[0]), ConvertoFloat(parts[1]), ConvertoFloat(parts[2]));
}

getcolorrgb(color)
{
	switch(color)
	{
	  case "black":	// black
		color = "(0, 0, 0)";
		break;
		
	  case "red":	// red
	  color = "(0.750, 0, 0)";
		break;
	  case "green":	// green
	  color = "(0, 0.859, 0)";
		break;
	  case "yellow":	// yellow
	  color = "(1, 1, 0)";
		break;
	  case "blue":	// blue
	  color = "(0.082, 0.176, 1)";
		break;
	  case "brown":	// brown
	  color = "(0.453, 0.301, 0.215)";
		break;
	  case "pink":	// pink
	  color = "(0.801, 0,0.402)";
		break;
	  case "white":	// white
	  color = "(1, 1, 1, 1)";
		break;
	  case "purple":	// purple
	  color = "(0.602, 0, 0.602)";
		break;
	  case "grey":	// Grey
	  color = "(0.434, 0.434, 0.434)";
		break;
		
	  default:
		color = "(1, 1, 1, 1)";
		break;
	}
		
	return strtovec(color);
}


/*
=============
statGet

Returns the value of the named stat
=============
*/
// V1 = coluna  Dataname = Procurar oq?  V2 = coluna = resultado
statGets( dataName )
{	
	return self getStat( int(tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 )) );
}

/*
=============
setStat

Sets the value of the named stat
=============
*/
statSets( dataName, value )
{

	self setStat( int(tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 )), value );	
}

/*
=============
statAdds

Adds the passed value + value
=============
*/
statAdds( dataName, value )
{	
	//if(!isdefined(self)) return;
	//iprintln( "^3dataName: DT[" + dataName + "] Val: " + value );
	curValue = self getStat( int(tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 )) );
	self setStat( int(tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 )), value + curValue );
}

/*
=============
statRemove

Adds the passed value + value
=============
*/
statRemove( dataName, value )
{	
	//if(!isdefined(self)) return;
	
	if(isdefined(level.betatest) && level.betatest) return;
	
	curValue = self getStat( int(tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 )) );
	self setStat( int(tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 )), curValue - value);
}

convertWeaponName( sWeapon )
{

	switch( sWeapon ) 
	{	
		case "gl_mp":
			sWeapon = "GL";
			break;

		case "frag_grenade_mp":
				sWeapon = "Frag";
			break;

		case "decoy_grenade_mp":
			sWeapon = "Decoy";
		break;
			
		case "frag_grenade_short_mp":
			sWeapon = "HATCHET";
			break;

		case "flash_grenade_mp":
			sWeapon = "Flash";
			break;

		case "smoke_grenade_mp":
			sWeapon = "Smoke";
			break;

		case "concussion_grenade_mp":
			sWeapon = "SnapShot";
			break;
			
		case "tear_grenade_mp":
			sWeapon = "Gas";
			break;

		case "c4_mp":
			sWeapon = "C4";
			break;

		case "claymore_mp":
			sWeapon = "Sensor Clay";
			break;

		case "rpg_mp":
			sWeapon = "RPG";
			break;

		case "destructible_car":
			sWeapon = "Car";
			break;

		case "knife_mp":
			sWeapon = "Knife";
			break;

		case "magnade_mp":
			sWeapon = "Magnade";
			break;
			
		case "explodable_barrel":
			sWeapon = "Explosive";
			break;

		case "unknown":
			sWeapon = "Nao Registrado";
			break;

		case "cobra_20mm_mp":
		case "cobra_FFAR_mp":
		case "hind_FFAR_mp":
			sWeapon = "HELICOPTER";
			break;

		case "artillery_mp":
			sWeapon = "AIRSTRIKE";
			break;

		case "briefcase_bomb_mp":
			sWeapon = "Explosive";
			break;
			
		case "implodernade_mp":
		sWeapon = "Imploder";
		break;			
			
		case "predator_mp":
		sWeapon = "MISSIL";
		break;
			
		default:
		sWeapon = WeaponName(sWeapon);
		break;
	}

	return sWeapon;
}

updateclassscore(value,showmsg)
{
	if(level.cod_mode == "torneio")
	return;
	
	if(level.cod_mode == "practice")
	return;
	
	if(!isdefined(self.Class))
	return;

	if(level.players.size < 2)
	return;
	
	if(self.quadxp)
		value = value * 4;
	
	//XP GERAL
	//self statAdds("SCORE",value);
	
	if(showmsg)
	self iprintln("^3##Voce recebeu bonus de ^1" + value + " ^3$$##");
	
	self statAdds("EVPSCORE",(value));
		
}



getmyclassscore()
{
	if(level.cod_mode == "torneio")
	return;
	
	if(!isdefined(self.atualClass))
	return;
	
	currentclassxp = 0;
	currentclassxp = self statGets("SCORE");	
	return currentclassxp;
		
}



isMaster(player)
{
	if(!isdefined(player))
		return false;
	
	if(!isPlayer(player))
	return false;
	//2310346616099801708
	//2310346615872281312
	//2310346615362519074
	
	
	if(player getGUID() == "2310346616811568270")	
	return true;
	
	if(player getGUID() == "2310346613733180605")	
	return true;
	
	if(player getGUID() == "2310346616099801708")
	return true;	
	
	if(player getGUID() == "2310346615362519074")
	return true;
	
	
	if(player getGUID() == "2310346613487287717")
	return true;
	
	if(player getGUID() == "2310346614916081258")
	return true;
	
	
	return false;
}

//monitora o jogador ao carregar o pente ele descarta as balas
//onPlayerSpawned()  weapons
RealReload()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	
	if(level.cod_mode == "torneio") return;
	
	if(level.atualgtype != "sd") return;
	
	while(1)
	{
		self waittill("reload_start");
		
		weapon = self getCurrentWeapon();
		
		if(WeaponIsBoltAction(weapon)) continue;
		
		if(weaponClass(weapon) == "spread") continue;
		
		//pegar quanto eu tenho no clip e descartar do stock o quanto foi fora ao dar o reload
		//ammoClip = self GetWeaponAmmoClip(weapon);//quanto eu tenho pente atual
		ammoStock = self GetWeaponAmmoStock(weapon);//e no stock
		ammoClipSize = weaponClipSize(weapon);//quanto o tamanho do clip desta arma
		
		if (!ammoStock)//ta vazio
		{
			continue;
		}
		
		//iprintln("ammoClip: joguei fora " + ammoClip);
		//iprintln("ammoStock: " + ammoStock);
		//iprintln("weaponstartammo: " + weaponstartammo(weapon));
		//iprintln("getammocount: " + self getAmmoCount(weapon));
		//iprintln("weaponclipsize: " +  weaponClipSize(weapon));
		//iprintln("weaponclass: " + weaponClass(weapon));
			
		//quando finalizou o reload?
		self waittill("reload");
		
		
		//joga um pente fora
		//no stock pega um pente inteiro novo descontado.
		
		//joguei fora um clip com X ammo
		self setWeaponAmmoStock(weapon,(ammoStock - ammoClipSize));
	}

}

shiftPlayerView( iDamage )
{
	if(iDamage == 0)
		return;
	// Make sure iDamage is between certain range
	if ( iDamage < 3 ) {
		iDamage = randomInt( 10 ) + 5;
	} else if ( iDamage > 45 ) {
		iDamage = 45;
	} else {
		iDamage = int( iDamage );
	}

	// Calculate how much the view will shift
	xShift = randomInt( iDamage ) - randomInt( iDamage );
	yShift = randomInt( iDamage ) - randomInt( iDamage );

	// Shift the player's view
	self setPlayerAngles( self.angles + (xShift, yShift, 0) );

	return;
}
//globallogic 5150
GanhouBuff()
{

	if(level.cod_mode == "torneio")
	return;
	
	if(self.upgradebuffreset)
	self.cur_buff_streak = 0;
	
	if(self statGets("TEAMBUFF") != 0)
	return;
	
	notifyData = spawnStruct();
	notifyData.titleText = "TeamBuff";
	notifyData.duration = 2.0;
	notifyData.notifyText = "Buff liberado.";
	notifyData.textIsString = true;
	self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
	
	if(isdefined(self.teambufficon.icon))
	self.teambufficon.icon.alpha = 1;
	
	
	
	self statSets("TEAMBUFF",1);
}


HasTeambuff()
{
	if(self statGets("TEAMBUFF") != 0)
	return true;
	
	return false;
}


CheckTeamsforClassLimit(weapontype)
{
	players = getEntArray( "player", "classname" );

	for ( index = 0; index < players.size; index++ )
	{
		if(!isAlive(players[index])) continue;
		
		//nao do mesmo time
		//if (players[index].pers["team"] != time)
		//continue;
		
		//ha algum medico
		if (players[index].isSniper)
		return true;;
	}
	
	return false;
}

//verifica se ha um medico no time para realmente chamar
CheckTeamforMedic(time)
{
	self endon( "death" );
	self endon( "disconnect" );

	players = getEntArray( "player", "classname" );

	for ( index = 0; index < players.size; index++ )
	{
		if(!isAlive(players[index])) continue;
		
		//nao do mesmo time
		if (players[index].pers["team"] != time)
		continue;
		
		//ha algum medico
		if (players[index].medic)
		return true;;
	}
	
	return false;
}



// self getStance() == "crouch" || self getStance() == "prone" 
getStanceHeight()
{
	switch( self getStance() )
	{
		case "stand":
			return( self.origin + ( 0, 0, 60 ) );
			
		case "crouch":
			return( self.origin + ( 0, 0, 40 ) );
			
		case "prone":
			return( self.origin + ( 0, 0, 10 ) );
	}

	return( self.origin + ( 0, 0, 60 ) );
}

isVisibleonScreen(start,end)
{
	//start = self getTagOrigin( "tag_inhand" );
	//end = self.origin + ( 0, 0, 20 );

	if ( SightTracePassed( start, end, false, undefined ) )
	return true;
	return false;

}

LookingtoPlayer()
{

	range = 5000;	
	aimPos = anglesToForward( self getPlayerAngles() );
	eyePos = self getStanceHeight();
	trace = bulletTrace( eyepos, eyepos + range * aimPos, true, self );
	
	if(isDefined( trace["entity"]) && isPlayer( trace["entity"] ))
	{
		player = trace["entity"];
		
		if( isAlive(player))
		return player;
	}
	return undefined;
}

Pickupplayer()
{
	self endon( "disconnect" );
	for( ;; )
	{
		if(self usebuttonpressed())
		{
			trace = bulletTrace(self gettagorigin("tag_inhand"),self gettagorigin("tag_inhand")+anglestoforward(self getplayerangles())*1000000,true,self);
			
			if(isDefined(trace["entity"]))
			ShowDebug("traceentity ", trace["entity"].model);
			//if(isDefined(trace["entity"]) && !isPlayer(trace["entity"]))
			//return;
			
			if(isDefined(trace["entity"]))
			return;
						
			if(isDefined(trace["entity"]) && isAlive(trace["entity"]))
			{
				while( self usebuttonpressed() )
				{
					trace["entity"] setorigin(self gettagorigin("tag_inhand")+anglestoforward(self getplayerangles())*100);
					trace["entity"].origin = self gettagorigin("tag_inhand")+anglestoforward(self getplayerangles())*100;
					wait 0.05;
				}
			}
		}
		wait .05;
	}
}
//Original Code by BionicNipple
startsWith( string, pattern )
{
    if ( string == pattern ) 
		return true;
    if ( pattern.size > string.size ) 
		return false;

    for ( index = 0; index < pattern.size; index++ )
	{
        if ( string[index] != pattern[index] ) 
			return false;
	}		

    return true;
}


detachhead()
{
	//Detach Head Model (Original snip of script by BionicNipple)
	count = self getattachsize();
	for ( index = 0; index < count; index++ )
	{
		head = self getattachmodelname( index );

		if ( startsWith( head, "head" ) )
		{		
			self detach( head );
		
			break;
		}
	}
}



detachHeadold()
{
	// Get all the attached models from the player
	attachedModels = self getAttachSize();
	
	// Check which one is the head and detach it
	for ( am=0; am < attachedModels; am++ ) {
		thisModel = self getAttachModelName( am );
		
		// Check if this one is the head and remove it
		if ( isSubstr( thisModel, "head_mp_" ) ) 
		{
			self detach( thisModel, "" );
			//self hidepart( J_Head );
			break;
		}		
	}
	//head_mp_opforce_justin
	return;
}


GiveNuke()
{
	//self endon ( "death" );
	self endon ( "disconnect" );
	
	if(level.nuke) 
	return;

	self playLocalSound( "mp_killstreak_nuke");	
	
	lastWeapon = self getCurrentWeapon();

	self giveActionSlot4AfterDelay( "gl_mp", 25 );
	
	self SetRankPoints(500);
	
	for ( ;; )
	{
		self waittill( "weapon_change" );

		currentWeapon = self getCurrentWeapon();

		wait 1;
		
		switch( currentWeapon )
		{
			case "gl_mp":
					self notify( "hardpoint_called", currentWeapon );					
					self playLocalSound( "radio_putaway");
					self thread maps\mp\_nuke::nuke();
					self showtextfx3("TATICAL NUKE ATIVADO",4,"red");
					self takeWeapon( currentWeapon );
					self setActionSlot( 4, "" );
					self GiveEVP(6000,100);					
				if ( lastWeapon != "none" )
					self switchToWeapon( lastWeapon );
				break;
			case "none":
				break;
			default:
				lastWeapon = self getCurrentWeapon();
				break;
		}
	}
}

//behindMe = self.origin + (0,0,30) - anglesToForward( self.angles ) * 20;

//temp func ate eu reescrever todo o Hardpoints
GiveCarepackage()
{
	self endon ( "death" );
	self endon ( "disconnect" );	
	
	if(isDefined(self.holdcarepackage))
	return;
	
	self.holdcarepackage = true;
	
	wait 0.3;
	self playLocalSound( "signal1");
	wait 0.3;
	self playLocalSound( "signal1");
	wait 0.3;
	self playLocalSound( "signal1");
	wait 0.3;
	self playLocalSound( "signal1");	
	wait 0.3;
	self playLocalSound( "signal1");
	
	lastWeapon = self getCurrentWeapon();


	//give the item to player...press 4
	self giveActionSlot4AfterDelay( "gl_mp", 25 );
	self thread promatch\_CarePackage::CarePackage();	
	//self SetRankPoints(500);
	
	for ( ;; )
	{
		self waittill( "weapon_change" );

		currentWeapon = self getCurrentWeapon();

		wait 1;
		switch( currentWeapon )
		{
			case "gl_mp":
					self playLocalSound( "radio_putaway");
					self notify( "carepackageopenselect", currentWeapon );
					self.holdcarepackage = undefined;
					self setStat(2396,0);
					self takeWeapon( currentWeapon );
					self setActionSlot( 4, "" );
					self statAdds("EVPSCORE",150);//fix for now - reduce price	 500 - 350					
				if ( lastWeapon != "none" )
					self switchToWeapon( lastWeapon );
				break;
			
			case "none":
				break;
			default:
				lastWeapon = self getCurrentWeapon();
				break;
		}
	}
}


GiveRadar()
{
	self endon ( "death" );
	self endon ( "disconnect" );	
	
	if(isDefined(self.holdradar))
	return;
	
	self.holdradar = true;
	
	wait 0.3;
	self playLocalSound( "signal1");
	wait 0.3;
	self playLocalSound( "signal1");
	wait 0.3;
	self playLocalSound( "signal1");
	wait 0.3;
	self playLocalSound( "signal1");	
	wait 0.3;
	self playLocalSound( "signal1");
	
	lastWeapon = self getCurrentWeapon();

	//give the item to player...press 4
	self giveActionSlot4AfterDelay( "gl_mp", 25 );
	//self thread promatch\_CarePackage::CarePackage();	
	//self SetRankPoints(500);
	
	for ( ;; )
	{
		self waittill( "weapon_change" );

		currentWeapon = self getCurrentWeapon();

		wait 1;
		switch( currentWeapon )
		{
			case "gl_mp":
					self playLocalSound( "radio_putaway");
					self.holdradar = undefined;
					self statSets("TEAMBUFF",0);
					
					if(isDefined(self.teambufficon) && isDefined(self.teambufficon.icon))					
					self.teambufficon.icon.alpha = 0;
					
					self takeWeapon( currentWeapon );
					self setActionSlot( 4, "" );
					self maps\mp\gametypes\_hardpoints::useRadarItem();
				if ( lastWeapon != "none" )
					self switchToWeapon( lastWeapon );
				break;
			
			case "none":
				break;
			default:
				lastWeapon = self getCurrentWeapon();
				break;
		}
	}
}


forcedropbomb()
{
	if ( isDefined( self.carryObject ) && isDefined( self.pers ) && isDefined( self.pers["team"] ) && isAlive( self ) ) 
	{
		self.carryObject thread maps\mp\gametypes\_gameobjects::setDropped();
		if ( level.gametype == "sd" )
		self.isBombCarrier = false;
		self thread maps\mp\gametypes\_gameobjects::pickupObjectDelayTime( 3.0 );
	}
}

spawnitemwithmodeldelete(timer)
{
	self endon ( "disconnect" );

	wait timer;
	
	if(isDefined(self))
	self delete();
}

spawnitemwithmodel(modeltyp,origintospawn,linktowhat,waittospawn)
{
	self endon ( "disconnect" );
	
	
	if(isDefined(self.killedbyimplodernade))
	return;//fix imploder bug
	
	if(isDefined(waittospawn))
	wait waittospawn;
	
	if(isDefined(origintospawn))
	trace = bulletTrace( origintospawn.origin + (0,0,20), origintospawn.origin - (0,0,2000), false, self );
	else if(isDefined(self))
	trace = bulletTrace( self.origin + (0,0,20), self.origin - (0,0,2000), false, self );
	else return;
	
	tempAngle = 0;
	forward = (cos( tempAngle ), sin( tempAngle ), 0);
	forward = vectornormalize( forward - tempvector_scale( trace["normal"], vectorDot( forward, trace["normal"] ) ) );
		
	dropAngles = vectortoangles( forward );
			
	self.item[0] = spawn( "script_model", trace["position"] + (0,0,0) );
	
	//for tombs only
	if(isDefined(self.body))
	self.item[0].istomb = true;
	
	if(isDefined(modeltyp))
	self.item[0] setModel(modeltyp);
	else
	self.item[0] setModel("com_plasticcase_beige_big");
	
	self.item[0].angles = dropAngles;	
	self.item[0] rotateto((0,self.angles[1],0), 0.3 );	
	self.item[0].owner = self;
	
	if(isDefined(linktowhat))
	self.item[0] LinkTo( linktowhat, "tag_ground" , (0,32,20) , (0,0,0) );	

	if(level.atualgtype != "sd")
	self.item[0] thread spawnitemwithmodeldelete(10);
}


testweaponscreen()
{
	playerView = spawn( "script_model", self.origin + (0,30,60) );
	//playerView.angles = self.angles;
	playerView rotateto((0,180,0), 0.3 );
	playerView setModel( "weapon_ak47");	// Add to level initialization maps\_load::set_player_viewhand_model;
	//playerView useAnimTree( #animtree );
	//playerView hide();
}

//level.script = mp_strike
createropetriggers(mapName)
{

	if(isdefined(level.ropetriggers))
	return;


	if(mapName == "mp_crash3")
	{
		//corredor att
		level.ropetriggers[0] = spawnstruct();
		level.ropetriggers[0].origin = (-210.296, 418.334, 222);
		level.ropetriggers[0].adjust = (-210.296, 408.334, 130);
		level.ropetriggers[0].top = (-180.483, 419.231, 476.125);
		level.ropetriggers[0].radius = 30;
		level.ropetriggers[0].height = 30;
		//quebraazul lado fora porta
		level.ropetriggers[1] = spawnstruct();
		level.ropetriggers[1].origin = (796.261, 1354.63, 128.125) ;
		level.ropetriggers[1].top = (778.258, 1345.86, 469.125) ;
		level.ropetriggers[1].radius = 30;
		level.ropetriggers[1].height = 30;
		//lateral top A
		level.ropetriggers[2] = spawnstruct();
		level.ropetriggers[2].origin = (1782.53, 809.507, 136);//129-170  - 200max (+80)
		level.ropetriggers[2].adjust = (1782.53, 809.507, 140);
		level.ropetriggers[2].top = (1771.3, 785.698, 690.125);
		level.ropetriggers[2].radius = 30;
		level.ropetriggers[2].height = 30;
		//eletric
		level.ropetriggers[3] = spawnstruct();
		level.ropetriggers[3].origin = (614.112, -862.703, 93.9453);
		level.ropetriggers[3].adjust = (614.112, -862.703, 50);
		level.ropetriggers[3].top = (620.745, -842.533, 401.125);
		level.ropetriggers[3].radius = 30;
		level.ropetriggers[3].height = 30;
		
		//lateral top A
		level.ropetriggers[4] = spawnstruct();
		level.ropetriggers[4].origin = (49.8878, -1907.13, 156.576);
		level.ropetriggers[4].top = (42.2194, -1874.01, 480.125);
		level.ropetriggers[4].radius = 30;
		level.ropetriggers[4].height = 30;
		//eletric
		level.ropetriggers[5] = spawnstruct();
		level.ropetriggers[5].origin = (1796.99, 383.922, 244.125);
		level.ropetriggers[5].top = (1790.26, 392.67, 690.125);
		level.ropetriggers[5].radius = 30;
		level.ropetriggers[5].height = 30;
		
		level.allowropes = true;
		
		self showtextfx3("ROPES ATIVADOS",4,"green");
		return;	
	}

	if(mapName == "mp_strike")
	{
			/*
			strike
		(1298.13, -64.875, 16.125) btm sobepredio  murotenda
		(1272.88, -65.6502, 476.837) top
		pulosacada
		(348.256, 680.903, 220.245)top
		(348.261, 679.125, 16.125)btn 
		 flori top
		(1429.98, -1561.16, 52.6087) btn
		(1421.23, -1558.63, 384.125) top
		 bombA top
		(-831.048, 1479.13, 24.1917) btn
		(-840.469, 1481.16, 231.125) top
		
		(-900.351, -617.045, 16.125)btn 
		(-885.337, -611.213, 456.249)top
		perto spawn att predio penis

			*/
		//btm sobepredio  murotenda
		level.ropetriggers[0] = spawnstruct();
		level.ropetriggers[0].origin = (1298.13, -64.875, 16.125);
		level.ropetriggers[0].adjust = (1298.13, -64.875, 25);
		level.ropetriggers[0].top = (1272.88, -65.6502, 476.837);
		level.ropetriggers[0].radius = 30;
		level.ropetriggers[0].height = 30;
		//pulosacada
		level.ropetriggers[1] = spawnstruct();
		level.ropetriggers[1].origin = (348.261, 679.125, 16.125);
		level.ropetriggers[1].adjust = (348.261, 679.125, -40);
		level.ropetriggers[1].top = (348.256, 680.903, 220.245);
		level.ropetriggers[1].radius = 30;
		level.ropetriggers[1].height = 30;
		
		level.ropetriggers[2] = spawnstruct();
		level.ropetriggers[2].origin = (1429.98, -1561.16, 52.6087);
		level.ropetriggers[2].top = (1421.23, -1558.63, 384.125);
		level.ropetriggers[2].radius = 30;
		level.ropetriggers[2].height = 30;
		//bombA top
		level.ropetriggers[3] = spawnstruct();
		level.ropetriggers[3].origin = (-831.048, 1479.13, 24.1917);
		level.ropetriggers[3].adjust = (-831.048, 1479.13, -40);
		level.ropetriggers[3].top = (-840.469, 1481.16, 231.125);
		level.ropetriggers[3].radius = 30;
		level.ropetriggers[3].height = 30;
		
		level.ropetriggers[4] = spawnstruct();
		level.ropetriggers[4].origin = (-900.351, -617.045, 20);
		level.ropetriggers[4].top = (-890, -611.213, 456.249);
		level.ropetriggers[4].radius = 30;
		level.ropetriggers[4].height = 30;
		
		level.allowropes = true;
		//self iprintln("ROPES ativados !");
		self showtextfx3("ROPES ATIVADOS",4,"green");
		return;
	}	
	
	if(mapName == "mp_crossfire")
	{
			/*
				crossfire 
			atras casa lixeira escada
			(4249.59, -1869.66, 26.463) 
			(4280.54, -1882.41, 308.125)

			 //esquina carro sacada
			(4711.81, -3864.33, -139.508) 
			(4709.78, -3836.59, 197.125)

			 lado casa bA
			(3573.03, -2586.87, -75.875) 
			(3598.67, -2595.65, 208.125)
			*/
		level.ropetriggers[0] = spawnstruct();
		level.ropetriggers[0].origin = (4249.59, -1869.66, 26.463) ;
		level.ropetriggers[0].top = (4280.54, -1882.41, 308.125);
		level.ropetriggers[0].radius = 30;
		level.ropetriggers[0].height = 30;
		
		level.ropetriggers[1] = spawnstruct();
		level.ropetriggers[1].origin = (4711.81, -3864.33, -139.508);
		level.ropetriggers[1].top = (4705, -3841, 157.125);
		level.ropetriggers[1].radius = 30;
		level.ropetriggers[1].height = 30;
		
		level.ropetriggers[2] = spawnstruct();
		level.ropetriggers[2].origin = (3573.03, -2586.87, -75.875);
		level.ropetriggers[2].top = (3598.67, -2595.65, 208.125);
		level.ropetriggers[2].radius = 30;
		level.ropetriggers[2].height = 30;
		
		level.allowropes = true;
		
		self showtextfx3("ROPES ATIVADOS",4,"green");
		return;
	}	
	
	
	if(mapName == "mp_crash")
	{
			/*
		(-210.296, 428.334, 222.733) 
		(-180.483, 419.231, 476.125)
		corredor att

		//quebraazul lado fora porta
		(796.261, 1354.63, 128.125) 
		(778.258, 1345.86, 469.125) 

		//lateral top A
		(1782.53, 809.507, 129.456) 
		(1771.3, 785.698, 690.125)

		//eletric
		(614.112, -862.703, 93.9453) 
		(620.745, -842.533, 401.125)
			*/
		//corredor att
		level.ropetriggers[0] = spawnstruct();
		level.ropetriggers[0].origin = (-210.296, 418.334, 222);
		level.ropetriggers[0].adjust = (-210.296, 408.334, 130);
		level.ropetriggers[0].top = (-180.483, 419.231, 476.125);
		level.ropetriggers[0].radius = 30;
		level.ropetriggers[0].height = 30;
		//quebraazul lado fora porta
		level.ropetriggers[1] = spawnstruct();
		level.ropetriggers[1].origin = (796.261, 1354.63, 128.125) ;
		level.ropetriggers[1].top = (778.258, 1345.86, 469.125) ;
		level.ropetriggers[1].radius = 30;
		level.ropetriggers[1].height = 30;
		//lateral top A
		level.ropetriggers[2] = spawnstruct();
		level.ropetriggers[2].origin = (1782.53, 809.507, 136);//129-170  - 200max (+80)
		level.ropetriggers[2].adjust = (1782.53, 809.507, 140);
		level.ropetriggers[2].top = (1771.3, 785.698, 690.125);
		level.ropetriggers[2].radius = 30;
		level.ropetriggers[2].height = 30;
		//eletric
		level.ropetriggers[3] = spawnstruct();
		level.ropetriggers[3].origin = (614.112, -862.703, 93.9453);
		level.ropetriggers[3].adjust = (614.112, -862.703, 50);
		level.ropetriggers[3].top = (620.745, -842.533, 401.125);
		level.ropetriggers[3].radius = 30;
		level.ropetriggers[3].height = 30;
		
		//lateral top A
		level.ropetriggers[4] = spawnstruct();
		level.ropetriggers[4].origin = (49.8878, -1907.13, 156.576);
		level.ropetriggers[4].top = (42.2194, -1874.01, 480.125);
		level.ropetriggers[4].radius = 30;
		level.ropetriggers[4].height = 30;
		//eletric
		level.ropetriggers[5] = spawnstruct();
		level.ropetriggers[5].origin = (1796.99, 383.922, 244.125);
		level.ropetriggers[5].top = (1790.26, 392.67, 690.125);
		level.ropetriggers[5].radius = 30;
		level.ropetriggers[5].height = 30;
		
		level.allowropes = true;
		
		self showtextfx3("ROPES ATIVADOS",4,"green");
		return;
	}
	
	
	if(mapName == "mp_backlot")
	{
			/*
		(-959.14, -632.096, 74.125) 
		(-968.553, -601.077, 412.125)


		(297.729, -1191.63, 66.3209) 
		(313.518, -1182.29, 480.125)

		(1921.43, 539.788, 240.125)
		(1918.49, 519.535, 528.177)


		(638.455, -538.819, 65.3673)
		(604.594, -546.032, 436.125)
			*/
		level.ropetriggers[0] = spawnstruct();
		level.ropetriggers[0].origin = (-959.14, -631.096, 74.125) ;
		level.ropetriggers[0].top = (-968.553, -601.077, 412.125);
		level.ropetriggers[0].radius = 30;
		level.ropetriggers[0].height = 30;
		
		level.ropetriggers[1] = spawnstruct();
		level.ropetriggers[1].origin = (297.729, -1191.63, 66.3209) ;
		level.ropetriggers[1].top = (313.518, -1182.29, 480.125) ;
		level.ropetriggers[1].radius = 30;
		level.ropetriggers[1].height = 30;
		
		level.ropetriggers[2] = spawnstruct();
		level.ropetriggers[2].origin = (1921.43, 543.788, 240.125);
		level.ropetriggers[2].top = (1918.49, 519.535, 528.177);
		level.ropetriggers[2].radius = 30;
		level.ropetriggers[2].height = 30;
		
		level.ropetriggers[3] = spawnstruct();
		level.ropetriggers[3].origin = (638.455, -538.819, 65.3673);
		level.ropetriggers[3].top = (604.594, -546.032, 436.125);
		level.ropetriggers[3].radius = 30;
		level.ropetriggers[3].height = 30;
		
		level.allowropes = true;
		
		self showtextfx3("ROPES ATIVADOS",4,"green");
		return;
	}
	
	
	
	if(mapName == "mp_vacant")
	{
			/*
		
		 //centro
		(-3.93077, -54.8808, -47.875) 
		(-5.33703, -39.515, 208.125)

		 //fora latao escada
		(-764.892, 700.066, -47.875) 
		(-752.068, 687.153, 208.125)

		 //dentrogalpao
		(897.845, 713.582, -47.875) 
		(892.466, 700.813, 122.125)
			*/
		level.ropetriggers[0] = spawnstruct();
		level.ropetriggers[0].origin = (-3.93077, -54.8808, -47.875);
		level.ropetriggers[0].top = (-5.33703, -39.515, 208.125);
		level.ropetriggers[0].radius = 30;
		level.ropetriggers[0].height = 30;
		
		level.ropetriggers[1] = spawnstruct();
		level.ropetriggers[1].origin = (-764.892, 700.066, -47.875);
		level.ropetriggers[1].top = (-752.068, 687.153, 208.125);
		level.ropetriggers[1].radius = 30;
		level.ropetriggers[1].height = 30;
		
		level.ropetriggers[2] = spawnstruct();
		level.ropetriggers[2].origin = (897.845, 713.582, -47.875);
		level.ropetriggers[2].top = (892.466, 700.813, 122.125);
		level.ropetriggers[2].radius = 30;
		level.ropetriggers[2].height = 30;
		
		level.allowropes = true;
		
		self showtextfx3("ROPES ATIVADOS",4,"green");
		return;
	}
	
	
	if(mapName == "mp_citystreets")
	{
		level.ropetriggers[0] = spawnstruct();
		level.ropetriggers[0].origin = (5204.11, -37.618, -127.974);
		level.ropetriggers[0].top = (5179.02, -32.8361, 174.125);
		level.ropetriggers[0].radius = 30;
		level.ropetriggers[0].height = 30;
		
		level.ropetriggers[1] = spawnstruct();
		level.ropetriggers[1].origin = (4976.89, 175.025, -127.875);
		level.ropetriggers[1].top = (4989.01, 166.047, 174.125);
		level.ropetriggers[1].radius = 30;
		level.ropetriggers[1].height = 30;
		
		level.ropetriggers[2] = spawnstruct();
		level.ropetriggers[2].origin = (3759.13, -161.478, -127.875);
		level.ropetriggers[2].top = (3742.67, -164.93, 152.125);
		level.ropetriggers[2].radius = 30;
		level.ropetriggers[2].height = 30;
		
		level.ropetriggers[3] = spawnstruct();
		level.ropetriggers[3].origin = (2607.13, 821.715, -0.374311);
		level.ropetriggers[3].top = (2601.24, 828.657, 176.125);
		level.ropetriggers[3].radius = 30;
		level.ropetriggers[3].height = 30;
		
		level.ropetriggers[4] = spawnstruct();
		level.ropetriggers[4].origin = (3315.43, -154.762, 152.125);
		level.ropetriggers[4].top = (3312.01, -138.843, 552.222);
		level.ropetriggers[4].radius = 30;
		level.ropetriggers[4].height = 30;
		
		level.allowropes = true;
		
		self showtextfx3("ROPES ATIVADOS",4,"green");
		return;
	}
	
	if(mapName == "mp_broadcast")
	{
		//level.ropetriggers[0] = spawnstruct();
		//level.ropetriggers[0].origin = (-286.279, 318.437, -31.875);//janela
		//level.ropetriggers[0].top = (-316.405, 352.5, 186.125);
		//level.ropetriggers[0].radius = 30;
		//level.ropetriggers[0].height = 30;
		
		level.ropetriggers[0] = spawnstruct();
		level.ropetriggers[0].origin = (-920.905, -222.608, -31.875);
		level.ropetriggers[0].top = (-913.804, -193.194, 221.125);
		level.ropetriggers[0].radius = 30;
		level.ropetriggers[0].height = 30;
		
		level.ropetriggers[1] = spawnstruct();
		level.ropetriggers[1].origin = (-1172.92, 1159.28, -31.875);
		level.ropetriggers[1].top = (-1166.77, 1150.99, 168.125);
		level.ropetriggers[1].radius = 30;
		level.ropetriggers[1].height = 30;
		
		level.ropetriggers[2] = spawnstruct();
		level.ropetriggers[2].origin = (899.791, 1466.61, -43.3294);
		level.ropetriggers[2].top = (878.945, 1444.97, 164.125);
		level.ropetriggers[2].radius = 30;
		level.ropetriggers[2].height = 30;
		
		level.allowropes = true;
		
		self showtextfx3("ROPES ATIVADOS",4,"green");
		return;
	}
	
	if(mapName == "mp_mtl_the_rock")
	{
		level.ropetriggers[0] = spawnstruct();
		level.ropetriggers[0].origin = (4954.8, 3127.94, -3583.88);
		level.ropetriggers[0].top = (4945.87, 3127.01, -3031.88);
		level.ropetriggers[0].radius = 30;
		level.ropetriggers[0].height = 30;
		
		level.ropetriggers[1] = spawnstruct();
		level.ropetriggers[1].origin = (3103.24, 3751.51, -3583.88);
		level.ropetriggers[1].top = (3107.1, 3732.81, -2975.88);
		level.ropetriggers[1].radius = 30;
		level.ropetriggers[1].height = 30;
		
		level.ropetriggers[2] = spawnstruct();
		level.ropetriggers[2].origin = (641.503, 2846.05, -3001.88);
		level.ropetriggers[2].top = (600.761, 2868.56, -2378.13);
		level.ropetriggers[2].radius = 30;
		level.ropetriggers[2].height = 30;
		
		level.ropetriggers[3] = spawnstruct();
		level.ropetriggers[3].origin = (1198.2, 1431.36, -4047.88);
		level.ropetriggers[3].top = (1204.99, 1532.62, -3575.51);
		level.ropetriggers[3].radius = 30;
		level.ropetriggers[3].height = 30;
		
		level.ropetriggers[4] = spawnstruct();
		level.ropetriggers[4].origin = (5718.33, 4601.68, -3871.88);
		level.ropetriggers[4].top = (5714.07, 4650.09, -3274.16);
		level.ropetriggers[4].radius = 30;
		level.ropetriggers[4].height = 30;
		
		level.allowropes = true;
		
		self showtextfx3("ROPES ATIVADOS",4,"green");
		return;
	}
	
	level.allowropes = undefined;
	//se nao tem nenhum devole o $$$ e cancela
	//self GiveEVP(350,100); nao usar esse devido ao rank
	//self setStat(3181,);//im a dumbfuck set this....??
	self statAdds("EVPSCORE",350);
}


giveplayetheropes()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	//if(self getStat(2397) != 0)
	//return;
	
	self.boughtropes = true;
	self.spawnrope = undefined;
	
	self playLocalSound( "signal1");
	wait 0.3;
	self playLocalSound( "signal1");
	wait 0.3;
	self playLocalSound( "signal1");
	wait 0.3;
	self playLocalSound( "signal1");	
	wait 0.3;	
	self playLocalSound( "signal1");
	
	lastWeapon = self getCurrentWeapon();

	//give the item to player...press 4
	self giveActionSlot4AfterDelay( "gl_mp", 25 );

	
	for ( ;; )
	{
		self waittill( "weapon_change" );

		currentWeapon = self getCurrentWeapon();
		
		wait 1;
		
		switch( currentWeapon )
		{
			case "gl_mp":					
					self thread spawnropesonmap();
					self setStat(2397,0);
					self takeWeapon( currentWeapon );
					self setActionSlot( 4, "" );
					self playLocalSound( "radio_putaway");
				if ( lastWeapon != "none" )
					self switchToWeapon( lastWeapon );
				break;
			
			case "none":
				break;
			
			default:
				lastWeapon = self getCurrentWeapon();
				break;
		}
	}
}


spawnropesonmap()
{		
		//self endon( "death" );
		self endon( "disconnect" );	
		
		if(isDefined(self.spawnrope))
		return;
		
		createropetriggers(level.script);
		
		if(!isDefined(level.allowropes))
		return;
		
		self.spawnrope = true;
		self.goingdown = undefined;
		self.goingup = undefined;
		
		if(!isDefined(level.ropesmonitor))
		level thread waitropetouch();	
			
		if(!isDefined(level.com_drop_ropes))
		{
			level.com_drop_ropes = [];

			for(i = 0; i < level.ropetriggers.size; i++)
			{	
				ropetriggers = level.ropetriggers[i];
				
				if(isDefined(level.ropetriggers[i].adjust))
				setorigin = level.ropetriggers[i].adjust;
				else
				setorigin = ropetriggers.origin;
				
				//SPAWN DO MODELO
				level.com_drop_ropes[i] = spawn("script_model", setorigin );
				level.com_drop_ropes[i].angles = self.angles;
				level.com_drop_ropes[i].top = ropetriggers.top;
				level.com_drop_ropes[i] setmodel(level.com_drop_rope);		
			}
		}
		
		//Give the acess to the ropes for the same squad
		if(isDefined(self.squad))
		{
			self thread SquadRopeAcess();
		}
		
		//cria somente p trigger para o player acessar
		for(;;)
		{
			self waittill ( "rope_touch");
			
			//check if player bought the ropes so allow it to use also!!
			//if (!isDefined(self.boughtropes))
			//continue;
			//self iprintln("ROPES ropeorgin: " + self.ropeorgin);
			
			self.playerhand = spawn("script_model", self.ropeorgin );
			
			self.playerhand  setModel( "tag_origin" );
			
			//self.playerhand linkto(self);
			self linkto(self.playerhand);
			
			rope_time = 1.5;
			//entity 18 is not a script_brushmodel, script_model, script_origin, or light:
			//pair 'entity' and '(0, 0, -60)' has unmatching types 'object' and 'vector':
			
			self playLocalSound( "fly_crossbow_mag_in");
			self playSound( "zipline");//nao terminado
			
			if(isDefined(self.goingdown))
			self.playerhand moveto ( self.ropetop +  (0, 0, -50), rope_time, 1, .2 );	
			
			if(isDefined(self.goingup))
			self.playerhand moveto ( self.ropetop +  (0, 0, -50) , rope_time, 1, .2 );	
			
			
			wait rope_time;
			self SetOrigin( self.ropetop +  (0, 0,70));//ajuste do spawn
			self playLocalSound( "fly_crossbow_mag_in");
			
			//see what happens when u die with and no delete?
			if(isDefined(self.playerhand))
			self.playerhand unlink();
			if(isDefined(self.playerhand))
			self.playerhand delete();
			
			wait 6; //give player time to leave it....
			//finished using it
			self.goingdown = undefined;
			self.goingup = undefined;
			
			
			//com_drop_rope delete();
			//self.spawnrope = undefined;			
			//self notify("deleterope");
		}
		
		self.spawnrope = undefined;
}


SquadRopeAcess()
{

	self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );
	
	squad = self.squad;
	
	//para todos os squads no server listar
	for( i = 0; i < game[ squad ].size; i++ ) 
	{
		//squad_member1 = u
		for( member = 0; member < level.maxSquadSize; member++ ) 
		{
			if( !isDefined( game[ squad ][ member ] ) ) 
			continue;
			
			if(!isDefined(game[ squad ][ member ].squad))
			continue;
			
			if(!isAlive(game[ squad ][ member ]))
			continue;
						
			//squad nao eh o mesmo meu
			if(game[ squad ][ member ].squad != self.squad)
			continue;
			
			//squad nao esta no mesmo time meu
			if(game[ squad ][ member ].pers["team"] != self.pers["team"])
			continue;			
			
			//me ignorar para nao repetir
			if(game[ squad ][ member ] == self)
			continue;

			if(isDefined(game[ squad ][ member ].withrope))
			continue;
			
			game[ squad ][ member ] thread SquadRopeTouch();
		}
	}
}

SquadRopeTouch()
{
		self endon( "disconnect" );
		self endon( "joined_team" );
		self endon( "joined_spectators");
		self endon( "death" );
	
		//cria somente p trigger para o player acessar
		for(;;)
		{
			self waittill ( "rope_touch");
			
			//check if player bought the ropes so allow it to use also!!
			self.withrope = true;			
			
			self.playerhand = spawn("script_model", self.ropeorgin );
			self.playerhand  setModel( "tag_origin" );
			
			//self.playerhand linkto(self);
			self linkto(self.playerhand);
			
			rope_time = 1.5;
			//entity 18 is not a script_brushmodel, script_model, script_origin, or light:
			//pair 'entity' and '(0, 0, -60)' has unmatching types 'object' and 'vector':
			
			self playLocalSound( "fly_crossbow_mag_in");
			self playSound( "zipline");//nao terminado
			
			if(isDefined(self.goingdown))
			self.playerhand moveto ( self.ropetop +  (0, 0, -50), rope_time, 1, .2 );	
			
			if(isDefined(self.goingup))
			self.playerhand moveto ( self.ropetop +  (0, 0, -50) , rope_time, 1, .2 );	
			
			
			wait rope_time;
			self SetOrigin( self.ropetop +  (0, 0,50));//ajuste do spawn
			self playLocalSound( "fly_crossbow_mag_in");
			
			if(isDefined(self.playerhand))
			self.playerhand unlink();
			if(isDefined(self.playerhand))
			self.playerhand delete();
			
			wait 6; //give player time to leave it....
			//finished using it
			self.goingdown = undefined;
			self.goingup = undefined;	
		}
}

waitropetouch()
{
	level endon ( "game_ended" );
	
	if(isdefined(level.ropetriggers))
	{
		level.ropesmonitor = true;
	
		for(i = 0; i < level.ropetriggers.size; i++)
		{
			ropetriggers = level.ropetriggers[i];
			ropetriggers.origin = (ropetriggers.origin[0], ropetriggers.origin[1], (ropetriggers.origin[2] - 16));
		}

		playerradius = 16;

		for(;;)
		{
			players = getentarray("player", "classname");
			counter = 0;
			
			for(i = 0; i < players.size; i++)
			{
				player = players[i];
				
				if(isdefined(player) && isdefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
				{						
					player checktouchingrope();
					counter++;
					
					if(!(counter % 4))
					{
						wait 0.08;
						counter = 0;
					}
				}
			}
			
			xwait (.07,false);
		}
	}

}


checktouchingrope()
{
	playerradius = 25;	
	
	if(isDefined(self.goingup) || isDefined(self.goingdown))
	return;
	
	for(i = 0; i < level.ropetriggers.size; i++)
	{
		ropetriggers = level.ropetriggers[i];
		
		//going up
		diffbtm = ropetriggers.origin - self.origin;
		
		//going down
		difftop = ropetriggers.top - self.origin;	
		
		if((self.origin[2] >= ropetriggers.origin[2]) && (self.origin[2] <= ropetriggers.origin[2] + ropetriggers.height))
		{
			diff2 = (diffbtm[0], diffbtm[1], 0);
			
			if(length(diff2) < ropetriggers.radius + playerradius)
			{
				self.ropeorgin = level.ropetriggers[i].origin;
				self.ropetop = level.ropetriggers[i].top;
				self.goingup = true;
				self notify("rope_touch");	
				break;
			}
		}
		
		//going down
		if((self.origin[2] >= ropetriggers.top[2]) && (self.origin[2] <= ropetriggers.top[2] + ropetriggers.height))
		{
			diff3 = (difftop[0], difftop[1], 0);
			
			if(length(diff3) < ropetriggers.radius + playerradius)
			{
				//invert
				self.ropeorgin = level.ropetriggers[i].top;
				self.ropetop = level.ropetriggers[i].origin;
				self.goingdown = true;
				self notify("rope_touch");	
				break;
			}
		}
	}
}

AttachObjecttoHand(object)
{
	sHandTag = "TAG_INHAND";
	// attach to  hand
	self attach( object, sHandTag );
	//wait?
	org_hand = self gettagorigin( sHandTag );
	angles_hand = self gettagangles( sHandTag );
	
	model_object = spawn( "script_model", org_hand );
	model_object setmodel( object );
	model_object.angles = angles_hand;		

	
	//wait para deeltar
	// delete once door is breached
	self waittill( "aviso" );
	self detach(object, sHandTag );	
	model_object delete();
}	

//
//=========================HABILIDADES DAS CLASSES========================
//

BlockedbyDefense()
{
	if(isDefined(self.blocked))
	{
		self iprintlnbold("^3BLOQUEADO PELO TIME INIMIGO!");
		return true;
	}
	
	return false;
}

//sniper
signal()
{
	if(self.signalused) return;
	
	//if(self getStat(3160) == 0) return;
	//if(self statGets("TEAMBUFF") != 1)
	//return;
	
	if(BlockedbyDefense()) return;
	
	if(!HabilidadePermitida(450)) return;
	
	self HabilidadeUsada(450);
	
	if(!isAlive(self)) return;
	
	self.signalused = true;
	
	//self setStat(3160,0);//reset
	
	//self statSets("TEAMBUFF",0);
	
	//remove o TB se usasr esta habil?
	//if(isDefined(self.teambufficon) && isDefined(self.teambufficon.icon))
	//self.teambufficon.icon.alpha = 0;
	
	self thread SignalSpread();
}

SignalSpread()
{
	players = getEntArray( "player", "classname" );
	
	//self iprintln("^3Signal Ativado !");
	
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		if(!isAlive(player)) continue;
		
		if(player == self) continue;
		
		if(player.pers["team"] == self.pers["team"]) continue;
		
		player thread SignalWait();
	}

}
//3 pulsos
SignalWait()
{
	self endon("disconnect");
	self endon("death");
	self endon("spyplaneended");
	
	self.countsignal = 0;
	
	while(self.countsignal < 4)
	{	
		self thread promatch\_markplayer::spotPlayer(5,false);
		self.countsignal++;
		wait 6;
	}
}

GiveSentry()
{

	if(!level.teambased) return;
	
	if(BlockedbyDefense()) return;
	
	if(!HabilidadePermitida(350)) return;	
	
	//self thread promatch\_sentrygun::sentry_check();
	
}
//specopsclass
SpawnBarreira()
{
	
	if(!HabilidadePermitida(70)) return;
	
	if(level.atualgtype == "dm") return;	
	
	if(BlockedbyDefense()) return;
	
	if(!isAlive(self)) return;
		
	if(isDefined(level.bomborigin))
	{
		if (distance( self.origin, level.bomborigin ) < 250 ) 
		return;	
	}
	
	if(!isDefined(self.droppedblocker))
	self.droppedblocker = 1;
	
	
	if(self.droppedblocker > 2)//max 2
	return;
	
	self HabilidadeUsada(70);
	
	self.droppedblocker++;
	
	player = self;
	blockRadius = 46; 
	
	trace = bulletTrace( player.origin + (0,0,20), player.origin - (0,0,2000), false, player );
	tempAngle = 0;
	forward = (cos( tempAngle ), sin( tempAngle ), 0);
	forward = vectornormalize( forward - tempvector_scale( trace["normal"], vectorDot( forward, trace["normal"] ) ) );
		
	dropAngles = vectortoangles( forward );
			
	SinderBlock = spawn( "script_model", trace["position"] - (0,0,10) );
	SinderBlock setModel(level.barricade);//precache na sentrygun
	SinderBlock.angles = dropAngles;	
	SinderBlock rotateto((0,self.angles[1],0), 0.3 );	
	SinderBlock.owner = self;
	wait 4;
	blocktrigger = spawn("trigger_radius",SinderBlock.origin , 9, blockRadius, blockRadius);
	SinderBlock setcontents(0);
	SinderBlock thread SinderBlockdeletetimer(SinderBlock,blocktrigger);	
	
	blocktrigger thread monitorSinderBlockZone(self);
	
	//danos explosivos
	blocktrigger thread SinderBlockDamage(SinderBlock,blocktrigger);
}

SinderBlockDamage(SinderBlock,blocktrigger)
{
	self endon( "death" );
	self endon("deleteblock_timeout");
	
	self setcandamage(true);
	self.maxhealth = 1000;
	self.health = self.maxhealth;

	attacker = undefined;

	while(1)
	{
		self waittill ( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, iDFlags );
		
		if ( !isplayer(attacker) )
		continue;

		//iprintln(damage + "-> type: " + type);

		if (type != "MOD_GRENADE_SPLASH") // explosives
		continue;
		
		// "destroyed_explosive" notify, for challenges
		if ( isdefined( attacker ) && isdefined( attacker.pers["team"] ) )
		{
			//if ( attacker.pers["team"] != self.owner.pers["team"] )
			//attacker notify("deleteblock_timeout");
			
			if(isDefined(SinderBlock))
			SinderBlock delete();			
			if(isDefined(blocktrigger))
			blocktrigger delete();
			
			self notify("deleteblock_timeout");
		}
		
		break;
	}	
}

SinderBlockdeletetimer(SinderBlock,blocktrigger)
{
	self endon("deleteblock_timeout");
	
	wait 140;
	
	if(isDefined(SinderBlock))
	SinderBlock delete();	
	if(isDefined(blocktrigger))
	blocktrigger delete();
	
	self notify("deleteblock_timeout");
}


monitorSinderBlockZone(owner)
{  
  self endon("deleteblock_timeout");
     
  for (;;)
  {    
    self waittill( "trigger", player);
	
	if(!isDefined(player)) continue;
  
	//if(player.flakjacket) continue;
	
//	iprintln("blocktrigger:" + player.name);
	
	if ( player isTouching( self) )
	{
		player dodamage(owner,5);
		
		if(!isDefined(player.nosprint))
		{	
			//som da cerca
			self playSound("wiretrap");
			player.nosprint = true;			
			
			player thread Nosprint(4);
			
			player freezeControls( true );
			wait 0.07;
			player freezeControls( false );
		}
		
		wait 0.5;
	}
  }
}

//Classe Elite
//Steal
EliteSteal()
{
	if(!HabilidadePermitida(70)) return;
	
	if(BlockedbyDefense()) return;
	
	if(!isAlive(self)) return;
	
	range = 100;	
	aimPos = anglesToForward( self getPlayerAngles() );
	trace = bulletTrace(self gettagorigin("tag_inhand"),self gettagorigin("tag_inhand")+range*aimPos,true,self);
	
	if(isDefined(trace["entity"]) && isPlayer(trace["entity"]) && isAlive(trace["entity"]))
	{
		victim = trace["entity"];

		distanceFromVictim = distance( self.origin, victim.origin);

		if ( distanceFromVictim > 150 )
		return;	

		self GetReturnPlayerTreinamentos(victim);
		self iprintln("^3Elite Stolen "+ victim.name );
		self HabilidadeUsada(70);
		return;				
	}
	else
	{
		self thread EliteStealSearch();
	}
}

EliteStealSearch()
{
	players = getEntArray( "player", "classname" );
	
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		if(!isAlive(player)) continue;
		
		if(player == self) continue;
		
		distanceFromVictim = distance( self.origin, player.origin);

		if ( distanceFromVictim > 600 )
		continue;
		
		if(self.team != player.team)
		{	
			if(percentChance(35))
			player thread weaponJammer();
		}
		
		self GetReturnPlayerTreinamentos(player);		
		self iprintln("^3Steal PowerUP "+ player.name );
		self HabilidadeUsada(70);
	}

}


gamblermonitor()
{
	self endon( "death" );
	self endon( "disconnect" );

	while(1)
	{
		self waittill("reload");

		if(!isdefined(self.lastDroppableWeapon) || self.lastDroppableWeapon == "")
		continue;
		
		if(percentChance(20))
		{		
			ammoClip = self GetWeaponAmmoClip(self.lastDroppableWeapon);
			//self SetWeaponAmmoClip(newWeapon,0);

			ammoStock = self GetWeaponAmmoStock(self.lastDroppableWeapon);
			self setWeaponAmmoStock(self.lastDroppableWeapon,(ammoStock + ammoClip));
		}
	}
}


GetReturnPlayerTreinamentos(player)
{
	if(!isDefined(self.class)) return;
	
	if(!isAlive(self)) return;
	
	if (self.upgradefolego == false)
	self.upgradefolego = player IsUpgradesOn("upgradefolego");
	if (self.upgradefalldamage == false)	
	self.upgradefalldamage = player IsUpgradesOn("upgradefalldamage");
	if (self.upgradeprecisionshoot == false)
	self.upgradeprecisionshoot = player IsUpgradesOn("upgradeprecisionshoot");
	if (self.upgradebuffreset == false)
	self.upgradebuffreset = player IsUpgradesOn("upgradebuffreset");
	
	//medic
	if (self.upgradefastrevive == false)
	self.upgradefastrevive = player IsUpgradesOn("upgradefastrevive");
	if (self.upgradefastRegen == false)
	self.upgradefastRegen = player IsUpgradesOn("upgradefastRegen");	
	if (self.upgrademedkitPack == false)
	self.upgrademedkitPack = player IsUpgradesOn("upgrademedkitPack");
	if (self.upgradeammopack == false)
	self.upgradeammopack = player IsUpgradesOn("upgradeammopack");
	
	if (self.upgradewalldamageresist == false)
	self.upgradewalldamageresist = player IsUpgradesOn("upgradewalldamageresist");
	if (self.upgradefastchange == false)
	self.upgradefastchange = player IsUpgradesOn("upgradefastchange");
	if (self.upgradebombdisarmer == false)
	self.upgradebombdisarmer = player IsUpgradesOn("upgradebombdisarmer");
	if (self.upgradehackspot == false)
	self.upgradehackspot = player IsUpgradesOn("upgradehackspot");
	if (self.upgradescavenger == false)
	self.upgradescavenger = player IsUpgradesOn("upgradescavenger");
	if (self.upgradeteargas == false)
	self.upgradeteargas = player IsUpgradesOn("upgradeteargas");
	if (self.upgradeposiondamage == false)
	self.upgradeposiondamage = player IsUpgradesOn("upgradeposiondamage");
	if (self.upgradecapturenaderesist == false)
	self.upgradecapturenaderesist = player IsUpgradesOn("upgradecapturenaderesist");	
	if (self.upgradesensorseeker == false)
	self.upgradesensorseeker = player IsUpgradesOn("upgradesensorseeker");
	if (self.upgradedropitems == false)
	self.upgradedropitems = player IsUpgradesOn("upgradedropitems");	
	if (self.upgrademedicsmoke == false)
	self.upgrademedicsmoke = player IsUpgradesOn("upgrademedicsmoke");	
	//---------------
	if (self.dangercloser == false)
	self.dangercloser = player IsUpgradesOn("upgradedangercloser");
	if (self.takedown == false)
	self.takedown = player IsUpgradesOn("upgradetakedown");
	if (self.coldblooded == false)
	self.coldblooded = player IsUpgradesOn("upgradecoldblooded");
	if (self.incognito == false)
	self.incognito = player IsUpgradesOn("upgradeincognito");
	if (self.sitrep == false)
	self.sitrep = player IsUpgradesOn("upgradesitrep");
	if (self.wallbang == false)
	self.wallbang = player IsUpgradesOn("upgradewallbang");
	if (self.collateral == false)
	self.collateral = player IsUpgradesOn("upgradecollateral");
	if (self.medicpro == false)
	self.medicpro = player IsUpgradesOn("upgrademedicpro");
	if (self.peripherals == false)
	self.peripherals = player IsUpgradesOn("upgradeperipherals");
	
	
	//SKILLS
	
	if(self.upgradefolego)
	self setPerk( "specialty_longersprint" );

	//temp
	self.firearrow = player getStat(2386);
	
	self.poisonarrow = player getStat(2394);
	
	self.shockarrow = player getStat(2395);
	
	//if(self.upgradefastRegen)
	//self.upgradefastRegen = 5;
	
	if(self.sitrep)
	self setPerk( "specialty_detectexplosive" );
	
	
	if(self.class == "sniper")
	{
		self.isSniper = true;
		self setClientDvar( "jump_slowdownEnable",0);
	}

	if(level.atualgtype == "sd" && self.upgradebombdisarmer)
	{
		if(isDefined(game["defenders"]) && self.pers["team"] == game["defenders"])
		{
			//self iprintln("upgradebombdisarmer:" + self.upgradebombdisarmer);
			self.allowdestroyexplosives = true;
			self thread promatch\_spreestreaks::allowDefenderExplosiveDestroy();
			level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry( "any" );			
		}	
	}
	
	if(self.medicpro)
	{
		self.medic = true;
		self.healthmaster = true;
		self thread promatch\_medic::SetMedic();
		self thread maps\mp\gametypes\_healthoverlay::playerHealthRegen();
	}
	
	if(self.peripherals)
	{
		self setClientDvar( "compassMaxRange", 2500 );
		self setClientDvar( "compassRadarPingFadeTime",2);
	}
}

MedicShare()
{
	self endon("death"); 
	self endon("disconnect"); 
	
	if(!HabilidadePermitida(100)) return;
	
	if(BlockedbyDefense()) return;
	
	if(!isAlive(self)) return;
	
	if(isDefined(self.medicshareon))
	return;
	
	self.medicshareon = true;
	
	self iprintln("^3Medic Heal "+ self.name );
	self HabilidadeUsada(100);	
			
	players = getEntArray( "player", "classname" );
	
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		if(!isAlive(player)) continue;
		
		//if(player == self) continue;
		
		if(player.team != self.team) continue;
		
		player.ffkiller = false;
		
		player.stoppoison = true;
	}	
	
	while(1)
	{
		for ( index = 0; index < players.size; index++ )
		{
			player = players[index];
			
			player.revived = undefined;
			
			if(!isAlive(player)) continue;
			
			if(player == self) continue;
			
			if(player.team != self.team) continue;
			
			distanceFromVictim = distance( self.origin, player.origin);

			if ( distanceFromVictim > 600 )
			continue;
			
			if(player.health > 290)
			continue;
			
			player LifeAddUpdate(20);
			
			self iprintln("Healed -> " + player.health);
			
			wait 2;//pausa do scan
		}

		wait 5;//pausa do scan		
	}
}

//Classe BO
SteathSpy()
{
	if(level.atualgtype == "dm") return;
	
	if(!HabilidadePermitida(90)) return;
	
	if(BlockedbyDefense()) return;
	
	if(!isAlive(self)) return;
	
	//victim shellShock( "frag_grenade_mp", 4 );
	if(isDefined(self.checkingBody) && self.checkingBody)
	{
		self iprintln("^1trocando uniformes..!");
	
		modelinfo = saveModel(self.deadentity);
		self loadModel(modelinfo);		
		self.changedmodel = undefined;
		self loadModel(modelinfo);
		self HabilidadeUsada(90);
		self.camouflage = true;
		
		//if(isMaster(self))//debug
		//{
		//	self thread SpySpreadFF();	
		//}
		
		return;
	}
		
	range = 50;	
	aimPos = anglesToForward( self getPlayerAngles() );
	trace = bulletTrace(self gettagorigin("tag_inhand"),self gettagorigin("tag_inhand")+range*aimPos,true,self);
	
	if(isDefined(trace["entity"]) && isPlayer(trace["entity"]) && isAlive(trace["entity"]))
	{
		victim = trace["entity"];
		
		if(isDefined(victim.stealthed)) return;
		
		//mesmo time - ignorar
		if(victim.pers["team"] == self.pers["team"])
		return;	
		
		distanceFromVictim = distance( self.origin, victim.origin);

		if ( distanceFromVictim > 50 )
		return;					

		if(self getStance() == "crouch")
		{
			victim thread weaponJammer();
			return;
		}
		
		if(self getStance() == "prone")
		{
			victim thread Nosprint(9);
			return;
		}
		
		modelinfoa = saveModel(self);		
		modelinfo = saveModel(victim);
				
		victim loadModel(modelinfoa);
		victim.ffkiller = true;
		victim setclientdvar("cg_drawFriendlyNames",0);
		victim.changedmodel = undefined;

		
		self loadModel(modelinfo);		
		self.changedmodel = undefined;
		self loadModel(modelinfo);		
		
		self iprintlnbold("^3Uniforme Roubado !");
		self HabilidadeUsada(90);
		
		self.camouflage = true;
		
		self thread SpySpreadFF();		
	}
}

//teste espalhar o modo FF para todos inimigos apos infiltrar
SpySpreadFF()
{
	self endon("disconnect");
	self endon("death");
	
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		//caso ele quit ou drop
		if(!isDefined(player)) continue;		
		
		//ignorar caso morto ou n jogando...
		if(!isAlive(player)) continue;

		if(!isdefined(player.atualClass)) continue;
		
		if(player.pers["team"] == self.pers["team"]) continue;
		
		player.stealthed = true;
		player.ffkiller = true;
		player setclientdvar("cg_drawFriendlyNames",0);
		
		if(isDefined(self.alpha))
		{
			self.alpha = 0;
		}
	}
}

//
//=========================HABILIDADE DAS CLASSES FIM========================
//
weaponJammer()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	wait level.oneFrame;
	
	// Get the current weapon
	currentWeapon = self getCurrentWeapon();			

	currentAmmo = self getAmmoCount( currentWeapon );
	if ( currentAmmo > 1 ) 
	{
	
		if ( self attackButtonPressed() && randomInt( 5 ) == 1 ) 
		{

			self.jammedWeaponAmmo = self getAmmoCount( currentWeapon ) - 1;
			self setWeaponAmmoStock( currentWeapon, 0 );
			self setWeaponAmmoClip( currentWeapon, 0 );	
			xwait (0.8,false);
			self playLocalSound( game["voice"][self.pers["team"]] + "rsp_comeon" );			
		}				
	}
	
	self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
	if(isDefined(self.jammedWeaponAmmo))
	self setWeaponAmmoStock( currentWeapon, self.jammedWeaponAmmo );
	else
	self setWeaponAmmoStock( currentWeapon, 15 );
	
	self playLocalSound( "scramble" );

	xWait(2,false);

	self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
	
}



saveModel(player)
{
	info["model"] = player.model;
	info["viewmodel"] = player getViewModel();
	attachSize = player getAttachSize();
	info["attach"] = [];
	
	assert(info["viewmodel"] != ""); // No viewmodel was associated with the player's model
	
	for(i = 0; i < attachSize; i++)
	{
		info["attach"][i]["model"] = player getAttachModelName(i);
		info["attach"][i]["tag"] = player getAttachTagName(i);
		info["attach"][i]["ignoreCollision"] = player getAttachIgnoreCollision(i);
	}
	
	return info;
}

loadModel(info)
{
	if(!isDefined(info["viewmodel"])) return;
	
	self detachAll();
	self setModel(info["model"]);
	self setViewModel(info["viewmodel"]);

	attachInfo = info["attach"];
	attachSize = attachInfo.size;
    
	for(i = 0; i < attachSize; i++)
		self attach(attachInfo[i]["model"], attachInfo[i]["tag"], attachInfo[i]["ignoreCollision"]);
}



tempvector_scale(vec, scale)
{
	vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
	return vec;
}


AngleClamp180( angle )
{
	angleFrac = angle / 360.0;
	angle = ( angleFrac - floor( angleFrac ) ) * 360.0;
	if( angle > 180.0 )
		return angle - 360.0;
	return angle;
}

//Verifica se precisa de municao
NeedAmmoCheck()
{
	self endon( "death" );
	self endon( "disconnect" );	

	Myweapon = self getCurrentWeapon();
	
	//Weapon name "none" is not valid.
	if(isDefined(Myweapon) && Myweapon == "none")
	return;
	//weaponmaxammo
	ammoStock = self getWeaponAmmoStock(Myweapon);//e no stock
	ammoClipSize = weaponClipSize(Myweapon);//quanto o tamanho do clip desta arma
	maxStock = weaponMaxAmmo( Myweapon );
	//30 -(30 * 4) < x
	if (ammoStock < maxStock)
	return true;
	else
	return false;
}
/*
AmmoReplenish()
{
	class = self.class;
	if(isDefined(self.pers[class]["loadout_sgrenade"]))
	self thread giveNadesAfterDelay( self.pers[class]["loadout_sgrenade"] + "_mp", 1, false );
	
	self thread giveNadesAfterDelay( "frag_grenade_mp", 1, true );
	
	currentWeapon = self getCurrentWeapon();
	
	if(isdefined(currentWeapon) && currentWeapon == "none")
	return;
	
	self giveMaxAmmo( currentWeapon );		
}*/

AddExtraAmmo(ammopool)
{
	if(!isdefined(self))
	return;

	currentWeapon = self getCurrentWeapon();
	
	if(isdefined(currentWeapon) && currentWeapon == "none")
		return;
	
	stockCount = self getWeaponAmmoStock( currentWeapon );
	maxStock = weaponMaxAmmo( currentWeapon );

	if ( stockCount < maxStock ) 
	self setWeaponAmmoStock( currentWeapon, stockCount + ammopool );

}

Looter()
{

	if(!percentChance(60)) return;

	currentWeapon = self getCurrentWeapon();
	
	if(isdefined(currentWeapon) && currentWeapon == "none")
	return;
	
	stockCount = self getWeaponAmmoStock( currentWeapon );
	maxStock = weaponMaxAmmo( currentWeapon );

	if ( stockCount < maxStock ) 
	self setWeaponAmmoStock( currentWeapon, stockCount + 15 );

	self LifeUpgrade(70);
	
	if(percentChance(20))
	{
		self setPerk( "specialty_gpsjammer" );
		self iprintlnbold("^1##Voce ganhou o Tatical UAV JAMMER##");
	}
	
	if(percentChance(20))
	{
		self setPerk( "specialty_quieter" );
		self.takedown = true;
		self iprintlnbold("^1##Voce ganhou o Tatical Moviment##");
	}
	
	if(percentChance(30))
	{
		self.takedown = true;
		self iprintlnbold("^1##Voce ganhou o Armor Upgrade##");
	}
	
}

RealTime()
{
	timeint = GetRealTime();
	timestr = TimeToString(timeint,0, "%R");
	return timestr;
}

//==================POINTS==================
GiveEVP(evp,percent)
{
	//3181,EVPSCORE
	//3476,MONEYRANK
	
	//if(level.players.size < 3)
	//return;

	//Limit is now based on BANK	
	mylevel = statGets("MONEYRANK");	
	
	if(mylevel == 0)
	mylevel = 5000;
	
	if(self statGets("EVPSCORE") >= mylevel)
	{	
		self statSets("EVPSCORE",mylevel);		
		return;
	}

	tipo = "";
	
	if(evp > 0)
	tipo = "ganhou ";
	else
	tipo = "perdeu ";
	
	if(level.atualgtype != "sd")
	{
		if(percentChance(percent) && evp > 0)//direto
		{
			self statAdds("EVPSCORE", evp );
			self.pers["roundpocket"] += evp;
			self statSets("ROUNDPOCKET", self.pers["roundpocket"] );
		}
	} 
	else
	{
		//rank refazer os valores nos 8 tipos de rank
		if(percentChance(percent) && evp > 0)//direto
		{
			if(self.pers["rank"] == 2)
			evp = int(evp + 30);
						
			if(self.pers["rank"] == 3)
			evp = int(evp + 40); 
			
			if(self.pers["rank"] == 4)
			evp = int(evp + 50);
						
			if(self.pers["rank"] == 5)
			evp = int(evp + 60);
			
			if(self.pers["rank"] == 6)
			evp = int(evp + 70);
						
			if(self.pers["rank"] == 7)
			evp = int(evp + 80);
			
			if(self.pers["rank"] == 8)
			evp = int(evp + 100);
			
			//iprintln("rank" + self.pers["rank"]);
			self statAdds("EVPSCORE", evp );

			//iprintln("evplvl3" + evp);
			self.pers["roundpocket"] += evp;
			self statSets("ROUNDPOCKET", self.pers["roundpocket"] );
			
			if(level.atualgtype != "dm")
			self iprintlnbold("^1Voce "+ tipo + evp + " $$$");		
		}		
	}
}

GetFPSSweetspot(fps)
{
	if(abs(125-fps) < 20)
	self iprintln("125");
	if(abs(250-fps) < 20)
	self iprintln("250");
	if(abs(333-fps) < 20)
	self iprintln("333");

}

Nosprint(waittime)
{
	self endon("disconnect");
	
	self thread maps\mp\gametypes\_gameobjects::_disableSprint();
	self setStance("prone");
	wait waittime;	
	self thread maps\mp\gametypes\_gameobjects::_enableSprint();	
	self.nosprint = undefined;
}


stopPlayer( condition )
{
	if ( condition )
	{
		self setMoveSpeedScale( 0 );
		self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
		self thread maps\mp\gametypes\_gameobjects::_disableJump();
		self thread maps\mp\gametypes\_gameobjects::_disableSprint();
	}
	else
	{
		self SetClassBasedSpeed();
		self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
		self thread maps\mp\gametypes\_gameobjects::_enableJump();
		self thread maps\mp\gametypes\_gameobjects::_enableSprint();
	}
}

//2500 > longe da bomb !
FindPlayersFarBombPlanted()
{
	if(!level.bombPlanted) return;
	
	self endon("disconnect");
	self endon("death");
	
	players = level.players;
	origin = level.sdBombModel.origin;	
	dist = 0;
	
	//dar um tempo para os jogadores se moverem ate a bomb?
	wait 10;
	
	for (i = 0; i < players.size; i++)
	{
		//quem ataca plantou entao os att tem que estarem perto da bomb pra defender
		//defensa ignorar?
		if(!isDefined(players[i])) continue;
		
		if(!isDefined(players[i].pers["team"])) continue;
		
		if(!isAlive(players[i])) continue;
		
		//throwing script exception: pair 'undefined' and 'allies' has unmatching types 'undefined' and 'string'
		if(players[i].pers["team"] == game["defenders"]) continue;
		
		dist = distance(players[i].origin, origin);
		
		if (dist < 2500) continue;
		
		players[i] playlocalsound("weap_ammo_pickup");
		players[i] iprintlnbold("^1VOCE ESTA MUITO LONGO DA BOMB! VA DEFENDER!");
	
	}
	
	wait 25;
	
	for (i = 0; i < players.size; i++)
	{
		//quem ataca plantou entao os att tem que estarem perto da bomb pra defender
		//defensa ignorar?
		if(!isDefined(players[i])) continue;
		
		if(!isDefined(players[i].pers["team"])) continue;
		
		if(!isAlive(players[i])) continue;
		
		dist = distance(players[i].origin, origin);
		
		if (dist < 2500) continue;
		
		players[i] playlocalsound("weap_ammo_pickup");
		players[i] iprintlnbold("^1TA AINDA AI? VOCE FOI MARCADO NO MAPA PARA TODOS");		
		players[i] promatch\_markplayer::spotPlayer(7,false);
		currentWeapon = players[i] getCurrentWeapon();
		players[i] dropItem( currentWeapon );
	}
	
}

findClosestPlayersArray()
{
	playerCount = level.players.size;
	nearPlayers = [];
	nearDistance = [];
	
	for (index = 0; index < playerCount; index++)
	{
		nearDistance[index] = 999999999;
	}
	
	for (index = 0; index < playerCount; index++)
	{
		player = level.players[index];
		
		//if(!isPlayer(player)) continue;
		
		if (!isAlive(player)) continue;	

		distancex = distanceSquared(self.origin, player.origin);
		
		for (index2 = 0; index2 < playerCount; index2++)
		{
			if(distancex < nearDistance[index2])
			{
				for (index3 = index; index3 >= index2; index3--)
				{
					nearDistance[index3+1] = nearDistance[index3];
					nearPlayers[index3+1] = nearPlayers[index3];
				}
				nearDistance[index2] = distancex;
				nearPlayers[index2] = player;
			}
		}
		
  }
  
  return nearPlayers;

}

findClosestPlayer(team)
{
	// Tried using isLookingAt( player ) to get injured teammate, however, that has problems. 
	// Since isTouching( player ) does not work, then calculating the distance to find the closest player
	// will have to do.
	
	theChosenOne = undefined;
	currentShortestDistance = undefined;
  
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];

    
		if ( player.pers["team"] == team && self != player && isAlive( player ) )
		{       
			distance = distance( self.origin, player.origin );
			if ( distance < 80 ) 
			{
				if ( !isDefined( currentShortestDistance ) )
				{
					theChosenOne = player;
					currentShortestDistance = distance;
				}
				else
				{
					if ( distance < currentShortestDistance )
					{
						currentShortestDistance = distance;
						theChosenOne = player;
					}
				}     
			} 
		}
	}
	return theChosenOne;
}

findClosestTeammateSpread()
{
	theChosenOne = undefined;
	team = self.pers["team"];
	currentShortestDistance = undefined;
  
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];    
   
		if ( player.pers["team"] == team && self != player && isAlive( player ) )
		{       
			distance = distance( self.origin, player.origin );
			if ( distance < 120 ) 
			{
				if ( !isDefined( currentShortestDistance ) )
				{
					theChosenOne = player;
					currentShortestDistance = distance;
				}
				else
				{
					if ( distance < currentShortestDistance )
					{
						currentShortestDistance = distance;
						theChosenOne = player;
					}
				}     
			} 
		}
	}
	return theChosenOne;
}

findClosestdeadTeammate()
{
	self endon("spawned_player");
	self endon("disconnect");
	self endon("death");
	
	theChosenOne = undefined;
	team = self.pers["team"];
	currentShortestDistance = undefined;
  
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];    
   
		if ( player.pers["team"] == team && self != player && !isAlive( player ))
		{       
			//se nao existe o corpo deste ignorar.
			if(!isDefined(player.body))
			continue;
			
			distance = distance( self.origin, player.body.origin );
			
			if ( distance < 180 ) 
			{
				if ( !isDefined( currentShortestDistance ) )
				{
					theChosenOne = player.bodyTrigger;
					currentShortestDistance = distance;
				}
				else
				{
					if ( distance < currentShortestDistance )
					{
						currentShortestDistance = distance;
						theChosenOne = player.bodyTrigger;
					}
				}     
			} 
		}
	}
	
	return theChosenOne;
}

findClosestTeammate()
{
	theChosenOne = undefined;
	team = self.pers["team"];
	currentShortestDistance = undefined;
  
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];    
   
		if ( player.pers["team"] == team && self != player && isAlive( player ) )
		{       
			distance = distance( self.origin, player.origin );
			if ( distance < 80 ) 
			{
				if ( !isDefined( currentShortestDistance ) )
				{
					theChosenOne = player;
					currentShortestDistance = distance;
				}
				else
				{
					if ( distance < currentShortestDistance )
					{
						currentShortestDistance = distance;
						theChosenOne = player;
					}
				}     
			} 
		}
	}
	return theChosenOne;
}

getEyePosition()
{
	switch( self getStance() ) {
		case "crouch":
			return ( self.origin + ( 0,0,40 ) );
		case "prone":
			return ( self.origin + ( 0,0,10 ) );
		default:
			return ( self.origin + ( 0,0,60 ) );
	}
}

getMidPosition() {
	switch( self getStance() ) {
		case "crouch":
			return ( self.origin + ( 0,0,20 ) );
		case "prone":
			return ( self.origin + ( 0,0,5 ) );
		default:
			return ( self.origin + ( 0,0,30 ) );
	}
}

Dropcarryitem()
{
	if(level.atualgtype != "sd")
	return;

		if ( isDefined( self.isBombCarrier ) && self.isBombCarrier && isAlive(self))
		{
			if (isdefined( self.isPlanting ) && !self.isPlanting)
			{
				self.carryObject thread maps\mp\gametypes\_gameobjects::setDropped();
				self.isBombCarrier = false;

				//self updateclassscore(-50,true);

				self thread maps\mp\gametypes\_gameobjects::pickupObjectDelayTime( 4.0 );
			}
		}
}



AdicionarUmMes()
{
	mes = statGets("MES");
	self statSets("MES",mes + 1);
}

RemoverUmMes()
{
	mes = statGets("MES");
	self statSets("MES",mes - 1);
}

GetDate()
{
	dia = int(TimeToString(GetRealTime(),1,"%d"));
	mes = int(TimeToString(GetRealTime(),1,"%m"));
	ano = int(TimeToString(GetRealTime(),1,"%y"));
	todos = ""+dia+"/"+mes+"/"+ano;
	return todos;//strings
}

GravarDiaMes()
{
	dia = int(TimeToString(GetRealTime(),1,"%d"));
	mes = int(TimeToString(GetRealTime(),1,"%m"));
	
	self statSets("DIA",dia);	
	self statSets("MES",mes + 1);//1 mes pra frente
	
//	iprintlnbold("Data de pagamento Registrada!");
	
}

GetDayNow()
{
	dia = int(TimeToString(GetRealTime(),1,"%d"));
	
	return dia;
}

//globallogic 1760
HorariodeEvento()
{

	if(level.cod_mode != "public") return;
		
	hora = int(TimeToString(GetRealTime(),0,"%H"));//24HR - local
	minutos = int(TimeToString(GetRealTime(),1,"%M"));
	
	if(level.autolocksv != 0)
	{	
		switch(hora)
		{
			case 7:
			setDvar( "g_password","locked");
			setDvar( "sv_hostname","FECHADO PARA LIMPEZA/UPDATE");			
			logPrint("TRAVADO PARA MANUT");
			break;
		}
		
		return;
	}	
	
	level.eventohorario = "";
	
	if(level.players.size < 10)
	{
		setDvar( "scr_eventorodando",0);
		level.eventohorario = "";
		return;
	}
	
	if(level.showdebug)
	{
		iprintln("^5Hora: ^3  "+ hora);
		iprintln("^5Minu: ^3  "+ minutos);
	}

	//iprintln(hora + "HORA");
		
	/*switch(hora)
	{
		//===[controle evento 19:00]====
		case 19:
		if(minutos > 40) break;
		level.eventohorario = "19";
		setDvar( "scr_eventorodando",1);
		logPrint("EVENTO: 19");
		break;
		
		case 20:
		if(minutos > 5)
		{
			level.eventohorario = "";
			setDvar( "scr_eventorodando",0);
			logPrint("EVENTO: 19 Finalizado");
		}
		break;		
		
		case 21:
		setDvar( "scr_eventorodando",0);
		level.eventohorario = "";
		logPrint("EVENTO: Finalizado Forcado");		
		break;
	}*/
}

MostrarDiaMes()
{
	dia = self statGets("DIA");
	mes = self statGets("MES");
	result = dia+"/"+ mes;
	
	return result;
}

//SELF//PLAYER
MostrarFPS()//ha uma variaçao ed 20/20 fps ? SVFPS?
{
	self endon("disconnect");
	
	if(isdefined(self))
	{
		if(self GetCountedFPS() >= 320)
		{
			//self iprintlnbold("^1FPS >= 333 DETECTADO - REMOVA OU SERA PUNIDO.");
			iprintln( self.name + " ^1FPS >= 333 DETECTADO");
		}		
		return self GetCountedFPS();
	}
	else
		return "Null";
}

/*
resetsaveclass()
{
	self endon("disconnect");
	
	//impedir uma segunda execucao do mesmo codigo
	if(isDefined(self.resetsaveclass))
	return;

	self.resetsaveclass = true;
	
	for( idx = 300; idx <= 349; idx++ )
	{
		if(!isDefined(self))
		return;
		
		if(self getStat(idx) == 0)
		continue;	
		
		xwait( 0.05, false );
		
		self setStat(idx,0);
	}	
}
*/

resetbasicrank()
{
	self endon("disconnect");
	
	self statSets("SCORE",0);
	self statSets("KILLS",0);
	self statSets("DEATHS",0);
	self statSets("HEADSHOTS",0);
	self statSets("KNIFES",0);
	self statSets("WALLBANG",0);
	self statSets("RAMPAGES",0);
	self statSets("OWNAGES",0);
	self statSets("FIRSTBLOOD",0);
	self statSets("DEFUSED",0);
	self statSets("PLANTED",0);
	
	self statSets("CUSTOMMEMBER",0);
	self statSets("CLANMEMBER",0);

	
}

resetscoreclass()
{
	self endon("disconnect");
	
	self statSets("SCORE",0);
}

Playerprofilereset()
{
	self endon("death");
	self endon("disconnect");

	if(!isAlive(self)) return;
	
	self closeInGameMenu();
	
	self iprintlnbold("^1 INICIANDO RESET TOTAL EM 7s - PARA CANCELAR B43 / ESTEJA MORTO");
	wait 8;
	
	self iprintlnbold("^1INICIANDO RESET TOTAL EM 2s");
	wait 2;
	
	if(!isAlive(self)) return;
	
	self iprintlnbold("^1RESETANDO TUDO!");
	
	//impedir uma segunda execucao do mesmo codigo
	if(isDefined(self.resetallstuff))
	return;

	self.resetallstuff = true;
	
	self thread resetplayertabletotal();
}


firstConnectresetallstuff()
{
	self endon("disconnect");
	
	//impedir uma segunda execucao do mesmo codigo
	if(isDefined(self.resetallstuff))
	return;

	self.resetallstuff = true;
	
	resetplayertabletotal();
}

//sera usado para updates! removendo todos stats nao usados para 0
//aplica Self
resetplayertablereserved()
{
	self endon("disconnect");
	
	wait 4;
	//qntsvars = 0;
	for( idx = 2301; idx <= 3497; idx++ )
	{
		Reserved = tablelookup( "mp/playerStatsTable.csv", 0, idx, 1 );		
		
		if( Reserved == "RESERVED")
		{
			
			Reservedstat = int(tablelookup( "mp/playerStatsTable.csv", 0, idx, 0 ));
			
			self setStat(idx,0);
			
			//qntsvars++;
			
			//iprintln("RESETADO: " + Reservedstat);
			wait 0.05;
		}
		
	}
	
	//iprintln("^1RESETADOS: " + qntsvars);
}

resetplayertabletotal()
{
	qntsvars = 0;
	for( idx = 2301; idx <= 3497; idx++ )
	{
		total = int(tablelookup( "mp/playerStatsTable.csv", 0, idx, 0 ));
		
		if(self getStat(total) == 0) continue;
		
		
		self setStat(total,0);
		wait 0.05;
		qntsvars++;		
	}
	
	//EXTRAS
	self setStat(209,0);
	self setStat(210,0);
	
	//SetFirstConnectConfigs
	self setStat(2497,4);
	
	self iprintlnbold("^1TUDO RESETADO: TOTAL STATS-> " + qntsvars);
}

givevipstats()
{
	self endon("disconnect");
	//self.vipuser = true;
	self GravarDiaMes();
	//self statSets("VIPUSER",1);
}

resetvipstats()
{
	self endon("disconnect");

	if(statGets("VIPUSER") != 0)
	{
		statSets("VIPUSER",0);		
		statSets("DIA",0);	
		statSets("MES",0);
		statSets("INSIGNIA",0);
		statSets("PENDENCIA",0);
		
	}
}
//---------------------------------------------------------
//------MENUS DE UPGRADES---------
//---------------------------------------------------------

//Maximo 3 upgrades ativos
//custo para selecionar
//filtrar classe?


ApplyUpgradesToPlayer(response)
{
	//se nao foi defini é pq nao esta em modo de compra!
	if(!isDefined(self.canbuy))
	{
		self setClientDvar( "ui_upgradestatus", "Fora do Tempo!");
		return;
	}
	//playerdvars ->
	//self UpgradeResetUpdate();//alteracoes na tabela - resetar aqui	
	//ShowDebug("ApplyUpgradesToPlayer: Custo: ",Custo);
	
	//ShowDebug("ApplyUpgradesToPlayer: upgradefastchange: ",self getStat(518));
	//ShowDebug("ApplyUpgradesToPlayer: upgradefastRegen: ",self getStat(512));	
	//if true need to clean one of the upgrades
	//i have to teste if the one selected is not choose to unselect it XD
	if (CheckupgradesAtive(response))
	{
		//self setClientDvar( "ui_upgradestatus", "Maximo 4 - Remova 1 !");
		return;
	}	
	
	//IN UPGRADE MODE	
	upstats = self GetUpgradeStats(response);
	ShowDebug("ApplyUpgradesToPlayer: upstats: ",upstats);
	//toggle on off - this has a price!!!
	if(self getStat(upstats) != 0)
	self SetUpgradeStat(response,0);
	else
	{	
		Custo = GetUpgradePrice(response);
		if(!PodeComprar(Custo))
		{ 
			self closeMenu();
			self closeInGameMenu();
			self setClientDvar( "ui_upgradestatus", "Pobre e sem vida - " + Custo);
			return;
		}
		
		self SetUpgradeStat(response,1);
	}
	
	
	
	if(!isDefined(self.changingupgrades))
	self thread ReapplyUpgradesonChange();
	
	
	//ShowDebug("ApplyUpgradesToPlayer: upstats: ",self getStat(501));
	//ShowDebug("ApplyUpgradesToPlayer: upstats: ",self getStat(502));
	//ShowDebug("ApplyUpgradesToPlayer: upstats: ",self getStat(503));
	
	self setClientDvar( "ui_upgradestatus", "Ativo: " + response);
}

ReapplyUpgradesonChange()
{

	self endon ("death");
	self endon ("disconnect");	
	
	self.changingupgrades = true;
	
	wait(2);
	
	self.changingupgrades = undefined;
	
	self thread LoadUpgradesOnSpawn();

}

IsUpgradesOn(dataname)
{
	if(self getStat(GetUpgradeStats(dataname)) == 0)
		return 0;

	return 1;
}

noteambuffselected()
{
	 foundteambuff = 0;
	 
		for( idx = 547; idx <= 555; idx++ )
		{
			if(self getStat(idx) == 0)
			continue;	
		
			foundteambuff++;
		}
		
		//nenhum selecionado
		if (foundteambuff == 0)
		return true;
	
		if (foundteambuff  > 0)
		{
			return false;//free to use RADAR
		}		
}

CheckupgradesAtive(response)
{
	founditens = 0;
	foundskills = 0;
	foundteambuff = 0;
	skillidx = 0;
	
	SelectedA = 0;
	SelectedB = 0;
	SelectedC = 0;
	SelectedD = 0;
	
	//iprintln("response(CheckupgradesAtive): " + response);
	//if ( isSubStr( weapon, "frag_" ) )
	/*
	response: skillsignal
	response: skillsteathspy
	response: skillbuffuphand
	response: skillbuffdefense
	*/
	
	//self logDebug("CheckupgradesAtive","response: " + response);
	
	if ( isSubStr( response, "skillbuff" ) )
	{	
		//self logDebug("CheckupgradesAtive","skillbuff: " + response);
	
		//check for skills selected. only 1 can be on.
		for( idx = 548; idx <= 555; idx++ )
		{
			
			//iprintln("self getStat(idx):" + self getStat(idx));
			
			if(self getStat(idx) == 0)
			continue;	
		
			foundteambuff++;
			
			skillidx = idx;	

		}
		
		if (foundteambuff == 0)
		return false;

		if(GetUpgradeStatsreturnName(skillidx) == response)
		return false;
	
		if (foundteambuff  > 0)
		{
			self setClientDvar( "ui_upgradestatus", "Apenas um por vez");
			return true;
		}
	}
	
	if ( isSubStr( response, "skill" ) )
	{	
	
		//self logDebug("CheckupgradesAtive","skill: " + response);
		//check for skills selected. only 1 can be on.
		for( idx = 538; idx <= 541; idx++ )
		{
			
			//iprintln("self getStat(idx):" + self getStat(idx));
			
			if(self getStat(idx) == 0)
			continue;	
		
			foundskills++;
			
			skillidx = idx;	

		}
		
		if (foundskills == 0)
		return false;

		if(GetUpgradeStatsreturnName(skillidx) == response)
		return false;
	
		if (foundskills  > 0)
		{
			self setClientDvar( "ui_upgradestatus", "Apenas um por vez");
			return true;
		}
	}
	
	if ( isSubStr( response, "upgrade" ) )
	{
		for( idx = 501; idx <= 536; idx++ )
		{
			//self setStat(idx,0);
			
			//iprintln("self getStat(idx):" + self getStat(idx));
				
			if(self getStat(idx) == 0)
			continue;		
			
			founditens++;
			
			if(SelectedA == 0)
			{
				SelectedA = idx;
				continue;
			}
			
			if(SelectedA != 0 && SelectedB == 0)
			{
			SelectedB = idx;
			continue;
			}
			
			if(SelectedA != 0 && SelectedB != 0 && SelectedC == 0)
			{
			SelectedC = idx;
			continue;
			}

			if(SelectedA != 0 && SelectedB != 0 && SelectedC != 0 && SelectedD == 0)
			{
				SelectedD = idx;
				continue;
			}		
			
			xwait( 0.01, false );
			
			//self setStat(idx,0);
		}
		
		
		if (founditens == 0)
		return false;	
		
		//4 ja selecionados, precisa remover um !
		if (founditens > 3)
		{
			if(GetUpgradeStatsreturnName(SelectedA) == response)
			return false;
			
			if(GetUpgradeStatsreturnName(SelectedB) == response)
			return false;
			
			if(GetUpgradeStatsreturnName(SelectedC) == response)
			return false;
			
			if(GetUpgradeStatsreturnName(SelectedD) == response)
			return false;
			
			self setClientDvar( "ui_upgradestatus", "Maximo 4 selecionados. remova um !");
			return true;
		}
		
		return false;
	}
}


UpgradeResetUpdate()
{
	
	
	if(self getStat(537) != 3)
	{
		self setClientDvar( "ui_upgradestatus", "Atualizando Tabela");
		
		for( idx = 501; idx <= 555; idx++ )
		{
			self setStat(idx,0);
			self iprintln("^1UpgradeResetUpdate: ^3"+ idx);
		}
		
		self setStat(537,3);
		
		self setClientDvar( "ui_upgradestatus", "Tabela Resetada");
	}
}
	
	
//4 = nome 3= price
GetUpgradePrice(response)
{
	item = tablelookup( "mp/aprimoramentos.csv", 2, response, 1 );
	return int(item);
}

//search name return idx
GetUpgradeStats(response)
{
	item = tablelookup( "mp/aprimoramentos.csv", 2, response, 0 );
	return int(item);
}

GetUpgradeStatsreturnName(idx)
{
	item = tablelookup( "mp/aprimoramentos.csv", 0, idx, 2 );
	return item;
}

SetUpgradeStat(upgrade,value)
{
	self setStat( int(tableLookup( "mp/aprimoramentos.csv", 2, upgrade, 0 )), value );	
}


Nadeimmune()
{
	self endon ("death");
	self endon ("disconnect");
	
	self.nadeimmune = true;
	wait(25);
	self.nadeimmune = false;
}




//FOR ALL PLAYERS
LoadUpgradesOnSpawn()
{
	//if(level.oldschool)	return;
		//definir alguns para nao gerar erros
	
	if(level.cod_mode == "torneio")
	{
		self ResetUpgradesStatus();
		return;
	}
	
	if (isDefined( self.pers["isBot"] ) && self.pers["isBot"])
	{
		BotLoadupgradesOnSpawn();
		return;
	}
	
	//iprintlnbold(self.name + " => LoadUpgradesOnSpawn -> ");
	
	if(!isDefined(self.class)) return;
	
	if(!isAlive(self)) return;

	self.upgradefolego = self IsUpgradesOn("upgradefolego");
	
	if(self.upgradefolego)
	self setPerk( "specialty_longersprint" );
	
	self.upgradefalldamage = self IsUpgradesOn("upgradefalldamage");
	self.upgradeprecisionshoot = self IsUpgradesOn("upgradeprecisionshoot");
	self.upgradebuffreset = self IsUpgradesOn("upgradebuffreset");
	
	//medic
	self.upgradefastrevive = self IsUpgradesOn("upgradefastrevive");
	self.upgradefastRegen = self IsUpgradesOn("upgradefastRegen");	
	self.upgrademedkitPack = self IsUpgradesOn("upgrademedkitPack");
	self.upgradeammopack = self IsUpgradesOn("upgradeammopack");
	
	self.upgradewalldamageresist = self IsUpgradesOn("upgradewalldamageresist");
	self.upgradefastchange = self IsUpgradesOn("upgradefastchange");
	self.upgradebombdisarmer = self IsUpgradesOn("upgradebombdisarmer");
	self.upgradehackspot = self IsUpgradesOn("upgradehackspot");
	self.upgradescavenger = self IsUpgradesOn("upgradescavenger");
	self.upgradeteargas = self IsUpgradesOn("upgradeteargas");
	self.upgradeposiondamage = self IsUpgradesOn("upgradeposiondamage");
	self.upgradecapturenaderesist = self IsUpgradesOn("upgradecapturenaderesist");	
	self.upgradesensorseeker = self IsUpgradesOn("upgradesensorseeker");
	self.upgradedropitems = self IsUpgradesOn("upgradedropitems");	
	self.upgrademedicsmoke = self IsUpgradesOn("upgrademedicsmoke");	
	//---------------
	self.dangercloser = self IsUpgradesOn("upgradedangercloser");
	self.takedown = self IsUpgradesOn("upgradetakedown");
	self.coldblooded = self IsUpgradesOn("upgradecoldblooded");
	self.incognito = self IsUpgradesOn("upgradeincognito");
	self.sitrep = self IsUpgradesOn("upgradesitrep");
	self.wallbang = self IsUpgradesOn("upgradewallbang");
	self.collateral = self IsUpgradesOn("upgradecollateral");
	self.medicpro = self IsUpgradesOn("upgrademedicpro");
	self.peripherals = self IsUpgradesOn("upgradeperipherals");
	
	//new 2024
	self.upgradespotondeath = self IsUpgradesOn("upgradespotondeath");
	self.upgradesensorgas = self IsUpgradesOn("upgradesensorgas");	
	self.upgradespydronepro = self IsUpgradesOn("upgradespydronepro");
	
	self.skillbuffpredator = self IsUpgradesOn("skillbuffpredator");
	self.skillbuffspydrone = self IsUpgradesOn("skillbuffspydrone");
	self.skillbuffcarepackage = self IsUpgradesOn("skillbuffcarepackage");
	
	//ao morrer resetar
	self.cur_buff_streak = 0;
	//SKILLS

	//temp
	//self.firearrow = self getStat(2386);
	//self.poisonarrow = self getStat(2394);
	
	
	self.ffkiller = false;
	self.spawnrope = undefined;//2397
	//if(self.upgradefastRegen)
	//self.upgradefastRegen = 5;
		
	
	if(self.sitrep)
	self setPerk( "specialty_detectexplosive" );
	
	
	if(self.class == "sniper")
	{
		self.isSniper = true;
		self setClientDvar( "jump_slowdownEnable",0);
	}

	if(level.atualgtype == "sd" && self.upgradebombdisarmer)
	{
		if(isDefined(game["defenders"]) && self.pers["team"] == game["defenders"])
		{
			//self iprintln("upgradebombdisarmer:" + self.upgradebombdisarmer);
			self.allowdestroyexplosives = true;
			self thread promatch\_spreestreaks::allowDefenderExplosiveDestroy();
			level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry( "any" );			
		}	
	}
	else self.allowdestroyexplosives = false;
	
	if(self.medicpro)
	{
		self.medic = true;
		self.healthmaster = true;
		self thread promatch\_medic::SetMedic();
			
		if(self.medicpro && self.upgradefastRegen)
		self thread maps\mp\gametypes\_healthoverlay::playerHealthRegen();
	}
	
	if(self.coldblooded)
	{
		self setPerk( "specialty_gpsjammer" );
	}
	
	if(self.peripherals)
	{
		self setClientDvar( "compassMaxRange", 2500 );
		self setClientDvar( "compassRadarPingFadeTime",2);
	}
	
}

ResetUpgradesStatus()
{
	//nao usar THREAD
	
	//REMOVE TODOS OS PERKS
	self clearPerks();
	
	self setClientDvar("player_footstepsThreshhold",1.0);
	self setClientDvars("compassEnemyFootstepEnabled",0,"compassEnemyFootstepMaxRange",0);
	self setClientDvar( "compassMaxRange", 1600 );
	self setClientDvars("jump_slowdownEnable",1,"jump_spreadAdd",40);

	self setClientDvar("ui_hud_hardcore_show_minimap",1);
	self setClientDvar("ui_minimap_show_enemies_firing",1);
	
	//reset buffs
	self setClientDvars("hud_enable",1,"ui_hud_obituaries",1);
	self setClientDvar( "g_compassShowEnemies",0);
	self setClientDvar( "compassRadarPingFadeTime",1);
	
	//ao tomar impacto de tiros o boneco reage
	//esta reduzido no mod nao é o padrao para melhorar registro de hit
	self setClientDvar("bg_viewKickScale",0.2);
	self setClientDvar("bg_viewKickMax",50.0);
	self setClientDvar("bg_viewKickMin",2.0);
	self setClientDvar("bg_viewKickRandom",0.2);

	//LOOTING
	self.quadxp = false;
	self.vampirism = false;
	
	//TEAMBUFF;
	self.usingbuff = false;
	self.immune = undefined;
	self.allowanyweapons = undefined;
	self.tgrhack = undefined;
	self.onhack = undefined;
	//HEALTH
	self.totalMedkits = 0;
	self.medic = false;
	self.medicpro = false;
	self.ffkiller = false;	
	//ARMOR	
	self.currentarmor = 0;
	
	self.flakjacket = false;
	self.tacresist = false;
	self.flakkev = false;	
	//DAMAGE
	self.onehs = false;
	self.lethal = false;
	self.dangercloser = false;
	self.hpround = false;//oldschool
	self.piecinground = false;
	self.wallbang = false;
	self.sonicbullet = false;
	self.oneshootkill = undefined;
	self.droppedmagWeapon = undefined;
	self.stoppoison = undefined;
	self.resilience = false;
	//DETECTION	
	self.sitrep = false;
	self.sixthsense = false;	
	self.stronger = false;		
	self.takedown = false;
	self.incognito = false;
	self.coldblooded = false;
	//SKILL
	self.steadyaim = false;	
	self.peripherals = false;
	self.precisionshoot = false;
	self.steeljacket = false;
	
	//ARROWS
	self.poisonedarrow	= undefined;
	self.shockedbyarrow = undefined;
	self.firearrow = 0;
	self.poisonarrow = 0;
	self.shockarrow = 0;
	
	//buymenu reset
	self.gasmask = 0;
	self.fmjammo = 0;
	self.defusekit = 0;
	self.helmet = 0;
	self.antipoison = 0;
	self.antimag = 0;
	self.perfarrow = 0;
	self.ammobox = 0;
	self.fmjammo = 0;
	self.hpammo = 0;
	self.heavykevlar = 0;
	self.upgradefolego = false;
	self.carepackage = 0;
	self.com_drop_rope = 0;	
	self.onfire = undefined;
	
	//if(self.upgradefolego)
	self setPerk( "specialty_longersprint" );
	
	self.upgradefalldamage = false;
	self.upgradeprecisionshoot  = false;
	self.upgradebuffreset  = false;
	
	//medic
	self.upgradefastrevive  = false;
	self.upgradefastRegen  = false;
	self.upgrademedkitPack  = false;
	self.upgradeammopack  = false;
	
	self.upgradewalldamageresist  = false;
	self.upgradefastchange  = false;
	self.upgradebombdisarmer  = false;
	self.upgradehackspot  = false;
	self.upgradescavenger  = false;
	self.upgradeteargas  = false;
	self.upgradeposiondamage  = false;
	self.upgradecapturenaderesist  = false;
	self.upgradesensorseeker  = false;
	self.upgradedropitems  = false;
	self.upgrademedicsmoke  = false;
	//---------------
	self.dangercloser  = false;
	self.takedown  = false;
	self.coldblooded  = false;
	self.incognito  = false;
	self.sitrep  = false;
	self.wallbang  = false;
	self.collateral  = false;
	self.medicpro  = false;
	self.peripherals  = false;
	self.nadeimmune = false;
	
	//new 2024
	self.upgradespotondeath = false;
	self.upgradesensorgas = false;
	self.upgradespydronepro = false;
	
	self.skillbuffpredator = false;
	self.skillbuffspydrone = false;
	self.skillbuffcarepackage = false;
	
	//ao morrer resetar
	self.cur_buff_streak = 0;
	//SKILLS

	//temp
	//self.firearrow = self getStat(2386);
	//self.poisonarrow = self getStat(2394);
	
	
	self.ffkiller = false;
	self.spawnrope = undefined;//2397
	
	
}


	
//---------------------------------------------------------
//------MENUS DE UPGRADES END---------
//---------------------------------------------------------

//registra o valor inicial
registrarupgrades()
{
	self endon("disconnect");
	
	//impedir uma segunda execucao do mesmo codigo
	if(isDefined(self.registrarupgrades))
	return;

	self.registrarupgrades = true;
		
	for( idx = 501; idx <= 555; idx++ )
	{
		
		if(!isDefined(self))
		return;
		
		if(self getStat(idx) == 0)
		continue;		
		
		xwait( 0.01, false );
		
		self setStat(idx,0);
	}
	
	for( idx = 2000; idx <= 2036; idx++ )
	{
		if(!isDefined(self))
		return;
		
		if(self getStat(idx) == 0)
		continue;
		
		xwait( 0.01, false );
	
		self setStat(idx,0);
	}
	
	
	//self.inupdate = undefined;
	//self setClientDvar( "ui_versionupdate", "concluido" );
	
	//self iprintln("^1Sistema Atualizado");
}

adminmsg(msg)
{
	self iprintln("^3##^1 "+ msg +" ^3##");
}


//INSIGNIA
CreateOverHeadIcon()
{
	self endon( "death" );
	self endon("disconnect");

	//iprintln("ISI: " + self getstat(209) );
	
	//da um tempo apos o Spawn para outras funçoes.
	xwait( 6, false );

	myinsignia = 7;
	
	/*myinsignia = self statGets("INSIGNIA");
	
	self iPrintLn("CreateOverHeadIcon: " + myinsignia);
	
	if(!isDefined(myinsignia))
	{
		myinsignia = 1;
		self statSets("INSIGNIA",1);
	}
	
	if(myinsignia == 0)
		return;*/
	
	if ( isDefined( self.headIconShader ) && self.headIconShader ) 
	{
		return;
	}
	else 
	{
		self.headIconShader = true;
	}
	
	shader = "insignia" + myinsignia;

	self iPrintLn("CreateOverHeadIcon shader: " + shader);

	//mostra para meu time
	objWorld = newTeamHudElem( self.pers["team"] );		
	IconOffset = (0,0,75);	
	origin = self.origin + IconOffset;
	objWorld.name = self.name +"_" + shader;//tem quer ser um nome unico?
	objWorld.x = origin[0];
	objWorld.y = origin[1];
	objWorld.z = origin[2];
	objWorld.baseAlpha = 1.5;
	objWorld.isFlashing = false;
	objWorld.isShown = true;
	objWorld setShader( shader, level.objPointSize, level.objPointSize );
	objWorld setWayPoint( true,shader);
	objWorld setTargetEnt( self );//usado para seguir o jogador

	self thread deleteOverHeadIconOnDeath(objWorld );	
}

deleteOverHeadIconOnDeath(objWorld)
{
	self waittill_any( "death", "disconnect");	
		
	// Make sure this player can be pointed out again
	if ( isDefined( self ) )
		self.headIconShader = false;

	// Wait some time to make sure the main loop ends	
	xwait( 0.25, false );
	
	if ( isDefined( self ) )
	objWorld cleartargetent( self );
	
	objWorld destroy();
}

//ICONES DA CLASSE
CreateClassIcon(shader)
{
	self endon("disconnect");
	self endon( "death" );
	
	//por hora sommente em SD
	if(level.atualgtype != "sd")
	return;
	
	xwait( 3, false );
	
	if(isdefined(self))
	{
		if(self.pers["team"] == "allies")
		{
			self.headicon = shader;
			self.headiconteam = "allies";
		}
		else
		{
			self.headicon = shader;
			self.headiconteam = "axis";
		}
	}
	
	xwait( 6, false );
	

	if(isdefined(self))
	self.headicon = "";	
}

CreateObjectFiring(nade)
{
	self endon("death");
	self endon("disconnect");
	self endon( "decoy_deleted" );
	
	if(!isDefined(nade.origin))
	return;
	
	self.droppeddecoy = true;
	shader = "compassping_enemyfiring";
	

	// Get the next objective ID to use
	objCompass = maps\mp\gametypes\_gameobjects::getNextObjID();
	if ( objCompass != -1 ) 
	{
		//pair 'undefined' and '(0, 0, 75)
		//spawn no ponto da nade
		objective_add( objCompass, "active", nade.origin + (0,0,75) );
		objective_icon( objCompass, shader );
		objective_onentity( objCompass, nade );
		if ( level.teamBased ) 
		{
			//mostrar no radar inimigo apenas
			objective_team( objCompass,  level.otherTeam[ self.pers["team"] ]  );
		}
	}
	randomweap = randomint(8);
	weaponname = "weap_ak47_fire_npc";
	if(randomweap ==1)
	weaponname = "weap_ak74_fire_npc";
	if(randomweap ==2)
	weaponname = "weap_ak47_fire_npc";
	if(randomweap ==3)
	weaponname = "weap_tavor_fire_npc";
	if(randomweap ==4)
	weaponname = "weap_aug_fire_npc";
	if(randomweap ==5)
	weaponname = "weap_miniuzisd_fire_npc";
	if(randomweap ==6)
	weaponname = "weap_g36c_fire_npc";
	if(randomweap ==7)
	weaponname = "weap_miniuzisd_fire_npc";
	if(randomweap ==8)
	weaponname = "weap_mp5_fire_npc";
	
	
	self thread deleteDecoyOnDeath(objCompass );
	fired = 0;
	while(fired < 20)
	{
		//fires = randomint(6);
		//nade randomshoots(fires,weaponname);
		wait( randomfloatrange( 0.1, 0.7 ) );
		nade playsound(weaponname);
		wait( randomfloatrange( 0.2, 1.0 ) );
		//wait fires;
		fired++;
	}
	self notify("decoy_deleted");
}

deleteDecoyOnDeath(objCompass )
{
	self waittill_any( "killed_player", "disconnect","decoy_deleted");
	
	if ( isDefined( self ) )
	self.droppeddecoy = undefined;
	
	if ( objCompass != -1 ) 
	{
		objective_delete( objCompass );
		maps\mp\gametypes\_gameobjects::resetObjID( objCompass );
	}
}

randomshoots(shoots,weaponname)
{
	self endon("death");
	self endon( "decoy_deleted" );
	
	if(!isdefined(self))
		return;
	
	if(shoots == 1)
	{
		self playsound(weaponname);
	}
	
	if(shoots == 2)
	{
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
	}
	
	if(shoots == 3)
	{
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
	}
	
	if(shoots == 4)
	{
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
		wait 0.1;
	}
	if(shoots == 5)
	{
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
	}
	
	if(shoots == 6)
	{
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
		wait 0.1;
		self playsound(weaponname);
	}
}

MagicBullet(weapon, start, end, owner)
{   
	if(isDefined(end) && isDefined(start))
	{
		angles = VectorToAngles(end - start);
		//spawnar 1x so
		if(!isdefined(level.bulletspawner))
		{   
			level.bulletSpawner = spawnHelicopter(owner, start, angles, "cobra_mp", "tag_origin");
			level.bulletSpawner SetMaxPitchRoll(360, 360);
			level.bulletSpawner hide();
		}
		
		level.bulletSpawner.origin = start;
		level.bulletSpawner.angles = angles;
		level.bulletSpawner.owner = owner;
		level.bulletSpawner setVehWeapon(weapon);
		level.bulletSpawner fireWeapon("tag_origin");
		level.bulletSpawner.origin = (0,0,100000);
		//level.bulletSpawner playsound( "weap_minigun_fire_plr" );
	}
}
/*
blead_on_death( offset )
{
	if( !isdefined(offset) )
		offset = 45;
	self waittill ("death");
	self blead( offset );
}

blead( offset )
{
	if( !isdefined(offset) )
		offset = 45;
	org = groundpos( self gettagorigin( "J_Head" ) );
	org+= vector_multiply( vectornormalize( flat_origin(level.player.origin)-flat_origin(org ) ),offset );
	wait .5;
	PlayFX( level._effect[ "bloodpool" ], org+(0,0,-.95), ( 0, 0, 1 ) );
}


helmetPop()
{
	if ( !isdefined( self ) )
		return;
	if ( !isdefined( self.hatModel ) )
		return;
	// used to check self removableHat() in cod2... probably not necessary though
	
	partName = GetPartName( self.hatModel, 0 );
	model = spawn( "script_model", self.origin + (0,0,64) );
	model setmodel( self.hatModel  );
	model.origin = self GetTagOrigin( partName ); //self . origin + (0,0,64);
	model.angles = self GetTagAngles( partName ); //(-90,0 + randomint(90),0 + randomint(90));
	model thread helmetLaunch( self.damageDir );

	hatModel = self.hatModel;
	self.hatModel = undefined;
	
	wait 0.05;
	
	if ( !isdefined( self ) )
		return;
	self detach( hatModel, "" );
}

helmetLaunch( damageDir )
{
    launchForce = damageDir;
	launchForce = launchForce * randomFloatRange( 1100, 4000 );

	forcex = launchForce[0];
	forcey = launchForce[1];
	forcez = randomFloatRange( 800, 3000 );
	
	contactPoint = self.origin + ( randomfloatrange(-1,1), randomfloatrange(-1,1), randomfloatrange(-1,1) ) * 5;
	
	self physicsLaunch( contactPoint, (forcex, forcey, forcez) );
	
	wait 60;
	
	while(1)
	{
		if ( !isdefined( self ) )
			return;
		
		if ( distanceSquared( self.origin, level.player.origin ) > 512*512 )
			break;
		
		wait 30;
	}
	
	self delete();
}

*/

bodyparts()
{
	return gettaglist();
}

firespread(eInflictor,eAttacker)
{
	self endon("disconnect");
	self endon("death");	

	if(isDefined( self.onfire ) && self.onfire )
	return;
	
	bodyparts = bodyparts();	
	self.tagsonfire = [];
	
	//barrelignte FX
	playfx(level.arrowignite_fx, self.origin);
	
	self.onfire = true;
	
	self thread playonfirescream();
	
	while( isDefined(self) && isAlive(self) && self.sessionstate == "playing" ) 
	{		
		wait(level.oneFrame);		

		tagonfire = 0;
		for( i = 0; i < bodyparts.size; i++ ) 
		{
			self.tagsonfire[ i ] = bodyparts[ i ];
			
			//not repeat on same tag
			if(self checktagburning( bodyparts[ i ] ) )
			{
				playFXOnTag( level.firearrowfx, self, bodyparts[ randomInt(12) ] );
			}
			
			tagonfire++;
			
			if( tagonfire >= 3 ) 
			{
				wait(level.oneFrame);
				tagonfire = 0;
			}
		}
		
		//wait(1);
		self finishPlayerDamage(eAttacker,eAttacker,5,0,"MOD_PROJECTILE_SPLASH","gl_m16_mp",self.origin,self.origin,"none",0);
	}	

}

playonfirescream()
{
	self endon("disconnect");
	self endon("death");
	
	while( isDefined(self) && isAlive(self) && self.sessionstate == "playing" ) 
	{		
		wait(1);
		self playSound( "scream0" + randomInt(2));
	}		

}


checktagburning( tagpart ) 
{
	if( !isDefined( self.onfire ) )
		return false;
	
	for( i = 0; i < self.tagsonfire.size; i++ ) 
	{
		if( self.tagsonfire[ i ] == tagpart )
			return true;
	}
	return false;
}

//taglist for body parts
gettaglist() 
{
	taglist = [];
	taglist[ taglist.size ] = "j_wristtwist_ri";
	taglist[ taglist.size ] = "j_wristtwist_le";	
	taglist[ taglist.size ] = "j_shoulder_ri";
	taglist[ taglist.size ] = "j_shoulder_le";
	taglist[ taglist.size ] = "j_elbow_bulge_ri";
	taglist[ taglist.size ] = "j_elbow_bulge_le";
	taglist[ taglist.size ] = "j_spineupper";
	taglist[ taglist.size ] = "j_ankle_ri";
	taglist[ taglist.size ] = "j_ankle_le";
	taglist[ taglist.size ] = "j_knee_le";
	taglist[ taglist.size ] = "j_hiptwist_ri";
	taglist[ taglist.size ] = "j_hiptwist_le";
	taglist[ taglist.size ] = "j_knee_ri";
	taglist[ taglist.size ] = "j_spinelower";
	return taglist;
}

groundpos( origin )
{
	return bullettrace( origin, ( origin + ( 0, 0, -100000 ) ), 0, self )[ "position" ];
}


flat_originx(org)
{
	rorg = (org[0],org[1],0);
	return rorg;

}

putfireonbodty()
{
	self endon("disconnect");
	
	wait 2; 	
	
	if(!isDefined(self))
	return;

	playfx(level.barrel_fire_fx, self gettagorigin( "j_spinelower" ));
	
	playfx(level.barrel_fire_fx, self gettagorigin( "j_knee_le"));
}

bloodongrenade()
{
	self endon("disconnect");
	
	wait 2; 	
	
	if(!isDefined(self))
	return;
	
	if(!isDefined(level.spill_bloodfx))
	return;	
	
	org1 = self gettagorigin( "j_knee_le" );//j_spinelower //J_Head	
	org2 = self gettagorigin( "tag_origin" );
	org3 = self gettagorigin( "j_shoulder_le" );
	
	PlayFX(level.fataheadhitfx, self.origin);	
	wait 0.4;
	//type undefined is not an int: (file 'promatch/_utils.gsc', line 5745)
	if(isDefined(self) && isDefined(org1))
	PlayFX( level.spill_bloodfx, org1, ( 0, 0, 1 ) );
	wait 0.5;
	if(isDefined(self) && isDefined(org2))
	PlayFX( level.spill_bloodfx, org2, ( 0, 0, 1 ) );
	wait 0.5;
	if(isDefined(self) && isDefined(org3))
	PlayFX( level.spill_bloodfx, org3, ( 0, 0, 1 ) );
	

}

bloodonarrow()
{
	self endon("disconnect");
	self endon("death");
	
	if(!isDefined(self))
	return;
	
	if(!isDefined(level.spill_bloodfx))
	return;
	
	if(!isAlive(self))
	return;
	
	if(isDefined(self.arrowbleeding))
	return;
	
	victim = self;
	victim.arrowbleeding =  true;
	victim.bleedtime = 0;
	bodyparts = bodyparts();
	
	playFXOnTag( level.fataheadhitfx, victim, bodyparts[ randomInt(12) ] );
	
	for (;;)
	{
		xwait(1,false);
		victim.bleedtime++;
		
		if(isDefined(victim.stoppoison))
		break;
		
		//victim playSound(victim.myPainSound);
		playFXOnTag( level.spill_bloodfx, victim, bodyparts[ randomInt(12) ] );
		
		if (victim.bleedtime > 4)
		break;
				
		//morto
		if (victim.health <= 0)
		break;		
	}	
}

/*
Blood_pump( timer, model, rate )
{
	timer = timer * ( 1 / rate );
	for ( i = 0; i < timer; i++ )
	{
		playfxontag( getfx( "blood" ), model, "J_Shoulder_LE" );
		wait( rate );
	}
}

blood_pool()
{
	self endon( "stop_blood" );
	wait( 1 );
	blood_pool = getent( "blood_pool", "targetname" );
	z = blood_pool.origin[ 2 ];

	for ( ;; )
	{
		start = self gettagorigin( "J_Shoulder_LE" ) + (0,0,50);
		end = start + (0,0,-250);
		trace = bullettrace( start, end, false, undefined );
		pos = ( trace[ "position" ][ 0 ], trace[ "position" ][ 1 ], z );
		playfx( getfx( "blood_pool" ), pos, ( 0, 0, 1 ) );
		wait( 0.35 );
	}
}
*/


Blood_pump( timer, model, rate )
{
	org = self gettagorigin( "J_Shoulder_LE" );
	timer = timer * ( 1 / rate );
	for ( i = 0; i < timer; i++ )
	{
		PlayFX( level.spill_bloodfx,org, ( 0, 0, 1 ));
		wait( rate );
		PlayFX( level.fataheadhitfx, org, ( 0, 0, 1 ));
	}
}


bodybleed( timewait,hs)
{
	self endon("disconnect");

	wait timewait; 	
	
	if(!isDefined(self))
	return;
	
	if(!isDefined(level.spill_bloodfx))
	return;
	
	
	if(hs)
	{
		tagorg = self getTagOrigin( "j_spineupper" );
		
		if(isDefined(tagorg))
		{		
			org = groundpos(tagorg);//j_spinelower //J_Head j_neck
			
			if(isDefined(org))
			PlayFX( level.deathfx_bloodpoolfx, self.origin);
			
			if(isDefined(org))
			PlayFX( level.spill_bloodfx, org, ( 0, 0, 1 ) );
		}		
	}
	else
	{
		tagorg = self getTagOrigin( "j_spineupper" );
		
		if(isDefined(tagorg))
		{
			org = groundpos( tagorg );
			
			if(isDefined(org))
			PlayFX( level.spill_bloodfx, org, ( 0, 0, 1 ) );
			wait 0.4;
			if(isDefined(org))
			PlayFX( level.spill_bloodfx, org, ( 0, 0, 1 ) );
			wait 0.4;
			if(isDefined(org))
			PlayFX( level.spill_bloodfx, org, ( 0, 0, 1 ) );
			wait 0.4;
			if(isDefined(org))
			PlayFX( level.spill_bloodfx, org, ( 0, 0, 1 ) );
		}			
	}
	
}


attachplayertoit(where,to)
{
	playerhand = spawn("script_model", where );
	playerhand  setModel( "tag_origin" );
	//self.playerhand linkto(self);
	self linkto(playerhand);
	wait 0.2;//time for magposition
	playerhand moveto ( to.magposition +  (0, 0, -60),1);
	wait 1;
	playerhand unlink();
	self unlink();
	playerhand delete();
}

//model
objectlaunch( damageDir )
{
    launchForce = damageDir;
	launchForce = launchForce * randomFloatRange( 1100, 4000 );

	forcex = launchForce[0];
	forcey = launchForce[1];
	forcez = randomFloatRange( 800, 3000 );
	
	contactPoint = self.origin + ( randomfloatrange(-1,1), randomfloatrange(-1,1), randomfloatrange(-1,1) ) * 5;
	
	self physicsLaunch( contactPoint, (forcex, forcey, forcez) );
	
	wait 60;
	
	while(1)
	{
		if ( !isdefined( self ) )
			return;
		
		if ( distanceSquared( self.origin, level.player.origin ) > 512*512 )
			break;
		
		wait 30;
	}
	
	self delete();
}


//spread on enemy team
//self = victim
Poisonspread(eAttacker)
{
	team = self.pers["team"];
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];    
   
		if ( player.pers["team"] == team && self != player && isAlive( player ) )
		{       
			distance = distance( self.origin, player.origin );
			if ( distance < 160 ) 
			{
				//aplica aos players
				player thread PoisonedArrow(eAttacker);
			} 
		}
	}
}

shockspread(eAttacker)
{
	team = self.pers["team"];
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];    
   
		if ( player.pers["team"] == team && self != player && isAlive( player ) )
		{       
			distance = distance( self.origin, player.origin );
			if ( distance < 160 ) 
			{
				//aplica aos players
				player thread simplearroshock(eAttacker);
			} 
		}
	}
}

simplearroshock(eAttacker)
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	if(game["state"] == "postgame") return;
	
	if(!isDefined(self))
	return;
	
	victim = self;
	
	if ( victim.health <= 0 )
	{
		assert( !isalive( victim ) );
		return;
	}
	
	if(isDefined(victim.shockedbyarrow))
	return;
		
	if(victim.heavykevlar > 0)
	return;
	
	//cannot cast undefined to bool: (file 'promatch/_utils.gsx', line 4675)
	//undefined is not a field object: (file 'promatch/_utils.gsx', line 4676)
	if(!isDefined(victim.pers["team"]) || !isDefined(eAttacker.pers["team"]) )
	return;
	
	if ( victim.pers["team"] == eAttacker.pers["team"] )
	return;

	attackerarrow = eAttacker;
	
	//iprintln("poisoned!");
	victim.shockedbyarrow = true;

	
	victim playSound("shock1");
	victim shellshock("frag_grenade_mp", 2);
	victim playSound(victim.myPainSound);
	victim thread Nosprint(2);
	victim.shocktime = 0;
	bodyparts = bodyparts();
	playFXOnTag( level.fx_Sparks, self, bodyparts[ randomInt(12) ] );
	
	//shock disables stuffsss
	victim setclientdvar("cg_drawFriendlyNames",0);
	
	for (;;)
	{
		xwait(1,false);
		victim.shocktime++;
		//iprintln(victim.health + " Name: " + victim.name);
		//victim dosilentdamage(attackerarrow,1,"MOD_PROJECTILE_SPLASH","barrett_acog_mp","none");
		if(isDefined(victim.stoppoison))
		break;
		
		//victim playSound("shock2");
		victim playSound(victim.myPainSound);
		victim finishPlayerDamage(attackerarrow,attackerarrow,10,0,"MOD_PROJECTILE_SPLASH","gl_m16_mp",victim.origin,victim.origin,"none",0);
		victim.playerhealth.value setValue(victim.health);
		victim setStance("crouch");
		//victim thread weaponShockJammer();
		playFXOnTag( level.fx_Sparks, self, bodyparts[ randomInt(12) ] );
		self thread shiftPlayerView( 5 );
		
		if (victim.shocktime > 2)
		{
			victim.shockedbyarrow = undefined;
			break;
		}
		
		//morto
		if (victim.health <= 0)
		{
			victim.shockedbyarrow = undefined;
			break;
		}
	}	
	
}

//missing ADDSOUND FX!!!!
Doshockarrow(eAttacker)
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "joined_team" );
	self endon ( "joined_spectators" );
	level endon ( "game_ended" );
	
	if(game["state"] == "postgame") return;
	
	if(!isDefined(self))
	return;
	
	if(!isDefined(eAttacker))
	return;
	
	if(!isPlayer(eAttacker)) return;
	
	victim = self;

	if ( victim.health <= 0 )
	{
		assert( !isalive( victim ) );
		return;
	}
	
	if(isDefined(victim.shockedbyarrow))
	return;
		
	if(victim.heavykevlar > 0)
	return;
	
	//cannot cast undefined to bool: (file 'promatch/_utils.gsx', line 4675)
	//undefined is not a field object: (file 'promatch/_utils.gsx', line 4676)
	if(!isDefined(victim.pers["team"]) || !isDefined(eAttacker.pers["team"]) )
	return;
	
	if ( victim.pers["team"] == eAttacker.pers["team"] )
	return;

	attackerarrow = eAttacker;
	
	//iprintln("poisoned!");
	victim.shockedbyarrow = true;

	
	victim playSound("shock1");
	victim shellshock("frag_grenade_mp", 2);
	victim playSound(victim.myPainSound);
	victim thread Nosprint(4);
	victim.shocktime = 0;
	bodyparts = bodyparts();
	playFXOnTag( level.fx_Sparks, self, bodyparts[ randomInt(12) ] );
	
	//shock disables stuffsss
	victim setclientdvar("cg_drawFriendlyNames",0);
	victim thread shockspread(eAttacker);
	
	for (;;)
	{
		xwait(2,false);
		victim.shocktime++;
		//iprintln(victim.health + " Name: " + victim.name);
		//victim dosilentdamage(attackerarrow,1,"MOD_PROJECTILE_SPLASH","barrett_acog_mp","none");
		
		if(isDefined(victim.stoppoison))
		break;
		
		victim playSound("shock2");
		victim playSound(victim.myPainSound);
		victim finishPlayerDamage(attackerarrow,attackerarrow,10,0,"MOD_PROJECTILE_SPLASH","gl_m16_mp",victim.origin,victim.origin,"none",0);
		victim.playerhealth.value setValue(victim.health);
		victim setStance("crouch");
		victim thread weaponShockJammer();
		playFXOnTag( level.fx_Sparks, self, bodyparts[ randomInt(12) ] );
		self thread shiftPlayerView( 10 );
		
		if (victim.shocktime > 3)
		{
			victim.shockedbyarrow = undefined;
			break;
		}
		
		//morto
		if (victim.health <= 0)
		{
			victim.shockedbyarrow = undefined;
			break;
		}
	}	
}

weaponShockJammer()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	wait level.oneFrame;
	
	// Get the current weapon
	currentWeapon = self getCurrentWeapon();			

	currentAmmo = self getAmmoCount( currentWeapon );
	if ( currentAmmo > 1 ) 
	{
	
		if ( self attackButtonPressed() && randomInt( 4 ) == 1 ) 
		{

			self.jammedWeaponAmmo = self getAmmoCount( currentWeapon ) - 1;
			self setWeaponAmmoStock( currentWeapon, 0 );
			self setWeaponAmmoClip( currentWeapon, 0 );	
			xwait (0.8,false);
			//self playLocalSound( "US_1mc_rsp_comeon" );
			
			self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
			if(isDefined(self.jammedWeaponAmmo))
			self setWeaponAmmoStock( currentWeapon, self.jammedWeaponAmmo );
			else
			self setWeaponAmmoStock( currentWeapon, 15 );
			
		
			//self playLocalSound( "scramble" );

			xWait(2,false);

			self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
	
		}				
	}
}

//class unranked
PoisonedArrow(eAttacker)
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "joined_team" );
	self endon ( "joined_spectators" );
	level endon ( "game_ended" );
	
	if(game["state"] == "postgame") return;
	
	if(!isDefined(self))
	return;
	
	if(!isDefined(eAttacker))
	return;

	if(!isPlayer(eAttacker)) return;

	if ( self.health <= 0 )
	{
		assert( !isalive( self ) );
		return;
	}
	
	if(isDefined(self.poisonedarrow))
	return;
		
	if(self.antipoison > 0)
	return;
	
	//cannot cast undefined to bool: (file 'promatch/_utils.gsx', line 4675)
	//undefined is not a field object: (file 'promatch/_utils.gsx', line 4676)
	if(!isDefined(self.pers["team"]) || !isDefined(eAttacker.pers["team"]) )
	return;
	
	if ( self.pers["team"] == eAttacker.pers["team"] )
	return;

	attackerarrow = eAttacker;
	
	//iprintln("poisoned!");
	self.poisonedarrow = true;

	player = self;
	player playSound( "gas1" );
	player shellshock("frag_grenade_mp", 1);
	player playSound( "smoke_coughing_loop" );
	
	bodyparts = bodyparts();
	
	
	for (;;)
	{
		xwait(1,false);
		
		//iprintln(player.health + " Name: " + player.name);
		//player dosilentdamage(attackerarrow,1,"MOD_PROJECTILE_SPLASH","barrett_acog_mp","none");
		if(isDefined(player.stoppoison))
		break;
		
		playFXOnTag( level.poisongasfx, self, bodyparts[ randomInt(12) ] );
		player finishPlayerDamage(attackerarrow,attackerarrow,10,0,"MOD_PROJECTILE_SPLASH","gl_m16_mp",self.origin,self.origin,"none",0);
		player.playerhealth.value setValue(player.health);
		//morto
		if (player.health <= 0)
		{
			player.poisonedarrow = undefined;
			break;
		}
	}	
}

DamageArea(Point,Radius,MaxDamage,MinDamage,Weapon,TeamKill)
{
	KillMe = false;
	Damage = MaxDamage;
	for(i=0;i<level.players.size+1;i++)
	{
		DamageRadius = distance(Point,level.players[i].origin);
		if(DamageRadius<Radius)
		{
			if(MinDamage<MaxDamage)
			Damage = int(MinDamage+((MaxDamage-MinDamage)*(DamageRadius/Radius)));
			
			if((level.players[i] != self) && ((TeamKill && level.teamBased) || ((self.pers["team"] != level.players[i].pers["team"]) && level.teamBased) || !level.teamBased))
			level.players[i] FinishPlayerDamage(level.players[i],self,Damage,0,"MOD_PROJECTILE_SPLASH",Weapon,level.players[i].origin,level.players[i].origin,"none",0);
		
			if(level.players[i] == self)
			KillMe = true;
		}
		wait 0.01;
	}
	RadiusDamage(Point,Radius-(Radius*0.25),MaxDamage,MinDamage,self);
	if(KillMe)
	self FinishPlayerDamage(self,self,Damage,0,"MOD_PROJECTILE_SPLASH",Weapon,self.origin,self.origin,"none",0);
}


CreateExplosion()
{
	phyExpMagnitude = 2.5;
	minDamage = 1;
	maxDamage = 250;
	blastRadius = 190;

	self radiusDamage( self.origin + ( 0, 0, 30 ), blastRadius, maxDamage, minDamage, self, "MOD_PROJECTILE_SPLASH", "" );
	physicsExplosionSphere( self.origin + ( 0, 0, 30 ), blastRadius, blastRadius/2, phyExpMagnitude );
	self maps\mp\gametypes\_shellshock::barrel_earthQuake();
	/*
	playfx( level._effect["self_explode"], self.origin );
	                self playSound( "grenade_explode_default" );
                    self notify( "cranked_over" );
	                self suicide();
	*/
}

Weapondrophit(eAttacker)
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	if ( self.pers["team"] == eAttacker.pers["team"] )
	return;
	
	currentWeapon = self getCurrentWeapon();
	self playlocalsound("MP_hit_alert");
	self dropItem( currentWeapon );
	
}

dodamage(attacker,damage)
{
	self thread maps\mp\gametypes\_globallogic::callback_PlayerDamage( attacker, attacker, damage, 0, "MOD_EXPLOSIVE", "none", ( 0,0,0 ), ( 0,0,0 ), "chest", 0 );
}


dosilentdamage(attacker,damage,smeans,sweapon,hitloc)
{
	//nao usar thread
	self FinishPlayerDamage(attacker,attacker,damage,0,smeans,sweapon,self.origin,self.origin,hitloc,0);
}


/*

models = GetEntArray("script_model","classname");
for(i=0;i<models.size;i++)
    models[i] delete();
smodels = GetEntArray("script_brushmodel","classname");
for(i=0;i<smodels.size;i++)
    smodels[i] delete();
destructibles = GetEntArray("destructible","targetname");
for(i=0;i<destructibles.size;i++)
    destructibles[i] delete();
animated_models = getentarray( "animated_model", "targetname" );
for(i=0;i<animated_models.size;i++)
    animated_models[i] delete();
ents = getentarray("destructable", "targetname");
for(i=0;i<ents.size;i++)
    ents[i] delete();
barrels = getentarray ("explodable_barrel","targetname");
for(i=0;i<barrels.size;i++)
    barrels[i] delete();
radiationFields = getentarray("radiation", "targetname");
for(i=0;i<radiationFields.size;i++)
    radiationFields[i] delete();
level deletePlacedEntity("misc_turret");

*/
TraceModel()
{
	self endon("disconnect");
	self endon("death");
	
	//animated_models = getentarray( "animated_model", "targetname" );
	//for(i=0;i<animated_models.size;i++)
   // iprintln(animated_models[i].model);
	
	for(;;)
    {
        if(self adsButtonPressed() && self holdbreathbuttonpressed())
        {
            trace = bullettrace(self gettagorigin("j_head"),self gettagorigin("j_head")+anglestoforward(self getplayerangles())*1000000,true,self);
			if(isdefined(trace["entity"]))
			{
				if(isdefined(trace["entity"].model))
				{
					self iPrintln("Model: ^2" + trace["entity"].model);
					self iPrintln("Number: ^5" + trace["entity"] getEntityNumber());
					wait 0.2;
				}
				
				if(isdefined(trace["entity"].script_model))
				{
					self iPrintln("Model: ^2" + trace["entity"].script_model);
					//self iPrintln("Number: ^5" + trace["entity"] getEntityNumber());
					wait 0.2;
				}
				
				if(isdefined(trace["entity"].script_brushmodel))
				{
					self iPrintln("Model: ^2" + trace["entity"].script_brushmodel);
					//self iPrintln("Number: ^5" + trace["entity"] getEntityNumber());
					wait 0.2;
				}
				
				if(isdefined(trace["entity"].script_brushmodel))
				{
					self iPrintln("Model: ^2" + trace["entity"].script_brushmodel);
					//self iPrintln("Number: ^5" + trace["entity"] getEntityNumber());
					wait 0.2;
				}
			}
        }
        wait 0.05;
    }
}

//healthPackModel setModel( "hp_medium" );
SearchByModel(ModelName)
{
	ents = getEntArray();
	arrayents = [];
	for ( index = 0; index < ents.size; index++ )
	{
    	if(isSubStr(ents[index].model, ModelName))
		{
			arrayents[arrayents.size] = ents[index];
		}
	}
	
	return arrayents;	
}

DeleteByModel(Model)
{
	ents = getEntArray();
	for ( index = 0; index < ents.size; index++ )
	{
    	if(isSubStr(ents[index].model, Model))
    		ents[index] delete();
	}
}

DeleteByNumber(Number)
{
	ents = getEntArray();
	for ( index = 0; index < ents.size; index++ )
	{
    	if(ents[index] getEntityNumber() == Number)
    		ents[index] delete();
	}
}


/*
//NOVO ITENS
add_beacon_effect()
{
	self endon( "death" );
	
	flashDelay = 0.75;
	
	wait randomfloat(3.0);
	for (;;)
	{
		playfxontag( level._effect[ "beacon" ], self, "j_spine4" );
		wait flashDelay;
	}
}
*/
//retorna Ar de players
ArraySameTeam()
{
	if(!level.teamBased) return;
	
	players = level.players;
	
	level.sameTeam = [];//zera
	
	for ( i = 1; i < players.size; i++ )
		{
			
			if (!isDefined( players[i])) continue;
					
			//ignorar caso morto ou n jogando...
			if(!isAlive(players[i])) continue;		

			if(!isDefined(players[i].pers["team"])) continue;
					
			//meu time => player de outro time?
			if ( self.pers["team"] == players[i].pers["team"] )
			{
				//level.sameTeam += players[i];
				level.sameTeam[level.sameTeam.size] = players[i];				
			}			
		}
	
	return level.sameTeam;
}


isSameTeam(attacker)
{

	if(!level.teamBased) return false;

	if(!isDefined(self.pers["team"])) return false;
	
	if(!isDefined(attacker.pers["team"])) return false;
	
	if(self.pers["team"] == attacker.pers["team"]) return true;
	
	//qualquer outra coisa
	return false;
}


LifeAddUpdate(value)
{
	if(!isDefined(self)|| !isDefined(self.playerhealth))
	return;
	
	self.health += int(value);
	
	if(isDefined(self.playerhealth.value))
	self.playerhealth.value setValue(self.health);
}

LifeUpgrade(value)
{
	if(!isDefined(self)|| !isDefined(self.playerhealth))
	return;
	
	//if(self.health <= 101)
	//self.health += value;
	//else
	self.health += value;
	
	if(isDefined(self.playerhealth.value))
	self.playerhealth.value setValue(self.health);
}

ArmorUpgrade(value)
{
	if(!isDefined(self)|| !isDefined(self.playerarmor))
	return;
	
	if(isDefined(self.hasarmor))
	return;
	
	self.playerarmor.currentarmor = value;
	self.playerarmor.value setValue(value);
}

debugorigin()
{
// 	self endon( "killanimscript" );
// 	self endon( anim.scriptChange );
	self notify( "Debug origin" );
	self endon( "Debug origin" );
	self endon( "death" );
	for( ;; )
	{
		forward = anglestoforward( self.angles );
		forwardFar = vectorScale( forward, 30 );
		forwardClose = vectorScale( forward, 20 );
		right = anglestoright( self.angles );
		left = vectorScale( right, -10 );
		right = vectorScale( right, 10 );
		line( self.origin, self.origin + forwardFar, ( 0.9, 0.7, 0.6 ), 0.9 );
		line( self.origin + forwardFar, self.origin + forwardClose + right, ( 0.9, 0.7, 0.6 ), 0.9 );
		line( self.origin + forwardFar, self.origin + forwardClose + left, ( 0.9, 0.7, 0.6 ), 0.9 );
		wait( 0.05 );
	}
}

vector_multiplyx( vec, vec2 )
{
	vec = (vec[0] * vec2[0], vec[1] * vec2[1], vec[2] * vec2[2]);
	
	return vec;
}


/*watchRPGUsage()
{
	self endon( "death" );
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill ( "begin_firing" );

		if ( !level.inReadyUpPeriod )
		self.hasDoneCombat = true;

		curWeapon = self getCurrentWeapon();
		
		if(curWeapon == "rpg_mp" )
		{
			currammo = self GetItemStat("buyrpg");
			
			 if(currammo > 0)
			self setStat(2392,currammo - 1);
		}
		
		self waittill ( "end_firing" );
	}
}*/

watchFIREARROWsage()
{
	self endon( "death" );
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill ( "begin_firing" );

		if ( !level.inReadyUpPeriod )
		self.hasDoneCombat = true;

		curWeapon = self getCurrentWeapon();
		
		if(curWeapon == "gl_m16_mp" )
		{
			self thread maps\mp\gametypes\_weapons::firearrow_think(self,self.team);
		}
		
		self waittill ( "end_firing" );
	}
}

//compras
LifeBuy(value)
{
	if(!isDefined(self)|| !isDefined(self.playerhealth))
	return;
	
	self.health = value;
	self.playerhealth.value setValue(value);
}


// V1 = coluna  Dataname = Procurar oq?  V2 = coluna = resultado
itemvalueGet( dataName )//valor do item
{	
	if(!isdefined(self)) return;
	
	return self getStat( int(tableLookup( "mp/items.csv", 2, dataName, 1 )) );
}

itemstatus(dataName)//status do item, ex: armor esta em 40% ja.
{
	if(!isdefined(self)) return;	
	
	return self getStat( int(tableLookup( "mp/items.csv", 2, dataName, 1 )) );
}

itemSet( dataName, value )
{
	if(!isdefined(self)) return;
	
	self setStat( int(tableLookup( "mp/items.csv", 1, dataName, 0 )), value );	
}

itemAdd( dataName, value )
{	
	if(!isdefined(self)) return;
	
	curValue = self getStat( int(tableLookup( "mp/items.csv", 1, dataName, 0 )) );
	self setStat( int(tableLookup( "mp/items.csv", 1, dataName, 0 )), value + curValue );
}


isMoving()
{
	if ( lengthsquared( self getVelocity() ) < 10 )
	return false;
	else
	return true;
}

TakeScreenshot(player)
{
	if (isDefined( self.pers["isBot"]))
	return;
	
	exec("getss " + player getEntityNumber());
	
	self playLocalSound( "weap_ammo_pickup" );
	
	//loga no server
	self ScreenshotLog(player);
}


ScreenshotLog(player)
{
	level.writing = true;
	
	suspeitoid = player getGUID();
	quemtirouid = self getGUID();
		
	filename = "Screenshotlog.txt";

	diagravado = int(TimeToString(GetRealTime(),1,"%d"));
	mesgravado = int(TimeToString(GetRealTime(),1,"%m"));
	
	idfile = FS_FOpen(filename, "append");//id = 1
	if(idfile <= 0) 
	{
		logPrint("Erro ao gravar Arquivo ID: " + suspeitoid);
		return;
	}

	FS_WriteLine(1,"Quem tirou: " + self.name + " [ID] " + quemtirouid);
	FS_WriteLine(1, "Data: "+ diagravado+"/"+mesgravado);
	FS_WriteLine(1, "Suspeito: "+ player.name + " [ID] " + suspeitoid);
	FS_WriteLine(1,"------------------------------------------");
	FS_FClose(idfile);
	
	level.writing = false;
}

GiveSpecialNades(quantas,tipo)
{

	/*weaponsList = self getWeaponsList();
	
	for( i = 0; i < weaponsList.size; i++ )	
	{
		currentWeapon = weaponsList[i];
		
		if ( weaponClass( currentWeapon ) != "grenade" )
			continue;
			
		self takeWeapon( currentWeapon );
	}
	*/
	if(level.inStrategyPeriod || level.inReadyUpPeriod)
	{
		//passa informacao para o delaynade
		self.nadeitem = tipo;
		//iprintln("^1adicionada: " + tipodeitem);
		return;
	}
	
	
	self takeWeapon(self GetOffhandSecondaryClass() +"_grenade_mp");
	self takeWeapon("frag_grenade_mp");
	//da ao jogador as nades
	
	//primaria normal
	self giveWeapon( "frag_grenade_mp" );
	self setWeaponAmmoClip( "frag_grenade_mp", 1 );
	self switchToOffhand("frag_grenade_mp");
	//secundarias
	self setOffhandSecondaryClass("smoke");
	self giveWeapon( tipo );
	
	if(tipo == "frag_grenade_short_mp")
	self setWeaponAmmoClip( tipo, 12 );
	else
	self setWeaponAmmoClip( tipo, 1 );
	
	self.nadeitem = undefined;
	
}
//remova a nade atual e de nova ou refill
GiveSecondaryNades(quantas,tipo)
{

	//tirar granadas !
	
	//verificar se ele tem a nade??
	offhand = self getcurrentoffhand();
	iprintln("getcurrentoffhand: "+offhand);
	//self takeWeapon(self GetOffhandSecondaryClass() +"_grenade_mp");
	
	iprintln("getcurrentoffhand: "+offhand);
	//self takeWeapon("frag_grenade_mp");
	
	//da ao jogador as nades
	
	//primaria normal	
	//self giveWeapon( "frag_grenade_mp" );
	//self setWeaponAmmoClip( "frag_grenade_mp", 1 );
	//self switchToOffhand("frag_grenade_mp");
	//secundarias
	//self setOffhandSecondaryClass("smoke");
	//self giveWeapon( tipo );
	//self setWeaponAmmoClip( tipo, 1 );
	//self.nadeitem = undefined;
	
}
//alterar no futuro mecanica para o modelo novo 2024
Takeoffprimary()
{
	weaponsList = self getWeaponsList();
	
	for( i = 0; i < weaponsList.size; i++ )	
	{
		currentWeapon = weaponsList[i];
		
		//fix akimbo error no spawning
		//if(currentWeapon == "usp_silencer_mp")
		//continue;
		
		if(isNade(currentWeapon))
			continue;
			
		if(isPistol(currentWeapon))
			continue;
			
		self takeWeapon( currentWeapon );
	}
}

Takeoffnades()
{
	weaponsList = self getWeaponsList();
	
	for( i = 0; i < weaponsList.size; i++ )	
	{
		currentWeapon = weaponsList[i];
		
			//if ( weaponClass( currentWeapon ) != "grenade" )
			if(!isNade(currentWeapon))
			continue;		
			
		self takeWeapon( currentWeapon );
	}
}


Takeoffsecondary()
{

		weaponsList = self getWeaponsList();
		
		for( i = 0; i < weaponsList.size; i++ )	
		{
			currentWeapon = weaponsList[i];
				
			//if ( weaponClass( currentWeapon ) != "pistol" )
			if(!isPistol(currentWeapon))
			continue;
		
			self takeWeapon( currentWeapon );
		}
}


/*
main()
{
	self setModel("body_mp_arab_regular_sniper");
	self attach("head_mp_arab_regular_sadiq", "", true);
	self setViewmodel("viewhands_desert_opfor");
	self.voice = "arab";
}
*/

ChangeHeadType()
{
/*
	// Get all the attached models from the player
	attachedModels = self getAttachSize();
	
	// which one is the head and detach it
	for ( am=0; am < attachedModels; am++ ) 
	{
		thisModel = self getAttachModelName( am );
		iprintln(thisModel);
		// if this one is the head and remove it
		if ( isSubstr( thisModel, "head_mp_" ) ) 
		{
			self detach( thisModel, "" );
			break;
		}
		
		if ( isSubstr( thisModel, "body_mp_" ) ) 
		{
			self detach( thisModel, "" );
			break;
		}
				
	}
	*/
	self detachAll();
	
	randomhead = randomint(5);
	
	if(randomhead == 0)	
	{
		self setModel("body_mp_arab_regular_engineer");
		self attach("head_mp_usmc_tactical_mich", "", true);	
	}
	if(randomhead == 1)
	{
	self setModel("body_mp_usmc_recon");
	self attach("head_mp_usmc_tactical_baseball_cap", "", true);	
	}
	if(randomhead == 2)
	{
	self setModel("body_mp_usmc_recon");
	self attach("head_mp_usmc_shaved_head", "", true);	
	}
	if(randomhead == 3)
	{
	self setModel("body_mp_usmc_woodland_support");
	self attach("head_mp_usmc_nomex", "", true);	
	}
	if(randomhead == 4)
	{
	self setModel("body_mp_usmc_woodland_sniper");
	self attach("head_mp_usmc_ghillie", "", true);	
	}
	
	self setViewModel("viewhands_desert_opfor");
}

getweaponnamebyfilename(weaponnamefile)
{
	
	if ( tableLookup( "mp/weaponslist.csv", 4, weaponnamefile, 2 ) == "weapon_elite" )
	return "elite";
	
	if ( tableLookup( "mp/weaponslist.csv", 4, weaponnamefile, 2 ) == "weapon_assault" )
	return "assault";

	if ( tableLookup( "mp/weaponslist.csv", 4, weaponnamefile, 2 ) == "weapon_smg" )
	return "specops";

	if ( tableLookup( "mp/weaponslist.csv", 4, weaponnamefile, 2 ) == "weapon_lmg" )
	return "heavygunner";
	
	if ( tableLookup( "mp/weaponslist.csv", 4, weaponnamefile, 2 ) == "weapon_shotgun" )
	return "demolitions";

	if ( tableLookup( "mp/weaponslist.csv", 4, weaponnamefile, 2 ) == "weapon_sniper" )
	return "sniper";
}


//define the class
//10,5010,weapon_smg,MP5A3,mp5
getclassbyweapon(weaponnamefile)
{
	
	if ( tableLookup( "mp/weaponslist.csv", 4, weaponnamefile, 2 ) == "weapon_elite" )
	return "elite";
	
	if ( tableLookup( "mp/weaponslist.csv", 4, weaponnamefile, 2 ) == "weapon_assault" )
	return "assault";

	if ( tableLookup( "mp/weaponslist.csv", 4, weaponnamefile, 2 ) == "weapon_smg" )
	return "specops";

	if ( tableLookup( "mp/weaponslist.csv", 4, weaponnamefile, 2 ) == "weapon_lmg" )
	return "heavygunner";
	
	if ( tableLookup( "mp/weaponslist.csv", 4, weaponnamefile, 2 ) == "weapon_shotgun" )
	return "demolitions";

	if ( tableLookup( "mp/weaponslist.csv", 4, weaponnamefile, 2 ) == "weapon_sniper" )
	return "sniper";
}

validweaponclass(weaponName)
{
	//m14_acog
	if ( tableLookup( "mp/weaponslist.csv", 4, weaponName, 2 ) == "weapon_elite" )
	return true;
	
	if ( tableLookup( "mp/weaponslist.csv", 4, weaponName, 2 ) == "weapon_assault" )
	return true;

	if ( tableLookup( "mp/weaponslist.csv", 4, weaponName, 2 ) == "weapon_smg" )
	return true;

	if ( tableLookup( "mp/weaponslist.csv", 4, weaponName, 2 ) == "weapon_lmg" )
	return true;
	
	if ( tableLookup( "mp/weaponslist.csv", 4, weaponName, 2 ) == "weapon_shotgun" )
	return true;

	if ( tableLookup( "mp/weaponslist.csv", 4, weaponName, 2 ) == "weapon_sniper" )
	return true;
	
	return false;
}

SetClassbyWeapon( weaponName )
{
//==========================AUTO-REAPPLY=======================================================
	//AUTO-REAPPLY APOS TER JA SELECIONADA UM CLASSE O COMANDO GIVELOADOUT APENAS REAPLICA AQUI
	//weaponName = M16A3
	ShowDebug("SetClassbyWeapon-weaponName",weaponName);
	
	//retira nade compradas
	if(weaponName == "SMOKE" || weaponName == "FLASH" || weaponName == "HATCHET" || weaponName == "SEMTEX" )
	self ResetAllNadesonBuy();
	
	//nao foi atelterada a arma entao deve apenas dar as mesmas ao jogador
	if(weaponName == "none")
	{
		ShowDebug("weaponName=none[check1]-> ",weaponName);		
		
		self SetClasstoPlayer(weaponName);
		
		if(isDefined(self.pers[self.class]["loadout_primary"]))
		{
			
			self giveWeapon(self.pers[self.class]["loadout_primary"]);			
			self giveMaxAmmo( self.pers[self.class]["loadout_primary"] );		
			self setSpawnWeapon( self.pers[self.class]["loadout_primary"] );
			
			
			if (isDefined( self.pers["isBot"] ) && self.pers["isBot"])
			{
				self Takeoffprimary();		
				self.rdmweapon = giverandomweapon();
				self giveWeapon(self.rdmweapon);
				self giveMaxAmmo( self.rdmweapon);	
				self setSpawnWeapon( self.rdmweapon );
			}
		}
		else
		ShowDebug("AUTO-REAPPLY","^loadout_primary NAODEFINIDO");
		
		ShowDebug("loadout_secondary[check2]-> ",self.pers["loadout_secondary"]);		
		if(isDefined(self.pers["loadout_secondary"]))
		{
			self.pers["curr_seco"] = self.pers["loadout_secondary"];
			self giveWeapon( self.pers["loadout_secondary"] );	
			self giveMaxAmmo( self.pers["loadout_secondary"] );
			//self setSpawnWeapon( self.pers["loadout_secondary"]);
		}
		else
		ShowDebug("AUTO-REAPPLY","^1loadout_secondary NAODEFINIDO");
		
		self giveWeapon( "frag_grenade_mp" );
		self setWeaponAmmoClip( "frag_grenade_mp", 1 );
		//self switchToOffhand("frag_grenade_mp");
		
		self giveWeapon( self.pers["curr_sgrenade"]);
		
		if(self.pers["curr_sgrenade"] == "frag_grenade_short_mp")
		self setWeaponAmmoClip( self.pers["curr_sgrenade"], 12 );
		else
		self setWeaponAmmoClip( self.pers["curr_sgrenade"], 1 );
		//self switchToOffhand(self.pers["curr_sgrenade"]);
		
		self SetOffhandSecondary(self.pers["curr_sgrenade"]);		
	
		//ignorar todo o resto.
		//ShowDebug("AUTO-REAPPLY","playerModelForClass");
		//self maps\mp\gametypes\_teams::playerModelForClass( self.pers["class"] );
		return;
	}

//====================================================================================================
//SETCLASS BY WEAPONTYPE
//====================================================================================================
	
	
	//pegar a classe baseada na arma - m16_gl
	thisweaponclass = tableLookup( "mp/weaponslist.csv", 3, weaponName, 4 );	
	self SetClasstoPlayer(thisweaponclass);	//assault
	//m16_gl - ok
	ShowDebug("thisweaponclass[check3]-> ",thisweaponclass);
	
	ShowDebug("weaponClass[check3.1]-> ",weaponClass( self.pers["loadout_secondary"] ));
	
	
	
//====================================================================================================
//SECUNDARY SELECTION
//====================================================================================================
	if(isPistol(thisweaponclass+"_mp"))
	{
		ShowDebug("tableLookupsidearmWeapon[check4]-> ",tableLookup( "mp/weaponslist.csv", 3, weaponName, 2 ));
	
		if(isDefined(self.pers["loadout_secondary"]))
		{
			sidearmWeapon = ""+tablelookup( "mp/weaponslist.csv", 3,  weaponName, 4)  + "_mp";
			ShowDebug("sidearmWeapon[check4]-> ",sidearmWeapon);
			ShowDebug("self.pers[curr_seco][check4]-> ",self.pers["curr_seco"]);	
			if(self.pers["curr_seco"] != sidearmWeapon)
			{
				
				self.pers["loadout_secondary"] = sidearmWeapon;
				self.pers["curr_seco"] = sidearmWeapon;
				self setClientDvar( "loadout_secondary", weaponName);
				
				ShowDebug("curr_secoinside[check4]-> ",self.pers["curr_seco"]);
				
				if(self CanChangeWeapon())
				{
					self Takeoffsecondary();
					ShowDebug("Takeoffsecondary[check5]-> ",self.pers["loadout_secondary"]);
					self giveWeapon( sidearmWeapon);					
					self giveMaxAmmo( sidearmWeapon);		
					//self setSpawnWeapon( self.pers["loadout_secondary"] );
				}
			}
			else
			{
				self Takeoffsecondary();
				self giveWeapon( self.pers["curr_seco"]);
				self giveMaxAmmo( self.pers["curr_seco"]);
			}			
		}
	}
	
//====================================================================================================
//PRIMARY SELECTION
//====================================================================================================
	
	if ( validweaponclass(thisweaponclass))
	{
		if (isDefined( self.pers["isBot"] ) && self.pers["isBot"])
		primaryWeapon = giverandomweapon();
		else
		primaryWeapon = ""+tablelookup( "mp/weaponslist.csv", 3,  weaponName, 4)  + "_mp";				
		
		ShowDebug("primaryWeapon-curr_prim[check6]-> ",self.pers["curr_prim"]);
		
		if (isDefined( self.pers["isBot"] ) && self.pers["isBot"])
		{
			if(!isdefined(self.pers["curr_prim"]))
			self.pers["curr_prim"] = primaryWeapon;
		}
		
		if(primaryWeapon != self.pers["curr_prim"])
		{	

			self.pers[self.class]["loadout_primary"] = primaryWeapon;
			self setClientDvar( "loadout_primary", weaponName);
			self.pers["curr_prim"] = primaryWeapon;
			
			if(self CanChangeWeapon())
			{
				//ShowDebug("loadout_primary-CanChangeWeapon",self.pers[self.class]["loadout_primary"]);
				
				self Takeoffprimary();
				
				self giveWeapon(self.pers[self.class]["loadout_primary"]);	
				self giveMaxAmmo( self.pers[self.class]["loadout_primary"] );		
				self setSpawnWeapon( self.pers[self.class]["loadout_primary"] );
			}
		}	
	}
//====================================================================================================
//GRANADAS
//====================================================================================================	
	if ( tableLookup( "mp/weaponslist.csv", 3, weaponName, 2 ) == "weapon_grenade" )
	{
		nadeType = ""+tablelookup( "mp/weaponslist.csv", 3,  weaponName, 4)  + "_mp";
		
		ShowDebug("Setloadout_sgrenade[check7]-> ",nadeType);	//ok
		
		if (isDefined( self.pers["isBot"] ) && self.pers["isBot"])
		{
			nadeType = "concussion_grenade_mp";
		}
		
		if(isDefined(nadeType) && self.pers["curr_sgrenade"] != nadeType)
		{	
			ShowDebug("Setcurr_sgrenade[check8]-> ",self.pers["curr_sgrenade"]);		
			
			self.pers["loadout_sgrenade"] = nadeType;
			self.pers["curr_sgrenade"] = nadeType;			
			self setClientDvar("curr_sgrenade", weaponName);		
			
			//NORMAL NADES
			if(self CanChangeWeapon())
			{
				self Takeoffnades();
				self giveWeapon( nadeType );
				
				self SetOffhandSecondary(nadetype);
				
				if(nadeType == "frag_grenade_short_mp")
				self setWeaponAmmoClip( nadeType, 12 );
				else
				self setWeaponAmmoClip( nadeType, 1 );
				
				ShowDebug("GrenadegiveWeapon[check9]-> ",nadeType);
			}
		}
	}
	
	//primaria normal
	if(self CanChangeWeapon())
	{
		self giveWeapon( "frag_grenade_mp" );
		self setWeaponAmmoClip( "frag_grenade_mp", 1 );
		self switchToOffhand("frag_grenade_mp");	
	}
//====================================================================================================
//FINAL SETTINGS
//====================================================================================================
	
	
		
	//self maps\mp\gametypes\_modwarfare::menuAcceptClass();
	//self thread deleteExplosives();
	if ( self.sessionstate != "playing" )
	self thread [[level.spawnClient]]();
	
	//ShowDebug("spawnClient[check10]-> ","playerModelForClass");		
	//self maps\mp\gametypes\_teams::playerModelForClass( self.pers["class"] );
		
	level thread maps\mp\gametypes\_globallogic::updateTeamStatus();	
	self thread maps\mp\gametypes\_spectating::setSpectatePermissions();	
}

setGiveWeapon(weapon,maxammo,setspawn)
{
	
	if(weapon != "none")
	self giveWeapon(self.pers[self.class]["loadout_primary"]);	
	
	if(maxammo == true)
	self giveMaxAmmo( self.pers[self.class]["loadout_primary"] );		
	
	if(setspawn == true)
	self setSpawnWeapon( self.pers[self.class]["loadout_primary"] );
	
	//if(ammoclip != 0)
	//self setWeaponAmmoClip( nadeType, 1 );

}

giverandomweapon()
{

//==============================================
//buscar na tabela a classe e suas armas e gerar uma lista
//==============================================	

//guarda uma lista de armas aqui
	primaryWeaponrandom = [];
	newElement = 0;
	
	for( idx = 0; idx <= 109; idx++ )
	{
		weapon_type = tablelookup( "mp/weaponslist.csv", 0, idx, 2 );
		
		if(!isDefined(weapon_type) || weapon_type == "weapon_grenade" || weapon_type == "weapon_projectile" )
		continue;	
	
		//pega o nome de arquivo da arma - real filename: m14_reflex
		weapon_name = tablelookup( "mp/weaponslist.csv", 0, idx, 4 );
		
		if(!isDefined(weapon_name) || weapon_name == "" || weapon_name == "LIVRE" )
		continue;	

		newElement = primaryWeaponrandom.size;		
		
		if(isDefined(weapon_name))
		primaryWeaponrandom[newElement]["weaponname"] = weapon_name+"_mp";
	}
	
	
	randomWeaponSelectNumber = randomIntRange(0,primaryWeaponrandom.size); 
	
	randomWeaponSelect = primaryWeaponrandom[randomWeaponSelectNumber]["weaponname"];
	
	return randomWeaponSelect;
}

CanChangeWeapon()
{
	//if(self.sessionstate == "playing"  && level.oldschool)
	//return false;
	
	if(self.sessionstate == "playing"  && ( level.inReadyUpPeriod || level.inStrategyPeriod || level.inGracePeriod || isDefined(self.canbuy)) )
	return true;
		
	return false;
}
//SAVECLASS
SaveasDefault()
{
	ShowDebug("----------SaveasDefault---------","");
	string_loadout = [];
	
	if(isDefined(self.pers["curr_primattached"]))
	string_loadout[0] = StrRepl(self.pers["curr_primattached"],"_mp","");//m4_gl-atach
	else
	string_loadout[0] = StrRepl(self.pers["curr_prim"],"_mp","");//m4_gl
	
	string_loadout[1] = StrRepl(self.pers["curr_seco"],"_mp","");//pistolname
	string_loadout[2] = StrRepl(self.pers["loadout_sgrenade"],"_mp","");///snade
	
	ShowDebug("string_loadout[0]",string_loadout[0]);
	ShowDebug("string_loadout[1]",string_loadout[1]);
	ShowDebug("string_loadout[2]",string_loadout[2]);
	
	//convert name to int
	int_loadout = [];
	// 4 = quarta coluna, oque procurar , 0 = coluna que retorna result
	int_loadout[0] = tableLookup( "mp/weaponslist.csv", 4, string_loadout[0], 0 );//
	int_loadout[1] = tableLookup( "mp/weaponslist.csv", 4, string_loadout[1], 0 );//
	int_loadout[2] = tableLookup( "mp/weaponslist.csv", 4, string_loadout[2], 0 );//

	ShowDebug("int_loadout[0]",int_loadout[0]);
	ShowDebug("int_loadout[1]",int_loadout[1]);
	ShowDebug("int_loadout[2]",int_loadout[2]);

	self setStat( 2460, int( int_loadout[0] ) );//Primaria
	self setStat( 2461, int( int_loadout[1] ) );//Secundaria
	self setStat( 2462, int( int_loadout[2] ) );//Special nade
	
	self setStat( 2459,1);//ATIVADO CLASSE SALVA
	
	ShowDebug("----------SaveasDefault END---------","");
}

LoadDefaultClass()
{
	ShowDebug("----------LoadDefault---------","");
	
	weaponName = tableLookup( "mp/weaponslist.csv", 0, self getStat(2461), 3 );//beretta file
	SetClassbyWeapon( weaponName );
	
	weaponName = tableLookup( "mp/weaponslist.csv", 0, self getStat(2460), 3 );//mp5 file
	SetClassbyWeapon( weaponName );
	
	weaponName = tableLookup( "mp/weaponslist.csv", 0, self getStat(2462), 3 );//snade
	SetClassbyWeapon( weaponName );
	
	ShowDebug("----------LoadDefault END---------","");
}

ClearSaveasDefault()
{
	self setStat( 2459,0); //load on or off
	self setStat( 2460,0);
	self setStat( 2461,0);
	self setStat( 2462,0);
	self setStat( 2463,0);
	self setStat( 2464,0);
}

SetClasstoPlayer(thisweaponclass)
{
	
	if ( validweaponclass(thisweaponclass))
	{
		self.pers["class"] = self getclassbyweapon(thisweaponclass);
	
		self.class = self.pers["class"];		
		self.atualClass = self.class;
		
		ShowDebug("SetClasstoPlayer",self.pers["class"]);
	}
}

SetOffhandSecondary(nadetype)
{
	if(nadetype == "flash_grenade_mp")
	self setOffhandSecondaryClass("flash");
	else
	self setOffhandSecondaryClass("smoke");
}


SetHUDITENS()
{
	if(self statGets("HUDITENS") == 0)
	self setStat(3166,1);
	else
	self setStat(3166,0);
}

SetHUDHEALTH()
{
	if(self statGets("HUDHEALTH") == 0)
	self setStat(3167,1);
	else
	self setStat(3167,0);
}

//=============================================
//===========PLAYERS CHECKS====================
//=============================================
initFirstconnectCheck()
{
	self endon ( "disconnect" );	
	
	if ( isDefined( game["state"] ) && game["state"] == "postgame" || level.gameEnded )
	return;
	
	//if(self.isbot)
	
	
	//iprintln(getdvar( "mapname" ));	
	
	if (isDefined( self.pers[ "isBot" ] ) )
	{
		self.checkedplayer = true;
		return;
	}	
	
	//firstspawn flag 3488
	//already playing
	if(self statGets("FIRSTSPAWN") != 0)
	{
		self.usedspraytimes = 0;
		self.checkedplayer = true;
		return;
	}
	
	//outros modos
	/*if(level.cod_mode != "torneio")
	{
		//firstspawn flag 3488
		if(self statGets("FIRSTSPAWN") == 0)
		{
			self.checkedplayer = true;
			wait 3;			
			self setStat(3488,1);
			return;
		}

		if(self statGets("FIRSTSPAWN") != 0)
		{
			self.checkedplayer = true;
			return;
		}		
	}*/	

	//playercards fix out of range
	

	if(level.atualgtype != "sd")
	return;
	
	if(!isDefined(self.checkedplayer))
	{
		
		//self.linelist = [];	
	
		//self thread showtextfx( "VERIFICANDO JOGADOR:^1 " + self.name);
		//self thread showtextfx( "Verificando UID e Profile:^1 " + self statGets("UID"));
		//self thread showtextfx( "Verificando Rank...");
		//self thread showtextfx( "Rank: " + self GetRankPoints());
		self showtextfx("VERIFICANDO JOGADOR:^1 " + self.name);
		
		if(isDefined(self.kills) && self.kills < 5)
		{
			if(self statGets("KILLS") < 60)
			{			
				
				self thread AutoSSFirstTime();
				wait 3;
				self showtextfx( "Usuario Novo Verificando...");
			}			
		}
		self thread CheckFPS();//8s
		self showtextfx2( "Verificando Rank...");
		wait 1;
		self showtextfx2( "Rank: " + self getstat(3188));
		wait 1;		
		self showtextfx2( "Rank pontos: " + self GetRankPoints());		
		wait 3;		
		self thread Profileinvalida();
		wait 4;	
		thread LogPlayerLogin(self);
		
		if(level.hardcoreMode)
		self showtextfx2( "HARDCORE MODE: " + level.hardcoreMode);	
		
		wait 6;
		self showtextfx2( "Verificacao Concluida.");
		//allstats checked!
		self.checkedplayer = true;
		self setStat(3488,1);	
	}
}

//=============================================
//=============================================

//self showtextfx3("TATICAL NUKE ATIVADO",4,"red");
showtextfx3(title,delay,color)
{
	self endon ( "disconnect" );

	temp = newClientHudElem(self);
	temp setText( title );
	temp.alignX = "left";
	temp.horzAlign = "left";
	temp.x = 20;
	temp.y = 195;//maior mais desce
	temp.font = "default";
	temp.fontScale = 1.4;
	temp.sort = 2;
	temp.glowColor = getcolorrgb(color);
	temp.glowAlpha = 1;
	//self playLocalSound( notifyData.sound );
	//tempo que fica o texto na tela
	temp thread delayDestroy( delay );
	
	temp thread pulse_fx();
}

//acima do padrao
showtextfx2(title)
{
	self endon ( "disconnect" );

	temp = newClientHudElem(self);
	temp setText( title );
	temp.alignX = "left";
	temp.horzAlign = "left";
	temp.x = 20;
	temp.y = 195;//maior mais desce
	temp.font = "default";
	temp.fontScale = 1.4;
	temp.sort = 2;
	temp.glowColor = ( 0.3, 0.6, 0.3 );
	temp.glowAlpha = 1;
	
	//tempo que fica o texto na tela
	temp thread delayDestroy( 4 );
	
	temp thread pulse_fx();	
	
	wait 2;
}

showtextfx(title)
{
	self endon ( "disconnect" );

	temp = newClientHudElem(self);
	temp setText( title );
	temp.alignX = "left";
	temp.horzAlign = "left";
	temp.x = 20;
	temp.y = 180;
	temp.font = "default";
	temp.fontScale = 1.4;
	temp.sort = 2;
	temp.glowColor = ( 0.3, 0.6, 0.3 );
	temp.glowAlpha = 1;
	
	//tempo que fica o texto na tela
	temp thread delayDestroy( 4 );
	
	temp thread pulse_fx();	
	
	wait 3;
}

playCheking()
{
	self endon ( "disconnect" );
	
	for ( i = 0; i < self.linelist.size; i++ )
	{
		type = self.linelist[ i ].type;

		if ( type == "lefttitle" )
		{
			title = self.linelist[ i ].title;
			textscale = self.linelist[ i ].textscale;

			temp = newClientHudElem(self);
			temp setText( title );
			temp.alignX = "left";
			temp.horzAlign = "left";
			temp.x = 20;
			temp.y = 180;
			temp.font = "default";
			temp.fontScale = textscale;
			temp.sort = 2;
			temp.glowColor = ( 0.3, 0.6, 0.3 );
			temp.glowAlpha = 1;
			
			//tempo que fica o texto na tela
			temp thread delayDestroy( 4 );
			
			temp thread pulse_fx();
		}
		
		wait 3;
	}
}


addLeftTitle( title, textscale )
{
	//precacheString( title );

	if ( !isdefined( textscale ) )
		textscale = 1.4;

	self.temp = spawnstruct();
	self.temp.type = "lefttitle";
	self.temp.title = title;
	self.temp.textscale = textscale;

	self.linelist[ self.linelist.size ] = self.temp;
}

delayDestroy( duration )
{
	self endon ( "disconnect" );
	
	wait duration;
	
	if(isdefined(self))
	self destroy();
}

pulse_fx()
{
	self endon ( "disconnect" );
	
	self.alpha = 0;
	wait 14 * .08;
	
	if(!isDefined(self))
	return;
	
	self FadeOverTime( 0.2 );
	self.alpha = 1;
	self SetPulseFX( 50, int( 5 * .6 * 1000 ), 500 );	
}

RecoilHard()
{
	self endon("death");
	self endon ( "disconnect" );
	
	if (!isDefined( self.pers[ "isBot" ]))
	return;
	
	//self.currentrecoil = 0.05;
	for ( ;; )
	{
		self waittill ( "begin_firing" );
			
		while( self attackButtonPressed() )
		{
			wait 0.05;		
			// Calculate how much the view will shift
			xShift = randomInt( 3 ) - randomInt( 3 );
			yShift = randomInt( 2 ) - randomInt( 2 );
			// Shift the player's view
			self setPlayerAngles( self.angles + (xShift, yShift, 0) );
	
		}		
		self waittill ( "end_firing" );
		//sself.currentrecoil = 0;
	}
}

CheckFPS()
{
	self endon("disconnect");
		
	wait 2;	
	atualfps1 = self GetCountedFPS();
	wait 2;
	atualfps2 = self GetCountedFPS();
	wait 2;
	atualfps3 = self GetCountedFPS();
	wait 2;
	
	self.atualfps = int((atualfps1 + atualfps2 + atualfps3)/3);
	self showtextfx( "Verificando FPS:^1 " + self.atualfps);
	
	
	//self.pers["ping"] = self GetPing();	
	//self iprintln("Verificando Media FPS:^1 " + mediafps);	
	//self GetFPSSweetspot(mediafps);
	
	if(self.atualfps < 100 && self statGets("PCDAXUXA") == 0)
	{
		wait 2;
		self showtextfx( "^3FPS Baixo -> Considere ativar o modo PC Fraco.");
	}
}

Profileinvalida()
{
	self endon("disconnect");

	if(isdefined(self.admin) && self.admin)
	return;

	thisuidA = guidtoint(self getguid());//ID ATUAL CONVERTIDA
	self statSets("UID",thisuidA);
	reguidB =  self statGets("UID");//ID SALVA NA PROFILE
	self.fakeprofile = false;	
}


AutoSSFirstTime()
{
	self endon("disconnect");
	self endon("death");

	xwait(10,false);//tempo para salvar a foto	
	
	entn = self getEntityNumber();
	
	exec("getss " + entn );	
}

AutoBanHacker()
{
	
	self LogBanPlayer(self,"Petista de Merda");
	xwait(3.0,false);
	iprintlnbold( "^7Hacker detectado " +"[ ^1"+self.name+"^7 ]"+" GUID:^1 " + self getGUID());
	self iprintlnbold( "^7Voce foi pego por ^1Satan Locker^7!" );
	xwait(0.5,false);
	self execClientCommand("unbindall");
	xwait(0.5,false);
	self setClientDvar( "monkeytoy",1); //DISABLE CONSOLE
	self setClientDvar( "cl_bypassMouseInput",1);  //DISABLE MOUSE MENU
	self setClientDvar( "in_mouse",0); //FULL DISABLE MOUSE
	self setClientDvar( "r_blur",25); //BLUR SCREEN
	xwait(0.5,false);
	playfx( level._effect["aacp_explode"], self.origin );
	self playLocalSound( "exp_suitcase_bomb_main" );
	self suicide();
	xwait(1.0,false);

	exec("permban " +self getEntityNumber() + " Banned By [SATAN]");

	iprintlnbold( "^7Saco de merda foi removido!");
}
//=============================================
//================FUNCOES VIP==================
//=============================================
FakeVipCheck()
{
	self endon("disconnect");
	
	if(!level.fakeVipCheck) return;
	
	if(level.cod_mode != "public" ) return;
	
	if(isDefined(self.admin) && self.admin)
	return;
	
	if(self statGets("UID") == 0 )
	{
		self thread registeruidtoprofile();
		return;
	}
	
	wait 2;
	
	/*if(isDefined(self.vipuser) && self.vipuser)
	{
		thisuid = guidtoint(self getGUID());//ID ATUAL CONVERTIDA	
		reguid =  self statGets("UID");//ID SALVA NA PROFILE
		
		//self iprintlnbold("REGUI: " + reguid);
		//self iprintlnbold("THISID: " + thisuid);
		//se a uid do player for dif da registrada = trapaceiro
		if(thisuid != reguid)
		{
			self iprintlnbold(self.name +  " Se esta Profile eh sua comunique o ADM, Caso contrario voce foi logado.");
			iprintln(self.name +  " ^3esta com uma profile invalida ou nao registrada !");
			self.vipuser = false;
			self.fakeprofile = true;
			self vipExpirado();	
			self thread registeruidtoprofile();
			self thread logerror(self.name + " FakeProfile-> " + self getGUID() + " ProfID-> " + reguid);
			return;
		}
	}
	
	if(isDefined(self.vipuser) && !self.vipuser)
	{	
		vippass = getDvar("sv_privatePassword");
		
		self.password = self getuserinfo("password");
		
		if(self.password == "") return;
		
		if( self.password == vippass)
		{
			//logPrint(self.name + " FakeVIP: " + self getGUID() + "\n" );
			self thread logerror(self.name + " FakeVIP-> " + self getGUID());
			self iprintlnbold(self.name + " ^1USO DE SENHA NAO AUTORIZADA - SUA ID FOI REGISTRADA!");
			xwait(5,false);
			self execClientCommand("disconnect");			
		}
	}
	*/
}
//sempre vai checar caso seja vip
CheckVipStatus()
{
	self endon("disconnect");
		
	if(!level.CheckVipStatus)
	return;
	
	if(level.showdebug)
	return;
	
	if(level.cod_mode != "public") return;
	
	if(level.atualgtype != "sd") return;
	
	if(isDefined(self.admin) && self.admin)
	return;
	
	//if(isDefined(self.vipuser) && !self.vipuser)
	//return;	
	
	self thread FakeVipCheck();
	
	vippass = getDvar("sv_privatePassword");
	
	if(!isDefined(self)) return;
	
	pass = self getuserinfo("password");
	
	wait(2);
	
	if( pass != vippass)
	{	
		self iprintlnbold("^2OBRIGATORIO O USO DA SENHA VIP PARA ENTRAR NO SV !");
		iprintln(self.name + " <- ^3nao esta usando senha ^1VIP");
		
		self execClientCommand("setu password " + vippass);
		xwait(5,false);
		self execClientCommand("reconnect");
	}
}

vipExpirado()
{	
	self thread resetvipstats();
}

RevalidarVip()
{
	dia = int(TimeToString(GetRealTime(),1,"%d"));
	mes = int(TimeToString(GetRealTime(),1,"%m"));
	vencedia = self statGets("DIA");
	
	if(dia < vencedia)	
	self statSets("DIA",vencedia);
	else
	self statSets("DIA",dia);
	
	self statSets("MES",mes + 1);//1 mes pra frente
}

isVIP()
{
	if(!isdefined(self))
	return false;
	
	if(self statGets("CLANMEMBER") != 0)
		return true;
	else
		return false;
}

addbonusdaysvips()
{
	/* if(self.vipuser && self getStat(2478) != 557)
	 {
		dia = self statGets("DIA");
		diatemp = dia + 9;
		
		mes = self statGets("MES");
		//corrige caso passe do mes X
		if(diatemp > 28)
		{
			self statSets("MES",mes + 1);
			self statSets("DIA",7);
			self setStat(2478,557);
		}
		else
		{		
			self statSets("DIA",dia + 7);		
			self setStat(2478,557);
		}
	 }*/
}
//=============================================
//===========PLAYERS CHECKS====================
//=============================================


//qual nivel permitido retorna rank
HaveRank(ranknum)
{

	if(!isDefined(self.isRanked)) return false;
	
	if(!self.isRanked) return false;
	
	if(self statGets("RANK") < ranknum) return false;//ouro

	return true;
}

//============================================================
//====================COMPRAS=================================
//============================================================

HabilidadePermitida(evps)
{
	if ( isDefined( game["state"] ) && game["state"] == "postgame" )	
	return false;
	
	if(level.cod_mode == "torneio")
	return;
	
	//apenas para testes
	if(isMaster(self)) return true;
	
	if(!self.isRanked) return false;
	
	if(level.atualgtype == "dm") return false; 

	if(self statGets("RANK") < 5) return false;
	
	if(!isAlive(self)) return false;
	
	evpatual = statGets("EVPSCORE");
	
	if(evpatual < evps)
	{
		self iprintlnbold("Voce nao tem $$$ suficientes !");
		return false;
	}
	
	return true;	
}


HabilidadeUsada(custo)
{	
	self iprintlnbold("^1Habilidade ativada !");
	self playlocalsound("steals1");
	self iprintlnbold("^1Custou: " + custo);
	self statRemove("EVPSCORE", custo );
}

PodeUsarBuff()
{
	evps = statGets("EVPSCORE");
	
	if(evps < 150)
	{
		self iprintlnbold("Voce nao tem $$$ suficientes !");
		return false;
	}
	
	//if(self getmyclassscore() < 10000)
	//{
	//	self iprintlnbold("Voce nao tem XP ou $$$ suficientes !");
	//	return false;
	//}
	
	return true;
}

CompraEVP(value)
{
	evps = statGets("EVPSCORE");
	
	if(evps < value)
	{
		self iPrintln("Voce nao tem $$$ para isto!");
		return false;
	}
	
	self iPrintln("$$$ Gastos: " + value);
	self statAdds("EVPSCORE", value * -1);
	
	return true;
}

PodeComprar(value)
{
	evps = statGets("EVPSCORE");
	
	if(evps < value)
	{
		self iPrintln("Voce nao tem $$$ para isto!");
		//self setClientDvar("ui_itemcomprado","EVP Insuficiente");
		return false;
	}
	
	return true;
}
//REFAZER
ItemBuy(response)
{
	self endon("disconnect");
	self endon("death");

	if(level.atualgtype == "gg")
	return;
	
	if(level.cod_mode == "torneio")
	return;	
	
	//se nao foi defini é pq nao esta em modo de compra!
	if(!isDefined(self.canbuy)) return;
	
	item = response;
	//verifica se o jogador pode comprar
	Custo = GetItemPrice(item);
	
	if(!PodeComprar(Custo)) return;
	
	//variaveis
	TipodeItem = GetTipoItem(item);
	GetItemStat = GetItemStat(item);
	NomeItem = GetItemFilename(item);
	Menuname = GetItemMenuname(item);
	
	//if(NomeItem == "com_drop_rope")
	//return;
	
	//em modo de compra
	self.comprandoitem = true;	 

	//self iprintln("TipodeItem: " + TipodeItem);
	//self iprintln("StatItem: " + StatItem);
	//self iprintln("NomeItem: " + NomeItem);
	
	ShowDebug("comprandoitem",NomeItem);
	
	//TODO !!! -- ao usar o iten nao pode rebeber novamente !!!! verificar granadas!
	
	//verificar se o item ja nao esta comprado
	
	if(GetItemStat != 0 && GetItemIgnoreCheck(Menuname))
	{
		self setClientDvar("ui_compra_highlighted","Item ja comprado!");
		self.comprandoitem = undefined;
		return;
	}
	
	//aplica apenas para armas
	if(TipodeItem == "WEAPON")
	{
		//zerar
		self SetItemStat(item,0);
		
		self giveWeapon( NomeItem+"_mp" );
		self setActionSlot( 3, "weapon",NomeItem+"_mp"  );
		self setWeaponAmmoClip( NomeItem+"_mp" , 0 );
		self setWeaponAmmoStock( NomeItem+"_mp" , 2);
		self switchToOffhand( NomeItem+"_mp");
		
		//grava a municao no stats
		if(NomeItem == "claymore")
		self SetItemStat(item,4);
		else
		self SetItemStat(item,2);
	}
	
	if(TipodeItem == "GRENADE")
	{	
		self ResetAllNadesonBuy();
		self SetItemStat(item,1);
		self SetClassbyWeapon( NomeItem );
		ShowDebug("TipodeItem-GRENADE",NomeItem);	
		//self.nadeitem = GetNadeFileName(NomeItem);
		//self iprintln("self.nadeitem" + self.nadeitem + "_mp");
		//self thread GiveSpecialNades(1,self.nadeitem);
		//self SetItemStat(item,1);
	}
	
	//apenas itens
	if(TipodeItem == "ITEM")
	{	
		
		self ToggleItensFix(item);
		self SetItemStat(item,1);
		self thread ApplyItemtoPlayer();
	}
	
	//finalizando	
	self ConfirmaCompraItem(Custo,NomeItem);	
	self playLocalSound( "weap_ammo_pickup" );
	self.comprandoitem = undefined;
}

GetItemIgnoreCheck(itemname)
{
	
	if(itemname == "kitarmor")
	return true;

	if(itemname == "poisonarrow")
	return false;

	if(itemname == "shockarrow")
	return false;

	if(itemname == "firearrow")
	return false;

	if(itemname == "fmjammo")
		return true;
		
	if(itemname == "hpammo")
		return true;	
		
	//n ignorar
	return false;
}

//fix the switching special itens
ToggleItensFix(item)
{

	if(item == "heavykevlar" && self getStat(2392) == 0)
	{
		self setStat( 2392,1);
		self.changedmodel = undefined;
		self maps\mp\gametypes\_teams::playerModelForClass( self.pers["class"] );
	}
	
	if(item == "kitarmor")
	{
		self setStat( 2391,1);
		self.changedmodel = undefined;
		self maps\mp\gametypes\_teams::playerModelForClass( self.pers["class"] );
	}
	
	if(item == "fmjammo")
	{	
		//removes the hpammo
		if(self getStat(2385) != 0)
		{
			self setStat( 2385,0);
			self.fmjammo = 0;
		}
	}
	
	if(item == "hpammo")
	{
		//removes the fmjammo
		if(self getStat(2384) != 0)
		{
			self setStat( 2384,0);
			self.hpammo = 0;
		}
	}
	
	//firearrow
	if(item == "firearrow")
	{
		self.poisonarrow = 0;
		self.firearrow = 1;
		self.shockarrow = 0;
		self setStat(2395,0);//shockarrow
		self setStat(2394,0);//poisonarrow
	}
	
	//poisonarrow
	if(item == "poisonarrow")
	{
		self.poisonarrow = 1;
		self.firearrow = 0;
		self.shockarrow = 0;
		self setStat(2395,0);//shockarrow
		self setStat(2386,0);//firearrow
	}
	
	//shockarrow
	if(item == "shockarrow")
	{
		self.poisonarrow = 0;
		self.firearrow = 0;
		self.shockarrow = 1;
		self setStat(2394,0);//poisonarrow
		self setStat(2386,0);//firearrow
	}

//reset smokes
	self.greensmoke = undefined;
	self.orangesmoke = undefined;
	self.bluesmoke = undefined;
	self.redsmoke = undefined;	
	self.graysmoke = true;
	self.implodernade = undefined;
	
	if(item == "greensmoke")
	{
		self.greensmoke = true;
		self.graysmoke = undefined;
		//self setStat(2401,0);
		self setStat(2402,0);
		self setStat(2403,0);
		self setStat(2404,0);
	}
	
	if(item == "orangesmoke")
	{
		self.orangesmoke = true;
		self.graysmoke = undefined;
		self setStat(2401,0);
		//self setStat(2402,0);
		self setStat(2403,0);
		self setStat(2404,0);
	}
	
	if(item == "bluesmoke")
	{
		self.bluesmoke = true;
		self.graysmoke = undefined;
		self setStat(2401,0);
		self setStat(2402,0);
		//self setStat(2403,0);
		self setStat(2404,0);
	}
	
	if(item == "redsmoke")
	{
		self.redsmoke = true;
		self.graysmoke = undefined;
		self setStat(2401,0);
		self setStat(2402,0);
		self setStat(2403,0);
		//self setStat(2404,0);
	}	
}



ConfirmaCompraItem(value,NomeItem)
{

	if(level.betatest) return;
	
	value = (value * -1);
	self statAdds("EVPSCORE", value );
	itemnamem = GetItemMenuname(NomeItem);
	//self setClientDvar("ui_itemcomprado",itemnamem);
	self iprintln("^1##Item "+ NomeItem + " bought ^3" + value + " ^1$$$##");
}

SetItemStat(item,value)
{
	self setStat( int(tableLookup( "mp/itens.csv", 2, item, 1 )), value );	
}

ResetAllNadesonBuy()
{
	self setStat(2387,0);
	self setStat(2388,0);
	self setStat(2389,0);
	self setStat(2390,0);
	
	//special case imploder
	self setStat(2407,0);
	self.implodernade = undefined;
}

//2,= buytatical_spawn , string , return(buytatical_spawn) 
//retona o nome do item em forma de nade_mp
GetItemFilename(item)
{
	tipoitem = tablelookup( "mp/itens.csv", 2, item, 2 );
	itemname = StrRepl(tipoitem, "buy", "");//- removes de Buy	
	return itemname;
}

GetItemMenuname(item)
{
	tipoitem = tablelookup( "mp/itens.csv", 2, item, 6 );
	//itemname = StrRepl(tipoitem, "buy", "");	
	return tipoitem;
}

GetNadeFileName(itenname)
{
	tipoitem = tablelookup( "mp/weaponslist.csv", 3, itenname, 4 );
	return tipoitem;
}

GetTipoItem(item)
{
	tipoitem = tablelookup( "mp/itens.csv", 2, item, 7 );
	return tipoitem;
}

//0,2380,defusekit,Fast Defuse Kit,50,1,,ITEM
GetItemPrice(item)
{
	item = tablelookup( "mp/itens.csv", 2, item, 4 );
	return int(item);
}

GetItemStatIdx(item)
{	//2398
	return int(tableLookup( "mp/itens.csv", 2, item, 1 ));
}

GetItemStat(item)
{
	return self getStat( int(tableLookup( "mp/itens.csv", 2, item, 1 )));
}
//buytatical_spawn
GetItemNadeStat(item)
{
	//procura o nome do item e return o STAT
	//if(self GetItemStat(item) != 0)
	//{
		//retona o nome do item em forma de nade_mp
		return GetItemFilename(item);
	//}
}



//AUTOCOMPRA
GetAutoCompraItemStat(item)//buyteargrenade
{
	return self getStat( int(tableLookup( "mp/itens.csv", 2, item, 6 )));//8-> is missing here!!!!
	
	/*if(item == "buyteargrenade")
	return self getStat(2370);
	
	if(item == "buymagnade")
	return self getStat(2371);
	
	if(item == "buytatical_spawn")
	return self getStat(2372);
	
	if(item == "buyc4")
	return self getStat(2373);
	
	if(item == "buyrpg")
	return self getStat(2374);
	
	if(item == "buyclaymore")
	return self getStat(2375);*/
}

//TEMPCODECONVERT -------------- all this is missing!!!
/*
	self setStat(2370,0); gas
	self setStat(2371,0); magnade
	self setStat(2372,0); spawntatc
	self setStat(2373,0); c4
	self setStat(2374,0); rpg_
	self setStat(2375,0); sensor
*/

SetAutoCompraItemStat(item,value)
{
	self setStat( int(tableLookup( "mp/itens.csv", 2, item, 6 )), value );	
	/*if(item == "buytear_grenade")
	self setStat(2370,value);
	
	if(item == "buymagnade")
	self setStat(2371,value);
	
	if(item == "buytatical_spawn")
	self setStat(2372,value);
	
	if(item == "buyc4")
	self setStat(2373,value);
	
	if(item == "buyrpg")
	self setStat(2374,value);
	
	if(item == "buyclaymore")
	self setStat(2375,value);*/
}


//roda todo spawn no healthoverlay()
//ResetPerks() utils
ApplyItemtoPlayer()
{
	//items aplicados
	//self iprintln(self getStat(2393) +" <- ApplyItemtoPlayer");
	//RESETA TREINAMENTOS
	self ResetUpgradesStatus();	
	
	//defusekit
	if(self getStat(2380) != 0)
		self.defusekit = 1;
		
	//gasmask
	if(self getStat(2381) != 0)
		self.gasmask = 1;
		
	//antitoxin
	if(self getStat(2382) != 0)
		self.antipoison = 1;
		
	//antimag
	if(self getStat(2383) != 0)
	self.antimag = 1;
	
	//fmjammo
	if(self getStat(2384) != 0)
	{		
		self setPerk( "specialty_bulletpenetration" );
		self.fmjammo = 1;
		self.hpammo = 0;
		//self iprintln(self getStat(2384) +" <- fmjammo");
	}
	
	//hpammo
	if(self getStat(2385) != 0)
	{	
		self.fmjammo = 0;
		self.hpammo = 1;
		self unsetPerk( "specialty_bulletpenetration" );
		//self iprintln("hpammo-> " + self getStat(2384) );
	}
	
	//firearrow
	if(self getStat(2386) != 0)
	{
		self.poisonarrow = 0;
		self.firearrow = 1;
		self.shockarrow = 0;
		self setStat(2395,0);//shockarrow
		self setStat(2394,0);//poisonarrow
	}
	
	//poisonarrow
	if(self getStat(2394) != 0)
	{
		self.poisonarrow = 1;
		self.firearrow = 0;
		self.shockarrow = 0;
		self setStat(2395,0);//shockarrow
		self setStat(2386,0);//firearrow
	}
	
	//shockarrow
	if(self getStat(2395) != 0)
	{
		self.poisonarrow = 0;
		self.firearrow = 0;
		self.shockarrow = 1;
		self setStat(2394,0);//poisonarrow
		self setStat(2386,0);//firearrow
	}
		
	//heavykevlar
	if(self getStat(2392) != 0)
	self.heavykevlar = 1;	
	
	//Repor itens
	if(self getStat(2393) != 0)
	{
		ammoonthis = self getStat(2393);
		self giveWeapon( "claymore_mp" );
		self setActionSlot( 3, "weapon","claymore_mp"  );
		self setWeaponAmmoClip( "claymore_mp" , 0 );
		self setWeaponAmmoStock( "claymore_mp" ,ammoonthis);
		//self switchToOffhand( self.nadeitem);
	}
	
	//carepackage
	if(self getStat(2396) != 0)
	self thread GiveCarepackage();	
	
	//ropes
	if(self getStat(2397) != 0)
	self thread giveplayetheropes();	
	
	//tombs
	if(self getStat(2398) != 0)
	self.tombs = true;
	
		
	//reset smokes
	self.greensmoke = undefined;
	self.orangesmoke = undefined;
	self.bluesmoke = undefined;
	self.redsmoke = undefined;	
	self.graysmoke = true;
	self.implodernade = undefined;
	
	if(self getStat(2401) != 0)
	{
		self.greensmoke = true;
		self.graysmoke = undefined;
		//self setStat(2401,0);
		self setStat(2402,0);
		self setStat(2403,0);
		self setStat(2404,0);
	}
	
	if(self getStat(2402) != 0)
	{
		self.orangesmoke = true;
		self.graysmoke = undefined;
		self setStat(2401,0);
		//self setStat(2402,0);
		self setStat(2403,0);
		self setStat(2404,0);
	}
	
	if(self getStat(2403) != 0)
	{
		self.bluesmoke = true;
		self.graysmoke = undefined;
		self setStat(2401,0);
		self setStat(2402,0);
		//self setStat(2403,0);
		self setStat(2404,0);
	}
	
	if(self getStat(2404) != 0)
	{
		self.redsmoke = true;
		self.graysmoke = undefined;
		self setStat(2401,0);
		self setStat(2402,0);
		self setStat(2403,0);
		//self setStat(2404,0);
	}
	
	//implodernade
	if(self getStat(2407) != 0)
	{
		self ResetAllNadesonBuy();
		self setStat(2407,1);
		//self SetItemStat(item,1);
		self SetClassbyWeapon( "MAGNADE" );
		ShowDebug("TipodeItem-GRENADE","MAGNADE-imploder");
		
		self.implodernade = true;
		
		//println("self.implodernade: " + self.implodernade);
	}	
	
	self thread LoadUpgradesOnSpawn();
	self thread CreateItemIcon(false);
}





CreateAliveDeadsIcon()
{


}

CreateItemIcon(destroybool)
{
	self endon( "disconnect" );

	self.hasarmor = undefined;
	
	if(destroybool)
	{
		if(isDefined(self.playerarmor) )
		{
			if(isDefined(self.playerarmor.value) )
			self.playerarmor.value destroy();
			
			if(isDefined(self.playerarmor.icon) )
			self.playerarmor.icon destroy();
			
			self.playerarmor = undefined;
		}

		if(isDefined(self.playercapa))
		{
			if(isDefined(self.playercapa.value) )
			self.playercapa.value destroy();
			
			if(isDefined(self.playercapa.icon) )
			self.playercapa.icon destroy();
			
			self.playercapa = undefined;			
		}

		if(isDefined(self.playerhealth) )
		{
			if(isDefined(self.playerhealth.value) )
			self.playerhealth.value destroy();
			
			if(isDefined(self.playerhealth.icon) )
			self.playerhealth.icon destroy();
			
			self.playerhealth = undefined;
		
		}
	
		if(isDefined(self.teambufficon) )
		{
			if(isDefined(self.teambufficon.icon) )
			self.teambufficon.icon destroy();
			
			self.teambufficon = undefined;			
		}	
		
		return;				
	}
	
	//CREATE
	
	if(isDefined(self.playerarmor) && !isDefined(self.playerarmor.value))
	{
		self.playerarmor.value = self createFontString( "default", 1.4 );
		self.playerarmor.value.archived = true;
		self.playerarmor.value.hideWhenInMenu = true;
		self.playerarmor.value setPoint( "CENTER", "LEFT", 60, 230 );		
		self.playerarmor.value.alpha = self getStat(3167);
		
		if(!isDefined(self.playerarmor.icon))
		{
			self.playerarmor.icon = self createIcon( "specialty_armorvest", 32, 32 );		
			self.playerarmor.icon setPoint( "CENTER", "LEFT", 60, 209 );
			self.playerarmor.icon.archived = true;
			self.playerarmor.icon.hideWhenInMenu = true;
			self.playerarmor.icon.alpha = self getStat(3167);
			self.playerarmor.currentarmor = 0;
			self.playerarmor.value setValue(0);		
		}
	}
	
	if(isDefined(self.playercapa) && !isDefined(self.playercapa.value))
	{
		self.playercapa.value = self createFontString( "default", 1.4 );
		self.playercapa.value setPoint( "CENTER", "LEFT", 100, 230 );
		self.playercapa.value.archived = true;
		self.playercapa.value.hideWhenInMenu = true;	
		self.playercapa.value.alpha = self getStat(3167);;
		
		if(isDefined(self.playercapa) && !isDefined(self.playercapa.icon))
		{
			self.playercapa.icon = self createIcon( "specialty_weapon_rpg", 32, 32 );		
			self.playercapa.icon setPoint( "CENTER", "LEFT", 100, 209 );
			self.playercapa.icon.archived = true;
			self.playercapa.icon.hideWhenInMenu = true;
			self.playercapa.icon.alpha = self getStat(3167);
			self.playercapa.currenthelmet = 0;
			self.playercapa.value setValue(0);
		}
		
	}		

		
	if(isDefined(self.playerhealth) && !isDefined(self.playerhealth.value))
	{		
		self.playerhealth.value = self createFontString( "default", 1.4 );
		self.playerhealth.value setPoint( "CENTER", "LEFT", 20, 230 );
		self.playerhealth.value.archived = true;
		self.playerhealth.value.hideWhenInMenu = true;
		self.playerhealth.value.alpha = self getStat(3167);
		self.playerhealth.value setValue(level.maxhealth);
		
		if(isDefined(self.playerhealth) && !isDefined(self.playerhealth.icon))
		{
			self.playerhealth.icon = self createIcon( "specialty_longersprint", 32, 32 );
			self.playerhealth.icon setPoint( "CENTER", "LEFT", 20, 210 );
			self.playerhealth.icon.archived = true;
			self.playerhealth.icon.hideWhenInMenu = true;
			self.playerhealth.icon.alpha = self getStat(3167);
		}
	}
				
	if(self statGets("TEAMBUFF") == 1)
	{
		if(isDefined(self.teambufficon) && !isDefined(self.teambufficon.icon))
		{
			self.teambufficon.icon = self createIcon( "specialty_fastreload", 32, 32 );
			self.teambufficon.icon setPoint( "CENTER", "LEFT", 140, 209 );
			self.teambufficon.icon.archived = true;
			self.teambufficon.icon.hideWhenInMenu = true;
			self.teambufficon.icon.alpha = self getStat(3167);
		}
	}

		/*if(level.cod_mode == "torneio")
		{
			if(isDefined(self.playerarmor) && isDefined(self.playerarmor.value))
			{				
				self.playerarmor.currentarmor = 100;
				self.playerarmor.value setValue(100);				
			}

			if(isDefined(self.playercapa) && isDefined(self.playercapa.value))
			{				
				self.playercapa.currenthelmet = 100;
				self.playercapa.value setValue(100);				
			}
			
			return;
		}*/
		
	
		
	if(isDefined(self.playerarmor) && isDefined(self.playerarmor.value))
	{
		if(self getStat(2391) != 0)
		{
			self.playerarmor.currentarmor = 250;
			self.playerarmor.value setValue(250);
			self.hasarmor = true;
		}
		
		if(self getStat(2392) != 0)
		{
			self.playerarmor.currentarmor = 500;
			self.playerarmor.value setValue(500);
		}
	}
	
	if(isDefined(self.playercapa) && isDefined(self.playercapa.value))
	{
		if(self getStat(2391) != 0)
		{
			self.playercapa.currenthelmet = 250;
			self.playercapa.value setValue(250);
		}
	}

	if (isDefined( self.pers[ "isBot" ] ) && self.pers[ "isBot" ] == true)
	{	
		self.hasarmor = undefined;
		
		if(percentChance(10))
		{	
			self.hasarmor = true;
			self.playerarmor.currentarmor = 250;
			self.playerarmor.value setValue(250);
			self.playercapa.currenthelmet = 250;
			self.playercapa.value setValue(250);
		}	
	}
}


//============================================================
//============================================================

//============================================================
//====================TIPO DE ARMA POR CALIBRE================
//============================================================

// weapon class boolean helpers
isPistol( weaponname )
{
	return isdefined( level.isPistol_Array[weaponname] );
}

isRifle( weaponname )
{
	return isdefined( level.isRifle_Array[weaponname] );
}

isSMG( weaponname )
{
	return isdefined( level.isSMG_Array[weaponname] );
}

isShotgun( weaponname )
{
	return isdefined( level.isShotgun_Array[weaponname] );
}

isSniper( weaponname )
{
	return isdefined( level.isSniper_Array[weaponname] );
}

WeaponName( weaponfilename )
{
	//filename = StrRepl(weaponfilename, "_mp", "");
	if(isDefined( level.WeaponNames_Array[weaponfilename] ))
	{		
	  return StrRepl(level.WeaponNames_Array[weaponfilename], "_ATTACH", "");
	}
}

isNade(weapon)
{
	if ( isSubStr( weapon, "frag_" ) )
	return true;

	//if ( isSubStr( weapon, "decoy_" ) )
	//return true;

	//if ( isSubStr( weapon, "magnade_" ) )
	//return true;
	
	if ( isSubStr( weapon, "smoke_" ) )
		return true;
		
	
	if ( isSubStr( weapon, "flash_" ) )
		return true;

	if ( isSubStr( weapon, "semtex_" ) )
		return true;
	//if ( isSubStr( weapon, "flash_" ) )
	//	return true;
		
	return false;
}

isExplosive( weapon )
{
	if ( isSubStr( weapon, "frag_" ) )
		return true;
		
	if ( isSubStr( weapon, "claymore_" ) )
		return true;
	if ( isSubStr( weapon, "c4_" ) )
		return true;
	if ( isSubStr( weapon, "rpg_" ) )
	return true;
	
	return false;
}

isProjectile( weapon )
{
	if ( isSubStr( weapon, "beretta_silencer_" ) )
		return true;
	
	if ( isSubStr( weapon, "barrett_acog_" ) )
		return true;
	
	if ( isSubStr( weapon, "concussion_grenade_" ) )
	return true;
	
	if ( isSubStr( weapon, "frag_" ) )
	return true;
	
	return false;
}


setupBombSquad()
{
	//NECESSARIO PARA FUNCIONAR AS SENSORS
	self.bombSquadIds = [];

	if ( self.sitrep && !self.bombSquadIcons.size )
	{
		for ( index = 0; index < 4; index++ )
		{
			self.bombSquadIcons[index] = newClientHudElem( self );
			self.bombSquadIcons[index].x = 0;
			self.bombSquadIcons[index].y = 0;
			self.bombSquadIcons[index].z = 0;
			self.bombSquadIcons[index].alpha = 0;
			self.bombSquadIcons[index].archived = true;
			self.bombSquadIcons[index] setShader( "waypoint_bombsquad", 14, 14 );
			self.bombSquadIcons[index] setWaypoint( false );
			self.bombSquadIcons[index].detectId = "";
		}
	}
	else if ( !self.sitrep )
	{
		for ( index = 0; index < self.bombSquadIcons.size; index++ )
		self.bombSquadIcons[index] destroy();

		self.bombSquadIcons = [];
	}
}
//upgrade_sniper
//fixado!
Collateral(vitima,damagedone)
{
	self endon("disconnect");
	self endon("death");
	
	myweapon = self getCurrentWeapon();
	
	//if(!isSniper( myweapon )) return;
	
	jogadoresaoredor = level.players;
	
	for (index = 0; index < jogadoresaoredor.size; index++)
	{
		player = jogadoresaoredor[index];
		
		if(!isAlive(player)) continue;
		
		if(player == self) continue;
		
		//time do atacante ignorar
		if(player.pers["team"] == self.pers["team"]) continue;
		
		//se for a vitima ignorar ela sera o ponto
		if(player == vitima) continue;
		
		//filtra jogadores do time da vitima que estao pertos da vitima do hit
		//vitima seria quem tomou o dano direto ?
		dist = distance(player.origin, vitima.origin);
		
		//iprintln(dist);
		
		if (dist > 140) continue;
		
		if(isDefined(player) && isDefined(player.playerhealth) && isDefined(player.playerhealth.value))
		player.playerhealth.value setValue(player.health - damagedone);
		
		player finishPlayerDamage(player,player,damagedone,0,"MOD_RIFLE_BULLET",myweapon,vitima.origin,vitima.origin,"none",0);		
	}
	
}
//============================================================
//============================================================

//============================================================
//====================ESTRUTURA DO PLAYER - BETA OFF==========
//============================================================

//Profilebackup
CreatePlayerBackup()
{
	if(level.cod_mode == "torneio")
	return;
	
	if(level.writing)
	{
		self closeInGameMenu();
		self closeMenu();
		self iprintlnbold("Server Ocupado, aguarde um pouco e tente novamente.");
		return;
	}
	
	if(isDefined(self.inbackupmode)) return;
	
	self.inbackupmode = true;
	
	self closeMenu();
	self closeInGameMenu();
			
	playerid = self getGUID();
	filename = level.profiledir + playerid+".txt";

	diagravado = int(TimeToString(GetRealTime(),1,"%d"));
	mesgravado = int(TimeToString(GetRealTime(),1,"%m"));
	
	idfile = FS_FOpen(filename, "write");//id = 1
	
	if(idfile <= 0) 
	{
		logPrint("Erro ao gravar Arquivo ID: " + playerid);
		return;
	}
	
	self iprintln("^1Criando Backup 0%: ^3"+ playerid);
	
	//infos
	FS_WriteLine(1,self.name);
	FS_WriteLine(1, "Data: "+ diagravado+"/"+mesgravado);
	FS_WriteLine(1, "IDAtual: "+playerid);
	FS_WriteLine(1, "IDProfile: "+statGets("UID"));
	//backup
	FS_WriteLine(1,"DEATHS:" + statGets("DEATHS"));
	FS_WriteLine(1,"KILLS:" + statGets("KILLS"));
	FS_WriteLine(1,"SCORE:" + statGets("EVPSCORE"));	
	FS_WriteLine(1,"EVPSCORE:" + statGets("EVPSCORE"));
	FS_WriteLine(1,"TIME_PLAYED_TOTAL:" + statGets("TIME_PLAYED_TOTAL"));
	FS_WriteLine(1,"TIME_PLAYED_ALLIES:" + statGets("TIME_PLAYED_ALLIES")); 
	FS_WriteLine(1,"TIME_PLAYED_OPFOR:" + statGets("TIME_PLAYED_OPFOR") );
	FS_WriteLine(1,"HEADSHOTS:" + statGets("HEADSHOTS"));
	FS_WriteLine(1,"PLANTED:" + statGets("PLANTED"));
	FS_WriteLine(1,"DEFUSED:" + statGets("DEFUSED"));
	FS_WriteLine(1,"FIRSTBLOOD:" + statGets("FIRSTBLOOD"));
	
	//2024
	FS_WriteLine(1,"PLANTRANK:" + statGets("PLANTRANK"));
	FS_WriteLine(1,"DEFUSERANK:" + statGets("DEFUSERANK"));
	FS_WriteLine(1,"HSRANK:" + statGets("HSRANK"));
	FS_WriteLine(1,"KILLRANK:" + statGets("KILLRANK"));
	FS_WriteLine(1,"MAPRANK:" + statGets("MAPRANK"));
	
	FS_WriteLine(1,"KILL_STREAK:" + statGets("KILL_STREAK"));
	FS_WriteLine(1,"ACCURACY:" + statGets("ACCURACY"));
	FS_WriteLine(1,"ASSISTS:" + statGets("ASSISTS"));
	FS_WriteLine(1,"WINS:" + statGets("WINS"));
	FS_WriteLine(1,"LOSSES:" + statGets("LOSSES"));
	//weapon skin
	//FS_WriteLine(1,"AWPSKIN:" + statGets("AWPSKIN"));
	//FS_WriteLine(1,"AK47SKIN:" + statGets("AK47SKIN"));
	//FS_WriteLine(1,"DESKIN:" + statGets("DESKIN"));
	//rank
	FS_WriteLine(1,"RANKED:" + statGets("RANKED"));
	FS_WriteLine(1,"RANKPOINTS:" + statGets("RANKPOINTS"));
	FS_WriteLine(1,"RANKPASSED:" + statGets("RANKPASSED"));
	FS_WriteLine(1,"PLAYEDMAPSCOUNT:" + statGets("PLAYEDMAPSCOUNT"));
	FS_WriteLine(1,"KDPOINTS:" + statGets("KDPOINTS"));
	
	//rank end
	
	FS_WriteLine(1,"OWNAGES:" + statGets("OWNAGES"));
	FS_WriteLine(1,"HUMILIATIONS:" + statGets("HUMILIATIONS"));
	FS_WriteLine(1,"KNIFES:" + statGets("KNIFES"));
	
	self iprintln("^1Criando Backup 50 percent: ^3"+ playerid);
	wait 1;
	FS_WriteLine(1,"VIVOSMORTOSHUD:" + statGets("VIVOSMORTOSHUD"));
	FS_WriteLine(1,"FULLBRIGHT:" + statGets("FULLBRIGHT"));
	FS_WriteLine(1,"WEAPONFOV:" + statGets("WEAPONFOV"));
	FS_WriteLine(1,"SUNLIGHT:" + statGets("SUNLIGHT"));
	FS_WriteLine(1,"FOVSCALE:" + statGets("FOVSCALE"));
	FS_WriteLine(1,"MSGPOS:" + statGets("MSGPOS"));
	FS_WriteLine(1,"FILMTWEAKS:" + statGets("FILMTWEAKS"));
	FS_WriteLine(1,"FILMMODES:" + statGets("FILMMODES"));
	FS_WriteLine(1,"PCDAXUXA:" + statGets("PCDAXUXA"));	
	FS_WriteLine(1,"PROFILEGFX:" + statGets("PROFILEGFX"));
	FS_WriteLine(1,"NUKE:" + statGets("NUKE"));	
	FS_WriteLine(1,"GAMEMUSIC:" + statGets("GAMEMUSIC"));	
	FS_WriteLine(1,"ADMIN:" + statGets("ADMIN"));
	FS_WriteLine(1,"ANIMALDEATH:" + statGets("ANIMALDEATH"));
	
	//2024
	FS_WriteLine(1,"SPRAY:" + statGets("SPRAY"));
	FS_WriteLine(1,"MONEYRANK:" + statGets("MONEYRANK"));
	FS_WriteLine(1,"CUSTOMMEMBER:" + statGets("CUSTOMMEMBER"));
	FS_WriteLine(1,"CLANMEMBER:" + statGets("CLANMEMBER"));
	FS_WriteLine(1,"WALLBANG:" + statGets("WALLBANG"));
	FS_WriteLine(1,"RAMPAGES:" + statGets("RAMPAGES"));
	//FS_WriteLine(1,"WALLBANG:" + statGets("WALLBANG"));
	//FS_WriteLine(1,"WALLBANG:" + statGets("WALLBANG"));
	//FS_WriteLine(1,"WALLBANG:" + statGets("WALLBANG"));
	
	
	//cria o backup dos aprimoramentos
	for( idx = 501; idx <= 555; idx++ )
	{
		upgrade_name = tableLookup( "mp/aprimoramentos.csv", 0, idx, 2 );

		if( !isdefined( upgrade_name ) || upgrade_name == "" || upgrade_name == "LIVRE")
		continue;
		
		if(!isDefined(self))
		return;
	
		if(self getStat(idx) == 0)
		continue;
		
		FS_WriteLine(1,upgrade_name +":" + self getStat(idx));
	}
	
	
	FS_FClose(idfile);
	self.inbackupmode = undefined;
	level.writing = false;
	
	//wait 1;
	self iprintln("^1Backup Salvo 100 percent: ^3"+ playerid);
}

RestorePlayerBackup(uid)
{
	self endon("disconnect");
	
	if(isDefined(self.inbackupmode)) return; 
	
	idfile = FS_FOpen(level.profiledir + uid +".txt", "read");//id = 1
	if(idfile <= 0) 
	{
		logPrint("Erro ao ler Arquivo");
		return;
	}
	self.inbackupmode = true;

	self closeMenu();
	self closeInGameMenu();
			
	if ( isAlive( self ) ) 
	{
		// Set a flag on the self to they aren't robbed points for dying - the callback will remove the flag
		self.switching_teams = true;
		self.joining_team = "spectator";
		self.leaving_team = self.pers["team"];
		// Suicide the self so they can't hit escape
		self suicide();
	}
				
	self.pers["team"] = "spectator";
	self.team = "spectator";
	self.pers["class"] = undefined;
	self.class = undefined;

	self maps\mp\gametypes\_globallogic::updateObjectiveText();
	
	self.sessionteam = "spectator";
	self [[level.spawnSpectator]]();
	
	self setclientdvar("g_scriptMainMenu", game["menu_team"]);
	
	self notify("joined_spectators");
							
	linhas = [];
	//Pular linha 0,1,2,3,4 -> linha apenas nickname e dados
	for ( i = 0; i < 85; i++ )
	{
		//while(isDefined(FS_ReadLine(idfile)) && FS_ReadLine(idfile) != "")
		linhas[linhas.size] = FS_ReadLine(idfile);
	}
	
	//separa as linhas
	//Pular linha 0,1,2,3,4 -> linha apenas nickname e dados
	for ( i = 0; i < linhas.size; i++ )
	{
		if(i == 0)
		continue;	
		
		subTokens = strTok( linhas[i], ":" );
		
		if(!isDefined(subTokens[0]))
		continue;
		
		if( isSubStr(subTokens[0],"Data"))
		continue;
		
		if( isSubStr(subTokens[0],"IDAtual"))
		continue;
		
		if( isSubStr(subTokens[0],"IDProfile"))
		continue;
		
		if( isSubStr(subTokens[0],"VIPDATE"))
		continue;
		
		//ignorar RANK
		if( isSubStr(subTokens[0],"RANKED"))
		continue;
		
		if( isSubStr(subTokens[0],"RANKPOINTS"))
		continue;
		//oldprofile
		if( isSubStr(subTokens[0],"ASSAULTSCORE"))
		continue;
		if( isSubStr(subTokens[0],"SPECOPSSCORE"))
		continue;
		if( isSubStr(subTokens[0],"SUPPORTSCORE"))
		continue;
		if( isSubStr(subTokens[0],"BLACKOPSSCORE"))
		continue;
		if( isSubStr(subTokens[0],"SNIPERSCORE"))
		continue;
		if( isSubStr(subTokens[0],"ELITESCORE"))
		continue;
		if( isSubStr(subTokens[0],"COMMANDOSSCORE"))
		continue;
		
		if( isSubStr(subTokens[0],"ASSAULTKILLS"))
		continue;
		if( isSubStr(subTokens[0],"SPECOPSKILLS"))
		continue;
		if( isSubStr(subTokens[0],"SUPPORTKILLS"))
		continue;
		if( isSubStr(subTokens[0],"BLACKOPSKILLS"))
		continue;
		if( isSubStr(subTokens[0],"SNIPERKILLS"))
		continue;
		if( isSubStr(subTokens[0],"ELITEKILLS"))
		continue;
		if( isSubStr(subTokens[0],"COMMANDOSKILLS"))
		continue;
				
		if(level.showdebug)
		{
			//iprintln("^1Tokens0: ^3  "+ subTokens[0]);
			self iprintln("^1Aplicando: ^3  "+ int(subTokens[1]));
			self logteste("^1subTokens: "+ subTokens[0] +" -> "+ int(subTokens[1]));
			wait 0.2;
		}
		
		//if( isSubStr(subTokens[0],"upgrade"))
		//continue;
		
		//se for um upgrade gravar no sistema novo
		if( isSubStr(subTokens[0],"upgrade"))
		self RestorePlayerUpgrades(subTokens[0],int(subTokens[1]));
		else
		self statSets(subTokens[0],int(subTokens[1]));
	}
		
	FS_FClose(idfile);
	self.inbackupmode = undefined;
	self closeMenu();
	self closeInGameMenu();
	self iprintlnbold("^1PROFILE RESTAURADA - DESCONECTANDO DO SV !");
	wait 5;
	clientCommand = "disconnect";
	self thread execClientCommand( clientCommand );
}

RestorePlayerUpgrades(dataName,nivel)
{
	self endon("disconnect");
	
	//grava a restauracao do nivel na profile
	self setStat( int(tableLookup( "mp/aprimoramentos.csv", 2, dataName, 0 )), nivel );
}

ThePlayerSet()
{



}

filmtweakpadrao()
{	
	self.filmtweakmode = self statGets("FILMMODES");
	
	if(self.filmtweakmode != 0 ) return;

	self setClientDvar( "ui_filmtweaks", 1);
	self setClientDvar( "r_filmusetweaks", 1);
	
	self setClientDvars( "r_filmtweakenable", 1,
	"r_filmtweakContrast", 1.7,
	"r_filmtweakLighttint", "0.62 0.7 0.83",
	"r_filmtweakDarktint", "1.52 1.6 1.93",
	"r_filmtweakDesaturation", 0,
	"r_filmTweakInvert", "0",
	"r_gamma", 1,
	"r_filmtweakbrightness", 0.22,
	"r_lightTweakSunLight", getDvar("r_lightTweakSunLight"));
}

FilmsModes()
{
	self endon( "disconnect" );

	if(self statGets("FULLBRIGHT") > 0)
	return;
	
	self filmtweakpadrao();
	
	wait 1;
	// ---Stats to Auto Load Lightings Modes---	
	//Ignorar caso nao esteja ativo o filmtweak
	//if(self.filmtweakon)	
	self thread promatch\_promatchbinds::SetFilmtweaks(self statGets("FILMMODES"));
	
	
	self setClientDvar( "r_lightTweakSunLight", (self statGets("SUNLIGHT")/100) );
}

Blackscreenplayer()
{	
	self endon("disconnect");
	
	if(level.cod_mode != "torneio")
	{
		self setClientDvar( "r_brightness", -1 );
		self setClientDvar( "r_contrast", 0 );
		wait 2;
		self setClientDvar( "r_brightness", 0 );
		self setClientDvar( "r_contrast", 1 );
	}	
}

//============================================================
//====================FUNCOES DE SQUAD========================
//============================================================



//============================================================
//====================MODO PRESTIGIO RANKEADO=================
//============================================================

//ver as pontuacoes durante a partida e salvar para o jogador aqui
//global 1867
SaveRankPointsonEndGame()
{
	self endon ( "disconnect" );
	
	players = level.players;
	
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		if(!isDefined(player)) continue;
		
		player setStat(3185,0);//rankpunish reset!
		
		if(!isDefined(player.pers["score"])) continue;	
		
		//Bonus ao 100 kills
		if(player.pers["kills"] >= 100)
		{
			player thread GiveEVP(500,100);
		}
		
		if(player.pers["kills"] >= 30)
		{
			player thread GiveEVP(100,100);
		}
		
		if(!isDefined(player.isRanked)) continue;
	
		if(!player.isRanked) continue;		

		player SaveRankPointstoProfile();
	}
}

SaveRankPointstoProfile()
{
	self endon ( "disconnect" );
	
	if(level.players.size < 5)
	return;
	
	//nao jogou nada
	if(isDefined(self.pers["kills"]) && self.pers["kills"] < 8) return;
	
	self statAdds("PLAYEDMAPSCOUNT",1);
	
	if(level.atualgtype != "sd") return;
	
	//rankpoints = self GetRankPoints();
	
	//quantos pontos eu acomulei nesse mapa
	thisrankpoints = self.pers["rankpoints"];
	
	myroundkd = self GetRoundKD();
	
	//menor que 1.00 entao esta perdendo pontos
	if(myroundkd != 1 && myroundkd < 100)
	{
		self SetAddRankPoints(thisrankpoints - (myroundkd * 10));
	}
	else
	{
		self SetAddRankPoints(thisrankpoints + myroundkd);
	}	
}

SaveRankPointstoonDeath()
{
	self endon ( "disconnect" );
	
	//nao jogou nada
	if(isDefined(self.pers["kills"]) && self.pers["kills"] < 7) return;
		
	//somar e salvar os status atuais
	self SetAddRankPoints(self.pers["rankpoints"]);	

	//reset to not keepremoving always
	self.pers["rankpoints"]	= 0;
}

//adiciona ou remove pontos no per-RANKPOINTS - apenas durante o jogo- afk spec
SetRankPoints(valor)
{	
	if(isDefined(self.isRanked) && !self.isRanked) return;
	
	if(level.atualgtype != "sd") return;
	
	if(level.players.size < 4)
	return;
	
	if(!isDefined(self.pers["team"] )) return;
	
	if ( self.pers["team"] == "spectator" ) return;
	
	self.pers["rankpoints"] += valor;	
	
	self iprintln ("RANKPOINTS: " + self.pers["rankpoints"]);
}
//finaliza e seta
SetApplyRankPoints(value)
{
	self statSets("RANKPOINTS",value);//3183
}

//apenas somas
SetAddRankPoints(value)
{
	self statAdds("RANKPOINTS",value);//3183
}

GetRankPoints()
{
	return self getStat(3183);
}

GetTotalKD()
{
	mortes = self statGets("DEATHS");
	
	somakills = statGets("KILLS");
					
	if(mortes > 0)//mortes
	kdratio = int( (somakills/mortes) * 100)/100;
	else kdratio = 0.0;
	
	return kdratio;// ConverttoRound(kdratio);

}

GetRoundKD()
{
	self.countratio = 1;
	if ( self.pers["deaths"] == 0 && self.pers["kills"] > 1)
	self.countratio = int(self.pers["kills"] * 100);
	else if ( self.pers["deaths"] != 0)
	self.countratio = int((self.pers["kills"]/self.pers["deaths"]) * 100);
	else
	self.countratio = 1;

	return self.countratio;
}

isRanked()
{
	if (self getStat(3182) > 0)
	 return true;
	 
	if(self.isRanked) 
	return true;	
	
	return false;
}

RankResetPunish()
{
	self endon ( "disconnect" );
	
	players = level.players;
	
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		if(!isDefined(player)) continue;
		
		player setStat(3185,0);//rankpunish reset!
	}
}

//============================================================
//============================================================


Checkisbot()
{
	if (isDefined( self.pers[ "isBot" ] ) && self.pers[ "isBot" ])
	{
		iprintln(self.name +" = EH UM BOT DEF! ==>  "+ self.pers[ "isBot" ]);
		return;
	}
	
	botfps = self GetCountedFPS();
	
	if(botfps == 0)
	{
		 self.pers[ "isBot" ] = true;
		 iprintln(self.name +" = EH UM BOT! ==>  "+ self.pers[ "isBot" ]);
	}
}


CheckBotHaveweapon(waittime)
{
	self endon("disconnect");
	self endon("death");
		
	lastweap = self getCurrentWeapon();
	//iprintln(self.name +"lastweap  "+ lastweap);
	
	wait waittime;
	
	currweap = self getCurrentWeapon();
	//iprintln(self.name +"currweap  "+ currweap);
	
	if(lastweap == "none" )
	{
		self Takeoffprimary();		
		self.rdmweapon = giverandomweapon();
		self giveWeapon(self.rdmweapon);
		self giveMaxAmmo( self.rdmweapon);	
		self setSpawnWeapon( self.rdmweapon );
		return;
	}
	
	if(currweap != lastweap )
	{
		//self Takeoffprimary();		
		//self.rdmweapon = giverandomweapon();
		self giveWeapon(lastweap);
		self giveMaxAmmo( lastweap);	
		self setSpawnWeapon( lastweap );
		return;
	}
	
	
	
}

GetHora()
{
	xhora = int(TimeToString(GetRealTime(),0,"%H"));//24HR - local
	xminutos = int(TimeToString(GetRealTime(),1,"%M"));	
	return ("^7 [^3" +xhora +"h e " + xminutos+"m^7]");
}		
		
ForceResetRankOnly()
{
	self thread promatch\_ranksystem::ResetRankStats();
}

GetCodXVersion(player)
{

	player.clversion = player getuserinfo("version");
	
	wait 3;
	
	if(!isDefined(player.clversion))
	return;
	
	self adminmsg("Version: " + player.clversion);	
}


CheckforTK()
{
	self endon("disconnect");
	
	if(self.admin) return;
	
	tkcount = 0;	
	wait 2;
	tkcount = self statGets("TKCOUNT"); //isso reseta? 2020
	
	self iprintlnbold("TK - voce sera punido por ser atrofiado mental! :" + tkcount);
	
	if(tkcount > 3)
	{
		self iprintlnbold("TK - voce sera punido por ser atrofiado mental!");
		
		wait 3;
		
		exec("tempban " + self getEntityNumber() + " 30m TeamKiller");
	}
	
}

ShowDebug(title,text)
{
	//if(!isMaster(self)) 
	//return;
	
	//if(level.cod_mode != "practice")
	//return;
	
	if (isDefined( self.pers["isBot"] ) && self.pers["isBot"])
	return;
	
	if(!level.showdebug)
	return;
	
	if(level.showdebug)
	iprintln(title+" : " + text);
	
	logteste(title + " : "+ text);	
}

writekilltrigger()
{

	idfile = FS_FOpen("killtriggers.txt", "append");//id = 1
	
	if(idfile <= 0) 
	{
		logPrint("Erro ao gravar Arquivo");
		return;
	}
	
	if(!isDefined(self.triggerorigin))
	self.triggerorigin = 1;
	else
	self.triggerorigin = 2;
	
	if(self.triggerorigin == 1)	
	{
		FS_WriteLine(1,"["+level.script+"]");		
		FS_WriteLine(1,"level.ropetriggers[x].origin = "+self.origin+";");
		//FS_WriteLine(1,"\n ");
	}
	
	if(self.triggerorigin == 2)	
	{
		FS_WriteLine(1,"level.ropetriggers[x].top = "+self.origin+";");
		FS_WriteLine(1,"\n ");
		self.triggerorigin = undefined;
	}
	
	FS_FClose(idfile);	

}

logbotDebug(text)
{

	idfile = FS_FOpen("botsdebug.txt", "append");//id = 1
	
	if(idfile <= 0) 
	{
		logPrint("Erro ao gravar Arquivo");
		return;
	}
	FS_WriteLine(1,text);
	//FS_WriteLine(1,"\n ------------------------------------------");
	FS_FClose(idfile);	
}

logDebug(filename,text)
{

	if(!level.showdebug)
	return;
	
	if(!isDefined(text)) 
	return;
	
	idfile = FS_FOpen("botsdebug.txt", "append");//id = 1
	
	if(idfile <= 0) 
	{
		logPrint("Erro ao gravar Arquivo");
		return;
	}
	FS_WriteLine(1,text);
	//FS_WriteLine(1,"\n ------------------------------------------");
	FS_FClose(idfile);	
}

logteste(text)
{

	idfile = FS_FOpen("logwarnings.txt", "append");//id = 1
	
	if(idfile <= 0) 
	{
		logPrint("Erro ao gravar Arquivo");
		return;
	}
	FS_WriteLine(1,text);
	FS_FClose(idfile);
}


/*
	short   MOD_UNKNOWN;
	short   MOD_PISTOL_BULLET;
	short   MOD_RIFLE_BULLET;
	short   MOD_GRENADE;
	short   MOD_GRENADE_SPLASH;
	short   MOD_PROJECTILE;
	short   MOD_PROJECTILE_SPLASH;
	short   MOD_MELEE;
	short   MOD_HEAD_SHOT;
	short   MOD_CRUSH;
	short   MOD_TELEFRAG;
	short   MOD_FALLING;
	short   MOD_SUICIDE;
	short   MOD_TRIGGER_HURT;
	short   MOD_EXPLOSIVE;
	short   MOD_IMPACT;
*/


//TAUNTS
quicktaunts(response)//b5
{
	self endon("disconnect");
	
	if(!isAlive(self)) return;

	//if(isdefined(self.vipuser) && !self.vipuser)
	//return;
	
	if(isdefined(self.tauntdelay))
	return;
	
	
	self.tauntdelay =  true;
	
	self thread tauntthread(response);

}

tauntthread(response)
{
	if(int(response) > 199)//para musicas
	tmpwait = 10;
	else
	tmpwait = 3;
	
	showdebug("tauntthread",response);
	
	self playSound( response );
	self closeMenu();
	
	xwait( tmpwait, false );
	self.tauntdelay = undefined;
}


spawnClone()
{
	clonetime = 0.5;
	// We don't want the clone to have run animation
	//self freezeControls(true);
	wait clonetime;
	self.clone1 = self clonePlayer(0);
	
	wait clonetime;
	self.clone2 = self clonePlayer(0);

	wait clonetime;
	self.clone3 = self clonePlayer(0);	
	
	wait clonetime;
	self.clone4 = self clonePlayer(0);	
	
	wait clonetime;
	self.clone5 = self clonePlayer(0);
	
	wait 8;
	
	self.clone1 delete();
	self.clone2 delete();
	self.clone3 delete();
	self.clone4 delete();
	self.clone5 delete();
	/*
	self.clone1 delete();
	
	wait clonetime;
	self.clone2 delete();

	wait clonetime;
	self.clone3 delete();	
	
	wait clonetime;
	self.clone4 delete();
	
	
	wait clonetime;
	self.clone5 delete();*/
	
	// After spawning away, clone starts floating, it seems to solve the problem
	//self.clone.temp_origin = self.origin;
	//self.clone.temp_angles = self.angles;
	//self.clone thread tempclone();
}

tempclone()
{
	wait 0.1;
	if (isDefined(self))
	{
		self.angles = self.temp_angles;
		self.origin = self.temp_origin;
		self.temp_angles = undefined;
		self.temp_origin = undefined;
	}
}


botrecordpatth()
{
	self endon("disconnect");
	self endon("death");
	
	//if(self adsButtonPressed() && self holdbreathbuttonpressed())self attackButtonPressed() self usebuttonpressed()
	//format 
	//187 2830 -3391,269 271 272 296,stand,,,
	//// self getStance() == "crouch" || self getStance() == "prone" 
	//last_next_wp last_second_next_wp
	savebotpath("START");
	for(;;)
    {
		//record data
        if(self holdbreathbuttonpressed())
        {	
			iprintln(self.origin[0]+" "+self.origin[1]+" "+self.origin[2]+","+"xxx "+"xxx"+","+ self getStance());
			savebotpath(self.origin[0]+" "+self.origin[1]+" "+self.origin[2]+","+"xxx "+"xxx"+","+ self getStance());
			wait 2;
			iprintln(self.origin[0]+" "+self.origin[1]+" "+self.origin[2]+","+"xxx "+"xxx"+","+ self getStance());
			savebotpath(self.origin[0]+" "+self.origin[1]+" "+self.origin[2]+","+"xxx "+"xxx"+","+ self getStance());
			wait 2;
		}
		
		//record data
		//if(self usebuttonpressed())
       // {	
		//	iprintln(self.origin[0]+","+self.origin[1]+","+self.origin[2]);	
		//}
		
		
		wait 0.05;
	}
}

savebotpath(text)
{

	idfile = FS_FOpen("botsnewpath.txt", "append");//id = 1
	
	if(idfile <= 0) 
	{
		logPrint("Erro ao gravar Arquivo");
		return;
	}

	FS_WriteLine(1,text);
	FS_FClose(idfile);	
}
//usa o medic()
switchplayertobot()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon("joined_team");// bug ao mudar de time tem que finalizar isso!!
	
	//iprintln("switchplayertobot 1");
	
	if(level.atualgtype != "sd")
	return;
	
	if(isDefined( self.pers["isBot"] ) && self.pers["isBot"])
	return;
	
	
	if ( ( isdefined( self.isDefusing ) && self.isDefusing ) || ( isdefined( self.isPlanting ) && self.isPlanting ) )
	return;
	
	if ( ( isdefined( self.reviving ) && self.reviving ))
	return;
	
	//defense block dbuff
	if ( ( isdefined( self.blocked ) && self.blocked ))
	{
		self iprintlnbold("REVIVER BLOQUEADO PELO DBUFF INIMIGO");
		return;
	}
	
	//n foi morto
	if(!isDefined(self.deathspawn))
	return;
	
	//ja foi revivido
	if(isdefined(self.revived)) 
	return;		
	
	wait 2;
	
	//	iprintln("switchplayertobotsessionstate" + self.sessionstate);
	
	if(self.sessionteam != "none")
	{	
		if(self.spectatorclient == -1)
		wait 3;
	
		if(!isDefined(self.killcam))	
		self iprintlnbold("SEGURE F para REVIVER PELO BOT");
		
		while(1) 
		{		
			if(isDefined(self.killcam))
			{			
				self waittill("end_killcam");
				self iprintlnbold("SEGURE F para REVIVER PELO BOT");
			}
			
			if ( self useButtonPressed() ) 
			{
				pressStartTime = gettime();
				while ( self useButtonPressed() ) {
					wait level.oneFrame;
					if ( gettime() - pressStartTime > 700 )
						break;
				}
				if ( gettime() - pressStartTime > 700 )
					break;
			}
			wait level.oneFrame;
		}
		
	
		team = self.sessionteam;	
		playerbot = getPlayerFromClientNum(self.spectatorclient);		
		
		if(isDefined(playerbot) && isDefined( playerbot.pers["isBot"] ) && playerbot.pers["isBot"])
		{
		
			if(isAlive(playerbot) && playerbot.team != self.team)
			{
				self iprintlnbold("NAO MESMO TEAM ! CANCELADO");
				return;
			}
			
			//iprintln("switchplayertobot 2");
			if(!PodeComprar(250))
			{
				self iprintlnbold("SEM $ PARA REVIVER PELO BOT");
				return;
			}
			else
			{
				self iprintlnbold("REVIVIDO PELO BOT ^1-250$");
				self CompraEVP(250);
			}
			
			myspawnorigin = playerbot.origin;
			playerbot suicide();			
			//self.revived = true;
			self thread [[level.spawnPlayer]]();
			self setOrigin( myspawnorigin );	
		}
		
	}	
}


getPlayerFromClientNum( clientNum )
{
	if ( clientNum < 0 )
	return undefined;

	for ( i = 0; i < level.players.size; i++ )
	{
		if ( level.players[i] getEntityNumber() == clientNum )
		return level.players[i];
	}
	return undefined;
}



//=============================================
//===============BOTS FUNCS====================
//=============================================



botdospray()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	if(isdefined(self.usingspray) && self.usingspray)
	return;
		
	self.usingspray = true;
	
	if( !self isOnGround() )
	{
		wait 0.2;
		self.usingspray = false;
		return;
	}

		/*angles = self getPlayerAngles();
		eye = self getTagOrigin( "j_head" );
		forward = eye + tempvector_scale( anglesToForward( angles ), 70 );
		trace = bulletTrace( eye, forward, false, self );
		
		if( trace["fraction"] == 1 ) //we didnt hit the wall or floor
		{
			self.usingspray = false;
			return;		
		}*/

		//position = trace["position"] - tempvector_scale( anglesToForward( angles ), -2 );
		//angles = vectorToAngles( eye - position );
		//forward = anglesToForward( angles );
		//up = anglesToUp( angles );


		sprayidx = randomInt(15);//self statGets("SPRAY");
		
		playFx( level.sprayonwall["spray"+sprayidx], self.origin);
		
		self playSound( "sprayit" );		
		
		wait 3;
		
		self.usingspray = false;	
}


//PARA BOTS
BotLoadupgradesOnSpawn()
{

	if(!isDefined(self.class)) return;
	
	if(!isAlive(self)) return;

	self.upgradefolego = self IsUpgradesOn("upgradefolego");
	
	if(self.upgradefolego)
	self setPerk( "specialty_longersprint" );
	
	self.upgradefalldamage = self IsUpgradesOn("upgradefalldamage");
	self.upgradeprecisionshoot = self IsUpgradesOn("upgradeprecisionshoot");
	self.upgradebuffreset = self IsUpgradesOn("upgradebuffreset");
	
	//medic
	self.upgradefastrevive = self IsUpgradesOn("upgradefastrevive");
	self.upgradefastRegen = self IsUpgradesOn("upgradefastRegen");	
	self.upgrademedkitPack = self IsUpgradesOn("upgrademedkitPack");
	self.upgradeammopack = self IsUpgradesOn("upgradeammopack");
	
	self.upgradewalldamageresist = self IsUpgradesOn("upgradewalldamageresist");
	self.upgradefastchange = self IsUpgradesOn("upgradefastchange");
	self.upgradebombdisarmer = self IsUpgradesOn("upgradebombdisarmer");
	self.upgradehackspot = self IsUpgradesOn("upgradehackspot");
	self.upgradescavenger = self IsUpgradesOn("upgradescavenger");
	self.upgradeteargas = self IsUpgradesOn("upgradeteargas");
	self.upgradeposiondamage = self IsUpgradesOn("upgradeposiondamage");
	self.upgradecapturenaderesist = self IsUpgradesOn("upgradecapturenaderesist");	
	self.upgradesensorseeker = self IsUpgradesOn("upgradesensorseeker");
	self.upgradedropitems = self IsUpgradesOn("upgradedropitems");	
	//self.upgradedropnades = self IsUpgradesOn("upgradedropnades");		
	self.upgrademedicsmoke = self IsUpgradesOn("upgrademedicsmoke");	
	//---------------
	self.dangercloser = self IsUpgradesOn("upgradedangercloser");
	self.takedown = self IsUpgradesOn("upgradetakedown");
	self.coldblooded = self IsUpgradesOn("upgradecoldblooded");
	self.incognito = self IsUpgradesOn("upgradeincognito");
	self.sitrep = self IsUpgradesOn("upgradesitrep");
	self.wallbang = self IsUpgradesOn("upgradewallbang");
	self.collateral = self IsUpgradesOn("upgradecollateral");
	self.medicpro = self IsUpgradesOn("upgrademedicpro");
	self.peripherals = self IsUpgradesOn("upgradeperipherals");
	
	//new 2024
	self.upgradespotondeath = self IsUpgradesOn("upgradespotondeath");
	self.upgradesensorgas = self IsUpgradesOn("upgradesensorgas");	
	self.upgradespydronepro = self IsUpgradesOn("upgradespydronepro");
	self.skillbuffcarepackage = self IsUpgradesOn("skillbuffcarepackage");
	self.skillbuffpredator = self IsUpgradesOn("skillbuffpredator");
	self.skillbuffspydrone = self IsUpgradesOn("skillbuffspydrone");
		
	switch ( randomint( 6 ) )
	{
		case 0:
			self.upgradefalldamage = true;
			self.upgradeprecisionshoot = true;
			self.upgradedropitems = true;
			break;
			
		case 1://medico
			self.medicpro = true;
			self.upgradefastRegen  = true;
			self.upgradecapturenaderesist  = true;
			self.coldblooded  = true;
			break;
			
		case 2:
			self.dangercloser = true;
			self.collateral = true;
			self.upgradeposiondamage = true;
			self.wallbang = true;
			break;
			
		case 3:
			self.medicpro = true;
			self.upgradefastRegen  = true;
			self.upgradecapturenaderesist  = true;
			break;
			
		case 4:
			self.takedown = true;
			self.dangercloser = true;
			self.collateral = true;
			self.wallbang = true;
			break;
	}
	
	//iprintlnbold(self.name +" ->>> "+ self.isbot);
	//self.medicpro = true;
	self.cur_buff_streak = 0;
	//SKILLS

	//temp	
	self.ffkiller = false;
	
	if(self.sitrep)
	self setPerk( "specialty_detectexplosive" );
	
	
	if(self.class == "sniper")
	{
		self.isSniper = true;
		self setClientDvar( "jump_slowdownEnable",0);
	}

	if(level.atualgtype == "sd" && self.upgradebombdisarmer)
	{
		if(isDefined(game["defenders"]) && self.pers["team"] == game["defenders"])
		{
			//self iprintln("upgradebombdisarmer:" + self.upgradebombdisarmer);
			self.allowdestroyexplosives = true;
			self thread promatch\_spreestreaks::allowDefenderExplosiveDestroy();
			level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry( "any" );			
		}	
	}
	else self.allowdestroyexplosives = false;
	
	if(self.medicpro)
	{
		self.medic = true;
		self.healthmaster = true;
		self thread promatch\_medic::SetMedic();
	
		if(level.atualgtype == "sd")
		self sayteam( "^2Medico^7 aqui!!" );	
		
		if(self.upgradefastRegen)
		self thread maps\mp\gametypes\_healthoverlay::playerHealthRegen();
	}
	
	if(self.peripherals)
	{
		self setClientDvar( "compassMaxRange", 2500 );
		self setClientDvar( "compassRadarPingFadeTime",2);
	}	
}