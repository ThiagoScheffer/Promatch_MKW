#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include promatch\_utils;

main()
{
	if(getdvar("mapname") == "mp_background")
		return;

	if ( !isdefined( game["switchedsides"] ) )
		game["switchedsides"] = false;		
		
	level.scr_dom_flash_on_capture = getdvarx( "scr_dom_flash_on_capture", "int", 1, 0, 2 );
	level.scr_dom_announce_on_capture = getdvarx( "scr_dom_announce_on_capture", "int", 1, 0, 2 );
	level.scr_dom_secured_all_bonus_time = getdvarx( "scr_dom_secured_all_bonus_time", "float", 20, 0, 60 );
	level.scr_dom_flag_capture_time = getdvarx( "scr_dom_flag_capture_time", "float", 10, 5, 60 );

	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 0, 0, 10 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 2, 0, 500 );
	maps\mp\gametypes\_globallogic::registerRoundSwitchDvar( level.gameType, 1, 0, 500 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 0, 0, 5000 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 25, 0, 1440 );

		
	level.teamBased = true;
	level.atualgtype = "dom";
	level.overrideTeamScore = true;
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onRoundSwitch = ::onRoundSwitch;
	
	level.onEndGame = ::onEndGame;
	
	game["dialog"]["gametype"] = gameTypeDialog( "domination" );
	game["dialog"]["offense_obj"] = "capture_objs";
	game["dialog"]["defense_obj"] = "capture_objs";
}


onPrecacheGameType()
{
	precacheShader( "compass_waypoint_captureneutral" );
	precacheShader( "compass_waypoint_capture" );
	precacheShader( "compass_waypoint_defend" );
	precacheShader( "compass_waypoint_captureneutral_a" );
	precacheShader( "compass_waypoint_capture_a" );
	precacheShader( "compass_waypoint_defend_a" );
	precacheShader( "compass_waypoint_captureneutral_b" );
	precacheShader( "compass_waypoint_capture_b" );
	precacheShader( "compass_waypoint_defend_b" );
	precacheShader( "compass_waypoint_captureneutral_c" );
	precacheShader( "compass_waypoint_capture_c" );
	precacheShader( "compass_waypoint_defend_c" );
	precacheShader( "compass_waypoint_captureneutral_d" );
	precacheShader( "compass_waypoint_capture_d" );
	precacheShader( "compass_waypoint_defend_d" );
	precacheShader( "compass_waypoint_captureneutral_e" );
	precacheShader( "compass_waypoint_capture_e" );
	precacheShader( "compass_waypoint_defend_e" );

	precacheShader( "waypoint_captureneutral" );
	precacheShader( "waypoint_capture" );
	precacheShader( "waypoint_defend" );
	precacheShader( "waypoint_captureneutral_a" );
	precacheShader( "waypoint_capture_a" );
	precacheShader( "waypoint_defend_a" );
	precacheShader( "waypoint_captureneutral_b" );
	precacheShader( "waypoint_capture_b" );
	precacheShader( "waypoint_defend_b" );
	precacheShader( "waypoint_captureneutral_c" );
	precacheShader( "waypoint_capture_c" );
	precacheShader( "waypoint_defend_c" );
	precacheShader( "waypoint_captureneutral_d" );
	precacheShader( "waypoint_capture_d" );
	precacheShader( "waypoint_defend_d" );
	precacheShader( "waypoint_captureneutral_e" );
	precacheShader( "waypoint_capture_e" );
	precacheShader( "waypoint_defend_e" );
}


