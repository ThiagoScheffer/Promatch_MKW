#include common_scripts\utility;
#include maps\mp\_utility;
#include promatch\_utils;

init()
{
	level.scr_claymore_friendly_fire = getdvarx( "scr_claymore_friendly_fire", "int", 0, 0, 2 );
	level.scr_concussion_grenades_base_time = 3;

	// Drop of weapons
	level.class_assault_allowdrop = getdvarx( "class_assault_allowdrop", "int", 1, 0, 1 );
	level.class_specops_allowdrop = getdvarx( "class_specops_allowdrop", "int", 1, 0, 1 );
	level.class_sniper_allowdrop = getdvarx( "class_sniper_allowdrop", "int", 1, 0, 1 );
	level.class_demolitions_allowdrop = getdvarx( "class_demolitions_allowdrop", "int", 1, 0, 1 );
	level.class_heavygunner_allowdrop = getdvarx( "class_heavygunner_allowdrop", "int", 1, 0, 1 );

	level.tearradius = 250;
	level.tearheight = 138;
	level.teargasfillduration = 7; 
	level.teargasduration = 17; 
	level.tearsufferingduration = 3; 
	level.teargrenadetimer = 1; 
	
	
	level.smokefillduration = 20; 
	
	//Tipo de armas
	level.isPistol_Array = [];
	level.isRifle_Array = [];
	level.isSMG_Array = [];
	level.isShotgun_Array = [];
	level.isSniper_Array = [];	
	level.WeaponNames_Array = [];
		
	
	//level.weapon_playerclass = [];
	
	//88,3088,weapon_lmg,Peace Keeper,saw,,,,,,  0 1 2 3 4V
	for( idx = 0; idx <= 112; idx++ )
	{
	
		//weapon_sniper weapon_shotgun - old class
		weapon_type = tablelookup( "mp/weaponslist.csv", 0, idx, 2 );
		
		//pega o nome de arquivo da arma - real filename: m14_reflex
		weapon_name = tablelookup( "mp/weaponslist.csv", 0, idx, 4 );
		
		//separa as armas e define a classe
		//weapon_playerclass = tablelookup( "mp/weaponslist.csv", 0, idx, 4 );
		
		//pega o nome da arma menu - usado para nomes na tela e killfeed
		weapon_namemenu = tablelookup( "mp/weaponslist.csv", 0, idx, 3 );
		
		//logprint("WEAPONS: " + weapon_name + "\n");	
		if( !isdefined( weapon_name ) || weapon_name == "")
		continue;
		
		if( !isdefined( weapon_namemenu ) || weapon_namemenu == "" || weapon_namemenu == "LIVRE")
		continue;
		
		//2022 - registrar tipo da arma
		weapon_type_register( weapon_name+"_mp", weapon_type );	
		
		//registra as armas e o tipo
		//if(weapon_type != "0")
		//{
		//	weapon_type_register( weapon_name+"_mp", weapon_type );		
			//logteste("weapon_name: [ " +weapon_name + " ] weapon_type: [ " + weapon_type + " ]");
		//}
		
		//cadastra e linka o nome do arquivo ao nome de menu
		weapon_namemenu_register( weapon_name+"_mp", weapon_namemenu );
		
		weapon_class_register( weapon_name+"_mp", weapon_type );
				
		precacheItem( weapon_name + "_mp" );
		
		//logteste(WeaponName(weapon_name + "_mp"));
			
	}
	
	//precacheItem( "claymore_mp" );
	//precacheItem( "claymore_mp" );
	
	//===mismatch causado por uma confusao na hora da tabela cachear alguma das armas.
	//resolvido removendo da tabela e cacheando manualmente a arma com o erro.
	//problema é que armas cacheadas manualmente nao sao salvas no menu 
	//sendo necessaria cadastrar elas tambem na tabela..
	//colocalando elas no ignore list e cacheando aqui parece resolver.
	
	//TEMPFIX mismatch
	//precacheItem( "m21_mp");	
	/*precacheItem( "gl_m14_mp");
	precacheItem( "gl_m4_mp");
	precacheItem( "m60e4_reflex_mp");
	precacheItem( "m60e4_acog_mp");
	precacheItem( "usp_mp");//GLOCKCSGO	
	precacheItem( "saw_mp" );
	precacheItem( "m60e4_mp" );
	precacheItem( "m60e4_reflex_mp" );//remington R5 rifle
	precacheItem( "m60e4_acog_mp" );//MTS255 Shot
	precacheItem( "m16_acog_mp" );//SA-58
	
	//precache new weapons
	precacheItem( "gl_g3_mp" );
	precacheItem( "ak74u_silencer_mp" );
	precacheItem( "g36c_silencer_mp" );
	precacheItem( "mp5_silencer_mp" );
	//precacheItem( "uzi_silencer_mp" );
	//precacheItem( "m4_silencer_mp" );
	//precacheItem( "g3_silencer_mp" );
	precacheItem( "m16_silencer_mp" );
	precacheItem( "p90_silencer_mp" );	
	precacheItem( "m21_acog_mp" );//l115a reflex
	precacheItem( "gl_m16_mp" );//olympia slug
	precacheItem( "uzi_acog_mp" );//mtar sil
	//precacheItem( "skorpion_silencer_mp" );//xm8sil
	precacheItem( "skorpion_acog_mp" );//vectorsil
	
	//ITEMS NAO PRECISAM SALVAR
	precacheItem( "tatical_spawn_mp" );
	precacheItem( "magnade_mp" );
	precacheItem( "tear_grenade_mp" );
	precacheItem( "c4_mp" );
	precacheItem( "claymore_mp" );
	precacheItem( "radar_mp" );
	precacheItem( "destructible_car" );
	//precacheItem( "nuke_mp" );
	precacheModel( "weapon_rpg7_stow" );
		*/
		//2022

	//precacheItem( "claymore_mp" );	
	//precacheItem( "saw_reflex_mp" );	
	thread promatch\_inspect::init();		
	thread maps\mp\_flashgrenades::main();
	//testes
	//thread maps\mp\_entityheadicons::init();
	
	claymoreDetectionConeAngle = 180;
	level.claymoreDetectionDot = cos( claymoreDetectionConeAngle );
	level.claymoreDetectionMinDist = 25;
	level.claymoreDetectionGracePeriod = .75;
	level.claymoreDetonateRadius = 192;
	
	level thread onPlayerConnect();
	
	level.c4explodethisframe = false;
}

weapon_namemenu_register( weapon, weapon_name )
{
	level.WeaponNames_Array[weapon] = weapon_name;
}

weapon_class_register( weapon, weapon_type )
{
	if( isSubstr( "weapon_elite weapon_smg weapon_assault weapon_projectile weapon_sniper weapon_shotgun weapon_lmg", weapon_type ) )
	level.primary_weapon_array[weapon] = weapon_type;
	else if( isSubstr( "weapon_pistol", weapon_type ) )
	level.side_arm_array[weapon] = 1;
	else if( weapon_type == "weapon_grenade" )
	level.grenade_array[weapon] = 1;
	else if( weapon_type == "weapon_explosive" )
	level.inventory_array[weapon] = 1;
	else
	assertex( false, "Weapon group info is missing from statsTable for: " + weapon_type );
}

weapon_type_register( weapon, weapon_type )
{
	if( isSubstr( "weapon_pistol", weapon_type ) )
	level.isPistol_Array[weapon] = weapon_type;
	else if( isSubstr( "weapon_assault", weapon_type ) )
	level.isRifle_Array[weapon] = weapon_type;
	else if( isSubstr( "weapon_elite", weapon_type ) )
	level.isSMG_Array[weapon] = weapon_type;
	else if( isSubstr( "weapon_shotgun", weapon_type ) )
	level.isShotgun_Array[weapon] = weapon_type;
	else if( isSubstr( "weapon_sniper", weapon_type ) )
	level.isSniper_Array[weapon] = weapon_type;
	else
	assertex( false, "Weapon group info is missing from statsTable for: " + weapon_type );
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);

		player.usedWeapons = false;
		player.hits = 0;

		player thread onPlayerSpawned();
		//player thread onPlayerKilled();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");

		self.concussionEndTime = 0;
		self.hasDoneCombat = false;
		self.riotshield = false;
	
		self thread watchGrenadeUsage();
		
		self thread watchWeaponChange();

		//self thread RealReload();
			
		self.droppedDeathWeapon = undefined;
		self.tookWeaponFrom = [];
		
		//reset any nade effect!
		self setClientDvar( "r_blur", 0 );
		
		if(level.gametype == "sd")
		self thread quietwalkingsound();
	}
}


onPlayerKilled()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("killed_player");
		
		//if(!self.demolition)
		//self deleteExplosives();
	}
}


watchWeaponChange()
{
	self endon("death");
	self endon("disconnect");

	self.lastDroppableWeapon = self getCurrentWeapon();
	
	//if(self.lastDroppableWeapon == "gl_m16_mp")
	//{
	//	self thread watchFIREARROWsage();
	//}
	if(level.atualgtype == "gg")
	return;
	
	while(1)
	{
		self waittill( "weapon_change", newWeapon );
		
		if(!self isonground())
		continue;

		//newweapon = none
		if (isDefined( self.pers["isBot"] ) && self.pers["isBot"])
		{	
			if(isdefined(self.isDefusing) && self.isDefusing)
			continue;
		
			if(isdefined(self.isPlanting) && self.isPlanting)
			continue;
		
			if(isdefined(self.reviving) && self.reviving)
			continue;	
		
			if(self isOnLadder())
			continue;
		
			if ( isdefined( self.droppedmagWeapon ) )
			continue;

			//iprintln(self.name +"  "+ newWeapon);
			
			if(newweapon == "none")
			{
				self Takeoffprimary();		
				self.rdmweapon = giverandomweapon();
				self giveWeapon(self.rdmweapon);
				self giveMaxAmmo( self.rdmweapon);	
				self setSpawnWeapon( self.rdmweapon );				
			}
		}
		
		
		if ( mayDropWeapon( newWeapon ) )
		self.lastDroppableWeapon = newWeapon;
	}
}

