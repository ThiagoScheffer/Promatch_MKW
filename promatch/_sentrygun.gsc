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
// Primary Sentry Turret code and models by INSANE.
// Additional code functions by Samuel, DemonSeed, Braxi & Hacker22.
// Additional OW code by [105]HolyMoly.
// V.4.1 Final

#include maps\mp\_utility;
#include common_scripts\utility;
#include promatch\_utils;

init()
{
 
        // Turret
	level.sentryTurretTags = [];
	level.sentryTurretTags[level.sentryTurretTags.size] = "tag_base";
	level.sentryTurretTags[level.sentryTurretTags.size] = "tag_swivel";
	level.sentryTurretTags[level.sentryTurretTags.size] = "tag_gun";
	level.sentryTurretTags[level.sentryTurretTags.size] = "tag_barrel";
	
	level.barricade =  "mil_barbedwire2"; //ch_crate24x24 mil_barbedwire2
	precacheModel( level.barricade);	
	precacheModel( "riot_shield_view" );
	
        // Strings
	game["sentrygun_pickup_hint"] = &"MP_SENTRYGUN_HINT";
	precacheString( game["sentrygun_pickup_hint"] );

	game["sentrygun_repair_hint"] = &"MP_SENTRYGUN_REPAIR_HINT";
	precacheString( game["sentrygun_repair_hint"] );

	game["sentrygun_repair"] = &"MP_SENTRYGUN_REPAIR";
	precacheString( game["sentrygun_repair"] );

	precacheShader( "hint_usable" );
	
        // FX
	level.fx_sentryTurretExplode = loadfx( "explosions/grenadeExp_metal" );
	level.fx_sentryTurretFlash = loadfx( "muzzleflashes/minigun_flash_view" );
	level.fx_sentryTurretShellEject = loadfx( "shellejects/rifle" );
	level.fx_sentryTurretSparks = loadfx( "props/securityCamera_explosion" );
	
        // Turret Dvar Settings
	level.sentryTurretClipSize = 500;
	level.sentryTurretHealth = 3000;
	level.scr_sentrygun_timer = 0;	
	level.scr_sentrygun_range = 1200;
	level.scr_sentrygun_ground_trace = 1;
	
	
	level.scr_sentrygun_surface_deploy = 1;
	level.scr_sentrygun_water_placement = 1;
	level.scr_sentrygun_moving_placement = 1;//If Sentry Gun can be deployed while player is moving
	
	level.scr_sentrygun_show_hint = 0;
	
	level.scr_sentrygun_look_forward_plant = 1;
	level.scr_sentrygun_timer_penalty = 0;
	
	level.scr_sentrygun_knife_kill = 0;
	
	
	level.scr_sentrygun_concussion_kill = 1;//adaptar para magnade
	
	level.scr_sentrygun_allow_repair = 1;
	
	level.scr_sentrygun_repair_time = 10;
	
	level.scr_sentrygun_repair_no_movement = 1;
	
	level.scr_sentrygun_damage_chance = 40;
	level.scr_sentrygun_percent_fx = 10;
	level.scr_sentrygun_perk_jammer = 1;
	level.scr_sentrygun_perk_juggernaut = 1;
	level.scr_sentrygun_kill_score = 10;
	level.scr_sentrygun_show_headicon = 0;
	level.scr_sentrygun_allow_hudicons = 1;

        // Precache
		precacheModel( "mw2_sentry_turret" );
        precacheShader( "compass_sentry_gun_red" );
        precacheShader( "waypoint_sentry_gun" );

        level thread onPlayerConnected();

}

onPlayerConnected()
{
	for(;;)
	{
		level waittill( "connected", player );

                player.hasMovedTurret = 0;
                player.hasTurretPlacement = undefined;
                player.hasDeployedTurret = undefined;
                player.isEntMoving = undefined;
                player.turretTime = -1;

				player.turretsdeployed = 0;;
        }

}

sentry_check() // Check for proper placement of Turret
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "game_ended" );


	if(isDefined(self.turretsdeployed) && self.turretsdeployed > 0)
	{
		self showHintText( "^1Voce ja tem uma Sentry ativa!" );
		return;
	}
	
		if ( self.pers["rank"] < 1 )
		{
			self showHintText( "^1Voce nao tem Rank para isso !" );
			return;
		}
		
		
        // Placement & movement initially passes 
        self.hasTurretPlacement = true;
        self.isEntMoving = false;
        self.weaponsDisabled = false;

        // Start Position Check
        angles =  self getPlayerAngles();
        start = self.origin + ( 0, 0, 20 ) + vectorScale( anglesToForward( angles ), 5 );
        end = self.origin + ( 0, 0, 20 ) + vectorScale( anglesToForward( angles ), 80 );
        endDrop = self.origin + ( 0, 0, 20 ) + vectorScale( anglesToForward( angles ), 40 );

        // Angle Checks
        left = vectorScale( anglesToRight( angles ), -20 );
        right = vectorScale( anglesToRight( angles ), 20 );
        back = vectorScale( anglesToForward( angles ), -20 );

        // Bullet Trace Checks
        check1 = bulletTracePassed( start, end, true, self );
        check2 = bulletTracePassed( start + ( 0, 0, -7 ) + left, end + left + back, true, self );
        check3 = bulletTracePassed( start + ( 0, 0, -7 ) + right , end + right + back, true, self );

        // Check if Turret has good placement
        if( !check1 || !check2 || !check3 ) {

             if( !check1 )
                     self showHintText( "^1Object ^7too close infront!" );

             if( !check2 )
                     self showHintText( "^1Object ^7too close to your left!" );

             if( !check3 )
                     self showHintText( "^1Object ^7too close to your right!" );

	     self.hasTurretPlacement = false;
             return;
        }

        // Trace Down
        if( level.scr_sentrygun_ground_trace == 1 ) 
		{
                trace = bulletTrace( endDrop + ( 0, 0, 0 ), endDrop + ( 0, 0, -18 ), false, self );
        } else {
                trace = bulletTrace( endDrop + ( 0, 0, 0 ), endDrop + ( 0, 0, -99999 ), false, self );
        }

        // Trace Up
        traceUp = bulletTrace( endDrop + ( 0, 0, 0 ), endDrop + ( 0, 0, 60 ), false, self );

        // Trace Down Left
        traceDownLeft = bulletTrace( endDrop + ( 0, -35, 0 ), endDrop + ( 0, -35, -18 ), false, self );

        // Trace Down Right
        traceDownRight = bulletTrace( endDrop + ( 0, 35, 0 ), endDrop + ( 0, 35, -18 ), false, self );

        // Trace Up Right
        traceUpRight = bulletTrace( endDrop + ( 0, 35, 0 ), endDrop + ( 0, 35, 60 ), false, self );

        // Trace Up Left
        traceUpLeft = bulletTrace( endDrop + ( 0, -35, 0 ), endDrop + ( 0, -35, 60 ), false, self );

        // Turret already active
        if( isDefined( self.hasDeployedTurret ) && self.hasDeployedTurret == true ) {
                return;
        }

        // Check if moving placement allowed
        if( level.scr_sentrygun_moving_placement == 0 ) {
                if( isEntMoving( self ) ) {
                        self.isEntMoving = true;
                        return;
                }
        }

        // Check if near Objective Safe Zone
        if( isDefined( self.safeZone ) ) {
                for ( index = 0; index < self.safeZone.size; index++ ) {
                        if( self isTouching( self.safeZone[index] ) ) {
                                self.hasTurretPlacement = false;
                                self showHintText( "^1NO ^7deployment near an Objective!" );
                                return; 
                        }
                }
        }

        // Check if near Objective Safe Zone.... If using Sammy's code
        if( isDefined( game["safezones"] ) ) {
                for ( index = 0; index < game["safezones"].size; index++ ) {
                        if( self isTouching( game["safezones"][index] ) ) {
                                self.hasTurretPlacement = false;
                                self showHintText( "^1NO ^7deployment near an Objective!" );
                                return; 
                        }
                }
        }

        // Cannot place if in Spawn Protection
	if( isDefined( self.spawn_protected ) && self.spawn_protected == true ) {
                self.hasTurretPlacement = false;
                self showHintText( "^1NO ^7deployment while in Spawn Protection" );
		return;
        }

        
        // No Deployment below water surfaces
        if( level.scr_sentrygun_water_placement == 1 ) {
                if( traceUp["surfacetype"] == "water" ) {
	                self.hasTurretPlacement = false;
                        self showHintText( "^1NO ^7deployment below " + traceUp["surfacetype"] + " surface!" );
                        return;
                }

                // No deployment on water surface if it's deep water
                if( trace["surfacetype"] == "water" ) {
                        traceAgain = bulletTrace( trace["position"] + ( 0, 0, -10 ), trace["position"] + ( 0, 0, -99999 ), false, self );

                        if( isDeployableSurface( traceAgain["surfacetype"] ) ) {
	                        self.hasTurretPlacement = false;
                                self showHintText( "^1NO ^7deployment on " + trace["surfacetype"] + " surface!" );
                                return;
                        }
                }
        }

        // Has to be looking forward..... No more than 15 degrees up or down
        if( level.scr_sentrygun_look_forward_plant == 1 ) {
                if( !isLookingForward( self ) ) {
                        self.hasTurretPlacement = false;
                        self showHintText( "Look ^1Forward ^7when planting Turret!" );
                        return;
                }
        }

        // No deployment on a non deployable surface
        if( level.scr_sentrygun_surface_deploy == 1 ) {
                if( !isDeployableSurface( trace["surfacetype"] ) ) {
	                self.hasTurretPlacement = false;
                        if( trace["surfacetype"] == "none" ) {
                                self showHintText( "^1NO ^7deployment surface detected!" );
                        } else {
                                self showHintText( "^1NO ^7deployment on " + trace["surfacetype"] + " surface!" );
                        }
                        return;
                }
        }

        // No drop if there is no trace to ground... 18 units... more thorough check
        if( level.scr_sentrygun_ground_trace == 1 ) {
                if( trace["fraction"] == 1 || traceDownLeft["fraction"] == 1 || traceDownRight["fraction"] == 1 ) {
	                self.hasTurretPlacement = false;
                        self showHintText( "^1NO ^7deployment surface detected!" );
                        return;
                }

                // No drop if there is a trace hit above ground on the edges... 60 units
                if( traceUpRight["fraction"] != 1 || traceUpLeft["fraction"] != 1 ) {
	                self.hasTurretPlacement = false;
                        self showHintText( "^1NO ^7room above to plant!" );
                        return;
                }
        }

        // Deploy Turret
        self thread deploy_turret( trace["position"], ( 0, angles[1], 0 ) );

        // Start monitor threads
        self thread onJoinedTeamOrSpectators();

        if( level.scr_sentrygun_concussion_kill > 0 )
                self thread sentry_concussion();

		self.turretsdeployed = 1;
		
		self SetRankPoints(-300);
		self HabilidadeUsada(350);
	
}

