#include common_scripts\utility;
#include promatch\_eventmanager;
#include promatch\_utils;

init()
{
	// Get the main module's dvar
	level.scr_aacp_enable = getdvard( "scr_aacp_enable", "int", 1, 0, 1 );

	// Load maps
	tempMaps = getdvarlistx( "scr_aacp_maps_", "string", "" );
	// If we don't have any maps we'll set the stock ones
	if ( tempMaps.size == 0 ) {	tempMaps[0] = level.defaultMapList;	}
	
	// Process all the maps and add them to the internal array
	level.scr_aacp_maps = [];
	for ( iMapLine = 0; iMapLine < tempMaps.size; iMapLine++ ) 
	{
		theseMaps = strtok( toLower( tempMaps[iMapLine] ), ";" );
		for ( iMap = 0; iMap < theseMaps.size; iMap++ ) 
		{
			level.scr_aacp_maps[ level.scr_aacp_maps.size ] = theseMaps[iMap];
		}		
	}
	
	//usado para resetar a rotaçao caso o adm erre ou queira desfazer
	level.oldrotation =  getDvar( "sv_mapRotationCurrent" );
	
	//LEVEL DEFIN
	// Gametypes
	level.scr_aacp_gametypes = getdvard( "scr_aacp_gametypes", "string", level.defaultGametypeList );
	level.scr_aacp_gametypes = strtok( level.scr_aacp_gametypes, ";" );
	level.setnext = "";
	
	//Redirect
	level.scr_reservedslots_redirectip = getdvarx( "scr_reservedslots_redirectip", "string", "" );
	
	// Rulesets DEfault
	level.scr_aacp_rulesets = getdvard( "scr_aacp_rulesets", "string", "" );
	level.scr_aacp_rulesets = strtok( level.scr_aacp_rulesets, ";" );

	// Custom reasons
	tempReasons = getdvarlistx( "scr_aacp_custom_reason_", "string", "" );
	level.scr_aacp_custom_reasons_code = [];
	level.scr_aacp_custom_reasons_text = [];
	
	// Add no custom reason option
	level.scr_aacp_custom_reasons_code[0] = "<No Custom Reason>";
	level.scr_aacp_custom_reasons_text[0] = "";
	for ( iLine=0; iLine < tempReasons.size; iLine++ ) 
	{
		thisLine = strtok( tempReasons[iLine], ";" );
		
		// Add the new custom reason
		newElement = level.scr_aacp_custom_reasons_code.size;
		level.scr_aacp_custom_reasons_code[newElement] = thisLine[0];
		level.scr_aacp_custom_reasons_text[newElement] = thisLine[1];
	}
	
	level._effect["aacp_explode"] = loadfx( "props/barrelexp" );	
	level._effect[ "sectors" ] = loadfx("misc/ui_flagbase_red");
	
	// Access codes	
	level.aacpIconOffset = (0,0,75);
	level.aacpIconShader = "waypoint_kill";
	level.aacpIconCompass = "compass_waypoint_target";
	precacheShader(level.aacpIconShader);
	precacheShader(level.aacpIconCompass);
	

	level.aacpPlayers = [];
	level thread addNewEvent( "onPlayerConnecting", ::addPlayer );
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
	//level thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	
}

addPlayer()
{
	// We'll add the player in the first undefined slot we find
	i = 0; 
	while ( isDefined( level.aacpPlayers[i] ) ) 
	i++;
	level.aacpPlayers[i] = self;		
}


onPlayerConnected()
{
	self thread initAACP();
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}

onPlayerSpawned()
{	
	// Save spawn information
	self.spawnOrigin = self getOrigin();
	self.spawnAngles = self getPlayerAngles();
}

Setuiclientvars()
{	
   self endon("disconnect");
	//anti glitches
	if ( getDvarInt( "scr_killtriggers") == 0)
	{
		self setClientDvar("ui_killtriggers", 0 );
	} else 
	{
		self setClientDvar("ui_killtriggers", 1 );
	}

	//globalchat
	if ( getDvarInt( "globalchat") == 0)
	{
		self setClientDvar("ui_globalchat", 0 );
	} else 
	{
		self setClientDvar("ui_globalchat", 1 );
	}		
	//server record
	if (getDvarInt( "sv_autodemorecord") == 0)
	{	
		self setClientDvar("ui_autodemorecord", 0 );	
	} else 
	{
		self setClientDvar("ui_autodemorecord", 1 );				
	}
	//Sniper only
	if (getDvarInt( "scr_Sniperonly") == 0)
	{	
		self setClientDvar("ui_sniperonly", 0 );	
	} else 
	{
		self setClientDvar("ui_sniperonly", 1 );				
	}
	//knife only
	if (getDvarInt( "scr_knifeonly") == 0)
	{	
		self setClientDvar("ui_knifeonly", 0 );	
	} else 
	{
		self setClientDvar("ui_knifeonly", 1 );				
	}	
	
	//hardcore
	if (getDvarInt( "sv_hardcoreMode") == 0)
	{	
		self setClientDvar("ui_hcmode", 0 );	
	} else 
	{
		self setClientDvar("ui_hcmode", 1 );				
	}	
	
	//ThirdPerson
	if (getDvarInt( "scr_thirdperson_enable") == 0)
	{	
		self setClientDvar("ui_thirdperson", 0 );	
	} 
	else 
	{
		self setClientDvar("ui_thirdperson", 1 );				
	}

	//killcam
	if ( getDvarInt( "scr_game_allowkillcam") == 0)
	{
		self setClientDvar("ui_allowkillcam", 0 );	
	} else 
	{
		self setClientDvar("ui_allowkillcam", 1 );	
	}
	//Cod mode
	if ( getDvar( "cod_mode") == "practice")
	{
		self setClientDvar("ui_cod_mode", "practice_rule" );	
	} 
	else if ( getDvar( "cod_mode") == "torneio")
	{
		self setClientDvar("ui_cod_mode", "torneio_rule" );	
	}
	else if ( getDvar( "cod_mode") == "promatch_r15")
	{
		self setClientDvar("ui_cod_mode", "promatch_r15_rule" );	
	}
	else if ( getDvar( "cod_mode") == "public")
	{
		self setClientDvar("ui_cod_mode", "public_rule" );	
	}
	else if ( getDvar( "cod_mode") == "custom")
	{
		self setClientDvar("ui_cod_mode", "custom_rule" );	
	}	
	
}


initAACP()
{
	self endon("disconnect");

	if(self statGets("ADMIN") == 1)
	{
		self.aacpAccess = "true";
		self.aacpActiveCommand = false;
		
		self setClientDvars(
		"ui_aacp_map", self getCurrentMap(),
		"ui_aacp_gametype", self getCurrentGametype(),
		"ui_aacp_ruleset", self getCurrentRuleset(),
		"ui_aacp_player", self getFirstPlayer(),
		"ui_aacp_reason", self getFirstReason()
		);
		self thread Setuiclientvars();//207
		self thread onMenuResponse();
	}
	else
	{
		self.aacpAccess = "";
		//self thread onMenuResponse();
	}

	if(self isMaster(self) && (isDefined(self.aacpAccess) && self.aacpAccess == "" && self statGets("ADMIN") != 1))
	{
    	self.aacpAccess = "beta";
		self.aacpActiveCommand = false;
		//iprintlnbold(self.aacpAccess);
		self setClientDvars(
		"ui_aacp_map", self getCurrentMap(),
		"ui_aacp_gametype", self getCurrentGametype(),
		"ui_aacp_ruleset", self getCurrentRuleset(),
		"ui_aacp_player", self getFirstPlayer(),
		"ui_aacp_reason", self getFirstReason()
		);
		self thread Setuiclientvars();
		self thread onMenuResponse();
		return;
	}
}

getCurrentMap()
{
	// Get the current map and get the position in our array
	currentMap = toLower( getDvar( "mapname" ) );
	
	index = 0;
	while ( index < level.scr_aacp_maps.size && currentMap != level.scr_aacp_maps[ index ] )
	{
		index++;
	}
	
	// If we can't find the map then we just use the first map in the array
	if ( index == level.scr_aacp_maps.size ) 
	{
		index = 0;
		currentMap = level.scr_aacp_maps[ index ];
	}
	
	self.aacpMap = index;
	return getMapName( currentMap );	
}


getCurrentGametype()
{
	// Get the current gametype and get the position in our array
	currentType = toLower( getDvar( "g_gametype" ) );
	
	index = 0;
	while ( index < level.scr_aacp_gametypes.size && currentType != level.scr_aacp_gametypes[ index ] ) {
		index++;
	}
	
	// If we can't find the gametype then we just use the first gametype in the array
	if ( index == level.scr_aacp_gametypes.size ) 
	{
		index = 0;
		currentType = level.scr_aacp_gametypes[ index ];
	}
	
	self.aacpType = index;
	return getGameType( currentType );	
}

