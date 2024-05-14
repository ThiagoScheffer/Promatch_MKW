#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include promatch\_utils;
init()
{
	if ( !level.oldschool )
	{
		deletePickups();
		return;
	}
	
	if ( getdvar( "scr_os_pickupweaponrespawntime" ) == "" )
		setdvar( "scr_os_pickupweaponrespawntime", "15" );
	
	level.pickupWeaponRespawnTime = getdvarfloat( "scr_os_pickupweaponrespawntime" );
	
	if ( getdvar( "scr_os_pickupperkrespawntime" ) == "" )
		setdvar( "scr_os_pickupperkrespawntime", "25" );
	
	level.pickupPerkRespawnTime = 15.0; //getdvarfloat( "scr_os_pickupperkrespawntime" );
	
	thread initPickups();
	
	thread onPlayerConnect();	
	
	oldschoolLoadout = spawnstruct();
	
	oldschoolLoadout.primaryWeapon = "ak47_mp";
	
	oldschoolLoadout.secondaryWeapon = "usp_mp";
	
	oldschoolLoadout.inventoryWeapon = "";
	oldschoolLoadout.inventoryWeaponAmmo = 0;
	
	//grenade types: "", "frag", "smoke", "flash"
	oldschoolLoadout.grenadeTypePrimary = "frag";
	oldschoolLoadout.grenadeCountPrimary = 0;
	
	oldschoolLoadout.grenadeTypeSecondary = "";
	oldschoolLoadout.grenadeCountSecondary = 0;
	
	level.oldschoolLoadout = oldschoolLoadout;
	
	// mp_player_join
	level.oldschoolPickupSound = "oldschool_pickup";
	level.oldschoolRespawnSound = "oldschool_return";
	
	level.validPerks = [];
	level.validPerks[ level.validPerks.size ] = "specialty_bulletdamage";
	level.validPerks[ level.validPerks.size ] = "specialty_armorvest";
	level.validPerks[ level.validPerks.size ] = "specialty_rof";
	level.validPerks[ level.validPerks.size ] = "specialty_pistoldeath";
	level.validPerks[ level.validPerks.size ] = "specialty_grenadepulldeath";
	level.validPerks[ level.validPerks.size ] = "specialty_fastreload";

	level.perkPickupHints = [];
	level.perkPickupHints[ "specialty_bulletdamage"] = "Ativar ^1Dano";
	level.perkPickupHints[ "specialty_armorvest"] = "Ativar ^2Protecao";
	level.perkPickupHints[ "specialty_rof"] = "Ativar ^3Sobrecarga";
	level.perkPickupHints[ "specialty_pistoldeath"] = "Ativar ^8Ocultar";
	level.perkPickupHints[ "specialty_grenadepulldeath"] = "Ativar ^7Vingativo";
	level.perkPickupHints[ "specialty_fastreload"] = "Ativar ^4Agilidade";

	//perkPickupKeys = getArrayKeys( level.perkPickupHints ); 

	//for ( i = 0; i < perkPickupKeys.size; i++ )
	//precacheString( level.perkPickupHints[ perkPickupKeys[i] ] );
	
}
//retorna uma arma weapon_mp
randomweapon()
{

//==============================================
//buscar na tabela a classe e suas armas e gerar uma lista
//==============================================	

//guarda uma lista de armas aqui
	primaryWeaponrandom = [];
	newElement = 0;
	
	for( idx = 0; idx <= 109; idx++ )
	{
		weapon_type = tablelookup( "mp/weaponslist.csv", 0, idx, 2 );
		
		if(!isDefined(weapon_type) || weapon_type == "weapon_grenade" || weapon_type == "weapon_projectile" )
		continue;	
	
		//pega o nome de arquivo da arma - real filename: m14_reflex
		weapon_name = tablelookup( "mp/weaponslist.csv", 0, idx, 4 );
		
		if(!isDefined(weapon_name) || weapon_name == "" || weapon_name == "LIVRE" )
		continue;	

		newElement = primaryWeaponrandom.size;		
		
		if(isDefined(weapon_name))
		primaryWeaponrandom[newElement]["weaponname"] = weapon_name+"_mp";
	}
	
	
	randomWeaponSelectNumber = randomIntRange(0,primaryWeaponrandom.size); 
	
	randomWeaponSelect = primaryWeaponrandom[randomWeaponSelectNumber]["weaponname"];
	
	return randomWeaponSelect;
}