deploy_turret( position, angles )
{

	self.sentryTurret = [];
	self.sentryTurret[self.sentryTurret.size] = spawn( "script_model", position ); // Base
	self.sentryTurret[0] setModel( "mw2_sentry_turret" );
	self.sentryTurret[0].angles = angles;
	self.sentryTurret[0].owner = self;
	self.sentryTurret[0].team = self.pers["team"];
	self.sentryTurret[0].targetname = "sentryTurret";
	self.sentryTurret[0].origin = position;
	self.sentryTurret[0] thread manual_move();
	self.sentryTurret[0] thread sentry_damage();

        if( level.scr_sentrygun_show_headicon == 1 ) 
		{
	        self.sentryTurret[0] maps\mp\_entityheadicons::setEntityHeadIcon( self.sentryTurret[0].team, ( 0, 0, 70 ) );
        }

        if( level.scr_sentrygun_allow_hudicons == 1 ) 
		{

	        team = self.pers["team"];
	        otherTeam = level.otherTeam[team];

	        // Check if we should show the icon on the compass
	        if ( level.scr_hud_show_2dicons == 1 ) {
		        // Get the next objective ID to use
		        level.objCompassTurret = maps\mp\gametypes\_gameobjects::getNextObjID();
		        objective_add( level.objCompassTurret, "active", position  + ( 0, 0, 75 ) );
		        objective_icon( level.objCompassTurret, "compass_sentry_gun_red" );
		        objective_team( level.objCompassTurret, otherTeam );
	        }
		
	        // Check if we should show the world icon
	        if ( level.scr_hud_show_3dicons == 1 ) 
			{
		        level.objWorldTurret = newTeamHudElem( team );		
			
		        // Set stuff for world icon
		        origin = position + ( 0, 0, 110 );
		        level.objWorldTurret.name = "waypoint_sentry_gun";
		        level.objWorldTurret.x = origin[0];
		        level.objWorldTurret.y = origin[1];
		        level.objWorldTurret.z = origin[2];
		        level.objWorldTurret.baseAlpha = 0.9;
		        level.objWorldTurret.isFlashing = false;
		        level.objWorldTurret.isShown = true;
		        level.objWorldTurret setShader( "waypoint_sentry_gun", level.objPointSize, level.objPointSize );
		        level.objWorldTurret setWayPoint( true, "waypoint_sentry_gun" );
                        level.objWorldTurret thread maps\mp\gametypes\_objpoints::startFlashing();
            }

	}

	for( x = 0; x < level.sentryTurretTags.size; x++ )
		if( level.sentryTurretTags[x] != "tag_base" )
			self.sentryTurret[0] hidePart( level.sentryTurretTags[x] );

	wait( 0.05 );

	self.sentryTurret[self.sentryTurret.size] = spawn( "script_model", self.sentryTurret[0] getTagOrigin( "j_pivot" ) ); // Swivel
	self.sentryTurret[self.sentryTurret.size] = spawn( "script_model", self.sentryTurret[0] getTagOrigin( "j_hinge" ) ); // Gun
	self.sentryTurret[self.sentryTurret.size] = spawn( "script_model", self.sentryTurret[0] getTagOrigin( "j_barrel" ) ); // Barrel

	for( i = 1; i < self.sentryTurret.size; i++ )
	{
		self.sentryTurret[i] setModel( "mw2_sentry_turret" );
		self.sentryTurret[i].angles = angles;
		self.sentryTurret[i].owner = self;
		self.sentryTurret[i].team = self.pers["team"];
		self.sentryTurret[i].targetname = "sentryTurret";
		self.sentryTurret[i] thread manual_move();
		self.sentryTurret[i] thread sentry_damage();

		if( i == 1 )
		{
			for( x = 0; x < level.sentryTurretTags.size; x++ )
				if( level.sentryTurretTags[x] != "tag_swivel" )
					self.sentryTurret[i] hidePart( level.sentryTurretTags[x] );
		}
		if( i == 2 )
		{
			for( x = 0; x < level.sentryTurretTags.size; x++ )
				if( level.sentryTurretTags[x] != "tag_gun" )
					self.sentryTurret[i] hidePart( level.sentryTurretTags[x] );
		}
		if( i == 3 )
		{
			for( x = 0; x < level.sentryTurretTags.size; x++ )
				if( level.sentryTurretTags[x] != "tag_barrel" )
					self.sentryTurret[i] hidePart( level.sentryTurretTags[x] );
		}
	}

	self.sentryTurretDamageTaken = 0;
	self.sentryTurretIsIdling = true;
	self.sentryTurretIsTargeting = false;
	self.sentryTurretIsFiring = false;
	self.sentryTurretTarget = undefined;
    self.hasDeployedTurret = true;

	self thread sentry_idle();
	self thread sentry_targeting();
    self thread preventWeaponsPickup();

        // If initial timer = 0
        if( level.scr_sentrygun_timer == 0 ) {
                self playSound( "sentrygun_plant" );
        }

        // Start Timer
        if( level.scr_sentrygun_timer > 0 ) {
                self thread sentry_clock();
        }

        // Wait to make solid if owner is "IN" Turret when turret spawns
        if( self.turretTime == -1 || self.turretTime >= 2 ) 
		{
                while( distance( self.origin, position ) <= 30 ) {
                        wait( 0.05 );
                }

                // Make Solid
                for( i = 0; i < ( self.sentryTurret.size - 1 ); i++ ) {
                        self.sentryTurret[i] setContents( 1 );
                }
        }

}

