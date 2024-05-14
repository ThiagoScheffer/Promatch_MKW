#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include promatch\_utils;


main()
{
	if(getdvar("mapname") == "mp_background")
	return;

	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();
	//SET VARIABLES SD
	level.scr_sd_sdmode = getdvarx( "scr_sd_sdmode", "int", 0, 0, 1  );
	level.scr_sd_scoreboard_bomb_carrier = getdvarx( "scr_sd_scoreboard_bomb_carrier", "int", 0, 0, 1 );
	level.scr_sd_bomb_notification_enable = getdvarx( "scr_sd_bomb_notification_enable", "int", 1, 0, 1 );
	level.scr_sd_planting_sound = getdvarx( "scr_sd_planting_sound", "int", 1, 0, 1 );
	level.scr_sd_show_briefcase = getdvarx( "scr_sd_show_briefcase", "int", 0, 0, 1 );
	level.scr_sd_bombtimer_show = getdvarx( "scr_sd_bombtimer_show", "int", 1, 0, 1 );
	level.scr_sd_defenders_show_both = getdvarx( "scr_sd_defenders_show_both", "int", 0, 0, 1 );
	level.multiBomb = 0;
	
	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 1, 0, 1 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 28, 0, 30 );
	maps\mp\gametypes\_globallogic::registerRoundSwitchDvar( level.gameType, 7, 0, 30 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 14, 0, 5000 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 2.20, 0, 1440 );

	level.roundswitch = 7;
	level.roundLimit = 28;
	level.scorelimit = 14;
		
	level.teamBased = true;
	level.overrideTeamScore = true;
	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onDeadEvent = ::onDeadEvent;
	//level.onOneLeftEvent = ::onOneLeftEvent;
	level.onTimeLimit = ::onTimeLimit;
	level.onRoundSwitch = ::onRoundSwitch;
	level.getTeamKillPenalty = ::sd_getTeamKillPenalty;
	level.getTeamKillScore = ::sd_getTeamKillScore;	
	level.endGameOnScoreLimit = false;
	
	level.bomborigin = undefined;
	level.droppedbomborigin = undefined;
	
	//votemenu playerInitVote
	level.bombplantedmsg = [];	
	// Add no custom reason option
	level.bombplantedmsg[0] = "Depositando a feh em Alah...";
	level.bombplantedmsg[1] = "Um homem de saco vazio nao quer guerra com ninguem. Papai Noel 2077";	
	level.bombplantedmsg[2] = "Voce sabe quantos meses o Wolfzz trabalhou para comer um prato hj?";	
	level.bombplantedmsg[3] = "A gente fica muito indefeso com uma pessoa lambendo nosso cu.";
	level.bombplantedmsg[4] = "Ligando pro Lula...";	
	level.bombplantedmsg[5] = "Pesquisando um novo Crush...";
	level.bombplantedmsg[6] = "Se homem nao comesse mulher feia, muitos de nos nao estariam vivos";
	level.bombplantedmsg[7] = "Digitando algo sem sentido...";
	level.bombplantedmsg[8] = "Eu vou desestalar e estalar de novo";
	level.bombplantedmsg[9] = "Eu passaria manteiga no cu para os cachorros lamberem....";	
	level.bombplantedmsg[10] = "Ta todo mundo sem dente- feio- camisa do flamengo- por isso q a porrada sobrou";
	level.bombplantedmsg[11] = "Dando para o cavalo...";
	level.bombplantedmsg[12] = "So tem aids quem faz exame, eu nao fiz exame.";
	level.bombplantedmsg[13] = "Se a galil fosse boa igual ao ^2OX^7, eu engravidaria ela - ^2Snipershot";	
	
	level.bombdefusedmsg = [];	
	level.bombdefusedmsg[0] = "Do mesmo jeito que largo minha filha pra usar droga, nego larga a familia pra beber";
	level.bombdefusedmsg[1] = "Quando eu morrer quero um bocado de rapariga no meu enterro";	
	level.bombdefusedmsg[2] = "Eu nao me importo q falem mal d mim pelas costas, porque atras d um portao qualquer cachorro late";	
	level.bombdefusedmsg[3] = "Sacanagen eh deixar o haya jogar sem um cuidador ao lado!";
	level.bombdefusedmsg[4] = "Se for cagar nao limpe, voce eh sujo mesmo.";	
	level.bombdefusedmsg[5] = "enfiou a camisa do Brasil na bunda";
	level.bombdefusedmsg[6] = "Macho que nao consegue nem confiar na propria mulher, esse sim... eh gado demais.";
	level.bombdefusedmsg[7] = "Antigamente quando eu trabalhava com que eu trabalho";
	level.bombdefusedmsg[8] = "Quem ignora buraco eh prefeitura - Raparigueiro";
	level.bombdefusedmsg[9] = "^2Uber^7 quando senta no vaso a agua que entra na bunda - ^2Snipershot";
	level.bombdefusedmsg[10] = "Se a galil fosse boa igual ao ^2OX^7, eu engravidaria ela - ^2Snipershot";
	
	/*SUAVE NA NAVE, DE BOA NA LAGOA, 
	TRANQUILO COMO UM GRILO, 
	FIRMÃO NO BUSÃO, DE LEVE NA NEVE, BELEZA NA REPRESA, MANSO NO BALANÇO, NA MORAL NO MATAGAL, LEGAL NO BANANAL, FIRMOSE NA APOTEOSE, 
	TUDO EM CIMA NA PISCINA,
	TUDO CERTO NO DESERTO, 
	SÓ NO SOSSEGO DO MORCEGO, RELAX NO DUREX, JÓIA NA JIBÓIA?
	*/
}


