#include promatch\_eventmanager;
#include promatch\_utils;
#include common_scripts\utility;
//V104

demorec()
{	
	//DeMO 3152	
	if (statGets("DEMOREC") == 0)
	{	
		statSets("DEMOREC",1);
		mapa = toLower( getDvar( "mapname" ) );
		round = game["roundsplayed"]+1;
		modo = toLower( getDvar( "g_gametype" ) );
		self ExecClientCommand ("record  " + mapa + "_[" + modo +  "]_Round(" + round +")");
		self iprintlnbold( &"OW_DEMOON" );
		self playLocalSound( "weap_ammo_pickup" );
	}
	else if (statGets("DEMOREC") == 1)
	{	
		statSets("DEMOREC",0);
		self ExecClientCommand ("stoprecord");
		self iprintlnbold( &"OW_DEMOOFF" );
		self playLocalSound( "weap_ammo_pickup" );
	} 
	
}

musiclevel()
{
	if(self statGets("GAMEMUSIC") == 0)
	{
		self statSets("GAMEMUSIC",1); 
		self setClientDvar( "ui_music", 1);
	}
	else 
	{
		self statSets("GAMEMUSIC",0);
		self setClientDvar( "ui_music", 0);
	}
}

HighQuality()
{	
	
	if(self statGets("PROFILEGFX") == 0) 
	{ 
		self setClientDvar( "ui_quality", 0);
		//self iprintln( "High Quality Off" );		
		return;
	}
	
	if ( self statGets("PROFILEGFX") == 1)
	{	
			self setclientdvars("r_lodscalerigid",1,
			"cg_brass",1,
			"r_normalmap",1,
			"r_dlightlimit",4,
			"fx_drawclouds",1,
			"r_zfeather",1,
			"r_distortion",1,
			"ragdoll_enable", 1,
			"r_aaAlpha",2,
			"sm_enable",1,
			"r_altModelLightingUpdate",1,
			"r_detail", 1,
			"r_dof_bias",0.3,
			"dynent_active",1,
			"r_drawSun",1,
			"r_drawWater",1,
			"r_lodScaleSkinned",2,
			"r_forceLod","high",	
			"r_lodBiasRigid",-1000,
			"r_lodBiasSkinned",-1000,	
			"r_normal",1,	
			"ui_quality",1
			);
			self iprintln( "High Quality Enabled" );		
	}
}

hudmessagepos()
{
	if(self statGets("MSGPOS") == 0)
	{						
		self setClientDvar( "ui_gamemessagehud",1);
		self statSets("MSGPOS",1);
	}
	else
	{
		self setClientDvar( "ui_gamemessagehud",0);
		self statSets("MSGPOS",0);
	}
}

xuxapcOnOff()
{
	//self iprintln( "High Quality ?" );

	if(self statGets("PCDAXUXA") == 0)
	{
		self statSets("PCDAXUXA",1);
		self setClientDvar( "ui_pcxuxa", 1);
		
		self statSets("PROFILEGFX",0);
		self setClientDvar( "ui_quality", 0);

		self AplicarPCdaXuxa();
		self playLocalSound( "weap_ammo_pickup" );
		return;			
	}
	
	if(self statGets("PCDAXUXA") == 1)
	{
		self setClientDvar( "ui_pcxuxa", 0);
		self statSets("PCDAXUXA",0);
		self iprintln( "Modo PC da XUXA desativado" );
		self playLocalSound( "weap_ammo_pickup" );
	}
}

AplicarPCdaXuxa()
{
		self setclientdvars("r_lodscalerigid",2.99,
			"dynent_active",0,
			"ragdoll_enable",0,
			"r_distortion",0,
			"cg_brass",0,
			"r_fastSkin",1,
			"r_normalmap",0,
			"r_dlightlimit",0,
			"fx_drawclouds",0,
			"cg_blood",0,
			"r_dof_enable",0,
			"r_glow_allowed",0,
			"r_aaAlpha","off",
			"r_aaSamples",1,
			"r_autopriority",1,
			"sm_enable",0,
			"r_altModelLightingUpdate",1,
			"r_detail", 0,
			"r_drawDecals",0,
			"r_drawSun",0,
			"r_drawWater",0,
			"r_forceLod",3,	
			"r_glow",0,				
			"r_lodBiasRigid",0,
			"r_lodBiasSkinned",0,
			"r_lodScaleSkinned",2.99,
			"ui_pcxuxa",1,
			"r_normal",0	
			);	
}

