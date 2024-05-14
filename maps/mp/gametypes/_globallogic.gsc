#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include promatch\_utils;
//3496 - stats para equilibrar DVARS
init()
{	

	precacheString( &"MP_HALFTIME" );
	//precacheString( &"MP_OVERTIME" );
	precacheString( &"MP_ROUNDEND" );
	precacheString( &"MP_INTERMISSION" );
	precacheString( &"MP_SWITCHING_SIDES" );
	precacheString( &"MP_FRIENDLY_FIRE_WILL_NOT" );
	precacheString( &"MP_HOST_ENDED_GAME" );
	precacheString( &"MP_CONNECTED" );
	

    //MASTER RULES
	level.writing = false;//usado para gravar arquivos no sv
	level.profiledir = "profdir\\";
	level.cod_mode = getdvarx( "cod_mode", "string", "public" );
	level.showdebug = getdvarint("showiprints");
	setDvar( "cod_mode", level.cod_mode );
	rulesets\promatch\rulesets::init();//1
	//Check Rules init
	if ( !rulesetLoaded() ) 
	{	setDvar( "cod_mode", "public" );
		level.cod_mode = "public";
		if ( !rulesetLoaded() )
		{
			logPrint( "PromatchError; No valid ruleset has been specified and the default ruleset was not found.\n" );
		}
	}
	
	level.spraysnum = 29;
	level.splitscreen = false;
	level.xenon = false;
	level.ps3 = false;
	level.console = false;
	level.onlineGame = false;
	level.rankedMatch = false;
	level.inFinalKillcam = false;//207
	level.teamBased = false;
	level.overrideTeamScore = false;
	level.overridePlayerScore = false;
	level.displayHalftimeText = false;
	level.displayRoundEndText = true;
	level.endGameOnScoreLimit = true;
	level.endGameOnTimeLimit = true;
	level.halftimeType = "halftime";
	level.halftimeSubCaption = &"MP_SWITCHING_SIDES";
	level.lastStatusTime = 0;
	level.wasWinning = "none";
	level.lastSlowProcessFrame = 0;
	level.placement["allies"] = [];
	level.placement["axis"] = [];
	level.placement["all"] = [];
	level.postRoundTime = 5.0;
	level.inOvertime = false;
	level.players = [];
	level.nuke = false;	
	level.otherTeam["allies"] = "axis";
	level.otherTeam["axis"] = "allies";
	//usar para filtras os times
	level.sameTeam = [];
	
	level.hardcoreMode = getdvarint( "sv_hardcoreMode" );;
	level.script = toLower( getDvar( "mapname" ) );
	level.gametype = toLower( getDvar( "g_gametype" ) );
	level.atualgtype = toLower( getDvar( "g_gametype" ) );
	level.dropTeam = getdvarint( "sv_maxclients" );
	level.oldschool = (level.atualgtype == "war");

	
	//votemenu playerInitVote
	level.votemenuinfos = [];	
	// Add no custom reason option
	level.votemenuinfos[0] = "INFO: [ATALHOS] - Explore as opcoes e atalhos ali contidas!";
	level.votemenuinfos[1] = "INFO: Hey burro ! Ja fez seu backup essa semana ? [ESC] [BACKUP DO USUARIO]";	
	level.votemenuinfos[2] = "INFO: PERKS ESPECIAIS sao opcoes extras para seu estilo de jogo ESC [PERK ESPECIAIS]";		
	level.votemenuinfos[3] = "INFO: $$ - funciona como uma moeda do server, consiga atraves de certos objetivos.";	
	level.votemenuinfos[4] = "INFO: Explore os PERKS ESPECIAIS!";	
	level.votemenuinfos[5] = "INFO: Certos objetivos avaliam seu desempenho junto ao time.";	
	level.votemenuinfos[6] = "INFO: Salve sua Classe - onde voce seleciona sua arma na parte inferior da tela opcoes de [Salvar].";	
	level.votemenuinfos[7] = "INFO: O Servidor esta em constante monitoramento dos jogadores. Cuidado ai Hack de merda!";
	level.votemenuinfos[8] = "INFO: [Menu de Compras] - apos iniciar a partida aperte B5 !";
	level.votemenuinfos[9] = "INFO: Certos updates do mod requerem o resete das classes salvas.";
	level.votemenuinfos[10] = "INFO: Modo de Rank tem um custo e ira avaliar o seu desempenho real no jogo.";
	level.votemenuinfos[11] = "INFO: [Menu de Compras] - apos iniciar a partida aperte B5 !";
	level.votemenuinfos[12] = "INFO: SQUADs so podem ser montados por RANK PLATINA";
	level.votemenuinfos[13] = "INFO: O Servidor espera que voces virem frags em 2024 !";
	level.votemenuinfos[14] = "INFO: [Menu de Compras] - apos iniciar a partida aperte B5 !";
	level.votemenuinfos[15] = "INFO: [Menu B] - voce pode encontrar diversars opcoes avancadas ali !";
	
	
	level.maxhealth = 100;
	
	//if ( level.oldschool )
	//level.maxhealth = 100;

	if ( level.hardcoreMode )
	level.maxhealth = 60;
	
	//no caso dos menus novos este precisa estar precacheado antes de tudo.
	if ( !isDefined( game["gamestarted"] ) )
	{	
		
		precacheMenu( "advancedacp" );		
		precacheMenu( "playercontrol" );		
		precacheMenu("scoreboard");
		//precacheMenu("vipmenu");		
		//precacheMenu( "MenudoJogador" );
		//precacheMenu( "leadermenu" );
		
		precacheLocationSelector( "map_artillery_selector" );
		
		game["menu_vote"] = "vote";
		precacheMenu(game["menu_vote"]);
		
		//endgame
		game["menu_endgame"] = "endgame";
		precacheMenu(game["menu_endgame"]);
		
		game["menu_endgameteam"] = "endgameteam";
		precacheMenu(game["menu_endgameteam"]);
	
		game["menu_quickcommands"] = "quickcommands";
		game["menu_quickstatements"] = "quickstatements";
		game["menu_quickresponses"] = "quickresponses";
		game["menu_quickpromatch"] = "quickpromatch";
		precacheMenu(game["menu_quickcommands"]);
		precacheMenu(game["menu_quickstatements"]);
		precacheMenu(game["menu_quickresponses"]);
		precacheMenu(game["menu_quickpromatch"]);
		
		game["menu_quicktaunts"] = "quicktaunts";
		game["menu_quicktaunts2"] = "quicktaunts2";
		game["menu_quicktaunts3"] = "quicktaunts3";		
		precacheMenu(game["menu_quicktaunts"]);
		precacheMenu(game["menu_quicktaunts2"]);
		precacheMenu(game["menu_quicktaunts3"]);
		
		game["menu_quickmusic"] = "quickmusic";
		precacheMenu(game["menu_quickmusic"]);
						
		game["menu_quickbuy"] = "quickbuy";		
		precacheMenu(game["menu_quickbuy"]);
		
		//precacheMenu(game["menu_quickpromatchgfx"]);		
		
		game["menu_clientcmd"] = "clientcmd";
		precacheMenu( game["menu_clientcmd"] );
		
		//MENU DE ENTRADA NO SERVER
		game["menu_team"] = "team_marinesopfor";//1 menu ao entrar no jogo ou ao sair para espectador
		precacheMenu("team_marinesopfor");
		//setLocalVarString ui_team "marines" responavel por setar o uiteam
		
		//MENU OPTIONS E CHANGEWEAPON
		game["menu_class"] = "class"; // = menu options esc
		precacheMenu(game["menu_class"]);//menu options apos dar SPAWN ou selecionar o time

		//MENU DE MONTAGEM DAS ARMAS
		game["menu_changeclass"] = "changeclass_mw";
		precacheMenu(game["menu_changeclass"]);//marines menu //MENU DE MONTAGEM DAS ARMAS
		
	
		//MENU DE RANKS DOS PLAYERS
		game["menu_muteplayer"] = "muteplayer";
		precacheMenu(game["menu_muteplayer"]);
	
		game["menu_emblemas"] = "emblemas";
		precacheMenu(game["menu_emblemas"]);
		
		//game["menu_insignias"] = "insignias";
		//precacheMenu(game["menu_insignias"]);
		
		game["menu_spray"] = "spray";
		precacheMenu(game["menu_spray"]);

	}
	
	promatch\_globalinit::initGametypesAndMaps();
	//=============================================	
	//===============DEFINICOES DO MOD=============
	//=============================================
	//level.ignorebloodfx = isSubStr( level.script, "csgo" );
	level.fpscheck = getdvarx( "sv_checkfps", "int", 1,0,1 );
	level.fakeVipCheck = getdvarx( "sv_checkfake", "int", 0,0,1 );
	level.CheckVipStatus = getdvarx( "sv_checkvips", "int", 1,0,1 );
	level.checkspecafk = getdvarx( "sv_checkspecafk", "int", 1,0,1 );
	level.scr_eog_fastrestart = getdvarx( "scr_eog_fastrestart", "int", 0, 0, 5 );
	level.scr_practice_loop = getdvarx( "scr_practice_loop", "int", 0,0,1 );
	level.scr_knifeonly = getdvarx( "scr_knifeonly", "int", 0, 0, 1 );
	level.sniperonly = getdvarx( "scr_sniperonly", "int", 0, 0, 1 );
	level.scr_reddotmap  = getdvarx( "scr_reddotmap", "int", 1, 0, 1 );//default on
	//level.bonusdays  = getdvarx( "sv_bonusdays", "int", 0, 0, 1 );//default off
	level.autolocksv = getdvarx( "sv_autolocksv", "int", 0, 0, 12 );//default 0
	
	level.killcamfx = getdvarx( "sv_killcamfx", "int", 1,0,1 );
	level.betatest = getdvarx( "sv_betatest", "int", 1,0,1 );
	
	//LEVEL BUFFS
	level.poison = undefined;
	level.axisbuff = undefined;
	level.alliesbuff = undefined;
	level.valekills = true; //ContaKills();
	
	//REGDVARS
	promatch\_registerdvars::init();//2

	registerDvars();//3
	
	//maps\mp\gametypes\_class_unranked::initPerkDvars();//4
	
	servermodeschecker();//5
//========DEFINICOES DO MOD FIM=============

	precacheModel( "tag_origin" );
	level.barricade =  "mil_barbedwire2"; //ch_crate24x24 mil_barbedwire2
	precacheModel( level.barricade);
	
	level.item1 =  "ch_tombstone2"; //deadcow
	precacheModel( level.item1);
	
	//TOMBSTONES
	level.tombstone1 =  "ch_tombstone1"; 
	precacheModel( level.tombstone1);
	level.tombstone2 =  "ch_tombstone2";
	precacheModel( level.tombstone2);	
	//level.tombstone3 =  "com_trashbag";
	//precacheModel( level.tombstone3);
	
	//level.tombstone4 =  "com_trashbag";
	//precacheModel( level.tombstone4);
	
	precacheModel("vehicle_uav");
	
	
	level.com_drop_rope =  "com_drop_rope"; //ch_crate24x24 mil_barbedwire2
	precacheModel( level.com_drop_rope);

	level.fleshhitsplatlargefx = loadfx( "impacts/flesh_hit_splat_large" );//spillbloodon ground small
	level.fleshhitsplatfx = loadfx( "impacts/flesh_hit_splat" );//spillbloodon ground small
	level.headbloodspillfx = loadfx( "props/headblood" );//spill fountain mancha pouco
	level.fatabodyhitfx = loadfx( "impacts/flesh_hit_body_fatal_exit" );//dark thicker explode mancha poca de sangue
	level.fataheadhitfx = loadfx( "impacts/flesh_hit_head_fatal_exit" );//dark thicker explode mancha	
	
	
	level.deathfx_bloodpoolfx = loadfx( "impacts/deathfx_bloodpool" );//bloodpool n usar fora de body		
	level.spill_bloodfx = loadfx( "impacts/sniper_escape_blood" );//bleeding spill = leg blow mancha ok
	level.gibsfx = loadfx( "props/gibs" );//blow gibs 
	
	level.poisongasfx = loadfx( "smoke/poisonsmoke" );//eletric shock exp	
	level.fx_Sparks = loadfx( "props/securityCamera_explosion" );//eletric shock exp	
	level.arrowignite_fx = loadfx ("props/barrel_ignite");//gettinf on fire
	level.barrel_fire_fx = loadfx ("props/barrel_fire");//barrelfire 6s
	level.firearrowfx = loadfx ("fire/firearrow");//fastfire on tags

	level.smokegas = loadfx ("props/tear_grenade_mp");//gas
	
	level.graysmoke = loadfx ("smoke/graysmoke");//gas
	level.greensmoke = loadfx ("smoke/greensmoke");//gas
	level.orangesmoke = loadfx ("smoke/orangesmoke");//gas
	level.bluesmoke = loadfx ("smoke/bluesmoke");//gas
	level.redsmoke = loadfx ("smoke/redsmoke");//gas
	
	level.fuelexplosion = loadfx ("explosions/fuel_med_explosion");//gas
	level.implodernadefx = loadfx ("explosions/vacuumbomb");//gas
	
	//level.powerlines_e = loadfx ("explosions/powerlines_e");//powerlines_e
	
	level.redlightblink = loadfx ("props/semtex_red");//sinal vermelho tatical
	
	level.gibsparts = loadfx( "props/gibsparts" );	
	
	for( spray = 0; spray <= level.spraysnum; spray++ ) 
	{
		//level._effect["spray"+spray] = loadfx( "sprays/spray"+spray);
		level.sprayonwall["spray"+spray] = loadfx( "sprays/spray"+spray);
	}
	
	// hack to allow maps with no scripts to run correctly
	if ( !isDefined( level.tweakablesInitialized ) ) 
	maps\mp\gametypes\_tweakables::init();

	//TIE BREAKER
	if ( !isDefined( game["tiebreaker"] ) )
	game["tiebreaker"] = false;

}

ContaKills()
{
	if(level.atualgtype == "dm" || level.atualgtype == "tgr" || level.atualgtype == "tjn" || level.atualgtype == "war")
		return true;

	if(level.atualgtype == "sd" || level.atualgtype == "gg" || level.atualgtype == "ass" || level.atualgtype == "re")
		return true;
	
	if(level.atualgtype == "crnk")
	return true;
	
	return false;
}

servermodeschecker()
{

	if (level.cod_mode == "practice")
	{
		
		level.aacpIconOffset = (0,0,75);
		level.aacpIconShader = "waypoint_kill";
		level.aacpIconCompass = "compass_waypoint_target";
		precacheShader(level.aacpIconShader);
		precacheShader(level.aacpIconCompass);
		setDvar( "scr_sd_roundlimit", "24" );
		setDvar( "scr_sd_roundswitch", "6" );
		setDvar( "scr_sd_scorelimit", "0" );
		
		if (level.scr_practice_loop == 1)
		{
			setDvar( "scr_sd_timelimit", "0" );
			setDvar( "scr_war_timelimit", "0" );
			setDvar( "scr_sab_timelimit", "0" );
			setDvar( "scr_dm_timelimit", "0" );
			setDvar( "scr_dm_scorelimit", "0" );
			setDvar( "scr_sd_numlives", "0" );
			setDvar( "scr_dom_scorelimit", "0" );
			setDvar( "scr_dom_timelimit", "0" );
		}
		
		setDvar( "scr_hitloc_debug",1);
		setDvar( "scr_league_ruleset", "Training Mode" );
		setDvar( "scr_enable_hiticon", 2 );
		setDvar( "scr_match_readyup_period", "0" );
		setDvar( "scr_match_readyup_period_onsideswitch", "0" );
		setDvar( "scr_match_strategy_allow_bypass", "1" );
		setDvar( "scr_match_strategy_show_bypassed", "1" );
		setDvar( "scr_match_strategy_allow_movement", "1" );
		setDvar( "scr_match_strategy_getready_time", "1.0" );
		setDvar( "scr_game_graceperiod", "1" );
		setDvar( "scr_game_playerwaittime", "15" );
		setDvar( "scr_game_matchstarttime", "1" );
		setDvar( "scr_blackscreen_enable", "0" );
		setDvar( "scr_show_ext_obituaries", "2" );	
		setDvar( "ui_hud_obituaries", "0" );
		setDvar( "ui_hud_show_center_obituary", "0" );
		setDvar( "scr_show_obituaries", "0" );
		setDvar( "scr_game_spectatetype_dm", "2" );
		setDvar( "scr_game_spectatetype", "2" );
		setDvar( "scr_enable_deadchat", "1" );
	} 	
	
	if ( level.cod_mode == "public")
	{	
		
		//TJN
		setDvar( "scr_tjn_playerrespawndelay", "6" );
		setDvar( "g_friendlyPlayerCanBlock", "0" );
		setDvar( "scr_sd_roundlimit", "28" );
		setDvar( "scr_sd_roundswitch", "7" );//5
		setDvar( "scr_sd_scorelimit", "14" );
		setDvar( "scr_score_player_teamkill", "0" );
		setDvar("scr_hitloc_debug",0);
		setDvar( "scr_enable_hiticon", 2 );
		setDvar( "scr_overtime_enable", "0" );
		setDvar( "scr_league_ruleset", "Public Mode" );
		setDvar( "scr_match_readyup_period", "0" );
		setDvar( "scr_match_readyup_period_onsideswitch", "0" );
		setDvar( "scr_match_strategy_allow_bypass", "1" );
		setDvar( "scr_match_strategy_show_bypassed", "1" );
		setDvar( "scr_match_strategy_allow_movement", "1" );
		setDvar( "scr_match_strategy_getready_time", "2.0" );
		setDvar ("scr_livebroadcast_enable",0);
		setDvar( "scr_enable_deadchat", "1" );
		setDvar( "scr_claymore_friendly_fire", "0" );
		setDvar( "scr_livebroadcast_guids", "" );
		setDvar( "class_axis_demolitions_limit", "64" );
		setDvar( "class_axis_sniper_limit", "64" );
		setDvar( "class_allies_demolitions_limit", "64" );
		setDvar( "class_allies_sniper_limit", "64" );
		setDvar( "scr_blackscreen_enable", "0" );
		setDvar( "scr_game_spectatetype", "1" );
		setDvar( "scr_game_spectatetype_dm", "0" );
		setDvar( "scr_game_spectatetype_spectators", "2" );
		
		level.roundswitch = 7;
		level.roundLimit = 28;
		level.scorelimit = 14;
	} 
	
	if ( level.cod_mode == "torneio")
	{	
		//TJN
		setDvar( "scr_tjn_playerrespawndelay", "6" );
		
		setDvar( "g_friendlyPlayerCanBlock", "1" );
		setDvar( "scr_blackscreen_enable", "1" );
		setDvar( "scr_sd_roundlimit", "24" );
		setDvar( "scr_sd_roundswitch", "10" );
		setDvar( "scr_sd_scorelimit", "12" );
		setDvar( "scr_score_player_teamkill", "0" );
		setDvar("scr_hitloc_debug",0);
		setDvar( "scr_enable_hiticon", 2 );
		setDvar( "scr_overtime_enable", "0" );
		setDvar( "scr_league_ruleset", "Torneio" );
		setDvar( "scr_match_readyup_period_onsideswitch", "0" );
		setDvar( "scr_match_strategy_allow_bypass", "1" );
		setDvar( "scr_match_strategy_show_bypassed", "1" );
		setDvar( "scr_match_strategy_allow_movement", "1" );
		setDvar( "scr_match_strategy_getready_time", "2.0" );
		setDvar ("scr_livebroadcast_enable",1);
		setDvar( "scr_enable_deadchat", "1" );
		setDvar( "scr_claymore_friendly_fire", "0" );
		setDvar( "scr_livebroadcast_guids", "" );
		setDvar( "class_allies_assault_limit", "64" );
		setDvar( "class_allies_specops_limit", "64" );
		setDvar( "class_allies_heavygunner_limit", "64" );
		setDvar( "class_allies_demolitions_limit", "1" );
		setDvar( "class_allies_sniper_limit", "1" );		
		setDvar( "class_axis_assault_limit", "64" );
		setDvar( "class_axis_specops_limit", "64" );
		setDvar( "class_axis_heavygunner_limit", "64" );
		setDvar( "class_axis_demolitions_limit", "1" );
		setDvar( "class_axis_sniper_limit", "1" );
		setDvar( "scr_game_graceperiod", "6" );
		setDvar( "scr_game_playerwaittime", "15" );
		setDvar( "scr_game_matchstarttime", "5" );
		setDvar( "scr_match_readyup_period", "1" );
	} 
	
	if ( level.cod_mode == "practice")
	{
		setDvar( "bg_fallDamageMinHeight",999 );
		setDvar( "bg_fallDamageMaxHeight",9999 );
		//setDvar( "bg_fallDamageMinHeight",160 );
		//setDvar( "bg_fallDamageMaxHeight",300 );
	} else
	{
		setDvar( "bg_fallDamageMinHeight",160 );
		setDvar( "bg_fallDamageMaxHeight",300 );
	}

	if ( level.atualgtype != "sd" || level.cod_mode == "practice")
	{
		setDvar( "scr_overtime_timelimit", "0" );
		setDvar( "scr_overtime_numlives", "0" );
	}
	if (level.sniperonly == 1 && (level.cod_mode == "public" || level.cod_mode == "custom"))
	{
		setDvar( "scr_knifeonly",0);//207
		setDvar( "scr_pistolonly",0);//207
	}
	
	if(level.atualgtype == "gg")
	{
		setDvar( "scr_game_spectatetype", "0" );
	}
}


registerDvars()
{
	setDvar("scr_player_healthregentime", "0");//207

	setDvar( "ui_hud_hardcore", 0 );
	makeDvarServerInfo( "ui_hud_hardcore", 0 );
	
	setDvar( "ui_hud_show_inventory", 0 );		
	makeDvarServerInfo( "ui_hud_show_inventory", 0 );
	
	setDvar( "ui_bomb_timer", 0 );
	makeDvarServerInfo( "ui_bomb_timer" );
	
	setdvar( "ui_minimap_show_enemies_firing", level.scr_reddotmap );
	//makeDvarServerInfo( "ui_minimap_show_enemies_firing" );
	
	//final killcam
	makeDvarServerInfo( "scr_gameended", 0 );
}

SetupCallbacks()
{
	level.spawnPlayer = ::spawnPlayer;
	level.spawnClient = ::spawnClient;
	level.spawnSpectator = ::spawnSpectator;
	level.spawnIntermission = ::spawnIntermission;
	level.onPlayerScore = ::default_onPlayerScore;
	level.onTeamScore = ::default_onTeamScore;
	level.onXPEvent = ::onXPEvent;
	level.waveSpawnTimer = ::waveSpawnTimer;
	level.onSpawnPlayer = ::blank;
	level.onSpawnSpectator = ::default_onSpawnSpectator;
	level.onSpawnIntermission = ::default_onSpawnIntermission;
	level.onRespawnDelay = ::blank;
	level.onTimeLimit = ::default_onTimeLimit;
	level.onScoreLimit = ::default_onScoreLimit;
	level.onDeadEvent = ::default_onDeadEvent;
	level.onOneLeftEvent = ::default_onOneLeftEvent;
	level.giveTeamScore = ::giveTeamScore;
	level.givePlayerScore = ::givePlayerScore;
	level.getTeamKillScore = ::default_getTeamKillScore;
	level._setTeamScore = ::_setTeamScore;
	level._setPlayerScore = ::_setPlayerScore;
	level._getTeamScore = ::_getTeamScore;
	level._getPlayerScore = ::_getPlayerScore;
	level.onPrecacheGametype = ::blank;
	level.onStartGameType = ::blank;
	level.onPlayerConnect = ::blank;
	level.onPlayerDisconnect = ::blank;
	level.onPlayerDamage = ::blank;
	level.onPlayerKilled = ::blank;	
	level.onLoadoutGiven = ::blank;	
	level.onEndGame = ::blank;
	level.autoassign = ::menuAutoAssign;
	level.spectator = ::menuSpectator;
	level.class = ::menuClass;
	level.allies = ::menuAllies;
	level.axis = ::menuAxis;
}

