#include promatch\_utils;

init()
{

	// Get the module's dvar
	level.teamBalance = getdvarx( "scr_teambalance_public", "int", 0, 0, 1 );
	level.maxClients = getDvarInt( "sv_maxclients" );
	
	//scr_sd_teamBalanceEndOfRound
	level.teamBalanceEndOfRound = getdvarx( "scr_" + level.gameType + "_teamBalanceEndOfRound", "int", ( level.gameType == "sd" ), 0, 1 );
	level.scr_teambalance_show_message =  getdvarx( "scr_teambalance_show_message", "int", 0, 0, 1 );
	level.scr_teambalance_check_interval = getdvarx( "scr_teambalance_check_interval", "float", 10.0, 1.0, 120.0 );
	level.scr_teambalance_delay = getdvarx( "scr_teambalance_delay", "int", 1, 0, 30 );
	
	
	game["strings"]["autobalance"] = &"MP_AUTOBALANCE_NOW";
	
	/*switch(game["allies"])
	{
		case "marines":
		precacheShader("mpflag_american");
		break;
	}
	
	precacheShader("mpflag_russian");
	precacheShader("mpflag_spectator");*/
	
	setPlayerModels();

	level.freeplayers = [];
	
	if( level.teamBased )
	{
		level thread onPlayerConnect();
		
		if(level.cod_mode != "practice")
		level thread updateTeamBalance();
		
		xwait(0.15,false);		
		level thread updatePlayerTimes();
	}
}
//if(isdefined(self.admin) && self.admin)
	//return;
onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);

		player.dont_auto_balance = undefined;
		
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
		
		if (level.gametype != "dm")
		player thread trackPlayedTime();
		
	}
}

onJoinedTeam()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_team");
		self updateTeamTime();
	}
}


onJoinedSpectators()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_spectators");
		self.pers["teamTime"] = undefined;
		
		//if(self.vipuser && level.cod_mode != "torneio")
		self.statusicon = "hud_status_dead";
	}
}

//01
updateTeamBalance()
{
	if(level.cod_mode == "torneio")
		return;
	
	level.teamLimit = level.maxclients / 2;
	
	level.balancingteams = false;
	
	wait .15;

	level endon ( "game_ended" );
	for( ;; )
	{
		if( level.teamBalance && !level.balancingteams )
		{
			//iprintln("BalanceNeed?: " + NeedsTeamBalance());
			
			if(NeedsTeamBalance())
			{
				xwait ( level.scr_teambalance_delay,false );
				
				level balanceDeadPlayers();
			}			
			xwait ( level.scr_teambalance_check_interval,false );
		}		
		wait 2.0;
	}
}

//03
NeedsTeamBalance()
{
	level.team["allies"] = 0;
	level.team["axis"] = 0;

	players = level.players;
	for(i = 0; i < players.size; i++)
	{
		if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
			level.team["allies"]++;
		else if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "axis"))
			level.team["axis"]++;
	}

	if((level.team["allies"] > (level.team["axis"] + 1)) || (level.team["axis"] > (level.team["allies"] + 1)))
		return true;//precisa
	else
		return false;
}

balanceDeadPlayers()
{
	if( level.teamBalanceEndOfRound )
		return;
	
	AlliedPlayers = [];
	AxisPlayers = [];
	
	players = level.players;
	for(i = 0; i < players.size; i++)
	{
		if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
			AlliedPlayers[AlliedPlayers.size] = players[i];
		else if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "axis"))
			AxisPlayers[AxisPlayers.size] = players[i];
	}
	numToBalance = int( abs( AxisPlayers.size - AlliedPlayers.size) ) - 1;
	
	if(numToBalance > 0)
	level.balancingteams = true;
	
	//iprintln("numToBalance?: " + numToBalance);
	//cannot switch on undefined: (file 'maps/mp/gametypes/_teams.gsc', line 720)
	while( numToBalance > 0 && ((AlliedPlayers.size > (AxisPlayers.size + 1)) || (AxisPlayers.size > (AlliedPlayers.size + 1))))
	{	
		if(AlliedPlayers.size > (AxisPlayers.size + 1))
		{
			for(j = 0; j < AlliedPlayers.size; j++)
			{			
				if(isAlive(AlliedPlayers[j])) continue;
				
				if(isDefined(AlliedPlayers[j].dont_auto_balance)) continue;
				
				if(isDefined(AlliedPlayers[j].squad)) continue;
				
				if(isDefined(AlliedPlayers[j].pers["class"]) && isDefined(AlliedPlayers[j].pers["team"]))
				{
					AlliedPlayers[j] changeTeam("axis");
					break;
				}				
			}			
		}
		else if(AxisPlayers.size > (AlliedPlayers.size + 1))
		{
			for(j = 0; j < AxisPlayers.size; j++)
			{
			
				if(isAlive(AxisPlayers[j])) continue;
					
				if(isDefined(AxisPlayers[j].dont_auto_balance)) continue;
				
				if(isDefined(AxisPlayers[j].squad)) continue;

					if(isDefined(AxisPlayers[j].pers["class"]) && isDefined(AxisPlayers[j].pers["team"]))
					{
						AxisPlayers[j] changeTeam("allies");				
						break;
					}				
			}
		}
		
		AlliedPlayers = [];
		AxisPlayers = [];
		numToBalance--;
		
		players = level.players;
		for(i = 0; i < players.size; i++)
		{
			if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
				AlliedPlayers[AlliedPlayers.size] = players[i];
			else if((isdefined(players[i].pers["team"])) &&(players[i].pers["team"] == "axis"))
				AxisPlayers[AxisPlayers.size] = players[i];
		}
	}
	
	level.balancingteams = false;
}

