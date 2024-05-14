main()
{
	maps\mp\_load::main();	
	maps\mp\_compass::setupMiniMap("compass_map_mp_crash");
	
	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";
	setdvar("compassmaxrange","1600");
	VisionSetNaked( "mp_crash" );
	
	setdvar("r_lightTweakSunLight","1.3");
	
	//Woodstop
    level.killtriggers[0] = spawnstruct();
    level.killtriggers[0].origin = (1710, 701, 700);
    level.killtriggers[0].radius = 100;
    level.killtriggers[0].height = 50;
    
    //gradestop
    level.killtriggers[1] = spawnstruct();
    level.killtriggers[1].origin = (1305, 101, 467);
    level.killtriggers[1].radius = 100;
    level.killtriggers[1].height = 90;
    
     //Kinameio
    level.killtriggers[2] = spawnstruct();
    level.killtriggers[2].origin = (504, -273, 422);
    level.killtriggers[2].radius = 120;
    level.killtriggers[2].height = 70;
    
    //SacadaSpawn
    level.killtriggers[3] = spawnstruct();
    level.killtriggers[3].origin = (-352, 1010, 447);
    level.killtriggers[3].radius = 100;
    level.killtriggers[3].height = 100;
    
     //GlitchArcos
    level.killtriggers[4] = spawnstruct();
    level.killtriggers[4].origin = (142, 698, 240);
    level.killtriggers[4].radius = 40;
    level.killtriggers[4].height = 20;
	
	//lixeira fora A
    level.killtriggers[5] = spawnstruct();
    level.killtriggers[5].origin = (1172, 1340, 230);
    level.killtriggers[5].radius = 40;
    level.killtriggers[5].height = 20;
	
	//garagem attk
	level.killtriggers[6] = spawnstruct();
    level.killtriggers[6].origin = (134.9932, 1971.44, 318);
    level.killtriggers[6].radius = 40;
    level.killtriggers[6].height = 20;
	
	//casaazul
    level.killtriggers[7] = spawnstruct();
    level.killtriggers[7].origin = (334.857, 1480.81, 210);
    level.killtriggers[7].radius = 40;
    level.killtriggers[7].height = 20;
    
    //master
    level.killtriggers[8] = spawnstruct();
    level.killtriggers[8].origin = (931, -30.6902, 755);
    level.killtriggers[8].radius = 20000;
    level.killtriggers[8].height = 70;
}
