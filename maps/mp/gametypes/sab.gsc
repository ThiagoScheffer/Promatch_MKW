#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include promatch\_utils;


main()
{
	if ( getdvar("mapname") == "mp_background" )
		return;

	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	level.teamBased = true;
	level.overrideTeamScore = true;

	// Syntax is getdvarx( dvarname, dvartype, dvardefault, minValue, maxValue )
	level.scr_sab_show_bomb_carrier = getdvarx( "scr_sab_show_bomb_carrier", "int", 0, 0, 2  );
	level.scr_sab_scoreboard_bomb_carrier = getdvarx( "scr_sab_scoreboard_bomb_carrier", "int", 1, 0, 1 );
	level.scr_sab_suddendeath_show_enemies = getdvarx( "scr_sab_suddendeath_show_enemies", "int", 1, 0, 1 );
	level.scr_sab_suddendeath_timelimit = getdvarx( "scr_sab_suddendeath_timelimit", "int", 90, 0, 600 );
	level.scr_sab_show_briefcase = getdvarx( "scr_sab_show_briefcase", "int", 1, 0, 1 );
	level.scr_sab_show_bomb_carrier_time = getdvarx( "scr_sab_show_bomb_carrier_time", "int", 5, 5, 600 );
	level.scr_sab_show_bomb_carrier_distance = getdvarx( "scr_sab_show_bomb_carrier_distance", "int", 0, 0, 1000 );
	
	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 0, 0, 10 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 4, 0, 500 );
	maps\mp\gametypes\_globallogic::registerRoundSwitchDvar( level.gameType, 2, 0, 500 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 3, 0, 5000 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 15, 0, 1440 );

	if ( !game["tiebreaker"] )
	{
		level.onPrecacheGameType = ::onPrecacheGameType;
		level.onStartGameType = ::onStartGameType;
		level.onSpawnPlayer = ::onSpawnPlayer;
		level.onTimeLimit = ::onTimeLimit;
		level.onDeadEvent = ::onDeadEvent;
		level.onRoundSwitch = ::onRoundSwitch;

		level.endGameOnScoreLimit = false;


	}
	else
	{
		level.onStartGameType = ::onStartGameType;
		level.onSpawnPlayer = ::onSpawnPlayer;
		level.onEndGame = ::onEndGame;

		level.endGameOnScoreLimit = false;



		maps\mp\gametypes\_globallogic::registerNumLivesDvar( "tb", 1, 1, 1 );
		maps\mp\gametypes\_globallogic::registerTimeLimitDvar( "tb", 0, 0, 0 );
	}

	badtrig = getent( "sab_bomb_defuse_allies", "targetname" );
	if ( isdefined( badtrig ) )
		badtrig delete();

	badtrig = getent( "sab_bomb_defuse_axis", "targetname" );
	if ( isdefined( badtrig ) )
		badtrig delete();
}

onPrecacheGameType()
{
	game["bomb_dropped_sound"] = "mp_war_objective_lost";
	game["bomb_recovered_sound"] = "mp_war_objective_taken";

	precacheShader("waypoint_bomb");

	precacheShader("waypoint_kill");
	precacheShader("waypoint_bomb_enemy");
	precacheShader("waypoint_defend");
	precacheShader("waypoint_defuse");
	precacheShader("waypoint_target");
	precacheShader("compass_waypoint_bomb");
	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_defuse");
	precacheShader("compass_waypoint_target");
	precacheShader("hud_suitcase_bomb");

	precacheString(&"MP_EXPLOSIVES_RECOVERED_BY");
	precacheString(&"MP_EXPLOSIVES_DROPPED_BY");
	precacheString(&"MP_EXPLOSIVES_PLANTED_BY");
	precacheString(&"MP_EXPLOSIVES_DEFUSED_BY");
	precacheString(&"MP_YOU_HAVE_RECOVERED_THE_BOMB");
	precacheString(&"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES");
	precacheString(&"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES");
	precacheString(&"MP_PLANTING_EXPLOSIVE");
	precacheString(&"MP_DEFUSING_EXPLOSIVE");
	precacheString(&"MP_TARGET_DESTROYED");
	precacheString(&"MP_NO_RESPAWN");
	precacheString(&"MP_TIE_BREAKER");
	precacheString(&"MP_NO_RESPAWN");
	precacheString(&"MP_SUDDEN_DEATH");

	precacheModel( "prop_suitcase_bomb" );
}


