init()
{

//nao pode ser usado devido ao limite de headicon !!!

	if ( level.createFX_enabled )
		return;
	
	//level thread onPlayerConnect();
	
	//for(;;)
	//{
	//	updateFriendIconSettings();
	//	wait 5;
	//}
}
onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		player thread onPlayerSpawned();
		player thread onPlayerKilled();
	}
}
onPlayerSpawned()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("spawned_player");
		
		self thread showFriendIcon();
	}
}
onPlayerKilled()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("killed_player");
		self.headicon = "";
	}
}	
showFriendIcon()
{

	if(self.pers["team"] == "allies")
	{
		self.headicon = "insignia1";
		self.headiconteam = "allies";
	}
	else
	{
		self.headicon = "insignia1";
		self.headiconteam = "axis";
	}
	
}
	
updateFriendIconSettings()
{
	//drawfriend = GetDvarFloat( #"scr_drawfriend");
	//if(level.drawfriend != drawfriend)
	//{
	//	level.drawfriend = drawfriend;
	//	updateFriendIcons();
	//}
}
updateFriendIcons()
{
	
	players = level.players;
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
		{

			if(player.pers["team"] == "allies")
			{
				player.headicon = "insignia1";;
				player.headiconteam = "allies";
			}
			else
			{
				player.headicon = "insignia1";;
				player.headiconteam = "axis";
			}
			
		}
	}
} 
