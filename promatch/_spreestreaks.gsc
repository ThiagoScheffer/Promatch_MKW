#include promatch\_utils;
#include maps\mp\_utility;

TeamBuff()
{
	self endon ( "disconnect" );
	//level endon ( "game_ended" );

	if(level.cod_mode == "torneio")
		return;
	
	//self iprintln("TeamBuff LVL1");
	if(!level.teamBased)
	return;
	
	//if(level.players.size < 4)
	//return;

	if ( level.inGracePeriod )
	return;

	//self iprintln("TeamBuff LVL2");
	
	//if(!isdefined(self.atualClass))
	//return;

	//DEFENSE BLOCKER
	if(isdefined(self.blocked))
	{
		//self iprintln("^3#BUFF BLOQUEADO PELO INIMIGO#");
		self thread showtextfx3("BUFF BLOQUEADO PELO INIMIGO",4,"red");
		return;
	}
	
	if(self.usingbuff)
	{
		//self iprintln("^3#TeamBuff em Uso. Aguarde!#");
		self thread showtextfx3("TeamBuff em Uso. Aguarde",4,"yellow");
		return;
	}
	
	//self iprintln("TeamBuff LVL3");
	
	if(self statGets("TEAMBUFF") < 1)//se nao estiver 1 ponto para usar cancela
	return;

	//se ha um buff sendo usado no mesmo time retorna. evita buff se auto resetar um por cima do outro
	if(isdefined(level.axisbuff) && level.axisbuff == self.pers["team"])
	{
		self thread showtextfx3("TeamBuff em Uso. Aguarde",4,"yellow");
		return;
	}
	
	if(isdefined(level.alliesbuff) && level.alliesbuff == self.pers["team"])
	{
		self thread showtextfx3("TeamBuff em Uso. Aguarde",4,"yellow");
		return;
	}
	
	//self iprintln("TeamBuff LVL4");
	
	if(self noteambuffselected())
	return;
	
	//nao tem XP nem evp
	if(!self PodeUsarBuff()) return;
	
	//self iprintln("TeamBuff LVL5");
	
	self playLocalSound( "radio_pullout");
	
	self.bufftype = "none";
	
	if(self IsUpgradesOn("skillbuffuphand"))
	self.bufftype = "Uphand";
	
	if(self IsUpgradesOn("skillbuffdefense"))
	self.bufftype = "Defense";
	
	if(self IsUpgradesOn("skillbuffhealing"))
	self.bufftype = "Healing";
	
	if(self IsUpgradesOn("skillbuffnowhere"))
	self.bufftype = "Nowhere";
	
	if(self IsUpgradesOn("skillbuffjammer"))
	self.bufftype = "Jammer";
	
	if(self IsUpgradesOn("skillbuffhack"))
	self.bufftype = "Hack";
	
	
	team = self.pers["team"];
	otherteam = "axis";
	if (team == "axis")
	otherteam = "allies";
	
	if(self IsUpgradesOn("skillbuffspydrone"))
	{
		self thread printmsgfxtobothteams("nosso SpyDrone esta ativo","Spydrone inimigo Ativo!!!","red");
		
		self thread playsoundtoteam(game["voice"][self.team] + "ouruavonline");
		self thread playsoundtoenemyteam(game["voice"][otherteam] + "enemyuavair");
		self thread promatch\_droneplane::dospyplane();
		return;
	}
	
	if(self IsUpgradesOn("skillbuffpredator"))
	{
		self thread printmsgfxtobothteams("nosso Missil Predador esta ativo","Cuidado Missil Predador inimigo !","red");
	
		self thread playsoundtoteam(game["voice"][self.team] + "predator_friendly");		
		self thread playsoundtoenemyteam( game["voice"][otherteam] + "predator_enemy");		
		self promatch\_predator::givePredator();
		
		return;
	}
	
	if(self IsUpgradesOn("skillbuffcarepackage"))
	{
		self thread promatch\_CarePackage::CarePackage();	
		self notify( "carepackageopenselect");
		return;
	}
	
	
	if(self.bufftype == "none")
	return;
	
	//self iprintln("TeamBuff LVL6");
	
	//indica qual time esta usando um BUFF no momento
	//se estiver em uso o jogador tera que esperar
	if(self.pers["team"] == "axis")
	level.axisbuff = "axis";
	else
	level.alliesbuff = "allies";
	
	await = 0;
	whatbuff = "";

	self.usingbuff = true;
	
	//USADO
	self statSets("TEAMBUFF",0);
	
	//add um check para evp e xp aqui!
	//if(isDefined(self.vipuser) && !self.vipuser)
	//{
	//	self updateclassscore(-500,false);
	//	self iprintln("^2Teambuff Usado -50 EVP - 500 XP");
	//	self statAdds("EVPSCORE", (50 * -1) );
	//}
	//else
	//{
		//self updateclassscore(-500,false);
		//self iprintln("^2Teambuff Usado");
		self thread showtextfx3("TeamBuff em Uso. Aguarde",3,"yellow");
		self statAdds("EVPSCORE", (150 * -1) );
	//}
	
	if(isDefined(self.teambufficon) && isDefined(self.teambufficon.icon))
	self.teambufficon.icon.alpha = 0;

	//APLICA POR XSEGUNDOS O BUFF
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		//caso ele quit ou drop
		if(!isDefined(player)) continue;		
		
		//ignorar caso morto ou n jogando...
		if(!isAlive(player)) continue;

		if(!isdefined(player.class)) continue;
	
		//==ELITE==
		if(self.bufftype == "Hack")
		{
			//roda uma unica vez
			if(!isDefined(level.elitebuff))
			{
				level.elitebuff = self.pers["team"];
				
				if(level.atualgtype == "sd" && isDefined(level.sdBomb))
				{
					if(self.pers["team"] == game["attackers"])
					{
						if(level.bombPlanted)
						{
							level.bombhacked = true;
							level notify("bomb_hacked");
							
						}
						else
						{
							//reseta o timer da bomd para os attacker poderem ter mais jogo
							//maps\mp\gametypes\_globallogic::pauseTimer();
							setGameEndTime( int( gettime() + (level.bombTimer * 1000) ) );							
						}
					}
						
					if(self.pers["team"] == game["defenders"])
					{
						if(!level.bombPlanted)
						{
							level.bombhacked = undefined;
							level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry( "any" );
						}
						else
						{
							level.bombunhacked = true;
							level notify("bomb_hacked");//desativa o normal
							level notify("bombunhacked");//desativa o hackeado
						}
					}
				}
				
				//claysensorhack
				if(!MesmoTime(player))
				{
					//verifica se o jogador possui clays e entao hackeia
					player HackExplosives(self);

					if(isDefined(self.sentryTurret))
					{
						for( i = 1; i < self.sentryTurret.size; i++ )
						{
							self.sentryTurret[i].owner = self;
							self.sentryTurret[i].team = self.pers["team"];
						}
					}
				}			
				
			}
			
			
			
			if(MesmoTime(player))
			{
				//Todos modos
				player.revived = undefined;
				player.onhack = true;
				
				
				if(level.atualgtype == "sd")
				{					
					//timer 50 - posso dar 10S a+ para meu time
					if(player.pers["team"] == game["attackers"])
					{
						if(!level.bombPlanted)
						{
							player.useTime = 5000; //contrar os defenders							
						}
						continue;
					}
					
					if(player.pers["team"] == game["defenders"])
					{
						if(!level.bombPlanted)
						{
							player thread allowDefenderExplosiveDestroy();
							player.allowdestroyexplosives = true;
						}
						continue;
					}
				}
								
				if(level.atualgtype == "ctf" && player.isFlagCarrier)
				{
					player setPerk( "specialty_longersprint" );
					player setPerk( "specialty_bulletdamage" );
					player.statusicon = "";
					continue;
				}
				
				if(level.atualgtype == "dom")
				player.useTime = int(8000);	
				
				if(level.atualgtype == "tgr")
				player.tgrhack = true;
				
				whatbuff = "HACK!";
				player thread TeamBuffSound( "^1ELITE BUFF!", self.name + ": " + whatbuff );
			}
			else
			{
				player.ffkiller = true;
				player.stealthed = true;
				player.preventWallbang = true;				
				player.poisonedmeds = true;
				player thread showtextfx3("BUFF " + self.bufftype + " INIMIGO ATIVO",4,"red");
				
				if(percentChance(30))
				{
					//currentWeapon = player getCurrentWeapon();
					//player setWeaponAmmoStock( currentWeapon, 0 );
					//player setWeaponAmmoClip( currentWeapon, 0 );
					//player thread weaponJammer();
					
					player thread Jinxed();
					
				}
			}
			
		
			continue; //ignorar todas outras classes
		}
		//ASSAULT
		if(self.bufftype == "Uphand")
		{			
			if(MesmoTime(player))
			{
				player setClientDvar("bg_viewKickScale",0);
				player setClientDvar( "bg_shock_movement",0);
				player setPerk( "specialty_longersprint" );
				player setPerk( "specialty_fastreload" );
				player setPerk( "specialty_explosivedamage" );
				player setClientDvars("jump_spreadAdd",0,"player_dmgtimer_timePerPoint",0,"player_dmgtimer_flinchTime",0,"player_dmgtimer_stumbleTime",0);
				whatbuff = "UPHAND!";
				player thread TeamBuffSound( "^1COMBAT BUFF!", self.name + ": " + whatbuff );
			}
			
			player thread showtextfx3("BUFF " + self.bufftype + " INIMIGO ATIVO",4,"red");
			
			continue; // nao precisa verificar o resto ja que a classe nao muda.					
		}
		//SNIPER
		if(self.bufftype == "Nowhere")
		{
			if(MesmoTime(player))
			{
				
				player.takedown = true;
				player.coldblooded = true;
				//player setPerk( "specialty_gpsjammer" );
				player setPerk( "specialty_quieter" );
				whatbuff = "NOWHERE!";				
				player thread TeamBuffSound( "^1TACTICAL BUFF!", self.name + ": " + whatbuff );
			}
			else
			{
				player thread showtextfx3("BUFF " + self.bufftype + " INIMIGO ATIVO",4,"red");
			
				if(!isDefined(player.immune))
				{
					player.incognito = false;
					player.takedown = false;
					player.coldblooded = false;
					player setClientDvar("ui_hud_hardcore_show_minimap",0);
				}					
			}
			
			continue; // nao precisar verificar o resto ja que a classe nao muda.
		}
		
		//MEDICO	
		if(self.bufftype == "Healing")
		{
			
			if(MesmoTime(player))
			{
				whatbuff = "HEALING!";
			
				player LifeUpgrade(70);
				
				player setPerk( "specialty_longersprint" );
				
				player thread TeamBuffSound( "^1MEDIC BUFF!", self.name + " ativou o " + whatbuff);
			}
			
			player thread showtextfx3("BUFF " + self.bufftype + " INIMIGO ATIVO",4,"red");
			
			//restaura os medkits
			self.totalMedkits = 5;
			
			continue; // nao precisar verificar o resto ja que a classe nao muda.
		}

		if(self.bufftype == "Defense")
		{
			if(!MesmoTime(player)) 
			{ 
				player thread showtextfx3("BUFF " + self.bufftype + " INIMIGO ATIVO",4,"red");
			
				//DEFESA REMOVE PROTEÇOES
				if(!isDefined(player.immune))
				{
					player.takedown = false;
					player.incognito = false;
					player.coldblooded = false;
					player.tacresist = false;
					player.flakjacket = false;
					player.blocked = true;
					
					if(player.health < 100 && level.atualgtype != "ass")
					player LifeUpgrade(level.maxhealth);
					
					player unsetPerk( "specialty_quieter" );
				}
			}
			else //DA AO NOSSO TIME UMA PROTEÇAO EXTRA
			{		
				whatbuff = "DEFENSE!";
				player.blocked = undefined;//remove bloqueio nosso
				player.immune = true;				
				player.tacresist = true;
				player.flakjacket = true;
				player.ffkiller = false;
				player.sitrep = true;
				player.poisonedmeds = false;
				//reseta ataques
				player setClientDvar("ui_minimap_show_enemies_firing",1);
				player setClientDvars("hud_enable",1,"ui_hud_obituaries",1);
				player setClientDvar("ui_hud_hardcore_show_minimap",1);
				
				//removed entity is not an entity:
				if(isDefined(player.playerarmor) && isDefined(player.playerarmor.value))
				{
					player.playerarmor.base = 0.3;
					player.playerarmor.currentarmor = 300;
					player.playerarmor.value setValue(300);
					
					player.playercapa.currenthelmet = 300;
					player.playercapa.base = 0.3;
					player.playercapa.value setValue(300);
				}

								
				player thread TeamBuffSound( "^1DEFENSE BUFF!", self.name + ": " + whatbuff);
			}
		}
		
		if(self.bufftype == "Jammer")
		{
			whatbuff = "Jammer!";
			
			//aviso para o time inimigo
			if(!MesmoTime(player))
			{
				player thread showtextfx3("BUFF " + self.bufftype + " INIMIGO ATIVO",4,"red");
			
				if(!isDefined(player.immune))//DEFENSE BLOCK
				{					
					player setClientDvars("hud_enable",0,"ui_hud_obituaries",0);					
				}
			}
			else
			{
				player setPerk( "specialty_gpsjammer" );
				//player setPerk( "specialty_quieter" );
				//player.takedown = true;
				player.incognito = true;
				//player.coldblooded = true;
				player.sitrep = true;//imune a clays				
				player thread TeamBuffSound( "^1HUD JAMMER!", self.name + ": " + whatbuff);
			}
			continue; //ignorar todas outras classes
		}
	}	
	
	xwait( 2, false );
	
	self ResetBuffs();
	self.usingbuff = false;
}

