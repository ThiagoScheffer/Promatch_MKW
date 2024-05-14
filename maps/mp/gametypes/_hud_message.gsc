#include maps\mp\gametypes\_hud_util;
#include promatch\_utils;

init()
{
	precacheString( &"MP_FIRSTPLACE_NAME" );
	precacheString( &"MP_SECONDPLACE_NAME" );
	precacheString( &"MP_THIRDPLACE_NAME" );
	precacheString( &"MP_MATCH_BONUS_IS" );

	game["strings"]["draw"] = &"MP_DRAW";
	game["strings"]["round_draw"] = &"MP_ROUND_DRAW";
	game["strings"]["round_win"] = &"MP_ROUND_WIN";
	game["strings"]["round_loss"] = &"MP_ROUND_LOSS";
	game["strings"]["victory"] = &"MP_VICTORY";
	game["strings"]["defeat"] = &"MP_DEFEAT";
	game["strings"]["halftime"] = &"MP_HALFTIME";
//	game["strings"]["overtime"] = &"MP_OVERTIME";
	game["strings"]["roundend"] = &"MP_ROUNDEND";
	game["strings"]["intermission"] = &"MP_INTERMISSION";
	game["strings"]["side_switch"] = &"MP_SWITCHING_SIDES";
	game["strings"]["match_bonus"] = &"MP_MATCH_BONUS_IS";
	
	level thread onPlayerConnect();
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connecting", player );//A002
		if(isdefined(player))
		{
			player thread hintMessageDeathThink();
			player thread lowerMessageThink();
			player thread initNotifyMessage();
		}
	}
}


hintMessage( hintText )
{
	notifyData = spawnstruct();
	
	notifyData.notifyText = hintText;
	notifyData.glowColor = (0.3, 0.6, 0.3);
	
	notifyMessage( notifyData );
}


initNotifyMessage()
{
	titleSize = 2.5;
	textSize = 1.75;
	iconSize = 30;
	font = "objective";
	point = "TOP";
	relativePoint = "BOTTOM";
	yOffset = 30;
	xOffset = 0;
	
	self.notifyTitle = createFontString( font, titleSize );
	self.notifyTitle setPoint( point, undefined, xOffset, yOffset );
	self.notifyTitle.glowColor = (0.2, 0.3, 0.7);
	self.notifyTitle.glowAlpha = 1;
	self.notifyTitle.hideWhenInMenu = true;
	self.notifyTitle.archived = false;
	self.notifyTitle.alpha = 0;

	self.notifyText = createFontString( font, textSize );
	self.notifyText setParent( self.notifyTitle );
	self.notifyText setPoint( point, relativePoint, 0, 0 );
	self.notifyText.glowColor = (0.2, 0.3, 0.7);
	self.notifyText.glowAlpha = 1;
	self.notifyText.hideWhenInMenu = true;
	self.notifyText.archived = false;
	self.notifyText.alpha = 0;

	self.notifyText2 = createFontString( font, textSize );
	self.notifyText2 setParent( self.notifyTitle );
	self.notifyText2 setPoint( point, relativePoint, 0, 0 );
	self.notifyText2.glowColor = (0.2, 0.3, 0.7);
	self.notifyText2.glowAlpha = 1;
	self.notifyText2.hideWhenInMenu = true;
	self.notifyText2.archived = false;
	self.notifyText2.alpha = 0;

	self.notifyIcon = createIcon( "white", iconSize, iconSize );
	self.notifyIcon setParent( self.notifyText2 );
	self.notifyIcon setPoint( point, relativePoint, 0, 0 );
	self.notifyIcon.hideWhenInMenu = true;
	self.notifyIcon.archived = false;
	self.notifyIcon.alpha = 0;

	self.doingNotify = false;
	self.notifyQueue = [];
}

oldNotifyMessage( titleText, notifyText, iconName, glowColor, sound,duration )
{
	sound = undefined;
	notifyData = spawnstruct();
	
	notifyData.titleText = titleText;
	notifyData.notifyText = notifyText;
	notifyData.iconName = iconName;
	notifyData.glowColor = glowColor;
	notifyData.sound = undefined;
	notifyData.duration = duration;

	notifyMessage( notifyData );
}

