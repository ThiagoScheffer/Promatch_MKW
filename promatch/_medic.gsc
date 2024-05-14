#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

#include promatch\_eventmanager;
#include promatch\_utils;

init()
{  
 


  //=======
  //Medic
  //=======      
  level.scr_healthsystem_medic_healing_time = 3;
  level.scr_healthsystem_medic_healing_health = 100;
  level.scr_healthsystem_healing_icon = getdvarx( "scr_healthsystem_healing_icon", "int", 1, 0, 1 );

  precacheModel( "health_obj" );
  precacheModel( "hp_medium" );

  level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	//self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onPlayerKilled", ::onPlayerKilled );
	self thread addNewEvent( "onJoinedSpectators", ::onJoinedSpectators );   
}

onPlayerSpawned()
{
}
//call from utils.
SetMedic()
{
	self setClientdvar( "cg_drawhealth", 0 );
	self.totalMedkits = 3;
	self.isHealingTeammate = false;
	self.reviving = false;
	self.cantsuicide = undefined;
	if(self.upgrademedkitPack > 0)
	self.totalMedkits = 7;
}

onPlayerKilled()
{
	//self.waitbot = true;
	
	//forBOTTEST
	//if(isDefined(self.waitbot))
	self thread switchplayertobot();	
	
	if ( isDefined( self.reviving ) ) 
	{
		self.reviving = false;
		self updateSecondaryProgressBar( undefined, undefined, true, undefined );
	}
}

onJoinedSpectators()
{
	self notify("end_healthregen");
	self setClientdvar( "cg_drawhealth", 0 );
	self.reviving = false;	
}

givePlayerScore( event, score )
{
	self maps\mp\gametypes\_rank::giveRankXP( event, score );
	
	self.pers["score"] += score;
	//self statAdds( "score", (self.pers["score"] - score) );
	self.score = self.pers["score"];
	self notify ( "update_playerscore_hud" );
}


dropHealthPack()
{

	//PERK MEDIC LIBERA SOMENTE O DROP DE HEALTH 3 PACKS
	if(!isDefined(self.medic))
	return;
	
	if(!self.medic) 
		return;
	
	if(!isAlive(self))
		return;	
	
	//acabou o medkits
	if(self.totalMedkits <= 0)
		return;	
	
	//give the deadbody preference over the mkit
	if(isDefined( self.checkingBody ) && self.checkingBody)
		return;

	// Get the victim's origin
	playerOrigin = self.origin;

	// Calculate the position and angles to spawn this healthpack
	trace = playerPhysicsTrace( playerOrigin + (0,0,20), playerOrigin - (0,0,2000), false, self.body );
	angleTrace = bulletTrace( playerOrigin + (0,0,20), playerOrigin - (0,0,2000), false, self.body );
	tempAngle = randomfloat( 360 );
	dropOrigin = trace;
	if ( angleTrace["fraction"] < 1 && distance( angleTrace["position"], trace ) < 10.0 )
	{
		forward = (cos( tempAngle ), sin( tempAngle ), 0);
		forward = vectornormalize( forward - vector_scale( angleTrace["normal"], vectordot( forward, angleTrace["normal"] ) ) );
		dropAngles = vectortoangles( forward );
	}
	else
	{
		dropAngles = ( 0, tempAngle, 0);
	}

	// Create a new health pack
	healthPackTrigger = spawn( "trigger_radius", dropOrigin, 0, 10, 2 );
	healthPackModel = spawn( "script_model", dropOrigin );
	healthPackModel.angles = dropAngles;
	healthPackModel setModel( "hp_medium" );
	healthPackModel.owner = self;
	healthPackModel.team = self.pers["team"];
	
	if(isDefined(self.poisonedmeds))
	healthPackModel.droppoisonedmeds = true;
	
	
	healthPackGlow = undefined;
	healthPackGlow = spawn( "script_model", dropOrigin );
	healthPackGlow.angles = dropAngles;
	healthPackGlow setModel( "health_obj" );
	
	
	//reduz medkits
	self.totalMedkits--;
	self iprintln("Medkits Restantes: " + self.totalMedkits);
	// Function to control the pickup
	healthPackTrigger thread pickupHealthPackThink( healthPackModel, healthPackGlow );

	// Function to remove the healthpack from the game if it's not picked up in certain amount of time
	healthPackTrigger thread pickupHealthPackTimeout( healthPackModel, healthPackGlow );
}