onStartGameType()
{
	maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OBJECTIVES_DOM" );
	maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OBJECTIVES_DOM" );

	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OBJECTIVES_DOM" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OBJECTIVES_DOM" );
	}
	else
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OBJECTIVES_DOM_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OBJECTIVES_DOM_SCORE" );
	}
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"OBJECTIVES_DOM_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"OBJECTIVES_DOM_HINT" );

	setClientNameMode("auto_change");

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_dom_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_dom_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dom_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dom_spawn" );

	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );

	level.spawn_all = getentarray( "mp_dom_spawn", "classname" );
	
	// Check if we should switch spawn points
	if ( game["switchedsides"] ) {
		level.spawn_axis_start = getentarray("mp_dom_spawn_allies_start", "classname" );
		level.spawn_allies_start = getentarray("mp_dom_spawn_axis_start", "classname" );		
	} else {
		level.spawn_axis_start = getentarray("mp_dom_spawn_axis_start", "classname" );
		level.spawn_allies_start = getentarray("mp_dom_spawn_allies_start", "classname" );
	}

	level.startPos["allies"] = level.spawn_allies_start[0].origin;
	level.startPos["axis"] = level.spawn_axis_start[0].origin;

	flagBaseFX = [];
	flagBaseFX["marines"] = "misc/ui_flagbase_silver";
	flagBaseFX["sas"    ] = "misc/ui_flagbase_black";
	flagBaseFX["russian"] = "misc/ui_flagbase_red";
	flagBaseFX["opfor"  ] = "misc/ui_flagbase_gold";

	level.flagBaseFXid[ "allies" ] = loadfx( flagBaseFX[ game[ "allies" ] ] );
	level.flagBaseFXid[ "axis"   ] = loadfx( flagBaseFX[ game[ "axis"   ] ] );

	level.displayRoundEndText = true;

	allowed[0] = "dom";
//	allowed[1] = "hardpoint";
	maps\mp\gametypes\_gameobjects::main(allowed);

	thread domFlags();
	
	//thread EventHud();	
}
//Hud Server Common
EventHud()
{
	position = newHudElem();
	position.x = 10;
	position.y = 135;
	position.horzAlign = "left";//move para laterias
	position.vertAlign = "top";
	position.alignX = "left";//alinhamento font
	position.alignY = "middle";
	position.fontScale = 1.4;
	position.font = "default";
	position.color = (.8, 1, 1);
	position.hidewheninmenu = true;
	position setText( "Evento Ativo" );
}

onSpawnPlayer()
{
	spawnpoint = undefined;

	if ( !level.useStartSpawns )
	{
		flagsOwned = 0;
		enemyFlagsOwned = 0;
		myTeam = self.pers["team"];
		enemyTeam = getOtherTeam( myTeam );
		for ( i = 0; i < level.flags.size; i++ )
		{
			team = level.flags[i] getFlagTeam();
			if ( team == myTeam )
				flagsOwned++;
			else if ( team == enemyTeam )
				enemyFlagsOwned++;
		}

		if ( flagsOwned == level.flags.size )
		{
			// own all flags! pretend we don't own the last one we got, so enemies can spawn there
			enemyBestSpawnFlag = level.bestSpawnFlag[ getOtherTeam( self.pers["team"] ) ];

			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( level.spawn_all, getSpawnsBoundingFlag( enemyBestSpawnFlag ) );
		}
		else if ( flagsOwned > 0 )
		{
			// spawn near any flag we own that's nearish something we can capture
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( level.spawn_all, getBoundaryFlagSpawns( myTeam ) );
		}
		else
		{
			// own no flags!
			bestFlag = undefined;
			if ( enemyFlagsOwned > 0 && enemyFlagsOwned < level.flags.size )
			{
				// there should be an unowned one to use
				bestFlag = getUnownedFlagNearestStart( myTeam );
			}
			if ( !isdefined( bestFlag ) )
			{
				// pretend we still own the last one we lost
				bestFlag = level.bestSpawnFlag[ self.pers["team"] ];
			}
			level.bestSpawnFlag[ self.pers["team"] ] = bestFlag;

			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( level.spawn_all, bestFlag.nearbyspawns );
		}
	}

	if ( !isdefined( spawnpoint ) )
	{
		if (self.pers["team"] == "axis")
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_axis_start);
		else
			spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_allies_start);
	}

	//spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( level.spawn_all );

	assert( isDefined(spawnpoint) );

	self spawn(spawnpoint.origin, spawnpoint.angles);
}