getCurrentRuleset()
{
	// If there's no active ruleset then there's no need to search for it
	currentRuleset = level.cod_mode;
	if ( currentRuleset != "" ) {
		index = 0;
		while ( index < level.scr_aacp_rulesets.size && currentRuleset != level.scr_aacp_rulesets[ index ] ) {
			index++;
		}
	} else {
		index = level.scr_aacp_rulesets.size;
	}
	
	// If we can't find the ruleset then we just return the first element in the array if there's one
	if ( index == level.scr_aacp_rulesets.size ) {
		if ( level.scr_aacp_rulesets.size > 0 ) {
			index = 0;
			currentRuleset = level.scr_aacp_rulesets[ index ];
		} else {
			index = -1;
			currentRuleset = "";
		}
	}
	
	self.aacpRuleset = index;
	return currentRuleset;	
}


getFirstPlayer()
{
	// Get the first defined player
	index = 0;
	while ( index < level.aacpPlayers.size )
	{
		if ( isDefined( level.aacpPlayers[index] )  )
		{
			break;
		}
		index++;
	}	
	// Save player's ID
	self.aacpPlayer = ""+level.aacpPlayers[index] getEntityNumber();
//	self iprintln(self.aacpPlayer);
	return level.aacpPlayers[index].name + " [" + level.aacpPlayers[index] getEntityNumber()+"]";
}


getFirstReason(){index = 0;currentReason = level.scr_aacp_custom_reasons_code[ index ];self.aacpReason = index;return currentReason;}


getPreviousMap()
{// Check if we are going outside the array
	if ( self.aacpMap == 0 ) {	self.aacpMap = level.scr_aacp_maps.size - 1;} else {self.aacpMap--;}return getMapName( level.scr_aacp_maps[ self.aacpMap ] );	
}


getNextMap()
{// Check if we are going outside the array
	
	if ( self.aacpMap == level.scr_aacp_maps.size - 1 ) 
	{
		self.aacpMap = 0;
	} 
	else 
	{
		self.aacpMap++;
	}
	return 
	
	getMapName( level.scr_aacp_maps[ self.aacpMap ] );
}


getPreviousGametype()
{
	// Check if we are going outside the array
	if ( self.aacpType == 0 ) {
		self.aacpType = level.scr_aacp_gametypes.size - 1;
	} else {
		self.aacpType--;
	}
	return getGameType( level.scr_aacp_gametypes[ self.aacpType ] );	
}


getNextGametype()
{
	// Check if we are going outside the array
	if ( self.aacpType == level.scr_aacp_gametypes.size - 1 ) {
		self.aacpType = 0;
	} else {
		self.aacpType++;
	}
	return getGameType( level.scr_aacp_gametypes[ self.aacpType ] );		
}
// If we can't find the player then we just use the first in the array
getUpdatePlayers()
{
	self.aacpAccess = "master";
	self.aacpActiveCommand = false;
	self setClientDvars(
	"ui_aacp_map", self getCurrentMap(),
	"ui_aacp_gametype", self getCurrentGametype(),
	"ui_aacp_ruleset", self getCurrentRuleset(),
	"ui_aacp_player", self getFirstPlayer(),
	"ui_aacp_reason", self getFirstReason()
	);
	self thread Setuiclientvars();
	self thread onMenuResponse();
	return;
}

getPreviousRuleset()
{
	// Check if we have any rulesets
	if ( level.scr_aacp_rulesets.size > 0 ) {
		// Check if we are going outside the array
		if ( self.aacpRuleset == 0 ) {
			self.aacpRuleset = level.scr_aacp_rulesets.size - 1;
		} else {
			self.aacpRuleset--;
		}
		return level.scr_aacp_rulesets[ self.aacpRuleset ];
	} else {
		return "";
	}
}


getNextRuleset()
{
	// Check if we have any rulesets
	if ( level.scr_aacp_rulesets.size > 0 ) {	
		// Check if we are going outside the array
		if ( self.aacpRuleset == level.scr_aacp_rulesets.size - 1 ) 
		{
			self.aacpRuleset = 0;
		} else {
			self.aacpRuleset++;
		}
		return level.scr_aacp_rulesets[ self.aacpRuleset ];		
	} else {
		return "";
	}
}


getPreviousPlayer()
{	// Get the current's player position
	index = 0;
	index = self getCurrentPlayer( true );	
	index--;
	// Cycle until we found the next defined player
	while ( index >= 0 ) 
	{	
	if ( isDefined( level.aacpPlayers[index] ) ) 
	{	break;
	}
	index--;
	}
	
	// Check if we couldn't find a defined player and search from the end again
	if ( index < 0 ) 
	{	index = level.aacpPlayers.size - 1;
	while ( index >= 0 ) 
		{
			if ( isDefined( level.aacpPlayers[index] ) ) {break;} index--;
			
		}
	}

	if ( index < 0 )
	{
		self.aacpPlayer = "";
		return "";	
	} 
		else 
	{

	self.aacpPlayer = ""+level.aacpPlayers[index] getEntityNumber();
	//Jogador Marcado parar observar
	if(level.aacpPlayers[index] statGets("MARKPLAYER") != 0)
	return level.aacpPlayers[index].name + " ^5[" + level.aacpPlayers[index] getEntityNumber()+"]";
	else
	return level.aacpPlayers[index].name + " [" + level.aacpPlayers[index] getEntityNumber()+"]";
	}
}


getNextPlayer()
{
	// Get the current's player position
	index = 0;
	index = self getCurrentPlayer( true );
	index++;
	
	// Cycle until we found the next defined player
	while ( index < level.aacpPlayers.size ) 
	{
		if ( isDefined( level.aacpPlayers[index] ) ) 
		{
			break;
		}
		index++;
	}
	
	// Check if we couldn't find a defined player and search from the end again
	if ( index == level.aacpPlayers.size ) 
	{
		index = 0;
		while ( index < level.aacpPlayers.size ) 
		{
			if ( isDefined( level.aacpPlayers[index] ) ) 
			{
				break;
			}
			index++;
		}		
	}

	if ( index == level.aacpPlayers.size ) 
	{
		self.aacpPlayer = "";
		return "";
	} else 
	{
	
	if(level.aacpPlayers[index] statGets("TIMENUM") != 0)
	self setClientDvar( "ui_timenum",level.aacpPlayers[index] statGets("TIMENUM") );
		
	self.aacpPlayer = ""+level.aacpPlayers[index] getEntityNumber();
	//Jogador Marcado parar observar
	if(level.aacpPlayers[index] statGets("MARKPLAYER") != 0)
	return level.aacpPlayers[index].name + " ^5[" + level.aacpPlayers[index] getEntityNumber()+"]";
	else
	return level.aacpPlayers[index].name + " [" + level.aacpPlayers[index] getEntityNumber()+"]";	
	}
}


getPreviousReason()
{
	// Check if we are going outside the array
	if ( self.aacpReason == 0 ) {
		self.aacpReasons = level.scr_aacp_custom_reasons_code.size - 1;
	} else {
		self.aacpReason--;
	}
	return level.scr_aacp_custom_reasons_code[self.aacpReason];	
}


getNextReason()
{
	// Check if we are going outside the array
	if ( self.aacpReason == level.scr_aacp_custom_reasons_code.size - 1 ) {
		self.aacpReason = 0;
	} else {
		self.aacpReason++;
	}
	return level.scr_aacp_custom_reasons_code[self.aacpReason];		
}


getCurrentPlayer( returnPosition )
{
	// If there's no player then we return undefined or the position zero
	if ( self.aacpPlayer == "" ) 
	{
		if ( returnPosition ) 
		{
			return 0;
		} else 
		{
			return undefined;
		}		
	}	
	
	// Find the position of the current player
	index = 0;
	while ( index < level.aacpPlayers.size ) 
	{
		if ( isDefined( level.aacpPlayers[index] ) && ""+level.aacpPlayers[index] getEntityNumber() == self.aacpPlayer ) 
		{
			break;
		}
		index++;
	}
	
	// If player disconnected we then
	if ( index == level.aacpPlayers.size ) {
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
		} else 
		{
			return level.aacpPlayers[index];
		}
	}	
}

onMenuResponse()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill( "menuresponse", menuName, menuOption );		
		// Make sure we handle only responses coming from the Advanced ACP menu
		if ( (menuName == "vipmenu" || menuName == "advancedacp" || menuName == "playercontrol") && !self.aacpActiveCommand ) 
		{
			self.aacpActiveCommand = true;
		
			if (isSubStr( menuOption, "botcontrol" ) )
			{
				sTwcommand = strTok( menuOption, ":" );
				menuOption = sTwcommand[1];
			}
						
			switch ( menuOption )
			{
				//VIPMENUS CASES
				case "pagpendente":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						/*if(player statGets("PENDENCIA") == 0)
						{
							player statSets("PENDENCIA",1);
							self adminmsg("VIP PENDENTE REGISTRADO");
						}
						else
						{
							self adminmsg("PENDENCIA REMOVIDA");
							player statSets("PENDENCIA",0);
						}*/
						player thread ForceResetRankOnly();
						self adminmsg("rankresetados");
					} 
					else {self setClientDvar( "ui_aacp_player", self getNextPlayer() );}
				break;
				
				case "add100evp":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						//player atualizardovip();
						player statAdds("EVPSCORE",100);
						self setClientDvar( "ui_add100evp",player statGets("EVPSCORE") );
					} 
					else {self setClientDvar( "ui_aacp_player", self getNextPlayer() );}
				break;

				//1000 EVP
				case "add1000evp":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						player statAdds("EVPSCORE",1000);
						//UPDADE MY INFO
						self setClientDvar( "ui_add1000evp",player statGets("EVPSCORE") );
					} 
					else {self setClientDvar( "ui_aacp_player", self getNextPlayer() );}
				break;