pickupHealthPackThink( healthPackModel, healthPackGlow )
{
	self endon("death");

	for (;;)
	{
		self waittill ( "trigger", player );

		if(!isAlive(player))
			continue;
		
		if(!isDefined(healthPackModel.owner))
		continue;

		
		healthPackPicked = false;
		
		//normal player
		if ( player.health < player.maxhealth && !player.medic) 
		{
			if(level.cod_mode == "torneio")
			{
				player LifeUpgrade(player.maxhealth);
				healthPackPicked = true;
			}
			else
			{
			
				//poison buff
				if(player.pers["team"] != healthPackModel.team)
				{
					if(isdefined(healthPackModel.droppoisonedmeds))
					{
						player thread PoisonedArrow();
					}
					else
					{			
						//healthPackModel.owner updateclassscore(9,true);					
						healthPackPicked = true;
					}
				}
				else
				{
					//APLICA AQUI TUDO PARA O JOGADOR
					
					//anula veneno
					player.stoppoison = true;
					//MEDKIT COMPLETA TODA VIDA
					
					
					//Medkits dao mais vida e parte da vida volta para o medico
					if(healthPackModel.owner.healthmaster)
					{
						healthPackModel.owner LifeUpgrade(healthPackModel.owner.health + 25);
						player LifeUpgrade(player.maxhealth + 25);
					}
					else
					player LifeUpgrade(player.maxhealth);					
					
					//da ao medic xp por ter ajudado o time
					//healthPackModel.owner updateclassscore(50,true);
					
					healthPackPicked = true;
				}						  
			}
		}				
		
		//remove apos ser usado
		if ( healthPackPicked ) 
		{
			player playLocalSound( "health_pickup_medium" );
			
			//se o dono do medkit possui o treinamento 4
			if(isDefined(healthPackModel.owner) && healthPackModel.owner.upgrademedkitPack)
			thread sharehealthtoteam(healthPackModel.team);		
			
			thread destroyHealthPack( self, healthPackModel, healthPackGlow );	
			
			return;
		}
		
		//APRIMORAMENTO AMMO - da aos jogadores que pegarem este medkit tbm um pouco de ammo
		if(healthPackModel.owner.upgradeammopack > 0 )
		{
			currentWeapon = player getCurrentWeapon();
				
			//Weapon name "none" is not valid.
			if(isDefined(currentWeapon) && currentWeapon != "none")
			{				
			
				if (maps\mp\gametypes\_weapons::isPrimaryWeapon(currentWeapon ) )
				{					
					amount = randomIntRange(90,150);
					
					stockAmmo = player GetWeaponAmmoStock( currentWeapon );
					stockMax = WeaponMaxAmmo( currentWeapon );
					//player iprintln(stockAmmo);
					
					//se ainda tem muita municao nao pegar!
					if ( stockAmmo > 40)
					continue;
					
					if ( stockAmmo >= stockMax - 50)
					continue;
					
					//diff = amount - player getWeaponAmmoClip( currentWeapon );
				
					//player setWeaponAmmoStock( currentWeapon, diff );

					if ( isWeaponClipOnly( currentWeapon ) )
					{
						player setWeaponAmmoClip( currentWeapon, amount );
					}
					else
					{
						player setWeaponAmmoStock( currentWeapon, amount );
					}
						
					//if(player != healthPackModel.owner)
					//healthPackModel.owner updateclassscore(50,true);
					
					player playLocalSound( "weap_ammo_pickup" );				
					thread destroyHealthPack( self, healthPackModel, healthPackGlow );
					return;
				}
			}
		}

	}
}

