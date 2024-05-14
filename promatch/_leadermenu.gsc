#include common_scripts\utility;
#include promatch\_eventmanager;
#include promatch\_utils;
//V207 V5
init()
{
	//if(level.cod_mode == "torneio") return;
		
	level.scr_denuncias_reasons_code = [];
	
	// Add no custom reason option
	level.scr_denuncias_reasons_code[0] = "<Sem Motivos>";

	level.scr_denuncias_reasons_code[1] = "<WallHack>";
	
	level.scr_denuncias_reasons_code[2] = "<Aimbot>";	
	
	level.scr_denuncias_reasons_code[3] = "<Elevador>";
	
	level.scr_denuncias_reasons_code[4] = "<Script Tiro Rapido>";
	
	level.scr_denuncias_reasons_code[5] = "<Glitch Fora do Mapa>";
	
	level.scr_denuncias_reasons_code[6] = "<Farming XP>";
	
	level.scr_denuncias_reasons_code[7] = "<Estragando o jogo>";
	
	level.leaderPlayers = [];
	
	level thread addNewEvent( "onPlayerConnecting", ::addPlayer );
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


addPlayer()
{	
	i = 0; 
	while ( isDefined(level.leaderPlayers[i] ) ) 
	i++;
	level.leaderPlayers[i] = self;
}

onPlayerConnected()
{
	self setClientDvar("ui_leader_player", self getFirstPlayer());
	self setClientDvar("ui_leader_reason",self getFirstReason());
	self thread onMenuResponse();	
}


getFirstPlayer()
{	
	index = 0;
	while ( index < level.leaderPlayers.size ) 
	{
		if(isDefined(level.leaderplayers[index]))
		{
			break;		
		}
		index++;
	}
	
	// Save player's GUID
	self.leaderPlayer = ""+level.leaderPlayers[index] getEntityNumber();
	return level.leaderPlayers[index].name;		
}


getPreviousPlayer()
{	

	// Get the current's player position
	index = 0;
	index = self getCurrentPlayer( true );
	index--;
	
	// Cycle until we found the next defined player
	while ( index >= 0 ) 
	{
		if(isDefined( level.leaderplayers[index] ) ) 
		{
			break;
		}
		index--;
	}
	
	// Check if we couldn't find a defined player and search from the end again
	if ( index < 0 ) 
	{
		index = level.leaderPlayers.size - 1;
		while ( index >= 0 )
		{
			if(isDefined( level.leaderplayers[index] ) )
			{
				break;
			}
			index--;
		}		
	}

	if ( index < 0 )
	{
		self.leaderPlayer = "";
		return "";	
	} 
		else 
	{

	self.leaderPlayer = ""+level.leaderplayers[index] getEntityNumber();

	return level.leaderplayers[index].name + " [" + level.leaderplayers[index] getEntityNumber()+"]";
	}
}


getNextPlayer()
{	
	// Get the current's player position
	index = 0;
	index = self getCurrentPlayer( true );
	index++;
	
	// Cycle until we found the next defined player
	while ( index < level.leaderPlayers.size ) 
	{
		if ( isDefined( level.leaderPlayers[index] ) ) 
		{
			break;
		}
		index++;
	}
	
	// Check if we couldn't find a defined player and search from the end again
	if ( index == level.leaderPlayers.size ) 
	{
		index = 0;
		while ( index < level.leaderPlayers.size ) 
		{
			if ( isDefined( level.leaderPlayers[index] ) ) 
			{
				break;
			}
			index++;
		}		
	}
	
	if ( index == level.leaderPlayers.size ) 
	{
		self.leaderPlayer = "";
		return "";
	}
	else 
	{	
		self.leaderPlayer = ""+level.leaderPlayers[index] getEntityNumber();
		//Jogador Marcado parar observar
		return level.leaderPlayers[index].name;	
	}
}
//============================================================
//usado para SQUADMENUS
//============================================================
getCurrentPlayerTeam( returnPosition)
{	
	// If there's no player then we return undefined or the position zero
	if ( self.leaderPlayer == "" ) 
	{
		if ( returnPosition ) {
			return 0;
		} else {
			return undefined;
		}		
	}	
	

	// Find the position of the current player
	index = 0;
	while ( index < level.leaderPlayers.size ) 
	{
		playerteam = level.leaderPlayers[index].pers["team"];

		if (isDefined( level.leaderPlayers[index] ) && isDefined(playerteam) && playerteam == self.pers["team"] && ""+level.leaderPlayers[index] getEntityNumber() == self.leaderPlayer ) 
		{
			break;
		}
		index++;
	}
	// If player disconnected we then
	if ( index == level.leaderPlayers.size ) 
	{
		// Functions are not supposed to return two different type of values but what the hell
		if ( returnPosition ) {
			return 0;
		} else {
			return undefined;
		}
	} else 
	{
		// Functions are not supposed to return two different type of values but what the hell
		if ( returnPosition ) {
			return index;
		} else {
			return level.leaderPlayers[index];
		}
	}

}

getNextPlayerSameTeam()
{	
	// Get the current's player position
	index = 0;
	index = self getCurrentPlayerTeam( true);
	index++;
	
	// Cycle until we found the next defined player
	while ( index < level.leaderPlayers.size ) 
	{
		
		if ( isDefined( level.leaderPlayers[index] ))
		{
			if(isDefined(level.leaderPlayers[index].pers["team"]))
			{
				if(level.leaderPlayers[index].pers["team"] == self.pers["team"])
				break;
			}			
		}
		index++;
	}
	
	// Check if we couldn't find a defined player and search from the end again
	if ( index == level.leaderPlayers.size ) 
	{
		index = 0;
		//^1Error: script runtime error: potential infinite loop in script - killing thread. - fixed (self.leaderActiveCommand not set)
		while ( index < level.leaderPlayers.size ) 
		{		
			if ( isDefined( level.leaderPlayers[index] ))
			{	
			//pair 'undefined' and 'allies' has unmatching types 'undefined' and 'string': (file 'promatch/_leadermenu.gsc', line 240)
				if(isDefined(level.leaderPlayers[index].pers["team"]))
				{
					if(level.leaderPlayers[index].pers["team"] == self.pers["team"] )
					break;
				}
				else
				continue;
			}
			index++;
		}		
	}	
	
	self.leaderPlayer = ""+level.leaderPlayers[index] getEntityNumber();
	return level.leaderPlayers[index].name;		
}


getCurrentPlayer( returnPosition )
{	
	// If there's no player then we return undefined or the position zero
	if ( self.leaderPlayer == "" ) 
	{
		if ( returnPosition ) {
			return 0;
		} else {
			return undefined;
		}		
	}	
	

	// Find the position of the current player
	index = 0;
	while ( index < level.leaderPlayers.size ) 
	{
		if ( isDefined( level.leaderPlayers[index] ) && ""+level.leaderPlayers[index] getEntityNumber() == self.leaderPlayer ) 
		{
			break;
		}
		index++;
	}
	// If player disconnected we then
	if ( index == level.leaderPlayers.size ) {
		// Functions are not supposed to return two different type of values but what the hell
		if ( returnPosition ) {
			return 0;
		} else {
			return undefined;
		}
	} else {
		// Functions are not supposed to return two different type of values but what the hell
		if ( returnPosition ) {
			return index;
		} else {
			return level.leaderPlayers[index];
		}
	}

}

getFirstReason()
{
	index = 0;
	currentReason = level.scr_denuncias_reasons_code[ index ];
	self.denunciaReason = index;return currentReason;
}

getNextReason()
{
	// Check if we are going outside the array
	if ( self.denunciaReason == level.scr_denuncias_reasons_code.size - 1 ) {
		self.denunciaReason = 0;
	} else {
		self.denunciaReason++;
	}
	return level.scr_denuncias_reasons_code[self.denunciaReason];		
}

onMenuResponse()
{
	self endon("disconnect");


	self setClientDvar( "ui_leader_reason", "Motivo" );
	
	for(;;)
	{
		self waittill( "menuresponse", menuName, menuOption );

		//self.squadleader = (self getStat(3164) == 1);
		
		if ( menuName != "leadermenu" && isAlive(self) && isDefined(self.squad) && !isDefined(self.leaderActiveCommand) )
		{	
		
			self.leaderActiveCommand = true;			
						
			switch ( menuOption ) 
			{
				case "squad_nextplayer":
				player = self getCurrentPlayerTeam( false);
				self setClientDvar( "ui_leader_player", self getNextPlayerSameTeam() );					
				break;

				
				case "squad_add":
				//undefined is not a field object
				player = self getCurrentPlayerTeam( false);
				
				//iprintln("squadmember-> " + player.name);
				//undefined is not a field object: (file 'promatch/_leadermenu.gsc', line 340)
				//fixex?
				if(!isDefined(player)) break;
				
				if(!isDefined(player.squad))
				{					
					//como eu sou o lider eu tenho as infor dos squads
					squadname = self promatch\_squadteam::GetStatSquad();					
					player.dont_auto_balance = true;
					player thread promatch\_squadteam::joinSquad(squadname);
					
					//iprintln("squadname-> " + squadname);

				}
				break;
				
				case "squad_kick":
				player = self getCurrentPlayerTeam( false);
				if( !isDefined( player.squad ) )
				break;
				
				//iprintln("kicksquad-> " + player.name);			
				//carrega qual o numero no squad deste jogador
				kicking = player statGets("SQUAD_NUMBER");
				//iprintln("kicksquad-> " + kicking);

				//if( kicking == game[ self.squad ][ 0 ] )
				player thread promatch\_squadteam::leaveSquad( true );				
				break;				
			}
			
			self.leaderActiveCommand = undefined;
		}
		
		if ( isSubStr(menuOption,"report_") && !isdefined(self.leaderActiveCommand) ) 
		{
			self.leaderActiveCommand = true;
			//iprintln("menuOption-> " + menuOption);
			switch ( menuOption ) 
			{
				
				case "report_nextplayer":
					player = self getCurrentPlayer( false );
					self setClientDvar( "ui_leader_player", self getNextPlayer() );					
					break;

					case "report_nextreason":
					self setClientDvar( "ui_leader_reason", self getNextReason() );
					break;

					
				case "report_TakeScreenshot":
					// Check if this player is still connected and alive
					player = self getCurrentPlayer( false );
					//iprintln("PPPP: " + player.name);
					if ( isDefined( player ) ) 
					{
						exec("getss " + player getEntityNumber());	
						//loga no server
						self ScreenshotLog(player);
						
						self playLocalSound( "weap_ammo_pickup" );
					}
					else 
						{
							
							self setClientDvar( "ui_leader_player", self getNextPlayer() );
						}
					break;
					
					case "report_registrardenuncia":
					// Check if this player is still connected
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						// Check if we should display a custom message or just kick the player directly
						if(isDefined(self.denunciaReason))
						{
							if ( level.scr_denuncias_reasons_code[ self.denunciaReason ] != "<Sem Motivos>" ) 
							{
								self GravarDenuncia(player,level.scr_denuncias_reasons_code[ self.denunciaReason ]);
							}
						}
					}
					self setClientDvar( "ui_leader_player", self getNextPlayer() );
					break;					
			}
			self.leaderActiveCommand = undefined;
		}
	}
}

GravarDenuncia(denunciado,motivo)
{

	playerid = denunciado getguid();
	diagravado = int(TimeToString(GetRealTime(),1,"%d"));
	mesgravado = int(TimeToString(GetRealTime(),1,"%m"));
	FS_WriteLine(1, "Data: "+ diagravado+"/"+mesgravado);
	
	idfile = FS_FOpen("denuncias.txt", "append");//id = 1
	if(idfile <= 0) 
	{
		logPrint("Erro ao gravar Arquivo");
		return;
	}

	FS_WriteLine(1,"\n-------------------------------------------------");
	FS_WriteLine(1, "Data: "+ diagravado+"/"+mesgravado);
	FS_WriteLine(1, "Quem Denunciou: "+ self.name + " ["+self getguid()+"]");
	FS_WriteLine(1, "Jogador: "+ denunciado.name + " ["+playerid+"]");
	FS_WriteLine(1,"Motivo: " + motivo);
	FS_WriteLine(1,"-------------------------------------------------");
	FS_FClose(idfile);
}