onPrecacheGameType()
{
	game["bomb_dropped_sound"] = "mp_war_objective_lost";
	game["bomb_recovered_sound"] = "mp_war_objective_taken";


	precacheShader("waypoint_bomb");
	precacheShader("hud_suitcase_bomb");
	precacheShader("waypoint_target");
	precacheShader("waypoint_target_a");
	precacheShader("waypoint_target_b");
	precacheShader("waypoint_defend");
	precacheShader("waypoint_defend_a");
	precacheShader("waypoint_defend_b");
	precacheShader("waypoint_defuse");
	precacheShader("waypoint_defuse_a");
	precacheShader("waypoint_defuse_b");
	precacheShader("compass_waypoint_target");
	precacheShader("compass_waypoint_target_a");
	precacheShader("compass_waypoint_target_b");
	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_defend_a");
	precacheShader("compass_waypoint_defend_b");
	precacheShader("compass_waypoint_defuse");
	precacheShader("compass_waypoint_defuse_a");
	precacheShader("compass_waypoint_defuse_b");
	precacheShader("compass_waypoint_bomb");
	precacheString( &"MP_EXPLOSIVES_RECOVERED_BY" );
	precacheString( &"MP_EXPLOSIVES_DROPPED_BY" );
	precacheString( &"MP_EXPLOSIVES_PLANTED_BY" );
	precacheString( &"MP_EXPLOSIVES_DEFUSED_BY" );
	precacheString( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES" );
	precacheString( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
	precacheString( &"MP_CANT_PLANT_WITHOUT_BOMB" );

	precacheModel( "prop_suitcase_bomb" );
}

sd_getTeamKillPenalty( eInflictor, attacker, sMeansOfDeath, sWeapon )
{
	teamkill_penalty = maps\mp\gametypes\_globallogic::default_getTeamKillPenalty( eInflictor, attacker, sMeansOfDeath, sWeapon );

	if ( ( isdefined( self.isDefusing ) && self.isDefusing ) || ( isdefined( self.isPlanting ) && self.isPlanting ) )
	{
		teamkill_penalty = teamkill_penalty * level.teamKillPenaltyMultiplier;
	}
	
	return teamkill_penalty;
}

sd_getTeamKillScore( eInflictor, attacker, sMeansOfDeath, sWeapon )
{
	teamkill_score = maps\mp\gametypes\_rank::getScoreInfoValue( "teamkill" );
	
	if ( ( isdefined( self.isDefusing ) && self.isDefusing ) || ( isdefined( self.isPlanting ) && self.isPlanting ) )
	{
		teamkill_score = teamkill_score * level.teamKillScoreMultiplier;
	}
	
	return int(teamkill_score);
}

onRoundSwitch()
{
	if ( !isdefined( game["switchedsides"] ) )
		game["switchedsides"] = false;

	if(level.players.size >= 8)
	{
		level.multiBomb = 0;
	}
	else
	{
		level.multiBomb = 1;
	}

	if ( game["teamScores"]["allies"] == level.scorelimit - 1 && game["teamScores"]["axis"] == level.scorelimit - 1 )
	{
		// overtime! team that's ahead in kills gets to defend.
		aheadTeam = getBetterTeam();
		if ( aheadTeam != game["defenders"] )
		{
			game["switchedsides"] = !game["switchedsides"];
		}
		else
		{
			level.halftimeSubCaption = "";
		}
		level.halftimeType = "overtime";
	}
	else
	{
		level.halftimeType = "halftime";
		game["switchedsides"] = !game["switchedsides"];
	}
}

getBetterTeam()
{
	kills["allies"] = 0;
	kills["axis"] = 0;
	deaths["allies"] = 0;
	deaths["axis"] = 0;

	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		team = player.pers["team"];
		if ( isDefined( team ) && (team == "allies" || team == "axis") )
		{
			kills[ team ] += player.kills;
			deaths[ team ] += player.deaths;
		}
	}

	if ( kills["allies"] > kills["axis"] )
		return "allies";
	else if ( kills["axis"] > kills["allies"] )
		return "axis";

	// same number of kills

	if ( deaths["allies"] < deaths["axis"] )
		return "allies";
	else if ( deaths["axis"] < deaths["allies"] )
		return "axis";

	// same number of deaths

	if ( randomint(2) == 0 )
		return "allies";
	return "axis";
}

onStartGameType()
{
	if ( !isDefined( game["switchedsides"] ) )
		game["switchedsides"] = false;

	if ( isDefined( game["attackers"] ) && game["attackers"] != "axis" )
	game["attackers"] = "axis";
	
	if (  isDefined( game["defenders"] ) && game["defenders"] != "allies" )
	game["defenders"] = "allies";
	
	if ( game["switchedsides"] )
	{
		oldAttackers = game["attackers"];
		oldDefenders = game["defenders"];
		game["attackers"] = oldDefenders;
		game["defenders"] = oldAttackers;
	}

	setClientNameMode( "manual_change" );

	game["strings"]["target_destroyed"] = &"MP_TARGET_DESTROYED";
	game["strings"]["bomb_defused"] = &"MP_BOMB_DEFUSED";

	precacheString( game["strings"]["target_destroyed"] );
	precacheString( game["strings"]["bomb_defused"] );

	level._effect["bombexplosion"] = loadfx("explosions/tanker_explosion");
	//SET OBJ TEXT
	maps\mp\gametypes\_globallogic::setObjectiveText( game["attackers"], &"OBJECTIVES_SD_ATTACKER" );
	maps\mp\gametypes\_globallogic::setObjectiveText( game["defenders"], &"OBJECTIVES_SD_DEFENDER" );
	maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["attackers"], &"OBJECTIVES_SD_ATTACKER_SCORE" );
	maps\mp\gametypes\_globallogic::setObjectiveScoreText( game["defenders"], &"OBJECTIVES_SD_DEFENDER_SCORE" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( game["attackers"], &"OW_SD_ATTACKER_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( game["defenders"], &"OW_SD_DEFENDER_HINT" );

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
		
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sd_spawn_attacker" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sd_spawn_defender" );

	//moveSpawns("mp_sd_spawn_defender", "593,017,2314,08,-57,875/-442,377,2360,14,-57,875/357,617,2424,06,-57,875/375,418,2182,7,-57,875");
	//moveSpawns("mp_sd_spawn_defender", "0,187,-544,66,7/1,195,-588,59,2");
					
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );

	allowed[0] = "sd";
	allowed[1] = "bombzone";
	allowed[2] = "blocker";
	maps\mp\gametypes\_gameobjects::main(allowed);
	level.displayRoundEndText = true;
	
	thread updateGametypeDvars();

	thread bombs();
	
	//thread AlphaHud();	
}