sharehealthtoteam(team)
{
	players = getEntArray( "player", "classname" );
	
	for ( index = 0; index < players.size; index++ )
	{
		if(!isAlive(players[index])) continue;
		
		//nao do mesmo time
		if (players[index].pers["team"] != team)
		continue;
		
		//compartilha meds
		if (players[index].medic)
		players[index] LifeAddUpdate(15);
	}

}
pickupHealthPackTimeout( healthPackModel, healthPackGlow )
{
	self endon("death");

	healthPackTimeout = promatch\_timer::getTimePassed() + 70 * 1000;
	while ( healthPackTimeout > promatch\_timer::getTimePassed() )
		wait level.oneFrame;

	// Remove the health pack from the game
	thread destroyHealthPack( self, healthPackModel, healthPackGlow );
}

destroyHealthPack( healthPackTrigger, healthPackModel, healthPackGlow )
{
	// Destroy the trigger first
	healthPackTrigger delete();

	// Destroy the script model entity
	healthPackModel delete();
	
	if ( isDefined( healthPackGlow ) )
		healthPackGlow delete();
}

//medic pro - pode se curar e curar amigos
medic()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );
	
	if(!isAlive(self))
		return;
	
	if ( !self.medic)
	return;
 	
	//MEDIC PRO REVIVE
	if(isDefined( self.checkingBody ) && self.checkingBody && self.medicpro)
	{
		self MedicRespawn();
		return;
	}
	
   //ATE AQUI O MEDICO PODE PROCURAR POR FERIDOS
	teammate = self findClosestTeammate();  
  
	//se nao ha players perto, mostrar minimap possivel p
	if ( !isDefined( teammate ))
	{
		self iprintln("Procurando feridos...");
		
		
		self ShowMinimapTeammate();
		return;
	}
	
	if ( !self.medicpro )
	return;

	if (!isDefined( teammate ))
	return;

	if ( teammate.health >= getMaxHealth() )
	return;
	
	self thread healTeammate( teammate );
	
  
	return;
}  

healTeammate( teammate )
{ 

	//If we are already healing the teammate then lets stop
	if ( isDefined( self.isHealingTeammate ) && self.isHealingTeammate )
	{
		self.isHealingTeammate = false;
	}
	else
	{    
		self.isHealingTeammate = true;
		
    
		self iprintln( &"OW_MEDIC_SELF_HEAL", teammate );
		teammate iprintln( &"OW_MEDIC_TEAMMATE_HEAL", self );

		self stopPlayer( true );
		teammate stopPlayer( true );
    
		if(isDefined(teammate.medicmarker))
		bonusxp = 100;
		else
			bonusxp = 55;
    
		addingHealth = 0.0;
		remainingHealthPoints = 0.0;
		healEnds = promatch\_timer::getTimePassed() + level.scr_healthsystem_medic_healing_time * 1000;
		while ( isAlive( teammate ) && self.isHealingTeammate && healEnds > promatch\_timer::getTimePassed() )
		{
			//if ( ( isDefined( self.lastStand ) && self.lastStand ) || ( isDefined( teammate.lastStand ) && teammate.lastStand ) ) 
			//{
			//	remainingHealthPoints = 0;
			//	break;
			//}  

			addingHealth += ( level.scr_healthsystem_medic_healing_health / level.scr_healthsystem_medic_healing_time ) * level.oneFrame;
      
			//removed entity is not an entity:
			if(!isDefined( teammate ))
			break;
			
			if ( int( addingHealth ) >= 1 )
			{
				remainingHealthPoints += addingHealth - 1.0;
				//teammate LifeUpgrade(teammate.health + 2);
				teammate.health += 2;
				addingHealth = 0.0;
				
				if (teammate.health >= getMaxHealth() )
				{
					break;
				}
			}
			wait level.oneFrame;
		}
    
		if ( (teammate.health + int( remainingHealthPoints ) ) >= getMaxHealth() )
			teammate.health = getMaxHealth();
		else
			teammate.health += int( remainingHealthPoints ); 
    
		if(!isDefined( teammate ))
		{
			self.isHealingTeammate = false;
			return;
		}
		
		if ( self.isHealingTeammate )
		{  
			self.isHealingTeammate = false;
			
			//MEDIC			
			self iprintln( &"OW_MEDIC_HEALING_FULL" );
			self iprintln( "^2Vida: ^7" + teammate.health );
			//PLAYER
			teammate iprintln( &"OW_MEDIC_HEALING_FULL" );
			teammate LifeUpgrade(teammate.health);//atualiza o status da vida
			teammate.stoppoison = true;
			//BONUS
			//if(level.cod_mode == "public" && !isDefined(teammate.healedteammate))
			//self GiveEVP(5,100);
			
			teammate.healedteammate = true;//antifarm
		}
	}
  
     
	self stopPlayer( false );
	teammate stopPlayer( false ); 
  
	return;
}     

