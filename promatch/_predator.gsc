//*********************************************************************************
//                                                                                  
//        _   _       _        ___  ___      _        ___  ___          _             
//       | | | |     | |       |  \/  |     | |       |  \/  |         | |            
//       | |_| | ___ | |_   _  | .  . | ___ | |_   _  | .  . | ___   __| |___       
//       |  _  |/ _ \| | | | | | |\/| |/ _ \| | | | | | |\/| |/ _ \ / _` / __|      
//       | | | | (_) | | |_| | | |  | | (_) | | |_| | | |  | | (_) | (_| \__ \      
//       \_| |_/\___/|_|\__, | \_|  |_/\___/|_|\__, | \_|  |_/\___/ \__,_|___/      
//                       __/ |                  __/ |                               
//                      |___/                  |___/                                
//                                                                                  
//                       Website: http://www.holymolymods.com                       
//*********************************************************************************
// Predator Missle base code from OW2 mod...Thanks Sammy:)
// Coded for OW mod by [105]HolyMoly July 6/2012
// V.4.0

#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include promatch\_utils;
#include common_scripts\utility;

init()
{

	precacheModel("projectile_hellfire_missile");
    precacheModel( "prop_suitcase_bomb" );
	level.droneexplosion = loadfx ("explosions/clusterbomb");
	level.droneexplosionhuge = loadfx ("explosions/wall_explosion_pm_a");


	//level.predator_explosion = loadfx ("explosions/fuel_med_explosion");
    level._effect["hellfire_trail"] = loadfx ("smoke/smoke_geotrail_barret");
	//level.air_support_fx_yellow = loadfx( "misc/ui_pickup_available" );
	//level.air_support_fx_red 	= loadfx( "misc/ui_pickup_unavailable" );

	//precacheShader( "black" );
	precacheShader( "ac130_overlay_105mm" );
	precacheShader( "ac130_overlay_grain" );
	precacheShader( "waypoint_pred_kill" );
}