sentry_clock()
{
        self endon( "disconnect" );
        self endon( "sentry_turret_over" );


        // Destroy Timer if present
        if( isDefined( self.turretTimer ) ) {
                self.turretTimer destroy();
        }

        // Amount of Penalty time to be Multiplied
        penaltyTime = ( level.scr_sentrygun_timer_penalty );

        // Progressive penalty for moving Turret
        if( self.hasMovedTurret > 0 ) 
		{
                time = int( self.turretTime - ( penaltyTime * self.hasMovedTurret )  );
                        if( time < 0 ) {
                                time = 1;
                        }
        } else {
 
                time = int( level.scr_sentrygun_timer );
        }

        if( !isDefined( self.turretTimer ) )
	{
	        self.turretTimer = newClientHudElem( self );
	        self.turretTimer.x = 170;
	        self.turretTimer.y = 460;
	        self.turretTimer.alignx = "center";
	        self.turretTimer.aligny = "middle";
	        self.turretTimer.horzAlign = "fullscreen";
	        self.turretTimer.vertAlign = "fullscreen";

                if( level.hardcoreMode ) {
	        self.turretTimer.alpha = 0;
                } else {
                        self.turretTimer.alpha = 1;
                }

	        self.turretTimer.fontScale = 1.6;
	        self.turretTimer.sort = -1;
	        self.turretTimer.foreground = true;
	        self.turretTimer setTenthsTimer( time );
	} 
		
        self.turretTime = int( time );

        // Plant sound if there is enough time to hear it
        if( self.turretTime >= 1 ) {
                self playSound( "sentrygun_plant" );
        }

        while( true )
        {

                if( level.gameEnded || level.intermission ) {

                        if( isDefined( self.turretTimer ) ) {
                                self.turretTimer destroy();
                                break;
                        }
                }

                if( !level.hardcoreMode ) {

                        if( self.turretTime <= 10 ) {
 
                              self.turretTimer.color = ( 1, 0, 0 );// Red
                           
                              if( self.turretTime == 0 ) {
                                      break; // No tick on second "0" :)
                              }

                              if( self.sessionstate == "playing" ) {
                                      self playLocalSound( "ui_mp_suitcasebomb_timer" );
                              }

                        } else if( self.turretTime <= 20 ){

                                      self.turretTimer.color = ( 1, 0.5, 0 );// Orange
                           
                        } else {

                                self.turretTimer.color = ( 0, 1, 0 ); //Green        
                        }

                } 

                if( level.hardcoreMode ) {
                           
                        if( self.turretTime == 0 ) {
                                break; // No tick on second "0" :)
                        }

                        if( self.turretTime <= 10 ) {

                                if( self.sessionstate == "playing" ) {
                                        self playLocalSound( "ui_mp_suitcasebomb_timer" );
                                }
                        }
                }
                        

                wait ( 1.0 );
                self.turretTime--;
            
        }

        if( self.turretTime <= 0 ) {
                self thread sentry_explode();
        }

}

sentry_idle()
{
	self endon( "disconnect" );
	self endon( "end_sentry_turret" );

	wait( 0.5 );

	while( 1 )
	{

		if( self.sentryTurretIsTargeting )
		{
			while( self.sentryTurretIsTargeting )
				wait( 0.5 );
		}

		self.sentryTurretIsIdling = true;

                self.sentryTurret[1] playLoopSound( "sentrygun_hyd_turn_idle" );

		randomYaw = randomIntRange( -360, 360 );

		for( i = 1; i < self.sentryTurret.size; i++ )
			self.sentryTurret[i] rotateYaw( randomYaw, 3, .5, .5 );

		wait( 3.0 );

                self.sentryTurret[1] stopLoopSound();

		self.sentryTurretIsIdling = false;

                if( level.gameEnded || level.intermission ) {
                        self.sentryTurret[1] stopLoopSound();
                        break;
                }

	}

}

sentry_targeting()
{
	self endon( "disconnect" );
	self endon( "end_sentry_turret" );
        level endon( "game_ended" );
	
	self.sentryTurretTrig = spawn( "trigger_radius", self.sentryTurret[0].origin, 0, int( level.scr_sentrygun_range ), int( level.scr_sentrygun_range ) / 5 );
	self.sentryTurretTrig.origin = ( self.sentryTurret[0].origin - ( 0, 0, int( level.scr_sentrygun_range ) / 10 ) );
	
	while( true )
	{
		wait( 0.05 );
			
		if( !isDefined( self.sentryTurretTrig ) || !isDefined( self.sentryTurret ) )
			break;
	
		if( self.sentryTurretIsTargeting || self.sentryTurretIsFiring )
			continue;

		eligibleTargets = [];

		p = getentarray( "player", "classname" );

		for(i = 0; i < p.size; i++)
		{
                        if( !isDefined( p[i].model ) || p[i].model == "" )

				continue;

			if( p[i].sessionstate != "playing" )
				continue;

			if( p[i].health < 1 )
				continue;

			if( p[i] == self )
					continue;

			if(isDefined(p[i].coldblooded) && p[i].coldblooded)
			continue;
			
			if( level.teamBased && p[i].pers["team"] == self.pers["team"] )
				continue;

		        if ( level.gametype == "ftag" && p[i].freezeTag["frozen"] )
			        continue;

			if( isDefined( p[i].spawn_protected ) && p[i].spawn_protected == true )
				continue;

                        if( level.scr_sentrygun_perk_jammer == 1 && p[i] hasPerk( "specialty_gpsjammer" ) ) 
						{
							if( isDefined( p[i].firingWeapon ) && p[i].firingWeapon == false ) 
							{
									continue;
							}
                        }

			if( p[i] isTouching( self.sentryTurretTrig ) && SightTracePassed( self.sentryTurret[0] getTagOrigin( "j_barrel" ), p[i] getTagOrigin( "j_spine4" ), false, self.sentryTurret ) )
				eligibleTargets[eligibleTargets.size] = p[i];
		}

		if( !eligibleTargets.size ) {
			continue;
                }

		random = randomInt( eligibleTargets.size );
		target = eligibleTargets[random];
		self.sentryTurretTarget = target;

		self thread sentry_target();

		eligibleTargets = undefined;

	}

}

