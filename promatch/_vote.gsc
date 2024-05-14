/***************************************************************************
Map Vote Menu Mod
Created by |UzD|GaZa
Site / Support: http://www.uzd-zombies.com/viewtopic.php?f=29&t=33
-Modded by EncryptorX 2019
**************************************************************************/
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include promatch\_utils;
init()
{
	
	//if(level.players.size < 2)
	//return;
	
	/******************************RUN VOTE MOD********************************************************************/
	startvotesystem();
	
	level.vote_customname =  getDvar( "vote_customname" );
	level.vote_custommap = getDvar( "vote_custommap" );
	level.vote_customgtype = getDvar( "vote_customgtype" );
	level.vote_custommaplist = getDvar( "vote_custommaplist" );
	
	if(level.vote_custommaplist == "")	
	level.vote_custommaplist = "mp_killhouse,strike,crash,crossfire,backlot,vacant,citystreets,broadcast,mp_pipeline";
	
	if(level.vote_customname == "")
	level.vote_customname = "VAZIO";
	if(level.vote_customgtype == "")
	level.vote_customgtype = "dm";
	
	
	
	/***************************************************************************************************************/
}

startvotesystem()
{	
	maps = undefined;
	gametypes = undefined;
	votetime = undefined;
	winnertime = undefined;	
	standalone = true;
	
	votetime = 14; //Time available to vote
	
	winnertime = 5.0; //Time the winning map is displayed for
	
	/**********INIT CHECKS************************************************************/
	level.inVote = undefined;//Undefined here to catch errors later relating to non-standalone
	
	if(!isDefined(standalone))
		standalone = true;//Default to true
		
	if(!isDefined(votetime) || (isDefined(votetime) && votetime < 0))
		votetime = 0;
		
	if(!isDefined(winnertime) || (isDefined(winnertime) && winnertime < 0))
		winnertime = 0;
	
	//if(isDefined(level.newmapoverride))
	//return;
	
	//Do not run if the vote times exceed 30 seconds for a dedicated server.
	if((votetime + winnertime > 30) && standalone)
	{
		logPrint("VoteMod: Not loaded, dedicated server vote times exceed 30 seconds. Check scripts\vote.gsc\n");
		return;
	}
	else if(!votetime || !winnertime)
	{
		logPrint("VoteMod: Not loaded, no/incorrect vote times given.  Check scripts\vote.gsc\n");
		return;
	}
	else
		logPrint("VoteMod: Loaded Successfully.\n");
	/****************************************************************************/
	
	//if(level.cod_mode == "torneio")
	//votetime = 7.0;

	level.VoteVoteTime = int(votetime); //Time available to vote
	level.VoteWinnerTime = int(winnertime); //Time the winning map is displayed for

	level.quadros = 10;
	
	/****METHODS************************************************************/
	CreateStockMapArray();//Add stock iw4x maps
	
	level thread monitorIntermission();//Wait for intermission to start before injecting vote mod- Standalone (e.g no gamelogic.gsc)
	/****************************************************************************/
	
	/*****DEFINE MENU************************************************************/
	
	/****************************************************************************/
	
	/*****SETUP VOTE MAPS************************************************************/
	level.inVote = false;
	level.VotePosition = undefined;
	
	/***************************************************************************/
}