domFlags()
{
	level.lastStatus["allies"] = 0;
	level.lastStatus["axis"] = 0;

	game["flagmodels"] = [];
	game["flagmodels"]["neutral"] = "prop_flag_neutral";

	if ( game["allies"] == "marines" )
		game["flagmodels"]["allies"] = "prop_flag_american";
	else
		game["flagmodels"]["allies"] = "prop_flag_brit";

	if ( game["axis"] == "russian" )
		game["flagmodels"]["axis"] = "prop_flag_russian";
	else
		game["flagmodels"]["axis"] = "prop_flag_opfor";

	precacheModel( game["flagmodels"]["neutral"] );
	precacheModel( game["flagmodels"]["allies"] );
	precacheModel( game["flagmodels"]["axis"] );

	precacheString( &"MP_CAPTURING_FLAG" );
	precacheString( &"MP_LOSING_FLAG" );
	//precacheString( &"MP_LOSING_LAST_FLAG" );
	precacheString( &"MP_DOM_YOUR_FLAG_WAS_CAPTURED" );
	precacheString( &"MP_DOM_ENEMY_FLAG_CAPTURED" );
	precacheString( &"MP_DOM_NEUTRAL_FLAG_CAPTURED" );

	precacheString( &"MP_ENEMY_FLAG_CAPTURED_BY" );
	precacheString( &"MP_NEUTRAL_FLAG_CAPTURED_BY" );
	precacheString( &"MP_FRIENDLY_FLAG_CAPTURED_BY" );

	primaryFlags = getEntArray( "flag_primary", "targetname" );
	secondaryFlags = getEntArray( "flag_secondary", "targetname" );

	if ( (primaryFlags.size + secondaryFlags.size) < 2 )
	{
		printLn( "^1Not enough domination flags found in level!" );
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}

	level.flags = [];
	for ( index = 0; index < primaryFlags.size; index++ )
		level.flags[level.flags.size] = primaryFlags[index];

	for ( index = 0; index < secondaryFlags.size; index++ )
		level.flags[level.flags.size] = secondaryFlags[index];

	level.domFlags = [];
	for ( index = 0; index < level.flags.size; index++ )
	{
		trigger = level.flags[index];
		if ( isDefined( trigger.target ) )
		{
			visuals[0] = getEnt( trigger.target, "targetname" );
		}
		else
		{
			visuals[0] = spawn( "script_model", trigger.origin );
			visuals[0].angles = trigger.angles;
		}

		visuals[0] setModel( game["flagmodels"]["neutral"] );

		domFlag = maps\mp\gametypes\_gameobjects::createUseObject( "neutral", trigger, visuals, (0,0,100) );
		domFlag maps\mp\gametypes\_gameobjects::allowUse( "enemy" );
		domFlag maps\mp\gametypes\_gameobjects::setUseTime( level.scr_dom_flag_capture_time );
		domFlag maps\mp\gametypes\_gameobjects::setUseText( &"MP_CAPTURING_FLAG" );
		label = domFlag maps\mp\gametypes\_gameobjects::getLabel();
		domFlag.label = label;
		domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_defend" + label );
		domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend" + label );
		domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_captureneutral" + label );
		domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_captureneutral" + label );
		domFlag maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
		
		domFlag.onUse = ::onUse;
		domFlag.onBeginUse = ::onBeginUse;
		domFlag.onUseUpdate = ::onUseUpdate;
		domFlag.onEndUse = ::onEndUse;


		traceStart = visuals[0].origin + (0,0,32);
		traceEnd = visuals[0].origin + (0,0,-32);
		trace = bulletTrace( traceStart, traceEnd, false, undefined );

		upangles = vectorToAngles( trace["normal"] );
		domFlag.baseeffectforward = anglesToForward( upangles );
		domFlag.baseeffectright = anglesToRight( upangles );

		domFlag.baseeffectpos = trace["position"];

//		makeDvarServerInfo( "scr_obj" + label, "neutral" );
//		makeDvarServerInfo( "scr_obj" + label + "_flash", 0 );
//		setDvar( "scr_obj" + label, "neutral" );
//		setDvar( "scr_obj" + label + "_flash", 0 );

		// legacy spawn code support
		level.flags[index].useObj = domFlag;
		level.flags[index].adjflags = [];
		level.flags[index].nearbyspawns = [];

		domFlag.levelFlag = level.flags[index];

		level.domFlags[level.domFlags.size] = domFlag;
	}

	thread promatch\_readyupperiod::notifyObjectiveCreated();
	
	thread updateDomScores();

	// level.bestSpawnFlag is used as a last resort when the enemy holds all flags.
	level.bestSpawnFlag = [];
	level.bestSpawnFlag[ "allies" ] = getUnownedFlagNearestStart( "allies", undefined );
	level.bestSpawnFlag[ "axis" ] = getUnownedFlagNearestStart( "axis", level.bestSpawnFlag[ "allies" ] );

	flagSetup();

//	setDvar( level.scoreLimitDvar, level.domFlags.size );
}

