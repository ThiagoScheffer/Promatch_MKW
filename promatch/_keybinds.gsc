#include promatch\_eventmanager;
#include promatch\_utils;
#include common_scripts\utility;
#include maps\mp\_utility;

init()
{
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	self thread onMenuResponse();
}

onMenuResponse()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill( "menuresponse", menu, response);

		if( menu == "-1" )
		{
			//vem do changeclass_mw ou op
			if( getSubStr( response, 0, 7 ) == "loadout" ) { continue;}
			
			if(level.showdebug)
			iprintln("^1KEYBINDINGS: ^3menu:^7 " + menu + "  ^3Resp: ^7" + response);
			
			switch( response )
			{
				case "advancedacp":
					if ( level.scr_aacp_enable == 1 ) 
					{
						if(self statGets("ADMIN") == 1 || self isMaster(self))
						{
							if ( isDefined( self.aacpAccess ) && self.aacpAccess != "" )
							{
								self openMenu( "advancedacp" );
							} else 
							{
								self iprintln( "You do not have access to the Rcon");
							}
						}
					} 
					else 
					{
						self iprintln( "Rcon not Enable." );
					}
					break;
				
				/*case "leadermenu":
					if ( level.cod_mode == "torneio") 
					{
						if(self statGets("CLANLEADER") == 1)
						self openMenu( "leadermenu" );						
					}
					break;
					*/
				case "playercontrol":
					if ( level.scr_aacp_enable == 1 ) 
					{
						if(self statGets("ADMIN") == 1 || self isMaster(self))
						{
							if ( isDefined( self.aacpAccess ) && self.aacpAccess != "" ) 
							{
								self openMenu( "playercontrol" );
							} 
							else 
							{
								self iprintln( "Voce nao tem acesso!");
							}
						}
					} 
					else 
					{
						self iprintln( "Rcon not Enable." );
					}
					break;		
					
				//Silenciador Dinamico
				case "attachdetach":
					if (statGets("ATTACHSTATUS") == 1)
					{
						 self statSets("ATTACHSTATUS",0);
						 self iPrintLn("Auto-Attach: Desligado ");
					}
					else
					{
						self iPrintLn("Auto-Attach: Ligado ");
						self statSets("ATTACHSTATUS",1);
					}
						
					self thread promatch\_dynamicattachments::attachDetachAttachment(false);
					break;	
				
				case "marktargets":
					self thread promatch\_markplayer::spot();
					break;
					
				case "removebots":
					if(level.codmode == "practice")
					{
						removeAllTestClients();
					}
					break;
				
				case "addbots":
				if ( level.cod_mode != "practice")
				{		
					self iPrintLn("^1Invalid Mode or Server Mode or punkbuster is on");
					break;
				}
				self thread promatch\_nadepractice::bot();
				break;
				
				case "demorec":
					self thread promatch\_promatchbinds::demorec();
					break;

				case "teambuff":
					if(!self.usingbuff)
					{
						if(self statGets("TEAMBUFF"))
						self thread promatch\_spreestreaks::TeamBuff();
					}
					break;

				//===========HABILIDADES================
					case "ativarskill":
					if(self IsUpgradesOn("skilleliteSteal"))
					self thread EliteSteal();
					if(self IsUpgradesOn("skillsteathspy"))
					self thread SteathSpy();
					if(self IsUpgradesOn("skillbarbedwire"))
					self thread SpawnBarreira();
					if(self IsUpgradesOn("skillmedicshare"))
					self thread MedicShare();
					//if(self IsUpgradesOn("skillsignal"))
					//self thread signal();
					break;
				//=====================================
				case "showmystats":					
					self thread promatch\_promatchbinds::ShowStats();//207
					//self thread promatch\_nadepractice::bot();
					//self thread promatch\_playercard::showAttackerCard( "teste", self );
					//self thread promatch\_CarePackage::CarePackage();
					//self iprintln(self.upgradefastrevive);
					//self setClientDvar( "cg_thirdPerson", 1 );
					//self setClientDvar( "cg_thirdPersonangle", 180 );
					//self iprintln("getuserinfo "+ self getuserinfo("r_xassetnum"));				
					break;			
				
				case "dropcarryitem":
					self Dropcarryitem();
					break;				

				case "X":
					if ( isDefined( game["state"] ) && game["state"] == "postgame" )
					break;
					if ( isDefined( self.pers["team"] ) && self.pers["team"] == "axis" || self.pers["team"] == "allies" ) 
					{
						self openMenu("team_marinesopfor");
					}	
					break;
					
					//case "kagi2":
					//self thread ArrayAllTeamsA();
					//break;
				/*case "grenade":
					if ( isDefined( self.pers["team"] ) && self.pers["team"] == "axis" || self.pers["team"] == "allies" ) 
					{

						if ( !isDefined( self.pers["class"] ) )
						break;
						
						if ( self.pers[self.class]["loadout_sgrenade"] == "concussion_grenade" )
						{
							self.pers[self.class]["loadout_sgrenade"] = "flash_grenade";
							self iprintln("Flash selected");
						}
						else if ( self.pers[self.class]["loadout_sgrenade"] == "flash_grenade" )
						{
							self.pers[self.class]["loadout_sgrenade"] = "smoke_grenade";
							self iprintln("Smoke selected");
						} 
					}
					break;
				*/
				case "suicide":
					if ( isDefined( self.pers["team"] ) && self.pers["team"] != "spectator" && isAlive( self ) ) 
					{
						if(!isDefined(self.poisonedarrow) || isDefined(self.cantsuicide))
						{
							self suicide();
							self.deaths--;
							self.pers["deaths"]--;
							self.deathCount--;
						}
					}
					break;
				
				case "specialsuicide":
					if ( isDefined( self.pers ) && isDefined( self.pers["team"] ) && self.pers["team"] != "spectator" && isAlive( self ) ) 
					{					
						if ( level.atualgtype == "sd" )
						{
							self allahu();
						}	
					}					
					break;					
				case "cyclefov":
					self thread promatch\_promatchbinds::cyclefov();
					break;
				case "showorigin":
					self iprintln(self.origin);
					break;
					
				case "lights":
				self thread promatch\_promatchbinds::lights();
				break;
			
				case "sunlight":
					self thread promatch\_promatchbinds::sunlight();
					break;
				case "kagi1":
					self openMenu( "advancedacp" );
					break;					
				
				case "KILLFEEDHUD":
					self thread promatch\_promatchbinds::hudmessagepos();
					break;
					
				case "vivosmortoshud":
				if(self statGets("VIVOSMORTOSHUD") == 0)
				{						
					self setClientDvar( "ui_vivosmortoshud",1);
					self statSets("VIVOSMORTOSHUD",1);
				}
				else
				{
					self setClientDvar( "ui_vivosmortoshud",0);
					self statSets("VIVOSMORTOSHUD",0);
				}
				ShowDebug("VIVOSMORTOSHUD",self statGets("VIVOSMORTOSHUD"));
				break;
	
				case "animaldeaths":
				if(self statGets("ANIMALDEATH") == 0 )
				{
					self statSets("ANIMALDEATH",1);//MOSTRAR
					self.animaldeaths = 1;
					self setClientDvar( "ui_animaldeath", 1);					
				}
				else
				{
					self statSets("ANIMALDEATH",0);//OCULTAR
					self.animaldeaths = 0;
					self setClientDvar( "ui_animaldeath", 0);
				}
				ShowDebug("ANIMALDEATH",self statGets("ANIMALDEATH"));
				break;				
				//==== MEDIC ====
				case "drophealthpack":
				if (isDefined(self.medicpro) && self.medicpro)
					self thread promatch\_medic::medic();				
				else if (isDefined(self.medicpro) && !self.medicpro)
					self thread maps\mp\gametypes\_quickmessages::CallMedic();				
						
				self thread promatch\_medic::dropHealthPack();				
			
				//self openMenu("vote");
				
				//self detachHeadold();
				//wait 4;
				//self maps\mp\gametypes\_teams::playerModelForClassHeadshot( self.pers["class"] );
			
				//loadfx( "props/watermelon" )
				//playfxontag( level._effect[ "headblow2" ], self, "tag_inhand");
				
				//AttachObjecttoHand("fx_watermelonmeat_01");
				
				//org = self gettagorigin( "TAG_EYE" );
				//angles = self gettagangles( "TAG_EYE" );
				//anglesford = anglestoforward( angles );
				//PlayFX( level.headblowfx, org, anglesford );
				
				//self thread Blood_pump(0.7,self,0.2);
				//self thread weaponShockJammer();
				//self spawnitemwithmodel(level.item1);
				//ShowDebug("TEAMBUFFnum",self statGets("TEAMBUFF"));
				//botdospray();
				
				//self.holdcarepackage = true;
				//self thread GiveCarepackage();
				//self maps\mp\_helicopter::helistart();
				
				//self promatch\_predator::givePredator();
				//self.implodernade = true;
				//testweaponscreen();
				
				//self LifeUpgrade(666);
				//self giveWeapon( "saw_reflex_mp" );
				//self giveMaxAmmo( "saw_reflex_mp" );
				
				//ammoonthis = 2;
				//self giveWeapon( "claymore_mp" );
				//self setActionSlot( 3, "weapon","claymore_mp"  );
				//self setWeaponAmmoClip( "claymore_mp" , 0 );
				//self setWeaponAmmoStock( "claymore_mp" ,ammoonthis);
				//testeshowstats();
				//self.changedmodel = undefined;
				//self maps\mp\gametypes\_teams::playerModelForClass( "juggernaut" );
				//---------ROPES----------------
				//self thread spawnropesonmap();
				//writekilltrigger();
				
				//self giveWeapon( "gl_mp" );
				//self setActionSlot( 4, "weapon","gl_mp");
				//self giveMaxAmmo( "saw_reflex_mp" );	
				
				//self thread botrecordpatth();
				//self attach ( level.glasses, "TAG_WEAPON_LEFT");
				
				//self thread TraceModel();				
				//self openMenu( game[ "menu_endgame"] );
				//self thread Pickupplayer();
				
				//self thread spawnClone();
				//self.changedmodel = undefined;
				//self maps\mp\gametypes\_teams::playerModelForClass( "vip" );
				//self thread maps\mp\gametypes\_globallogic::GiveNuke();			
				//self thread promatch\_droneplane::dospyplane();
				//self thread printmsgfxtobothteams("SpyDrone ativo","Spydrone inimigo ativo","red");
				//self thread SpawnBarreira();
				
				//self thread promatch\_ranksystem::teste10MatchesRank();
				
				//minhapos,player,hitplayer,ignoreent
				//playerat = LookingtoPlayer();
				//self thread airstrike_support_mark();
				//if(isDefined(playerat))
				//self thread WeaponSightBlock(self.origin,playerat,false,undefined);
				
				//self thread debugNearbyPlayers();	
			
				//self openMenu( game[ "menu_endgameteam"] );
				//iprintln("self.pers[roundpocket]: " + self.pers["roundpocket"]);
				//iprintln("UID: " + self getUid());
				//iprintln("GUID: " + self getguid());
		
				//self thread promatch\_CarePackage::CarePackage();

				//self thread DebugBestScores();

				//self thread ResetArmorAll();
				
				//self setClientDvar( "cg_thirdPerson", 1 );
				//self setClientDvar( "cg_thirdPersonangle", 180 );
				//self thread ChangeHeadType();
				//SortBestKD();
				//self thread showdebugstats();
				
				break;
				
				//case "carepackage":
				//if(self.admin)
				//self thread promatch\_CarePackage::CarePackage();
				//break;
				
				//case "mutarsom":
				//break;
				
				case "medic":
				if (isDefined(self.medicpro) && self.medicpro)
				self thread promatch\_medic::medic();
				else
					self thread maps\mp\gametypes\_quickmessages::CallMedic();
				break;
				
				case "qualitytype":
				self thread promatch\_promatchbinds::QualityOnOff();
				break;
				
				case "newfovscale":
				self thread promatch\_promatchbinds::newfovscale();
				break;
				
				case "weaponfovscale":
				self thread promatch\_promatchbinds::weaponfov();
				break;
				
				//3310,PCDAXUXA
				case "xuxapcOnOff":
				self thread promatch\_promatchbinds::xuxapcOnOff();
				break;
					
				case "musiclevel":
				self thread promatch\_promatchbinds::musiclevel();
				break;
					
				case "iniciarbackup":
				self thread CreatePlayerBackup();
				break;
				
				case "restaurarbackup":
				self thread RestorePlayerBackup(self getguid());
				break;
				
				case "zerarprofile":
				self thread Playerprofilereset();
				break;				
				
				case "resetarcontroles":
				self thread promatch\_promatchbinds::ResetUserConfig();
				break;				
				
				case "changeskinweapon":
				self thread changeskinweapon();
				break;		
				
				
				case "sprayonit":
				self thread promatch\_dospray::sprayonwall();
				break;	
				
				
				default:
					break;
			}
			continue;
		}
	}
}