CreateStockMapArray()
{
	level.iw4xmaps = [];
	
	level.iw4xmaps["broadcast"] = [];
	level.iw4xmaps["broadcast"]["localised_name"] = "Broadcast";
	level.iw4xmaps["broadcast"]["preview_name"] = "mp_broadcast";
	level.iw4xmaps["broadcast"]["zone_name"] = "mp_broadcast";

	level.iw4xmaps["canalbf3"] = [];
	level.iw4xmaps["canalbf3"]["localised_name"] = "CANAL BF3[GRANDE] ";
	level.iw4xmaps["canalbf3"]["preview_name"] = "mp_canal_bf3";
	level.iw4xmaps["canalbf3"]["zone_name"] = "mp_canal_bf3";
	
	level.iw4xmaps["bloc"] = [];
	level.iw4xmaps["bloc"]["localised_name"] = "Bloc";
	level.iw4xmaps["bloc"]["preview_name"] = "mp_bloc";
	level.iw4xmaps["bloc"]["zone_name"] = "mp_bloc";
	
	level.iw4xmaps["crash"] = [];
	level.iw4xmaps["crash"]["localised_name"] = "Crash";
	level.iw4xmaps["crash"]["preview_name"] = "mp_crash";
	level.iw4xmaps["crash"]["zone_name"] = "mp_crash";
	
	level.iw4xmaps["crash3"] = [];
	level.iw4xmaps["crash3"]["localised_name"] = "Crash3";
	level.iw4xmaps["crash3"]["preview_name"] = "mp_crash3";
	level.iw4xmaps["crash3"]["zone_name"] = "mp_crash3";
	
	level.iw4xmaps["crossfire"] = [];
	level.iw4xmaps["crossfire"]["localised_name"] = "Crossfire";
	level.iw4xmaps["crossfire"]["preview_name"] = "mp_crossfire";
	level.iw4xmaps["crossfire"]["zone_name"] = "mp_crossfire";
	
	level.iw4xmaps["hardhat"] = [];
	level.iw4xmaps["hardhat"]["localised_name"] = "Hardhat[MW3]";
	level.iw4xmaps["hardhat"]["preview_name"] = "mp_mw3_hardhat";
	level.iw4xmaps["hardhat"]["zone_name"] = "mp_mw3_hardhat";
	
	level.iw4xmaps["strike"] = [];
	level.iw4xmaps["strike"]["localised_name"] = "Strike";
	level.iw4xmaps["strike"]["preview_name"] = "mp_strike";
	level.iw4xmaps["strike"]["zone_name"] = "mp_strike";
	
	level.iw4xmaps["summit"] = [];
	level.iw4xmaps["summit"]["localised_name"] = "Summit[BO]";
	level.iw4xmaps["summit"]["preview_name"] = "mp_summit";
	level.iw4xmaps["summit"]["zone_name"] = "mp_summit";
	
	level.iw4xmaps["nuketown"] = [];
	level.iw4xmaps["nuketown"]["localised_name"] = "Nuketown[BO]";
	level.iw4xmaps["nuketown"]["preview_name"] = "mp_nuketown";
	level.iw4xmaps["nuketown"]["zone_name"] = "mp_nuketown";
	
	level.iw4xmaps["vacant"] = [];
	level.iw4xmaps["vacant"]["localised_name"] = "Vacant1";
	level.iw4xmaps["vacant"]["preview_name"] = "mp_vacant";
	level.iw4xmaps["vacant"]["zone_name"] = "mp_vacant";
	
	level.iw4xmaps["backlot"] = [];
	level.iw4xmaps["backlot"]["localised_name"] = "Backlot";
	level.iw4xmaps["backlot"]["preview_name"] = "mp_backlot";
	level.iw4xmaps["backlot"]["zone_name"] = "mp_backlot";
	
	level.iw4xmaps["citystreets"] = [];
	level.iw4xmaps["citystreets"]["localised_name"] = "Citystreets";
	level.iw4xmaps["citystreets"]["preview_name"] = "mp_citystreets";
	level.iw4xmaps["citystreets"]["zone_name"] = "mp_citystreets";
	
	level.iw4xmaps["pipeline"] = [];
	level.iw4xmaps["pipeline"]["localised_name"] = "Pipeline";
	level.iw4xmaps["pipeline"]["preview_name"] = "mp_pipeline";
	level.iw4xmaps["pipeline"]["zone_name"] = "mp_pipeline";
	
	level.iw4xmaps["killhouse"] = [];
	level.iw4xmaps["killhouse"]["localised_name"] = "Killhouse";
	level.iw4xmaps["killhouse"]["preview_name"] = "mp_killhouse";
	level.iw4xmaps["killhouse"]["zone_name"] = "mp_killhouse";
	
	level.iw4xmaps["mirage"] = [];
	level.iw4xmaps["mirage"]["localised_name"] = "Mirage[CSGO]";
	level.iw4xmaps["mirage"]["preview_name"] = "mp_csgo_mirage";
	level.iw4xmaps["mirage"]["zone_name"] = "mp_csgo_mirage";
	
	level.iw4xmaps["inferno"] = [];
	level.iw4xmaps["inferno"]["localised_name"] = "Inferno[CSGO]";
	level.iw4xmaps["inferno"]["preview_name"] = "mp_csgo_inferno";
	level.iw4xmaps["inferno"]["zone_name"] = "mp_csgo_inferno";
	
	level.iw4xmaps["office"] = [];
	level.iw4xmaps["office"]["localised_name"] = "Office[CSGO]";
	level.iw4xmaps["office"]["preview_name"] = "mp_csgo_office";
	level.iw4xmaps["office"]["zone_name"] = "mp_csgo_office";
	
	level.iw4xmaps["lake"] = [];
	level.iw4xmaps["lake"]["localised_name"] = "Lake[CSGO]";
	level.iw4xmaps["lake"]["preview_name"] = "mp_efa_lake";
	level.iw4xmaps["lake"]["zone_name"] = "mp_efa_lake";

	level.iw4xmaps["toujane"] = [];
	level.iw4xmaps["toujane"]["localised_name"] = "Toujane[COD2]";
	level.iw4xmaps["toujane"]["preview_name"] = "mp_toujane_snow";
	level.iw4xmaps["toujane"]["zone_name"] = "mp_toujane_snow";
	
	//02.04.23
	level.iw4xmaps["Alcatraz"] = [];
	level.iw4xmaps["alcatraz"]["localised_name"] = "Alcatraz[GRANDE]";
	level.iw4xmaps["alcatraz"]["preview_name"] = "mp_mtl_the_rock";
	level.iw4xmaps["alcatraz"]["zone_name"] = "mp_mtl_the_rock";
	
	level.iw4xmaps["Highrise"] = [];
	level.iw4xmaps["highrise"]["localised_name"] = "Highrise[MW2]";
	level.iw4xmaps["highrise"]["preview_name"] = "mp_highrise";
	level.iw4xmaps["highrise"]["zone_name"] = "mp_highrise";
	
	level.iw4xmaps["cc"] = [];
	level.iw4xmaps["cc"]["localised_name"] = "CC";
	level.iw4xmaps["cc"]["preview_name"] = "mp_cc";
	level.iw4xmaps["cc"]["zone_name"] = "mp_cc";
	
	level.iw4xmaps["oukhta"] = [];
	level.iw4xmaps["oukhta"]["localised_name"] = "Oukhta";
	level.iw4xmaps["oukhta"]["preview_name"] = "mp_oukhta";
	level.iw4xmaps["oukhta"]["zone_name"] = "mp_oukhta";
	
	level.iw4xmaps["castle"] = [];
	level.iw4xmaps["castle"]["localised_name"] = "Castle[COD5]";
	level.iw4xmaps["castle"]["preview_name"] = "mp_castle_v1";
	level.iw4xmaps["castle"]["zone_name"] = "mp_castle_v1";
	
	level.iw4xmaps["rasalem"] = [];
	level.iw4xmaps["rasalem"]["localised_name"] = "Rasalem";
	level.iw4xmaps["rasalem"]["preview_name"] = "mp_rasalem";
	level.iw4xmaps["rasalem"]["zone_name"] = "mp_rasalem";
	
	level.iw4xmaps["scrap"] = [];
	level.iw4xmaps["scrap"]["localised_name"] = "Scrapyard[MW2]";
	level.iw4xmaps["scrap"]["preview_name"] = "mp_mw2_boneyard";
	level.iw4xmaps["scrap"]["zone_name"] = "mp_mw2_boneyard";
	
	//10.04.23
	level.iw4xmaps["skidrow"] = [];
	level.iw4xmaps["skidrow"]["localised_name"] = "Skidrow[MW2]";
	level.iw4xmaps["skidrow"]["preview_name"] = "mp_skidrow";
	level.iw4xmaps["skidrow"]["zone_name"] = "mp_skidrow";
	
	level.iw4xmaps["derail"] = [];
	level.iw4xmaps["derail"]["localised_name"] = "Derail[MW2]";
	level.iw4xmaps["derail"]["preview_name"] = "mp_derail";
	level.iw4xmaps["derail"]["zone_name"] = "mp_derail";
	
	level.iw4xmaps["derail"] = [];
	level.iw4xmaps["derail"]["localised_name"] = "Derail[MW2]";
	level.iw4xmaps["derail"]["preview_name"] = "mp_derail";
	level.iw4xmaps["derail"]["zone_name"] = "mp_derail";
	
	level.iw4xmaps["quarry"] = [];
	level.iw4xmaps["quarry"]["localised_name"] = "Quarry[MW2]";
	level.iw4xmaps["quarry"]["preview_name"] = "mp_mw2_quarry";
	level.iw4xmaps["quarry"]["zone_name"] = "mp_mw2_quarry";
	
	level.iw4xmaps["lookout"] = [];
	level.iw4xmaps["lookout"]["localised_name"] = "Lookout[MW3]";
	level.iw4xmaps["lookout"]["preview_name"] = "mp_mw3_lookout";
	level.iw4xmaps["lookout"]["zone_name"] = "mp_mw3_lookout";
	
	level.iw4xmaps["seatown"] = [];
	level.iw4xmaps["seatown"]["localised_name"] = "Seatown[MW3]";
	level.iw4xmaps["seatown"]["preview_name"] = "mp_seatown";
	level.iw4xmaps["seatown"]["zone_name"] = "mp_seatown";
	
	
	level.iw4xmaps["dust2"] = [];
	level.iw4xmaps["dust2"]["localised_name"] = "Dust2[CSGO]";
	level.iw4xmaps["dust2"]["preview_name"] = "mp_dust2";
	level.iw4xmaps["dust2"]["zone_name"] = "mp_dust2";	
	
	
	
	
	

}
//"mp_convoy;mp_backlot;mp_bloc;mp_bog;mp_broadcast;mp_carentan;mp_countdown;mp_crash;mp_creek;mp_crossfire;mp_citystreets;mp_farm;
//mp_killhouse;mp_overgrown;mp_pipeline;mp_shipment;mp_showdown;mp_strike;mp_cargoship;mp_crash_snow;mp_vacant"
StartMapMenuCreation()
{
	gametypes = "";
	level.quadros = 10;
	
	if(getdvarint("scr_eventorodando") == 1 && isDefined(level.eventohorario) && level.eventohorario != "")
	{		
		gametypes = "kc,crnk,dom,ctf";		
	}	
	else
	{		

		gametypes = "";
		gametypes = "sd";
		
		if(level.cod_mode == "torneio")
		{
			gametypes = "";
			gametypes = "sd,dm,ass";
		}
	}  

	/******************MAPS*******************************/
	level.mapTok = [];//Store Vote Maps
	level.mapVotes = [];//Store Votes for each map
	level.voteMaps = "";
	level.voteMaps = level.vote_custommaplist;
	
	//se vazio completar com Stocks
	if(level.voteMaps == "")
	{
		stockmaps = getArrayKeys( level.iw4xmaps );	
		for(i=0;i<stockmaps.size;i++)
		{
			level.mapTok[i] = stockmaps[i];
			//logDebug("votemap","iw4xmaps->" + level.mapTok[i]);
		}
		
		
		
		//logerror("Votemap: Lista vazia");
		logPrint("Vote Mod: No maps specified in vote.gsc, setting to default.\n");
	}
	else if(strTok( level.voteMaps, "," ).size < level.quadros)//If the user has entered maps although under 9 add some from stock iw4x.
	{
		level.mapTok = strTok( level.voteMaps, "," );
		
		stockmaps = getArrayKeys( level.iw4xmaps );
		for(i=level.mapTok.size;i < level.quadros;i++)
		{
			
			level.mapTok[i] = stockmaps[i];
		}
			
		logPrint("Vote Mod: Not enough maps specified in vote.gsc, adding some default maps.\n");
	}
	else//As above 9 maps entered use the sv_votemaps
	{
		level.mapTok = strTok( level.voteMaps, "," );
		//logDebug("votemap","maps9->" + level.mapTok[i]);
	}
	
    randomArray = [];
    for(i = 0; i < level.quadros; i++)
	{
		selectedRand = randomintrange(0, level.mapTok.size);
        randomArray[i] = level.mapTok[selectedRand];
        level.mapTok = restructMapArray(level.mapTok, selectedRand);
    }
	
    level.mapTok = randomArray;
	for( i=0; i < level.mapTok.size; i++ )
	{
		level.mapVotes[i] = 0;
	}
	/****************************************************************************/
	
	/**********************GAME MODES********************************************/		
	level.votegametypes = "";
	level.votegametypes = gametypes;
	
	//logteste(level.votegametypes);
	
	if(level.votegametypes != "")
	{
		level.gamemodeTok = [];
		level.gamemodeTok = strTok( level.votegametypes, "," );
		
		randomGametypeArray = [];
		for(i=0;i < level.quadros;i++)
		{
			randomGametypeArray[i] = level.gamemodeTok[randomintrange(0,level.gamemodeTok.size)];
			
			//logDebug("votemap","votegametypes->" + randomGametypeArray[i]);
		}
		level.gamemodeTok = randomGametypeArray;
	}
	else//If the user hasn't entered any game modes into 'sv_gametypes' just use g_gametype
		return;
}