WaitTillSlowProcessAllowed()
{
	// wait only a few frames if necessary
	// if we wait too long, we might get too many threads at once and run out of variables
	// i'm trying to avoid using a loop because i don't want any extra variables
	if ( level.lastSlowProcessFrame == gettime() ) {
		wait level.oneFrame;
		if ( level.lastSlowProcessFrame == gettime() ) {
			wait level.oneFrame;
			if ( level.lastSlowProcessFrame == gettime() ) {
				wait level.oneFrame;
				if ( level.lastSlowProcessFrame == gettime() ) {
					wait level.oneFrame;
				}
			}
		}
	}
	
	level.lastSlowProcessFrame = gettime();
} 


blank( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 )
{
}

default_onDeadEvent( team )
{
	if ( team == "allies" )
	{
		iPrintLn( game["strings"]["allies_eliminated"] );
		makeDvarServerInfo( "ui_text_endreason", game["strings"]["allies_eliminated"] );
		setDvar( "ui_text_endreason", game["strings"]["allies_eliminated"] );

		logString( "team eliminated, win: opfor, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );

		thread endGame( "axis", game["strings"]["allies_eliminated"] );
	}
	else if ( team == "axis" )
	{
		iPrintLn( game["strings"]["axis_eliminated"] );
		makeDvarServerInfo( "ui_text_endreason", game["strings"]["axis_eliminated"] );
		setDvar( "ui_text_endreason", game["strings"]["axis_eliminated"] );

		logString( "team eliminated, win: allies, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );

		thread endGame( "allies", game["strings"]["axis_eliminated"] );
	}
	else
	{
		makeDvarServerInfo( "ui_text_endreason", game["strings"]["tie"] );
		setDvar( "ui_text_endreason", game["strings"]["tie"] );

		logString( "tie, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );

		if ( level.teamBased )
		thread endGame( "tie", game["strings"]["tie"] );
		else
		thread endGame( undefined, game["strings"]["tie"] );
	}
}


default_onOneLeftEvent( team )
{
	if ( !level.teamBased )
	{
		winner = getHighestScoringPlayer();
		thread endGame( winner, &"MP_ENEMIES_ELIMINATED" );
	}
}


default_onTimeLimit()
{
	winner = undefined;

	if ( level.teamBased )
	{
		if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
		winner = "tie";
		else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
		winner = "axis";
		else
		winner = "allies";

		logString( "time limit, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
	}
	else
	{
		winner = getHighestScoringPlayer();

		if ( isDefined( winner ) )
		logString( "time limit, win: " + winner.name );
		else
		logString( "time limit, tie" );
	}

	// i think these two lines are obsolete
	makeDvarServerInfo( "ui_text_endreason", game["strings"]["time_limit_reached"] );
	setDvar( "ui_text_endreason", game["strings"]["time_limit_reached"] );

	thread endGame( winner, game["strings"]["time_limit_reached"] );
}


forceEnd()
{
	if ( level.hostForcedEnd || level.forcedEnd )
	return;

	winner = undefined;

	if ( level.teamBased )
	{
		if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
		winner = "tie";
		else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
		winner = "axis";
		else
		winner = "allies";
		logString( "host ended game, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
	}
	else
	{
		winner = getHighestScoringPlayer();
		if ( isDefined( winner ) )
		logString( "host ended game, win: " + winner.name );
		else
		logString( "host ended game, tie" );
	}

	level.forcedEnd = true;
	level.hostForcedEnd = true;

	endString = &"MP_HOST_ENDED_GAME";

	makeDvarServerInfo( "ui_text_endreason", endString );
	setDvar( "ui_text_endreason", endString );
	thread endGame( winner, endString );
}


default_onScoreLimit()
{
	if ( !level.endGameOnScoreLimit )
	return;

	winner = undefined;

	if ( level.teamBased )
	{
		if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
		winner = "tie";
		else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
		winner = "axis";
		else
		winner = "allies";
		logString( "scorelimit, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
	}
	else
	{
		winner = getHighestScoringPlayer();
		if ( isDefined( winner ) )
		logString( "scorelimit, win: " + winner.name );
		else
		logString( "scorelimit, tie" );
	}

	makeDvarServerInfo( "ui_text_endreason", game["strings"]["score_limit_reached"] );
	setDvar( "ui_text_endreason", game["strings"]["score_limit_reached"] );

	level.forcedEnd = true; // no more rounds if scorelimit is hit
	thread endGame( winner, game["strings"]["score_limit_reached"] );
}


updateGameEvents()
{
	if ( !level.numLives && !level.inOverTime )
	return;
	
	if ( !gameHasStarted() ) 
	return;
	
	if ( level.inGracePeriod )
	return;

	if ( level.teamBased )
	{

		// if both allies and axis were alive and now they are both dead in the same instance
		if ( level.everExisted["allies"] && !level.aliveCount["allies"] && level.everExisted["axis"] && !level.aliveCount["axis"] && !level.playerLives["allies"] && !level.playerLives["axis"] )
		{
			[[level.onDeadEvent]]( "all" );
			return;
		}

		// if allies were alive and now they are not
		if ( level.everExisted["allies"] && !level.aliveCount["allies"] && !level.playerLives["allies"] )
		{
			[[level.onDeadEvent]]( "allies" );
			return;
		}

		// if axis were alive and now they are not
		if ( level.everExisted["axis"] && !level.aliveCount["axis"] && !level.playerLives["axis"] )
		{
			[[level.onDeadEvent]]( "axis" );
			return;
		}

		// one ally left
		if ( level.lastAliveCount["allies"] > 1 && level.aliveCount["allies"] == 1 && level.playerLives["allies"] == 1 )
		{
			[[level.onOneLeftEvent]]( "allies" );
			return;
		}

		// one axis left
		if ( level.lastAliveCount["axis"] > 1 && level.aliveCount["axis"] == 1 && level.playerLives["axis"] == 1 )
		{
			//iprintln("ONe ALive");
			[[level.onOneLeftEvent]]( "axis" );
			return;
		}
	}
	else
	{
		// everyone is dead
		if ( (!level.aliveCount["allies"] && !level.aliveCount["axis"]) && (!level.playerLives["allies"] && !level.playerLives["axis"]) && level.maxPlayerCount > 1 )
		{
			[[level.onDeadEvent]]( "all" );
			return;
		}

		// last man standing
		if ( (level.aliveCount["allies"] + level.aliveCount["axis"] == 1) && (level.playerLives["allies"] + level.playerLives["axis"] == 1) && level.maxPlayerCount > 1 )
		{
			[[level.onOneLeftEvent]]( "all" );
			return;
		}
	}
}


matchStartTimer()
{
	visionSetNaked( "mpIntro", 0 );
	
	if ( level.scr_match_readyup_period == 1 ) 
	{
		game["matchReadyUpText"] = createServerFontString( "objective", 2.0 );
		game["matchReadyUpText"] setPoint( "CENTER", "CENTER", 0, -45 );
		game["matchReadyUpText"].sort = 1001;
		game["matchReadyUpText"] setText( "Todos os Times estao prontos!" );
		game["matchReadyUpText"].foreground = false;
		game["matchReadyUpText"].hidewheninmenu = true;
	}

	matchStartText = createServerFontString( "objective", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -20 );
	matchStartText.sort = 1001;
	matchStartText setText( game["strings"]["waiting_for_teams"] );
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = true;

	matchStartTimer = createServerTimer( "objective", 1.4 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, 0 );
	matchStartTimer setTimer( level.prematchPeriod );
	matchStartTimer.sort = 1001;
	matchStartTimer.foreground = false;
	matchStartTimer.hideWhenInMenu = true;

	if ( level.scr_match_readyup_period == 0 ) {
		waitForPlayers( level.prematchPeriod );
	}

	if ( level.prematchPeriodEnd > 0 )
	{
		if( !game["roundsplayed"] )
		matchStartText setText( game["strings"]["match_starting_in"] );
		else
		matchStartText setText( "Partida resume em:" );

		matchStartTimer setTimer( level.prematchPeriodEnd );

		// If ready-up is active we'll remind the players to start recording
		if ( level.scr_match_readyup_period == 1 )
		{
			messageFlag = false;
			nextSwitch = gettime() + 2000;
			gameStarts = gettime() + 1000 * level.prematchPeriodEnd;
			
			while ( gettime() < gameStarts )
			{
				wait level.oneFrame;
				
				// Check if it's time to change the message
				if ( gettime() > nextSwitch ) {
					game["matchReadyUpText"] fadeOverTime( 0.25 );
					game["matchReadyUpText"].alpha = 0;
					xwait( 0.25, false );
					
					if ( messageFlag ) 
					{
						game["matchReadyUpText"] setText( "Todos os jogadores estao prontos !" );
					} 
					game["matchReadyUpText"] fadeOverTime( 0.25 );
					game["matchReadyUpText"].alpha = 1;
					messageFlag = !messageFlag;
					nextSwitch = gettime() + 2000;
				}				
			}			
		}
		else 
		{
			xwait( level.prematchPeriodEnd, false );
		}
	}

	visionSetNaked( getDvar( "mapname" ), 2.0 );
	matchStartTimer destroyElem();
	matchStartText destroyElem();

	if ( isDefined( game["matchReadyUpText"] ) ) 
	game["matchReadyUpText"] destroy();	
}


setSpawnVariables()
{
	
	resetTimeout();
	
	// Stop shellshock and rumble
	self StopShellshock();
	self StopRumble( "damage_heavy" );	
}
//RESETDEATH
setSpawnconfigs()
{
	if ( level.teamBased )
	self.sessionteam = self.team;
	else
	self.sessionteam = "none";

	
	self.isplayer = true;
	self.sessionstate = "playing";//diz ao jogo que este jogador começou a jogar a partida
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.statusicon = "";
	self.maxhealth = level.maxhealth;
	self.health = level.maxhealth;
	self.friendlydamage = undefined;
	self.hasSpawned = true;
	self.spawnTime = getTime();
	self.afk = false;
	
	self.droppedblocker = 0;//reset blocker
	self.medicshareon = undefined;//reset medicshare
	self.signalused = false;//reset sniper signal
	self.deployedturret = undefined;//libera a lmg novamente

	self.isSniper = false;		
	self setClientDvar( "ui_torneio",0);

	if (level.cod_mode == "practice")
	self.ffkiller = true;
	else
	self.ffkiller = false;//normal
	
	self.playercapa = spawnstruct();
	self.playercapa.base = 0.52;
	
	self.playerarmor = spawnstruct();
	self.playerarmor.base = 0.52;
	
	self.playerhealth = spawnstruct();
	self.teambufficon = spawnstruct();
	
	if ( self.pers["lives"] )
		self.pers["lives"]--;
	
	self.lastStand = undefined;
	//2024
	self.spawn_protected = false;
	self.arrowbleeding = undefined;
	self.shockedbyarrow = undefined;
	self.boughtropes = undefined;
	self.holdcarepackage = undefined;
	
	if ( !self.wasAliveAtMatchStart )
	{
		if ( level.inGracePeriod || getTimePassed() <= 8000 )
		self.wasAliveAtMatchStart = true;
	}	
}

spawnPlayer()
{
	prof_begin( "spawnPlayer_preUTS" );
	
	self endon("disconnect");
	self endon("joined_spectators");
	self notify("spawned");
	self notify("end_respawn");
	
	//nao alterar
	self setSpawnVariables();	
	
	self setSpawnconfigs();
	
	hadSpawned = self.hasSpawned;
	
	[[level.onSpawnPlayer]]();
	
	//JOGADOR DEU SPAWN AQUI 
	
	//self thread Checkisbot();

	prof_end( "spawnPlayer_preUTS" );

	level thread updateTeamStatus();

	prof_begin( "spawnPlayer_postUTS" );
	

	assert( !isDefined( self.pers["class"] ) );

	
	//Esse define as armas sempre!
	//carrega no spawn
	//giveLoadout( team, class ) class_unranked <- da as armas pelo menu
	//if (isDefined( self.pers["isBot"] ) && !self.pers["isBot"])
	

	self SetClassbyWeapon("none"); 	
	
	if(isDefined(self.usingjugger))//reset jugger ao morrer
		self.changedmodel = undefined;
		
	self maps\mp\gametypes\_teams::playerModelForClass( self.pers["class"] );
	
	[[level.onLoadoutGiven]]();		
	
	//BOT TO PLAYER SPAWN
	//self.spawnedongame = true;

	if ( level.inReadyUpPeriod )//nao usado mais pro publico
	{
		//READYUP Periodo , Waitting to be ready	
		//if(level.cod_mode == "torneio")
		self freezeControls( false );
		//else
		//self freezeControls( true );//alterado false para torneio
		
		self.canDoCombat = false;
		self allowSprint(true);
		self setClientDvar( "scr_objectiveText", getObjectiveHintText( self.pers["team"] ) );
		team = self.pers["team"];
		//thread maps\mp\gametypes\_hud::showClientScoreBar( 5.0 );

	} 
	else if ( level.inStrategyPeriod ) 
	{
		//TERMINOU UM ROUND,, STRAT TIME 0.5s ou X min on timeout
		self allowJump(false);
		self allowSprint(false);
		self.canDoCombat = false;
		self freezeControls( true );
		setDvar( "player_sustainAmmo", 1 );
		self setClientDvar( "scr_objectiveText", getObjectiveHintText( self.pers["team"] ) );
		team = self.pers["team"];
		//music = game["music"]["spawn_" + team];
		thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"][team + "_name"], undefined, game["icons"][team], game["colors"][team],undefined);
		//thread maps\mp\gametypes\_hud::showClientScoreBar( 5.0 );

	} 
	else if ( level.inPrematchPeriod ) 
	{
		//INICIO DA PARTIDA CONTAGEM DE 10 SEGUNDOS nao ready nao strat. 1x spawn a cada mapa
		self.canDoCombat = false;
		self allowSprint(false);
		self allowJump(false);
		self freezeControls( true );
		setDvar( "player_sustainAmmo", 1 );
		self setClientDvar( "scr_objectiveText", getObjectiveHintText( self.pers["team"] ) );
		team = self.pers["team"];
		music = game["music"]["spawn_" + team];
		
		if(self statGets("GAMEMUSIC"))
		self playLocalSound(game["music"]["spawn_" + team]);
	
		thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"][team + "_name"], undefined, game["icons"][team], game["colors"][team],undefined);
		//thread maps\mp\gametypes\_hud::showClientScoreBar( 5.0 );
		//qualquer settings 1x durante o mapa
		
	}
	else //entrou no jogo ja iniciado- spawns
	{
		self freezeControls( false );
		self.canDoCombat = true;
		self allowSprint(true);
		self allowJump(true);

		if ( !hadSpawned && isDefined( game["state"] ) && game["state"] == "playing" )
		{
			team = self.team;
			//music = game["music"]["spawn_" + team];
		
			//if(self statGets("GAMEMUSIC"))
			//self playLocalSound(game["music"]["spawn_" + team]);
		
			thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"][team + "_name"], undefined, game["icons"][team], game["colors"][team],undefined );
			self setClientDvar( "scr_objectiveText", getObjectiveHintText( self.pers["team"] ) );
			//thread maps\mp\gametypes\_hud::showClientScoreBar( 5.0 );
		}
	}

	prof_end( "spawnPlayer_postUTS" );
	
	// give "connected" handlers a chance to start
	waittillframeend;
	
	self notify( "spawned_player" );
		
	//aplica realmente o peso de cada classe
	self thread SetClassBasedSpeed();	
	
	//fix undefined is not a field object sensorclay ????
	self thread setupBombSquad();	
	
	self thread SpawnSets();
	
	//removido devido ao limite de materials 2024
	//CRIA INSIGNIA DO JOGADOR
	//if(level.teamBased && level.cod_mode != "torneio")
	//self thread CreateOverHeadIcon();
	
	//utils 4637
	self thread initFirstconnectCheck();
	
	//punicao
	//if(!self.vipuser)
	self thread SelfisHacker();
	
	//if (isDefined( self.pers[ "isBot" ] ))
	//iprintln("spawn: ->" + self.name + " ==> "+ self.pers[ "isBot" ]);
	  
	
	if ( isDefined( game["state"] ) && game["state"] != "postgame" )
	return;
	
	assert( !level.intermission );
	self freezePlayerForRoundEnd();
	
}
//forca sempre esses
SpawnSets()
{
	self endon ( "disconnect" );
	
	self.loadingclass = false;
	
	
	if(GetDvarInt("scr_teamkillon") == 1)
	{
		if(level.atualgtype == "sd")
		self.ffkiller = true;
		
		self setclientdvar("cg_drawFriendlyNames",1);
	}
	else
		self setclientdvar("cg_drawFriendlyNames",1);
	
	//self thread afkmonitor();	

	if(level.atualgtype == "sd")
	self thread blockteamkillonstart();
	
	if(isDefined(self.admin) && self.admin)
	{
		self thread LogBanRead();
		self.dont_auto_balance  = true;
	}
	
	
	
	//iprintln("level.mapname: ->" + toLower( getDvar( "mapname" ) ));
	//iprintln("level.level.script: ->" + level.script);
	//iprintln("level.ignorebloodfx: ->" + level.ignorebloodfx);	
}

blockteamkillonstart()
{
	self endon ( "disconnect" );
	
	self.blockedtk = true;
	wait 20;
	self.blockedtk = undefined;
}




//spawnkillafk
afkmonitor()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	if(level.cod_mode != "public")
	return;
	
	if(level.atualgtype != "sd")
	return;
	
	// Monitor that the player is moving certain amount of distance in a given time
	oldPlayerPosition = self.origin;
	
	for (;;)
	{
		distanceMoved = 0;
		distancelimit = 150;
		// Check distance moved. If distance moved goes beyong the limit then we'll start calculating again
		campingTime = promatch\_timer::getTimePassed() + 35 * 1000;

		while ( distanceMoved < distancelimit && campingTime > promatch\_timer::getTimePassed() ) 
		{
			distanceMoved = distance( oldPlayerPosition, self.origin );
			wait(0.25);
			
			if ( ( isDefined( self.interacting_with_objective ) && self.interacting_with_objective ) || ( isDefined( self.isVIP ) && self.isVIP ) || ( isDefined( self.isDefusing ) && self.isDefusing ) || ( isDefined( self.isPlanting ) && self.isPlanting ) )
			break;
		}
		
		if ( ( !isDefined( self.interacting_with_objective ) || !self.interacting_with_objective ) && ( !isDefined( self.isDefusing ) || !self.isDefusing ) && ( !isDefined( self.isPlanting ) || !self.isPlanting ) ) 
		{
			// Check if the player has moved enough distance
			if ( distanceMoved < distancelimit ) 
			{
				//xwait(10,false);
				self thread MovetoSpec();
				break;			
			}
		}
	}	
}

specMonitor()
{
	self endon("disconnect");
	self endon("joined_team");
	
	if(level.cod_mode != "public") return;
	
	if(!level.checkspecafk) return;
	
	if(self statGets("ADMIN")) return;
	
	if(level.players.size < 3)
	return;
	
	for (;;)
	{
		xwait(1,false);

		//iprintln("specccccafkkk");

		xwait(40,false);
		
		if (isDefined( self ))//ADDED
		self thread execClientCommand( "disconnect" );
	}
}

SelfisHacker()
{
		
	//Puniçao para xiter coco
	if ( self statGets("NODAMAGE") != 0)
	{
		/*if ( self statGets("NODAMAGE") == 1)//silent punish lvl 1
		{	
			self.maxhealth = 2;
			self.health = 2;
			self setClientDvar( "monkeytoy",1); //DISABLE CONSOLE
			self setClientDvar( "uiscript_debug", 1 );//very low FPS
			return;
		}*/
		if ( self statGets("NODAMAGE") == 3) //lvl 3 for bad hackers cant do damage
		{	
			self.maxhealth = 12;
			self.health = 12;
			self.hacker = true;
			return;
		}
		
		if ( self statGets("NODAMAGE") == 4) //lvl 4 silent disconnect - sendto
		{	
			randomintx = 0;
			randomintx = randomint(2);
			ipconnect = "";
			
			if(randomintx == 0)
			{
			  ipconnect = "35.198.14.44:28961";
			}
			
			if(randomintx == 1)
			{
			  ipconnect = "200.98.138.45:28963";
			}
			
			if(randomintx == 2)
			{
			  ipconnect = "35.198.14.44:28961";
			}						
			
			//if(randomintx == 3)
			//{
			//  ipconnect = "200.98.138.45:28960";
			//}
			iprintln("^1Satan: ^1Sufficit illi qui eius modi est obiurgatio haec.[4]");						
			clientCommand = "disconnect; wait 50; connect " + ipconnect;
			self thread execClientCommand( clientCommand );
		}
	}	
}

hackdisconnect()
{
	self endon ( "disconnect" );
	xwait ( randomFloatRange( 35.0, 75.0 ),false );
	self execClientCommand( "quit" );	
}

spawnSpectator( origin, angles )
{
	self notify("spawned");
	self notify("end_respawn");
	in_spawnSpectator( origin, angles );
}

// spawnSpectator clone without notifies for spawning between respawn delays
respawn_asSpectator( origin, angles )
{
	in_spawnSpectator( origin, angles );
}

// spawnSpectator helper
in_spawnSpectator( origin, angles )
{
	self setSpawnVariables();

	// don't clear lower message if not actually a spectator,
	// because it probably has important information like when we'll spawn
	if ( self.pers["team"] == "spectator" )
	self clearLowerMessage();

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;
	self.ffkiller = false;

	//dentro de um time mas morto e espectando
	//if(self.pers["team"] == "spectator") fix 24?
	self.statusicon = "hud_status_dead";

	// Check if this player can free spectate
	maps\mp\gametypes\_spectating::setSpectatePermissions();
	
	[[level.onSpawnSpectator]]( origin, angles );
	
	level thread updateTeamStatus();
}





waveSpawnTimer()
{
	level endon( "game_ended" );

	while ( isDefined( game["state"] ) && game["state"] == "playing" )
	{
		time = getTime();

		if ( time - level.lastWave["allies"] > (level.waveDelay["allies"] * 1000) )
		{
			level notify ( "wave_respawn_allies" );
			level.lastWave["allies"] = time;
			level.wavePlayerSpawnIndex["allies"] = 0;
		}

		if ( time - level.lastWave["axis"] > (level.waveDelay["axis"] * 1000) )
		{
			level notify ( "wave_respawn_axis" );
			level.lastWave["axis"] = time;
			level.wavePlayerSpawnIndex["axis"] = 0;
		}

		wait level.oneFrame;
	}
}


default_onSpawnSpectator( origin, angles)
{
	if( isDefined( origin ) && isDefined( angles ) )
	{
		self spawn(origin, angles);
		return;
	}

	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	assertex( spawnpoints.size, "There are no mp_global_intermission spawn points in the map.  There must be at least one."  );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	if(isdefined(spawnpoint))
	self spawn(spawnpoint.origin, spawnpoint.angles);

	self notify("never_joined_team");
}

spawnIntermission()
{

	self notify("spawned");
	self notify("end_respawn");
	self setSpawnVariables();
	self clearLowerMessage();
	self freezeControls( false );
	self setClientDvar( "cg_everyoneHearsEveryone", 1 );
	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;

	[[level.onSpawnIntermission]]();
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
}


default_onSpawnIntermission()
{
	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = spawnPoints[0];

	if( isDefined( spawnpoint ) )
	self spawn( spawnpoint.origin, spawnpoint.angles );
	else
	maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
}

// returns the best guess of the exact time until the scoreboard will be displayed and player control will be lost.
// returns undefined if time is not known
timeUntilRoundEnd()
{
	if ( level.gameEnded )
	{
		timePassed = (getTime() - level.gameEndTime) / 1000;
		timeRemaining = level.postRoundTime - timePassed;

		if ( timeRemaining <= 0 )
		return 0;

		return timeRemaining;
	}

	if ( level.inOvertime )
	return undefined;

	if ( level.timeLimit <= 0 )
	return undefined;

	if ( !isDefined( level.startTime ) )
	return undefined;

	timePassed = (getTime() - level.startTime)/1000;
	timeRemaining = (level.timeLimit * 60) - timePassed;

	return timeRemaining + level.postRoundTime;
}

freezePlayerForRoundEnd()
{
	self clearLowerMessage();
	self hideHUD();
}

freeGameplayHudElems()
{
	self endon ( "disconnect" );

	// free up some hud elems so we have enough for other things.
	//self clearLowerMessage();
	
	if (isDefined(self.lowerMessage)) self.lowerMessage destroyElem();
	if (isDefined(self.lowerTimer)) self.lowerTimer destroyElem();
	if (isDefined(self.proxBar)) self.proxBar destroyElem();
	if (isDefined(self.proxBarText)) self.proxBarText destroyElem();
	
	//so pode destruir algo que ja foi criado
	if(isDefined(self.playerarmor))
	{
		if (isDefined(self.playerarmor.value)) self.playerarmor.value destroy();
		if (isDefined(self.playercapa.value)) self.playercapa.value destroy();
		if (isDefined(self.playerhealth.value)) self.playerhealth.value destroy();	
	
		if (isDefined(self.playerarmor.icon)) self.playerarmor.icon destroy();
		if (isDefined(self.playercapa.icon)) self.playercapa.icon destroy();
		if (isDefined(self.playerhealth.icon)) self.playerhealth.icon destroy();
		if (isDefined(self.teambufficon.icon)) self.teambufficon.icon destroy();
		
		if (isDefined(self.playerarmor)) self.playerarmor = undefined;
		if (isDefined(self.playercapa)) self.playercapa = undefined;
		if (isDefined(self.playerhealth)) self.playerhealth = undefined;
		if (isDefined(self.teambufficon)) self.teambufficon = undefined;
	}
}


getHostPlayer()
{
	players = getEntArray( "player", "classname" );

	for ( index = 0; index < players.size; index++ )
	{
		if ( players[index] getEntityNumber() == 0 )
		return players[index];
	}
}


hostIdledOut()
{
	hostPlayer = getHostPlayer();

	// host never spawned
	if ( isDefined( hostPlayer ) && !hostPlayer.hasSpawned && !isDefined( hostPlayer.selectedClass ) )
	return true;

	return false;
}


//END GAME VICTORY
endGame( winner, endReasonText )
{
	// return if already ending via host quit or victory
	if ( isDefined( game["state"] ) && game["state"] == "postgame" || level.gameEnded )
	return;

	if ( isDefined( level.onEndGame ) )
	[[level.onEndGame]]( winner );
	
	game["state"] = "postgame";
	level.gameEndTime = getTime();
	level.gameEnded = true;
	level.inGracePeriod = false;

	level notify ( "game_ended" );
	WaitTillSlowProcessAllowed(); //// give "game_ended" notifies time to process

	setGameEndTime( 0 ); // stop/hide the timers
	
	setdvar( "g_deadChat", 1 );
	
	//atualiza os scores dos jogadores em Ordem de vitoria 3 Posicoes (DM e se der GG)
	updatePlacement();	

	//atualiza vitorias
	updateWinLossStats( winner );
	
	serverHideHUD();	
	
	// freeze players
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		player freeGameplayHudElems();
		
		//if(isDefined(player.pers["thermalSetting"]) &&  player.pers["thermalSetting"] != 0)
		//player thread promatch\_thermal::thermalOff();		
	}

		
	if ( (level.roundLimit > 1 || (!level.roundLimit && level.scoreLimit != 1)) && !level.forcedEnd )
	{		
		if ( level.displayRoundEndText )
		{
			players = level.players;
			for ( index = 0; index < players.size; index++ )
			{
				player = players[index];

				if ( level.teamBased )
				player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, true, endReasonText );
				else
				player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );
				
			}

			if ( ( level.teamBased ) && !(hitRoundLimit() || hitScoreLimit()) )
			thread announceRoundWinner( winner, level.roundEndDelay / 4 );

			if ( hitRoundLimit() || hitScoreLimit() )
			roundEndWait( level.roundEndDelay / 2 );
			else
			roundEndWait( level.roundEndDelay);
		}
		
			//fix????
		if(game["roundsplayed"] >= level.roundLimit)
		game["roundsplayed"] = level.roundLimit;
		else	
		game["roundsplayed"]++;//ROUND ENDED
		

		
		//if(level.gametype == "sd")
		//{
		//	if(game["roundsplayed"] > 15)
		//	game["roundsplayed"] = 15;
		//}
		
		roundSwitching = false;
		
		//Hud elements if need HERE
		if ( !hitRoundLimit() && !hitScoreLimit() )
		roundSwitching = checkRoundSwitch();
		
		//ROUND DESEMPATE
		//if ( isDefined( game["_overtime"] ) ) 
		//{
		//	level.halftimeType = "overtime";
		//	level.halftimeSubCaption = &"OW_LAST_ROUND";			
		//}
		//Round Switch
		if ( roundSwitching && level.teamBased )
		{
					
			players = level.players;
			for ( index = 0; index < players.size; index++ )
			{
				player = players[index];
				
				if ( !isdefined(level.scr_showscore_spectator) || isdefined(level.scr_showscore_spectator) && level.scr_showscore_spectator == 0 )
				{
					if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
					{
						player [[level.spawnIntermission]]();
						player closeMenu();
						player closeInGameMenu();
					
						continue;
					}
				}

				switchType = level.halftimeType;
				if ( switchType == "halftime" )
				{
					if ( level.roundLimit )
					{
						if ( (game["roundsplayed"] * 2) == level.roundLimit )
						switchType = "halftime";
						else
						switchType = "intermission";
					}
					else if ( level.scoreLimit )
					{
						if ( game["roundsplayed"] == (level.scoreLimit - 1) )
						switchType = "halftime";
						else
						switchType = "intermission";
					}
					else
					{
						switchType = "intermission";
					}
				}
				switch( switchType )
				{
					case "halftime":
						break;
					case "overtime":
						setDvar( "scr_league_ruleset", "Tie Breaker R24" );
						break;
					default:
						break;
				}
				player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( switchType, true, level.halftimeSubCaption );
				player thread promatch\_ranksystem::UpdateandSaveRank();
			}

			roundEndWait( level.halftimeRoundEndDelay);
		}		
		else if ( !hitRoundLimit() && !hitScoreLimit() && !level.displayRoundEndText && level.teamBased )
		{
			//END SWITCH
			//HALFTIME
						
			players = level.players;
			for ( index = 0; index < players.size; index++ )
			{
				player = players[index];

				if ( !isdefined(level.scr_showscore_spectator) || isdefined(level.scr_showscore_spectator) && level.scr_showscore_spectator == 0 )
				{
					if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
					{
						player [[level.spawnIntermission]]();
						continue;
					}
				}

				switchType = level.halftimeType;
				if ( switchType == "halftime" )
				{
					if ( level.roundLimit )
					{
						if ( (game["roundsplayed"] * 2) == level.roundLimit )
						switchType = "halftime";
						else
						switchType = "roundend";
					}
					else if ( level.scoreLimit )
					{
						if ( game["roundsplayed"] == (level.scoreLimit - 1) )
						switchType = "halftime";
						else
						switchTime = "roundend";
					}
				}
				switch( switchType )
				{
				case "halftime":
					break;
				case "overtime":
					break;
				}
				player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( switchType, true, endReasonText );
			}

			roundEndWait( level.halftimeRoundEndDelay, !(hitRoundLimit() || hitScoreLimit()) );
		}
		
		//acabaram os rounds aqui
		
		//FINALKILLCAM HUD
		setDvar( "scr_gameended", 2 );
		//adicionar funcoes para dar pontos aqui!
		if (hitRoundLimit() || hitScoreLimit())
		{
			setDvar( "scr_gameended", 1 );//round killcam
			setDvar( "sv_autodemorecord", 0 );//desativa demo ao fim do mapa
		}
		
		executePostRoundEvents();
	
		//Virada de jogo - apenas reinicia o round
		if ( !hitRoundLimit() && !hitScoreLimit() )
		{          	
			level notify ( "restarting" );
		//<save persistent> if true then player info is retained			
			map_restart( true );
			return;
		}
		
		//HALFTIME END
		if ( hitRoundLimit() )
		endReasonText = game["strings"]["round_limit_reached"];
		else if ( hitScoreLimit() )
		endReasonText = game["strings"]["score_limit_reached"];
		else
		endReasonText = game["strings"]["time_limit_reached"];
	}


	if ( ( level.teamBased ) && hitRoundLimit() ) 
	{
		if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
		winner = "tie";
		else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
		winner = "axis";
		else
		winner = "allies";
	}

	// catching gametype, since DM forceEnd sends winner as player entity, instead of string
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];

		if ( !isdefined(level.scr_showscore_spectator) || isdefined(level.scr_showscore_spectator) && level.scr_showscore_spectator == 0 )
		{
			if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
			{
				player [[level.spawnIntermission]](); 
				//player closeMenu();
				//player closeInGameMenu();
				continue;
			}
		}
		
		//atualiza stats	- sendo usado no ranksystem
		

			   
		//Result end round.
		if ( level.teamBased )
		{	
			winner = getWinningTeam();
			player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, false, endReasonText );
		}	
		else 
		{
			player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );
		}
	}
	
	
	
	
	/*//KNIFE ROUND
	if (level.scr_kniferound != 0)
	{
		//Reseta KnifeRound
		setDvar( "scr_kniferound", "0" );
		
		xwait(5.0,false);
		map_restart( false );
	}*/
	
	//FIM DO MAPA - server.cfg
	
	//verificar horario de eventos
	//if(getdvarint("scr_ativareventos") == 1)
	//HorariodeEvento();
	
	
	//para testes aqui
	//level.eventohorario = "16";
	//setDvar( "scr_eventorodando",1);

	//if(getdvarint("scr_eventorodando") == 1)
	//level.eventohorario = "ativo";	
	//else
	level.eventohorario = "";
	
	//espera de fim do round
	roundEndWait( level.postRoundTime);
	
	//trocando de lados
	level.intermission = true;
	level notify("intermission");

	//apenas no fim do mapa este codigo executa
	//regain players array since some might've disconnected during the wait above
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		//0306
		if ( player statGets("DEMOREC") == 1)
		{	
			player statSets("DEMOREC",0);
			player ExecClientCommand ("stoprecord");
			player iprintln( &"OW_DEMOOFF" );
		} 
		player closeMenu();
		player closeInGameMenu();
		player notify ( "reset_outcome" );
				
		player thread spawnIntermission();
		
		//2024 - novo menu final de jogo para FFA?
		//player setclientdvar( "g_scriptMainMenu", game["menu_endgame"] );
		//player openMenu( game[ "menu_endgame"] );
		//all moved to messagehud outcome
	}
	
	logString( "game ended" );
	
	//threads para executar e aplicar coisas para os jogadores tem que ser aqui !!
	thread SaveRankPointsonEndGame();	
	
	//fecha qualquer arquivo de log aberto!
	fs_fcloseall();
	//timer on vote menu
	level.finaltimer = 14.0;
	
	//novo tempo
	thread timeLimitClock_Intermission(level.finaltimer);
	
	//atualizar menu de rank
	//thread SortBestKD();
	
	thread UpdateBestMenus();
		
	//tempo aguardando o intermission (fim do mapa)	
	xwait(level.finaltimer, false );
	
	
	//--------GAME ENDED - acabou tudo--- qualquer outro codigo aqui

	if(level.cod_mode == "public")
	{
			
		if ( level.scr_eog_fastrestart == 1 ) 
		{	
			setDvar("setnextmap", "0");
			setDvar("scr_eog_fastrestart",0);
			level.scr_eog_fastrestart = 0;
			RankResetPunish();
			map_restart( false );
			return;
		}
		
		//reseta um proximo mapa forcado
		setDvar("setnextmap", "0");
	}
	
	//<save persistent> if true then player info is retained
	exitLevel( false );
}