sentry_target()
{

	self endon( "disconnect" );
	self endon( "end_sentry_turret" );
        level endon( "game_ended" );

	if( self.sentryTurretIsFiring )
	{
		while( self.sentryTurretIsFiring )
			wait( 0.5 );
	}

	if( !isDefined( self.sentryTurretTarget ) || ( isDefined( self.sentryTurretTarget ) && self.sentryTurretTarget.health < 1 ) )
	{
		self.sentryTurretTarget = undefined;
		self.sentryTurretIsTargeting = false;
		return;
	}

	self.sentryTurretIsTargeting = true;

    self.sentryTurret[1] playLoopSound( "sentrygun_hyd_turn" );

	// aim toward target
	targetVec = vectorToAngles( self.sentryTurretTarget getTagOrigin( "j_spine4" ) - self.sentryTurret[3].origin);
	self.sentryTurretHinge = spawn( "script_origin", self.sentryTurret[0] getTagOrigin( "j_hinge" ) );
	self.sentryTurretHinge.angles = self.sentryTurret[2].angles;

	for( i = 2; i < self.sentryTurret.size; i++ )
		self.sentryTurret[i] linkTo( self.sentryTurretHinge );

	wait( 0.05 );

	self.sentryTurretHinge rotateTo( ( targetVec[0], targetVec[1], self.sentryTurret[2].angles[2] ), .3 );
	self.sentryTurret[1] rotateTo( ( self.sentryTurret[1].angles[0], targetVec[1], self.sentryTurret[1].angles[2] ), .3 );

	wait( 0.4 );

        self.sentryTurret[1] stopLoopSound();

	for( i = 2; i < self.sentryTurret.size; i++ )
		self.sentryTurret[i] unlink(); // Unlink after aimed correctly - Rest of positioning is taken care of in sentry_fire()

	wait( 0.05 );

	self thread sentry_fire();

	wait( 0.05 );

	if( self.sentryTurretIsFiring )
	{
		while( self.sentryTurretIsFiring )
			wait( 0.5 );
	}

	for( i = 2; i < self.sentryTurret.size; i++ )
		self.sentryTurret[i] linkTo( self.sentryTurretHinge );

	wait( 0.05 );

        self.sentryTurret[1] playLoopSound( "sentrygun_hyd_turn" );

	self.sentryTurretHinge rotateTo( ( 0, self.sentryTurret[2].angles[1], self.sentryTurret[2].angles[2] ), .25 );

	wait( 0.3 );

        self.sentryTurret[1] stopLoopSound();

	for( i = 2; i < self.sentryTurret.size; i++ )
		self.sentryTurret[i] unlink();

	if( isDefined( self.sentryTurretHinge ) ) {
		self.sentryTurretHinge delete();
        }

	self thread anchor_barrel();

	self.sentryTurretIsTargeting = false;
}

sentry_fire()
{
	self endon( "disconnect" );
	self endon( "end_sentry_turret" );
        level endon( "game_ended" );

	self.sentryTurretIsFiring = true;

	for( i = 0; i < level.sentryTurretClipSize; i++ )
	{
		wait( 0.05 );

		if( ( !isDefined( self.sentryTurretTarget ) ) || ( isDefined( self.sentryTurretTarget ) && self.sentryTurretTarget.health < 1 ) || ( isDefined( self.sentryTurretTarget ) && !sightTracePassed( self.sentryTurret[2] getTagOrigin( "j_barrel_anchor" ), self.sentryTurretTarget getTagOrigin( "j_spine4" ), false, self.sentryTurret ) ) )
			break;

		targetVec = vectorToAngles( self.sentryTurretTarget getTagOrigin( "j_spine4" ) - self.sentryTurret[3].origin );
		start = self.sentryTurret[3] getTagOrigin( "tag_flash" );
		end = self.sentryTurret[3] getTagOrigin( "tag_flash" ) + vector_scale( anglesToForward( self.sentryTurret[3] getTagAngles( "tag_flash" ) ), 10000 );
		ent = bulletTrace( start, end, true, self )["entity"];

		if( !isDefined( ent ) && isDefined( self.sentryTurretTarget ) )
		{
			self.sentryTurret[1] rotateTo( ( self.sentryTurret[1].angles[0], targetVec[1], self.sentryTurret[1].angles[2] ), .25 );
			self.sentryTurret[2] rotateTo( ( targetVec[0], targetVec[1], self.sentryTurret[2].angles[2] ), .25 );
		}

		self thread anchor_barrel();
		self.sentryTurret[3] rotateRoll( 72, .05, 0, 0 );

		self.sentryTurretHinge.origin = self.sentryTurret[2] getTagOrigin( "tag_origin" );
		self.sentryTurretHinge.angles = self.sentryTurret[2] getTagAngles( "tag_origin" );

		self.sentryTurret[3] playSound( "weap_m249saw_turret_fire_npc" );

		self.sentryTurret[3] thread sentry_bullet();
	}

	wait( 0.25 );

	self thread anchor_barrel();
	self.sentryTurretHinge.origin = self.sentryTurret[2] getTagOrigin( "tag_origin" );
	self.sentryTurretHinge.angles = self.sentryTurret[2] getTagAngles( "tag_origin" );

	wait( 0.25 );

	self.sentryTurretTarget = undefined;
	self.sentryTurretIsFiring = false;
}

anchor_barrel() // Position barrel correctly according to gun body
{
	self.sentryTurret[3].origin = self.sentryTurret[2] getTagOrigin( "j_barrel_anchor" );
	self.sentryTurret[3].angles = ( self.sentryTurret[2] getTagAngles( "j_barrel_anchor")[0], self.sentryTurret[2] getTagAngles( "j_barrel_anchor" )[1], self.sentryTurret[3].angles[2] );
}

sentry_bullet()
{
	self endon( "death" );
	self endon( "end_sentry_turret" );
        level endon( "game_ended" );

	wait( 0.05 );

	if( !isDefined( self ) )
		return;

	start = self getTagOrigin( "tag_flash" );
	end = self getTagOrigin( "tag_flash" ) + vector_scale( anglesToForward( self getTagAngles( "tag_flash" ) ), 10000 );
	ent = bulletTrace( start, end, true, self )["entity"];

	if( level.teamBased )
	{
		if( isDefined( ent ) && isPlayer( ent ) && isAlive( ent ) && isDefined( ent.pers["team"] ) && ent.pers["team"] != self.team )
		{
			ent thread [[level.callbackPlayerDamage]]
			(
				self,				// eInflictor	-The entity that causes the damage.(e.g. a turret)
				self.owner,			// eAttacker	-The entity that is attacking.
				10,					// iDamage	-Integer specifying the amount of damage done
				0,					// iDFlags		-Integer specifying flags that are to be applied to the damage
				"MOD_RIFLE_BULLET",	// sMeansOfDeath	-Integer specifying the method of death
				"p90_reflex_mp",				// sWeapon	-The weapon number of the weapon used to inflict the damage
				ent.origin,			// vPoint		-The point the damage is from?
				( 0, 0, 0 ),			// vDir		-The direction of the damage
				"none",				// sHitLoc	-The location of the hit
				0					// psOffsetTime	-The time offset for the damage
			);
		}
	}
	else 
	{
		if( isDefined( ent ) && isPlayer( ent ) && isAlive( ent ) )
		{
			ent thread [[level.callbackPlayerDamage]]
			(
				self,				// eInflictor	-The entity that causes the damage.(e.g. a turret)
				self.owner,			// eAttacker	-The entity that is attacking.
				20,					// iDamage	-Integer specifying the amount of damage done
				0,					// iDFlags		-Integer specifying flags that are to be applied to the damage
				"MOD_RIFLE_BULLET",	// sMeansOfDeath	-Integer specifying the method of death
				"p90_reflex_mp",				// sWeapon	-The weapon number of the weapon used to inflict the damage
				ent.origin,			// vPoint		-The point the damage is from?
				( 0, 0, 0 ),			// vDir		-The direction of the damage
				"none",				// sHitLoc	-The location of the hit
				0					// psOffsetTime	-The time offset for the damage
			);
		}
	}


	if( isDefined( ent ) && !isPlayer( ent ) )
	{
		ent notify( "damage", 20, self.owner, ( 0, 0, 0 ), ( 0, 0, 0 ), "MOD_RIFLE_BULLET" );
	}

}

