main()
{
	maps\mp\_load::main();	
	maps\mp\_compass::setupMiniMap("compass_map_mp_bloc");
	game["allies"] = "sas";
	game["axis"] = "russian";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "woodland";
	game["axis_soldiertype"] = "woodland";
	setdvar("compassmaxrange","2000");
	VisionSetNaked( "mp_bloc" );
	setdvar("r_lightTweakSunLight","0.9");
}