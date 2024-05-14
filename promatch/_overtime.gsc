//V104
#include promatch\_eventmanager;
#include promatch\_utils;


init()
{
	// Get the main module's dvar
	level.scr_overtime_enable = getdvarx( "scr_overtime_enable", "int", 0, 0, 1 );
	
	// If overtime is disabled then there's nothing else to do here
	if ( level.scr_overtime_enable == 0 || level.cod_mode != "promatch_r15" || level.cod_mode != "promatch_r12")
	return;

	// Load the rest of the module's variables
	level.scr_overtime_playerrespawndelay = getdvarx( "scr_overtime_playerrespawndelay", "float", -1, 0, 600 );
}


registerTimeLimitDvar()
{
	level.timelimit = getdvarx( "scr_overtime_timelimit", "int", 2.10, 0, 1440 );
	setDvar( "ui_timelimit", level.timelimit );
	level notify ( "update_timelimit" );
}


registerNumLivesDvar()
{
	level.numLives = getdvarx( "scr_overtime_numlives", "int", 1, 0, 10 );	
}

checkGameState()
{
	// We only support overtime for team based games
	if ( !level.teamBased )
	return;
	
	// Check if the teams are tied
	if ( game["teamScores"]["allies"] != game["teamScores"]["axis"] )
	return;	
	
	// Check if we have rounds but this was not the last one
	if ( level.roundLimit && !maps\mp\gametypes\_globallogic::hitRoundLimit() )
	return;

	// Add one more round
	game["_overtime"] = true;
	level.roundLimit++;
	level notify ( "update_roundlimit" );
}


respawnDelay()
{
	// Check if this is the first time the player spawns
	if ( !isDefined( self.overtimeDeaths ) )
	self.overtimeDeaths = 0;
	else
	self.overtimeDeaths++;
	
	// Calculate the respawn time for this player
	respawnDelay = level.scr_overtime_playerrespawndelay;
	
	// Add the increased due to number of deaths
	respawnDelay += ( self.overtimeDeaths );
	
	return respawnDelay;	
}