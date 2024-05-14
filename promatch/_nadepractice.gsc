// **************************************************************
// *  AM4 written by  Matthias Lorenz for www.eSports4all.com   *
// *  http://www.admiralmod.com
//Modified by EncryptorX									*

#include promatch\_eventmanager;
#include promatch\_utils;
#include maps\mp\gametypes\_hud_util;

//todo: Add Save position and load OK
//Clean some stuff OK
//Test all.  OK

init() 
{	
	thread ModeHud();

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );	
	
	level thread onPlayerConnect();
	
	//level thread DeleteByModel("ENTER MODEL NAME HERE");
	//level thread DeleteByNumber(ENTITY NUMBER HERE);
	
	precacheString( &"OW_EXTENDED_OBITUARY" );
	precacheShader( "hudStopwatch" );
	
}


//Hud Server Common
ModeHud()
{
	nadetraining = newHudElem();
	nadetraining.x = -8;
	nadetraining.y = 35;
	nadetraining.horzAlign = "right";
	nadetraining.vertAlign = "top";
	nadetraining.alignX = "right";
	nadetraining.alignY = "middle";
	nadetraining.fontScale = 1.5;
	nadetraining.font = "default";
	nadetraining.color = (1,0.5,0);
	nadetraining.hidewheninmenu = true;
	nadetraining setText( "Practice Mode" );

	position = newHudElem();
	position.x = -8;
	position.y = 50;
	position.horzAlign = "right";
	position.vertAlign = "top";
	position.alignX = "right";
	position.alignY = "middle";
	position.fontScale = 1.4;
	position.font = "default";
	position.color = (.8, 1, 1);
	position.hidewheninmenu = true;
	position setText( "ProMatch MW ^12021" );
}

onPlayerConnected()
{	
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}


onPlayerConnect()
{	
	level endon ( "game_ended" );
	
	
	
	for(;;)
	{	//add connected
		level waittill("connected", player);
		
		//Main Module
		player thread nadetraining();		
		
		//player thread TraceModel();
		
		//Hud Thread For Help tips
		player thread createHUD();
		
		//0306 aperfeiçoado o codigo
		player thread KeysMoni();
		
		//player.fixed = undefined;
	}
}


onPlayerSpawned()
{
	//self thread waitForKill();
	
	//self thread waitForDamages();
	//if(isdefined(self.fixed))
	//self.origin = self.fixed;
	wait 6;
	
	if(isDefined(self) && isDefined(self.pers["isBot"]))
	self thread RegenArmor();
}

waitForDamages()
{
	self endon("disconnect");	
	self waittill ( "damage", eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, fDistance );

	// Make sure the attacker is a player
	if ( !isPlayer( eAttacker ) )
	return;

	if(sWeapon == "gl_mp")
	return;
	

	
	/*if ( !isDefined( fDistance ) )
	fDistance = 0;
	distInches = fDistance;
	distMeters = int( distInches * 0.0254 * 10 ) / 10;
	distToShow = distMeters + "m";
	sWeapon = convertWeaponName( sWeapon );
	sHitLoc = convertHitLocation( sHitLoc );
	iprintln( &"OW_EXTENDED_OBITUARY", eAttacker.name, self.name, iDamage, sHitLoc, sWeapon, distToShow );*/

}
waitForKill()
{
	self endon("disconnect");	
	
	// Wait for the player to die
	self waittill( "player_killed", eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, fDistance );

	// Make sure the attacker is a player
	if ( !isPlayer( eAttacker ) )
	return;

	if(!isDefined(sWeapon))
	return;
	
	if(sWeapon == "gl_mp")
	return;
	
	showObituary = true;

	// Check if we should show detail about certain kills
	if ( self == eAttacker && level.scr_show_obituaries != 0 ) {
		showObituary = false;
	}

	// Check if we still need to show the extended obituary
	if ( !showObituary )
	return;

	if ( !isDefined( fDistance ) )
	fDistance = 0;
	distInches = fDistance;
	distMeters = int( distInches * 0.0254 * 10 ) / 10;
	distToShow = distMeters + "m";


	// Adjustment to the weapon name
	if ( sMeansOfDeath == "MOD_MELEE" ) 
	{
		sWeapon = "knife_mp";
	} 
	else if ( sMeansOfDeath == "MOD_SUICIDE" ) 
	{
		// Don't show extended obituary information
		return;	
	}

	// Convert the weapon name and hit location to the long description
	sWeapon = convertWeaponName( sWeapon );
	sHitLoc = convertHitLocation( sHitLoc );
	
	iprintln( &"OW_EXTENDED_OBITUARY", eAttacker.name, self.name, iDamage, sHitLoc, sWeapon, distToShow );
	
	return;
}

