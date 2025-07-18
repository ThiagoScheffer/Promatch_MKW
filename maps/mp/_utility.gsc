#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include promatch\_utils;

gameHasStarted()
{
	if ( level.teamBased )
		return( level.everExisted[ "axis" ] && level.everExisted[ "allies" ] );
	else
		return( level.maxPlayerCount > 1 );
}

triggerOff()
{
	if (!isdefined (self.realOrigin))
		self.realOrigin = self.origin;

	if (self.origin == self.realorigin)
		self.origin += (0, 0, -10000);
}

triggerOn()
{
	if (isDefined (self.realOrigin) )
		self.origin = self.realOrigin;
}

error(msg)
{
	println("^c*ERROR* ", msg);
	wait level.oneFrame;	// waitframe
/#
	if (getdvar("debug") != "1")
		assertmsg("This is a forced error - attach the log file");
#/
}

vector_scale(vec, scale)
{
	vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
	return vec;
}

vector_multiply( vec, vec2 )
{
	vec = (vec[0] * vec2[0], vec[1] * vec2[1], vec[2] * vec2[2]);
	
	return vec;
}


add_to_array( array, ent )
{
	if( !isdefined( ent ) )
		return array;

	if( !isdefined( array ) )
		array[ 0 ] = ent;
	else
		array[ array.size ] = ent;

	return array;
}

exploder( num )
{
	if(isDefined(num) && isDefined(level.exploderFunction))//fix maps bugs?
	[[ level.exploderFunction ]]( num );
}

exploder_sound()
{
	if(isdefined(self.script_delay))
		xwait( self.script_delay, false );
		
	self playSound(level.scr_sound[self.script_sound]);
}

cannon_effect()
{
	if( !isdefined( self.v[ "delay" ] ) )
		self.v[ "delay" ] = 0;

	min_delay = self.v[ "delay" ];
	max_delay = self.v[ "delay" ] + 0.001;// cant randomfloatrange on the same #
	if( isdefined( self.v[ "delay_min" ] ) )
		min_delay = self.v[ "delay_min" ];

	if( isdefined( self.v[ "delay_max" ] ) )
		max_delay = self.v[ "delay_max" ];

	if( min_delay > 0 )
		xwait( randomfloatrange( min_delay, max_delay ), false );

	if( isdefined( self.v[ "repeat" ] ) )
	{
		for( i = 0;i < self.v[ "repeat" ];i ++ )
		{
			playfx( level._effect[ self.v[ "fxid" ] ], self.v[ "origin" ], self.v[ "forward" ], self.v[ "up" ] );
			exploder_playSound();

			if( min_delay > 0 )
				xwait( randomfloatrange( min_delay, max_delay ), false );
		}
		return;
	}

	playfx( level._effect[ self.v[ "fxid" ] ], self.v[ "origin" ], self.v[ "forward" ], self.v[ "up" ] );
	exploder_playSound();
}

exploder_playSound()
{
	if( !isdefined( self.v[ "soundalias" ] ) || self.v[ "soundalias" ] == "nil" )
		return;
	
	play_sound_in_space( self.v[ "soundalias" ], self.v[ "origin" ] );
}

brush_delete()
{
// 		if( ent.v[ "exploder_type" ] != "normal" && !isdefined( ent.v[ "fxid" ] ) && !isdefined( ent.v[ "soundalias" ] ) )
// 		if( !isdefined( ent.script_fxid ) )

	num = self.v[ "exploder" ];
	if( isdefined( self.v[ "delay" ] ) )
		xwait( self.v[ "delay" ], false );
	else
		wait level.oneFrame;// so it disappears after the replacement appears

	if( !isdefined( self.model ) )
		return;


	assert( isdefined( self.model ) );

//	if( self.model.spawnflags & 1 )
//		self.model connectpaths();

	if( level.createFX_enabled )
	{
		if( isdefined( self.exploded ) )
			return;
			
		self.exploded = true;
		self.model hide();
		self.model notsolid();
		
		xwait( 3.0, false );
		self.exploded = undefined;
		self.model show();
		self.model solid();
		return;
	}

	if( !isdefined( self.v[ "fxid" ] ) || self.v[ "fxid" ] == "No FX" )
		self.v[ "exploder" ] = undefined;
		
	waittillframeend;// so it hides stuff after it shows the new stuff
	self.model delete();
}

