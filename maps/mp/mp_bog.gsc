main()
{
	maps\mp\_load::main();
	maps\mp\_compass::setupMiniMap("compass_map_mp_bog");

	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";
	setdvar("compassmaxrange","1800");
	VisionSetNaked( "mp_bog" );
	setdvar("r_lightTweakSunLight","0.8");
}