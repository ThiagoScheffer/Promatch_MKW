#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include promatch\_utils;

precachehelicopter(model,type)
{
	if(!isdefined(type))
		type = "blackhawk";

	deathfx = loadfx ("explosions/tanker_explosion");	
	level.effect["heli_crash"] = loadFX("explosions/helicopter_explosion");//default effect
	
	precacheModel( model );
	level.vehicle_deathmodel[model] = model;
	
	//precachevehicle(type);
	precacheitem( "cobra_FFAR_mp" );
	precacheitem( "hind_FFAR_mp" );
	precacheitem( "cobra_20mm_mp" );
	
	/******************************************************/
	/*					SETUP WEAPON TAGS				  */
	/******************************************************/
	
	level.cobra_missile_models = [];
	level.cobra_missile_models["cobra_Hellfire"] = "projectile_hellfire_missile";
//	level.cobra_missile_models["cobra_Sidewinder"] = "projectile_sidewinder_missile";

	precachemodel( level.cobra_missile_models["cobra_Hellfire"] );
//	precachemodel( level.cobra_missile_models["cobra_Sidewinder"] );
	
	// helicopter sounds:
	level.heli_sound["allies"]["hit"] = "cobra_helicopter_hit";
	level.heli_sound["allies"]["hitsecondary"] = "cobra_helicopter_secondary_exp";
	level.heli_sound["allies"]["damaged"] = "cobra_helicopter_damaged";
	level.heli_sound["allies"]["spinloop"] = "cobra_helicopter_dying_loop";
	level.heli_sound["allies"]["spinstart"] = "cobra_helicopter_dying_layer";
	level.heli_sound["allies"]["crash"] = "cobra_helicopter_crash";
	level.heli_sound["allies"]["missilefire"] = "weap_cobra_missile_fire";
	level.heli_sound["axis"]["hit"] = "hind_helicopter_hit";
	level.heli_sound["axis"]["hitsecondary"] = "hind_helicopter_secondary_exp";
	level.heli_sound["axis"]["damaged"] = "hind_helicopter_damaged";
	level.heli_sound["axis"]["spinloop"] = "hind_helicopter_dying_loop";
	level.heli_sound["axis"]["spinstart"] = "hind_helicopter_dying_layer";
	level.heli_sound["axis"]["crash"] = "hind_helicopter_crash";
	level.heli_sound["axis"]["missilefire"] = "weap_hind_missile_fire";
	
		/******************************************************/
		/*					SETUP HELICONTROL				  */
		/*****************************************************/
		
	//How much fuel the heli has
    level.fuel = 800;
    //If you want the heli to use fuel
    level.usefuel = true;
    //If you want helicopter do you damage to surrounding players when it crashes.
    level.damageoncrash = true;
    //The radius size that damage will occur
    level.damageradius = 500;
    //The speed the helicopter travels
    level.speed = 20;
	//setModel("vehicle_mi-28_flying");
	
	//precacheModel( "vehicle_mi-28_flying" );
}






helistart()
{
    //trig = getEnt("heli_start", "targetname");
   //while(1)
   // {
       // trig waittill("trigger", player);
        if(!isDefined(self.flying) || self.flying == false)
            self heliplayerspawn_heli();
   // }
}
 
heliplayerspawn_heli()
{
    //spawn heli model
    self.helimodel = spawn("script_model", self.origin + (-45,0,90));
    self.helimodel setModel("vehicle_cobra_helicopter_fly");
    self.pilot = self;
    self.alive = true;
    self.flying = true;
    self.linker = false;
    self.crash = false;
    self.fuel = level.fuel;
    self freezeControls(1);
    self.angles = (0,360,0);
    self freezeControls(0);
    self disableWeapons();
 
    self setclientDvar("cg_thirdpseron", "1");
    self setclientDvar("cg_thirdpseronrange", 600);
 
    self.linker = spawn( "script_origin", self.origin);
    self.linker setContents(0);
    self.linker linkTo( self.helimodel );
    self linkTo( self.linker );
    self.linker = true;
 
    if(level.usefuel)
        self thread heliplayer_hud();
    self thread heliplayer_fly();
    self thread heliplayer_pitch();
    self thread heliplayerondeath();
    self thread heliplayeronspec();
 
}
 
//create heli fuel fud
heliplayer_hud()
{
    self endon("disconnect");
    self endon("flight_end");
    self.hud = addTextHud( self, -100, 120, 1, "left", "top", 1.4, 2 );
    self.hud.label = &"Fuel: ";
    while(isDefined(self.hud))
    {
        if(self.fuel < 100)
            self.hud.color = (1,0,0);
        self.hud setvalue(self.fuel);
        wait 0.05;
    }
}
 
//control planes angle
heliplayer_pitch()
{
    self endon("disconnect");
    self endon("flight_end");
 
    self waittill("flight_start");
 
    while(1)
    {
        angles = self getPlayerAngles();
        if(angles[0] > 30)
            angles = (30, angles[1], angles[2]);
        else if(angles[0] < -30)
            angles = (-30, angles[1], angles[2]);
        self setPlayerAngles(angles);
 
        self.helimodel rotateTo(self.angles, 0.8);
 
        wait 0.3;
    }
}
 
//move plane forward
heliplayer_fly()
{
    self endon("disconnect");
    self endon("flight_end");
 
    self iPrintLnBold("Taking off, get ready!");
    wait 0.5;
    self.helimodel moveTo(self.helimodel.origin + (0,0,300), 5);
    self iPrintLnBold("Use your mouse to control the helicopter");
    wait 1;
    self iPrintLnBold("To exit press FRAG");
    self.helimodel waittill("movedone");
    self notify("flight_start");
   
 
 
    while(1)
    {
        //move forward
        forward = vector_scale(anglesToForward(self.helimodel.angles), level.speed);
        self.helimodel moveTo(self.helimodel.origin + forward, 0.05);
        //check if crashed
        start = self.helimodel.origin - (0,0,140);
        end = start + vector_scale ( anglesToForward(self.helimodel.angles - (0,0,0)), 50/*check for crash range*/);
        trace = bulletTrace( start, end, false, self.helimodel );
        if(trace["fraction"] != 1)
            self thread heliplayerendflight("crash");
 
        if(level.usefuel)
            self.fuel--;
 
        if(self fragButtonPressed())
            self thread heliplayerendflight("exit");
           
 
        if(self.fuel < 0 && level.usefuel)
            self thread heliplayerendflight("fuel");
 
 
        wait 0.05;
    }
   
}
 
