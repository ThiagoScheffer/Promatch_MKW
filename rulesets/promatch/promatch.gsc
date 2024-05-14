#include promatch\_utils;

init()
{
	//******************************************************************************
	// PROMATCH VARIABLES
	//******************************************************************************
	setDvar( "scr_enable_deadchat", "0" );
	setDvar( "scr_show_ext_obituaries", "0" );	
	//******************************************************************************
	setMonitorDvar( "scr_dm_numlives", "0" );
	setMonitorDvar( "scr_dm_playerrespawndelay", "1" );
	setMonitorDvar( "scr_dm_roundlimit", "1" );
	setMonitorDvar( "scr_dm_scorelimit", "0" );
	setMonitorDvar( "scr_dm_timelimit", "15" );
	//******************************************************************************
	setMonitorDvar( "scr_sab_bombtimer", "50" );
	setMonitorDvar( "scr_sab_defusetime", "6" );
	setMonitorDvar( "scr_sab_hotpotato", "0" );
	setMonitorDvar( "scr_sab_numlives", "0" );
	setMonitorDvar( "scr_sab_planttime", "5" );
	setMonitorDvar( "scr_sab_playerrespawndelay", "3" );
	setMonitorDvar( "scr_sab_roundlimit", "6" );
	setMonitorDvar( "scr_sab_roundswitch", "2" );
	setMonitorDvar( "scr_sab_scorelimit", "4" );
	setMonitorDvar( "scr_sab_timelimit", "4" );
	setMonitorDvar( "scr_sab_waverespawndelay", "0" );
	setMonitorDvar( "scr_sab_suddendeath_show_enemies", "0" );
	setMonitorDvar( "scr_sab_suddendeath_timelimit", "90" );
	setMonitorDvar( "scr_sab_show_briefcase", "0" );
	setMonitorDvar( "scr_sab_scoreboard_bomb_carrier", "1" );
	setMonitorDvar( "scr_sab_show_bomb_carrier", "1" );
	setMonitorDvar( "scr_sab_show_bomb_carrier_time", "7" );
	setMonitorDvar( "scr_sab_show_bomb_carrier_distance", "1" );
	//******************************************************************************
	//setMonitorDvar( "scr_sd_sdmode", "0" );
	setMonitorDvar( "scr_sd_bombsites_enabled", "0" );
	setMonitorDvar( "scr_sd_defenders_show_both", "0" );
	setMonitorDvar( "scr_sd_bomb_notification_enable", "1" );
	setMonitorDvar( "scr_sd_bombtimer", "48" );
	setMonitorDvar( "scr_sd_bombtimer_show", "1" );
	setMonitorDvar( "scr_sd_numlives", "1" );
	setMonitorDvar( "scr_sd_scoreboard_bomb_carrier", "0" );
	setMonitorDvar( "scr_sd_show_briefcase", "0" );
	setMonitorDvar( "scr_sd_timelimit", "2.10" );
	//******************************************************************************
	setMonitorDvar( "scr_war_numlives", "0" );
	setMonitorDvar( "scr_war_playerrespawndelay", "2" );
	setMonitorDvar( "scr_war_roundlimit", "1" );
	setMonitorDvar( "scr_war_roundswitch", "1" );
	setMonitorDvar( "scr_war_scorelimit", "5000" );
	setMonitorDvar( "scr_war_timelimit", "15" );
	setMonitorDvar( "scr_war_waverespawndelay", "0" );
	setMonitorDvar( "scr_war_forcestartspawns", "0" );
	//******************************************************************************
	//******************************************************************************	

	//******************************************************************************
	// LIVE BROADCAST SETTINGS
	//******************************************************************************
	// Enable live broadcast so players have a clearer picture of the game status for
	// public broadcasting
	// 0 = Disabled (default), 1 = Enabled
	setDvar( "scr_livebroadcast_enable", "0" );
	
	
	//******************************************************************************
	// READY-UP SETTINGS
	//******************************************************************************
	// Enable ready-up period so players need to confirm they are ready to start the match
	// 0 = Disabled (default), 1 = Enabled
	setDvar( "scr_match_readyup_period", "1" );
	
	// Enable ready-up period again after switching sides
	// 0 = Disabled (default), 1 = Enabled
	setDvar( "scr_match_readyup_period_onsideswitch", "0" );
	
	//******************************************************************************
	// STRATEGY TIME SETTINGS
	//******************************************************************************

	// Show in the scoreboard with a green sign which players have bypassed the strategy time
	// 0 = Disabled, 1 = Enabled (default)
	setDvar( "scr_match_strategy_show_bypassed", "1" );
	
	// Allow player to change directions during the strategy time
	// 0 = Disabled (default), 1 = Enabled
	setDvar( "scr_match_strategy_allow_movement", "1" );
	
	// Value in seconds for players to get ready once strategy time is over
	// Allowed values: 0.5-5.0 (default is 1.5)
	setDvar( "scr_match_strategy_getready_time", "1.0" );
	
	//Modo de treino	
	setDvar( "scr_hitloc_debug", "0" );

	// Time the server will allow players to change their kits after the round started.
	// Allowed values: 1-120 (default is 15)
	//setDvar( "scr_game_graceperiod", "20" );
	//setDvar( "scr_game_playerwaittime", "27" );
	//setDvar( "scr_game_matchstarttime", "5" );
	
	// Time to wait to allow players look at the scoreboard once the game finishes
	// before loading the next map.
	// Allowed values: 0-120 (default is 15)
	setDvar( "scr_intermission_time", "5" );


	//******************************************************************************
	// HARDPOINTS: UAV, AIRSTRIKE, AND HELICOPTER
	//******************************************************************************
	// HARDPOINT SETTINGS
	//******************************************************************************
	// 0 = Disabled, 1 = Enabled (default)
	setDvar( "scr_game_hardpoints", "0" );
	
	
	// Display a message to all the players that certain player has reach a new killstreak.
	// 0 = Disabled, 1 = Enabled (default)
	setDvar( "scr_announce_killstreak", "0" );
	
	
	//******************************************************************************
	// UAV SETTINGS
	//******************************************************************************
	// 0 = Disabled, 1 = Enabled (default)
	setDvar( "scr_hardpoint_allow_uav", "0" );

	
	//******************************************************************************
	// AIRSTRIKE SETTINGS
	//******************************************************************************
	// 0 = Disabled, 1 = Enabled (default)
	setDvar( "scr_hardpoint_allow_airstrike", "0" );
	
	//******************************************************************************
	// HELICOPTER SETTINGS
	//******************************************************************************
	// 0 = Disabled, 1 = Enabled (default)
	setDvar( "scr_hardpoint_allow_helicopter", "0" );

	//******************************************************************************
	// HUD OPTIONS
	//******************************************************************************
	
	// 0 = Disabled (default), 1 = Enabled
	//setDvar( "scr_hardcore", "0" );
	
	// Moves the progress bar during objectives completion
	// 0 = Disabled (default), 1 = Bottom of the screen, 2 = Top of the screen
	setDvar( "scr_adjust_progress_bars", "1" );
	
	// Show a message on the screen when a player joins a team or switches to spectator
	// 0 = Disabled (default), 1 = Enabled
	setDvar( "scr_show_player_assignment", "1" );
	
	// Control what kind of hiticons should be shown to attacking players when causing damage to an enemy. 
	// 0 = Disabled, 1 = Enabled (default), 2 = Enabled (not through walls)
	setDvar( "scr_enable_hiticon", "2" );
	
	// Control if the special hiticon should be shown to the player attacking an enemy who is using the Juggernaut perk.
	// 0 = Disabled, 1 = Enabled (default)
	setDvar( "scr_enable_bodyarmor_feedback", "0" );
	
	// Show names on enemy players
	// 0 = Disabled, 1 = Enabled (default)
	setDvar( "scr_hud_show_enemy_names", "0" );
	
	// Show names on friendly players
	// 0 = Disabled, 1 = Enabled (default)
	setDvar( "scr_hud_show_friendly_names", "1" );
	
	// Show XP points gained during the game in the middle of the screen
	// 0 = Disabled, 1 = Enabled (default, NON-HARDCORE), 2 = Enabled (also HARDCORE)
	setDvar( "scr_hud_show_xp_points", "1" );
	
	// Show the center obituary message showing the attacker or the victim's name
	// 0 = Disabled, 1 = Enabled (default)
	setDvar( "scr_hud_show_center_obituary", "0" );
	
	// Control which type of obituaries should be shown to all the players in the server
	// 0 = Disabled, 1 = Enabled (default), 2 = Show only TKs
	//setDvar( "scr_show_obituaries", "1" );
	
	// Show the game scores on screen (NON-HARDCORE)
	// 0 = Disabled, 1 = Enabled (default)
	// setDvar( "scr_hud_show_scores", "1" );
	
	// Show the stance indicator on screen 
	// 0 = Disabled (default), 1 = Enabled
	setDvar( "scr_hud_show_stance", "0" );
	
	// Show the mini-icons in the minimap indicating objective positions
	// 0 = Disabled, 1 = Enabled (default)
	setDvar( "scr_hud_show_2dicons", "1" );
	
	// Show the world icons on the screen indicating objective positions
	// 0 = Disabled, 1 = Enabled (default)
	setDvar( "scr_hud_show_3dicons", "1" );
	
	// Show the minimap to be shown in hardcore mode (HARDCORE)
	// 0 = Disabled (default), 1 = Enabled
	setDvar( "scr_hardcore_show_minimap", "1" );
	
	// Forces the compass (showing the North, South, West, East coordinates) in hardcore mode (HARDCORE).
	// 0 = Disabled (default), 1 = Enabled
	setDvar( "scr_hardcore_show_compass", "0" );
	
	// Show the mini-icons in the compass indicating objective positions with their distance
	// 0 = Disabled (default), 1 = Enabled
	setDvar( "scr_hud_compass_objectives", "0" );
	
	// Shows enemies in the minimap when firing a non-silenced weapon
	// 0 = Disabled (default for hardcore mode), 1 = Enabled (default for non-hardcore mode)
	setDvar( "scr_minimap_show_enemies_firing", "1" );
	
	// Control if the players' screens will be blacked out or not when dying. 
	// 0 = Disabled (default), 1 = Enabled
	setDvar( "scr_blackscreen_enable", "0" );
	
	//******************************************************************************
	// OTHER OPTIONS
	//******************************************************************************
	setDvar( "scr_teambalance", "1" );
	
	// Controls friendly fire in the game
	// 0 = Disabled (default), 1 = Enabled (victim receives damage)
	// 2 = Reflective (attacker receives damage), 4 = Shared (50% attacker and 50% victim)
	setDvar( "scr_team_fftype", "1" );
	
	// Forces the player to spawn instead of waiting for the player to press the USE key
	// indicating that he or she's ready to respawn again
	// 0 = Disabled, 1 = Enabled (default)
	setDvar( "scr_player_forcerespawn", "1" );
	
	// Controls the jump height for the players
	// Allowed values: 0-1000 (default is 39)
	setDvar( "jump_height", "39" );

	//******************************************************************************
	// SPECTATE OPTIONS
	//******************************************************************************
	// Spectate type that will apply to all the players assigned to a team
	// 0 = Disabled (default), 1 = Team/Player only, 2 = Free
	setDvar( "scr_game_spectatetype", "1" );
	setDvar( "scr_game_spectatetype_dm", "0" );
	
	// Spectate type that will apply to players not assigned to a team
	// 0 = Disabled (default), 1 = Team/Player only, 2 = Free
	setDvar( "scr_game_spectatetype_spectators", "2" );
	

	//******************************************************************************
	// VISUAL EFFECTS OPTIONS
	//******************************************************************************
	// Controls the destruction of vehicles
	// 0 = Disabled, 1 = Enabled (default)	
	setDvar( "scr_destructibles_enable_physics", "1" );

	//******************************************************************************
	// WEAPON OPTIONS
	//******************************************************************************
	
	// Set friendly fire for planted claymores
	// 0 = Detonation by enemies only (default)
	// 1 = Enemies and friendlies (except owner)
	// 2 = Everyone (including owner)
	setDvar( "scr_claymore_friendly_fire", "0" );
	
	// Allow stationary turrets on the maps
	// 0 = Disabled, 1 = Enabled (default)
	//setDvar( "scr_allow_stationary_turrets", "0" );
	
	// Controls whether the delay of weapon will happen just at the beginning of the round or every time the player spawns
	// 0 = Disabled, 1 = Enabled (default)
	setDvar( "scr_delay_only_round_start", "0" );	
	
	// Controls whether tracer bullets should be used when firing weapons
	// Allowed values: 0-1 (chance of bullet being a tracer) (default is 0.2)
	setDvar( "scr_fire_tracer_chance", "0.2" );
}