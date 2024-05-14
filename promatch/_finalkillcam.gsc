#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include promatch\_utils;
/*

TESTAR
	if ( ( isSubStr( sWeapon, "frag_grenade_short_mp" ) ) && isdefined( eInflictor ) )
	{
		killcamentity = eInflictor getEntityNumber();
		doKillcam = true;
	}
*/
finalKillcamWaiter()
{
	if ( !level.inFinalKillcam )
		return;
		
	while (level.inFinalKillcam)
		xwait(0.05,false);
}
//registerPostRoundEvent from utils event
postRoundFinalKillcam()
{	
	level notify( "play_final_killcam" );
	resetOutcomeForAllPlayers();
	finalKillcamWaiter();	
}
//Iniciada finalK <- Global
startFinalKillcam( 
	attackerNum, // entity number of the attacker
	eInflictorNum, // entity number of the eInflictor
	killcamentity, // entity to view during killcam aka helicopter or airstrike
	killcamentityindex, // entity number of the above
	killcamentitystarttime, // time at which the killcamentity came into being
	sWeapon, // killing weapon <- not working
	deathTime, // time when the player died
	deathTimeOffset, // time between player death and beginning of killcam
	offsetTime, // something to do with how far back in time the killer was seeing the world when he made the kill; latency related, sorta
	attacker, // entity object of attacker - = player
	victim,//victim of the attacker
	eInflictor,
	sMeansOfDeath
)
{			
	if(attackerNum < 0)
		return;
  
	recordKillcamSettings( attackerNum, eInflictorNum,killcamentity,sWeapon, deathTime, deathTimeOffset, offsetTime, killcamentityindex, killcamentitystarttime, attacker,victim,eInflictor,sMeansOfDeath);
	doFinalKillcam();
}

recordKillcamSettings( spectatorclient, eInflictorentityindex,killcamentity, sWeapon, deathTime, deathTimeOffset, offsettime, killcamentityindex, entitystarttime, attacker,victim,eInflictor,sMeansOfDeath )
{
	if ( !isDefined(level.lastKillCam) )
		level.lastKillCam = spawnStruct();

	level.lastKillCam.spectatorclient = spectatorclient;
	level.lastKillCam.weapon = sWeapon;
	level.lastKillCam.killcamentityview = killcamentity;
	level.lastKillCam.deathTime = deathTime;
	level.lastKillCam.deathTimeOffset = deathTimeOffset;
	level.lastKillCam.offsettime = offsettime;
	level.lastKillCam.entityindex = killcamentityindex;//entidade a ser assistida 97 = impacto nade e ballistc ?
	level.lastKillCam.eInflictorentityindex = eInflictorentityindex;
	level.lastKillCam.entitystarttime = entitystarttime;
	level.lastKillCam.attacker = attacker;
	level.lastKillCam.victim = victim;
	level.lastKillCam.eInflictor = eInflictor;
	level.lastKillCam.sMeansOfDeath = sMeansOfDeath;
	level.victimint = level.lastKillCam.victim getentitynumber();
	
}


doFinalKillcam()
{
	if ( level.inFinalKillcam )
		return;

	if ( !isDefined(level.lastKillCam) )
		return;
	level.headshotkill = undefined;
	setClientNameMode( "manual_change" );
	level.inFinalKillcam = true;
	level waittill ( "play_final_killcam" );
	visionSetNaked( getDvar( "mapname" ), 0 );

	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		player closeMenu(); 
		player closeInGameMenu();
		player thread finalKillcam();//START THREAD FINAL Killcam
	}
	xwait( 0.1,false );

	while ( areAnyPlayersWatchingTheKillcam() )
		wait level.oneFrame;

	level.inFinalKillcam = false;
}

areAnyPlayersWatchingTheKillcam()
{
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		if ( isDefined( player.killcam ) )
			return true;
	}
	
	return false;
}