//===========SET CLAN==============	
				case "setasclan":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{						
						if(player statGets("CLANMEMBER") == 0)
						{
							player statSets("CLANMEMBER",1);
							player.clanmember = true;
							
							self adminmsg("CLANMEMBER REGISTRADO");
							//self thread vipLogtoServer(player);
						}
						else
						{
							self adminmsg("CLANMEMBER REMOVIDO");
							player statSets("CLANMEMBER",0);
							player.clanmember = false;
							//self thread vipLogtoServer(player);
						}						
					} 
					else {self setClientDvar( "ui_aacp_player", self getNextPlayer() );}
				break;
				
				case "setascustommember":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{						
						if(player statGets("CUSTOMMEMBER") == 0)
						{
							player statSets("CLANMEMBER",0);
							player statSets("CUSTOMMEMBER",1);
							player.custommember = true;
							
							self adminmsg("CUSTOMMEMBER REGISTRADO");
							//self thread vipLogtoServer(player);
						}
						else
						{
							self adminmsg("CUSTOMMEMBER REMOVIDO");
							player statSets("CLANMEMBER",0);
							player statSets("CUSTOMMEMBER",0);
							player.custommember = false;
							//self thread vipLogtoServer(player);
						}						
					} 
					else {self setClientDvar( "ui_aacp_player", self getNextPlayer() );}
				break;