//got some problems. using arrays.
Nadetraining() 
{

	self endon( "disconnect" );
	for(;;)
	{	
		//Wait for player to Launch the nade.
		self waittill( "grenade_fire", grenade, grenadeTypePrimary );
		
		//rescue the evil egg
		grenadeType = getentarray("grenade","classname");
		
		for(i=0;i<grenadeType.size;i++) 
		{
			//Give the nade using the self give.
			self giveweapon(grenadeTypePrimary);
			self setWeaponAmmoClip(grenadeTypePrimary,1);
			
			if(isDefined(grenadeType[i].origin) && !isDefined(self.onfly) ) 
			{
				if(distance(grenadeType[i].origin, self.origin) < 145) 
				{			
					self.onfly = true;	
					grenadeType[i] thread Fly(self);		
				}				
			}
		}
		
		xwait (0.1,false);
	}
}
//207
getPlayerEyes()
{
	playerEyes = self.origin;
	switch ( self getStance() ) 
	{
		case "prone":
			playerEyes += (0,0,11);
			break;
		case "crouch":
			playerEyes += (0,0,40);
			break;
		case "stand":
			playerEyes += (0,0,60);
			break;
	}
	
	return playerEyes;	
}

bot()
{
	self endon("disconnect");
	origin =  self.origin; // minha orign
	angles = self getPlayerAngles();
	
	entbot = addtestclient();
	entbot.pers["isBot"] = true;
	entbot.vipuser = false;
	
	
	mystance = self getstance();
	//myweapon = self getCurrentWeapon();
	//objCompass = maps\mp\gametypes\_gameobjects::getNextObjID();
	xwait (0.05,false);

	if (isDefined(entbot) && self isOnGround()) 
		{
			self iprintln("Bot Added"); 		
			
			while( !isdefined(self.pers["team"]) )
			xwait( 1.0,false);
			
			entbot notify( "menuresponse", game["menu_team"], self.pers["team"] );

			if(!isDefined(entbot.pers["team"]))
			{
				entbot.pers["team"] = self.pers["team"];
				entbot.pers["class"] = self.pers["class"];
			}
			
			entbot SetClassbyWeapon("none"); 
			
			//entbot notify( "menuresponse", game["menu_changeclass_" + entbot.pers["team"] ],"assault" );
			xwait( 3.0,false);
			//entbot notify("menuresponse", game["menu_changeclass"] , "go");
			
			//entbot maps\mp\gametypes\_teams::playerModelForClass( self.pers["class"] );	
				
				
			entbot thread [[level.spawnPlayer]]();


			modelinfo = saveModel(self);
			entbot loadModel(modelinfo);		
			entbot.changedmodel = undefined;
			entbot loadModel(modelinfo);
				
				
			while(!isAlive(entbot)) 
			wait level.oneframe;
			
			if(isDefined(self.playerarmor) )
			{
				entbot.playerarmor.base = self.playerarmor.base;
				entbot.playerarmor.currentarmor = self.playerarmor.currentarmor;
				
				entbot.playercapa.currenthelmet = self.playercapa.currenthelmet;
				entbot.playercapa.base = self.playercapa.base;

				iprintln("Helmet> " + entbot.playercapa.currenthelmet);
				iprintln("Kevlar> " + entbot.playerarmor.currentarmor);
			}
			
			
			entbot freezeControls( false );
			
			//entbot.takedown = true;
			//entbot.incognito = true;
			//entbot.coldblooded = true;
		
			//if(isdefined(entbot.fixed))
			//	entbot setOrigin( entbot.fixed );
			//else			
			entbot setOrigin( origin );
			//entbot.fixed = 	origin;
			entbot SetPlayerAngles( angles );
			entbot.maxhealth = 9999; 
			//entbot.maxhealth = 100; //TESTE
			entbot.health = entbot.maxhealth;
			
			
			entbot thread botLookAtMe();
			
			
			
			//
			//entbot botaction("+fire");
			//entbot takeAllWeapons();//TESTE
			entbot setClientDvar( "player_sustainAmmo", 1 );
			
			
		/*
			if ( objCompass != -1 )
			{
				objective_add( objCompass, "active", entbot.origin + level.aacpIconOffset );
				objective_icon( objCompass, level.aacpIconCompass );
				objective_onentity( objCompass, entbot );
				if ( level.teamBased )
				{
					objective_team( objCompass, level.otherTeam[ entbot.pers["team"] ] );
				}
			}	

			objWorld = newHudElem();		
			origin = entbot.origin + level.aacpIconOffset;
			objWorld.name = "pointout_" + entbot getEntityNumber();
			objWorld.x = origin[0];
			objWorld.y = origin[1];
			objWorld.z = origin[2];
			objWorld.baseAlpha = 1.0;
			objWorld.isFlashing = false;
			objWorld.isShown = true;
			objWorld setShader( level.aacpIconShader, level.objPointSize, level.objPointSize );
			objWorld setWayPoint( true, level.aacpIconShader );
			objWorld setTargetEnt( entbot );
			objWorld thread maps\mp\gametypes\_objpoints::startFlashing();	
			*/
		}
		else if ( !isdefined(entbot))
		{
			self iprintln("Cant Add Bots. Zomb Ent Full or Invalide Mode");
			self iprintln("^1Restart the Server");
			xwait(2,false);
		}
}