//Hud Server Common
AlphaHud()
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
	position setText( "^1Update" );
}

onSpawnPlayer()
{
	self.isPlanting = false;
	self.isDefusing = false;
	self.isBombCarrier = false;
	self.didQuickDefuse = false;
	self.canPickupObject = true;
	
	if(self.pers["team"] == game["attackers"])
		spawnPointName = "mp_sd_spawn_attacker";
	else
		spawnPointName = "mp_sd_spawn_defender";

	if ( level.multiBomb && !isDefined( self.carryIcon ) && self.pers["team"] == game["attackers"] && !level.bombPlanted )
	{
		self.carryIcon = createIcon( "hud_suitcase_bomb", 32, 32 );
		self.carryIcon setPoint( "CENTER", "LEFT", 180, 209 );
		self.carryIcon.alpha = 0.75;
		//self setclientdvar("ui_drawbombicon", 1);
	}
	
	//if(self.pers["team"] == game["defenders"])
	//self thread allowDefenderExplosiveDestroy();
	
	spawnPoints = getEntArray( spawnPointName, "classname" );
	assert( spawnPoints.size );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );

	self spawn( spawnpoint.origin, spawnpoint.angles );
	level notify ( "spawned_player" );	
	
}

CountTeamNearBombSite()
{
	teamA = 0;
	
	teamB = 0;
	
	

}

onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	//=== SELF - SEMPRE SERA QUEM MORRER==	
	victim = self;
	
	//jogador comum
/*	if(isPlayer( attacker ) && attacker != self && !isDefined(attacker.squad) && !attacker.isRanked )
	{
		if(!level.bombPlanted && isDefined(victim.isBombCarrier) && victim.isBombCarrier)
		{
		
		
		}
	}*/
	
	//PONTOS DESSE TIPO APENAS EM SQUAD
	if(isPlayer( attacker ) && attacker != self && attacker.isRanked )
	{
		//============[DEFESA]-> mata ATTACKER - PROTEGE O OBJETIVO===============
		if ( attacker.pers["team"] == game["defenders"] ) 
		{
			//iprintln("ATTACKER: " + attacker.name);
			//iprintln("VITIMA: " + self.name);
			
			//DEFENSE MATOU ATTACKER BOMBCARRIER
			if(!level.bombPlanted && isDefined(victim.isBombCarrier) && victim.isBombCarrier)
			{
				//iprintln("self.carryObject: " + self.name);
				//recebe bonus por matar o BC			
				attacker thread [[level.onXPEvent]]( "killcarrier" );
				maps\mp\gametypes\_globallogic::givePlayerScore( "killcarrier", attacker );			
				attacker SetRankPoints(100);
				//vitima perde ponto
				victim thread [[level.onXPEvent]]( "carrierdeath" );
				maps\mp\gametypes\_globallogic::givePlayerScore( "carrierdeath", victim );
				victim SetRankPoints(-100);
			}
			//DEFESA ESTA IMPEDINDO DA BOMB QUE CAIU SER PEGA
			if(isdefined(level.droppedbomborigin))
			{
				//DISTANCIA ENTRE A VITIMA E A BOMB
				distanceToBomber = distance( victim.origin, level.droppedbomborigin);
				//distancia certa 420
				if ( distanceToBomber <= 800 ) 
				{	
					//iprintln("distanceToBomber: " + distanceToBomber + " [QmMorreu] " +self.name +" [QmMatou] " + attacker.name );
				
					//ATTACKER RECEBE BONUS POR IMPEDIR OBJETIVOS
					attacker thread [[level.onXPEvent]]( "defend" );
					maps\mp\gametypes\_globallogic::givePlayerScore( "defend", attacker );
					attacker SetRankPoints(250);
					victim SetRankPoints(-200);
				}	
			}
			//DEFESA ESTA DEFENDENDO QUEM ESTA DEFUSANDO
			if(level.bombPlanted && isdefined(level.bomborigin))
			{
				//DISTANCIA ENTRE A VITIMA E A BOMB
				distanceToBomber = distance( victim.origin, level.bomborigin);
				//distancia certa 420
				if ( distanceToBomber <= 800 ) 
				{	
					//iprintln("distanceToBomber: " + distanceToBomber + " [QmMorreu] " +self.name +" [QmMatou] " + attacker.name );
				
					//ATTACKER RECEBE BONUS POR IMPEDIR OBJETIVOS
					attacker thread [[level.onXPEvent]]( "defend" );
					maps\mp\gametypes\_globallogic::givePlayerScore( "defend", attacker );
					attacker SetRankPoints(250);
					victim SetRankPoints(-200);
				}	
			}
			
			//mudar aqui para que todos que estao perto do bombcarrier percam ponto
			
		}
		
		//============[ATAQUE]-ATTACKER - DEVE EXPLODIR O OBJETIVO===============
		if ( attacker.pers["team"] == game["attackers"] ) 
		{	
			
			//ATTACKER MATOU QUEM ESTAVA PERTO DA BOMB TENTANDO DEFUSAR
			if(level.bombPlanted)
			{
				//DISTANCIA ENTRE A VITIMA E ONDE FOI PLANTADA A BOMB
				distanceToBomber = distance( victim.origin, level.bomborigin);
				//distancia certa 420
				if ( distanceToBomber <= 800 ) 
				{	
					//iprintln("distanceToBomber: " + distanceToBomber + " [QmMorreu] " +self.name +" [QmMatou] " + attacker.name );
				
					//ATTACKER RECEBE BONUS POR DEFENDER A BOMBZONE
					attacker thread [[level.onXPEvent]]( "defend" );
					maps\mp\gametypes\_globallogic::givePlayerScore( "defend", attacker );
					
					//attacker ganha pontos
					attacker SetRankPoints(200);
					victim SetRankPoints(-100);
				}		

				//bomb plantada e defesa ta muito longe da bomb fazendo sei la oq..
				if ( distanceToBomber > 2000)
				{
					victim SetRankPoints(-900);
				}
			}
			//NAO FOI PLANTADA A BOMBA
			if(!level.bombPlanted)
			{
				//ATTACKER DEFENDEU O BOMBCARRIER
				if(isDefined(level.bombcarrier) && isAlive(level.bombcarrier))
				{
					distanceToBomber = distance( victim.origin,level.bombcarrier.origin);
					//distancia certa 420
					if ( distanceToBomber <= 800 ) 
					{	
						//iprintln("distanceToBomber: " + distanceToBomber + " [QmMorreu] " +self.name +" [QmMatou] " + attacker.name );
					
						//ATTACKER RECEBE BONUS POR DEFENDER
						attacker SetRankPoints(100);
						victim SetRankPoints(-100);
						attacker thread [[level.onXPEvent]]( "defend_assist" );
						maps\mp\gametypes\_globallogic::givePlayerScore( "defend_assist", attacker );
					}
				}				
			}
		}		
	}
	
	thread checkAllowSpectating();
}