HoldRiotShield()//2020
{
	self endon("disconnect");

	self.riotshieldmodel = spawn( "script_model", self.origin + (0,0,60));		
	self.riotshieldmodel.angles = self getPlayerAngles() + (0,0,0);
	self.riotshieldmodel.origin = (self getTagOrigin("TAG_INHAND"));
	self.riotshieldmodel setModel("riot_shield_view");
	self.riotshieldmodel linkTo(self,"torso_stabilizer",(30,0,6),(0,0,0));//torso_stabilizer ok
		
	self thread RiotdeleteOnDeath( self.riotshieldmodel );
}

/*HoldRiotShield()
{
	self endon("disconnect");
	
	while(1) 
	{		
		handOrigin = "TAG_INHAND";
		//self allowSprint(false);
		self.riotshieldmodel = spawn( "script_model", self.origin + (0,0,60));		
		self.riotshieldmodel.angles = self getPlayerAngles() + (0,0,0);
		self.riotshieldmodel.origin = (self getTagOrigin(handOrigin));
		self.riotshieldmodel setModel("riot_shield_view");
		self.riotshieldmodel linkTo(self,"torso_stabilizer",(30,0,6),(0,0,0));//torso_stabilizer ok
		//delete model
		self waittill_any( "weapon_change","death");
		//self allowSprint(true);
		//if(!isDefined(self.riotshieldmodel))
		//return;		
		
		//removed entity is not an entity: (file 'maps/mp/gametypes/_weapons.gsc', line 294)
		//self.riotshieldmodel unlink();
		
		self.riotshieldmodel unlink();
		self.riotshieldmodel delete();
		return;
	}	
}*/

RiotdeleteOnDeath(ent)
{
	self waittill_any( "weapon_change","death");
	
	wait level.oneFrame;
	
	if ( isdefined(ent) )
	{
		ent unlink();
		ent delete();
	}
}

riotkeep(player)
{
	self endon("disconnect");
	self endon("death");
	self endon("weapon_change");
	
	//pode ser usado para grudar algo e esconder no corpo do alvo
	while(isAlive(player))
	{
		self.origin = player getTagOrigin("tag_stowed_hip_rear");
		wait 0.05;			
	}		
}

quietwalkingsound()
{
	self endon("death");
	self endon("disconnect");
	
	//self iprintln("quietwalkingsound: " + self getStance());	
	
	while(isDefined( self ))
	{
		//wait(self getStance() == "crouch" && self isMoving())
		
		self waitTillCrouchMoving();
		
		rdnnum = randomInt(4);
		rdnnumwait = randomInt(10);
		//self iprintln("quietwalkingsound: rdnnum " );
		
		if(rdnnum != 0)
		self playSound( "quietmove" + rdnnum);
		wait rdnnumwait;		
	}

}

waitTillCrouchMoving()
{
	self endon("death");
	self endon("disconnect");
	
	
	while( isDefined( self ) )
	{
		if ( self getStance() == "crouch" && self isMoving() )
		break;
	
		xwait(1, false );
	}
}

//v1.0 futuro analisar firerate
//weaponShootTime = weaponfiretime( weaponName );
getreload(newWeapon)
{
	self endon( "death" );
	self endon( "disconnect" );
	
	self endon( "weapon_change");

	while(1)
	{
		self waittill("reload_start");

		ammoClip = self GetWeaponAmmoClip(newWeapon);
		self SetWeaponAmmoClip(newWeapon,0);

		ammoStock = self GetWeaponAmmoStock(newWeapon);
		self setWeaponAmmoStock(newWeapon,(ammoStock + ammoClip));
	}
}



isHackWeapon( weapon )
{
	if ( weapon == "radar_mp" || weapon == "airstrike_mp" || weapon == "helicopter_mp" )
	return true;
	if ( weapon == "briefcase_bomb_mp" )
	return true;
	return false;
}

mayDropWeapon( weapon )
{
	if ( weapon == "none" )
	return false;

	//if ( level.cod_mode == "torneio" )
	//return false;

	if ( isHackWeapon( weapon ) )
	return false;

	invType = WeaponInventoryType( weapon );
	if ( invType != "primary" )
	return false;

	if ( isPrimaryWeapon( weapon ))
	{
		switch ( level.primary_weapon_array[weapon] )
		{
			case "weapon_assault":
				return ( level.class_assault_allowdrop );
			case "weapon_smg":
				return ( level.class_specops_allowdrop );
			case "weapon_sniper":
				return ( level.class_sniper_allowdrop );
			case "weapon_shotgun":
				return ( level.class_demolitions_allowdrop );
			case "weapon_lmg":
				return ( level.class_heavygunner_allowdrop );
		}
	}

	return true;
}

//globallogic //comprar antigmag
dropWeaponMagnetic(eAttacker)
{

	weapon = self getCurrentWeapon();

	if ( !isdefined( weapon ) )
	return;

	if ( weapon == "none" )
	return;
	
	if ( isdefined( self.droppedmagWeapon ) )
	return;

	if ( level.inGracePeriod )
	return;
	
	//armazena alguma muniçao no pente.
	//clipAmmo = self GetWeaponAmmoClip( weapon );
	
	//if ( !clipAmmo ){return;}
	
	
	item = self dropItem( weapon );
	
	self.droppedmagWeapon = true;
	//novo upgrade ?
	//seta quando de ammo este item tera dropad no chao
	//undefined is not an entity: 
	if(isDefined(item))
	{
		//item itemWeaponSetAmmo(20,10);		
		item.owner = self;		 
		//println("item.origin: " + item.origin);
		
		dropEnt = spawn( "script_model",item.origin);
		dropEnt setmodel("tag_origin");
		dropEnt.origin = item.origin;
		dropEnt.angles = item.angles;
		
		
		startpos = item.origin;
		wait 0.2;
		endpos = eAttacker.magposition;
		
		//magposition
		//iprintln("endpos " + endpos);
		weaponClass = "weapon_" + weapon;
	//	iprintln("weaponClass " + weaponClass);
		weapon = spawn( weaponClass, dropEnt.origin );
		weapon.angles = dropEnt.angles;
		weapon linkto( dropEnt );
		//moveto ( coordinate, moveTime, accel, decel );
		dropEnt moveto ( endpos , 0.2);		
		wait 0.3;
		dropEnt.origin = endpos;		
		toground = getmagdropGroundpoint(dropEnt);			
		//dropEnt moveGravity( ( 0, 50, 150 ), 100 );
		dropEnt.origin = toground;
		//item thread watchPickup();		
		dropEnt thread deletePickupAfterAWhile();	
	}
	
	
	/*
	ent = spawnstruct();
	ent thread smoke(owner,position,team);//update new position
	*/
	//entity 83 is not a script_brushmodel, script_model, script_origin, or light:
}

dropOffhandMagnetic(eAttacker)
{
	grenadeTypes = [];
	
	
	if (!level.inPrematchPeriod && !level.inStrategyPeriod ) 
	{
		grenadeTypes[grenadeTypes.size] = "frag_grenade_mp";
		//grenadeTypes[grenadeTypes.size] = "semtex_grenade_mp";
		grenadeTypes[grenadeTypes.size] = "smoke_grenade_mp";
		grenadeTypes[grenadeTypes.size] = "frag_grenade_short_mp";
		grenadeTypes[grenadeTypes.size] = "flash_grenade_mp";
	}

	for ( index = 0; index < grenadeTypes.size; index++ )
	{
		if ( !self hasWeapon( grenadeTypes[index] ) )
		continue;

		count = self getAmmoCount( grenadeTypes[index] );

		if ( !count )
		continue;

		// No matter how many grenades the player has it only drops one
		self setWeaponAmmoClip( grenadeTypes[index], 1 );
		item = self dropItem( grenadeTypes[index] );

		if(isDefined(item) && isDefined(eAttacker.magposition))
		{
			//item itemWeaponSetAmmo(20,10);		
			item.owner = self;		 
			//println("grenadeTypes.origin: " + item.origin);
			
			dropEnt = spawn( "script_model",item.origin);
			dropEnt setmodel("tag_origin");
			dropEnt.origin = item.origin;
			dropEnt.angles = item.angles;
			dropEnt moveGravity( ( 0, 50, 150 ), 100 );
			
			startpos = item.origin;
			wait 0.2;
			endpos = eAttacker.magposition;
			
			
			//iprintln("grenadeTypesendpos " +  );
			weaponClass = "weapon_frag_grenade_mp";
			weapon = spawn( weaponClass, dropEnt.origin );
			weapon setmodel("weapon_m67_grenade");
			weapon.angles = dropEnt.angles;
			weapon linkto( dropEnt );
			//item hide();
			//wait 1;
			//moveto ( coordinate, moveTime, accel, decel );
			dropEnt moveto ( endpos , 0.2);			
			wait 0.3;
			dropEnt.origin = endpos;
			toground = getmagdropGroundpoint(dropEnt);			
			dropEnt.origin = toground;
			
			//iprintln("grenadeTypesdropEnt " + dropEnt.origin);
			//wait 2;		
			//weapon unlink();
			//item delete();

			//weapon thread watchPickup();		
			dropEnt thread deletePickupAfterAWhile();	
		}		

		item thread deletePickupAfterAWhile();

	}
}

