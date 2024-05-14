#include promatch\_eventmanager;
#include promatch\_utils;
#include promatch\_spreestreaks;
init()
{
	// Get the main module's dvar
	level.scr_realtime_stats_enable = getdvarx( "scr_realtime_stats_enable", "int", 1, 0, 1 );

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
	level.scr_realtime_stats_default_on = getdvarx( "scr_realtime_stats_default_on", "int", 0, 0, 1 );
	
	level.valekills = true;
	
}


onPlayerConnected()
{
	// Make sure the initialization happens only at the beginning of the map
	if ( !isDefined( self.pers["stats"] ) ) 
	{
		
		// Initialize variables to keep stats
		self.pers["stats"] = [];
		self.pers["stats"]["show"] = level.scr_realtime_stats_default_on;
		
		// Kills
		self.pers["stats"]["kills"] = [];
		self.pers["stats"]["kills"]["total"] = 0;
		self.pers["stats"]["kills"]["teamkills"] = 0;
		self.pers["stats"]["kills"]["consecutive"] = 0;
		self.pers["stats"]["kills"]["killstreak"] = 0;
		self.pers["stats"]["kills"]["knife"] = 0;
		self.pers["stats"]["kills"]["headshots"] = 0;
		//NOVOS
		self.pers["stats"]["kills"]["bulletStreak"] = 0;
		self.pers["stats"]["kills"]["lastBulletKillTime"] = 0;
		self.pers["stats"]["kills"]["vengeance"] = 0;
		
		// Deaths
		self.pers["stats"]["deaths"] = [];
		self.pers["stats"]["deaths"]["total"] = 0;
		self.pers["stats"]["deaths"]["consecutive"] = 0;
		self.pers["stats"]["deaths"]["deathstreak"] = 0;
			
	}
	
	//if ( level.gametype == "sd")
	self thread onPlayerKilled();

	if ( level.gametype == "sd")
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}

//so 1x ao dar spawn por round
onPlayerSpawned()
{
	if ( isDefined( self.pers["isBot"] ) && self.pers["isBot"] )
	return;

	if(level.cod_mode == "public")
	self thread achievements();	
}



 

//ideia eh marcar os jogadores que estao mais presentes no mod.
proplayerhud( stringOne, stringTwo )
{
	notifyData = spawnStruct();
	notifyData.titleText = stringOne;
	notifyData.sound = "challengecomplete_metal";
	notifyData.duration = 7.0;
	notifyData.notifyText = stringTwo;
	notifyData.textIsString = true;
	self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}

playSoundOnEveryone( soundName,msg,killer )
{
	level endon( "game_ended" );
	
	if(level.cod_mode == "torneio")
	return;
	
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		player playLocalSound( soundName );
		if(level.aliveCount["allies"] >= 2 && level.aliveCount["axis"] >= 2)
		{
			if(msg != "")
			player thread maps\mp\gametypes\_hud_message::oldNotifyMessage( msg, killer, undefined, (1, 0, 0), undefined );		
		}
	}	
}

MortesMSG(sMeansOfDeath,sWeapon,iDamage)
{
	//so aparece para quem nao esta oculto - self = quem morreu
	if(isdefined(self.incognito) && !self.incognito)
	{
		if (issubstr( sMeansOfDeath, "MOD_GRENADE_SPLASH" ) )
		{
			msgint =  randomIntRange( 1,8);
			if(msgint == 1)
			iprintln(self.name + " tentou por o pino da granada novamente...");
			if(msgint == 2)
			iprintln(self.name + " descobriu a area da explosao.");
			if(msgint == 3)
			iprintln(self.name + " se explodiu de tesao.");
			if(msgint == 4)
			iprintln(self.name + " estourou o ventil.");
			if(msgint == 5)
			iprintln(self.name + " pisou num bostao explosivo.");
			if(msgint == 6)
			iprintln(self.name + " queimou a rosca.");
			if(msgint == 7)
			iprintln(self.name + " pressionou a bola do inimigo.");
			if(msgint == 8)
			iprintln(self.name + " pressionou a bola do inimigo.");
		}
		
		if ( sMeansOfDeath == "MOD_CRUSH" )
		{
			msgint =  randomIntRange( 1,8);
			if(msgint == 1)
			iprintln(self.name + " foi explodido...");
			if(msgint == 2)
			iprintln(self.name + " derreteu a bunda!");
			if(msgint == 3)
			iprintln(self.name + " foi carbonizado");
		}
	
		if ( sMeansOfDeath == "MOD_FALLING" )
		{
			msgint =  randomIntRange( 1,15);
			if(msgint == 1)
			iprintln(self.name + " virou cadeirante!");
			if(msgint == 2)
			iprintln(self.name + " quebrou a unha e teve uma severa hemorragia...");
			if(msgint == 3)
			iprintln(self.name + " caiu do penhasco.");
			if(msgint == 4)
			iprintln(self.name + " queria virar alejado.");
			if(msgint == 5)
			iprintln(self.name + " piso falso?");
			if(msgint == 6)
			iprintln(self.name + " nao olha por onde morre ?");
			if(msgint == 7)
			iprintln(self.name + " agonia de se cagar ao morrer...tao bela");
			if(msgint == 8)
			iprintln(self.name + " esperou o SUS...morreu ali mesmo.");
		}
		
		if (iDamage >= 240 && sMeansOfDeath != "MOD_HEAD_SHOT" && sMeansOfDeath != "MOD_SUICIDE")
		{
			msgint =  randomIntRange( 1,15);
			if(msgint == 1)
			iprintln(self.name + " foi perfurado...sem penetracao?");
			if(msgint == 2)
			iprintln(self.name + " morreu como um pato.");
			if(msgint == 3)
			iprintln(self.name + " perdeu as pregas.");
			if(msgint == 4)
			iprintln("Abateram a marreca " + self.name);
			if(msgint == 5)
			iprintln(self.name + " tomou so uma...com forca");
			if(msgint == 6)
			iprintln(self.name + "  morreu tomando um fincao...");
			if(msgint == 7)
			iprintln(self.name + "  eh apenas um alvo de pratica...");
			if(msgint == 8)
			iprintln(self.name + "  cada dia da mais pontos ao seus adversarios...");
			if(msgint == 9)
			iprintln(self.name + "  eh um bundao!");
			if(msgint == 10)
			iprintln(self.name + "  adora morrer para os snipers.");
		}
	

	}
}