BombPlantedCheckNearTeam()
{
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		
		//nao me dar ponto novamente!
		if(player == self)
		 continue;
		 
		if(player.pers["team"] != self.pers["team"])
		 continue; 
		 
		 if(!isDefined(player.squad))
		 continue;
		 
		 if(!isAlive(player))
		 continue;
		 
		 distanceToBomber = distance( player.origin, level.bomborigin);
		 
		//todos atttackers que estiverem proximos da bomb na hora de plantada = fazendo objetivos junto!
		if ( player.pers["team"] == game["attackers"] )
		{			
			//quase grudado no jogador - escudo humano !
			if ( distanceToBomber <= 110 )
			{
				player thread [[level.onXPEvent]]( "defend" );				
				player GiveEVP(70,100);
				player SetRankPoints(150);
				
			}
			else if ( distanceToBomber <= 900 ) 
			{
				player thread [[level.onXPEvent]]( "defend" );				
				player GiveEVP(30,100);
				player SetRankPoints(50);
			}		
		}		
		
		if ( player.pers["team"] == game["defenders"] )
		{			
			//quase grudado no jogador - escudo humano !
			if ( distanceToBomber <= 110 )
			{
				player thread [[level.onXPEvent]]( "defend" );				
				player GiveEVP(70,100);
				player SetRankPoints(100);
				
			}
			else if ( distanceToBomber <= 900 ) 
			{
				player thread [[level.onXPEvent]]( "defend" );				
				player GiveEVP(30,100);
				player SetRankPoints(50);
			}		
		}		
	}
}

checkAllowSpectating()
{
	wait level.oneFrame;

	if ( level.bombExploded || level.bombDefused )
	return;

 	update = false;
	if ( !level.aliveCount[ game["attackers"] ] )
	{
		level.spectateOverride[game["attackers"]].allowEnemySpectate = 2;
		update = true;
	} 
	if ( !level.aliveCount[ game["defenders"] ] )
	{
		level.spectateOverride[game["defenders"]].allowEnemySpectate = 2;
		update = true;
	}
	
	if ( update )
		maps\mp\gametypes\_spectating::updateSpectateSettings(); 
}


sd_endGame( winningTeam, endReasonText )
{	
	wait level.oneFrame;
	
	if ( isdefined( winningTeam ) )
	[[level._setTeamScore]]( winningTeam, [[level._getTeamScore]]( winningTeam ) + 1 );
	xwait(0.1,false);//0318 time to update the broad
	thread maps\mp\gametypes\_globallogic::endGame( winningTeam, endReasonText );
}


onDeadEvent( team )
{
	if ( level.bombExploded || level.bombDefused )
	return;

	if ( team == "all" )
	{
		if ( level.bombPlanted )
		sd_endGame( game["attackers"], game["strings"][game["defenders"]+"_eliminated"] );
		else
		sd_endGame( game["defenders"], game["strings"][game["attackers"]+"_eliminated"] );
	}
	else if ( team == game["attackers"] )
	{
		if ( level.bombPlanted )
		{
			level.spectateOverride[game["attackers"]].allowEnemySpectate = 3;
			maps\mp\gametypes\_spectating::updateSpectateSettings();
			//iPrintLnBold( "CheckDead: " + level.aliveCount[ game["attackers"] ] );
			return;
		}
		level thread sd_endGame( game["defenders"], game["strings"][game["attackers"]+"_eliminated"] );
	}
	else if ( team == game["defenders"] )//Morram todos  da defesa
	{
		level thread sd_endGame( game["attackers"], game["strings"][game["defenders"]+"_eliminated"] );
	}
}

onTimeLimit()
{
	if ( level.teamBased )
	sd_endGame( game["defenders"], game["strings"]["time_limit_reached"] );
	else
	sd_endGame( undefined, game["strings"]["time_limit_reached"] );
}

updateGametypeDvars()
{
	if(level.cod_mode == "torneio")
	{
		level.plantTime = 6;
		level.defuseTime = 7;
		level.bombTimer = 48;
	}
	else
	{
		level.plantTime = 6;
		level.defuseTime = 9;
		level.bombTimer = 50;
	}
	
	level.teamKillPenaltyMultiplier = dvarFloatValue( "teamkillpenalty", 2, 0, 10 );
	level.teamKillScoreMultiplier = dvarFloatValue( "teamkillscore", 4, 0, 40 );		
}