implodeNadefx(eAttacker)
{

	if ( isdefined( self.droppedmagWeapon ) )
	return;

	if ( level.inGracePeriod )
	return;
	
	//if(!isAlive(eAttacker))
	//return;
	
	victim = self;
	
	self.droppedmagWeapon = true;
	self.killedbyimplodernade = true;
	
	//println("victim.origin: " + victim.origin);
	wait 0.3;
	dropEnt = spawn( "script_model",self.origin);
	dropEnt setmodel("tag_origin");
	//dropEnt.origin = eAttacker.magposition;
	//dropEnt.angles = item.angles;
	//println("eAttacker.magposition: " + eAttacker.magposition);
	self linkto(dropEnt);
	//startpos = victim.origin;
	//dropEnt moveGravity( ( 0, 50, 150 ), 100 );
	wait 0.2;
	endpos = eAttacker.magposition;	
	
	//moveto ( coordinate, moveTime, accel, decel );
	if(isDefined(endpos))
	dropEnt moveto ( endpos +  (0, 0, -80), 0.3);
	else
	dropEnt moveto ( self.origin +  (0, 0, -80), 0.3);
	
	wait 0.3;
	if(isAlive(self))
	self finishPlayerDamage(eAttacker,eAttacker,900,0,"MOD_PROJECTILE_SPLASH","magnade_mp",self.origin,self.origin,"none",0);
	//dropEnt.origin = endpos;
	
	if(isDefined(dropEnt))
	dropEnt unlink();
	
	if(isDefined(dropEnt))
	dropEnt delete();
	
	//self suicide();	
	//wait 0.3;
	//self SetOrigin(endpos);	
	//self finishPlayerDamage(eAttacker,eAttacker,300,0,"MOD_PROJECTILE_SPLASH","magnade_mp",self.origin,self.origin,"none",0);
	
	if ( isDefined( self.body ) ) 
	{
		PlayFX( level.gibsparts,endpos);
		self.body delete();
		self.body = undefined;
	}
	
	//self.killedbyimplodernade = undefined;
	//toground = getmagdropGroundpoint(dropEnt);			
	//dropEnt moveGravity( ( 0, 50, 150 ), 100 );
	//dropEnt.origin = toground;
}


getmagdropGroundpoint( item )
{
	trace = bullettrace( item.origin, item.origin + (0,0,-128), false, item );
	groundpoint = trace["position"];
	
	finalz = groundpoint[2];
	
	for ( radiusCounter = 1; radiusCounter <= 3; radiusCounter++ )
	{
		radius = radiusCounter / 3.0 * 50;
		
		for ( angleCounter = 0; angleCounter < 10; angleCounter++ )
		{
			angle = angleCounter / 10.0 * 360.0;
			
			pos = item.origin + (cos(angle), sin(angle), 0) * radius;
			
			trace = bullettrace( pos, pos + (0,0,-128), false, item );
			hitpos = trace["position"];
			
			if ( hitpos[2] > finalz && hitpos[2] < groundpoint[2] + 10 )
				finalz = hitpos[2];
		}
	}
	return (groundpoint[0], groundpoint[1], finalz);
}

//reativado 5.3 - aprimoramento
dropWeaponForDeath( attacker )
{
	weapon = self getCurrentWeapon();
	
	//iprintln("Drop: " + weapon);//primary onlys

	if ( isdefined( self.droppedDeathWeapon ) )
	return;
	
	if ( isdefined( self.droppedmagWeapon ) )
	return;

	if ( level.inGracePeriod )
	return;

	if ( !isdefined( weapon ) )
	return;

	if ( weapon == "none" )
	return;
	
	//if ( !(self AnyAmmoForWeaponModes( weapon )) )
	//return;

	//armazena alguma muniçao no pente.
	clipAmmo = self GetWeaponAmmoClip( weapon );
	
	if ( !clipAmmo ){return;}

	//stockAmmo = self GetWeaponAmmoStock( weapon );
	//stockMax = WeaponMaxAmmo( weapon );
	//if ( stockAmmo > stockMax )
	//stockAmmo = stockMax;

	item = self dropItem( weapon );

	self.droppedDeathWeapon = true;
	//novo upgrade ?
	//seta quando de ammo este item tera dropad no chao
	if(isDefined(item))
	{
		item itemWeaponSetAmmo(clipAmmo,0);
		item itemRemoveAmmoFromAltModes();
		item.owner = self;
		item.ownersattacker = attacker;
		item thread watchPickup();
		item thread deletePickupAfterAWhile();
	}
}

deletePickupAfterAWhile()
{
	self endon("death");

	xwait(20, true );

	if ( !isDefined( self ) )
	return;

	self delete();
}

deletebypass()
{
	self endon("death");

	if ( !isDefined( self ) )
	return;

	self delete();
}

getItemWeaponName()
{
	classname = self.classname;
	assert( getsubstr( classname, 0, 7 ) == "weapon_" );
	weapname = getsubstr( classname, 7 );
	return weapname;
}

watchPickup()
{
	self endon("death");

	weapname = self getItemWeaponName();
	//iprintln ("Watchpickup " + weapname );
	
	while(1)
	{
		self waittill( "trigger", player, droppedItem );

		if ( isdefined( droppedItem ) )
		{
			//droppedItem delete();
			break;
		}
		
		// otherwise, player merely acquired ammo and didn't pick this up
	}
	
	//droppedItem delete();
	assert( isdefined( player.tookWeaponFrom ) );

	// make sure the owner information on the dropped item is preserved
	droppedWeaponName = droppedItem getItemWeaponName();
	if ( isdefined( player.tookWeaponFrom[ droppedWeaponName ] ) )
	{
		droppedItem.owner = player.tookWeaponFrom[ droppedWeaponName ];
		droppedItem.ownersattacker = player;
		player.tookWeaponFrom[ droppedWeaponName ] = undefined;
	}
	droppedItem thread watchPickup();
	droppedItem thread deletePickupAfterAWhile();

	// take owner information from self and put it onto player
	if ( isdefined( self.ownersattacker ) && self.ownersattacker == player )
	{
		player.tookWeaponFrom[ weapname ] = self.owner;
	}
	else
	{
		player.tookWeaponFrom[ weapname ] = undefined;
	}
}

itemRemoveAmmoFromAltModes()
{
	origweapname = self getItemWeaponName();

	curweapname = weaponAltWeaponName( origweapname );

	altindex = 1;
	while ( curweapname != "none" && curweapname != origweapname )
	{
		self itemWeaponSetAmmo( 0, 0, altindex );
		curweapname = weaponAltWeaponName( curweapname );
		altindex++;
	}
}
//globallogic 4973
dropOffhand()
{
	grenadeTypes = [];
	
	
	if (!level.inPrematchPeriod && !level.inStrategyPeriod ) 
	{
		grenadeTypes[grenadeTypes.size] = "frag_grenade_mp";
		grenadeTypes[grenadeTypes.size] = "semtex_grenade_mp";
		grenadeTypes[grenadeTypes.size] = "smoke_grenade_mp";
		grenadeTypes[grenadeTypes.size] = "frag_grenade_short_mp";
		grenadeTypes[grenadeTypes.size] = "flash_grenade_mp";
	}

	for ( index = 0; index < grenadeTypes.size; index++ )
	{
		if ( !self hasWeapon( grenadeTypes[index] ) )
		continue;

		count = self getAmmoCount( grenadeTypes[index] );

		if ( !count )
		continue;

		// No matter how many grenades the player has it only drops one
		self setWeaponAmmoClip( grenadeTypes[index], 1 );

		item = self dropItem( grenadeTypes[index] );
		//self iprintln("grenadeTypes[index]: " + grenadeTypes[index]);
		//item thread watchGrenadePickup( grenadeTypes[index] );

		item thread deletePickupAfterAWhile();
		//iprintln("item: " + item);
	}
}

watchGrenadePickup( grenadeType )
{
	self endon("death");
	
	while(1) 
	{
		self waittill( "trigger", player );
		
		// Check if need to activate martyrdom for this player again
		if ( ( grenadeType == level.weapons["frag_grenade_mp"] ) && isDefined( player.vengeance ) && player.vengeance ) 
		{
			player iprintln("hasFragsForMartyrdom: " + grenadeType);
			//player.hasFragsForMartyrdom = true;
			player setPerk( "specialty_grenadepulldeath" );
		}
	}
}

getWeaponBasedGrenadeCount(weapon)
{
	return 1;
}

getWeaponBasedSmokeGrenadeCount(weapon)
{
	return 1;
}

getFragGrenadeCount()
{
	grenadetype = "frag_grenade_mp";

	count = self getammocount(grenadetype);
	return count;
}

getSmokeGrenadeCount()
{
	grenadetype = "smoke_grenade_mp";

	count = self getammocount(grenadetype);
	return count;
}

getFlashGrenadeCount()
{
	grenadetype = "flash_grenade_mp";

	count = self getammocount(grenadetype);
	return count;
}

getConcussionGrenadeCount()
{
	grenadetype = "concussion_grenade_mp";

	count = self getammocount(grenadetype);
	return count;
}

