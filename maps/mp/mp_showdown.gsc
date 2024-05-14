main()
{
	maps\mp\_load::main();
	maps\mp\_compass::setupMiniMap("compass_map_mp_showdown");

	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";
	
	VisionSetNaked( "mp_showdown" );
	setdvar("r_lightTweakSunLight","1.6");
	
	setdvar("compassmaxrange","2000");
}