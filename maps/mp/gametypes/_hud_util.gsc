#include promatch\_utils;

setParent( element )
{
	if ( isDefined( self.parent ) && self.parent == element )
	return;
	
	if ( isDefined( self.parent ) )
	self.parent removeChild( self );

	self.parent = element;
	self.parent addChild( self );

	if ( isDefined( self.point ) )
	self setPoint( self.point, self.relativePoint, self.xOffset, self.yOffset );
	else
	self setPoint( "TOPLEFT" );
}

getParent()
{
	return self.parent;
}

addChild( element )
{
	element.index = self.children.size;
	self.children[self.children.size] = element;
}

removeChild( element )
{
	element.parent = undefined;

	if ( self.children[self.children.size-1] != element )
	{
		self.children[element.index] = self.children[self.children.size-1];
		self.children[element.index].index = element.index;
	}
	self.children[self.children.size-1] = undefined;
	
	element.index = undefined;
}


setPoint( point, relativePoint, xOffset, yOffset, moveTime )
{
	if ( !isDefined( moveTime ) )
	moveTime = 0;

	element = self getParent();
	
	if ( !isDefined( self ) )
	return;
	
	if ( moveTime )
	self moveOverTime( moveTime );
	
	if ( !isDefined( xOffset ) )
	xOffset = 0;
	self.xOffset = xOffset;

	if ( !isDefined( yOffset ) )
	yOffset = 0;
	self.yOffset = yOffset;
	
	self.point = point;

	self.alignX = "center";
	self.alignY = "middle";

	if ( isSubStr( point, "TOP" ) )
	self.alignY = "top";
	if ( isSubStr( point, "BOTTOM" ) )
	self.alignY = "bottom";
	if ( isSubStr( point, "LEFT" ) )
	self.alignX = "left";
	if ( isSubStr( point, "RIGHT" ) )
	self.alignX = "right";

	if ( !isDefined( relativePoint ) )
	relativePoint = point;

	self.relativePoint = relativePoint;

	relativeX = "center";
	relativeY = "middle";

	if ( isSubStr( relativePoint, "TOP" ) )
	relativeY = "top";
	if ( isSubStr( relativePoint, "BOTTOM" ) )
	relativeY = "bottom";
	if ( isSubStr( relativePoint, "LEFT" ) )
	relativeX = "left";
	if ( isSubStr( relativePoint, "RIGHT" ) )
	relativeX = "right";

	if ( element == level.uiParent )
	{
		self.horzAlign = relativeX;
		self.vertAlign = relativeY;
	}
	else
	{
		self.horzAlign = element.horzAlign;
		self.vertAlign = element.vertAlign;
	}


	if ( relativeX == element.alignX )
	{
		offsetX = 0;
		xFactor = 0;
	}
	else if ( relativeX == "center" || element.alignX == "center" )
	{
		offsetX = int(element.width / 2);
		if ( relativeX == "left" || element.alignX == "right" )
		xFactor = -1;
		else
		xFactor = 1;	
	}
	else
	{
		offsetX = element.width;
		if ( relativeX == "left" )
		xFactor = -1;
		else
		xFactor = 1;
	}
	self.x = element.x + (offsetX * xFactor);

	if ( relativeY == element.alignY )
	{
		offsetY = 0;
		yFactor = 0;
	}
	else if ( relativeY == "middle" || element.alignY == "middle" )
	{
		offsetY = int(element.height / 2);
		if ( relativeY == "top" || element.alignY == "bottom" )
		yFactor = -1;
		else
		yFactor = 1;	
	}
	else
	{
		offsetY = element.height;
		if ( relativeY == "top" )
		yFactor = -1;
		else
		yFactor = 1;
	}
	self.y = element.y + (offsetY * yFactor);
	
	self.x += self.xOffset;
	self.y += self.yOffset;
	
	switch ( self.elemType )
	{
		case "bar":
			setPointBar( point, relativePoint, xOffset, yOffset );
			//self.bar setPoint( point, relativePoint, xOffset, yOffset );
			self.barFrame setParent( self getParent() );
			self.barFrame setPoint( point, relativePoint, xOffset, yOffset );
			break;
	}
	
	self updateChildren();
}