onRoundSwitch()
{
	if ( !isdefined( game["switchedsides"] ) )
		game["switchedsides"] = false;

	if ( game["teamScores"]["allies"] == level.scorelimit - 1 && game["teamScores"]["axis"] == level.scorelimit - 1 )
	{
		level.halftimeType = "overtime";
		level.halftimeSubCaption = &"MP_TIE_BREAKER";
		game["tiebreaker"] = true;
	}
	else
	{
		level.halftimeType = "halftime";
		game["switchedsides"] = !game["switchedsides"];
	}
}


onStartGameType()
{
	if ( !isdefined( game["switchedsides"] ) )
		game["switchedsides"] = false;

	setClientNameMode("auto_change");

	game["strings"]["target_destroyed"] = &"MP_TARGET_DESTROYED";

	if ( !game["tiebreaker"] )
	{
		maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OBJECTIVES_SAB" );
		maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OBJECTIVES_SAB" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OBJECTIVES_SAB_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OBJECTIVES_SAB_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"OBJECTIVES_SAB_HINT" );
		maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"OBJECTIVES_SAB_HINT" );
	}
	else
	{
		maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OBJECTIVES_WAR" );
		maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OBJECTIVES_WAR" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OBJECTIVES_WAR_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OBJECTIVES_WAR_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"OBJECTIVES_WAR_HINT" );
		maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"OBJECTIVES_WAR_HINT" );
	}

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sab_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sab_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_sab_spawn_allies" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_sab_spawn_axis" );

	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );

	level.spawn_axis = getentarray("mp_sab_spawn_axis", "classname");
	level.spawn_allies = getentarray("mp_sab_spawn_allies", "classname");
	level.spawn_axis_start = getentarray("mp_sab_spawn_axis_start", "classname");
	level.spawn_allies_start = getentarray("mp_sab_spawn_allies_start", "classname");

	level._effect["bombexplosion"] = loadfx("explosions/tanker_explosion");

	if ( game["tiebreaker"] )
	{
		allowed[0] = "war";
		maps\mp\gametypes\_gameobjects::main(allowed);
		return;
	}

	level.displayRoundEndText = true;

	allowed[0] = "sab";
	maps\mp\gametypes\_gameobjects::main(allowed);

	thread updateGametypeDvars();

	thread sabotage();
}


onTimeLimit()
{
	if ( level.inOvertime )
		return;

	thread onOvertime();
}


onOvertime()
{
	level endon ( "game_ended" );

	level.timeLimitOverride = true;
	level.inOvertime = true;

	for ( index = 0; index < level.players.size; index++ )
	{
		level.players[index] notify("force_spawn");
		level.players[index] thread maps\mp\gametypes\_hud_message::oldNotifyMessage( &"MP_SUDDEN_DEATH", &"MP_NO_RESPAWN", undefined, (1, 0, 0), "mp_last_stand" );

		if ( level.scr_sab_suddendeath_show_enemies == 1 ) {
			level.players[index] setClientDvars("cg_deadChatWithDead", 1,
								"cg_deadChatWithTeam", 0,
								"cg_deadHearTeamLiving", 0,
								"cg_deadHearAllLiving", 0,
								"cg_everyoneHearsEveryone", 0,
								"g_compassShowEnemies", 1 );
		}
	}

	if ( level.scr_sab_suddendeath_timelimit > 0 ) {
		waitTime = 0;
		while ( waitTime < level.scr_sab_suddendeath_timelimit ) {
			if ( !level.bombPlanted ) {
				waitTime += 1;
				setGameEndTime( getTime() + ( ( level.scr_sab_suddendeath_timelimit - waitTime ) * 1000 ) );
			}
			xwait( 1.0, false );
		}
		thread maps\mp\gametypes\_globallogic::endGame( "tie", game["strings"]["tie"] );
	} else {
		level.timelimit = 0;
	}
}