monitorIntermission()//Standalone
{
	level waittill ( "intermission" );
	
	if ( level.scr_eog_fastrestart == 1 )
	return;
	
	if(getdvarint("setnextmap") == 1) 
	return;	
	
	setDvar("sv_maprotation","");
	setDvar("sv_maprotationCurrent","");
	
	//server  cria lista de mapas aqui!
	StartMapMenuCreation();
	
	players = level.players;

	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		if ( !isDefined( player.connected ) )//teste !!!
		continue;
		
		player thread onMenuResponse();
		
		player thread playerInitVote();
		
		player setClientDvar( "vote_customname",level.vote_customname);
	}

	//para o sv apenas!
	BeginVoteForMatch();
}

VoteTimerAndText(text, countDown)
{
	level notify("newVoteText");
	level endon("newVoteText");
	
	while(countDown)
	{
		players = level.players;
		
		for ( index = 0; index < players.size; index++ )
		{
			player = players[index];
			player setClientDvar( "hud_voteText",  (text+" (" + countDown + "s):"));
			player playLocalSound( "timer1" );
		}
	
		wait 1;
		countDown--;
		
	}
}

BeginVoteForMatch()
{

	if(!isDefined(level.inVote))//Error in scripts/vote.gsc do not continue
		return;
	
	//Begin Vote
	level.inVote = true;
	level.VotePosition = "voting";
	
	updateVoteDisplayForPlayers();
	
	players = level.players;
	
	for ( index = 0; index < players.size; index++ )
	{
		if(!isDefined(players[index])) continue;
		
		player = players[index];
		
		player thread StartVoteForPlayer();
	}
	
	/*******Timer 1- Vote for new map*************************************/
	VoteTimerAndText("^3Vote para o prox mapa",level.VoteVoteTime);
	
	level notify( "time_over" );//End any further voting
	
	SetFinalVoteMap();//Set next map from votes / Randomised for no votes/players
	/*********************************************************************/
		
	level.VotePosition = "winner";

	
	for ( index = 0; index < players.size; index++ )
	{
		if(!isDefined(players[index])) continue;
		
		player = players[index];		
		player closeMenu( game["menu_vote"] );
		player setClientDvar( "ui_inVote", "0" );		
		//utilizar baseado no numero de quadros
		//player setClientDvar( "hud_Quadros", "0" );
	}
	/*********************************************************************/
	
	for ( index = 0; index < players.size; index++ )
	{
		if(!isDefined(players[index])) continue;
		
		player = players[index];
	
		if(player.sessionstate != "intermission")
		player.sessionstate = "intermission";
	}
	
	//End Vote
	level.inVote = false;
	level.VotePosition = undefined;
}

