#include promatch\_utils;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
init()
{
	precacheModel( "com_plasticcase_beige_big" );
	precacheModel( "vehicle_cobra_helicopter_fly" );
	precacheItem( "airstrike_mp" );
	precacheItem( "artillery_mp" );

	level.packagecratemodel = "com_plasticcase_beige_big";
	level.chopperpackage = undefined;
}



CarePackage()
{

	if(isDefined(level.chopperpackage)) return;
	
	if(!level.teambased) return;

	if(isDefined(self.packagecrate))
	self.packagecrate = undefined;
	
	//if(isDefined(level.chopperpackage))
	//level.chopperpackage = [];
	
	self notify( "CarePackOver" );
	self thread CarePackageFunc();
}


CarePackageFunc()
{
	//self endon ( "death" );
	self endon ( "disconnect" );
	
	//self waittill( "grenade_fire", GrenadeWeapon );
	//self thread GrenadeOriginFollow2( GrenadeWeapon );
	self thread SelectDropOrigin();
	
	self waittill( "confirm_location" );
	wait 2;
	
	if(!isDefined(self.droppackagelocation))
	return;
	
	//ja tem algo no meio ou rodando??
	if(isDefined(level.chopperpackage))
	{
		level.chopperpackage Delete();	
		level.chopperpackage = undefined;
		return;
	}	
	
	self.LockMenu = false;
	level.chopperpackage = spawnHelicopter(self, (3637, 10373, 750), self.angles, "cobra_mp", "vehicle_cobra_helicopter_fly");
	level.chopperpackage playLoopSound( "mp_cobra_helicopter" );
	
	self.packagecrate = spawn( "script_model", (0,32,20) );
	self.packagecrate setmodel(level.packagecratemodel);
	self.packagecrate LinkTo( level.chopperpackage, "tag_ground" , (0,32,20) , (0,0,0) );
	self playLocalSound("carepackageincoming");	
	self statSets("TEAMBUFF",0);
	
	if(isDefined(self.teambufficon) && isDefined(self.teambufficon.icon))					
	self.teambufficon.icon.alpha = 0;
	
	self showtextfx3("CAREPACKAGE VINDO...",4,"blue");
	level.chopperpackage.currentstate = "ok";
	level.chopperpackage.laststate = "ok";
	level.chopperpackage setdamagestage( 3 );
	level.chopperpackage setspeed(1000, 25, 10);
	level.chopperpackage setvehgoalpos( self.droppackagelocation + (-30, 40, 750), 1);
	//self linkTo( self.packagecrate);
	wait 15;
	
	
	self.packagecrate Unlink();
	fall = bullettrace(self.packagecrate.origin, self.packagecrate.origin + (0, 0, -10000), false, self);
	time = CareSpeed(500, self.packagecrate.origin, fall["position"]);
	self.packagecrate moveto(fall["position"], time);
	self showtextfx3("CAREPACKAGE DROPADO",4,"green");
	wait time;
	//self Unlink();
	self.packagecrate thread DeleteBoxOvertime(self);
	
	//undefined is not an entity: (file 'promatch/_carepackage.gsc', line 90)
	//level.chopperpackage setvehgoalpos((6516, 2758, 1714), 1);
	if(!isDefined(level.chopperpackage))
	{
		level.chopperpackage = undefined;
		return;
	}
	
	level.chopperpackage setvehgoalpos((6516, 2758, 1714), 1);
	self thread DestroyCareChopper();
	//level.Point = NewHudElem();
	//level.Point.x = self.packagecrate.origin[0];
	//level.Point.y = self.packagecrate.origin[1];
	//level.Point.z = self.packagecrate.origin[2]+15;
	//level.Point setShader("waypoint_bombsquad",14,14);
	//level.Point setwaypoint(true);
	self thread CareTrigger();
}

CareTrigger()
{
	self endon( "CarePackOver" );
	self endon( "Disconnect" );
	
	self.CareGot = false;
	
	if(!isDefined(self.Itensinthebox))
	self.Itensinthebox = [];
	
	//caixa de elementos variaveis
	//newElement = self.itenscomprados.size;
	
	level.Itensinthebox = [];
	level.Itensinthebox[ level.Itensinthebox.size ] = "Juggernaut";
	level.Itensinthebox[ level.Itensinthebox.size ] = "Stealth Killer";
	level.Itensinthebox[ level.Itensinthebox.size ] = "HitKill";
	level.Itensinthebox[ level.Itensinthebox.size ] = "Sixthsense ";
	level.Itensinthebox[ level.Itensinthebox.size ] = "moneybox";
	level.Itensinthebox[ level.Itensinthebox.size ] = "Mbox";
	level.Itensinthebox[ level.Itensinthebox.size ] = "Weapons";


	self thread HintText();
		
	for(;;)
	{
		if(!isDefined(self)) break;
		
		if( Distance( self.origin, ( self.packagecrate.origin ) ) < 35 )
		{
			self.Hnt = "Segure o [{+activate}] para pegar o CarePackage";
			if( self UseButtonPressed() )
			{
				self FreezeControls( true );
				self thread CreateBoxBar( "CENTER", "CENTER", 0, 120, 100, 4, ( 1, 1, 1 ), 1.5 );
				wait 1.5;
				self.PickedBoxIten = RandomInt(level.Itensinthebox.size);
				self SetCarePackegePerk(self.PickedBoxIten);
	
				self.packagecrate delete();
				
				//self.Progress["Bar"] DestroyElem();
				//level.Point destroy();
				self.CareGot = true;
				
				if(isDefined(level.chopperpackage))
				level.chopperpackage delete();
				
				if(isDefined(level.chopperpackage))
				level.chopperpackage = undefined;
				
				self FreezeControls( false );
				self notify( "CarePackOver" );
			}
		}
		wait 0.05;
	}
}