onDeadEvent( team )
{
	if ( level.bombExploded )
		return;

	if ( team == "all" )
	{
		if ( level.bombPlanted )
		{
			[[level._setTeamScore]]( level.bombPlantedBy, [[level._getTeamScore]]( level.bombPlantedBy ) + 1 );
			thread maps\mp\gametypes\_globallogic::endGame( level.bombPlantedBy, game["strings"][level.bombPlantedBy+"_mission_accomplished"] );
		}
		else
		{
			thread maps\mp\gametypes\_globallogic::endGame( "tie", game["strings"]["tie"] );
		}
	}
	else if ( level.bombPlanted )
	{
		if ( team == level.bombPlantedBy )
		{
			level.plantingTeamDead = true;
			return;
		}

		[[level._setTeamScore]]( level.bombPlantedBy, [[level._getTeamScore]]( level.bombPlantedBy ) + 1 );
		thread maps\mp\gametypes\_globallogic::endGame( level.bombPlantedBy, game["strings"][level.otherTeam[level.bombPlantedBy]+"_eliminated"] );
	}
	else
	{
		[[level._setTeamScore]]( level.otherTeam[team], [[level._getTeamScore]]( level.otherTeam[team] ) + 1 );
		thread maps\mp\gametypes\_globallogic::endGame( level.otherTeam[team], game["strings"][team+"_eliminated"] );
	}
}


onSpawnPlayer()
{
	self.isPlanting = false;
	self.isDefusing = false;
	self.isBombCarrier = false;

	spawnteam = self.pers["team"];
	if ( game["switchedsides"] )
		spawnteam = getOtherTeam( spawnteam );

	if ( level.useStartSpawns )
	{
		if (spawnteam == "axis")
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_axis_start);
		else
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_allies_start);
	}
	else
	{
		if (spawnteam == "axis")
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(level.spawn_axis);
		else
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(level.spawn_allies);
	}

	if ( game["tiebreaker"] )
	{
		self thread maps\mp\gametypes\_hud_message::oldNotifyMessage( &"MP_TIE_BREAKER", &"MP_NO_RESPAWN", undefined, (1, 0, 0), "mp_last_stand" );

		hintMessage = maps\mp\gametypes\_globallogic::getObjectiveHintText( self.pers["team"] );
		if ( isDefined( hintMessage ) )
			self thread maps\mp\gametypes\_hud_message::hintMessage( hintMessage );
	}

	assert( isDefined(spawnpoint) );

	self spawn( spawnpoint.origin, spawnpoint.angles );
}


updateGametypeDvars()
{
	level.plantTime = 5;
	level.defuseTime = 5;
	level.bombTimer = 70;
	level.hotPotato = 1;
}


sabotage()
{
	level.bombPlanted = false;
	level.bombExploded = false;

	trigger = getEnt( "sab_bomb_pickup_trig", "targetname" );
	if ( !isDefined( trigger ) )
	{
		error( "No sab_bomb_pickup_trig trigger found in map." );
		return;
	}

	visuals[0] = getEnt( "sab_bomb", "targetname" );
	if ( !isDefined( visuals[0] ) )
	{
		error( "No sab_bomb script_model found in map." );
		return;
	}

	visuals[0] setModel( "prop_suitcase_bomb" );
	level.sabBomb = maps\mp\gametypes\_gameobjects::createCarryObject( "neutral", trigger, visuals, (0,0,32) );
	level.sabBomb maps\mp\gametypes\_gameobjects::allowCarry( "any" );
	level.sabBomb maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_bomb" );
	level.sabBomb maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_bomb" );
	level.sabBomb maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_bomb" );
	level.sabBomb maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_bomb" );
	level.sabBomb maps\mp\gametypes\_gameobjects::setCarryIcon( "hud_suitcase_bomb" );
	level.sabBomb maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	level.sabBomb.objIDPingEnemy = true;
	level.sabBomb.onPickup = ::onPickup;
	level.sabBomb.onDrop = ::onDrop;
	level.sabBomb.allowWeapons = true;
	level.sabBomb.objPoints["allies"].archived = true;
	level.sabBomb.objPoints["axis"].archived = true;
	level.sabBomb.autoResetTime = 60.0;

	if ( !isDefined( getEnt( "sab_bomb_axis", "targetname" ) ) )
	{
		error("No sab_bomb_axis trigger found in map.");
		return;
	}
	if ( !isDefined( getEnt( "sab_bomb_allies", "targetname" ) ) )
	{
		error("No sab_bomb_allies trigger found in map.");
		return;
	}

	if ( game["switchedsides"] )
	{
		level.bombZones["allies"] = createBombZone( "allies", getEnt( "sab_bomb_axis", "targetname" ) );
		level.bombZones["axis"] = createBombZone( "axis", getEnt( "sab_bomb_allies", "targetname" ) );
	}
	else
	{
		level.bombZones["allies"] = createBombZone( "allies", getEnt( "sab_bomb_allies", "targetname" ) );
		level.bombZones["axis"] = createBombZone( "axis", getEnt( "sab_bomb_axis", "targetname" ) );
	}
}


