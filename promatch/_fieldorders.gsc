//                       Website: http://www.holymolymods.com                       
//*********************************************************************************
// Coded for Openwarfare Mod by [105]HolyMoly  Oct 5/2014
// V.0.1

//V 0.2 by EncryptorX 10.5.15
//V 0.3 by EncryptorX 14.10.16
//V 0.4 by EncryptorX 19.03.17
#include promatch\_eventmanager;
#include promatch\_utils;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;

init()
{

	//if(level.players.size < 7) return;//no minimo 4x4 em modo Evento
	
	// Get the main module's dvars
	level.scr_field_orders = getdvarx( "scr_field_orders", "int", 0, 0, 1 );

        // If not activated or certain gametypes
	if ( level.scr_field_orders == 0)
		return;
		

        // Dvars
        level.scr_field_order_reminder_time = 15;
        level.scr_field_order_headshot_only = getdvarx( "scr_field_order_headshot_only", "int", 0, 0, 1 );
        level.scr_field_order_timer = getdvarx( "scr_field_order_timer", "int", 30, 0, 300 );
        level.scr_field_order_timer_reset = getdvarx( "scr_field_order_timer_reset", "int", 45, 5, 600 );

        //Field Order Counters
        level.scr_field_order_0 = 1;
        level.scr_field_order_1 = 1;
        level.scr_field_order_2 = 1;
        level.scr_field_order_3 = 1;
        level.scr_field_order_4 = 1;
        level.scr_field_order_5 = 2;
        level.scr_field_order_6 = 1;
        level.scr_field_order_7 = 1;
        level.scr_field_order_8 = 2;
        level.scr_field_order_9 = 2;
        level.scr_field_order_10 = 2;



		//Field Order Points
		level.scr_field_order_0_points = 1;
		level.scr_field_order_1_points = 2;
		level.scr_field_order_2_points = 2;
		level.scr_field_order_3_points = 2;
		level.scr_field_order_4_points = 3;
		level.scr_field_order_5_points = 5;
		level.scr_field_order_6_points = 6;
		level.scr_field_order_7_points = 2;
		level.scr_field_order_8_points = 15;
		level.scr_field_order_9_points = 10;
		level.scr_field_order_10_points = 15;
		level.scr_field_order_11_points = 8;

		// Precache other assets
		game[getdvar("g_gametype")]["fieldOrderModel"] = "hm_bluecase";
		precacheModel( game[getdvar("g_gametype")]["fieldOrderModel"] );
		precacheShader( "blue_briefcase" );
		precacheShader( "waypoint_field_order" );


	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );

}

onPlayerConnected()
{

		self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
        self thread addNewEvent( "onJoinedSpectators", ::onJoinedSpectators );
       // self thread onPlayerDisconnect();
        
}

onPlayerSpawned()
{

        // Clear all fields
        self.hasFieldOrders = false;
        self.fieldOrdersComplete = false;
        self.orderNumber = -1;
        self.points = 0;
        self.crouchKill = 0;
        self.proneKill = 0;
        self.headshotKill = 0;
        self.meleeKill = 0;
        self.jumpKill = 0;
        self.behindKill = 0;
        self.nadehumiliation = 0;
        self.pistolKill = 0;
        self.explosiveKill = 0;
        self.wallkiller = 0;
        self.pickedWeaponKill = 0;

        // Turn off compass if killed before timer is up!
       // if( level.scr_game_forceuav == 0 ) 
        //        self setClientDvar( "g_compassshowenemies", "0" );

        // Briefcase icon
        if( !isDefined( self.caseIcon ) ) 
		{
	        self.caseIcon = createIcon( "blue_briefcase", 28, 28 );
			self.caseIcon setPoint( "CENTER", "CENTER", 250, 204 ); // 220, 140
			self.caseIcon.alpha = 0;
        }
        
        self thread checkFieldOrders();
        
}

onJoinedSpectators()
{

        if( isDefined( self.hasFieldOrders ) && self.hasFieldOrders == true ) 
		{
                self.hasFieldOrders = false;
                level.fieldOrdersActive = false;

                if( isDefined( self.caseIcon ) )
                        self.caseIcon.alpha = 0;        
        }

}

