#include promatch\_utils;
#include maps\mp\gametypes\_hud_util;

init()
{
	precacheString(&"PLATFORM_PRESS_TO_SKIP");
	precacheString(&"PLATFORM_PRESS_TO_RESPAWN");
	precacheShader("white");
	
	level.killcam = 1;//maps\mp\gametypes\_tweakables::getTweakableValue( "game", "allowkillcam" );
	
	if( level.killcam )
	setArchive(true);
}

killcam(
attackerNum, // entity number of the attacker
killcamentity, // entity number of the attacker's killer entity aka helicopter or airstrike
sWeapon, // killing weapon
predelay, // time between player death and beginning of killcam
offsetTime, // something to do with how far back in time the killer was seeing the world when he made the kill; latency related, sorta
respawn, // will the player be allowed to respawn after the killcam?
maxtime, // time remaining until map ends; the killcam will never last longer than this. undefined = no limit
attacker // entity object of attacker
)
{
	self endon("disconnect");
	self endon("spawned");
	level endon("game_ended");

	//iprintln("WEAPON USED TO KILL -> "+ killcamentity);

	if(level.cod_mode == "torneio")
	return;

	if(!isdefined(attacker))
		return;
	
	if(attacker.incognito)
		return;

	if(attackerNum < 0)
	return;

	// length from killcam start to killcam end
	if (getdvar("scr_killcam_time") == "") {
		if (sWeapon == "artillery_mp")
		camtime = 1.3;
		else if ( !respawn ) // if we're not going to respawn, we can take more time to watch what happened
		camtime = 5.0;
		else if (sWeapon == "frag_grenade_mp")
		camtime = 4.5; // show long enough to see grenade thrown
		else
		camtime = 2.5;
	}
	else
	camtime = getdvarfloat("scr_killcam_time");
	
	if (isdefined(maxtime)) {
		if (camtime > maxtime)
		camtime = maxtime;
		if (camtime < .05)
		camtime = .05;
	}
	
	// time after player death that killcam continues for
	if (getdvar("scr_killcam_posttime") == "")
	postdelay = 2;
	else {
		postdelay = getdvarfloat("scr_killcam_posttime");
		if (postdelay < 0.05)
		postdelay = 0.05;
	}
	
	if(sWeapon == "frag_grenade_mp" || sWeapon == "frag_grenade_short_mp" || sWeapon == "gl_m16_mp" ) 
	  	self setClientDvar("cg_airstrikeKillCamDist",25);
	else 
		self setClientDvar("cg_airstrikeKillCamDist",200);
		
	
	/* timeline:
	
	|        camtime       |      postdelay      |
	|                      |   predelay    |
	
	^ killcam start        ^ player death        ^ killcam end
										^ player starts watching killcam
	
	*/
	
	killcamlength = camtime + postdelay;
	
	// don't let the killcam last past the end of the round.
	if (isdefined(maxtime) && killcamlength > maxtime)
	{
		// first trim postdelay down to a minimum of 1 second.
		// if that doesn't make it short enough, trim camtime down to a minimum of 1 second.
		// if that's still not short enough, cancel the killcam.
		if (maxtime < 2)
		return;

		if (maxtime - camtime >= 1) {
			// reduce postdelay so killcam ends at end of match
			postdelay = maxtime - camtime;
		}
		else {
			// distribute remaining time over postdelay and camtime
			postdelay = 1;
			camtime = maxtime - 1;
		}
		
		// recalc killcamlength
		killcamlength = camtime + postdelay;
	}

	killcamoffset = camtime + predelay;
	
	self notify ( "begin_killcam", getTime() );
	self.sessionstate = "spectator";
	self.spectatorclient = attackerNum;
	self.killcamentity = -1;
	
	//if ( killcamentityindex >= 0 )
	//	self.killcamentity = killcamentityindex;
		
	self.archivetime = killcamoffset;
	self.killcamlength = killcamlength;
	self.psoffsettime = offsetTime;

	// ignore spectate permissions
	self allowSpectateTeam("allies", true);
	self allowSpectateTeam("axis", true);
	self allowSpectateTeam("freelook", true);
	self allowSpectateTeam("none", true);
	
	// wait till the next server frame to allow code a chance to update archivetime if it needs trimming
	wait level.oneFrame;

	if ( self.archivetime <= predelay ) // if we're not looking back in time far enough to even see the death, cancel
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
		
		return;
	}
	
	
	self.killcam = true;
	
	self thread spawnedKillcamCleanup();
	self thread endedKillcamCleanup();
	self thread waitSkipKillcamButton();
	self thread waitKillcamTime();

	self waittill("end_killcam");

	self endKillcam();

	self.sessionstate = "dead";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
}
//pega entidade marcada
setKillCamEntity( killcamentityindex, delayms )
{
	self endon("disconnect");
	self endon("end_finalkillcam");
	self endon("spawned");
	
	if ( delayms > 0 )
		xwait (delayms / 1000,false);
	
	self.killcamentity = killcamentityindex;
}

waitKillcamTime()
{
	self endon("disconnect");
	self endon("end_killcam");

	xwait( self.killcamlength - level.oneFrame, false);
	self notify("end_killcam");
}

waitSkipKillcamButton()
{
	self endon("disconnect");
	self endon("end_killcam");

	while(self useButtonPressed())
	wait level.oneFrame;

	while(!(self useButtonPressed()))
	wait level.oneFrame;

	self notify("end_killcam");
}

endKillcam()
{
	self.killcam = undefined;
	
	self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
}

spawnedKillcamCleanup()
{
	self endon("end_killcam");
	self endon("disconnect");

	self waittill("spawned");
	self endKillcam();
}

spectatorKillcamCleanup( attacker )
{
	self endon("end_killcam");
	self endon("disconnect");
	attacker endon ( "disconnect" );

	attacker waittill ( "begin_killcam", attackerKcStartTime );
	waitTime = max( 0, (attackerKcStartTime - self.deathTime) - 50 );
	xwait( waitTime, false );
	self endKillcam();
}

endedKillcamCleanup()
{
	self endon("end_killcam");
	self endon("disconnect");

	level waittill("game_ended");
	self endKillcam();
}
