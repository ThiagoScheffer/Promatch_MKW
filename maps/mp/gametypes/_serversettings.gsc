#include promatch\_utils;

init()
{
	level.hostname = getdvar("sv_hostname");
	if(level.hostname == "" || level.hostname == "Cod4Host")
	level.hostname = "^7ProMatch Advanced Mod";
	setdvar("sv_hostname", level.hostname);
	setdvar("ui_hostname", level.hostname);
	setdvar("ui_net_ip", getdvar("net_ip"));
	setdvar("ui_net_port", getdvar("net_port"));
	setdvar("ui_adress", getdvar("sv_adress"));
	//necessario para ser acessado pelos menus
	makeDvarServerInfo("ui_adress", getdvar("sv_adress"));
	makeDvarServerInfo("ui_net_port", getdvar("net_port"));
	
	//makeDvarServerInfo("ui_hostname", level.hostname);
	//makeDvarServerInfo("ui_net_ip", getdvar("net_ip"));	
	//makeDvarServerInfo("ui_scoremsg3", getdvar("ui_scoremsg3"));

	//alimenta os menus
	makeDvarServerInfo( "sv_ftplink", getDvar( "sv_ftplink" ));
	
	makeDvarServerInfo( "scr_aviso1", getDvar( "scr_aviso1" ));
	makeDvarServerInfo( "scr_aviso2", getDvar( "scr_aviso2" ));
	makeDvarServerInfo( "scr_aviso3", getDvar( "scr_aviso3" ));
	makeDvarServerInfo( "scr_aviso4", getDvar( "scr_aviso4" ));
	
	
	
	level.motd = getdvar("scr_motd");
	if(level.motd == "")
	level.motd = "";
	//setdvar("scr_motd", level.motd);
	//setdvar("ui_motd", level.motd);
	//makeDvarServerInfo("ui_motd", "");
	
	// Set mod name and version
	setDvar( "_Mod", "ProMatch MW", true );
	setDvar( "_ModVer", "v10 2024", true );
	
	//level.allow_teamchange = getdvar("g_allow_teamchange");
	//if(level.allow_teamchange == "")
	//level.allow_teamchange = "1";
	//setdvar("g_allow_teamchange", level.allow_teamchange);
	//setdvar("ui_allow_teamchange", level.allow_teamchange);
	//makeDvarServerInfo("ui_allow_teamchange", "1");
	// Reset certain values no matter what the setting in the server
	setDvar("sv_clientSidebullets", 0 );
	setDvar( "g_allowvote", "0" );
	setDvar( "g_voteAllowKick", "0" );
	setDvar( "g_voteAllowMap", "0" );
	setDvar( "g_voteAllowGametype", "0" );
	setDvar( "g_voteAllowRestart", "0" );
	setDvar("scr_game_forceuav",1);
	setDvar( "ui_hud_obituaries", "1" );
	setDvar( "ui_hud_showobjicons", "1" );
	setDvar( "g_knockback", "1000" );
	setDvar( "sv_keywords", "promatch,promod" );
	setDvar( "loc_warnings", "0" );
	setDvar( "sv_zombietime", "2" );//tempo mantendo o client no sv para enviar informacoes
	setDvar( "sv_timeout", "80" );//tempo que espera por um cliente que caiu antes de remover
	setDvar( "clientSideEffects", "0" );
	setDvar( "g_inactivityspectator", "0" );
	setDvar( "sv_floodProtect", "2" );
	setDvar( "sv_reconnectlimit", "4" );
	setDvar( "sv_disableClientConsole", "0" );
	//setDvar( "cl_autocmd", "0" );
	//setDvar( "sv_pure", "0" );
	setDvar( "g_no_script_spam", "1" );
	setDvar( "perk_grenadeDeath" , "semtex_grenade_mp");
	setDvar( "perk_sprintMultiplier",4);//sv
	setDvar( "g_gravity", "800" );
	setDvar( "sv_kickBanTime", "3600" );
	setDvar( "sv_voice", "0" );
	setDvar( "voice_deadChat", "0" );
	setDvar( "voice_global", "0" );
	//setDvar( "voice_localEcho", "0" );
	//setDvar( "winvoice_mic_mute", "1" );
	setDvar( "player_dmgtimer_maxTime" , "100");//player is slowed due to damage
	setDvar( "player_dmgtimer_stumbleTime" , "100");
	setDvar( "player_dmgtimer_timePerPoint" , "60");
	setDvar( "player_meleeChargeFriction" , "5000");
	setDvar( "g_maxDroppedWeapons" , "8");
	setDvar( "bg_aimSpreadMoveSpeedThreshold" , "200");
	setDvar( "scr_game_spectatetype_spectators", "2" );
	setDvar( "scr_drawfriend", "0" );
	setDvar( "scr_hud_show_stance", "0" );
	setDvar( "scr_hud_show_grenade_indicator", "1" );
	setDvar( "scr_hud_show_redcrosshairs", "0" );
	setDvar( "scr_hud_show_death_icons", "1" );
	setDvar( "scr_hud_show_friendly_names", "1" );
	setDvar( "scr_hud_show_enemy_names", "1" );
	setDvar( "scr_realtime_stats_default_on", "0" );
	setDvar( "player_lean_rotate_left", 1.1 );
	setDvar( "player_lean_rotate_right", 1 );
	setDvar( "player_lean_shift_left", 1 );
	setDvar( "player_lean_shift_right", 3 );
	setDvar( "player_lean_rotate_crouch_left", 1.3 );
	setDvar( "player_meleeWidth", 20 );
	//setDvar( "player_meleeHeight", 30 );
	//setDvar( "player_meleerange", 60 );
	//setDvar( "aim_automelee_range", 10 );
	//setDvar( "aim_automelee_enable", 1 );
	setDvar( "player_lean_rotate_crouch_right", 1 );
	setDvar( "player_lean_shift_crouch_left", 0 );
	setDvar( "player_lean_shift_crouch_right", 2 );
	setDvar( "bg_bobMax", 0);
	setDvar( "ui_hud_showobjicons", "1" );
	setDvar( "player_scopeExitOnDamage", "0" );
	setDvar( "scr_show_obituaries", "1" );
	setDvar("player_throwBackInnerRadius", 0);
	setDvar("player_throwBackOuterRadius", 0);

	//NETWORK
	setDvar( "net_noipx", "1" );
	setDvar( "g_speed", "180" );//teste
	 
	// If the host is "localhost", disable Add to favorites.
	if ( getdvar( "net_ip" ) == "localhost" ) 
	{
		level.ui_favoriteAddress = "";
	} else 
	{
		level.ui_favoriteAddress = getdvar("net_ip") + ":" + getdvar("net_port");
	}
	//COD ARENA
	if(level.oldschool)
	{
		setDvar( "jump_height", 70 );
		setDvar( "jump_slowdownEnable", 0 );
		setDvar( "bg_fallDamageMinHeight", 756 );
		setDvar( "bg_fallDamageMaxHeight", 812 );
		setDvar( "perk_sprintMultiplier" , 5);
		setDvar( "g_speed", "200" );//teste
		setDvar( "g_gravity", "710" );
		level.scr_jump_slowdown_enable = 0;
	}
	else
	{
		setDvar( "jump_height", 55 );
		setDvar( "g_gravity", "790" );
	}
	
	level.friendlyfire = 0;	
	constrainGameType(getdvar("g_gametype"));

	//for(;;)
	//{
	//	updateServerSettings();
	//	xwait (15.0,false);
	//}
}