brush_show()
{
	if( isdefined( self.v[ "delay" ] ) )
		xwait( self.v[ "delay" ], false );
	
	assert( isdefined( self.model ) );
	
	self.model show();
	self.model solid();
		
//	if( self.model.spawnflags & 1 )
//	{
//		if( !isdefined( self.model.disconnect_paths ) )
//			self connectpaths();
//		else
//			self disconnectpaths();
//	}

	if( level.createFX_enabled )
	{
		if( isdefined( self.exploded ) )
			return;

		self.exploded = true;
		xwait( 3.0, false );
		self.exploded = undefined;
		self.model hide();
		self.model notsolid();
	}
}

brush_throw()
{
	if( isdefined( self.v[ "delay" ] ) )
		xwait( self.v[ "delay" ], false );

	ent = undefined;
	if( isdefined( self.v[ "target" ] ) )
		ent = getent( self.v[ "target" ], "targetname" );

	if( !isdefined( ent ) )
	{
		self.model delete();
		return;
	}

	self.model show();

	startorg = self.v[ "origin" ];
	startang = self.v[ "angles" ];
	org = ent.origin;


	temp_vec = ( org - self.v[ "origin" ] );
	x = temp_vec[ 0 ];
	y = temp_vec[ 1 ];
	z = temp_vec[ 2 ];

	self.model rotateVelocity( ( x, y, z ), 12 );

	self.model moveGravity( ( x, y, z ), 12 );
	if( level.createFX_enabled )
	{
		if( isdefined( self.exploded ) )
			return;

		self.exploded = true;
		xwait( 3.0, false );
		self.exploded = undefined;
		self.v[ "origin" ] = startorg;
		self.v[ "angles" ] = startang;
		self.model hide();
		return;
	}
	
	self.v[ "exploder" ] = undefined;
	xwait( 6.0, false );
	self.model delete();
// 	self delete();
}

getPlant()
{
	start = self.origin + (0, 0, 10);

	range = 11;
	forward = anglesToForward(self.angles);
	forward = vector_scale(forward, range);

	traceorigins[0] = start + forward;
	traceorigins[1] = start;

	trace = bulletTrace(traceorigins[0], (traceorigins[0] + (0, 0, -18)), false, undefined);
	if(trace["fraction"] < 1)
	{
		//println("^6Using traceorigins[0], tracefraction is", trace["fraction"]);
		
		temp = spawnstruct();
		temp.origin = trace["position"];
		temp.angles = orientToNormal(trace["normal"]);
		return temp;
	}

	trace = bulletTrace(traceorigins[1], (traceorigins[1] + (0, 0, -18)), false, undefined);
	if(trace["fraction"] < 1)
	{
		//println("^6Using traceorigins[1], tracefraction is", trace["fraction"]);

		temp = spawnstruct();
		temp.origin = trace["position"];
		temp.angles = orientToNormal(trace["normal"]);
		return temp;
	}

	traceorigins[2] = start + (16, 16, 0);
	traceorigins[3] = start + (16, -16, 0);
	traceorigins[4] = start + (-16, -16, 0);
	traceorigins[5] = start + (-16, 16, 0);

	besttracefraction = undefined;
	besttraceposition = undefined;
	for(i = 0; i < traceorigins.size; i++)
	{
		trace = bulletTrace(traceorigins[i], (traceorigins[i] + (0, 0, -1000)), false, undefined);

		if(!isdefined(besttracefraction) || (trace["fraction"] < besttracefraction))
		{
			besttracefraction = trace["fraction"];
			besttraceposition = trace["position"];

		}
	}
	
	if(besttracefraction == 1)
		besttraceposition = self.origin;
	
	temp = spawnstruct();
	temp.origin = besttraceposition;
	temp.angles = orientToNormal(trace["normal"]);
	return temp;
}

orientToNormal(normal)
{
	hor_normal = (normal[0], normal[1], 0);
	hor_length = length(hor_normal);

	if(!hor_length)
		return (0, 0, 0);
	
	hor_dir = vectornormalize(hor_normal);
	neg_height = normal[2] * -1;
	tangent = (hor_dir[0] * neg_height, hor_dir[1] * neg_height, hor_length);
	plant_angle = vectortoangles(tangent);


	return plant_angle;
}

array_levelthread (ents, process, var, excluders)
{
	exclude = [];
	for (i=0;i<ents.size;i++)
		exclude[i] = false;

	if (isdefined (excluders))
	{
		for (i=0;i<ents.size;i++)
		for (p=0;p<excluders.size;p++)
		if (ents[i] == excluders[p])
			exclude[i] = true;
	}

	for (i=0;i<ents.size;i++)
	{
		if (!exclude[i])
		{
			if (isdefined (var))
				level thread [[process]](ents[i], var);
			else
				level thread [[process]](ents[i]);
		}
	}
}