setPointBar( point, relativePoint, xOffset, yOffset )
{
	self.bar.horzAlign = self.horzAlign;
	self.bar.vertAlign = self.vertAlign;
	
	self.bar.alignX = "left";
	self.bar.alignY = self.alignY;
	self.bar.y = self.y;
	
	if ( self.alignX == "left" )
	self.bar.x = self.x;
	else if ( self.alignX == "right" )
	self.bar.x = self.x - self.width;
	else
	self.bar.x = self.x - int(self.width / 2);
	
	if ( self.alignY == "top" )
	self.bar.y = self.y;
	else if ( self.alignY == "bottom" )
	self.bar.y = self.y;

	self updateBar( self.bar.frac );
}


updateBar( barFrac, rateOfChange )
{
	if ( self.elemType == "bar" )
	updateBarScale( barFrac, rateOfChange );
}


updateBarScale( barFrac, rateOfChange ) // rateOfChange is optional and is in "(entire bar lengths) per second"
{
	barWidth = int(self.width * barFrac + 0.5); // (+ 0.5 rounds)
	
	if ( !barWidth )
	barWidth = 1;
	
	self.bar.frac = barFrac;
	self.bar setShader( self.bar.shader, barWidth, self.height );
	
	assertEx( barWidth <= self.width, "barWidth <= self.width: " + barWidth + " <= " + self.width + " - barFrac was " + barFrac );
	
	//if barWidth is bigger than self.width then we are drawing more than 100%
	if ( isDefined( rateOfChange ) && barWidth < self.width ) 
	{
		if ( rateOfChange > 0 )
		{
			//printLn( "scaling from: " + barWidth + " to " + self.width + " at " + ((1 - barFrac) / rateOfChange) );
			assertex( ((1 - barFrac) / rateOfChange) > 0, "barFrac: " + barFrac + "rateOfChange: " + rateOfChange );
			self.bar scaleOverTime( (1 - barFrac) / rateOfChange, self.width, self.height );
		}
		else if ( rateOfChange < 0 )
		{
			//printLn( "scaling from: " + barWidth + " to " + 0 + " at " + (barFrac / (-1 * rateOfChange)) );
			assertex(  (barFrac / (-1 * rateOfChange)) > 0, "barFrac: " + barFrac + "rateOfChange: " + rateOfChange );
			self.bar scaleOverTime( barFrac / (-1 * rateOfChange), 1, self.height );
		}
	}
	self.bar.rateOfChange = rateOfChange;
	self.bar.lastUpdateTime = getTime();
}


createFontString( font, fontScale )
{
	fontElem = newClientHudElem( self );
	fontElem.elemType = "font";
	fontElem.font = font;
	fontElem.fontscale = fontScale;
	fontElem.x = 0;
	fontElem.y = 0;
	fontElem.width = 0;
	fontElem.height = int(level.fontHeight * fontScale);
	fontElem.xOffset = 0;
	fontElem.yOffset = 0;
	fontElem.children = [];
	fontElem setParent( level.uiParent );
	fontElem.hidden = false;
	return fontElem;
}


createServerFontString( font, fontScale, team )
{
	if ( isDefined( team ) )
	fontElem = newTeamHudElem( team );
	else
	fontElem = newHudElem( self );
	
	fontElem.elemType = "font";
	fontElem.font = font;
	fontElem.fontscale = fontScale;
	fontElem.x = 0;
	fontElem.y = 0;
	fontElem.width = 0;
	fontElem.height = int(level.fontHeight * fontScale);
	fontElem.xOffset = 0;
	fontElem.yOffset = 0;
	fontElem.children = [];
	fontElem setParent( level.uiParent );
	fontElem.hidden = false;
	
	return fontElem;
}

createServerTimer( font, fontScale, team )
{	
	if ( isDefined( team ) )
	timerElem = newTeamHudElem( team );
	else
	timerElem = newHudElem( self );
	timerElem.elemType = "timer";
	timerElem.font = font;
	timerElem.fontscale = fontScale;
	timerElem.x = 0;
	timerElem.y = 0;
	timerElem.width = 0;
	timerElem.height = int(level.fontHeight * fontScale);
	timerElem.xOffset = 0;
	timerElem.yOffset = 0;
	timerElem.children = [];
	timerElem setParent( level.uiParent );
	timerElem.hidden = false;
	
	return timerElem;
}

createIcon( shader, width, height )
{
	iconElem = newClientHudElem( self );
	iconElem.elemType = "icon";
	iconElem.x = 0;
	iconElem.y = 0;
	iconElem.width = width;
	iconElem.height = height;
	iconElem.xOffset = 0;
	iconElem.yOffset = 0;
	iconElem.children = [];
	iconElem setParent( level.uiParent );
	iconElem.hidden = false;
	
	if ( isDefined( shader ) )
	iconElem setShader( shader, width, height );
	
	return iconElem;
}