StartVoteForPlayer()
{
	self endon("disconnect");

	if(!isDefined(self))
	return;
	
	//Hide Intermission
	if(!isDefined(self.sessionstate))
		self.sessionstate = "spectator";
		
	if(self.sessionstate != "spectator")
		self.sessionstate = "spectator";
		
	self freezeControls( true );
	self closeMenu();
	self closeInGameMenu();
	
	//Dvars
	//usado para mostrar os mapas na tela
	//self setClientDvar( "hud_Quadros", level.quadros );	
	//self setClientDvar( "ui_inVote", "1" );
	
	self setClientDvars("ui_inVote", 1,
	"ui_stat_bestname", getDvar("sv_bestname"));
	
	/*,
	"ui_Medal1", getDvar("sv_medal1"),
	"ui_Medal2", getDvar("sv_medal2"),
	"ui_Medal3", getDvar("sv_medal3"),
	"ui_Medal4", getDvar("sv_medal4"),
	"ui_Medal5", getDvar("sv_medal5"),
	"ui_Medal6", getDvar("sv_medal6"),
	"ui_Medal7", getDvar("sv_medal7"),
	"ui_Medal8", getDvar("sv_medal8"),
	"ui_Medal9", getDvar("sv_medal9"),
	"ui_Medal10", getDvar("sv_medal10"));*/
		
	
	self openMenu("vote");
	
	//Threads
	self thread onDisconnect();
}


