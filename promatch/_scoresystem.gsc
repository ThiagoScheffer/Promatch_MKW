#include promatch\_utils;
//V104
init()
{
	
	level.scr_score_tk_affects_teamscore = 1;
	// Register the different scores
	// Type of kills		
	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 10 );
	
		
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 25);
	maps\mp\gametypes\_rank::registerScoreInfo( "melee", 30 );
	maps\mp\gametypes\_rank::registerScoreInfo( "grenade", 12 ); 
	maps\mp\gametypes\_rank::registerScoreInfo( "vehicleexplosion", 75 );
	maps\mp\gametypes\_rank::registerScoreInfo( "barrelexplosion", 75 );
	maps\mp\gametypes\_rank::registerScoreInfo( "c4", 5 );
	maps\mp\gametypes\_rank::registerScoreInfo( "claymore", 5 );
	maps\mp\gametypes\_rank::registerScoreInfo( "airstrike", 15 ); 	

	// Assist kills
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 1 ); 	
	maps\mp\gametypes\_rank::registerScoreInfo( "assist_75", 12 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist_50", 9 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist_25", 5 );
	
	// Death, suicide and team kill point losses
	maps\mp\gametypes\_rank::registerScoreInfo( "death", -10 ); 
	maps\mp\gametypes\_rank::registerScoreInfo( "suicide", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", -500 );		
	maps\mp\gametypes\_rank::registerScoreInfo( "camper", -100 );

	// Game actions scores
	maps\mp\gametypes\_rank::registerScoreInfo( "capture", 500 );
	maps\mp\gametypes\_rank::registerScoreInfo( "take", 400 );
	maps\mp\gametypes\_rank::registerScoreInfo( "return", 150 );
	maps\mp\gametypes\_rank::registerScoreInfo( "defend", 125 );
	maps\mp\gametypes\_rank::registerScoreInfo( "holding", 100);
	maps\mp\gametypes\_rank::registerScoreInfo( "killcarrier", 120 );
	
	maps\mp\gametypes\_rank::registerScoreInfo( "extracted", 800 );
	maps\mp\gametypes\_rank::registerScoreInfo( "vipkilled", 500 );
	
	
	maps\mp\gametypes\_rank::registerScoreInfo( "defend_assist", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assault_assist", 50 );
	
	maps\mp\gametypes\_rank::registerScoreInfo( "carrierdeath", -15 );
	
	maps\mp\gametypes\_rank::registerScoreInfo( "revive", 125 );
	
	//retrieval scores
	maps\mp\gametypes\_rank::registerScoreInfo( "recaptured", 150 );
	maps\mp\gametypes\_rank::registerScoreInfo( "revive", 50 );
	
	//estava perto do bombcarrier e deixo ele morrer
	maps\mp\gametypes\_rank::registerScoreInfo( "timeinutil", -7);
		
	if(level.gametype == "sd" || level.gametype == "sab")
	{
		maps\mp\gametypes\_rank::registerScoreInfo( "death", -8 ); 
		maps\mp\gametypes\_rank::registerScoreInfo( "plant", 450 );
		maps\mp\gametypes\_rank::registerScoreInfo( "defuse", 300 );
	}

	
	if(level.gametype == "dm")
	{
		maps\mp\gametypes\_rank::registerScoreInfo( "kill", 20 );
		maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 25 );
		maps\mp\gametypes\_rank::registerScoreInfo( "melee", 15 );
		maps\mp\gametypes\_rank::registerScoreInfo( "grenade", 5 ); 	
	}
	
	if(level.gametype == "dom")
	{
		maps\mp\gametypes\_rank::registerScoreInfo( "kill", 5 );
		maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 5 );
		maps\mp\gametypes\_rank::registerScoreInfo( "melee", 5 );
		maps\mp\gametypes\_rank::registerScoreInfo( "grenade", 5 ); 	
	}
	
	if(level.gametype == "ctf")
	{
		maps\mp\gametypes\_rank::registerScoreInfo( "kill", 5 );
		maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 5 );
		maps\mp\gametypes\_rank::registerScoreInfo( "melee", 5 );
		maps\mp\gametypes\_rank::registerScoreInfo( "grenade", 5 ); 	
	}
	
	maps\mp\gametypes\_rank::registerScoreInfo( "assault", 15 );	
	maps\mp\gametypes\_rank::registerScoreInfo( "helicopter", 1 );
	maps\mp\gametypes\_rank::registerScoreInfo( "helicopterdown", 1000 );	

	maps\mp\gametypes\_rank::registerScoreInfo( "conecamper", -50 );	
}

//globallogic 5348
getPointsForKill( pMeansOfDeath, pWeapon, pAttacker)
{
	// Initialize the score info array with the default kill values
	scoreInfo = [];
	scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
	scoreInfo["type"] = "kill";


	// Headshot kill
	if ( pMeansOfDeath == "MOD_HEAD_SHOT" )
	{
		pAttacker  maps\mp\gametypes\_globallogic::incPersStat( "headshots", 1 );
		pAttacker.headshots = pAttacker maps\mp\gametypes\_globallogic::getPersStat( "headshots" );
		
		scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "headshot" );
		scoreInfo["type"] = "headshot";
		pAttacker playLocalSound( "bullet_impact_headshot_2" );		

		//if ( isDefined( pAttacker.lastStand ) )
		//	scoreInfo["score"] *= 2;
	} 
	else if ( pMeansOfDeath == "MOD_MELEE" ) 
		{
			scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "melee" );
			scoreInfo["type"] = "melee";

		// Grenade kill		
		} else if ( issubstr( pMeansOfDeath, "MOD_GRENADE" ) && ( pWeapon == "frag_grenade_mp" || pWeapon == "semtex_grenade_mp" || pWeapon == "frag_grenade_short_mp") ) 
		{
			scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "grenade" );
			scoreInfo["type"] = "grenade";
			
			// C4 kill
		} else if ( issubstr( pMeansOfDeath, "MOD_GRENADE" ) && pWeapon == "c4_mp") 
		{
			scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "c4" );
			scoreInfo["type"] = "c4";

		// nade throw	
		} 
		else if ( issubstr( pMeansOfDeath, "MOD_EXPLOSIVE" ) && pWeapon == "destructible_car" ) 
		{
			scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "vehicleexplosion" );
			scoreInfo["type"] = "vehicleexplosion";
			if(level.aliveCount["allies"] >= 3 && level.aliveCount["axis"] >= 3)
			pAttacker GiveEVP(10,100);
			
		// Exploding barrel kill
		} else if ( issubstr( pMeansOfDeath, "MOD_CRUSH" ) && pWeapon == "explodable_barrel" ) 
		{
			scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "barrelexplosion" );
			scoreInfo["type"] = "barrelexplosion";
			
			if(level.aliveCount["allies"] >= 3 && level.aliveCount["axis"] >= 3)
			pAttacker GiveEVP(50,100);
			
		} else if ( issubstr( pMeansOfDeath, "MOD_PROJECTILE" ) && pWeapon == "artillery_mp") {
			scoreInfo["score"] = maps\mp\gametypes\_rank::getScoreInfoValue( "airstrike" );
			scoreInfo["type"] = "airstrike";
		} 
	return scoreInfo;
}