sentry_damage()
{
	self endon( "death" );
	self endon( "sentry_turret_over" );
        level endon( "game_ended" );

	self setCanDamage( true );
	self.maxhealth = 999999;
	self.health = self.maxhealth;
	attacker = undefined;
	self.turretArmorVest = false;

	level.newHealth = level.sentryTurretHealth;

	while( true )
	{
		self waittill( "damage", dmg, attacker, vDir, vPoint, sMeansOfDeath );

			//
			
                // iDamage Fix 
               if( sMeansofDeath == "MOD_GRENADE" || sMeansofDeath == "MOD_GRENADE_SPLASH" ) 
				{
						//mag nade?
						if( dmg == 15 ) 
						{
							self.owner notify( "turret_concussion" );
						}
                }

                // Nube Tube hit no explosion
                if( sMeansofDeath == "MOD_IMPACT" ) 
				{
					dmg = 135;
					dmg /= 4;
                }
		
		if( dmg < 5 ) 
		{
			continue;
        }

        // Check allows for owner to damage their own Turret?
		//if( isDefined( attacker ) && !friendlyFireCheck( self.owner, attacker ) ) 
		//{
		//	continue;
       // }

		// Show hit Alert to Attacker
		if( isDefined( attacker ) && isPlayer( attacker ) && isAlive( attacker ) ) 
		{

				attacker.extraKillPoints = 500;    

				if( sMeansofDeath == "MOD_RIFLE_BULLET" || sMeansofDeath == "MOD_PISTOL_BULLET" ) 
				{

				// Has Deep Impact perk X2 damage
					if ( attacker hasPerk( "specialty_bulletpenetration" ) ) 
					{
						dmg *= 2;
					}					
				}
				//attacker ShowDebug("dmgturret",dmg);
				
				attacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( dmg );				
		}

                // Debug
                // iprintln( level.newHealth );

		self.owner.sentryTurretDamageTaken += dmg;

                // Turret Health less than Damage
		if( self.owner.sentryTurretDamageTaken >= level.newHealth ) 
		{

		        // Turret killed. Give a score to attacker and/or attacker Team
                        if( level.teamBased ) 
						{
                 
                                // SD and Demolition........ No team points for kills
                                if( level.overrideTeamScore == true ) 
								{

                                        if( attacker != self.owner ) 
										{
											if(attacker.pers["team"] == self.owner.pers["team"])
											{
											   attacker SetRankPoints(-100);
                                               attacker givePlayerScore( "kill", -400 );
											}
											else
											{
											   attacker SetRankPoints(300);
                                               attacker givePlayerScore( "kill", level.scr_sentrygun_kill_score + attacker.extraKillPoints );
											}
                                        }
 
                                } 
								else 
								{

                                        // War, Dom, etc........ Team and Player Points
                                        if( attacker != self.owner ) 
										{
												attacker givePlayerScore( "kill", level.scr_sentrygun_kill_score + attacker.extraKillPoints );
                                                [[level._setTeamScore]]( attacker.pers["team"], [[level._getTeamScore]]( attacker.pers["team"] ) + level.scr_sentrygun_kill_score + attacker.extraKillPoints );
                                        }
                                } 

                        } else {

                                // FFA.........Player Points
                                if( attacker != self.owner ) {
                                        attacker givePlayerScore( "kill", level.scr_sentrygun_kill_score + attacker.extraKillPoints );
                                }
                        } 
						break;
                }
	}
	
	if( !isDefined( self ) ) {return;}

        // Delete Message if for some reason owner knives Turret
        self.owner DeletePickupMessage();

	self.owner thread sentry_explode( attacker, sMeansofDeath );
}

manual_move() // Watch for owner manually moving his turret
{
	self endon( "death" );
	self endon( "end_sentry_turret" );
        level endon( "game_ended" );

	while( 1 )
	{
		wait( 0.05 );

                // No Turret.. quit thread!
		if( !isDefined( self ) ) {
			return;
                }

                // Owner not alive
                if( isDefined( self.owner ) && !isAlive( self.owner ) ) {
                        self.owner DeletePickupMessage();
                        continue;
                }

                // Owner frozen near Turret
		if ( level.gametype == "ftag" && self.owner.freezeTag["frozen"] ) {
                        self.owner DeletePickupMessage();
			continue;
                }

                // Cannot move Turret if owner in spawn protection.......may be Invisible
	        if( isDefined( self.owner.spawn_protected ) && self.owner.spawn_protected == true ) {
                        self.owner DeletePickupMessage();
			continue;
                }
			
		if( isDefined( self.owner ) && isDefined( self ) ) {

			if( ( distance( self.origin, self.owner.origin ) <= 40 ) && self.owner isLookingAt( self ) ) {
				self.owner CreatePickupMessage();
				
				if( self.owner useButtonPressed() ) 
				{
					self.owner thread sentry_remove( true );
					self.owner.turretsdeployed = 0;
                }

			} else 
			{
			   self.owner DeletePickupMessage();
            }
	
		}

	}

}