SelectDropOrigin()
{
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon ( "teleported" );
	//self iPrintln( "Teleport! Shoot to start.");
	//self Giveweapon("airstrike_mp");
	
	for(;;)
	{
		self waittill( "carepackageopenselect" );
		self beginLocationselection( "map_artillery_selector", 450 * 1.2 );
		self notify("droppackageselected");
		self.selectingLocation = true;
		self waittill( "confirm_location", location );
		newLocation = PhysicsTrace( location + ( 0, 0, 1000 ), location - ( 0, 0, 1000 ) );
		//self SetOrigin( newLocation );
		self.droppackagelocation = newLocation;
		self endLocationselection();
		self.selectingLocation = undefined;
		//self iPrintln( "^2You Teleported to " + newLocation );
		self notify("teleported");
	}
}


SetCarePackegePerk(perk)
{
	//player = self;
	self playSound("oldschool_pickup");
	
	//sameteam = ArraySameTeam();
	switch (perk)
		{
			case  0:			
				//iprintln(self);
				self setPerk( "specialty_armorvest" );
				self.flakjacket = true;
				self LifeUpgrade(800);
				self giveWeapon( "saw_reflex_mp" );
				self giveMaxAmmo( "saw_reflex_mp" );
				
				if(isDefined(self.playerarmor))
				{
					self.playerarmor.base = 0.2;
					self.playerarmor.currentarmor = 666;
					self.playerarmor.value setValue(666);
					self.playercapa.currenthelmet = 666;
					self.playercapa.base = 0.2;
					self.playercapa.value setValue(666);
					self.hasarmor = true;
				}
				
				self.changedmodel = undefined;
				self maps\mp\gametypes\_teams::playerModelForClass( "juggernaut" );
				self setClientDvars("jump_slowdownEnable",0,"jump_spreadAdd",1,"player_dmgtimer_timePerPoint",0,"player_dmgtimer_flinchTime",0,"player_dmgtimer_stumbleTime",0);
				self iPrintlnBold("^2Juggernaut");
						
			break;			
						
			case  1:
			
				//iprintln(self);
				self setPerk( "specialty_pistoldeath" );
				self.coldblooded = true;
				self.takedown = true;
				self.incognito = true;
				self setClientDvar( "compassMaxRange", 2500 );
				self setPerk( "specialty_quieter" );
				self setPerk( "specialty_gpsjammer" );
				self LifeUpgrade(120);
				self setClientDvars("compassEnemyFootstepEnabled",1,"compassEnemyFootstepMaxRange",800);
				
				if(isDefined(self.playerarmor))
				{
					self.playerarmor.base = 0.5;
					self.playerarmor.currentarmor = 250;
					self.playerarmor.value setValue(250);
					self.playercapa.currenthelmet = 250;
					self.playercapa.base = 0.5;
					self.playercapa.value setValue(250);
					self.hasarmor = true;
				}
				
				self iPrintlnBold("^8Stealth Killer");
			
			break;
			
			case  2:			
				//iprintln(self);
				self setPerk( "specialty_bulletdamage" );
				self.hardhit = true;
				self.piecinground = true;
				self.wallbang = true;
				self.hpround = true;
				self.dangercloser = true;
				self.oneshootkill = true;
				self LifeUpgrade(100);
				
				if(isDefined(self.playerarmor))
				{
					self.playerarmor.base = 0.5;
					self.playerarmor.currentarmor = 250;
					self.playerarmor.value setValue(250);
					self.playercapa.currenthelmet = 250;
					self.playercapa.base = 0.5;
					self.playercapa.value setValue(250);
					self.hasarmor = true;
				}
				
				self iPrintlnBold("^1HitKill");
			
			break;			
			
			case  3:
				if(isDefined(self.playerarmor))
				{
					self.playerarmor.base = 0.5;
					self.playerarmor.currentarmor = 250;
					self.playerarmor.value setValue(250);
					self.playercapa.currenthelmet = 250;
					self.playercapa.base = 0.5;
					self.playercapa.value setValue(250);
					self.hasarmor = true;
				}
				
				self LifeUpgrade(125);
				self giveWeapon( "frag_grenade_mp" );
				self giveMaxAmmo( "frag_grenade_mp" );
				self.gasmask = 1;
				self.antipoison = 1;
				self.antimag = 1;
				self setClientDvars("compassEnemyFootstepEnabled",1,"compassEnemyFootstepMinSpeed",10,"compassEnemyFootstepMaxRange",250);
				self setClientDvar( "compassMaxRange", 2500 );
				self setClientDvar( "compassRadarPingFadeTime",2);	
				self iPrintlnBold("^4Sixthsense Kit");			
			break;
			
			case  4:
				self LifeUpgrade(125);
				self GiveEVP(3500,100);
				self iPrintlnBold("^4Money Box");			
			break;
			
			case  5:
			{	
				if(randomint(25) == 1)
				{
					self giveWeapon( "rpg_mp" );
					self giveMaxAmmo( "rpg_mp" );				
					self giveWeapon( "frag_grenade_mp" );
					self giveMaxAmmo( "frag_grenade_mp" );	
					self SetActionSlot( 3, "weapon", "rpg_mp" );
					self LifeUpgrade(333);
					self GiveEVP(3333,100);
					self thread gamblermonitor();
					self setPerk( "specialty_bulletdamage" );
					self.hardhit = true;
					self.piecinground = true;
					self.wallbang = true;
					self.hpround = true;
					self.dangercloser = true;
					self.oneshootkill = true;
					self setPerk( "specialty_armorvest" );
					self.flakjacket = true;			
					
					if(isDefined(self.playerarmor))
					{	
						self.hasarmor = true;
						self.playerarmor.base = 0.2;
						self.playerarmor.currentarmor = 666;
						self.playerarmor.value setValue(666);
						self.playercapa.currenthelmet = 666;
						self.playercapa.base = 0.2;
						self.playercapa.value setValue(666);
					}
					
					self setClientDvars("jump_slowdownEnable",0,"jump_spreadAdd",1,"player_dmgtimer_timePerPoint",0,"player_dmgtimer_flinchTime",0,"player_dmgtimer_stumbleTime",0);
					
					self iPrintlnBold("^4Pandora Box");
					return;
				}
				
				self SetCarePackegePerk(randomint(9));
				self iPrintlnBold("^4Reroll Box");
			}
			break;
			
			case  6:
				if(isDefined(self.hasarmor))
				{
					self.playerarmor.base = 0.5;
					self.playerarmor.currentarmor = 250;
					self.playerarmor.value setValue(250);
					self.playercapa.currenthelmet = 250;
					self.playercapa.base = 0.5;
					self.playercapa.value setValue(250);
				}
				
				self LifeUpgrade(125);				
				self giveWeapon( "rpg_mp" );
				self giveMaxAmmo( "rpg_mp" );
				self SetActionSlot( 3, "weapon", "rpg_mp" );				
				self giveWeapon( "frag_grenade_mp" );
				self giveMaxAmmo( "frag_grenade_mp" );				
				self giveWeapon( "saw_reflex_mp" );
				self giveMaxAmmo( "saw_reflex_mp" );	
				self iPrintlnBold("^4Weapon Box");			
			break;
		}
	
}
			