set_ambient (track)
{
	level.ambient = track;
	if ((isdefined (level.ambient_track)) && (isdefined (level.ambient_track[track])))
	{
		ambientPlay (level.ambient_track[track], 2);
		println ("playing ambient track ", track);
	}
}

deletePlacedEntity(entity)
{
	entities = getentarray(entity, "classname");
	for(i = 0; i < entities.size; i++)
	{
		//println("DELETED: ", entities[i].classname);
		entities[i] delete();
	}
}

playSoundOnPlayers( sound, team )
{
	assert( isdefined( level.players ) );

	if ( isdefined( team ) )
		{
			for ( i = 0; i < level.players.size; i++ )
			{
				player = level.players[i];
				if ( isdefined( player.pers["team"] ) && (player.pers["team"] == team))
				{
					//iprintln("Music: " + sound);
					if(player statGets("GAMEMUSIC"))
					player playLocalSound(sound);
				}
			}
		}
		else
		{
			for ( i = 0; i < level.players.size; i++ )
			{	
				if(level.players[i] statGets("GAMEMUSIC"))
				level.players[i] playLocalSound(sound);
			}
		}
}


waitRespawnButton()
{
	self endon("disconnect");
	self endon("end_respawn");

	reDisplay = 19;

	while(self useButtonPressed() != true) {
		wait level.oneFrame;
		reDisplay++;
		
		if ( level.inTimeoutPeriod ) {
			self.lowerMessage.alpha = 0;
			xwait( 0.1, true );
			self.lowerMessage.alpha = 1;
		}
		
		if ( reDisplay > 19 ) {
			reDisplay = 0;
			setLowerMessage( game["strings"]["press_to_spawn"] );
		}		
	}		
}


setLowerMessage( text, time )
{
	if ( !isDefined( self.lowerMessage ) )
		return;
	
	if ( isDefined( self.lowerMessageOverride ) && text != &"" )
	{
		text = self.lowerMessageOverride;
		// time = undefined;
	}
	
	self notify("lower_message_set");
	
	if (isDefined( self.lowerMessage ) )
	{
		self.lowerMessage setText( text );
		
		if ( isDefined( time ) && time > 0 )
			self.lowerTimer setTimer( time );
		else
			self.lowerTimer setText( "" );
		
		self.lowerMessage fadeOverTime( 0.05 );
		self.lowerMessage.alpha = 1;
		self.lowerTimer fadeOverTime( 0.05 );
		self.lowerTimer.alpha = 1;
	}
}

clearLowerMessage( fadetime )
{
	if ( !isDefined( self.lowerMessage ) )
		return;
	
	if ( !isDefined(self) )
		return;
		
		
	self notify("lower_message_set");
	
	if ( !isdefined( fadetime) || fadetime == 0 )
	{
		setLowerMessage( &"" );
	}
	else
	{
		self endon("disconnect");
		self endon("lower_message_set");
		
		self.lowerMessage fadeOverTime( fadetime );
		self.lowerMessage.alpha = 0;
		self.lowerTimer fadeOverTime( fadetime );
		self.lowerTimer.alpha = 0;
		
		xwait( fadetime, false );
		
		if (isDefined(self.lowerMessage) )
		self setLowerMessage("");
	}
}

printOnTeam(text, team)
{
	assert( isdefined( level.players ) );
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if ( ( isdefined(player.pers["team"]) ) && (player.pers["team"] == team) )
			player iprintln(text);
	}
}


printBoldOnTeam(text, team)
{
	assert( isdefined( level.players ) );
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if ( ( isdefined(player.pers["team"]) ) && (player.pers["team"] == team) )
			player iprintlnbold(text);
	}
}



printBoldOnTeamArg(text, team, arg)
{
	assert( isdefined( level.players ) );
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if ( ( isdefined(player.pers["team"]) ) && (player.pers["team"] == team) )
			player iprintlnbold(text, arg);
	}
}


printOnTeamArg(text, team, arg)
{
	assert( isdefined( level.players ) );
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if ( ( isdefined(player.pers["team"]) ) && (player.pers["team"] == team) )
			player iprintln(text, arg);
	}
}


