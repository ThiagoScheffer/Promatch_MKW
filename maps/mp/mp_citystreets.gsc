main()
{
	maps\mp\_load::main();
	maps\mp\_compass::setupMiniMap("compass_map_mp_citystreets");
	VisionSetNaked( "mp_citystreets" );
	setdvar("r_lightTweakSunLight","0.78");
	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";
    setdvar("compassmaxrange","2000");

	maps\mp\_explosive_barrels::main();
   //Sacada Arco A
    level.killtriggers[0] = spawnstruct();
    level.killtriggers[0].origin = (5017, 41, 192);
    level.killtriggers[0].radius = 150;
    level.killtriggers[0].height = 150;
	
	//Spawn DEf Bloco tijos B
    level.killtriggers[1] = spawnstruct();
    level.killtriggers[1].origin = (3592, 621, 70);
    level.killtriggers[1].radius = 70;
    level.killtriggers[1].height = 40;
	
	
	//B porta casa arcos
    level.killtriggers[2] = spawnstruct();
    level.killtriggers[2].origin = (3300, -665, 80);
    level.killtriggers[2].radius = 60;
    level.killtriggers[2].height = 30;
	
   //master
    level.killtriggers[3] = spawnstruct();
    level.killtriggers[3].origin = (4481, -41, 305);
    level.killtriggers[3].radius = 30000;
    level.killtriggers[3].height = 40;
}