//pode estar havendo conflitos aqui
ResetBuffs()
{
	//STREAKS VIP
	if(isDefined(level.poisonteam))
	level.poisonteam = undefined;//MEDIC
	

	if(isDefined(level.elitebuff))
	level.elitebuff = undefined;
	
	
	if(isDefined(level.attackbuff))
	level.attackbuff = undefined;
	
	if(isDefined(level.tacticalbuff))
	level.tacticalbuff = undefined;
	
	if(isDefined(level.defensebuff))
	level.defensebuff = undefined;
	
	if(isdefined(level.axisbuff) && level.axisbuff == self.pers["team"])
	{
		level.axisbuff = undefined;
	}
	
	if(isdefined(level.alliesbuff) && level.alliesbuff == self.pers["team"])
	{
		level.alliesbuff = undefined;
	}
}

allowDefenderExplosiveDestroy()
{
  self endon( "disconnect" );
  self endon( "death" );
  
  if(!self.upgradebombdisarmer)
  return;
  
  self.destroyingExplosive = false;
  self.explosiveDestroyed = false;
  lastWeapon = self getCurrentWeapon();
  startTime = 0;
  destroyTime = 15;
   
  while ( isAlive( self ) && !level.bombPlanted && !level.gameEnded && !self.explosiveDestroyed )
  {     
    while ( isAlive( self ) && self meleeButtonPressed() && self.isBombCarrier && !level.gameEnded )
    {
      if ( startTime == 0 )
      {
        //if ( level.scr_sd_allow_defender_explosivedestroy_sound )
        playSoundOnPlayers( "mp_ingame_summary", game["attackers"] );
	
        wait( 0.5 ); //Give time for melee animation to finish
        if ( self meleeButtonpressed() )
        {
 
            
            self giveWeapon( "briefcase_bomb_mp" );
            self setWeaponAmmoStock( "briefcase_bomb_mp", 0 );
            self setWeaponAmmoClip( "briefcase_bomb_mp", 0 );
            self switchToWeapon( "briefcase_bomb_mp" );
            self attach( "prop_suitcase_bomb","tag_inhand", true );
            while ( self getCurrentWeapon() != "briefcase_bomb_mp" )
            wait (0.05);
          
          startTime = promatch\_timer::getTimePassed();
          self.destroyingExplosive = true;
        }
        else
        {
          break;
        }   
      }
      wait( 0.05 );
      timeHack = ( promatch\_timer::getTimePassed() - startTime ) / 1000; 
      self updateSecondaryProgressBar( timeHack, destroyTime, false, "Destruindo explosivos..." );
        
      if ( timeHack >= destroyTime )
      {
        self.explosiveDestroyed = true; 
        break;
      }
      
      if(self getCurrentWeapon() != "briefcase_bomb_mp" )
      	break;
    }
	
    if ( self.destroyingExplosive )
    {
      self updateSecondaryProgressBar( undefined, undefined, true, undefined );
      self.destroyingExplosive = false;
      wait .5;

        self detach( "prop_suitcase_bomb", "tag_inhand" );
		
		if(isDefined(lastWeapon) && lastWeapon != "none")
        self switchToWeapon( lastWeapon );
      
      startTime = 0;  
    }  
    wait .5;   
  }
  
  if ( !level.bombPlanted && !level.gameEnded)
  {
    setGameEndTime( 0 );
	level.wasendedbycasedestroyed = true;
    maps\mp\gametypes\sd::sd_endGame( game["defenders"], "MALETA DESTRUIDA!" );

    maps\mp\gametypes\_globallogic::givePlayerScore( "defuse", self );
	self thread [[level.onXPEvent]]( "defuse" );
  }
  
}