getWinningTeam()
{
	if ( getGameScore( "allies" ) == getGameScore( "axis" ) )
	winner = "tie";
	else if ( getGameScore( "allies" ) > getGameScore( "axis" ) )
	winner = "allies";
	else
	winner = "axis";	
	return winner;
}


roundEndWait( defaultDelay,matchbonus )
{
	matchbonusx = matchbonus; //remover esta futuramente
	notifiesDone = false;
	while ( !notifiesDone )
	{
		players = level.players;
		notifiesDone = true;
		for ( index = 0; index < players.size; index++ )
		{
			if ( !isDefined( players[index].doingNotify ) || !players[index].doingNotify )
			continue;

			notifiesDone = false;
		}
		xwait( 0.5, false );
	}

	xwait( defaultDelay, false );
}


roundEndDOF( time )
{
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
}


getHighestScoringPlayer()
{
	players = level.players;
	winner = undefined;
	tie = false;

	for( i = 0; i < players.size; i++ )
	{
		if ( !isDefined( players[i].score ) )
		continue;

		if ( players[i].score < 1 )
		continue;

		if ( !isDefined( winner ) || players[i].score > winner.score )
		{
			winner = players[i];
			tie = false;
		}
		else if ( players[i].score == winner.score )
		{
			tie = true;
		}
	}

	if ( tie || !isDefined( winner ) )
	return undefined;
	else
	return winner;
}


checkTimeLimit()
{
	if ( isDefined( level.timeLimitOverride ) && level.timeLimitOverride )
	return;

	if ( !isDefined( game["state"] ) || game["state"] != "playing" )
	{
		setGameEndTime( 0 );
		return;
	}

	if ( level.timeLimit <= 0 )
	{
		if ( isDefined( level.startTime ) )
		setGameEndTime( level.startTime );
		else
		setGameEndTime( 0 );
		return;
	}

	if ( level.inPrematchPeriod )
	{
		setGameEndTime( 0 );
		return;
	}

	if ( !isdefined( level.startTime ) )
	return;

	timeLeft = getTimeRemaining();

	setGameEndTime( getTime() + int(timeLeft) );

	if ( timeLeft > 0 )
	return;

	[[level.onTimeLimit]]();
}

getTimeRemaining()
{
	return level.timeLimit * 60000 - getTimePassed();
}

checkScoreLimit()
{
	
	if ( isDefined( game["state"] ) && game["state"] != "playing" )
	return;

	if ( level.scoreLimit <= 0 )
	return;

	if ( level.teamBased )
	{
		if( game["teamScores"]["allies"] < level.scoreLimit && game["teamScores"]["axis"] < level.scoreLimit )
		return;
	}
	else
	{
		if ( !isPlayer( self ) )
		return;

		if ( self.score < level.scoreLimit )
		return;
	}

	[[level.onScoreLimit]]();
}


hitRoundLimit()
{
	if( level.roundLimit <= 0 )
	return false;

	return ( game["roundsplayed"] >= level.roundLimit );
}

hitScoreLimit()
{
	if( level.scoreLimit <= 0 )
	return false;

	if ( level.teamBased )
	{
		if( game["teamScores"]["allies"] >= level.scoreLimit || game["teamScores"]["axis"] >= level.scoreLimit )
		return true;
	}
	else
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( isDefined( player.score ) && player.score >= level.scorelimit )
			return true;
		}
	}
	return false;
}

registerRoundSwitchDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_roundswitch");

	level.roundswitchDvar = dvarString;
	level.roundswitchMin = minValue;
	level.roundswitchMax = maxValue;
	level.roundswitch = getdvarx( dvarString, "int", defaultValue, minValue, maxValue );
}

registerRoundLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_roundlimit");

	level.roundLimitDvar = dvarString;
	level.roundlimitMin = minValue;
	level.roundlimitMax = maxValue;
	level.roundLimit = getdvarx( dvarString, "int", defaultValue, minValue, maxValue );
	
	// Check if we need to increase the number of rounds due to overtime
	//if ( isDefined( game["_overtime"] ) && game["_overtime"] == true )
	//level.roundLimit++;
}


registerScoreLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_scorelimit");

	level.scoreLimitDvar = dvarString;
	level.scorelimitMin = minValue;
	level.scorelimitMax = maxValue;
	level.scoreLimit = getdvarx( dvarString, "int", defaultValue, minValue, maxValue );

	setDvar( "ui_scorelimit", level.scoreLimit );
}


registerTimeLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	level.timeLimitDvar = dvarString;
	level.timelimitMin = minValue;
	level.timelimitMax = maxValue;

	// Check if we need to use the timelimit due to overtime
	//if ( isDefined( game["_overtime"] ) && game["_overtime"] == true ) 
	//{
	//	promatch\_overtime::registerTimeLimitDvar();

	//} else 
	//{
		dvarString = ("scr_" + dvarString + "_timelimit");
		level.timelimit = getdvarx( dvarString, "float", defaultValue, minValue, maxValue );
		setDvar( "ui_timelimit", level.timelimit );
	//}
}


registerNumLivesDvar( dvarString, defaultValue, minValue, maxValue )
{
	level.numLivesDvar = dvarString;
	level.numLivesMin = minValue;
	level.numLivesMax = maxValue;

	// Check if we need to use the number of lives due to overtime
	//if ( isDefined( game["_overtime"] ) && game["_overtime"] ) 
	//{
	//	promatch\_overtime::registerNumLivesDvar();
	//} else {
		dvarString = ("scr_" + dvarString + "_numlives");
		level.numLives = getdvarx( dvarString, "int", defaultValue, minValue, maxValue );
	//}
}


getValueInRange( value, minValue, maxValue )
{
	if ( value > maxValue )
	return maxValue;
	else if ( value < minValue )
	return minValue;
	else
	return value;
}

updateGameTypeDvars()
{
	level endon ( "game_ended" );

	while ( isDefined( game["state"] ) && game["state"] == "playing" )
	{
		
		roundlimit = getdvarx( level.roundLimitDvar, "int", level.roundlimit, level.roundLimitMin, level.roundLimitMax );
			if ( roundlimit != level.roundlimit )
			{
				level.roundlimit = roundlimit;
				level notify ( "update_roundlimit" );
			}
			
			timeLimit = getdvarx( level.timeLimitDvar, "float", level.timeLimit, level.timeLimitMin, level.timeLimitMax );
			if ( timeLimit != level.timeLimit )
			{
				level.timeLimit = timeLimit;
				setDvar( "ui_timelimit", level.timeLimit );
				level notify ( "update_timelimit" );
			}
		
		thread checkTimeLimit();

		scoreLimit = getdvarx( level.scoreLimitDvar, "int", level.scoreLimit, level.scoreLimitMin, level.scoreLimitMax );
		if ( scoreLimit != level.scoreLimit )
		{
			level.scoreLimit = scoreLimit;
			setDvar( "ui_scorelimit", level.scoreLimit );
			level notify ( "update_scorelimit" );
		}
		
		thread checkScoreLimit();

		// make sure we check time limit right when game ends
		if ( isdefined( level.startTime ) )
		{
			if ( getTimeRemaining() < 3000 )
			{
				xwait( 0.1, false );
				continue;
			}
		}
		xwait( 1, false );
	}
}
//apertei  o botao autoassign !
menuAutoAssign()
{
	assignment = getTeamAssignment();
	
	self closeMenus();

	if ( isDefined( self.pers["team"] ) && (self.sessionstate == "playing" || self.sessionstate == "dead") )
	{
		if ( assignment == self.pers["team"] )
		{
			self beginClassChoice();
			return;
		}
		else
		{
			self.switching_teams = true;
			self.joining_team = assignment;
			self.leaving_team = self.pers["team"];
			self suicide();
		}
	}
	
	if(isDefined(self.squad))
	{
		//o player esta mudando via menu de time!	
		self thread promatch\_squadteam::leaveSquad();	
		self thread promatch\_squadteam::ResetSquadStats();		
	}
	
	self.pers["team"] = assignment;
	self.team = assignment;
	//self.pers["weapon"] = undefined;
	//self.pers["savedmodel"] = undefined;
	
	//self.pers["class"] = undefined;
	//self.class = undefined;
	
	self updateObjectiveText();

	//nao mover
	if ( level.teamBased )
	self.sessionteam = assignment;
	else
	self.sessionteam = "none";
	

	if ( !isAlive( self ) ) 
	self.statusicon = "hud_status_dead";

	self notify("joined_team");

	//self thread showPlayerJoinedTeam();
	self notify("end_respawn");

	self beginClassChoice();

	self setclientdvar( "g_scriptMainMenu", game["menu_class"] );
}

getTeamAssignment()
{
	teams[0] = "allies";
	teams[1] = "axis";
	
	if ( !level.teamBased )
		return teams[randomInt(2)];

	if ( self.sessionteam != "none" && self.sessionteam != "spectator" && self.sessionstate != "playing" && self.sessionstate != "dead" )
	{
		assignment = self.sessionteam;
	}
	else
	{
		playerCounts = self maps\mp\gametypes\_teams::CountPlayers();
				
		// if teams are equal return the team with the lowest score
		if ( playerCounts["allies"] == playerCounts["axis"] )
		{
			if( getTeamScore( "allies" ) == getTeamScore( "axis" ) )
				assignment = teams[randomInt(2)];
			else if ( getTeamScore( "allies" ) < getTeamScore( "axis" ) )
				assignment = "allies";
			else
				assignment = "axis";
		}
		else if( playerCounts["allies"] < playerCounts["axis"] )
		{
			assignment = "allies";
		}
		else
		{
			assignment = "axis";
		}
	}
	
	return assignment;
}

updateObjectiveText()
{
	if ( self.pers["team"] == "spectator" )
	{
		self setClientDvar( "cg_objectiveText", "" );
		return;
	}

	if( level.scorelimit > 0 )
	{
		self setclientdvar( "cg_objectiveText", getObjectiveScoreText( self.pers["team"] ), level.scorelimit );
	}
	else
	{
		self setclientdvar( "cg_objectiveText", getObjectiveText( self.pers["team"] ) );
	}
}

closeMenus()
{
	self closeMenu();
	self closeInGameMenu();
}
// ao estar em spec , forca o spawn, necessario
beginClassChoice( forceNewChoice )
{
	assert( self.pers["team"] == "axis" || self.pers["team"] == "allies" );

	team = self.pers["team"];
	
	self SetClassbyWeapon( "M4-CARBINE" );
}

showMainMenuForTeam()
{
	assert( self.pers["team"] == "axis" || self.pers["team"] == "allies" );

	team = self.pers["team"];

	self openMenu( game[ "menu_changeclass"] );
}





menuAllies()
{

	//bloqueia acesso a selecionar os times caso nao seja vip
	//if(level.cod_mode != "torneio" && !self.vipuser)
	//return;
			
	//if(self.pers["team"]=="allies")return;
	self closeMenus();

	if(self.pers["team"] != "allies")
	{
		if( level.teamBased && !maps\mp\gametypes\_teams::getJoinTeamPermissions( "allies" ) )
		{
			self openMenu("team_marinesopfor"); // = team_marinesopfor
			return;
		}

		// allow respawn when switching teams during grace period.
		if ( level.inGracePeriod && (!isdefined(self.hasDoneCombat) || !self.hasDoneCombat) )
		self.hasSpawned = false;

		if(self.sessionstate == "playing")
		{
			self.switching_teams = true;
			self.joining_team = "allies";
			self.leaving_team = self.pers["team"];
			//self.statusicon = "";
			self CreateItemIcon(true);
			self suicide();
		}

		self.pers["team"] = "allies";
		self.team = "allies";
		
		if(isDefined(self.squad))
		{
			//o player esta mudando via menu de time!	
			self thread promatch\_squadteam::leaveSquad();	
			self thread promatch\_squadteam::ResetSquadStats();		
		}
		
		if ( self resetPlayerClassOnTeamSwitch( false ) ) 
		{
			self.pers["class"] = undefined;
			self.class = undefined;
		}
		//self.pers["weapon"] = undefined;
		//self.pers["savedmodel"] = undefined;

		self updateObjectiveText();

		if ( level.teamBased )
		self.sessionteam = "allies";
		else
		self.sessionteam = "none";
		
		self setclientdvar("g_scriptMainMenu", game["menu_class"]);

		self notify("joined_team");	

		//self thread showPlayerJoinedTeam();
		self notify("end_respawn");
		
		self thread preventTeamSwitchExploit();
	}

		self beginClassChoice();
}