heliplayerendflight(reason)
{
    self endon("disconnect");
    self endon("flightend_end");
    self notify("flight_end");
    if(isDefined(self.hud))
        self.hud destroy();
    self.flying = false;
    if(reason == "fuel")
    {
        self iPrintLnBold("^1!!!OUT OF FUEL!!!");
        self.helimodel rotateTo((40,self.angles[1],self.angles[2]), 0.6);
        while(self.crash == false)
        {
            angles = self.helimodel.angles;
            forward = vector_scale(anglesToForward(angles), 60);
            self.helimodel moveTo(self.helimodel.origin + forward, 0.05);
            start = self.helimodel.origin - (0,0,140);
            end = start + vector_scale ( anglesToForward(self.helimodel.angles - (0,0,0)), 60);
            trace = bulletTrace( start, end, false, self.helimodel );
            if(trace["fraction"] != 1)
                self.crash = true;
            wait 0.05;
 
        }
        playFX(level.effect["heli_crash"], self.helimodel.origin);
        self unlink();
        self enableWeapons();
        self.crash = false;
        self setclientDvar("cg_thirdpseron", 0);
        Earthquake( 1, 2, self.helimodel.origin, 4000 );
        if(level.damageoncrash)
            RadiusDamage( self.helimodel.origin, level.damageradius, 100, 10, self );
        self.helimodel delete();
        self suicide();
    }
    if(reason == "exit")
    {
        self unlink();
        self enableWeapons();
        self setclientDvar("cg_thirdpseron", 0);
        self.helimodel delete();
    }
    if(reason == "crash")
    {
        self unlink();
        self enableWeapons();
        self setclientDvar("cg_thirdpseron", 0);
        playFX(level.effect["heli_crash"], self.helimodel.origin);
        Earthquake( 1, 2, self.helimodel.origin, 4000 );
        if(level.damageoncrash)
            RadiusDamage( self.helimodel.origin, level.damageradius, 100, 10, self );
        self.helimodel delete();
        self suicide();
    }
 
}
 
heliplayerondeath()
{
    self notify("death_wait");
    self endon("disconnect");
    self endon("death_wait");
    self waittill("death");
    self notify("flight_end");
    self notify("flightend_end");
    if(isDefined(self.hud))
        self.hud destroy();
    self.flying = false;
    self unlink();
    self enableWeapons();
    self setclientDvar("cg_thirdpseron", 0);
    if(isDefined(self.helimodel))
        self.helimodel delete();
}
 
heliplayeronspec()
{
    self notify("spec_wait");
    self endon("disconnect");
    self endon("spec_wait");
    self waittill("joined_spectators");
    self notify("flight_end");
    self notify("flightend_end");
    if(isDefined(self.hud))
        self.hud destroy();
    self.flying = false;
    self unlink();
    self enableWeapons();
    self setclientDvar("cg_thirdpseron", 0);
    if(isDefined(self.helimodel))
        self.helimodel delete();
}
 
addTextHud( who, x, y, alpha, alignX, alignY, fontScale, sort )
{
    if( isPlayer( who ) )
        hud = newClientHudElem( who );
    else
        hud = newHudElem();
 
    hud.x = x;
    hud.y = y;
    hud.alpha = alpha;
    hud.sort = sort;
    hud.alignX = alignX;
    hud.alignY = alignY;
    if(fontScale != 0)
        hud.fontScale = fontScale;
    return hud;
}


































// generate path graph from script_origins
heli_path_graph()
{	
	// collecting all start nodes in the map to generate path arrays
	path_start = getentarray( "heli_start", "targetname" ); 		// start pointers, point to the actual start node on path
	path_dest = getentarray( "heli_dest", "targetname" ); 			// dest pointers, point to the actual dest node on path
	loop_start = getentarray( "heli_loop_start", "targetname" ); 	// start pointers for loop path in the map
	leave_nodes = getentarray( "heli_leave", "targetname" ); 		// points where the helicopter leaves to
	crash_start = getentarray( "heli_crash_start", "targetname" );	// start pointers, point to the actual start node on crash path
	
	assertex( ( isdefined( path_start ) && isdefined( path_dest ) ), "Missing path_start or path_dest" );
		
	// for each destination, loop through all start nodes in level to populate array of start nodes that leads to this destination
	for (i=0; i<path_dest.size; i++)
	{
		startnode_array = [];
		
		// destnode is the final destination from multiple start nodes
		destnode_pointer = path_dest[i];
		destnode = getent( destnode_pointer.target, "targetname" );
		
		// for each start node, traverse to its dest., if same dest. then append to startnode_array
		for ( j=0; j<path_start.size; j++ )
		{
			toDest = false;
			currentnode = path_start[j];
			// traverse through path to dest.
			while( isdefined( currentnode.target ) )
			{
				nextnode = getent( currentnode.target, "targetname" );
				if ( nextnode.origin == destnode.origin )
				{
					toDest = true;
					break;
				}
				
				// debug ==============================================================
				debug_print3d_simple( "+", currentnode, ( 0, 0, -10 ) );
				if( isdefined( nextnode.target ) )
					debug_line( nextnode.origin, getent(nextnode.target, "targetname" ).origin, ( 0.25, 0.5, 0.25 ) );
				if( isdefined( currentnode.script_delay ) )
					debug_print3d_simple( "Wait: " + currentnode.script_delay , currentnode, ( 0, 0, 10 ) );
					
				currentnode = nextnode;
			}
			if ( toDest )
				startnode_array[startnode_array.size] = getent( path_start[j].target, "targetname" ); // the actual start node on path, not start pointer
		}
		assertex( ( isdefined( startnode_array ) && startnode_array.size > 0 ), "No path(s) to destination" );
		
		// load the array of start nodes that lead to this destination node into level.heli_paths array as an element
		level.heli_paths[level.heli_paths.size] = startnode_array;
	}	
	
	// loop paths array
	for (i=0; i<loop_start.size; i++)
	{
		startnode = getent( loop_start[i].target, "targetname" );
		level.heli_loop_paths[level.heli_loop_paths.size] = startnode;
	}
	assertex( isdefined( level.heli_loop_paths[0] ), "No helicopter loop paths found in map" );
	
	// leave nodes
	for (i=0; i<leave_nodes.size; i++)
		level.heli_leavenodes[level.heli_leavenodes.size] = leave_nodes[i];
	assertex( isdefined( level.heli_leavenodes[0] ), "No helicopter leave nodes found in map" );
	
	// crash paths
	for (i=0; i<crash_start.size; i++)
	{
		crash_start_node = getent( crash_start[i].target, "targetname" );
		level.heli_crash_paths[level.heli_crash_paths.size] = crash_start_node;
	}
	assertex( isdefined( level.heli_crash_paths[0] ), "No helicopter crash paths found in map" );
}

init()
{
	path_start = getentarray( "heli_start", "targetname" ); 		// start pointers, point to the actual start node on path
	loop_start = getentarray( "heli_loop_start", "targetname" ); 	// start pointers for loop path in the map

	if ( !path_start.size && !loop_start.size)
		return;
		
	precachehelicopter( "vehicle_cobra_helicopter_fly" );
	precachehelicopter( "vehicle_mi24p_hind_desert" );
	
	// array of paths, each element is an array of start nodes that all leads to a single destination node
	level.chopper = undefined;
	level.heli_paths = [];
	level.heli_loop_paths = [];
	level.heli_leavenodes = [];
	level.heli_crash_paths = [];
	
	//dvars
	thread heli_update_global_dvars();

	// helicopter fx
	level.chopper_fx["explode"]["death"] = loadfx ("explosions/helicopter_explosion_cobra");
	level.chopper_fx["explode"]["large"] = loadfx ("explosions/aerial_explosion_large");
	level.chopper_fx["explode"]["medium"] = loadfx ("explosions/aerial_explosion");
	level.chopper_fx["smoke"]["trail"] = loadfx ("smoke/smoke_trail_white_heli");
	level.chopper_fx["fire"]["trail"]["medium"] = loadfx ("smoke/smoke_trail_black_heli");
	level.chopper_fx["fire"]["trail"]["large"] = loadfx ("fire/fire_smoke_trail_L");

	heli_path_graph();
}