getUnownedFlagNearestStart( team, excludeFlag )
{
	best = undefined;
	bestdistsq = undefined;
	for ( i = 0; i < level.flags.size; i++ )
	{
		flag = level.flags[i];

		if ( flag getFlagTeam() != "neutral" )
			continue;

		distsq = distanceSquared( flag.origin, level.startPos[team] );
		if ( (!isDefined( excludeFlag ) || flag != excludeFlag) && (!isdefined( best ) || distsq < bestdistsq) )
		{
			bestdistsq = distsq;
			best = flag;
		}
	}
	return best;
}


onBeginUse( player )
{
	// o status da flag ownerTeam = qual time dono da flag
	ownerTeam = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
	setDvar( "scr_obj" + self maps\mp\gametypes\_gameobjects::getLabel() + "_flash", 1 );
	self.didStatusNotify = false;
	
	player thread antinades();
	
	if ( ownerTeam == "neutral" )
	{
		//statusDialog( "securing"+self.label, player.pers["team"] );

		// [0.0.1] See what kind of flashing we should do according to the dvar
		switch ( level.scr_dom_flash_on_capture ) 
		{
			case 1:
				self.objPoints[player.pers["team"]] thread maps\mp\gametypes\_objpoints::startFlashing();
				break;
			case 2:
				self.objPoints["allies"] thread maps\mp\gametypes\_objpoints::startFlashing();
				self.objPoints["axis"] thread maps\mp\gametypes\_objpoints::startFlashing();
				break;
		}
		// [0.0.1]
		return;
	}

	if ( ownerTeam == "allies" )
		otherTeam = "axis";
	else
		otherTeam = "allies";

	// [0.0.1] See what kind of flashing we should do according to the dvar
	switch ( level.scr_dom_flash_on_capture ) 
	{
		case 1:
			self.objPoints[player.pers["team"]] thread maps\mp\gametypes\_objpoints::startFlashing();
			break;
		case 2:
			self.objPoints["allies"] thread maps\mp\gametypes\_objpoints::startFlashing();
			self.objPoints["axis"] thread maps\mp\gametypes\_objpoints::startFlashing();
			break;
	}
}



onUseUpdate( team, progress, change )
{
	if ( progress > 0.05 && change && !self.didStatusNotify )
	{
		ownerTeam = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
		if ( ownerTeam == "neutral" )
		{
			// [0.0.1] See what kind of announcement we should do according to the dvar
			switch ( level.scr_dom_announce_on_capture ) {
				case 1:
					statusDialog( "securing"+self.label, team );
					break;
				case 2:
					if ( team == "allies" )
						otherTeam = "axis";
					else
						otherTeam = "allies";

					//should we announce a team they are "losing" a neutral flag?
					//statusDialog( "losing"+self.label, otherTeam );
					statusDialog( "securing"+self.label, team );
					break;
			}
			// [0.0.1]
		}
		else
		{
			// [0.0.1] See what kind of announcement we should do according to the dvar
			switch ( level.scr_dom_announce_on_capture ) {
				case 1:
					statusDialog( "securing"+self.label, team );
					break;
				case 2:
					statusDialog( "losing"+self.label, ownerTeam );
					statusDialog( "securing"+self.label, team );
					break;
			}
			// [0.0.1]
		}

		self.didStatusNotify = true;
	}
}


