#include promatch\_utils;

spot()
{
	if(!level.teamBased)
		return;
	
	if(level.cod_mode == "torneio")
		return;
	
	if(self attackbuttonpressed())
		return;
	
	if(!isAlive(self)) return;
		
	range = 5000;	
	aimPos = anglesToForward( self getPlayerAngles() );
	eyePos = self getStanceHeight();
	trace = bulletTrace( eyepos, eyepos + range * aimPos, true, self );
	team = self.sessionteam;
			
	if(level.atualgtype == "sd" && isDefined(level.droppedbomborigin) && self.pers["team"] != game["attackers"])
	{
		
		if(!isdefined(self.nearbomb))//pode ser necessario resetar futuramente.
		{
			if(self isPlayerNearBomb())
			{
			
				self.nearbomb = true;
				self thread BombNearme();
			}
		}
	}
	
	//distanceFromBomb = distance( self.origin, level.droppedbomborigin);
	//xxx[0] = getEnt( "sd_bomb", "targetname" );
	//iprintln("^3"+xxx[0].origin);

	if(!isDefined(self.deadwarning))
	self thread isADeadPlayer();
	
	if(isDefined( trace["entity"]) && isPlayer( trace["entity"] ))
	{
		if(self attackbuttonpressed())
		return;
		
		player = trace["entity"];
		
		if( isAlive(player) && player.pers["team"] != self.pers["team"])
		{
			//iprintln("^2"+trace["entity"].name);
			if(isDefined(player.coldblooded) && player.coldblooded) return;
			
			if(isDefined(player.insidesmoke)) return;
			
			//eu alvo estou com aprimoramento
			if(player.upgradehackspot > 0)
			{
				self spotPlayer(3,false);
				self.spotMarker = true;
				self.wasmarkedby = player;
					
			}			
			
			if(!isDefined( player.spotMarker ) )
			{				
				player.spotMarker = true;
				player.wasmarkedby = self;
				player spotPlayer(3,false);				
			
				if(player.isSniper)
				{
					soundalias = "mp_stm_sniper";
					self doQuickWarning( soundalias, "^1Sniper avistado!" );				
				}
				else
				{
					soundalias = "mp_stm_enemyspotted";
					self doQuickWarning( soundalias, "^1Alvo avistado!" );
				}
			}
		}	
	}
}

isADeadPlayer()
{
	self endon("disconnect");
	
	if ( !level.teamBased ) return;
	
	team = self.sessionteam;
  
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];

		//ignorar caso ja esteja marcado
		if(isDefined(player.needmedic) && player.needmedic == true)
		continue;
		
		if (isAlive( player )) continue;
		
		if(player.pers["team"] != team)
		continue;
		
		if(!isDefined(player.body))
			continue;
			
		if(self == player)
		continue;
		
		if(distance( self.origin, player.body.origin) > 160) continue;
	
		medictaunt = randomint(2);
		if(medictaunt == 1)
		soundaliasx = "medic1";
		else
		soundaliasx = "medic2";	
		
		
		//self sayTeam("Presuntao precisando de medico aqui!");
		player thread promatch\_medic::ShowonCompass(player,true,self);
		self.deadwarning = true;
		self doQuickWarning( soundaliasx, "^1Ferido aqui!" );
		break;
		
	}
	wait 2;
	self.deadwarning = undefined;
}


isPlayerNearBomb()
{	
	distanceFromBomb = distance( self.origin, level.droppedbomborigin);

	if ( distanceFromBomb <= 300 ) 
	{	
		return true;
	}
	return false;
}

getOriginFromBomb( entityName )
{
	bombZone = getEnt( entityName, "targetname" );
	if ( isDefined( bombZone ) ) {
		trace = playerPhysicsTrace( bombZone.origin + (0,0,20), bombZone.origin - (0,0,2000), false, undefined );
		return trace;
	}
	return;	
}

vectorScale(vector, scale)
{
	vector = (vector[0] * scale, vector[1] * scale, vector[2] * scale);
	return vector; 
}