giveLoadout()
{
	assert( isdefined( level.oldschoolLoadout ) );
	
	if ( !isDefined( self.pers["class"] ) )
	{
		currentdefaultweapon = "m16_mp";
		
		self.pers["class"] = "assault";
		self.class = self.pers["class"];
		self.pers[self.pers["class"]]["loadout_primary"] = currentdefaultweapon;
		self.pers["curr_prim"] = currentdefaultweapon;
		
		self.pers["loadout_secondary"] = "deserteagle_mp";
		self.pers["curr_seco"] = "deserteagle_mp";		
		
		self.pers["loadout_sgrenade"] = "flash_grenade_mp";
		self.pers["curr_sgrenade"] = "flash_grenade_mp";		
	}
	
	//loadout = level.oldschoolLoadout;
	
	//loadout.primaryWeapon = WeaponName(randomweapon());	
	
	//iprintln("loadout.primaryWeapon: " + loadout.primaryWeapon);
	
	self maps\mp\gametypes\_teams::playerModelForClass( self.pers["class"] );//seta o modelo das classes
	
	self SetClassbyWeapon(WeaponName(randomweapon()));
	
	[[level.onLoadoutGiven]]();
}

deletePickups()
{
	pickups = getentarray( "oldschool_pickup", "targetname" );
	
	for ( i = 0; i < pickups.size; i++ )
	{
		if ( isdefined( pickups[i].target ) )
			getent( pickups[i].target, "targetname" ) delete();
		pickups[i] delete();
	}
}

initPickups()
{
	level.pickupAvailableEffect = loadfx( "misc/ui_pickup_available" );
	level.pickupUnavailableEffect = loadfx( "misc/ui_pickup_unavailable" );
	
	wait .5; // so all pickups have a chance to spawn and drop to the ground
	
	//aqui inicializa o tipo de spawn!
	pickups = getentarray( "oldschool_pickup", "targetname" );
	
	for ( i = 0; i < pickups.size; i++ )
	{
		thread trackPickup( pickups[i], i );
	}

}


spawnPickupFX( groundpoint, fx )
{
	effect = spawnFx( fx, groundpoint, (0,0,1), (1,0,0) );
	triggerFx( effect );
	
	return effect;
}

playEffectShortly( fx )
{
	self endon("death");
	wait .05;
	playFxOnTag( fx, self, "tag_origin" );
}

getPickupGroundpoint( pickup )
{
	trace = bullettrace( pickup.origin, pickup.origin + (0,0,-128), false, pickup );
	groundpoint = trace["position"];
	
	finalz = groundpoint[2];
	
	for ( radiusCounter = 1; radiusCounter <= 3; radiusCounter++ )
	{
		radius = radiusCounter / 3.0 * 50;
		
		for ( angleCounter = 0; angleCounter < 10; angleCounter++ )
		{
			angle = angleCounter / 10.0 * 360.0;
			
			pos = pickup.origin + (cos(angle), sin(angle), 0) * radius;
			
			trace = bullettrace( pos, pos + (0,0,-128), false, pickup );
			hitpos = trace["position"];
			
			if ( hitpos[2] > finalz && hitpos[2] < groundpoint[2] + 15 )
				finalz = hitpos[2];
		}
	}
	return (groundpoint[0], groundpoint[1], finalz);
}

replaceweaponpickup(classname)
{
	newweapon = randomweapon();
	//classname : weapon_rpd_mp
	weaponfilename = StrRepl(classname, classname, "weapon_"+newweapon);
	ShowDebug("weaponfilename",""+weaponfilename);
	//rpd_mp
	//look at weapon list file
	//81,5081,weapon_shotgun,M1014,m1014,45-7,15m
	return weaponfilename;
}


