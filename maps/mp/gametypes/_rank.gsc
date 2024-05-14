#include promatch\_utils;
init()
{
	level.scoreInfo = [];
	level.rankTable = [];
	level thread onPlayerConnect();
}
endGameUpdate()
{
	player = self;			
}

registerScoreInfo( type, value )
{
	level.scoreInfo[type]["value"] = value;
}

getScoreInfoValue( type )
{
	return ( level.scoreInfo[type]["value"] );
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		player.rankUpdateTotal = 0;
		player thread onPlayerSpawned();
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
	}
}

onJoinedTeam()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_team");
		self thread removeRankHUD();
	}
}

onJoinedSpectators()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("joined_spectators");
		self thread removeRankHUD();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");

		if(!isdefined(self.hud_rankscroreupdate))
		{
			self.hud_rankscroreupdate = newClientHudElem(self);
			self.hud_rankscroreupdate.horzAlign = "center";
			self.hud_rankscroreupdate.vertAlign = "middle";
			self.hud_rankscroreupdate.alignX = "center";
			self.hud_rankscroreupdate.alignY = "middle";
	 		self.hud_rankscroreupdate.x = 0;
			self.hud_rankscroreupdate.y = -60;
			self.hud_rankscroreupdate.font = "default";
			self.hud_rankscroreupdate.fontscale = 2.0;
			self.hud_rankscroreupdate.archived = false;
			self.hud_rankscroreupdate.color = (0.5,0.5,0.5);
			self.hud_rankscroreupdate maps\mp\gametypes\_hud::fontPulseInit();
		}
		
		self thread FogFix();
	}
}

//strike2 forca luz e fog?
FogFix()
{
	self endon ( "disconnect" );
	wait 5;
	self setClientDvar( "r_fog", 0 );
}


giveRankXP( type, value )
{
	self endon("disconnect");

	if ( !isDefined( value ) )
		value = getScoreInfoValue( type );
	
	switch( type )
	{
		case "killedwithbomb":
		case "kill":
		case "headshot":
		case "melee": 		
		case "grenade": 
		case "vehicleexplosion": 
		case "barrelexplosion":    	
		case "c4":    	
		case "claymore":
		case "rpg":
		case "grenadelauncher":
		case "airstrike":
		case "helicopter":
		case "assist": 
		case "assist_25": 
		case "assist_50": 
		case "assist_75": 
		case "suicide":
		case "teamkill":
		case "hardpoint":
		case "helicopterdown":			
		case "helicopterdown_rpg":			
		case "capture":
		case "return":
		case "defend":
		case "assault":
		case "plant":
		case "defuse":
		case "pickup":
		break;
	}
	
/*
if ( level.numLives >= 1 && level.rankedMatch )
{
multiplier = max(1,int( 10/level.numLives ));
value = int(value * multiplier);
}
*/
	
	if(isDefined(level.doublexp))
	{
		if(level.doublexp == true && level.players.size >= 6)
			value = int(value * 2);
	}
	
	if(level.oldschool)
	{
		value = int(value * 2);
	}
		
	if ( type == "teamkill" )
		self thread updateRankScoreHUD(-3000);
	else if(isDefined(self.squad))
	{
		//atualiza na minha tela no centro!
		self thread updateRankScoreHUD( value);
		//compartilha para o squad no mesmo lado
		self thread GiveToSquadsXP( value);
		//me da os XP para minha classe atual
		//self thread updateclassscore(value,false);//posso mesmo usar thread?
	}
	
		
		
	//para outros jogadores que nao sao SQUAD
	if(!isDefined(self.squad))
	{
		self thread updateRankScoreHUD( value);
		//self thread updateclassscore(value,false);
	}
}

GiveToSquadsXP(value)
{
	self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );

	//metade do XP para todos
	if(value > 1)
	{
		if(value > 200)
		amount = int(value * 0.2);
		else
		amount = int(value * 0.5);
	}
	else 
	{
		amount = int(value * 5);
	}
	
	squad = self.squad;
	
	//para todos os squads no server listar
	for( i = 0; i < game[ squad ].size; i++ ) 
	{
		//squad_member1 = u
		for( member = 0; member < level.maxSquadSize; member++ ) 
		{
			if( !isDefined( game[ squad ][ member ] ) ) 
			continue;
			
			if(!isDefined(game[ squad ][ member ].squad))
			continue;
			
			if(!isAlive(game[ squad ][ member ]))
			continue;
						
			//squad nao eh o mesmo meu
			if(game[ squad ][ member ].squad != self.squad)
			continue;
			
			//squad nao esta no mesmo time meu
			if(game[ squad ][ member ].pers["team"] != self.pers["team"])
			continue;			
			
			//me ignorar para nao repetir xp
			if(game[ squad ][ member ] == self)
			continue;

			if(isDefined(game[ squad ][ member ].squadxpgiven))
			continue;
			
			//allies
			//iprintln(game[ squad ][ member ].pers["team"]);
			//squad_a
			//iprintln(game[ squad ][ member ].squad);
			//meunick
			//iprintln(game[ squad ][ member ]);
			
			//game[ squad ][ member ] thread updatesquadscore(amount,true);
		}
	}
}

updatesquadscore(value,showmsg)
{
	self endon( "disconnect" );
	
	if(level.cod_mode == "torneio")
	return;
	
	if(!isdefined(self.atualClass))
	return;

	if(level.players.size < 4)
	return;
	
	self.squadxpgiven = true;
	
	squad = self.squad;	
	value = value * game[ squad ].size;
		
	if(showmsg)
	self iprintln("^3##Voce recebeu SquadXP de ^1" + value + " ^3XP##");
	
	self statAdds("SCORE",(value));

	wait 1;
	
	self.squadxpgiven = undefined;
}

updateRankScoreHUD( amount )
{
	self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );

	if ( !amount )
		return;

	self notify( "update_score" );
	self endon( "update_score" );

	self.rankUpdateTotal += amount;
	
	wait level.oneframe;

	if( isDefined( self.hud_rankscroreupdate ) )
	{
		if ( self.rankUpdateTotal < 0 )
		{
			self.hud_rankscroreupdate.label = &"";
			self.hud_rankscroreupdate.color = (1,0,0);
		}
		else
		{
			//iprintln("RankXP: "+ self.rankUpdateTotal);
			self.hud_rankscroreupdate.label = &"MP_PLUS";
			self.hud_rankscroreupdate.color = (1,1,0.5);
		}

		self.hud_rankscroreupdate setValue(self.rankUpdateTotal);
		self.hud_rankscroreupdate.alpha = 0.85;
		self.hud_rankscroreupdate thread maps\mp\gametypes\_hud::fontPulse( self );
		xwait (1,false);
		self.hud_rankscroreupdate fadeOverTime( 0.75 );
		self.hud_rankscroreupdate.alpha = 0;

		self.rankUpdateTotal = 0;
	}
}

removeRankHUD()
{
	if(isDefined(self.hud_rankscroreupdate))
		self.hud_rankscroreupdate.alpha = 0;
}