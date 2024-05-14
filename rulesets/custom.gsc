
#include promatch\_utils;

init()
{
	
	
	//Broadcaster
	setDvar( "scr_livebroadcast_enable", "1" );
	
	// Time the server will allow players to change their kits after the round started.
	// Allowed values: 1-120 (default is 15)
	// setDvar( "scr_game_graceperiod", "3" );
	
	// Time the server will wait for players on both sides before starting the game.
	// Allowed values: 1-120 (default is 15)
	setDvar( "scr_game_playerwaittime", "7" );
	
	
	// Time the server will wait to start the match (slow connecting players can 
	// benefit from this variable so the server gives enough time to everyone to
	// load the map before the game starts)
	// Allowed values: 0-120 (default is 15)
	setDvar( "scr_game_matchstarttime", "5" );
	
	// Time to wait to allow players look at the scoreboard once the game finishes
	// before loading the next map.
	// Allowed values: 0-120 (default is 15)
	setDvar( "scr_intermission_time", "5" );
	
	// Enable game forfeit when all the players in one team disconnect from the server.
	// 0 = Disabled, 1 = Enabled (default)
	setDvar( "scr_forfeit_enable", "1" );

	//******************************************************************************
	// OVERTIME OPTIONS
	//******************************************************************************
	// Enable overtime when a game ends up in a tie
	// 0 = Disabled (default), 1 = Enabled
	//setDvar( "scr_overtime_enable", "1" );

	//******************************************************************************
	// CLASS/WEAPON LIMITATIONS
	//******************************************************************************
	// Limit how many players can select this class/item for each team
	// Values: 0-64. Default value is 64.
	// setDvar( "class_allies_assault_limit", "64" );
	setDvar( "class_allies_specops_limit", "64" );
	setDvar( "class_allies_demolitions_limit", "64" );
	setDvar( "class_allies_heavygunner_limit", "1" );
	//setDvar( "class_allies_sniper_limit", "2" );
	
	// setDvar( "class_axis_assault_limit", "64" );
	setDvar( "class_axis_specops_limit", "64" );
	setDvar( "class_axis_demolitions_limit", "64" );
	setDvar( "class_axis_heavygunner_limit", "1" );
	//setDvar( "class_axis_sniper_limit", "2" );
	
	//******************************************************************************
	// DROP WEAPONS/ARMORY FOR PICKUP SETTINGS
	//******************************************************************************
	// 0 = Weapon will not be dropped, 1 = Weapon will be dropped when the player is killed (default)
	// setDvar( "class_assault_allowdrop", "1" );
	// setDvar( "class_specops_allowdrop", "1" );
	// setDvar( "class_heavygunner_allowdrop", "1" );
	setDvar( "class_demolitions_allowdrop", "0" );
	setDvar( "class_sniper_allowdrop", "0" );
	
	//******************************************************************************
	// SPECIAL GRENADES (APPLY TO ALL CLASSES)
	//******************************************************************************
	// 0 = Disabled, 1 = Enabled (default)
	// setDvar( "weap_allow_frag_grenade", "1" );
	setDvar( "weap_allow_concussion_grenade", "1" );
	setDvar( "weap_allow_flash_grenade", "1" );
	setDvar( "weap_allow_smoke_grenade", "1" );
	

	//******************************************************************************
	// OTHER OPTIONS
	//******************************************************************************

	setDvar( "scr_game_hardpoints", "0" );
	setDvar( "scr_hardpoint_show_reminder", "0" );
	
	// Forces the player to spawn instead of waiting for the player to press the USE key
	// indicating that he or she's ready to respawn again
	// 0 = Disabled, 1 = Enabled (default)
	setDvar( "scr_player_forcerespawn", "1" );

}