trackPickup( pickup, id )
{	

	//Trackpickup: weapon_m1014_reflex_mp
	//logPrint("Trackpickup: " + pickup.classname);
	
	//pickup = "weapon_m1014_reflex_mp";
		
	groundpoint = getPickupGroundpoint( pickup );
	
	effectObj = spawnPickupFX( groundpoint, level.pickupAvailableEffect );
	
	classname = pickup.classname;		
	//classname = replaceweaponpickup(classname);
	origin = pickup.origin;
	angles = pickup.angles;
	spawnflags = pickup.spawnflags;
	model = pickup.model;
	/*
	classname : weapon_rpd_mp
	spawnflags : 3
	model : weapon_rpd
	*/
	
	ShowDebug("classname",""+classname);
	//ShowDebug("pickup",pickup);
	ShowDebug("spawnflags",""+spawnflags);
	ShowDebug("model",""+model);
	
	isWeapon = false;
	isPerk = false;
	weapname = undefined;
	perk = undefined;
	trig = undefined;
	respawnTime = undefined;
	
	/*ents = getEntArray();
	for ( index = 0; index < ents.size; index++ )
	{
    	if(isSubStr(ents[index].model, Model))
    		ents[index] delete();
	}*/
	/*
		getItemWeaponName()
		{
		classname = self.classname;
		assert( getsubstr( classname, 0, 7 ) == "weapon_" );
		weapname = getsubstr( classname, 7 );
		return weapname;
		}
	
	*/
	//se for uma arma aqui
	//weapon_g36c_gl_mp
	if ( issubstr( classname, "weapon_" ) )
	{
		classname = replaceweaponpickup(classname);
		isWeapon = true;
		weapname = pickup maps\mp\gametypes\_weapons::getItemWeaponName();
		//weapname = "gl_g3_mp";
		respawnTime = level.pickupWeaponRespawnTime;		
		
		if ( !getDvarInt( "scr_game_perks" ) )
		{
			pickup delete();
			trig delete();
			effectObj delete();
			return;
		}
	}
	else	
	if ( classname == "script_model" )
	{
		isPerk = true;
		
		perk = pickup.script_noteworthy;
		
		//perk = level.validPerks[randomInt(5)];
		//logerror("Perks335 - " + perk);
		
		for ( i = 0; i < level.validPerks.size; i++ )
		{
			if ( level.validPerks[i] == perk )
				break;
		}
		
		if ( i == level.validPerks.size )
		{
			maps\mp\_utility::error( "oldschool_pickup with classname script_model does not have script_noteworthy set to a valid perk" );
			return;
		}
		
		//perk = level.validPerks[randomInt(5)];
		
		//cannot cast undefined to string: (file 'maps/mp/gametypes/_oldschool.gsc', line 349)
		trig = getent( pickup.target, "targetname" );
		
		//logerror("trig - " + trig);
			
		respawnTime = level.pickupPerkRespawnTime;
		
		if ( !getDvarInt( "scr_game_perks" ) )
		{
			pickup delete();
			trig delete();
			effectObj delete();
			return;
		}
		
		if ( isDefined( level.perkPickupHints[ perk ] ) )
			trig setHintString( level.perkPickupHints[ perk ] );
	}
	else
	{
		maps\mp\_utility::error( "oldschool_pickup with classname " + classname + " is not supported (at location " + pickup.origin + ")" );
		return;
	}
	
	if ( isDefined( pickup.script_delay ) )
		respawnTime = pickup.script_delay;
	
	while(1)
	{
		pickup thread spinPickup();
		
		player = undefined;
		
		if ( isWeapon )
		{
			pickup thread changeSecondaryGrenadeType( weapname );
			pickup setPickupStartAmmo( weapname );
			
			while(1)
			{
				pickup waittill( "trigger", player, dropped );
				
				if ( !isdefined( pickup ) )
					break;
				
				// player only picked up ammo. the pickup still remains.
				assert( !isdefined( dropped ) );
			}
			//aqui deleta o objeto trocado (caido no chao)
			if ( isdefined( dropped ) )
			{
				dropDeleteTime = 5;
				if ( dropDeleteTime > respawnTime )
					dropDeleteTime = respawnTime;
				dropped thread delayedDeletion( dropDeleteTime );
			}
		}
		else
		{
			assert( isPerk );
			
			
			while(1)
			{
				trig waittill( "trigger", player );
				if ( !player hasPerk( perk ) )
					break;
			}
			
			
			trig waittill( "trigger", player );
			
			pickup delete();
			trig triggerOff();
		}
		
		if ( isWeapon )
		{
			//iprintln("weapname: " + weapname);
			if(isSniper(weapname))
			{
				player.isSniper = true;
			}
			if ( weaponInventoryType( weapname ) == "item" && (!isdefined( player.inventoryWeapon ) || weapname != player.inventoryWeapon) )
			{
				player removeInventoryWeapon();
				player.inventoryWeapon = weapname;
				player SetActionSlot( 3, "weapon", weapname );
				// this used to reset the action slot to alt mode when your ammo is up for the weapon.
				// however, this isn't safe for C4, which you need to still have even when you have no ammo, so you can detonate.
				//player thread resetActionSlotToAltMode( weapname );
			}
			
			player giveMaxAmmo( weapname);
		}
		else
		{
			assert( isPerk );
			
			//player iprintln("HASPERK: " + !player hasPerk( perk ));
			//player iprintln("PERK: " + perk );
			//player iprintln("NAME: " + player.name );
			
			if ( !player hasPerk( perk ) )
			{			
				player setPerk( perk );
				switch (perk)
				{
					case  "specialty_armorvest":
					player.flakjacket = true;
					if(isDefined(player.hasarmor))
					{
						player LifeUpgrade(player.health + 200);
						player.playerarmor.base = 0.2;
						player.playerarmor.currentarmor = 300;
						player.playerarmor.value setValue(300);
						player.playercapa.currenthelmet = 150;
						player.playercapa.base = 0.2;
						player.playercapa.value setValue(150);
					}
					break;
					
					case  "specialty_rof":
					player setPerk( "specialty_bulletpenetration" );
					player setClientDvars("jump_slowdownEnable",0,"jump_spreadAdd",1,"player_dmgtimer_timePerPoint",0,"player_dmgtimer_flinchTime",0,"player_dmgtimer_stumbleTime",0);
					player LifeUpgrade(100);
					break;
					
					case  "specialty_pistoldeath":
					player.coldblooded = true;
					player.takedown = true;
					player setClientDvar( "compassMaxRange", 2500 );
					player setPerk( "specialty_quieter" );
					player setPerk( "specialty_gpsjammer" );
					player LifeUpgrade(100);
					break;
					
					case  "specialty_grenadepulldeath":
					player.dangercloser = true;
					player.vampirism = true;
					player setClientDvars("compassEnemyFootstepEnabled",1,"compassEnemyFootstepMaxRange",500);
					player LifeUpgrade(100);
					break;
					
					case  "specialty_bulletdamage":					
					player.wallbang = true;
					player.hpround = true;
					player.wallbang = true;
					player.dangercloser = true;
					player.onehs = true;
					player LifeUpgrade(100);
					break;
					
					case  "specialty_fastreload":
					player setMoveSpeedScale( 1.35 );
					player setPerk( "specialty_gpsjammer" );
					break;
				}
				
				//if(player.health <= 100)
				//player.health = 100;
				
				player.numPerks++;
			}
		}
		
		thread playSoundinSpace( level.oldschoolPickupSound, origin );
		
		effectObj delete();
		effectObj = spawnPickupFX( groundpoint, level.pickupUnavailableEffect );
		
		wait respawnTime;
		
		pickup = spawn( classname, origin, spawnflags );
		pickup.angles = angles;
		if ( isPerk )
		{
			pickup setModel( model );
			trig triggerOn();
		}
		
		pickup playSound( level.oldschoolRespawnSound );
		
		effectObj delete();
		effectObj = spawnPickupFX( groundpoint, level.pickupAvailableEffect );
	}
}