TeamBuffSound( stringOne, stringTwo )
{
	notifyData = spawnStruct();
	notifyData.titleText = stringOne;
	notifyData.sound = "steals2";
	
	if( stringTwo == "Expirou.")
	notifyData.duration = 2.0;
	else
	notifyData.duration = 5.0;

	notifyData.notifyText = stringTwo;
	notifyData.textIsString = true;
	self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}


buffDefense(mode)
{


}

RenewRegen()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "joined_team" );
	self endon ( "joined_spectators" );
	level endon ( "game_ended" );
	
	if ( self.health <= 0 )
	{
		assert( !isalive( self ) );
		return;
	}

	maxhealth = self.maxhealth;
	oldhealth = maxhealth;
	player = self;

	regenRate = 10; // 0.017;
	
	for (;;)
	{
		xwait(1,false);

		//morto
		if (player.health <= 0)
		return;
	
		//if (player.health < 150)
		//{
		//	LifeUpgrade(15);
		//	continue;
		//}

		player.health += regenRate;
	}	
}

//==============VOLTADO PARA O JOGADOR VIP=======================
berserkmode()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "joined_team" );
	self endon ( "joined_spectators" );
	level endon ( "game_ended" );

	self notify("onberserker");
	self endon("onberserker");
	
	//if(!self.vipuser)
	//	return;
	
	if ( self.health <= 0 )
	{
		assert( !isalive( self ) );
		return;
	}

	notifyData = spawnStruct();
	notifyData.titleText = "BERSERK";
	notifyData.duration = 2.0;
	notifyData.sound = "steals2";
	notifyData.notifyText = "Berserk!!!";
	notifyData.textIsString = true;
	self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
	
	maxhealth = self.maxhealth;
	oldhealth = maxhealth;
	player = self;

	regenRate = 20; // 0.017;
	
	player.tacresist = true;
	player.flakjacket = true;
	
	for (;;)
	{
		xwait(1,false);

		//morto
		if (player.health <= 0)
		return;
	
		if (player.health >= 250)
		{
			//self iprintln("Full Berserk " + player.health);
			continue;
		}

		player.health += regenRate;
		//update hud
		player.playerhealth.value setValue(player.health);
		//debug
		//self iprintln("Berserk: " + player.health);
	}	
}