QualityOnOff()
{
	//self iprintln( "High Quality ?" );

	if(self statGets("PROFILEGFX") == 0)
	{
		self statSets("PROFILEGFX",1);
		self statSets("PCDAXUXA",0);
		self setClientDvar( "ui_pcxuxa", 0);
		self setclientdvars("r_lodscalerigid",1,
		"cg_brass",1,
		"r_lodScaleSkinned",1,
		"r_normalmap",1,
		"r_dlightlimit",4,
		"fx_drawclouds",1,
		"r_zfeather",1,
		"r_distortion",1,
		"ragdoll_enable", 1,
		"r_specular",0,
		"r_aaAlpha",2,
		"r_aaSamples",3,
		"sm_enable",1,
		"r_altModelLightingUpdate",1,
		"r_detail", 0,
		"r_dof_bias",0.3,
		"r_drawDecals",1,
		"r_drawSun",1,
		"r_drawWater",1,
		"r_forceLod","high",	
		"r_lodBiasRigid",-1000,
		"r_lodBiasSkinned",-1000,	
		"r_normal",1,	
		"ui_quality",1
		);
		self playLocalSound( "weap_ammo_pickup" );
		return;			
	}
	
	if(self statGets("PROFILEGFX") == 1)
	{
		self statSets("PROFILEGFX",0);
		self setclientdvars("r_lodscalerigid",1,
			"cg_brass",0,
			"r_normalmap",0,
			"r_dlightlimit",2,
			"fx_drawclouds",0,
			"r_dof_enable",0,
			"r_glow_allowed",0,
			"r_aaAlpha",0,
			"r_aaSamples",1,
			"sm_enable",0,
			"r_altModelLightingUpdate",1,
			"r_detail", 0,
			"r_drawDecals",0,
			"r_drawSun",0,
			"r_drawWater",0,
			"r_forceLod",3,	
			"r_glow",0,				
			"r_lodBiasRigid",0,
			"r_lodBiasSkinned",0,	
			"ui_quality",0
			);	
			self iprintln( " Quality Disable" );
			self playLocalSound( "weap_ammo_pickup" );
	}
}

ResetUserConfig()
{
	self setclientdvars("r_lodscalerigid",1,
		"cg_hudDamageIconInScope",0,
		"r_fastSkin",1,
		"cg_viewzsmoothingmax",16,
		"cg_viewzsmoothingmin",1,
		"cg_viewzsmoothingtime",0.1,
		"cg_huddamageiconheight",64,
		"cg_huddamageiconwidth",128,
		"r_dlightlimit",2,
		"sm_enable",0,
		"r_lodRigid",2,
		"r_lodscaleSkinned",2,
		"sv_cheats", 0,
		"r_distortion",0,
		"r_fullscreen",1,
		"developer",0,								
		"con_maxfps",250,
		"r_zfeather",0,
		"cl_maxpackets",125
		);
		xwait (0.05,false);
		self setclientdvars ("com_maxfps",250,
		"snaps",75,
		"sm_enable",0,
		"compassPlayerHeight",15,
		"compassPlayerWidth",15,
		"cg_debugInfoCornerOffset","-20 464",
		"ragdoll_enable", 0,
		"cg_brass", 1,
		"r_detail", 0,
		"cg_fov", 80,
		"rate", 30000,
		"r_dof_enable", 0,
		"cg_huddamageicontime", 2000,
		"waypointIconHeight",12,
		"waypointIconWidth",12
		);
		
		self statSets("WEAPONFOV",0);
		self setClientDvar( "cg_gun_x", "0" );
		//self iPrintLnBold ("Your game´s CFG is now ^2Allowed^7.");
}

movie1()
{
	//exec "exec rulesets/americanstyle.cfg";	
}



SetFilmtweaks(tweaknum)
{

	// ---Stats to Auto Load Lightings Modes---	
	//Ignorar caso nao esteja ativo o filmtweak
	switch(tweaknum)
	{
		case 00:
		self thread film00();
		break;		
		case 01:
		self thread film01();
		break;		
		case 02:
		self thread film02();
		break;		
		case 03:
		self thread film03();
		break;
		case 04:
		self thread film04();
		break;
		case 05:
		self thread film05();
		break;
		case 06:
		self thread film06();
		break;		
		case 07:
		self thread film07();
		break;
		
		case 08:
		self thread film08();
		break;
		
		case 09:
		self thread film09();
		break;
		
		case 10:
		self thread film10();
		break;
	}


}