changeTeam( team )
{
	self closeMenu();
	self closeInGameMenu();
	
	
	
	if(self.pers["team"] != team)
	{
		
		if ( isDefined( self.pers["team"] ) && (self.sessionstate == "dead") )
		{
			
			self.switching_teams = true;
			self.joining_team = team;
			self.leaving_team = self.pers["team"];
			self suicide();			
		}

		self.pers["team"] = team;
		self.team = team;
		self.pers["weapon"] = undefined;
		self.pers["savedmodel"] = undefined;

		self maps\mp\gametypes\_globallogic::updateObjectiveText();

		if ( level.teamBased )
		self.sessionteam = team;
		else
		self.sessionteam = "none";

		if ( !isAlive( self ) ) 
		self.statusicon = "hud_status_dead";
	
		self notify("joined_team");
		//self notify("end_respawn");
		
		
		//atualiza o menu para o nome time
		self setclientdvar("g_scriptMainMenu", game["menu_class"]);
		
		if(level.atualgtype != "sd" && game["state"] == "playing")
		{
			self.changedmodel = undefined;
			maps\mp\_utility::clearLowerMessage();
			self thread	[[level.spawnPlayer]]();		
		}	
		
	}
}

canAutobalance(player)
{
	//iprintln("canAutobalance" + player.name );
	if ( !level.teamBalanceEndOfRound && ( ( isdefined( player.isDefusing ) && player.isDefusing ) || ( isdefined( player.isPlanting ) && player.isPlanting ) || isDefined( player.carryObject ) ) )
		return false;
	else
		return true;
	
}



trackPlayedTime()
{
	self endon( "disconnect" );
	
	self.timePlayed["allies"] = 0;
	self.timePlayed["axis"] = 0;
	self.timePlayed["total"] = 0;
	
	while ( level.inPrematchPeriod || level.inStrategyPeriod || level.inReadyUpPeriod)
	wait level.oneFrame;

	for ( ;; )
	{
		if ( isDefined( game["state"] ) && game["state"] == "playing" )
		{
			if ( self.sessionteam == "allies" )
			{
				self.timePlayed["allies"]++;
				self.timePlayed["total"]++;
				
			}
			else if ( self.sessionteam == "axis" )
			{
				self.timePlayed["axis"]++;
				self.timePlayed["total"]++;
			}
		}

		xwait( 1.0, false );
	}
}


updatePlayerTimes()
{
	nextToUpdate = 0;
	for ( ;; )
	{
		nextToUpdate++;
		if ( nextToUpdate >= level.players.size )
			nextToUpdate = 0;

		if ( isDefined( level.players[nextToUpdate] ) )
			level.players[nextToUpdate] updatePlayedTime();

		xwait( 4.0,false );
	}
}


updatePlayedTime()
{
	if ( self.timePlayed["allies"] ) 
	{
		self statAdds( "time_played_allies", self.timePlayed["allies"] );
		self statAdds( "time_played_total", self.timePlayed["allies"] );
	}
	
	if ( self.timePlayed["axis"] )
	{
		self statAdds( "time_played_opfor", self.timePlayed["axis"] );
		self statAdds( "time_played_total", self.timePlayed["axis"] );
	}
	
	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
	return;

	self.timePlayed["allies"] = 0;
	self.timePlayed["axis"] = 0;
	self.timePlayed["total"] = 0;
}


updateTeamTime()
{
	if ( game["state"] != "playing" )
		return;

	if ( game["state"] == "postgame" )
		return;
	
	self.pers["teamTime"] = getTime();
}




