main()
{
	maps\mp\_load::main();
	maps\mp\_compass::setupMiniMap("compass_map_mp_carentan");
	
	game["allies"] = "sas";
	game["axis"] = "russian";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "urban";
	game["axis_soldiertype"] = "urban";
	VisionSetNaked( "mp_carentan" );
	setdvar("r_lightTweakSunLight","0.75");
	
}