notifyMessage( notifyData )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	if ( isdefined(self.doingNotify) && !self.doingNotify )
	{
		self thread showNotifyMessage( notifyData );
		return;
	}
	
	self.notifyQueue[ self.notifyQueue.size ] = notifyData;
}


showNotifyMessage( notifyData )
{
	self endon("disconnect");
	
	self.doingNotify = true;

	waitRequireVisibility( 0 );

	if ( isDefined( notifyData.duration ) )
	duration = notifyData.duration;
	else if ( level.gameEnded )
	duration = 2.0;
	else
	duration = 5.0;
	
	self thread resetOnCancel();

	if ( isDefined( notifyData.sound ) )
	self playLocalSound( notifyData.sound );

	if ( isDefined( notifyData.leaderSound ) )
	self maps\mp\gametypes\_globallogic::leaderDialogOnPlayer( notifyData.leaderSound );
	
	if ( isDefined( notifyData.glowColor ) )
	glowColor = notifyData.glowColor;
	else
	glowColor = (0.3, 0.6, 0.3);

	anchorElem = self.notifyTitle;

	if ( isDefined( notifyData.titleText ) )
	{
		if ( isDefined( notifyData.titleLabel ) )
		self.notifyTitle.label = notifyData.titleLabel;
		else
		self.notifyTitle.label = &"";

		if ( isDefined( notifyData.titleLabel ) && !isDefined( notifyData.titleIsString ) )
		self.notifyTitle setValue( notifyData.titleText );
		else
		self.notifyTitle setText( notifyData.titleText );
		self.notifyTitle setPulseFX( 100, int(duration*1000), 1000 );
		self.notifyTitle.glowColor = glowColor;	
		self.notifyTitle.alpha = 1;
	}

	if ( isDefined( notifyData.notifyText ) )
	{
			if ( isDefined( notifyData.textLabel ) )
			self.notifyText.label = notifyData.textLabel;
			else
			self.notifyText.label = &"";
			
			if ( isDefined( notifyData.textLabel ) && !isDefined( notifyData.textIsString ) )
			self.notifyText setValue( notifyData.notifyText );
			else
			self.notifyText setText( notifyData.notifyText );
			self.notifyText setPulseFX( 100, int(duration*1000), 1000 );
			self.notifyText.glowColor = glowColor;	
			self.notifyText.alpha = 1;
			anchorElem = self.notifyText;

	}

	if ( isDefined( notifyData.notifyText2 ) )
	{
		self.notifyText2 setParent( anchorElem );
		
		if ( isDefined( notifyData.text2Label ) )
		self.notifyText2.label = notifyData.text2Label;
		else
		self.notifyText2.label = &"";
		
		self.notifyText2 setText( notifyData.notifyText2 );
		self.notifyText2 setPulseFX( 100, int(duration*1000), 1000 );
		self.notifyText2.glowColor = glowColor;	
		self.notifyText2.alpha = 1;
		anchorElem = self.notifyText2;
	}

	if ( isDefined( notifyData.iconName ) && !level.splitScreen )
	{
		self.notifyIcon setParent( anchorElem );
		self.notifyIcon setShader( notifyData.iconName, 60, 60 );
		if ( notifyData.iconName == "icon_0" )
		self.notifyIcon thread maps\mp\_nuke::rotatingNukeIcon();
		self.notifyIcon.alpha = 0;
		self.notifyIcon fadeOverTime( 1.0 );
		self.notifyIcon.alpha = 1;
		
		waitRequireVisibility( duration );

		self.notifyIcon fadeOverTime( 0.75 );
		self.notifyIcon.alpha = 0;
	}
	else
	{
		waitRequireVisibility( duration );
	}

	self notify ( "notifyMessageDone" );
	self.doingNotify = false;

	if ( self.notifyQueue.size > 0 )
	{
		nextNotifyData = self.notifyQueue[0];
		
		newQueue = [];
		for ( i = 1; i < self.notifyQueue.size; i++ )
		self.notifyQueue[i-1] = self.notifyQueue[i];
		self.notifyQueue[i-1] = undefined;
		
		self thread showNotifyMessage( nextNotifyData );
	}
}

