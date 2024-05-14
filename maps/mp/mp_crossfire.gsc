main()
{
	maps\mp\_load::main();
	maps\mp\_compass::setupMiniMap("compass_map_mp_crossfire");

	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

	VisionSetNaked( "mp_crossfire" );
	setdvar("r_lightTweakSunLight","1");

	setdvar("compassmaxrange","2100");

	//Master
	level.killtriggers[0] = spawnstruct();
    level.killtriggers[0].origin = (4265, -3116, 356);
    level.killtriggers[0].radius = 30000;
    level.killtriggers[0].height = 650;
	//spawn def - casa porta
    level.killtriggers[1] = spawnstruct();
    level.killtriggers[1].origin = (5872, -4904, -63.772);
    level.killtriggers[1].radius = 40;
    level.killtriggers[1].height = 10;
	//spawn def topcasalixeira
	level.killtriggers[2] = spawnstruct();
    level.killtriggers[2].origin = (5690, -4213, -12);
    level.killtriggers[2].radius = 20;
    level.killtriggers[2].height = 9;
	//spawn attk arcondi	
	level.killtriggers[3] = spawnstruct();
    level.killtriggers[3].origin = (3460, -1132, 180);
    level.killtriggers[3].radius = 20;
    level.killtriggers[3].height = 10;
	
	//lixeira spawn	attq
	level.killtriggers[4] = spawnstruct();
    level.killtriggers[4].origin = (3588, -1257, 61);
    level.killtriggers[4].radius = 65;
    level.killtriggers[4].height = 10;
	
	// quebrada spawn defesa
	level.killtriggers[5] = spawnstruct();
    level.killtriggers[5].origin = (6696, -4557, -44);
    level.killtriggers[5].radius = 65;
    level.killtriggers[5].height = 10;
}