updatefilmtweakui()
{	
	self setClientDvar( "ui_filmtweak00", 0);	
	self setClientDvar( "ui_filmtweak01", 0);
	self setClientDvar( "ui_filmtweak02", 0);
	self setClientDvar( "ui_filmtweak03", 0);
	self setClientDvar( "ui_filmtweak04", 0);
	self setClientDvar( "ui_filmtweak05", 0);
	self setClientDvar( "ui_filmtweak06", 0);	
	self setClientDvar( "ui_filmtweak07", 0);
	self setClientDvar( "ui_filmtweak08", 0);
	self setClientDvar( "ui_filmtweak09", 0);
	self setClientDvar( "ui_filmtweak10", 0);
	
	if(statGets("FILMMODES") == 0)
	self setClientDvar( "ui_filmtweak00", 1);
	
	if(statGets("FILMMODES") == 1)
	self setClientDvar( "ui_filmtweak01", 1);
	
	if(statGets("FILMMODES") == 2)
	self setClientDvar( "ui_filmtweak02", 1);
	
	if(statGets("FILMMODES") == 3)
	self setClientDvar( "ui_filmtweak03", 1);
	
	if(statGets("FILMMODES") == 4)
	self setClientDvar( "ui_filmtweak04", 1);
	
	if(statGets("FILMMODES") == 5)
	self setClientDvar( "ui_filmtweak05", 1);
	
	if(statGets("FILMMODES") == 6)
	self setClientDvar( "ui_filmtweak06", 1);
	
	if(statGets("FILMMODES") == 7)
	self setClientDvar( "ui_filmtweak07", 1);
	
	if(statGets("FILMMODES") == 8)
	self setClientDvar( "ui_filmtweak08", 1);
	
	if(statGets("FILMMODES") == 9)
	self setClientDvar( "ui_filmtweak09", 1);
	
	if(statGets("FILMMODES") == 10)
	self setClientDvar( "ui_filmtweak10", 1);
}



film00()
{
	statSets("FILMMODES",0);
	//self setClientDvar( "r_lightTweakSunLight", getDvar("r_lightTweakSunLight"));
	self updatefilmtweakui();
	self iprintln( "Definido pelo usuario." );	
}


film01()
{
	self setClientDvars( "r_filmtweakenable", 1,
	"r_filmtweakContrast", 1.15,
	"r_filmtweakLighttint", "1.1 1.1 1.1",
	"r_filmtweakDarktint", "1.8 1.8 1.8",
	"r_filmtweakDesaturation", 0,
	"r_filmTweakInvert", "0",
	"r_gamma", 1.1,
	"r_filmtweakbrightness", 0,
	"r_lightTweakSunLight", 0);
	statSets("FILMMODES",1);
	self setClientDvar( "r_filmusetweaks", 1);
	self updatefilmtweakui();
	self playLocalSound( "weap_ammo_pickup" );
	self iprintln( "film-01" );
}


film02()
{
	self setClientDvars( "r_filmtweakenable", 1,
	"r_filmtweakContrast", 1.1,
	"r_filmtweakLighttint", "1.6 1.6 1.6",
	"r_filmtweakDarktint", "1.8 1.8 1.8",
	"r_filmtweakDesaturation", 0,
	"r_filmTweakInvert", "0",
	"r_gamma", 1.1,
	"r_filmtweakbrightness", 0.04,
	"r_lightTweakSunLight", 0);
	statSets("FILMMODES",2);
	self setClientDvar( "r_filmusetweaks", 1);
	self updatefilmtweakui();
	self playLocalSound( "weap_ammo_pickup" );
	self iprintln( "film-02" );
}

film03()
{
	self setClientDvars( "r_filmtweakenable", 1,
	"r_filmtweakContrast", 1.2,
	"r_filmtweakLighttint", "1 1 1",
	"r_filmtweakDarktint", "1.6 1.6 1.6",
	"r_filmtweakDesaturation", 0,
	"r_filmTweakInvert", "0",
	"r_gamma", 1.1,
	"r_filmtweakbrightness", 0,
	"r_lightTweakSunLight", 0);
	statSets("FILMMODES",3);
	self setClientDvar( "r_filmusetweaks", 1);
	self updatefilmtweakui();
	self playLocalSound( "weap_ammo_pickup" );
	self iprintln( "film-03" );
}