// waits for waitTime, plus any time required to let flashbangs go away.
waitRequireVisibility( waitTime )
{
	interval = .066;
	
	while ( !self canReadText() )
	wait interval;
	
	while ( waitTime > 0 )
	{
		wait interval;
		if ( self canReadText() )
		waitTime -= interval;
	}
}


canReadText()
{
	if ( self maps\mp\_flashgrenades::isFlashbanged() )
	return false;
	
	return true;
}


resetOnDeath()
{
	self endon ( "notifyMessageDone" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	self waittill ( "death" );

	resetNotify();
}


resetOnCancel()
{
	self notify ( "resetOnCancel" );
	self endon ( "resetOnCancel" );
	self endon ( "notifyMessageDone" );
	self endon ( "disconnect" );

	level waittill ( "cancel_notify" );
	
	resetNotify();
}


resetNotify()
{
	self.notifyTitle.alpha = 0;
	self.notifyText.alpha = 0;
	self.notifyIcon.alpha = 0;
	self.doingNotify = false;
}


hintMessageDeathThink()
{
	self endon ( "disconnect" );

	for ( ;; )
	{
		self waittill ( "death" );
		
		if ( isDefined( self.hintMessage ) )
		self.hintMessage destroyElem();
	}
}

lowerMessageThink()
{
	self endon ( "disconnect" );
	
	//if ( !isDefined( self.connected ) )//A003
	//return;
	self.lowerMessages = [];//added
	self.lowerMessage = createFontString( "default", level.lowerTextFontSize );
	self.lowerMessage setPoint( "CENTER", level.lowerTextYAlign, 0, level.lowerTextY );
	self.lowerMessage setText( "" );
	self.lowerMessage.archived = false;
	
	timerFontSize = 1.5;
	
	self.lowerTimer = createFontString( "default", timerFontSize );
	self.lowerTimer setParent( self.lowerMessage );
	self.lowerTimer setPoint( "TOP", "BOTTOM", 0, 0 );
	self.lowerTimer setText( "" );
	self.lowerTimer.archived = false;
}
//da ao  time X evps
GiveScorePlayersTeamEVP(team)
{	
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
    
		if(!isDefined(player))
		continue;
		
		if(!isDefined(player.tgrcoletou))
		continue;
		
		//nao colheu praticamente nada nao ganha nada!
		if(player.tgrcoletou < 5)
		continue;
		
		if(player.pers["team"] != team)
		continue;
		
		if(!isDefined(player.score))
		continue;
	  
		if(player.score < 500)
		continue;
		
		if(isDefined(player.trgwinner))
		continue;
		
		if(player.pers["team"] == "axis")
		{
			player.trgwinner = true;
			player iPrintLnBold("^3EVP's Recebidos: " + level.axisdrops * 15);
			player GiveEVP(level.axisdrops * 15,100);
		}	
		
		if(player.pers["team"] == "allies")
		{
			player.trgwinner = true;
			player iPrintLnBold("^3EVP's Recebidos: " + level.alliesdrops * 15);
			player GiveEVP(level.alliesdrops * 15,100);
		}		
		
		//if ( player.pers["team"] == team )
		//{
		//	player GiveEVP(100,100);
		//}	
	}
}
teamOutcomeNotify( winner, isRound, endReasonText )
{
	self endon ( "disconnect" );
	self notify ( "reset_outcome" );
	
	team = self.pers["team"];
	
	if ( !isDefined( team ) || (team != "allies" && team != "axis") )
	team = "allies";

	// wait for notifies to finish
	while ( self.doingNotify )
	wait level.oneFrame;

	self endon ( "reset_outcome" );
	
	//left getTeamScore( team )
	//right getTeamScore( level.otherTeam[team] )
	if ( isDefined( self.pers["team"] ) && winner == team )
	self playLocalSound( "menuon" );
	else
	self playLocalSound( "menuoff" );
	
	if(team == "allies")
	self setClientDvar( "ui_team","marines");
	else
	self setClientDvar( "ui_team","opfor");
	
	self setClientDvar( "ui_outcomescore", getTeamScore( team ) + " --- " + getTeamScore( level.otherTeam[team] ));
	
	if ( winner == "halftime" )
	self setClientDvar( "ui_endReasonText", "HALF TIME");
	else if ( winner == "intermission" )
	self setClientDvar( "ui_endReasonText", "INTERMISSION");
	else if ( winner == "tie" )
	self setClientDvar( "ui_endReasonText", "TIE");
	else if ( winner == "roundend" )
	self setClientDvar( "ui_endReasonText", "ROUND END");
	else if ( isDefined( self.pers["team"] ) && winner == team )
	{
		if ( isRound )
		self setClientDvar( "ui_endReasonText", "ROUND WIN");
		else
		self setClientDvar( "ui_endReasonText", "VICTORY");
	}
	else
	{
		if ( isRound )
		self setClientDvar( "ui_endReasonText", "ROUND LOST");
		else
		self setClientDvar( "ui_endReasonText", "DEFEAT");
	}
	
	if(isDefined(level.endedbynuke))
	self setClientDvar( "ui_endReasonText", "TACTICAL NUKE");
	
	if(isDefined(level.wasendedbycasedestroyed))
	self setClientDvar( "ui_endReasonText", "MALETA DESTRUIDA");
	
	self openMenu( game[ "menu_endgameteam"] );
	
}