/*
carrega 1 vez a cada mapa.o sv deve gerenciar

game["allies_model"]["COMMANDO"] = mptype\mptype_ally_urban_sniper::main;
-> character\character_mp_sas_urban_assault::main();
->	self setModel("body_mp_sas_urban_assault");
	self setViewmodel("viewhands_black_kit");
	self.voice = "british";

*/
setPlayerModels()
{
	//CUSTOM NAO DO JOGO
	precacheModel("viewhands_mw2_ranger_airborne");
	precacheModel("viewhands_mw2_udt");
	precacheModel("viewhands_mw2_militia");
	precacheModel("viewhands_mw2_ranger");
	precacheModel("playermodel_mw3_juggernaunt");
	
	
	game["allies_model"] = [];
	game["axis_model"] = [];
	
	alliesCharSet = tableLookup( "mp/mapsTable.csv", 0, getDvar( "mapname" ), 1 );
	if ( !isDefined( alliesCharSet ) || alliesCharSet == "" )
	{
		if ( !isDefined( game["allies_soldiertype"] ) || !isDefined( game["allies"] ) )
		{
			game["allies_soldiertype"] = "desert";
			game["allies"] = "marines";
		}
	}
	else
		game["allies_soldiertype"] = alliesCharSet;

	axisCharSet = tableLookup( "mp/mapsTable.csv", 0, getDvar( "mapname" ), 2 );
	if ( !isDefined( axisCharSet ) || axisCharSet == "" )
	{
		if ( !isDefined( game["axis_soldiertype"] ) || !isDefined( game["axis"] ) )
		{
			game["axis_soldiertype"] = "desert";
			game["axis"] = "arab";
		}
	}
	else
		game["axis_soldiertype"] = axisCharSet;

	//=================================================
	//===============MODELS============================
	//=================================================
	
	if ( game["allies_soldiertype"] == "desert" )
	{
		assert( game["allies"] == "marines" );
		if ( game["allies"] != "marines" ) 
		{
			iprintln( "WARNING: game[\"allies\"] == "+game["allies"]+", expected \"marines\"." );
			game["allies"] = "marines";
		}
		
		//Mapas comuns BACKLOT CRASH ETC
		
		//mptype\mptype_ally_cqb::precache();
		/*
		main()
		{
			self setModel("body_mp_usmc_specops");
			self attach("head_mp_usmc_tactical_mich_stripes_nomex", "", true);
			self setViewmodel("viewmodel_base_viewhands");
			self.voice = "american";
		}

		precache()
		{
			precacheModel("body_mp_usmc_specops");
			precacheModel("head_mp_usmc_tactical_mich_stripes_nomex");
			precacheModel("viewmodel_base_viewhands");
		}
		*/
		//mptype\mptype_ally_sniper::precache();//normal
		precacheModel("body_mp_usmc_sniper");
		precacheModel("head_mp_usmc_tactical_baseball_cap");
		/*
		main()
		{
			self setModel("body_mp_usmc_sniper");
			self attach("head_mp_usmc_tactical_baseball_cap", "", true);
			self setViewmodel("viewmodel_base_viewhands");
			self.voice = "american";
		}

		precache()
		{
			precacheModel("body_mp_usmc_sniper");
			precacheModel("head_mp_usmc_tactical_baseball_cap");
			precacheModel("viewmodel_base_viewhands");
		}
		*/
		//mptype\mptype_ally_engineer::precache();
		/*
		main()
		{
			self setModel("body_mp_usmc_recon");
			self attach("head_mp_usmc_nomex", "", true);
			self setViewmodel("viewmodel_base_viewhands");
			self.voice = "american";
		}

		precache()
		{
			precacheModel("body_mp_usmc_recon");
			precacheModel("head_mp_usmc_nomex");
			precacheModel("viewmodel_base_viewhands");
		}
		*/
		//mptype\mptype_ally_rifleman::precache(); //colete
		precacheModel("body_mp_usmc_assault");
		precacheModel("head_mp_usmc_tactical_mich");
		/*
		main()
		{
			self setModel("body_mp_usmc_assault");
			self attach("head_mp_usmc_tactical_mich", "", true);
			self setViewmodel("viewmodel_base_viewhands");
			self.voice = "american";
		}

		precache()
		{
			precacheModel("body_mp_usmc_assault");
			precacheModel("head_mp_usmc_tactical_mich");
			precacheModel("viewmodel_base_viewhands");
		}
		*/
		//mptype\mptype_ally_support::precache(); //medico
		precacheModel("body_mp_usmc_support");
		precacheModel("head_mp_usmc_shaved_head");
		/*
		main()
		{
			self setModel("body_mp_usmc_support");
			self attach("head_mp_usmc_shaved_head", "", true);
			self setViewmodel("viewmodel_base_viewhands");
			self.voice = "american";
		}

		precache()
		{
			precacheModel("body_mp_usmc_support");
			precacheModel("head_mp_usmc_shaved_head");
			precacheModel("viewmodel_base_viewhands");
		}
		*/
		
		precacheModel("body_mp_usmc_specops");
		

		
		//STRIKE ALLIES
		game["allies_model"]["NORMAL"] = ::usmcmarinesallies_normal;
		game["allies_model"]["ASSAULT"] = ::usmcmarinesallies_assault;
		game["allies_model"]["MEDIC"] = ::usmcmarinesallies_medic;
		game["allies_model"]["CLANMEMBER"] = ::urbanallies_clanmember;
		
	}
	else if ( game["allies_soldiertype"] == "urban" )//KILLHOUSE
	{
		// assert( game["allies"] == "sas" );
		if ( game["allies"] != "sas" ) 
		{
			iprintln( "WARNING: game[\"allies\"] == "+game["allies"]+", expected \"sas\"." );
			game["allies"] = "sas";
		}
		
		
		//2024 TESTE -devido ao problema de HS usar apenas esse		
		//precacheModel("viewhands_black_kit");
		
		//COM CAPA		
		precacheModel("head_mp_usmc_tactical_mich");

		//CLAN
		precacheModel("body_mp_usmc_woodland_specops");
		precacheModel("head_mp_usmc_tactical_mich_stripes_nomex");
		precacheModel("body_mp_opforce_sniper");		
		
		//SEM CAPA
		precacheModel("head_mp_usmc_tactical_baseball_cap");
		precacheModel("body_mp_usmc_woodland_support");
		precacheModel("head_mp_usmc_nomex");
		
		
		
		//derail
		game["allies_model"]["ASSAULT"] = ::woodland_assault;
		game["allies_model"]["NORMAL"] = ::woodland_normal;
		game["allies_model"]["CLANMEMBER"] = ::woodland_clanmember;
		game["allies_model"]["MEDIC"] = ::woodland_normal;
		
		
	}
	else
	{
		// assert( game["allies"] == "sas" );
		if ( game["allies"] != "marines" ) {
			iprintln( "WARNING: game[\"allies\"] == "+game["allies"]+", expected \"marines\"." );
			game["allies"] = "marines";
		}
		
		//mptype\mptype_ally_woodland_assault::precache();
		precacheModel("body_mp_usmc_woodland_assault");
		precacheModel("head_mp_usmc_tactical_mich");
		/*
		main()
		{
			self setModel("body_mp_usmc_woodland_assault");
			self attach("head_mp_usmc_tactical_mich", "", true);
			self setViewmodel("viewhands_sas_woodland");
			self.voice = "british";
		}

		precache()
		{
			precacheModel("body_mp_usmc_woodland_assault");
			precacheModel("head_mp_usmc_tactical_mich");
			precacheModel("viewhands_sas_woodland");
		}
		*/
		//mptype\mptype_ally_woodland_recon::precache();
		//mptype\mptype_ally_woodland_sniper::precache();		
		precacheModel("body_mp_usmc_woodland_sniper");
		precacheModel("head_mp_usmc_ghillie");
		
		/*
		main()
		{
			self setModel("body_mp_usmc_woodland_sniper");
			self attach("head_mp_usmc_ghillie", "", true);
			self setViewmodel("viewhands_marine_sniper");
			self.voice = "british";
		}

		precache()
		{
			precacheModel("body_mp_usmc_woodland_sniper");
			precacheModel("head_mp_usmc_ghillie");
			precacheModel("viewhands_marine_sniper");
		}
		*/
		//mptype\mptype_ally_woodland_specops::precache();
		
		//mptype\mptype_ally_woodland_support::precache();
		precacheModel("body_mp_usmc_woodland_support");
		precacheModel("head_mp_usmc_shaved_head");
		/*
		main()
		{
			self setModel("body_mp_usmc_woodland_support");
			self attach("head_mp_usmc_shaved_head", "", true);
			self setViewmodel("viewhands_sas_woodland");
			self.voice = "british";
		}

		precache()
		{
			precacheModel("body_mp_usmc_woodland_support");
			precacheModel("head_mp_usmc_shaved_head");
			precacheModel("viewhands_sas_woodland");
		}
		*/


		//CLAN
	//	precacheModel("mp_fullbody_sniper_aa_desert");
		precacheModel("body_mp_usmc_woodland_specops");
		precacheModel("head_mp_usmc_tactical_mich_stripes_nomex");
		//precacheModel("viewhands_black_kit");		

		game["allies_model"]["NORMAL"] = ::woodlandmarinesallies_normal;
		game["allies_model"]["ASSAULT"] = ::woodlandmarinesallies_assault;
		game["allies_model"]["MEDIC"] = ::woodlandmarinesallies_medic;
		game["allies_model"]["CLANMEMBER"] = ::woodland_clanmember;
	}

	
	
	if ( game["axis_soldiertype"] == "desert" )
	{
		// assert( game["axis"] == "opfor" || game["axis"] == "arab" );
		if ( game["axis"] != "opfor" && game["axis"] != "arab" ) {
			iprintln( "WARNING: game[\"axis\"] == "+game["axis"]+", expected \"opfor\" or \"arab\".");
			game["axis"] = "opfor";
		}
		
		//mptype\mptype_axis_cqb::precache();
		/*
		main()
		{
		self setModel("body_mp_arab_regular_cqb");
		self attach("head_mp_arab_regular_headwrap", "", true);
		self setViewmodel("viewhands_desert_opfor");
		self.voice = "arab";
		}

		precache()
		{
		precacheModel("body_mp_arab_regular_cqb");
		precacheModel("head_mp_arab_regular_headwrap");
		precacheModel("viewhands_desert_opfor");
		}
		*/
		//mptype\mptype_axis_sniper::precache();//crash na toujane??
		precacheModel("body_mp_arab_regular_sniper");
			precacheModel("head_mp_arab_regular_sadiq");
		/*
		main()
		{
			self setModel("body_mp_arab_regular_sniper");
			self attach("head_mp_arab_regular_sadiq", "", true);
			self setViewmodel("viewhands_desert_opfor");
			self.voice = "arab";
		}

		precache()
		{
			precacheModel("body_mp_arab_regular_sniper");
			precacheModel("head_mp_arab_regular_sadiq");
			precacheModel("viewhands_desert_opfor");
		}
		*/
		//mptype\mptype_axis_engineer::precache();
		/*
		main()
			{
				self setModel("body_mp_arab_regular_engineer");
				self attach("head_mp_arab_regular_ski_mask", "", true);
				self setViewmodel("viewhands_desert_opfor");
				self.voice = "arab";
			}

			precache()
			{
				precacheModel("body_mp_arab_regular_engineer");
				precacheModel("head_mp_arab_regular_ski_mask");
				precacheModel("viewhands_desert_opfor");
			}
		*/
		//mptype\mptype_axis_rifleman::precache();
		precacheModel("body_mp_arab_regular_assault");
			precacheModel("head_mp_arab_regular_suren");
		/*
		main()
		{
			self setModel("body_mp_arab_regular_assault");
			self attach("head_mp_arab_regular_suren", "", true);
			self setViewmodel("viewhands_desert_opfor");
			self.voice = "arab";
		}

		precache()
		{
			precacheModel("body_mp_arab_regular_assault");
			precacheModel("head_mp_arab_regular_suren");
			precacheModel("viewhands_desert_opfor");
		}
		*/
		//mptype\mptype_axis_support::precache();	
		precacheModel("body_mp_arab_regular_support");
		precacheModel("head_mp_arab_regular_asad");
		/*
		main()
		{
			self setModel("body_mp_arab_regular_support");
			self attach("head_mp_arab_regular_asad", "", true);
			self setViewmodel("viewhands_desert_opfor");
			self.voice = "arab";
		}

		precache()
		{
			precacheModel("body_mp_arab_regular_support");
			precacheModel("head_mp_arab_regular_asad");
			precacheModel("viewhands_desert_opfor");
		}
		*/		
		//mptype\mptype_axis_engineer::precache();
		/*
		main()
		{
			self setModel("body_mp_arab_regular_engineer");
			self attach("head_mp_arab_regular_ski_mask", "", true);
			self setViewmodel("viewhands_desert_opfor");
			self.voice = "arab";
		}

		precache()
		{
			precacheModel("body_mp_arab_regular_engineer");
			precacheModel("head_mp_arab_regular_ski_mask");
			precacheModel("viewhands_desert_opfor");
		}
		*/
		

		
		precacheModel("head_mp_usmc_tactical_mich_stripes_nomex");
		precacheModel("body_mp_arab_regular_cqb");
		
		//STRIKE-TOUJANE-BACKLOT OPFOR
		game["axis_model"]["NORMAL"] = ::arabopforaxis_normal;
		game["axis_model"]["ASSAULT"] = ::arabopforaxis_assault;
		game["axis_model"]["MEDIC"] = ::arabopforaxis_medic;
		game["axis_model"]["CLANMEMBER"] = ::arab_clanmember;
	}
	else if ( game["axis_soldiertype"] == "urban" )
	{
		// assert( game["axis"] == "opfor" );
		if ( game["axis"] != "russian" ) {
			iprintln( "WARNING: game[\"axis\"] == "+game["axis"]+", expected \"russian\".");
			game["axis"] = "russian";
		}	
		
		//mptype\mptype_axis_urban_sniper::precache();
		precacheModel("body_mp_opforce_sniper_urban");
		precacheModel("head_mp_opforce_justin");
		/*
		main()
			{
				self setModel("body_mp_opforce_sniper_urban");
				self attach("head_mp_opforce_justin", "", true);
				self setViewmodel("viewhands_op_force");
				self.voice = "russian";
			}

			precache()
			{
				precacheModel("body_mp_opforce_sniper_urban");
				precacheModel("head_mp_opforce_justin");
				precacheModel("viewhands_op_force");
			}

		*/
		//mptype\mptype_axis_urban_support::precache();
		precacheModel("body_mp_opforce_support");
		precacheModel("head_mp_opforce_3hole_mask");
		/*
				main()
		{
			self setModel("body_mp_opforce_support");
			self attach("head_mp_opforce_3hole_mask", "", true);
			self setViewmodel("viewhands_op_force");
			self.voice = "russian";
		}

		precache()
		{
			precacheModel("body_mp_opforce_support");
			precacheModel("head_mp_opforce_3hole_mask");
			precacheModel("viewhands_op_force");
		}

		*/
		//mptype\mptype_axis_urban_assault::precache();
		precacheModel("body_mp_opforce_assault");
		precacheModel("head_mp_opforce_headwrap");
		/*
		main()
		{
			self setModel("body_mp_opforce_assault");
			self attach("head_mp_opforce_headwrap", "", true);
			self setViewmodel("viewhands_op_force");
			self.voice = "russian";
		}

		precache()
		{
			precacheModel("body_mp_opforce_assault");
			precacheModel("head_mp_opforce_headwrap");
			precacheModel("viewhands_op_force");
		}
		*/
		//mptype\mptype_axis_urban_engineer::precache();
		/*
		main()
			{
				self setModel("body_mp_opforce_eningeer");
				self attach("head_mp_opforce_gasmask", "", true);
				self setViewmodel("viewhands_op_force");
				self.voice = "russian";
			}

			precache()
			{
				precacheModel("body_mp_opforce_eningeer");
				precacheModel("head_mp_opforce_gasmask");
				precacheModel("viewhands_op_force");
			}

		*/
		//mptype\mptype_axis_urban_cqb::precache();
		/*
				main()
		{
			self setModel("body_mp_opforce_cqb");
			self attach("head_mp_opforce_gasmask", "", true);
			self setViewmodel("viewhands_op_force");
			self.voice = "russian";
		}

		precache()
		{
			precacheModel("body_mp_opforce_cqb");
			precacheModel("head_mp_opforce_gasmask");
			precacheModel("viewhands_op_force");
		}
		*/

		//precacheModel("head_mp_usmc_tactical_mich");
		precacheModel("body_mp_opforce_sniper");	
		
		game["axis_model"]["NORMAL"] = ::urbanrussianaxis_normal;
		game["axis_model"]["ASSAULT"] = ::urbanaxis_assault;
		game["axis_model"]["MEDIC"] = ::urbanrussianaxis_medic;
		game["axis_model"]["CLANMEMBER"] = ::urban_clanmember;
	}
	else //game["axis_soldiertype"] = "woodland";
	{
		// assert( game["axis"] == "opfor" );
		if ( game["axis"] != "russian" ) {
			iprintln( "WARNING: game[\"axis\"] == "+game["axis"]+", expected \"russian\".");
			game["axis"] = "russian";
		}
		
		//mptype\mptype_axis_woodland_rifleman::precache();
		precacheModel("body_mp_opforce_assault");
		precacheModel("head_mp_opforce_headwrap");
		/*
		main()
		{
			self setModel("body_mp_opforce_assault");
			self attach("head_mp_opforce_headwrap", "", true);
			self setViewmodel("viewhands_op_force");
			self.voice = "russian";
		}

		precache()
		{
			precacheModel("body_mp_opforce_assault");
			precacheModel("head_mp_opforce_headwrap");
			precacheModel("viewhands_op_force");
		}
		*/
		//mptype\mptype_axis_woodland_cqb::precache();
		/*
		main()
		{
		self setModel("body_mp_opforce_cqb");
		self attach("head_mp_opforce_gasmask", "", true);
		self setViewmodel("viewhands_op_force");
		self.voice = "russian";
		}

		precache()
		{
		precacheModel("body_mp_opforce_cqb");
		precacheModel("head_mp_opforce_gasmask");
		precacheModel("viewhands_op_force");
		}
		*/
		//mptype\mptype_axis_woodland_sniper::precache();
		precacheModel("body_mp_opforce_sniper");
		precacheModel("head_mp_opforce_ghillie");
		/*
		main()
			{
				self setModel("body_mp_opforce_sniper");
				self attach("head_mp_opforce_ghillie", "", true);
				self setViewmodel("viewhands_marine_sniper");
				self.voice = "russian";
			}

			precache()
			{
				precacheModel("body_mp_opforce_sniper");
				precacheModel("head_mp_opforce_ghillie");
				precacheModel("viewhands_marine_sniper");
			}
		*/
		//mptype\mptype_axis_woodland_engineer::precache();
		/*
		main()
		{
			self setModel("body_mp_opforce_eningeer");
			self attach("head_mp_opforce_gasmask", "", true);
			self setViewmodel("viewhands_op_force");
			self.voice = "russian";
		}

		precache()
		{
			precacheModel("body_mp_opforce_eningeer");
			precacheModel("head_mp_opforce_gasmask");
			precacheModel("viewhands_op_force");
		}
		*/
		//mptype\mptype_axis_woodland_support::precache();
		precacheModel("body_mp_opforce_support");
		precacheModel("head_mp_opforce_3hole_mask");
		/*
		main()
		{
			self setModel("body_mp_opforce_support");
			self attach("head_mp_opforce_3hole_mask", "", true);
			self setViewmodel("viewhands_op_force");
			self.voice = "russian";
		}

		precache()
		{
			precacheModel("body_mp_opforce_support");
			precacheModel("head_mp_opforce_3hole_mask");
			precacheModel("viewhands_op_force");
		}
		*/

		
		precacheModel("body_mp_opforce_cqb");
		game["axis_model"]["NORMAL"] = ::woodlandaxis_normal;	
		game["axis_model"]["ASSAULT"] = ::woodlandopforaxis_assault;
		game["axis_model"]["MEDIC"] =	::woodlandopforaxis_medic;
		game["axis_model"]["CLANMEMBER"] = ::woodlandopforaxis_member;
	}
}