updateServerSettings()
{
	sv_hostname = getdvar("sv_hostname");
	if(level.hostname != sv_hostname)
	{
		level.hostname = sv_hostname;
		setdvar("ui_hostname", level.hostname);
	}

	g_allow_teamchange = getdvar("g_allow_teamchange");
	if(level.allow_teamchange != g_allow_teamchange)
	{
		level.allow_teamchange = g_allow_teamchange;
		setdvar("ui_allow_teamchange", level.allow_teamchange);
	}
}

constrainGameType(gametype)
{
	entities = getentarray();
	for(i = 0; i < entities.size; i++)
	{
		entity = entities[i];

		if(gametype == "dm")
		{
			if(isdefined(entity.script_gametype_dm) && entity.script_gametype_dm != "1")
			{
				//iprintln("DELETED(GameType): ", entity.classname);
				entity delete();
			}
		}
		else if(gametype == "tdm" || gametype == "war")
		{
			if(isdefined(entity.script_gametype_tdm) && entity.script_gametype_tdm != "1")
			{
				//iprintln("DELETED(GameType): ", entity.classname);
				entity delete();
			}
		}
		else if(gametype == "hq")
		{
			if(isdefined(entity.script_gametype_hq) && entity.script_gametype_hq != "1")
			{
				//iprintln("DELETED(GameType): ", entity.classname);
				entity delete();
			}
		}
		else if(gametype == "sd")
		{
			if(isdefined(entity.script_gametype_sd) && entity.script_gametype_sd != "1")
			{
				//iprintln("DELETED(GameType): ", entity.classname);
				entity delete();
			}
		}
		else if(gametype == "ctf")
		{
			if(isdefined(entity.script_gametype_ctf) && entity.script_gametype_ctf != "1")
			{
				//iprintln("DELETED(GameType): ", entity.classname);
				entity delete();
			}
		}
	}
	if(gametype != "war")
	{
		pickups = getentarray( "oldschool_pickup", "targetname" );
		
		for ( i = 0; i < pickups.size; i++ )
		{
			if ( isdefined( pickups[i].target ) )
				getent( pickups[i].target, "targetname" ) delete();
			pickups[i] delete();
		}
	}
}