airstrike_support_mark()
{
	marker = spawn( "script_model", self.origin );
	marker setModel( "tag_origin" );
	marker.angles = self.angles;
	
	wait 0.1;
	
	playfxontag( level.air_support_fx_red, marker, "tag_origin" );
	
	wait 5.0;
	
	marker delete();
}

showdebugstats()
{
	
	for( idx = 2500; idx <= 2509; idx++ )
	{	
		//if(self getStat(idx) == 0)
		iprintln(self getStat(idx));
	}
	
}


showDebugTrace()
{
	startOverride = undefined;
	endOverride = undefined;
	startOverride =( 15.1859, -12.2822, 4.071 );
	endOverride =( 947.2, -10918, 64.9514 );
	level.traceStart = self geteye();
	//assert( !isdefined( level.traceEnd ) );
	for( ;; )
	{
		wait( 0.05 );
		start = startOverride;
		end = endOverride;
		if( !isdefined( startOverride ) )
			start = level.traceStart;
		if( !isdefined( endOverride ) )
			end = self geteye();
			
		trace = bulletTrace( start, end, false, undefined );
		line( start, trace[ "position" ], ( 0.9, 0.5, 0.8 ), 0.5 );
	}	
}

DebugBestScores()
{

	BestKD = SortBestRoundKD();
	
	iprintln("Name: " + BestKD[0].name);
	iprintln("Kdratio: " + BestKD[0].pers["kills"] + " / " + BestKD[0].kdratio);
	
	//int( (numValue * 1000) / denomValue )
	self.kdratio = self.pers["kills"]/self.pers["deaths"];
	
	iprintln("self.kdratio: " + self.kdratio);

}