//TORNEIO
				case "cadtimenum":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						timenum = player statGets("TIMENUM");
						
						if(timenum > 10)
						timenum = 0;
						else
						timenum++;
						
						player statSets("TIMENUM",timenum);
						
						self setClientDvar( "ui_timenum",player statGets("TIMENUM") );
					} 
					else {self setClientDvar( "ui_aacp_player", self getNextPlayer() );}
				break;
				
				case "cadlider":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						lidernum = player statGets("CLANLEADER");
						if(lidernum == 0)
						player statSets("CLANLEADER",1);
						else
						player statSets("CLANLEADER",0);
						
						self adminmsg("Lider Registrado: " + player statGets("CLANLEADER"));
					} 
					else {self setClientDvar( "ui_aacp_player", self getNextPlayer() );}
				break;
				
				case "adicionarmes":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						player AdicionarUmMes();
						self setClientDvar( "ui_mes",player statGets("MES") );
					} 
					else {self setClientDvar( "ui_aacp_player", self getNextPlayer() );}
				break;
				
				case "removermes":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						player RemoverUmMes();
						self setClientDvar( "ui_mes",player statGets("MES") );
					} 
					else {self setClientDvar( "ui_aacp_player", self getNextPlayer() );}
				break;
				
				case "restaurarscores":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{	
						player thread RestorePlayerBackup(player getguid());
						self adminmsg("DADOS REGISTRADOS");
					} 
					else {self setClientDvar( "ui_aacp_player", self getNextPlayer() );}
				break;
				
				case "premiumvip":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{	
						
						if(player statGets("PREMIUMVIP") == 0)
						{
							player statSets("PREMIUMVIP",1);
							self adminmsg("PREMIUM REGISTRADO");
						}
						else
						{
							player statSets("PREMIUMVIP",0);
							self adminmsg("PREMIUM REMOVIDO");
						}						
					} 
					else {self setClientDvar( "ui_aacp_player", self getNextPlayer() );}
				break;
				
				case "clearvipstats":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						player resetvipstats();
						self adminmsg("VIP STATS RESETADOS");
					} 
					else {self setClientDvar( "ui_aacp_player", self getNextPlayer() );}
				break;
				
				case "clearall":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						if(getDvarInt( "forceresetonly"))
						{
							//usar para reset especifico
							
							self adminmsg("RESETADO: " + player.name);
						}
						else
						{
							player firstConnectresetallstuff();
							self adminmsg("RESETADO: " + player.name);
						}
					} 
					else {self setClientDvar( "ui_aacp_player", self getNextPlayer() );}
				break;


				case "setasadmin":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						if(player statGets("ADMIN") == 0)
						player statSets("ADMIN",1);
						else
						player statSets("ADMIN",0);
					
						self adminmsg("Admin: " + player statGets("ADMIN"));
					} 
					else {self setClientDvar( "ui_aacp_player", self getNextPlayer() );}
				break;

				
				case "previousmap":
					self setClientDvar( "ui_aacp_map", self getPreviousMap() );
					break;
					
				case "nextmap":
					self setClientDvar( "ui_aacp_map", self getNextMap() );
					break;					

		
				case "g_sd":
				{
					//setdvar("g_gametype","sd");
					level.setnext = "sd";
					self iprintln( "^3Gametype is now ^1SD" );
				}
				break;	
				case "g_sab":
				{
					//setdvar("g_gametype","sab");
					level.setnext = "sab";
					self iprintln( "^3Gametype is now ^1SAB" );
				}
				break;
				case "g_dm":
				{
					//setdvar("g_gametype","dm");
					level.setnext = "dm";
					self iprintln( "^3Gametype is now ^1DM" );
				}
				break;	
				case "g_ctf":
				{
					//setdvar("g_gametype","ctf");
					level.setnext = "ctf";
					self iprintln( "^3Gametype is now ^1CTF" );
				}
				break;	
				case "g_tdm"://fixed TDM -> WAR
				{
					//setdvar("g_gametype","war");
					level.setnext = "war";
					self iprintln( "^3Gametype is now ^1TDM" );
				}
				break;
				case "g_dom":
				{
					//setdvar("g_gametype","dom");
					level.setnext = "dom";
					self iprintln( "^3Gametype is now ^1DOM" );
				}
				break;
				case "g_ass":
				{
					//setdvar("g_gametype","ass");
					level.setnext = "ass";
					self iprintln( "^3Gametype is now ^1ASS" );
				}
				break;
				case "g_kc":
				{
					//setdvar("g_gametype","kc");
					level.setnext = "kc";
					self iprintln( "^3Gametype is now ^1KC" );
				}
				break;
				case "g_gg":
				{
					//setdvar("g_gametype","gg");
					level.setnext = "gg";
					self iprintln( "^3Gametype is now ^1GG" );
				}
				break;	
				case "g_re":
				{
					//setdvar("g_gametype","re");
					level.setnext = "re";
					self iprintln( "^3Gametype is now ^1RE" );
				}
				break;
				case "g_tgr":
				{
					//setdvar("g_gametype","tgr");
					level.setnext = "tgr";
					self iprintln( "^3Gametype is now ^1TGR" );
				}
				break;
				case "g_tjn":
				{
					//setdvar("g_gametype","tjn");
					level.setnext = "tjn";
					self iprintln( "^3Gametype is now ^1TJN" );
				}
				break;
				
				case "g_crnk":
				{
					//setdvar("g_gametype","crnk");
					level.setnext = "crnk";
					self iprintln( "^3Gametype is now ^1CRANKED" );
				}
				break;
				
				case "g_toitc":
				{
					//setdvar("g_gametype","toitc");
					level.setnext = "toitc";
					self iprintln( "^3Gametype is now ^1TOITC" );
				}
				break;
				
				case "setnext":
					// Make sure the map being added is not the same as the next map in the rotation
					nextRotation = getDvar( "sv_mapRotationCurrent" );
					if(level.setnext == "")
					{
						newMap = "gametype " + toLower(level.gametype) + " map " + level.scr_aacp_maps[ self.aacpMap ];
					}
					else
					{
						level.gametype = level.setnext;
						newMap = "gametype " + level.gametype + " map " + level.scr_aacp_maps[ self.aacpMap ];
					}
					//iprintln("setnext: "+level.setnext);
					// Make sure the map rotation is not too long
					if ( nextRotation.size + newMap.size <= 1020 ) 
					{	
						//salva a rotaçao antiga
						rotbackup = getDvar( "sv_mapRotationold" );
						
						if(!isDefined(rotbackup))
						setDvar( "sv_mapRotationold",nextRotation);
					
						setDvar( "sv_mapRotationCurrent",  newMap + " " + nextRotation );
						//self iprintln("NextSet: " + newMap );
						level.setnext = "";
						//level.newmapoverride = true;
						setDvar("setnextmap", "1");
					}
					break;

					case "cancelrot":
					resetRotation = getDvar( "sv_mapRotationold" );//altual alterada
					
					if(!isDefined(resetRotation)) break;
					setDvar("setnextmap", "0");
					setDvar( "sv_mapRotationCurrent", resetRotation );
					self adminmsg("Rotacao resetada ao normal");
					level.setnext = "";					
					break;			
				
				case "autoeventos":
					eventoativo = getDvar( "scr_ativareventos" );
					if(eventoativo == "1")
					{
						self setClientDvar( "ui_eventos",0);
						setDvar( "scr_ativareventos", "0" );
						setDvar( "scr_eventorodando",0);
						self adminmsg("Rotacao de Eventos Desativada Manualmente");
					}
					else
					{
						self setClientDvar( "ui_eventos",1);
						setDvar( "scr_ativareventos", "1" );
						self adminmsg("Rotacao de Eventos Ativa Manualmente");
					}
					
					break;
					
				case "endmap":
					level.forcedEnd = true;
					if ( level.teamBased ) {
						thread maps\mp\gametypes\_globallogic::endGame( "tie", game["strings"]["round_draw"] );
					} else {
						thread maps\mp\gametypes\_globallogic::endGame( undefined, game["strings"]["round_draw"] );
					}
					break;					
					
				case "loadmap":
					//207 - if is the current map one do a Restart
					//iprintln("aacpType: " + level.scr_aacp_gametypes[ self.aacpType ]);
					if (level.scr_aacp_gametypes[ self.aacpType ] != level.setnext || level.scr_aacp_maps[ self.aacpMap ] != level.script ) 
					{
						nextRotation = " " + getDvar( "sv_mapRotationCurrent" );
						
						if (level.scr_aacp_gametypes[ self.aacpType ] != level.setnext)
						newgametype = level.setnext;
						else						
						newgametype = toLower(getDvar("g_gametype"));
						level.setnext = "";
						setDvar( "sv_mapRotationCurrent", "gametype " + newgametype + " map " + level.scr_aacp_maps[ self.aacpMap ] + nextRotation );
						exitLevel( false );	//restart the map
					}
					break;		
					
				case "rotatemap":
					exitLevel( false );					
					break;						
					
				case "restartmap":
					nextRotation = " " + getDvar("sv_mapRotationCurrent");
					setDvar("sv_mapRotationCurrent", "gametype " + toLower(getDvar("g_gametype")) + " map " + level.script + nextRotation );
					exitLevel( false );					
					break;	
					
				case "fastrestartmap":
					RankResetPunish();				
					map_restart( false );	
					break;					

				case "public_rule":
					setDvar( "cod_mode", "public");
					break;
				
				case "practice_rule":
					setDvar( "cod_mode", "practice");
					break;
					
				case "torneio_rule":
					setDvar( "cod_mode", "torneio");
					break;

				case "previousplayer":
					self setClientDvar( "ui_aacp_player", self getPreviousPlayer());
					break;
					
				case "nextplayer":
					self setClientDvar( "ui_aacp_player", self getNextPlayer());
					break;

				case "previousreason":
					self setClientDvar( "ui_aacp_reason", self getPreviousReason() );
					break;
					
				case "nextreason":
					self setClientDvar( "ui_aacp_reason", self getNextReason() );
					break;
					
				case "svdemorecord"://server 1.7a apenas
				if (getDvarInt( "sv_autodemorecord"))
				{	
					setDvar( "sv_autodemorecord", 0 );
					iprintln( "^3Server DemoRecord ^1Disable" ); 
				} else 
				{
					setDvar( "sv_autodemorecord", 1 );				
					iprintln( "^3Server DemoRecord: ^1Enable" ); 
					iprintln( "^1Server is now recording all players." );
				}
				break;
				
				case "killzone":
					//Check killzones dvars
					level.scr_killtriggers = getdvarx( "scr_killtriggers", "int", 0, 0, 1 );
					if ( getDvarInt( "scr_killtriggers"))
					{
						setDvar( "scr_killtriggers", 0 );
						iprintln( "^3Anti-Glitches ^1Disable" ); 
					} else 
					{
						setDvar( "scr_killtriggers", 1 );				
						iprintln( "^3Anti-Glitches ^1Enable" );
					}							
					break;
			
				case "hardcoremode":
					if(!isMaster(self)) break;	
					level.hardcoreMode = getdvarx( "sv_hardcoreMode", "int", 0, 0, 1 );
					if ( getDvarInt( "sv_hardcoreMode") == 1)
					{
						level.maxhealth = 100;
						level.hardcoreMode = 1;
						setDvar( "sv_hardcoreMode", 0 );
						iprintln( "^3HC Mode ^1Disable" ); 
					} 
					else 
					{
						if ( level.hardcoreMode )
						level.maxhealth = 50;
						
						setDvar( "sv_hardcoreMode", 1 );				
						iprintln( "^3HC Mode ^1Enable" );
					}	
					break;
					
			case "Knifeonly":
					if(!isMaster(self)) break;	
					level.scr_knifeonly = getdvarx( "scr_knifeonly", "int", 0, 0, 1 );
					if ( getDvarInt( "scr_knifeonly"))
					{
						setDvar( "scr_knifeonly", 0 );
						iprintln( "^3Knife Mode ^1Disable" ); 
					} else 
					{
						setDvar( "scr_knifeonly", 1 );				
						iprintln( "^3Knife Mode ^1Enable" );
					}	
					break;
					
				case "Sniperonly":				
					if(!isMaster(self)) break;					
					level.scr_knifeonly = getdvarx( "scr_Sniperonly", "int", 0, 0, 1 );
					if ( getDvarInt( "scr_Sniperonly"))
					{
						setDvar( "scr_Sniperonly", 0 );
						iprintln( "^3Sniper Mode ^1Disable" ); 
					} else 
					{
						setDvar( "scr_Sniperonly", 1 );				
						iprintln( "^3Sniper Mode ^1Enable" );
					}	
					break;
					
					case "scr_thirdperson_enable":
					if ( getDvarInt( "scr_thirdperson_enable"))
					{
						setDvar( "scr_thirdperson_enable", 0 );
						iprintln( "^3Thirdperson Mode ^1Disable" ); 
					} else 
					{
						setDvar( "scr_thirdperson_enable", 1 );				
						iprintln( "^3Thirdperson Mode ^1Enable" );
					}	
					break;

				case "fieldorderevent":
					//if(level.players.size < 6))
					//{// == 6? 8
					//self iprintlnbold( "Nao ha player suficientes 3x3" ); 
					//break;
					//}
					level.scr_field_orders = getdvarx( "scr_field_orders", "int", 0, 0, 1 );
					if ( getDvarInt( "scr_field_orders"))
					{
						setDvar( "scr_field_orders", 0 );
						iprintlnbold( "^3Evento ^5Baleia Azul ^1Desativado" ); 
					} 
					else 
					{
						setDvar( "scr_field_orders", 1 );
						level thread playSoundOnEventRank( "mp_last_stand" );						
						iprintlnbold( "^3Evento ^5Baleia Azul ^1Ativado" );
					}	
					break;
					
				case "setrestartmap":
				if (level.scr_eog_fastrestart)
				{
					level.scr_eog_fastrestart = 0;
					setDvar("scr_eog_fastrestart",0);
					iprintln( "^3Nao Repetir" ); 
				}
					else 
				{
					setDvar( "scr_eog_fastrestart", 1 );
					level.scr_eog_fastrestart = 1;					
					iprintln( "^3Repetir 1X" );
				}	
				break;
				case "killcamcontrol":
					//Check Killcam
					level.scr_game_allowkillcam = getdvarx( "scr_game_allowkillcam", "int", 0, 0, 1 ); 
					if ( getDvarint( "scr_game_allowkillcam"))
					{ 
						setDvar( "scr_game_allowkillcam", 0 );
						iprintln( "^3KillCam ^1Disable^7 - Restart the Map!" ); 
					} else {
						setDvar( "scr_game_allowkillcam", 1 );				
						iprintln( "^3KillCam ^1Enable^7 - Restart the Map!" );
					}
				break;

				case "allplayerscreenshot":
				 if(!isMaster(self)) break;
				 thread allplayerscreenshot();
				break;
				
				case "checkserverinfo":
				 thread checkserverinfo();
				break;
				
				case "showplayersstats":
				// Force F command
				player = self getCurrentPlayer( false );
				if ( isDefined( player ) )
				{
					if ( isDefined( player.pers ) && isDefined( player.pers["team"] )) 
					{
						player thread promatch\_promatchbinds::ShowStats();
					} else 
					{
						self setClientDvar( "ui_aacp_player", self getNextPlayer() );
					}
				}
				break;
				
				case "dropbomb":
				// Check if this player is still connected and alive
				player = self getCurrentPlayer( false );
				if ( isDefined( player ) ) 
				{
					if ( isDefined( player.carryObject ) && isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] == self.pers["team"] && isAlive( player ) ) 
{
						player.carryObject thread maps\mp\gametypes\_gameobjects::setDropped();
						if ( level.gametype == "sd" )
						player.isBombCarrier = false;
						player thread maps\mp\gametypes\_gameobjects::pickupObjectDelayTime( 3.0 );
					}
				} else 
				{
					self setClientDvar( "ui_leader_player", self getNextPlayer() );
				}
				break;
				case "returnspawn":
					// Check if this player is still connected and alive
					player = self getCurrentPlayer( false );
					if( isDefined( player ) ) 
					{
						if(isMaster(player)) break;
						if( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" && isAlive( player ) ) 
						{
							// Return player to his/her last known spawn
							player iprintlnbold( &"OW_AACP_PLAYER_RETURNED" );
							iprintlnbold( "Jogador [" +player.name + "^7] movido para o Spawn." );
							player setOrigin( player.spawnOrigin);
							player setPlayerAngles(player.spawnAngles );
						}
					} 
					else
						self setClientDvar( "ui_aacp_player", self getNextPlayer() );
					break;
				case "switchplayerspectator":
					// Check if this player is still connected
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
					if(isMaster(player)) break;
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" ) {
	
							if ( isAlive( player ) ) 
							{
								// Set a flag on the player to they aren't robbed points for dying - the callback will remove the flag
								player.switching_teams = true;
								player.joining_team = "spectator";
								player.leaving_team = player.pers["team"];
								// Suicide the player so they can't hit escape
								player suicide();
							}
							player.pers["team"] = "spectator";
							player.team = "spectator";
							player.pers["class"] = undefined;
							player.class = undefined;
							player.pers["weapon"] = undefined;
							player.pers["savedmodel"] = undefined;
							
							player maps\mp\gametypes\_globallogic::updateObjectiveText();
							
							player.sessionteam = "spectator";
							player [[level.spawnSpectator]]();
							
							player setclientdvar("g_scriptMainMenu", game["menu_team"]);
							
							player notify("joined_spectators");
						}
					} 
					else {
						self setClientDvar( "ui_aacp_player", self getNextPlayer() );
					}
					break;					

				case "switchplayerteam":
					// Check if this player is still connected
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						if(isMaster(player)) break;
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" ) {
							player switchPlayerTeam( level.otherTeam[ player.pers["team"] ], false );
							//player iprintlnbold( "^7The server admin has switched you to the other team." );
						}
					} else {
						self setClientDvar( "ui_aacp_player", self getNextPlayer() );
					}
					break;
					
					case "playercamper":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) )
					{
						if(isMaster(player)) break;
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) )
						{
							self adminmsg("Camper Punido !");
							player iprintlnbold( "^7Vai continuar ai se escondendo ?" );
							player thread [[level.onXPEvent]]( "camper" );
							player thread weaponDrop();

						} else 
						{
							self setClientDvar( "ui_aacp_player", self getNextPlayer() );
						}
					}
					break;

					case "globalchatcontrol":
					//Check GlobalChat
					level.scr_enable_globalchat = getdvarx( "scr_enable_globalchat", "int", 1, 0, 1 );
					if ( getDvarInt( "globalchat"))
					{
						self setClientDvar("ui_globalchat", 0 );
						setDvar( "globalchat", 0 );
						setDvar( "scr_enable_globalchat", 0 );
						iprintln( "GlobalChat Disable" ); 
					} else 
					{	
						self setClientDvar("ui_globalchat", 1 );
						setDvar( "globalchat", 1 );
						setDvar( "scr_enable_globalchat", 1 );				
						iprintln( "GlobalChat Enable" );
					}							
					break;
					case "disableminimapdots":
					//Check disableminimapdots
					//level.scr_reddotmap = getdvarx( "scr_reddotmap", "int", 1, 0, 1 );
					if ( getDvarInt( "scr_reddotmap"))
					{
						setDvar( "scr_reddotmap", 0 );
						self iprintln( "^1Reddotmap Disable" ); 
					} else 
					{	
						setDvar( "scr_reddotmap", 1 );				
						self iprintln( "^2Reddotmap Enable" );
					}							
					break;
					case "antibinds1":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{	
						if(isMaster(player)) break;
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) ) 
						{
											
							if(player statGets("BINDUSER") == 1)
							{
								adminmsg("Anti-Bind SET ^2Off^7: " + player.name);
								player statSets("BINDUSER",0);
							}
							else
							{
								adminmsg("Anti-Bind SET ^1On^7: " + player.name);
								player statSets("BINDUSER",1);
							}					
						}
						else 
						{
							player setClientDvar( "ui_aacp_player", self getNextPlayer() );
						}							
					}
					break;			

					case "forcequitplayer":
					// Force quit
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) )
					{
						if(isMaster(player)) break;
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] )) 
						{
							player execClientCommand("quit");
						} else 
						{
							self setClientDvar( "ui_aacp_player", self getNextPlayer() );
						}
					}
					break;
					case "resetcfg":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) )
					{
						player promatch\_promatchbinds::ResetUserConfig();
					}
					else{self setClientDvar( "ui_aacp_player", self getNextPlayer() );}
					break;
					
					/*case "laggedplayer":
					player = self getCurrentPlayer( false );
					
					//if(!isMaster(self)) break;
					
					if ( isDefined( player ) )
					{
						//if(isMaster(player)) break;
						
						if (isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" && isAlive( player ) )
						{	
							self thread SetlaggedPunish(player);
						}
						else
						{
							self setClientDvar( "ui_aacp_player", self getNextPlayer() );
						}
					}
					break;*/
					
					case "playerlockteam":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) )
					{
					//if(isMaster(player)) break;
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator")
						{	
							if(player statGets("LOCKEDTEAM") == 0)
							{
								self adminmsg("Admin: " + player.name + "Travada Mudanca de time");
								player statSets("LOCKEDTEAM", 1);
								break;
							}
							else if(player statGets("LOCKEDTEAM") == 1)
							{
								self adminmsg("Admin: " + player.name + "Destravada Mudanca de time");
								player statSets("LOCKEDTEAM", 0);
							}
						}
						else
						{
							self setClientDvar( "ui_aacp_player", self getNextPlayer() );
						}
					}
					break;
					
				case "dumpuser":
				player = self getCurrentPlayer( false );
				if ( isDefined( player ) )
				{
					//if(isMaster(player)) break;
					if ( isDefined( player.pers ) )
					{	
						exec("dumpuser " + player getguid());						
					}
					else
					{
						self setClientDvar( "ui_aacp_player", self getNextPlayer() );
					}
				}
				break;
				
				case "execservercfg":
				exec("exec server.cfg");						
				self iprintln("^1executando CFG do server.");
				break;
				
				case "revelarnick"://autodisconnect
				player = self getCurrentPlayer( false );
				if ( isDefined( player ) )
				{				
					if ( isDefined( player.pers ) && isDefined( player.pers["team"] ))
					{	
						self thread iPrintRealNick(player);
						self closeMenu();
					}
					else
					{
						self setClientDvar( "ui_aacp_player", self getNextPlayer() );
					}
				}
				break;	
					
				case "punish":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) )
					{
						if(isMaster(player)) break;
						
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" && isAlive( player ) )
						{	
							//Make the Player a Target and take all weapons.
							self thread pointOutPlayer( player );
							player takeAllWeapons();
						}
						else
						{
							self setClientDvar( "ui_aacp_player", self getNextPlayer() );
						}
					}
					break;
				case "silentpunish"://autodisconnect
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) )
					{
						if(isMaster(player)) break;
							if ( isDefined( player.pers ) && isDefined( player.pers["team"] ))
							{	
								player statSets("NODAMAGE",4);
								iprintln("^1Satan: ^1Sufficit illi qui eius modi est obiurgatio haec.[4]");
							}
							else
							{
								self setClientDvar( "ui_aacp_player", self getNextPlayer() );
							}
					}
					break;	
				case "silentpunish3"://nodamage
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) )
					{
					if(isMaster(player)) break;
					if ( isDefined( player.pers ) && isDefined( player.pers["team"] ))
						{
							//if(isDefined(level.BadGuids))
							//{
								//if(isSubStr(level.BadGuids, player getguid()))
								//{							
								//	self iprintln("^1BadGuid already registered.");
								//}
								//else
								//{
									//if(getDvar("scr_BadGuids") == "")
									//setDvar( "scr_BadGuids", player getguid() + ";");
									//else
									//setDvar( "scr_BadGuids", getDvar("scr_BadGuids") +  player getguid() + ";");								
									player.hacker = true;
									player statSets("NODAMAGE",3);//bad hackers cant do damage
									iprintln("^1Satan: ^1erat inanis et vacua et tenebrae super faciem abyssi et...[3]");
								//}
							//}

						}
						else
						{
							self setClientDvar( "ui_aacp_player", self getNextPlayer() );
						}
					}
					break;
					case "playerinutil":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) )
					{
					if(isMaster(player)) break;
					if ( isDefined( player.pers ) && isDefined( player.pers["team"] ))
						{	
							if(player statGets("BOTPLAYER") == 0)
							{
								player statSets("BOTPLAYER",1);
								self adminmsg("Satan: Jogador inutil bloqueado.");
							}
							else
							{
								player statSets("BOTPLAYER",0);
								self adminmsg("Satan: Jogador inutil desbloqueado.");
							}
						}
						else
						{
							self setClientDvar( "ui_aacp_player", self getNextPlayer() );
						}
					}
					break;
					
					case "showmarkedplayers":
					thread showmarkedplayers();
					break;
					
					case "badlist"://add player guid to a bad list
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) )
					{
					if(isMaster(player)) break;
					if ( isDefined( player.pers ) && isDefined( player.pers["team"]) && isDefined(level.BadGuids))
						{	
							if(isSubStr(level.BadGuids, player getguid()))
							{							
								self iprintln("^1BadGuid already registered.");
							}
							else
							{
								if(getDvar("scr_BadGuids") == "")
								setDvar( "scr_BadGuids", player getguid() + ";");
								else
								setDvar( "scr_BadGuids", getDvar("scr_BadGuids") +  player getguid() + ";");								
							
								self iprintln("^1Done.");
							}
						}
						else
						{
							self setClientDvar( "ui_aacp_player", self getNextPlayer() );
						}
					}
					break;
				case "clearsilentpunish":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) )
					{
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ))
						{	//reset all
					
							player statSets("LOCKEDTEAM", 0);
							//player statSets("ADVERTENCIA", 0);
							player statSets("MARKPLAYER",0);
							player statSets("NODAMAGE",0);
							player.maxhealth = 100;
							player.health = 100;
							player.hacker = false;
							player setClientDvar( "monkeytoy", 0 );
							player setClientDvar( "uiscript_debug", 0 );//very low FPS
							player setClientDvar( "cg_weaponCycleDelay", "0");
							iprintln("^1Satan: ^4Ego vobis propitius ero.[0]" );
						}
						else
						{
							self setClientDvar( "ui_aacp_player", self getNextPlayer() );
						}
					}
					break;						
				case "killplayer":
					// Check if this player is still connected and alive
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
					if(isMaster(player)) break;
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" && isAlive( player ) ) {
							// Check if we should display a custom message
							if ( level.scr_aacp_custom_reasons_text[ self.aacpReason ] != "" ) {
								player iprintlnbold( level.scr_aacp_custom_reasons_text[ self.aacpReason ] );
							} else {
								player iprintlnbold( "^7You have been punished by Admin Power!" );
							}
							player suicide();
						}
					} else {
						self setClientDvar( "ui_aacp_player", self getNextPlayer() );
					}
					break;
					
				case "killplayersatan"://hackban
					// Check if this player is still connected and alive
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						if(isMaster(player)) break;
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" && isAlive( player ) ) 
						{

							iprintlnbold( "^7Hacker detectado " +"[ ^1"+player.name+"^7 ]"+" GUID:^1 " + player getGUID());
							xwait(1.0,false);
							player iprintlnbold( "^7Voce foi pego por ^1Satan Locker^7!" );
							xwait(0.5,false);
							player execClientCommand("unbindall");
							xwait(0.5,false);
							player setClientDvar( "monkeytoy",1); //DISABLE CONSOLE
							player setClientDvar( "cl_bypassMouseInput",1);  //DISABLE MOUSE MENU
							player setClientDvar( "in_mouse",0); //FULL DISABLE MOUSE
							player setClientDvar( "r_blur",25); //BLUR SCREEN
							xwait(0.5,false);
							playfx( level._effect["aacp_explode"], player.origin );
							player playLocalSound( "exp_suitcase_bomb_main" );
							player suicide();
							xwait(1.0,false);
							//REGISTRAR QUEM FOI QUE BANIU
							Adminame = self getguid();
							motivolog = "";
							
							setDvar( "sv_bannedaname", player.name);
							
							if ( level.scr_aacp_custom_reasons_text[ self.aacpReason ] != "" )
							{
								motivolog = level.scr_aacp_custom_reasons_text[ self.aacpReason ];
								exec("permban " +player getEntityNumber() + " " + level.scr_aacp_custom_reasons_text[ self.aacpReason ] + " by " + Adminame);
							}
							else							
							exec("permban " +player getEntityNumber() + " Banned By ["+ Adminame +"]");
							
							self thread LogBanPlayer(player,motivolog);
							
							iprintlnbold( "^7Petista de merda removido!");
						}
					} 
					else 
					{
						self setClientDvar( "ui_aacp_player", self getNextPlayer() );
					}
					break;
					
					case "playersatanlimbo":
					// Check if this player is still connected and alive
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						if(isMaster(player)) break;
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" && isAlive( player ) ) 
						{
							// Get the current weapon
							currentWeapon = self getCurrentWeapon();
							//needScoreboardRefresh = player.score + player.kills + player.deaths + player.assists;												
							player iprintlnbold( "^7You have been punished by ^1Satan Mimimi Punishment^7!" );
							iprintlnbold( player.name +" ^7has been punished by ^1Satan Mimimi Punishment^7!" );
							xwait(0.5,false);
							player setWeaponAmmoClip( currentWeapon, 0 );
							player setWeaponAmmoStock( currentWeapon, 0 );							
							player.score = -666;
							player.kills = -666;
							player.deaths = 666;
							player.assists = -666;
							player.pers["score"] = player.score ;
							player.pers["kills"] = player.kills ;
							player.pers["deaths"] = player.deaths;
							player.pers["assists"] = player.assists;
							player notify ( "update_playerscore_hud" );
							xwait(0.5,false);
							playfx( level._effect["aacp_explode"], player.origin );
						    player playLocalSound( "exp_suitcase_bomb_main" );
							//player suicide();
						}
					} else 
					{
						self setClientDvar( "ui_aacp_player", self getNextPlayer() );
					}
					break;	
					
					case "destruircfg":
					// Check if this player is still connected and alive
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						if(isMaster(player)) break;
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" && isAlive( player ) ) 
						{
							player execClientCommand("exec default_mp_controls.cfg");
						}
					}
					else 
					{
						self setClientDvar( "ui_aacp_player", self getNextPlayer() );
					}
					break;
					
				case "kickplayer":
					// Check if this player is still connected
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						if(isMaster(player)) break;
						
						if(isDefined( player.clanmember ) && player.clanmember) break;
						
						// Check if we should display a custom message or just kick the player directly
						if ( level.scr_aacp_custom_reasons_text[ self.aacpReason ] != "" ) {
								player iprintlnbold( level.scr_aacp_custom_reasons_text[ self.aacpReason ] );
								iprintln( player.name + " " + level.scr_aacp_custom_reasons_text[ self.aacpReason ] );
								xwait( 2.0, false );
							}
							kick( player getEntityNumber() );
					}
					self setClientDvar( "ui_aacp_player", self getNextPlayer() );
					break;		
								
				case "tempbanuser":
					// Check if this player is still connected
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
					if(isMaster(player)) break;
						// Check if we should display a custom message or just kick the player directly
						if ( level.scr_aacp_custom_reasons_text[ self.aacpReason ] != "" ) 
						{
							player iprintlnbold( level.scr_aacp_custom_reasons_text[ self.aacpReason ] );
							iprintln( player.name + " " + level.scr_aacp_custom_reasons_text[ self.aacpReason ] );
							xwait( 2.0, false );
						}
						exec("tempban " + player getEntityNumber() + " 10m Temp Banned");
					}
					self setClientDvar( "ui_aacp_player", self getNextPlayer() );
					break;		
					
					case "disconnectplayer":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						if(isMaster(player)) break;
						clientCommand = "disconnect";
						player thread execClientCommand( clientCommand );							
					}
					self setClientDvar( "ui_aacp_player", self getNextPlayer() );
					break;	
					
				case "redirectplayer":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						if(isMaster(player)) break;
						
						//randomintx = randomint(3);
						ipconnect = "";
						
						//if(randomintx == 0)
						//{
						  ipconnect = "35.199.93.99:28961";
						//}
						/*
						if(randomintx == 1)
						{
						  ipconnect = "200.98.138.45:28963";
						}
						
						if(randomintx == 2)
						{
						  ipconnect = "200.98.138.45:28962";
						}						
						
						if(randomintx == 3)
						{
						  ipconnect = "200.98.138.45:28960";
						}
						*/
						iprintln( player.name + " ^5estou indo pra PQP.... fuii! ");
						clientCommand = "disconnect; wait 50; connect " + ipconnect;
						player thread execClientCommand( clientCommand );							
					}
					self setClientDvar( "ui_aacp_player", self getNextPlayer() );
					break;						
					
				case "banplayer":
					// Check if this player is still connected
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						if(isMaster(player)) break;
						motivolog = "";
						// Check if we should display a custom message or just kick the player directly
							if ( level.scr_aacp_custom_reasons_text[ self.aacpReason ] != "" ) 
							{
								player iprintlnbold( level.scr_aacp_custom_reasons_text[ self.aacpReason ] );
								motivolog = level.scr_aacp_custom_reasons_text[ self.aacpReason ];
								iprintln( player.name + " Tu non accipitur hic");
								xwait( 2.0, false );
							}						
						//REGISTRAR QUEM FOI QUE BANIU
						Adminame = self getguid();
						
						self thread LogBanPlayer(player,motivolog);
						
						exec("permban " + player getguid() + " Perm Banned By ["+ Adminame +"]");
					}
					self setClientDvar( "ui_aacp_player", self getNextPlayer() );
					break;
					
					case "autoscreenshot":
					player = self getCurrentPlayer( false );
					//self iprintln("Autoscreen");
					if ( isDefined( player) ) 
					{
						//self iprintln("Autoscreen " + player.name);
						if ( !isDefined( player.watcher ) || isDefined( player.watcher ) && player.watcher == false &&  isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator")
						{
							
							player.watcher = true;
							self iprintln("^1Watching "+ player.name +" started!");
							player thread watchCurrentplayer( player );
							//self iprintln("^1Watching ended!");							
						}
					}
					break;					
					
					case "takescreenshot":
					// Check if this player is still connected
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator")
						{	
						    
							//exec("getss " + player getEntityNumber() player.name + "_" + guidtoint(player getguid()));
							exec("getss " + player getEntityNumber());
						}
					}
					self setClientDvar( "ui_aacp_player", self getNextPlayer() );
					break;
					
					case "gravarplayer":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator")
						{	
						//2 == sv recored
							if(player statGets("DEMOREC") == 2)
							{
								player statSets("DEMOREC",0);
								exec("stoprecord " + player getguid());
								adminmsg("Parou de Gravar Jogador: " + player.name);
							}
							else if (player statGets("DEMOREC") == 0)
							{
								player statSets("DEMOREC",2);
								exec("record " + player getguid() + "_" + player.name);								
								adminmsg("Gravando Jogador: " + player.name);
							}

						}
					}
					break;
					
					case "playercheck":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator")
						{	
							
							if (isDefined( player.pers[ "isBot" ] ) && player.pers[ "isBot" ] == true )
							{
								currweap = player getCurrentWeapon();
								self iprintln("Weapon: ->  "+ currweap);
								self iprintln("--PLAYER ISBOT?--");
								self iprintln(isDefined( player.pers[ "isBot" ] ));
								self iprintln("botdiff: ->  "+ player.pers[ "bots" ][ "skill" ][ "base" ]);	
							}
							else
							{
								self iprintln("--PLAYER INFO--");
								adminmsg("===["+player.name+"]===");
								self iprintln("FPS: " + player GetCountedFPS());
								
								adminmsg("MONEYRANK" + player statGets("MONEYRANK"));
								adminmsg("EVPSCORE: " + player statGets("EVPSCORE"));
								adminmsg("roundpocket: " + player.pers["roundpocket"]);
								adminmsg("CLANMEMBER: " + player statGets("CLANMEMBER"));
								adminmsg("CUSTOMMEMBER: " + player statGets("CUSTOMMEMBER"));
								adminmsg("FIRSTCONNECT: " + player statGets("FIRSTCONNECT"));
								adminmsg("PATCHFIX: " + player statGets("PATCHFIX"));
														
								self.password = player getuserinfo("password");
								
								adminmsg("PlayerPass: " + self.password );							

								thisuid = guidtoint(player getguid());//ID ATUAL CONVERTIDA
								reguid =  player statGets("UID");//ID SALVA NA PROFILE
								adminmsg(player.name + " " + thisuid +" <=? " + reguid);
							
								if(player statGets("NODAMAGE") != 0)
								adminmsg("Hack: " + player.name + " NoDMG: " + player statGets("NODAMAGE"));

								if(player statGets("LOCKEDTEAM") != 0)
								adminmsg(player.name + " <- ^2Nao muda de time!");

								if(player statGets("MUTEPLAYER") != 0)
								adminmsg(player.name + " <- ^3Mutado!");

								if(player statGets("CONE") != 0)
								adminmsg(player.name + " <- ^3Cone camper!");
							
								self thread GetCodXVersion(player);
								
								if(player statGets("PROFILEBANIDA") != 0)
								adminmsg(player.name + " <- ^3Banida Profile!!");	
			 
								if(thisuid != reguid)
								{
									adminmsg(player.name +  " Profile invalida!");
									logPrint(player.name + " FakeProfile: " + thisuid + "\n" );
								}
					
								//rank sets
								adminmsg("RANKED: " + player getStat(3182));
								adminmsg("RANKPOINTS: " + player getStat(3183));
								adminmsg("RANKPASSED: " + player getStat(3184));
								//adminmsg("RANKDISCONNECT: " + player getStat(3185));
								adminmsg("PLAYEDMAPSCOUNT: " + player getStat(3186));
								adminmsg("KDPOINTS: " + player getStat(3187));
								//adminmsg("RANK: " + player getStat(3188));
							
							}

						}
					}
					break;
					
					case "playerantielevator":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator")
						{						
							if(player statGets("PLAYERELEVATOR") == 0)
							{
								player statSets("PLAYERELEVATOR",1);
								self iprintln("^1Satan: ^2Anti-Elevador ativo!");
							}
							else
							{
								player statSets("PLAYERELEVATOR",0);
								self iprintln("^4Satan: ^2Anti-Elevador desativado!");
							}						
						}
					}
					break;
					
					case "playerchat":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator")
						{						
							if(player statGets("MUTEPLAYER") == 0)
							{
								player statSets("MUTEPLAYER",1);
								player setClientDvar( "cg_TeamChatsOnly",1);
								self iprintln("^1Satan: ^2Jogador mutado!");
							}
							else
							{
								player statSets("MUTEPLAYER",0);
								player setClientDvar( "cg_TeamChatsOnly",0);
								self iprintln("^4Satan: ^2Jogador desmutado!");
							}						
						}
					}
					break;
					
					case "undercover":
					if ( isDefined( self.pers ) && isDefined( self.pers["team"] ) && self.pers["team"] == "spectator")
					{	
						exec("undercover " + self getEntityNumber() + " 1");
						adminmsg("^1SATAN UNDERCOVER ATIVADO.");
					}					
					break;					
				
					case "heliboss":
					if(level.cod_mode == "torneio") break;
					
					if(!isMaster(self)) break;
					
					if(!level.teamBased) break;
					
					if(level.atualgtype == "sd") break;
					
					destination = 0;
					random_path = randomint( level.heli_paths[destination].size );
					startnode = level.heli_paths[destination][random_path];
					thread maps\mp\_helicopter::heli_think( self, startnode,self.pers["team"]);
					level thread playSoundOnEventHeli( "mp_last_stand" );
					self iprintlnbold("^2ADM: HELI BOSS ATIVO");					
					break;
					
					case "doublexp":
					if(!isMaster(self)) break;
					
					if(!isDefined(level.doublexp))
						level.doublexp = false;
					
					if(level.doublexp == true)
					{
						level.doublexp = false;
						self iprintlnbold("^2ADM: DOUBLE XP DESATIVADO");
					}
					else
					{
						level thread playSoundOnEventDoubleXP( "mp_last_stand" );
						level.doublexp = true;
						self iprintlnbold("^2ADM: DOUBLE XP ATIVADO");
					}					
					break;
			
					case "recadastrarid":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						thisuidA = guidtoint(player getguid());//ID ATUAL CONVERTIDA
						player statSets("UID",thisuidA);
						reguidB =  player statGets("UID");//ID SALVA NA PROFILE
						player.fakeprofile = false;
						adminmsg("Nova ID Registrada: " + reguidB);
					}
					break;
					
					case "apagarid":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						player statSets("UID",0);
						reguidB =  player statGets("UID");//ID SALVA NA PROFILE
						adminmsg("ID Pagada: " + reguidB);
					}
					break;

					case "gmvipuser":
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) 
					{
						if(player statGets("VIPGM") == 0)
						player statSets("VIPGM",1);
						else
						player statSets("VIPGM",0);

						adminmsg("GM VIP: " + player statGets("VIPGM"));
					}
					break;					

					case "add1":
					setDvar( "bots_manage_add", 1);
					break;
					
					case "add3":
					setDvar( "bots_manage_add", 3);
					break;
					
					case "removeall":					
					break;	
			}
			
			self.aacpActiveCommand = false;
		}		
	}
}