spotPlayer(timer,bomb)
{
	self endon( "death" );
	self endon( "marker_deleted" );
	self endon("disconnect");

	if(!isAlive(self))
		return;
	
	
	if(isDefined(self.incognito) && self.incognito && !isDefined(self.bypass)) 
	return;
		
	if(bomb == true)
	{			
		objWorld = newTeamHudElem( self.pers["team"]);		
		origin = level.droppedbomborigin;
		objWorld.name = "bpointoutm_" + self getEntityNumber();
		objWorld.x = origin[0];
		objWorld.y = origin[1];
		objWorld.z = origin[2];
		objWorld.baseAlpha = 1.0;
		objWorld.isFlashing = false;
		objWorld.isShown = true;
		objWorld setShader( "waypoint_bomb", level.objPointSize, level.objPointSize );
		objWorld setWayPoint( true, "waypoint_bomb" );
		self thread markerTimer(objWorld,timer);
		return;	 	
	}

	objWorld = newTeamHudElem( level.otherTeam[ self.pers["team"] ] );	
	if(isDefined(objWorld))
	{
		origin = self.origin + (0,0,75);
		objWorld.name = "pointoutm_" + self getEntityNumber();
		objWorld.x = origin[0];
		objWorld.y = origin[1];
		objWorld.z = origin[2];
		objWorld.baseAlpha = 1.0;
		objWorld.isFlashing = false;
		objWorld.isShown = true;
		objWorld setShader( "waypoint_kill", level.objPointSize, level.objPointSize );
		objWorld setWayPoint( true, "waypoint_kill" );
	}
	else
	{
		return;
	}
	
	/*
		throwing script exception: undefined is not a field object

		^1******* script runtime error *******
		undefined is not a field object: (file 'promatch/_markplayer.gsc', line 192)
		objWorld.name = "pointoutm_" + self getEntityNumber();
 
	*/
	//if(isdefined(self.followkill))
	//objWorld setTargetEnt( self );//usado para seguir
	
	//self.followkill = undefined;
	//debug
	//self.wasmarkedby iprintln("^3Voce marcou ele!");
	
	self thread deleteMarkerOnDeath(objWorld);
	self thread markerTimer(objWorld,timer);

}

BombNearme()
{
	self endon( "death" );
	self endon("disconnect");
	
	if ( !level.multiBomb )
	self spotPlayer(5,true);
	
	self sayTeam( "Bomba Perto de mim !"); 
	self pingPlayer();
	xwait(4,false);
	self.nearbomb = undefined;
}


DeadBodyNear()
{
	self endon( "death" );
	self endon("disconnect");
	
	
}


doQuickWarning( soundalias, saytext )
{
	if(self.sessionstate != "playing")
		return;

	if ( self.pers["team"] == "allies" )
	{
		if ( game["allies"] == "sas" )
			prefix = "UK_";
		else
			prefix = "US_";
	}
	else
	{
		if ( game["axis"] == "russian" )
			prefix = "RU_";
		else
			prefix = "AB_";
	}

	if(isdefined(level.QuickMessageToAll) && level.QuickMessageToAll)
	{
		self playSound( prefix+soundalias );
		self sayAll(saytext);
	}
	else
	{
		self playSound( prefix+soundalias );
		self sayTeam( saytext );
		self pingPlayer();
	}
}

markerTimer(objWorld,timer)
{
	self endon("disconnect");
	self endon( "marker_deleted" );
	//self endon( "death" ); talvez destrua mesmo o player morto
	
	xwait(timer,false);	
	
	if(isdefined(objWorld))
	objWorld destroy();
	
	if(isdefined(self))
	self.spotMarker = undefined;
	
	self notify( "marker_deleted" );
	
}


deleteMarkerOnDeath(objWorld)
{
	self endon( "marker_deleted" );
	self waittill( "death" );
	
	if(isdefined(objWorld))
	objWorld destroy();
	
	self.spotMarker = undefined;
}