givePredator()
{

	self endon( "disconnect" );
	self endon( "death" );
	level endon( "game_ended" );

	// Thirdperson Fix
	if( getDvarInt( "scr_thirdperson_enable" ) == 1 ) self setClientDvar( "cg_thirdperson", "0" );

	self thread onGameEnded();

        // Fade to Black to hide Stance
        self thread predBlackScreen();

	level.hpPredator = true;
	self.spawn_protected = true;
	self.inPredator = true;
	
	self statSets("TEAMBUFF",0);
	
	if(isdefined(self.teambufficon.icon))
	self.teambufficon.icon.alpha = 0;
	
	//Current weapons and ammo
	ammoClipList = [];
	ammoStockList = [];
	originalHealth = self.health;

	weaponsList = self getWeaponsList();
  
	for (i = 0; i < weaponsList.size; i++)
	{

	  ammoClipList[ammoClipList.size] = self getWeaponAmmoClip( weaponsList[i] );
	  ammoStockList[ammoStockList.size] = self getWeaponAmmoStock( weaponsList[i] );

	}

        // Self Position for respawn                
	self.currPos = self.origin;

	self.currAngles = self.angles;
    self.stancePos = self getStance();

	//Do not allow Predator to pick up an objective (for when it crashes)
	self.canPickupObject = false;
	self.preventObjectives = true;

	//Look for Sharpshooter gametype and disable weapon cycling.
	//if( level.gametype == "ss" )
		//self.disableSharpShooter = true;

	//If the player is carrying a bomb or the flag drop it. Otherwise it will fly with the player in the air.
	if( isDefined( self.carryObject ) )
		self.carryObject thread maps\mp\gametypes\_gameobjects::setDropped();

	self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
	self takeAllWeapons();
	self clearPerks();
	self hide();
	
	//Make sure the player is crouched to use this weapon
	self ExecClientCommand( "gocrouch" );
	wait( 0.08 );

	// Create pickup trigger and flag
	selfBombCase = spawn( "script_model", self.currPos );
	selfBombCase setmodel( "prop_suitcase_bomb" );
	selfCaseTrigger = spawn( "trigger_radius", self.currPos, 0, 20, 5 );

	self thread watchForEnemyTrigger( selfCaseTrigger, selfBombCase );
        
	//Set up the Predator model and do not show to the owner.
	dropPoint = self.currPos + ( 0, 0, 2000 );
	
	predatormodel = spawn( "script_model", dropPoint );
	predatormodel hide();
	predatormodel setModel( "projectile_hellfire_missile" );


    // Show Missle to everyone else
	for( i=0; i<level.players.size; i++ )
	{
		if( self != level.players[i] )
			predatorModel showToPlayer( level.players[i] );
	}

	predatorModel.angles = ( self.currAngles );
	predatormodel.origin = dropPoint;
	predatorModel.thrust = 5;
	predatorModel.maxSpeed = 200;
	predatorModel.targetname = "predator";
	predatorModel.owner = self;
	predatorModel.team = self.pers["team"];

	self.predatormodel = predatorModel;
	self setplayerangles( self.currAngles + ( 90, 0, 0 ) );
	self setOrigin( predatorModel.origin );
	self linkTo( predatorModel, "tag_origin", ( 50, 0, 0 ), ( 0, 0, 0 ) );

        // Timing for blackscreen
	wait ( 0.3 );

    // Set up Hud and Timer
	self thread overlay_coords();
	self thread predator_hud();
	self thread predatorTimer( 20, selfCaseTrigger, selfBombCase );
	self thread doPredatorStrike( selfCaseTrigger, selfBombCase, weaponsList, ammoClipList, ammoStockList, originalHealth );

	// Watch for Kills & Disconnects
	self thread onPlayerKilled( selfCaseTrigger, selfBombCase );
	self thread onPlayerDisconnect( selfCaseTrigger, selfBombCase );
	self thread onJoinedSpectators( selfCaseTrigger, selfBombCase );


}

doPredatorStrike( selfCaseTrigger, selfBombCase, weaponsList, ammoClipList, ammoStockList, originalHealth )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "predator_expired" );
	level endon( "game_ended" );

    //if( level.scr_hardpoint_predator_kill_targets == 1 ) 
	self thread addKillTargets();

	self thread watchForLockOn();
     
	// Wait for Blackscreen
	wait( 1.0 );

	earthquake( 1, 1, self.predatorModel.origin, 1000 );

	self.predatormodel thread maps\mp\gametypes\_hardpoints::playsoundinspace( "predator_burst" );

	wait( 0.05);

	self.predatormodel thread maps\mp\gametypes\_hardpoints::playsoundinspace( "shell_incoming" );

	

	currentSpeed = 0;

	while( isDefined( self.predatorModel ) )
	{
		if ( currentSpeed < self.predatorModel.maxSpeed )
			currentSpeed += self.predatorModel.thrust;

		forward = vectorNormalize( anglesToForward( self getPlayerAngles() ) );
		nextPos = self.predatorModel.origin + forward * currentSpeed;

		playfxontag( level._effect["hellfire_trail"], self.predatorModel, "tag_fx" );
		playfxontag( level.redlightblink, self.predatorModel, "tag_fx" );
		//If there is an obstruction between the current position and the next then Predator will hit something in this loop.
		trace = bulletTrace(self.predatorModel.origin, nextPos, false, self.predatorModel);
		if( trace["fraction"] != 1 && trace["surfacetype"] != "default" )
		{
			self notify( "predator_end" ); 
			finalPos = trace["position"] - forward * 100;
			self.predatorModel moveto( finalPos, 0.1 );
			self thread predWhiteScreen();
			wait 0.1;

			self thread predator_detachPlayer( weaponsList, ammoClipList, ammoStockList, originalHealth );

			// Delete Case and Trigger
			if( isDefined( selfCaseTrigger ) )selfCaseTrigger delete();
			if( isDefined( selfBombCase ) ) selfBombCase delete(); 

			//owner, attacker, inflictor, hit location
			thread explode( self, self, self.predatorModel, finalPos );

			break;
		}
		else
		{
			//MoveTo time is the same as the loop.
			self.predatorModel moveTo( nextpos, 0.1 );
			self.predatorModel.angles = self getPlayerAngles();
		}

		wait 0.1;             
	}        
}


