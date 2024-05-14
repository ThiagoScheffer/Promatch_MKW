#include maps\mp\gametypes\_hud_util;

#include promatch\_eventmanager;
#include promatch\_utils;

init()
{
	// Get the main module's dvar
	level.scr_dogtags_enable = getdvarx( "scr_dogtags_enable", "int", 0, 0, 1 );
	
	// If dog tags are not enabled then there's nothing else to do here
	if ( level.gametype == "tgr" || level.gametype == "dm" || level.gametype == "gg")
	return;
		
	// Precache the dogtag shader
	precacheShader( "dogtag" );
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onPlayerKilled", ::onPlayerKilled );
	self thread onPlayerBody();
}


onPlayerSpawned()
{
	// Initialize some variables and create the HUD elements
	self.checkingBody = false;
	//marca o corpo como revistado
	self.looted = false;
	
	self.dogTags["name"] = createFontString( "default", 1.4 );
	self.dogTags["name"].alpha = 0;
	self.dogTags["name"] setPoint( "LEFT", "LEFT", 20, 0 );
	self.dogTags["name"].hideWhenInMenu = true;
	self.dogTags["name"].archived = true;
	
	self.dogTags["image"] = createIcon( "dogtag", 16, 16 );
	self.dogTags["image"].alpha = 0;
	self.dogTags["image"] setPoint( "LEFT", "LEFT", 2, 0 );
	self.dogTags["image"].hideWhenInMenu = true;
	self.dogTags["image"].archived = true;
	
	// Remove this player's body
	if ( isDefined( self.body ) ) 
	{
		self.body delete();
		self.body = undefined;
	}
	// Remove also the body trigger
	if ( isDefined( self.bodyTrigger ) ) 
	{
		self.bodyTrigger delete();
		self.bodyTrigger = undefined;
	}
	
	// Remove also the tomb 
	if ( isDefined( self.item ) ) 
	{
		if(self.item[0].istomb)
		{
			self.item[0].istomb = undefined;
			self.item[0] delete();
			
		}
	}
	
	
}


onPlayerKilled()
{

	// Hide the HUD elements
	if (isDefined( self.dogTags ) ) 
	{		
		if(isDefined(self.dogTags["image"]))		
		self.dogTags["image"] destroy();
	
		if(isDefined(self.dogTags["name"]))
		self.dogTags["name"] destroy();		
	}
}


onPlayerBody()
{
	self endon("disconnect");
	
	while(1) 
	{
		self waittill("player_body");
		
		if ( isDefined( self.body ) ) 
		self thread dogTagMonitor();
	}
}

//eu morri aqui. sera criado um trigger do meu corpo
dogTagMonitor()
{
	self endon("spawned_player");
	self endon("disconnect");
	level endon( "game_ended" );
	
	if ( level.inReadyUpPeriod || level.inStrategyPeriod || level.inGracePeriod )
	return;
	
	// Wait until the body is not moving anymore
	self.body maps\mp\gametypes\_weapons::waitTillNotMoving();
	
	// Create the trigger we'll be using for players to check the dog tags
	if(isDefined(self.body))
	{
		self.bodyTrigger = spawn( "trigger_radius", self.body.origin, 0, 32 , 32 );
		self.bodyTrigger.name = self.name;
		self.bodyTrigger.team = self.pers["team"];
		self thread removeTriggerOnDisconnect();
		
		while(1) 
		{
			wait level.oneFrame;
			self.bodyTrigger waittill("trigger", player);
			
			if(!isDefined(player.checkingBody))
			continue;
			
			//BOT MEDIC PRO REVIVE
			if (isDefined( player.pers[ "isBot" ] ) && player.pers[ "isBot" ] && level.gametype == "sd")
			{
				if (isDefined( self.bodyTrigger ) && player isTouching( self.bodyTrigger ) && player.medicpro && !player.checkingBody && !isDefined(self.beingrevived )) 
				{
					
					if(self.bodyTrigger.team == player.pers["team"])
					{
						//iprintlnbold(player.name + " => bodyTrigger -> " + self.bodyTrigger.name);
						player.deadentity = self.deadentity;
						player.checkingBody = true;
						player thread promatch\_medic::ReviveTeammatebot(self);
						player.bot.stop_move = true;
					}		
					
				}
			}			
	
			if ( !player.checkingBody ) 
			{
				player.checkingBody = true;
				player thread monitorCheckDogTag( self );
			}
		}
	}
}