sentry_repair( trigger ) // self is owner
{

        while( isDefined( trigger ) ) 
        {
                trigger waittill( "trigger", player );

		// Check if the player has disconnected
		if ( !isDefined( player ) || !isDefined( player.pers ) )
			continue;

		// Make sure it's a player
		if ( !isPlayer( player ) )
			continue;

                // Must be alive
		if ( !isAlive( player ) )
			continue;
			
		// Make sure this player is not frozen
		if ( level.gameType == "ftag" && player.freezeTag["frozen"] )
			continue;

                // Make sure this player is not Spawn Protected
                if( isDefined( player.spawn_protected ) && player.spawn_protected == true ) {
                        continue;
                }

		while( isAlive( player ) && player isLookingAt( self.sentryTurret[0] ) && ( distance( self.sentryTurret[0].origin, player.origin ) <= 40 ) ) {

                        player CreateRepairMessage();

                        player.repairedTurret = false;
                        player.hasWeapons = true;
                        player.firstAngles = player.angles;
                        player.firstOrigin = player.origin;

                        wait( 0.15 );

		        if( isAlive( player ) && player useButtonPressed() ) {

                                player thread maps\mp\gametypes\_gameobjects::_disableWeapon();
                                player.hasWeapons = false;
                                player.canPickupObject = false;
                                player playSound( "mp_bomb_defuse" );
                        
                                player.progressTime = 0;

                                wait( 0.20 );

		                while( isAlive( player ) && player useButtonPressed() ) 
						{

                                        // Trigger is gone
                                        if( !isDefined( trigger ) ) {
                                                break;
                                        }

                                        // Game ended
                                        if( level.gameEnded || level.intermission ) {
                                                break;
                                        }

                                        newAngles = player.angles;
                                        newOrigin = player.origin;

                                        // No movement while repairing turret
                                        if( level.scr_sentrygun_repair_no_movement == 1 ) 
										{
                                                if( newAngles != player.firstAngles || newOrigin != player.firstOrigin ) {
                                                        player iprintlnBold( "^1DO NOT ^7move while Repairing!" );
                                                        wait( 0.10 );
                                                        break;
                                                }
                                        }
 
                                        player.progressTime += 0.05;

                                        player updateSecondaryProgressBar( player.progressTime, level.scr_sentrygun_repair_time, false, game["sentrygun_repair"] );

                                        if( player.progressTime >= level.scr_sentrygun_repair_time ) {
                                                player updateSecondaryProgressBar( undefined, undefined, true, undefined );

                                                wait( 0.05 );

                                                self thread sentry_hacked( player );
                                                player.repairedTurret = true;
                                                break;
                                        }
  
                                        wait( 0.05 );
                                }

                        } 

                        // Delete Progress Bar
                        player updateSecondaryProgressBar( undefined, undefined, true, undefined );

                        // Enable Weapons if disabled
                        if( player.hasWeapons == false ) {
                                player thread maps\mp\gametypes\_gameobjects::_enableWeapon();
                                player.hasWeapons = true;
                                player.canPickupObject = true;
                        }

                        if( isDefined( player.repairedTurret ) && player.repairedTurret == true ) {
                                player.repairedTurret = false;
                                break;
                        }

                        // Trigger is gone
                        if( !isDefined( trigger ) ) {
                                break;
                        }

                        // Game ended
                        if( level.gameEnded || level.intermission ) {
                                break;
                        }

                }

                // Delete Messages
                player DeleteRepairMessage();

                if( isDefined( player.repairedTurret ) && player.repairedTurret == true ) {
                        player.repairedTurret = false;
                        break;
                }

                // Trigger is gone
                if( !isDefined( trigger ) ) {
                        break;
                }

                // Game ended
                if( level.gameEnded || level.intermission ) {
                        break;
                }

                wait( 0.05 );

        } 
  		
}

sentry_hacked( attacker )
{

        level endon( "intermission" );
        level endon( "game_ended" );

	self notify( "end_sentry_turret" );
        self notify( "sentry_turret_over" );
	
	for( i = 0; i < self.sentryTurret.size; i++ )
	{
		if( isDefined( self.sentryTurret[i] ) )
		{
			self.sentryTurret[i] notify( "end_sentry_turret" );
			self.sentryTurret[i] delete();
		}
	}

	if( isDefined( self.entityHeadIcons ) ) 
		self maps\mp\_entityheadicons::setEntityHeadIcon( "none" );
	
	if( isDefined( self.sentryTurretTrig ) )
		self.sentryTurretTrig delete();

	if( isDefined( self.repairTrigger ) )
		self.repairTrigger delete();

	if( isDefined(self.sentryTurretHinge ) )
		self.sentryTurretHinge delete();

        if( isDefined( self.turretTimer ) ) {
                self.turretTimer destroy();
        }

	// Delete the objective
	if ( isDefined( level.objCompassTurret ) && level.objCompassTurret != -1 ) {
		objective_delete( level.objCompassTurret );
		maps\mp\gametypes\_gameobjects::resetObjID( level.objCompassTurret );
	}

        // Delete 3D Icon
        if( isDefined( level.objWorldTurret ) ) {
	        level.objWorldTurret notify( "stop_flashing_thread" );
	        level.objWorldTurret thread maps\mp\gametypes\_objpoints::stopFlashing();

	        // Wait some time to make sure the main loop ends	
	        wait ( 0.25 );

                level.objWorldTurret destroy();
        }

	wait( 0.05 );

        // Stops owner from hacking turret to get full time back!
        if( attacker == self ) {
                self.hasMovedTurret++;
        }
        
        self.hasDeployedTurret = false;
	self.sentryTurret = undefined;
	self.owner = undefined;

        if( attacker != self ) {

                self.hasMovedTurret = 0;

                if( isDefined( self ) && self.sessionstate == "playing" ) 
				{ 
                        self iprintlnBold( "Your Sentry Gun was ^1STOLEN ^7by" );
                        self iprintlnBold( "^3" + attacker.name );
                        self playLocalSound( "mp_war_objective_taken" );
                }

                iprintln( attacker.name + " ^1stole ^7" + self.name + "'s" + " ^2Sentry Gun!" );
        }

        // Attacker Functions
        if( isDefined( attacker ) && attacker.sessionstate == "playing" ) { 
	        attacker playLocalSound( "oldschool_pickup" );
        }
	
        // Delete Messages
        attacker DeleteRepairMessage();
        attacker updateSecondaryProgressBar( undefined, undefined, true, undefined ); 

       // attacker maps\mp\gametypes\_hardpoints::giveHardpointItem( "p90_reflex_mp" );
       // attacker thread maps\mp\gametypes\_hardpoints::hardpointNotify( "p90_reflex_mp" );
        
}

sentry_remove( play )
{
	self notify( "end_sentry_turret" );
        self notify( "sentry_turret_over" );
	
	if( play ) {

		self PlaySoundToPlayer( "oldschool_pickup", self );
        }
	
	self DeletePickupMessage();

	for( i = 0; i < self.sentryTurret.size; i++ )
	{
		if( isDefined( self.sentryTurret[i] ) )
		{
			self.sentryTurret[i] notify( "end_sentry_turret" );
			self.sentryTurret[i] delete();
		}
	}

	if( isDefined( self.entityHeadIcons ) ) 
		self maps\mp\_entityheadicons::setEntityHeadIcon( "none" );
	
	if( isDefined( self.sentryTurretTrig ) )
		self.sentryTurretTrig delete();

	if( isDefined( self.repairTrigger ) )
		self.repairTrigger delete();

	if( isDefined(self.sentryTurretHinge ) )
		self.sentryTurretHinge delete();

        if( isDefined( self.turretTimer ) ) {
                self.turretTimer destroy();
        }

	// Delete the objective
	if ( isDefined( level.objCompassTurret ) && level.objCompassTurret != -1 ) {
		objective_delete( level.objCompassTurret );
		maps\mp\gametypes\_gameobjects::resetObjID( level.objCompassTurret );
	}

        // Delete 3D Icon
        if( isDefined( level.objWorldTurret ) ) {
	        level.objWorldTurret notify( "stop_flashing_thread" );
	        level.objWorldTurret thread maps\mp\gametypes\_objpoints::stopFlashing();

	        // Wait some time to make sure the main loop ends	
	        wait ( 0.25 );

                level.objWorldTurret destroy();
        }

	wait( 0.05 );
        
    self.hasMovedTurret++;
    self.hasDeployedTurret = false;
	self.sentryTurret = undefined;
	self.owner = undefined;
    self.turretsdeployed = 0;    
       // self maps\mp\gametypes\_hardpoints::giveHardpointItem( "p90_reflex_mp" );
       // self thread maps\mp\gametypes\_hardpoints::hardpointNotify( "p90_reflex_mp" );
	
}

