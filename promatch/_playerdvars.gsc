#include promatch\_eventmanager;
#include promatch\_utils;

init()
{
	// Get the module's dvar

	// These variables apply to any game mod
	level.scr_show_guid_on_firstspawn = getdvarx( "scr_show_guid_on_firstspawn", "int", 0, 0, 1 );
	level.scr_hud_show_redcrosshairs = getdvarx( "scr_hud_show_redcrosshairs", "int", 0, 0, 1 );
	level.scr_leadermenu_enable = getdvard( "scr_leadermenu_enable", "int", 0, 0, 1 );

	// Get the GUIDs for leaders	
	level.scr_leadermenu_guids = getdvarx( "scr_leadermenu_guids", "string", "" );
	level.scr_hud_show_grenade_indicator = 250;
	
	//FORCED CLIENT DVARS
	forceClientDvar( "cg_drawSnapshot", "0" );
	forceClientDvar( "r_desaturation", "0" );
	//forceClientDvar( "cg_thirdPersonRange" , "120" );
	//forceClientDvar( "cg_thirdPersonAngle", "0" );
	forceClientDvar( "r_specularcolorscale", "0" );
	//forceClientDvar( "cl_packetdup", "0" );
	forceClientDvar("cg_huddamageiconheight", "64" );
	forceClientDvar( "cg_huddamageiconwidth", "128" );
	forceClientDvar( "waypointIconHeight", "12" );//207
	forceClientDvar( "waypointIconWidth", "12" );
	forceClientDvar( "cg_viewzsmoothingmax", "16" );
	forceClientDvar( "cg_viewzsmoothingmin", "1" );	
	forceClientDvar( "r_cachesmodellighting", "1" );
	forceClientDvar( "clientSideEffects", "0" );
	//16
	forceClientDvar( "r_cachemodellighting", "1" );
	forceClientDvar( "phys_autoDisableTime", "0.02" );
	forceClientDvar( "cg_drawhealth", 0 );
	forceClientDvar( "sj_cheats", 0 );
	forceClientDvar( "r_specularmap", 0 );// 0 black off all 3 gray
	//forceClientDvar( "cg_scoreboardpinggraph", 1 );
	forceClientDvar( "r_polygonOffsetBias", -1 );
	forceClientDvar( "r_polygonOffsetScale", -1 );
	forceClientDvar( "cg_drawCrosshairNames", 0);
	//forceClientDvar( "cg_drawFriendlyNames", 1 );//0408
	//forceClientDvar( "r_fog", 0 );
	forceClientDvar( "compass_objectives", 0 );
	//16
    //forceClientDvar( "r_depthPrepass", 1 );
	//forceClientDvar( "cl_voice", 0 );
	//forceClientDvar( "ui_hud_showhits", 0 );//hud info fix
	forceClientDvar( "compassRadarPingFadeTime", 1 );
	forceClientDvar( "r_brightness", "0" );//207
	forceClientDvar( "cg_hudMapFriendlyHeight", 12);//207
	forceClientDvar( "cg_hudMapFriendlyWidth", 12 );//207
	forceClientDvar( "cg_hudMapPlayerHeight", 12 );//207
	forceClientDvar( "cg_hudMapPlayerWidth", 12 );//207
	forceClientDvar( "g_compassshowenemies", 0 );//207x
	forceClientDvar( "compassPlayerHeight", "15" );
	forceClientDvar( "compassPlayerWidth", "15" );	
	forceClientDvar( "compassFriendlyHeight", 12 );//207x
	forceClientDvar( "compassFriendlyWidth", 12 );//207x
	forceClientDvar( "compassObjectiveHeight", 14 );//207x
	forceClientDvar( "compassObjectiveWidth", 14 );//207x
	forceClientDvar( "cg_crosshairEnemyColor", 0 );
	//forceClientDvar( "cg_hudGrenadeIconMaxRangeFrag", 1);
	forceClientDvar( "hud_fade_stance", 0 );
	forceClientDvar( "hud_fade_ammodisplay", 0 );
	forceClientDvar( "hud_fade_offhand", 0 );
	//forceClientDvar( "hud_fade_healthbar", 7 );
	
	completeForceClientDvarsArray();
}