explode( owner, attacker, eInflictor, location, noDamage )
{
	if( isDefined( eInflictor ) )
		eInflictor hide();

	forward = ( location + ( 0, 0, 15 + randomint(120) ) ) - location;
	//playfx ( level.predator_explosion, location, forward );
	playfx( level.droneexplosionhuge, location, forward);
	thread maps\mp\gametypes\_hardpoints::playsoundinspace( "predator_explode", location, true );
	playRumbleOnPosition( "artillery_rumble", location );
	earthquake( 1.4, 1, location, 2000 );

	//Parameters: targetpos (+ a small offset), radius, maxdamage, mindamage, player causing damage, entity that player used to cause damage
	if( isDefined( !level.gameEnded ) && !isDefined( noDamage ) && isDefined( attacker ) && isDefined( eInflictor) )
		thread losRadiusDamage( location + (0,0,16), 600, 300, 100, attacker, eInflictor ); 

	PhysicsExplosionSphere( location, 400, 200, 3 );

	level.hpPredator = undefined;

	if( isDefined( eInflictor ) && !isPlayer( eInflictor ) )
		eInflictor delete();

	if( isDefined( owner ) )
		owner notify("explode_done");
}

predator_detachPlayer( weaponsList, ammoClipList, ammoStockList, originalHealth )
{
	self endon( "disconnect" );
	self notify( "predator_detached" );

	self freezeControls ( true );
	self unlink();

	self thread predator_hudOff();
	self.inPredator = undefined;
	level.hpPredator = undefined;

	self thread respawn( weaponsList, ammoClipList, ammoStockList, originalHealth );

}

watchForLockon()
{
	self endon("death");
	self endon("disconnect");
	self endon("predator_detached");
	level endon ("game_ended");

	while( !self useButtonPressed() )
		wait 0.05;

	self.predatorModel.maxSpeed = 200;
	self.predatorModel.thrust = 25;

	self freezeControls( true );
}

watchForEnemyTrigger( selfCaseTrigger, selfBombCase )
{

        selfCaseTrigger waittill( "trigger", player ); 

        if( level.teamBased )
        {
			if( player.pers["team"] != self.pers["team"] )
			{       
					self suicide();
					self thread removeKillTargets();
					   // Thirdperson Fix
					  if(getDvarInt( "scr_thirdperson_enable" ) == 1 )
					  self setClientDvars( 
							"cg_thirdPerson", "1",
							"cg_thirdPersonAngle", "360",
							"cg_thirdPersonRange", "72"
							);

					  self setClientDvar( "player_view_pitch_up", "85" ); 

						self.inPredator = undefined;
						level.hpPredator = undefined;

					  iprintln( "Predator Missle destroyed by ^2" + player.name );
					  player thread givePlayerScore( "kill", 500);
					  [[level._setTeamScore]]( player.pers["team"], [[level._getTeamScore]]( player.pers["team"] ) + level.scr_hardpoint_predator_destroyed_points );

					  // Delete Case and Trigger
					  if( isDefined( selfCaseTrigger ) )selfCaseTrigger delete();
					  if( isDefined( selfBombCase ) ) selfBombCase delete(); 

			}
        }
        else
        {

                self suicide();

                self thread removeKillTargets();
   
                // Thirdperson Fix
                if( getDvarInt( "scr_thirdperson_enable" ) == 1 ) self setClientDvars( 
		          "cg_thirdPerson", "1",
		          "cg_thirdPersonAngle", "360",
		          "cg_thirdPersonRange", "72"
	        );

                self setClientDvar( "player_view_pitch_up", "85" ); 

	        self.inPredator = undefined;
	        level.hpPredator = undefined;

                iprintln( "Predator Missle destroyed by ^2" + player.name );
                player thread givePlayerScore( "kill", 600 );

                // Delete Case and Trigger
                if( isDefined( selfCaseTrigger ) )selfCaseTrigger delete();
                if( isDefined( selfBombCase ) ) selfBombCase delete(); 
        }

        return;

} 
            
