main()
{
	maps\mp\_load::main();	
	maps\mp\_compass::setupMiniMap("compass_map_mp_strike");

	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

	VisionSetNaked( "mp_strike" );
	setdvar("r_lightTweakSunLight","1");
	setdvar("compassmaxrange","1900");

     //tenta  atras coca
    level.killtriggers[0] = spawnstruct();
    level.killtriggers[0].origin = (-2312, 723, 164);
    level.killtriggers[0].radius = 200;
    level.killtriggers[0].height = 40;

	//gradestop
    level.killtriggers[1] = spawnstruct();
    level.killtriggers[1].origin = (724, -112, 158);
    level.killtriggers[1].radius = 100;
    level.killtriggers[1].height = 70;
    
     //ElevadorMuroA->B
    level.killtriggers[2] = spawnstruct();
    level.killtriggers[2].origin = (237, 1136, 245);
    level.killtriggers[2].radius = 220;
    level.killtriggers[2].height = 70;
    
    //gradestop
    level.killtriggers[3] = spawnstruct();
    level.killtriggers[3].origin = (1832, 1038, 158);
    level.killtriggers[3].radius = 100;
    level.killtriggers[3].height = 70;
    
	//sacadagaragem
    level.killtriggers[4] = spawnstruct();
    level.killtriggers[4].origin = (417, 638, 236);
    level.killtriggers[4].radius = 100;
    level.killtriggers[4].height = 70;
	
	//Fonte A
    level.killtriggers[5] = spawnstruct();
    level.killtriggers[5].origin = (-1196, 1883, 200);
    level.killtriggers[5].radius = 600;
    level.killtriggers[5].height = 70;
	
	//Spawn defesa B Lixeira perto tenda do muro
    level.killtriggers[6] = spawnstruct();
    level.killtriggers[6].origin = (1824, 1453, 230);
    level.killtriggers[6].radius = 100;
    level.killtriggers[6].height = 70;
	
     //master
    level.killtriggers[7] = spawnstruct();
    level.killtriggers[7].origin = (-59, -394, 456);
    level.killtriggers[7].radius = 25000;
    level.killtriggers[7].height = 70;
}