getMapVoteName( InputMap )
{
	map = tolower(InputMap);//Make lower case
	
	if(isDefined(level.iw4xmaps[map]))//In game map e.g "Terminal"
		return level.iw4xmaps[map]["zone_name"];
	else//Custom map e.g mp_waw_castle
		return map;
}

getPreviewName( InputMap )
{
	return "custom_map";
}

getLocalisedName( InputMap )
{
	map = tolower(InputMap);//Make lower case
	
	if(isDefined(level.iw4xmaps[map]))//In game map e.g "Terminal"
		return level.iw4xmaps[map]["localised_name"];
	else//Custom map e.g mp_waw_castle
		return map;
}

getGameTypeName( num )
{
	switch(level.gamemodeTok[num])
	{
		case "sd":
			gamemode = "Search and Destroy";
			break;
			
		case "dm":
		gamemode = "Free for All";
		break;

		case "ass":
		gamemode = "Assassination";
		break;

		case "ctf":
		gamemode = "Capture the Flag";
		break;		
		
		case "dom":
		gamemode = "Domination";
		break;
		
		case "war":
		gamemode = "Team Deathmatch";
		break;

		default:
			gamemode = "Search and Destroy";
	}
	
	return gamemode;
}

//para o jogador
playerInitVote()
{
	self endon("disconnect");

	self setClientDvar( "ui_inVote", "0" );
	self setClientDvar( "ui_selected_vote", "" );
	
	randominfo = randomInt(15);
	self setClientDvar( "hud_voteTextinfos", level.votemenuinfos[randominfo] );
	
	//Joined late
	if(level.inVote && isDefined(level.VotePosition))
	{	
		if(level.VotePosition == "voting")
		{
			wait 0.5;//era 1
			updateVoteDisplayForPlayers(0);
			self StartVoteForPlayer();
		}
		else if(level.VotePosition == "winner")
		{
			wait 0.5;
			winNumberA = getHighestVotedMap();
			
			self StartVoteForPlayer();
			
			self setClientDvar( "hud_voteText", "^3Prox Map:" );
			self setClientDvar( "hud_Quadros", level.quadros );
			
			//if(!isDefined(level.gamemodeTok))
			//	MapNameLoc = ("^3" + getLocalisedName(level.mapTok[winNumberA]));
			//else
			//	MapNameLoc = ("^3" + getLocalisedName(level.mapTok[winNumberA]) + " - " + getGameTypeName(winNumberA));
		}
	}
}