predBlackScreen()
{
        wait( 0.08 );

	// Create the hud elements will be using for the black out
	if( !isDefined( self.predBlack ) ) 
	{
		self.predBlack = newClientHudElem( self );
		self.predBlack.x = 0;
		self.predBlack.y = 0;
		self.predBlack.alignX = "left";
		self.predBlack.alignY = "top";
		self.predBlack.horzAlign = "fullscreen";
		self.predBlack.vertAlign = "fullscreen";
		self.predBlack.sort = -5;
		self.predBlack.color = ( 0, 0, 0 );
		self.predBlack.archived = false;
		self.predBlack setShader( "black", 640, 480 );	
		self.predBlack.alpha = 1;

    }

        if( !level.gameEnded )
		{
	        if( isDefined( self.predBlack ) ) 
			{
                 wait( 1.0 );
				if( isDefined( self.predBlack ) ) 
				self.predBlack fadeOverTime( 1.0 );
				
				if( isDefined( self.predBlack ) ) 
				self.predBlack.alpha = 0;
            }
        }
}

predWhiteScreen()
{
    wait( 0.08 );

		if( !isDefined( self.hud_predator_white ) ) {
		self.hud_predator_white = newClientHudElem( self );
		self.hud_predator_white.x = 0;
		self.hud_predator_white.y = 0;
		self.hud_predator_white.alignX = "left";
		self.hud_predator_white.alignY = "top";
		self.hud_predator_white.horzAlign = "fullscreen";
		self.hud_predator_white.vertAlign = "fullscreen";
		self.hud_predator_white.sort = -5;
		self.hud_predator_white.color = ( 1, 1, 1 );
		self.hud_predator_white.archived = false;
		self.hud_predator_white setShader( "white", 640, 480 );	
		self.hud_predator_white.alpha = 1;

        }

        if( !level.gameEnded )
		{
                if( isDefined( self.hud_predator_white ) ) 
				{
                        wait ( 2.3 );
						
						if( isDefined( self.hud_predator_white ) ) 
                        self.hud_predator_white fadeOverTime( 0.75 );
						
						if( isDefined( self.hud_predator_white ) ) 
						self.hud_predator_white.alpha = 0;
                }
        }
       
}

overlay_coords()
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "predator_detached" );
	level endon( "game_ended" );

	if( !isDefined( self.long ) ){
		self.long = newClientHudElem( self );
		self.long.x = -100;
		self.long.y = 350;
		self.long.alignX = "right";
		self.long.alignY = "top";
		self.long.horzAlign = "right";
		self.long.vertAlign = "top";
		self.long.fontScale = 1.8;
                self.long.color = ( 1, 1, 1 );
                self.long.alpha = 1.0;
		self.long.sort = -5;
	}    

   	if( !isDefined( self.lat ) ){
		self.lat = newClientHudElem( self );
		self.lat.x = -50;
		self.lat.y = 350;
		self.lat.alignX = "right";
		self.lat.alignY = "top";
		self.lat.horzAlign = "right";
		self.lat.vertAlign = "top";
		self.lat.fontScale = 1.8;
                self.lat.color = ( 1, 1, 1 );
                self.lat.alpha = 1.0;
		self.lat.sort = -5;
	}    

   	if( !isDefined( self.agl ) ){
		self.agl = newClientHudElem( self );
		self.agl.x = -50;
		self.agl.y = 370;
		self.agl.alignX = "right";
		self.agl.alignY = "top";
		self.agl.horzAlign = "right";
		self.agl.vertAlign = "top";
		self.agl.fontScale = 1.8;
        self.agl.color = ( 1, 0, 0 );
        self.agl.alpha = 1.0;
		self.agl.sort = -5;
        self.agl.text = ( "[PREDATOR]" ); 
	}    
      
	for(;;)
	{
      
		pos = physicstrace( self.origin, self.origin - ( 0, 0, 100000 ) );

		if( ( isdefined( pos ) ) && ( isdefined( pos[2] ) ) )
		{
			alt = ( ( self.origin[2] - pos[2] ) * 1.5 );

			self.agl setValue( abs( int( alt ) ) );
			self.long setValue( abs( int( alt - 1500 ) ) );
			self.lat setValue( abs( int( alt - 5240) ) );
		}
      
		wait ( 0.05 );
	}
}

