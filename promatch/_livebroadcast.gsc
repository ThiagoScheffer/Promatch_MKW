// Code by T3chnnor OW team
#include promatch\_eventmanager;
#include promatch\_utils;
//V104
init()
{
	// We start this thread anyway so we can populate the internal value for broadcasters
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );	
	//precacheStatusIcon( "hud_status_broadcaster" );
}


onPlayerConnected()
{
	//self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	if(level.atualgtype == "sd")
	self thread deadaliveplayersicon();
}


deadaliveplayersicon()
{
	self endon("disconnect");
	level endon("game_ended");
	
	// Initialize tracker array so we only send the things that changed and nothing more
	maxPlayersPerTeam = 12;
	statusTracker = [];
	level.inupdatealiveplayers = false;
	
	for (;;)
	{
		// changed to false to make a refresh when game ends and start again. so players health  stats keep up.
		//xwait( 0.15, false );
		self waittill("getteamplayersalive");
		//iprintln("---------------ATUALIZANDO PLAYERS VIVOS-----------------");
		
		if(level.inupdatealiveplayers)
		continue;
		
		xwait( 0.15, false );
		
		// Do not update anything if the player is not playing
		if ( !isDefined( self.pers["team"] ) || self.pers["team"] == "spectator" )
		continue;
		
		level.inupdatealiveplayers = true;

		// Init variables for this cycle
		statusChanged = [];
		
		teamPlayers = [];
		teamPlayers["allies"] = 0;
		teamPlayers["axis"] = 0;
		pname = "";
		// Check and save status of all the players in the server	
		for ( index = 0; index < level.players.size; index++ ) 
		{
			
			player = level.players[index];
			team = player.pers["team"];
			pname = player.name;
			// We are only interested in the players assigned to a team
			if ( team == "allies" || team == "axis" ) 
			{
				// Make sure we still have a free slot in this team
				if ( teamPlayers[team] < maxPlayersPerTeam ) 
				{
					teamPlayers[team]++;
					
					// Check if this player's name has changed
					if ( !isDefined( statusTracker["lb_"+team+"_p"+teamPlayers[team]] ) || statusTracker["lb_"+team+"_p"+teamPlayers[team]] != pname ) 
					{
						statusTracker["lb_"+team+"_p"+teamPlayers[team]] = pname;
						newElement = statusChanged.size;
						statusChanged[newElement]["name"] = "lb_"+team+"_p"+teamPlayers[team];
						statusChanged[newElement]["value"] = pname + " [" +player getEntityNumber()+"]";
					}
					// Check if this player's health has changed
					if ( !isDefined( statusTracker["lb_"+team+"_h"+teamPlayers[team]] ) || statusTracker["lb_"+team+"_h"+teamPlayers[team]] !=  player.health ) {
						statusTracker["lb_"+team+"_h"+teamPlayers[team]] = player.health;
						newElement = statusChanged.size;
						statusChanged[newElement]["name"] = "lb_"+team+"_h"+teamPlayers[team];
						statusChanged[newElement]["value"] = player.health;
					}					
				}
			}
		}
		
		// Complete the arrays just in case players have disconnected
		teamKeys = getArrayKeys( teamPlayers );
		for ( index = 0; index < teamKeys.size; index++ ) 
		{
			team = teamKeys[index];
			
			for ( slot = teamPlayers[team]; slot < maxPlayersPerTeam; slot++ ) {
				teamPlayers[team]++;
				
				// Check if this player slot used to be assigned
				if ( !isDefined( statusTracker["lb_"+team+"_p"+teamPlayers[team]] ) || statusTracker["lb_"+team+"_p"+teamPlayers[team]] != "" ) {
					statusTracker["lb_"+team+"_p"+teamPlayers[team]] = "";
					newElement = statusChanged.size;
					statusChanged[newElement]["name"] = "lb_"+team+"_p"+teamPlayers[team];
					statusChanged[newElement]["value"] = "";
					
					statusTracker["lb_"+team+"_h"+teamPlayers[team]] = 0;
					newElement = statusChanged.size;
					statusChanged[newElement]["name"] = "lb_"+team+"_h"+teamPlayers[team];
					statusChanged[newElement]["value"] = 0;
				}
			}
		}

		// Check if we have any new status to send
		if ( statusChanged.size > 0 ) 
		{
			
			// Because we make calls sending up to 16 variables at the same time for performance
			// reasons we need to complete the array with dummy variables
			addDummy = 10 - ( statusChanged.size % 10 );
			if ( addDummy != 10 ) {
				for ( i = 0; i < addDummy; i++ ) {
					newElement = statusChanged.size;
					statusChanged[newElement]["name"] = "dv"+i;
					statusChanged[newElement]["value"] = "";
				}
			}
			
			// Calculate how many cycles we'll need to send all the variables
			sendCycles = int( statusChanged.size / 10 );
			
			// Send the updates to the current broadcaster
			for ( cycle = 0; cycle < sendCycles; cycle++ ) {
				firstElement = 10 * cycle;
				
				// Send this cycle
				self setClientDvars(
				statusChanged[ firstElement + 0 ]["name"], statusChanged[ firstElement + 0 ]["value"],
				statusChanged[ firstElement + 1 ]["name"], statusChanged[ firstElement + 1 ]["value"],
				statusChanged[ firstElement + 2 ]["name"], statusChanged[ firstElement + 2 ]["value"],
				statusChanged[ firstElement + 3 ]["name"], statusChanged[ firstElement + 3 ]["value"],
				statusChanged[ firstElement + 4 ]["name"], statusChanged[ firstElement + 4 ]["value"],
				statusChanged[ firstElement + 5 ]["name"], statusChanged[ firstElement + 5 ]["value"],
				statusChanged[ firstElement + 6 ]["name"], statusChanged[ firstElement + 6 ]["value"],
				statusChanged[ firstElement + 7 ]["name"], statusChanged[ firstElement + 7 ]["value"],
				statusChanged[ firstElement + 8 ]["name"], statusChanged[ firstElement + 8 ]["value"],
				statusChanged[ firstElement + 9 ]["name"], statusChanged[ firstElement + 9 ]["value"]
				);
				
				// We only wait if we need to send another set of variables to this client
				if ( (cycle+1) < sendCycles ) {
					xwait( 0.1, false );
				}
			}

		//	iprintln("---------------ATUALIZANDO PLAYERS VIVOS END-----------------");			
		}
		
		level.inupdatealiveplayers = false;
	}
}