StreakNotify( stringOne, stringTwo )
{
	notifyData = spawnStruct();
	notifyData.titleText = stringOne;
	notifyData.sound = "steals2";
	
	notifyData.duration = 3.0;

	notifyData.notifyText = stringTwo;
	notifyData.textIsString = true;
	self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}

preventTeamBuffs()
{
	self endon("disconnect");

	self.blocked = true;

	xwait (30,false );
	
	self.blocked = undefined;
}

Setspawndelayzero(team)//alterar para temporario
{
	if(team == "allies")
	{
		level.waveDelay["allies"] = 0;
		level.lastWave["allies"] = 0;
	}
	else
	{
		level.waveDelay["axis"] = 0;
		level.lastWave["axis"] = 0;
	}
	//getdvarx( "scr_" + level.gameType + "_waverespawndelay", "float", 0, 0, 300 );
}


//azar
Stun()
{
	self endon("disconnect");
	self endon("death");
	

		if(percentChance(50))
		{
			self weaponJammer();
			self shellshock("frag_grenade_mp", 3.0);
			return;
		}
		
		if(percentChance(50))
		{
			self.ffkiller = true;
			self.spotMarker = true;
			self thread promatch\_markplayer::spotPlayer(6,false);
			return;
		}	
}




//azar
Jinxed()
{
	self endon("disconnect");
	self endon("death");
	
	if(percentChance(35))
	{	
		self.spotMarker = true;
		self thread promatch\_markplayer::spotPlayer(6,false);
		self shellshock("frag_grenade_mp", 1.0);
		return;
	}
	
	if(percentChance(35))
	{
		currentWeapon = self getCurrentWeapon();
		self setWeaponAmmoStock( currentWeapon, 0 );
		self setWeaponAmmoClip( currentWeapon, 0 );
		return;
	}
	
	if(percentChance(35))
	{
		self JinxedDropiten();
		self shellshock("frag_grenade_mp", 1.0);
		return;
	}
	
	if(percentChance(45))
	{
		self.ffkiller = true;
		self shellshock("frag_grenade_mp", 1.0);
	}
	
	if(percentChance(45))
	{
		self.spotMarker = true;
		self thread promatch\_markplayer::spotPlayer(6,false);
		return;
	}		

	//if(percentChance(15))
	//{
		//self LifeUpgrade(5);
	//}	
}