film04()
{
	self setClientDvars( "r_filmtweakenable", 1,
	"r_filmtweakContrast", 1.1,
	"r_filmtweakLighttint", "1.1 1.1 1.1",
	"r_filmtweakDarktint", "1.3 1.5 1.6",
	"r_filmtweakDesaturation", 0.3,
	"r_filmTweakInvert", "0",
	"r_gamma", 1.2,
	"r_filmtweakbrightness", 0,
	"r_lightTweakSunLight", 0.8);
	statSets("FILMMODES",4);
	self setClientDvar( "r_filmusetweaks", 1);
	self updatefilmtweakui();
	self playLocalSound( "weap_ammo_pickup" );
	self iprintln( "film-04" );
}

film05()
{
	self setClientDvars( "r_filmtweakenable", 1,
	"r_filmtweakContrast", 1.1,
	"r_filmtweakLighttint", "1.8 1.8 1.8",
	"r_filmtweakDarktint", "1.8 1.8 1.8",
	"r_filmtweakDesaturation", 0,
	"r_filmTweakInvert", "0",
	"r_gamma", 1.1,
	"r_filmtweakbrightness", 0,
	"r_lightTweakSunLight", 0);
	statSets("FILMMODES",5);
	self setClientDvar( "r_filmusetweaks", 1);
	self updatefilmtweakui();
	self playLocalSound( "weap_ammo_pickup" );
	self iprintln( "film-05" );
}

film06()
{
	self setClientDvars( "r_filmtweakenable", 1,
	"r_filmtweakContrast", 1.2,
	"r_filmTweakInvert", "0",
	"r_filmtweakLighttint", "1 1 1",
	"r_filmtweakDarktint", "1.8 1.9 1.8",
	"r_filmtweakDesaturation", 0,
	"r_gamma", 1.2,
	"r_filmtweakbrightness", 0,
	"r_lightTweakSunLight", 0.8);
	statSets("FILMMODES",6);
	self setClientDvar( "r_filmusetweaks", 1);
	self updatefilmtweakui();
	self playLocalSound( "weap_ammo_pickup" );
	self iprintln( "film-06" );
}


film07()
{
	self setClientDvars( "r_filmtweakenable", 1,
	"r_filmtweakContrast", 1.2,
	"r_filmtweakLighttint", "0.8 0.8 1",
	"r_filmtweakDarktint", "1.8 1.8 2",
	"r_filmtweakDesaturation", 0,
	"r_filmTweakInvert", "0",
	"r_gamma", 1.1,
	"r_filmtweakbrightness", 0,
	"r_lightTweakSunLight", 0);	
	statSets("FILMMODES",7);	
	self setClientDvar( "r_filmusetweaks", 1);	
	self updatefilmtweakui();	
	self playLocalSound( "weap_ammo_pickup" );
	self iprintln( "film-07" );
}


film08()
{
	self setClientDvars( "r_filmtweakenable", 1,
	"r_filmtweakContrast", 2,
	"r_filmtweakLighttint", "0.4 0.43 0.53",
	"r_filmtweakDarktint", "1.4 1.5 1.8",
	"r_filmtweakDesaturation", 0,
	"r_filmTweakInvert", "0",
	"r_gamma", 1,
	"r_filmtweakbrightness", 0.35,
	"r_lightTweakSunLight", 0);	
	statSets("FILMMODES",8);	
	self setClientDvar( "r_filmusetweaks", 1);	
	self updatefilmtweakui();	
	self playLocalSound( "weap_ammo_pickup" );
	self iprintln( "film-08" );
}

film09()
{
	self setClientDvars( "r_filmtweakenable", 1,
	"r_filmtweakContrast", 2,
	"r_filmtweakLighttint", "0.4 0.43 0.53",
	"r_filmtweakDarktint", "1.4 1.5 1.8",
	"r_filmtweakDesaturation", 0,
	"r_filmTweakInvert", "0",
	"r_gamma", 1,
	"r_filmtweakbrightness", 0.35,
	"r_lightTweakSunLight", 0);	
	statSets("FILMMODES",8);	
	self setClientDvar( "r_filmusetweaks", 1);	
	self updatefilmtweakui();	
	self playLocalSound( "weap_ammo_pickup" );
	self iprintln( "film-09" );
}