createBombZone( team, trigger )
{
	visuals = getEntArray( trigger.target, "targetname" );

	bombZone = maps\mp\gametypes\_gameobjects::createUseObject( team, trigger, visuals, (0,0,64) );
	bombZone resetBombsite();
	bombZone.onUse = ::onUse;
	bombZone.onBeginUse = ::onBeginUse;
	bombZone.onEndUse = ::onEndUse;
	bombZone.onCantUse = ::onCantUse;
	for ( i = 0; i < visuals.size; i++ )
	{
		if ( isDefined( visuals[i].script_exploder ) )
		{
			bombZone.exploderIndex = visuals[i].script_exploder;
			break;
		}
	}

	return bombZone;
}


onBeginUse( player )
{
	// planted the bomb
	if ( !self maps\mp\gametypes\_gameobjects::isFriendlyTeam( player.pers["team"] ) ) 
	{
			player playSound( "mp_bomb_plant" );

		player.isPlanting = true;
	} else {
		player.isDefusing = true;
	}
}

onEndUse( team, player, result )
{
	if ( !isAlive( player ) )
		return;

	player.isPlanting = false;
	player.isDefusing = false;
}


onPickup( player )
{
	level notify ( "bomb_picked_up" );

	self.autoResetTime = 60.0;

	level.useStartSpawns = false;

	team = player.pers["team"];

	if ( team == "allies" )
		otherTeam = "axis";
	else
		otherTeam = "allies";

	//player iPrintLnBold( &"MP_YOU_HAVE_RECOVERED_THE_BOMB" );
	player playLocalSound( "mp_suitcase_pickup" );
	player logString( "bomb taken" );

	player maps\mp\gametypes\_globallogic::leaderDialogOnPlayer( "obj_destroy", "bomb" );
	excludeList[0] = player;
	maps\mp\gametypes\_globallogic::leaderDialog( "bomb_taken", team, "bomb", excludeList );


	maps\mp\gametypes\_globallogic::leaderDialog( "bomb_lost", otherTeam );
	maps\mp\gametypes\_globallogic::leaderDialog( "obj_defend", otherTeam );
	
	player.isBombCarrier = true;

	// recovered the bomb before abandonment timer elapsed
	if ( team == self maps\mp\gametypes\_gameobjects::getOwnerTeam() )
	{
		printOnTeamArg( &"MP_EXPLOSIVES_RECOVERED_BY", team, player );
		playSoundOnPlayers( game["bomb_recovered_sound"], team );
	}
	else
	{
		printOnTeamArg( &"MP_EXPLOSIVES_RECOVERED_BY", team, player );
		playSoundOnPlayers( game["bomb_recovered_sound"] );
	}

	self maps\mp\gametypes\_gameobjects::setOwnerTeam( team );
	//Kill waypoint is always enabled
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_target" );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_kill" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_defend" );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend" );

	level.bombZones[team] maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
	level.bombZones[otherTeam] maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
}