watchWeaponUsage()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon ( "game_ended" );

	//self.firingWeapon = false;
	
	if(!self.isRanked) return;	
	
	for ( ;; )
	{
		self waittill ( "begin_firing" );

		if ( !level.inReadyUpPeriod )
		self.hasDoneCombat = true;

		//self.firingWeapon = true;

		curWeapon = self getCurrentWeapon();

		switch ( weaponClass( curWeapon ) )
		{
			case "rifle":
			case "pistol":
			case "smg":
			case "spread":
				self thread watchCurrentFiring( curWeapon );
				break;
			default:
				break;
		}
		self waittill ( "end_firing" );
		//self.firingWeapon = false;
	}
}

watchCurrentFiring( curWeapon )
{
	self endon("disconnect");

	//so tem 1 jogador..n tem por calcular
	//if(level.players.size < 2) return;
	
	startAmmo = self getWeaponAmmoClip( curWeapon );
	//starttimefire = gettime();	
	self waittill ( "end_firing" );	

	
	if ( !self hasWeapon( curWeapon ) )
	return;
	
	//if(BulletTracePassed( self.origin + (0,0,50), self.origin - (0,0,50), true, undefined))
	//self iprintln("wall?");
	
	shotsFired = startAmmo - (self getWeaponAmmoClip( curWeapon )) + 1;

	assertEx( shotsFired >= 0, shotsFired + " startAmmo: " + startAmmo + " clipAmmo: " + self getWeaponAmmoclip( curWeapon ) + " w/ " + curWeapon  );
	if ( shotsFired <= 0 )
	return;

		statTotal = shotsFired;
		statHits  =  self.hits;
		statMisses =  shotsFired - self.hits;
	
		//salva o total de hits - calcular no fim do mapa!
		//self.pers["weaponhits"] = statHits;
		//self.pers["weaponmiss"] = statHits;
		self.pers["accuracy"] += int(statHits * 100 / statTotal);
		//self setStat(2306,self.pers["accuracy"]);
		//self maps\mp\gametypes\_persistence::statSet( "accuracy", int(statHits * 10000 / statTotal) );
		
		self iprintln ("^2Hits: " + statHits + "  " +  "^1Misses: " + statMisses);
		
		
		self.hits = 0;
	
}

checkHit( sWeapon )
{
	// Hack for Airstrikes
	if ( sWeapon == "artillery_mp" )
	return;
	
	switch ( weaponClass( sWeapon ) )
	{
		case "rifle":
		case "pistol":
		case "mg":
		case "smg":
			self.hits++;
			break;
		case "spread":
			self.hits = 1;
			break;
		default:
			break;
	}
}

// returns true if damage should be done to the item given its owner and the attacker
friendlyFireCheck( owner, attacker, forcedFriendlyFireRule )
{
	if ( !isdefined(owner) ) // owner has disconnected? allow it
	return true;

	if ( !level.teamBased ) // not a team based mode? allow it
	return true;
	
	if(forcedFriendlyFireRule)
	return true;
	
	if (!isdefined(attacker.pers["team"])) // attacker not on a team? should not do ...
	return false;
	
	if ( attacker.pers["team"] == owner.pers["team"] ) // attacker not on the same team as the owner? allow it
	return false;
	
	if ( attacker.pers["team"] != owner.pers["team"] ) // attacker not on the same team as the owner? allow it
	return true;
	
	if(!isDefined(attacker.ffkiller))
	return false;
	
	if ( !attacker.ffkiller ) // friendly fire is off? block
	return false;
	
	if ( attacker.ffkiller ) // friendly fire is on? allow it
	return true;

	if ( attacker == owner ) // owner may attack his own items
	return true;	

	return false; // disallow it
}

watchGrenadeUsage()
{
	self endon( "death" );
	self endon( "disconnect" );

	self.throwingGrenade = false;
	self.gotPullbackNotify = false;
	
	self deleteExplosives();

	//thread watchC4();
	
	//thread watchC4Detonation();
	
	//thread watchC4AltDetonation();
	
	thread watchClaymores();
	
	thread deleteC4AndClaymoresOnDisconnect();

	//self thread watchForThrowbacks();

	for ( ;; )
	{
		self waittill ( "grenade_pullback", weaponName );

		if ( !level.inReadyUpPeriod )
		self.hasDoneCombat = true;

		if ( weaponName == "claymore_mp" )
		continue;
		
		self.throwingGrenade = true;
		self.gotPullbackNotify = true;

		if ( weaponName == "c4_mp" )
		self beginC4Tracking();
		else 
		{
			if ( level.inReadyUpPeriod ) 
			{
				self thread dontAllowSuicide();
			}
			
			self beginGrenadeTracking();
		}
	}
}

dontAllowSuicide()
{
	limitTime = gettime() + 3000;

	while ( self.throwingGrenade && limitTime > gettime() )
	wait level.oneFrame;

	if ( limitTime <= gettime() ) {
		self freezeControls( true ); xwait( 0.1, false );	self freezeControls( false );
	}

	return;
}
/*
	// grenades
	grenades = getentarray("grenade", "classname");
	for (i = 0; i < grenades.size; i++)
	{
		entpos = grenades[i].origin;
		dist = distance(pos, entpos);
		if (dist < radius && (!doLOS || weaponDamageTracePassed(pos, entpos, startRadius, grenades[i])))
		{
			newent = spawnstruct();
			newent.isPlayer = false;
			newent.isADestructable = false;
			newent.entity = grenades[i];
			newent.damageCenter = entpos;
			ents[ents.size] = newent;
		}
	}
*/


createfollownade()
{
	
	grenades = getentarray("grenade", "classname");
	
	for (i = 0; i < grenades.size; i++)
	{
		entpos = grenades[i].origin;
		newent = spawnstruct();
		newent.isPlayer = false;
		newent.isADestructable = false;
		newent.entity = grenades[i];
		newent.entity.owner = grenades[i].originalOwner;
		newent.entity.num = grenades[i] getentitynumber();
		level.killcamnade = newent.entity.num;
		level.killcamnadeattacker = newent.entity.owner;
		
		//'WEAPONS:[newent] -> ' and 'entity' has unmatching types 'string' and 'object'
		//iprintln("WEAPONS:[newent] -> " + newent.entity.owner.name);
		
		//iprintln("WEAPONS[newent.entity.num] -> " + newent.entity.num);
	}
}

beginGrenadeTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	if (isDefined( self.pers[ "isBot" ] ) && self.pers[ "isBot" ] )
		return;
	
	startTime = getTime();

	self waittill ( "grenade_fire", grenade, weaponName );

	if ( (getTime() - startTime > 1000) )
	grenade.isCooked = true;
	
	
	
	if ( weaponName == "magnade_mp" )
	{
		//self setStat(2389,0);//dono da nage reseta mag
		//self setStat(2407,0);//usou e reseta imploder
		
		grenade thread magdetonate(self);
	
		//iprintln("magnade_mp-> " + grenade.origin);
		//grenade thread createfollownade();
		
	}
	
	if ( weaponName == "frag_grenade_mp" )
	{
		
		grenade.originalOwner = self;		
		grenade thread createfollownade();
		grenade thread maps\mp\gametypes\_shellshock::grenade_earthQuake();		
	}
	//hatchet
	if ( weaponName == "frag_grenade_short_mp" )
	{
		
		//iprintln("WEAPONS:[weaponName] -> "+ weaponName);
		//iprintln("WEAPONS:[newent] -> "+ grenade getentitynumber());
		
		grenade.originalOwner = self;		
		
		grenade thread createfollownade();
		
		//grenade thread StuckItem(startTime);
	}
	

	if ( weaponName == "decoy_grenade_mp" )
	{
		grenade.originalOwner = self;
		if(level.players.size > 3 && !isdefined(self.droppeddecoy))
		{	   
		   wait 3;
		   self thread CreateObjectFiring(grenade);
		}
	}
	
	if ( weaponName == "tear_grenade_mp" )
	{
		self setStat(2388,0);		
		//quem é o dono da nade e seu time
		grenade thread tearGrenade_think(self,self.pers["team"]);
	}
	
	if ( weaponName == "smoke_grenade_mp" )
	{	
		if(level.cod_mode != "torneio")
		grenade thread smokeGrenade_think(self,self.pers["team"]);
	}
	
	if ( weaponName == "semtex_grenade_mp" )
	{
		//if(level.players.size >= 6)
		//{
			grenade.originalOwner = self;
			//grenade thread StuckItem(startTime);			
		//}
	}
	//SnapShotG
	if ( weaponName == "concussion_grenade_mp" )
	{
			grenade.originalOwner = self;
			grenade thread SnapshotShow(grenade.originalOwner);
	}
	
	//if ( weaponName == "gl_m16_mp" )
	//{
		//iprintln("testessssssssssss");
		//grenade thread firearrow_think(self,self.team);
	//}
	
	self.throwingGrenade = false;
}


//=======================SNAPSHOT GRENADE=================
SnapshotShow(owner)
{
	
	self waittill( "explode", position );
	
	players = getEntArray( "player", "classname" );
		
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		if(!isAlive(player)) continue;
		
		if(player == owner) continue;
		
		if(player.pers["team"] == owner.pers["team"]) continue;
		
		dist = distance(player.origin, position);
		
		if(dist > 400) continue;
		
		player thread SnapshotReveal();
	}
}

SnapshotReveal()
{
	self endon("disconnect");
	self endon("death");

	self thread promatch\_markplayer::spotPlayer(3,false);
}

//=======================FIREARROW========================
firearrow_think(owner,team)
{
	self waittill( "explode", position );
		
	ent = spawnstruct();
	ent thread firethread(owner,position,team);//update new position
}