bombs()
{
	level.bombPlanted = false;
	level.bombDefused = false;
	level.bombExploded = false;
	level.bombhacked = undefined;//attack
	level.bombunhacked = undefined;//defense

	trigger = getEnt( "sd_bomb_pickup_trig", "targetname" );
	if ( !isDefined( trigger ) )
	{
		maps\mp\_utility::error("No sd_bomb_pickup_trig trigger found in map.");
		return;
	}

	visuals[0] = getEnt( "sd_bomb", "targetname" );//modelo TNT ou MAleta
	if ( !isDefined( visuals[0] ) )
	{
		maps\mp\_utility::error("No sd_bomb script_model found in map.");
		return;
	}

	visuals[0] setModel( "prop_suitcase_bomb" );

	if ( !level.multiBomb )
	{
		level.sdBomb = maps\mp\gametypes\_gameobjects::createCarryObject( game["attackers"], trigger, visuals, (0,0,32) );
		level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry( "friendly" );
		level.sdBomb maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_bomb" );
		level.sdBomb maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_bomb" );
		level.sdBomb maps\mp\gametypes\_gameobjects::setVisibleTeam( "friendly" );
		level.sdBomb maps\mp\gametypes\_gameobjects::setCarryIcon( "hud_suitcase_bomb" );
		level.sdBomb.allowWeapons = true;
		level.sdBomb.onPickup = ::onPickup;
		level.sdBomb.onDrop = ::onDrop;
	}
	else
	{
		trigger delete();
		visuals[0] delete();
	}


	level.bombZones = [];

	bombZones = getEntArray( "bombzone", "targetname" );

	for ( index = 0; index < bombZones.size; index++ )
	{
		trigger = bombZones[index];
		visuals = getEntArray( bombZones[index].target, "targetname" );

		bombZone = maps\mp\gametypes\_gameobjects::createUseObject( game["defenders"], trigger, visuals, (0,0,64) );
		bombZone maps\mp\gametypes\_gameobjects::allowUse( "enemy" );
		bombZone maps\mp\gametypes\_gameobjects::setUseTime( level.plantTime );
		bombZone maps\mp\gametypes\_gameobjects::setUseText( level.bombplantedmsg[randomint(level.bombplantedmsg.size)] );
		bombZone maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES" );
		if ( !level.multiBomb )
		bombZone maps\mp\gametypes\_gameobjects::setKeyObject( level.sdBomb );
	
		label = bombZone maps\mp\gametypes\_gameobjects::getLabel();
		bombZone.label = label;
		bombZone maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_defend" + label );
		bombZone maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend" + label );
		bombZone maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_target" + label );
		bombZone maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_target" + label );
		bombZone maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
		bombZone.onBeginUse = ::onBeginUse;
		bombZone.onEndUse = ::onEndUse;
		bombZone.onUse = ::onUsePlantObject;
		bombZone.onCantUse = ::onCantUse;
		//bombweapon
		//bombZone.useWeapon = "briefcase_bomb_mp";//novo
		for ( i = 0; i < visuals.size; i++ )
		{
			if ( isDefined( visuals[i].script_exploder ) )
			{
				bombZone.exploderIndex = visuals[i].script_exploder;
				break;
			}
		}

		level.bombZones[level.bombZones.size] = bombZone;

		bombZone.bombDefuseTrig = getent( visuals[0].target, "targetname" );
		assert( isdefined( bombZone.bombDefuseTrig ) );
		bombZone.bombDefuseTrig.origin += (0,0,-10000);
		bombZone.bombDefuseTrig.label = label;
	}

	for ( index = 0; index < level.bombZones.size; index++ )
	{
		array = [];
		for ( otherindex = 0; otherindex < level.bombZones.size; otherindex++ )
		{
			if ( otherindex != index )
				array[ array.size ] = level.bombZones[otherindex];
		}
		level.bombZones[index].otherBombZones = array;
	}
	/*
	if(level.bombZones.size == 2)
	{
		if(percentChance(50))
			level.bombZones[0] disableObject();
		else
			level.bombZones[1] disableObject();
	}
	*/
	// End Settings bombsites
	thread promatch\_readyupperiod::notifyObjectiveCreated();
}
//AO APERTAR PARA DEFUSAR 
onBeginUse( player )
{
	//iprintlnbold("begindef: " + player.name);
	if ( self maps\mp\gametypes\_gameobjects::isFriendlyTeam( player.pers["team"] ) )
	{
	
		//contrato
		//iprintln(player.defusekit);
		
		if(player.defusekit > 0)
		level.defuseObject maps\mp\gametypes\_gameobjects::setUseTime( 6 );
		else
		level.defuseObject maps\mp\gametypes\_gameobjects::setUseTime( level.defuseTime );
		
		player.isDefusing = true;		
		
				
		if( !player.incognito )	
			player playSound( "mp_bomb_defuse" );
		

		player thread quickDefuse();// sem a thread nao pega a maleta.
		
		if ( isDefined( level.sdBombModel ) )
		level.sdBombModel hide();
	}
	else
	{
		player.isPlanting = true;	
		
			if( !player.incognito )	
			player playSound( "mp_bomb_plant" );
	
			if(player.upgradecapturenaderesist > 0)
			player.nadeimmune = true;
		

		if ( level.multibomb )
		{
			for ( i = 0; i < self.otherBombZones.size; i++ )
			{
				self.otherBombZones[i] maps\mp\gametypes\_gameobjects::allowUse( "none" );
				self.otherBombZones[i] maps\mp\gametypes\_gameobjects::setVisibleTeam( "friendly" );
			}
		}
	}
}

