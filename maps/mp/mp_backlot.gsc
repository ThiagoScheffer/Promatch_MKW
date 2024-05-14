main()
{

	maps\mp\_load::main();	
	maps\mp\_compass::setupMiniMap("compass_map_mp_backlot");

	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

	//setdvar( "r_specularcolorscale", "1" );
	//setdvar("r_glowbloomintensity0",".25");
	//setdvar("r_glowbloomintensity1",".25");
	//setdvar("r_glowskybleedintensity0",".3");
	setdvar("compassmaxrange","1800");
	VisionSetNaked( "mp_backlot" );
	setdvar("r_lightTweakSunLight","1.3");
    //SacadSpawn
    level.killtriggers[0] = spawnstruct();
    level.killtriggers[0].origin = (-383, -1125, 280);
    level.killtriggers[0].radius = 100;
    level.killtriggers[0].height = 100;
    //Poste T
    level.killtriggers[1] = spawnstruct();
    level.killtriggers[1].origin = (577, -814, 405);
    level.killtriggers[1].radius = 100;
    level.killtriggers[1].height = 100;
    
     //BugCasaLatao
    level.killtriggers[2] = spawnstruct();
    level.killtriggers[2].origin = (221, 285, 300);
    level.killtriggers[2].radius = 130;
    level.killtriggers[2].height = 30;
    
    //Bugscadas
    level.killtriggers[3] = spawnstruct();
    level.killtriggers[3].origin = (-828, -569, 22);
    level.killtriggers[3].radius = 30;
    level.killtriggers[3].height = 30;
    
           
    //Bugscadasspawn
    level.killtriggers[4] = spawnstruct();
    level.killtriggers[4].origin = (340, 1415, 300);
    level.killtriggers[4].radius = 60;
    level.killtriggers[4].height = 60;
    
    
     //B Glitchunderstair
    level.killtriggers[5] = spawnstruct();
    level.killtriggers[5].origin = (1857, 473, 80);
    level.killtriggers[5].radius = 40;
    level.killtriggers[5].height = 40;
	
	//B ElevCasakebradescada murinho escada
    level.killtriggers[6] = spawnstruct();
    level.killtriggers[6].origin = (1443, -553, 250);
    level.killtriggers[6].radius = 40;
    level.killtriggers[6].height = 40;
	
	//B encima quebrada
    level.killtriggers[7] = spawnstruct();
    level.killtriggers[7].origin = (1525, 414, 540);
    level.killtriggers[7].radius = 300;
    level.killtriggers[7].height = 20;
	//encima casa lmg
    level.killtriggers[8] = spawnstruct();
    level.killtriggers[8].origin = (798, -1496, 316);
    level.killtriggers[8].radius = 400;
    level.killtriggers[8].height = 20;
	
	//NovoElevadorpocoA
    level.killtriggers[9] = spawnstruct();
    level.killtriggers[9].origin = (-771, -537, 457);
    level.killtriggers[9].radius = 100;
    level.killtriggers[9].height = 100;
    
	//Master
    level.killtriggers[10] = spawnstruct();
    level.killtriggers[10].origin = (-417, -1080, 474);
    level.killtriggers[10].radius = 30000;
    level.killtriggers[10].height = 20;
}