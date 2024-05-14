#include promatch\_utils;

init()
{
	// Load the module's dvars
	level.spectateOverride["allies"] = spawnstruct();
	level.spectateOverride["axis"] = spawnstruct();
	level.scr_livebroadcast_guids = getdvarx( "scr_livebroadcast_guids", "string","" );
	level.scr_game_spectatetype = getdvarx( "scr_game_spectatetype", "int", 0, 0, 2 );
	level.scr_game_spectatetype_spectators = getdvarx( "scr_game_spectatetype_spectators", "int", 0, 0, 2 );
	level.scr_game_spectators_guids = getdvarx( "scr_game_spectators_guids", "string", level.scr_livebroadcast_guids );
	level.scr_broadnames = getdvarx( "scr_broadnames", "int", 0,0,1 );
	
	level thread onPlayerConnect();
}


onPlayerConnect()
{
   for(;;)
   {
      level waittill("connecting", player);

      player thread onJoinedTeam();
      player thread onJoinedSpectators();
      player thread onPlayerSpawned();
   }
}


onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");
		self setSpectatePermissions();
	}
}


onJoinedTeam()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_team");
		self setSpectatePermissions();
	}
}

onJoinedSpectators()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_spectators");
		self setSpectatePermissions();
	}
}


updateSpectateSettings()
{
	level endon ( "game_ended" );

	for ( index = 0; index < level.players.size; index++ )
	level.players[index] setSpectatePermissions();
	//iPrintLnBold( "Updates: " + index );
}


getOtherTeam( team )
{
	if ( team == "axis" )
	return "allies";
	else if ( team == "allies" )
	return "axis";
	else
	return "none";
}



setSpectatePermissions()
{
	team = self.sessionteam;
	
	if ( self.pers["team"] == "spectator" ) 
	{
		self setclientdvars ("ui_end",0);		
		
		if(level.cod_mode == "torneio")
		{
			if ( level.scr_livebroadcast_guids != "" ) 
			{    
				
				if ( isSubstr( level.scr_livebroadcast_guids, self getguid() ) )
				{
					self setClientDvar( "g_compassshowenemies", "1");
					if (level.scr_broadnames == 1)
					self setClientDvar( "cg_drawThroughWalls", 1 );
				} 
				else 
				{ 
					self setClientDvar( "g_compassshowenemies", 0 );
					self setClientDvar( "cg_drawThroughWalls", 0 );
				}
			}
			else
			{
				self setClientDvar( "g_compassshowenemies", 0 );
				self setClientDvar( "cg_drawThroughWalls", 0 );
			}
			
			// If we have GUIDs setup then we'll check for matches
			if ( level.scr_game_spectators_guids != "" ) 
			{
				if ( issubstr( level.scr_game_spectators_guids, self getguid() ) ) 
				{
					spectateType = 2;
				} else 
				{
					spectateType = 1;				
				}           
			} 
			else 
			{
				
				spectateType = level.scr_game_spectatetype_spectators;
				
			}	
		}
		else
		{
			self setClientDvar("ui_end",0);		
			self setClientDvar( "g_compassshowenemies", 0 );
			self setClientDvar( "cg_drawThroughWalls", 0 );
			spectateType = level.scr_game_spectatetype_spectators;		
		}
		
	} 
	else
	{
		spectateType = level.scr_game_spectatetype;
	}
	
	switch( spectateType )
	{
		case 0: // disabled
			self allowSpectateTeam( "allies", false );
			self allowSpectateTeam( "axis", false );
			self allowSpectateTeam( "freelook", false );
			self allowSpectateTeam( "none", false );
			break;
		case 1: // team/player only
			if ( !level.teamBased )
			{
				self allowSpectateTeam( "allies", true );
				self allowSpectateTeam( "axis", true );
				self allowSpectateTeam( "none", true );
				self allowSpectateTeam( "freelook", false );
			}
			else if ( isDefined( team ) && (team == "allies" || team == "axis") )
			{
				self allowSpectateTeam( team, true );
				self allowSpectateTeam( getOtherTeam( team ), false );
				self allowSpectateTeam( "freelook", false );
				self allowSpectateTeam( "none", false );
			}
			else
			{
				self allowSpectateTeam( "allies", false );
				self allowSpectateTeam( "axis", false );
				self allowSpectateTeam( "freelook", false );
				self allowSpectateTeam( "none", false );
			}
			break;
		case 2: // free
			self allowSpectateTeam( "allies", true );
			self allowSpectateTeam( "axis", true );
			self allowSpectateTeam( "freelook", true );
			self allowSpectateTeam( "none", true );
			self setclientdvar( "r_fog", 0 );
			break;
	}
	if ( isDefined( team ) && (team == "axis" || team == "allies") )
	{
		self setclientdvar( "ui_broadcaster", 0 );
		
		if ( isdefined(level.spectateOverride[team].allowFreeSpectate) )
		self allowSpectateTeam( "freelook", true );
	
		if (isdefined(level.spectateOverride[team].allowEnemySpectate) && level.spectateOverride[team].allowEnemySpectate == 2)
		{
			self allowSpectateTeam( getOtherTeam( team ), true );
		}
		else if (isdefined(level.spectateOverride[team].allowEnemySpectate) && level.spectateOverride[team].allowEnemySpectate == 3)
		{
			self allowSpectateTeam( "allies", true );
			self allowSpectateTeam( "axis", true );
			self allowSpectateTeam( "freelook", false );
			self allowSpectateTeam( "none", false );
		} 
	
		//iPrintLnBold( "Type: " + spectateType );
		//iPrintLnBold( "Check: " + level.spectateOverride[team].allowEnemySpectate );
			
	}
}