outcomeNotify( winner, endReasonText )
{
	self endon ( "disconnect" );
	self notify ( "reset_outcome" );

	// wait for notifies to finish
	while ( self.doingNotify )
	{	
		wait level.oneFrame;
	}

	self endon ( "reset_outcome" );

	players = level.placement["all"];
	

		//2024 - novo menu final de jogo para FFA?
		//self setclientdvar( "g_scriptMainMenu", game["menu_endgame"] );
		self playLocalSound( "menuon" );
		self openMenu( game[ "menu_endgame"] );
		
	//aparece no final do jogo!
	//porem este text esta sobrepondo o Winner
	
	if(level.atualgtype != "dm")
	{
		if (isDefined( players[1] ) && players[0].score == players[1].score && players[0].deaths == players[1].deaths && (self == players[0] || self == players[1]) )
		{
			self setClientDvar( "ui_endReasonText", "TIE");
		}
		else if (isDefined( players[2] ) && players[0].score == players[2].score && players[0].deaths == players[2].deaths && self == players[2] )
		{
			self setClientDvar( "ui_endReasonText", "TIE");
		}
		else if ( ( isDefined( players[0] ) && self == players[0] ) || ( isDefined( winner ) && self == winner ) )
		{
			self setClientDvar( "ui_endReasonText", "VICTORY");
		}
		else
		{
			self setClientDvar( "ui_endReasonText", "DEFEAT");
		}
	} 

	if(level.atualgtype == "dm" || level.atualgtype == "gg")
	{
	
		//if(isDefined(endReasonText))
		self setClientDvar( "ui_endReasonText", "[TOP 4]");
	
		//MENU FEED
		if ( isDefined( players[0] ) )
		{
			self setClientDvar( "ui_winner0", players[0].name + "^7 - [ Kills: " + players[0].pers["kills"] + " Deaths: " + players[0].pers["deaths"] + " Headshots: " + players[0].pers["headshots"] + " $$$: " + players[0].pers["roundpocket"] + " ]");
			if(!isDefined(players[0].winnerdm))
			{
				
				players[0] GiveEVP(650,100);			
				players[0].winnerdm = true;
			}
		}
			
		if (isDefined( players[1] ) )
		{
			self setClientDvar( "ui_winner1", players[1].name + "^7 - [ Kills: " + players[1].pers["kills"] + " Deaths: " + players[1].pers["deaths"] + " Headshots: " + players[1].pers["headshots"]  + " $$$: " + players[1].pers["roundpocket"] + " ]");
			if(!isdefined(players[1].winnerdm))
			{

				players[1] GiveEVP(350,100);	
				players[1].winnerdm = true;
			}
		}

		if (isDefined( players[2] ) )
		{
			self setClientDvar( "ui_winner2", players[2].name + "^7 - [ Kills: " + players[2].pers["kills"] + " Deaths: " + players[2].pers["deaths"] + " Headshots: " + players[2].pers["headshots"]  + " $$$: " + players[2].pers["roundpocket"] + " ]" );
			if(!isdefined(players[2].winnerdm))
			{	
				players[2] GiveEVP(250,100);			
				players[2].winnerdm = true;
			}
		}
		
		if (isDefined( players[3] ) )
		{
			self setClientDvar( "ui_winner3", players[3].name + "^7 - [ Kills: " + players[3].pers["kills"] + " Deaths: " + players[3].pers["deaths"] + " Headshots: " + players[3].pers["headshots"]  + " $$$: " + players[3].pers["roundpocket"] + " ]" );
			if(!isdefined(players[3].winnerdm))
			{	
				players[3] GiveEVP(150,100);			
				players[3].winnerdm = true;
			}
		}
	}
	
	if(isDefined(level.endedbynuke))
	self setClientDvar( "ui_endReasonText", "TACTICAL NUKE");
	

	
	//self thread updateOutcome( firstTitle, secondTitle, thirdTitle );
	//self thread resetOutcomeNotify( outcomeTitle, outcomeText, firstTitle, secondTitle, thirdTitle, matchBonus );
}