quickDefuse()
{
  self endon( "disconnect" );
  self endon( "death" );
  
  if ( self.didQuickDefuse )
  	return;
  
  self.isChangingWire = false;
  //self.isTryingQF = false;
  
  if ( isAlive( self ) && self.isDefusing && !level.gameEnded && !level.bombExploded )
  {
    bombwire[0] = "^1Vermelho";
    bombwire[1] = "^2Verde";
    bombwire[2] = "^3Amarelo";
    bombwire[3] = "^5Azul"; 
	bombwire[4] = "^8Preto";
    
    playerChoice = 0;//alterna entras as escolhas
	
    self iprintlnbold( "^1Quick Defuse:^7 Troque os fios apertando: ^2[{+toggleads_throw}]" );
    self iprintlnbold( "Aperte ^2[{+attack}]^7 para cortar o fio." );
    while ( self.isDefusing && isAlive( self ) && !level.gameEnded && !level.bombExploded && !self.didQuickDefuse )
    {		
		//aqui foi cortado
		  if ( self attackButtonPressed() ) 
		  {
				self.didQuickDefuse = true;
				//cada fio tem 25% de chance
				self thread quickDefuseResults();
					
		  } 
		  else if ( self adsButtonPressed() && !self.isChangingWire ) 
		  {
			self.isChangingWire = true;
			self allowAds( false );
			
			
			if ( playerChoice == 5 )
			  playerChoice = 0;
			else
			  playerChoice++;        
			
			if(isdefined(bombwire[playerChoice]))
			self iprintlnbold( bombwire[playerChoice] ); 	
			
			xwait( 0.1,false );
			
			//reseta
			self.isChangingWire = false;
			self allowAds( true );
		  }
		  
		 xwait( 0.05,false );
    }
	
	xwait( 1,false );
  }
}  

quickDefuseResults()
{
  level endon ( "game_ended" );
  
  if(self.defusekit != 0)
  chance = percentChance(25);
  else
  chance = percentChance(10);

  if (chance && isAlive( self ) && !level.gameEnded && !level.bombExploded ) 
  {
	self GiveEVP(100,100);
  	level.defuseObject thread maps\mp\gametypes\sd::onUseDefuseObject( self );	
  } 
  else if (isAlive( self ) && !level.gameEnded && !level.bombExploded ) 
  {	
  	level notify( "wrong_wire" );
  }
  
	if(self.defusekit != 0)
	self setStat(2380,0);
}

onEndUse( team, player, result )
{
	if ( !isDefined( player ) )
	return;
	
	if ( isAlive( player ) )
	{
		player.isDefusing = false;
		player.isPlanting = false;
		player.nadeimmune = false;
	}
	
	if ( self maps\mp\gametypes\_gameobjects::isFriendlyTeam( player.pers["team"] ) )
	{
		if ( isDefined( level.sdBombModel ) && !result )
		{
			level.sdBombModel show();
		}
	}
	else
	{
		if ( level.multibomb && !result )
		{
			for ( i = 0; i < self.otherBombZones.size; i++ )
			{
				self.otherBombZones[i] maps\mp\gametypes\_gameobjects::allowUse( "enemy" );
				self.otherBombZones[i] maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
			}
		}
	}
}

onCantUse( player )
{
	player iPrintLnBold( &"MP_CANT_PLANT_WITHOUT_BOMB" );
}

onUsePlantObject( player )
{
	// planted the bomb
	if ( !self maps\mp\gametypes\_gameobjects::isFriendlyTeam( player.pers["team"] ) )
	{
		level thread bombPlanted( self, player );
		
		player logString( "bomb planted: " + self.label );
		
		// disable all bomb zones except this one
		for ( index = 0; index < level.bombZones.size; index++ )
		{
			if ( level.bombZones[index] == self )
			continue;

			if ( level.scr_sd_sdmode == 0 ) 
			{
				level.bombZones[index] maps\mp\gametypes\_gameobjects::disableObject();
			} else 
			{
				level.bombZones[index] maps\mp\gametypes\_gameobjects::allowUse( "none" );			
			}
		}

		if( !player.incognito)
		player playSound( "mp_bomb_plant" );
	
	
		//This Fixed the HUD bug
		serverShowHUD();
		
		player notify ( "bomb_planted" );
		
		if (!player.incognito )
		iPrintLn( &"MP_EXPLOSIVES_PLANTED_BY", player );

		if(isDefined(player.insidesmoke))
		{
			if(isDefined(player.smokeowner))
			player.smokeowner SetRankPoints(50);
		}
		
		//RANK
		//player SetRankPoints(200);
		
		player thread BombPlantedCheckNearTeam();
		
		if(!player.incognito)
		maps\mp\gametypes\_globallogic::leaderDialog( "bomb_planted" );
		
		//New Codes
		level.bombOwner = player;
		player.bombPlantedTime = getTime();
		//iPrintLn( player.bombPlantedTime );
		maps\mp\gametypes\_globallogic::givePlayerScore( "plant", player );
		
		player statAdds("PLANTED",1);
		
		player GiveEVP(135,100);
		
		player thread [[level.onXPEvent]]("plant");
		
		//removido por agora !
		//thread FindPlayersFarBombPlanted();
	}
}