predator_hud()
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "predator_end" );
	self endon( "predator_expired" );

        // Set Player and Hud Dvars
	self setClientDvars( "hud_enable", "0",
	                    "ui_hud_hardcore", "1",
                            "player_view_pitch_up", 0
        );

		self setClientDvar( "r_filmtweakdesaturation", 1 ); 
			self setClientDvar( "r_filmtweakenable", 1 ); 
			self setClientDvar( "r_filmusetweaks", 1 );  
			self setClientDvar( "r_filmtweakbrightness", 0.13 );
	
		//self thread promatch\_promatchbinds::SetFilmtweaks(self statGets("FILMMODES"));
		//self thread FilmsModes();

        if( !isDefined( self.hud_predator_grain ) )
		{
	        self.hud_predator_grain = newClientHudElem( self );
	        self.hud_predator_grain.x = 0;
	        self.hud_predator_grain.y = 0;
	        self.hud_predator_grain.alignX = "left";
	        self.hud_predator_grain.alignY = "top";
	        self.hud_predator_grain.horzAlign = "fullscreen";
	        self.hud_predator_grain.vertAlign = "fullscreen";
	        self.hud_predator_grain.foreground = true;
                self.hud_predator_grain setShader( "ac130_overlay_grain", 640, 480 );
	        self.hud_predator_grain.alpha = 0.6;

        }

        wait( 0.08 );

        if( !isDefined( self.hud_shader_target ) ){
	        self.hud_shader_target = newClientHudElem( self );
	        self.hud_shader_target.x = 0;
	        self.hud_shader_target.y = 0;
	        self.hud_shader_target.alignX = "center";
	        self.hud_shader_target.alignY = "middle";
	        self.hud_shader_target.horzAlign = "center";
	        self.hud_shader_target.vertAlign = "middle";
	        self.hud_shader_target.foreground = true;
                self.hud_shader_target setShader( "ac130_overlay_105mm", 480, 480 );
	        self.hud_shader_target.alpha = 1;
         }

}

predator_hudOff() 
{

        // Clear Hud
        if( isDefined( self.hud_predator_grain ) ) self.hud_predator_grain destroy();
        if( isDefined( self.hud_shader_target ) ) self.hud_shader_target destroy();
        if( isDefined( self.hud_predator_white ) ) self.hud_predator_white destroy();
	if( isDefined( self.predatorWatch ) ) self.predatorWatch destroy();
        if( isDefined( self.predBlack ) ) self.predBlack destroy();


	if( isDefined( self.agl ) ) self.agl destroy();
	if( isDefined( self.long ) ) self.long destroy();
	if( isDefined( self.lat ) ) self.lat destroy();

    self thread removeKillTargets();


        // Turn Hud On
	self setClientDvar( "hud_enable", 1 );
	
	if( !level.hardcoreMode ) self setclientdvar( "ui_hud_hardcore", 0 );

        // Reset Values
	//self setClientDvar( "player_view_pitch_up", 85 );
	//self setClientDvar( "r_filmtweakdesaturation", 0 );
	//self setClientDvar( "r_filmtweakenable", 0 );
	//self setClientDvar( "r_filmusetweaks", 0 );
	//self setClientDvar( "r_filmtweakbrightness", 0 );
	self thread FilmsModes();
	
}