onDrop( player )
{
	level notify("bomb_dropped");

	if ( !level.bombPlanted )
	{
		if ( isDefined( player ) ) 
		{
			player.isBombCarrier = false;
			printOnTeamArg( &"MP_EXPLOSIVES_DROPPED_BY", self maps\mp\gametypes\_gameobjects::getOwnerTeam(), player );
		}
		playSoundOnPlayers( game["bomb_dropped_sound"], self maps\mp\gametypes\_gameobjects::getOwnerTeam() );
		if ( isDefined( player ) )
			player logString( "bomb dropped" );
		else
			logString( "bomb dropped" );

		thread abandonmentThink( 0.0 );
	}
}


abandonmentThink( delay )
{
	level endon ( "bomb_picked_up" );

	xwait( delay, false );

	if ( isDefined( self.carrier ) )
		return;

	if ( self maps\mp\gametypes\_gameobjects::getOwnerTeam() == "allies" )
		otherTeam = "axis";
	else
		otherTeam = "allies";

	playSoundOnPlayers( game["bomb_dropped_sound"], otherTeam );

	self maps\mp\gametypes\_gameobjects::setOwnerTeam( "neutral" );
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_bomb" );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_bomb" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_bomb" );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_bomb" );

	level.bombZones["allies"] maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
	level.bombZones["axis"] maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
}


onUse( player )
{
	team = player.pers["team"];
	otherTeam = level.otherTeam[team];

	lpselfnum = player getEntityNumber();
	lpGuid = player getGuid();

	// planted the bomb
	if ( !self maps\mp\gametypes\_gameobjects::isFriendlyTeam( player.pers["team"] ) )
	{
		player notify ( "bomb_planted" );
		//This Fixed the HUD bug
		serverShowHUD();
		player playSound( "mp_bomb_plant" );
			
		player logString( "bomb planted" );
		logPrint("BP;" + lpGuid + ";" + lpselfnum + ";" + player.name + "\n");
		
		iPrintLn( &"MP_EXPLOSIVES_PLANTED_BY", player );
		maps\mp\gametypes\_globallogic::leaderDialog( "bomb_planted" );

		maps\mp\gametypes\_globallogic::givePlayerScore( "plant", player );
		player thread [[level.onXPEvent]]( "plant" );
		level thread bombPlanted( self, player.pers["team"] );

		
		level.bombOwner = player;
		level.sabBomb.autoResetTime = undefined;
		level.sabBomb maps\mp\gametypes\_gameobjects::allowCarry( "none" );
		level.sabBomb maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
		level.sabBomb maps\mp\gametypes\_gameobjects::setDropped();


		self setUpForDefusing();
	}
	else // defused the bomb
	{
		player notify ( "bomb_defused" );
		player logString( "bomb defused" );
		logPrint("BD;" + lpGuid + ";" + lpselfnum + ";" + player.name + "\n");
		
		
		iPrintLn( &"MP_EXPLOSIVES_DEFUSED_BY", player );
		maps\mp\gametypes\_globallogic::leaderDialog( "bomb_defused" );

		maps\mp\gametypes\_globallogic::givePlayerScore( "defuse", player );
		player thread [[level.onXPEvent]]( "defuse" );

		level thread bombDefused( self );

		if ( level.inOverTime && isDefined( level.plantingTeamDead ) )
		{
			thread maps\mp\gametypes\_globallogic::endGame( player.pers["team"], game["strings"][level.bombPlantedBy+"_eliminated"] );
			return;
		}

		self resetBombsite();

		level.sabBomb maps\mp\gametypes\_gameobjects::allowCarry( "any" );
		level.sabBomb maps\mp\gametypes\_gameobjects::setPickedUp( player );
	}
}


onCantUse( player )
{
	player iPrintLnBold( &"MP_CANT_PLANT_WITHOUT_BOMB" );
}


