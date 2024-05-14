#include promatch\_utils;



main()
{
	precacheShellShock("flashbang");
	//precacheShellShock("teargas");
}

flashRumbleLoop( duration )
{
	//self endon("stop_monitoring_flash");

	self endon("flash_rumble_loop");
	self notify("flash_rumble_loop");

	goalTime = getTime() + duration * 1000;

	while ( getTime() < goalTime )
	{
		self PlayRumbleOnEntity( "damage_heavy" );
		wait level.oneFrame;
	}
}


monitorFlash()
{
	self endon("disconnect");
	self.flashEndTime = 0;
	while(1)
	{
		self waittill( "flashbang", amount_distance, amount_angle, attacker , P );

		if ( !isalive( self ) || level.inReadyUpPeriod )
			continue;
		
		if(level.cod_mode == "practice" && isdefined(self.nodamage) && self.nodamage == true)
		continue;
				
		//PERK TACRESIST
		if(self.tacresist)
			continue;
			
		if(self.nadeimmune)
			continue;	
	
		hurtattacker = false;
		hurtvictim = true;
		//LookatPos = anglesToForward( self getPlayerAngles() );
		//LookatPosattacker = anglesToForward( attacker getPlayerAngles() );
		//iprintln("FlashGrenades->: ATtacker " + LookatPosattacker + " " + LookatPos + "  amount_distance: " + amount_distance + " Ang: " + amount_angle );

		if ( amount_angle < 0.35 )
			amount_angle = 0.35;
		else if ( amount_angle > 0.8 )
			amount_angle = 1;

		duration = amount_distance * amount_angle * 6;

		if ( duration < 0.25 )
			continue;

		rumbleduration = undefined;
		if ( duration > 2 )
			rumbleduration = 0.85;
		else
			rumbleduration = 0.25;

		assert(isdefined(self.pers["team"]));
		
		//controla efeito flash
		if (level.teamBased && isdefined(attacker) && isdefined(attacker.pers["team"]) && attacker.pers["team"] == self.pers["team"] && attacker != self)
		{
			if(!attacker.ffkiller) // no FF
			{
				continue;
			}			
		}
		
		if (hurtvictim)
			self thread applyFlash(duration, rumbleduration);
		if (hurtattacker)
			attacker thread applyFlash(duration, rumbleduration);
	}
}

applyFlash(duration, rumbleduration)
{
	if ( !isDefined( self.flashDuration ) || duration > self.flashDuration )
	{
		self notify ("strongerFlash");
		self.flashDuration = duration;
	}
	else if( duration < self.flashDuration )
		return;

	if ( !isDefined( self.flashRumbleDuration ) || rumbleduration > self.flashRumbleDuration )
		self.flashRumbleDuration = rumbleduration;

	wait level.oneFrame;

	if ( isDefined( self.flashDuration ) )
	{
		self shellshock( "flashbang", self.flashDuration + 1);
		self.flashEndTime = getTime() + (self.flashDuration * 1000);
	}

	self thread overlapProtect(duration);

	if ( isDefined( self.flashRumbleDuration ) )
	{
		self thread flashRumbleLoop( self.flashRumbleDuration );
	}

	self.flashRumbleDuration = undefined;
}

overlapProtect(duration)
{
	self endon( "disconnect" );
	self endon ( "strongerFlash" );
	for(;duration > 0;)
	{
		duration -= 0.05;
		self.flashDuration = duration;
		wait level.oneFrame;
	}
}

isFlashbanged()
{
	return isDefined( self.flashEndTime ) && gettime() < self.flashEndTime;
}