sentry_explode( attacker, type )
{
	self notify( "end_sentry_turret" );
    self notify( "sentry_turret_over" );

	//permit plantar novamente
	//self.turretsdeployed = 0;
	
	self.sentryTurret[0] playSound( "grenade_explode_default" );
	playFX( level.fx_sentryTurretExplode, self.sentryTurret[0] getTagOrigin( "j_hinge" ) );

        // Percent Chance the Turret will cause damage on attacker who knifes it! 
	if( isDefined( attacker ) && isPlayer( attacker ) && isAlive( attacker ) ) 
	{
                if( percentChance( level.scr_sentrygun_damage_chance ) && type == "MOD_MELEE" ) 
				{

		        attacker thread [[level.callbackPlayerDamage]]
		        (
			        self.sentryTurret[0],				// eInflictor	-The entity that causes the damage.(e.g. a turret)
			        attacker,			// eAttacker	-The entity that is attacking.
			        300,					// iDamage	-Integer specifying the amount of damage done
			        0,					// iDFlags		-Integer specifying flags that are to be applied to the damage
			        "MOD_RIFLE_BULLET",	// sMeansOfDeath	-Integer specifying the method of death
			        "p90_reflex_mp",				// sWeapon	-The weapon number of the weapon used to inflict the damage
			        self.origin,			// vPoint		-The point the damage is from?
			        ( 0, 0, 0 ),			// vDir		-The direction of the damage
			        "none",				// sHitLoc	-The location of the hit
			        0					// psOffsetTime	-The time offset for the damage
		        );
	        }
        }

	for( i = 0; i < self.sentryTurret.size; i++ )
	{
		if( isDefined( self.sentryTurret[i] ) )
		{
			self.sentryTurret[i] notify( "end_sentry_turret" );
			self.sentryTurret[i] delete();
		}
	}

        // Delete Messages if player was close to Turret and Killed
        self DeletePickupMessage();

	if( isDefined( self.entityHeadIcons ) ) 
		self maps\mp\_entityheadicons::setEntityHeadIcon( "none" );
	
	if( isDefined( self.sentryTurretTrig ) )
		self.sentryTurretTrig delete();

	if( isDefined( self.repairTrigger ) )
		self.repairTrigger delete();

	if( isDefined( self.sentryTurretHinge ) )
		self.sentryTurretHinge delete();

        // Delete Timer
        if( isDefined( self.turretTimer ) ) {
                self.turretTimer destroy();
        }

	// Delete the objective Compass
	if ( isDefined( level.objCompassTurret ) && level.objCompassTurret != -1 ) {
		objective_delete( level.objCompassTurret );
		maps\mp\gametypes\_gameobjects::resetObjID( level.objCompassTurret );
	}

        // Delete 3D Icon
        if( isDefined( level.objWorldTurret ) ) {
	        level.objWorldTurret notify( "stop_flashing_thread" );
	        level.objWorldTurret thread maps\mp\gametypes\_objpoints::stopFlashing();

	        // Wait some time to make sure the main loop ends	
	        wait ( 0.25 );

                level.objWorldTurret destroy();
        }

	wait( 0.05 );

	self.sentryTurret = undefined;
        self.hasDeployedTurret = false;
        self.hasMovedTurret = 0;
   
        // Play sound and text to owner
        if( isAlive( self ) && self.sessionstate == "playing" ) {

                self maps\mp\gametypes\_globallogic::leaderDialogOnPlayer( "sentrygun_destroyed" );
        }

        if( isDefined( attacker ) ) {

                if( attacker == self ) {
                        self iprintlnBold( "Sentry Gun ^1Suicide!" );

                } else {

                        if( isDefined( self ) && self.sessionstate == "playing" )
                                self iprintlnBold( "Sentry Gun destroyed by ^3" + attacker.name );

                        iprintln( "Sentry Gun destroyed by ^3" + attacker.name );
                }

        } 

        if( self.turretTime == 0 ) {

                if( isDefined( self ) && self.sessionstate == "playing" )
                        self iprintlnBold( "Sentry Gun Time ^1Expired!" );
        }
   
}

sentry_concussion()
{
	self endon( "disconnect" );
	self endon( "sentry_turret_over" );
        level endon( "game_ended" );

        turretConcussion = 0;

        concussionKill = level.scr_sentrygun_concussion_kill;

        // Owner has armor vest increase concussions needed by 2
        if( level.scr_sentrygun_perk_juggernaut == 1 ) 
		{
			if( self hasPerk( "specialty_armorvest" ) ) 
			{
				concussionKill *= 2; 
			}
        }

        for(;;)
        {      
			self waittill( "turret_concussion" );

			turretConcussion++;

			if( turretConcussion == concussionKill )
			break;

			wait( 0.05 );
        }

	self notify( "end_sentry_turret" );
      
        // Unlink parts
	for( i = 2; i < self.sentryTurret.size; i++ )
		self.sentryTurret[i] unlink();

        // New Hinge to rotate downward
	self.sentryTurretHinge = spawn( "script_origin", self.sentryTurret[0] getTagOrigin( "j_hinge" ) );
	self.sentryTurretHinge.angles = self.sentryTurret[2].angles;

        // Link to Hinge
	for( i = 2; i < self.sentryTurret.size; i++ )
		self.sentryTurret[i] linkTo( self.sentryTurretHinge );

        // Face downward
	self.sentryTurretHinge rotateTo( ( 45, self.sentryTurret[2].angles[1], self.sentryTurret[2].angles[2] ), 2 );

        // End some functions and loop sounds
	for( i = 0; i < self.sentryTurret.size; i++ )
	{
		if( isDefined( self.sentryTurret[i] ) )
		{
			self.sentryTurret[i] notify( "end_sentry_turret" );
                        self.sentryTurret[i] stopLoopSound();
		}
	}

        // Delete Pickup Messages if player was trying to move it
        self DeletePickupMessage();

        // Message to owner
        if( isDefined( self ) && self.sessionstate == "playing" )
                self iprintlnBold( "Sentry Gun ^1Disabled!" );

        if( level.scr_sentrygun_allow_repair == 1 ) {
                self.repairTrigger = spawn( "trigger_radius", self.sentryTurret[0].origin, 0, 40, 70 );
                self thread sentry_repair( self.repairTrigger );
        }

        // Play Fx and sound while disabled
        while( level.scr_sentrygun_timer == 0 || self.turretTime > 5 ){ 
                playFx( level.fx_sentryTurretSparks, self.sentryTurret[0] getTagOrigin( "j_hinge" ) );
                self.sentryTurret[0] playSound( "tv_shot_sparks" );
                wait( 10.0 );
        }

        wait( self.turretTime );

        self notify( "sentry_turret_over" );

}

CreateRepairMessage()
{
	self createHudElement( "sentrygun_pickup", 0, 30, "center", "middle", "center_safearea", "center_safearea", false, "hint_usable", 30, 30, 1, 0.8, 1, 1, 1 );
	self createHudTextElement( "sentrygun_repair_hint", 0, 0, "center", "middle", "center_safearea", "center_safearea", false, 1, .7, 1, 1, 1, 1.4, game["sentrygun_repair_hint"] );
}

CreatePickupMessage()
{
	self createHudElement( "sentrygun_pickup", 0, 30, "center", "middle", "center_safearea", "center_safearea", false, "hint_usable", 30, 30, 1, 0.8, 1, 1, 1 );
	self createHudTextElement( "sentrygun_pickup_hint", 0, 0, "center", "middle", "center_safearea", "center_safearea", false, 1, .7, 1, 1, 1, 1.4, game["sentrygun_pickup_hint"] );
}