bombPlanted( destroyedObj, team )
{
	maps\mp\gametypes\_globallogic::pauseTimer();
	level.bombPlanted = true;
	level.bombPlantedBy = team;
	level.timeLimitOverride = true;
	setDvar( "ui_bomb_timer", 1 );

	// communicate timer information to menus
	setGameEndTime( int( getTime() + (level.bombTimer * 1000) ) );

	destroyedObj.visuals[0] thread maps\mp\gametypes\_globallogic::playTickingSound();

	starttime = gettime();
	bombTimerWait();

	setDvar( "ui_bomb_timer", 0 );
	destroyedObj.visuals[0] maps\mp\gametypes\_globallogic::stopTickingSound();

	if ( !level.bombPlanted )
	{
		if ( level.hotPotato )
		{
			timePassed = (gettime() - starttime) / 1000;
			level.bombTimer -= timePassed;
		}
		return;
	}
	explosionOrigin = level.sabBomb.visuals[0].origin;
	level.bombExploded = true;

	if ( isdefined( level.bombowner ) )
		destroyedObj.visuals[0] radiusDamage( explosionOrigin, 512, 200, 20, level.bombowner );
	else
	destroyedObj.visuals[0] radiusDamage( explosionOrigin, 512, 200, 20 );

	rot = randomfloat(360);
	explosionEffect = spawnFx( level._effect["bombexplosion"], explosionOrigin + (0,0,50), (0,0,1), (cos(rot),sin(rot),0) );
	triggerFx( explosionEffect );

	thread playSoundinSpace( "exp_suitcase_bomb_main", explosionOrigin );

	[[level._setTeamScore]]( team, [[level._getTeamScore]]( team ) + 1 );
	
	thread GiveScorePlayersTeamPlanted(team);
	
	setGameEndTime( 0 );

	xwait( 3.0, false );

	// end the round without resetting the timer
	thread maps\mp\gametypes\_globallogic::endGame( team, game["strings"]["target_destroyed"] );
}

//da ao  time que plantou a bomb X evps
GiveScorePlayersTeamPlanted(team)
{

	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
    
		if(player.pers["team"] != team)
		continue;
	  
		if ( player.pers["team"] == team )
		{
			player GiveEVP(40,100);
		}
	}
}


playSoundinSpace( alias, origin )
{
	org = spawn( "script_origin", origin );
	org.origin = origin;
	org playSound( alias  );
	xwait( 10.0, false ); // MP doesn't have "sounddone" notifies =(
	org delete();
}


bombTimerWait()
{
	level endon("bomb_defused");
	xwait( level.bombTimer, false );
}


resetBombsite()
{
	self maps\mp\gametypes\_gameobjects::allowUse( "enemy" );
	self maps\mp\gametypes\_gameobjects::setUseTime( level.plantTime );
	self maps\mp\gametypes\_gameobjects::setUseText( &"MP_PLANTING_EXPLOSIVE" );
	self maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES" );
	self maps\mp\gametypes\_gameobjects::setKeyObject( level.sabBomb );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_defend" );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_target" );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_target" );
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
	if( level.scr_sab_show_briefcase == 1 )
		self.useWeapon = "briefcase_bomb_mp";
}

setUpForDefusing()
{
	self maps\mp\gametypes\_gameobjects::allowUse( "friendly" );
	self maps\mp\gametypes\_gameobjects::setUseTime( level.defuseTime );
	self maps\mp\gametypes\_gameobjects::setUseText( &"MP_DEFUSING_EXPLOSIVE" );
	self maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
	self maps\mp\gametypes\_gameobjects::setKeyObject( undefined );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_defuse" );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defuse" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_defend" );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_defend" );
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
}


bombDefused( object )
{
	setDvar( "ui_bomb_timer", 0 );
	maps\mp\gametypes\_globallogic::resumeTimer();
	level.bombPlanted = false;
	if ( !level.inOvertime )
		level.timeLimitOverride = false;

	level notify("bomb_defused");
}


onEndGame( winningTeam )
{
	if ( isdefined( winningTeam ) && (winningTeam == "allies" || winningTeam == "axis") )
	{
		thread GiveScorePlayersTeamPlanted(winningTeam);
		
		[[level._setTeamScore]]( winningTeam, [[level._getTeamScore]]( winningTeam ) + 1 );		
	}
}