firethread(owner,position,team)
{
	self endon("firearrow_timeout");

	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
	return;

	if(!isDefined(team)) return;
	
	if(!isDefined(self)) return;
	
	pos = position;
	
	if(!isDefined(pos))
	{
		return;
	}
	//iprintln("smokenade spawn2:" + pos);
	
	
	arrowtrigger = spawn("trigger_radius", pos, 0, 120, 120);
	
	if(!isDefined(arrowtrigger)) return;
	
	thread firetimedout(arrowtrigger);
	
	while(1)
	{
		arrowtrigger waittill("trigger", player);
		
		if(!isDefined(player)) continue;
		
		if(!isDefined(owner)) continue;
		
		if (player.sessionstate != "playing")
		continue;
		
		if (player == owner)
		continue;
		
		if(player.pers["team"] == owner.pers["team"]) continue;
		
		if( !player isTouching( arrowtrigger) )
		continue;

		owner dodamage(player,30);
		
		/*if (!isdefined(player.firesuffering))
		{	
			player.firesuffering = true;
			player thread firesuffering();
			player thread firetimedout();
		}*/
	}
}

firesuffering()
{
	self endon("death");
	self endon("disconnect");	
	
	while(1)
	{
		wait 1;
		dodamage(self,30);
	}
		
	self.firesuffering = undefined;
	
}

firetimedout(arrowtrigger)
{
	wait 2;
	
	if(isDefined(arrowtrigger))
	arrowtrigger delete();
	
	//iprintln("^3firearrow_timeout");
	
	self notify("firearrow_timeout");
}

//=======================SMOKE========================
smokeGrenade_think(owner,team)
{
	self waittill( "explode", position );
		
	ent = spawnstruct();
	ent thread smoke(owner,position,team);//update new position
}



smoke(owner,position,team)
{
	self endon("smoke_timeout");

	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
	return;

	if(!isDefined(team)) return;
	
	if(!isDefined(self)) return;
	
	pos = position;
	
	if(!isDefined(pos))
	{
		return;
	}
	
	//iprintln("smokenade spawn2:" + pos);

	
	smoketrigger = spawn("trigger_radius", pos, 0, 220, 120);
	
	//starttime = gettime();
	
	if(!isDefined(smoketrigger)) return;
	
	thread smoketimer(smoketrigger);
	
	/*
	level.graysmoke = loadfx ("props/graysmoke");//gas
	level.greensmoke = loadfx ("props/greensmoke");//gas
	level.orangesmoke = loadfx ("props/orangesmoke");//gas
	level.bluesmoke = loadfx ("props/bluesmoke");//gas
	level.redsmoke = loadfx ("props/redsmoke");//gas
	*/
	if(isDefined(owner.greensmoke))
	playfx(level.greensmoke, pos);
	
	if(isDefined(owner.orangesmoke))
	playfx(level.orangesmoke, pos);
	
	if(isDefined(owner.bluesmoke))
	playfx(level.bluesmoke, pos);
	
	if(isDefined(owner.redsmoke))
	playfx(level.redsmoke, pos);
	
	if(isDefined(owner.graysmoke))
	playfx(level.graysmoke, pos);
	
	while(1)
	{
		smoketrigger waittill("trigger", player);
		
		if(!isDefined(player)) continue;
		
		if (player.sessionstate != "playing")
		continue;
		
		if (!isdefined(player.insidesmoke))
		{
			player.insidesmoke = true;
			//iprintln("smokenade insidesmoke:" + player.insidesmoke);
			
			if(player != self)
			player.smokeowner = owner;
			
			player thread insidesmoke();			
		}
		
		if(player.gasmask > 0)
		continue;
		
		//if(player.medicpro)
		//continue;
		
		if( !player isTouching( smoketrigger) )
		continue;

		//guarda o inicio do efeito da smoke no jgador
		player.smokegasstarttime = gettime(); 
		
		if (!isdefined(player.smokegassuffering))
		{	
			//aqui! se o jogador esta platando a bomb e jogaram smoke nele quem jogou ganha ponto de suporte
			//iprintln("smokegassuffering insidesmoke:" + player.insidesmoke);
			player.smokegassuffering = true;
			player thread smokegassuffering();
			player thread smokecoughing();
			player thread smokegassufferingreset();
		}
	}
}
//nao pode ser spotado dentro da fumaca
insidesmoke()
{
	self endon("disconnect");	
	//self waittill( "death");	
	wait 9;
	self.insidesmoke = undefined;
}
//caso o jogador morra resetar para n ficar borrada a tela
smokegassufferingreset()
{
	self endon( "smoke_timeout" );
	self endon("disconnect");
	
	self waittill( "death");
	
	self.smokegassuffering = undefined;
	self setClientDvar( "r_blur", 0 );

}

smoketimer(smoketrigger)
{
	wait level.smokefillduration;
	
	if(isDefined(smoketrigger))
	smoketrigger delete();
	
	//iprintln("^3Tear expired");
	self notify("smoke_timeout");
}

smokecoughing()
{
	self endon("death");
	self endon("disconnect");
	
	while(1)
	{
		wait 1;
		
		//tempo atual dentro do trigger - tempo que o iniciou o efeito > 1s apos sair do trigger
		if (gettime() - self.smokegasstarttime > 1 * 1000)
		break;
		
		self playSound( "smoke_coughing_loop" );
		wait 5;
	}
	
	self playSound( "smoke_coughing_out" );
}

smokegassuffering()
{
	self endon("death");
	self endon("disconnect");	
	
	while(1)
	{
		wait 1;
		//tempo atual dentro do trigger - tempo que o iniciou o efeito > 1s apos sair do trigger
		if (gettime() - self.smokegasstarttime > 1 * 1000)
		break;
		
		self setClientDvar( "r_blur", 2);
		wait 1;
		self setClientDvar( "r_blur", 4 );	
		wait 1;		
		self setClientDvar( "r_blur", 5 );	
		wait 1;		
		//self setClientDvar( "r_blur", 8 );
	}

	self setClientDvar( "r_blur", 3 );
	wait 1;	
	self setClientDvar( "r_blur", 2 );
	wait 1;	
	//self setClientDvar( "r_blur", 2 );
	//wait 1;		
	self.smokegassuffering = undefined;
	self setClientDvar( "r_blur", 0 );
}

//=======================SMOKE END========================

//=======================TEARGAS========================

tearGrenade_think(owner,team)
{
	// wait for death
	
	// (grenade doesn't actually die until finished smoking)
	//wait level.teargrenadetimer;
	self waittill( "explode", position );
	
	wait 2; // tempo para ela preencher o local de gas
	
	ent = spawnstruct();
	ent thread tear(owner,position,team);//update new position
}



tear(owner,position,team)
{
	//iprintln("tearnade spawn:" + self.origin);
	self endon("tear_timeout");

	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
	return;
	
	currad = level.tearradius;
	curheight = level.tearheight;
		
	if(isDefined(owner.upgradeteargas) && owner.upgradeteargas > 0)
	currad = level.tearradius * 2;
		
	if(!isDefined(team)) return;
	
	if(!isDefined(self)) return;
	
	pos = position;
	
	if(!isDefined(pos))
	{
		//logerror("TEARNADEERROR POS");
		return;
	}
	//iprintln("tearnade spawn2:" + pos);
	
	
	teartrigger = spawn("trigger_radius", pos, 0, level.tearradius, level.tearheight);
	starttime = gettime();
	
	if(!isDefined(teartrigger)) return;
	
	thread teartimer(teartrigger);
	
	while(1)
	{
		teartrigger waittill("trigger", player);
		
		if(!isDefined(player)) continue;
		
		if (player.sessionstate != "playing")
		continue;
		
		//if(player.pers["team"] == team )
		//continue;
		
		if(player.gasmask > 0)
		continue;
		
		if( !player isTouching( teartrigger) )
		continue;

		
		player.teargasstarttime = gettime(); 
		
		//struct is not an entity - fixed
		if (!isdefined(player.teargassuffering))
		{
			player.teargassuffering = true;
			player shellshock("frag_grenade_mp", 10);
			player thread teargascoughing();
		}
	}
}


teartimer(teartrigger)
{
	wait level.teargasduration;
	
	if(isDefined(teartrigger))
	teartrigger delete();
	
	//iprintln("^3Tear expired");
	self notify("tear_timeout");
}

teargascoughing()
{
	self endon("death");
	self endon("disconnect");
	
	while(1)
	{
		wait 1;
		
		//tempo atual dentro do trigger - tempo que o iniciou o efeito > 1s apos sair do trigger
		if (gettime() - self.teargasstarttime > 1 * 1000)
		break;
		
		self playSound( "smoke_coughing_loop" );
		wait 5;
	}
	
	self playSound( "smoke_coughing_out" );
}

teargassuffering()
{
	self endon("death");
	self endon("disconnect");
		
	while(1)
	{

		//todo contrato GasDamage - usar na incendiaria?
		//self RadiusDamage( self.origin, 140, 30, 10, self.owner, "MOD_EXPLOSIVE", "flash_grenade_mp" );
		//iprintln("^3SHELLSHOCK 2");
		self shellshock("frag_grenade_mp", 2);
		
		if (gettime() - self.teargasstarttime > level.tearsufferingduration * 1000)
			break;
		
		wait 1;
	}
	
	self.teargassuffering = undefined;
}

//=======================TEARGAS END========================
magdetonate(owner)
{	

	//self waittill( "magdetonate",position,attacker);
	//self waittill( "detonate", position);
	//self waittill("explode",position);
	
	//iprintln("magdetonate-> " + owner.origin);
	
	while(1)
	{
		self waittill( "death", position);
		
		owner.magposition = self.origin;//salva a posi ondem explod
		//iprintln("magposition-> " + owner.magposition);
		if(isDefined(owner.implodernade))
		{
			self playSound( "implodernadefx");
			PlayFX( level.implodernadefx,self.origin);
			PlayFX( level.fx_Sparks,self.origin);			
			PlayFX( level.fataheadhitfx,self.origin);
		}
		
		break;
	}	
}