// update helicopter dvars realtime
heli_update_global_dvars()
{
	for( ;; )
	{
		// heli_update_dvar( dvar, default ) returns value
   	    level.heli_loopmax = heli_get_dvar_int( "scr_heli_loopmax", "4");			// how many times helicopter will circle the map before it leaves
		level.heli_missile_rof = heli_get_dvar_int( "scr_heli_missile_rof", "2" );	// missile rate of fire, one every this many seconds per target, could fire two at the same time to different targets
		level.heli_armor = heli_get_dvar_int( "scr_heli_armor", "5000" );			// armor points, after this much damage is taken, helicopter is easily damaged, and health degrades
		level.heli_rage_missile = heli_get_dvar( "scr_heli_rage_missile", "30" );	// higher the value, more frequent the missile assault
		//level.heli_maxhealth = heli_get_dvar_int( "scr_heli_maxhealth", "99100" );	// max health of the helicopter
		level.heli_missile_max = heli_get_dvar_int( "scr_heli_missile_max", "999" );	// max number of missiles helicopter can carry
		level.heli_dest_wait = heli_get_dvar_int( "scr_heli_dest_wait", "2" );		// time helicopter waits (hovers) after reaching a destination
		level.heli_debug = heli_get_dvar_int( "scr_heli_debug", "0" );				// debug mode, draws debugging info on screen
		
		level.heli_targeting_delay = heli_get_dvar( "scr_heli_targeting_delay", "0.5" );	// targeting delay
		level.heli_turretReloadTime = heli_get_dvar( "scr_heli_turretReloadTime", "1" );	// mini-gun reload time
		level.heli_turretClipSize = heli_get_dvar_int( "scr_heli_turretClipSize", "40" );	// mini-gun clip size, rounds before reload
		level.heli_visual_range = heli_get_dvar_int( "scr_heli_visual_range", "3500" );		// distance radius helicopter will acquire targets (see)
		level.heli_health_degrade = heli_get_dvar_int( "scr_heli_health_degrade", "0" );	// health degradation after injured, health descrease per second for heavy injury, half for light injury
				
		level.heli_target_spawnprotection = heli_get_dvar_int( "scr_heli_target_spawnprotection", "5" );// players are this many seconds safe from helicopter after spawn
		level.heli_turret_engage_dist = heli_get_dvar_int( "scr_heli_turret_engage_dist", "1000" );		// engaging distance for turret
		level.heli_missile_engage_dist = heli_get_dvar_int( "scr_heli_missile_engage_dist", "1300" );	// engaging distance for missiles
		level.heli_missile_regen_time = heli_get_dvar( "scr_heli_missile_regen_time", "2" );			// gives one more missile to helicopter every interval - seconds
		level.heli_turret_spinup_delay = heli_get_dvar( "scr_heli_turret_spinup_delay", "0.55" );			// seconds it takes for the helicopter mini-gun to spin up before shots fired
		level.heli_target_recognition = heli_get_dvar( "scr_heli_target_recognition", "0.5" );			// percentage of the player's body the helicopter sees before it labels him as a target
		level.heli_missile_friendlycare = heli_get_dvar_int( "scr_heli_missile_friendlycare", "256" );	// if friendly is within this distance of the target, do not shoot missile
		level.heli_missile_target_cone = heli_get_dvar( "scr_heli_missile_target_cone", "0.5" );		// dot product of vector target to helicopter forward, 0.5 is in 90 range, bigger the number, smaller the cone
		level.heli_armor_bulletdamage = heli_get_dvar( "scr_heli_armor_bulletdamage", "0.3" );			// damage multiplier to bullets onto helicopter's armor
		
		level.heli_attract_strength = heli_get_dvar( "scr_heli_attract_strength", "1000" );
		level.heli_attract_range = heli_get_dvar( "scr_heli_attract_range", "4096" );		
		
		xwait(1,false);
	}
}

heli_get_dvar_int( dvar, def )
{
	return int( heli_get_dvar( dvar, def ) );
}

// dvar set/fetch/check
heli_get_dvar( dvar, def )
{
	if ( getdvar( dvar ) != "" )
		return getdvarfloat( dvar );
	else
	{
		setdvar( dvar, def );
		return def;
	}
}

spawn_helicopter( owner, origin, angles, model, targetname )
{
	chopper = spawnHelicopter( owner, origin, angles, model, targetname );
	chopper.attractor = Missile_CreateAttractorEnt( chopper, level.heli_attract_strength, level.heli_attract_range );
	return chopper;
}

//----------------BOSS------------------
heli_think( owner, startnode, heli_team )
{
	
	heliOrigin = startnode.origin;
	heliAngles = startnode.angles;
	
	chopperboss = spawn_helicopter( owner, heliOrigin, heliAngles, "cobra_mp", "vehicle_cobra_helicopter_fly" );
	chopperboss playLoopSound( "mp_cobra_helicopter" );
	
	chopperboss.team = heli_team;
	chopperboss.pers["team"] = heli_team;
	
	chopperboss.owner = undefined;
	chopperboss thread heli_existance();
	
	level.chopperboss = chopperboss;
	//level.chopperboss = true;
	// TO DO: convert all helicopter attributes into dvars
	chopperboss.reached_dest = false;						// has helicopter reached destination
	chopperboss.maxhealth = 20000;							// max health
	chopperboss.waittime = level.heli_dest_wait;			// the time helicopter will stay stationary at destination
	chopperboss.loopcount = 40; 							// how many times helicopter circled the map
	chopperboss.evasive = false;							// evasive manuvering
	chopperboss.health_bulletdamageble = level.heli_armor;	// when damage taken is above this value, helicopter can be damage by bullets to its full amount
	chopperboss.health_evasive = level.heli_armor;			// when damage taken is above this value, helicopter performs evasive manuvering
	chopperboss.health_low = 3000;						// when damage taken is above this value, helicopter catchs on fire
	chopperboss.targeting_delay = level.heli_targeting_delay; // delay between per targeting scan - in seconds
	chopperboss.primaryTarget = undefined;					// primary target ( player )
	chopperboss.secondaryTarget = undefined;				// secondary target ( player )
	chopperboss.attacker = undefined;						// last player that shot the helicopter
	chopperboss.missile_ammo = 9999;						// initial missile ammo
	chopperboss.currentstate = "ok";						// health state
	chopperboss.lastRocketFireTime = -1;
	
	// helicopter loop threads
	chopperboss thread heli_fly( startnode );	// fly heli to given node and continue on its path
	chopperboss thread heli_damage_monitor();	// monitors damage
	chopperboss thread heli_health();			// display helicopter's health through smoke/fire
	chopperboss thread attack_targets();		// enable attack
	chopperboss thread heli_targeting();		// targeting logic
	chopperboss thread heli_missile_regen();	// regenerates missile ammo
}


