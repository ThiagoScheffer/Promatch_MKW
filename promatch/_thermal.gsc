//******************************************************************************
//  _____                  _    _             __
// |  _  |                | |  | |           / _|
// | | | |_ __   ___ _ __ | |  | | __ _ _ __| |_ __ _ _ __ ___
// | | | | '_ \ / _ \ '_ \| |/\| |/ _` | '__|  _/ _` | '__/ _ \
// \ \_/ / |_) |  __/ | | \  /\  / (_| | |  | || (_| | | |  __/
//  \___/| .__/ \___|_| |_|\/  \/ \__,_|_|  |_| \__,_|_|  \___|
//       | |               We don't make the game you play.
//       |_|                 We make the game you play BETTER.
//
//            Website: http://openwarfaremod.com/
//******************************************************************************

#include common_scripts\utility;
#include maps\mp\_utility;
#include promatch\_utils;
#include promatch\_eventmanager;

init()
{
	initThermalArrays();
	level.onThermalReset = ::onThermalReset;

	level thread addNewEvent( "onPlayerConnected", ::thermalOnPlayerConnect );
}


//NOT SURE I NEED THIS!
thermalOnPlayerConnect()
{
	self.pers["thermalSetting"] = 0;
	
	self thread addNewEvent( "onPlayerKilled", ::onPlayerKilled );
	
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}

onPlayerSpawned()
{
	onThermalReset();
}

onPlayerKilled()
{
	if(self.pers["thermalSetting"] != 0)
	self thread thermalOff();
}

//self thread thermalRestore();
onThermalReset()
{
	self.pers["thermalSetting"] = 0;
	self thermalOff();
}

thermalWatchWeaponChange()
{
	self endon("death");
	self endon("disconnect");
	
	while(1)
	{
		self waittill( "weapon_change", newWeapon );

		//If this player is a sniper, and the new weapon is not a sniper rifle with the correct perk, turn off thermal.
		if( isDefined( self.pers["class"] ) && !isThermal( newWeapon ) )
		{
			self onThermalReset();
		}
	}
}

isThermal( weapon )
{
	if( isSubStr( weapon, "g36c_acog" ) )
		return true;
	//if ( isSubStr( weapon, "m16_reflex_" ) )
	//	return true;

	return false;
}


thermalToggle()
{
	//currentWeapon = self getCurrentWeapon();
	//self iprintln("currentWeapon THERMAL ON " + currentWeapon);	
	
	
	if (self statGets("FILMTWEAKS") == 0)
	{
		self iprintln("THERMAL OFF nao usando FILMTWEAKS");	
		return;
	}
	
	//if( isThermal(currentWeapon))
	//{
		if ( self statGets("FULLBRIGHT") == 1)
		{
			self.isonFullbright = true;
			//self setClientDvar( "r_fullbright", "0" );
		}
	
		self setThermalView();
		//self iprintln("THERMAL ON");
		self thread watchForAdsIn();
	//}
}

setThermalView(setting)
{
	self.pers["thermalSetting"] = 1;
	/*
	if( isDefined( setting ) )
		self.pers["thermalSetting"] = setting;
	else
		self.pers["thermalSetting"]++;

	if( self.pers["thermalSetting"] > ( level.thermalArray.size  ) )
		self.pers["thermalSetting"] = 0;

	if( self.pers["thermalSetting"] == 0)
		self thread thermalOff(true);
	else if( self.pers["thermalSetting"] == 1)
	{
		self PlayLocalSound( "item_nightvision_on" );
		self thread thermalRestore();
	}
	else
		self thread thermalRestore();*/

}

//APLICA O THERMAL
thermalRestore()
{
		
	//Test - just in case the setting is undefined do nothing
	if( !isDefined( self.pers["thermalSetting"]) )
	{
		return;
	}
	
	if( !isDefined( level.thermalArray[self.pers["thermalSetting"]] ) )
	{
		return;
	}
	
	self setClientDvars(
		"r_filmTweakInvert", "1",
		"r_filmusetweaks", "1",
		"r_filmtweakenable", "1",
		"r_filmtweakdesaturation", level.thermalArray[self.pers["thermalSetting"]]["desaturation"], 	//default 0.2
		"r_filmtweakbrightness", level.thermalArray[self.pers["thermalSetting"]]["brightness"],  	//-1 to 1
		"r_filmTweakContrast", level.thermalArray[self.pers["thermalSetting"]]["contrast"], 		//default 1.4 
		"r_filmTweakLightTint", level.thermalArray[self.pers["thermalSetting"]]["lighttint"]	//rgb 0-2 each
	);

	self setClientDvars(
		"r_glowTweakEnable", "1",  						//0-1
		"r_glowUseTweaks", "1", 						//0-1
		"r_glowTweakBloomCutoff", level.thermalArray[self.pers["thermalSetting"]]["bloomcutoff"],	//0-1 default 0.5 //seems to control contrast.
		"r_glowTweakBloomDesaturation", level.thermalArray[self.pers["thermalSetting"]]["bloomdesaturation"],	//0 or 1, default 0 - glow color, based on terrain color.
		"r_glowTweakBloomIntensity0", level.thermalArray[self.pers["thermalSetting"]]["bloomintensity"]	//range 0-20 default 1 - controls intensity of the glowing parts
	);
}