printOnPlayers( text, team )
{
	players = level.players;
	for(i = 0; i < players.size; i++)
	{
		if ( isDefined( team ) )
		{
			if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == team))
				players[i] iprintln(text);
		}
		else
		{
			players[i] iprintln(text);
		}
	}
}

printAndSoundOnEveryone( team, otherteam, printFriendly, printEnemy, soundFriendly, soundEnemy, printargFriendly, printargEnemy, printargExtra )
{
	shouldDoSounds = isDefined( soundFriendly );
	
	shouldDoEnemySounds = false;
	if ( isDefined( soundEnemy ) )
	{
		assert( shouldDoSounds ); // can't have an enemy sound without a friendly sound
		shouldDoEnemySounds = true;
	}
	
	// For backwards compatibility
	if ( !isDefined( printargEnemy ) )
		printargEnemy = printargFriendly;
		
	// For backwards compatibility
	if ( !isDefined( printargExtra ) )
		printargExtra = "";		
	
//Simplified 106
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		playerteam = player.pers["team"];
		if ( isdefined( playerteam ) )
		{
			if ( playerteam == team )
			{
					player iprintln( printFriendly, printargFriendly, printargExtra );
					
					if(!player.incognito)
					player playLocalSound( soundFriendly );
			}
		}
	}
}


_playLocalSound( soundAlias )
{
	self playLocalSound( soundAlias );
}


dvarIntValue( dVar, defVal, minVal, maxVal )
{
	dVar = "scr_" + level.gameType + "_" + dVar;
	if ( getDvar( dVar ) == "" )
	{
		setDvar( dVar, defVal );
		return defVal;
	}
	
	value = getDvarInt( dVar );

	if ( value > maxVal )
		value = maxVal;
	else if ( value < minVal )
		value = minVal;
	else
		return value;
		
	setDvar( dVar, value );
	return value;
}


dvarFloatValue( dVar, defVal, minVal, maxVal )
{
	dVar = "scr_" + level.gameType + "_" + dVar;
	if ( getDvar( dVar ) == "" )
	{
		setDvar( dVar, defVal );
		return defVal;
	}
	
	value = getDvarFloat( dVar );

	if ( value > maxVal )
		value = maxVal;
	else if ( value < minVal )
		value = minVal;
	else
		return value;
		
	setDvar( dVar, value );
	return value;
}


play_sound_on_tag( alias, tag )
{
	if ( isdefined( tag) )
	{
		org = spawn( "script_origin", self getTagOrigin( tag ) );
		org linkto( self, tag, (0,0,0), (0,0,0) );
	}
	else
	{
		org = spawn( "script_origin", (0,0,0) );
		org.origin = self.origin;
		org.angles = self.angles;
		org linkto( self );
	}

	org playsound (alias);
	xwait( 5.0, false );
	org delete();
}


createLoopEffect( fxid )
{
	ent = maps\mp\_createfx::createEffect( "loopfx", fxid );
	ent.v[ "delay" ] = 0.5;
	return ent;
}

createOneshotEffect( fxid )
{
	ent = maps\mp\_createfx::createEffect( "oneshotfx", fxid );
	ent.v[ "delay" ] = -15;
	return ent;
}

loop_fx_sound ( alias, origin, ender, timeout )
{
	org = spawn ("script_origin",(0,0,0));
	if ( isdefined( ender ) )
	{
		thread loop_sound_delete (ender, org);
		self endon( ender );
	}
	org.origin = origin;
	org playloopsound (alias);
	if (!isdefined (timeout))
		return;
		
	xwait( timeout, false );
//	org delete();
}

exploder_damage()
{
	if( isdefined( self.v[ "delay" ] ) )
		delay = self.v[ "delay" ];
	else
		delay = 0;
		
	if( isdefined( self.v[ "damage_radius" ] ) )
		radius = self.v[ "damage_radius" ];
	else
		radius = 128;

	damage = self.v[ "damage" ];
	origin = self.v[ "origin" ];
	
	xwait( delay, false );
	// Range, max damage, min damage
	radiusDamage( origin, radius, damage, damage );
}


exploder_before_load( num )
{
	// gotta wait twice because the createfx_init function waits once then inits all exploders. This guarentees
	// that if an exploder is run on the first frame, it happens after the fx are init.
	waittillframeend;
	waittillframeend;
	activate_exploder( num );
}

exploder_after_load( num )
{
	activate_exploder( num );
}