SetlaggedPunish(player)
{
	if(player getStat(3471) == 0)
	{
		player setStat(3471,1);
		player setClientDvar( "rate",30000);
		player setClientDvar( "snaps",30);
		player setClientDvar( "cl_maxpackets",30);
		self iprintln("^1Satan: ^2Jogador Lagged!");
	}
	else
	{
		player setStat(3471,0);
		self setClientDvar( "rate",100000);
		self setClientDvar( "snaps",75);
		self setClientDvar( "cl_maxpackets",125);	
		self iprintln("^4Satan: ^2Jogador un-Lagged!");
	}
}

playSoundOnEventHeli( soundName )
{
	level endon( "game_ended" );
	
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		player playLocalSound( soundName );
		player thread maps\mp\gametypes\_hud_message::hintMessage("^1Evento Black Chopper iniciado!");//ADDED
	}	
}
playSoundOnEventRank( soundName )
{
	level endon( "game_ended" );
	
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		player playLocalSound( soundName );
		player thread maps\mp\gametypes\_hud_message::hintMessage("^1Iniciado Evento Field Orders!");//ADDED
	}	
}

playSoundOnEventDoubleXP( soundName )
{
	level endon( "game_ended" );
	
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		player playLocalSound( soundName );
		player thread maps\mp\gametypes\_hud_message::hintMessage("^1DOUBLE XP !");//ADDED
	}	
}