menuAxis()
{

	//bloqueia acesso a selecionar os times caso nao seja vip
	//if(level.cod_mode != "torneio" && !self.vipuser)
	//return;
	
	//if(self.pers["team"]=="axis")return;	
	self closeMenus();
	if(self.pers["team"] != "axis")
	{
		
		if( level.teamBased && !maps\mp\gametypes\_teams::getJoinTeamPermissions( "axis" ) )
		{
			self openMenu("team_marinesopfor");
			return;
		}

		// allow respawn when switching teams during grace period.
		if ( level.inGracePeriod && (!isdefined(self.hasDoneCombat) || !self.hasDoneCombat) )
		self.hasSpawned = false;

		if(self.sessionstate == "playing")
		{
			self.switching_teams = true;
			self.joining_team = "axis";
			self.leaving_team = self.pers["team"];
			self CreateItemIcon(true);
			
			self suicide();
		}

		if(isDefined(self.squad))
		{
			//o player esta mudando via menu de time!	
			self thread promatch\_squadteam::leaveSquad();	
			self thread promatch\_squadteam::ResetSquadStats();		
		}
	
		self.pers["team"] = "axis";
		self.team = "axis";
		
		if ( self resetPlayerClassOnTeamSwitch( false ) ) 
		{
			self.pers["class"] = undefined;
			self.class = undefined;
		}
		//self.pers["weapon"] = undefined;
		//self.pers["savedmodel"] = undefined;

		self updateObjectiveText();

		if ( level.teamBased )
		self.sessionteam = "axis";
		else
		self.sessionteam = "none";

		self setclientdvar("g_scriptMainMenu", game["menu_class"]);
		self notify("joined_team");
		self notify("end_respawn");
		
		self thread preventTeamSwitchExploit();//novo
	}

	self beginClassChoice();
}


menuSpectator()
{
	//if (self.pers["team"] == "spectator") 
	//return;
	
	//iprintln("MenuSPECC");
	
	self closeMenus();

	if(self.pers["team"] != "spectator")
	{
		if(isAlive(self))
		{
			self.switching_teams = true;
			self.joining_team = "spectator";
			self.leaving_team = self.pers["team"];
			self suicide();
		}
		
		if(self.sessionstate == "playing")
		{
			self.switching_teams = true;
			self.joining_team = "spectator";
			self.leaving_team = self.pers["team"];
			self suicide();
		}
		


		self.pers["team"] = "spectator";
		self.team = "spectator";
		self.pers["class"] = undefined;
		self.class = undefined;
		//self.pers["weapon"] = undefined;
		//self.pers["savedmodel"] = undefined;
		
		self updateObjectiveText();
		
		self.sessionteam = "spectator";
		[[level.spawnSpectator]]();
		
		self setclientdvar("g_scriptMainMenu", "team_marinesopfor");
		self notify("joined_spectators");

	}
}


//De onde vem isso?
menuClass( response )
{
	self closeMenus();

	assert( !level.oldschool );

	// this should probably be an assert
	if(!isDefined(self.pers["team"]) || (self.pers["team"] != "allies" && self.pers["team"] != "axis"))
	return;

	class = self maps\mp\gametypes\_class_unranked::getClassChoice( response );
	
	//primary = self maps\mp\gametypes\_class_unranked::getWeaponChoice( response );

	if ( class == "restricted" )
	{
		self beginClassChoice();
		return;
	}
	//TESTAR
	//if( (isDefined( self.pers["class"] ) && self.pers["class"] == class) && 
		//(isDefined( self.pers["primary"] ) && self.pers["primary"] == primary) )
		//return;

	if ( self.sessionstate == "playing" )
	{
		self.pers["class"] = class;
		self.class = class;
		//self.pers["primary"] = primary;
		//self.pers["weapon"] = undefined;

		if ( isDefined( game["state"] ) && game["state"] == "postgame" && ( level.atualgtype != "ass" || !isDefined( self.isVIP ) || !self.isVIP ) )
		return;
		
		//self iprintlnbold("CLASS");
		if ( ( level.inGracePeriod || level.inStrategyPeriod ) && !self.hasDoneCombat)
		{
			self thread deleteExplosives();

			self maps\mp\gametypes\_class_unranked::setClass( self.pers["class"] );
			self.tag_stowed_back = undefined;
			self.tag_stowed_hip = undefined;
			self maps\mp\gametypes\_class_unranked::giveLoadout( self.pers["team"], self.pers["class"] );
		}
		else
		{
			self iPrintLnBold( game["strings"]["change_class"] );
		}
	}
	else
	{
		self.pers["class"] = class;
		self.class = class;
		//self.pers["primary"] = primary;
		//self.pers["weapon"] = undefined;

		if ( isDefined( game["state"] ) && game["state"] == "postgame" )
		return;

		if ( isDefined( game["state"] ) && game["state"] == "playing" )
		self thread [[level.spawnClient]]();
	}

	level thread updateTeamStatus();

	self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
}


onXPEvent( event )
{
	self maps\mp\gametypes\_rank::giveRankXP( event );
}


givePlayerScore( event, player, victim )
{
	if ( level.overridePlayerScore )
	return;

	score = player.pers["score"];
	[[level.onPlayerScore]]( event, player, victim );

	if ( score == player.pers["score"] )
	return;

	player.score = player.pers["score"];
	
	if ( !level.teambased )
	thread sendUpdatedDMScores();

	player notify ( "update_playerscore_hud" );
	player thread checkScoreLimit();
}


default_onPlayerScore( event, player, victim )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( event );

	assert( isDefined( score ) );

	player.pers["score"] += score;
	

}


_setPlayerScore( player, score )
{
	if ( score == player.pers["score"] )
	return;

	player.pers["score"] = score;
	player.score = player.pers["score"];

	player notify ( "update_playerscore_hud" );
	player thread checkScoreLimit();
}


_getPlayerScore( player )
{
	return player.pers["score"];
}


giveTeamScore( event, team, player, victim )
{
	if ( level.overrideTeamScore )
	return;

	teamScore = game["teamScores"][team];
	[[level.onTeamScore]]( event, team, player, victim );

	if ( teamScore == game["teamScores"][team] )
	return;

	updateTeamScores( team );

	thread checkScoreLimit();
}

_setTeamScore( team, teamScore )
{
	if ( teamScore == game["teamScores"][team] )
	return;

	game["teamScores"][team] = teamScore;

	updateTeamScores( team );

	thread checkScoreLimit();
}

updateTeamScores( team1, team2 )
{
	setTeamScore( team1, getGameScore( team1 ) );
	if ( isdefined( team2 ) )
	setTeamScore( team2, getGameScore( team2 ) );

	if ( level.teambased )
	thread sendUpdatedTeamScores();
}


_getTeamScore( team )
{
	return game["teamScores"][team];
}


default_onTeamScore( event, team, player, victim )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( event );

	assert( isDefined( score ) );

	otherTeam = level.otherTeam[team];

	if ( game["teamScores"][team] > game["teamScores"][otherTeam] )
	level.wasWinning = team;
	else if ( game["teamScores"][otherTeam] > game["teamScores"][team] )
	level.wasWinning = otherTeam;

	game["teamScores"][team] += score;

	isWinning = "none";
	if ( game["teamScores"][team] > game["teamScores"][otherTeam] )
	isWinning = team;
	else if ( game["teamScores"][otherTeam] > game["teamScores"][team] )
	isWinning = otherTeam;

	if ( isWinning != "none" )
	level.wasWinning = isWinning;
}


sendUpdatedTeamScores()
{
	level notify("updating_scores");
	level endon("updating_scores");
	wait level.oneFrame;

	WaitTillSlowProcessAllowed();

	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[i] updateScores();
	}
}

sendUpdatedDMScores()
{
	level notify("updating_dm_scores");
	level endon("updating_dm_scores");
	wait level.oneFrame;

	WaitTillSlowProcessAllowed();

	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[i] updateDMScores();
		level.players[i].updatedDMScores = true;
	}
}

initPersStat( dataName )
{
	if( !isDefined( self.pers[dataName] ) )
	self.pers[dataName] = 0;
}


getPersStat( dataName )
{
	return self.pers[dataName];
}


incPersStat( dataName, increment )
{
	self.pers[dataName] += increment;	
}

UpdatePersStat( dataName, newvalue )
{
	self.pers[dataName] = newvalue;
}

updatePersRatio( ratio, num, denom )
{
	numValue = self statGets( num );
	denomValue = self statGets( denom );
	if ( denomValue == 0 )
	denomValue = 1;
	
	//tem que ser inteiro
	self statSets( ratio, int(numValue/denomValue));
}

//roda a cada spawn,morte,kill
updateTeamStatus()
{
	// run only once per frame, at the end of the frame.
	level notify("updating_team_status");
	level endon("updating_team_status");
	level endon ( "game_ended" );
	
	waittillframeend;

	wait 0;// Required for Callback_PlayerDisconnect to complete before updateTeamStatus can execute

	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
	return;

	resetTimeout();

	prof_begin( "updateTeamStatus" );
	
	level.playerCount["allies"] = 0;
	level.playerCount["axis"] = 0;
	level.aliveCount["allies"] = 0;
	level.aliveCount["axis"] = 0;
	level.playerLives["allies"] = 0;
	level.playerLives["axis"] = 0;
	level.lastAliveCount["allies"] = level.aliveCount["allies"];
	level.lastAliveCount["axis"] = level.aliveCount["axis"];
	level.alivePlayers["allies"] = [];
	level.alivePlayers["axis"] = [];
	level.activePlayers = [];

	//iprintln("---------------ATUALIZANDO PLAYERS VIVOS-----------------");

	setDvar( "ui_aliveallies", getteamplayersalive("allies") );
	setDvar( "ui_aliveaxis", getteamplayersalive("axis") );
	
	players = level.players;
	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		team = player.team;
		class = player.class;
		
		if(!isDefined(team))
		continue;
		
		if ( team != "spectator" && player isValidClass( player.class ) )
		{
			level.playerCount[team]++;

			if ( player.sessionstate == "playing" )
			{
				level.aliveCount[team]++;
				level.playerLives[team]++;
		
				if ( isAlive( player ) )
				{
					level.alivePlayers[team][level.alivePlayers.size] = player;
					level.activeplayers[ level.activeplayers.size ] = player;					
				}
			}
			else
			{
				if ( player maySpawn() )
				level.playerLives[team]++;
			}
			
			player notify("getteamplayersalive");
			
		}
	}
	
	
	
	if ( level.aliveCount["allies"] + level.aliveCount["axis"] > level.maxPlayerCount )
	level.maxPlayerCount = level.aliveCount["allies"] + level.aliveCount["axis"];

	if ( level.aliveCount["allies"] )
	level.everExisted["allies"] = true;
	if ( level.aliveCount["axis"] )
	level.everExisted["axis"] = true;
	
	prof_end( "updateTeamStatus" );

	level updateGameEvents();
}


isValidClass( class )
{
	if ( level.oldschool )
	{
		assert( !isdefined( class ) );
		return true;
	}
	
	return isdefined( class ) && class != "";
}

playTickingSound()
{
	self endon("death");
	self endon("stop_ticking");
	level endon("game_ended");
	
	time = level.bombTimer;
	
	while(1)
	{
		//self playSound( "ui_mp_suitcasebomb_timer" );
		
		
		//self playSound( "timer3" );
		
		if ( time > 30 )
		{
			
			time -= 1;
			wait 1;
		}
		else if ( time > 20 )
		{
			time -= 0.5;
			wait .5;
		}
		else if ( time > 10 )
		{
			time -= 0.4;
			wait .4;
		}
		else
		{
			time -= 0.3;
			wait .3;
		}
		
		self playSound( "timer2" );		
	}
}

stopTickingSound()
{
	self notify("stop_ticking");
}

timeLimitClock()
{
	level endon ( "game_ended" );
	wait level.oneFrame;

	clockObject = spawn( "script_origin", (0,0,0) );

	while ( isDefined( game["state"] ) && game["state"] == "playing" )
	{
		if ( !level.timerStopped && level.timeLimit )
		{
			timeLeft = getTimeRemaining() / 1000;
			timeLeftInt = int(timeLeft + 0.5); // adding .5 and flooring rounds it.

			if ( timeLeftInt >= 30 && timeLeftInt <= 60 )
			level notify ( "match_ending_soon" );

			if ( timeLeftInt <= 10 || (timeLeftInt <= 30 && timeLeftInt % 2 == 0) )
			{
				level notify ( "match_ending_very_soon" );
				// don't play a tick at exactly 0 seconds, that's when something should be happening!
				if ( !timeLeftInt )
				break;

				clockObject playSound( "ui_mp_timer_countdown" );
			}

			// synchronize to be exactly on the second
			if ( timeLeft - floor(timeLeft) >= 0.05 )
			xwait( timeLeft - floor(timeLeft), false );
		}

		xwait( 1.0, false );
	}
}


timeLimitClock_Intermission( waitTime )
{
	setGameEndTime( getTime() + int(waitTime*1000) );
	clockObject = spawn( "script_origin", (0,0,0) );
	
	while ( waitTime > 0 ) 
	{
		if ( waitTime <= 11 ) {
			clockObject playSound( "timer2" );
		}
		wait ( 1.0 );
		waitTime -= 1.0;
	}
	if( isDefined( clockObject ) )
		clockObject delete();
	
}


gameTimer()
{
	level endon ( "game_ended" );
	level waittill("prematch_over");
	level.startTime = getTime();
	level.discardTime = 0;

	if ( isDefined( game["roundMillisecondsAlreadyPassed"] ) )
	{
		level.startTime -= game["roundMillisecondsAlreadyPassed"];
		game["roundMillisecondsAlreadyPassed"] = undefined;
	}

	prevtime = gettime();

	while ( isDefined( game["state"] ) && game["state"] == "playing" )
	{
		if ( !level.timerStopped )
		{
			// the wait isn't always exactly 1 second. dunno why.
			game["timepassed"] += gettime() - prevtime;
		}
		prevtime = gettime();
		xwait( 1.0, false );
	}
}

getTimePassed()
{
	if ( !isDefined( level.startTime ) )
	return 0;

	if ( level.timerStopped )
	return (level.timerPauseTime - level.startTime) - level.discardTime;
	else
	return (gettime() - level.startTime) - level.discardTime;

}

pauseTimer()
{
	if ( level.timerStopped )
	return;

	level.timerStopped = true;
	level.timerPauseTime = gettime();
}


resumeTimer()
{
	if ( !level.timerStopped )
	return;

	level.timerStopped = false;
	level.discardTime += gettime() - level.timerPauseTime;
}


startGame()
{
	//ADD HUDS HERE
	thread gameTimer();
	
	level.timerStopped = false;
	
	level notify("prematch_start");
	
	serverHideHUD();
	
	thread maps\mp\gametypes\_spawnlogic::spawnPerFrameUpdate();

	// Do the readyup when the game just started or strategy time when is the second or so round
	if ( level.prematchPeriod > 0 )	
	{
		//if(level.cod_mode == "public" || level.cod_mode == "practice")
		promatch\_readyupperiod::init();
	} 
	else 
	{
		//if(level.cod_mode == "public" || level.cod_mode == "practice")
		promatch\_strategyperiod::init();
	}
	
	//Clear Players HUD
	for ( index = 0; index < level.players.size; index++ ) 
	{
		if ( !isDefined( level.players[index] ) )
		continue;			
		
		level.players[index] hideHUD();
		
	}	
	
	prematchPeriod();
	
	level notify("prematch_over");

	thread timeLimitClock();
	
	thread gracePeriod();
	
	//thread preventWallbangExploit();

	thread musicController();
	
	//reset killcam
	setDvar( "scr_gameended", 0 );	
	//reseta para recalcular scorebest
	thread ResetBestMenus();
}

preventWallbangExploit()
{
	level endon("game_ended");

	if ( isDefined( game["state"] ) && game["state"] != "playing" )
	return;

	//desativa
	level.preventWallbangExploit = true;
	
	endTime = GetTime() + 9000; 
	
	while ( endTime > GetTime() )
		xwait (1,false );
	
	//iprintln("PROTECTION WALL ENDED");
	
	//ativa novamente
	level.preventWallbangExploit = undefined;
}


musicController()
{
	level endon ( "game_ended" );
	
	thread suspenseMusic();
}

suspenseMusic()
{
	level endon ( "game_ended" );
	level endon ( "match_ending_soon" );

	numTracks = game["music"]["suspense"].size;
	for ( ;; )
	{
		wait( randomFloatRange( 120, 370 ) );

		playSoundOnPlayers( game["music"]["suspense"][randomInt(numTracks)] );
	}
}

waitForPlayers( maxTime )
{
	endTime = gettime() + maxTime * 1000 - 200;

	if ( level.teamBased )
	{
		while( (!level.everExisted[ "axis" ] || !level.everExisted[ "allies" ]) && gettime() < endTime )
		wait level.oneFrame;
	}else
	{
		while ( level.maxPlayerCount < 2 && gettime() < endTime )
		wait level.oneFrame;
	}
}

matchStartTimerSkip()
{
	visionSetNaked( getDvar( "mapname" ), 0 );
}

//PRIMEIRO SPAWN DO MAPA
prematchPeriod()
{
	level endon( "game_ended" );

	if ( level.prematchPeriod > 0 )
	{
		matchStartTimer();
	}
	else
	{
		matchStartTimerSkip();
	}

	level.inPrematchPeriod = false;
	
	serverShowHUD();

	for ( index = 0; index < level.players.size; index++ )
	{
		if ( !isDefined( level.players[index] ) )
		continue;
		
		level.players[index] showHUD();
		level.players[index] freezeControls( false );
		level.players[index] allowSprint(true);
		level.players[index] allowJump(true);
		level.players[index].canDoCombat = true;

		hintMessage = getObjectiveHintText( level.players[index].pers["team"] );
		
		if ( !isDefined( hintMessage ) || !level.players[index].hasSpawned )
		continue;

		level.players[index] setClientDvar( "scr_objectiveText", hintMessage );
		level.players[index] thread maps\mp\gametypes\_hud_message::hintMessage( hintMessage );

	}
	
	//Disable infinite ammo.
	setDvar( "player_sustainAmmo", 0 );
}

//PERIODO QUE O JOGADOR PODE TROCAR DE LADO OU ARMAS AO ENTRAR NO JOGO
gracePeriod()
{
	level endon("game_ended");

	xwait( level.gracePeriod, false );//fix erro spawn wait

	level notify ( "grace_period_ending" );
	wait level.oneFrame;

	level.inGracePeriod = false;

	if ( isDefined( game["state"] ) && game["state"] != "playing" )
	return;

	if ( level.numLives )
	{
		// Players on a team but without a weapon show as dead since they can not get in this round
		players = level.players;

		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];

			if ( !player.hasSpawned && player.sessionteam != "spectator" && !isAlive( player ) ) 
			self.statusicon = "hud_status_dead";			
		}
	}

	level thread updateTeamStatus();
}


announceRoundWinner( winner, delay )
{
	if ( delay > 0 )
	xwait( delay, false );

	if ( !isDefined( winner ) || isPlayer( winner ) )
	return;
}


announceGameWinner( winner, delay )
{
	if ( delay > 0 )
	xwait( delay, false );

	if ( !isDefined( winner ) || isPlayer( winner ) )
	return;
}


updateWinStats( winner )
{
	if(level.players.size < 6)
	return;
	
	if(level.atualgtype != "sd")
	return;
	
	winner statAdds("LOSSES",-1);
	winner statAdds( "WINS", 1 );	
	winner updatePersRatio( "WLRATIO", "WINS", "LOSSES" );
	
	winner SetRankPoints(20);
}


updateLossStats( loser )
{
	if(level.players.size < 6)
	return;
	
	if(level.atualgtype != "sd")
	return;
	
	loser statAdds( "LOSSES", 1 );
	loser updatePersRatio( "WLRATIO", "WINS", "LOSSES" );
	
	loser SetRankPoints(-15);
}


updateTieStats( loser )
{
}

updateWinLossStats( winner )
{
	//if ( level.roundLimit > 1 && !hitRoundLimit() )
	//return;
	
	//if(level.players.size < 8)
	//return;
	//pair 'undefined' and 'tie' 
	if(!isDefined(winner)) return;
	
	if(level.atualgtype != "sd")
	return;
	
	if ( !game["timepassed"] )
		return;

	players = level.players;

	if ( isPlayer( winner ) )
	{
		if ( level.hostForcedEnd && winner getEntityNumber() == 0 )
		return;
		//iprintln("WINNERNAME: " + winner);
		updateWinStats( winner );
	}
	else
	{
		for ( i = 0; i < players.size; i++ )
		{
			if ( !isDefined( players[i].pers["team"] ) )
			continue;

			if ( level.hostForcedEnd && players[i] getEntityNumber() == 0 )
			return;

			if ( winner == "tie" )
			updateTieStats( players[i] );
			else if ( players[i].pers["team"] == winner )
			updateWinStats( players[i] );
		}
	}
}

TimeUntilWaveSpawn( minimumWait )
{

	// the time we'll spawn if we only wait the minimum wait.
	earliestSpawnTime = gettime() + minimumWait * 1000;

	lastWaveTime = level.lastWave[self.pers["team"]];
	waveDelay = level.waveDelay[self.pers["team"]] * 1000;
	
	//divide by 0 fix
	if(waveDelay == 0 ) 
	return 0;
		
	// the number of waves that will have passed since the last wave happened, when the minimum wait is over.
	numWavesPassedEarliestSpawnTime = (earliestSpawnTime - lastWaveTime) / waveDelay;
	// rounded up
	numWaves = ceil( numWavesPassedEarliestSpawnTime );

	timeOfSpawn = lastWaveTime + numWaves * waveDelay;

	// avoid spawning everyone on the same frame
	if ( isdefined( self.waveSpawnIndex ) )
	timeOfSpawn += 50 * self.waveSpawnIndex;

	return (timeOfSpawn - gettime()) / 1000;
}

TeamKillDelay()
{
	teamkills = self.pers["teamkills"];
	if ( level.minimumAllowedTeamKills < 0 || teamkills <= level.minimumAllowedTeamKills )
	return 0;
	
	exceeded = (teamkills - level.minimumAllowedTeamKills);
	
	return 2 * exceeded;
}


TimeUntilSpawn( includeTeamkillDelay )
{
	if ( (level.inGracePeriod && !self.hasSpawned) || level.gameended )//207
	return 0;

	respawnDelay = 0;
	if ( self.hasSpawned )
	{
		result = self [[level.onRespawnDelay]]();
		
		if ( isDefined( result ) )
		respawnDelay = result;
		else
		respawnDelay = getdvarx( "scr_" + level.atualgtype + "_playerrespawndelay", "float", 5, -1, 300 );

		if ( level.hardcoreMode && !isDefined( result ) && !respawnDelay )
		respawnDelay = 2.0;
		
		if (level.cod_mode == "practice")//ADDED
		respawnDelay = -1;

		if ( includeTeamkillDelay && self.teamKillPunish )
		respawnDelay += TeamKillDelay();
	}
	
	//verificar isso no KC
	waveBased = (getdvarx( "scr_" + level.atualgtype + "_waverespawndelay", "float", 0.0, 0.0, 300 ) > 0);

	if ( waveBased )
	return self TimeUntilWaveSpawn( respawnDelay );

	return respawnDelay;
}