statusDialog( dialog, team )
{
	time = getTime();
	if ( getTime() < level.lastStatus[team] + 6000 )
		return;

	thread delayedLeaderDialog( dialog, team );
	level.lastStatus[team] = getTime();
}


onEndUse( team, player, success )
{
	setDvar( "scr_obj" + self maps\mp\gametypes\_gameobjects::getLabel() + "_flash", 0 );

	self.objPoints["allies"] thread maps\mp\gametypes\_objpoints::stopFlashing();
	self.objPoints["axis"] thread maps\mp\gametypes\_objpoints::stopFlashing();
}


resetFlagBaseEffect()
{
	if ( isdefined( self.baseeffect ) )
		self.baseeffect delete();

	team = self maps\mp\gametypes\_gameobjects::getOwnerTeam();

	if ( team != "axis" && team != "allies" )
		return;

	fxid = level.flagBaseFXid[ team ];

	self.baseeffect = spawnFx( fxid, self.baseeffectpos, self.baseeffectforward, self.baseeffectright );
	triggerFx( self.baseeffect );
}

onUse( player )
{
	team = player.pers["team"];
	oldTeam = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
	label = self maps\mp\gametypes\_gameobjects::getLabel();

	player logString( "flag captured: " + self.label );

	self maps\mp\gametypes\_gameobjects::setOwnerTeam( team );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_capture" + label );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_capture" + label );
	self.visuals[0] setModel( game["flagmodels"][team] );
	setDvar( "scr_obj" + self maps\mp\gametypes\_gameobjects::getLabel(), team );

	self resetFlagBaseEffect();

	level.useStartSpawns = false;

	assert( team != "neutral" );

	if ( oldTeam == "neutral" )
	{
		otherTeam = getOtherTeam( team );
		thread printAndSoundOnEveryone( team, otherTeam, &"MP_NEUTRAL_FLAG_CAPTURED_BY", &"MP_NEUTRAL_FLAG_CAPTURED_BY", "mp_war_objective_taken", undefined, player );

		statusDialog( "secured"+self.label, team );
		statusDialog( "enemy_has"+self.label, otherTeam );
	}
	else
	{
		thread printAndSoundOnEveryone( team, oldTeam, &"MP_ENEMY_FLAG_CAPTURED_BY", &"MP_FRIENDLY_FLAG_CAPTURED_BY", "mp_war_objective_taken", "mp_war_objective_lost", player );

//		thread delayedLeaderDialogBothTeams( "obj_lost", oldTeam, "obj_taken", team );

		if ( getTeamFlagCount( team ) == level.flags.size )
		{
			statusDialog( "secure_all", team );
			statusDialog( "lost_all", oldTeam );
		}
		else
		{
			statusDialog( "secured"+self.label, team );
			statusDialog( "lost"+self.label, oldTeam );
		}

		level.bestSpawnFlag[ oldTeam ] = self.levelFlag;
	}

	if ( getTeamFlagCount( team ) == level.flags.size ) {
		if ( level.scr_dom_secured_all_bonus_time > 0 ) {
			level.securedAllTeam = team;
			level.securedAllBonusTime = promatch\_timer::getTimePassed() + level.scr_dom_secured_all_bonus_time * 1000;
		}
	} else {
		level.securedAllTeam = undefined;
		level.securedAllBonusTime = undefined;
	}

	thread giveFlagCaptureXP( self.touchList[team] );
}
//apenas apos ser capturado
giveFlagCaptureXP( touchList )
{
	wait level.oneFrame;
	maps\mp\gametypes\_globallogic::WaitTillSlowProcessAllowed();
	
	players = getArrayKeys( touchList );
	
	for ( index = 0; index < players.size; index++ )
	{
		if(!isdefined(touchList[players[index]].player.domfarm))
		{
			touchList[players[index]].player thread antifarm();	
				
			touchList[players[index]].player thread [[level.onXPEvent]]( "capture" );
			maps\mp\gametypes\_globallogic::givePlayerScore( "capture", touchList[players[index]].player );
			evpx = players.size * 50;//qnto mais jogadores mais pontos
			touchList[players[index]].player GiveEVP(evpx,100);	
			//iprintln("capturando?: " + evpx);			
		}
	}
}