//3993 - global
VersionUpgrade()
{

	self endon("disconnect");
	
	if ( isDefined( game["state"] ) && game["state"] == "postgame" || level.gameEnded )
		return;
	
	// ---ATUALIZAR NO MENU TEAM_MARINESOPFOR - VARIAVEL DA MSG
	//alterar para novo update 5.3006
	self setClientDvar( "ui_versionupdate", "concluido" );

	if(self statGets("PATCHFIX") != 901)
	{
		self setClientDvar( "ui_versionupdate", "update" );
		self.inupdate = true;		
		
		//self openMenu( "team_marinesopfor" );
			
		//self CreatePlayerBackup();
		
		//sempre que for mexido nas armas!
		//self thread resetsaveclass();
		
		//sempre nos updates  - reseta os RESERVADOS
		//self resetscoreclass();
		
		//jogador usando profile antiga - mudara para o novo padrao
		//if(self statGets("KILLS") > 20000)
		//self resetbasicrank();
		
		//self thread resetplayertablereserved();
		
		//self thread UpgradeResetUpdate();//alteracoes na tabela - resetar aqui	
				
		//wait 1;
		
		self setStat(3167,1);
		
		self setStat(3166,1);
		
		
		//3496
		self statSets("PATCHFIX",901);
		
		self.inupdate = undefined;
		self setClientDvar( "ui_versionupdate", "concluido" );
		//self closeMenu( "team_marinesopfor" );
	}
	
}


//globallogic 4015
SetFirstConnectConfigs()
{	
	if ( isDefined( game["state"] ) && game["state"] == "postgame" || level.gameEnded )
		return;
	
	if(statGets("FIRSTCONNECT") != 4)
	{
	
		self thread registeruidtoprofile();
		
		//Classes reset	
		firstConnectresetallstuff();
		
		registrarupgrades();
		
		self setStat(3167,1);
		
		self setStat(3166,1);
		
		self setClientDvar( "cg_gun_x", "0" );
		
		self setClientDvars("r_lodscalerigid",1,
		"cg_hudDamageIconInScope",0,
		"r_fastSkin",1,
		"cg_viewzsmoothingmax",16,
		"cg_viewzsmoothingmin",1,
		"cg_viewzsmoothingtime",0.1,
		"cg_huddamageiconheight",64,
		"cg_huddamageiconwidth",128,
		"r_dlightlimit",2,
		"sm_enable",0,
		"r_lodscalerigid",1,
		"r_lodScaleSkinned",1,
		"r_lodScaleSkinned",1,
		"r_lodScaleSkinned",1,
		"r_lodScaleSkinned",1,
		"sv_cheats", 0,
		"r_fullscreen",1,
		"developer",0,								
		"con_maxfps",250,
		"r_zfeather",0,
		"cg_blood",0,
		"cl_maxpackets",125
		);
		wait (0.05);
		self setClientDvars("com_maxfps",250,
		"snaps",75,
		"sm_enable",0,
		"compassPlayerHeight",15,
		"compassPlayerWidth",15,
		"cg_debugInfoCornerOffset","-20 464",
		"ragdoll_enable", 1,
		"cg_brass", 0,
		"r_detail", 1,
		"cg_fov", 80,
		"rate", 100000,
		"r_dof_enable", 0,
		"cg_huddamageicontime", 2000,
		"waypointIconHeight",12,
		"waypointIconWidth",12
		);

		self statSets("FIRSTCONNECT",4);
	}
}

