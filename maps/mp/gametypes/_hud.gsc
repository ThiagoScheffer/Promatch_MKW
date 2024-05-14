#include promatch\_utils;


init()
{
	precacheShader( "progress_bar_bg" );
	precacheShader( "progress_bar_fg" );
	precacheShader( "progress_bar_fill" );
	precacheShader( "score_bar_bg" );
	precacheShader( "score_bar_allies" );
	precacheShader( "score_bar_opfor" );

	level.uiParent = spawnstruct();
	level.uiParent.horzAlign = "left";
	level.uiParent.vertAlign = "top";
	level.uiParent.alignX = "left";
	level.uiParent.alignY = "top";
	level.uiParent.x = 0;
	level.uiParent.y = 0;
	level.uiParent.width = 0;
	level.uiParent.height = 0;
	level.uiParent.children = [];

	level.fontHeight = 12;

	level.hud["allies"] = spawnstruct();
	level.hud["axis"] = spawnstruct();

	//Progress BARS Bottom Screen
	level.primaryProgressBarY = 183; // from center
	level.primaryProgressBarTextY = 169;
	level.secondaryProgressBarY = -169; // from center
	level.secondaryProgressBarTextY = -180;


	level.primaryProgressBarX = 0;
	level.primaryProgressBarHeight = 9; //28; // this is the height and width of the whole progress bar, including the outline. the part that actually moves is 2 pixels smaller.
	level.primaryProgressBarWidth = 120;
	level.primaryProgressBarTextX = 0;
	level.primaryProgressBarFontSize = 1.4;

	level.secondaryProgressBarX = 0;
	level.secondaryProgressBarHeight = 5;
	level.secondaryProgressBarWidth = 150;
	level.secondaryProgressBarTextX = 0;
	level.secondaryProgressBarFontSize = 1.4;

	level.teamProgressBarY = 32; // 205;
	level.teamProgressBarHeight = 14;
	level.teamProgressBarWidth = 192;
	level.teamProgressBarTextY = 8; // 155;
	level.teamProgressBarFontSize = 1.65;

	if ( getDvar( "ui_score_bar" ) == "" )
	setDvar( "ui_score_bar", 0 );

	level.lowerTextYAlign = "CENTER";
	level.lowerTextY = 70;
	level.lowerTextFontSize = 2;
}


showClientScoreBar( time )
{
	self notify ( "showClientScoreBar" );
	self endon ( "showClientScoreBar" );
	self endon ( "death" );
	self endon ( "disconnect" );

	self setClientDvar( "ui_score_bar", 1 );
	xwait( time, false );
	self setClientDvar( "ui_score_bar", 0 );
}


fontPulseInit()
{
	self.baseFontScale = self.fontScale;
	self.maxFontScale = self.fontScale * 2;
	self.inFrames = 3;
	self.outFrames = 5;
}


fontPulse(player)
{
	self notify ( "fontPulse" );
	self endon ( "fontPulse" );
	self endon( "death" );//addded
	
	player endon("disconnect");
	player endon("joined_team");
	player endon("joined_spectators");

	scaleRange = self.maxFontScale - self.baseFontScale;

	while ( self.fontScale < self.maxFontScale )
	{
		self.fontScale = min( self.maxFontScale, self.fontScale + (scaleRange / self.inFrames) );
		wait level.oneFrame;
	}

	while ( self.fontScale > self.baseFontScale )
	{
		self.fontScale = max( self.baseFontScale, self.fontScale - (scaleRange / self.outFrames) );
		wait level.oneFrame;
	}
}