heli_commandos( owner, startnode, heli_team )
{
	
	heliOrigin = startnode.origin;
	heliAngles = startnode.angles;
	
	choppercommandos = spawn_helicopter( owner, heliOrigin, heliAngles, "cobra_mp", "vehicle_cobra_helicopter_fly" );
	choppercommandos playLoopSound( "mp_cobra_helicopter" );
	
	choppercommandos.team = heli_team;
	choppercommandos.pers["team"] = heli_team;
	
	choppercommandos.owner = owner;
	
	choppercommandos thread heli_existance();
	
	level.choppercommandos = choppercommandos;
	level.heli_loopmax = 1;
	//level.choppercommandos = true;
	// TO DO: convert all helicopter attributes into dvars
	choppercommandos.reached_dest = false;						// has helicopter reached destination
	choppercommandos.maxhealth = 2000;					// max health
	choppercommandos.waittime = level.heli_dest_wait;			// the time helicopter will stay stationary at destination
	choppercommandos.loopcount = 1; 							// how many times helicopter circled the map
	choppercommandos.evasive = true;							// evasive manuvering
	choppercommandos.health_bulletdamageble = level.heli_armor;	// when damage taken is above this value, helicopter can be damage by bullets to its full amount
	choppercommandos.health_evasive = level.heli_armor;			// when damage taken is above this value, helicopter performs evasive manuvering
	choppercommandos.health_low = 1000;						// when damage taken is above this value, helicopter catchs on fire
	choppercommandos.targeting_delay = level.heli_targeting_delay; // delay between per targeting scan - in seconds
	choppercommandos.primaryTarget = undefined;					// primary target ( player )
	choppercommandos.secondaryTarget = undefined;				// secondary target ( player )
	choppercommandos.attacker = undefined;						// last player that shot the helicopter
	choppercommandos.missile_ammo = 9999;						// initial missile ammo
	choppercommandos.currentstate = "ok";						// health state
	choppercommandos.lastRocketFireTime = -1;
	
	// helicopter loop threads
	choppercommandos thread heli_fly( startnode );	// fly heli to given node and continue on its path
	choppercommandos thread heli_damage_monitor();	// monitors damage
	choppercommandos thread heli_health();			// display helicopter's health through smoke/fire
	choppercommandos thread attack_targets();		// enable attack
	choppercommandos thread heli_targeting();		// targeting logic
	choppercommandos thread heli_missile_regen();	// regenerates missile ammo
}

heli_existance()
{
	self waittill_any( "death", "crashing", "leaving" );
	level notify( "helicopter gone" );
}

heli_missile_regen()
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	
	for( ;; )
	{
		debug_print3d( "Missile Ammo: " + self.missile_ammo, ( 0.5, 0.5, 1 ), self, ( 0, 0, -100 ), 0 );
		
		if( self.missile_ammo >= level.heli_missile_max )
			self waittill( "missile fired" );
		else
		{
			// regenerates faster when damaged
			if ( self.currentstate == "heavy smoke" )
				xwait( level.heli_missile_regen_time/4,false);
			else if ( self.currentstate == "light smoke" )
				xwait( level.heli_missile_regen_time/2,false );
			else
				xwait( level.heli_missile_regen_time,false );
		}
		if( self.missile_ammo < level.heli_missile_max )
			self.missile_ammo++;
	}
}

// helicopter targeting logic
heli_targeting()
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	
	// targeting sweep cycle
	for ( ;; )
	{		
		// array of helicopter's targets
		targets = [];
		
		// scan for all players in game
		players = level.players;
		for (i = 0; i < players.size; i++)
		{
			player = players[i];
			
			if ( canTarget_turret( player ) )
			{
				//iprintlnbold("cantarget: " + player.name);
				if( isdefined( player ) )
					targets[targets.size] = player;
			}
			else
				continue;
		}
	
		// no targets found
		if ( targets.size == 0 )
		{
			//iprintlnbold(" targets.size: 0");
			self.primaryTarget = undefined;
			self.secondaryTarget = undefined;
			debug_print_target(); // debug
			xwait ( self.targeting_delay,false );
			continue;
		}
		else if ( targets.size == 1 )
		{
			update_player_threat( targets[0] );
			self.primaryTarget = targets[0];	// primary only
			self notify( "primary acquired" );
			//iprintlnbold("acquired 1 targ: " + targets[0].name);
			self.secondaryTarget = undefined;
			debug_print_target(); // debug
			xwait ( self.targeting_delay,false );
			continue;
		}
		else if ( targets.size > 1 )
			assignTargets( targets );
			
		debug_print_target(); //debug
	}	
}

// targetability
canTarget_turret( player )
{
	canTarget = true;
	
	if ( !isalive( player ) || player.sessionstate != "playing" )
		return false;
		
	//if ( distance( player.origin, self.origin ) > level.heli_visual_range )
	//	return false;
	
	if ( !isdefined( player.pers["team"] ) )
		return false;


	if ( player.pers["team"] == "spectator" )
		return false;
	
	if(isdefined(level.choppercommandos))
	{
	
		if ( player == self.owner )
		return false;
		
		if ( level.teamBased && player.pers["team"] == self.team )
		return false;	
	}
	
	//if ( isdefined( player.spawntime ) && ( gettime() - player.spawntime )/1000 <= level.heli_target_spawnprotection )
		//return false;

	if ( level.teamBased && player.pers["team"] == self.team )
	return true;	
		
	heli_centroid = self.origin + ( 0, 0, -160 );
	heli_forward_norm = anglestoforward( self.angles );
	heli_turret_point = heli_centroid + 144*heli_forward_norm;
	
	if ( player sightConeTrace( heli_turret_point, self) < level.heli_target_recognition )
		return false;	

	return canTarget;
}

// assign targets to primary and secondary
assignTargets( targets )
{
	for( idx=0; idx<targets.size; idx++ )
		update_player_threat ( targets[idx] );
	
	assertex( targets.size >= 2, "Not enough targets to assign primary and secondary" );
	
	// find primary target, highest threat level
	highest = 0;	
	second_highest = 0;
	primaryTarget = undefined;
	secondaryTarget = undefined;
	
	// find max and second max, 2n
	for( idx=0; idx<targets.size; idx++ )
	{
		assertex( isdefined( targets[idx].threatlevel ), "Target player does not have threat level" );
		if( targets[idx].threatlevel >= highest )
		{
			highest = targets[idx].threatlevel;
			primaryTarget = targets[idx];
		}
	}
	for( idx=0; idx<targets.size; idx++ )
	{
		assertex( isdefined( targets[idx].threatlevel ), "Target player does not have threat level" );
		if( targets[idx].threatlevel >= second_highest && targets[idx] != primaryTarget )
		{
			second_highest = targets[idx].threatlevel;
			secondaryTarget = targets[idx];
		}
	}	
	
	assertex( isdefined( primaryTarget ), "Targets exist, but none was assigned as primary" );
	self.primaryTarget = primaryTarget;
	self notify( "primary acquired" );
	
	assertex( isdefined( secondaryTarget ), "2+ targets exist, but none was assigned as secondary" );
	self.secondaryTarget = secondaryTarget;
	self notify( "secondary acquired" );
		
	assertex( self.secondaryTarget != self.primaryTarget, "Primary and secondary targets are the same" );
	
	xwait ( self.targeting_delay,false );
}