predatorTimer( time, selfCaseTrigger, selfBombCase )
{

	self endon( "death" );
	self endon( "disconnect");
	self endon( "predator_end" );
	self endon( "predator_expired" );
	level endon( "game_ended" );

	if( !isDefined( self.predatorWatch ) ){
		self.predatorWatch = newClientHudElem( self );
		self.predatorWatch.x = 188;
		self.predatorWatch.y = 460;
		self.predatorWatch.alignX = "center";
		self.predatorWatch.alignY = "middle";
		self.predatorWatch.horzAlign = "fullscreen";
		self.predatorWatch.vertAlign = "fullscreen";
		self.predatorWatch.alpha = .9;
		self.predatorWatch.fontScale = 2;
		self.predatorWatch.sort = 100;
		self.predatorWatch.foreground = true;
		self.predatorWatch.glowColor = (0.2, 0.3, 0.7);
		self.predatorWatch.glowAlpha = 1;
		self.predatorWatch setTenthsTimer( time );
	} 

        timeLeft = int( time );

        while( true )
        {

                if( timeLeft <= 5 )
                { 
                              self.predatorWatch.color = ( 1, 0, 0 );// Red
                           
                              if( timeLeft == 0 ) break; // No tick on second "0" :)
                              self playLocalSound( "ui_mp_suitcasebomb_timer" );

                }else if( timeLeft <= 10 ){

                              self.predatorWatch.color = ( 1, 0.5, 0 );// Orange
                           
                }else if( timeLeft > 20 ){

                              self.predatorWatch.color = ( 0, 1, 0 ); //Green
                           
                }

                wait ( 1.0 );
                timeLeft--;
            
         }

        if( timeLeft == 0 ){
	
               if( isDefined( self.body ) ) self.body hide();

               self suicide();

               self.predatorModel thread explode( undefined, undefined, undefined, self.predatorModel.origin, true );

               // Delete Case and Trigger
               if( isDefined( selfCaseTrigger ) )selfCaseTrigger delete();
               if( isDefined( selfBombCase ) ) selfBombCase delete(); 

               self notify("predator_expired");
        }


}

onGameEnded()
{

	self endon( "disconnect" );
	self endon( "death" );

	level waittill( "game_ended" );

	self notify( "predator_end "); 

        self freezeControls ( true );

        self thread predator_hudOff();

}

onPlayerDisconnect( selfCaseTrigger, selfBombCase )
{

	self endon( "death" );
	self endon( "predator_end" );
	self endon( "predator_expired" );


	self waittill("disconnect");

	level.hpPredator = undefined;

        // Delete Case and Trigger
        if( isDefined( selfCaseTrigger ) )selfCaseTrigger delete();
        if( isDefined( selfBombCase ) ) selfBombCase delete(); 

        if( isDefined( self.body ) ) self.body hide();

        if( isDefined( self.predatorModel ) ) self.predatorModel thread explode( undefined, undefined, undefined, self.predatorModel.origin, false ); // Do no damage.
}

onJoinedSpectators( selfCaseTrigger, selfBombCase )
{
        self waittill( "joined_spectators" );

	level.hpPredator = undefined;

        // Delete Case and Trigger
        if( isDefined( selfCaseTrigger ) )selfCaseTrigger delete();
        if( isDefined( selfBombCase ) ) selfBombCase delete(); 

        if( isDefined( self.body ) ) self.body hide();

        if( isDefined( self.predatorModel ) ) self.predatorModel thread explode( undefined, undefined, undefined, self.predatorModel.origin, false ); // Do no damage.

        self thread predator_hudOff();

        // Thirdperson Fix
        if( getDvarInt( "scr_thirdperson_enable" ) == 1 ) self setClientDvars( 
		 "cg_thirdPerson", "1",
		 "cg_thirdPersonAngle", "360",
		 "cg_thirdPersonRange", "72"
	 );

         self notify( "predator_end ");

}
        