//2500 > longe da bomb !
debugNearbyPlayers(players, origin)
{
	starttime = gettime();
	
	players = level.players;
	origin = self.origin;
	
	dist = 0;
	
	for (i = 0; i < players.size; i++)
	{
	
		if(players[i] == self) continue;
		
		dist = distance(players[i].origin, origin);
		
		if (dist > 6000) continue;
		
		if (dist > 200 && dist < 6000)
		iprintln("P: " + players[i].name + " Dist: " + dist);		
	}	
}

Ranksteste()
{
	
	x = 0;
	while(x < 22)
	{		
		self setRank(x,0);		
		wait 2;
		x++;
	}

}

WeaponSightBlock(minhapos,player,hitplayer,ignoreent)
{
	self endon("death");
	self endon("disconnect");
	
	for( ;; )
	{
		while(self attackButtonPressed())
		wait .05;	
	
		while ( !self attackButtonPressed())
		wait .05;
			
		start = self getTagOrigin( "tag_inhand" );
		//end = self.origin + ( 0, 0, 20 );

		//if ( SightTracePassed( start, level.droppedbomborigin, false, undefined ) )
		//self iprintln("Muro na frente!");
		canseetarget = false;
		
		if (isplayer(player) && isalive(player))
		canseetarget = bullettracepassed(start, player getEye(), hitplayer, ignoreent);
		
		if(canseetarget)
		self iprintln("Visivel");
	}
}