defaultWoodHands()
{
	self setViewmodel("viewhands_mw2_ranger_airborne");
}

defaultSasHands()
{
	self setViewmodel("viewhands_mw2_udt");
}

//Padrao crash,backlot etc
defaultAxiesOpforHands()
{
	self setViewmodel("viewhands_mw2_militia");
}

defaultAxiesMarinesHands()
{
	self setViewmodel("viewhands_mw2_ranger");
}


usmcmarinesallies_normal()
{
	self setModel("body_mp_usmc_sniper");
	self attach("head_mp_usmc_tactical_baseball_cap", "", true);
	defaultAxiesMarinesHands();
	self.voice = "american";
}

usmcmarinesallies_medic()
{
	self setModel("body_mp_usmc_support");
	self attach("head_mp_usmc_shaved_head", "", true);
	defaultAxiesMarinesHands();
	self.voice = "american";
}

usmcmarinesallies_assault()
{
	self setModel("body_mp_usmc_assault");
	self attach("head_mp_usmc_tactical_mich", "", true);
	defaultAxiesMarinesHands();
	self.voice = "american";
}
		
woodlandmarinesallies_normal()
{
	self setModel("body_mp_usmc_woodland_sniper");
	self attach("head_mp_usmc_ghillie", "", true);
	defaultWoodHands();
	self.voice = "british";
}

