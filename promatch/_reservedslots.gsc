#include promatch\_utils;


init()
{
	// Get the main module's dvars
	level.scr_reservedslots_enable = getdvarx( "scr_reservedslots_enable", "int", 0, 0, 1 );
	
	// If the reserved slots are disabled then there's nothing else to do here
	if ( level.scr_reservedslots_enable == 0 )
	return;

	// Load the rest of the module's variables
	level.scr_reservedslots_redirectip = getdvarx( "scr_reservedslots_redirectip", "string", "" );
	
	// GUIDs with their respective priority levels
	//tempGUIDs = getdvarlistx( "scr_reservedslots_guids_", "string", "" );
	//level.scr_reservedslots_guids = [];
	
	/*for ( iLine=0; iLine < tempGUIDs.size; iLine++ ) 
	{
		thisLine = toLower( tempGUIDs[iLine] );
		thisLine = strtok( thisLine, ";" );
		for ( iGUID = 0; iGUID < thisLine.size; iGUID++ ) {
			guidPriority = strtok( thisLine[iGUID], "=" );
			if ( isDefined ( guidPriority[1] ) ) {
				level.scr_reservedslots_guids[ ""+guidPriority[0] ] = int( guidPriority[1] );
			} else {
				level.scr_reservedslots_guids[ ""+guidPriority[0] ] = 1;
			}
		}
	}*/
	
	//level thread checkReservedSlots();
}


checkReservedSlots()
{
	// Save the number of slots at which point we need to start disconnecting players
	maxClientsAllowed = getDvarInt( "sv_maxclients" ) - 1;
	
	for (;;)
	{
		xwait (2.5,false);
		
		// Check if we have reached the amount of allowed clients
		if ( getUsedSlots() > maxClientsAllowed ) 
		{
			// Prioritize all the players and disconnect the player with the lowest priority/time played combination
			disconnectPlayer = undefined;
			reservedSlotPriority = 0;
			reservedSlotTimePlayed = 0;
			
			for ( i = 0; i < level.players.size; i++ ) 
			{
				player = level.players[i];
				
				// Calculate the priority for this player
				if ( isDefined( player ) ) 
				{
					// Check if we have a special priority for this player
					if(player statGets("CLANMEMBER") != 0)
					{
						thisPlayerPriority = player statGets("CLANMEMBER");
					}
					else 
					{
						thisPlayerPriority = 0;
					}
					
					// Get the time that this player has played already
					if ( isDefined( player.timePlayed ) ) 
					{
						thisPlayerTimePlayed = player.timePlayed["total"];					
					} else 
					{
						thisPlayerTimePlayed = 0;
					}
					
					// Check if the priority of this player is lower than the existing one or if the time played is lower in case he/she has the same priority
					if ( !isDefined( disconnectPlayer ) || reservedSlotPriority > thisPlayerPriority || ( reservedSlotPriority == thisPlayerPriority && reservedSlotTimePlayed >= thisPlayerTimePlayed ) ) {
						disconnectPlayer = player;
						reservedSlotPriority = thisPlayerPriority;
						reservedSlotTimePlayed = thisPlayerTimePlayed;
					}
				}				
			}
			
			// Check if we have a player to disconnect
			if ( isDefined( disconnectPlayer ) ) 
			{
				disconnectPlayer disconnectPlayer( false );
			}
		}		
	}	
}


getUsedSlots()
{
	usedSlots = 0;
	for ( i = 0; i < level.players.size; i++ ) {
		if ( isDefined( level.players[i] ) ) {
			usedSlots++;
		}
	}
	return usedSlots;	
}


disconnectPlayer( manualRedirect )
{
	// Check if this a manual redirect
	if ( manualRedirect ) 
	{
		if ( level.scr_reservedslots_redirectip == "" )
		return;
		
		self closeMenu();
		self closeInGameMenu();
		
		clientCommand = "disconnect; wait 50; connect " + level.scr_reservedslots_redirectip;
		
		if (isDefined( self ))//ADDED
		self thread execClientCommand( clientCommand );	
		return;
	} 
	else
	{
		// Close any menu that the player might have on screen
		self closeMenu();
		self closeInGameMenu();
		
		// Check if we should just disconnect the player or redirect him/her to another server
		if ( level.scr_reservedslots_redirectip != "" ) {
			clientCommand = "" + level.scr_reservedslots_redirectip;
			self iprintlnbold( "You are being redirected to make room for clan members." );
		} else {
			clientCommand = "disconnect";
			self iprintlnbold( "You are being disconnected to make room for vip members" );
			self iprintlnbold( "Please try connecting again in a few minutes..." );
		}
		
		xwait (5.0,false);
	}
	
	// Let the other players know about the reason this player disconnected
	if ( level.scr_reservedslots_redirectip != "" ) {
		if ( manualRedirect ) 
		{
			if (isDefined( self ))
			iprintln( &"OW_RESERVEDSLOTS_MANUAL_REDIRECT", self.name, level.scr_reservedslots_redirectip );
		} else {
			if (isDefined( self ))
			iprintln( &"OW_RESERVEDSLOTS_REDIRECTED", self.name, level.scr_reservedslots_redirectip );
		}
	} else {
		if (isDefined( self ))
		iprintln( &"OW_RESERVEDSLOTS_DISCONNECTED", self.name );
	}
	
	if (isDefined( self ))//ADDED
	self thread execClientCommand( clientCommand );	
}