onPlayerKilled()
{
	self endon("disconnect");
	level endon( "game_ended" );
	
	if(level.cod_mode == "torneio") return;
	
	for (;;) 
	{
		self waittill( "player_killed", eInflictor, attacker,iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, fDistance);

		if(level.players.size < 3)
		continue;
		
		
		
		if(!isDefined(self.class))
		return;
		
		if(!isDefined(attacker.class))
		return;
		
		if(isDefined(self.pcdaxuxa) && !self.pcdaxuxa)
		self thread MortesMSG(sMeansOfDeath,sWeapon,iDamage);
		
		
		savedtime = gettime();
		attacker.lastKilledPlayer = self;
		attacker.lastKillTime =  savedtime;
		self.lastKilledBy = attacker;
		victim = self;
		
		// Handle the stats for the victim 
		self.pers["stats"]["kills"]["consecutive"] = 0;
		self.pers["stats"]["deaths"]["total"] += 1;
				
		//nao mover daqui!!
		if(level.valekills && level.atualgtype != "kc")
		self statAdds("DEATHS", 1);//DEATH

	
		//====APENAS PONTOS PARA O ATTACKER===
		if ( isPlayer( attacker ) && attacker != self ) 
		{
			// Check if it was a team kill (team kills don't count towards K/D ratio or total kills, headshots, distances, etc)
			if ( level.cod_mode == "public" && sWeapon != "gl_mp" && level.teambased && isPlayer( attacker ) && attacker.pers["team"] == self.pers["team"] ) 
			{
				attacker.pers["stats"]["kills"]["teamkills"] += 1;
				attacker SetRankPoints(victim.pers["rank"] * -10);
				continue;				
			} 
			else 
			{
				if(attacker.pers["team"] == self.pers["team"]) continue;
				
				//iprintln("DENTRO DO KILLED");
				attacker.pers["stats"]["deaths"]["total"] = 0;
				attacker.pers["stats"]["kills"]["consecutive"] += 1;
			
				if ( sWeapon == "gl_mp"  && sMeansOfDeath == "MOD_EXPLOSIVE")
				{
					//attacker updateclassscore(400,true);
					attacker GiveEVP(20,100);
					continue;
				}
				
				if ( sMeansOfDeath == "MOD_RIFLE_BULLET"  || sMeansOfDeath == "MOD_HEAD_SHOT" || sMeansOfDeath == "MOD_GRENADE_SPLASH"  )
				{
				//	iprintln("^1lasttime: " + attacker.pers["stats"]["kills"]["lastBulletKillTime"]);
					//iprintln("savedtime: " + savedtime);
					
					if(attacker.pers["stats"]["kills"]["lastBulletKillTime"] == savedtime)
					attacker.pers["stats"]["kills"]["bulletStreak"]++;
				else
					attacker.pers["stats"]["kills"]["bulletStreak"] = 1;
				
					attacker.pers["stats"]["kills"]["lastBulletKillTime"] = savedtime;//REGRAVA
				}
				
				//EU QUE MORRI E SOU O MELHOR DO TIME;
				if ( level.gametype == "sd" && isHighestScoringPlayer( self ) && level.aliveCount["allies"] >= 2 && level.aliveCount["axis"] >= 2)
				{
					//ATTACKER ME MATOU !
					level thread playSoundOnEveryone( "ownage","Melhor Oponente", attacker.name +" acabou com o jogo do " + self.name);					
					
					//attacker updateclassscore(1000,true);
					attacker GiveEVP(40,100);
					attacker statAdds("OWNAGES", 1);
					
					attacker SetRankPoints(self.pers["rank"] * 8);					
					
					self SetRankPoints(attacker.pers["rank"] * -8);
					
				}
			
				
				if ( sMeansOfDeath == "MOD_RIFLE_BULLET" && attacker.pers["stats"]["kills"]["bulletStreak"] == 3 )
				{
					////TRIPLE INSTANT KILL
					
					attacker.pers["stats"]["kills"]["bulletStreak"] = 0;
					level thread playSoundOnEveryone( "triplekill","Colateral Hack", attacker.name +" ^1Absurdo....3 em 1 !!");	
					//attacker updateclassscore(500,true);
					attacker GiveEVP(20,100);
					attacker SetRankPoints(victim.pers["rank"] * 1);
					attacker statAdds("KILL_STREAK", 3);//KILL					
				}
				//DOUBLE INSTANT KILL
				if ( sMeansOfDeath == "MOD_RIFLE_BULLET" && attacker.pers["stats"]["kills"]["bulletStreak"] == 2 )
				{
					if(sMeansOfDeath == "MOD_HEAD_SHOT")
					attacker GiveEVP(20,100);
					else
					attacker GiveEVP(10,100);
					
					attacker SetRankPoints(victim.pers["rank"] * 1);
					
					level thread playSoundOnEveryone( "instantdouble","Colateral Shit", attacker.name +" ^1Instant MultiKill !!");	
					attacker statAdds("KILL_STREAK", 2);//KILL
				} 
				//quando for granadas por aqui
				if( sMeansOfDeath == "MOD_GRENADE_SPLASH")
				{
					if(attacker.pers["stats"]["kills"]["bulletStreak"] == 3)
					{
						level thread playSoundOnEveryone( "wickedsick","^1Boliche ",attacker.name + " matou todos em um Strike!");
						attacker GiveEVP(15,100);
						attacker.pers["stats"]["kills"]["bulletStreak"] = 0;
						attacker SetRankPoints(victim.pers["rank"] * 1);
					}
					
					if(attacker.pers["stats"]["kills"]["bulletStreak"] == 2 && int(fDistance) >= 800)
					{
						level thread playSoundOnEveryone( "wickedsick","Basqueteiro", attacker.name + " acertou na mosca!");
						//attacker updateclassscore(130,true);
						attacker GiveEVP(10,100);
					}
					
					//morreu na explosao do decoy
					if(sWeapon == "decoy_grenade_mp")
					{
						//playedSound = true;
						level thread playSoundOnEveryone( "humiliation","Otario",self.name + " sentou no pepinao explosivo " + attacker.name);

						//Humiliation
						//attacker updateclassscore(500,true);
						attacker GiveEVP(10,100);
						//self updateclassscore(-50,true);
						
						self SetRankPoints(attacker.pers["rank"] * -2);
						
						attacker statAdds("HUMILIATIONS", 1);
						
					}					
				}
				
				//saw_acog - bow	
				if ( sWeapon == "winchester1200_grip_mp" && sMeansOfDeath == "MOD_IMPACT" && int(fDistance) >= 860)
				{					
					level thread playSoundOnEveryone( "humiliation","^3Slug Cheater", attacker.name +" ^1Winchester Master !!!");	
					attacker statAdds("HUMILIATIONS", 4);//Humili
				}
				
				if ( sWeapon == "saw_acog" && int(fDistance) >= 860)
				{					
					level thread playSoundOnEveryone( "humiliation","^3Tribal Killer", attacker.name +" ^1um flechada no moscao !!!");	
					attacker statAdds("HUMILIATIONS", 1);//Humili
				}				
					//NADE LONG RANGE
				if ( sWeapon != "winchester1200_grip_mp" && sMeansOfDeath == "MOD_IMPACT" && int(fDistance) >= 760)
				{
					//iprintln("bulletStreak: " + attacker.pers["stats"]["kills"]["bulletStreak"]);
					level thread playSoundOnEveryone( "humiliation","^3Arremessador", attacker.name +" ^1essa foi longe !!!");	
					//attacker updateclassscore(550,true);
					attacker GiveEVP(10,100);
					//self updateclassscore(-180,true);
					
					attacker SetRankPoints(self.pers["rank"] * 2);					
					self SetRankPoints(attacker.pers["rank"] * -2);
					
					attacker statAdds("HUMILIATIONS", 4);//Humili
				}
				//NADE humi
				if(sWeapon != "winchester1200_grip_mp" && sMeansOfDeath == "MOD_IMPACT" && int(fDistance) < 200) //any gametype
				{
					//playedSound = true;
					level thread playSoundOnEveryone( "humiliation","^3Pedrada ",self.name + " foi humilhado por " + attacker.name);

					if(level.gametype != "dm" && MorethanSix())
					{
						//Humiliation
						//attacker updateclassscore(350,true);
						attacker GiveEVP(10,100);
						attacker statAdds("HUMILIATIONS", 2);
						//self updateclassscore(-150,true);
					}
				}				
				//iprintlnbold("Consecutives: " + attacker.pers["stats"]["kills"]["consecutive"]);
				if ( attacker.pers["stats"]["kills"]["consecutive"] > attacker.pers["stats"]["kills"]["killstreak"] )
				{
					attacker.pers["stats"]["kills"]["killstreak"] = attacker.pers["stats"]["kills"]["consecutive"];
					//attacker statAdds("KILL_STREAK", attacker.pers["stats"]["kills"]["killstreak"]);
				}

				/*
		attacker.lastKilledPlayer = self;
		attacker.lastKillTime =  savedtime;
		self.lastKilledBy = attacker;
		*/
//=======================================================TEAMBASED=======================================================================================

			if(level.atualgtype == "sd")
			{
				//ANTI-BOMBER
				if ( isdefined( self.isPlanting ) && self.isPlanting && MorethanSix())
				{
					//ANTI-BOMBER WALLHACK
					if (self.iDFlags & level.iDFLAGS_PENETRATION)
					{
						attacker GiveEVP(70,100);
						//attacker updateclassscore(10,true);
						//self updateclassscore(-30,true);
						
						attacker SetRankPoints(self.pers["rank"] * 5);					
						self SetRankPoints(attacker.pers["rank"] * -5);
					
						level thread playSoundOnEveryone( "wickedsick","Profissional", attacker.name +" enxergar eh pros fracos...");						
					}
					else
					{
						level thread playSoundOnEveryone( "denied","Anti-Bomba", attacker.name +" ^1Nao deixou o " + self.name + " armar a bomba!");	
						attacker statAdds("DEFUSED", 1);//+1 def
						attacker GiveEVP(50,100);
						
						//self updateclassscore(-30,true);
						
						attacker SetRankPoints(self.pers["rank"] * 2);					
						self SetRankPoints(attacker.pers["rank"] * -2);
					}
				}						
				//Payback (VITIMA MATOU O ATTACKER NO OUTRO ROUND)
				/*if( isDefined( self.lastKilledBy ) )
				{
				  if(attacker.lastKilledBy)
				  {
					//string = player.pers["lastKilledBy"].name;
					//iprintln("award payback: " + player.name + " killed " + string + ". Actual victim is " + data.victim.name );
					level thread playSoundOnEveryone( "dominating","Payback", attacker.name +" se vingou do " + self.name);
					attacker updateclassscore(700,true);
					attacker statAdds("OWNAGES", 1);
					attacker.lastKilledBy = undefined;
					self updateclassscore(-150,true);
					attacker SetRankPoints(20);
					self SetRankPoints(-20);
				  }
				}	*/
			}
					//MORREU EM MODO STEALTH
					/*if(isdefined(self.instealth))
					{
						self updateclassscore(self.score * -1,true);
						self statAdds("EVPSCORE", -100);
						self.pers["score"] = 0;
						self.kills = 0;
						self.pers["kills"] = 0;
					}*/
					
					
					//BONUS POR MATAR UM PLAYER MARCADO
					if(isdefined(self.spotMarker))
					{
						if(isdefined(self.wasmarkedby) && isAlive(self.wasmarkedby) && self.wasmarkedby != attacker)
						{
							//self.wasmarkedby updateclassscore(100,true);
							self.wasmarkedby GiveEVP(10,100);
							self.wasmarkedby SetRankPoints(self.pers["rank"] * 2);
							self.wasmarkedby = undefined;//reseta						
						}							 
					}
						
					//CRUELDADE - reviveu e matou o infeliz.
					if (isdefined(self.revived) && attacker.medicpro)
					{
						if (sMeansOfDeath == "MOD_MELEE" )
						{
							level thread playSoundOnEveryone( "denied","Crueldade", attacker.name +" salvou " + self.name + " para mata-lo...");
							//attacker updateclassscore(50,true);				
							attacker GiveEVP(10,100);
						}
					}
					
					//CRUELDADE - revidada
					if (isdefined(attacker.revived) && self.medicpro)
					{
						//if (sMeansOfDeath == "MOD_MELEE" )
						//{
							level thread playSoundOnEveryone( "denied","Crueldade RetroAnal", attacker.name +" fodeu " + self.name + " gostoso...");
							//attacker updateclassscore(250,true);
							attacker GiveEVP(10,100);
							attacker.revived = undefined;
						//}
					}
				
//ERROR pair 'undefined' and '15' has unmatching types 'undefined' and 'int'				
					//RIVAL - PLAYER ODEIA MESMO O JOGADOR
					if (isDefined( attacker.killedPlayers[""+self.clientid] ) )
					{					
						if ( attacker.killedPlayers[""+self.clientid] == 15)
						{
							level thread playSoundOnEveryone( "dominating","Rival", attacker.name +" odeia " + self.name);
							attacker statAdds("KILLS", 1);
							//attacker updateclassscore(200,true);
							attacker GiveEVP(20,100);
							//self updateclassscore(-100,true);
							attacker SetRankPoints(10);
							self SetRankPoints(-10);
						}
					}
					//FLASH KILL
					if ( savedtime < attacker.flashEndTime)
					{
						level thread playSoundOnEveryone( "unstoppable","Previsao", attacker.name +" voce viu " + self.name + "? eu nao...");
						//attacker updateclassscore(100,true);
						attacker GiveEVP(10,100);
					}
					//iprintln("Dis " + fDistance);
					//iprintln("killedtime " + killedtime);
					//iprintln("iDFlags " + self.iDFlagsTime);
					//2000 fd = 52m
					
					//ATRAVES DA PAREDE wall
					if ( attacker isSniper( sWeapon ) && int(fDistance) >= 2600 )  
					{
						 
						if ( self.iDFlags & level.iDFLAGS_PENETRATION )
						{
							attacker statAdds("WALLBANG", 1);//WALLBANG MEDAL
							attacker GiveEVP(10,100);
							level thread playSoundOnEveryone( "impressive","Visao X", attacker.name +" paredes? pra que?");
							
							attacker SetRankPoints(self.pers["rank"] * 2);					
							self SetRankPoints(attacker.pers["rank"] * -2);
						}
					}
					//ATRAVES DA PAREDE wall HS
					if ( attacker.isSniper && isSniper( sWeapon ) && sMeansOfDeath == "MOD_HEAD_SHOT" )  
					{						 
						if ( self.iDFlags & level.iDFLAGS_PENETRATION )
						{
							attacker statAdds("WALLBANG", 1);//WALLBANG MEDAL
							attacker GiveEVP(40,100);
							level thread playSoundOnEveryone( "impressive","Wallbilidade", attacker.name +" que isso em...");
							
							attacker SetRankPoints(self.pers["rank"] * 3);					
							self SetRankPoints(self.pers["rank"] * -3);
						}
					}
					
					//BALLISTIC MASTER
					if ( sWeapon == "beretta_silencer_mp" && int(fDistance) >= 2200 )  
					{
							attacker GiveEVP(10,100);
							//attacker updateclassscore(100,true);
							//self updateclassscore(-10,true);
				
							attacker SetRankPoints(self.pers["rank"] * 2);					
							
							self SetRankPoints(attacker.pers["rank"] * -2);
							
							level thread playSoundOnEveryone( "Hattrick","Mestre Balistico", attacker.name +" tem um nivel absurdo de precisao!");
						
					}
					
					//HATCHET
					//iprintln("Sweapon: " + sWeapon);
					//iprintln("Distance: " + int(fDistance));
					if ( sWeapon == "frag_grenade_short_mp" && int(fDistance) >= 1400 )  
					{
						if (MorethanSix())
						{
							//attacker updateclassscore(120,true);
							attacker GiveEVP(10,100);
							level thread playSoundOnEveryone( "Hattrick","Certeiro", attacker.name +" caga litros com sua Hatchet");
						}
					}
					
					if ( attacker.isSniper && sMeansOfDeath == "MOD_HEAD_SHOT" && int(fDistance) >= 4000)
					{
							//attacker updateclassscore(120,true);
							attacker GiveEVP(10,100);
							level thread playSoundOnEveryone( "longhs","HeadHunter", attacker.name +" mas que belo HS a 100m!!");	

							attacker SetRankPoints(self.pers["rank"] * 2);					
							self SetRankPoints(attacker.pers["rank"] * -2);
					}
					
					//FLYING SHOOT
					if(attacker.isSniper && !attacker isOnGround() && int(fDistance) >= 2600  )
					{
						level thread playSoundOnEveryone( "dominating","Habilidoso", attacker.name +" matou dando uma voadora!");
						//attacker updateclassscore(60,true);
						attacker GiveEVP(30,100);
						
						attacker SetRankPoints(self.pers["rank"] * 6);					
						self SetRankPoints(attacker.pers["rank"] * -2);
					}
				
//--------------------------------normal----------------------------------------
				// Check if this was a headshot
				if ( sMeansOfDeath == "MOD_HEAD_SHOT" ) 
				{
					attacker.pers["stats"]["kills"]["headshots"] += 1;
					attacker statAdds("HEADSHOTS", 1);//HEAD
					
					attacker SetRankPoints(self.pers["rank"] * 4);					
					self SetRankPoints(self.pers["rank"] * -2);
						
					//attacker statAdds("MAPHEADSHOT", 1);//HEAD
					//attacker.atualhs = attacker getStat(2302);					
					//attacker setStat(2302,attacker.pers["stats"]["kills"]["headshots"]);
					
					//usado pelo best
					attacker.mapheadshots = attacker.pers["stats"]["kills"]["headshots"];
					//iprintln(attacker.atualhs);
				}			
				else if ( sMeansOfDeath == "MOD_MELEE" || sMeansOfDeath == "MOD_BAYONET" ) 
				{
					attacker.pers["stats"]["kills"]["knife"] += 1;
					attacker statAdds("KNIFES", 1);//knife
				}					
								
				attacker.pers["stats"]["kills"]["total"] += 1;			

			}
			
			//CONTA KILLS E DEATHS APENAS AQUI
			if(level.valekills && level.atualgtype != "kc")
			{
				//CLASS KILLS					
				attacker statAdds("KILLS",1);				
			}
		}
	}	
}

