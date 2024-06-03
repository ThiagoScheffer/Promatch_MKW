#include promatch\_eventmanager;
#include promatch\_utils;
#include promatch\_spreestreaks;
//from old promatch code
//updated v221115
init()
{
	//desativado temporariamente
	//if (level.cod_mode == "public")
	//	return;

	killingSprees = getdvarx( "scr_killingspree_sounds", "string", "2 doublekill;3 triplekill; 5 killingspree;7 rampage;9 dominating;12 unstoppable;25 monsterkill" );
	killingSprees = strtok( killingSprees, ";" );
	level.scr_killingspree_kills = [];
	level.scr_killingspree_sounds = [];
	
	for ( iSpree = 0; iSpree < killingSprees.size; iSpree++ ) 
	{
		thisSpree = strtok( killingSprees[ iSpree ], " " );
		level.scr_killingspree_kills[ iSpree ] = int( thisSpree[0] );
		level.scr_killingspree_sounds[ iSpree ] = thisSpree[1];
	}
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
	//level thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}


onPlayerConnected()
{
	self thread onPlayerKillStreak();
	self.OneManArmy = undefined;
	//self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}

//so funciona 1 vez no spawn - nao tem looping
onPlayerSpawned()
{

}

//GetTeamPlayersAlive( <team> )
onPlayerKillStreak()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	//if(isdefined(self.pcdaxuxa) && self.pcdaxuxa)
	//return;
	
	if(level.cod_mode == "torneio")
	return;
	
	for( ;; )
	{
		self waittill( "kill_streak", killStreak, streakGiven, sMeansOfDeath,victim,sWeapon);
		playedSound = false;
		playedSoundKills = false;
		
		/*if(streakGiven && level.atualgtype != "war" && self.class == "xxx")
		{
			if(self.upgradeberserk >= 8)
			{
				if(killStreak == self.upgradeberserk)
				self thread promatch\_spreestreaks::berserkmode();
			}		
		}*/
		
		//FIRST BLOOD - ok
		if( (level.atualgtype != "dm" || level.atualgtype != "tjn") && !playedSound && !isDefined( level.firstBlood ) && level.players.size >= 6)
		{
			playedSound = true;
			level.firstBlood = true;
			level thread playSoundOnEveryone( "firstblood","^1First Blood",victim);
			self GiveEVP(25,100);
			self statAdds("FIRSTBLOOD",1);
			
			self.enemyteamwasalive = getteamplayersalive(level.otherTeam[ self.pers["team"] ]) + 1;///adiciona 1 pois morreu ao iniciar este codigo? -> firstblood ?
		}
		//FIRST BLOOD only for DM - ok
		if(level.atualgtype == "dm" && !playedSound && !isDefined( level.firstBlood ))
		{
			playedSound = true;
			level.firstBlood = true;
			level thread playSoundOnEveryone( "firstblood","^1First Blood",victim);
			
			continue;
		}		
		
		
		if(!playedSound && sMeansOfDeath == "MOD_HEAD_SHOT" && level.players.size >= 4 )//any gametype
		{
			playedSound = true;
			self playLocalSound( "headshot" );
			
			continue;
		}

		if(level.atualgtype == "sd")
		{
				
			//KILLING SPREE NORMAL SD - apenas para rankeado
			if( self.isRanked && streakGiven && !playedSoundKills && level.players.size >= 8)
			{
				killingSpree = 0;
				
				///adiciona 1 pois morreu ao iniciar este codigo? -> firstblood ?
				if(!isDefined(self.enemyteamwasalive))
				self.enemyteamwasalive = getteamplayersalive(level.otherTeam[ self.pers["team"] ]) + 1;
				
				ShowDebug(self.enemyteamwasalive,self.enemyteamwasalive);
				
				while( killingSpree < level.scr_killingspree_kills.size && level.scr_killingspree_kills[ killingSpree ] != killStreak )
				killingSpree++;			

				if( killingSpree < level.scr_killingspree_kills.size ) 
				{					
					
					if(!self.incognito)
					iprintln("^1"+self.name + " ^2 " +level.scr_killingspree_sounds[ killingSpree ] );
					
					if(level.scr_killingspree_sounds[ killingSpree ] == "triplekill")
					self GiveEVP(15,100);
					
					//ShowDebug("killingSpree: ",killingSpree);
					
					if(level.scr_killingspree_sounds[ killingSpree ] == "killingspree")//5
					{
						if(self.enemyteamwasalive == 5 && !isDefined( level.acedone ))
						{
							level thread promatch\_killingspree::playSoundOnEveryone( "acekill","^1ACE ",self.name + " Jogou bonito !");				
							playedSound = true;
							level.acedone = true;
							self GiveEVP(350,100);
							self SetRankPoints(200);
							
						}
					}
					
					if(level.scr_killingspree_sounds[ killingSpree ] == "rampage")//7
					{
						if(self.enemyteamwasalive == 7 && !isDefined( level.acedone ))
						{
							level thread promatch\_killingspree::playSoundOnEveryone( "acekill","^1DIE HARD ACE ",self.name + " Matou todos!!!");				
							playedSound = true;
							level.acedone = true;
							self GiveEVP(500,100);
							self SetRankPoints(500);
							self statAdds("RAMPAGES",1);
						}
					};
					
					if(level.scr_killingspree_sounds[ killingSpree ] == "dominating")//9
					{
						if(self.enemyteamwasalive == 9 && !isDefined( level.acedone ))
						{
							level thread promatch\_killingspree::playSoundOnEveryone( "acekill","^1HARD ACE ",self.name + " Arruinou o jogo de todos!!!");				
							playedSound = true;
							level.acedone = true;
							self GiveEVP(700,100);
							self SetRankPoints(2000);
						}
					}
					
					if(level.scr_killingspree_sounds[ killingSpree ] == "monsterkill")//12
					{
						if(self.enemyteamwasalive >= 12 && !isDefined( level.acedone ))
						{
							level thread promatch\_killingspree::playSoundOnEveryone( "acekill","^1IMPOSSIBLE ACE ",self.name + " IMORTAL !!!");				
							playedSound = true;
							level.acedone = true;
							self GiveEVP(1500,100);
							self SetRankPoints(1000);
						}
					}
					
					self playLocalSound( level.scr_killingspree_sounds[ killingSpree ] );
					playedSoundKills = true;
				}
			}
			//ignora o resto que nao precisa..
			continue;
		}
		
		//KILLING SPREE NORMAL
		if( streakGiven && !playedSoundKills && level.players.size >= 8 && level.atualgtype != "dm" && level.atualgtype != "sd") //only if there is 4x4 alive in the match
		{
			killingSpree = 0;
			while( killingSpree < level.scr_killingspree_kills.size && level.scr_killingspree_kills[ killingSpree ] != killStreak )
				killingSpree++;			
			
			if( killingSpree < level.scr_killingspree_kills.size ) 
			{
				self playLocalSound( level.scr_killingspree_sounds[ killingSpree ] );
				playedSoundKills = true;
				
				if(!self.incognito)
				iprintln("^1"+self.name + " ^2 " +level.scr_killingspree_sounds[ killingSpree ] );

			
				if(level.scr_killingspree_sounds[ killingSpree ] == "triplekill")
				self GiveEVP(30,100);
				
				if(level.scr_killingspree_sounds[ killingSpree ] == "killingspree")
				self GiveEVP(40,100);
				
				if(level.scr_killingspree_sounds[ killingSpree ] == "rampage")
				self GiveEVP(50,100);
				
				if(level.scr_killingspree_sounds[ killingSpree ] == "dominating")
				self GiveEVP(60,100);
				
				if(level.scr_killingspree_sounds[ killingSpree ] == "monsterkill")
				self GiveEVP(70,100);
			}
		}
			
		//DM than play this.
		if( streakGiven && !playedSound && level.atualgtype == "dm")
		{
			killingSpree = 0;
			while( killingSpree < level.scr_killingspree_kills.size && level.scr_killingspree_kills[ killingSpree ] != killStreak )
				killingSpree++;
			if( killingSpree < level.scr_killingspree_kills.size ) 
			{
				self playLocalSound( level.scr_killingspree_sounds[ killingSpree ] );
				playedSound = true;
				iprintln("^1"+self.name + " ^2 " +level.scr_killingspree_sounds[ killingSpree ] );
				
				if(level.players.size >= 5)
				{
					if(level.scr_killingspree_sounds[ killingSpree ] == "triplekill")
					self GiveEVP(40,100);

					if(level.scr_killingspree_sounds[ killingSpree ] == "killingspree")
					self GiveEVP(60,100);

					if(level.scr_killingspree_sounds[ killingSpree ] == "rampage")
					self GiveEVP(80,100);

					if(level.scr_killingspree_sounds[ killingSpree ] == "dominating")
					self GiveEVP(150,100);

					if(level.scr_killingspree_sounds[ killingSpree ] == "monsterkill")
					self GiveEVP(250,100);
				}
			}
		}	
	}
}




/*
CountPlayers()
{
	//chad
	players = level.players;
	allies = 0;
	axis = 0;
	for(i = 0; i < players.size; i++)
	{
		if ( players[i] == self )
			continue;

		if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
			allies++;
		else if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "axis"))
			axis++;
	}
	players["allies"] = allies;
	players["axis"] = axis;
	return players;
}
*/
getAllOtherPlayers(myteam)
{
	aliveplayers = [];

	// Make a list of fully connected, non-spectating, alive players
	for(i = 0; i < level.players.size; i++)
	{
		if ( !isdefined( level.players[i] ) )
		continue;
		
		player = level.players[i];

		//ignorar meu time ?
		if ( player.sessionstate != "playing" || player == self || player.pers["team"] == myteam )
		continue;

		aliveplayers[aliveplayers.size] = player;
	}
	
	return aliveplayers;//retorna apenas os vivos do time inimigo?
}

playSoundOnEveryone( soundName,msg,killer )
{
	level endon( "game_ended" );
	
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		player playLocalSound( soundName );
		if(msg != "")
		player thread maps\mp\gametypes\_hud_message::oldNotifyMessage( msg, killer, undefined, (1, 0, 0), undefined );		
	}	
}


