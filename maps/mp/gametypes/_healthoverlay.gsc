#include promatch\_utils;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include promatch\_eventmanager;
//Original Code from OpenWarfare
init()
{
	//precacheShader("overlay_low_health");

	level.healthOverlayCutoff = 0.55; // getting the dvar value directly doesn't work right because it's a client dvar getdvarfloat("hud_healthoverlay_pulseStart");

	regenTime = 10;//level.scr_player_healthregentime;

	level.playerHealth_RegularRegenDelay = regenTime * 1000;

	level.healthRegenDisabled = (level.playerHealth_RegularRegenDelay <= 0);

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
	
	
}

onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onPlayerDeath", ::onPlayerDeath );
	self thread addNewEvent( "onJoinedSpectators", ::onJoinedSpectators );
}

onJoinedSpectators()
{
	self setClientDvar( "r_brightness", 0 );
	self setClientDvar( "r_contrast", 1 );
}

//todo o spawn este codigo executa novamente
onPlayerSpawned()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );
	
	//usado para banir offline
	if(getDvar( "AutoBanHacker" ) == self getguid())
	{
		self thread AutoBanHacker();
		setDvar("AutoBanHacker", "");
	}

	
	//if(!isDefined(self.Class)) return;

	
	
//================SOMENTE MODO PUBLICO==================
	
//======================================================

	//Tempo para comprar
	self.canbuy = undefined;
	
	self thread cantimerbuy();
	
//======================================================	
//===============ATUALIZANDO STATS DE ITENS=============
//======================================================
	
	wait 1.5;
	
	while ( level.inReadyUpPeriod )
	wait 1;
	
	if(level.cod_mode == "torneio") 
	{
		self thread CreateItemIcon(false);
		//self thread playerHealthRegen();
		return;
	}
	
	//player incomodando toda hora -em testes
	//if ( self statGets("PLAYERELEVATOR") != 0){self thread WatchElevatorShit();}
	if(level.cod_mode == "public") 
	{
		//if(self.medicpro && self.upgradefastRegen)
		//self thread playerHealthRegen();
		
		//items aplicados
		self thread ApplyItemtoPlayer();
	}
}

cantimerbuy()
{
	//nao finalizar ao morrer para evitar bugs
	self endon( "disconnect" );
	//evita uma outra thread de abrir
	self notify( "cantimerbuy" );
	self endon( "cantimerbuy" );
	
	//caso abra uma nova thread
	if(isDefined(self.canbuy)) return;
	
	self.canbuy = true;
	
	endTime = GetTime() + 22000; 
	
	
	self showtextfx2( "Compra liberada!" );
	
	while ( endTime > GetTime() )
	{
		if(!self isMoving())		
		xwait (1,false );
		else
		break;
	}
	
	self showtextfx2( "Periodo de compra acabou.");
	ShowDebug("self.canbuy","self.canbuy - off");
	self.canbuy = undefined;
}


onPlayerDeath()
{	
	self thread CreateItemIcon(true);	
}

playerHealthRegen()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "joined_team" );
	self endon ( "joined_spectators" );
	level endon ( "game_ended" );
	self endon("onberserker");//caso o jogador entre em modo berserker
	
	if(level.atualgtype == "gg") return;
	
	//load time for others stuff
	wait(5);
	
	if(!isDefined(self))
	return;
			
	if ( self.health <= 0 )
	{
		assert( !isalive( self ) );
		return;
	}
	
	maxhealth = self.maxhealth;
	oldhealth = maxhealth;
	player = self;
	health_add = 0;

	regenRate = 0.1; // 0.017;
	veryHurt = false;
	
	lastSoundTime_Recover = 0;
	hurtTime = 0;
	newHealth = 0;

	for (;;)
	{
		wait level.oneFrame;

		if(!isDefined(player))
		return;
		
		if (player.health >= maxhealth)
		{
			veryHurt = false;
			self.atBrinkOfDeath = false;
			
			if(isDefined(player.playerhealth))
			player.playerhealth.value setValue(player.health);
			
			continue;
		}

		if (player.health <= 0)
		return;
		
		wasVeryHurt = veryHurt;
		ratio = player.health / maxHealth;
		if (ratio <= level.healthOverlayCutoff)
		{
			veryHurt = true;
			if (!wasVeryHurt)
			{
				hurtTime = gettime();
			}
		}

		if (player.health >= oldhealth)
		{
			if (gettime() - hurttime < (level.playerHealth_RegularRegenDelay))
			continue;

			if (veryHurt)
			{
				newHealth = ratio;
				if (gettime() > hurtTime + 3000)
				newHealth += regenRate;
			}
			else
			newHealth = 1;

			if ( newHealth >= 1.0 )
			{
				newHealth = 1.0;
			}

			if (newHealth <= 0)
			{
				// Player is dead
				return;
			}

			player setnormalhealth(newHealth);
			oldhealth = player.health;
			
			continue;
		}

		oldhealth = player.health;

		health_add = 0;
		hurtTime = gettime();
	}
}


WatchElevatorShit()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	//ANTIELEVE
	heightTracker = 0;
	lastDistance = 0;
	
	for (;;)
	{
	
		wait 5;
					
		if(!isDefined(self))
		break;
		
		if ( !( self isOnGround() ) && !( self isMantling() ) && !( self isOnLadder()) ) 
		{
			playerOrigin = self.origin;

			//distance from the player to the ground
			groundOrigin = playerphysicstrace( playerOrigin, playerOrigin + (0,0,-1000) );
			newDistance = int( distance( playerOrigin, groundOrigin ) );

			// If distance is higher than the one measured before then the player might be jumping
			if ( newDistance > lastDistance ) 
			{
				heightTracker++;
				//iprintln("heightTracker: " + heightTracker);
				
				if ( heightTracker >= 3 ) 
				{
					//iprintln("NewD: " + newDistance);
					//iprintln("LastD: " + lastDistance);
					heightTracker = 0;
					if(newDistance > 450)
						self suicide();

				}
			} else 
			{
				heightTracker = 0;
			}
			lastDistance = newDistance;
		} 
		else 
		{
			heightTracker = 0;
		}
		
	}
}