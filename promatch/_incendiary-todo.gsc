#include code\utility;

init() 
{
	level._effect[ "limbfire" ] = loadFx( "obs/limbfire" );
	
	level.fireNumTags = 14;
	level.fireSpreadChance = 7;
	level.fireGoOutChance = 3;
	level.fireDamageTagThreshold = 3;
	level.fireDamagePerTag = 0.7;
	level.fireDamagePerTagLess = 0.35;
	level.fireSpreadDistance = 45;
	level.fireSpreadTagThreshold = 8;
	
	while( 1 ) {
		level waittill( "connected", client );
		client thread watchSpawn();
	}
}

watchSpawn() 
{
	self endon( "disconnect" );
	
	while( 1 ) {
		self waittill( "spawned_player" );
		
		tagList = getTagList();
		self.tagsOnFire = undefined;
		self.lastFireInflictor = undefined;
		
		self thread fireEffects();
		self thread fireSpread();
		self thread fireDamage();
		self thread fireSpreadToOthers();
	}
}

getTagList() {
	tagList = [];
	tagList[ tagList.size ] = "j_wristtwist_ri";
	tagList[ tagList.size ] = "j_wristtwist_le";
	tagList[ tagList.size ] = "j_elbow_bulge_ri";
	tagList[ tagList.size ] = "j_elbow_bulge_le";
	tagList[ tagList.size ] = "j_shoulder_ri";
	tagList[ tagList.size ] = "j_shoulder_le";
	tagList[ tagList.size ] = "j_spineupper";
	tagList[ tagList.size ] = "j_ankle_ri";
	tagList[ tagList.size ] = "j_ankle_le";
	tagList[ tagList.size ] = "j_knee_ri";
	tagList[ tagList.size ] = "j_knee_le";
	tagList[ tagList.size ] = "j_hiptwist_ri";
	tagList[ tagList.size ] = "j_hiptwist_le";
	tagList[ tagList.size ] = "j_spinelower";
	return tagList;
}

getAdjacentTags( tagName ) {
	tagList = [];
	
	switch( tagName ) {
		case "j_wristtwist_ri":
			tagList[ tagList.size ] = "j_elbow_bulge_ri";
			break;
		case "j_wristtwist_le":
			tagList[ tagList.size ] = "j_elbow_bulge_le";
			break;
		
		case "j_elbow_bulge_ri":
			tagList[ tagList.size ] = "j_wristtwist_ri";
			tagList[ tagList.size ] = "j_shoulder_ri";
			break;
		case "j_elbow_bulge_le":
			tagList[ tagList.size ] = "j_wristtwist_le";
			tagList[ tagList.size ] = "j_shoulder_le";
			break;
		
		case "j_shoulder_ri":
			tagList[ tagList.size ] = "j_elbow_bulge_ri";
			tagList[ tagList.size ] = "j_spineupper";
			break;
		case "j_shoulder_le":
			tagList[ tagList.size ] = "j_elbow_bulge_le";
			tagList[ tagList.size ] = "j_spineupper";
			break;
		
		case "j_spineupper":
			tagList[ tagList.size ] = "j_shoulder_ri";
			tagList[ tagList.size ] = "j_shoulder_le";
			tagList[ tagList.size ] = "j_spinelower";
			break;
		
		case "j_ankle_ri":
			tagList[ tagList.size ] = "j_knee_ri";
			break;
		case "j_ankle_le":
			tagList[ tagList.size ] = "j_knee_le";
			break;
		
		case "j_knee_ri":
			tagList[ tagList.size ] = "j_ankle_ri";
			tagList[ tagList.size ] = "j_hiptwist_ri";
			break;
		case "j_knee_le":
			tagList[ tagList.size ] = "j_ankle_le";
			tagList[ tagList.size ] = "j_hiptwist_le";
			break;
		
		case "j_hiptwist_ri":
			tagList[ tagList.size ] = "j_knee_ri";
			tagList[ tagList.size ] = "j_spinelower";
			break;
		case "j_hiptwist_le":
			tagList[ tagList.size ] = "j_knee_le";
			tagList[ tagList.size ] = "j_spinelower";
			break;
		
		case "j_spinelower":
			tagList[ tagList.size ] = "j_hiptwist_ri";
			tagList[ tagList.size ] = "j_hiptwist_le";
			tagList[ tagList.size ] = "j_spineupper";
			break;
	}
	return tagList;
}