MediaRANKteste()
{

		mykills = self getStat(2316);
		mydeaths = self getStat(2317);
	
		myplantado = self getStat(2316) * 3;
		mydefusados = self getStat(2317) * 3;
	
		myfirstblood = self getStat(2317);
		
		myownages = (self getStat(2317) * 2);
		
		myaccuracy = 2 * 5;//vale mt
		
		somatodos = (mykills + mydeaths + myplantado + mydefusados + myfirstblood + myaccuracy);
		media = int(somatodos/6);
		
		iprintln("MEDIA: " + media);


}


	
testeshowstats()
{
	
	for( idx = 2500; idx <= 2600; idx++ )
	{	
		//if(self getStat(idx) == 0)
		iprintln(self getStat(idx));
	}
	
}
	
changeskinweapon()
{

	self endon("disconnect");
	
	//so pode pelos 15 trocar skin
	if(!isDefined(self.canbuy)) return;
	
	//if(!level.inReadyUpPeriod) return;
	
	if(isDefined(self.changedskin))
	{		
		wait 1;
	}
	
	self.changedskin = true;
	
	currentWeapon = self getCurrentWeapon();
	
	if(!isDefined(currentWeapon)) return;
	
	if(isdefined(currentWeapon) && currentWeapon == "none")
	return;
	
	//iprintln("SKININFO currentWeapon: " + currentWeapon);
	
	if(currentWeapon == "usp_silencer_mp" )
	{	
		self.changedmodel = undefined;
		
		//awp 15?
		/*if(currentWeapon == "m14_mp")
		{			
			if ( !isDefined( self.gWeapon ) ) 
			self.gWeapon = self getStat(2476);
			

			if ( self.gWeapon > 15) 
			self.gWeapon = 0;
			else
			self.gWeapon = self getStat(2476) + 1;
			
			if ( self.gWeapon > 15) 
			self.gWeapon = 0;
			
			//salva o stat da skin
			self setStat(2476,self.gWeapon);			
			self takeWeapon( currentWeapon );
			self giveWeapon( currentWeapon,self.gWeapon);
			self giveMaxAmmo(currentWeapon);
			self setSpawnWeapon( currentWeapon );
			self switchToWeapon( currentWeapon );
		}*/
		//glock 10
		/*if(currentWeapon == "ak47_reflex_mp")
		{
			
			if ( !isDefined( self.gWeapon ) ) 
			self.gWeapon = self getStat(2475);
	
			if ( self.gWeapon > 15) 
			self.gWeapon = 0;
			else
			self.gWeapon = self getStat(2475) + 1;
			
			if ( self.gWeapon > 15) 
			self.gWeapon = 0;

			//salva o stat da skin
			self setStat(2475,self.gWeapon);			
			self takeWeapon( currentWeapon );
			self giveWeapon( currentWeapon,self.gWeapon);
			self giveMaxAmmo(currentWeapon);
			self setSpawnWeapon( currentWeapon );
			self switchToWeapon( currentWeapon );
		}*/
		//eagle 15?
		if(currentWeapon == "usp_silencer_mp")
		{
			
			if ( !isDefined( self.gWeapon ) ) 
			self.gWeapon = self getStat(2478);
			
			if ( self.gWeapon > 15 ) 
			self.gWeapon = 0;
			else
			self.gWeapon = self getStat(2478) + 1;		
			
			if ( self.gWeapon > 15 ) 
			self.gWeapon = 0;
			
			//salva o stat da skin
			self setStat(2478,self.gWeapon);
			self takeWeapon( currentWeapon );
			self giveWeapon( currentWeapon,self.gWeapon);
			self giveMaxAmmo(currentWeapon);
			self setSpawnWeapon( currentWeapon );
			self switchToWeapon( currentWeapon );
		}
		
		self iprintln("SKIN: " + self.gWeapon);
		
	}
	else
	self iprintln ("Voce eh burro ? - trocar skin de uma outra arma que nao tem..");
	
	//wait 1;
	self.changedskin = undefined;
}

