#include promatch\_utils;
//V104
init()
{	
	// Do not thread these initializations
	//promatch\_eventmanager::eventManagerInit(); -> Globallogic [EVENTS TREADS]
	
	removeStationaryTurrets();
		
	thread promatch\_playercard::init();
	
	thread promatch\_playerdvars::init();	
	thread promatch\_vote::init();
	thread promatch\_advancedacp::init();
	thread promatch\_leadermenu::init();
	thread promatch\_keybinds::init();
	thread promatch\_livebroadcast::init();	
	
	thread promatch\_globalchat::init();		
    thread promatch\_dynamicattachments::init();
	thread promatch\_killingspree::init();	
	
	thread promatch\_scoresystem::init();
	thread promatch\_ranksystem::init();
	
	thread promatch\_medic::init();	
	thread promatch\_realtimestats::init();
	thread promatch\_tactical_insertion::init();
	thread promatch\_rsmonitor::init();
	thread promatch\_killtriggers::init();
	thread promatch\_timer::init();//usado em utils nades
	thread promatch\_guidcs::init();
	thread promatch\_reservedslots::init();
	thread promatch\_dvarmonitor::init();	
	thread promatch\_paindeathsounds::init();
	thread promatch\_carepackage::init();
	thread promatch\_dogtags::init();	
	thread promatch\_fieldorders::init();
	
	//thread promatch\_thermal::init();
	
	//thread promatch\_saveclass::init();
	
	//talvez mudar para o top
	//if(level.atualgtype != "sd")
	//{
		thread promatch\_predator::init();
		maps\mp\_helicopter::init();
		maps\mp\_nuke::init();		 
	//} 
}

initGametypesAndMaps()
{
	// ********************************************************************
	// WE DO NOT USE LOCALIZED STRINGS TO BE ABLE TO USE THEM IN MENU FILES
	// ********************************************************************
	
	// Load all the gametypes we currently support
	level.supportedGametypes = [];
	level.supportedGametypes["ass"] = "Assassination";
	level.supportedGametypes["gg"] = "Gun Game";
	level.supportedGametypes["ctf"] = "Capture the Flag";
	level.supportedGametypes["dm"] = "Free for All";
	level.supportedGametypes["dom"] = "Domination";
	level.supportedGametypes["sd"] = "Search and Destroy";
	level.supportedGametypes["war"] = "COD Arena";

	// Build the default list of gametypes
	level.defaultGametypeList = buildListFromArrayKeys( level.supportedGametypes, ";" );
	
	// Load the name of the stock maps
	level.stockMapNames = [];
	level.stockMapNames["mp_convoy"] = "Ambush";
	level.stockMapNames["mp_backlot"] = "Backlot";
	level.stockMapNames["mp_bloc"] = "Bloc";
	level.stockMapNames["mp_bog"] = "Bog";
	level.stockMapNames["mp_broadcast"] = "Broadcast";
	level.stockMapNames["mp_carentan"] = "Chinatown";
	level.stockMapNames["mp_countdown"] = "Countdown";
	level.stockMapNames["mp_crash"] = "Crash";
	level.stockMapNames["mp_creek"] = "Creek";
	level.stockMapNames["mp_crossfire"] = "Crossfire";
	level.stockMapNames["mp_citystreets"] = "District";
	level.stockMapNames["mp_farm"] = "Downpour";
	level.stockMapNames["mp_killhouse"] = "Killhouse";
	level.stockMapNames["mp_overgrown"] = "Overgrown";
	level.stockMapNames["mp_pipeline"] = "Pipeline";
	level.stockMapNames["mp_shipment"] = "Shipment";
	level.stockMapNames["mp_showdown"] = "Showdown";
	level.stockMapNames["mp_strike"] = "Strike";
	level.stockMapNames["mp_vacant"] = "Vacant";
	level.stockMapNames["mp_cargoship"] = "Wet Work";
	level.stockMapNames["mp_crash_snow"] = "Winter Crash";
	
	// Build the default list of maps
	level.defaultMapList = buildListFromArrayKeys( level.stockMapNames, ";" );
	
	// Load the names of the custom maps
	customMapNamesList = getdvarlistx( "scr_custom_map_names_", "string", "" );
	
	// Load the maps into an array
	level.customMapNames = [];
	
	for ( i=0; i < customMapNamesList.size; i++ ) 
	{
		// Split the maps
		customMapNames = strtok( customMapNamesList[i], ";" );
		for ( mapix = 0; mapix < customMapNames.size; mapix++ ) {
			// Split the map file name and the desired map name
			thisMap = strtok( customMapNames[ mapix ], "=" );
			// First element is the map file name and second element is the desired map name
			level.customMapNames[ toLower( thisMap[0] ) ] = thisMap[1];
		}
	}
	
}

buildListFromArrayKeys( arrayToList, delimiter )
{
	newList = "";
	arrayKeys = getArrayKeys( arrayToList );
	
	for ( i = arrayKeys.size-1; i >= 0; i-- ) {
		if ( newList != "" ) {
			newList += delimiter;
		}
		newList += arrayKeys[i];
	}
	
	return newList;
}

removeStationaryTurrets()
{
	// Classes for turrets (this way if something new comes out we just need to add an entry to the array)
	turretClasses = [];
	turretClasses[0] = "misc_turret";
	turretClasses[1] = "misc_mg42";
	//turretClasses[2] = "tree_desertpalm01";
	
	//turretClasses[2] = "com_floodlight";

	
	destructibles = GetEntArray("worldspawn","targetname");
	models = GetEntArray("worldspawn","classname");
	for(i=0;i<destructibles.size;i++)
	{
		if(isDefined(destructibles[i]))
		for(i=0;i<models.size;i++)
		{
			if(models)
			models[i] delete();
		}
	
		destructibles[i] delete();
	}
	
	//melon = getEnt( "scr_watermelon", "targetname" )
	
	
	// Cycle all the classes used by turrets
	for ( classix = 0; classix < turretClasses.size; classix++ )
	{
		// Get an array of entities for this class
		turretEntities = getentarray( turretClasses[ classix ], "classname" );

		// Cycle and delete all the entities retrieved
		if ( isDefined ( turretEntities ) ) 
		{
			for ( turretix = 0; turretix < turretEntities.size; turretix++ ) 
			{
				turretEntities[ turretix ] delete();
			}
		}
	}

	return;
}