activate_exploder( num )
{
	num = int( num );
	for( i = 0;i < level.createFXent.size;i ++ )
	{
		ent = level.createFXent[ i ];
		if( !isdefined( ent ) )
			continue;
	
		if( ent.v[ "type" ] != "exploder" )
			continue;	
	
		// make the exploder actually removed the array instead?
		if( !isdefined( ent.v[ "exploder" ] ) )
			continue;

		if( ent.v[ "exploder" ] != num )
			continue;

		if( isdefined( ent.v[ "firefx" ] ) )
			ent thread fire_effect();

		if( isdefined( ent.v[ "fxid" ] ) && ent.v[ "fxid" ] != "No FX" )
			ent thread cannon_effect();
		else
		if( isdefined( ent.v[ "soundalias" ] ) )
			ent thread sound_effect();

		if( isdefined( ent.v[ "damage" ] ) )
			ent thread exploder_damage();

		if( isdefined( ent.v[ "earthquake" ] ) )
		{
			eq = ent.v[ "earthquake" ];
			earthquake( level.earthquake[ eq ][ "magnitude" ], 
						level.earthquake[ eq ][ "duration" ], 
						ent.v[ "origin" ], 
						level.earthquake[ eq ][ "radius" ] );
		}

		if( ent.v[ "exploder_type" ] == "exploder" )
			ent thread brush_show();
		else
		if( ( ent.v[ "exploder_type" ] == "exploderchunk" ) || ( ent.v[ "exploder_type" ] == "exploderchunk visible" ) )
			ent thread brush_throw();
		else
			ent thread brush_delete();
	}

}

sound_effect ()
{
	self effect_soundalias();
}

effect_soundalias ( )
{
	if (!isdefined (self.v["delay"]))
		self.v["delay"] = 0;
	
	// save off this info in case we delete the effect
	origin = self.v["origin"];
	alias = self.v["soundalias"];
	xwait( self.v["delay"], false );
	play_sound_in_space ( alias, origin );
}

play_sound_in_space (alias, origin, master)
{
	org = spawn ("script_origin",(0,0,1));
	if (!isdefined (origin))
		origin = self.origin;
	org.origin = origin;
	if (isdefined(master) && master)
		org playsoundasmaster (alias);
	else
		org playsound (alias);
	xwait( 10.0, false );
	org delete();
}

fire_effect()
{
	if( !isdefined( self.v[ "delay" ] ) )
		self.v[ "delay" ] = 0;

	delay = self.v[ "delay" ];
	if( ( isdefined( self.v[ "delay_min" ] ) ) && ( isdefined( self.v[ "delay_max" ] ) ) )
		delay = self.v[ "delay_min" ] + randomfloat( self.v[ "delay_max" ] - self.v[ "delay_min" ] );

	forward = self.v[ "forward" ];
	up = self.v[ "up" ];

	org = undefined;

	firefxSound = self.v[ "firefxsound" ];
	origin = self.v[ "origin" ];
	firefx = self.v[ "firefx" ];
	ender = self.v[ "ender" ];
	if( !isdefined( ender ) )
		ender = "createfx_effectStopper";
	timeout = self.v[ "firefxtimeout" ];

	fireFxDelay = 0.5;
	if( isdefined( self.v[ "firefxdelay" ] ) )
		fireFxDelay = self.v[ "firefxdelay" ];

	xwait( delay, false );

	if( isdefined( firefxSound ) )	
		level thread loop_fx_sound( firefxSound, origin, ender, timeout );

	playfx( level._effect[ firefx ], self.v[ "origin" ], forward, up );
}

loop_sound_delete ( ender, ent )
{
	ent endon ("death");
	self waittill (ender);
	ent delete();
}

createExploder( fxid )
{
	ent = maps\mp\_createfx::createEffect( "exploder", fxid );
	ent.v["delay"] = 0;
	ent.v["exploder_type"] = "normal";
	return ent;
}

getOtherTeam( team )
{
	if ( team == "allies" )
		return "axis";
	else if ( team == "axis" )
		return "allies";
		
	assertMsg( "getOtherTeam: invalid team " + team );
}


wait_endon( waitTime, endOnString, endonString2, endonString3 )
{
	self endon ( endOnString );
	if ( isDefined( endonString2 ) )
		self endon ( endonString2 );
	if ( isDefined( endonString3 ) )
		self endon ( endonString3 );
	
	xwait( waitTime, false );
}

isMG( weapon )
{
	return isSubStr( weapon, "_bipod_" );
}