// threat factors
update_player_threat( player )
{
	player.threatlevel = 0;
	
	// distance factor
	dist = distance( player.origin, self.origin );
	player.threatlevel += ( (level.heli_visual_range - dist)/level.heli_visual_range )*100; // inverse distance % with respect to helicopter targeting range
	
	// behavior factor
	if ( isdefined( self.attacker ) && player == self.attacker )
		player.threatlevel += 100;
	
	// class factor - projectile weapon class has higher threat
	if ( isdefined( player.atualClass ) && ( player.atualClass == "elite" || player.atualClass == "heavygunner" || player.atualClass == "assault" ) )
		player.threatlevel += 200;

	// player score factor
	if(isDefined(player.helihits))
	player.threatlevel += player.helihits * 2;
		
	if( isdefined( player.antithreat ) )
		player.threatlevel -= player.antithreat;
		
	if( player.threatlevel <= 0 )
		player.threatlevel = 1;
}

// resets helicopter's motion values
heli_reset()
{
	self clearTargetYaw();
	self clearGoalYaw();
	self setspeed( 60, 25 );	
	self setyawspeed( 75, 45, 45 );
	//self setjitterparams( (30, 30, 30), 4, 6 );
	self setmaxpitchroll( 30, 30 );
	self setneargoalnotifydist( 256 );
	self setturningability(0.9);
}

heli_wait( waittime )
{
	self endon ( "death" );
	self endon ( "crashing" );
	self endon ( "evasive" );

	//self thread heli_hover();
	xwait( waittime,false );
	//heli_reset();
	
	//self notify( "stop hover" );
}

// hover movements
heli_hover()
{
	// stop hover when anything at all happens
	self endon( "death" );
	self endon( "stop hover" );
	self endon( "evasive" );
	self endon( "leaving" );
	self endon( "crashing" );
	
	original_pos = self.origin;
	original_angles = self.angles;
	self setyawspeed( 10, 45, 45 );
	
	x = 0;
	y = 0;

}

// accumulate damage and react
heli_damage_monitor()
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	
	self.damageTaken = 0;
	
	for( ;; )
	{
		// this damage is done to self.health which isnt used to determine the helicopter's health, damageTaken is.
		self waittill( "damage", damage, attacker, direction_vec, P, type );
	
		if(damage > 500)
			damage = 500;
		
		if( !isdefined( attacker ) || !isplayer( attacker ) )
			continue;
	

		attacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( false );
		self.attacker = attacker;//quem atacou o heli para o heli
		
		if ( type == "MOD_RIFLE_BULLET" || type == "MOD_PISTOL_BULLET" )
		{
			if( self.damageTaken >= self.health_bulletdamageble )
				self.damageTaken += damage;
			else
				self.damageTaken += damage*level.heli_armor_bulletdamage;
		}
		else
			self.damageTaken += damage;
		
		//controla o dano no heli por player
		attacker.helihits += damage;
		
		//abacou aqui
		if( self.damageTaken > self.maxhealth ) 
		{
			attacker notify( "destroyed_helicopter" );
			
			if(!isDefined(level.choppercommandos))
			{
				updatePlacementheli();
			
				playersbest = level.placement["all"];

				//iprintln("PolePos: " + playersbest[0].name);
				//iprintln("PoleHits: " + playersbest[0].helihits);
			
				if(isDefined(playersbest[0]))
				{
					playersbest[0] thread maps\mp\gametypes\_rank::giveRankXP( "helicopter", 8000 );
					playersbest[0] statAdds("EVPSCORE", 3000);
					iprintlnbold(playersbest[0].name + " ^2Recebeu 3000 EVP + 8000 XP!");
				}

					if(isDefined( playersbest[1] ))
					{
						playersbest[1] thread maps\mp\gametypes\_rank::giveRankXP( "helicopter", 6000 );
						playersbest[1] statAdds("EVPSCORE", 2000);
						iprintlnbold(playersbest[1].name + " ^2Recebeu 2000 EVP + 6000 XP!");
					}

						if(isDefined( playersbest[2] ))
						{
							playersbest[2] thread maps\mp\gametypes\_rank::giveRankXP( "helicopter", 4000 );
							playersbest[2] statAdds("EVPSCORE", 1500);
							iprintlnbold(playersbest[2].name + " ^2Recebeu 1500 EVP + 4000 XP!");
						}
			}
			
			break;
		}
	}
}

updatePlacementheli()
{
	prof_begin("updatePlacement");

	if ( !level.players.size )
	return;

	level.placement["all"] = [];
	for ( index = 0; index < level.players.size; index++ )
	{
		if ( level.players[index].team == "allies" || level.players[index].team == "axis" )
		level.placement["all"][level.placement["all"].size] = level.players[index];
	}

	placementAll = level.placement["all"];

	for ( i = 1; i < placementAll.size; i++ )
	{
		player = placementAll[i];
		playerScore = player.helihits;
		for ( j = i - 1; j >= 0 && (playerScore > placementAll[j].helihits || (playerScore == placementAll[j].helihits && player.deaths < placementAll[j].deaths)); j-- )
		placementAll[j + 1] = placementAll[j];
		placementAll[j + 1] = player;
	}

	level.placement["all"] = placementAll;
	
	prof_end("updatePlacement");
}


heli_health()
{
	self endon( "death" );
	self endon( "leaving" );
	self endon( "crashing" );
	
	self.currentstate = "ok";
	self.laststate = "ok";
	self setdamagestage( 3 );
	
	for ( ;; )
	{
		if ( self.health_bulletdamageble > self.health_low )
		{
			if ( self.damageTaken >= self.health_bulletdamageble )
				self.currentstate = "heavy smoke";
			else if ( self.damageTaken >= self.health_low )
				self.currentstate = "light smoke";
		}
		else
		{
			if ( self.damageTaken >= self.health_low )
				self.currentstate = "heavy smoke";
			else if ( self.damageTaken >= self.health_bulletdamageble )
				self.currentstate = "light smoke";
		}
		
		if ( self.currentstate == "light smoke" && self.laststate != "light smoke" )
		{
			self setdamagestage( 2 );
			self.laststate = self.currentstate;

		}
		if ( self.currentstate == "heavy smoke" && self.laststate != "heavy smoke" )
		{
			self setdamagestage( 1 );
			self notify ( "stop body smoke" );
			self.laststate = self.currentstate;
			
			// play loop sound "damaged"
			//self playloopsound ( level.heli_sound[self.team]["damaged"] );
		}
		
		if ( self.currentstate == "heavy smoke" )
		{
			self.damageTaken += level.heli_health_degrade;
			level.heli_rage_missile = 20; // increase missile firing rate more
		}
		if ( self.currentstate == "light smoke" )
		{
			self.damageTaken += level.heli_health_degrade/2;
			level.heli_rage_missile = 10;	// increase missile firing rate
		}
			
		if( self.damageTaken >= self.health_evasive )
		{
			if( !self.evasive )
				self thread heli_evasive();
		}
		
		if( self.damageTaken > self.maxhealth )
			self thread heli_crash();
			
		// debug =================================
		//if( self.damageTaken <= level.heli_armor )
		//	debug_print3d_simple( "Armor: " + (level.heli_armor-self.damageTaken), self, ( 0,0,100 ), 20 );
		//else
		//	debug_print3d_simple( "Health: " + ( self.maxhealth - self.damageTaken ), self, ( 0,0,100 ), 20 );
			
		xwait(1,false);
	}
}
// evasive manuvering - helicopter circles the map for awhile then returns to path
heli_evasive()
{
	// only one instance allowed
	self notify( "evasive" );
	
	self.evasive = true;
	
	// set helicopter path to circle the map level.heli_loopmax number of times
	loop_startnode = level.heli_loop_paths[0];
	self thread heli_fly( loop_startnode );
}

