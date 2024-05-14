#include maps\mp\_utility;
#include common_scripts\utility;

main()
{
	VisionSetNaked( "mp_creek", 0 );
	maps\mp\_load::main();	
	maps\mp\_compass::setupMiniMap("compass_map_mp_creek");
	
	game["allies"] = "sas";
	game["axis"] = "russian";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "woodland";
	game["axis_soldiertype"] = "woodland";
	setdvar("r_lightTweakSunLight","1.5");
}