onPlayerDisconnect()
{

        self waittill( "disconnect" );

        if( isDefined( self.hasFieldOrders ) && self.hasFieldOrders == true ) 
		{
                self.hasFieldOrders = false;
                level.fieldOrdersActive = false;

                if( isDefined( self.caseIcon ) )
                        self.caseIcon.alpha = 0;
        }

}

removeTriggerOnPickup( fieldOrderTrigger, fieldOrder )
{ 
        fieldOrderTrigger endon( "timer_reset" );

        fieldOrderTrigger waittill( "trigger", player );

        // If by some chance a dead player activates the trigger, the suitcase will simply be deleted and field orders restarted!
        if ( isAlive( player ) ) 
		{

                player.hasFieldOrders = true;

                // Briefcase Icon On
				if ( isDefined( player.caseIcon ) )
                        player.caseIcon.alpha = 0.6;

               // player.statusicon = "blue_briefcase";

                player.orderNumber = randomInt( 12 );

                // Field Order Notification
	        notifyData = spawnStruct();
	        notifyData.titleText = "Evento Baleia Azul!";

		if( player.orderNumber == 0 ) notifyData.notifyText = ( "Consiga 1 Kill abaixado." );
		if( player.orderNumber == 1 ) notifyData.notifyText = ( "Consiga 1 Kill deitado e se mate." );
		if( player.orderNumber == 2 ) notifyData.notifyText = ( "Consiga 1 Headshot com inimigo de costas." );
		if( player.orderNumber == 3 ) notifyData.notifyText = ( "Consiga 1 Kill de faca em um Rank 50+." );
		if( player.orderNumber == 4 ) notifyData.notifyText = ( "Consiga 1 Kill pulando de uma altura fatal(pra vc)." );
		if( player.orderNumber == 5 ) notifyData.notifyText = ( "Consiga 2 kills por tras segurando uma nade armada." );
		if( player.orderNumber == 6 ) notifyData.notifyText = ( "Mate um jogador com uma Nade(Pedrada)" );
		if( player.orderNumber == 7 ) notifyData.notifyText = ( "Seja o ultimo a defusar e se mate." );
		if( player.orderNumber == 8 ) notifyData.notifyText = ( "Consiga um First Blood." );
		if( player.orderNumber == 9 ) notifyData.notifyText = ( "Consiga 1 Teamkill e 2 kills seguidas." );
		if( player.orderNumber == 10 ) notifyData.notifyText = ( "Consiga 2 Kills antes de morrer de uma queda." );
		if( player.orderNumber == 11 ) notifyData.notifyText = ("Consiga 2 Kills seguidos pela parede.");

	        notifyData.iconName = "blue_briefcase";
            notifyData.glowColor = ( 0, 0.9, 1 ); // light blue
	        notifyData.duration = 5.0;

                player thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );

                if( level.scr_field_order_reminder_time > 0 )
                        player thread showReminder( notifyData.notifyText );

                player playLocalSound( "case_pickup" );

        } 
		else 
		{
               player.hasFieldOrders = false;
               level.fieldOrdersActive = false;
        }


        // Notify trigger and model picked up
        fieldOrder notify( "picked_up" );

        xwait( 0.08,false );

        // Delete Trigger and Model
        fieldOrderTrigger delete();
	fieldOrder delete();

}