playSoundinSpace( alias, origin )
{
	org = spawn( "script_origin", origin );
	org.origin = origin;
	org playSound( alias  );
	wait 10; // MP doesn't have "sounddone" notifies =(
	org delete();
}

setPickupStartAmmo( weapname )
{
	curweapname = weapname;
	
	//iprintln("weapname: " + weapname);
	
	altindex = 0;
	while ( altindex == 0 || (curweapname != weapname && curweapname != "none") )
	{
		allammo = weaponmaxammo(curweapname );
		clipammo = weaponClipSize( curweapname );
		
		reserveammo = 0;
		if ( clipammo >= allammo )
		{
			clipammo = allammo;
		}
		else
		{
			reserveammo = allammo - clipammo;
		}
		
		self itemWeaponSetAmmo( clipammo, reserveammo, altindex );
		curweapname = weaponAltWeaponName( curweapname );
		altindex++;
	}	
}

changeSecondaryGrenadeType( weapname )
{
	self endon("trigger");
	
	if ( weapname != level.weapons["smoke"] && weapname != level.weapons["flash"] && weapname != level.weapons["concussion"] )
		return;
	
	offhandClass = "smoke";
	if ( weapname == level.weapons["flash"] )
		offhandClass = "flash";
	
	trig = spawn( "trigger_radius", self.origin - (0,0,20), 0, 128, 64 );
	self thread deleteTriggerWhenPickedUp( trig );
	
	while(1)
	{
		trig waittill( "trigger", player );
		if ( player getWeaponAmmoTotal( level.weapons["smoke"] ) == 0 && 
			player getWeaponAmmoTotal( level.weapons["flash"] ) == 0 && 
			player getWeaponAmmoTotal( level.weapons["concussion"] ) == 0 )
		{
			player setOffhandSecondaryClass( offhandClass );
		}
	}
}