film10()
{
	self setClientDvars( "r_filmtweakenable", 1,
	"r_filmtweakContrast", 2,
	"r_filmtweakLighttint", "0.4 0.43 0.53",
	"r_filmtweakDarktint", "1.4 1.5 1.8",
	"r_filmtweakDesaturation", 0,
	"r_filmTweakInvert", "0",
	"r_gamma", 1,
	"r_filmtweakbrightness", 0.35,
	"r_lightTweakSunLight", 0);	
	statSets("FILMMODES",10);	
	self setClientDvar( "r_filmusetweaks", 1);	
	self updatefilmtweakui();	
	self playLocalSound( "weap_ammo_pickup" );
	self iprintln( "film-10" );
}

//manual
Sunlight()
{
	if (!isDefined( self.sunlight ) ) 
	{
		self.sunlight = 0;
	}
	
	// Cycle the value
	self.sunlight++;
	
	if ( self.sunlight > 4 ) 
	{
		self.sunlight = 0;
	}

	//sunlight - caso alterado
	switch(self.sunlight)
	{
		case 0:
		self setClientDvar( "r_lightTweakSunLight", 80/100 );
		statSets("SUNLIGHT",80);
		self iprintlnbold( "SunLight em 0.8" );
		break;
		
		case 1:
		self setClientDvar( "r_lightTweakSunLight", 120/100 );
		statSets("SUNLIGHT",120);
		self iprintlnbold( "SunLight em 1.2" );
		break;
		
		case 2:
		self setClientDvar( "r_lightTweakSunLight", 210/100 );
		statSets("SUNLIGHT",210);
		self iprintlnbold( "SunLight em 2.1" );
		break;
		
		case 3:
		self setClientDvar( "r_lightTweakSunLight", 0 );
		statSets("SUNLIGHT",0);
		self iprintlnbold( "SunLight em 0" );
		break;		
		
		case 4:
		lightvalue = getDvarFloat("r_lightTweakSunLight");
		self setClientDvar( "r_lightTweakSunLight", lightvalue);		
		statSets("SUNLIGHT",int(lightvalue * 100));
		self iprintlnbold( "SunLight padrao do mapa." );
		break;
	}
}

lights()
{
	//Ignorar caso nao esteja ativo o filmtweak
	//iprintln (statGets("FILMTWEAKS"));
	if (self statGets("FILMTWEAKS") == 0)
	{
		self iPrintLn("^1FilmTweaks Off (Press B + 48)");
		return;
	}
	

	if ( self statGets("FULLBRIGHT") == 1)
	{
		self iPrintLn("^FULLBRIGHT ativo (Press B + 48)");
		return;
	}

	if ( !isDefined( self.lights  ) ) 
	{
		self.lights  = 0;
	}
	
	self.lights++;
	if ( self.lights  > 10 ) 
	{
		self.lights  = 0;
	}
	
	self thread SetFilmtweaks(self.lights);
}

drawdecal()
{		 
	if ( !isDefined( self.decal ) ) 
	{
		self.decal  = 1;
	}
	
	// Cycle the value
	self.decal++;
	if ( self.decal  != 1 ) {
		self.decal  = 0;
	}
	
	// Initialze the variables 

	dc1 = "0";
	dc2 = "0";
	
	switch ( self.decal ) {
	case 0:

		dc1 = 0;
		self iprintln( &"OW_DECAYOFF" );
		
		break;

	case 1:

		dc2 = 1;
		self iprintln( &"OW_DECAYON" );

		break;
		
	}
	self playLocalSound( "weap_ammo_pickup" );
	self setClientDvars( "r_Drawdecals", dc1,"r_Drawdecals", dc2);
	return;
}




newfovscale()
{
	getfov = self statGets("FOVSCALE");
	//self iprintln("fovscale: "+ getfov );
	
	if (getfov == 0)
	{	
		self statSets("FOVSCALE",125);
		self setClientDvar( "ui_cg_fovscale", "1.125" );
		self setClientDvar( "cg_fovscale", "1.125" );		
		return;
	} 
	
	if ( getfov == 125)
	{	
		self statSets("FOVSCALE",250);
		self setClientDvar( "ui_cg_fovscale", "1.250" );
		self setClientDvar( "cg_fovscale", "1.250" );
		return;
	}
	
	if ( getfov == 250)
	{	
		self statSets("FOVSCALE",0);
		self setClientDvar( "ui_cg_fovscale", "1" );
		self setClientDvar( "cg_fovscale", "1" );
		return;
	}
}