createServerIcon( shader, width, height, team )
{
	if ( isDefined( team ) )
	iconElem = newTeamHudElem( team );
	else
	iconElem = newHudElem( self );
	iconElem.elemType = "icon";
	iconElem.x = 0;
	iconElem.y = 0;
	iconElem.width = width;
	iconElem.height = height;
	iconElem.xOffset = 0;
	iconElem.yOffset = 0;
	iconElem.children = [];
	iconElem setParent( level.uiParent );
	iconElem.hidden = false;
	
	if ( isDefined( shader ) )
	iconElem setShader( shader, width, height );
	
	return iconElem;
}


createServerBar( color, width, height, flashFrac, team, selected )
{
	if ( isDefined( team ) )
	barElem = newTeamHudElem( team );
	else
	barElem = newHudElem( self );
	barElem.x = 0;
	barElem.y = 0;
	barElem.frac = 0;
	barElem.color = color;
	barElem.sort = -2;
	barElem.shader = "progress_bar_fill";
	barElem setShader( "progress_bar_fill", width, height );
	barElem.hidden = false;
	if ( isDefined( flashFrac ) )
	{
		barElem.flashFrac = flashFrac;

	}

	if ( isDefined( team ) )
	barElemFrame = newTeamHudElem( team );
	else
	barElemFrame = newHudElem( self );
	barElemFrame.elemType = "icon";
	barElemFrame.x = 0;
	barElemFrame.y = 0;
	barElemFrame.width = width;
	barElemFrame.height = height;
	barElemFrame.xOffset = 0;
	barElemFrame.yOffset = 0;
	barElemFrame.bar = barElem;
	barElemFrame.barFrame = barElemFrame;
	barElemFrame.children = [];
	barElemFrame.sort = -1;
	barElemFrame.color = (1,1,1);
	barElemFrame setParent( level.uiParent );
	if ( isDefined( selected ) )
	barElemFrame setShader( "progress_bar_fg_sel", width, height );
	else
	barElemFrame setShader( "progress_bar_fg", width, height );
	barElemFrame.hidden = false;

	if ( isDefined( team ) )
	barElemBG = newTeamHudElem( team );
	else
	barElemBG = newHudElem( self );
	barElemBG.elemType = "bar";
	barElemBG.x = 0;
	barElemBG.y = 0;
	barElemBG.width = width;
	barElemBG.height = height;
	barElemBG.xOffset = 0;
	barElemBG.yOffset = 0;
	barElemBG.bar = barElem;
	barElemBG.barFrame = barElemFrame;
	barElemBG.children = [];
	barElemBG.sort = -3;
	barElemBG.color = (0,0,0);
	barElemBG.alpha = 0.5;
	barElemBG setParent( level.uiParent );
	barElemBG setShader( "progress_bar_bg", width, height );
	barElemBG.hidden = false;
	
	return barElemBG;
}

createBar( color, width, height, flashFrac )
{
	barElem = newClientHudElem(	self );
	barElem.x = 0 ;
	barElem.y = 0;
	barElem.frac = 0;
	//barElem.color = color;
	barElem.sort = -2;
	barElem.color = (1,0.1,0.1);
	barElem.alpha = 0.8;
	barElem.shader = "progress_bar_fill";
	barElem setShader( "progress_bar_fill", width + 1, height );
	barElem.hidden = false;
	if ( isDefined( flashFrac ) )
	{
		barElem.flashFrac = flashFrac;
	}

	barElemFrame = newClientHudElem( self );
	barElemFrame.elemType = "icon";
	barElemFrame.x = 0;
	barElemFrame.y = 0;
	barElemFrame.width = width;
	barElemFrame.height = height;
	barElemFrame.xOffset = 0;
	barElemFrame.yOffset = 0;
	barElemFrame.bar = barElem;
	barElemFrame.barFrame = barElemFrame;
	barElemFrame.children = [];
	barElemFrame.sort = -1;
	barElemFrame setParent( level.uiParent );
	//	barElemFrame setShader( "progress_bar_fg", width, height );
	barElemFrame.hidden = false;
	
	//Fundo da Barra
	barElemBG = newClientHudElem( self );
	barElemBG.elemType = "bar";
	if ( !level.splitScreen )
	{
		barElemBG.x = -2;
		barElemBG.y = -2;
	}
	barElemBG.width = width;
	barElemBG.height = height;
	barElemBG.xOffset = 0;
	barElemBG.yOffset = -1;
	barElemBG.bar = barElem;
	barElemBG.barFrame = barElemFrame;
	barElemBG.children = [];
	barElemBG.sort = -3;
	barElemBG.color = (0,0,0);
	barElemBG.alpha = 0.9;
	barElemBG setParent( level.uiParent );
	barElemBG setShader( "progress_bar_bg", width, height + 3 );

	barElemBG.hidden = false;
	
	return barElemBG;
}