deleteTriggerWhenPickedUp( trig )
{
	self waittill("trigger");
	trig delete();
}

resetActionSlotToAltMode( weapname )
{
	self notify("resetting_action_slot_to_alt_mode");
	self endon("resetting_action_slot_to_alt_mode");
	
	while(1)
	{
		if ( self getWeaponAmmoTotal( weapname ) == 0 )
		{
			curweap = self getCurrentWeapon();
			if ( curweap != weapname && curweap != "none" )
				break;
		}
		wait .2;
	}
	
	self removeInventoryWeapon();
	self SetActionSlot( 3, "altmode" );
}

getWeaponAmmoTotal( weapname )
{
	return self getWeaponAmmoClip( weapname ) + self getWeaponAmmoStock( weapname );
}

removeInventoryWeapon()
{
	if ( isDefined( self.inventoryWeapon ) )
		self takeWeapon( self.inventoryWeapon );
	self.inventoryWeapon = undefined;
}

spinPickup()
{
	if ( self.spawnflags & 2 || self.classname == "script_model" )
	{
		self endon("death");
		
		org = spawn( "script_origin", self.origin );
		org endon("death");
		
		self linkto( org );
		self thread deleteOnDeath( org );
		
		while(1)
		{
			org rotateyaw( 360, 3, 0, 0 );
			wait 2.9;
		}
	}
}

deleteOnDeath( ent )
{
	ent endon("death");
	self waittill("death");
	ent delete();
}

delayedDeletion( delay )
{
	self thread delayedDeletionOnSwappedWeapons( delay );
	
	wait delay;
	
	if ( isDefined( self ) )
	{
		self notify("death");
		self delete();
	}
}

delayedDeletionOnSwappedWeapons( delay )
{
	self endon("death");
	while(1)
	{
		self waittill( "trigger", player, dropped );
		if ( isdefined( dropped ) )
			break;
	}
	dropped thread delayedDeletion( delay );
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill ( "connecting", player );

		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "spawned_player" );
		
		self.inventoryWeapon = undefined;
		self clearPerks();
		self.numPerks = 0;
		self.atualClass = self.class;
		self SetMoveSpeedScale(1);
	}
}

clearPerksOnDeath()
{
	self endon("disconnect");
	self waittill("death");
	
	self clearPerks();
	self.numPerks = 0;
}

watchWeaponsList()
{
	self endon("death");
	
	waittillframeend;
	
	self.weapons = self getWeaponsList();
	
	for(;;)
	{
		self waittill( "weapon_change", newWeapon );
		
		self thread updateWeaponsList( .05 );
	}
}

updateWeaponsList( delay )
{
	self endon("death");
	self notify("updating_weapons_list");
	self endon("updating_weapons_list");
	
	self.weapons = self getWeaponsList();
}

hadWeaponBeforePickingUp( newWeapon )
{
	for ( i = 0; i < self.weapons.size; i++ )
	{
		if ( self.weapons[i] == newWeapon )
			return true;
	}
	return false;
}