/*
//globallogic //comprar antigmag
dropWeaponMagnetic()
{

	weapon = self getCurrentWeapon();

	if ( !isdefined( weapon ) )
	return;

	if ( weapon == "none" )
	return;
	
	if ( isdefined( self.droppedmagWeapon ) )
	return;

	if ( level.inGracePeriod )
	return;
	
	//armazena alguma muniçao no pente.
	//clipAmmo = self GetWeaponAmmoClip( weapon );
	
	//if ( !clipAmmo ){return;}
	
	item = self dropItem( weapon );

	self.droppedmagWeapon = true;
	//novo upgrade ?
	//seta quando de ammo este item tera dropad no chao
	//undefined is not an entity: 
	if(isDefined(item))
	{
		item itemWeaponSetAmmo(20,10);
		//item itemRemoveAmmoFromAltModes();
		item.owner = self;
		item thread watchPickup();
		
		
		item thread deletePickupAfterAWhile();
	}
}
*/
endOnXplode()
{
	self waittill( "death" );
	waittillframeend;
	self notify ( "end_xplode" );
}

StuckItem(timer,victim, sHitLoc, vDir,sWeapon)
{
	self endon("death");
	level endon("game_ended");
	
	//self waittill ("itemstuckonplayer", victim, sHitLoc, vDir,sWeapon);

	if( !isDefined( victim ) )
	return;

	if( !isDefined( self ) )
	return;

	//undefined is not a field object: (file 'maps/mp/gametypes/_weapons.gsc', line 1539)
	//if(!isdefined(victim.team) || !isdefined(self.originalOwner.team))
	 
	if(!isdefined(victim.team) )
	return;
	
	if(!isdefined(self.originalOwner) )
	return;

	
	//undefined is not a field object: (file 'maps/mp/gametypes/_weapons.gsc', line 1552)
	//if(victim.team == self.originalOwner.team)	 
	if(victim.team == self.originalOwner.team)
	return;
	
		
   // if(level.showdebug)
	//iprintln("^1StuckSemtex[sWeapon]: " + sWeapon );

	
	if( isDefined( self.originalOwner ) )
	{
		if(sWeapon == "semtex_grenade_mp")
		{
			level thread playStreakBonus( "humiliation","Semtex Coladinha", self.originalOwner.name +" grudou na bunda do " + victim.name);		
			self.originalOwner thread GiveEVP(100,100);
			
			if( isDefined( victim) )
			self thread stuckonPlayer(victim, sHitLoc, timer,sWeapon);
		}
		
		if(sWeapon == "frag_grenade_short_mp")
		{
			if( isDefined( victim) )
			self thread stuckonPlayer(victim, sHitLoc, timer,sWeapon);
		}
	}

	

}

stuckonPlayer(victim, sHitLoc, timer,sWeapon)
{
	level endon("game_ended");
	self endon("exploded");
	self endon("death");
	
	victim endon("death");
	victim endon("disconnect");
	
	if(!isDefined(sWeapon))
		return;
	
	//pair 'undefined' and 'frag_grenade_short_mp' has unmatching types 'undefined' and 'string'
	if(sWeapon == "frag_grenade_short_mp")
	{
		//iprintln("^1stuckonPlayer[sWeapon]: " + sWeapon );
		self.origin = victim getTagOrigin("tag_stowed_hip_rear");
		return;
	}
	
	self.origin = victim getTagOrigin("tag_stowed_hip_rear");
	//iprintln("^1StuckSemtex[getTagOrigin]: " + self.origin );	
	
	//pode ser usado para grudar algo e esconder no corpo do alvo
	timeddetonate = 0;
	while( isDefined(victim) && isAlive(victim) && victim.sessionstate == "playing" )
	{
		self.origin = victim getTagOrigin("tag_stowed_hip_rear");
		self hide();
		wait level.oneframe;		
		timeddetonate++;
		
		//iprintln("^1StuckSemtex[timeddetonate]: " + timeddetonate );	
		
		if(timeddetonate == 30)
		{
			self detonate();
			break;
		}	
	}
	
	//self hide();
	//wait 0.5;	
	//self detonate();
}

beginC4Tracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	self waittill_any ( "grenade_fire", "weapon_change" );
	self.throwingGrenade = false;
}

watchForThrowbacks()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	for ( ;; )
	{
		self waittill ( "grenade_fire", grenade, weapname );
		if ( self.gotPullbackNotify )
		{
			self.gotPullbackNotify = false;
			continue;
		}
		if ( !isSubStr( weapname, "frag_" ) )
		continue;

		// no grenade_pullback notify! we must have picked it up off the ground.
		grenade.threwBack = true;

		grenade thread maps\mp\gametypes\_shellshock::grenade_earthQuake();
		grenade.originalOwner = self;
	}
}

watchC4()
{
	self endon( "spawned_player" );
	self endon( "disconnect" );

	//maxc4 = 2;

	while(1)
	{
		self waittill( "grenade_fire", c4, weapname );
		if ( weapname == "c4" || weapname == "c4_mp" )
		{
			if ( !self.c4array.size )
			self thread watchC4AltDetonate();

			self.c4array[self.c4array.size] = c4;
			c4.owner = self;
			
			if ( level.teamBased )
			c4.targetname = "c4_mp_" + self.pers["team"];
			c4.activated = false;

			c4 thread maps\mp\gametypes\_shellshock::c4_earthQuake();
			c4 thread c4Activate();
			c4 thread c4Damage();
			c4 thread c4DetectionTrigger( self.pers["team"] );
			
			//self setStat(2391,self getWeaponAmmoClip("c4_mp"));
		}
	}
}


watchClaymores()
{
	self endon( "spawned_player" );
	self endon( "disconnect" );

	self.claymorearray = [];
	while(1)
	{
		self waittill( "grenade_fire", claymore, weapname );
		if ( weapname == "claymore" || weapname == "claymore_mp" )
		{			
			self.claymorearray[self.claymorearray.size] = claymore;
			claymore.owner = self;
			claymore.teamside = self.pers["team"];
			claymore.planttime = promatch\_timer::getTimePassed();
			
			if ( level.teamBased )
			claymore.targetname = "claymore_mp_" + self.pers["team"];
					
			//DANO POR BALAS OU EXPLOSIVOS
			claymore thread c4Damage();
			
			//AO PASSAR POR ELA.
			claymore thread claymoreDetonation();
		
			//AVISO AO SQUAD
			claymore thread claymoreDetectionTrigger_wait( self.pers["team"] );
			
			//self statSets("claymore_mp",self getWeaponAmmoClip("claymore_mp"));
			self setStat(2393,self getWeaponAmmoClip("claymore_mp"));
		}
	}
}

waitTillNotMoving()
{
	prevorigin = (0,0,0);
	while( isDefined( self ) )
	{
		if ( self.origin == prevorigin )
		break;

		prevorigin = self.origin;
		xwait( .15, false );
	}
}
//DETONAÇAO AUTOMATICA AO PASSAR POR ELA.
claymoreDetonation()
{
	//controla o explosivo caso alguem passe por ele.
	self endon("death");

	self waitTillNotMoving();

	damagearea = spawn("trigger_radius", self.origin + (0,0,0-level.claymoreDetonateRadius), 0, level.claymoreDetonateRadius, level.claymoreDetonateRadius*2);
	self thread deleteOnDeath( damagearea );

	
	while(1)
	{
		damagearea waittill("trigger", player);

		if ( promatch\_timer::getTimePassed() - self.planttime < 3000 )
		continue;
	
		if ( isdefined( self.owner ) && player == self.owner )
		continue;
		
		if(!isDefined(self.owner))
		continue;
		
		if ( !friendlyFireCheck( self.owner, player, false ) )
		continue;
		
		//clayignore - cannot cast undefined to bool
		if(isDefined(player.coldblooded) && player.coldblooded)
		continue;
		
		//mudar o sistema de como isso funciona para desarmar?
		//if(isDefined(player.notarget) && player.notarget)
		//continue;
		
		//controla se o jogador esta se movimentando
		if ( lengthsquared( player getVelocity() ) < 10 )
		continue;

		if ( !player shouldAffectClaymore( self ) )
		continue;
	
		//chamando a marcao por mim e nao no jogador.
		if(isDefined(self.owner) && isAlive(player))
		self.owner SensorpointOutPlayer( player);
		
		for ( index = 0; index < level.players.size; index++ ) 
		{
			meutime = level.players[index];
		
			if ( !isDefined( meutime ) || !isDefined( meutime.pers ))
				continue;
				
			if(meutime.pers["team"] != self.owner.pers["team"] )
				continue;
								
			if ( ( meutime.sessionstate == "dead" || meutime.sessionstate == "spectator" ))
				continue;
				
			meutime iprintln("^1##^3Movimentos detectados^1##");
			
		}
		
		wait 5;
	}

	if(isDefined(self.owner))
	self.owner thread rebuildExplosiveArray();
	
	//self detonate();
}