maySpawn()
{
	if ( level.inOvertime )
	return false;

	if ( level.inReadyUpPeriod || level.inStrategyPeriod || level.inGracePeriod )
	return true;

	if ( level.numLives)
	{
		if (gameHasStarted() && (!self.pers["lives"] || (!level.inGracePeriod && !self.hasSpawned)))
		return false;
	}

	return true;
}

spawnClient( timeAlreadyPassed )
{
	assert(	isDefined( self.team ) );
	
	assert(	isValidClass( self.class ) );

	if ( !self maySpawn() )
	{
		currentorigin =	self.origin;
		currentangles =	self.angles;

		shouldShowRespawnMessage = true;
		if ( level.roundLimit > 1 && game["roundsplayed"] >= (level.roundLimit - 1) )
		shouldShowRespawnMessage = false;
		if ( level.scoreLimit > 1 && level.teambased && game["teamScores"]["allies"] >= level.scoreLimit - 1 && game["teamScores"]["axis"] >= level.scoreLimit - 1 )
		shouldShowRespawnMessage = false;
		if ( shouldShowRespawnMessage )
		{
			setLowerMessage( game["strings"]["spawn_next_round"] );
			self thread removeSpawnMessageShortly( 3 );
		}
		self thread	[[level.spawnSpectator]](self.origin,self.angles);
		return;
	}

	if ( isdefined(self.waitingToSpawn) && self.waitingToSpawn )
	return;

	self.waitingToSpawn = true;

	self waitAndSpawnClient( timeAlreadyPassed );

	if ( isdefined( self ) )
	self.waitingToSpawn = false;
}

waitAndSpawnClient( timeAlreadyPassed )
{
	self endon ( "disconnect" );
	self endon ( "end_respawn" );
	self endon ( "game_ended" );

	if ( !isdefined( timeAlreadyPassed ) )
	timeAlreadyPassed = 0;

	spawnedAsSpectator = false;

	if ( self.teamKillPunish )
	{
		teamKillDelay = TeamKillDelay();
		if ( teamKillDelay > timeAlreadyPassed )
		{
			teamKillDelay -= timeAlreadyPassed;
			timeAlreadyPassed = 0;
		}
		else
		{
			timeAlreadyPassed -= teamKillDelay;
			teamKillDelay = 0;
		}

		if ( teamKillDelay > 0 )
		{
			setLowerMessage( &"MP_FRIENDLY_FIRE_WILL_NOT", teamKillDelay );

			self thread	respawn_asSpectator( self.origin + (0, 0, 60), self.angles );
			spawnedAsSpectator = true;

			xwait( teamKillDelay, false );
		}

		self.teamKillPunish = false;
	}

	if ( !isdefined( self.waveSpawnIndex ) && isdefined( level.wavePlayerSpawnIndex[self.team] ) )
	{
		self.waveSpawnIndex = level.wavePlayerSpawnIndex[self.team];
		level.wavePlayerSpawnIndex[self.team]++;
	}

	timeUntilSpawn = self TimeUntilSpawn( false );
	if ( timeUntilSpawn > timeAlreadyPassed )
	{
		timeUntilSpawn -= timeAlreadyPassed;
		timeAlreadyPassed = 0;
	}
	else
	{
		timeAlreadyPassed -= timeUntilSpawn;
		timeUntilSpawn = 0;
	}
	//bug de spawn aqui ?
	if ( timeUntilSpawn > 0 )
	{
		// spawn player into spectator on death during respawn delay, if he switches teams during this time, he will respawn next round
		setLowerMessage( game["strings"]["waiting_to_spawn"], timeUntilSpawn );

		if ( !spawnedAsSpectator )
		self thread	respawn_asSpectator( self.origin + (0, 0, 60), self.angles );
		spawnedAsSpectator = true;

		self waitForTimeOrNotify( timeUntilSpawn, "force_spawn" );
	}

	waveBased = (getdvarx( "scr_" + level.atualgtype + "_waverespawndelay", "float", 0, 0, 300 ) > 0);
	
	if ( level.scr_player_forcerespawn == 0 && self.hasSpawned && !waveBased )
	{
		if ( !spawnedAsSpectator )
		self thread	respawn_asSpectator( self.origin + (0, 0, 60), self.angles );
		
		spawnedAsSpectator = true;

		self waitRespawnButton();
	}

	self.waitingToSpawn = false;

	self clearLowerMessage();

	self.waveSpawnIndex = undefined;

	self thread	[[level.spawnPlayer]]();
}


waitForTimeOrNotify( time, notifyname )
{
	self endon( notifyname );

	finishWait = promatch\_timer::getTimePassed() + time * 1000;
	
	while ( isDefined( level.startTime ) && finishWait > promatch\_timer::getTimePassed() ) 
	{
		wait level.oneFrame;
		if ( level.inTimeoutPeriod ) 
		{
			self.lowerMessage.alpha = 0;
			self.lowerTimer.alpha = 0;
			xwait( 0.1, true );
			self.lowerTimer setTimer( ( finishWait - promatch\_timer::getTimePassed() ) / 1000 );
			self.lowerMessage.alpha = 1;
			self.lowerTimer.alpha = 1;
		}
	}
}


removeSpawnMessageShortly( delay )
{
	self endon("disconnect");

	waittillframeend; // so we don't endon the end_respawn from spawning as a spectator

	self endon("end_respawn");

	xwait( delay, false );

	self clearLowerMessage( 2.0 );
}

//REPETE A CADA ROUND
//PRECACHE ICONES AQUI
Callback_StartGameType()
{
	level.prematchPeriod = 0;
	level.prematchPeriodEnd = 0;
	level.intermission = false;
	
	registerPostRoundEvent( promatch\_finalkillcam::postRoundFinalKillcam );	
		
	game["state"] = "playing";//force

	if ( !isDefined( game["gamestarted"] ) )
	{
		if ( !isDefined( game["attackers"] ) )
		game["attackers"] = "axis";
		if (  !isDefined( game["defenders"] ) )
		game["defenders"] = "allies";

		if ( isDefined( game["attackers"] ) && game["attackers"] != "axis" )
		game["attackers"] = "axis";
		
		if (  isDefined( game["defenders"] ) && game["defenders"] != "allies" )
		game["defenders"] = "allies";
		
		if ( !isDefined( game["state"] ) )
		game["state"] = "playing";
		
		precacheStatusIcon( "hud_status_dead" );
		
		precacheShader( "white" );
		precacheShader( "black" );
		
		 // Precache INSIGNIAS
		//for( insig = 1; insig < 21; insig++ ) 
		//{
		//	precacheShader( "insignia" + insig );
		//}
		
		//Healthoverlay
		
		precacheShader( "specialty_weapon_rpg" );//CAPACETE
		precacheShader( "specialty_armorvest" );//ARMOR
		precacheShader( "specialty_longersprint" );//HEALTH
		precacheShader( "specialty_quieter" );//ALIADO MORTO
		
		precacheShader( "specialty_fastreload" );//TEAMBUFF
		precacheShader( "compassping_enemyfiring" );
		precacheShader( "compassping_player" ); //added para o medic
		precacheRumble( "damage_heavy" );
		
		//sprays
		//precacheShader("gfx_spray0");
		//precacheShader( "spray0_menu" + spray );
		for( spray = 0; spray <= level.spraysnum; spray++ ) 
		{
			precacheShader( "gfx_spray" + spray );
		}
		
		//icones no TAB
		precacheStatusIcon( "squad_a" );
		precacheStatusIcon( "squad_b" );
		precacheStatusIcon( "squad_c" );
		precacheStatusIcon( "squad_d" );	
		precacheStatusIcon( "squad_e" );
		
		//necessario para o hud vivos mortos!!
		makeDvarServerInfo( "ui_aliveaxis", 0 );
		makeDvarServerInfo( "ui_aliveallies", 0 );

		game["music"]["suspense"] = [];
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_01";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_02";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_03";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_04";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_05";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_06";
		
		//dialog bomb
		game["dialog"]["bomb_defused"] = "bomb_defused";
		game["dialog"]["bomb_planted"] = "bomb_planted";
		game["dialog"]["nuke_friendly"] = "nuke_friendly";
		game["dialog"]["nuke_enemy"] = "nuke_enemy";
		game["dialog"]["nuke_mp"] = "nuke_ready";
	
		[[level.onPrecacheGameType]]();
		
		game["gamestarted"] = true;
		game["teamScores"]["allies"] = 0;
		game["teamScores"]["axis"] = 0;

		if(level.cod_mode == "practice")
		{
			level.prematchPeriod = 1;
			level.prematchPeriodEnd = 1;
		}
		else
		{
			// first round, so set up prematch
			level.prematchPeriod = 25;
			level.prematchPeriodEnd = 15;
			
			if(level.betatest)
			{
				level.prematchPeriod = 4;
				level.prematchPeriodEnd = 4;
			}
		}
		
		
	} 
	else 
	{
		if ( isDefined( game["readyupperiod"] ) && game["readyupperiod"] ) 
		{
			level.prematchPeriod = level.scr_game_playerwaittime;
			level.prematchPeriodEnd = level.scr_game_matchstarttime;
		} 
		else 
		{
			if ( getdvarx( "scr_match_readyup_period", "int", 0, 0, 1 ) == 1 && getdvarx( "scr_match_readyup_period_onsideswitch", "int", 0, 0, 1 ) == 1 ) 
			{
				if ( isDefined( level.roundSwitch ) && level.roundSwitch && game["roundsplayed"] && ( game["roundsplayed"] % level.roundswitch == 0 ) ) 
				{
					if(level.cod_mode == "practice")
					{
						level.prematchPeriod = 1;
						level.prematchPeriodEnd = 1;
					}
					else
					{
						level.prematchPeriod = level.scr_game_playerwaittime;
						level.prematchPeriodEnd = level.scr_game_matchstarttime;
					}
				}
			}
		}		
	
	}

	if(!isDefined(game["timepassed"]))
	game["timepassed"] = 0;

	if(!isDefined(game["roundsplayed"]))
	game["roundsplayed"] = 0;

	level.skipVote = false;
	level.gameEnded = false;
	level.teamSpawnPoints["axis"] = [];
	level.teamSpawnPoints["allies"] = [];
	level.objIDStart = 0;
	level.forcedEnd = false;
	level.hostForcedEnd = false;

	// this gets set to false when someone takes damage or a gametype-specific event happens.
	level.useStartSpawns = true;

	// set to 0 to disable
	if(level.cod_mode == "practice")
	setdvar( "scr_teamKillPunishCount", "0" );
	
	if ( getdvar( "scr_teamKillPunishCount" ) == "" )
	setdvar( "scr_teamKillPunishCount", "2" );

	level.minimumAllowedTeamKills = getdvarint( "scr_teamKillPunishCount" ) - 1; // punishment starts at the next one
	//[EVENTS TREADS]
	
	promatch\_eventmanager::eventManagerInit();
	
	//Threadings
	thread maps\mp\gametypes\_menus_unranked::init();
	thread maps\mp\gametypes\_class_unranked::init();
	thread maps\mp\gametypes\_hud::init();
	thread maps\mp\gametypes\_scoreboard::init();
	thread maps\mp\gametypes\_rank::init();	
	thread maps\mp\gametypes\_modwarfare::init();	
	thread maps\mp\gametypes\_serversettings::init();
	thread maps\mp\gametypes\_clientids::init();
	thread maps\mp\gametypes\_teams::init();
	thread maps\mp\gametypes\_weapons::init();	
	thread maps\mp\gametypes\_killcam::init();
	thread maps\mp\gametypes\_shellshock::init();
	thread maps\mp\gametypes\_deathicons::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	thread maps\mp\gametypes\_spectating::init();
	thread maps\mp\gametypes\_objpoints::init();
	thread maps\mp\gametypes\_gameobjects::init();
	thread maps\mp\gametypes\_spawnlogic::init();
	thread maps\mp\gametypes\_oldschool::init();
	thread maps\mp\gametypes\_hud_message::init();
	thread maps\mp\gametypes\_quickmessages::init();
	thread maps\mp\_explosive_barrels::main();	
		
	// Main Inits from MOD not thread
	promatch\_globalinit::init();
	thread promatch\_squadteam::init();
	thread maps\mp\gametypes\_healthoverlay::init();
	
	stringNames = getArrayKeys( game["strings"] );
	for ( index = 0; index < stringNames.size; index++ )
	{
		if ( !isString( game["strings"][stringNames[index]] ) )
		{
			precacheString( game["strings"][stringNames[index]] );
		}
	}
		
	//practice mode init
	if (level.cod_mode == "practice")
	{ 
		thread promatch\_nadepractice::init(); 
	}

	level.maxPlayerCount = 0;
	level.playerCount["allies"] = 0;
	level.playerCount["axis"] = 0;
	level.aliveCount["allies"] = 0;
	level.aliveCount["axis"] = 0;
	level.playerLives["allies"] = 0;
	level.playerLives["axis"] = 0;
	level.lastAliveCount["allies"] = 0;
	level.lastAliveCount["axis"] = 0;
	level.everExisted["allies"] = false;
	level.everExisted["axis"] = false;
	level.waveDelay["allies"] = 0;
	level.waveDelay["axis"] = 0;
	level.lastWave["allies"] = 0;
	level.lastWave["axis"] = 0;
	level.wavePlayerSpawnIndex["allies"] = 0;
	level.wavePlayerSpawnIndex["axis"] = 0;
	level.alivePlayers["allies"] = [];
	level.alivePlayers["axis"] = [];
	level.activePlayers = [];

	if ( !isDefined( level.timeLimit ) )
	registerTimeLimitDvar( "default", 10, 1, 1440 );

	if ( !isDefined( level.scoreLimit ) )
	registerScoreLimitDvar( "default", 100, 1, 500 );

	if ( !isDefined( level.roundLimit ) )
	registerRoundLimitDvar( "default", 1, 0, 24 );

	makeDvarServerInfo( "ui_scorelimit" );
	makeDvarServerInfo( "ui_timelimit" );
	
	//makeDvarServerInfo( "ui_allow_classchange", getDvar( "ui_allow_classchange" ) );
	//makeDvarServerInfo( "ui_allow_teamchange", getDvar( "ui_allow_teamchange" ) );

	if ( level.numlives )
	setdvar( "g_deadChat", 0 );
	else
	setdvar( "g_deadChat", 1 );

	waveDelay = getdvarx( "scr_" + level.atualgtype + "_waverespawndelay", "float", 0, 0, 300 );
	
	if ( waveDelay )
	{
		level.waveDelay["allies"] = waveDelay;
		level.waveDelay["axis"] = waveDelay;
		level.lastWave["allies"] = 0;
		level.lastWave["axis"] = 0;

		level thread [[level.waveSpawnTimer]]();
	}

	level.inTimeoutPeriod = false;
	level.inReadyUpPeriod = false;
	level.inStrategyPeriod = false;
	level.inPrematchPeriod = true;
	level.fieldOrdersActive = false;

	
	//usado apenas para por dar spawn
	if(level.cod_mode == "practice")
	level.gracePeriod = 1;
	else
		level.gracePeriod = 6;
	
	if(level.cod_mode == "torneio")
	level.gracePeriod = 0;

	level.inGracePeriod = true;
	level.roundEndDelay = 5;//final do mapa
	level.halftimeRoundEndDelay = 5;

	if (level.teamBased )
	updateTeamScores( "axis", "allies" );

	if ( !level.teamBased )
	thread initialDMScoreUpdate();


	[[level.onStartGameType]]();
	
	thread startGame();
	
	level thread updateGameTypeDvars();

}

initialDMScoreUpdate()
{
	xwait( 0.2, false );
	numSent = 0;
	while(1)
	{
		didAny = false;

		players = level.players;
		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];

			if ( !isdefined( player ) )
			continue;

			if ( isdefined( player.updatedDMScores ) )
			continue;

			player.updatedDMScores = true;
			player updateDMScores();

			didAny = true;
			xwait( 0.5, false );
		}

		if ( !didAny )
		xwait( 3, false ); // let more players connect
	}
}

checkRoundSwitch()
{
	if ( !level.teamBased )
		return false;
		
	if ( !isdefined( level.roundSwitch ) || !level.roundSwitch )
	return false;
	
	if ( !isdefined( level.onRoundSwitch ) )
	return false;

	//ShowDebug("checkRoundSwitch:",game["roundsplayed"]);
	//ShowDebug("halftimecount:",level.halftimecount);

	/*if(level.halftimecount == 4)
	{
		level.halftimecount = 0;
		onRoundSwitch();
		return true;
	}*/
	

	assert( game["roundsplayed"] > 0 );	
	if ( game["roundsplayed"] % level.roundswitch == 0 )
	{
		onRoundSwitch();
		return true;
	}

	return false;
}

onRoundSwitch()
{
		if ( !isDefined( game["switchedsides"] ) )//207
		game["switchedsides"] = false;

		tempscores = game["teamScores"]["allies"];
		game["teamScores"]["allies"] = game["teamScores"]["axis"];
		game["teamScores"]["axis"] = tempscores;
		updateTeamScores( "allies", "axis" );

		for( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( player.pers["team"] != "spectator" ) 
			{
				player switchPlayerTeam( level.otherTeam[ player.pers["team"] ], true );				
			}
		}		
}

getGameScore( team )
{
	return game["teamScores"][team];
}


listenForGameEnd()
{
	self waittill( "host_sucks_end_game" );
	level.skipVote = true;
	if ( !level.gameEnded )
	level thread maps\mp\gametypes\_globallogic::forceEnd();
}

//CONTROLE DE SCORES - definiçoes necessarias
initPlayerStats()
{
	//inicializa scores 1x
	self initPersStat( "score" );
	self initPersStat( "deaths" );
	self initPersStat( "suicides" );
	self initPersStat( "kills" );
	self initPersStat( "headshots" );
	self initPersStat( "assists" );
	self initPersStat( "teamkills" );
	
	//SISTEMA DE RANK
	self initPersStat( "rankpoints" );
	self initPersStat( "accuracy" );
	self initPersStat( "rank" );
	//controle de ping alto nos votos
	self initPersStat( "ping" );
	//pocketround $$ per map
	self initPersStat( "roundpocket" );
	//SELF INITS
	self.score = self.pers["score"];
	self.deaths = self.pers["deaths"];
	self.suicides = self.pers["suicides"];
	self.kills = self.pers["kills"];
	self.headshots = self.pers["headshots"];
	self.assists = self.pers["assists"];
	self.mykdratio = 0;
	self.isplayer = true;//define o jogador como um player e n objeto
	self.teamKillPunish = false;
	self.top_streak = 0;
	self.mapheadshots = 0;
	self.teamkills = 0;
	
	if ( level.minimumAllowedTeamKills >= 0 && self.pers["teamkills"] > level.minimumAllowedTeamKills )
	self thread reduceTeamKillsOverTime();
	
	self.killedPlayers = [];
	self.killedPlayersCurrent = [];
	self.killedBy = [];
	self.lastKilledBy = undefined;//payback
	self.leaderDialogQueue = [];
	self.leaderDialogActive = false;
	self.leaderDialogGroups = [];
	self.leaderDialogGroup = "";
	self.cur_kill_streak = 0;
	self.cur_buff_streak = 0;
	self.cur_death_streak = 0;
	self.death_streak = 0; 
	self.kill_streak = 0;
	self.lastGrenadeSuicideTime = -1;
	self.teamkillsThisRound = 0;
	//=======SPECIAL STREAKS======
	
	self.deathspawn = undefined;
	self.onehs = false;
	//====CLASS RELATED
	self.isSniper = false;
	
	//=======ESPECIAL=======
	self.clanmember = self getstat(3302) != 0;
	self.custommember = self getstat(3471) != 0;
	self.highquality = self getstat(3400) != 0;
	self.pcdaxuxa = self getstat(3310) != 0;
	self.animaldeaths = self getstat(3497) != 0;
	self.binduser = self getstat(3489) != 0;
	self.admin = self getstat(3473) != 0;
	self.voteclick = 0;//vote menu limit

	self.ffkiller = false;
	self.winnerdm = undefined;
	self.helihits = 0;//quem acertou mais o heli
	self.pers["lives"] = level.numLives;
	self.hasSpawned = false;
	self.waitingToSpawn = false;
	self.deathCount = 0;
	self.lastKillTime = -1;//NOVO
	self.wasAliveAtMatchStart = false;
	self.ptracer = false; //0308
	//time registers
	self.timePlayed["allies"] = 0;
	self.timePlayed["axis"] = 0;
	self.timePlayed["total"] = 0;
	self.beheaded = false;	
}

Callback_PlayerConnect()
{
	thread notifyConnecting();
	
	self waittill( "begin" );
	
	waittillframeend;//Alterando este para outro local causa erros no ACP
	
	level notify( "connected", self );
	
	self.connected = true;//FOR DISCONNECT

	//Logging the Join Match
	lpGuid = self getguid();
	lpselfnum = self getEntityNumber();
	logPrint("J;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");
	
	if (!isDefined( self.pers["isBot"] ))
	{	
		//configuraçao da profile nova
		self promatch\_playerdvars::SetFirstConnectConfigs();//207
		
		//testar migraçao aqui - NAO USAR THREAD PARA ATUALIZAR AS FUNCOES NOVAS ANTES DE LER
		self promatch\_playerdvars::VersionUpgrade();		
	}
	
	// only print that we connected if we haven't connected in a previous round
	if(!isdefined(self.pers["score"]))
	{
		self thread ResetBestMedals();
		self thread ResetTimedItens();		
		self.statusicon = "";//RESET ICON BUG				
	}
		
	if ( level.numLives )
	{
		self setClientDvars("cg_deadChatWithDead", 1,
		"cg_deadChatWithTeam", 0,
		"cg_deadHearTeamLiving", 0,
		"cg_deadHearAllLiving", 0,
		"cg_everyoneHearsEveryone", 0 );
	}
	else
	{
		self setClientDvars("cg_deadChatWithDead", 0,
		"cg_deadChatWithTeam", 1,
		"cg_deadHearTeamLiving", 1,
		"cg_deadHearAllLiving", 0,
		"cg_everyoneHearsEveryone", 0 );
	}
	
	initPlayerStats();
	
	self thread maps\mp\_flashgrenades::monitorFlash();	
	
	//atualiza o numero de jogadores na array
	level.players[level.players.size] = self;

	//update scores
	if ( level.teambased ) 
	self updateScores();

	// When joining a game in progress, if the game is at the post game state (scoreboard) the connecting player should spawn into intermission
	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
	{		
		self.pers["team"] = "spectator";
		self.team = "spectator";
		self.sessionstate = "dead";

		self hideHUD();

		[[level.spawnIntermission]]();
		self closeMenu();
		self closeInGameMenu();
	
		return;
	}
	
	//ver pq este roda logo ao concetar dando ponto negativo
	updateLossStats( self );

	//REDEFINE ALL PERKS
	self ResetUpgradesStatus();
	
	self thread promatch\_playerdvars::LoadPlayerConfigStats();

	level endon( "game_ended" );

	if ( isDefined( self.pers["team"] ) ) self.team = self.pers["team"];	
	if ( isDefined( self.pers["class"] ) ) self.class = self.pers["class"];
	
	if ( !isDefined( self.pers["team"] ) )
	{
		// Don't set .sessionteam until we've gotten the assigned team from code,
		// because it overrides the assigned team.
		//self.pers["team"] = "spectator";
		self.pers["team"]="spectator";
		self.team = "spectator";
		self.sessionstate = "dead";
			
		//ATUALIZAR TEXTOS
		self updateObjectiveText();
		
		//==========================================================
		//================APOS CONECTAR CLIENT ESTA NO SPEC=========
		//==========================================================
		[[level.spawnSpectator]]();
		
		//Abre o menu team_marinesopfor = menu inicial  (Attack Autoscolher Defense)
		self setclientdvar( "g_scriptMainMenu", "team_marinesopfor" );
		self openMenu( "team_marinesopfor" );
		
		if ( self.pers["team"] == "spectator" )//Espec do proprio time(morto)
		{
			self.sessionteam = "spectator";
			self.statusicon = "hud_status_dead";//fix 207
		}

		if ( level.teamBased )
		{
			// set team and spectate permissions so the map shows waypoint info on connect
			self.sessionteam = self.pers["team"];
			
			if ( !isAlive( self ) ) 
			{
				if ( self.pers["team"] != "spectator" ) 
				self.statusicon = "hud_status_dead";
			}

			// Check if this player can free spectate
			self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
		}
	}  
	else if ( self.pers["team"] == "spectator" )
	{	//0308
		//apos os rounds codigos de spec sao aqui

		self setclientdvar( "g_scriptMainMenu", "team_marinesopfor" );
		self.sessionteam = "spectator";
		self.sessionstate = "spectator";
		self.statusicon = "hud_status_dead";
		
		[[level.spawnSpectator]]();
	}
	else
	{
		self.sessionteam = self.pers["team"];
		self.sessionstate = "dead";
		self.statusicon = "hud_status_dead";//fix dead icon bug
		self updateObjectiveText();

		[[level.spawnSpectator]]();

		if ( isValidClass( self.pers["class"] ) )
		{
			self thread [[level.spawnClient]]();
		}
		else
		{
			self showMainMenuForTeam();
		}

		self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
	}
		
	if ( level.inPrematchPeriod ) 
	{
		self hideHUD();
	} 
	else 
	{
		self showHUD();
	}
	
	if ( isDefined( self.pers["isBot"] ) && self.pers["isBot"] )
	return;
}