CreateBoxBar( align, relative, x, y, width, height, colour, time )
{
	self endon( "Disconnect" );
	
	ProgBar = createBar( colour, width, height, self );
	ProgBar setPoint( align, relative, x, y );
	ProgBar updateBar( 0, 1 / time );
	for( T = 0;T < time;T += 0.05 )
	wait .05;
	ProgBar DestroyElem();
}

DeleteBoxOvertime(player)
{
	self endon( "Disconnect" );
	player endon( "CarePackOver" );
	for(;;)
	{
		wait 50;
		if(isDefined(self.CareGot) && !self.CareGot)
		{
			self Delete();
			//player.Progress["Bar"] DestroyElem();
			level.Point Destroy();
			player notify( "CarePackOver" );
			player FreezeControls( false );
		}
	}
}
HintText()
{
	self endon( "Disconnect" );
	self endon( "CarePackOver" );
	
	self.Txt = self createFontString( "objective", 1.4 );
	self.Txt setPoint( "CENTER", "CENTER" );
	self.hnt = "";
	for(;;)
	{
		if(!isDefined(self))
		return;
		
		self.Txt setText("" + self.hnt);
		self.hnt = "";
		wait 0.1;
	}
}

CareSpeed(speed, origin, moveto)
{
	dist = distance(origin, moveto);
	time = (dist / speed);
	return time;
}

DestroyCareChopper()
{
	self endon( "Disconnect" );
	
	wait 10;
	if(isDefined(level.chopperpackage))
	level.chopperpackage Delete();
	
	if(isDefined(level.chopperpackage))
	level.chopperpackage = undefined;
}

GrenadeOriginFollow2( Gren )
{
	Gren endon( "explode" );
	for(;;)
	{
		self.Grenade = Gren.origin;
		wait .01;
	}
}