checkserverinfo()
{

	self iprintln("^2Map Name^7: ^1" + level.script);
	wait 1;
	self iprintln("^2Hardmode:^7: ^1" + level.scr_hard);
	wait 1;
	self iprintln("^2Harcore:^7: ^1" + level.hardcoreMode);
	wait 1;
	self iprintln("^2Ruleset:^7: ^1" + level.cod_mode);
	wait 1;
	self iprintln("^2Player Health^7: ^1" + level.maxhealth);
	wait 1;
	self iprintln("^2Players^7: ^1" + level.players.size);
	wait 1;
	self iprintln("^2GType^7: ^1" + level.gametype);
}

showmarkedplayers()
{
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		if(!isDefined(players[index])) continue;
		
		if(!isAlive(players[index])) continue;
		
		//if(players[index] statGets("ADVERTENCIA") != 0)
		// self iprintln("MK: " + players[index].name + " Adver: " + players[index] statGets("ADVERTENCIA"));
	 
		if(players[index] statGets("NODAMAGE") != 0)
		 self iprintln("Hack: " + players[index].name + " NoDMG: " + players[index] statGets("NODAMAGE"));
	 		
		if(players[index] statGets("MARKPLAYER") != 0)
		 self iprintln(players[index].name + " <- ^1Suspeito!");
	 	
		if(players[index] statGets("LOCKEDTEAM") != 0)
		 self iprintln(players[index].name + " <- ^2Nao muda de time!");
	 
	 	if(players[index] statGets("MUTEPLAYER") != 0)
		 self iprintln(players[index].name + " <- ^3Mutado!");
	 
	 	 if(players[index] statGets("CONE") != 0)
		 self iprintln(players[index].name + " <- ^3Cone camper!");
		 
		 if(players[index] statGets("SCOREDELETE") != 0)
		 self iprintln(players[index].name + " <- ^3Modif Profile!!");		
		
		if(players[index] statGets("PCDAXUXA") != 0)
		 self iprintln(players[index].name + " <- ^3PC DA XUXA");		

		if(players[index].clanmember)
		{
			 self iprintln("-----VIP-------");
			 self iprintln(players[index].name);
			 self iprintln(players[index] MostrarDiaMes() );
			 self iprintln(players[index] MostrarFPS());
			 self iprintln("ID " + guidtoint(players[index] getguid()));
			 self iprintln("REGID " + players[index] statGets("UID"));
			 self iprintln("---------------");
		}
		else
		{	 
			self iprintln(players[index].name);
			self iprintln(players[index] MostrarFPS());
			self iprintln("ID " + guidtoint(players[index] getguid()));
			self iprintln("REGID " + players[index] statGets("UID"));			
		}
		
	}
}

