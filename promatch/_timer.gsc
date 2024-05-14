#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include promatch\_utils;

init()
{
	// Wait for the game to start
	level waittill("prematch_over");
	
	// Init some variables we'll be using
	level.timerStart = gettime();
	level.timerDiscard = 0;
	
	// Start the thread to monitor timeouts
	if (level.cod_mode == "promatch_r12" || level.cod_mode == "promatch_r15")
	level thread monitorTimeOuts();	
}


monitorTimeOuts()
{
	level endon("game_ended");
	
	for (;;)
	{
		wait level.oneFrame;
		// Check if we are in timeout mode
		if ( level.inTimeoutPeriod )
		level.timerDiscard += ( level.oneFrame * 1000 );
	}	
}


getTimePassed()
{
	if ( level.inReadyUpPeriod ) 
	{
		return gettime();
	} else if ( !isDefined( level.timerStart ) ) {
		return 0;
	} else {
		return ( gettime() - level.timerStart - level.timerDiscard );	
	}
}


getServerTime()
{
	return gettime();
}