checkFieldOrders()
{

	self endon( "check_complete" );
	self endon( "disconnect" );
	self endon("game_ended");

	// Wait for the player to die
	self waittill( "player_killed", eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, fDistance );

		//iprintln("WEAPON: " + sWeapon); //NOME DO ARQUIVO REAL
        // Briecase icon off
        if( isDefined( self.caseIcon ) ) {
                self.caseIcon.alpha = 0;
        }

        // Reset
       // if( level.scr_game_forceuav == 0 ) 
         //       self setClientDvar( "g_compassshowenemies", "0" );

        // First time and reset, if killed by suicide, or non player...... restart orders!
        if( level.fieldOrdersActive == false && isPlayer( attacker ) && attacker != self ) 
		{

                // Team or FFA gametype setting
                if( level.teamBased ) {
                        if( attacker.pers["team"] == self.pers["team"] )
                                return;
                }

                // Headshot Only Dvar
                if( level.scr_field_order_headshot_only == 1 && !isHeadShot(sHitLoc, sMeansOfDeath ) ) {
                        return;
                }

                level.fieldOrdersActive = true;
                
                // Place spawnpoint on the ground based on player box size 
                basePosition = playerPhysicsTrace( self.origin, self.origin + ( 0, 0, -99999 ) );

                // Position of case according to gametype
                startPoint = basePosition + ( 0, 0, 40 );

                fieldOrderTrigger = spawn("trigger_radius", basePosition, 0, 20, 50 );

	        fieldOrder = spawn("script_model", startPoint );
	        fieldOrder setModel( game[getdvar("g_gametype")]["fieldOrderModel"] );//se alterado o modo de jogo durante o field ele se perde - fix: game[getdvar("g_gametype")]

                fieldOrder thread showObjFieldOrder( basePosition, fieldOrderTrigger );

                // Rotate Model
                fieldOrder thread rotate();

                // Wait for another player to pickup the briefcase
                fieldOrder thread removeTriggerOnPickup( fieldOrderTrigger, fieldOrder );

                if( level.scr_field_order_timer_reset > 0 )
                fieldOrder thread timerReset( fieldOrder, fieldOrderTrigger );


        }

        // Self has orders and loses them
        if( isDefined( self.hasFieldOrders ) && self.hasFieldOrders == true ) 
		{

                self.hasFieldOrders = false;

                // Place spawnpoint on the ground based on player box size 
                basePosition = playerPhysicsTrace( self.origin, self.origin + ( 0, 0, -99999 ) );

                // Position of case according to gametype
                startPoint = basePosition + ( 0, 0, 40 );
                
                fieldOrderTrigger = spawn("trigger_radius", basePosition, 0, 20, 50 );

	        fieldOrder = spawn("script_model", startPoint );
	        fieldOrder setModel( game[getdvar("g_gametype")]["fieldOrderModel"] );

			fieldOrder thread showObjFieldOrder( basePosition, fieldOrderTrigger );

			// Rotate Model
			fieldOrder thread rotate();

			// Wait for another player to pickup the briefcase
			fieldOrder thread removeTriggerOnPickup( fieldOrderTrigger, fieldOrder );

            // Field Order Failed
	        notifyData = spawnStruct();
	        notifyData.titleText = "Voce Falhou! :(";
            notifyData.notifyText = "Boa sorte na proxima vez.";
	        notifyData.iconName = "blue_briefcase";
            notifyData.sound = "mp_war_objective_taken";
            notifyData.glowColor = ( 0, 0.9, 1 ); // light blue
	        notifyData.duration = 5.0;

            self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );

                if( level.scr_field_order_timer_reset > 0 )
                        fieldOrder thread timerReset( fieldOrder, fieldOrderTrigger );


        } 
	
        if( isDefined( attacker.hasFieldOrders ) && attacker.hasFieldOrders == true && attacker != self ) 
		{
                if( isDefined( attacker.fieldOrdersComplete ) && attacker.fieldOrdersComplete == false ) 
				{  

                        stance = attacker GetStance();
                        
                        // ( "Consiga 1 Kill abaixado." );
                        if( attacker.orderNumber == 0 ) 
						{
                                if( stance == "crouch" ) 
								{
									attacker.crouchKill++;
                                }

                                if( attacker.crouchKill == level.scr_field_order_0 ) 
								{
										attacker.fieldOrdersComplete = true;
										attacker.points = level.scr_field_order_0_points;
										attacker.crouchKill = 0;
                                }           
                        }

                        // ( "Consiga 1 Kill deitado e se mate." );
                        if( attacker.orderNumber == 1 ) 
						{
                                if( stance == "prone" ) 
								{
										
                                        attacker.proneKill++;
                                        //attacker iprintln( attacker.proneKill );

                                        if( isExplosive( sWeapon )) 
										{
                                                attacker.proneKill--;
                                                //attacker iprintln( attacker.proneKill );
                                        }
                                }

                                if( attacker.proneKill == level.scr_field_order_1 ) 
								{
                                        attacker.fieldOrdersComplete = true;
                                        attacker.points = level.scr_field_order_1_points;
                                        attacker.proneKill = 0;
                                }
                        }

                        // Check headshot kills
                        if( attacker.orderNumber == 2 ) 
						{
                                if( isHeadShot(sHitLoc, sMeansOfDeath ) ) {
                                        attacker.headshotKill++;
                                        //attacker iprintln( attacker.headshotKill );
                                
                                        if( isHardpoint( sWeapon ) ) 
										{
                                                attacker.headshotKill--;
                                                //attacker iprintln( attacker.headshotKill );
                                        }
                                }

                                if( attacker.headshotKill == level.scr_field_order_2 ) {
                                        attacker.fieldOrdersComplete = true;
                                        attacker.points = level.scr_field_order_2_points;
                                        attacker.headshotKill = 0;
                                }
                        }

                        // Check Melee kills
                        if( attacker.orderNumber == 3 ) 
						{
                                if( sMeansOfDeath == "MOD_MELEE" || sWeapon == "beretta_silencer_mp" ) { 
                                        attacker.meleeKill++;
                                        //attacker iprintln( attacker.meleeKill );
                                }

                                if( attacker.meleeKill == level.scr_field_order_3 ) {
                                        attacker.fieldOrdersComplete = true;
                                        attacker.points = level.scr_field_order_3_points;
                                        attacker.meleeKill = 0;
                                }
                        }

                        // Check jumping kills
                        if( attacker.orderNumber == 4 ) 
						{
                                if( !attacker isOnGround() ) 
								{
                                        attacker.jumpKill++;
                                        //attacker iprintln( attacker.jumpKill );

                                        if( isExplosive( sWeapon ) ) {
                                                attacker.jumpKill--;
                                                //attacker iprintln( attacker.jumpKill );
                                        }
                                }

                                if( attacker.jumpKill == level.scr_field_order_4 ) {
                                        attacker.fieldOrdersComplete = true;
                                        attacker.points = level.scr_field_order_4_points;
                                        attacker.jumpKill = 0;
                                }
                        }

                        // Check behind kills
                        if( attacker.orderNumber == 5 ) 
						{

                                self.deathAngles = self getPlayerAngles();
                                attacker.deathAngles = attacker getPlayerAngles();

		                vAngles = self.deathAngles[1];
		                pAngles = attacker.deathAngles[1];
		                angleDiff = AngleClamp180( vAngles - pAngles );

		                if ( abs( angleDiff ) < 30 ) 
						{
                                        attacker.behindKill++;
                                        //attacker iprintln( attacker.behindKill );
                                        
                                        if( isExplosive( sWeapon ) ) 
										{
                                                attacker.behindKill--;
                                                //attacker iprintln( attacker.behindKill );
                                        }
                                }

                                if( attacker.behindKill == level.scr_field_order_5 ) {
                                        attacker.fieldOrdersComplete = true;
                                        attacker.points = level.scr_field_order_5_points;
                                        attacker.behindKill = 0;
                                }
                        }

                        //Humiliar com uma Nade
                        if( attacker.orderNumber == 6 )
						{
                               if(sMeansOfDeath == "MOD_IMPACT" && level.players.size >= 6 && int(fDistance) <= 200)
								{ 
                                        attacker.nadehumiliation++;                                       
                                }

                                if( attacker.nadehumiliation == level.scr_field_order_6 ) {
                                        attacker.fieldOrdersComplete = true;
                                        attacker.points = level.scr_field_order_6_points;
                                        attacker.nadehumiliation = 0;
                                }
                        }

                        // check pistol kills
                        if( attacker.orderNumber == 7 ) 
						{
                                if( isPistol( sWeapon ) ) 
								{ 
                                        attacker.pistolKill++;
                                        //attacker iprintln( attacker.pistolKill );
                                }

                                if( attacker.pistolKill == level.scr_field_order_7 ) 
								{
                                        attacker.fieldOrdersComplete = true;
                                        attacker.points = level.scr_field_order_7_points;
                                        attacker.pistolKill = 0;
                                }
                        }

                        // Check explosive kills
                        if( attacker.orderNumber == 8 ) 
						{
                                if( isExplosive( sWeapon ) || isProjectile( sWeapon ) ) {
                                        attacker.explosiveKill++;
                                        //attacker iprintln( attacker.explosiveKill );
                                }

                                if( attacker.explosiveKill == level.scr_field_order_8 ) {
                                        attacker.fieldOrdersComplete = true;
                                        attacker.points = level.scr_field_order_8_points;
                                        attacker.explosiveKill = 0;
                                }
                        }


                        // Pela Parede
                        if( attacker.orderNumber == 9 ) 
						{
                                if (self.iDFlags & level.iDFLAGS_PENETRATION )
								{
                                        attacker.wallkiller++;
                                        //attacker iprintln( attacker.wallkiller );
                                }

                                if( attacker.wallkiller == level.scr_field_order_9 ) {
                                        attacker.fieldOrdersComplete = true;
                                        attacker.points = level.scr_field_order_9_points;
                                        attacker.wallkiller = 0;
                                }
                        }

                        // vingança
                        if( attacker.orderNumber == 10 ) 
						{
                                if( isDefined( attacker.tookWeaponFrom[ sWeapon ] ) ) {
                                        attacker.pickedWeaponKill++;
                                        //attacker iprintln( attacker.pickedWeaponKill );
                                      
                                        if( sMeansOfDeath == "MOD_MELEE" ) 
										{
                                                attacker.pickedWeaponKill--; 
                                        }      
                                }

                                if( attacker.pickedWeaponKill == level.scr_field_order_10 ) 
								{
                                        attacker.fieldOrdersComplete = true;
                                        attacker.points = level.scr_field_order_10_points;
                                        attacker.pickedWeaponKill = 0;
                                }
                        }

                        // Check humiliation
                        if( attacker.orderNumber == 11 && isDefined(self) && isDefined(attacker)) 
						{ 
				
                                attacker.hasHumiliated = false;

                                if( isDefined( attacker.hasHumiliated ) && attacker.hasHumiliated == false ) 
								{

                                        thisBody = self.body;

                                        // Wait until the body is not moving anymore
                                        xwait( 0.5,false );
										thisBody maps\mp\gametypes\_weapons::waitTillNotMoving();
										
										if(isDefined( thisBody ) && isDefined( attacker ))
                                        attackerDistance = distance( thisBody.origin, attacker.origin );
										else
											return;
											

                                        //iprintln( attackerDistance );

                                        while( isDefined( thisBody ) && isDefined( attackerDistance ) && attackerDistance > 30 ) 
										{
                                                attackerDistance = distance( thisBody.origin, attacker.origin );
                                                wait level.oneFrame;

                                                if( isDefined( attacker.hasHumiliated ) && attacker.hasHumiliated == true )
                                                        break;

                                                //iprintln( "waiting" );
                                        }

                                        while( isDefined( attackerDistance ) && attackerDistance < 30 ) 
										{

                                                attackerStance1 = attacker getStance();
                                               // attacker iprintln( attackerStance1 );
                                                xwait( 0.2,false );
                  
                                                attackerStance2 = attacker getStance();
                                                //attacker iprintln( attackerStance2 );
                                               xwait( 0.2,false );
                                        
                                               attackerStance3 = attacker getStance();
                                               // attacker iprintln( attackerStance3 );
                                               xwait( 0.2,false );
                                        
                                                if( attackerStance1 != attackerStance2 && attackerStance1 != attackerStance3 ) 
												{
                                                        attacker.fieldOrdersComplete = true;
                                                        attacker.points = level.scr_field_order_11_points;
                                                        attacker.hasHumiliated = true;
                                                        break;
                                                } 

                                                attackerDistance = distance( thisBody.origin, attacker.origin );  
                                                attacker iprintln( "Voce esta em cima do corpo!" );
                                      
                                        }  
                                }    
                        }

                        waittillframeend;

                }

                //Orders complete
                if( isDefined( attacker.fieldOrdersComplete ) && attacker.fieldOrdersComplete == true ) {

                        if( isAlive( attacker ) ) {

                                attacker.fieldOrdersComplete = false;
                                attacker.orderNumber = -1;

                                if( isDefined( attacker.caseIcon ) )
                                        attacker.caseIcon.alpha = 0;

	                            attacker thread completeOrdersPoints();
   
                        
                                // Stop order reminder
                                attacker notify( "orders_completed" );

                                // Wait to process current kills........wait time is IMPORTANT!!!!!!!
                                xwait( 0.06,false );

                                // Clear Dvars for next Field Order
                                attacker.hasFieldOrders = false;
                                level.fieldOrdersActive = false;
                                //attacker.statusicon = "";

                        } 

                }    
          
        }

        //Debug
        //iprintln( "Check Complete" );

        self notify( "check_complete" );

}
                