weaponfov()
{

	weapofov = statGets("WEAPONFOV");
	
	if (weapofov == 0)
	{	
		self statSets("WEAPONFOV",2);//long scale		
		self setClientDvar( "ui_weaponfovscale", "2" );
		self setClientDvar( "cg_gun_x", "2" );
		self iprintlnbold( "Weapon Fov em 2" );
		self playLocalSound( "weap_ammo_pickup" );
		return;
	} 
	else if ( weapofov == 2)
	{	
		self statSets("WEAPONFOV",-2);//real weapon fov
		self setClientDvar( "ui_weaponfovscale", "-2" );
		self setClientDvar( "cg_gun_x", "-2" );
		self iprintlnbold( "Weapon Fov em Modo Real" );
		self playLocalSound( "weap_ammo_pickup" );
		return;
	}
	else
	{	
		self statSets("WEAPONFOV",0);//NORMAL
		self setClientDvar( "ui_weaponfovscale", "0" );
		self setClientDvar( "cg_gun_x", "0" );
		self iprintlnbold( "Weapon Fov em Normal" );
		self playLocalSound( "weap_ammo_pickup" );
	}
}

cyclefov()
{
	if ( !isDefined( self.cycleFOV ) ) 
	{
		self.cycleFOV = 0;
	}
	
	// Cycle the value
	self.cycleFOV++;
	if ( self.cycleFOV > 4 ) {
		self.cycleFOV = 0;
	}
	
	// Initialze the variables 
	drawFOV = 0;
	
	
	// Check which values we need to set according to the position in the cycle
	switch ( self.cycleFOV ) 
	{
	case 0:
		drawFOV = 65;
		self iprintln( &"OW_FOV1" );			
		break;
		
	case 1:
		drawFOV = 70;
		self iprintln( &"OW_FOV2" );			
		break;
		
	case 2:
		drawFOV = 75;
		self iprintln( &"OW_FOV3" );			
		break;
		
	case 3:
		drawFOV = 80;
		self iprintln( &"OW_FOV4" );			
		break;
		
	case 4:
		drawFOV = 90;
		self iprintln( "FOV 90" );			
		break;
	
	}
	
	// Set the corresponding client dvars
	self setClientDvar( "cg_fov", drawFOV );
	self playLocalSound( "weap_ammo_pickup" );
	return;
}

fullbright()
{
	if ( statGets("FULLBRIGHT") == 0)//Normal
	{	
		statSets("FULLBRIGHT",1);
		self setClientDvar( "r_fullbright", "1" );
		self iprintlnbold( "Fullbright is now enable" );
		self playLocalSound( "weap_ammo_pickup" );
		return;
	} 
	else if ( statGets("FULLBRIGHT") != 0)
	{	
		statSets("FULLBRIGHT",0);
		self setClientDvar( "r_fullbright", "0" );		
		self iprintlnbold( "Fullbright is now disable" );
		self playLocalSound( "weap_ammo_pickup" );
	}
}


filmtweaks()
{
	if ( self statGets("FILMTWEAKS") == 0)
	{	
		
		statSets("FILMTWEAKS",1);
		self setClientDvar( "ui_filmtweaks", 1);
		self setClientDvar( "r_filmtweakenable", 1);
		self setClientDvar( "r_filmusetweaks", 1);
		self iprintlnbold( "Filmtweaks Enabled" );
		self playLocalSound( "weap_ammo_pickup" );
		return;
	}
	else
	{
		self setClientDvar( "ui_filmtweaks", 0);
		self setClientDvar( "r_filmtweakenable", 0);
		self setClientDvar( "r_filmusetweaks", 0);
		statSets("FILMTWEAKS",0);
		self iprintlnbold( "Filmtweaks Disabled" );
		self playLocalSound( "weap_ammo_pickup" );
	}
}




//Training Modules

penetration()
{
	if ( !isdefined (self.ptracer) || isdefined (self.ptracer) && self.ptracer == false)
	{	
		self.ptracer = true;
		self setClientDvar ( "ui_hud_showhits", 1);
		//self setClientDvar ("cg_LaserForceOn", "1");
		self.hint3 setText( "^2Mode^7: Shooting" );
	} else
	{
		self.ptracer = false;	
		self setClientDvar ( "ui_hud_showhits", 0);
		//self setClientDvar ("cg_LaserForceOn", "0");
		self.hint3 setText( "^2Mode^7: Nade" );
		
	}
}

