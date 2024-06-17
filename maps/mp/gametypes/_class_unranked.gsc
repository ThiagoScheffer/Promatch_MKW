#include common_scripts\utility;
#include promatch\_eventmanager;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include promatch\_utils;



init()
{
	level.classMap["assault_mp"] = "CLASS_ASSAULT";
	level.classMap["specops_mp"] = "CLASS_SPECOPS";
	level.classMap["heavygunner_mp"] = "CLASS_HEAVYGUNNER";
	level.classMap["demolitions_mp"] = "CLASS_DEMOLITIONS";
	level.classMap["sniper_mp"] = "CLASS_SNIPER";
	level.classMap["elite_mp"] = "CLASS_ELITE";

	level.weapons["semtex"] = "semtex_grenade_mp";
	level.weapons["tatical"] = "tatical_spawn_mp";
	level.weapons["magnade"] = "magnade_mp";
	level.weapons["frag"] = "frag_grenade_mp";
	level.weapons["smoke"] = "smoke_grenade_mp";
	level.weapons["flash"] = "flash_grenade_mp";
	level.weapons["concussion"] = "concussion_grenade_mp";
	level.weapons["c4"] = "c4_mp";
	level.weapons["claymore"] = "claymore_mp";
	level.weapons["rpg"] = "rpg_mp";
	level.weapons["frag"] = "frag_grenade_short_mp"; //precisa?

	self.pers["class"] = "CLASS_ASSAULT";
	
	// generating weapon type arrays which classifies the weapon as primary (back stow), pistol, or inventory (side pack stow)
	// using mp/weaponslist.csv's weapon grouping data ( numbering 0 - 109 )
	level.primary_weapon_array = [];
	level.side_arm_array = [];
	level.grenade_array = [];
	level.inventory_array = [];
	/*max_weapon_num = 109;
	
	for( i = 0; i < max_weapon_num; i++ )
	{
		weapon = tableLookup( "mp/weaponslist.csv", 0, i, 4 );
		
		//logprint("WEAPONSUNRANKED: " + weapon + "\n");	
		
		if ( !isDefined( weapon ) || weapon == "" )
		continue;

		weapon_type = tableLookup( "mp/weaponslist.csv", 0, i, 2 );

		weapon_class_register( weapon+"_mp", weapon_type );

	}*/

	precacheShader( "waypoint_bombsquad" );

	//level thread onPlayerConnecting();
	
	level thread addNewEvent( "onPlayerConnecting", ::onPlayerConnectingStatus );
}

onPlayerConnectingStatus()
{
	if ( !isDefined( self.pers["class"] ) ) 
	self.pers["class"] = undefined;
	
	self.class = self.pers["class"];
	self.atualClass = "";		
	
	self.sitrep = false;
	
	self.bombSquadIcons = [];
	self.bombSquadIds = [];
	
}


getClassChoice( response )
{
	tokens = strtok( response, "," );

	assert( isDefined( level.classMap[tokens[0]] ) );

	return ( level.classMap[tokens[0]] );
}

getWeaponChoice( response )
{
	tokens = strtok( response, "," );
	if ( tokens.size > 1 )
	return int(tokens[1]);
	else
	return 0;
}

//MENUSUNRAKED chama
//_modwarfare.gsc 344
//Responsavel por setar as classes no spawn e ao virar o round
//codigo executa toda vez e nao pode ser cancelado.
//2022 - TESTAR Aplicar Class upgrades aqui ao trocar no menu 
//
giveLoadout( team, class )
{	
	if( !isDefined( team ) || !isDefined( class ) )
		return;
		
	//self takeAllWeapons();	
	//self setClass( class );//teste
	
	//logDebug("giveLoadoutUnranked",self.pers["class"]);
	
	//self maps\mp\gametypes\_teams::playerModelForClass( self.pers["class"] );//seta o modelo das classes
	
	self SetClassbyWeapon("none");
	
	[[level.onLoadoutGiven]]();
}


setClass( newClass )
{
	self setClientDvar("loadout_curclass", newClass);//CHANGED
	self.curClass = newClass;
	self.class = newClass;
}

// sets the amount of ammo in the gun.
// if the clip maxs out, the rest goes into the stock.
setWeaponAmmoOverall( weaponname, amount )
{
	if ( isWeaponClipOnly( weaponname ) )
	{
		self setWeaponAmmoClip( weaponname, amount );
	}
	else
	{
		self setWeaponAmmoClip( weaponname, amount );
		diff = amount - self getWeaponAmmoClip( weaponname );
		assert( diff >= 0 );
		self setWeaponAmmoStock( weaponname, diff );
	}
}

fadeAway( waitDelay, fadeDelay )
{
	xwait (waitDelay,false);

	self fadeOverTime( fadeDelay );
	self.alpha = 0;
}