finalKillcam()
{
	self endon("disconnect");
	level endon("game_ended");	
	self notify( "end_killcam" );
	
	level.headshotkill = undefined;
	level.dokillcamnade = false;
	
	postDeathDelay = (getTime() - level.lastKillCam.deathTime) / 1000;
	predelay = postDeathDelay + level.lastKillCam.deathTimeOffset;
	sWeapon = level.lastKillCam.weapon;
	attackername = level.lastKillCam.attacker.name;
	victimname = level.lastKillCam.victim.name;	
	camtime = calcKillcamTime( level.lastKillCam.weapon, level.lastKillCam.entitystarttime, predelay, false, undefined );
	postdelay = 2; // time after player death that killcam continues for
	killcamlength = camtime + postdelay - 0.05; // We do the -0.05 since we are doing a wait below.
	killcamoffset = camtime + predelay;
	
	self notify ( "begin_killcam", getTime() );
	
	killcamstarttime = (getTime() - killcamoffset * 1000);
	
	
	//SET CLIENT SPEC	
	self.sessionstate = "spectator";
	//who the killcam will show - start with the attacker
	self.spectatorclient = level.lastKillCam.spectatorclient; //num of client
	
	self.killcamentity = -1;
	
	//================================================================================================
	//=========SET DE TIPO DE MORTE===================================================================
	//================================================================================================
	if(level.lastKillCam.sMeansOfDeath == "MOD_EXPLOSIVE" || level.lastKillCam.weapon == "destructible_car" || level.lastKillCam.sMeansOfDeath == "MOD_CRUSH")
	level.lastKillCam.entityindex = level.victimint;
	
	//TESTE
	if(level.lastKillCam.sMeansOfDeath == "MOD_HEAD_SHOT" || level.lastKillCam.weapon == "gl_m16_mp")
	{
		level.headshotkill = true;
		self setClientDvars( "cg_thirdPersonAngle", "60", "cg_thirdPersonRange", "100");
		self setClientDvar("cg_airstrikeKillCamDist",150);			
	}
	else
	level.headshotkill = undefined;
	

	if(isDefined(level.killcamnade) && level.lastKillCam.sMeansOfDeath == "MOD_GRENADE_SPLASH" || isDefined(level.killcamnade) && level.lastKillCam.weapon == "frag_grenade_short_mp")
	{
		//PLAYER NAME
		//iprintln("FINALKILLCAM:[owner] -> " + level.killcamnadeattacker.name );
		//iprintln("FINALKILLCAM:[attacker num] -> " + level.killcamnade);
		self setClientDvar("cg_airstrikeKillCamDist",150);	
		self setClientDvars( "cg_thirdPersonAngle", "30", "cg_thirdPersonRange", "120");	
		
		if(isDefined(level.killcamnade) && level.killcamnadeattacker == level.lastKillCam.attacker)
		{
			level.lastKillCam.entityindex = level.killcamnade;
			level.dokillcamnade = true;
		}
	}	
	
	//=================================================================================================
	//=================================================================================================
	
	
	//SET self.killcamentity = killcamentityindex; = watching 
	if ( level.lastKillCam.entityindex >= 0 )
		self setKillCamEntity( level.lastKillCam.entityindex, level.lastKillCam.entitystarttime - killcamstarttime - 100 );
	
	self.archivetime = killcamoffset;
	self.killcamlength = killcamlength;
	self.psoffsettime = level.lastKillCam.offsettime;
	// ignore spectate permissions
	self allowSpectateTeam("allies", true);
	self allowSpectateTeam("axis", true);
	self allowSpectateTeam("freelook", false);
	self allowSpectateTeam("none", false);
	
	//level.lastKillCam.victimidx = level.lastKillCam.victim getEntityNumber();
	//iprintln("WEAPON USED TO KILL -> "+ level.lastKillCam.weapon);
	//iprintln("SMEANSOFDEATH -> "+ level.lastKillCam.sMeansOfDeath);
	//iprintln("ANGLE ORI ->"+ int(level.lastKillCam.attacker.angles[1]));
	//iprintln("spectatorclient-> "+ level.lastKillCam.spectatorclient);
	//iprintln("eInflictorentityindex -> "+ level.lastKillCam.eInflictorentityindex);
	//iprintln("attacker -> "+ level.lastKillCam.attacker.name);
	//iprintln("victim -> "+ level.lastKillCam.victim.name);


	//--------------------------------------
	//level.lastKillCam.entityindex = usado para assistir
	//--------------------------------------
			
	

	//iprintln("FINALKILLCAM:[killcamentity] -> " + self.killcamentity);
	//iprintln("FINALKILLCAM:[spectatorclient INT] -> " + self.spectatorclient);
	//iprintln("FINALKILLCAM:[psoffsettime] -> " + level.lastKillCam.offsettime);
	//iprintln("FINALKILLCAM:[killcamentityview] -> " + level.lastKillCam.killcamentityview); = undefined error

	
 	
	self thread endedFinalKillcamCleanup();
	// wait till the next server frame to allow code a chance to update archivetime if it needs trimming
	wait level.oneFrame;

	if ( self.archivetime <= predelay ) // if we're not looking back in time far enough to even see the death, cancel
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;

		self notify ( "end_finalkillcam" );//= killcam_ended
		
		return;
	}
	
	self thread checkForAbruptKillcamEnd();	
	self.killcam = true;
	
	self addKillcamTimer(camtime);//HUD
	
	if(isDefined(level.lastKillCam.attacker) && isdefined(level.lastKillCam.victim))
	self addKillcamKiller(attackername,victimname);
	
	self thread waitFinalKillcamSlowdown( killcamstarttime );
	
	//self thread waitKillcamTime();
	//Killcam Ativada	
	self waittill("end_finalkillcam");
		
	//RESET dVars
	ResetSlowMoFX();
	//iprintln("FINALKILLCAM:[ResetSlowMoFX] -> " + self.killcam);
	//iprintln("FINALKILLCAM:[self.spectatorclient] -> " + self.spectatorclient);//19 = bot
	self endKillcam();
	
	setDvar("timescale",1);//FIX SLOW BUG SERVER
	
	self FreezeEndOfFinalKillCam();
}