getCurrentFraction()
{
	frac = self.bar.frac;
	if (isdefined(self.bar.rateOfChange))
	{
		frac += (getTime() - self.bar.lastUpdateTime) * self.bar.rateOfChange;
		if (frac > 1) frac = 1;
		if (frac < 0) frac = 0;
	}
	return frac;
}

createPrimaryProgressBar(yOffset)
{
	if ( !isDefined( yOffset ) )
	yOffset = 2;
	
	bar = createBar( (1, 1, 1), level.primaryProgressBarWidth, level.primaryProgressBarHeight );
	bar setPoint("CENTER", undefined, level.primaryProgressBarX, level.primaryProgressBarY - yOffset );
	return bar;
}

createPrimaryProgressBarText(yOffset)
{
	if ( !isDefined( yOffset ) )
	yOffset = 2;
	text = createFontString( "objective", level.primaryProgressBarFontSize );
	text setPoint("CENTER", undefined, level.primaryProgressBarTextX, level.primaryProgressBarTextY - yOffset );
	text.sort = -1;
	return text;
}

createTeamProgressBar( team )
{
	bar = createServerBar( (1,0,0), level.teamProgressBarWidth, level.teamProgressBarHeight, undefined, team );
	bar setPoint("TOP", undefined, 0, level.teamProgressBarY);
	return bar;
}
createTeamProgressBarText( team )
{
	text = createServerFontString( "default", level.teamProgressBarFontSize, team );
	text setPoint("TOP", undefined, 0, level.teamProgressBarTextY);
	return text;
}


setFlashFrac( flashFrac )
{
	self.bar.flashFrac = flashFrac;
}

hideElem()
{
	if ( self.hidden )
	return;
	
	self.hidden = true;

	if ( self.alpha != 0 )
	self.alpha = 0;
	
	if ( self.elemType == "bar" || self.elemType == "bar_shader" )
	{
		self.bar.hidden = true;
		if ( self.bar.alpha != 0 )
		self.bar.alpha = 0;

		self.barFrame.hidden = true;
		if ( self.barFrame.alpha != 0 )
		self.barFrame.alpha = 0;
	}
}

showElem()
{
	if ( !self.hidden )
	return;
	
	self.hidden = false;

	if ( self.elemType == "bar" || self.elemType == "bar_shader" )
	{
		if ( self.alpha != .5 )
		self.alpha = .5;
		
		self.bar.hidden = false;
		if ( self.bar.alpha != 1 )
		self.bar.alpha = 1;

		self.barFrame.hidden = false;
		if ( self.barFrame.alpha != 1 )
		self.barFrame.alpha = 1;
	}
	else
	{
		if ( self.alpha != 1 )
		self.alpha = 1;
	}
}


destroyElem()
{
	if ( !isDefined( self.children ) )
	return;

	tempChildren = [];

	for ( index = 0; index < self.children.size; index++ )
	{
		if ( isDefined( self.children[index] ) )
		tempChildren[tempChildren.size] = self.children[index];
	}

	for ( index = 0; index < tempChildren.size; index++ )
	tempChildren[index] setParent( self getParent() );
	
	if ( self.elemType == "bar" || self.elemType == "bar_shader" )
	{
		self.bar destroy();
		self.barFrame destroy();
	}
	
	self destroy();
}

setIconShader( shader )
{
	self setShader( shader, self.width, self.height );
}

setWidth( width )
{
	self.width = width;
}


setHeight( height )
{
	self.height = height;
}

setSize( width, height )
{
	self.width = width;
	self.height = height;
}

updateChildren()
{
	if ( !isDefined( self.children ) )
	return;

	for ( index = 0; index < self.children.size; index++ )
	{
		child = self.children[index];
		child setPoint( child.point, child.relativePoint, child.xOffset, child.yOffset );
	}
}