isRiotShieldHit( sHitLoc)
{
		// Better Names for hitloc
	switch( sHitLoc )
	{
		case "torso_upper":
		case "torso_lower":
		case "head":
		case "neck":
		case "left_arm_upper":
		case "left_arm_lower":
		case "left_hand":
		case "right_arm_upper":
		case "right_arm_lower":
		case "right_hand":
		case "left_leg_upper":
		case "right_leg_upper":
		sHitLoc = true;
		break;
		
		default:
		sHitLoc = false;
	  	break;
	}

	return sHitLoc;
}

isArmorShot( sHitLoc)
{

	if(isDefined(self.hasarmor))
	return (sHitLoc == "torso_upper" || sHitLoc == "torso_lower"  );
	else
	return false;
}

cac_modified_damage( victim, attacker, damage, meansofdeath, iDFlags,sHitLoc,sWeapon,vDir,vPoint)
{
	//assert( isPlayer( victim ) );
	// skip conditions
	
	if( !isdefined( victim) || !isdefined( attacker ) || !isplayer( attacker ) || !isplayer( victim ) )
	return damage;
	
	if( attacker.sessionstate != "playing" || !isdefined( damage ) || !isdefined( meansofdeath ) )
	return damage;
	
	//modo que nao tenham times
	if( level.teamBased && victim.pers["team"] == attacker.pers["team"] && !attacker.ffkiller)
	return 0;
	
	if( meansofdeath == "" )
	return damage;
	
	if(isDefined(attacker.pers["isBot"])) 
	damage = damage * 0.5;
	
	//if(level.oldschool && meansofdeath == "MOD_MELEE")
	//return 300;
	
	//if(level.oldschool)
	//return damage;
	
	//dropcrate
	if(isDefined(attacker.oneshootkill))
	return victim.health;
	
	if(level.atualgtype == "war")
	{		
		if(meansofdeath == "MOD_MELEE")
		return 400;

		//HPROUNDS
		if(attacker.hpround)
		return damage + 57;	

		//ONE HEADSHOT KILL
		if(attacker.onehs && meansofdeath == "MOD_HEAD_SHOT")
		{
			return 400;
		}
	}
		
	if(meansofdeath == "MOD_MELEE")	
	return damage;
			
	final_damage = damage;
	
	//explosivos
	if (isExplosiveDamage( meansofdeath ) ) 
	{
		if(victim.nadeimmune)
		{			
			return 15;
		}		
		
		if(victim.heavykevlar && attacker.dangercloser) 
		{
			//final_damage = old_damage * 0.4;
			return final_damage;
		}

		if(victim.heavykevlar) 
		{
			final_damage = damage * 0.5;
			return final_damage;
		}
		
		if(attacker.dangercloser)
		{
			final_damage = damage * 1.12;
			return final_damage;
		}
		
		//auto marker - scannade? ao jogar em um local revela todos na volta
		//if(attacker.vengeance)
		//{
			//if(sWeapon == "frag_grenade_mp")
			//final_damage = 30;
			
			//contrato
			//if(!isDefined( victim.spotMarker ))
			//{
				//victim thread promatch\_markplayer::spotPlayer(5,false);
				//victim.spotMarker = true;
			//}
		//}
		
		return final_damage;
	}
	
	

		
	//RIFLES E CALIBRES ALTOS

	//AVALIAR 1
	if(attacker.isSniper && isSniper(sWeapon) && isDefined( iDFlags ))
	{
		//if(level.atualgtype == "war")
		//return 400;			
					
		//iprintln("wallbang->");
		if((iDFlags & level.iDFLAGS_PENETRATION))
		{
			if(attacker.wallbang)
			{
				if(percentChance(50))
				return 400;
			}
			
			//if(damage <= 50 && attacker.sonicbullet)
			//{				
			//	final_damage = damage + 80;
			//}	
			
			//if(attacker.hpammo)
			//return (final_damage * 0.4);
			
			//if(attacker.fmjammo)
			//return (final_damage * 1.2);
		}							
	}
		
	//GERAL PELA PAREDE
	if(iDFlags & level.iDFLAGS_PENETRATION)
	{			
		//HARDHIT - somente pela parede
		//if( (attacker.piecinground))
		//final_damage += 25;//testar
						
		if(victim.upgradewalldamageresist)
		final_damage = (final_damage * 0.5);
		
		if(attacker.hpammo)
		final_damage = (final_damage * 0.2);
		
		if(attacker.fmjammo && final_damage < 50)
		final_damage = (final_damage * 2);
		
		return final_damage;
	}
		
		//TRATAR DANOS NA CABECA
	if(meansofdeath == "MOD_HEAD_SHOT")
	{
	
		if(isDefined(victim.playercapa) && isDefined(victim.playercapa.currenthelmet))
		{
				//TEM CAPACACETE
				if(victim.playercapa.currenthelmet > 0 && !attacker.fmjammo)
				{
					//250 > 130
					if(final_damage < victim.playercapa.currenthelmet)
					{
						if(attacker.hpammo)
						Dm = final_damage * 0.2;
						else
						Dm = int(final_damage * victim.playercapa.base);
						
						victim.playercapa.currenthelmet = int(victim.playercapa.currenthelmet - Dm );
						
						if(isDefined(victim.playercapa))
						victim thread UpdateCapaHit(Dm);
						
						attacker playlocalsound("bullet_impact_headshot_2");
						
						return Dm;
					}
					else
					{
						victim.playercapa.value setValue(0);
						victim.playercapa.currenthelmet = 0;
					}
				}
				
				return final_damage;
		}
		
		if(attacker.hpammo)
		return (final_damage * 1.1);
	}
		//self.playerarmor.base = 0.52;
		//se o attacker estiver com fmj ampliar o dano
		//verificar se como funciona no caso das 12
		if(isArmorShot(sHitLoc))
		{	
		
			if(attacker.fmjammo)
			final_damage = final_damage * 1.3;
		
			if(victim.heavykevlar && final_damage >= 100 )
			{
				victim setStat(2392,0);				
				victim.heavykevlar = 0;
				attacker playlocalsound("bullet_ap_plate");
				
				if(isDefined(victim.hasarmor))
				{
					victim.playerarmor.value setValue(0);
					victim.playerarmor.currentarmor = 0;
				}
				
				return 25;
			}
			
			//so executar se o dano for menor que o colete - otimiza o codigo!
			if(final_damage <= victim.playerarmor.currentarmor)
			{	
				if(attacker.hpammo)
				Dm = final_damage * 0.2;
				else
				Dm = final_damage * victim.playerarmor.base;	
					
				
				victim.playerarmor.currentarmor = int(victim.playerarmor.currentarmor - Dm );//100 - 16
				
				//iprintln("DM - " + Dm);
				attacker playlocalsound("bullet_ap_plate");
				
				if(isDefined(victim.playerarmor))
				victim thread UpdateKevlarHit(Dm);
				
				return Dm;
			}
			else
			{
				if(isDefined(victim.playerarmor))
				{
					victim.playerarmor.value setValue(0);
					victim.playerarmor.currentarmor = 0;
				}
			}
		}
				
		//qualquer outra parte do corpo
		if(attacker.hpammo)
		final_damage = (final_damage * 1.2);

		if(attacker.fmjammo)
		final_damage = (final_damage * 0.5);
			
		
		return  final_damage;
	//}

	//return  final_damage;
}