woodlandmarinesallies_assault()
{
	self setModel("body_mp_usmc_woodland_assault");
	self attach("head_mp_usmc_tactical_mich", "", true);
	defaultWoodHands();
	self.voice = "british";
}

woodlandmarinesallies_medic()
{
	self setModel("body_mp_usmc_woodland_support");
	self attach("head_mp_usmc_shaved_head", "", true);
	defaultWoodHands();
	self.voice = "british";
}
		

urbanallies_clanmember()
{
	self setModel("body_mp_usmc_specops");
	self attach("head_mp_usmc_tactical_mich_stripes_nomex", "", true);
	defaultAxiesMarinesHands();
	self.voice = "american";
}
		
		
urbanaxis_assault()
{
	self setModel("body_mp_opforce_assault");
	self attach("head_mp_usmc_tactical_mich", "", true);
	defaultSasHands();
	self.voice = "russian";
}
		
		
arab_clanmember()
{
	self setModel("body_mp_arab_regular_cqb");
	self attach("head_mp_usmc_tactical_mich_stripes_nomex", "", true);
	defaultAxiesOpforHands();
	self.voice = "arab";
}

arabopforaxis_normal()
{
	self setModel("body_mp_arab_regular_sniper");
	self attach("head_mp_arab_regular_sadiq", "", true);
	defaultAxiesOpforHands();
	self.voice = "arab";
}

