#include promatch\_eventmanager;
#include maps\mp\_utility;
#include promatch\_utils;

init()
{
	

	level._efx["tactical_insertion_beacon_red"]= loadfx( "props/semtex_red" );
	level.scr_tactical_insert_debug = getdvarx( "scr_tactical_insert_debug", "int", 0, 0, 1 );
	
	if(level.atualgtype == "sd")
	return;
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	self.insertion_marker = undefined;
	self.marker_fx = [];
	
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onJoinedTeam", ::onJoinedTeam );
	self thread addNewEvent( "onJoinedSpectators", ::onJoinedSpectators ); 
	self thread onDisconnected(); 
	
}

onPlayerSpawned()
{
	self thread monitorTacticalInsert();
	
	if( isDefined( self.insertion_marker ) )
		self InsertionMove();
}

InsertionMove()
{
	if( isdefined( self.insertion_marker ) && self.insertion_marker.team == self.pers["team"] )
	{
		self setOrigin( self.insertion_marker.origin );
		self SetPlayerAngles( self.insertion_marker.angles );
		self iprintlnBold( "Insertion Complete!" );
		self CleanUpMarker();
	}	
}

CleanUpMarker()
{
	if( isDefined( self.insertion_marker ) )
	{
		if( isDefined( self.insertion_marker.visual ) )
			self.insertion_marker.visual delete();
			
		if( self.marker_fx.size )
			for( i=0; i < self.marker_fx.size; i++ )
				if( isDefined( self.marker_fx[i] ) )
					self.marker_fx[i] delete();
		
		self.insertion_marker delete();
	}
}

monitorTacticalInsert()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	for( ;; )
	{
		self waittill ( "grenade_fire", grenade, weaponName );
		
		if( weaponName == "tatical_spawn_mp" )
		{			
			self setStat(2390,0);
			self thread trackInsertionPoint( grenade );
		}	
	}
}

onJoinedTeam()
{
	if( isDefined( self.insertion_marker ) )
		self CleanUpMarker();
}

onJoinedSpectators()
{
	if( isDefined( self.insertion_marker ) )
		self CleanUpMarker();
}

onDisconnected()
{
	self waittill("disconnect");
	
	if( isDefined( self.insertion_marker ) )
		self CleanUpMarker();
}

trackInsertionPoint( grenade )
{
	self endon( "disconnect" );
	
   grenade waitTillNotMoving();
   
   self playSound ( "signal1" );
   
   self.insertion_marker = spawn( "script_origin", self.origin );
   self.insertion_marker.origin = self.origin;
   self.insertion_marker.team = self.pers["team"];
   self.insertion_marker.angles = self.angles;
   self.insertion_marker.visual = grenade;

   grenade.insertion_fx_ownteam = spawnBeaconFX( grenade.origin, level._efx["tactical_insertion_beacon_red"] );
   grenade.insertion_fx_ownteam.team = self.pers["team"];
   grenade.insertion_fx_ownteam thread showToTeam();   
   self.marker_fx[self.marker_fx.size] = grenade.insertion_fx_ownteam;
   
   grenade.insertion_fx_otherteam = spawnBeaconFX( grenade.origin, level._efx["tactical_insertion_beacon_red"] );
   grenade.insertion_fx_otherteam.team = getOtherTeam( self.pers["team"] );
   grenade.insertion_fx_otherteam thread showToTeam();
   self.marker_fx[self.marker_fx.size] = grenade.insertion_fx_otherteam;
}

spawnBeaconFX( origin, fx )
{
	effect =  spawnFx( fx, origin, (0,0,1), (1,0,0) );
	triggerFx( effect );
	
	return effect;
}

waitTillNotMoving()
{
	prevorigin = (0,0,0);
	while( isDefined( self ) )
	{
		if ( self.origin == prevorigin )
			break;

		prevorigin = self.origin;
		wait .15;
	}
}

showToTeam()
{
	level endon( "game_ended" );
	self endon( "death" );

	while( isDefined( self ) )
	{
		self hide();
		players = getEntArray( "player", "classname" );
		for( i = 0; i < players.size ; i++ )
		{
			player = players[i];
			
			if( isDefined( player.pers["team"] ) && player.pers["team"] == self.team )
			{
				self ShowToPlayer( player );
			}
		}
			
		wait( 0.05 );
	}
}