recoil()
{
	if ( !isdefined (self.precoil) || isdefined (self.precoil) && self.precoil == false)
	{	
		self.precoil = true;
		self setClientDvar ("cg_firstPersonTracerChance",1);
		self setClientDvar ("cg_tracerchance",1);
		self setClientDvar ("cg_tracerlength",6000);
		self setClientDvar ("cg_tracerSpeed",80);
		self.hint3 setText( "^2Mode^7: Recoil Analysis" );
	} else
	{
		self.precoil = false;
		self setClientDvar ("cg_firstPersonTracerChance",0);
		self setClientDvar ("cg_tracerchance",0);	
		self setClientDvar ("cg_tracerSpeed",200);
		self.hint3 setText( "^2Mode^7: Nade" );		
	}
}


target()
{
	if ( !isdefined (self.targetx) || isdefined (self.targetx) && self.targetx == false)
	{	
		self.targetx = true;		
		objCompass = maps\mp\gametypes\_gameobjects::getNextObjID();
		if ( objCompass != -1 )
		{
			objective_add( objCompass, "active", self.origin + level.aacpIconOffset );
			objective_icon( objCompass, level.aacpIconCompass );
			objective_onentity( objCompass, self );
			if ( level.teamBased )
			{
				objective_team( objCompass, level.otherTeam[ self.pers["team"] ] );
			}
		}		

		objWorld = newHudElem();		
		origin = self.origin + level.aacpIconOffset;
		objWorld.name = "pointout_" + self getEntityNumber();
		objWorld.x = origin[0];
		objWorld.y = origin[1];
		objWorld.z = origin[2];
		objWorld.baseAlpha = 1.0;
		objWorld.isFlashing = false;
		objWorld.isShown = true;
		objWorld setShader( level.aacpIconShader, level.objPointSize, level.objPointSize );
		objWorld setWayPoint( true, level.aacpIconShader );
		objWorld setTargetEnt( self );
		objWorld thread maps\mp\gametypes\_objpoints::startFlashing();	
		self iprintln("Target Ativated");
		self thread deleteObjectiveOnDD( objCompass, objWorld );
	}
	else 
	{ 
		self.targetx = false;
		self notify("targetoff");
	}
	
}		


deleteObjectiveOnDD( objID, objWorld )
{
	self waittill_any( "disconnect", "targetoff" );
	
	objWorld notify("stop_flashing_thread");
	objWorld thread maps\mp\gametypes\_objpoints::stopFlashing();


	xwait( 0.25, false );
	
	if (isdefined(self))
	{
		self iprintln("Target Disable");
	}
	if ( objID != -1 ) 
	{//CHD
		maps\mp\gametypes\_gameobjects::resetObjID( objID );
	}
	objWorld destroy();
}

