#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include promatch\_utils;

dospyplane()
{
	level endon( "game_ended" );
	
	if(isDefined(level.spyplane))
	return;


		
		
	self.spyplane = true;
	//in USE dont allow other
	level.spyplane = true;
	level.spyplanehealth = 300;
	
	self thread spawnspyplane();
}



spyplanetimer()
{
	level endon( "game_ended" );	
	
	timer = 0;
	
	while(timer < 27)
	{
		wait 1;
		timer++;	
	}	
	
	self notify( "spyplaneended" );
	
	level.spyplane  = undefined;
	
	if(isDefined(self))
	self delete();
}


spawnspyplane()
{
	level endon( "game_ended" );
	self.rLoc = GetPosition();
	self.spyplanemodel = spawn( "script_model", (self.rLoc[0]+(1150*cos(0)), self.rLoc[1]+(1150*sin(0)), self.rLoc[2]) );
	self.spyplanemodel setModel( "vehicle_uav" );
	self.spyplanemodel.rLoc = GetPosition();	
	self.spyplanemodel.maxhealth = level.spyplanehealth;
	
	//self.spyplanemodel setcontents(1);
	self.spyplanemodel setcandamage( true );
	
	self maps\mp\gametypes\_hardpoints::useRadarItem();
	//self playLocalSound( "radio_putaway");
	self statSets("TEAMBUFF",0);
	
	if(isDefined(self.teambufficon) && isDefined(self.teambufficon.icon))					
	self.teambufficon.icon.alpha = 0;
	
	if(self.upgradespydronepro)
	self thread signal();
	
	level.flyingdrone = true;
	
    self.spyplanemodel thread spyplanemove();
	self.spyplanemodel thread spyplanetimer();
	self.spyplanemodel thread damagespyplane();
}

GetPosition()
{
	location = (50,100,3000);

	return location;
}

spyplanemove()
{
    level endon( "game_ended" );
	self endon( "spyplaneended" );
	self endon( "disconnect" );
  

    while(level.flyingdrone)
	{
		for( k = 0; k < 360; k +=.9 ) // ??, circle(360°), speed(and direction +or-)
		{
			if(!level.flyingdrone)
			break;
			
			playfxontag( level.redlightblink, self, "tag_origin" );	

			location = (self.rLoc[0]+(1150*cos(k)), self.rLoc[1]+(1150*sin(k)), self.rLoc[2]);
			angles = vectorToAngles(location - self.origin);
			self moveTo(location,.1);
			self.angles = (angles[0],angles[1],angles[2]-35); //tilt (dőlés szög) //X Z Y
			wait .1;
					
		}
	}	
}

damagespyplane()
{
	self endon( "disconnect" );
	//self endon( "death" );
	self endon( "spyplaneended" );
	
	damageTaken = 0;
	timertodelete = 0;
	fallindowndrone = 1000;
	
	//iprintln(damageTaken);
	for (;;)
	{
		self waittill( "damage", damage, attacker, direction_vec, P, type );
		
		if( !isdefined( attacker ) || !isplayer( attacker ) )
		continue;
		
		attacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( damage );

		damageTaken += damage;

		playfxontag( level.fx_Sparks, self, "tag_origin" );	
		//iprintln(damageTaken);
		
		if(damageTaken >= self.maxhealth)
		{			
			self playSound( level.barrelExpSound );			
			break;
		}
	}

	playfxontag( level.droneexplosion, self, "tag_origin" );	

	while ( timertodelete < 5)
	{
		timertodelete++;
		playfxontag( level.fuelexplosion, self, "tag_origin" );			
		//self moveTo((50,-100,3900 - 500),.5);
		xwait (0.6,false );				
	}
	
			
	playfxontag( level.droneexplosion, self, "tag_origin" );
	self playSound( level.barrelExpSound );
	playfxontag( level.droneexplosionhuge, self, "tag_origin" );
	wait 1;	
	//playfxontag( level.fuelexplosion, self, "tag_origin" );	
	level.flyingdrone = false;
	level.spyplane  = undefined;		
	
	if(isDefined(self))
	self delete();
	
    self notify( "spyplaneended" );
}