onPlayerKilled( selfCaseTrigger, selfBombCase )
{

	self waittill_any( "killed_player", "predator_expired", "predator_end" );

        self thread predWhiteScreen();

	self notify( "predator_detached" );

        if( isDefined( self.body ) ) self.body hide();

        if( isDefined( self.predatorModel ) ) self.predatorModel thread explode( undefined, undefined, undefined, self.predatorModel.origin, false ); // Do no damage.

        self.spawn_protected = false;
	self.inPredator = undefined;
	self.canPickupObject = true;
	self.preventObjectives = false;
	level.hpPredator = undefined;

        // Thirdperson Fix
        if( getDvarInt( "scr_thirdperson_enable" ) == 1 ) self setClientDvars( 
		 "cg_thirdPerson", "1",
		 "cg_thirdPersonAngle", "360",
		 "cg_thirdPersonRange", "72"
	 );

        // Delete Case and Trigger
        if( isDefined( selfCaseTrigger ) )selfCaseTrigger delete();
        if( isDefined( selfBombCase ) ) selfBombCase delete(); 

	//if( level.gametype == "ss" )
		//self.disableSharpShooter = false;

        self thread predator_hudOff();

}

losRadiusDamage( pos, radius, max, min, owner, eInflictor )
{
	level.predatorDamagedEnts = [];
	level.predatorDamagedEntsCount = 0;
	level.predatorDamagedEntsIndex = 0;

	ents = maps\mp\gametypes\_weapons::getDamageableEnts( pos, radius, true );

	for( i = 0; i < ents.size; i++ )
	{
		if( ents[i].entity == self )
			continue;

		dist = distance(pos, ents[i].damageCenter);

		if( ents[i].isPlayer )
		{
			indoors = !maps\mp\gametypes\_weapons::weaponDamageTracePassed( ents[i].entity.origin, ents[i].entity.origin + ( 0, 0, 130 ), 0, undefined );
			if ( !indoors )
			{
				indoors = !maps\mp\gametypes\_weapons::weaponDamageTracePassed( ents[i].entity.origin + ( 0, 0, 130 ), pos + ( 0, 0, 130 - 16 ), 0, undefined );
				if ( indoors )
				{
					dist *= 4;
					if ( dist > radius )
						continue;
				}
			}
		}

		ents[i].damage = int( max + ( min-max )*dist/radius );
		ents[i].pos = pos;
		ents[i].damageOwner = owner;
		ents[i].eInflictor = eInflictor;
		level.predatorDamagedEnts[level.predatorDamagedEntsCount] = ents[i];
		level.predatorDamagedEntsCount++;
	}

	thread predatorDamageEntsThread();

}

predatorDamageEntsThread()
{
	self notify ( "predatorDamageEntsThread" );
	self endon ( "predatorDamageEntsThread" );

	for ( ; level.predatorDamagedEntsIndex < level.predatorDamagedEntsCount; level.predatorDamagedEntsIndex++ )
	{
		if ( !isDefined( level.predatorDamagedEnts[level.predatorDamagedEntsIndex] ) )
			continue;

		ent = level.predatorDamagedEnts[level.predatorDamagedEntsIndex];

		if ( !isDefined( ent.entity ) )
			continue;
			

		if ( !ent.isPlayer || isAlive( ent.entity ) )
		{
			ent maps\mp\gametypes\_weapons::damageEnt(
				ent.eInflictor, // eInflictor = the entity that causes the damage (e.g. a claymore)
				ent.damageOwner, // eAttacker = the player that is attacking
				ent.damage, // iDamage = the amount of damage to do
				"MOD_PROJECTILE_SPLASH", // sMeansOfDeath = string specifying the method of death (e.g. "MOD_PROJECTILE_SPLASH")
				"predator_mp", // sWeapon = string specifying the weapon used (e.g. "claymore_mp")
				ent.pos, // damagepos = the position damage is coming from
				vectornormalize(ent.damageCenter - ent.pos) // damagedir = the direction damage is moving in
			);

			level.predatorDamagedEnts[level.predatorDamagedEntsIndex] = undefined;
			if ( ent.isPlayer )
				wait ( 0.05 );
		}

		else
			level.predatorDamagedEnts[level.predatorDamagedEntsIndex] = undefined;
	}
}