MorethanSix()//changed 2024 
{
	//if(level.aliveCount["allies"] >= 2 && level.aliveCount["axis"] >= 2)
	//	return true;
	//else
		//return false;	
		
	if(level.players.size >= 4)
	return true;
	
	return false;
}

isHighestScoringPlayer( player )//vitima
{
	//DEBUG
	//iprintln("kills: " + players.kills);
		
	if ( !isDefined( player.kills ) || player.kills < 30 )// se meu score eh menor que isso
		return false;
	
	players = level.players;
	if ( level.teamBased )
		team = player.pers["team"];
	else
		team = "all";//DM
	//highScore = player.kills;//armazena o meu score => 130
	for( i = 0; i < players.size; i++ )//verifica todo meu time, se eu sou mesmo o melhor em score
	{
		//DEBUG
		//iprintln("Name: " + player.name+ " Score: " + players[i].score);

		if ( team != "all" && players[i].pers["team"] != team )//ignora o outro time
			continue;
			
		if ( !isDefined( players[i].kills ) )// 0 ou nulo ignorar
			continue;
			
		if ( players[i].kills <= 30 )//filtra so o maior mesmo (tem que ter algum player com esse escore no meu time)
			continue;
		
		if ( players[i].kills >= 30 ) //alguem tem 130 > H - nao sou o melhor do time.
			return false;
	}
	
	return true;
}