DeleteRepairMessage()
{
	self deleteHudTextElementbyName( "sentrygun_repair_hint" );
	self deleteHudElementbyName( "sentrygun_pickup" );
}

DeletePickupMessage()
{
	self deleteHudTextElementbyName( "sentrygun_pickup_hint" );
	self deleteHudElementbyName( "sentrygun_pickup" );
}

onJoinedTeamOrSpectators()
{ 

	self endon( "disconnect" );
    self endon( "sentry_turret_over" );

	for(;;)
	{
		self waittill_any( "joined_team", "joined_spectators" );

		if( isDefined( self.sentryTurret ) ) 
		{
				self thread sentry_explode();
		}

    }

}

isEntMoving( ent ) // code by [105]HolyMoly

{

	oldPosition = ent.origin;

        // Wait time to see if entity has changed position
        wait( 0.10 );

	// Calculate the distance between the last position and the current position
	travelledDistance = distance( oldPosition, ent.origin );

	// True or false 
	if ( travelledDistance == 0 ) 
                return false;

        return true;
        
}

isLookingForward( ent ) // code by [105]HolyMoly
{

        anglesForward = ent getPlayerAngles();

        if( anglesForward[0] > 15 )
                return false;

        if( anglesForward[0] < -15 )
                return false;

        return true;

}

isDeployableSurface( surfacetype )
{

        result = false;

	switch( surfacetype )
	{
		case "brick": // Solid building wall types
		case "concrete":
		case "plaster":
		case "ceramic": // floor
		case "grass": // round bales as well
		case "asphalt": // Terrain surfaces
		case "dirt":
		case "rock":
		case "sand": // includes sand bags!
		case "gravel":
		case "mud":
		case "metal": // Containers
		case "carpet": // Hanging draperies etc
		case "wood": // Non solid building wall
		case "snow":
		case "ice":
		case "water":
		case "rubber":


			result = true;
                        break;
        }

        return result;

/*
        The following surfacetypes can be determined:
        asphalt
        default
        bark
        brick
        carpet
        cloth
        concrete
        ceramic
        cushion
        dirt
        flesh
        foliage
        fruit
        glass
        grass
        gravel
        ice
        metal
        mud
        none
        paintedmetal
        paper
        plaster
        plastic
        rock
        rubber
        sand
        snow
        water
        wood

*/

}

showHintText( text )
{
	if( isAlive( self ) ) 
	{
			self iprintlnBold( text );
	}
}

createHudTextElement( hud_text_name, x, y, xAlign, yAlign, horzAlign, vertAlign, foreground, sort, alpha, color_r, color_g, color_b, size, text ) 
{
	if( !isDefined( self.txt_hud ) ) self.txt_hud = [];
	
	count = self.txt_hud.size;

	self.txt_hud[count] = newClientHudElem( self );
	self.txt_hud[count].name = hud_text_name;
	self.txt_hud[count].x = x;
	self.txt_hud[count].y = y;
	self.txt_hud[count].alignX = xAlign;
	self.txt_hud[count].alignY = yAlign;
	self.txt_hud[count].horzAlign = horzAlign;
	self.txt_hud[count].vertAlign = vertAlign;
	self.txt_hud[count].foreground = foreground;	
	self.txt_hud[count].sort = sort;
	self.txt_hud[count].color = ( color_r, color_g, color_b );
	self.txt_hud[count].hideWhenInMenu = true;
	self.txt_hud[count].alpha = alpha;
	self.txt_hud[count].fontScale = size;
	self.txt_hud[count].font = "objective";
	self.txt_hud[count] setText( text );
}

deleteHudTextElementbyName( hud_text_name )
{
	if( isDefined( self.txt_hud ) && self.txt_hud.size > 0 ) 
	{
		for(i=0; i<self.txt_hud.size; i++ ) 
		{
			if( isDefined( self.txt_hud[i].name ) && self.txt_hud[i].name == hud_text_name ) 
			{
				self.txt_hud[i] destroy();
				self.txt_hud[i].name = undefined;
			}
		}	
	}
}

createHudElement( hud_element_name, x, y, xAlign, yAlign, horzAlign, vertAlign, foreground, shader, shader_width, shader_height, sort, alpha, color_r, color_g, color_b ) 
{
	if( !isDefined( self.hud ) ) self.hud = [];
	
	count = self.hud.size;

	self.hud[count] = newClientHudElem( self );
	self.hud[count].x = x;
	self.hud[count].y = y;
	self.hud[count].alignX = xAlign;
	self.hud[count].alignY = yAlign;
	self.hud[count].horzAlign = horzAlign;
	self.hud[count].vertAlign = vertAlign;
	self.hud[count].foreground = foreground;
	self.hud[count] setShader(shader, shader_width, shader_height);	
	self.hud[count].sort = sort;
	self.hud[count].alpha = alpha;
	self.hud[count].color = (color_r,color_g,color_b);
	self.hud[count].hideWhenInMenu = true;
	
	self.hud[count].name 			= hud_element_name;
	self.hud[count].shader_name 	= shader;
	self.hud[count].shader_width 	= shader_width;
	self.hud[count].shader_height 	= shader_height;
}

deleteHudElementbyName( hud_element_name )
{
	if( isDefined( self.hud ) && self.hud.size > 0 ) 
	{
		for( i=0; i<self.hud.size; i++ ) 
		{
			if( isDefined( self.hud[i].name ) && self.hud[i].name == hud_element_name ) 
			{
				self.hud[i] destroy();
				self.hud[i].name = undefined;
			}
		}	
	}
}

givePlayerScore( event, score )
{
	self maps\mp\gametypes\_rank::giveRankXP( event, score );
		
	self.pers["score"] += score;
	self maps\mp\gametypes\_persistence::statAdd( "score", ( self.pers["score"] - score ) );
	self.score = self.pers["score"];
	self notify ( "update_playerscore_hud" );
}

// returns true if damage should be done to the item given its owner and the attacker
friendlyFireCheck( owner, attacker, forcedFriendlyFireRule )
{
	if ( !isDefined( owner ) ) // owner has disconnected? allow it
		return true;

	if ( !level.teamBased ) // not a team based mode? allow it
		return true;

	friendlyFireRule = level.friendlyfire;
	if ( isDefined( forcedFriendlyFireRule ) )
		friendlyFireRule = forcedFriendlyFireRule;

	if ( friendlyFireRule != 0 ) // friendly fire is on? allow it
		return true;
/*
	if ( attacker == owner ) // owner may attack his own items if true
		return true;
*/
	if (!isDefined( attacker.pers["team"] ) ) // attacker not on a team? allow it
		return true;

	if ( attacker.pers["team"] != owner.pers["team"] ) // attacker not on the same team as the owner? allow it
		return true;

	return false; // disallow it
}

//undefined is not an array, string, or vector: (file 'promatch/_sentrygun.gsx', line 1861)
preventWeaponsPickup()
{
	self endon( "sentry_turret_over" );	
	//self endon( "disconnect" );

	for( ;; )
	{
		ent = getEntArray();
		for( i = 0; i < ent.size; i++ )
		{
			// Find all weapons
			
			if(!isDefined( ent[i] ))
			continue;
			
			if( isSubStr( ent[i].classname, "weapon_" ) ) 
			{

					// Within a certain distance of Turret
					if( isDefined( self.sentryTurret[0] )  ) 
					{
					
						if( distance( self.sentryTurret[0].origin, ent[i].origin ) <= 150 )
						{
							// Delete Weapon
							ent[i] delete();
						}
					}
			}
		}

		wait( 0.05 );
	}
}