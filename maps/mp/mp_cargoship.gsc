main()
{
	maps\mp\_load::main();	
	maps\mp\_compass::setupMiniMap("compass_map_mp_cargoship");
	
	game["allies"] = "sas";
	game["axis"] = "russian";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "woodland";
	game["axis_soldiertype"] = "woodland";
	setdvar("compassmaxrange","2100");
	
	VisionSetNaked( "mp_cargoship" );
	setdvar("r_lightTweakSunLight","1.3");

}
