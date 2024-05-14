#include promatch\_utils;

init()
{
	// Use this variable to know if players have switched teams
	if ( !isDefined( game["switchedteams"] ) )
		game["switchedteams"] = false;

	// Make sure the mapper has defined the teams correctly
	if ( !isDefined( game["allies"] ) || ( game["allies"] != "marines" && game["allies"] != "sas" ) ) 
	{
		game["allies"] = "marines";
	}
	if ( !isDefined( game["axis"] ) || ( game["axis"] != "opfor" && game["axis"] != "arab" && game["axis"] != "russian" ) ) {
		game["axis"] = "opfor";
	}	

	game["strings"]["press_to_spawn"] = &"PLATFORM_PRESS_TO_SPAWN";
	if ( level.teamBased )
	{
		game["strings"]["waiting_for_teams"] = &"MP_WAITING_FOR_TEAMS";
		game["strings"]["opponent_forfeiting_in"] = &"MP_OPPONENT_FORFEITING_IN";
	}
	else
	{
		game["strings"]["waiting_for_teams"] = &"MP_WAITING_FOR_PLAYERS";//Wait for more players
		game["strings"]["opponent_forfeiting_in"] = &"MP_OPPONENT_FORFEITING_IN";
	}
	game["strings"]["match_starting_in"] = &"MP_MATCH_STARTING_IN";
	game["strings"]["spawn_next_round"] = &"MP_SPAWN_NEXT_ROUND";
	game["strings"]["waiting_to_spawn"] = &"MP_WAITING_TO_SPAWN";
	game["strings"]["match_starting"] = &"MP_MATCH_STARTING";
	game["strings"]["change_class"] = &"MP_CHANGE_CLASS_NEXT_SPAWN";
	game["strings"]["last_stand"] = &"MPUI_LAST_STAND";

	//game["strings"]["cowards_way"] = &"PLATFORM_COWARDS_WAY_OUT";

	game["strings"]["tie"] = &"MP_MATCH_TIE";
	game["strings"]["round_draw"] = &"MP_ROUND_DRAW";

	game["strings"]["enemies_eliminated"] = &"MP_ENEMIES_ELIMINATED";
	game["strings"]["score_limit_reached"] = &"MP_SCORE_LIMIT_REACHED";
	game["strings"]["round_limit_reached"] = &"MP_ROUND_LIMIT_REACHED";
	game["strings"]["time_limit_reached"] = &"MP_TIME_LIMIT_REACHED";
	game["strings"]["players_forfeited"] = &"MP_PLAYERS_FORFEITED";
		
		
			// Set default resources
		teamNames["sas"] = &"MPUI_SAS_SHORT";
		teamNames["marines"] = &"MPUI_MARINES_SHORT";
		teamNames["opfor"] = &"MPUI_OPFOR_SHORT";
		teamNames["arab"] = &"MPUI_OPFOR_SHORT";
		teamNames["russian"] = &"MPUI_SPETSNAZ_SHORT";
		
		logoNames["sas"] = "faction_128_sas";
		logoNames["marines"] = "faction_128_usmc";
		logoNames["opfor"] = "faction_128_arab";
		logoNames["arab"] = "faction_128_arab";
		logoNames["russian"] = "faction_128_ussr";
		
		headIconNames["sas"] = "headicon_british";
		headIconNames["marines"] = "headicon_american";
		headIconNames["opfor"] = "headicon_opfor";
		headIconNames["arab"] = "headicon_opfor";
		headIconNames["russian"] = "headicon_russian";
	
		switch ( game["allies"] )
		{
		case "sas":
			game["strings"]["allies_win"] = &"MP_SAS_WIN_MATCH";
			game["strings"]["allies_win_round"] = &"MP_SAS_WIN_ROUND";
			game["strings"]["allies_mission_accomplished"] = &"MP_SAS_MISSION_ACCOMPLISHED";
			game["strings"]["allies_eliminated"] = &"MP_SAS_ELIMINATED";
			game["strings"]["allies_forfeited"] = &"MP_SAS_FORFEITED";
			game["strings"]["allies_name"] = &"MP_SAS_NAME";
			game["music"]["spawn_allies"] = "mp_spawn_sas";
			game["music"]["victory_allies"] = "mp_victory_sas";
			game["icons"]["allies"] = "faction_128_sas";
			game["colors"]["allies"] = (0.6,0.64,0.69);
			game["voice"]["allies"] = "UK_1mc_";
			setDvar( "scr_allies", "sas" );
			break;
		case "marines":
		default:
			game["strings"]["allies_win"] = &"MP_MARINES_WIN_MATCH";
			game["strings"]["allies_win_round"] = &"MP_MARINES_WIN_ROUND";
			game["strings"]["allies_mission_accomplished"] = &"MP_MARINES_MISSION_ACCOMPLISHED";
			game["strings"]["allies_eliminated"] = &"MP_MARINES_ELIMINATED";
			game["strings"]["allies_forfeited"] = &"MP_MARINES_FORFEITED";
			game["strings"]["allies_name"] = &"MP_MARINES_NAME";
			game["music"]["spawn_allies"] = "mp_spawn_usa";
			game["music"]["victory_allies"] = "mp_victory_usa";
			game["icons"]["allies"] = "faction_128_usmc";
			game["colors"]["allies"] = (0,0,0);
			game["voice"]["allies"] = "US_1mc_";
			setDvar( "scr_allies", "usmc" );
			break;
		}
		switch ( game["axis"] )
		{
		case "russian":
			game["strings"]["axis_win"] = &"MP_SPETSNAZ_WIN_MATCH";
			game["strings"]["axis_win_round"] = &"MP_SPETSNAZ_WIN_ROUND";
			game["strings"]["axis_mission_accomplished"] = &"MP_SPETSNAZ_MISSION_ACCOMPLISHED";
			game["strings"]["axis_eliminated"] = &"MP_SPETSNAZ_ELIMINATED";
			game["strings"]["axis_forfeited"] = &"MP_SPETSNAZ_FORFEITED";
			game["strings"]["axis_name"] = &"MP_SPETSNAZ_NAME";
			game["music"]["spawn_axis"] = "mp_spawn_soviet";
			game["music"]["victory_axis"] = "mp_victory_soviet";
			game["icons"]["axis"] = "faction_128_ussr";
			game["colors"]["axis"] = (0.52,0.28,0.28);
			game["voice"]["axis"] = "RU_1mc_";
			setDvar( "scr_axis", "ussr" );
			break;
		case "arab":
		case "opfor":
		default:
			game["strings"]["axis_win"] = &"MP_OPFOR_WIN_MATCH";
			game["strings"]["axis_win_round"] = &"MP_OPFOR_WIN_ROUND";
			game["strings"]["axis_mission_accomplished"] = &"MP_OPFOR_MISSION_ACCOMPLISHED";
			game["strings"]["axis_eliminated"] = &"MP_OPFOR_ELIMINATED";
			game["strings"]["axis_forfeited"] = &"MP_OPFOR_FORFEITED";
			game["strings"]["axis_name"] = &"MP_OPFOR_NAME";
			game["music"]["spawn_axis"] = "mp_spawn_opfor";
			game["music"]["victory_axis"] = "mp_victory_opfor";
			game["icons"]["axis"] = "faction_128_arab";
			game["colors"]["axis"] = (0.65,0.57,0.41);
			game["voice"]["axis"] = "AB_1mc_";
			setDvar( "scr_axis", "arab" );
			break;
		}

// Set the values that we'll be using
	level.scr_team_allies_name = teamNames[ game[ "allies" ] ];
	level.scr_team_allies_logo = logoNames[ game[ "allies" ] ];
	level.scr_team_allies_headicon = headIconNames[ game[ "allies" ] ];
	
	level.scr_team_axis_name = teamNames[ game[ "axis" ] ];
	level.scr_team_axis_logo = logoNames[ game[ "axis" ] ];
	level.scr_team_axis_headicon = headIconNames[ game[ "axis" ] ];	
	

	// Set variables and internal values according to team sides
	level thread setTeamResources();
	
	// Set the colors for names
	switch(game["allies"])
	{
		case "sas":
			setDvar( "g_TeamColor_Allies", ".5 .5 .5" );
			setDvar( "g_ScoresColor_Allies", "0 0 0" );
			break;
		
		default:
			setDvar( "g_TeamColor_Allies", "0.6 0.64 0.69" );
			setDvar( "g_ScoresColor_Allies", "0.6 0.64 0.69" );
			break;
	}


	switch(game["axis"])
	{
		case "opfor":
		case "arab":
			setDvar( "g_TeamColor_Axis", "0.65 0.57 0.41" );		
			setDvar( "g_ScoresColor_Axis", "0.65 0.57 0.41" );
			break;
		
		default:
			setDvar( "g_TeamColor_Axis", "0.52 0.28 0.28" );		
			setDvar( "g_ScoresColor_Axis", "0.52 0.28 0.28" );
			break;
	}
	
	setDvar( "g_ScoresColor_Spectator", ".25 .25 .25" );
	setDvar( "g_ScoresColor_Free", ".76 .78 .10" );
	setDvar( "g_teamColor_MyTeam", ".6 .8 .6" );
	setDvar( "g_teamColor_EnemyTeam", "1 .45 .5" );	
}

setTeamResources()
{
// Set server and internal variables
	precacheShader( level.scr_team_allies_logo );
	setDvar( "g_TeamIcon_Allies", level.scr_team_allies_logo );
	setDvar( "g_TeamName_Allies", level.scr_team_allies_name );	
	game["strings"]["allies_name"] = level.scr_team_allies_name;
	game["icons"]["allies"] = level.scr_team_allies_logo;		
	
	precacheShader( level.scr_team_axis_logo );
	setDvar( "g_TeamIcon_Axis", level.scr_team_axis_logo );
	setDvar( "g_TeamName_Axis", level.scr_team_axis_name );
	game["strings"]["axis_name"] = level.scr_team_axis_name;			
	game["icons"]["axis"] = level.scr_team_axis_logo;
}