onMenuResponse()
{
    self endon("disconnect");

    for(;;)
    {
        self waittill("menuresponse", menu, response);
		
		if(level.VoteVoteTime < 4) return;
		
		if(menu == game["menu_vote"] && level.inVote)//Prevent Early Voting
        {
			switch(response)
			{
				case "map1":
					self castMap(0);
					break;
				case "map2":
					self castMap(1);
					break;
				case "map3":
					self castMap(2);
					break;					
				case "map4":
					self castMap(3);
					break;
				case "map5":
					self castMap(4);
					break;
				case "map6":
					self castMap(5);
					break;
				case "map7":
					self castMap(6);
					break;
				case "map8":
					self castMap(7);
					break;
				case "map9":
					self castMap(8);//killhouse1
					break;
				case "map10":
					if(level.vote_customname != "VAZIO")
					self castMap(9);//outro
					break;
					
				default:
					break;
			}
        }
		if(response == "back" && level.inVote)//Re open vote menu after closing other menu
			self openMenu("vote");
	}
}

restructMapArray(oldArray, index)
{
   restructArray = [];
	for( i=0; i < oldArray.size; i++) {
		if(i < index) 
			restructArray[i] = oldArray[i];
		else if(i > index) 
			restructArray[i - 1] = oldArray[i];
	}
	return restructArray;
}

