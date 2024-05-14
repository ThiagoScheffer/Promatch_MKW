#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

#include promatch\_utils;

init()
{	
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		//player thread onPlayerDisconnect();
		
		//player thread onJoinedTeam();
		
		player thread initClassLoadouts();
		
		player thread onJoinedSpectators();		
	}
}

onPlayerDisconnect()
{
	self waittill( "disconnect" );
	
}

onJoinedTeam()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_team");		
	}
}

onJoinedSpectators()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_spectators");
		
		self.pers["oldteam"] = "spectator";
		
	}
}




// init all player classes to default server settings
initClassLoadouts()
{
	if ( !isDefined( self.pers["class"] ) )
	{
		currentdefaultweapon = "m16_gl_mp";
		
		self.pers["class"] = "assault";
		self.class = self.pers["class"];
		self.pers[self.pers["class"]]["loadout_primary"] = currentdefaultweapon;
		self.pers["curr_prim"] = currentdefaultweapon;
		
		self.pers["loadout_secondary"] = "deserteagle_mp";
		self.pers["curr_seco"] = "deserteagle_mp";		
		
		self.pers["loadout_sgrenade"] = "flash_grenade_mp";
		self.pers["curr_sgrenade"] = "flash_grenade_mp";		
	}	
}


//responsavel por abrir o menu da Classe ao selecionar o time->classe
setLoadoutForClass( classType )
{

	// Check if this player changed teams
	if ( !isDefined( self.pers["oldteam"] ) || self.pers["team"] != self.pers["oldteam"] ) 
	{
		changedTeam = true;
		self.pers["oldteam"] = self.pers["team"];
	} 
	else 
	{
		changedTeam = false;		
	}
	
	self setClientDvar("loadout_class", classType);	
}

//VEM DO MENUSUNRAKED - chama o giveLoadout(classunranked) para aplicar as armas
//2024 nao usado mais
/*
menuAcceptClass()
{
		
	// already playing
	if ( self.sessionstate == "playing" )
	{
		//FIX cannot cast undefined to string
		if ( game["state"] == "postgame" ) 
		return;
		
		if(level.cod_mode == "public" && (level.inStrategyPeriod || level.inReadyUpPeriod || level.inGracePeriod))
		{	
			self thread deleteExplosives();
			
			self.changedmodel = undefined;
			
			//self.atualClass = undefined;
			return;
		}
		
		if(level.cod_mode == "practice")//ADDED
		{
			self.changedmodel = undefined;
			
			self thread deleteExplosives();
		}		
		else //so proximo round para alterar classe
		{
			//Aviso next spawn aplica nova classe
			//game["strings"]["change_class"] 
			self iPrintLnBold("Classe sera alterada no proximo Spawn !");
			
			if ( level.numLives == 1 && !level.inGracePeriod )
			{
				//self setClientDvar( "loadout_curclass", "" );
				//self.curClass = undefined;
			}
		}
	}
	else
	{
		if ( isDefined( game["state"] ) && game["state"] == "postgame" )
		return;
		
		if ( isDefined( game["state"] ) && game["state"] == "playing" )//o jogo esta em andamento nao o jogador
		self thread [[level.spawnClient]]();	
	}	
			
	level thread maps\mp\gametypes\_globallogic::updateTeamStatus();
	self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
}*/