completeOrdersPoints()
{

	notifyData = spawnStruct();
	notifyData.titleText = "Field Orders Completado";

        if( self.points != 0 ) 
		{

                if( level.teamBased ) 
				{
                        if( level.overrideTeamScore == true ) 
						{
                                notifyData.notifyText = ( "+" + self.points + " EVP Points" );
								//iprintln("TESTEa");
                        } 
						else 
						{

                                notifyData.notifyText = ( "+" + self.points + " Points" );
								//iprintln("TESTEb");
                        } 

                } else 
				{
                    notifyData.notifyText = ( "+" + self.points + " EVP Points" );
                }

        }

	//notifyData.iconName = "blue_briefcase";
        notifyData.sound = "mp_war_objective_lost";
        notifyData.glowColor = ( 0, 0.9, 1 ); // light blue
		notifyData.duration = 4.5;

        self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );

        // Give score 
        if( level.teamBased ) 
		{
                if( level.overrideTeamScore == true ) 
				{
					self thread givePlayerScore( "challenge", self.points );
					if(level.players.size >= 6)
					{
						//iprintln("^1Valendo!!");
						//EVENTPOINT
						self statAdds("EVPSCORE", self.points );
					}
					//iprintln("TESTEc");
                } 
				else 
				{

					self thread givePlayerScore( "challenge", self.points );
					[[level._setTeamScore]]( self.pers["team"], [[level._getTeamScore]]( self.pers["team"] ) + self.points );
					//iprintln("TESTEd");
                }

        } else 
		{   

                self thread givePlayerScore( "challenge", self.points );

        }

        // Clear Points Dvar
        self.points = 0;

}

