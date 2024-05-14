main()
{
	maps\mp\_load::main();
	maps\mp\_compass::setupMiniMap("compass_map_mp_countdown");

	game["allies"] = "sas";
	game["axis"] = "russian";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "woodland";
	game["axis_soldiertype"] = "woodland";
	
	VisionSetNaked( "mp_countdown" );
	setdvar("r_lightTweakSunLight","1.5");
	
	setdvar("compassmaxrange","2000");
}