arabopforaxis_assault()
{
	self setModel("body_mp_arab_regular_assault");
	self attach("head_mp_arab_regular_suren", "", true);
	defaultAxiesOpforHands();
	self.voice = "arab";
}

arabopforaxis_medic()
{
	self setModel("body_mp_arab_regular_support");
	self attach("head_mp_arab_regular_asad", "", true);
	defaultAxiesOpforHands();
	self.voice = "arab";
}
		
		
urban_clanmember()
{
	self setModel("body_mp_opforce_sniper");
	self attach("head_mp_usmc_tactical_mich_stripes_nomex", "", true);
	defaultSasHands();
	self.voice = "russian";
}

urbanrussianaxis_normal()
{
	self setModel("body_mp_opforce_sniper_urban");
	self attach("head_mp_opforce_justin", "", true);
	defaultSasHands();
	self.voice = "russian";
}

urbanrussianaxis_medic()
{
	self setModel("body_mp_opforce_support");
	self attach("head_mp_opforce_3hole_mask", "", true);
	defaultSasHands();
	self.voice = "russian";
}
			
			
			
woodlandaxis_normal()
{
	self setModel("body_mp_opforce_cqb");
	self attach("head_mp_opforce_headwrap", "", true);
	defaultSasHands();
	self.voice = "russian";
}		
		
