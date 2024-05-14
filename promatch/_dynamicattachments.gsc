#include promatch\_eventmanager;
#include promatch\_utils;

init()
{
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );	
}	


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}	

onPlayerSpawned()
{
	self.attachmentAction = false;	
}

/*
m4_acog = 4
ACR68 = 3


procura arma m4_acog
encontrou retorna nome real  ACR68

procura novamente agora pelo nome real com o _attach

*/

GetandSetAttach(weaponname)
{
	//remove _mp
	namereplace = StrRepl(weaponname, "_mp", "");
		
	//busca na tabela retorna o NOME
	weapon_name = tablelookup( "mp/weaponslist.csv", 4, namereplace, 3 );
	
	//iprintln("NOMEARMA: " + weapon_name);
	
	//ATTACH
	//se o nome nao contem ATTACH - procurar pelo ATTACH desta arma
	if ( !isSubstr( weapon_name, "_ATTACH" ) )
	{
		//ACR68_ATTACH
		weapon_name_attach = weapon_name + "_ATTACH";
		//ACR68_ATTACH -> m4_xxx
		weapon_attach = "" +tablelookup( "mp/weaponslist.csv", 3, weapon_name_attach, 4 );
		
		//iprintln("weapon_attach: " + weapon_attach);
		
		if(weapon_attach != "")
		return weapon_attach;
	}
	
	//DETACH
	if (isSubstr( weapon_name, "_ATTACH" ) )
	{
		//ACR68_ATTACH
		namereplaceattach = StrRepl(weapon_name, "_ATTACH", "");
		
		//iprintln("namereplaceattach: " + namereplaceattach);
		
		//ACR68_ATTACH -> m4_xxx
		weapon_detach = "" +tablelookup( "mp/weaponslist.csv", 3, namereplaceattach, 4 );
		
		//iprintln("weapon_detach: " + weapon_detach);
		
		if(weapon_detach != "")
		return weapon_detach;
	}
	
	return "";
}

/*chamado pelo keybindings
statGets("DESKIN")
self statSets("RANKPOINTS",value)

status = true - restaurar attach
*/
attachDetachAttachment(status)
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "game_ended" );

	
	// Jogar deve estar ativo e vivo.
	if(!isAlive( self ) )
		return;

	if(!isDefined(self.Class)) return;
	
	if(level.atualgtype == "gg") return;
	
	if(!isDefined(status))
	status = false;
	//if(level.inGracePeriod) return;
	
	// Make sure the current weapon supports an attach/detach action
	currentWeapon = self getCurrentWeapon(); // Arma atual do jogador
	
		// Initiate attaching/detaching action. If there's already another action running we'll cancel the request
		if(!isDefined(self.attachmentAction))
		return;
		
		if( self.attachmentAction )
			return;
		else
			self.attachmentAction = true;		
		
		newWeapon = "";
		
		//seta troca ex: m14_acog_mp -> pesquisa na tabela e retorna o attach correto
		newWeapon = GetandSetAttach(currentWeapon);
		//nknown weapon '0_mp': (file 'promatch/_dynamicattachments.gsc', line 152)
		//arma nao permitida attach
		if(newWeapon == "" || newWeapon == "0")
		{
			self.attachmentAction = false;
			return;
		}		
	
		//file flag
		newWeapon = newWeapon + "_mp";
		
		self.pers["curr_primattached"] = newWeapon;
		
		// Get the ammo info for the current weapon
		clipAmmo = self getWeaponAmmoClip( currentWeapon );
		totalAmmo = self getAmmoCount( currentWeapon );

		self allowSprint(false);
		if(status == false)
		{
			// Disable the player's weapons
			self thread maps\mp\gametypes\_gameobjects::_disableWeapon();
		
		
			if(isDefined(self.upgradefastchange) && self.upgradefastchange > 0)
			timetowait = 0.5;
			else
			timetowait = 2;
			
			wait(timetowait);
		}
		
		// Take the current weapon from the player
		self takeWeapon( currentWeapon );
		
		if(level.showdebug)
		iprintln("^2Weapon with: " + newWeapon);
		
		self giveWeapon( newWeapon );
		self setWeaponAmmoClip( newWeapon, clipAmmo );
		self setWeaponAmmoStock( newWeapon, totalAmmo - clipAmmo );
		
		if(status == true)
		self setSpawnWeapon(newWeapon);
		
		self switchToWeapon( newWeapon );
		self thread maps\mp\gametypes\_gameobjects::_enableWeapon();
		self allowSprint(true);
		self.attachmentAction = false;	

		//if(promatch\_thermal::isThermal( newWeapon ))
		//{
			//self iprintln("thermalToggle ON");
			//self thread promatch\_thermal::thermalToggle();
		//}		
		
		newWeapon = "";//RESETA		
}