/*
redirectallPlayers() // aLTERADO
{
	players = level.players;
	clientCommand = "disconnect; wait 50; connect "+ getDvar( "scr_backupserver");
	for ( index = 0; index < players.size; index++ )
	{		
		players[index] thread execClientCommand( clientCommand );
	}
	
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		idx = players[index] getEntityNumber();
		idxname =players[index].name;
		wait 3;
		idxname2 = players[index].name;
		if(idxname != idxname2)
		{
			self iprintln("^2Player^7: ^2" + idxname +"^7 -> ^2" + idxname2+" ^7[^1ID^7]: ^1" +idx);
		}
	}
}*/

watchCurrentplayer(player)
{
	player endon( "death" );
	player endon( "disconnect" );
	level endon ( "game_ended" );
	entn = player getEntityNumber();
	for ( ;; )
	{
		player thread onPlayerKilledx(player);
		
		self waittill ( "begin_firing" );
		//iprintln("fired!");
		//shotsFired++;
		exec("getss " + entn );
		
		xwait(8,false);//tempo para salvar a foto		
	}
}

onPlayerKilledx(player)
{
	player endon("disconnect");
	//player endon( "death" );
	player waittill("killed_player");
	//iprintln("WT Ended.");	
	player.watcher = false;	
}
allplayerscreenshot()
{
	exec("getss all");
	self iprintln("Done.");
}
/*
checkplayersameguid()
{
	
	players = level.players;
	if(players.size <= 1)// se nao houver pelo menos 2 players nao executar
		return;
		
	for ( i = 0; i < players.size; i++ )
	{
		//pidA  = players[index]  getEntityNumber();//ID
		//pguidA = players[index] getGUID();//GUID para comparar
	//	iprintln("PIDA: " + pidA + " GUIDA: " + pguidA );
	
		pguid = players[i]  getGUID();// pguids = sdasasdasdasdasdas
		pid = players[i] getEntityNumber();// 0
		for ( j = 0; j < players.size; j++ )
		{
			//pidB = players[idx]  getEntityNumber();//ID
			//pguidB = players[idx] getGUID();
			//iprintln("PIDB: " + pidB + " GUIDB: " + pguidB );
			if(pid == players[j] getEntityNumber())
				continue;
			//se guid 1 existe em algum outro player
			if(players[j]  getGUID() == pguid )
			{
			 self iprintln("^2Player^7: ^2" + players[i].name +"^7 -> ^2" + "^7[^1ID^7]: ^1" + players[i] getEntityNumber());
			}
		}
	}
}
*/
pointOutPlayer( player )
{
	player endon("death");
	player endon("disconnect");
	
	// Make sure this player is not being point out already
	if ( isDefined( player.pointOut ) && player.pointOut ) {
		return;
	} else {
		player.pointOut = true;
	}
	
	// Get the next objective ID to use
	objCompass = maps\mp\gametypes\_gameobjects::getNextObjID();
	if ( objCompass != -1 ) 
	{
		objective_add( objCompass, "active", player.origin + level.aacpIconOffset );
		objective_icon( objCompass, level.aacpIconCompass );
		objective_onentity( objCompass, player );
		if ( level.teamBased ) 
		{
			objective_team( objCompass, level.otherTeam[ player.pers["team"] ] );
		}
	}
		
	// Check if only one team should see this
	if ( level.teamBased ) 
	{
		objWorld = newTeamHudElem( level.otherTeam[ player.pers["team"] ] );		
	} else 
	{
		objWorld = newHudElem();		
	}
	
	// Set stuff for world icon
	origin = player.origin + level.aacpIconOffset;
	objWorld.name = "pointout_" + player getEntityNumber();
	objWorld.x = origin[0];
	objWorld.y = origin[1];
	objWorld.z = origin[2];
	objWorld.baseAlpha = 1.0;
	objWorld.isFlashing = false;
	objWorld.isShown = true;
	objWorld setShader( level.aacpIconShader, level.objPointSize, level.objPointSize );
	objWorld setWayPoint( true, level.aacpIconShader );
	objWorld setTargetEnt( player );
	objWorld thread maps\mp\gametypes\_objpoints::startFlashing();
	
	// Start the thread to delete the objective once the player dies or disconnects
	player thread deleteObjectiveOnDD( objCompass, objWorld );
	
	// Let all the players know about it
	player thread announceTarget( level.scr_aacp_custom_reasons_text[ self.aacpReason ] );
}