/*
	short   j_spine4;
	short   j_helmet;
	short   j_head;
	j_spinelower ?

*/


RegenArmor()
{
	self endon( "disconnect" );
	self endon("death");
	self.startorigin = self.origin;
	
	for(;;)
	{	
		//self waittill("spawned_player");
		
		wait 5;
		
		self.ffkiller = true;
		self takeAllWeapons();//TESTE
		self giveWeapon( "m16_mp" );
		self giveMaxAmmo( "m16_mp" );
		self setSpawnWeapon( "m16_mp" );
		
		self SetClassbyWeapon("G36C"); 

		//self iprintln("Bot myweapon"+ myweapon); 
			
		
		if(!isDefined(self.playerarmor))
		continue;
		
		if(!isDefined(self.playercapa))
		continue;
		
		if(self.playerarmor.currentarmor < 70)
		{
			iprintln("->playerarmor.currentarmor Zerou");
			
			firstPlayer = FindPlayers();
			//restaura coletes do bot
			if(isDefined(firstPlayer) && isAlive(firstPlayer))
			{
				iprintln("firstPlayer: " + firstPlayer.name);
				if(isDefined(firstPlayer.playerarmor) )
				{
					iprintln("Regenplayerarmor.currentarmor: " + firstPlayer.playerarmor.currentarmor);
					iprintln("Regenplayerarmor.currentarmor: " + firstPlayer.playercapa.currenthelmet);
				
					self.playerarmor.base = firstPlayer.playerarmor.base;
					self.playerarmor.currentarmor = firstPlayer.playerarmor.currentarmor;			
					self.playercapa.currenthelmet = firstPlayer.playercapa.currenthelmet;
					self.playercapa.base = firstPlayer.playercapa.base;
					currentWeapon = self getCurrentWeapon();
					self giveMaxAmmo( currentWeapon );	
				}
			}
		}

		//move
		//self BotMove(self.origin + (0,0,100));
		//dodging so wait a while
		//wait randomfloatrange(1,2);
		
		//backtorigin
		//self BotMove(self.origin + (0,0,-100));
	}
}
//wat
RamdomLock()
{
	local = randomInt(2);
	
	if(local == 1)
	return "j_head";
	else
	return "j_spinelower";
}