antinades()
{
	self endon("disconnect");
	
	self notify( "antinades" );
	self endon( "antinades" );	
	
	if(!isDefined(self.upgradecapturenaderesist))
	{
		self logerror("upgradecapturenaderesist -> player: " + self.name + "ndefinido");
		return;
	}
	//self iprintln("capturando?");
	if(self.upgradecapturenaderesist > 0)
	self.nadeimmune = true;
	
	xwait (12,false );
	//self iprintln("capturando? fim");
	self.nadeimmune = false;
}

antifarm()
{
	self endon("disconnect");
	self notify( "antifarmdom" );
	self endon( "antifarmdom" );
		
	self.domfarm = true;
	
	endTime = GetTime() + 8000; 
	
	while ( endTime > GetTime() )
		xwait (1,false );
	
	self.domfarm = undefined;

}

delayedLeaderDialog( sound, team )
{
	xwait(0.1,false);
	maps\mp\gametypes\_globallogic::WaitTillSlowProcessAllowed();

	maps\mp\gametypes\_globallogic::leaderDialog( sound, team );
}

delayedLeaderDialogBothTeams( sound1, team1, sound2, team2 )
{
	xwait(0.1,false);
	maps\mp\gametypes\_globallogic::WaitTillSlowProcessAllowed();

	maps\mp\gametypes\_globallogic::leaderDialogBothTeams( sound1, team1, sound2, team2 );
}


updateDomScores()
{
	// disable score limit check to allow both axis and allies score to be processed
	level.endGameOnScoreLimit = false;

	while ( !level.gameEnded )
	{

		numFlags = getTeamFlagCount( "allies" );
		if ( numFlags )
			[[level._setTeamScore]]( "allies", [[level._getTeamScore]]( "allies" ) + numFlags );

		numFlags = getTeamFlagCount( "axis" );
		if ( numFlags )
			[[level._setTeamScore]]( "axis", [[level._getTeamScore]]( "axis" ) + numFlags );

		// Check if we need to give bonus points for securing all the flags
		if ( isDefined( level.securedAllBonusTime ) && level.securedAllBonusTime <= promatch\_timer::getTimePassed() ) {
			numFlagsBonus = getTeamFlagCount( level.securedAllTeam ) * 5;
			[[level._setTeamScore]]( level.securedAllTeam, [[level._getTeamScore]]( level.securedAllTeam ) + numFlagsBonus );
			level.securedAllBonusTime = promatch\_timer::getTimePassed() + level.scr_dom_secured_all_bonus_time * 1000;
		}

		level.endGameOnScoreLimit = true;
		maps\mp\gametypes\_globallogic::checkScoreLimit();
		level.endGameOnScoreLimit = false;
		xwait(5.0,false);
	}
}


onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	if ( self.touchTriggers.size && isPlayer( attacker ) && attacker.pers["team"] != self.pers["team"] )
	{
		triggerIds = getArrayKeys( self.touchTriggers );
		ownerTeam = self.touchTriggers[triggerIds[0]].useObj.ownerTeam;
		team = self.pers["team"];

		if ( team == ownerTeam )
		{
			attacker thread [[level.onXPEvent]]( "assault" );
			maps\mp\gametypes\_globallogic::givePlayerScore( "assault", attacker );
			attacker GiveEVP(10,50);
		}
		else
		{
			attacker thread [[level.onXPEvent]]( "defend" );
			maps\mp\gametypes\_globallogic::givePlayerScore( "defend", attacker );
			attacker GiveEVP(10,50);
		}
	}
	
	//reseta
	self.nadeimmune = false;
}



