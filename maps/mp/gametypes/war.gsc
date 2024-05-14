#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include promatch\_utils;

main()
{
	if(getdvar("mapname") == "mp_background")
	return;
	
	if ( !isdefined( game["switchedsides"] ) )
	game["switchedsides"] = false;		
	
	level.scr_war_forcestartspawns = getdvarx( "scr_war_forcestartspawns", "int", 0, 0, 1 );
	
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 0, 0, 10 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 1, 0, 500 );
	maps\mp\gametypes\_globallogic::registerRoundSwitchDvar( level.gameType, 0, 0, 500 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 12000, 0, 8000 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 12, 0, 1440 );
	
	level.teamBased = true;
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onRoundSwitch = ::onRoundSwitch;

	level.onEndGame = ::onEndGame;
	
	game["dialog"]["gametype"] = gameTypeDialog( "team_deathmtch" );
}


onStartGameType()
{
	setClientNameMode("auto_change");

	maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OBJECTIVES_WAR" );
	maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OBJECTIVES_WAR" );
	maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OBJECTIVES_WAR_SCORE" );
	maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OBJECTIVES_WAR_SCORE" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"OBJECTIVES_WAR_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"OBJECTIVES_WAR_HINT" );
	
	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );	
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );

	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );
	
	allowed[0] = "war";
	
	if ( getDvarInt( "scr_oldHardpoints" ) > 0 )
	allowed[1] = "hardpoint";
	
	level.displayRoundEndText = false;
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	// elimination style
	if ( level.roundLimit != 1 && level.numLives )
	{
		level.overrideTeamScore = true;
		level.displayRoundEndText = true;
		level.onDeadEvent = ::onDeadEvent;
	}
	
}

onSpawnPlayer()
{
	// Check which spawn points should be used
	if ( game["switchedsides"] ) {
		spawnTeam = level.otherTeam[ self.pers["team"] ];
	} else {
		spawnTeam =  self.pers["team"];
	}
	
	self.usingObj = undefined;

	if ( level.inGracePeriod || level.scr_war_forcestartspawns )
	{
		spawnPoints = getentarray("mp_tdm_spawn_" + spawnTeam + "_start", "classname");
		
		if ( !spawnPoints.size )
		spawnPoints = getentarray("mp_sab_spawn_" + spawnTeam + "_start", "classname");
		
		if ( !spawnPoints.size )
		{
			spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnTeam );
			spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
		}
		else
		{
			spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
		}		
	}
	else
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnTeam );
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
	}
	
	self spawn( spawnPoint.origin, spawnPoint.angles );
}


onDeadEvent( team )
{
	// Make sure players on both teams were not eliminated
	if ( team != "all" ) {
		[[level._setTeamScore]]( getOtherTeam(team), [[level._getTeamScore]]( getOtherTeam(team) ) + 1 );
		thread maps\mp\gametypes\_globallogic::endGame( getOtherTeam(team), game["strings"][team + "_eliminated"] );
	} else {
		// We can't determine a winner if everyone died like in S&D so we declare a tie
		thread maps\mp\gametypes\_globallogic::endGame( "tie", game["strings"]["round_draw"] );
	}
}


onRoundSwitch()
{
	// Just change the value for the variable controlling which map assets will be assigned to each team
	level.halftimeType = "halftime";
	game["switchedsides"] = !game["switchedsides"];
}

onEndGame( winningTeam )
{
	if ( isdefined( winningTeam ) && (winningTeam == "allies" || winningTeam == "axis") )
	{
		thread GiveScorePlayersTeamPlanted(winningTeam);
		
		[[level._setTeamScore]]( winningTeam, [[level._getTeamScore]]( winningTeam ) + 1 );		
	}
}

//da ao  time X evps
GiveScorePlayersTeamPlanted(team)
{

	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
    
		if(player.pers["team"] != team)
		continue;
		
		if(player.score < 2100)
		continue;
	  
		if ( player.pers["team"] == team )
		{
			player GiveEVP(300,100);
		}
	}
}