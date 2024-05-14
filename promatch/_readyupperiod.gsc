#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

#include promatch\_eventmanager;
#include promatch\_utils;
//V104
init()
{
	// Get the main module's dvar
	level.scr_match_readyup_period = getdvarx( "scr_match_readyup_period", "int", 0, 0, 1 );
	level.scr_match_strategy_time = getdvarx( "scr_match_strategy_time", "float", 0, 0, 200 );
	level.scr_league_ruleset = getdvarx( "scr_league_ruleset", "string", "" );
	level.version = getdvarx( "_ModVer", "string", "" );

	// If readyup period is disabled then there's nothing else to do here
	if ( level.scr_match_readyup_period == 0 ) 
	{
		level.inReadyUpPeriod = false;
		return;
	}
	
	
	// Get the rest of the module's dvar
	level.scr_match_readyup_disable_weapons = getdvarx( "scr_match_readyup_disable_weapons", "int", 0, 0, 1 );
	level.scr_match_readyup_show_checksums_interval = 30;
	level.scr_match_readyup_time_match = int( getdvarx( "scr_match_readyup_time_match", "float", 0, 0, 1440 ) * 60 );
	level.scr_match_readyup_time_round = int( getdvarx( "scr_match_readyup_time_round", "float", 0, 0, 1440 ) * 60 );
	
	// Check if it's coming back after restarting the map //Timeout Thinking
	if ( isDefined( game["readyupperiod"] ) && game["readyupperiod"] && level.scr_kniferound == 1)
	{
		// Deactivate map objectives
		precacheShader( "knife_mp" );
		precacheShader( "c4_mp" );
		thread deactivateMapObjectives();
		level.onLoadoutGiven = ::onLoadoutGiven;
		game["readyupperiod"] = false;
		return;
	} 
	else if ( isDefined( game["readyupperiod"] ) && game["readyupperiod"] )
	{
		game["readyupperiod"] = false;
		return;
	}

	// We are officially in readyup period
	level notify("readyupperiod_started");
	level.inReadyUpPeriod = true;
	game["readyupperiod"] = true;
	setDvar( "g_deadChat", "1" );
	setClientNameMode( "auto_change" );
	
	//if ( isdefined(game["_overtime"]) && game["_overtime"] == true)
	//level.scr_league_ruleset = "Tie Breaker";

	// Deactivate map objectives
	thread deactivateMapObjectives();

	// Precache some resources we'll be using
	precacheString( &"OW_READYUP_ALL_PLAYERS_READY" );
	precacheString( &"OW_READYUP_MOD_CHECKSUMS" );
	precacheString( &"OW_READYUP_NOT_READY" );
	precacheString( &"OW_READYUP_PERIOD" );
	precacheString( &"OW_READYUP_PERIOD_ROUND" );
	precacheString( &"OW_READYUP_PRESS_TO_TOGGLE" );
	precacheString( &"OW_READYUP_READY" );
	precacheString( &"OW_READYUP_RECORD_REMINDER" );
	precacheString( &"OW_READYUP_WAITING_FOR_MORE_PLAYERS" );
	
	//precacheStatusIcon( "compassping_friendlyyelling_mp" );
	//precacheStatusIcon( "compassping_player" );

	//Now is gonna blow >:O
	level.promatchver = newHudElem();
	level.promatchver.x = -7;
	level.promatchver.y = 35;
	level.promatchver.horzAlign = "right";
	level.promatchver.vertAlign = "top";
	level.promatchver.alignX = "right";
	level.promatchver.alignY = "middle";
	level.promatchver.alpha = 1;
	level.promatchver.fontScale = 1.4;
	level.promatchver.hidewheninmenu = true;
	//level.promatchver.color = (1,0.5,0);
	level.promatchver setText("ProMatch MW ^13.0.0");

	level.ruletext = newHudElem();
	level.ruletext.x = -7;
	level.ruletext.y = 50;
	level.ruletext.horzAlign = "right";
	level.ruletext.vertAlign = "top";
	level.ruletext.alignX = "right";
	level.ruletext.alignY = "middle";
	level.ruletext.alpha = 1;
	level.ruletext.fontScale = 1.4;
	level.ruletext.hidewheninmenu = true;
	level.ruletext.color = (1,0.5,0);
	level.ruletext setText( level.scr_league_ruleset );
/*	
	if (level.scr_hard)
	{
	level.hardertext = newHudElem();
	level.hardertext.x = -7;
	level.hardertext.y = 65;
	level.hardertext.horzAlign = "right";
	level.hardertext.vertAlign = "top";
	level.hardertext.alignX = "right";
	level.hardertext.alignY = "middle";
	level.hardertext.alpha = 1;
	level.hardertext.fontScale = 1.4;
	level.hardertext.hidewheninmenu = true;
	level.hardertext.color = (1,0.8,0);
	level.hardertext setText( "Harder Mode Enable");
	}
*/
	//Waiting players Count.
	level.waiting = newHudElem();
	level.waiting.x = -60;
	level.waiting.y = 100;
	level.waiting.horzAlign = "right";
	level.waiting.vertAlign = "middle";
	level.waiting.alignX = "center";
	level.waiting.alignY = "middle";
	level.waiting.fontScale = 1.4;
	level.waiting.font = "default";
	level.waiting.color = (1,0.5,0);
	level.waiting.hidewheninmenu = true;
	level.waiting setText("Waiting on...");
	
	// Show the player we are in ready up period
	game["readyUpPeriod"] = createServerFontString( "objective", 1.4 );
	game["readyUpPeriod"].archived = false;
	game["readyUpPeriod"].hideWhenInMenu = true;
	game["readyUpPeriod"].alignX = "center";
	game["readyUpPeriod"].alignY = "top";
	game["readyUpPeriod"].horzAlign = "center";
	game["readyUpPeriod"].vertAlign = "top";
	game["readyUpPeriod"].sort = -1;
	game["readyUpPeriod"].x = 0;
	game["readyUpPeriod"].y = 60;
	
	if( game["roundsplayed"] )
	{
		game["readyUpPeriod"] setText( &"OW_READYUP_PERIOD_ROUND" );
	} else {
		game["readyUpPeriod"] setText( &"OW_READYUP_PERIOD" );
	}

	// Let's wait until we have enough players to start a match
	level.waitingForPlayers = true;


	// Make sure we have enough players
	waitForPlayers();

	// Let's check if there's a time limit to force the ready-up to be over
	if ( level.scr_match_readyup_time_match != 0 && !game["roundsplayed"] ) {
		level thread showTimeLimitCountdown( level.scr_match_readyup_time_match );
		
	} else if ( level.scr_match_readyup_time_round != 0 && game["roundsplayed"] ) {
		level thread showTimeLimitCountdown( level.scr_match_readyup_time_round );
	}

	// Create the HUD elements
	createHudElements();
	
	createPlayerElements();

	// Let's wait until all players are ready to start the match
	while ( level.inReadyUpPeriod )
	{
		wait level.oneFrame;
		
		// Initialize counters
		readyUpNotReady[ "allies" ] = 0;
		readyUpNotReady[ "axis" ] = 0;
		readyUpNotReady[ "spectator" ] = 0;

		// Check all the players
		for ( index = 0; index < level.players.size; index++ )
		{
			player = level.players[index];

			// Start the monitoring thread if this player doesn't have it running
			
			if ( !isDefined( player.readyUpPeriod ) ) {				
				player.matchReady = false;
				player thread readyUpPeriod();
				player thread addNewEvent( "onJoinedTeam", ::onJoinedTeam );
			}

			// Get the players team
			playerTeam = player.pers["team"];

			// Check type of player

			if ( !isDefined( player.matchReady ) || !player.matchReady ) {
				readyUpNotReady[ playerTeam ]++;
			}

			
		}

		// If there are no players "not ready" then ready up period is over
		if ( readyUpNotReady[ "allies" ] == 0 && readyUpNotReady[ "axis" ] == 0 && readyUpNotReady[ "spectator" ] == 0 ) {
			level.inReadyUpPeriod = false; 
		}
		
		
		// Update the HUD elements
		// Display the amount of players in the allies team not ready
		game["readyUpTextAlliesNotReady"] setValue( readyUpNotReady[ "allies" ] );
		if ( readyUpNotReady[ "allies" ] == 0 ) {
			game["readyUpTextAlliesNotReady"].color = ( 0.07, 0.69, 0.26 );
			
		} else {
			game["readyUpTextAlliesNotReady"].color = ( 0.694, 0.220, 0.114 );
		}

		// Display the amount of players in the axis team not ready
		game["readyUpTextAxisNotReady"] setValue( readyUpNotReady[ "axis" ] );
		if ( readyUpNotReady[ "axis" ] == 0 ) {
			game["readyUpTextAxisNotReady"].color = ( 0.07, 0.69, 0.26 );
		} else {
			game["readyUpTextAxisNotReady"].color = ( 0.694, 0.220, 0.114 );
		}
	}

	level notify("readyupperiod_ended");

	// Destroy the HUD elements
	destroyHudElements();
	xwait( 1.0, false );
	setClientNameMode( "manual_change" );
	// Restart the map and go to match start timer
	map_restart( true );

	xwait( 1.0, false );
}

