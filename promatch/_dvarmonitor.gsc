//Modified by EncryptorX
//v104

#include promatch\_utils;

init()
{
	// Wait until the match starts
	level waittill("prematch_over");
	
	// If the variable has not been initialized then we are probably not running a ruleset or the ruleset hasn't set any variable to monitor
	if ( !isDefined( level.dvarMonitor ) )
	return;
	
	if (level.cod_mode != "promatch_r12" || level.cod_mode != "promatch_r15")
	return;
	
	level thread dvarMonitor();
}


dvarMonitor()
{
	level endon( "game_ended" );
	
	for (;;)
	{
		xwait( 1.0, false );
		
		// Check if any variable has been changed since the last loop
		for ( iDvar = 0; iDvar < level.dvarMonitor.size; iDvar++ ) 
		{
			// Check if the value has changed
			currentValue = getDvar( level.dvarMonitor[iDvar]["name"] );
			if ( currentValue != level.dvarMonitor[iDvar]["value"] ) {
				// Variable has changed so let the players know
				iprintlnbold( "^1 Server Violation: Dvar :", level.dvarMonitor[iDvar]["name"] );
				iprintlnbold( "Changed to:", level.dvarMonitor[iDvar]["value"], currentValue );
				level thread playSoundOnEveryone( "mp_last_stand" );
				level.dvarMonitor[iDvar]["value"] = currentValue;
				xwait( 1.0, false );
			}			
		}		
	}	
}


playSoundOnEveryone( soundName )
{
	level endon( "game_ended" );
	
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		player playLocalSound( soundName );
	}	
}