updateVoteDisplayForPlayers(nmb)
{
	players = level.players;
	
	if(!isDefined(nmb))
	nmb = 0;///cast number = btn number - 8 9 DM
	
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		player setClientDvar("hud_gamesize", level.players.size);
		
		for(i=0; i < level.mapTok.size; i++) 
		{
			//getLocalisedName-> Mirage			
			//logDebug("votemap","getLocalisedName-> " + getLocalisedName(level.mapTok[i]));
			//mapTok-> mirage					
			//logDebug("votemap","mapTok-> " + level.mapTok[i]);
			
			//atualizaria as fotos de cada 
			//player setClientDvar(("hud_picName"+i), getPreviewName(level.mapTok[i]));
			
			//atualiza os nomes dos maps nos quadros
			player setClientDvar(("hud_mapName"+i), getLocalisedName(level.mapTok[i]));
			
			if(!isDefined(level.gamemodeTok))
				GameTypeLocVotes = level.mapVotes[i];
			else
				GameTypeLocVotes = (getGameTypeName(i) + " - " + level.mapVotes[i]);
			

			//limpa os votos de cada botao
			if("hud_smapVotes"+i == "hud_smapVotes8")
			player setClientDvar(("hud_smapVotes"+i),"DM ("+ level.mapVotes[i]+")"  );
			
			if("hud_smapVotes"+i == "hud_smapVotes9")
			player setClientDvar(("hud_smapVotes"+i),level.vote_customgtype +" ("+ level.mapVotes[i]+")"  );
			
			player setClientDvar(("hud_mapVotes"+i), GameTypeLocVotes);
			
			
			if(level.mapVotes[i] != 0)
			{				
				if(!isDefined(level.gamemodeTok))
					GameTypeLocVotes = ("^3"+level.mapVotes[getHighestVotedMap()]);
				else
					GameTypeLocVotes = ("^3" + getGameTypeName(getHighestVotedMap()) + " - " + level.mapVotes[getHighestVotedMap()]);
				
				//GameTypeLocVotes-> ^3Search and Destroy - 1
				//logDebug("votemap","GameTypeLocVotes-> " + GameTypeLocVotes);
				
				//logDebug("votemap","hud_smapVotesHighestVotedMap-> " + getHighestVotedMap()); //9 = botao?			
				
				//atualiza o contador de cada botao com os votos nele
				if("hud_smapVotes"+i == "hud_smapVotes8")
				player setClientDvar(("hud_smapVotes"+getHighestVotedMap()),"DM ("+ level.mapVotes[getHighestVotedMap()]+")"  );
				
				if("hud_smapVotes"+i == "hud_smapVotes9")
				player setClientDvar(("hud_smapVotes"+getHighestVotedMap()),level.vote_customgtype +" ("+ level.mapVotes[getHighestVotedMap()]+")"  );				
				
				player setClientDvar(("hud_mapVotes"+getHighestVotedMap()),GameTypeLocVotes );
				player setClientDvar(("hud_mapName"+getHighestVotedMap()), ("^3"+getLocalisedName(level.mapTok[getHighestVotedMap()])));
						
			
			}	
		}
	}
}


getHighestVotedMap()
{
	highest = 0;

	position = randomInt(level.mapVotes.size);
	
	for(i=0; i < level.mapVotes.size; i++ ) 
	{
		if( level.mapVotes[i] > highest ) 
		{
			highest = level.mapVotes[i];
			position = i;
		}
	}		

	return position;
}

