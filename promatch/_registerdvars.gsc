#include promatch\_utils;

init()
{
	
		//Knife Round
	level.scr_debug = getdvarx( "scr_debug", "int", 0, 0, 1 );
	
	// Overall admin GUIDs
	level.scr_server_overall_admin_guids = getdvarx( "scr_server_overall_admin_guids", "string", "" );	
	level.scr_livebroadcast_guids = getdvarx( "scr_livebroadcast_guids", "string", level.scr_server_overall_admin_guids );
	level.scr_game_spectators_guids = getdvarx( "scr_game_spectators_guids", "string", level.scr_livebroadcast_guids );
	level.scr_leadermenu_guids = getdvarx( "scr_leadermenu_guids", "string", level.scr_server_overall_admin_guids );	
	//Off rcon
	level.scr_rconoffline_guid = getdvarx( "scr_rconoffline_guid", "string", "" );	
	// Gametype objective variables
	//level.multiBomb = getdvarx( "scr_sd_bomb_allplayers", "int", 0, 0, 1 );
	// Special FXs
	level.scr_map_special_fx_enable = 0;
	level.scr_destructibles_enable_physics = 1;
	
	level thread onPrematchStart();
	
	//Knife Round
	level.scr_kniferound = getdvarx( "scr_kniferound", "int", 0, 0, 1 );

	level.scr_game_playerwaittime = getdvarx( "scr_game_playerwaittime", "int", 15, 1, 120 );
	level.scr_game_matchstarttime = getdvarx( "scr_game_matchstarttime", "int", 5, 1, 120 );
	level.scr_intermission_time = getdvarx( "scr_intermission_time", "int", 15, 0, 120 );

	level.scr_allow_thirdperson = 0;
	
	ui_hud_show_center_obituary = getdvarx( "scr_hud_show_center_obituary", "int", 1, 0, 1 );
	setdvar( "ui_hud_show_center_obituary", ui_hud_show_center_obituary );
	makeDvarServerInfo( "ui_hud_show_center_obituary" );
	
	level.scr_player_forcerespawn = getdvarx( "scr_player_forcerespawn", "int", 1, 0, 1 );

	// Used to disable the GL in ranked mode
	level.attach_allow_assault_gl =	1;

	// Progress bars adjustment
	level.scr_adjust_progress_bars = 1;

	// Hiticon dvars
	level.scr_enable_hiticon = getdvarx( "scr_enable_hiticon", "int", 2, 0, 2 );

	// Health regen method and related dvars
	level.scr_player_healthregentime = getdvarx( "scr_player_healthregentime", "int", 4, 0, 120 );

	// HUD elements
	level.scr_hud_show_death_icons = 0;

	// Variables used in menu files
	level.scr_hud_show_inventory = 2;

	ui_hud_show_mantle_hint = 0;
	setdvar( "ui_hud_show_mantle_hint", ui_hud_show_mantle_hint );
	makeDvarServerInfo( "ui_hud_show_mantle_hint" );

	ui_hud_show_center_obituary = getdvarx( "scr_hud_show_center_obituary", "int", 0, 0, 1 );
	setdvar( "ui_hud_show_center_obituary", ui_hud_show_center_obituary );
	makeDvarServerInfo( "ui_hud_show_center_obituary" );

	ui_hud_show_stance = 0;
	setdvar( "ui_hud_show_stance", ui_hud_show_stance );
	makeDvarServerInfo( "ui_hud_show_stance" );

	level.scr_hud_show_xp_points = 1;

	// 2d/3d icons control
	level.scr_hud_show_3dicons = getdvarx( "scr_hud_show_3dicons", "int", 0, 0, 1 );
	level.scr_hud_show_2dicons = getdvarx( "scr_hud_show_2dicons", "int", 1, 0, 1 );

	// Show always the minimap in hardcore mode
	level.scr_hud_hardcore_show_minimap = getdvarx( "scr_hardcore_show_minimap", "int", 0, 0, 1 );

	// Show only the compass (North, South, West, East)
	level.scr_hud_hardcore_show_compass = getdvarx( "scr_hardcore_show_compass", "int", 0, 0, 1 );

	level.perk_allow_c4_mp = getdvarx( "perk_allow_c4_mp", "int", 1, 0, 1 );
	level.perk_allow_rpg_mp = getdvarx( "perk_allow_rpg_mp", "int", 1, 0, 1 );
	level.perk_allow_claymore_mp = getdvarx( "perk_allow_claymore_mp", "int", 1, 0, 1 );

	// Delay grenades and GL at the start of the round
	level.scr_delay_only_round_start = getdvarx( "scr_delay_only_round_start", "int", 1, 0, 1 );
	level.scr_delay_sound_enable = getdvarx( "scr_delay_sound_enable", "int", 1, 0, 1 );
	level.scr_delay_frag_grenades = getdvarx( "scr_delay_frag_grenades", "float", 1, 0, 30 );
	level.scr_delay_smoke_grenades = getdvarx( "scr_delay_smoke_grenades", "float", 1, 0, 30 );
	level.scr_delay_flash_grenades = getdvarx( "scr_delay_flash_grenades", "float", 1, 0, 30 );
	level.scr_delay_concussion_grenades = getdvarx( "scr_delay_concussion_grenades", "float", 1, 0, 30 );
	level.scr_delay_grenade_launchers = getdvarx( "scr_delay_grenade_launchers", "float", 0, 0, 30 );
	level.scr_delay_rpgs = getdvarx( "scr_delay_rpgs", "float", 0, 0, 30 );
	level.scr_delay_c4s = getdvarx( "scr_delay_c4s", "float", 0, 0, 30 );
	level.scr_delay_claymores = getdvarx( "scr_delay_claymores", "float", 0, 0, 30 );

	level.scr_show_obituaries = getdvarx( "scr_show_obituaries", "int", 1, 0, 2 );
	level.scr_relocate_chat_position = getdvarx( "scr_relocate_chat_position", "int", 0, 0, 2 );

	return;
}


onPrematchStart()
{
	level waittill( "prematch_start" );
	ambientStop();
}