getTeamFlagCount( team )
{
	score = 0;
	for (i = 0; i < level.flags.size; i++)
	{
		if ( level.domFlags[i] maps\mp\gametypes\_gameobjects::getOwnerTeam() == team )
			score++;
	}
	return score;
}

getFlagTeam()
{
	return self.useObj maps\mp\gametypes\_gameobjects::getOwnerTeam();
}

getBoundaryFlags()
{
	// get all flags which are adjacent to flags that aren't owned by the same team
	bflags = [];
	for (i = 0; i < level.flags.size; i++)
	{
		for (j = 0; j < level.flags[i].adjflags.size; j++)
		{
			if (level.flags[i].useObj maps\mp\gametypes\_gameobjects::getOwnerTeam() != level.flags[i].adjflags[j].useObj maps\mp\gametypes\_gameobjects::getOwnerTeam() )
			{
				bflags[bflags.size] = level.flags[i];
				break;
			}
		}
	}

	return bflags;
}

getBoundaryFlagSpawns(team)
{
	spawns = [];

	bflags = getBoundaryFlags();
	for (i = 0; i < bflags.size; i++)
	{
		if (isdefined(team) && bflags[i] getFlagTeam() != team)
			continue;

		for (j = 0; j < bflags[i].nearbyspawns.size; j++)
			spawns[spawns.size] = bflags[i].nearbyspawns[j];
	}

	return spawns;
}

getSpawnsBoundingFlag( avoidflag )
{
	spawns = [];

	for (i = 0; i < level.flags.size; i++)
	{
		flag = level.flags[i];
		if ( flag == avoidflag )
			continue;

		isbounding = false;
		for (j = 0; j < flag.adjflags.size; j++)
		{
			if ( flag.adjflags[j] == avoidflag )
			{
				isbounding = true;
				break;
			}
		}

		if ( !isbounding )
			continue;

		for (j = 0; j < flag.nearbyspawns.size; j++)
			spawns[spawns.size] = flag.nearbyspawns[j];
	}

	return spawns;
}

// gets an array of all spawnpoints which are near flags that are
// owned by the given team, or that are adjacent to flags owned by the given team.
getOwnedAndBoundingFlagSpawns(team)
{
	spawns = [];

	for (i = 0; i < level.flags.size; i++)
	{
		if ( level.flags[i] getFlagTeam() == team )
		{
			// add spawns near this flag
			for (s = 0; s < level.flags[i].nearbyspawns.size; s++)
				spawns[spawns.size] = level.flags[i].nearbyspawns[s];
		}
		else
		{
			for (j = 0; j < level.flags[i].adjflags.size; j++)
			{
				if ( level.flags[i].adjflags[j] getFlagTeam() == team )
				{
					// add spawns near this flag
					for (s = 0; s < level.flags[i].nearbyspawns.size; s++)
						spawns[spawns.size] = level.flags[i].nearbyspawns[s];
					break;
				}
			}
		}
	}

	return spawns;
}

onEndGame( winningTeam )
{
	//if ( isdefined( winningTeam ) && (winningTeam == "allies" || winningTeam == "axis") )
	//{
	//	thread GiveScorePlayersTeamEVP(winningTeam);
	//}
}

//da ao  time X evps
GiveScorePlayersTeamEVP(team)
{
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
    
		if(!isDefined(player))
		continue;
		
		if(player.pers["team"] != team)
		continue;
		
		if(!isDefined(player.score))
		continue;
	  
		if(player.score < 2700)
		continue;
		
		player GiveEVP(500,100);
				
	}
}

// gets an array of all spawnpoints which are near flags that are
// owned by the given team
getOwnedFlagSpawns(team)
{
	spawns = [];

	for (i = 0; i < level.flags.size; i++)
	{
		if ( level.flags[i] getFlagTeam() == team )
		{
			// add spawns near this flag
			for (s = 0; s < level.flags[i].nearbyspawns.size; s++)
				spawns[spawns.size] = level.flags[i].nearbyspawns[s];
		}
	}

	return spawns;
}