ResetTimedItens()
{

	//DEMO STOP
	if (statGets("DEMOREC") != 0)
	{	
		self statSets("DEMOREC",0);
		self ExecClientCommand ("stoprecord");
		exec("stoprecord " + self.name);
	}
		
	//RESETITENS
	//ApplyItemtoPlayer
	self setStat(2380,0); 
	self setStat(2381,0);
	self setStat(2382,0);
	self setStat(2383,0);
	//fmj hpammo
	self setStat(2384,0);
	self setStat(2385,0);
	

	
	self setStat(2387,0);
	self setStat(2388,0);
	
	self setStat(2389,0);
	self setStat(2387,0);
	self setStat(2388,0);
	
	self setStat(2390,0);//buydecoy	
	self setStat(2391,0);//kitarmor
	self setStat(2392,0);//heavykevlar	
	self setStat(2393,0);//sensor
	self setStat(2386,0);//firearrow
	self setStat(2394,0);//poisonarrow
	self setStat(2395,0);//shockarrow
	self setStat(2396,0);//carepackage
	self setStat(2397,0);//com_drop_rope
	self setStat(2398,0);//tombs
	
	self setStat(2401,0);//greensmoke
	self setStat(2402,0);//orangesmoke
	self setStat(2403,0);//bluesmoke
	self setStat(2404,0);//redsmoke
	
	self setStat(2407,0);//implodernade
	
	//firstcheck
	self setStat(3488,0);	
	//SQUADS
	self setStat(3163,0);
	self setStat(3164,0);//lider
	
	//limpar autocompras
	self setStat(2370,0);
	self setStat(2371,0);
	self setStat(2372,0);
	self setStat(2373,0);
	self setStat(2374,0);
	self setStat(2375,0);
	
	//TK
	self setStat(3300,0);
	//HS per map
	self setStat(2302,0);
	//killstreaks map
	self setStat(2303,0);
	
	//2024 
	self setStat(3477,0);//pocketround
}

forceSpawn()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "spawned" );

	xwait( 60.0, false );

	if ( self.hasSpawned )
	return;

	if ( self.pers["team"] == "spectator" )
	return;

	if ( !isValidClass( self.pers["class"] ) )
	{
		self.pers["class"] = "ASSAULT";
		self.class = self.pers["class"];
	}

	self closeMenus();
	self thread [[level.spawnClient]]();
}

Callback_PlayerDisconnect()
{
	if ( !isDefined( self.connected ) ) //ADDED
	return;
	
	//remover fields caso seja round restart
	if(isdefined(level.scr_field_orders) && level.scr_field_orders)
	{		
		if( isDefined( self.hasFieldOrders ) && self.hasFieldOrders == true ) 
		{
				self.hasFieldOrders = false;
				level.fieldOrdersActive = false;

				if( isDefined( self.caseIcon ) )
						self.caseIcon.alpha = 0;        
		}
	}
	
	self removePlayerOnDisconnect();//FOR CLIENT

	if ( isDefined( self.score ) && isDefined( self.pers["team"] ) )
	{
		setPlayerTeamRank( self, level.dropTeam, self.score - 5 * self.deaths );
		self logString( "team: score " + self.pers["team"] + ":" + self.score );
		level.dropTeam += 1;
	}

	[[level.onPlayerDisconnect]]();

	//player quitting log
	lpselfnum = self getEntityNumber();
	lpGuid = self getguid();
	logPrint("Q;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");
	
	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if ( level.players[entry] == self )
		{
			while ( entry < level.players.size-1 )
			{
				level.players[entry] = level.players[entry+1];
				entry++;
			}
			level.players[entry] = undefined;
			break;
		}
	}
	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if ( isDefined( level.players[entry].killedPlayers[""+self.clientid] ) )
			level.players[entry].killedPlayers[""+self.clientid] = undefined;

		if ( isDefined( level.players[entry].killedPlayersCurrent[""+self.clientid] ) )
			level.players[entry].killedPlayersCurrent[""+self.clientid] = undefined;

		if ( isDefined( level.players[entry].killedBy[""+self.clientid] ) )
			level.players[entry].killedBy[""+self.clientid] = undefined;
	}
	
	if ( level.gameEnded )
	self removeDisconnectedPlayerFromPlacement();

	level thread updateTeamStatus();
}

removePlayerOnDisconnect()
{
	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if ( level.players[entry] == self )
		{
			while ( entry < level.players.size-1 )
			{
				level.players[entry] = level.players[entry+1];
				entry++;
			}
			level.players[entry] = undefined;
			break;
		}
	}
	
	//fix squad bug?
	for ( entry = 0; entry < level.leaderPlayers.size; entry++ )
	{
		if ( level.leaderPlayers[entry] == self )
		{
			while ( entry < level.leaderPlayers.size-1 )
			{
				level.leaderPlayers[entry] = level.leaderPlayers[entry+1];
				entry++;
			}
			level.leaderPlayers[entry] = undefined;
			break;
		}
	}
}

removeDisconnectedPlayerFromPlacement()
{
	offset = 0;
	numPlayers = level.placement["all"].size;
	found = false;
	for ( i = 0; i < numPlayers; i++ )
	{
		if ( level.placement["all"][i] == self )
		found = true;

		if ( found )
		level.placement["all"][i] = level.placement["all"][ i + 1 ];
	}
	if ( !found )
	return;

	level.placement["all"][ numPlayers - 1 ] = undefined;
	assert( level.placement["all"].size == numPlayers - 1 );

	if ( level.teamBased )//CHANGED
	{
		updateTeamPlacement();
		return;
	}

	numPlayers = level.placement["all"].size;
	for ( i = 0; i < numPlayers; i++ )
	{
		player = level.placement["all"][i];
		player notify( "update_outcome" );
	}

}

updatePlacement()
{
	prof_begin("updatePlacement");

	if ( !level.players.size )
	return;

	level.placement["all"] = [];
	for ( index = 0; index < level.players.size; index++ )
	{
		if ( level.players[index].team == "allies" || level.players[index].team == "axis" )
		level.placement["all"][level.placement["all"].size] = level.players[index];
	}

	placementAll = level.placement["all"];

	for ( i = 1; i < placementAll.size; i++ )
	{
		player = placementAll[i];
		playerScore = player.score;
		for ( j = i - 1; j >= 0 && (playerScore > placementAll[j].score || (playerScore == placementAll[j].score && player.deaths < placementAll[j].deaths)); j-- )
		placementAll[j + 1] = placementAll[j];
		placementAll[j + 1] = player;
	}

	level.placement["all"] = placementAll;
	
	if ( level.teamBased )//207
	updateTeamPlacement();

	prof_end("updatePlacement");
}


updateTeamPlacement()
{
	placement["allies"]    = [];
	placement["axis"]      = [];
	placement["spectator"] = [];

	if ( !level.teamBased )
	return;

	placementAll = level.placement["all"];
	placementAllSize = placementAll.size;

	for ( i = 0; i < placementAllSize; i++ )
	{
		player = placementAll[i];
		team = player.pers["team"];

		placement[team][ placement[team].size ] = player;
	}

	level.placement["allies"] = placement["allies"];
	level.placement["axis"]   = placement["axis"];
}

isHeadShot(sHitLoc, sMeansOfDeath )
{
	return (sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck") && sMeansOfDeath != "MOD_MELEE";
}

isArmorShot(sHitLoc, sMeansOfDeath )
{
	return (sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "torso_upper" || sHitLoc == "torso_lower"  ) && sMeansOfDeath != "MOD_MELEE";
}

isLegsShot(sHitLoc)
{
	return (sHitLoc == "left_foot" || sHitLoc == "right_foot" || sHitLoc == "right_leg_upper" || sHitLoc == "left_leg_upper" || sHitLoc == "right_leg_lower" || sHitLoc == "left_leg_lower");
}

isHandsShot(sHitLoc)
{
	return (sHitLoc == "left_hand" || sHitLoc == "right_hand");
}

/*

	victim thread [[level.callbackPlayerDamage]](
		attacker, // eInflictor The entity that causes the damage.(e.g. a turret)
		attacker, // eAttacker The entity that is attacking.
		1000, // iDamage Integer specifying the amount of damage done
		0, // iDFlags Integer specifying flags that are to be applied to the damage
		"MOD_RIFLE_BULLET", // sMeansOfDeath Integer specifying the method of death
		"none", // sWeapon The weapon number of the weapon used to inflict the damage
		(0,0,0), // vPoint The point the damage is from?
		(0,0,0), // vDir The direction of the damage
		"none", // sHitLoc The location of the hit
		0 // psOffsetTime The time offset for the damage
	);
*/
Callback_PlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	//iprintln("iDamage: " + iDamage);	
	//iprintln("sMeansOfDeath: " + sMeansOfDeath);
	//iprintln("sWeapon: " + sWeapon);
	//iprintln("eInflictor-> " + eInflictor.classname );
	
	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
	return;

	if ( level.inStrategyPeriod )
	return;
	//iprintln("AAAA: " + iDamage);

	if(level.cod_mode == "practice" && isdefined(self.nodamage) && self.nodamage == true)
	return;
	
	//iprintln("BBB: " + iDamage);

	if ( self.sessionteam == "spectator")
	return;

	//iprintln("CCCC: " + iDamage);

	if ( level.inTimeoutPeriod && level.timeoutTeam != self.pers["team"] )
	return;	
	
	//anula dano de perfuraçao!!!
	if ( isdefined(level.preventWallbangExploit) && (iDFlags & level.iDFLAGS_PENETRATION) )
	return;
	
	//elite hack
	if ( isdefined(self.preventWallbang) && (iDFlags & level.iDFLAGS_PENETRATION) )
	return;
	
	//iprintln("DDD: " + iDamage);
	
	 if (isdefined(self.inPredator))
	 return;
	
	
	// If iDamage has been reduced to zero we don't do anything else
	if ( iDamage < 1 )
	return;

	//===============WEAPOAN CONVERTS===================
	if(sWeapon == "beretta_silencer_mp" || sWeapon == "frag_grenade_short_mp")
	sMeansofDeath = "MOD_IMPACT";
		
	if(sWeapon == "m40a3_acog_mp" || sWeapon == "m1014_grip_mp" )
		sMeansOfDeath = "MOD_RIFLE_BULLET";	
	
	//if(sMeansOfDeath == "MOD_PROJECTILE_SPLASH" && isDefined(eAttacker.inPredator))
	//sWeapon = "predator_mp";

	//pair 'entity' and 'undefined' has unmatching types 'object' and 'undefined':
	//if(isDefined(level.bulletSpawner) && sWeapon == "beretta_mp" && eAttacker == level.bulletSpawner)
	//iDamage = 5;
	
	//iprintln(eInflictor);
	//necessario
	if ( isHeadShot(sHitLoc, sMeansOfDeath ) )
	sMeansOfDeath = "MOD_HEAD_SHOT";
		
	if(sWeapon == "gl_m16_mp" && sMeansOfDeath == "MOD_IMPACT") 
	sMeansofDeath = "MOD_PISTOL_BULLET";
	
	//======================END=============================
	
	
	//===============UPGRADES EFFECTS===================
	//controle de quedas
	if(sMeansOfDeath == "MOD_FALLING")
	{	
		if(self.resilience)
		return;
		
		prof_begin( "Callback_PlayerDamage world" );
		
		if(self.upgradefalldamage > 0)
		{
			iDamage = iDamage * 0.5;
		}
		
		self finishPlayerDamageWrapper(eInflictor, eAttacker, int(iDamage), iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
		
		prof_end( "Callback_PlayerDamage world" );
		
		return;
	}
	
	
	
	
	//iprintln("FFF: " + iDamage);
	//sitrep coldblooded
	if( self.coldblooded && sWeapon == "decoy_grenade_mp")
	return;

	//iprintln("GGG: " + iDamage);
	
	//iprintln("eAttacker-> " + isPlayer( eAttacker ));//1
	
	
	if ( isDefined( eAttacker ) && isPlayer( eAttacker ) )
	{
		//se a vitima esta morta...n tem pq continuar.
		if(!isAlive(self)) return;
	
		//iprintln("Dano1");	
		
		//ignore FF firearrow
		if(sWeapon == "gl_m16_mp" && self.pers["team"] == eAttacker.pers["team"])
		return;

		//explosivos n afetam o mesmo time
		if ( level.teamBased && eAttacker != self && self.pers["team"] == eAttacker.pers["team"] && (sMeansOfDeath == "MOD_GRENADE_SPLASH" || sMeansOfDeath == "MOD_GRENADE" || sMeansOfDeath == "MOD_EXPLOSIVE"))
		{
			return;
		}

		//anti-Xiter
		if (isDefined( eAttacker.hacker ) && eAttacker.hacker )//true = cannot do damage
		return;
			
		//iprintln("Dano2");	
		if( isDefined( eAttacker.canDoCombat ) && !eAttacker.canDoCombat )
			return;
		
		//iprintln("Dano3");
		
		if( eAttacker.team == "spectator" || ( isDefined( eAttacker.teamSwitchExploit ) && eAttacker.teamSwitchExploit ) )
		return;
		
		//iprintln("Dano4");
			
		if(sMeansOfDeath == "MOD_MELEE")
		{
			iDamage = 400;
			org = self gettagorigin( "j_spinelower" );
			angles = self gettagangles( "j_spinelower" );
			anglesford = anglestoforward( angles );
				
			PlayFX( level.spill_bloodfx, org, anglesford );
			PlayFX( level.fleshhitsplatlargefx, self.origin);
			
			if (isDefined( eAttacker.pers["isBot"] ) && eAttacker.pers["isBot"])
				self thread botdospray();
		}
	
		//iprintln("upgradeposiondamage-> " + eAttacker.upgradeposiondamage);
		//iprintln("isSniper(sWeapon-> " + isSniper(sWeapon));
	
		//eu que ataquei a vitima, meu hit espalha para todos ao redor
		if(eAttacker.collateral && isSniper(sWeapon))
		eAttacker thread Collateral(self,45);
		
		//iprintln("sHitLoc-> " + sHitLoc);
		//iprintln("iDamage-> " + iDamage);
		//iprintln("isLegsShot(sHitLoc)-> " + isLegsShot(sHitLoc));
		//iprintln("isSniper(sWeapon-> " + isHandsShot(sHitLoc));
		
		//testar! verificar se pode apenas retornar este dano?
		if(isLegsShot(sHitLoc))
		{
			if(iDamage < 141)
			iDamage = iDamage * 0.7;
			else
			iDamage = iDamage * 0.3;
		}
	
		if(isHandsShot(sHitLoc))
		{
			if(iDamage < 141)
			iDamage = iDamage * 0.7;
			else
			iDamage = iDamage * 0.3;
		}		
		//cannot cast undefined to bool: (file 'maps/mp/gametypes/_globallogic.gsc', line 4599)		
		if(eAttacker.upgradeprecisionshoot && isHandsShot(sHitLoc))
		{
			if (percentChance(35)) 
			self thread Weapondrophit(eAttacker);//self on victim
		}
		
		//comprar antimag
		if( sWeapon == "magnade_mp" && !self.antimag)
		{
			if(eAttacker != self && !isSameTeam(eAttacker))//nao pode ser do mesmo time!
			{
				//special
				if(isDefined(eAttacker.implodernade))
				{
					self thread maps\mp\gametypes\_weapons::implodeNadefx(eAttacker);
					return;
				}
				
               self thread maps\mp\gametypes\_weapons::dropWeaponMagnetic(eAttacker);
			   self thread maps\mp\gametypes\_weapons::dropOffhandMagnetic(eAttacker);
			   self shellshock("frag_grenade_mp", 3.0);
			   //self thread attachplayertoit(self.origin,eAttacker);
			   return;
			}
		}
		
		
		//iprintln("sMeansOfDeath-> " + sMeansOfDeath);
		//iprintln("iDamage-> " + iDamage);
		//iprintln("selfpoisonedarrow-> " + !isDefined(self.poisonedarrow));
		//CROSSBOW
		// 3 ARROWS - NORMAL,POISON,FIRE
		//eAttacker = player attacking
		if(sWeapon == "gl_m16_mp" && sMeansOfDeath != "MOD_MELEE")
		{
			//iprintln("sWeaponArrow-> " + sWeapon);
			//iprintln("sMeansOfDeath-> " + sMeansOfDeath);
			
			if(eAttacker.firearrow)
			iDamage = 40;
			
			if(eAttacker.poisonarrow)
			iDamage = 30;
			
			if(eAttacker.shockarrow)
			iDamage = 20;
		
			self thread bloodonarrow();
		
			//se for hit direto
			if(sMeansOfDeath != "MOD_GRENADE_SPLASH")
			{
				if(!isDefined(self.poisonedarrow) && self.antipoison == 0 && eAttacker.poisonarrow == 1)
				{
					if(isDefined(eAttacker.upgradeposiondamage) && eAttacker.upgradeposiondamage)
					{
						self thread PoisonedArrow(eAttacker);
						
						self thread Poisonspread(eAttacker);
					}
					else
					self thread PoisonedArrow(eAttacker);
				}
				
				if(!isDefined(self.shockedbyarrow) && self.heavykevlar == 0 && eAttacker.shockarrow == 1)
				{
					self thread Doshockarrow(eAttacker);					
				}
				
				if(!isDefined(self.onfire) && eAttacker.firearrow && eAttacker.poisonarrow == 0)
				{
					//iprintln("firespread-> " + eAttacker.firearrow);
					self thread firespread(eInflictor,eAttacker);				
				}
			}
			
			 if(sMeansOfDeath == "MOD_GRENADE_SPLASH" )
			iDamage = 30;
		}
		//org = self gettagorigin( "j_spinelower" );
		//angles = self gettagangles( "j_spinelower" );
		//anglesford = anglestoforward( angles );
		//PlayFX( level.spill_bloodfx, org, anglesford );	
		
		//iprintln("iDamage: " + iDamage + " isDefined(self.hasarmor): " + isDefined(self.hasarmor) + "  HT: " + sHitLoc);
		
		
		if(iDamage >= 55 && sMeansOfDeath == "MOD_RIFLE_BULLET" && !isDefined(self.hasarmor))
		{
			//iprintln("iDamage1: " + iDamage);
			
			if ( iDamage >= self.health )
			{
				org = self gettagorigin( "j_spinelower" );
				angles = self gettagangles( "j_spinelower" );
				anglesford = anglestoforward( angles );
				PlayFX( level.spill_bloodfx, org, anglesford );
				PlayFX( level.spill_bloodfx, org, anglesford );
				//PlayFX( level.fatabodyhitfx, org, anglesford );
				PlayFX( level.fleshhitsplatlargefx, self.origin);				
			}
		}
		
		if(iDamage >= 10 && sMeansOfDeath == "MOD_PISTOL_BULLET" && !isDefined(self.hasarmor))
		{
			//iprintln("iDamage2: " + iDamage);
			if (iDamage <= self.health )
			{
				org = self gettagorigin( "j_spinelower" );
				angles = self gettagangles( "j_spinelower" );
				anglesford = anglestoforward( angles );
				PlayFX( level.spill_bloodfx, org, anglesford );
				//PlayFX( level.fatabodyhitfx, org, anglesford );					
				PlayFX( level.fleshhitsplatfx,self.origin);	
			}
		}	
	
	}
	//=====================END============================
		
	

		
//=================MODIFICA DANO=================================
	self.iDFlags = iDFlags;
	self.iDFlagsTime = getTime();
	
	iDamage = int(maps\mp\gametypes\_class_unranked::cac_modified_damage( self, eAttacker, iDamage, sMeansOfDeath,iDFlags,sHitLoc,sWeapon,vDir,vPoint));
	
	
	if( !isDefined( vDir ) )
	iDFlags |= level.iDFLAGS_NO_KNOCKBACK;
	
	//TESTE
	prof_begin( "Callback_PlayerDamage flags/tweaks" );
	
	//reseta o friendly
	friendly = false;	

	if(level.cod_mode == "practice" && sMeansofDeath != "MOD_FALLING")
	{
		fDistance = distance( self.origin, eAttacker.origin );
		
		//CONVERTE UNIDADE MUNDO 3D EM METROS		
		distMeters = int( fDistance * 0.0254 );
		distToShow = distMeters + "m";		
		
		//METRICA PARA CONFIG DAS ARMAS
		metrica = int(((distMeters/0.0254)*10)/10);///converte em float ficando 1.0 -> 1.1 
		
		//76 = 40 -> X/0.0254/10 * 10?
		if(isdefined(distToShow) && isdefined(metrica))
		iprintln("^1DAMAGE: " + iDamage + " ^2MOD: " + sMeansOfDeath + " ^3DIST: " + distToShow + " ^3VAL: " + metrica);
	}
	//iprintln("^1Globallogic[sMeansOfDeath]: " + sMeansOfDeath );
	//DETECTA TIPO DE IMPACTO
	if( sMeansOfDeath == "MOD_IMPACT" && isDefined( eInflictor) && !isPlayer( eInflictor) && eInflictor.classname == "grenade" )
	{
		
		//iprintln("^1Globallogic[sWeapon]: " + sWeapon );	
		
		if( sWeapon == "semtex_grenade_mp")
		eInflictor thread maps\mp\gametypes\_weapons::StuckItem( 0, self, sHitLoc, vDir,sWeapon);
		
		//eInflictor notify("itemstuckonplayer", self, sHitLoc, vDir,sWeapon);
		
		if(sWeapon == "frag_grenade_short_mp")
		eInflictor thread maps\mp\gametypes\_weapons::StuckItem( 0,self, sHitLoc, vDir,sWeapon );
	}
	
	// explosive barrel/car detection
	sWeaponHack = undefined;
	if ( sWeapon == "none" && isDefined( eInflictor ) )	
	{
		if ( isDefined( eInflictor.targetname ) && eInflictor.targetname == "explodable_barrel" )	
		{
			sWeaponHack = "explodable_barrel";
			sWeapon = "destructible_car";
			sMeansOfDeath = "MOD_IMPACT";					
		} 
		else if ( isDefined( eInflictor.destructible_type ) && isSubStr( eInflictor.destructible_type, "vehicle_" ) ) 	
		{
			sWeapon = "destructible_car";
		}
	}

	
	if ( ( level.teamBased && (self.health == self.maxhealth)) || !isDefined( self.attackers ) )
	{
		self.attackers = [];
		//self.attackerData = [];		
		self.attackerDamage = [];//usado para Assist damage
	}

	prof_end( "Callback_PlayerDamage flags/tweaks" );
	
	// check for completely getting out of the damage
	//se o damage nao for por perfuração
	if( !(iDFlags & level.iDFLAGS_NO_PROTECTION) )
	{		
		//MESMO TIME AQUI SOFRE PUNICAO
		if (level.teamBased && isPlayer( eAttacker ) && (self != eAttacker) && (self.pers["team"] == eAttacker.pers["team"]) )
		{
			prof_begin( "Callback_PlayerDamage player" ); 
			// profs automatically end when the function returns
			
			//ignora no inicio do round o TK
			if(isDefined(eAttacker.blockedtk)) return;
			
			if (!eAttacker.ffkiller) // no one takes damage
			return;			
			
			if (eAttacker.ffkiller) // the friendly takes damage
			{
			
				if(level.cod_mode != "practice")
				iDamage = int(iDamage * .3);
				//per hit punish
				if(eAttacker.isRanked)
				eAttacker thread SetRankPoints(-25);
				
				// Make sure at least one point of damage is done
				if ( iDamage < 1 )
				iDamage = 1;

				self.lastDamageWasFromEnemy = false;
				eAttacker.lastDamageWasFromEnemy = false;
				
				self finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				/*
				if ( isAlive( eAttacker ) ) // may have died due to friendly fire punishment
				{
					eAttacker.friendlydamage = true;
					eAttacker finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage * 2, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
					eAttacker.friendlydamage = undefined;
				}*/
			}
			
			friendly = true;
		}//daqui para baixo inimigos
		else
		{
			prof_begin( "Callback_PlayerDamage world" );
			// Make sure at least one point of damage is done
			if(iDamage < 1)
			iDamage = 1;			

			if ( level.teamBased && isDefined( eAttacker ) && isPlayer( eAttacker ) )
			{
				if ( !isdefined( self.attackers[eAttacker.clientid] ) )
				{
					self.attackerData[eAttacker.clientid] = false;
					self.attackerDamage[eAttacker.clientid] = iDamage;//assist damage
					self.attackers[ self.attackers.size ] = eAttacker;					
				}
				else
				{
					//GUARDA O DANO NO ALVO
					if(isdefined( self.attackerDamage[eAttacker.clientid]))
					self.attackerDamage[eAttacker.clientid] += iDamage;//assist damage
				}				
				if ( maps\mp\gametypes\_weapons::isPrimaryWeapon( sWeapon ) )//PQ DISTO?
				self.attackerData[eAttacker.clientid] = true;
			}

			//registra o ultimo attacker
			if ( isdefined( eAttacker ) )
			level.lastLegitimateAttacker = eAttacker;

			self.wasCooked = undefined;

			//self.lastDamageWasFromEnemy = (isDefined( eAttacker ) && (eAttacker != self));//verdadeiro se foi alguem que me deu hit
			
			//GUARDA O REGISTRO DO ULTIMO PLAYER QUE ME ACERTOU
			//if ( self.lastDamageWasFromEnemy )
			//eAttacker.damagedPlayers[ self.clientId ] = getTime();
			
			self finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
			//self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
			
			
			
			prof_end( "Callback_PlayerDamage world" );
		}
		
		

		//USADO PARA EFEITOS DE SANGUE
		//self notify( "damage_taken", eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
		
		
		//self.playerhealth.value setValue(self.health);
		
	
		//se eu sou attacker e acertei alguem
		if ( isdefined(eAttacker) && isplayer( eAttacker ) && eAttacker != self )
		{
			if ( iDamage > 0 ) 
			{
				//vampirism STREAK
				if(eAttacker.vampirism)
				{
					eAttacker.health += vampirism_health( iDamage, eAttacker );
					
					if(isDefined(eAttacker.playerhealth) && isDefined(eAttacker.playerhealth.value))
					eAttacker.playerhealth.value setValue(eAttacker.health);
				}
				
				if( !(iDFlags & level.iDFLAGS_PENETRATION))
				eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( iDamage);
			}
		}

		self.hasDoneCombat = true;
	}

	//set spawn for FFA
	if ( isdefined( eAttacker ) && eAttacker != self && !friendly )
	level.useStartSpawns = false;	

	prof_begin( "Callback_PlayerDamage log" );

	prof_end( "Callback_PlayerDamage log" );
}

vampirism_health( iDamage, eAttacker )
{	
	return Int(iDamage * 0.3);
}

finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{	
	self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
	
	if (isDefined(self.playerhealth) && isDefined(self.playerhealth.value))
	self.playerhealth.value setValue(self.health);
	
	//perkblast tacresist 
	//self damageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage );
}

damageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage )
{
	//self thread maps\mp\gametypes\_weapons::onWeaponDamage( eInflictor, sWeapon, sMeansOfDeath, iDamage );
	self PlayRumbleOnEntity( "damage_heavy" );
}