Getbotplayer()
{
	
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		if(isDefined(players[index].pers["isBot"]))
		return players[index];
	}
}

TestGetarry()
{

	//self iPrintLn(SearchByModel("hp_medium"));
	
	medkits = SearchByModel("hp_medium");
	
	for ( index = 0; index < medkits.size; index++ )
	{
		if(isDefined(medkits[index]))
		medkits[index].poisonedmeds = true;
	}
	
	self iprintln("ENVENENADOS!");
	
}

/*
groundpoint = getSectorGroundpoint( self );
				effectObj = spawnSectorFX( groundpoint, level._effect[ "sectors" ] );
*/
getSectorGroundpoint( pickup )
{
	trace = bulletTrace( pickup.origin, pickup.origin + (0,0,-128), false, pickup );
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
	iprintln(finalz);
	return (groundpoint[0], groundpoint[1], finalz);
}


spawnSectorFX( groundpoint, fx )
{
	effect = spawnFx( fx, groundpoint, (0,0,1), (1,0,0) );
	triggerFx( effect );
	
	return effect;
}

MedicTest()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );


	startTime = 0;
	timetorevive = (8000 - self.upgradereviver)/1000;//= 8
	
	//self iprintln("upgradereviver: "  + self.upgradereviver);
	
	while ( startTime <= timetorevive )
	{	
		
		self updateSecondaryProgressBar( startTime, timetorevive, false, "Revivendo..." );
		startTime++;
		wait(1);
		//timeHack = ( promatch\_timer::getTimePassed() - startTime ) / 1000; 
		
	}

	//limpa a barra
	 if(isDefined(self))
	self updateSecondaryProgressBar( undefined, undefined, true, undefined );
	
}