isTagOnFire( tagName ) {
	if( !isDefined( self.tagsOnFire ) )
		return false;
	
	for( i = 0; i < self.tagsOnFire.size; i++ ) {
		if( self.tagsOnFire[ i ] == tagName )
			return true;
	}
	return false;
}

fireEffects() 
{
	self endon( "death" );
	self endon( "disconnect" );
	
	fullTagList = getTagList();
	
	while( 1 ) {
		wait( 0.05 );
		if( !isDefined( self.tagsOnFire ) )
			continue;
		
		consecTag = 0;
		for( i = 0; i < fullTagList.size; i++ ) {
			if( self isTagOnFire( fullTagList[ i ] ) )
				playFXOnTag( level._effect[ "burn_tag" ], self, fullTagList[ i ] );
			consecTag++;
			if( consecTag >= 4 ) {
				wait( 0.05 );
				consecTag = 0;
			}
		}
	}
}

fireSpread() {
	self endon( "death" );
	self endon( "disconnect" );
	
	while( 1 ) 
	{
		wait( 0.05 );
		if( !isDefined( self.tagsOnFire ) )
			continue;
		
		wait( 0.5 );
		// Putting out fire
		if( self isRemovingFire() ) {
			for( i = 0; i < self.tagsOnFire.size; i++ ) {
				if( randomInt( level.fireGoOutChance ) == 0 )
					self putOutTag( self.tagsOnFire[ i ] );
			}
		}
		if( self.tagsOnFire.size == 0 ) {
			self.tagsOnFire = undefined;
			self notify( "nofire" );
			continue;
		}
		
		if( self.tagsOnFire.size >= level.fireNumTags )
			continue;
		
		// Spreading fire
		if( self isFireProof() || self isInRain() )
			continue;
		for( i = 0; i < self.tagsOnFire.size; i++ ) 
		{
			adjacentTags = getAdjacentTags( self.tagsOnFire[ i ] );
			for( j = 0; j < adjacentTags.size; j++ ) 
			{
				if( self isTagOnFire( adjacentTags[ j ] ) )
					continue;
				if( randomInt( level.fireSpreadChance ) == 0 )
					self.tagsOnFire[ self.tagsOnFire.size ] = adjacentTags[ j ];
			}
		}
	}
}

isRemovingFire() {
	return ( self.moveSpeed > 250 || ( self.moveSpeed > 10 && self getStance() == "prone" ) );
}

fireDamage() {
	self endon( "death" );
	self endon( "disconnect" );
	
	while( 1 ) {
		wait( 0.05 );
		if( !isDefined( self.tagsOnFire ) )
			continue;
		if( self.tagsOnFire.size <= level.fireDamageTagThreshold )
			continue;
		
		wait( 0.5 );
		if( !isDefined( self.tagsOnFire ) )
			continue;
		if( self.tagsOnFire.size <= level.fireDamageTagThreshold )
			continue;
		
		if( !isDefined( self.spamDelay ) ) {
			if( self.tagsOnFire.size > level.fireSpreadTagThreshold && self.health > 40 ) {
				if( self.pers[ "team" ] == "axis" )
					self playSound( "obsfirescream" );
				else
					self playSound( "firescream" );
				self thread playerSpamDelay( 3 );
			}
			else if( self.pers[ "team" ] == "allies" ) {
				self playSound( "generic_pain" );
				self thread playerSpamDelay( 1 );
			}
		}
		
		if( isDefined( self.lastFireInflictor ) )
			attacker = self.lastFireInflictor;
		else
			attacker = self;
		if( self isFireProof() )
			self thread maps\mp\gametypes\_globallogic::callback_PlayerDamage( attacker, attacker, int( level.fireDamagePerTag * self.tagsOnFire.size + 1 ), 0, "MOD_EXPLOSIVE", "burning_mp", ( 0,0,0 ), ( 0,0,0 ), "neck", 0 );
		else
			self thread maps\mp\gametypes\_globallogic::callback_PlayerDamage( attacker, attacker, int( level.fireDamagePerTagLess * self.tagsOnFire.size + 1 ), 0, "MOD_EXPLOSIVE", "burning_mp", ( 0,0,0 ), ( 0,0,0 ), "neck", 0 );
		if( self maps\mp\_flashgrenades::isFlashbanged() == false )
			self shellShock( "onfire", 0.5 );
	}
}