SensorpointOutPlayer( player)
{
	player endon("death");
	player endon("disconnect");
	
	if ( isDefined( player.sensorpointOut ) && player.sensorpointOut )
	return;
	
	player.sensorpointOut = true;
	origin = player.origin;
	
	warnicon = newTeamHudElem( level.otherTeam[player.pers["team"]] );
	warnicon.name = "sensor_" + player getEntityNumber();
	warnicon.x = origin[0];
	warnicon.y = origin[1];
	warnicon.z = origin[2] + 54;
	warnicon.baseAlpha = .61;
	warnicon setShader("waypoint_kill", 14, 14);
	warnicon setWayPoint(true,"waypoint_kill");
	
	//iprintln(self.upgradesensorseeker);
	
	if(isDefined(self) && self.upgradesensorseeker > 0)
	warnicon setTargetEnt( player );
	
	player thread deletewarniconOnDD(warnicon);
	player thread deletewarniconOnTimer(warnicon);
	
}

deletewarniconOnTimer(warnicon)
{
	self endon( "death" );

	wait (4);
	
	// Make sure this player can be pointed out again
	if ( isDefined( self ) )
		self.sensorpointOut = false;


	self notify("warnicon_timedout");
	
	//removed entity is not an entity:
	if(isDefined(self))
	{
		warnicon ClearTargetEnt();
		warnicon destroy();
	}
}

deletewarniconOnDD(warnicon)
{
	self endon( "warnicon_timedout" );
	
	self waittill_any( "killed_player", "disconnect" );
	
	// Make sure this player can be pointed out again
	if ( isDefined( self ) )
	self.sensorpointOut = false;
		
	// Wait some time to make sure the main loop ends
	wait (0.2);
	
	warnicon ClearTargetEnt();
	warnicon destroy();
}

ClaydestroySlowly()
{
	self endon("death");
	
	self fadeOverTime(1.0);
	self.alpha = 0;
	
	xwait(1.0,false);
	self destroy();
}


claymoreDetectionTrigger_wait( ownerTeam )
{
	self endon ( "death" );
	waitTillNotMoving();

	if ( level.oldschool )
	return;

	self thread claymoreDetectionTrigger( ownerTeam );
}

claymoreDetectionTrigger( ownerTeam )
{
	trigger = spawn( "trigger_radius", self.origin-(0,0,128), 0, 512, 256 );
	trigger.detectId = "trigger" + getTime() + randomInt( 1000000 );

	trigger thread detectIconWaiter( level.otherTeam[ownerTeam] );

	self waittill( "death" );
	trigger notify ( "end_detection" );

	if ( isDefined( trigger.bombSquadIcon ) )
	trigger.bombSquadIcon destroy();

	trigger delete();
}


detectIconWaiter( detectTeam )
{
	self endon ( "end_detection" );
	level endon ( "game_ended" );

	while( !level.gameEnded )
	{
		self waittill( "trigger", player );

		if ( !isDefined( player ) || !isDefined( player.sitrep ) || !player.sitrep )
		continue;

		if ( player.team != detectTeam && level.scr_claymore_friendly_fire == 0 )
		continue;

		if ( isDefined( player.bombSquadIds[self.detectId] ) )
		continue;

		player thread showHeadIcon( self );

	}
}

shouldAffectClaymore( claymore )
{
	pos = self.origin + (0,0,32);

	dirToPos = pos - claymore.origin;
	claymoreForward = anglesToForward( claymore.angles );

	dist = vectorDot( dirToPos, claymoreForward );
	if ( dist < level.claymoreDetectionMinDist )
	return false;

	dirToPos = vectornormalize( dirToPos );

	dot = vectorDot( dirToPos, claymoreForward );
	return ( dot > level.claymoreDetectionDot );
}

deleteOnDeath(ent)
{
	self waittill("death");
	wait level.oneFrame;
	if ( isdefined(ent) )
	{
		ent delete();
	}
}

c4Activate()
{
	self endon("death");

	self waittillNotMoving();

	wait level.oneFrame;

	self notify("activated");
	self.activated = true;
}

watchC4AltDetonate()
{
	self endon("death");
	self endon( "disconnect" );
	self endon( "detonated" );
	level endon( "game_ended" );

	buttonTime = 0;
	for( ;; )
	{
		if ( self UseButtonPressed() )
		{
			buttonTime = 0;
			while( self UseButtonPressed() )
			{
				buttonTime += 0.05;
				xwait( 0.05, false );
			}

			println( "pressTime1: " + buttonTime );
			if ( buttonTime >= 0.5 )
			continue;

			buttonTime = 0;
			while ( !self UseButtonPressed() && buttonTime < 0.5 )
			{
				buttonTime += 0.05;
				xwait( 0.05, false );
			}

			println( "delayTime: " + buttonTime );
			if ( buttonTime >= 0.5 )
			continue;

			if ( !self.c4Array.size )
			return;

			self notify ( "alt_detonate" );
		}
		wait level.oneFrame;
	}
}

watchC4Detonation()
{
	self endon("death");
	self endon("disconnect");

	while(1)
	{
		self waittill( "detonate" );
		weap = self getCurrentWeapon();
		if ( weap == "c4_mp" )
		{
			newarray = [];
			for ( i = 0; i < self.c4array.size; i++ )
			{
				c4 = self.c4array[i];
				if ( isdefined(self.c4array[i]) )
				{
					c4 thread waitAndDetonate( 0.1 );
				}
			}
			self.c4array = newarray;
			self notify ( "detonated" );
		}
	}
}


watchC4AltDetonation()
{
	self endon("death");
	self endon("disconnect");

	while(1)
	{
		self waittill( "alt_detonate" );
		weap = self getCurrentWeapon();
		if ( weap != "c4_mp" || weap != "claymore_mp" )
		{
			newarray = [];
			for ( i = 0; i < self.c4array.size; i++ )
			{
				c4 = self.c4array[i];
				if ( isdefined(self.c4array[i]) )
				c4 thread waitAndDetonate( 0.1 );
			}
			self.c4array = newarray;
			self notify ( "detonated" );
		}
	}
}


waitAndDetonate( delay )
{
	self endon("death");
	xwait( delay, false );

	self.owner thread rebuildExplosiveArray();
	self detonate();
}

deleteC4AndClaymoresOnDisconnect()
{
	self endon("death");
	self waittill("disconnect");

	c4array = self.c4array;
	claymorearray = self.claymorearray;

	wait level.oneFrame;

	for ( i = 0; i < c4array.size; i++ )
	{
		if ( isdefined(c4array[i]) )
		c4array[i] delete();
	}
	for ( i = 0; i < claymorearray.size; i++ )
	{
		if ( isdefined(claymorearray[i]) )
		{
			if ( isdefined( claymorearray[i].warnicon ) )
			claymorearray[i].warnicon destroy();
			
			claymorearray[i] delete();
		}
	}
}

c4Damage()
{
	self endon( "death" );

	self setcandamage(true);
	self.maxhealth = 100000;
	self.health = self.maxhealth;

	attacker = undefined;

	while(1)
	{
		self waittill ( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, iDFlags );
		
		if ( !isplayer(attacker) )
		continue;

		// don't allow people to destroy C4 on their team if FF is off
		//if ( !friendlyFireCheck( self.owner, attacker ) )
		//continue;

		if ( damage > 100 ) // ignore explosives
		continue;

		break;
	}

	if ( level.c4explodethisframe )
	xwait( 0.1 + randomfloat(0.4), false );
	else
	wait level.oneFrame;

	if (!isdefined(self))
	return;

	//remove o icone de aviso da claymore
	if ( isdefined( self.warnicon ) )
	self.warnicon destroy();
			
	level.c4explodethisframe = true;

	thread resetC4ExplodeThisFrame();

	//funciona para explosivos em geral
	if ( isDefined( type ) && (isSubStr( type, "MOD_GRENADE" ) || isSubStr( type, "MOD_EXPLOSIVE" )) )
	self.wasChained = true;

	if ( isDefined( iDFlags ) && (iDFlags & level.iDFLAGS_PENETRATION) )
	self.wasDamagedFromBulletPenetration = true;

	self.wasDamaged = true;

	// "destroyed_explosive" notify, for challenges
	if ( isdefined( attacker ) && isdefined( attacker.pers["team"] ) && isdefined( self.owner ) && isdefined( self.owner.pers["team"] ) )
	{
		if ( attacker.pers["team"] != self.owner.pers["team"] )
		attacker notify("destroyed_explosive");
	}

	self.owner thread rebuildExplosiveArray();
	
	
	if(isDefined(self.owner.upgradesensorgas) && self.owner.upgradesensorgas)
	{
		ent = spawnstruct();
		ent thread tear(self.owner,self.origin,self.owner.pers["team"]);//update new position
		playfx(level.smokegas, self.origin);
		self playSound("gas2");
	}		
	//destruido por: attacker
	self detonate( attacker );
	
	
	// won't get here; got death notify.
}

rebuildExplosiveArray()
{
	self endon("disconnect");
	self endon("death");

	xwait( 0.1, false );

	newarray = [];
	if ( isDefined ( self.c4array ) ) {
		for ( i = 0; i < self.c4array.size; i++ )
		{
			if ( isdefined(self.c4array[i]) )
			newarray[newarray.size] = self.c4array[i];
		}
	}
	if ( isDefined( self ) )
	self.c4array = newarray;

	newarray = [];
	if ( isDefined( self.claymorearray ) ) {
		for ( i = 0; i < self.claymorearray.size; i++ )
		{
			//if ( isdefined( self.claymorearray[i].warnicon ) )
			//	self.claymorearray[i].warnicon destroy();
			
			if ( isdefined(self.claymorearray[i]) )
			newarray[newarray.size] = self.claymorearray[i];
		}
	}
	if ( isDefined( self ) )
	self.claymorearray = newarray;
}

