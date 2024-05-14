main()
{
	maps\mp\_load::main();
	maps\mp\_compass::setupMiniMap("compass_map_mp_overgrown");

	game["allies"] = "sas";
	game["axis"] = "russian";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "woodland";
	game["axis_soldiertype"] = "woodland";
	VisionSetNaked( "mp_overgrow" );
	setdvar("r_lightTweakSunLight","1.1");
	setdvar("compassmaxrange","2200");
}