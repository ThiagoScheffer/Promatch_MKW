main()
{
	maps\mp\_load::main();
	maps\mp\_compass::setupMiniMap("compass_map_mp_crash_snow");

	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

	VisionSetNaked( "mp_crash_snow" );
	setdvar("r_lightTweakSunLight","0.25");

	setdvar("compassmaxrange","1600");
	
	//Woodstop
    level.killtriggers[0] = spawnstruct();
    level.killtriggers[0].origin = (100, 1968, 380);
    level.killtriggers[0].radius = 100;
    level.killtriggers[0].height = 50;
    
    //gradestop
    level.killtriggers[1] = spawnstruct();
    level.killtriggers[1].origin = (931, -30.6902, 745);
    level.killtriggers[1].radius = 20000;
    level.killtriggers[1].height = 70;
}
