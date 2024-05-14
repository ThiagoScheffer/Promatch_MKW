#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include promatch\_utils;
//V104

init()
{
	// Get the main module's dvars
	level.scr_match_strategy_time = getdvarx( "scr_match_strategy_time", "float", 4, 0, 800 );
	level.scr_league_ruleset = getdvarx( "scr_league_ruleset", "string", "" );
	level.version = getdvarx( "_ModVer", "string", "" );
	level.strattext = getdvarx( "scr_strattext", "string", "Strat time" );
	
	// There's no need to have strategy time when the game is not team based unless players are crazy and like to talk to themselves... ;)
	if ( !level.teamBased || level.scr_match_strategy_time == 0 ) 
	{
		level.inStrategyPeriod = false;
		return;
	}


	if ( level.scr_match_strategy_time < 2.5 ) 
	{
		level.scr_match_strategy_time = 2.5;
	}
	
	//if ( isdefined(game["_overtime"]) && game["_overtime"] == true)
	//	level.scr_league_ruleset = "Tie Breaker";
		
	// Get the rest of the dvars
	level.scr_match_strategy_allow_bypass = getdvarx( "scr_match_strategy_allow_bypass", "int", 0, 0, 1 );
	level.scr_match_strategy_show_bypassed = getdvarx( "scr_match_strategy_show_bypassed", "int", 1, 0, 1 );
	level.scr_match_strategy_getready_time = getdvarx( "scr_match_strategy_getready_time", "float", 0, 0, 5 );
	level.scr_match_strategy_allow_movement = getdvarx( "scr_match_strategy_allow_movement", "int", 0, 0, 1 );

	// We are in strategy mode
	level.inStrategyPeriod = true;
	
	setDvar( "g_deadChat", "1" );
	precacheString( &"OW_STRATEGY_PERIOD_FINISHED" );
	precacheString( &"OW_STRATEGY_GET_READY" );
	precacheString( &"OW_STRATEGY_BYPASSED" );
	precacheString( &"OW_PRESS_TO_BYPASS" );
	
	//precacheStatusIcon( "compassping_friendlyyelling_mp" );

	level thread onPlayerConnect();

	level.strategyPeriodEnds = gettime() + level.scr_match_strategy_time * 1000;

	// Show HUD elements
	level.strategyPeriodText = createServerFontString( "objective", 1.5 );
	level.strategyPeriodText setPoint( "CENTER", "CENTER", 0, -20 );
	level.strategyPeriodText.sort = 1001;
	level.strategyPeriodText setText( level.strattext );
	level.strategyPeriodText.foreground = false;
	level.strategyPeriodText.hidewheninmenu = true;

	level.strategyPeriodTimer = createServerTimer( "objective", 1.5 );
	level.strategyPeriodTimer setTimer( ( level.strategyPeriodEnds - gettime() ) / 1000 );
	level.strategyPeriodTimer setPoint( "CENTER", "CENTER", 0, 0 );
	level.strategyPeriodTimer.color = ( 1, 0.5, 0 );
	level.strategyPeriodTimer.sort = 1001;
	level.strategyPeriodTimer.foreground = false;
	level.strategyPeriodTimer.hideWhenInMenu = true;

	level.promatchver = newHudElem();
	level.promatchver.x = -7;
	level.promatchver.y = 35;
	level.promatchver.horzAlign = "right";
	level.promatchver.vertAlign = "top";
	level.promatchver.alignX = "right";
	level.promatchver.alignY = "middle";
	level.promatchver.alpha = 1;
	level.promatchver.fontScale = 1.4;
	level.promatchver.hidewheninmenu = true;
	
	if(level.hardcoreMode)
	level.promatchver setText("Publico ^1 v10 ProHC");
	else
	level.promatchver setText("Publico ^1 v10");

	level.ruletext = newHudElem();
	level.ruletext.x = -7;
	level.ruletext.y = 50;
	level.ruletext.horzAlign = "right";
	level.ruletext.vertAlign = "top";
	level.ruletext.alignX = "right";
	level.ruletext.alignY = "middle";
	level.ruletext.alpha = 1;
	level.ruletext.fontScale = 1.4;
	level.ruletext.hidewheninmenu = true;
	level.ruletext.color = (1,0.5,0);
	level.ruletext setText( level.scr_league_ruleset );
	//permissao de compras
	level.canbuy = true;
	
	level notify("strategyperiod_started");
	
	//level thread maps\mp\gametypes\_teams::balanceMostRecent();
	
	// Loop until the strategy period is over
	while ( level.inStrategyPeriod )
	{
		wait level.oneFrame;
		
		// Check that we are still within the time frame
		if ( gettime() >= level.strategyPeriodEnds ) 
		{
			level.inStrategyPeriod = false;
		}		
		
	}
	level.canbuy = false;
	// Show a message letting players know the round is about to start
	level.strategyPeriodText setText( &"OW_STRATEGY_PERIOD_FINISHED" );
	level.strategyPeriodTimer setTenthsTimer( level.scr_match_strategy_getready_time );

	//xwait( level.scr_match_strategy_getready_time, false );
	
	level.strategyPeriodText destroy();
	level.strategyPeriodTimer destroy();
	level.promatchver destroy();
	level.ruletext destroy();

	level notify("strategyperiod_ended");
	
}

onPlayerConnect()
{
	self endon("strategyperiod_ended");

	while ( level.inStrategyPeriod )
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	self endon("strategyperiod_ended");
	
	while ( level.inStrategyPeriod )
	{
		self waittill("spawned_player");
		self thread strategyPeriod();
	}
}

//ESSE controla o STRAT De 3 segundos
strategyPeriod()
{
	self endon("disconnect");

	if ( !level.inStrategyPeriod )
	return;
	
	// Freeze player on the spot
	self freezeControls( false );
	self allowJump(false);
	self allowSprint(false);
	self setMoveSpeedScale( 0 );	
	
	self.allowclasschanges = true;
	//Set Allow Name Change
	setClientNameMode("auto_change");

	// Wait until strategy period is over
	while ( level.inStrategyPeriod )
	wait level.oneFrame;

	// Enable player movement
	self notify("strategyperiod_ended");
	
	setDvar( "g_deadChat", 0 );	
	self.allowclasschanges = undefined;
	// Unfreeze the player
	self allowSprint(true);	
	self allowJump(true);
	self thread SetClassBasedSpeed();
}