onJoinedTeam()
{
	self.matchReady = false;
}

readyUpPeriod()
{
	self endon("disconnect");

	self.readyUpPeriod = true;

	// Wait until waiting for players is over
	while ( level.waitingForPlayers )
	wait level.oneFrame;

	// Create the HUD element that will show the player if is ready or not
	self.readyUpText = createFontString( "objective", 1.5 );
	self.readyUpText setPoint( "CENTER", "BOTTOM", 0, -40 );
	self.readyUpText.sort = 1001;
	self.readyUpText.foreground = false;
	self.readyUpText.hidewheninmenu = true;

	// Create the press USE key to toggle the readiness status
	self.readyUpToggleText = createFontString( "default", 1.4 );
	self.readyUpToggleText setPoint( "CENTER", "BOTTOM", 0, -13 );
	self.readyUpToggleText.sort = 1001;
	self.readyUpToggleText.foreground = false;
	self.readyUpToggleText.hidewheninmenu = true;
	self.readyUpToggleText setText( &"OW_READYUP_PRESS_TO_TOGGLE" );

	// We are going to monitor this player until the readyup period ends
	keyDown = false;

	while ( level.inReadyUpPeriod)
	{
		wait level.oneFrame;

		// Check if the player hit the use key
		if ( self useButtonPressed() ) {
			// Toggle the status
			self.matchReady = !self.matchReady;
			keyDown = true;
		}

		// Check if there was a status change and update the player status
		if ( self.matchReady ) 
		{
			//self.statusicon = "compassping_friendlyyelling_mp";
			self.readyUpText.color = ( 0.07, 0.69, 0.26 );
			self.readyUpText setText( &"OW_READYUP_READY" );
		}
		if ( !self.matchReady ) {
			//self.statusicon = "compassping_player";
			self.readyUpText.color = ( 0.694, 0.220, 0.114 );
			self.readyUpText setText( &"OW_READYUP_NOT_READY" );
		}

		// If the player pressed the use key then we have to wait until the key is released
		if ( keyDown ) {
			// Wait until the player releases the key or readyup period is over
			while ( level.inReadyUpPeriod && self useButtonPressed() ) {
				wait level.oneFrame;
			}
			keyDown = false;
		}
	}

	// Clear the HUD elements
	if ( isDefined( self.readyUpText ) )
	self.readyUpText destroy();

	if ( isDefined( self.readyUpToggleText ) )
	self.readyUpToggleText destroy();

	//if ( self.pers["team"] != "spectator" )
	self notify("readyupperiod_ended");
	
	self.readyUpPeriod = undefined;
}