botLookAtMe()
{
	self endon("death");
	self endon( "disconnect" );
	
	
	
	for(;;)
	{
		players = level.players;

		
		firstPlayer = FindPlayers();
		
		if(!isDefined(firstPlayer)) // no player there
		{
			wait 10;
			
			firstPlayer = FindPlayers();
			

		}
		
		//gostand gocrouch goprone fire melee frag smoke reload sprint leanleft leanright ads holdbreath.
		while(isalive( firstPlayer ) )
		{	
			if(!isDefined(firstPlayer))
			return;
		
			self botLookAt(firstPlayer.origin,0.08);
			self botLookAtPlayer(firstPlayer,RamdomLock());//j_spinelower pelvis
			self botaction("+ads");
			self botaction("+fire");			
			wait 0.05;
		}
		self botstop();
		
		//currentWeapon = self getCurrentWeapon();
		//self giveMaxAmmo( currentWeapon );
			
		if(isDefined(firstPlayer) && !isAlive(firstPlayer))
		wait 10;
	

		
	}
}

FindPlayers()
{
		firstPlayer = undefined;
		players = level.players;		
		for(i=0;i<players.size;i++)
		{
			if(!isDefined(players[i].pers["isBot"]) && isAlive(players[i])) // is not a bot
			{
				firstPlayer = players[i];
				break;
			}
			xwait(3,false);
		}
		
		return firstPlayer;
}

//Todo Clean the code.
Fly(player)
{
	player endon("joined_spectators");
	player endon( "disconnect" );
	
	old_player_origin = player.origin;	
	
	player.hilfsObjekt = spawn("script_model", player.origin );
	//player.hilfsObjekt.angles = player.angles;
	player.hilfsObjekt linkto(self);
	
	player linkto(player.hilfsObjekt);

	stopfly = false; //Attack
	flying = false; //F

	
	while ( isDefined(self) ) 
	{
		
		if(player attackButtonPressed())
		{
			stopfly = true;
			break;
		}
		
		
		if(player useButtonPressed()) 
		{
			flying = true;
			break;
		}
		
		wait level.oneFrame;		
	}
	
	xwait( 0.1,false);

	player.hilfsObjekt unlink();
	
	if(stopfly)
	{
		for(i=0; i < 3.5 ;i += 0.1) 
		{
			xwait (0.1,false);
			
			if( player useButtonPressed() ) 
			break;		
		}
	}
	
	

	if ( isDefined ( player.hilfsObjekt ) )		
	player.hilfsObjekt moveto( old_player_origin, 0.1 );
	
	xwait ( 0.2,false );
	
	player unlink();
	
	player.onfly = undefined;
	
	if(isDefined(player.hilfsObjekt))
	player.hilfsObjekt delete();	
	
}		


//change to monitor keys for better coding;
//humm someproblems with bombplant..
//now its ok added a isonground check and planting;defu.
//Some new problem on Loading...fixed
KeysMoni()
{
	self endon("disconnect");
	
	for (;;)
	{
		//Botao Melee Salvar
		wait level.oneFrame;
		if (self meleeButtonPressed() )
		{
			count = 0;
			while ( self meleeButtonPressed() && count < 4 )
			{
				wait level.oneFrame;
				count += 0.2;
			}
			if (count >  2 )
			{	//0308
				if (level.teamBased && level.gametype == "sd")
				{
					if ( ( isdefined( self.isDefusing ) && !self.isDefusing ) || ( isdefined( self.isPlanting ) && !self.isPlanting ) )
					{
						save();
					}
				} else
				{
					save();
				}
			}
			
			xwait (0.1,false);
		}

		//Botao F Carregar
		if (  self useButtonPressed() )
		{
			count =0;
			while ( self useButtonPressed() && count < 4)
			{
				wait level.oneFrame;
				count += 0.2;

			}
			if (count > 2 ) 
			{
				if (( isdefined( self.isDefusing ) && self.isDefusing ) || ( isdefined( self.isPlanting ) && self.isPlanting ))
				{
					//This fixed;
					xwait (6.5,false);					
				}
				else
				{
					load();
				}			
			}
			
			xwait (0.1,false);
		}
		
		
		wait level.oneFrame;
	}
	
}			


