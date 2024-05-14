#include promatch\_utils;
//v104
init()
{
	// Just start the thread that will monitor if a new ruleset needs to be loaded
	precacheString( &"OW_RULESET_VALID" );
	precacheString( &"OW_RULESET_NOT_VALID" );

	// We do this so it can be changed without the need to enter "set"
	setDvar( "cod_mode", getdvard( "cod_mode", "string", "", undefined, undefined ) );
	level thread rulesetMonitor();
}

rulesetMonitor()
{
	// Initialize a variable to keep the current ruleset
	currentRuleset = level.cod_mode;

	// Loop until we have a valid new ruleset
	for (;;)
	{
		// Monitor a change in ruleset
		while ( level.cod_mode == currentRuleset ) 
		{
			xwait( 1.0, false );
			level.cod_mode = getdvard( "cod_mode", "string", "", undefined, undefined );

			// If the game ends we'll kill the thread as a new one will start with the new map
			if ( game["state"] == "postgame" )
			return;
		}

		// Check if we have a rule for this league and gametype first
		if ( isDefined( level.matchRules ) && isDefined( level.matchRules[ level.cod_mode ] ) )
		{
			if ( isDefined( level.matchRules[ level.cod_mode ][ level.gametype ] ) || isDefined( level.matchRules[ level.cod_mode ]["all"] ) )
			{
				thread closeEveryonesMenus();
				iprintln( &"OW_RULESET_VALID", level.cod_mode );
				xwait( 3.0, false );
				nextRotation = " " + getDvar( "sv_mapRotationCurrent" );
				setdvar( "sv_mapRotationCurrent", "gametype " + level.gametype + " map " + level.script + nextRotation );
				exitLevel( false );
				return;
			}
		}
		else if ( level.cod_mode == "" )
		{
			thread closeEveryonesMenus();
			iprintln( &"OW_RULESET_DISABLED" );
			xwait( 3.0, false );
			nextRotation = " " + getDvar( "sv_mapRotationCurrent" );
			setdvar( "sv_mapRotationCurrent", "gametype " + level.gametype + " map " + level.script + nextRotation );
			exitLevel( false );
			return;
		}

		// The ruleset is not valid
		iprintln( &"OW_RULESET_NOT_VALID", level.cod_mode );
		setDvar( "cod_mode", currentRuleset );
		level.cod_mode = currentRuleset;
	}
}


closeEveryonesMenus()
{
	for ( index = 0; index < level.players.size; index++ )
	{
		level.players[index] thread maps\mp\gametypes\_globallogic::closeMenus();
	}
}