waitForPlayers()
{
	// Create the HUD element so players know we are waiting for more players
	waitingForPlayersText = createServerFontString( "objective", 1.5 );
	waitingForPlayersText setPoint( "CENTER", "BOTTOM", 0, -10 );
	waitingForPlayersText.sort = 1001;
	waitingForPlayersText.foreground = false;
	waitingForPlayersText.hidewheninmenu = true;
	waitingForPlayersText setText( &"OW_READYUP_WAITING_FOR_MORE_PLAYERS" );

 	while ( level.waitingForPlayers )
	{
		wait level.oneFrame;
		players[ "allies" ] = 0;
		players[ "axis" ] = 0;
		players[ "spectator" ] = 0;

		for ( index = 0; index < level.players.size; index++ )
		{
			player = level.players[index];
			// Get the players team
			playerTeam = player.pers[ "team" ];
			players[ playerTeam ]++;

			// Check if we have players on both teams
			if ( level.teamBased ) {
				if ( players[ "allies" ] > 0 && players[ "axis" ] > 0 ) {
					level.waitingForPlayers = false;
					break;
				}
			} else {
				// Or if we have more than 1 players for FFA
				if ( ( players[ "allies" ] + players[ "axis" ] ) >= 2 ) {
					level.waitingForPlayers = false;
					break;
				}
			}
		}
	}

	// Destroy the HUD element
	waitingForPlayersText destroy();
	level.waitingForPlayers = false;
}