load()
{	
	if (!isdefined(self.saveo))
	{
		self iprintln("No Position ^2Saved");
	}
	else
	{
		self freezecontrols( true );
		xwait (0.1,false);
		self setOrigin( self.saveo);
		self SetPlayerAngles ( self.savea );
		self freezecontrols( false );
		self iprintln("Position ^2Loaded");
	}

}


save()
{
	if ( !self isOnGround() )
	return; 
	self.saveo = self.origin;
	self.savea = self getPlayerAngles();
	self iprintln("New Position ^2Saved");
}


//Hud Clientes
createHUD()
{
	self.hint2 = newClientHudElem(self);
	//Laterais
	self.hint2.x = -8;
	//y altura
	self.hint2.y = 120;
	self.hint2.horzAlign = "right";
	self.hint2.vertAlign = "top";
	self.hint2.alignX = "right";
	self.hint2.alignY = "middle";
	self.hint2.fontScale = 1.4;
	self.hint2.font = "default";
	self.hint2.hidewheninmenu = true;
	self.hint2 setText( "^7Press ^1[{+attack}] ^7: Stop Fly" );

	self.hint3 = newClientHudElem(self);
	self.hint3.x = -8;
	self.hint3.y = 135;
	self.hint3.horzAlign = "right";
	self.hint3.vertAlign = "top";
	self.hint3.alignX = "right";
	self.hint3.alignY = "middle";
	self.hint3.fontScale = 1.4;
	self.hint3.font = "default";
	self.hint3.hidewheninmenu = true;
	self.hint3 setText( "^7Press ^1[{+activate}]^7 : Return" );
	
	//B4
	self.hint3 = newClientHudElem(self);
	self.hint3.x = -8;
	self.hint3.y = 150;
	self.hint3.horzAlign = "right";
	self.hint3.vertAlign = "top";
	self.hint3.alignX = "right";
	self.hint3.alignY = "middle";
	self.hint3.fontScale = 1.4;
	self.hint3.font = "default";
	self.hint3.hidewheninmenu = true;
	self.hint3 setText( "^7Press ^1[{mp_QuickMessage}] + 4 ^7 for more." );
	
	//Save
	self.hint3 = newClientHudElem(self);
	self.hint3.x = -8;
	self.hint3.y = 165;
	self.hint3.horzAlign = "right";
	self.hint3.vertAlign = "top";
	self.hint3.alignX = "right";
	self.hint3.alignY = "middle";
	self.hint3.fontScale = 1.4;
	self.hint3.font = "default";
	self.hint3.hidewheninmenu = true;
	self.hint3 setText( "^7Hold ^1[{+melee}]^7 to Save Pos. " );
	
	//Load
	self.hint3 = newClientHudElem(self);
	self.hint3.x = -8;
	self.hint3.y = 180;
	self.hint3.horzAlign = "right";
	self.hint3.vertAlign = "top";
	self.hint3.alignX = "right";
	self.hint3.alignY = "middle";
	self.hint3.fontScale = 1.4;
	self.hint3.font = "default";
	self.hint3.hidewheninmenu = true;
	self.hint3 setText( "^7Hold ^1[{+activate}]^7 to Load Pos." );
	
	
	//Hud Modos
	self.hint3 = newClientHudElem(self);
	self.hint3.x = -8;
	self.hint3.y = 75;
	self.hint3.horzAlign = "right";
	self.hint3.vertAlign = "top";
	self.hint3.alignX = "right";
	self.hint3.alignY = "middle";
	self.hint3.fontScale = 1.4;
	self.hint3.font = "default";
	self.hint3.color = (.9, 1, 1);
	self.hint3.hidewheninmenu = true;
	self.hint3 setText( "^2Mode^7: Nade" );
	
}