//aqui podemos ver quem votou em qual mapa!
//vem do menu  !!
castMap( number )
{

	//8 e 0 = DM BTN
	
	//limita o clickar do vote!
	if(isDefined(self.voteclick) && self.voteclick > 4)
	return;
	
	if(isDefined(self.pers["ping"]) && self.pers["ping"] > 120)
	return;
	
	if(level.VoteVoteTime < 4) return;
	
	if( !isDefined(self.hasVoted) || !self.hasVoted ) 
	{
		self.voteclick++;
		self.hasVoted = 1;
		level.mapVotes[number]++;
		self.votedNum = number;
		
		
		
		updateVoteDisplayForPlayers(number);
		
		//if(!isDefined(level.gamemodeTok))
				//MapNameLoc = getLocalisedName(level.mapTok[self.votedNum]);
			//else
				//MapNameLoc = (getLocalisedName(level.mapTok[self.votedNum]) + " - " + getGameTypeName(self.votedNum));
				
		//level.mapVotes[i]-> 1
		//castMap2-> 1 == 1 VOTO
		//castMap2-> 9 == no BOTAO 9
		//logDebug("votemap","castMap1-> " + level.mapVotes[number]);
		//logDebug("votemap","castMap1-> " + self.votedNum);
		
	}
	else if( self.hasVoted && isDefined( self.votedNum ) && self.votedNum != number )//em outro botao
	{
		self.voteclick++;
		level.mapVotes[self.votedNum]--;
		level.mapVotes[number]++;
		self.votedNum = number;
		
		updateVoteDisplayForPlayers(number);
		
		//if(!isDefined(level.gamemodeTok))
				//MapNameLoc = getLocalisedName(level.mapTok[self.votedNum]);
		//	else
			//	MapNameLoc = (getLocalisedName(level.mapTok[self.votedNum]) + " - " + getGameTypeName(self.votedNum));
		
		//logDebug("votemap","castMap2hasVoted-> " + level.mapVotes[number]);	
		//logDebug("votemap","castMap2hasVoted-> " + level.mapVotes[number]);
		//logDebug("votemap","castMap2hasVoted-> " + self.votedNum);
	}
}

onDisconnect()
{
	level endon ( "time_over" );
	self waittill ( "disconnect" );
	
	if(level.inVote && isDefined(level.VotePosition))//Remove players vote & update player count for all
	{
		if ( isDefined( self.votedNum ) ) 
			level.mapVotes[self.votedNum]--;
		if (level.VotePosition == "voting")
			updateVoteDisplayForPlayers(0);
	}
}

SetFinalVoteMap()
{
	winNumberA = randomInt(level.mapTok.size);
	
	level.RandomMap = level.mapTok[winNumberA];  
	level.winMap = getMapVoteName( level.RandomMap );

	if( level.players.size > 0 )
	{
		winNumberA = getHighestVotedMap();//numero do botao mais votado
		level.winMap = getMapVoteName( level.mapTok[winNumberA] );//nome do map

		players = level.players;
	
		for ( index = 0; index < players.size; index++ )
		{
			player = players[index];
						
			//if(!isDefined(level.gamemodeTok))
			//	MapNameLoc = ("^3" + getLocalisedName(level.mapTok[winNumberA]));
			//else
			//	MapNameLoc = ("^3" + getLocalisedName(level.mapTok[winNumberA]) + " - " + getGameTypeName(winNumberA));
			
			//if(isDefined(level.mapVotes) && level.mapVotes.size > 1 && (winNumberA == 8 || winNumberA == 9))
			//player setClientDvar(("ui_gametype"), "dm");
			//else
			player setClientDvar(("ui_gametype"), level.gamemodeTok[winNumberA]);
		}
	}
	//logDebug("votemap","level.winMap-> " + level.winMap);
	//logDebug("votemap","winNumberA-> " + winNumberA);
	//ShowDebug("SetFinalVoteMap1",level.winMap);
	//ShowDebug("SetFinalVoteMap2",level.gamemodeTok[winNumberA] );
	
	if(level.mapVotes.size > 0 && level.mapVotes.size >= 1 && (winNumberA == 8 || winNumberA == 9))
	{
		if(winNumberA == 8)
		{
			setDvar("sv_maprotation", "gametype dm" + " map mp_killhouse");
			setDvar("sv_maprotationCurrent", "gametype dm" +  " map  mp_killhouse");
		}
		
		if(winNumberA == 9)
		{
			setDvar("sv_maprotation", "gametype " + level.vote_customgtype + " map " + level.vote_custommap);
			setDvar("sv_maprotationCurrent", "gametype "+ level.vote_customgtype +  " map "+ level.vote_custommap);
		}
	}
	else
	{
			//nao votar em modo custom
			if(level.gamemodeTok[winNumberA] == "ass" || level.gamemodeTok[winNumberA] == "gg")
			level.gamemodeTok[winNumberA] = "sd";
		
			setDvar("sv_maprotation", "gametype " + level.gamemodeTok[winNumberA] + " map "+level.winMap);
			setDvar("sv_maprotationCurrent", "gametype " + level.gamemodeTok[winNumberA] + " map "+level.winMap);
		
	}
	
}