waitFinalKillcamSlowdown( startTime )
{
	self endon("disconnect");
	self endon("end_finalkillcam");
	secondsUntilDeath = ( ( level.lastKillCam.deathTime - startTime ) / 1000 );
	deathTime = getTime() + secondsUntilDeath * 1000;
	waitBeforeDeath = 3;//before start slowmo
	
	SetSlowMoFX();	
	
	//iprintln("FINALKILLCAM:[killcamentity] -> " + self.killcamentity);
	//iprintln("FINALKILLCAM:[entityindex] -> " + level.lastKillCam.entityindex);//102
	//iprintln("FINALKILLCAM:[spectatorclient INT] -> " + self.spectatorclient);//18
	//iprintln("FINALKILLCAM:[eInflictorentityindex] -> " + level.lastKillCam.eInflictorentityindex);//19
	
	//if(isDefined(level.headshotkill))
	//self.spectatorclient = level.lastKillCam.spectatorclient;
	
	//iprintln("FINALKILLCAM[xwaitmax]> " + (secondsUntilDeath - waitBeforeDeath));//2.25
	
	//iprintln("FINALKILLCAM:[killcamentity] -> " + self.killcamentity);
	//iprintln("FINALKILLCAM[lastKillCam.deathTime]> " + level.lastKillCam.deathTime);//31050
	//iprintln("FINALKILLCAM[startTime]> " + startTime);//26050
	//iprintln("FINALKILLCAM[deathTime]> " + deathTime);//41800
	
	
	
	if(level.dokillcamnade || isDefined(level.headshotkill))
	xwait( max(0, (secondsUntilDeath - waitBeforeDeath) + 2.5 ),false );
	else
	xwait( max(0, (secondsUntilDeath - waitBeforeDeath)),false );
	
	if(level.dokillcamnade || isDefined(level.headshotkill))
	{
		self.spectatorclient = level.victimint;
		
		//self setClientDvar( "cg_thirdPerson", "1");		
		if(isDefined(level.headshotkill))
		{
			self setClientDvar( "cg_thirdPersonAngle", "160");
			self setClientDvar( "cg_thirdPersonrange", "120");
			//self.spectatorclient = -1;
			self.killcamentity = -1;
		}
		
		
	}	
	
	setTimeScale( 0.55, int( deathTime - 500 ));	
	
	//self.spectatorclient = -1;
	//self.killcamentity = -1;
	/*while(true)
	{
		self setClientDvar( "cg_thirdPersonAngle", "180");
		wait 0.2;
		self setClientDvar( "cg_thirdPersonAngle", "120");
		wait 0.2;
		self setClientDvar( "cg_thirdPersonAngle", "90");
		wait 0.2;
		self setClientDvar( "cg_thirdPersonAngle", "60");
		wait 0.2;
		self setClientDvar( "cg_thirdPersonAngle", "30");
		wait 0.2;
		self setClientDvar( "cg_thirdPersonAngle", "0");
		
		break;
	}*/
	self setClientDvar( "cg_thirdPersonrange", "200");
	xwait( waitBeforeDeath,false );
	
	//if(isDefined(level.headshotkill))
	//self.spectatorclient = level.lastKillCam.eInflictorentityindex;	
		
	//iprintln("FINALKILLCAM:[dokillcamnade] -> " + level.dokillcamnade);
	
	//
	
	
	//self.spectatorclient = level.victimint;
	//aqui ja terminou de morrer
	setDvar("timescale",1);
	
	//iprintln("FINALKILLCAM:[entityindexPOS] -> " + level.lastKillCam.entityindex);//102	
	level.headshotkill = undefined;
	level.killcamnade = undefined;
	
	if(level.dokillcamnade)
	xwait( 1,false );
	
	//xwait(self.killcamlength - 0.05,false);
	self notify("end_finalkillcam");
}


