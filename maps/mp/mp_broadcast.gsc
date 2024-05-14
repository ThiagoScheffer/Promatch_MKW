main()
{
	maps\mp\_load::main();	
	maps\mp\_compass::setupMiniMap("compass_map_mp_broadcast");
	
	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

	setdvar("compassmaxrange","1600");
	VisionSetNaked( "mp_broadcast" );
	setdvar("r_lightTweakSunLight","1.4");
}
