#include promatch\_utils;
// Credit to Abney Park for original code
init()
{
	level endon("game_ended");
	level.scr_killtriggers = getdvarx( "scr_killtriggers", "int", 0, 0, 1 );
	
	if ( level.scr_killtriggers == 0  )
	return;
	
	LoadCustomKillstriggers();
	
	if(isdefined(level.killtriggers))
	{
		for(i = 0; i < level.killtriggers.size; i++)
		{
			killtrigger = level.killtriggers[i];
			killtrigger.origin = (killtrigger.origin[0], killtrigger.origin[1], (killtrigger.origin[2] - 16));
		}

		playerradius = 16;

		for(;;)
		{
			players = getentarray("player", "classname");
			counter = 0;
			
			for(i = 0; i < players.size; i++)
			{
				player = players[i];
				
				if(isdefined(player) && isdefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
				{
					player checkKillTriggers();
					counter++;
					
					if(!(counter % 4))
					{
						xwait (.05,false);
						counter = 0;
					}
				}
			}
			
			xwait (.07,false);
		}
	}
	//else
	//{
	// logprint("ERROR NO KILLTRIGGERS FOUND!");
	//}
}

LoadCustomKillstriggers()
{
 
	 if(level.script == "mp_dust2")
	 {
		//spawn Attack
		level.killtriggers[0] = spawnstruct();
		level.killtriggers[0].origin = (-462, -430, 230);
		level.killtriggers[0].radius = 100;
		level.killtriggers[0].height = 100;
		
		//
		level.killtriggers[1] = spawnstruct();
		level.killtriggers[1].origin = (1269, 363, 97);
		level.killtriggers[1].radius = 100;
		level.killtriggers[1].height = 100;
		
		//
		level.killtriggers[2] = spawnstruct();
		level.killtriggers[2].origin = (271, 1648, 224);
		level.killtriggers[2].radius = 100;
		level.killtriggers[2].height = 100;
		
		//
		level.killtriggers[3] = spawnstruct();
		level.killtriggers[3].origin = (391, 2764, 294);
		level.killtriggers[3].radius = 100;
		level.killtriggers[3].height = 100;
		
		//
		level.killtriggers[4] = spawnstruct();
		level.killtriggers[4].origin = (-1363, 2203, 172);
		level.killtriggers[4].radius = 100;
		level.killtriggers[4].height = 100;
	 }
	 
	  if(level.script == "mp_crossfire2")
	 {
		//spawn Attack
		level.killtriggers[0] = spawnstruct();
		level.killtriggers[0].origin = (3659, -3827, 102);
		level.killtriggers[0].radius = 100;
		level.killtriggers[0].height = 100;
		
		if(level.atualgtype == "sd")
		{
			//
			level.killtriggers[1] = spawnstruct();
			level.killtriggers[1].origin = (3603, -1241, 59);
			level.killtriggers[1].radius = 100;
			level.killtriggers[1].height = 100;
			
			//
			level.killtriggers[2] = spawnstruct();
			level.killtriggers[2].origin = (6698, -4466, 24);
			level.killtriggers[2].radius = 100;
			level.killtriggers[2].height = 100;
		}
	 }
	 
	  if(level.script == "mp_crash2")
	 {
		//spawn Attack
		level.killtriggers[0] = spawnstruct();
		level.killtriggers[0].origin = (107, 1920, 365);
		level.killtriggers[0].radius = 100;
		level.killtriggers[0].height = 100;
		
		if(level.script == "mp_crossfire2")
		{		
			//
			level.killtriggers[1] = spawnstruct();
			level.killtriggers[1].origin = (-923, 2133, 390);
			level.killtriggers[1].radius = 100;
			level.killtriggers[1].height = 100;
			
			//
			level.killtriggers[2] = spawnstruct();
			level.killtriggers[2].origin = (-846, 1478, 417);
			level.killtriggers[2].radius = 100;
			level.killtriggers[2].height = 100;
		}
	 }
}

checkKillTriggers()
{
	playerradius = 16;
	
	for(i = 0; i < level.killtriggers.size; i++)
	{
		killtrigger = level.killtriggers[i];
		diff = killtrigger.origin - self.origin;
		
		if((self.origin[2] >= killtrigger.origin[2]) && (self.origin[2] <= killtrigger.origin[2] + killtrigger.height))
		{
			diff2 = (diff[0], diff[1], 0);
			
			if(length(diff2) < killtrigger.radius + playerradius)
			{
				//self iprintln("local nao permitido!");
				iprintln( self.name + " ^1esta em um local nao permitido do mapa!");
				
				if(isDefined(self.spawnOrigin))
				self setOrigin( self.spawnOrigin);
				
				break;
			}
		}
	}
}