removeTriggerOnDisconnect()
{
	self endon("spawned_player");
	
	// Save the body and trigger
	body = self.body;
	bodyTrigger = self.bodyTrigger;
	
	// Wait for the player to disconnect and remove his body and trigger from the game
	self waittill("disconnect");
	
	if ( isDefined( body ) )
		body delete();
		
	if ( isDefined( bodyTrigger ) )
		bodyTrigger delete();
}


monitorCheckDogTag( deadPlayer )
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );
	
	self.deadentity =  deadPlayer;
	// Stay here as long as the body exists and the player is touching it
	while ( isDefined( self ) && isDefined( deadPlayer.body ) && isDefined( deadPlayer.bodyTrigger ) && self isTouching( deadPlayer.bodyTrigger ) ) 
	{
		wait level.oneFrame;
		
		// Check if the player is crouched or proned
		if ( isDefined( self ) && ( self getStance() == "crouch" || self getStance() == "prone" ) ) 
		{
			if(isDefined( deadPlayer ))//fix removed ent
			{
				// Update the information with the dead player's name and show the HUD elements
				if(isDefined( self.dogTags["name"] ))
				self.dogTags["name"] setPlayerNameString( deadPlayer );
				
				if(isDefined( self.dogTags["name"] ))
				self.dogTags["name"] fadeOverTime(1);
				
				if(isDefined( self.dogTags["image"] ))
				self.dogTags["image"] fadeOverTime(1);
			
				if(isDefined( self.dogTags["image"] ))
				self.dogTags["name"].alpha = 1;
			
				if(isDefined( self.dogTags["image"] ))
				self.dogTags["image"].alpha = 1;
				
				//self.isonbody = true;
				
				//===LOOTING VIP ===
				if(!deadPlayer.looted && isAlive(self) && self.upgradescavenger)
				{
					self iprintln("^3Revistando corpo....");
							
					if(percentChance(30))
					{					
						evpsx = randomInt(20);
						self statAdds("EVPSCORE", evpsx );
						self iprintlnbold("^1##Voce ganhou $" + evpsx +" ##");
					}
				
				
				
					if(percentChance(25))
					{
					 self AddExtraAmmo(100);
					 self iprintlnbold("^1##Voce ganhou Municao##");
					}
					
					if(percentChance(15))
					{
						evpsx = randomInt(100);
						self statAdds("EVPSCORE", evpsx );
						self iprintlnbold("^1##Voce ganhou $" + evpsx +" ##");
					}
				
				
			
					if(percentChance(10))
					{
						self setPerk( "specialty_quieter" );
						self setPerk( "specialty_pistoldeath" );
						self iprintlnbold("^1##Voce ganhou Assassin Perk##");
					}		

					if(percentChance(20))
					{
						self setPerk( "specialty_quieter" );
						self iprintlnbold("^1##Voce ganhou o Quieter##");
					}
	
					if(percentChance(10))
					{
						self setPerk( "specialty_bulletaccuracy" );
						self setPerk( "specialty_grenadepulldeath" );
						self iprintlnbold("^1##Voce ganhou Rage Perk##");
					}								
				
					if(percentChance(15))
					{
						self thread LifeUpgrade(50);
						self iprintlnbold("^1##Voce ganhou Bonus de Vida##");
					}
					
				
					if(percentChance(3))
					{
						self statSets("TEAMBUFF",1);						
						
						//if (isDefined(self.teambufficon.icon))
						//self.teambufficon.icon.alpha = 1;
						
						self iprintlnbold("^1##Voce ganhou TeamBuff##");
					}
					
					if(percentChance(15))
					{
						evpsx = randomInt(50);
						self statAdds("EVPSCORE", evpsx );
						self iprintlnbold("^1##Voce ganhou $" + evpsx +" ##");
					}
					
					deadPlayer.looted = true;
				}				
			}
			//cannot cast undefined to bool: (file 'promatch/_dogtags.gsc', line 337)
			// Wait for the body to be removed, player leaving the trigger zone or player is not crouched or proned
			while ( isDefined( self ) && isDefined( deadPlayer.body ) && isDefined( deadPlayer.bodyTrigger ) && self isTouching( deadPlayer.bodyTrigger ) && ( self getStance() == "crouch" || self getStance() == "prone" ) )
				wait level.oneFrame;
				
			// Hide the HUD elements
			if ( isDefined( self ) )
			{
				if(isDefined( self.dogTags["name"] ))
				self.dogTags["name"].alpha = 0;
				
				if(isDefined( self.dogTags["image"] ))
				self.dogTags["image"].alpha = 0;
			}
		}
	}
	
	// Body is not there or the player is not touching the trigger anymore
	self.checkingBody = false;
}