// including grenade launcher, grenade, RPG, C4, claymore
isExplosiveDamage( meansofdeath )
{
	explosivedamage = "MOD_GRENADE MOD_GRENADE_SPLASH MOD_PROJECTILE MOD_EXPLOSIVE MOD_PROJECTILE_SPLASH";
	if( isSubstr( explosivedamage, meansofdeath ) )
	return true;
	else
	return false;
}

// if primary weapon damage
isPrimaryDamage( meansofdeath )
{
	// including pistols as well since sometimes they share ammo
	if( meansofdeath == "MOD_RIFLE_BULLET")
	return true;
	return false;
}


UpdateCapaHit(damage)
{
	self endon( "disconnect" );
	self endon( "death" );
	self notify( "update_capahit" );
	self endon( "update_capahit" );

	wait level.oneframe;	
	
	if ( !damage || !isDefined(self.hasarmor))
	return;
	
	if(self.playercapa.currenthelmet < 0)
	self.playercapa.currenthelmet = 0;
	
	if(isDefined(self.pers["isBot"])) return;

	self.playercapa.value setValue(self.playercapa.currenthelmet);
	
	if(level.showdebug)
	iprintln("playerhelmet-> " + self.playercapa.currenthelmet);
}

UpdateKevlarHit(damage)
{
	self endon( "disconnect" );
	self endon( "death" );
	
	self notify( "update_kevahit" );
	self endon( "update_kevahit" );

	wait level.oneframe;	
	
	if ( !damage || !isDefined(self.hasarmor) )
	return;
	
	//if(!isDefined(self.playerarmor)) return;
	
	if(isDefined(self.hasarmor))
	self.playerarmor.currentarmor = 0;
	
	if(isDefined(self.pers["isBot"])) return;
	
	self.playerarmor.value setValue(self.playerarmor.currentarmor);
	
	if(level.showdebug)
	iprintln("playerarmor-> " + self.playerarmor.currentarmor);
}