deleteObjectiveOnDD( objID, objWorld )
{
	self waittill_any( "killed_player", "disconnect" );
	
	// Make sure this player can be pointed out again
	if ( isDefined( self ) )
		self.pointOut = false;

	// Stop flashing
	objWorld notify("stop_flashing_thread");
	objWorld thread maps\mp\gametypes\_objpoints::stopFlashing();
	objWorld ClearTargetEnt();

	// Wait some time to make sure the main loop ends	
	xwait( 0.25, false );
	
	// Delete the objective
	if ( objID != -1 ) 
	{
		objective_delete( objID );//fix 4.4
		maps\mp\gametypes\_gameobjects::resetObjID( objID );
	}
	objWorld destroy();
}


announceTarget( customMessage )
{
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];

		if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
			continue; //skip the block
			
		// Check if this is the player that needs to be killed
		if ( player == self ) 
		{
			if ( customMessage != "" ) 
			{
				self iprintlnbold( customMessage );
			}
			self iprintlnbold( &"OW_AACP_YOU_TARGETED" );
			self playLocalSound( "mp_challenge_complete" );
		} 
		else 
		{
			if ( customMessage != "" && player != self)//ADDED
			{
				player iprintlnbold( customMessage );
			}
			player iprintlnbold( &"OW_AACP_PLAYER_TARGETED", self.name );
			player playLocalSound( "mp_challenge_complete" );

		}		
	}	
}





getMapGametypeCombinations()
{
	mgCombinations = [];
	
	mapRotations = getMapRotations();

	// Convert map rotations into array with all the map/gametype combinations
	currentGametype = tolower( getdvard( "g_gametype", "string", "war" ) );

	for ( mr=0; mr < mapRotations.size; mr++ )
	{
		// Split the line into each element
		thisMapRotation = strtok( mapRotations[mr], " " );
		
		// Analyze the elements and start adding them to the list
		for ( e=0; e < thisMapRotation.size; e++ ) {
			// Discard "gametype" and "map" keywords
			if ( thisMapRotation[e] == "gametype" || thisMapRotation[e] == "map" ) {
				continue;
				
			// Check for valid gametype (we add semicolons to the string to make sure we have a full gametype name)
			} else if ( isSubstr( ";"+level.defaultGametypeList+";", ";"+thisMapRotation[e]+";" ) ) {
				currentGametype = thisMapRotation[e];
				continue;
				
			// Check for map and add it to the new list
			} else if ( getSubStr( thisMapRotation[e], 0, 3 ) == "mp_" ) {
				newElement = mgCombinations.size;
				mgCombinations[newElement]["gametype"] = currentGametype;
				mgCombinations[newElement]["mapname"] = thisMapRotation[e];
			}			
		}				
	}
	
	return mgCombinations;
}

getMapRotations()
{
	mapRotations = [];
	
	// Get the first mandatory map rotation
	thisMapRotation = tolower( getdvard( "sv_mapRotation", "string", "" ) );
	mapRotations[0] = thisMapRotation;
	
	return mapRotations;	
}