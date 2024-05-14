#include promatch\_eventmanager;
#include promatch\_utils;

init()
{
	// Get the main module's dvars
	level.scr_health_death_sound = getdvarx( "scr_health_death_sound", "int", 0, 0, 1 );

	if (level.scr_health_death_sound == 0 )
		return;
	
	if(level.cod_mode == "torneio")
		return;

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onPlayerKilled", ::onPlayerKilled );
}

onPlayerSpawned()
{
	// Set which kind of voice this player is going to do when dying
	switch ( self.pers["team"] ) 
	{
		case "allies":
			switch ( game["allies"] ) {
				case "sas":
					self.myDeathSound = "generic_death_british_";
					self.myPainSound = "generic_pain_british_";
					break;
				case "marines":
				default:
					self.myDeathSound = "generic_death_american_";
					self.myPainSound = "generic_pain_american_";
					break;
			}
			break;
		case "axis":
			switch ( game["axis"] ) {
				case "russian":
					self.myDeathSound = "generic_death_russian_";
					self.myPainSound = "generic_pain_russian_";
					break;
				case "arab":
				case "opfor":
				default:
					self.myDeathSound = "generic_death_arab_";
					self.myPainSound = "generic_pain_arab_";
					break;
			}
			break;
		default:
			self.myDeathSound = "generic_death_american_";
			self.myPainSound = "generic_pain_american_";
			break;
	}
	// Assign a random number between 1 and 8 (sound aliases for go from 1 to 8).
	self.myDeathSound = self.myDeathSound + randomIntRange(1, 9);
	self.myPainSound = self.myPainSound + randomIntRange(1, 9);
}

//acontece quando o jogador foi morto por algum player apenas
onPlayerKilled()
{

	if(isDefined(self.onfire))
	{
		self playSound( "scream03");//final death
		return;
	}
	
	//iprintln("DTH: " + statGets("ANIMALDEATH"));
	if(self.animaldeaths == 1)
	{
		if(!self.incognito)
		self playSound( "animal" + randomIntRange(0,28));
		
		return;
	}
	
	// Make the death sound for this player

	if(!self.incognito)
	self playSound( self.myDeathSound );	
}