resetC4ExplodeThisFrame()
{
	wait level.oneFrame;
	level.c4explodethisframe = false;
}

saydamaged(orig, amount)
{
	for (i = 0; i < 60; i++)
	{
		print3d(orig, "damaged! " + amount);
		wait level.oneFrame;
	}
}

playC4Effects()
{
	self endon("death");
	self waittill("activated");

	while(1)
	{
		org = self getTagOrigin( "tag_fx" );
		ang = self getTagAngles( "tag_fx" );

		fx = spawnFx( level.C4FXid, org, anglesToForward( ang ), anglesToUp( ang ) );
		triggerfx( fx );

		self thread clearFXOnDeath( fx );

		originalOrigin = self.origin;

		while(1)
		{
			xwait( 0.25, false );
			if ( self.origin != originalOrigin )
			break;
		}

		fx delete();
		self waittillNotMoving();
	}
}


c4DetectionTrigger( ownerTeam )
{
	if ( level.oldschool )
	return;

	self waittill( "activated" );

	trigger = spawn( "trigger_radius", self.origin-(0,0,128), 0, 512, 256 );
	trigger.detectId = "trigger" + getTime() + randomInt( 1000000 );

	trigger thread detectIconWaiter( level.otherTeam[ownerTeam] );

	self waittill( "death" );
	trigger notify ( "end_detection" );

	if ( isDefined( trigger.bombSquadIcon ) )
	trigger.bombSquadIcon destroy();

	trigger delete();
}


showHeadIcon( trigger )
{
	
	if(!isDefined(trigger))
		return;
		
	triggerDetectId = trigger.detectId;
	useId = -1;
	for ( index = 0; index < 4; index++ )
	{
	
		if(!isDefined(self.bombSquadIcons))
		return;
		
		if(!isDefined(self.bombSquadIcons[index]))
		return;
		
		detectId = self.bombSquadIcons[index].detectId;

		if(!isDefined(detectId))
		return;
		
		if(!isDefined(triggerDetectId))
		return;		
		
		if ( detectId == triggerDetectId )
		return;

		if ( detectId == "" )
		useId = index;
	}

	if ( useId < 0 )
	return;

	self.bombSquadIds[triggerDetectId] = true;

	self.bombSquadIcons[useId].x = trigger.origin[0];
	self.bombSquadIcons[useId].y = trigger.origin[1];
	self.bombSquadIcons[useId].z = trigger.origin[2]+24+128;

	self.bombSquadIcons[useId] fadeOverTime( 0.25 );
	self.bombSquadIcons[useId].alpha = 1;
	self.bombSquadIcons[useId].detectId = trigger.detectId;

	while ( isAlive( self ) && isDefined( trigger ) && self isTouching( trigger ) )
	wait level.oneFrame;

	if ( !isDefined( self ) )
	return;

	self.bombSquadIcons[useId].detectId = "";
	self.bombSquadIcons[useId] fadeOverTime( 0.25 );
	self.bombSquadIcons[useId].alpha = 0;
	self.bombSquadIds[triggerDetectId] = undefined;
}


playClaymoreEffects()
{
	self endon("death");

	while(1)
	{
		self waittillNotMoving();

		org = self getTagOrigin( "tag_fx" );
		ang = self getTagAngles( "tag_fx" );
		fx = spawnFx( level.claymoreFXid, org, anglesToForward( ang ), anglesToUp( ang ) );
		triggerfx( fx );

		self thread clearFXOnDeath( fx );

		originalOrigin = self.origin;

		while(1)
		{
			xwait( .25, false );
			if ( self.origin != originalOrigin )
			break;
		}

		fx delete();
	}
}

clearFXOnDeath( fx )
{
	fx endon("death");
	self waittill("death");
	fx delete();
}

getDamageableEnts(pos, radius, doLOS, startRadius)
{
	ents = [];

	if (!isdefined(doLOS))
	doLOS = false;

	if ( !isdefined( startRadius ) )
	startRadius = 0;

	// players
	players = level.players;
	for (i = 0; i < players.size; i++)
	{
		if (!isalive(players[i]) || players[i].sessionstate != "playing")
		continue;

		playerpos = players[i].origin + (0,0,32);
		dist = distance(pos, playerpos);
		if (dist < radius && (!doLOS || weaponDamageTracePassed(pos, playerpos, startRadius, undefined)))
		{
			newent = spawnstruct();
			newent.isPlayer = true;
			newent.isADestructable = false;
			newent.entity = players[i];
			newent.damageCenter = playerpos;
			ents[ents.size] = newent;
		}
	}

	// grenades
	grenades = getentarray("grenade", "classname");
	for (i = 0; i < grenades.size; i++)
	{
		entpos = grenades[i].origin;
		dist = distance(pos, entpos);
		if (dist < radius && (!doLOS || weaponDamageTracePassed(pos, entpos, startRadius, grenades[i])))
		{
			newent = spawnstruct();
			newent.isPlayer = false;
			newent.isADestructable = false;
			newent.entity = grenades[i];
			newent.damageCenter = entpos;
			ents[ents.size] = newent;
		}
	}

	destructibles = getentarray("destructible", "targetname");
	for (i = 0; i < destructibles.size; i++)
	{
		entpos = destructibles[i].origin;
		dist = distance(pos, entpos);
		if (dist < radius && (!doLOS || weaponDamageTracePassed(pos, entpos, startRadius, destructibles[i])))
		{
			newent = spawnstruct();
			newent.isPlayer = false;
			newent.isADestructable = false;
			newent.entity = destructibles[i];
			newent.damageCenter = entpos;
			ents[ents.size] = newent;
		}
	}

	destructables = getentarray("destructable", "targetname");
	for (i = 0; i < destructables.size; i++)
	{
		entpos = destructables[i].origin;
		dist = distance(pos, entpos);
		if (dist < radius && (!doLOS || weaponDamageTracePassed(pos, entpos, startRadius, destructables[i])))
		{
			newent = spawnstruct();
			newent.isPlayer = false;
			newent.isADestructable = true;
			newent.entity = destructables[i];
			newent.damageCenter = entpos;
			ents[ents.size] = newent;
		}
	}

	return ents;
}

weaponDamageTracePassed(from, to, startRadius, ignore)
{
	midpos = undefined;

	diff = to - from;
	if ( lengthsquared( diff ) < startRadius*startRadius )
	midpos = to;
	dir = vectornormalize( diff );
	midpos = from + (dir[0]*startRadius, dir[1]*startRadius, dir[2]*startRadius);

	trace = bullettrace(midpos, to, false, ignore);

	return (trace["fraction"] == 1);
}

damageEnt(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, damagepos, damagedir)
{
	if (self.isPlayer)
	{
		self.damageOrigin = damagepos;
		self.entity thread [[level.callbackPlayerDamage]](
		eInflictor, // eInflictor The entity that causes the damage.(e.g. a turret)
		eAttacker, // eAttacker The entity that is attacking.
		iDamage, // iDamage Integer specifying the amount of damage done
		0, // iDFlags Integer specifying flags that are to be applied to the damage
		sMeansOfDeath, // sMeansOfDeath Integer specifying the method of death
		sWeapon, // sWeapon The weapon number of the weapon used to inflict the damage
		damagepos, // vPoint The point the damage is from?
		damagedir, // vDir The direction of the damage
		"none", // sHitLoc The location of the hit
		0 // psOffsetTime The time offset for the damage
		);
	}
	else
	{
		// destructable walls and such can only be damaged in certain ways.
		if (self.isADestructable && (sWeapon == "artillery_mp" || sWeapon == "claymore_mp"))
		return;

		self.entity notify("damage", iDamage, eAttacker, (0,0,0), (0,0,0), "mod_explosive", "", "" );
	}
}

debugline(a, b, color)
{
	for (i = 0; i < 30*20; i++)
	{
		line(a,b, color);
		wait level.oneFrame;
	}
}


onWeaponDamage( eInflictor, sWeapon, meansOfDeath, damage )
{
	self endon ( "death" );
	self endon ( "disconnect" );

	switch( sWeapon )
	{
		case "concussion_grenade_mp":
			// should match weapon settings in gdt
			//verifica se o einflic n foi destruido.
			if ( !isDefined( eInflictor ) )//ADDED
			return;
			else if( meansOfDeath == "MOD_IMPACT" )
			return;
			
			radius = 14;
			scale = 1 - (distance( self.origin, eInflictor.origin ) / radius);

			if ( scale < 0 )
			scale = 0;

			time = scale;

			wait level.oneFrame;
			self shellShock( "frag_grenade_mp", time );
			self.concussionEndTime = getTime() + (time * 1000);
			break;
			default:
			// shellshock will only be done if meansofdeath is an appropriate type and if there is enough damage.
			maps\mp\gametypes\_shellshock::shellshockOnDamage( meansOfDeath, damage );
			break;
	}

}

// weapon stowing logic ===================================================================

// weapon class boolean helpers
isPrimaryWeapon( weaponname )
{
	return isdefined( level.primary_weapon_array[weaponname] );
}

isSideArm( weaponname )
{
	return isdefined( level.side_arm_array[weaponname] );
}
isInventory( weaponname )
{
	return isdefined( level.inventory_array[weaponname] );
}
isGrenade( weaponname )
{
	return isdefined( level.grenade_array[weaponname] );
}
getWeaponClass_array( current )
{
	if( isPrimaryWeapon( current ) )
	return level.primary_weapon_array;
	else if( isSideArm( current ) )
	return level.side_arm_array;
	else if( isGrenade( current ) )
	return level.grenade_array;
	else
	return level.inventory_array;
}