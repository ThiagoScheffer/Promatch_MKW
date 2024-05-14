#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

#include promatch\_eventmanager;
#include promatch\_utils;

init()
{
	// Get the main module's dvar
	level.scr_timeouts_perteam = getdvarx( "scr_timeouts_perteam", "int", 0, 0, 5 );
	level.scr_match_strategy_time = getdvarx( "scr_match_strategy_time", "float", 0, 0, 800 );
	
	// If team timeouts are disabled or is not a match game or is not team based then there's nothing else to do here
	if ( level.scr_timeouts_perteam == 0 || !level.teamBased ) {
		return;
	}

	// Get the rest of the module's dvars
	level.scr_timeouts_guids = getdvarx( "scr_timeouts_guids", "string", level.scr_leadermenu_guids );

	// Precache some resources we'll be using
	precacheString( &"OW_TIMEOUT_CALLED" );
	precacheString( &"OW_TIMEOUTS_NOMORE" );
	precacheString( &"OW_TIMEOUTS_LEFT" );
	

	// Check if we already stored the number of timeouts remaining for each team in this game
	if ( !isDefined( game["timeouts"] ) ) 
	{
		game["timeouts"]["allies"] = level.scr_timeouts_perteam;
		game["timeouts"]["axis"] = level.scr_timeouts_perteam;
	}

	if ( !isDefined( level.bombPlanted ) )
	level.bombPlanted = false;

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}


onPlayerSpawned()
{
	// By default a player is not in timeout mode
	self.inTimeout = false;
}


timeoutCalled()
{
	// Make sure timeouts are allowed
	if ( level.scr_timeouts_perteam == 0 || !level.teamBased )
	return;

	// Make sure we are not in any state where we don't allowe timeouts to be called
	if ( level.inReadyUpPeriod || level.inStrategyPeriod || level.inPrematchPeriod || level.inTimeoutPeriod || level.inFinalKillcam || game["state"] == "postgame" )
	return;

	// Check if only certain people can call timeouts
	//if ( level.scr_timeouts_perteam != 0 ) {
	//	if ( !issubstr( level.scr_timeouts_guids, self getguid() ) ) {
	//		return;
	//	}
	//} 

	// Check if this player's team has timeouts left
	playerTeam = self.pers["team"];
	if ( game["timeouts"][playerTeam] == 0 ) 
	{
		// Inform all the players in the player's team that there are no more timeouts left
		for ( i = 0; i < level.players.size; i++ )
		{
			if ( level.players[i].pers["team"] == playerTeam ) {
				level.players[i] iprintln( &"OW_TIMEOUTS_NOMORE", self.name );
			}
		}
		return;
	} else 
	{
		game["timeouts"][playerTeam] -= 1;

		// Show the information about who called the timeout and how many timeouts are left to the team calling the timeout
		for ( i = 0; i < level.players.size; i++ )
		{
			if ( level.players[i].pers["team"] == playerTeam ) 
			{
				level.players[i] iprintln( &"OW_TIMEOUTS_LEFT", self.name, game["timeouts"][playerTeam] );
			}
		}
	}


	// We are officially in timeout mode
	level.timeoutTeam = playerTeam;
	level thread playSoundOnEveryone( "mp_last_stand" );
	setdvar ("scr_strattext","Strat Timeout");
	setDvar("scr_match_strategy_time", 700);
	return;
}

playSoundOnEveryone( soundName )
{
	level endon( "game_ended" );
	
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		player playLocalSound( soundName );
		player thread TimeoutRoll();
	}	
}


TimeoutRoll()
{
        self endon ( "disconnect" );
        displayText = self createFontString( "objective", 1.5 );
        displayText setPoint( "left", "bottom", -230, 230);
        displayText setText("^1Time-out foi pedido!");
		maps\mp\gametypes\_hud_message::hintMessage("^1Time-out foi pedido");//ADDED
}