// attach helicopter on crash path
heli_crash()
{
	self notify( "crashing" );
	
	// fly to crash path
	self thread heli_fly( level.heli_crash_paths[0] );
	
	// helicopter losing control and spins
	self thread heli_spin( 180 );
	
	// wait until helicopter is on the crash path
	self waittill ( "path start" );

	// body explosion fx when on crash path
	playfxontag( level.chopper_fx["explode"]["large"], self, "tag_engine_left" );
	// along with a sound
	self playSound ( level.heli_sound[self.team]["hitsecondary"] );

	self setdamagestage( 0 );
	// form fire smoke trails on body after explosion
	self thread trail_fx( level.chopper_fx["fire"]["trail"]["large"], "tag_engine_left", "stop body fire" );
	
	self waittill( "destination reached" );
	self thread heli_explode();
}

// self spin at one rev per 2 sec
heli_spin( speed )
{
	self endon( "death" );
	
	// tail explosion that caused the spinning
	playfxontag( level.chopper_fx["explode"]["medium"], self, "tail_rotor_jnt" );
	// play hit sound immediately so players know they got it
	self playSound ( level.heli_sound[self.team]["hit"] );
	
	// play heli crashing spinning sound
	self thread spinSoundShortly();
	
	// form smoke trails on tail after explosion
	self thread trail_fx( level.chopper_fx["smoke"]["trail"], "tail_rotor_jnt", "stop tail smoke" );
	
	// spins until death
	self setyawspeed( speed, speed, speed );
	while ( isdefined( self ) )
	{
		self settargetyaw( self.angles[1]+(speed*0.9) );
		xwait ( 1,false );
	}
}

spinSoundShortly()
{
	self endon("death");
	
	xwait(0.25,false);
	
	self stopLoopSound();
	wait level.oneFrame;
	self playLoopSound( level.heli_sound[self.team]["spinloop"] );
	wait level.oneFrame;
	self playSound( level.heli_sound[self.team]["spinstart"] );
}

// TO DO: Robert will replace the for-loop to use geotrails for smoke trail fx
// this plays single smoke trail puff on origin per 0.05
// trail_fx is the fx string, trail_tag is the tag string
trail_fx( trail_fx, trail_tag, stop_notify )
{
	// only one instance allowed
	self notify( stop_notify );
	self endon( stop_notify );
	self endon( "death" );
		
	for ( ;; )
	{
		playfxontag( trail_fx, self, trail_tag );
		 wait level.oneFrame;
	}
}

// crash explosion
heli_explode()
{
	self notify( "death" );
	
	forward = ( self.origin + ( 0, 0, 100 ) ) - self.origin;
	playfx ( level.chopper_fx["explode"]["death"], self.origin, forward );
	
	// play heli explosion sound
	self playSound( level.heli_sound[self.team]["crash"] );
	level.chopperboss = undefined;
	level.choppercommandos = undefined;
	level.chopper = undefined;

	self delete();
}

// helicopter leaving parameter, can not be damaged while leaving
heli_leave()
{
	self notify( "desintation reached" );
	self notify( "leaving" );
	
	// helicopter leaves randomly towards one of the leave origins
	random_leave_node = randomInt( level.heli_leavenodes.size );
	leavenode = level.heli_leavenodes[random_leave_node];
	
	heli_reset();
	self setspeed( 100, 45 );	
	self setvehgoalpos( leavenode.origin, 1 );
	self waittillmatch( "goal" );
	self notify( "death" );
	level.chopperboss = undefined;
	level.choppercommandos = undefined;
	level.chopper = undefined;	

	self delete();
}
	
// flys helicopter from given start node to a destination on its path
heli_fly( currentnode )
{
	self endon( "death" );
	
	// only one thread instance allowed
	self notify( "flying");
	self endon( "flying" );
	
	// if owner switches teams, helicopter should leave
	//if(!isDefined(level.chopperboss))
	//self endon( "abandoned" );
	self.loopcount = 0;
	self.reached_dest = false;
	heli_reset();
	
	pos = self.origin;
	xwait( 2,false );

	while ( isdefined( currentnode.target ) )
	{	
		nextnode = getent( currentnode.target, "targetname" );
		assertex( isdefined( nextnode ), "Next node in path is undefined, but has targetname" );
		
		// offsetted 
		pos = nextnode.origin+(0,0,30);
		
		// motion change via node
		if( isdefined( currentnode.script_airspeed ) && isdefined( currentnode.script_accel ) )
		{
			heli_speed = currentnode.script_airspeed;
			heli_accel = currentnode.script_accel;
		}
		else
		{
			heli_speed = 30+randomInt(20);
			heli_accel = 15+randomInt(15);
		}
		
		// fly nonstop until final destination
		if ( !isdefined( nextnode.target ) )
			stop = 1;
		else
			stop = 0;

		if ( level.inTimeoutPeriod )
			xWait( 0.4,false );
			
		// debug ==============================================================
		debug_line( currentnode.origin, nextnode.origin, ( 1, 0.5, 0.5 ), 200 );
			
		// if in damaged state, do not stop at any node other than destination
		if( self.currentstate == "heavy smoke" || self.currentstate == "light smoke" )	
		{
			// movement change due to damage
			self setspeed( heli_speed, heli_accel );	
			self setvehgoalpos( (pos), stop );
			
			self waittill( "near_goal" ); //self waittillmatch( "goal" );
			self notify( "path start" );
		}
		else
		{
			// if the node has helicopter stop time value, we stop
			if( isdefined( nextnode.script_delay ) ) 
				stop = 1;
	
			self setspeed( heli_speed, heli_accel );	
			self setvehgoalpos( (pos), stop );
			
			if ( !isdefined( nextnode.script_delay ) )
			{
				self waittill( "near_goal" ); //self waittillmatch( "goal" );
				self notify( "path start" );
			}
			else
			{			
				// post beta addition --- (
				self setgoalyaw( nextnode.angles[1] );
				// post beta addition --- )
				
				self waittillmatch( "goal" );				
				heli_wait( nextnode.script_delay );
			}
		}
		
		// increment loop count when helicopter is circling the map
		for( index = 0; index < level.heli_loop_paths.size; index++ )
		{
			//iprintlnbold("loop_paths leave: " + level.heli_loop_paths.size);
			//iprintlnbold("loopcount leave: " + self.loopcount);
			if ( level.heli_loop_paths[index].origin == nextnode.origin )
				self.loopcount++;
		}
		
		if(isdefined(level.choppercommandos))
		{
			if(self.loopcount >= 1)
			{
				self thread heli_leave();
				return;	
			}
		}
		
		if(isdefined(level.chopperboss))
		{
			if(self.loopcount >= 40)
			{
				self thread heli_leave();
				return;	
			}
		}
		else if(!isdefined(level.chopperboss))
		{
			if( self.loopcount >= level.heli_loopmax )
			{
				//iprintlnbold("loopmax leave: " + level.heli_loopmax);
				//iprintlnbold("loopcount leave: " + level.heli_loopmax);
				self thread heli_leave();
				return;
			}
		}
		currentnode = nextnode;
	}
	
	self setgoalyaw( currentnode.angles[1] );
	self.reached_dest = true;	// sets flag true for helicopter circling the map
	self notify ( "destination reached" );
	// wait at destination
	heli_wait( self.waittime );
	
	// if still alive, switch to evasive manuvering
	if( isdefined( self ) )
		self thread heli_evasive();
}