destroyHudElements()
{
	// Allies
	game["readyUpIconAllies"] destroy();
	game["readyUpTextAlliesNotReady"] destroy();

	// Axis
	game["readyUpIconAxis"] destroy();
	game["readyUpTextAxisNotReady"] destroy();

	// Misc
	game["readyUpPeriod"] destroy();
	level.promatchver destroy();
	level.ruletext destroy();
//	if (level.scr_hard)
	//{
	//level.hardertext destroy();
	//}
	level.waiting destroy();
}

//Icones e numero do Modo pronto 
createPlayerElements()
{
	// Create the elements to show the allies readiness status
	game["AliveDeadIconAllies"] = createServerIcon( game["icons"]["allies"], 28, 28 );
	game["AliveDeadIconAllies"].archived = false;
	game["AliveDeadIconAllies"].hideWhenInMenu = true;
	game["AliveDeadIconAllies"].alignX = "center";
	game["AliveDeadIconAllies"].alignY = "bottom";
	game["AliveDeadIconAllies"].horzAlign = "right";
	game["AliveDeadIconAllies"].vertAlign = "bottom";
	game["AliveDeadIconAllies"].sort = -3;
	game["AliveDeadIconAllies"].alpha = 0.9;
	game["AliveDeadIconAllies"].x = 200;
	game["AliveDeadIconAllies"].y = 390;

	return;
}


//Icones e numero do Modo pronto 
createHudElements()
{
	// Create the elements to show the allies readiness status
	game["readyUpIconAllies"] = createServerIcon( game["icons"]["allies"], 28, 28 );
	game["readyUpIconAllies"].archived = false;
	game["readyUpIconAllies"].hideWhenInMenu = true;
	game["readyUpIconAllies"].alignX = "center";
	game["readyUpIconAllies"].alignY = "bottom";
	game["readyUpIconAllies"].horzAlign = "right";
	game["readyUpIconAllies"].vertAlign = "bottom";
	game["readyUpIconAllies"].sort = -3;
	game["readyUpIconAllies"].alpha = 0.9;
	game["readyUpIconAllies"].x = -28;
	game["readyUpIconAllies"].y = -85;

	game["readyUpTextAlliesNotReady"] = createServerFontString( "objective", 1.6 );
	game["readyUpTextAlliesNotReady"].archived = false;
	game["readyUpTextAlliesNotReady"].hideWhenInMenu = true;
	game["readyUpTextAlliesNotReady"].alignX = "left";
	game["readyUpTextAlliesNotReady"].alignY = "bottom";
	game["readyUpTextAlliesNotReady"].horzAlign = "right";
	game["readyUpTextAlliesNotReady"].vertAlign = "bottom";
	game["readyUpTextAlliesNotReady"].sort = -1;
	game["readyUpTextAlliesNotReady"].x = -42;
	game["readyUpTextAlliesNotReady"].y = -70;


	// Create the elements to show the axis readiness status
	game["readyUpIconAxis"] = createServerIcon( game["icons"]["axis"], 28, 28 );
	game["readyUpIconAxis"].archived = false;
	game["readyUpIconAxis"].hideWhenInMenu = true;
	game["readyUpIconAxis"].alignX = "center";
	game["readyUpIconAxis"].alignY = "bottom";
	game["readyUpIconAxis"].horzAlign = "right";
	game["readyUpIconAxis"].vertAlign = "bottom";
	game["readyUpIconAxis"].sort = -3;
	game["readyUpIconAxis"].alpha = 0.9;
	game["readyUpIconAxis"].x = -58;
	game["readyUpIconAxis"].y = -85;

	game["readyUpTextAxisNotReady"] = createServerFontString( "objective", 1.6 );
	game["readyUpTextAxisNotReady"].archived = false;
	game["readyUpTextAxisNotReady"].hideWhenInMenu = true;
	game["readyUpTextAxisNotReady"].alignX = "right";
	game["readyUpTextAxisNotReady"].alignY = "bottom";
	game["readyUpTextAxisNotReady"].horzAlign = "right";
	game["readyUpTextAxisNotReady"].vertAlign = "bottom";
	game["readyUpTextAxisNotReady"].sort = -1;
	game["readyUpTextAxisNotReady"].x = -72;
	game["readyUpTextAxisNotReady"].y = -70;

	return;
}

onLoadoutGiven()
{
	self knifeonly();	
}