achievements()
{

		if(!self.isRanked) return;
//=================================BOMB PLANTS==================================
		if(statGets("PLANTRANK") == 2)
		{
			if(statGets("PLANTED") >= 1000 )
			{
				statSets("PLANTRANK", 3  );
				iprintlnbold(self.name ," is now a ^1Bomb Hunter^7 with ^11000^7 Bomb Plants");
				self thread proplayerhud( "^1Bomb Hunter!", "^7You have Stolen the Bomb ^1" + 1000 + " ^7times!" );
				statAdds("EVPSCORE", 6000 );
			}
		}
		if(statGets("PLANTRANK") == 1)
		{
			if(statGets("PLANTED") >= 500 )
			{
				statSets("PLANTRANK", 2  );
				iPrintLn(self.name ," is now a ^1Bomb Thief^7 with ^1500^7 Bomb Plants");
				self thread proplayerhud( "^1Bomb Thief!", "^7You have Stolen the Bomb ^1" + 500 + " ^7times!" );
				statAdds("EVPSCORE", 3000 );					
			}
		}
		if(statGets("PLANTRANK") == 0)
		{
			if (statGets("PLANTED") >=  100)
			{
				statSets("PLANTRANK", 1  );
				iPrintLn(self.name, " is now a ^1Bomb Owner^7 with ^1100^7 Bomb Plants");	 
				self thread proplayerhud( "^1Bomb Owner!", "^7You have Planted the Bomb ^1" + 100 + " ^7times!" );
				statAdds("EVPSCORE", 1000 );
			}
		}
		
//=================================DEFUSES==================================
		if(statGets("DEFUSERANK") == 2)
		{
			if (statGets("DEFUSED") >=  1000)
			{
				statSets("DEFUSERANK", 3  );
				iprintlnbold(self.name," is now a ^1Bomb Pro with^7 ^11000^7 Defuses");	 
				self thread proplayerhud( "^1Bomb Pro!", "^7You have Defused the Bomb ^1" + 1000 + " ^7times!" );
				statAdds("EVPSCORE", 6000 );					
			}
		}
		if(statGets("DEFUSERANK") == 1)
		{
			if (statGets("DEFUSED") >=  500)
			{
				statSets("DEFUSERANK", 2  );
				iPrintLn(self.name," is now a ^1Bomb Maker with^7 ^1500^7 Defuses");	 
				self thread proplayerhud( "^1Bomb Pro!", "^7You have Defused the Bomb ^1" + 500 + " ^7times!" );
				statAdds("EVPSCORE", 3000 ); 					
			}
		}
		if(statGets("DEFUSERANK") == 0)
		{
			if (statGets("DEFUSED") >=  100)
			{
				statSets("DEFUSERANK", 1  );
				iPrintLn(self.name," is now a ^1Bomb Expert^7 with ^1100^7 Defuses");
				self thread proplayerhud( "^1Bomb Expert!", "^7You have Defused the Bomb ^1" + 100 + " ^7times!" );
				statAdds("EVPSCORE", 1000 );	
			}
		}
		
//=================================KILLS==================================
		if(statGets("KILLRANK") == 7)
		{
			if (statGets("KILLS") >=  100000)
			{
				statSets("KILLRANK", 8  );
				iprintlnbold(self.name," is now a ^1Promatch The One ^7with ^1100000^7 Kills");	 
				self thread proplayerhud( "^1Promatch Full Kills!", "^7The End: ^1" + 25000);
				
				statAdds("MONEYRANK",100000);
				statAdds("EVPSCORE", 100000);
			}	
		}
		if(statGets("KILLRANK") == 6)
		{
			if (statGets("KILLS") >=  20000)
			{
				statSets("KILLRANK", 7  );
				iprintlnbold(self.name," is now a ^1Promatch Godlike ^7with ^120000^7 Kills");	 
				self thread proplayerhud( "^1Promatch Godlike!", "^7Nuclear casualties: ^1" + 20000);
				
				statAdds("MONEYRANK",30000);
				statAdds("EVPSCORE", 20000);				
			}	
		}
		
		if(statGets("KILLRANK") == 5)
		{
			if (statGets("KILLS") >=  15000)
			{
				statSets("KILLRANK", 6  );
				self thread proplayerhud( "^1Promatch Elite Supreme!", "^7Total annihilation: ^1" + 15000);
			
				statAdds("MONEYRANK",25000);
				statAdds("EVPSCORE", 15000);
			}	
		}
		if(statGets("KILLRANK") == 4)
		{
			if (statGets("KILLS") >=  10000)
			{
				statSets("KILLRANK", 5  );
				iprintlnbold(self.name," is now a ^1Promatch Elite ^7with ^110000^7 Kills");	 
				self thread proplayerhud( "^1Promatch Elite!", "^7WTF was that? You made players extinction: ^1" + 10000 + " ^7Noobs killed!" );
				
				statAdds("MONEYRANK",20000);
				statAdds("EVPSCORE", 10000);
			}	
		}
		
		if(statGets("KILLRANK") == 3)
		{
			if (statGets("KILLS") >=  3500)
			{
				statSets("KILLRANK", 4  );
				iPrintLn(self.name," is now a ^1Promatch Master ^7with ^13500^7 Kills");	 
				self thread proplayerhud( "^1Promatch Master!", "^7You have Killed ^1" + 3500 + " ^7Noobs!" );
				
				statAdds("MONEYRANK",15000);
				statAdds("EVPSCORE", 3500);
			}	
		}
		if(statGets("KILLRANK") == 2)
		{
			if (statGets("KILLS") >=  2500)
			{
				statSets("KILLRANK", 3  );
				iPrintLn(self.name," is now a ^1Promatch Pro ^7with ^12500^7 Kills , Noobs Ownage...");	 
				self thread proplayerhud( "^1Promatch Pro", "^7You have Killed ^1" + 2500 + " ^7chickens!");//unlocked
				
				statAdds("MONEYRANK",10000);
				statAdds("EVPSCORE", 2500);
			}
		}
		if(statGets("KILLRANK") == 1)
		{
			if (statGets("KILLS") >=  1500)
			{
				statSets("KILLRANK", 2  );
				iPrintLn(self.name," is now a ^1Promatch Expert^7 with ^11500^7 Kills");	 
				self thread proplayerhud( "^1Promatch Expert!", "^7You have Killed ^1" + 1500 + " ^7Bonus Frags!" ); 
				
				statAdds("MONEYRANK",7000);
				statAdds("EVPSCORE", 2000);
				
			}
		}
		if(statGets("KILLRANK") == 0)
		{
			if (statGets("KILLS") >=  500)
			{
				statSets("KILLRANK", 1  );
				iPrintLn(self.name," is now a ^1Promatch Player ^7with ^1500^7 Kills");
				self thread proplayerhud( "^1Promatch Player!", "^7You have Killed ^1" + 500 + " ^7Players!" );
				statAdds("MONEYRANK",6000);
				statAdds("EVPSCORE", 1500);				
			}
		}
		
		
//=================================HEADSHOTS==================================
		if(statGets("HSRANK") == 4)
		{
			if (statGets("HEADSHOTS") >=  2000 )
			{
				statSets("HSRANK", 5  );
				iPrintLn(self.name," is now an ^1Head Hunter!^7 with ^11500^7 Headshots");
				self thread proplayerhud( "^1Head Hunter", "^7You have done ^1" + 2000 + " ^7HeadShot Kills!");
				statAdds("EVPSCORE", 5000);
			}
		}
		
		if(statGets("HSRANK") == 3)
		{
			if (statGets("HEADSHOTS") >=  1500 )
			{
				statSets("HSRANK", 4  );
				iPrintLn(self.name," is now an ^1Head Hunter!^7 with ^11500^7 Headshots");
				self thread proplayerhud( "^1Head Hunter", "^7You have done ^1" + 1500 + " ^7HeadShot Kills!");
				statAdds("MONEYRANK",1000);
				statAdds("EVPSCORE", 4000);
			}
		}
		
		if(statGets("HSRANK") == 2)
		{
			if (statGets("HEADSHOTS") >=  500 )
			{
				statSets("HSRANK", 3  );
				iPrintLn(self.name," is now an ^1AimBOT^7 with ^1500^7 Headshots");
				self thread proplayerhud( "^1Aim BOT!", "^7You have done ^1" + 500 + " ^7HeadShot Kills!");
				statAdds("MONEYRANK",1000);
				statAdds("EVPSCORE", 3000 );
			}
		}
		
		if (statGets("HSRANK") == 1)
		{
			if (statGets("HEADSHOTS") >=  300)
			{
				statSets("HSRANK", 2  );
				iPrintLn(self.name," is now an ^1Aim Master^7 with ^1300^7 Headshots");
				self thread proplayerhud( "^1Aim Master!", "^7You have done ^1" + 300 + " ^7HeadShot Kills!" );
				statAdds("MONEYRANK",1000);
				statAdds("EVPSCORE", 2000 );
			}
		}
		
		if ( statGets("HSRANK") == 0)
		{
			if (statGets("HEADSHOTS") >=  100 )
			{
				statSets("HSRANK", 1  );
				iPrintLn(self.name," is now an ^1Aim Expert^7 with ^1100^7 Headshots");
				self thread proplayerhud( "^1Head Hunter!", "^7You have done ^1" + 100 + " ^7Headshot Kills!" );
				statAdds("MONEYRANK",1000);
				statAdds("EVPSCORE", 1000);
			}
		}
		
		
		//=================================PLAYEDMAPSCOUNT==================================

		if(self getStat(2327) == 4)
		{
			if (statGets("PLAYEDMAPSCOUNT") >=  1000 )
			{
				self setStat(2327, 5  );

				iPrintLn(self.name," temos aqui o Senhor ^1Master of the House^7 com ^11000x ^7agora so vive aqui.....");
				self thread proplayerhud( "^1Master of the House","^7Voce tem ^11000x ^7jogadas neste servidor.");
				statAdds("EVPSCORE", 15000);
			}
		}
		
		if(self getStat(2327) == 3)
		{
			if (statGets("PLAYEDMAPSCOUNT") >=  500 )
			{
				self setStat(2327, 4  );
				iPrintLn(self.name," hmmm parece que o ^1The Owner^7 chegou, com ^1500x ^7jogadas neste servidor !!!!");
				self thread proplayerhud( "^1The Owner", "^7Voce tem ^1500x ^7jogadas neste servidor.");
				statAdds("EVPSCORE", 10000);
			}
		}
		
		if(self getStat(2327) == 2)
		{
			if (statGets("PLAYEDMAPSCOUNT") >=  400 )
			{
				self setStat(2327, 3  );
				iPrintLn(self.name," faz parte da familia ^1My House^7 com ^1400x ^7jogadas neste servidor.");
				self thread proplayerhud( "^1My HOUSE", "^7Voce tem ^1400x ^7jogadas neste servidor.");
				statAdds("EVPSCORE", 5000 );
			}
		}
		
		if (self getStat(2327) == 1)
		{
			if (statGets("PLAYEDMAPSCOUNT") >=  300)
			{
				self setStat(2327, 2  );
				iPrintLn(self.name," temos aqui um explorador ^1The Explorer^7 com ^11300x^7 jogadas aqui!!!!");
				self thread proplayerhud( "^1The Explorer", "^7Voce tem ^11300x ^7jogadas neste servidor.");
				statAdds("EVPSCORE", 4000 );
			}
		}
		
		if ( self getStat(2327) == 0)
		{
			if (statGets("PLAYEDMAPSCOUNT") >=  100 )
			{
				self setStat(2327, 1 );
				iPrintLn(self.name," eh um cliente fiel ^1The Customer^7 com ^1100x^7 jogadas no servidor.");
				self thread proplayerhud( "^1The Customer", "^7Voce tem ^1100x ^7jogadas neste servidor.");
				statAdds("EVPSCORE", 2000);
			}
		}		
}