default_getTeamKillPenalty( eInflictor, attacker, sMeansOfDeath, sWeapon )
{
	teamkill_penalty = 1;
	
	if ( sWeapon == "airstrike_mp" )
	{
		teamkill_penalty = 2;
	}
	return teamkill_penalty;
}

default_getTeamKillScore( eInflictor, attacker, sMeansOfDeath, sWeapon )
{
	return maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
}

//SELF = vitima
Callback_PlayerKilled(eInflictor, attacker, iDamage,sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	self endon( "spawned" );
	self notify( "killed_player" );

	if ( level.inReadyUpPeriod )
	return;

	if ( self.sessionteam == "spectator" )
	return;

	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
	return;

	// back translation as explodable_barrel is not propagated correctly
	if ( issubstr( sMeansOfDeath, "MOD_IMPACT" ) && sWeapon == "destructible_car" )
	{
		sMeansOfDeath = "MOD_CRUSH";
		sWeapon = "explodable_barrel";
	}

	prof_begin( "PlayerKilled pre constants" );

	deathTimeOffset = 0;
	
	if ( isdefined( self.useLastStandParams ) ) 
	{
		self.useLastStandParams = undefined;
		
		assert( isdefined( self.lastStandParams ) );
		
		eInflictor = self.lastStandParams.eInflictor;
		attacker = self.lastStandParams.attacker;
		iDamage = self.lastStandParams.iDamage;
		sMeansOfDeath = self.lastStandParams.sMeansOfDeath;
		sWeapon = self.lastStandParams.sWeapon;
		vDir = self.lastStandParams.vDir;
		sHitLoc = self.lastStandParams.sHitLoc;
		fDistance = self.lastStandParams.fDistance;
		
		deathTimeOffset = (gettime() - self.lastStandParams.lastStandStartTime) / 1000;
		
		self.lastStandParams = undefined;
	}
	else 
	{
		fDistance = distance( self.origin, attacker.origin );
	}
	
	if( isSniper( sWeapon ) && sMeansOfDeath == "MOD_IMPACT" )
	{
		sMeansOfDeath = "MOD_RIFLE_BULLET";
	}
	
	//if(sMeansOfDeath == "MOD_PROJECTILE_SPLASH" && isDefined(attacker.inPredator))
	//sWeapon = "predator_mp";


	//heli dono do kill?
	if( attacker.classname == "script_vehicle" && isDefined( attacker.owner ) )
	attacker = attacker.owner;

	// Send player_killed event with all the data to the player
	self notify( "player_killed", eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, fDistance );

	

	if(sMeansOfDeath == "MOD_MELEE")
		nameWeapon = "KNIFE";
	else
	nameWeapon = convertWeaponName( sWeapon );
	
	//iprintln("sWeapon: " + sWeapon);
	//iprintln("sMeansOfDeath: " + sMeansOfDeath);
	//iprintln("Drop: " + weapon);	
	
	

	if(isDefined(self.killedbyimplodernade) && sWeapon == "magnade_mp")
	nameWeapon = "IMPLODER NADE";

	if(!isDefined(nameWeapon))
	nameWeapon = "NONE";
	
	if(sMeansOfDeath == "MOD_PROJECTILE_SPLASH" && nameWeapon == "NONE")
	nameWeapon = "MISSIL";

	if(isDefined(self.poisonedarrow) && self.poisonedarrow)
	nameWeapon = "VENENO";

	if(isDefined(self.shockedbyarrow) && self.shockedbyarrow)
	nameWeapon = "SHOCK";

	if(isDefined(self.onfire) && self.onfire)
	nameWeapon = "FOGO";

	if(nameWeapon == "HELICOPTER")
	{
		iprintln("^1["+ nameWeapon +"] ^5" + self.name + " ^7[ ^3"+ iDamage +"^7 ]" );
	}
	else if( isPlayer( attacker ) && attacker != self )
	{		
		//pair 'undefined' and 'heavygunner' 
		if(attacker.incognito)
		{
		    vDir = (0,0,0);
			//MOSTRA STATS APENAS PARA O JOGADOR - OUTROS NAO VEEM NADA
			if(sMeansOfDeath == "MOD_HEAD_SHOT")
			attacker iprintln("^1" +attacker.name + " ^7["+ nameWeapon +"] ^5" + self.name + " ^7[ ^1HS^7 ] (" + int(fDistance * 0.0254) + "m)");
			else
			attacker iprintln("^1" +attacker.name + " ^7["+ nameWeapon +"]-> ^5" + self.name + " ^7(" + int(fDistance * 0.0254) + "m)");
						
			//STEALTHBLACK SCREEN
			if (maps\mp\gametypes\_weapons::isPrimaryWeapon(sWeapon))
			self thread Blackscreenplayer();
		}
		else //NORMAL KILLSTATUS
		{
			if(sMeansOfDeath == "MOD_HEAD_SHOT")
			iprintln("^1" +attacker.name + " ^7["+ nameWeapon +"] ^5" + self.name + " ^7[ ^1HS^7 ] (" + int(fDistance * 0.0254) + "m)");
			else
			iprintln("^1" +attacker.name +" ^7["+ nameWeapon +"]-> ^5" + self.name + " ^7(" + int(fDistance * 0.0254) + "m)");
		}
		
		//DROP WEAPONS - DROPNADE
		if (!level.inGracePeriod && !(sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_SUICIDE"))
		{
			if ( !isDefined( self.pers["isBot"] ))
			{
				if(isDefined(attacker.upgradedropitems))
				{
					if(attacker.upgradedropitems > 0)
					{
						self maps\mp\gametypes\_weapons::dropWeaponForDeath( attacker );
						self maps\mp\gametypes\_weapons::dropOffhand();
					}
				}
			}
		}		
	}
	
	maps\mp\gametypes\_spawnlogic::deathOccured(self, attacker);

	self.sessionstate = "dead";
	self.statusicon = "hud_status_dead";
	//self.pers["weapon"] = undefined;
	//reseta quantos matou ?
	self.killedPlayersCurrent = [];
	self.deathCount++;

	if( !isDefined( self.switching_teams ) || !level.inReadyUpPeriod )
	{
		// if team killed we reset kill streak, but dont count death and death streak
		if ( isPlayer( attacker ) && level.teamBased && ( attacker != self ) && ( self.pers["team"] == attacker.pers["team"] ) )
		{
			self.cur_kill_streak = 0;
			self setClientDvar( "ui_currstreak",0);
		}
		else
		{
			self incPersStat( "deaths", 1 );
			self.deaths = self getPersStat( "deaths" );
			
			if(isDefined(self.squad))
			self thread [[level.onXPEvent]]( "death" );	
			
			self updatePersRatio( "KDRATIO", "kills", "deaths" );

			//reseta killstreaks
			self.cur_kill_streak = 0;
			
			self setClientDvar( "ui_currstreak",0);
			self.cur_death_streak++;

			//if ( self.cur_death_streak > self.death_streak )
			//{
			//	
			//	self.death_streak = self.cur_death_streak;
			//}
		}
	}

	lpselfnum = self getEntityNumber();
	lpselfname = self.name;
	lpattackGuid = "";
	lpattackname = "";
	if( isdefined( self.pers["team"] ) )
	lpselfteam = self.pers["team"];
	else
	lpselfteam = "";
	lpselfguid = self getguid();
	lpattackerteam = "";

	lpattacknum = -1;

	prof_end( "PlayerKilled pre constants" );
	
	self.cancelKillcam = false;
	
	if( isPlayer( attacker ) )
	{
		lpattackGuid = attacker getguid();
		lpattackname = attacker.name;
		if( isdefined( attacker.pers["team"] ) )
		lpattackerteam = attacker.pers["team"];
		else
		lpattackerteam = "";
		
		if ( attacker == self ) // eu mesmo = suicidio
		{
			doKillcam = false;

			// switching teams
			if ( isDefined( self.switching_teams ) )
			{
				if ( !level.teamBased && ((self.leaving_team == "allies" && self.joining_team == "axis") || (self.leaving_team == "axis" && self.joining_team == "allies")) )
				{
					playerCounts = self maps\mp\gametypes\_teams::CountPlayers();
					playerCounts[self.leaving_team]--;
					playerCounts[self.joining_team]++;

					if( (playerCounts[self.joining_team] - playerCounts[self.leaving_team]) > 1 )
					{
						//self thread [[level.onXPEvent]]( "suicide" );
						self incPersStat( "suicides", 1 );
						self.suicides = self getPersStat( "suicides" );
					}
				}
			}
			else
			{
				//self thread [[level.onXPEvent]]( "suicide" );
				self incPersStat( "suicides", 1 );
				self.suicides = self getPersStat( "suicides" );

				// suicides will be substracted from the players score only
				//maps\mp\gametypes\_globallogic::givePlayerScore( "suicide", self );

				if ( sMeansOfDeath == "MOD_SUICIDE" && sHitLoc == "none" && self.throwingGrenade )
				{
					self.lastGrenadeSuicideTime = gettime();
				}
			}

			if( isDefined( self.friendlydamage ) )
			self iPrintLn(&"MP_FRIENDLY_FIRE_WILL_NOT");
		}
		else
		{
			prof_begin( "PlayerKilled attacker" );

			lpattacknum = attacker getEntityNumber();

			doKillcam = true;
			//-------------------------------------------------
			//TEAMKILLER
			//-------------------------------------------------
			 if ( level.teamBased && self.pers["team"] == attacker.pers["team"] && attacker.ffkiller && self.ffkiller && level.cod_mode != "practice" ) // killed by a friendly
			{

				attacker notify("team_kill", self, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime );
				
				if(!isDefined(attacker.stealthed))
				{
					attacker thread [[level.onXPEvent]]( "teamkill" );

					attacker.pers["teamkills"]++;
					
					//tkrank = (attacker.pers["teamkills"] * 1000) * -1)
					
					attacker thread SetRankPoints(-5000);
					
					attacker.cur_kill_streak = 0;
					
					attacker statAdds("TKCOUNT",1);//add 1 ponto de tk - para punir
					
					attacker statAdds("TKPERM",1);//add PERMAMENTE PARA MENUS RANK
					
					//attacker setStat(3204, attacker getStat(3204) + 1);//TKPERM
					
					attacker thread CheckforTK();
					
					attacker.teamkillsThisRound++;

					maps\mp\gametypes\_globallogic::givePlayerScore( "teamkill", attacker );
					
					giveTeamScore( "teamkill", attacker.team,  attacker, self );
				
					if(level.gametype == "sd")
					{
						if(attacker getStat(3181) > 600)//EVPSCORE
						attacker thread GiveEVP(-350,100);
						else if(isAlive(attacker))
						{
							attacker takeAllWeapons();
						}					
					}
				}
			}
			else
			{
				prof_begin( "pks1" );

				attacker incPersStat( "kills", 1 );
				attacker.kills = attacker getPersStat( "kills" );
				attacker updatePersRatio( "KDRATIO", "kills", "deaths" );

				streakGiven = false;
				
				//killstreak add
				if ( isAlive( attacker ) && level.cod_mode != "torneio")
				{
					if ( !isDefined( eInflictor ) || !isDefined( eInflictor.requiredDeathCount ) || attacker.deathCount == eInflictor.requiredDeathCount )
					{
						attacker.cur_kill_streak++;
						attacker.cur_buff_streak++;
					}
				
					if ( attacker.cur_kill_streak > attacker.kill_streak )
					{
						//grava no mp
						//attacker statSets( "kill_streak", attacker.cur_kill_streak );
						attacker.kill_streak = attacker.cur_kill_streak;
						
						//salva os topstreak kills deste player
						attacker setStat(2303,attacker.cur_kill_streak);
						//attacker iprintln("^1kStreak: " +attacker.pers["top_streak"] );
					}
				
					if(level.atualgtype != "dm")
					{
						// iprintln("cur_buff_streak: " + attacker.cur_buff_streak);
						//iprintln("skillbuffspydrone: " + attacker.skillbuffspydrone);
						//iprintln("skillbuffpredator: " + attacker.skillbuffpredator);
						
						
						if( attacker.cur_buff_streak == 3 && attacker.skillbuffspydrone)
						{
							//3161 teambuff
						  attacker playLocalSound( "uavready");
						 //attacker playLocalSound( game["voice"][attacker.team] + "ouruavonline");
						  attacker thread GanhouBuff();
						  attacker iprintln("Teambuff DRONE recebido!");
						  
						 // if(isdefined(attacker.teambufficon.icon))
						 // attacker.teambufficon.icon.alpha = 1;
						} 
						else if( attacker.cur_buff_streak == 3 && !attacker.skillbuffspydrone && !attacker.skillbuffpredator && !attacker.skillbuffcarepackage)
							{
								//3161 teambuff
							  attacker thread GanhouBuff();
							  attacker iprintln("Teambuff Skill recebido!");
							   attacker playLocalSound( "mp_killstreak_radar");
							  // if(isdefined(attacker.teambufficon.icon))
								//attacker.teambufficon.icon.alpha = 1;
							}


						if( attacker.cur_buff_streak == 5 && attacker.skillbuffpredator && !attacker.skillbuffspydrone && !attacker.skillbuffcarepackage)
						{
							//3161 teambuff predator
							//game["voice"]["allies"] = "UK_1mc_";
						   attacker playLocalSound( game["voice"][attacker.team] + "predator_ready");
						   attacker thread GanhouBuff();
						   attacker iprintln("Teambuff recebido Predador!");
						   
						    //if(isdefined(attacker.teambufficon.icon))
							//attacker.teambufficon.icon.alpha = 1;
						}

						if( attacker.cur_buff_streak == 5 && !attacker.skillbuffpredator && !attacker.skillbuffspydrone && attacker.skillbuffcarepackage)
						{
							//3161 teambuff predator
							//game["voice"]["allies"] = "UK_1mc_";
						   attacker playLocalSound("carepackagewaiting");
						   attacker thread GanhouBuff();
						   attacker iprintln("Teambuff recebido Carepackage!");
						   
						    //if(isdefined(attacker.teambufficon.icon))
							//attacker.teambufficon.icon.alpha = 1;
						}									
					}
						
					streakGiven = true; //fix killingspree
					
					attacker setClientDvar( "ui_currstreak",attacker.cur_kill_streak);
					
					if(level.players.size >= 4 && attacker.cur_kill_streak == 23 )
					attacker thread playsoundtoall("siren");
				
					if(level.players.size >= 4 && attacker.cur_kill_streak == 25 )
					{
						attacker thread GiveNuke();
					}
					
					
					attacker notify( "kill_streak", attacker.cur_kill_streak, streakGiven, sMeansOfDeath,self.name,sWeapon);
				}

				// Check to make sure the kill streak was given to the attacker or the he/she might get a duplicate hardpoint
				//if ( isDefined( level.hardpointItems ) && isAlive( attacker ) && streakGiven )
				//attacker thread maps\mp\gametypes\_hardpoints::giveHardpointItemForStreak();

				attacker.cur_death_streak = 0;

				// Get the score corresponding with this kill
				ScoreOfPlayer = promatch\_scoresystem::getPointsForKill( sMeansOfDeath, sWeapon, attacker );

				// Make sure the attacker didn't switch to spectator
				if ( attacker.pers["team"] != "spectator" && ScoreOfPlayer["score"] != 0 ) 
				{
					// Give player the score points
					givePlayerScore( ScoreOfPlayer["type"], attacker, self );
					
					// Give player's team score
					if ( level.teamBased ) {
						giveTeamScore( ScoreOfPlayer["type"], attacker.pers["team"],  attacker, self );
					}
					
					// Give XP points to the player
					attacker thread maps\mp\gametypes\_rank::giveRankXP( ScoreOfPlayer["type"],  ScoreOfPlayer["score"] );
					
					//victim is marked?
					if(isDefined( self.upgradespotondeath ) && self.upgradespotondeath )
					{
						attacker thread promatch\_markplayer::spotPlayer(5,false);
						attacker.bypass = true;
					}
				}				
				
				//contRola quem matou ou foi morto via id
				name = ""+self.clientid;
				
				if ( !isDefined( attacker.killedPlayers[name] ) )
				attacker.killedPlayers[name] = 0;

				if ( !isDefined( attacker.killedPlayersCurrent[name] ) )
				attacker.killedPlayersCurrent[name] = 0;

				//salva no attacker o id de quem ele matou
				attacker.killedPlayers[name]++;
				attacker.killedPlayersCurrent[name]++;
				
				attackerName = ""+attacker.clientid;
				
				if ( !isDefined( self.killedBy[attackerName] ) )
				self.killedBy[attackerName] = 0;
				
				//salva na vitima o id do attacker
				self.killedBy[attackerName]++;
				
				maps\mp\gametypes\_globallogic::givePlayerScore( "death", self );

				prof_end( "pks1" );

				if ( level.teamBased )
				{
					prof_begin( "PlayerKilled assists" );

					if ( isdefined( self.attackers ) )
					{
						for ( j = 0; j < self.attackers.size; j++ )
						{
							player = self.attackers[j];

							if ( !isDefined( player ) )
							continue;

							if ( player == attacker )
							continue;

							damage_done = self.attackerDamage[player.clientId];						

							//old iprint here -
							//can it fix?
							if(!isdefined(self.printingassist))
							iprintln("^1" + attacker.name + " + " + player.name + " ^7["+ nameWeapon +"]-> ^5" + " ^2["+ damage_done +"]-> ^5" + self.name );
							
							self.printingassist = true;
							
							player thread processAssist( self, damage_done );
						}						
						
						//reseta todos que deram algum tipo de dano na vitima
						self.printingassist = undefined;
						self.attackers = [];
					}

					prof_end( "PlayerKilled assists" );
				}
			}
			
			prof_end( "PlayerKilled attacker" );
		}
	}
	else
	{
		doKillcam = false;
		killedByEnemy = false;

		lpattacknum = -1;
		lpattackguid = "";
		lpattackname = "";
		lpattackerteam = "world";

		// even if the attacker isn't a player, it might be on a team
		if ( isDefined( attacker ) && isDefined( attacker.team ) && (attacker.team == "axis" || attacker.team == "allies") )
		{
			if ( attacker.team != self.pers["team"] )
			{
				killedByEnemy = true;

				if ( level.teamBased )
				giveTeamScore( "kill", attacker.team, attacker, self );
			}
		}
	}

	prof_begin( "PlayerKilled post constants" );

	//avisa algo para os hardpoints
	self notify("playerKilledChallengesProcessed");

	//ATUALIZA SCORES E OUTRAS FUNÇOES
	level thread updateTeamStatus();


	//gerando pers sem cabeça por q nao eh mais remontado todo spawn
	//iprintln(iDamage + " Name: " + self.name + "  HT: " + sHitLoc);
	//iprintln("sMeansOfDeath: " + sMeansOfDeath);
	if(sMeansOfDeath == "MOD_HEAD_SHOT" && sMeansOfDeath != "MOD_MELEE")
	{
		if ( iDamage >= 200 && sHitLoc == "head" )
		{
			
			org = self gettagorigin( "J_Head" );
			angles = self gettagangles( "J_Head" );
			anglesford = anglestoforward( angles );		

			PlayFX( level.fataheadhitfx, org, anglesford );
			PlayFX( level.headbloodspillfx, org, anglesford );			
			PlayFX( level.fatabodyhitfx, org, anglesford );
			 
			if(isDefined(self.hasarmor))
			PlayFX( level.gibsfx, org, anglesford );
			
			self.beheaded = true;
			self.changedmodel = undefined;
			self thread detachHeadold();			
		}

		
		
		if ( iDamage >= 100 && iDamage < 150)
		{
			org = self gettagorigin( "J_Head" );
			angles = self gettagangles( "J_Head" );
			anglesford = anglestoforward( angles );
			
			PlayFX( level.spill_bloodfx, org, anglesford );
			PlayFX( level.fataheadhitfx, org, anglesford );
			
			
		}
		
		/*if(sMeansOfDeath == "MOD_HEAD_SHOT" && iDamage > 100 && iDamage < 200)
		{
			org = self gettagorigin( "j_spinelower" );
			angles = self gettagangles( "j_spinelower" );
			anglesford = anglestoforward( angles );
			PlayFX( level.fataheadhitfx, org, angles);	
		}*/
	}	
	
	//if(level.gametype != "ctf") //fix erro detach
	//{
		//self maps\mp\gametypes\_gameobjects::detachUseModels(); // want them detached before we create our corpse

		body = self clonePlayer( deathAnimDuration );
		
		if(isDefined(self.onfire))
		body.onfire = true;		
			
		//aqui ja esta morto resta apenas o corpo
		if ( isdefined( body ) )
		{	
			body.isdeadbody = true;
			//if(sMeansOfDeath == "MOD_HEAD_SHOT" && iDamage > 100 && iDamage < 200)
			
			if ( sMeansOfDeath == "MOD_HEAD_SHOT" && iDamage >= 200 && sHitLoc == "head")
			body thread bodybleed(2,true);
			
			if ( sMeansOfDeath == "MOD_GRENADE_SPLASH")
			body thread bloodongrenade();
		
		
			if ( iDamage >= 200 && sHitLoc != "head")
			body thread bodybleed(2,false);
		
		
			if(isDefined(body.onfire))
			body thread putfireonbodty(); 
	
			if ( self isOnLadder() || self isMantling() || !self isOnGround())
			body startRagDoll();
			
			if(isDefined(self.tombs))
			{
				tombstone = randomint(2);
				if(tombstone == 1)
				body thread spawnitemwithmodel(level.tombstone1,undefined,undefined,2);
				
				if(tombstone == 2)
				body thread spawnitemwithmodel(level.tombstone2,undefined,undefined,2);
			}
			
			//if(tombstone == 3)
			//body thread spawnitemwithmodel(level.tombstone3,undefined,undefined,2);
		
		
			//thread delayStartRagdoll( body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath );
		}	

			
		self notify("player_body");//necessario para alguns modos
		
		//se n estiver trocando de team e contem algum desses perks
		//se vitima esta em um squad mostrar para o time !
		if (!isDefined( self.switching_teams ) && !(self.takedown))
		thread maps\mp\gametypes\_deathicons::addDeathicon( body, self, self.pers["team"], 1.0 );
	//}
	//MEDIC - SALVA LOCAL DA MORTE;
	self.deathspawn = self.origin;
	self.body = body;
	self.switching_teams = undefined;
	self.joining_team = undefined;
	self.leaving_team = undefined;
	//mudar de posicao?
	self thread [[level.onPlayerKilled]](eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);

	if ( sWeapon == "none" || isSubStr( sWeapon, "cobra" ) ) //rm sWeapon == "frag_grenade_short_mp" 
	doKillcam = false;
	
	//killcam por entidade - tipo granadas etc
	if ( ( isSubStr( sWeapon, "_grenade_" ) ) && isdefined( eInflictor ) )
	{
		killcamentity = eInflictor getEntityNumber();
		doKillcam = true;
	}
	else
	{
		killcamentity = -1;
	}
	
	//ERROR undefined is not an array:
	//if ( isplayer( attacker ) )
	//attacker.damagedPlayers[self.clientid] = undefined;
	
	
	self.deathTime = getTime();

	// let the players watch themselves die
	xwait( 0.25, false );
	self thread cancelKillCamOnUse();
	postDeathDelay = waitForTimeOrNotifies( 1.75 );
	self notify ( "death_delay_finished" );
	//playfx( level._effect["aacp_explode3"], self.origin );
	
	//FINAL KILLCAM ***********************
	
	//iprintln("grenade:[eInflictor] -> " + eInflictor );
	
	killcamentity = self getKillcamEntity( attacker, eInflictor, sWeapon );
	
	killcamentityindex = -1;
	killcamentitystarttime = 0;

	if ( isDefined( killcamentity ) )
	{	
		//iprintln("KILLCAMkillcamentity -> " + killcamentity);
	
		killcamentityindex = killcamentity getEntityNumber();
		if ( isdefined( killcamentity.startTime ) )
			killcamentitystarttime = killcamentity.startTime;
		else
			killcamentitystarttime = killcamentity.birthtime;
		if ( !isDefined( killcamentitystarttime ) )
			killcamentitystarttime = 0;			

		if ( ( isSubStr( sWeapon, "_grenade_" ) ) && isdefined( eInflictor ) )
		{
			killcamentityindex = eInflictor getEntityNumber();
		}
	
	}
	
	//victim = self;
	if( level.gametype == "sd" && level.cod_mode == "public" && game["state"] != "playing")//207
	level thread promatch\_finalkillcam::startFinalKillcam(lpattacknum, self getEntityNumber(), killcamentity, killcamentityindex, killcamentitystarttime, sWeapon, self.deathTime, 0, psOffsetTime, attacker,self,eInflictor,sMeansOfDeath);
	 //FINAL KILLCAM ******************************
	if ( !isDefined( game["state"] ) || isDefined( game["state"] ) && game["state"] != "playing" )
	return;

	//SET RESPAWN DEPOIS DA KILLCAM
	respawnTimerStartTime = gettime();

	//cannot cast undefined to bool :
	if (level.cod_mode != "torneio" && !self.cancelKillcam && doKillcam && level.killcam && game[ "state" ] == "playing")//207
	{
		livesLeft = !(level.numLives && !self.pers["lives"]);
		timeUntilSpawn = self TimeUntilSpawn( true );
		willRespawnImmediately = livesLeft && (timeUntilSpawn <= 0);

		self maps\mp\gametypes\_killcam::killcam( lpattacknum, killcamentity, sWeapon, postDeathDelay + deathTimeOffset, psOffsetTime, willRespawnImmediately, timeUntilRoundEnd(), attacker );
	}

	if ( sMeansOfDeath == "MOD_TRIGGER_HURT" ) 
	{
		self.freezeangles = undefined;
		self.freezeorigin = undefined;
	}

	prof_end( "PlayerKilled post constants" );

	if ( !isDefined( game["state"] ) || isDefined( game["state"] ) && game["state"] != "playing" )
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
		return;
	}

	// class may be undefined if we have changed teams
	if ( isValidClass( self.class ) )
	{
		timePassed = (gettime() - respawnTimerStartTime) / 1000;
		self thread [[level.spawnClient]]( timePassed );
	}
}




cancelKillCamOnUse()
{
	self endon ( "death_delay_finished" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );

	for ( ;; )
	{
		if ( !self UseButtonPressed() )
		{
			wait level.oneFrame;
			continue;
		}

		buttonTime = 0;
		while( self UseButtonPressed() )
		{
			buttonTime += level.oneFrame;
			wait ( level.oneFrame );
		}

		if ( buttonTime >= 0.5 )
		continue;

		buttonTime = 0;

		while ( !self UseButtonPressed() && buttonTime < 0.5 )
		{
			buttonTime += level.oneFrame;
			wait level.oneFrame;
		}

		if ( buttonTime >= 0.5 )
		continue;

		self.cancelKillcam = true;
		return;
	}
}


waitForTimeOrNotifies( desiredDelay )
{
	startedWaiting = getTime();

	//	while( self.doingNotify )
	//		wait level.oneFrame;

	waitedTime = (getTime() - startedWaiting)/1000;

	if ( waitedTime < desiredDelay )
	{
		xwait( desiredDelay - waitedTime, false );
		return desiredDelay;
	}
	else
	{
		return waitedTime;
	}
}

reduceTeamKillsOverTime()
{
	timePerOneTeamkillReduction = 20.0;
	reductionPerSecond = 1.0 / timePerOneTeamkillReduction;

	while(1)
	{
		if ( isAlive( self ) )
		{
			self.pers["teamkills"] -= reductionPerSecond;
			if ( self.pers["teamkills"] < level.minimumAllowedTeamKills )
			{
				self.pers["teamkills"] = level.minimumAllowedTeamKills;
				break;
			}
		}
		xwait( 1, false );
	}
}

processAssist( killedplayer, damagedone )
{
	self endon("disconnect");
	killedplayer endon("disconnect");

	wait level.oneFrame; // don't ever run on the same frame as the playerkilled callback.
	WaitTillSlowProcessAllowed();

	if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" )
	return;

	if ( self.pers["team"] == killedplayer.pers["team"] )
	return;

	assist_level = "assist";
	assist_level_value = int( floor( damagedone / 25 ) );
	
	if ( assist_level_value > 0 )
	{
		if ( assist_level_value > 3 )
		{
			assist_level_value = 3;
		}
		assist_level = assist_level + "_" + ( assist_level_value * 25 );
	}
	
	self thread [[level.onXPEvent]]( assist_level );
	
	self incPersStat( "assists", 1 );
	
	//ADD ASSIST STAT
	self.assists = self getPersStat( "assists" );

	givePlayerScore( assist_level, self, killedplayer );
}

Callback_PlayerLastStand( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	playerHasPistol = false;
	
	self.health = 1;
	
	self.lastStandParams = spawnstruct();
	self.lastStandParams.eInflictor = eInflictor;
	self.lastStandParams.attacker = attacker;
	self.lastStandParams.iDamage = iDamage;
	self.lastStandParams.sMeansOfDeath = sMeansOfDeath;
	self.lastStandParams.sWeapon = sWeapon;
	self.lastStandParams.vDir = vDir;
	self.lastStandParams.sHitLoc = sHitLoc;
	self.lastStandParams.lastStandStartTime = gettime();
	
	if ( isDefined( attacker ) ) 
	{
		self.lastStandParams.fDistance = distance( self.origin, attacker.origin );
	}
	else {
		self.lastStandParams.fDistance = 0;
	}
	
	mayDoLastStand = mayDoLastStand( sWeapon, sMeansOfDeath, sHitLoc );

	if ( !mayDoLastStand ) 
	{
		self.useLastStandParams = true;
		self ensureLastStandParamsValidity();
		self suicide();
		return;
	}
	
	weaponslist = self getweaponslist();
	assertex( isdefined( weaponslist ) && weaponslist.size > 0, "Player's weapon(s) missing before dying -=Last Stand=-" );
	
	self thread maps\mp\gametypes\_gameobjects::onPlayerLastStand();
	
	// Let's make sure the player doesn't drop the pistol
	if ( !isPistol( self.lastDroppableWeapon ) ) 
	{
		self maps\mp\gametypes\_weapons::dropWeaponForDeath( attacker );
	}
	
	grenadeTypePrimary = level.weapons["frag"];
		
	// check if player has pistol
	for( i = 0; i < weaponslist.size; i++ ) 
	{
		weapon = weaponslist[i];
		if ( isPistol( weapon ) ) 
		{
			// get the ammo count before we take all the weapons away
			totalAmmoLeft = self getAmmoCount( weapon );
			clipAmmoLeft = self getWeaponAmmoClip( weapon );
			
			// take away all weapon and leave this pistol
			self takeallweapons();
			//self maps\mp\gametypes\_hardpoints::giveOwnedHardpointItem();
			self giveweapon( weapon );
			
			// If the player doesn't any ammo left there's no point to go into last stand
			if ( totalAmmoLeft > 0 ) 
			{
				self setWeaponAmmoStock( weapon,50);
				self setWeaponAmmoClip( weapon, 35 );
			}
			else 
			{
				self.useLastStandParams = true;
				self ensureLastStandParamsValidity();
				self suicide();
				return;
			}
			
			self switchToWeapon( weapon );
			self GiveWeapon( grenadeTypePrimary );
			self SetWeaponAmmoClip( grenadeTypePrimary, 0 );
			self SwitchToOffhand( grenadeTypePrimary );
			
			playerHasPistol = true;
			break;
		}
	}
	
	// Check if the player already had a pistol
	if ( !playerHasPistol ) 
	{
		// This player doesn't have any pistol so there's no point to go into last stand

		self.useLastStandParams = true;
		self ensureLastStandParamsValidity();
		self suicide();
		return;
		
		
		self takeallweapons();
		//self maps\mp\gametypes\_hardpoints::giveOwnedHardpointItem();
		self giveWeapon( "beretta_mp" );
		self giveMaxAmmo( "beretta_mp" );
		self switchToWeapon( "beretta_mp" );
		self GiveWeapon( grenadeTypePrimary );
		self SetWeaponAmmoClip( grenadeTypePrimary, 0 );
		self SwitchToOffhand( grenadeTypePrimary );
	}
	
	notifyData = spawnStruct();
	notifyData.titleText = game["strings"]["last_stand"]; //"Last Stand!";
	//notifyData.iconName = "specialty_pistoldeath";
	notifyData.glowColor = (1,0,0);
	notifyData.sound = "mp_last_stand";
	notifyData.duration = 2.0;
	self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
	
	self thread lastStandTimer( 40 );
}

lastStandTimer( delay )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "game_ended" );
	
	self freezeControls( false );
	self allowSprint(false);
	self allowJump(false);
		
	self thread lastStandWaittillDeath();
	
	self.lastStand = true;
	//self setLowerMessage( &"PLATFORM_COWARDS_WAY_OUT" );
	
	self thread lastStandAllowSuicide();
	//self thread lastStandKeepOverlay();
	
	wait delay;
	
	self thread LastStandBleedOut();
}