knifeonly()
{
	
	self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
	self takeAllWeapons();
	self clearPerks();
	self giveWeapon( "c4_mp" );
	self setWeaponAmmoClip("c4_mp",0);
	self setSpawnWeapon( "c4_mp" );
	self switchToWeapon( "c4_mp" );
	self thread maps\mp\gametypes\_gameobjects::_enableWeapon();

}
notifyObjectiveCreated()
{
	level endon("readyupperiod_ended");
	
	// Sending this event 2 times because gametype and readyup thread are not synchronized, so they could lose the event
	level notify( "spawned_objectivefx" );
	
	level waittill("readyupperiod_started");
	
	level notify( "spawned_objectivefx" );
}

deactivateMapObjectives()
{
	level waittill("spawned_objectivefx");
	
	// See which gametype is running and deactivate the corresponding objectives
	switch ( level.gametype ) {
		case "ass":
			// Deactivate the extraction zone trigger
			level.extractionZone maps\mp\gametypes\_gameobjects::allowUse( "none" );
			break;
		case "ch":
			// Deactivate the flag so nobody can pick it up
			level.flag maps\mp\gametypes\_gameobjects::allowUse( "none" );
			break;
			
		case "ctf":
			// Deactivate the flags so nobody can pick them up
			level.flags["allies"] maps\mp\gametypes\_gameobjects::allowUse( "none" );
			level.flags["axis"] maps\mp\gametypes\_gameobjects::allowUse( "none" );
			break;
			
		case "dom":
			// Deactivate all the domination flags so nobody can capture them
			for ( idx = 0; idx < level.domFlags.size; idx++ ) {
				level.domFlags[ idx ] maps\mp\gametypes\_gameobjects::allowUse( "none" );
			}
			break;
			
		case "koth":
			// Show all the locations where the HQ can spawn
			for ( idx = 0; idx < level.radios.size; idx++ ) {
				level.radios[ idx ].gameObject maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
				level.radios[ idx ].gameObject maps\mp\gametypes\_gameobjects::setModelVisibility( true );
				level.radios[ idx ].gameObject maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_captureneutral" );
				level.radios[ idx ].gameObject maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_captureneutral" );
				level.radios[ idx ].gameObject maps\mp\gametypes\_gameobjects::allowUse( "none" );
			}
			break;
			
		case "re":
			// Deactivate the objectives so nobody can pick them up
			level.objectiveA maps\mp\gametypes\_gameobjects::allowUse( "none" );
			level.objectiveB maps\mp\gametypes\_gameobjects::allowUse( "none" );
			break;
			
		case "sab":
			// Change the bomb attributes so no one can pick it up
			level.sabBomb maps\mp\gametypes\_gameobjects::allowCarry( "none" );
			// Deactivate the bomb sites
			level.bombZones["allies"] maps\mp\gametypes\_gameobjects::allowUse( "none" );
			level.bombZones["axis"] maps\mp\gametypes\_gameobjects::allowUse( "none" );
			// Show the location of the bomb sites to the players
			level.bombZones["allies"] maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
			level.bombZones["axis"] maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
			break;
			
		case "sd":
			// Change the bomb attributes so no one can pick it up
			if ( isDefined( level.sdBomb ) )
				level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry( "none" );
				
			// Deactivate the bomb sites
			for ( idx = 0; idx < level.bombZones.size; idx++ ) {
				level.bombZones[ idx ] maps\mp\gametypes\_gameobjects::allowUse( "none" );
			}
			
			break;
			
		case "tgr":
			// Deactivate the objectives so nobody can use them
			level.dropZones["allies"] maps\mp\gametypes\_gameobjects::allowUse( "none" );
			level.dropZones["axis"] maps\mp\gametypes\_gameobjects::allowUse( "none" );
			break;
			
	}
	
	return;
}


showTimeLimitCountdown( timeLimit )
{
	// Create the time limit countdown number
	limitCountdownTimer = createServerTimer( "objective", 3.0 );
	limitCountdownTimer setTimer( timeLimit );
	limitCountdownTimer setPoint( "CENTER", "CENTER", 0, 65 );
	limitCountdownTimer.color = ( 1, 0.5, 0 );
	limitCountdownTimer.sort = 1001;
	limitCountdownTimer.foreground = false;
	limitCountdownTimer.hideWhenInMenu = true;	
	
	// Calculate the time we need to wait
	matchStarts = gettime() + timeLimit * 1000;
	
	// Wait until the ready-up period ends or the time limit is reached
	while ( level.inReadyUpPeriod && gettime() < matchStarts )
	wait level.oneFrame;
	
	// Destroy the HUD element	
	limitCountdownTimer destroy();
	
	// Force ready-up
	level.inReadyUpPeriod = false;	
}