resetOutcomeNotify( outcomeTitle, outcomeText, firstTitle, secondTitle, thirdTitle, matchBonus )
{
	self endon ( "disconnect" );
	self waittill ( "reset_outcome" );
	
	if ( isDefined( outcomeTitle ) )
	outcomeTitle destroyElem();
	if ( isDefined( outcomeText ) )
	outcomeText destroyElem();
	if ( isDefined( firstTitle ) )
	firstTitle destroyElem();
	if ( isDefined( secondTitle ) )
	secondTitle destroyElem();
	if ( isDefined( thirdTitle ) )
	thirdTitle destroyElem();
	if ( isDefined( matchBonus ) )
	matchBonus destroyElem();
}

resetTeamOutcomeNotify( outcomeTitle, outcomeText, leftIcon, rightIcon, LeftScore, rightScore, matchBonus )
{
	self endon ( "disconnect" );
	self waittill ( "reset_outcome" );

	if ( isDefined( outcomeTitle ) )
	outcomeTitle destroyElem();
	if ( isDefined( outcomeText ) )
	outcomeText destroyElem();
	if ( isDefined( leftIcon ) )
	leftIcon destroyElem();
	if ( isDefined( rightIcon ) )
	rightIcon destroyElem();
	if ( isDefined( leftScore ) )
	leftScore destroyElem();
	if ( isDefined( rightScore ) )
	rightScore destroyElem();
	if ( isDefined( matchBonus ) )
	matchBonus destroyElem();
}


updateOutcome( firstTitle, secondTitle, thirdTitle )
{
	self endon( "disconnect" );
	self endon( "reset_outcome" );
	
	while( true )
	{
		self waittill( "update_outcome" );

		players = level.placement["all"];

		if ( isDefined( firstTitle ) && isDefined( players[0] ) )
		firstTitle setPlayerNameString( players[0] );
		else if ( isDefined( firstTitle ) )
		firstTitle.alpha = 0;
		
		if ( isDefined( secondTitle ) && isDefined( players[1] ) )
		secondTitle setPlayerNameString( players[1] );
		else if ( isDefined( secondTitle ) )
		secondTitle.alpha = 0;
		
		if ( isDefined( thirdTitle ) && isDefined( players[2] ) )
		thirdTitle setPlayerNameString( players[2] );
		else if ( isDefined( thirdTitle ) )
		thirdTitle.alpha = 0;
	}	
}