woodlandopforaxis_medic()
{
	self setModel("body_mp_opforce_support");
	self attach("head_mp_opforce_3hole_mask", "", true);
	defaultSasHands();
	self.voice = "russian";
}

woodlandopforaxis_assault()
{
	self setModel("body_mp_opforce_assault");
	self attach("head_mp_opforce_headwrap", "", true);
	defaultSasHands();
	self.voice = "russian";
}


woodlandopforaxis_member()
{
	self setModel("body_mp_opforce_sniper");
	self attach("head_mp_opforce_ghillie", "", true);
	defaultSasHands();
	self.voice = "russian";
}
		
woodland_normal()
{
	self setModel("body_mp_usmc_woodland_support");
	self attach("head_mp_usmc_tactical_baseball_cap", "", true);
	defaultWoodHands();
	self.voice = "british";
}


woodland_assault()
{
	self setModel("body_mp_usmc_woodland_support");
	self attach("head_mp_usmc_tactical_mich", "", true);
	defaultWoodHands();
	self.voice = "british";
}

woodland_clanmember()//killhouse
{
	self setModel("body_mp_opforce_sniper");
	//self setModel("mp_fullbody_sniper_aa_desert");	
	self attach("head_mp_usmc_tactical_mich_stripes_nomex", "", true);
	defaultWoodHands();
	self.voice = "british";
}
		

juggernaut()
{
	self setModel("playermodel_mw3_juggernaunt");
	defaultSasHands();
	self.voice = "british";
}


//[[game[self.pers["team"]+"_model"]["SPECOPS"]]]();
//axis + _model [class]
//usado apenas no cod arena
playerModelForWeapon( weapon )
{
	self detachAll();
	self.isSniper = false;
	
	weaponClass = tablelookup( "mp/weaponslist.csv", 4, weapon, 2 );

	switch ( weaponClass )
	{
		case "weapon_elite":			
		case "weapon_smg":
		case "weapon_assault":
		case "weapon_sniper":
		case "weapon_shotgun":
		case "weapon_lmg":
		[[game[self.pers["team"]+"_model"]["NORMAL"]]]();
			self.atualClass = "assault";
			self.Class = self.atualClass;
			break;
			
		default:
			[[game[self.pers["team"]+"_model"]["NORMAL"]]]();
			self.atualClass = "assault";
			self.Class = self.atualClass;
			break;
	}
	
	self setClientDvar("loadout_curclass", self.atualClass);//CHANGED
	self.curClass = self.atualClass;
	
}