ShowStats()
{
	//fix cannot set field of removed entity:
	if(!isDefined(self))
		return;
		
	if(level.cod_mode == "torneio") return;
	
	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
	return;
	
	if(!isDefined( self.onstats))
	self.onstats = false;
	
	if(self.onstats) return;
	
	//iprintln("PLAYERID" + self getguid());
	if ( isDefined( self.pers ) && isDefined( self.pers["team"] ) && self.pers["team"] != "spectator") 
	{				
		self.onstats = true;
	
		mortes = self statGets("DEATHS");
		
		somakills = statGets("KILLS");
						
		kdratio = GetTotalKD();
	
		//atualiza as XP
		somascores = statGets("SCORE");
	
		if(somascores > 0)
		self statSets("SCORE",somascores);
	
		myrank = self promatch\_ranksystem::ConvertRankToName();
		
		rankpoints = self GetRankPoints();
		
		if(rankpoints < 1)
		self SetApplyRankPoints(1);

		if(rankpoints > 9000)
		self SetApplyRankPoints(9000);
	
		xhora = int(TimeToString(GetRealTime(),0,"%H"));//24HR - local
		xminutos = int(TimeToString(GetRealTime(),1,"%M"));
		totalmaps = self statGets("PLAYEDMAPSCOUNT");
		
		self iprintln("^7Hora: [^3" +xhora +"h e " + xminutos+"m^7]");
		
		if(isDefined(myrank) && self.isRanked)
		{	
			roundkd = (self GetRoundKD()/100);
			iprintln("FPS: " + self getCountedFPS());
			iprintln("^7RANK: [^3"+myrank+"^7] Points: [^3" + rankpoints + "^7] RoundKD: [^3" + roundkd + "^7] TMapas: [^3" + totalmaps + "^7]");
			iprintln("^1"+ self.name + ": ^2Kills:^7 " + somakills + " ^2Deaths:^7 " + mortes + " ^3$$$:^7 " + self statGets("EVPSCORE") + " ^2K/D:^7 " + kdratio);
		}
		else if(isDefined(rankpoints) && self.isRanked && rankpoints < 1000)
		{
			self iprintln("Faltam " + (1000 - int(rankpoints)) + " para o Rank 1");
			
			iprintln("Points: [^3" + rankpoints + "^7]");
			iprintln("^1"+ self.name + ": ^2Kills:^7 " + somakills + " ^2Deaths:^7 " + mortes + " ^3$$$:^7 " + self statGets("EVPSCORE") + " ^2K/D:^7 " + kdratio);
		}
		else if(!self.isRanked)
		{
			iprintln("^7RANK: [^3NAO RANKEADO^7]");
			iprintln("^1"+ self.name + ": ^2Kills:^7 " + somakills + " ^2Deaths:^7 " + mortes + " ^3$$$:^7 " + self statGets("EVPSCORE") + " ^2K/D:^7 " + kdratio);
		}		
	
		xwait(5,false);
			
		if(isDefined(self))
		self.onstats = false;
	}
}


doTeleport()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon ( "teleported" );
	self iPrintln( "Teleport! Shoot to start.");
	//self Giveweapon("airstrike_mp");
	for(;;)
	{
		self waittill( "begin_firing" );
		self beginLocationselection( "map_artillery_selector", 450 * 1.2 );
		self.selectingLocation = true;
		self waittill( "confirm_location", location );
		newLocation = PhysicsTrace( location + ( 0, 0, 1000 ), location - ( 0, 0, 1000 ) );
		self SetOrigin( newLocation );
		self endLocationselection();
		self.selectingLocation = undefined;
		self iPrintln( "^2You Teleported to " + newLocation );
		self notify("teleported");
	}
}

noDamagePlayer()
{
	if ( !isdefined(self.nodamage) || isdefined(self.nodamage) && self.nodamage == false)
	{	
		self.nodamage = true;
		self.canDoCombat = false;
		self.hint3 setText( "^2Mode^7: No Damage" );
		self iPrintln( "You now cannot receive damage.");
	} 
	else
	{
		self.nodamage = false;
		self.canDoCombat = true;
		self iPrintln( "Damage Enable.");
		self.hint3 setText( "^2Mode^7: Nade" );		
	}
}


//TORNEIO
//em teste sistema de tracer para o lider destinar uma prioridade para o time
// durante a partida.
/*LeaderSetObjective()
{
	self endon ( "objetiveset" );
	self beginLocationselection( "map_artillery_selector", 450 * 1.2 );
	self waittill( "confirm_location", location );
	newLocation = PhysicsTrace( location + ( 0, 0, 1000 ), location - ( 0, 0, 1000 ) );
	self thread CreateSetIcon(newLocation);
	self endLocationselection();
	self iPrintln( "^2Voce selecionou um Objetivo pra o time " + newLocation );
	self notify("objetiveset");
}

CreateSetIcon(ori)
{
	self endon( "teamobj_deleted" );
	self endon("disconnect");
	
	objWorld = newTeamHudElem(self.pers["team"]);
	origin = ori;
	objWorld.name = "pointoutm_" + self getEntityNumber();
	objWorld.x = origin[0];
	objWorld.y = origin[1];
	objWorld.z = origin[2];
	objWorld.baseAlpha = 1.0;
	objWorld.isFlashing = false;
	objWorld.isShown = true;
	objWorld setShader( "waypoint_kill", level.objPointSize, level.objPointSize );
	objWorld setWayPoint( true, "waypoint_kill" );
	
	self thread markerTimer(objWorld);
}

markerTimer(objWorld)
{
	self endon( "teamobj_deleted" );
	self endon( "death" );
	
	xwait(5,false);	
	
	if(isDefined(objWorld))
	{
		objWorld destroy();
		self notify( "teamobj_deleted" );
	}
}*/