onUseDefuseObject( player )
{
	if(level.gameEnded||level.bombExploded)return;
	
	wait level.oneFrame;
	player notify ( "bomb_defused" );
	player logString( "bomb defused: " + self.label );
	level thread bombDefused();
	// disable this bomb zone
	self maps\mp\gametypes\_gameobjects::disableObject();
	
	//usou o kitdefuse
	if(player.defusekit != 0)
	player setStat(2380,0);
	
	if(isDefined(player.insidesmoke))
	{
		if(isDefined(player.smokeowner))
		{
			player.smokeowner SetRankPoints(150);
		}
	}
		
	//RANK
	player SetRankPoints(150);
	
	player thread BombPlantedCheckNearTeam();
	
	//tempo = level.bombOwner.bombPlantedTime + 3000 + (level.defuseTime*1000);
	if ( isDefined( level.bombOwner ) && ( level.bombOwner.bombPlantedTime + 6200 +  (level.defuseTime * 1000) ) > getTime()  && isAlive( level.bombOwner ) )
	{		

		level.defuser = player;//can be used to killcam
		if(level.aliveCount["allies"] >= 2 && level.aliveCount["axis"] >= 2)
		{
			player statAdds("DEFUSED",1);
			//player updateclassscore(100 * level.aliveCount["axis"],false);
			maps\mp\gametypes\_globallogic::givePlayerScore( "defuse", player );
			player GiveEVP(120,100);
			level thread playSoundOnEveryone( "mp_challenge_complete" );
			iPrintLn( "^2Defusador Ninja^7 ", player );
			xwait(5,false);
		}
		else
		{
			player statAdds("DEFUSED",1);
			//player updateclassscore(100,false);
			maps\mp\gametypes\_globallogic::givePlayerScore( "defuse", player );
			player GiveEVP(120,100);
			level thread playSoundOnEveryone( "mp_challenge_complete" );
			iPrintLn( "^2Defusador^7 ", player );
			xwait(5,false);
		}
	}
	else 
	{	
		maps\mp\gametypes\_globallogic::leaderDialog( "bomb_defused" );
		
		//if ( !player.incognito)
		iPrintLn( &"MP_EXPLOSIVES_DEFUSED_BY", player );
	
		maps\mp\gametypes\_globallogic::givePlayerScore( "defuse", player );
		player statAdds("DEFUSED",1);
		player GiveEVP(135,100);
		player thread [[level.onXPEvent]]( "defuse" );
	}
}

playSoundOnEveryone( soundName )
{
	level endon( "game_ended" );
	
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		player playLocalSound( soundName );
		player thread maps\mp\gametypes\_hud_message::oldNotifyMessage( "NINJA DEFUSE", level.defuser,undefined, (1, 0, 0), undefined );		
	}	
}

onDrop( player )
{
	if ( !level.bombPlanted )
	{
		if ( isDefined( player ) && isDefined( player.name ) && player.pers["team"] == game["attackers"] ) 
		{
			player.isBombCarrier = false;
			level.droppedbomborigin = player.origin;//salva o local da bomb dropada
			
			if(!level.multiBomb)
			level.bombcarrier = undefined;

			printOnTeamArg( &"MP_EXPLOSIVES_DROPPED_BY", game["attackers"], player );

			if (isAlive( player ) ) 
			{
				player.statusicon = "";
			}
		}
		//if ( isDefined( player ) )
		//player logString( "bomb dropped" );
		//else
		//logString( "bomb dropped" );
	}

	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_bomb" );
	
	if ( isDefined( player ) && player.pers["team"] == game["attackers"] )
	maps\mp\_utility::playSoundOnPlayers( game["bomb_dropped_sound"], game["attackers"] );
	else if ( isDefined( player ) )
	player playSoundToPlayer( game["bomb_dropped_sound"], player );
}


onPickup( player )
{
	
	//JOGADOR MARCADO COMO INUTIL
	if(player statGets("BOTPLAYER") == 1)
	{		
		player iprintlnbold("Voce nao permissao para pegar a bomb!");
		player.carryObject thread maps\mp\gametypes\_gameobjects::setDropped();
		//player thread maps\mp\gametypes\_gameobjects::pickupObjectDelayTime( 3.0 );
		self.canPickupObject = false;
		return;
	}
	
	if( player.pers["team"] == game["defenders"] && !player.upgradebombdisarmer)
	{
		player iprintlnbold("Apenas com upgrade BombHacker!");
		player.carryObject thread maps\mp\gametypes\_gameobjects::setDropped();
		self.canPickupObject = false;
		return;
	}
	
	player.isBombCarrier = true;
	level.droppedbomborigin = undefined;
	
	if(!level.multiBomb)
	level.bombcarrier = player;

	if ( isDefined( player ) && isDefined( player.allowdestroyexplosives ) &&  player.allowdestroyexplosives && player.pers["team"] == game["defenders"]  )
		player iprintlnbold( "^1Destrua esta maleta usando o botao da FACA!" );

	if ( isDefined( player ) && player.pers["team"] == game["attackers"] )
	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend" );

	if ( !level.bombDefused  && isDefined( player ) && player.pers["team"] == game["attackers"] )
	{
		if ( isDefined( player ) && isDefined( player.name ) )
		{
			player playLocalSound( "mp_suitcase_pickup" );			
		}
	
		printOnTeamArg( &"MP_EXPLOSIVES_RECOVERED_BY", game["attackers"], player );		
	}
}


onReset()
{
}