//USADO PELO JOGO NORMAL EM TODOS MODOS
//repete toda vez 
//class_unranked gsc
//self.pers["team"] == "allies" 
//self maps\mp\gametypes\_teams::playerModelForClass( self.pers["class"] );
playerModelForClass( class )
{		
	//iprintln("^1changedmodel-> " + isDefined(self.changedmodel) + " " + self.name );
	
	if(isDefined(self.changedmodel))
	return;
	
	//logDebug("playerModelForClass",self.pers["team"]);
	//logDebug("playerModelForClass",self.atualClass);
	//logDebug("playerModelForClass",self.class);
	//axis
	//assault
	//assault
		
	self.changedmodel = true;
	
	self.setmedicmodel = self IsUpgradesOn("upgrademedicpro");
	self.usingarmorkit = self getStat(2391);
	
	//if(isDefined(self.changedmodel))
	//iprintln("^3changedmodel-> " + self.changedmodel  + " " + self.name );
	
	//iprintln("^3medicpro-> " + self.medicpro);
	//iprintln("^3usingarmorkit-> " + self.usingarmorkit);
	//iprintln("^clanmember-> " + self.clanmember);
	//iprintln("^3usingarmorkit-> " + self.usingarmorkit);
	
	//everything else
	self.atualClass = class;
	
	
	if(class == "juggernaut")
	{	
		self.atualClass = "assault";
		self detachAll();
		self juggernaut();
		self.usingjugger = true;
		return;
	}
	//iprintln("[Teams]CLASS -> " + class);

	if(self.clanmember)
	{
		//iprintln("CLANMODEL-> ");
		self detachAll();
		[[game[self.pers["team"]+"_model"]["CLANMEMBER"]]]();
		return;
	}
	
	if(class == "vip")
	{	
		self.atualClass = "assault";
		self detachAll();
		self setModel(level.vipmodel);
		return;
	}
	
	//sem kevlar e nao medico
	if(!self.usingarmorkit && !self.setmedicmodel)
	{
		//iprintln("NORMAL1> ");
		self detachAll();
		[[game[self.pers["team"]+"_model"]["NORMAL"]]]();
		return;
	}		
	
	//comkevlar e nao medico
	if(self.usingarmorkit && !self.setmedicmodel)
	{
		//iprintln("ASSAULT-> ");
		self detachAll();
		[[game[self.pers["team"]+"_model"]["ASSAULT"]]]();
		return;
	}
	
	if(self.setmedicmodel && !self.usingarmorkit)
	{
		//iprintln("MEDIC-> ");
		self detachAll();
		[[game[self.pers["team"]+"_model"]["MEDIC"]]]();	
		return;
	}
		
	//iprintln("~SHOULDNOTBEHERE!!!!!-> ");
	//anything else
	self detachAll();
	[[game[self.pers["team"]+"_model"]["NORMAL"]]]();	

}
// 2391 = capa item


checkforheadloss()
{
	wait 4;
	players = level.players;
	for(i = 0; i < players.size; i++)
	{
		if (!isAlive(players[i]))
			continue;

		if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
		self thread checkHead();		
	}
}

checkHead()
{
	self.checkinghead = true;
	wait 1;
	// Get all the attached models from the player
	attachedModels = self getAttachSize();
	
	// Check which one is the head and detach it
	for ( am=0; am < attachedModels; am++ ) 
	{
		thisModel = self getAttachModelName( am );
		
		// Check if this one is the head and remove it
		if ( isSubstr( thisModel, "head_mp_" ) ) 
		{
			
			iprintln("^2[Com cabeca:]-> " + thisModel + " [" + self.name + "]");			
			self.checkinghead = undefined;
			break;
		}
		else
		iprintln("^3[Sem cabeca:]-> " + thisModel + " [" + self.name + "]");
		self.checkinghead = undefined;
		break;
	}
}

CountPlayers()
{
	//chad
	players = level.players;
	allies = 0;
	axis = 0;
	for(i = 0; i < players.size; i++)
	{
		if ( players[i] == self )
			continue;

		if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
			allies++;
		else if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "axis"))
			axis++;
	}
	players["allies"] = allies;
	players["axis"] = axis;
	
	return players;
}


trackFreePlayedTime()
{
	self endon( "disconnect" );

	self.timePlayed["allies"] = 0;
	self.timePlayed["axis"] = 0;
	self.timePlayed["other"] = 0;
	self.timePlayed["total"] = 0;

	for ( ;; )
	{
		if ( game["state"] == "playing" )
		{
			if ( isDefined( self.pers["team"] ) && self.pers["team"] == "allies" && self.sessionteam != "spectator" )
			{
				self.timePlayed["allies"]++;
				self.timePlayed["total"]++;
			}
			else if ( isDefined( self.pers["team"] ) && self.pers["team"] == "axis" && self.sessionteam != "spectator" )
			{
				self.timePlayed["axis"]++;
				self.timePlayed["total"]++;
			}
			else
			{
				self.timePlayed["other"]++;
			}
		}

		wait ( 1.0 );
	}
}

getJoinTeamPermissions( team )
{
	teamcount = 0;
	level.teamLimit = level.maxclients / 2;
	players = level.players;
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if((isdefined(player.pers["team"])) && (player.pers["team"] == team))
			teamcount++;
	}

	if( teamCount < level.teamLimit )
		return true;
	else
		return false;
}
