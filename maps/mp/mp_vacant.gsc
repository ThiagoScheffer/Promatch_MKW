main()
{
	maps\mp\_load::main();	
	maps\mp\_compass::setupMiniMap("compass_map_mp_vacant");
	
	game["allies"] = "sas";
	game["axis"] = "russian";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "woodland";
	game["axis_soldiertype"] = "woodland";

	//master
    level.killtriggers[0] = spawnstruct();
    level.killtriggers[0].origin = (307, -47.125, 126.125);
    level.killtriggers[0].radius =30000;
    level.killtriggers[0].height = 190;
	
	//lixeira fora A
    level.killtriggers[1] = spawnstruct();
    level.killtriggers[1].origin = (335, -898, 75);
    level.killtriggers[1].radius = 60;
    level.killtriggers[1].height = 20;
	
	VisionSetNaked( "mp_vacant" );
	setdvar("r_lightTweakSunLight","1.3");
	setdvar("compassmaxrange","1500");
}