calcKillcamTime( sWeapon, entitystarttime, predelay, respawn, maxtime )
{
	camtime = 0.0;
	
	camtime = checkWeaponAndSetDistance(sWeapon);
	
	if (isdefined(maxtime)) {
		if (camtime > maxtime)
			camtime = maxtime;
		if (camtime < .05)
			camtime = .05;
	}
	
	return camtime;
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


endKillcam()
{
	self.killcam = undefined;
	//self thread maps\mp\gametypes\_spectating::setSpectatePermissions();	

	if(isDefined(self.fkc_timer))
	self.fkc_timer.alpha = 0;
}

// This puts the player to the intermission point as a spectator once the killcam is over.
FreezeEndOfFinalKillCam()
{
	self freezeControls( true );
}


waitKillcamTime()
{
	self endon("disconnect");
	self endon("end_finalkillcam");

	xwait(self.killcamlength - 0.05,false);
	self notify("end_finalkillcam");
}



setTimeScale(to,time)
{
	difference = (abs(getTime() - time)/1000);
	timescale = getDvarFloat("timescale");
	if(difference != 0) 
	{
		for(i = timescale*20; i >= to*20; i -= 1 )//TEstar alterar 1
		{
			xwait( min(0.05,(int(difference)/int(getDvarFloat("timescale")*20))/20),false);
			setDvar("timescale",i/20);
		} 
	}
	else
	setDvar("timescale",1);
}

SetSlowMoFX()
{

     for(i=0;i<level.players.size;i++)
	 {
			if(level.killcamfx)
			{
				level.players[i] setClientDvar ("cg_firstPersonTracerChance","1");
				level.players[i] setClientDvar ("cg_tracerchance","1");
				level.players[i] setClientDvar ("cg_tracerlength","6000");
				level.players[i] setClientDvar ("cg_tracerSpeed","80");
			}
		  
		  if(self.spectatorclient == level.lastKillCam.eInflictorentityindex)
		  {
				level.players[i] setClientDvar ("cg_thirdperson","1");
			   // if(level.headshotkill)
			  // level.players[i] setClientDvar ("cg_thirdpersonangle","220");
		  }
	 }
}

ResetSlowMoFX()
{
     for(i=0;i<level.players.size;i++)
	 {
			if(level.killcamfx)
			{
				level.players[i] setClientDvar("ui_killcammsg", "");
				level.players[i] setClientDvar ("cg_firstPersonTracerChance","0.5");
				level.players[i] setClientDvar ("cg_tracerchance","0.2");
				level.players[i] setClientDvar ("cg_tracerlength","160");
				level.players[i] setClientDvar ("cg_tracerSpeed","7500");
			}
		
		 level.players[i] setClientDvar ("cg_thirdperson","0");
	 }
	
}


checkForAbruptKillcamEnd()
{
	self endon("disconnect");
	self endon("end_finalkillcam");
	
	while(1)
	{
		if ( self.archivetime <= 0 )
			break;
		wait level.oneFrame;
	}
	ResetSlowMoFX();//207
	self notify("end_finalkillcam");
}



endedFinalKillcamCleanup()
{
	self endon("end_finalkillcam");
	self endon("disconnect");

	level waittill("game_ended");
	self endKillcam(true);
}



checkWeaponAndSetDistance(sWeapon)
{
	//iprintln(sWeapon);
	camtime = 5;
	if (sWeapon == "artillery_mp")
	{
		camdist = 128;
		camtime = 1.3;
	}
	else if(sWeapon == "frag_grenade_mp" || sWeapon == "concussion_grenade_mp" || sWeapon == "frag_grenade_short_mp")
	{
		camdist = 120;
		camtime = 4.25;
	}
	else if(sWeapon == "c4_mp")
	{
		camdist = 40;
		camtime = 4.5;
	}
	else if(sWeapon == "explodable_barrel")
	{
		camdist = 390;
		camtime = 4.25;
	}
	else if(sWeapon == "destructible_car")
	{
		camdist = 450;
		camtime = 4.5;
	}
	else if(sWeapon == "cobra_FFAR_mp" || sWeapon == "hind_FFAR_mp")
		camdist = 60;
	else
		camdist = 40;
	
	//iprintln("CAMDIST ->"+ camdist);
	self setClientDvar("cg_airstrikeKillCamDist",camdist);
	
	return camtime;
}


addKillcamKiller(attacker,victim)
{	

	self setClientDvar("ui_killcammsg", "");
	
	msgint =  randomInt(6);

	if(msgint == 0)
	self setClientDvar("ui_killcammsg", "^2" + victim +" ^7ownado por ^1"+ attacker);
	if(msgint == 1)
	self setClientDvar("ui_killcammsg", "^2" + victim +" ^7ownado por ^1"+ attacker);
	if(msgint == 2)
	self setClientDvar("ui_killcammsg", "^2" + attacker +" ^7acabou com ^1"+ victim);
	if(msgint == 3)
	self setClientDvar("ui_killcammsg", "^2" + victim +" ^7eh franguinho do ^1"+ attacker);
	if(msgint == 4)
	self setClientDvar("ui_killcammsg", "^2" + victim +" ^7comeu poeira do ^1"+ attacker);
	if(msgint == 5)
	self setClientDvar("ui_killcammsg", "^2" + victim +" ^7se fez de vitima do ^1"+ attacker);
	if(msgint == 6)
	self setClientDvar("ui_killcammsg", "^2" + victim +" ^7foi detonado por ^1"+ attacker);
}

addKillcamTimer(camtime)
{
	if (!isDefined(self.fkc_timer))
	{
			self.fkc_timer = createFontString("big", 2.0);
			self.fkc_timer.archived = false;
			self.fkc_timer.x = 0;
			self.fkc_timer.alignX = "center";
			self.fkc_timer.alignY = "middle";
			self.fkc_timer.horzAlign = "center_safearea";
			self.fkc_timer.vertAlign = "top";
			self.fkc_timer.y = 50;
			self.fkc_timer.sort = 1;
			self.fkc_timer.font = "big";
			self.fkc_timer.foreground = true;
			self.fkc_timer.color = (0.85,0.85,0.85);
			self.fkc_timer.hideWhenInMenu = true;
	}
	self.fkc_timer.y = 50;
	self.fkc_timer.alpha = 1;
	self.fkc_timer setTenthsTimer(camtime);
}