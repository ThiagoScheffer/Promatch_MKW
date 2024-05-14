#include maps\mp\gametypes\_hud_util;
#include promatch\_eventmanager;
#include promatch\_utils;

init()
{

	if(level.cod_mode != "torneio")
	 return;
	 
	// Get the main module's dvar
	level.scr_blackscreen_spectators = getdvarx( "scr_blackscreen_spectators", "int", 1, 0, 1 );
	level.scr_blackscreen_spectators_guids = getdvarx( "scr_blackscreen_spectators_guids", "string", level.scr_livebroadcast_guids );

	// If the black screen is not enabled then there's nothing to do here
	if ( level.scr_blackscreen_spectators == 0 )
	return;
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	self thread addNewEvent( "onJoinedSpectators", ::onJoinedSpectators );
	
	if ( level.scr_blackscreen_spectators == 1 && !isSubstr( level.scr_blackscreen_spectators_guids, self getguid() ) && !level.inReadyUpPeriod  ) 
	self blind(true);
	
}


onJoinedSpectators()
{
	// Destroy the screen if the player when into spectating mode and spectators blackscreen is disabled
	if ( level.scr_blackscreen_spectators == 0 ) 
	{
		// Destroy the screen if the person joined the spectators and he is allowed to see the game
		self blind(false);
	} 
	else if (level.scr_blackscreen_spectators == 1 && isSubstr( level.scr_blackscreen_spectators_guids, self getguid() )) 
	{
		self blind(false);
		
	}
	else if ( level.scr_blackscreen_spectators == 1 && !isSubstr( level.scr_blackscreen_spectators_guids, self getguid() ) && !level.inReadyUpPeriod ) 
	{
		self blind(true);		
	}
}


onPlayerSpawned()
{
	//Limpar a tela ao dar spawn
	self blind(false);
}

blind( toggle ) 
{

	//Fullbright
	self setClientDvar( "r_fullbright", self statGets("FULLBRIGHT") );
	
	//If the player should be blinded
	if( toggle ) 
	{
	
		self hideHUD();
		//Set their brightness low with no contrast
		self setClientDvar( "r_brightness", -1 );
		self setClientDvar( "r_contrast", 0 );
		
	
	}
	//Otherwise they should be able to see
	else {
	
		self showHUD();
		//So put the brightness and contrast to normal
		self setClientDvar( "r_brightness", 0 );
		self setClientDvar( "r_contrast", 1 );
		
	
	}
}