//ao conectar
LoadPlayerConfigStats()
{
	self endon( "disconnect" );
	
	if ( isDefined( game["state"] ) && game["state"] == "postgame" || level.gameEnded )
		return;	

	if ( isDefined( level.inVote ) && level.inVote || level.gameEnded )
	return;	
	
	//FIRSTSPAWN
	if(self getStat(3488) != 0)
	return;
	
	wait 0.07;
	
	self setClientDvars( "cg_drawTalk", "ALL","cg_drawCrosshair", 1);//207
	self setClientDvar( "ui_favoriteAddress", level.ui_favoriteAddress);
	//self setClientDvars("logfile", 0,"cl_voice",0,"winvoice_mic_mute",1);
	
	//if(self.vipuser)		
	//self setClientDvar("ui_privatePassword",getdvar("sv_privatePassword"));
	
	self setClientDvar("ui_gamemessagehud",self statGets("MSGPOS"));
	
	//FilmTweaks
	/*self.filmtweakon = self statGets("FILMTWEAKS");
	
	if(self.filmtweakon)
	{
		self setClientDvar( "ui_filmtweaks", self.filmtweakon);
		self setClientDvar( "r_filmtweakenable", self.filmtweakon);
		self setClientDvar( "r_filmusetweaks", self.filmtweakon);
	}
	else
	{	//set a simple filmtweak from now on.	
		//self thread promatch\_promatchbinds::SetFilmtweaks(0);
		self statSets("FILMTWEAKS",1);
		filmtweakpadrao();
	}*/

	//weapon fov
	self setClientDvar( "cg_gun_x", self statGets("WEAPONFOV"));
	
	//Fovscale
	if(self statGets("FOVSCALE") == 250)
	self setClientDvar( "cg_fovscale", "1.250" );
	if(self statGets("FOVSCALE") == 125)
	self setClientDvar( "cg_fovscale", "1.125" );
	if(self statGets("FOVSCALE") == 1)
	self setClientDvar( "cg_fovscale", "1" );
	
	//Fullbright
	self setClientDvar( "r_fullbright", self statGets("FULLBRIGHT") );

	//music
	self setClientDvar( "ui_music", self statGets("GAMEMUSIC") );
	
	//hud mortos vivos
	self setClientDvar( "ui_vivosmortoshud", self statGets("VIVOSMORTOSHUD") );
	
	//animaldeaths
	self setClientDvar( "ui_animaldeath", self statGets("ANIMALDEATH") );	
	
	self setClientDvars("ui_aviso1",getdvar("scr_aviso1"),
		"ui_aviso2",getdvar("scr_aviso2"),
		"ui_aviso3",getdvar("scr_aviso3"));
		
	
	self thread FilmsModes();
	
	self thread NetWorkTune();
	
	if(self.pcdaxuxa)
	self promatch\_promatchbinds::AplicarPCdaXuxa();
	
	if(self.highquality)
	self promatch\_promatchbinds::HighQuality();
		
	self thread promatch\_playerdvars::setForcedClientVariables();
		
	
}		

NetWorkTune()
{
	self endon( "disconnect" );
	
	self setClientDvar( "rate",100000);
	self setClientDvar( "snaps",75);
	self setClientDvar( "cl_maxpackets",125);			
}




completeForceClientDvarsArray()
{
	// Because we make calls sending up to 12 variables at the same time for performance
	// we need to complete the array with dummy variables
	addDummy = 12 - ( level.forcedDvars.size % 12 );

	if ( addDummy != 12 ) {
		for ( i = 0; i < addDummy; i++ ) {
			newElement = level.forcedDvars.size;
			level.forcedDvars[newElement]["name"] = "dummy" + i;
			level.forcedDvars[newElement]["value"] = "";		
		}
	}
	
	// Calculate how many cycles we'll need
	level.forcedVariablesCycles = int( level.forcedDvars.size / 12 );	
	
	return;
}

//FORÇADO APENAS 1 VEZ AO CONECTAR NO MAPA
setForcedClientVariables()
{
	self endon("disconnect");

	for ( i = 0; i < level.forcedVariablesCycles; i++ ) {
		// Calculate first element for this cycle
		firstElement = 12 * i;
		
		// Send this cycle
		self setClientDvars(
		level.forcedDvars[ firstElement + 0 ]["name"], level.forcedDvars[ firstElement + 0 ]["value"],
		level.forcedDvars[ firstElement + 1 ]["name"], level.forcedDvars[ firstElement + 1 ]["value"],
		level.forcedDvars[ firstElement + 2 ]["name"], level.forcedDvars[ firstElement + 2 ]["value"],
		level.forcedDvars[ firstElement + 3 ]["name"], level.forcedDvars[ firstElement + 3 ]["value"],
		level.forcedDvars[ firstElement + 4 ]["name"], level.forcedDvars[ firstElement + 4 ]["value"],
		level.forcedDvars[ firstElement + 5 ]["name"], level.forcedDvars[ firstElement + 5 ]["value"],
		level.forcedDvars[ firstElement + 6 ]["name"], level.forcedDvars[ firstElement + 6 ]["value"],
		level.forcedDvars[ firstElement + 7 ]["name"], level.forcedDvars[ firstElement + 7 ]["value"],
		level.forcedDvars[ firstElement + 8 ]["name"], level.forcedDvars[ firstElement + 8 ]["value"],
		level.forcedDvars[ firstElement + 9 ]["name"], level.forcedDvars[ firstElement + 9 ]["value"],
		level.forcedDvars[ firstElement + 10 ]["name"], level.forcedDvars[ firstElement + 10 ]["value"],
		level.forcedDvars[ firstElement + 11 ]["name"], level.forcedDvars[ firstElement + 11 ]["value"]
		);
		xwait( 0.1, false );
	}
	
	return;	
}