//SISTEMA DE PROCURA POR amigos
ShowMinimapTeammate()
{
	if ( !level.teamBased ) return;
	
	team = self.sessionteam;
  
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];

		//ignorar caso ja esteja marcado
		if(isDefined(player.needmedic) && player.needmedic == true)
		continue;
		
		if(isDefined(player.searchingbody))
		continue;
		
		if(player.pers["team"] != team)
		continue;
		
		if(self == player)
		continue;
	
		//se este jogador estiver morto mostrar ele no plano do jogador e pular o proximo check, para um vivo
		if (!isAlive( player ))
		{
			//se nao existe o corpo deste ignorar.
			if(!isDefined(player.body))
			continue;
			
			if(isDefined(self.squad))
			self thread ShowonCompass(player,true,self);
			continue;
		}
		
		if (isAlive( player ) && player.health < player.maxhealth)
		{       
			self iprintln("^1Ferido: ^7"+ player.name + " ^2Vida: ^7"+ player.health );
			player.needmedic = true;
			player thread ShowonCompass(player,false,self);
			player pingPlayer();			
		}
	}
}				

//tbm chamado do quickmsg
ShowonCompass(player,isdead,medic)
{
	self endon("disconnect");
	
	if( !isDefined( medic))
	return;
	
	player.searchingbody = true;
	
	if(isdead == true)
	{
		origin = player.body.origin + (0,0,20);
		shader = "specialty_quieter";//procurar um icone melhor
	}
	else
	{
		self.medicmarker = true;
		origin = player.origin + (0,0,20);
		shader = "specialty_longersprint";
	}
		
	
	objWorld = newTeamHudElem( self.pers["team"]);
	
	if(isdead == true)
	objWorld.name = "deadpointout_" + self getEntityNumber();
	else
	objWorld.name = "pointout_" + self getEntityNumber();
	
	objWorld.x = origin[0];
	objWorld.y = origin[1];
	objWorld.z = origin[2];
	objWorld.Alpha = 1;
	
	if( isDefined( medic.squad ) && isDefined( player.squad ) ) 
	{
		if( medic.squad == player.squad )
		{
			objWorld.Alpha = 1;
		}
	}
	else objWorld.Alpha = 0;
	
	objWorld.isFlashing = false;
	objWorld.isShown = true;
	objWorld setShader( shader, level.objPointSize, level.objPointSize );
	objWorld setWayPoint( true, shader );
		
	
	if(isdead == false)
	{
		//objWorld setTargetEnt( self );
		//objWorld thread maps\mp\gametypes\_objpoints::startFlashing();		
		objWorld thread MediciconPosition( player, self, 40, objWorld );
	}
	
	if(isdead == true)
	{
		xwait( 5, false );
		player.searchingbody = undefined;
		objWorld destroy();		
		return;
	}
	
	self thread deleteMarkerOnDeath(objWorld );
	
	xwait( 8, false );
	self notify( "medic_compass_deleted" );
	
	if(isAlive(self) && isDefined(objWorld))
	{
		//iprintln("^1 destruido obj");
		self.medicmarker = undefined;
		self.needmedic = false;
		objWorld notify("stop_flashing_thread");
		//objWorld thread maps\mp\gametypes\_objpoints::stopFlashing();
		objWorld destroy();
	}

}
///compassping_friendlyyelling_mp