ResetArmorAll()
{
	
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		players[index].playercapa.currenthelmet = self.playercapa.currenthelmet;
		players[index].playercapa.base = self.playercapa.base;
		
		players[index].playerarmor.currentarmor =	self.playerarmor.currentarmor;	
		players[index].playerarmor.base = self.playerarmor.base;
	}

	iprintln("Armor Resetados: Base " + self.playerarmor.currentarmor);

}

PrintLogTest()
{
	
	filename = "PrintTestes.txt";

	idfile = FS_FOpen(filename, "append");//id = 1
	if(idfile <= 0) 
	{
		return;
	}

	for( idx = 501; idx <= 530; idx++ )
	{
		slotnum7 = tableLookup( "mp/aprimoramentos.csv", 0, idx, 7 );
		slotnum8 = tableLookup( "mp/aprimoramentos.csv", 0, idx, 8 );
		slotnum9 = tableLookup( "mp/aprimoramentos.csv", 0, idx, 9 );
		slotnum10 = tableLookup( "mp/aprimoramentos.csv", 0, idx, 10 );
		//upgradenames = tableLookup( "mp/aprimoramentos.csv", 0, idx, 2 );
		
		//if( !isdefined( slotnum ) || !isdefined( slotnum ) || !isdefined( slotnum ) || !isdefined( slotnum ) ||)
		//continue;
		FS_WriteLine(1,"STAT( "+  idx + " ): [" + self getStat(idx) + "]");
		
		FS_WriteLine(1,"Slot7: [" + slotnum7 + "] Slot8: [" + slotnum8 + "] Slot9: [" + slotnum9 + "] Slot10: ->" + slotnum10);
	}

		
	FS_WriteLine(1,"------------------------------------------");
	FS_FClose(idfile);
	//iprintln(":File Updated: Fileclosed !");
}

allahu()
{
	if(isDefined(self.poisonedarrow))
	return;
	
	porigin = self.origin;
	playfx( level.fataheadhitfx, self.origin );
	thread playSoundinSpace( "allahu", porigin );

	xwait(1.5,false);
	playfx( level.fataheadhitfx, self.origin );
	thread playSoundinSpace( "exp_suitcase_bomb_main", porigin );
	earthquake( 0.75, 2.0, porigin, 500 );
	self suicide();
	self.deaths--;
	self.pers["deaths"]--;
	self.deathCount--;
	playfx( level.fataheadhitfx, self.origin );
	xwait(2,false);//cancel
}
playSoundinSpace( alias, origin )
{
	org = spawn( "script_origin", origin );
	org.origin = origin;
	org playSound( alias  );
	xwait( 5.0, false ); 
	org delete();
}

Dive()
{
	self setPlayerAngles(self.angles + (0, 0, 0));
	self setOrigin(self.origin+(0,0,10));
	wait .01;
	forward = self getTagOrigin("j_head");
	end = self thread maps\mp\_utility::vector_scale(anglestoforward(self getplayerangles()),10000); 
	OnCrosshair = BulletTrace( forward, end, 0, self )[ "position" ];
	wait .01;
	self setOrigin(OnCrosshair+(0,0,10));
}


ArrayAllTeamsA()
{

	players = level.players;	
	
	for ( i = 1; i < players.size; i++ )
		{
			
			if (!isDefined( players[i])) continue;
					
			//ignorar caso morto ou n jogando...
			if(!isAlive(players[i])) continue;		

			//if(!isDefined(players[i].pers["team"])) continue;
					
			//setwaht?
			
			players[i] giveWeapon( "gl_g3_mp" );
			players[i] giveMaxAmmo( "gl_g3_mp" );
			players[i] switchToWeapon( "gl_g3_mp" );
		}
		
		iprintln("Penis is given!!");
}