thermalOff( playsound )
{

	//restaura
	if(isDefined(self.isonFullbright))
	{
		self setClientDvar( "r_fullbright", "1" );
	}
	
	self thread promatch\_promatchbinds::SetFilmtweaks(self statGets("FILMMODES"));

	//sunlight - automatico
	switch(self statGets("SUNLIGHT"))
	{
		case 0: //desativado
		break;
		
		case 1:
		self setClientDvar( "r_lightTweakSunLight", "0.8" );
		break;
		
		case 2:
		self setClientDvar( "r_lightTweakSunLight", "1.2" );
		break;
		
		case 3:
		self setClientDvar( "r_lightTweakSunLight", "0" );
		break;
		
		case 4:
		self setClientDvar( "r_lightTweakSunLight", getDvar("r_lightTweakSunLight"));
		break;
	
	}
	
	self setClientDvars(
		"r_glowTweakBloomCutoff", "0.5",	//0-1 default 0.5
		"r_glowTweakBloomDesaturation", "0", 	//0 or 1, default 0
		"r_glowTweakBloomIntensity0", "1", 	//range 0-20 default 1
		"r_glowTweakRadius0", "5",             //default 5,  radius in pixels 640x480 default 5
		"r_glowTweakEnable", "0",  		//0-1
		"r_glowUseTweaks", "0" 		//0-1
		);

	if( isDefined( playsound ))
		self PlayLocalSound( "item_nightvision_off" ); //NEED TO ADD CHECK FOR THIS
}






// NOTE: Sniper zoom and range finder have watchers!
// A convenient way to have all three in one thread?
// Possible to put these in menu with a sniper watcher?
// How to choose which thermal setting? Need dvar?
watchForAdsOut()
{
	if( self.pers["thermalSetting"] == 0 )
		return;

	//allow only one instance of this thread
	self notify("kill_ads_out");
	self endon("kill_ads_out");

	//Too many endons.
	//self endon("thermal_off");
	self endon("death");
	self endon("disconnect");
	level endon("game_ended");

	
	while( self playerads() == 1 )
		wait 0.05;

	if( isThermal( self getCurrentWeapon() ) )
		self thread thermalOff( true );

	self thread watchForAdsIn();

}

watchForAdsIn()
{
	wait 0.1;

	//allow only one instance of this thread
	self notify("kill_ads_in");
	self endon("kill_ads_in");
	
	self endon("death");
	self endon("disconnect");
	level endon("game_ended");

	while( self playerads() != 1 )
		wait 0.05;

	if( isThermal( self getCurrentWeapon() ) )
	{
		self PlayLocalSound( "item_nightvision_on" );
		self thread thermalRestore();
		wait 0.1;
	}
	
	self thread watchForAdsOut();
}



initThermalArrays()
{

//bog - 		bright 0.1	contrast 1.2	cutoff 0.9
//backlotnight	bright 0.8	contrast 2.8
//convoy 		bright 0.6	contrast 1.9
//cargoship		bright 0.7	contrast 2.2

	level.thermalArray = [];
	level.thermalArray[ level.thermalArray.size + 1 ] = setThermalArray(1.0, 0.8, 2.8, "1 1 1", "1 1 1", 0.5, 1.0, 2.0); //backlot night
	level.thermalArray[ level.thermalArray.size + 1 ] = setThermalArray(1.0, 0.1, 1.2, "1 1 1", "1 1 1", 0.6, 1.0, 10.0); //bog
	level.thermalArray[ level.thermalArray.size + 1 ] = setThermalArray(1.0, 0.6, 1.9, "1 1 1", "1 1 1", 0.6, 1.0, 5.0); //convoy
	level.thermalArray[ level.thermalArray.size + 1 ] = setThermalArray(1.0, 0.7, 2.2, "1 1 1", "1 1 1", 0.6, 1.0, 5.0); //cargoship
}


setThermalArray(desaturation, brightness, contrast, lightTint, darkTint, bloomCutoff, bloomDesaturation, bloomIntensity)
{
	thermalArray = [];
	thermalArray["desaturation"] = desaturation; //0-1 default 0.2
	thermalArray["brightness"] = brightness; //-1 to 1 default 0
	thermalArray["contrast"] = contrast; //0-4 default 1.4
	thermalArray["lighttint"] = lightTint;
	thermalArray["darktint"] = darkTint;
	thermalArray["bloomcutoff"] = bloomCutoff; //0-1 default 0.5 - contrast
	thermalArray["bloomdesaturation"] = bloomDesaturation; //0-1 default 0 - glow color
	thermalArray["bloomintensity"] = bloomIntensity; //0-20 default 1 - how much glow

	return thermalArray;
}