MediciconPosition( target, owner, zOff, iconpos ) 
{
	self endon( "death" );
	
	while( 1 ) 
	{
		wait level.oneframe;

		headPos = target getTagOrigin( "j_head" );
		
		if( !isDefined( headPos ) ) 
		{
			self.alpha = 0;
			continue;
		}	
		
		iconpos.x = headPos[ 0 ];
		iconpos.y = headPos[ 1 ];
		iconpos.z = headPos[ 2 ] + zOff;
	}
}

deleteMarkerOnDeath(objWorld)
{
	self endon( "medic_compass_deleted" );
	self waittill_any( "death", "disconnect" );
	if(isDefined(self))
	{
		//iprintln("^1 morreu e resetou");
		self.medicmarker = undefined;
		self.needmedic = false;
	}
	objWorld notify("stop_flashing_thread");
	objWorld thread maps\mp\gametypes\_objpoints::stopFlashing();
	objWorld destroy();
}

getMaxHealth()
{
	return level.maxhealth;
}

MedicRespawn()
{
			
	if( (level.gameType == "tjn" || level.gameType == "dm" || level.gameType == "ctf" || level.gameType == "dom")) return;
		
	team = self.sessionteam;
	
	if(isDefined( self.checkingBody ) && self.checkingBody)
	{
		if(!isdefined(self.deadentity)) return;
		
		if(isdefined(self.deadentity.revived) || isdefined(self.deadentity.beheaded) && self.deadentity.beheaded) 
		{
			self iprintln("A vida deste ser ja foi para o alem.");
			self.deadentity iprintln("Sua vida miseravel ja acabou neste mundo.");
			return;
		}

		if(!isdefined(self.deadentity.pers["team"])) return;
		
		if(!isdefined(self.reviving)) return;
		
		//anti-xp farm
		if(self.reviving) return;		

		if(self.deadentity.pers["team"] != team && percentChance(20))
		{
			self thread ReviveTeammate(self.deadentity);//setado no dogtags
			self.deadentity.cantsuicide = true;//impedir q se mate
			self iprintln("Isso nao esta certo...");
			self.deadentity iprintlnbold("Nao se mova! .. nao perai.. esta morto ai? mas que merda voce hein!");
			self.deadentity iprintlnbold("Calma! Quase la!! ja ja...espera indo entrando de vagar");
			return;
		}
		else if(!isdefined(self.deadentity.revived) && self.deadentity.pers["team"] == team)
		{	
		
			if(percentChance(100))
			{
				//iprintln("percentChance"  + self.name);				
				self thread ReviveTeammate(self.deadentity);						
			}
		}
		else
		{
			self.deadentity.revived = true;
			self iprintln("Nao foi possivel reviver esse saco de bosta...");
			self.deadentity iprintlnbold("Medico tentou ne! mas nao deu... se fode ae!");
		}		
	}	
}