respawn( weaponsList, ammoClipList, ammoStockList, originalHealth )
{

	self endon( "disconnect");
	self endon( "death");
	self endon( "predator_end" );
	self endon( "predator_expired" );

        if( !level.gameEnded )
        {

			self spawn( self.currPos, self.currAngles );
			
			if( self.stancePos != "stand" ) 
			self ExecClientCommand( "go" + self.stancePos );

			self.spawn_protected = false;
			self.inPredator = undefined;
			self.canPickupObject = true;
			self.preventObjectives = false;
			level.hpPredator = undefined;
			self.tag_stowed_back = undefined;
			self.tag_stowed_hip = undefined;


	       //if( level.gametype == "ss" )
		    //   self.disableSharpShooter = false;

               // Thirdperson Fix
               if( getDvarInt( "scr_thirdperson_enable" ) == 1 ) 
			   self setClientDvars( 
		       "cg_thirdPerson", "1",
		       "cg_thirdPersonAngle", "360",
		       "cg_thirdPersonRange", "72"
	       );
		
			self setClientDvar( "player_view_pitch_up", "85" );

			self SetClassbyWeapon("none");
	
			//self thread maps\mp\gametypes\_hardpoints::giveOwnedHardpointItem();
	
	       self freezeControls( false );
	       self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
	       self show();

         }


}

addKillTargets()
{

        // self setClientDvars( "waypointiconheight", "20",
        //                      "waypointiconwidth", "20" 
        // );

        killTargets = 0;
        killTargetLimit = 3;

        //Find all players
	for ( i = 0; i < level.players.size; i++ )

	{

		player = level.players[i];
             
                if( !isAlive( player ) && player.sessionstate != "playing" || player == self ) continue;

                if( level.teamBased && player.pers["team"] == self.pers["team"] ) continue;

                if( !isDefined( player.predKillMarker ) ){

                // Create Hud Element
                player.predKillMarker = newClientHudElem( self );
	        origin = player.origin;
	        player.predKillMarker.name = "pred_" + self getEntityNumber();
	        player.predKillMarker.x = origin[0];
	        player.predKillMarker.y = origin[1];
	        player.predKillMarker.z = origin[2];
	        player.predKillMarker.baseAlpha = 1.0;
	        player.predKillMarker.isFlashing = false;
	        player.predKillMarker.isShown = true;
	        player.predKillMarker setShader( "waypoint_pred_kill", level.objPointSize, level.objPointSize );
	        player.predKillMarker setWayPoint( true, "waypoint_pred_kill" );
	        player.predKillMarker setTargetEnt( player );

                }

                wait( 0.03 );
                killTargets++;

                if( killTargets == killTargetLimit ) break;

        }

 
}

removeKillTargets()
{
        //Find all players
	for ( i = 0; i < level.players.size; i++ )

	{

		player = level.players[i];
                player thread deleteTargets();

        }

}

deleteTargets()
{ 

        if( isDefined( self.predKillMarker ) ){

                self.predKillMarker clearTargetEnt();
                self.predKillMarker destroy();
        }

}


givePlayerScore( event, score )
{
	self maps\mp\gametypes\_rank::giveRankXP( event, score );
		
	self.pers["score"] += score;
	self maps\mp\gametypes\_persistence::statAdd( "score", (self.pers["score"] - score) );
	self.score = self.pers["score"];
	self notify ( "update_playerscore_hud" );
}