timerReset( fieldOrder, fieldOrderTrigger )
{
        level endon( "game_ended" );
        level endon( "intermission" );
        fieldOrder endon( "picked_up" );

        xWait( level.scr_field_order_timer_reset,false );

        level.fieldOrdersActive = false;

        // Notify of spoofed pickup
        fieldOrderTrigger notify( "timer_reset" );

        // Shut off 2D and 3D icons
        fieldOrderTrigger notify( "trigger" );

        xwait( 0.08,false );

        // Delete Trigger and Model
        fieldOrderTrigger delete();
	fieldOrder delete();

        // Notify trigger and model picked up
        fieldOrder notify( "picked_up" );
}

showEnemyCompassTimer()
{
        self endon( "death" ); 
	self endon( "disconnect" );
	self endon( "game_ended" );

        if( level.scr_field_order_uav_time == 0 )
                return;

        wait( level.scr_field_order_uav_time );

       // if( level.scr_game_forceuav == 0 ) 
         //       self setClientDvar( "g_compassshowenemies", "0" );

}

givePlayerScore( event, score )
{
	self maps\mp\gametypes\_rank::giveRankXP( event, score );
		
	self.pers["score"] += score;
	//self statAdds( "score", ( self.pers["score"] - score ) );
	self.score = self.pers["score"];
	self notify ( "update_playerscore_hud" );
}