bombPlanted( destroyedObj, player )
{
	maps\mp\gametypes\_globallogic::pauseTimer();
	level.bombPlanted = true;
	
	destroyedObj.visuals[0] thread maps\mp\gametypes\_globallogic::playTickingSound();
	level.tickingObject = destroyedObj.visuals[0];

	level.timeLimitOverride = true;
	setGameEndTime( int( gettime() + (level.bombTimer * 1000) ) );
	setDvar( "ui_bomb_timer", 1 );

	if ( !level.multiBomb )
	{
		level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry( "none" );
		level.sdBomb maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
		level.sdBomb maps\mp\gametypes\_gameobjects::setDropped();
		level.sdBombModel = level.sdBomb.visuals[0];
	}
	else
	{

		for ( index = 0; index < level.players.size; index++ )
		{
			if ( isDefined( level.players[index].carryIcon ) )
			level.players[index].carryIcon destroyElem();
		}

		trace = bulletTrace( player.origin + (0,0,20), player.origin - (0,0,2000), false, player );

		tempAngle = randomfloat( 360 );
		forward = (cos( tempAngle ), sin( tempAngle ), 0);
		forward = vectornormalize( forward - vector_scale( trace["normal"], vectordot( forward, trace["normal"] ) ) );
		dropAngles = vectortoangles( forward );
		
		//cria a imagem da maleta no chao
		level.sdBombModel = spawn( "script_model", trace["position"] );
		level.sdBombModel.angles = dropAngles;
		level.sdBombModel setModel( "prop_suitcase_bomb" );
	}
	
	destroyedObj maps\mp\gametypes\_gameobjects::allowUse( "none" );
	destroyedObj maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );

	
	label = destroyedObj maps\mp\gametypes\_gameobjects::getLabel();

	// create a new object to defuse with.
	trigger = destroyedObj.bombDefuseTrig;
	trigger.origin = level.sdBombModel.origin;
	level.bomborigin = trigger.origin;//local d protecao da bomb
	visuals = [];
	defuseObject = maps\mp\gametypes\_gameobjects::createUseObject( game["defenders"], trigger, visuals, (0,0,32) );
	defuseObject maps\mp\gametypes\_gameobjects::allowUse( "friendly" );
	defuseObject maps\mp\gametypes\_gameobjects::setUseTime( level.defuseTime );
	defuseObject maps\mp\gametypes\_gameobjects::setUseText( level.bombdefusedmsg[randomint(level.bombdefusedmsg.size)] );
	defuseObject maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
	defuseObject maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	defuseObject.label = label;
	defuseObject.onBeginUse = ::onBeginUse;
	defuseObject.onEndUse = ::onEndUse;
	defuseObject.onUse = ::onUseDefuseObject;
	defuseObject maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_defuse" + label );
	defuseObject maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_waypoint_defend" + label );
	defuseObject maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defuse" + label );
	defuseObject maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_defend" + label );
	//defuseObject.useWeapon = "briefcase_bomb_defuse_mp";

	player.isBombCarrier = false;
	
	level.droppedbomborigin = undefined;
	
	if(!level.multiBomb)
	level.bombcarrier = undefined;

	level.defuseObject = defuseObject;

	if(!isDefined(level.bombhacked))
	BombTimerWait();
	
	//reduz para 30s restante da bomba
	if(isDefined(level.bombhacked))
	BombTimerWaitHacked();
	
	if(isDefined(level.bombunhacked))
	BombTimerWaitUnHack();
	
	//RESETA TUDO APARTIR DAQUI
	setDvar( "ui_bomb_timer", 0 );	
	setGameEndTime( 0 );
	
	destroyedObj.visuals[0] maps\mp\gametypes\_globallogic::stopTickingSound();

	if ( level.gameEnded || level.bombDefused )
	return;

	level notify ( "bomb_exploded" );
	
	level.bombExploded = true;
	explosionOrigin = level.sdBombModel.origin;
	level.sdBombModel hide();
	
	if ( isdefined( player ) )
	destroyedObj.visuals[0] radiusDamage( explosionOrigin, 512, 200, 20, player );
	else
	destroyedObj.visuals[0] radiusDamage( explosionOrigin, 512, 200, 20 );

	rot = randomfloat(360);
	explosionEffect = spawnFx( level._effect["bombexplosion"], explosionOrigin + (0,0,50), (0,0,1), (cos(rot),sin(rot),0) );
	triggerFx( explosionEffect );

	PlayRumbleOnPosition( "grenade_rumble", explosionOrigin );
	earthquake( 0.75, 2.0, explosionOrigin, 2000 );
	thread playSoundinSpace( "exp_suitcase_bomb_main", explosionOrigin );

	//if ( isDefined( destroyedObj.exploderIndex ) )
	//exploder( destroyedObj.exploderIndex );

	for ( index = 0; index < level.bombZones.size; index++ )
	level.bombZones[index] maps\mp\gametypes\_gameobjects::disableObject();

	defuseObject maps\mp\gametypes\_gameobjects::disableObject();
	
	//setGameEndTime( 0 );
	//Tempo para Atualizar BroadLife
	xwait( 3.0, false );

	sd_endGame( game["attackers"], game["strings"]["target_destroyed"] );
}

BombTimerWaitUnHack()//3
{
	level endon("game_ended");
	level endon("bomb_exploded");
	level endon("bomb_defused");
	level endon("wrong_wire");

	setGameEndTime( int( gettime() + (60 * 1000) ) );
	xwait( 60, false );
}

BombTimerWaitHacked()//2
{
	level endon("game_ended");
	level endon("bomb_exploded");
	level endon("bomb_defused");
	level endon("wrong_wire");
	level endon("bombunhacked");
	//hackedtimer = int( (gettime() + (30 * 1000)));
	setGameEndTime( int( gettime() + (30 * 1000) ) );
	xwait( 30, false );
}

//timer normal
BombTimerWait()//1
{
	level endon("game_ended");
	level endon("bomb_exploded");
	level endon("bomb_defused");
	level endon("wrong_wire");
	level endon("bomb_hacked");
	xwait( level.bombTimer, false );
}

playSoundinSpace( alias, origin )
{
	org = spawn( "script_origin", origin );
	org.origin = origin;
	org playSound( alias  );
	xwait( 10.0, false ); 
	org delete();
}

bombDefused()
{
	level.tickingObject maps\mp\gametypes\_globallogic::stopTickingSound();
	level.bombDefused = true;
	level notify("bomb_defused");
	setDvar( "ui_bomb_timer", 0 );
	xwait( 1, false );//CHD to 1 - 005
	setGameEndTime( 0 );
	sd_endGame( game["defenders"], game["strings"]["bomb_defused"] );
}


disableObject()
{
	// Check if the bombzone should still show to the defenders
	if ( level.scr_sd_defenders_show_both == 1 ) {
		self maps\mp\gametypes\_gameobjects::setVisibleTeam( "friendly" );
		self maps\mp\gametypes\_gameobjects::allowUse( "none" );
	} else {
		self maps\mp\gametypes\_gameobjects::disableObject();
	}	
}