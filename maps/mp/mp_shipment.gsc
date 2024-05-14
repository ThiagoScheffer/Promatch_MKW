main()
{
	maps\mp\_load::main();	
	maps\mp\_compass::setupMiniMap("compass_map_mp_shipment");
	
	game["allies"] = "sas";
	game["axis"] = "russian";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "woodland";
	game["axis_soldiertype"] = "woodland";

	VisionSetNaked( "mp_shipment" );
	setdvar("r_lightTweakSunLight","1.3");
	setdvar("compassmaxrange","1400");

}