rotate()

{
	self endon( "picked_up" );


	while( true )

	{

       self movez( -20, 1.5, 0.3, 0.3 );

	   self rotateyaw( 360, 1.5, 0, 0 );

	   xwait(1.5,false );

	   self movez( 20, 1.5, 0.3, 0.3 );

	   self rotateyaw( 360 ,1.5, 0, 0 );

	   xwait(1.5,false );

	}

}
                

isHardpoint( weapon )
{
	if ( isSubStr( weapon, "beretta_silencer_" ) )
		return true;
	if ( isSubStr( weapon, "barrett_acog_" ) )
		return true;
	
	if ( isSubStr( weapon, "beretta_" ) )
		return true;
	
	if ( isSubStr( weapon, "winchester1200_" ) )
		return true;
	
	if ( isSubStr( weapon, "m1014_" ) )
		return true;
	
	if ( isSubStr( weapon, "deserteagle_" ) )
		return true;
	
	return false;
}


showReminder( text )
{
	self endon( "orders_completed" );
    self endon( "death" ); 
	self endon( "disconnect" );
	self endon( "game_ended" );

        while( 1 )
        {
                wait( level.scr_field_order_reminder_time );
                self iprintln( "^5Field Orders: " + text );
        }

}

isHeadShot(sHitLoc, sMeansOfDeath )
{
	return (sHitLoc == "head" || sHitLoc == "helmet") && sMeansOfDeath != "MOD_MELEE" && sMeansOfDeath != "MOD_IMPACT";
}