LastStandBleedOut()
{
	self.useLastStandParams = true;
	self ensureLastStandParamsValidity();
	self suicide();
}

lastStandAllowSuicide()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "game_ended" );
	
	while(1) {
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
	
	self thread LastStandBleedOut();
}

lastStandKeepOverlay()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "game_ended" );
	
	// keep the health overlay going by making code think the player is getting damaged
	while(1) 
	{
		self.health = 2;
		wait level.oneFrame;
		self.health = 1;
		wait level.oneFrame;
	}
}

lastStandWaittillDeath()
{
	self endon( "disconnect" );
	
	self waittill( "death" );
	
	self clearLowerMessage();
	self.lastStand = undefined;
}

mayDoLastStand( sWeapon, sMeansOfDeath, sHitLoc )
{
	if ( sMeansOfDeath != "MOD_PISTOL_BULLET" && sMeansOfDeath != "MOD_RIFLE_BULLET" && sMeansOfDeath != "MOD_FALLING" )
		return false;
		
	if ( isHeadShot(sHitLoc, sMeansOfDeath ) )
		return false;
		
	return true;
}

ensureLastStandParamsValidity()
{
	// attacker may have become undefined if the player that killed me has disconnected
	if ( !isDefined( self.lastStandParams.attacker ) )
		self.lastStandParams.attacker = self;
}



notifyConnecting()
{
	
	waittillframeend;
	
	if( isDefined( self ) )
	level notify( "connecting", self );
}


setObjectiveText( team, text )
{
	game["strings"]["objective_"+team] = text;
	precacheString( text );
}

setObjectiveScoreText( team, text )
{
	game["strings"]["objective_score_"+team] = text;
	precacheString( text );
}

setObjectiveHintText( team, text )
{
	game["strings"]["objective_hint_"+team] = text;
	precacheString( text );
}

getObjectiveText( team )
{
	if ( !isDefined( game["strings"]["objective_"+team] ) )
	return "";	
	return game["strings"]["objective_"+team];
}

getObjectiveScoreText( team )
{
	if ( !isDefined( game["strings"]["objective_score_"+team] ) )
	return "";
	return game["strings"]["objective_score_"+team];
}

getObjectiveHintText( team )
{
	if ( !isDefined( game["strings"]["objective_hint_"+team] ) )
	return "";

	return game["strings"]["objective_hint_"+team];
}

getHitLocHeight( sHitLoc )
{
	switch( sHitLoc )
	{
	case "helmet":
	case "head":
	case "neck":
		return 60;
	case "torso_upper":
	case "right_arm_upper":
	case "left_arm_upper":
	case "right_arm_lower":
	case "left_arm_lower":
	case "right_hand":
	case "left_hand":
	case "gun":
		return 48;
	case "torso_lower":
		return 40;
	case "right_leg_upper":
	case "left_leg_upper":
		return 32;
	case "right_leg_lower":
	case "left_leg_lower":
		return 10;
	case "right_foot":
	case "left_foot":
		return 5;
	}
	return 48;
}

debugLine( start, end )
{
	for ( i = 0; i < 50; i++ )
	{
		line( start, end );
		wait level.oneFrame;
	}
}
//UPDATED 22.6.18
delayStartRagdoll( ent, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath )
{
	
	if ( isDefined( ent ) )
	{
		//CODE from BO
		
		if ( ent isRagDoll() )
		return;
		
		if ( !isDefined( vDir ) )
		vDir = (0,0,0);
		
		explosionPos = ent.origin + ( 0, 0, getHitLocHeight( sHitLoc ) );
		explosionPos -= vDir * 20;
		explosionRadius = 40;
		explosionForce = 0.70;
		
		if ( sMeansOfDeath == "MOD_IMPACT" || sMeansOfDeath == "MOD_EXPLOSIVE" || isSubStr(sMeansOfDeath, "MOD_GRENADE") || isSubStr(sMeansOfDeath, "MOD_PROJECTILE"))
		{
			explosionForce = 3.0;
		}

		if (isSubStr(sWeapon, "dragunov") || isSubStr(sWeapon, "barrett") || isSubStr(sWeapon, "m40a3") || isSubStr(sWeapon, "remington700"))
		{
			explosionForce = 2.5;
		}
		
		//  Shotgun
		if ( isSubStr(sWeapon, "winchester") || isSubStr(sWeapon, "m1014"))
		{
			explosionForce = 2.0;
		}
		
		ent startragdoll( 1 );
		
		xwait( 0.05, false );
		
		if ( !isDefined( ent ) )
		return;
			
		// apply extra physics force to make the ragdoll go crazy
		physicsExplosionSphere( explosionPos, explosionRadius, explosionRadius/2, explosionForce );
	}	
}


isExcluded( entity, entityList )
{
	for ( index = 0; index < entityList.size; index++ )
	{
		if ( entity == entityList[index] )
		return true;
	}
	return false;
}

leaderDialog( dialog, team, group, excludeList )
{
	assert( isdefined( level.players ) );

	if ( !isDefined( team ) )
	{
		leaderDialogBothTeams( dialog, "allies", dialog, "axis", group, excludeList );
		return;
	}

	if ( isDefined( excludeList ) )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( (isDefined( player.pers["team"] ) && (player.pers["team"] == team )) && !isExcluded( player, excludeList ) )
			player leaderDialogOnPlayer( dialog, group );
		}
	}
	else
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( isDefined( player.pers["team"] ) && (player.pers["team"] == team ) )
			player leaderDialogOnPlayer( dialog, group );
		}
	}
}

leaderDialogBothTeams( dialog1, team1, dialog2, team2, group, excludeList )
{
	assert( isdefined( level.players ) );

	if ( isDefined( excludeList ) )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			team = player.pers["team"];

			if ( !isDefined( team ) )
			continue;

			if ( isExcluded( player, excludeList ) )
			continue;

			if ( team == team1 )
			player leaderDialogOnPlayer( dialog1, group );
			else if ( team == team2 )
			player leaderDialogOnPlayer( dialog2, group );
		}
	}
	else
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			team = player.pers["team"];

			if ( !isDefined( team ) )
			continue;

			if ( team == team1 )
			player leaderDialogOnPlayer( dialog1, group );
			else if ( team == team2 )
			player leaderDialogOnPlayer( dialog2, group );
		}
	}
}


leaderDialogOnPlayer( dialog, group )
{
	team = self.pers["team"];

	if ( !isDefined( team ) )
	return;

	//if ( team != "allies" && team != "axis" )//controla dialogo para spec
	//	return;

	if ( isDefined( group ) )
	{
		// ignore the message if one from the same group is already playing
		if ( self.leaderDialogGroup == group )
		return;

		hadGroupDialog = isDefined( self.leaderDialogGroups[group] );

		self.leaderDialogGroups[group] = dialog;
		dialog = group;

		// exit because the "group" dialog call is already in the queue
		if ( hadGroupDialog )
		return;
	}

	if ( !self.leaderDialogActive )
	self thread playLeaderDialogOnPlayer( dialog, team );
	else
	self.leaderDialogQueue[self.leaderDialogQueue.size] = dialog;
}


playLeaderDialogOnPlayer( dialog, team )
{
	self endon ( "disconnect" );

	self.leaderDialogActive = true;
	if ( isDefined( self.leaderDialogGroups[dialog] ) )
	{
		group = dialog;
		dialog = self.leaderDialogGroups[group];
		self.leaderDialogGroups[group] = undefined;
		self.leaderDialogGroup = group;
	}

	if ( isDefined( game["dialog"][dialog] ) ) {
		// Split all the dialogs that we should play
		dialogs = strtok( game["dialog"][dialog], ";" );
		for ( idialog = 0; idialog < dialogs.size; idialog++ ) {
			dialog = dialogs[idialog];
			self playLocalSound( game["voice"][team]+dialog );
			xwait( 3.0, false );
		}
	}

	self.leaderDialogActive = false;
	self.leaderDialogGroup = "";

	if ( self.leaderDialogQueue.size > 0 )
	{
		nextDialog = self.leaderDialogQueue[0];

		for ( i = 1; i < self.leaderDialogQueue.size; i++ )
		self.leaderDialogQueue[i-1] = self.leaderDialogQueue[i];
		self.leaderDialogQueue[i-1] = undefined;

		self thread playLeaderDialogOnPlayer( nextDialog, team );
	}
}


showPlayerJoinedTeam()
{
	
	// Initialize variable
	teamJoined = &"";
	
	// Get what team the player has joined
	if ( self.pers["team"] == "spectator" ) 
	{
		teamJoined = &"GAME_SPECTATOR";
	} 
	else 
	{
		switch ( game[self.pers["team"]] ) 
		{
		case "sas":
		case "marines":
			teamJoined = level.scr_team_allies_name;
			break;
			
		case "russian":
		case "opfor":
		case "arab":
			teamJoined = level.scr_team_axis_name;
			break;
		}
	}
	
	// Display a message to all the players in the server
	iprintln( &"OW_JOINED_TEAM", self.name, teamJoined );
	
}


rulesetLoaded()
{
	rulesetLoaded = true;
	
	// Initialize the rule sets
	if ( level.cod_mode != "" ) {
		// Check if we have a rule for this league and gametype first
		if ( isDefined( level.matchRules[ level.cod_mode ] ) ) {
			if ( isDefined( level.matchRules[ level.cod_mode ][ level.gametype ] ) ) {
				[[ level.matchRules[ level.cod_mode ][ level.gametype ] ]]();
			//	logPrint( "RSM;Ruleset " + level.cod_mode + " loaded.\n" );
				
			} else if ( isDefined( level.matchRules[ level.cod_mode ]["all"] ) ) {
				[[ level.matchRules[ level.cod_mode ][ "all" ] ]]();
			//	logPrint( "RSM;Ruleset " + level.cod_mode + " loaded.\n" );
				
			} else {
				// Rule is not valid or doesn't support the current gametype
				rulesetLoaded = false;
			}
		}
	}
	level.scr_league_ruleset = getdvarx( "scr_league_ruleset", "string", "" );
	
	return rulesetLoaded;
}	