fire_missile( sMissileType, iShots, eTarget )
{
	if ( !isdefined( iShots ) )
		iShots = 1;
	assert( self.health > 0 );
	
	weaponName = undefined;
	weaponShootTime = undefined;
	defaultWeapon = "cobra_20mm_mp";
	tags = [];
	switch( sMissileType )
	{
		case "ffar":
			if ( self.team == "allies" )
				weaponName = "cobra_FFAR_mp";
			else
				weaponName = "hind_FFAR_mp";
				
			tags[ 0 ] = "tag_store_r_2";
			break;
		default:
			assertMsg( "Invalid missile type specified. Must be ffar" );
			break;
	}
	assert( isdefined( weaponName ) );
	assert( tags.size > 0 );
	
	weaponShootTime = weaponfiretime( weaponName );
	assert( isdefined( weaponShootTime ) );
	
	self setVehWeapon( weaponName );
	nextMissileTag = -1;
	for( i = 0 ; i < iShots ; i++ ) // I don't believe iShots > 1 is properly supported; we don't set the weapon each time
	{
		nextMissileTag++;
		if ( nextMissileTag >= tags.size )
			nextMissileTag = 0;
		
		if ( isdefined( eTarget ) )
		{
			eMissile = self fireWeapon( tags[ nextMissileTag ], eTarget );
		}
		else
		{
			eMissile = self fireWeapon( tags[ nextMissileTag ] );
		}
		
		self.lastRocketFireTime = gettime();
		
		if ( i < iShots - 1 )
			xwait (weaponShootTime,false);
	}
	// avoid calling setVehWeapon again this frame or the client doesn't hear about the original weapon change
}

check_owner()
{
	
	if ( !isdefined( self.owner ) || !isdefined( self.owner.pers["team"] ) || self.owner.pers["team"] != self.team )
	{
		self notify ( "abandoned" );
		self thread heli_leave();	
	}
}

attack_targets()
{
	//self thread turret_kill_players();
	self thread attack_primary();
	self thread attack_secondary();
}

// missile only
attack_secondary()
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );	
	
	for( ;; )
	{
		if ( isdefined( self.secondaryTarget ) )
		{
			self.secondaryTarget.antithreat = undefined;
			self.missileTarget = self.secondaryTarget;
			
			antithreat = 0;

			while( isdefined( self.missileTarget ) && isalive( self.missileTarget ) )
			{
				// if selected target is not in missile hit range, skip
				if( self missile_target_sight_check( self.missileTarget ) )
					self thread missile_support( self.missileTarget, level.heli_missile_rof, true, undefined );
				else
					break;
				
				// lower targets threat after shooting
				antithreat += 100;
				self.missileTarget.antithreat = antithreat;
				
				self waittill( "missile ready" );
				
				// target might disconnect or change during last assault cycle
				if ( !isdefined( self.secondaryTarget ) || ( isdefined( self.secondaryTarget ) && self.missileTarget != self.secondaryTarget ) )
					break;
			}
			// reset the antithreat factor
			if ( isdefined( self.missileTarget ) )
				self.missileTarget.antithreat = undefined;
		}
		self waittill( "secondary acquired" );
		
		// check if owner has left, if so, leave
		//self check_owner();
	}	
}

// check if missile is in hittable sight zone
missile_target_sight_check( missiletarget )
{
	heli2target_normal = vectornormalize( missiletarget.origin - self.origin );
	heli2forward = anglestoforward( self.angles );
	heli2forward_normal = vectornormalize( heli2forward );

	heli_dot_target = vectordot( heli2target_normal, heli2forward_normal );
	
	if ( heli_dot_target >= level.heli_missile_target_cone )
	{
		debug_print3d_simple( "Missile sight: " + heli_dot_target, self, ( 0,0,-40 ), 40 );
		return true;
	}
	return false;
}

// if wait for turret turning is too slow, enable missile assault support
missile_support( target_player, rof, instantfire, endon_notify )
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );	
	 
	if ( isdefined ( endon_notify ) )
		self endon( endon_notify );
			
	self.turret_giveup = false;
	
	if ( !instantfire )
	{
		xwait( rof,false );
		self.turret_giveup = true;
		self notify( "give up" );
	}
	
	
	if ( self.missile_ammo > 0 && isdefined( target_player ) )
	{
		self fire_missile( "ffar", 7, target_player );
		self.missile_ammo--;
		self notify( "missile fired" );
	}
	else
	{
		return;
	}
	
	if ( instantfire )
	{
		xwait ( rof,false );
		self notify ( "missile ready" );
	}
}

// mini-gun with missile support
attack_primary()
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	
	for( ;; )
	{
		if ( isdefined( self.primaryTarget ) )
		{
			self.primaryTarget.antithreat = undefined;
			self.turretTarget = self.primaryTarget;
			
			antithreat = 0;
			last_pos = undefined;

			while( isdefined( self.turretTarget ) && isalive( self.turretTarget ) )
			{
				// shoots one clip of mini-gun none stop
				self setTurretTargetEnt( self.turretTarget, ( 0, 0, 40 ) );
				
				// if wait for turret turning is too slow, enable missile assault support
				if( self missile_target_sight_check( self.turretTarget ) )
					self thread missile_support( self.turretTarget, 10/level.heli_rage_missile, false, "turret on target" );

				self waittill( "turret_on_target" );
				
				self notify( "turret on target" );
				
				self thread turret_target_flag( self.turretTarget );
				
				// wait for turret to spinup and fire
				xwait( level.heli_turret_spinup_delay,false );
				
				// fire gun =================================
				weaponShootTime = weaponfiretime("cobra_20mm_mp" );
				self setVehWeapon( "cobra_20mm_mp" );
				
				// shoot full clip at target, if target lost, shoot at the last position recorded, if target changed, sweep onto next target
				for( i = 0 ; i < level.heli_turretClipSize ; i++ )
				{
					// if turret on primary target, keep last position of the target in case target lost
					if ( isdefined( self.turretTarget ) && isdefined( self.primaryTarget ) )
					{
						if ( self.primaryTarget != self.turretTarget )
							self setTurretTargetEnt( self.primaryTarget, ( 0, 0, 40 ) );
					}
					else
					{
						if ( isdefined( self.targetlost ) && self.targetlost && isdefined( self.turret_last_pos ) )
						{
							//println( "Target lost ---- shooting last pos: " + self.turret_last_pos ); // debug
							self setturrettargetvec( self.turret_last_pos );
						}
						else
						{
							self clearturrettarget();
						}	
					}
					if ( gettime() != self.lastRocketFireTime )
					{
						// fire one bullet
						self setVehWeapon( "cobra_20mm_mp" );
						miniGun = self fireWeapon( "tag_flash" );
					}
					
					// wait for RoF
					if ( i < level.heli_turretClipSize - 1 )
						xwait (weaponShootTime,false);
				}
				self notify( "turret reloading" );
				// end fire gun ==============================
				
				// wait for turret reload
				xwait( level.heli_turretReloadTime,false );
				
				// lower the target's threat since already assaulted on
				if ( isdefined( self.turretTarget ) && isalive( self.turretTarget ) )
				{
					antithreat += 100;
					self.turretTarget.antithreat = antithreat;
				}
				
				// primary target might disconnect or change during last assault cycle, if so, find new target
				if ( !isdefined( self.primaryTarget ) || ( isdefined( self.turretTarget ) && isdefined( self.primaryTarget ) && self.primaryTarget != self.turretTarget ) )
					break;
			}
				
			
			// reset the antithreat factor
			if ( isdefined( self.turretTarget ) )
				self.turretTarget.antithreat = undefined;
		}
		self waittill( "primary acquired" );
		
		// check if owner has left, if so, leave
		//self check_owner();
	}
}