showObjFieldOrder( basePosition, fieldOrderTrigger )
{
        self endon( "picked_up" );
        self endon( "game_ended" );

        // Time before Icons show Field order
        if( level.scr_field_order_timer > 0 ) 
                Xwait( level.scr_field_order_timer,false );
        

	// Get ID to use for Field order
        if ( level.scr_hud_show_2dicons == 1 ) 
		{
	        objCompassFieldOrder = maps\mp\gametypes\_gameobjects::getNextObjID();
	        if ( objCompassFieldOrder != -1 ) 
			{
		        objective_add( objCompassFieldOrder, "active", basePosition + ( 0, 0, 105 ) );
		        objective_icon( objCompassFieldOrder, "blue_briefcase" );
            
	        }

	        // Start the thread to delete objCompassFieldOrder once picked up
	        self thread deleteobjCompassFieldOrder( fieldOrderTrigger, objCompassFieldOrder );
        }

        // Create pickup icon for everyone
	if ( level.scr_hud_show_3dicons == 1 ) {
                objWorldFieldOrder = newHudElem();
                origin = basePosition + ( 0, 0, 105 );
                objWorldFieldOrder.x = origin[0];
                objWorldFieldOrder.y = origin[1];
                objWorldFieldOrder.z = origin[2];
                objWorldFieldOrder.baseAlpha = 1.0;
                objWorldFieldOrder.isFlashing = false;
                objWorldFieldOrder.isShown = true;
                objWorldFieldOrder setShader( "waypoint_field_order", level.objPointSize, level.objPointSize );
                objWorldFieldOrder setWayPoint( true, "waypoint_field_order" );
                objWorldFieldOrder thread maps\mp\gametypes\_objpoints::startFlashing();

	        // Start the thread to delete objWorldFieldOrder once picked up
	        self thread deleteobjWorldFieldOrder( fieldOrderTrigger, objWorldFieldOrder );

        }

}

deleteobjWorldFieldOrder( fieldOrderTrigger, objWorldFieldOrder )
{

	fieldOrderTrigger waittill( "trigger", player );

	// Stop flashing Kill icon
	objWorldFieldOrder notify("stop_flashing_thread");
	objWorldFieldOrder thread maps\mp\gametypes\_objpoints::stopFlashing();

	// Wait some time to make sure the main loop ends	
	xwait( 0.25,false);

        if( isDefined( objWorldFieldOrder ) ) 
                objWorldFieldOrder destroy();

	
}

deleteobjCompassFieldOrder( fieldOrderTrigger, objID  )
{

	fieldOrderTrigger waittill( "trigger", player );

	// Wait some time to make sure the main loop ends	
	xwait( 0.25,false);
	
	// Delete the objective
	if ( objID != -1 ) {
		objective_delete( objID );
		maps\mp\gametypes\_gameobjects::resetObjID( objID );
	}
	
}