putOutTag( tagName ) {
	newArray = [];
	for( i = 0; i < self.tagsOnFire.size; i++ ) {
		if( self.tagsOnFire[ i ] != tagName )
			newArray[ newArray.size ] = self.tagsOnFire[ i ];
	}
	self.tagsOnFire = newArray;
}

putOutNumTags( numTags ) {
	if( !isDefined( self.tagsOnFire ) )
		return;
	if( numTags >= self.tagsOnFire.size )
		self.tagsOnFire = [];
	else {
		newArray = [];
		for( i = 0; i < numTags; i++ )
			newArray[ newArray.size ] = self.tagsOnFire[ i ];
		self.tagsOnFire = newArray;
	}
}

fireSpreadToOthers() {
	self endon( "death" );
	self endon( "disconnect" );
	
	spreadDist = level.fireSpreadDistance;
	spreadDist = spreadDist * spreadDist;
	
	while( 1 ) {
		wait( 0.05 );
		if( !isDefined( self.tagsOnFire ) )
			continue;
		if( self.tagsOnFire.size <= level.fireSpreadTagThreshold )
			continue;
		
		wait( 0.5 );
		players = level.players;
		for( i = 0; i < players.size; i++ ) {
			if( !isDefined( players[ i ] ) || !isDefined( players[ i ].sessionState ) )
				continue;
			if( players[ i ].sessionState != "playing" || players[ i ] == self || players[ i ] isFireProof() || players[ i ] isInRain() )
				continue;
			
			if( distanceSquared( self.origin, players[ i ].origin ) < spreadDist ) {
				players[ i ] igniteTag( getClosestFireTag( self getMidPosition() ) );
				if( isDefined( self.lastFireInflictor ) )
					players[ i ].lastFireInflictor = self.lastFireInflictor;
				else
					players[ i ].lastFireInflictor = self;
			}
		}
	}
}

igniteTag( tagName ) {
	if( isDefined( self.tagsOnFire ) ) {
		for( i = 0; i < self.tagsOnFire.size; i++ ) {
			if( self.tagsOnFire[ i ] == tagName )
				return;
		}
	}
	else
		self.tagsOnFire = [];
	
	self.tagsOnFire[ self.tagsOnFire.size ] = tagName;
}

igniteAllTags() {
	tagList = getTagList();
	
	for( i = 0; i < tagList.size; i++ )
		self igniteTag( tagList[ i ] );
}

igniteNumTagsNearPoint( numTags, point ) {
	tagList = getTagList();
	
	for( i = 0; i < numTags; i++ ) {
		closestDist = undefined;
		closestTag = undefined;
		
		for( j = 0; j < tagList.size; j++ ) {
			if( self isTagOnFire( tagList[ j ] ) )
				continue;
			dist = distanceSquared( point, self getTagOrigin( tagList[ j ] ) );
			if( !isDefined( closestTag ) || dist < closestDist ) {
				closestTag = tagList[ j ];
				closestDist = dist;
			}
		}
		if( isDefined( closestTag ) )
			self igniteTag( closestTag );
	}
}