// target lost flaging
turret_target_flag( turrettarget )
{
	// forcing single thread instance
	self notify( "flag check is running" );
	self endon( "flag check is running" );
	
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	self endon( "turret reloading" );
	
	// ends on target player death or undefined
	turrettarget endon( "death" );
	turrettarget endon( "disconnect" );
	
	self.targetlost = false;
	self.turret_last_pos = undefined;
	
	while( isdefined( turrettarget ) )
	{
		heli_centroid = self.origin + ( 0, 0, -160 );
		heli_forward_norm = anglestoforward( self.angles );
		heli_turret_point = heli_centroid + 144*heli_forward_norm;
	
		sight_rec = turrettarget sightconetrace( heli_turret_point, self );
		if ( sight_rec < level.heli_target_recognition )
			break;
		
		wait level.oneFrame;
	}
	
	if( isdefined( turrettarget ) && isdefined( turrettarget.origin ) )
	{
		assertex( isdefined( turrettarget.origin ), "turrettarget.origin is undefined after isdefined check" );
		self.turret_last_pos = turrettarget.origin + ( 0, 0, 40 );
		assertex( isdefined( self.turret_last_pos ), "self.turret_last_pos is undefined after setting it #1" );
		self setturrettargetvec( self.turret_last_pos );
		assertex( isdefined( self.turret_last_pos ), "self.turret_last_pos is undefined after setting it #2" );
		debug_print3d_simple( "Turret target lost at: " + self.turret_last_pos, self, ( 0,0,-70 ), 60 );
		self.targetlost = true;
	}
	else
	{
		self.targetlost = undefined;
		self.turret_last_pos = undefined;
	}
}

// debug on screen elements ===========================================================
debug_print_target()
{
	if ( isdefined( level.heli_debug ) && level.heli_debug == 1.0 )
	{
		// targeting debug print
		if( isdefined( self.primaryTarget ) && isdefined( self.primaryTarget.threatlevel ) )
			primary_msg = "Primary: " + self.primaryTarget.name + " : " + self.primaryTarget.threatlevel;
		else
			primary_msg = "Primary: ";
			
		if( isdefined( self.secondaryTarget ) && isdefined( self.secondaryTarget.threatlevel ) )
			secondary_msg = "Secondary: " + self.secondaryTarget.name + " : " + self.secondaryTarget.threatlevel;
		else
			secondary_msg = "Secondary: ";
			
		frames = int( self.targeting_delay*20 )+1;
		
		thread draw_text( primary_msg, (1, 0.6, 0.6), self, ( 0, 0, 40), frames );
		thread draw_text( secondary_msg, (1, 0.6, 0.6), self, ( 0, 0, 0), frames );
	}
}

debug_print3d( message, color, ent, origin_offset, frames )
{
	if ( isdefined( level.heli_debug ) && level.heli_debug == 1.0 )
		self thread draw_text( message, color, ent, origin_offset, frames );
}

debug_print3d_simple( message, ent, offset, frames )
{
	if ( isdefined( level.heli_debug ) && level.heli_debug == 1.0 )
	{
		if( isdefined( frames ) )
			thread draw_text( message, ( 0.8, 0.8, 0.8 ), ent, offset, frames );
		else
			thread draw_text( message, ( 0.8, 0.8, 0.8 ), ent, offset, 0 );
	}
}

debug_line( from, to, color, frames )
{
	if ( isdefined( level.heli_debug ) && level.heli_debug == 1.0 && !isdefined( frames ) )
	{
		thread draw_line( from, to, color );
	}
	else if ( isdefined( level.heli_debug ) && level.heli_debug == 1.0 )
		thread draw_line( from, to, color, frames);
}

draw_text( msg, color, ent, offset, frames )
{
	//level endon( "helicopter gone" );
	if( frames == 0 )
	{
		while ( isdefined( ent ) )
		{
			print3d( ent.origin+offset, msg , color, 0.5, 4 );
			wait level.oneFrame;
		}
	}
	else
	{
		for( i=0; i < frames; i++ )
		{
			if( !isdefined( ent ) )
				break;
			print3d( ent.origin+offset, msg , color, 0.5, 4 );
			wait level.oneFrame;
		}
	}
}

draw_line( from, to, color, frames )
{
	//level endon( "helicopter gone" );
	if( isdefined( frames ) )
	{
		for( i=0; i<frames; i++ )
		{
			line( from, to, color );
			wait level.oneFrame;
		}		
	}
	else
	{
		for( ;; )
		{
			line( from, to, color );
			wait level.oneFrame;
		}
	}
}

// cpu friendly version of sight cone trace performs single trace per frame
// 1/4 second delay
improved_sightconetrace( helicopter )
{
	// obtain start as origin of the turret point
	heli_centroid = helicopter.origin + ( 0, 0, -160 );
	heli_forward_norm = anglestoforward( helicopter.angles );
	heli_turret_point = heli_centroid + 144*heli_forward_norm;
	draw_line( heli_turret_point, self.origin, ( 1, 1, 1 ), 5 );
	start = heli_turret_point;
	yes = 0;
	point = [];
	
	for( i=0; i<5; i++ )
	{
		if( !isdefined( self ) )
			break;
		
		half_height = self.origin+(0,0,36);
		
		tovec = start - half_height;
		tovec_angles = vectortoangles(tovec);
		forward_norm = anglestoforward(tovec_angles);
		side_norm = anglestoright(tovec_angles);

		point[point.size] = self.origin + (0,0,36);
		point[point.size] = self.origin + side_norm*(15, 15, 0) + (0, 0, 10);
		point[point.size] = self.origin + side_norm*(-15, -15, 0) + (0, 0, 10);
		point[point.size] = point[2]+(0,0,64);
		point[point.size] = point[1]+(0,0,64);
		
		// debug =====================================
		draw_line( point[1], point[2], (1, 1, 1), 1 );
		draw_line( point[2], point[3], (1, 1, 1), 1 );
		draw_line( point[3], point[4], (1, 1, 1), 1 );
		draw_line( point[4], point[1], (1, 1, 1), 1 );
		
		if( bullettracepassed( start, point[i], true, self ) )
		{
			draw_line( start, point[i], (randomInt(10)/10, randomInt(10)/10, randomInt(10)/10), 1 );
			yes++;
		}
		waittillframeend;
		//wait level.oneFrame;
	}
	//println( "Target sight: " + yes/5 );
	return yes/5;
}