JinxedDropiten()
{
	if ( isDefined( self.carryObject ) )
	{
		if(level.atualgtype == "ctf" || level.atualgtype == "sd")
		self.carryObject thread maps\mp\gametypes\_gameobjects::setDropped();

		if ( level.atualgtype == "sd" && isdefined( self.isPlanting ) && !self.isPlanting)
		{
		self.carryObject thread maps\mp\gametypes\_gameobjects::setDropped();
		self.isBombCarrier = false;
		}

		self thread maps\mp\gametypes\_gameobjects::pickupObjectDelayTime( 8.0 );
	}
}




//Todos os medkits do mapa darao vida para o primeiro medic que der o buff
MedicShareBuff()
{
	//self iPrintLn(SearchByModel("hp_medium"));
	
	medkits = SearchByModel("hp_medium");
	
	for ( index = 0; index < medkits.size; index++ )
	{
		if(isDefined(medkits[index]))
		medkits[index].sharehealth = true;
	}
	
	//self iprintln("ENVENENADOS!");	
}

ElitePoisonBuff()
{
	//self iPrintLn(SearchByModel("hp_medium"));
	
	medkits = SearchByModel("hp_medium");
	
	for ( index = 0; index < medkits.size; index++ )
	{
		if(isDefined(medkits[index]))
		medkits[index].poisonedmeds = true;
	}
	
	//self iprintln("ENVENENADOS!");	
}

