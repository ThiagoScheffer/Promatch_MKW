#include promatch\_utils;

init()
{
	
	precacheShader("headicon_dead");
	
	
	if (!level.teambased)
		return;
		
	//level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);

		player.selfDeathIcons = []; // icons that other people see which point to this player when he's dead
	}
}

updateDeathIconsEnabled()
{
	//if (!self.enableDeathIcons)
	//	self removeOtherDeathIcons();
}

addDeathIcon( entity, dyingplayer, team, timeout )
{
	if ( !level.teambased )
		return;
		
	if(level.cod_mode == "torneio")
	return;
	
	iconOrg = entity.origin;
	
	dyingplayer endon("spawned_player");
	dyingplayer endon("disconnect");
	
	wait level.oneFrame;
	maps\mp\gametypes\_globallogic::WaitTillSlowProcessAllowed();
	
	assert(team == "allies" || team == "axis");
	
	if ( getDvar( "ui_hud_showdeathicons" ) == "0" )
		return;
	
	if ( isdefined( self.lastDeathIcon ) )
		self.lastDeathIcon destroy();
	
	newdeathicon = newTeamHudElem( team );
	newdeathicon.x = iconOrg[0];
	newdeathicon.y = iconOrg[1];
	newdeathicon.z = iconOrg[2] + 54;
	
	
	newdeathicon.alpha = .61;
	
	newdeathicon.archived = true;
	newdeathicon setShader("headicon_dead", 7, 7);
	newdeathicon setwaypoint(true);
	
	self.lastDeathIcon = newdeathicon;
	
	newdeathicon thread destroySlowly ( timeout );
}

destroySlowly( timeout )
{
	self endon("death");
	
	wait timeout;
	
	self fadeOverTime(1.0);
	self.alpha = 0;
	
	xwait(1.0,false);
	self destroy();
}