flagSetup()
{
	maperrors = [];
	descriptorsByLinkname = [];

	// (find each flag_descriptor object)
	descriptors = getentarray("flag_descriptor", "targetname");

	flags = level.flags;

	for (i = 0; i < level.domFlags.size; i++)
	{
		closestdist = undefined;
		closestdesc = undefined;
		for (j = 0; j < descriptors.size; j++)
		{
			dist = distance(flags[i].origin, descriptors[j].origin);
			if (!isdefined(closestdist) || dist < closestdist) {
				closestdist = dist;
				closestdesc = descriptors[j];
			}
		}

		if (!isdefined(closestdesc)) {
			maperrors[maperrors.size] = "there is no flag_descriptor in the map! see explanation in dom.gsc";
			break;
		}
		if (isdefined(closestdesc.flag)) {
			maperrors[maperrors.size] = "flag_descriptor with script_linkname \"" + closestdesc.script_linkname + "\" is nearby more than one flag; is there a unique descriptor near each flag?";
			continue;
		}
		flags[i].descriptor = closestdesc;
		closestdesc.flag = flags[i];
		descriptorsByLinkname[closestdesc.script_linkname] = closestdesc;
	}

	if (maperrors.size == 0)
	{
		// find adjacent flags
		for (i = 0; i < flags.size; i++)
		{
			if (isdefined(flags[i].descriptor.script_linkto))
				adjdescs = strtok(flags[i].descriptor.script_linkto, " ");
			else
				adjdescs = [];
			for (j = 0; j < adjdescs.size; j++)
			{
				otherdesc = descriptorsByLinkname[adjdescs[j]];
				if (!isdefined(otherdesc) || otherdesc.targetname != "flag_descriptor") {
					maperrors[maperrors.size] = "flag_descriptor with script_linkname \"" + flags[i].descriptor.script_linkname + "\" linked to \"" + adjdescs[j] + "\" which does not exist as a script_linkname of any other entity with a targetname of flag_descriptor (or, if it does, that flag_descriptor has not been assigned to a flag)";
					continue;
				}
				adjflag = otherdesc.flag;
				if (adjflag == flags[i]) {
					maperrors[maperrors.size] = "flag_descriptor with script_linkname \"" + flags[i].descriptor.script_linkname + "\" linked to itself";
					continue;
				}
				flags[i].adjflags[flags[i].adjflags.size] = adjflag;
			}
		}
	}

	// assign each spawnpoint to nearest flag
	spawnpoints = getentarray("mp_dom_spawn", "classname");
	for (i = 0; i < spawnpoints.size; i++)
	{
		if (isdefined(spawnpoints[i].script_linkto)) {
			desc = descriptorsByLinkname[spawnpoints[i].script_linkto];
			if (!isdefined(desc) || desc.targetname != "flag_descriptor") {
				maperrors[maperrors.size] = "Spawnpoint at " + spawnpoints[i].origin + "\" linked to \"" + spawnpoints[i].script_linkto + "\" which does not exist as a script_linkname of any entity with a targetname of flag_descriptor (or, if it does, that flag_descriptor has not been assigned to a flag)";
				continue;
			}
			nearestflag = desc.flag;
		}
		else {
			nearestflag = undefined;
			nearestdist = undefined;
			for (j = 0; j < flags.size; j++)
			{
				dist = distancesquared(flags[j].origin, spawnpoints[i].origin);
				if (!isdefined(nearestflag) || dist < nearestdist)
				{
					nearestflag = flags[j];
					nearestdist = dist;
				}
			}
		}
		nearestflag.nearbyspawns[nearestflag.nearbyspawns.size] = spawnpoints[i];
	}

	if (maperrors.size > 0)
	{
		println("^1------------ Map Errors ------------");
		for(i = 0; i < maperrors.size; i++)
			println(maperrors[i]);
		println("^1------------------------------------");

		maps\mp\_utility::error("Map errors. See above");
		maps\mp\gametypes\_callbacksetup::AbortLevel();

		return;
	}
}

onRoundSwitch()
{
	// Just change the value for the variable controlling which map assets will be assigned to each team
	level.halftimeType = "halftime";
	game["switchedsides"] = !game["switchedsides"];
}