ReviveTeammate( teammate )
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	
	if(!isPlayer(teammate) || !isDefined(teammate) || !isdefined(teammate.class) || !isdefined(teammate.deathspawn))
		return;
		
	self.reviving = true;
	self stopPlayer( true );
			
	startTime = 0;
	
	if(self.upgradefastrevive)
	timetorevive = 5;
	else
	timetorevive = 8;
	
	//iprintln("ReviveTeammate"  + teammate.name);
	
	while ( isDefined(self) && !isAlive( teammate ) && self.reviving && startTime <= timetorevive )
	{
		self updateSecondaryProgressBar( startTime, timetorevive, false, "Revivendo..." );
		startTime++;
		wait(1);
	}

	//limpa a barra
	 if(isDefined(self))
	self updateSecondaryProgressBar( undefined, undefined, true, undefined );
	
	if(isDefined(teammate) && isdefined(teammate.class) && isdefined(teammate.deathspawn))
	{
		if(!isDefined(self.onhack))//Elite hack - se ativo nao dar XP
		{
			//fix XP Farm
			self thread [[level.onXPEvent]]( "revive" );
			self statAdds("DEATHS", 1 * -1);//bonus
			
			self SetRankPoints(20);
		}
		
		maps\mp\gametypes\_globallogic::givePlayerScore( "revive", self );
		
		teammate.revived = true;
		
		//upgrade
		if(isDefined(self.upgrademedicsmoke) && self.upgrademedicsmoke == 1)
		{
			self giveWeapon("smoke_grenade_mp");
			self SetWeaponAmmoClip( "smoke_grenade_mp", 2 );
			self SwitchToOffhand( "smoke_grenade_mp" );
		}
		
		teammate thread [[level.spawnPlayer]]();
		teammate setOrigin( teammate.deathspawn );
		if(teammate.deaths > 1 )
		{
			teammate.deaths--;
			teammate.deathCount--;
			
		}
		teammate SetRankPoints(10);
		teammate ExecClientCommand("goprone");
		
		if(level.cod_mode != "torneio")
		{
			teammate statAdds("DEATHS", 1 * -1);
			self statAdds("DEATHS", 1 * -1);
		}
		
		if(isDefined(self.onhack))//Elite hack se ativo pode reviver varias vezes
		teammate.revived = undefined;
	}
						
	self.reviving = false;
	self stopPlayer( false );
	self.checkingBody = false;
	//self.bot.stop_move = false;
} 


ReviveTeammatebot( teammate )
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );


	if(isDefined(teammate.beheaded) && teammate.beheaded)
	return;

	teammate.beingrevived = true;//fix many bots reviving.. kkkk

	
	self.reviving = true;
	self stopPlayer( true );
	
	startTime = 0;	
	timetorevive = 5;
	
	//iprintln("ReviveTeammatebot"  + teammate.name);
	//iprintln("ReviveTeammatebotdeathspawn"  + teammate.deathspawn);
	//iprintln("ReviveTeammatebot"  + teammate.name);
	
	self thread CheckBotHaveweapon(6);
	//self BotBuiltinBotAction( "+gocrouch" );
	while ( isDefined(self) && !isAlive( teammate ) && self.reviving && startTime <= timetorevive )
	{
		self updateSecondaryProgressBar( startTime, timetorevive, false, "Revivendo..." );
		self botAction("-gocrouch");
		self botAction("+goprone");
		startTime++;
		wait(1);
	}
	
	if(!self.incognito)
	self thread quicktaunts("taunt21");

	//limpa a barra
	 if(isDefined(self))
	self updateSecondaryProgressBar( undefined, undefined, true, undefined );
	
	if(isDefined(teammate) && isdefined(teammate.deathspawn))
	{	
		teammate.revived = true;		
		teammate thread [[level.spawnPlayer]]();
		teammate setOrigin( teammate.deathspawn );
		teammate.beingrevived = undefined;
		
		
		revivedtimeprone = 0;
		while ( revivedtimeprone < 3)
		{
			teammate botAction("-gocrouch");
			teammate botAction("+goprone");
			revivedtimeprone++;
			wait 1;
		}		
		
		teammate botAction("-gocrouch");
		
		if(teammate.deaths > 1 )
		{
			teammate.deaths--;
			teammate.deathCount--;			
		}
		
		//teammate ExecClientCommand("goprone");
	}
	
	self notify("playerrevived");
	
	self.reviving = false;
	self stopPlayer( false );
	self.checkingBody = false;
	self.bot.stop_move = false;
	
	
	//iprintln("ReviveTeammatebotstop_move"  + self.bot.stop_move);
} 