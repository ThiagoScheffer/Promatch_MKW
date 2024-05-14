#include promatch\_eventmanager;
#include promatch\_utils;
#include common_scripts\utility;

init()
{
	level.statsPlayers = [];	
	
	//level thread onPlayerConnect();
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	//for(;;)
	//{
	//	level waittill("connected", player);

		//player setClientDvar("ui_3dwaypointtext", "1");
		//player.enable3DWaypoints = true;
		//player setClientDvar("ui_deathicontext", "1");
		//player.enableDeathIcons = true;
		//player.classType = undefined;
		//player.selectedClass = false;
		self thread onMenuResponse();
	//}
}


onMenuResponse()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("menuresponse", menu, response);
		
		if(level.showdebug)
		iprintln("^1UNRANKED: ^3menu:^7 " + menu + "  ^3Resp: ^7" + response);
	
		//aguardar versionupdater
		if(isDefined(self.inupdate) && !isDefined( self.pers["isBot"]))
		continue;
	    
		//if (isDefined( self.pers["isBot"] ) && self.pers["isBot"])
		//{
		//	self [[level.autoassign]]();
		//	self SetClassbyWeapon( "M16A3" );
		//}			
					
		if ( response == "back" )//controla o retorno de um menu para outro
		{
			//RESETAR
			//self setClientDvar("ui_colete_name","");
			//self setClientDvar("ui_capa_name","");		
			
			self closeMenu();
			self closeInGameMenu();
			continue;
		}
		//HUDNOVOS
		if (isSubStr( response, "HUDITENS" ) )
		{
			self thread SetHUDITENS();	
			continue;
		}
		
		if (isSubStr( response, "HUDHEALTH" ) )
		{
			self thread SetHUDHEALTH();
			continue;
		}
		
		if (isSubStr( response, "spray" ) )
		{
			//ignore the keybinding
			if(response == "sprayonit")
			continue;
				
			if(level.cod_mode != "torneio")
			self thread changesprays(response);
			
			continue;
		}
		
		if (isSubStr( response, "playercard_emblem_" ) )
		{
		
			if(level.cod_mode != "torneio")
			self thread changeemblem(response);
			
			continue;
		}
		
		if (isSubStr( response, "taunt" ) )
		{
			if(level.cod_mode != "torneio")
			self thread quicktaunts(response);
			
			continue;
		}
		
		//ignorar
		if ( response == "qualitytype") continue;
			
		//upgrade MENU
		if(response != "teambuff" && isSubStr( response, "upgrade" ) || isSubStr( response, "skill" ) || isSubStr( response, "skillbuff" ) )
		{
			if(level.cod_mode != "torneio") 
			self thread ApplyUpgradesToPlayer(response);
			
			continue;
		}		
			
		//SQUAD MENU
		if(isSubStr( response, "squad_" ) )
		{
			
			if(!HaveRank(6))//observar
			continue;
			
			if(level.cod_mode == "torneio")
			continue;
			
			//nao é modo de jogo em times!
			if ( !level.teamBased ) continue;
			
			squadresponse = StrRepl( response, "squad_", "");
			self promatch\_squadteam::squadResponse(squadresponse);
			continue;
		}
		
		//FILMTWEAKS MENU
		if(isSubStr( response, "films_" ) )
		{			
			if(response == "films_sunlight")
			{
			self thread promatch\_promatchbinds::Sunlight();
			continue;
			}
			
			if(response == "films_fullbright")
			{
			self thread promatch\_promatchbinds::fullbright();
			continue;
			}
			
			if(response == "films_filmtweaks")
			{
			self thread promatch\_promatchbinds::filmtweaks();
			continue;
			}
			//APENAS FILMTWEAKS
			
			filmresponse = StrRepl( response, "films_filmtweak", "");
			//iprintln("filmresponse: " + filmresponse);
			self thread promatch\_promatchbinds::SetFilmtweaks(int(filmresponse));
			continue;			
		}
		//class.menu
		if( response == "changeteam" )
		{
			//trava mudança de time
			if(self statGets("LOCKEDTEAM"))
				continue;	
			
			self closeMenu();
			self closeInGameMenu();
			//1 menu ao entrar no jogo ou ao sair para espectador
			self openMenu(game["menu_team"]);
			
			continue;
		}
		
		if( response == "endgame" )
		{
			continue;
		}
		
		//ATalhos Loadclass
		if (isSubStr( response, "autoloadclass" ) )
		{
			ShowDebug("autoloadclass",response);
	
			if(response == "autoloadclass1")
			response = "customclass0";
			if(response == "autoloadclass2")
			response = "customclass1";
			if(response == "autoloadclass3")
			response = "customclass2";
			
			
			if(isDefined(self.loadingclass) && !self.loadingclass)//se for falso, esta livre para um novo load
			{
				self.changedmodel = undefined;
				self thread loadHandler( response );
			}
			
			continue;
		}
			
		//RANK SYSTEM
		/*if( menu == "muteplayer")
		{
			if(!isAlive(self)) continue; //precisa estar vivo para iniciar!
			
		}*/
		
		//MENU OPTIONS
		if(menu == game["menu_class"]) // game["menu_class"] = "class"; // = menu options esc
		{

			//if(level.oldschool)
			//continue;
			
			if(response == "changeweapon" && self.pers["team"] != "spectator")
			{		
				
				self closeMenu();
				self closeInGameMenu();

				//ABRE MENU DE MONTAGEM DE ARMAS
				self openMenu( game["menu_changeclass"] );		

				continue;
			}

			//usar para o load das customs button
			if (isSubStr( response, "customclass" ) )
			{
				if(!self.loadingclass)//se for falso, esta livre para um novo load
				{
					self.changedmodel = undefined;
					self thread loadHandler( response );
				}
				continue;
			}			
			
			
			//if(response == "redirect")
			//self thread promatch\_reservedslots::disconnectPlayer( true );
			//continue;			
		}
		else if( menu == game["menu_team"] )//1 menu ao entrar no jogo ou ao sair para espectador
		{		
			//fix para atalho via teclado
			if(response == "axis" || response == "allies")
			{
				self.changedmodel = undefined;
				if(isDefined(self.pers["team"]))
				{
					if(self.pers["team"] == "axis")	
						response = "allies";
						
					if(self.pers["team"] == "allies")	
						response = "axis";
						
					//self thread preventTeamSwitchExploit();
				}
			}
			
			//fix onteam select spectador menu
			if(self.pers["team"] != "spectator" && response == "autoassign" )
			{
				self [[level.spectator]]();
				continue;
			}
			
			//bloqueia acesso a selecionar os times caso nao seja vip
			//if(level.cod_mode != "torneio" && (response == "allies" || response == "axis"))
			//response = "autoassign";
			
			switch(response)
			{
				case "allies":
					self [[level.allies]]();
					self setClientDvar( "g_compassShowEnemies", 0);
					self setClientDvar( "cg_drawThroughWalls", 0 );
					break;

				case "axis":
					self [[level.axis]]();
					self setClientDvar( "g_compassShowEnemies", 0);
					self setClientDvar( "cg_drawThroughWalls", 0 );
					break;

				case "autoassign":
					self [[level.autoassign]]();
					self setClientDvar( "g_compassShowEnemies", 0);
					self setClientDvar( "cg_drawThroughWalls", 0 );
					break;

				case "spectator":
					self [[level.spectator]]();
					break;
			}
		}//MENU CENTRAL AÇOES DOS BOTOES AQUI		 
		else if( menu == game["menu_changeclass"] )
		{	
			//ShowDebug("menu_changeclass_weapons: ",response);
			
			/*if (response == "saveclass" )
			{
				if(isDefined(self.pers[self.class]["loadout_primary"]))
				self thread saveLoadout();
				else
				self iprintln ("saveclass:  Nao definido");
							
				continue;
			}		*/
			

			
			if (isSubStr( response, "classsave" ) )
			{
					ShowDebug("classsave0",response);
			
					if(response == "classsave0")
					self.classIndex = 0;
					if(response == "classsave1")
					self.classIndex = 1;
					if(response == "classsave2")
					self.classIndex = 2;
					
					
					if(isDefined(self.pers[self.class]["loadout_primary"]))
					self thread saveLoadout();
					else
					self iprintln ("saveclass:  Nao definido");
					
					continue;
			}
			
			//usar para o load das customs button
			/*if (isSubStr( response, "customclass" ) )
			{
				if(!self.loadingclass)//se for falso, esta livre para um novo load
				{
					self.changedmodel = undefined;
					//ShowDebug("responsecustomclass",response);
					self thread loadHandler( response );
				}
				continue;
			}*/
			
			/*
			if(response == "saveasspawn")
			{
				self thread SaveasDefault();
				continue;
			}
			
			if(response == "loadclass")
			{
				self thread LoadDefaultClass();
				continue;
			}
			
			if(response == "clearsaveasspawn")
			{
				self thread ClearSaveasDefault();
				continue;
			}
			*/
			
			
			ShowDebug("menu_changeclass_weapons: ",response);
			
			//load_weapon:M16A3
			sTwname = strTok( response, ":" );		
			
			if(!isDefined(sTwname))
			continue;
			
			if(!isDefined(sTwname[1]))
			continue;
			
			//clean Attach symbol
			sTwnameA = StrRepl(sTwname[1], "(A)", "");
			
			ShowDebug("menu_changeclass_StrRepl: ",sTwnameA);
			
			self SetClassbyWeapon(sTwnameA);

		}
		else if( menu == game["menu_quickbuy"] )
		{	
		
			//ShowDebug("menu_quickbuyresponse",response);

			self thread ItemBuy(response);

		}
		else if ( !level.console )
		{
			if(menu == game["menu_quickcommands"])
			maps\mp\gametypes\_quickmessages::quickcommands(response);
			else if(menu == game["menu_quickstatements"])
			maps\mp\gametypes\_quickmessages::quickstatements(response);
			else if(menu == game["menu_quickresponses"])
			maps\mp\gametypes\_quickmessages::quickresponses(response);
			else if(menu == game["menu_quickpromatch"])
			maps\mp\gametypes\_quickmessages::quickpromatch(response);
		}
	}
}

//spray0
changesprays(spray)
{
	//convert to int only
	sprayint = StrRepl(spray,"spray","");
	
	self statSets("SPRAY",int(sprayint));
	//self iprintln ("SPRAYSAVE:  " + sprayint);
	ShowDebug("SPRAYSAVE: ",sprayint);	
}

changeemblem(emblem)
{
	//convert to int only
	ShowDebug("EMBLEMSAVEchangeemblem: ",emblem);

	emblemint = int(StrRepl(emblem,"playercard_emblem_",""));
	
	if(!PodeComprar(20))
	{
		self closeMenu();
		self closeInGameMenu();
		self thread showtextfx2( "Voce eh muito pobre. sem $$$!");
		return;
	}	
	
	if(emblemint > level.scr_playercards_amount)
	emblemint = 0;
	
	self statSets("EMBLEM",int(emblemint));
	self statRemove("EVPSCORE",100);
	self setClientDvar( "ui_emblemstatus1","comprado [-$100]" );
	
	ShowDebug("EMBLEMSAVE: ",emblemint);	
}


classstat( direction )
{
	//definir qual slot usar
	if ( direction == "next" )
		self.classIndex++;
	else
		self.classIndex--;
		
	if ( self.classIndex < 0 )//-1?
		self.classIndex = 9;
	else if ( self.classIndex > 9 )//10
		self.classIndex = 0;

	//SLOT NAME UPDATE
	self setClientDvar( "ui_slotname", "customclass" + self.classIndex );
	//iprintln("SLOT: " + "Slot" + self.classIndex);
}


//Daqui segue o comando para o menusunranked
//APENAS AS CLASSES SALVAS CUSTOM PODE CARREGAR POR AQUI
loadHandler( response )
{	
	//if(level.oldschool) return;
	
	self.classIndex = 0;
	
	self.loadingclass = true;
	
	if(level.showdebug)
	iprintln("^1loadHandler: " + response);
	
	if(response == "customclass0")
	self.classIndex = 0;
	if(response == "customclass1")
	self.classIndex = 1;
	if(response == "customclass2")
	self.classIndex = 2;

	self setClientDvar( "ui_slotname", "CLASSE: " + self.classIndex );


	self thread loadLoadout();

}

//CARREGA OS VALORES DOS STATS
loadLoadout()
{
	
	stat_loadout = [];
	if(self.classIndex == 0)
	{
		stat_loadout[0] = self getStat( 250);//Primaria
		stat_loadout[1] = self getStat( 251 );//Secundaria
		stat_loadout[2] = self getStat( 252);//Special nade
	}
	if(self.classIndex == 1)
	{
		stat_loadout[0] = self getStat( 253);//Primaria
		stat_loadout[1] = self getStat( 254 );//Secundaria
		stat_loadout[2] = self getStat( 255);//Special nade
	}
	if(self.classIndex == 2)
	{
		stat_loadout[0] = self getStat( 256);//Primaria
		stat_loadout[1] = self getStat( 257 );//Secundaria
		stat_loadout[2] = self getStat( 258);//Special nade
	}
	
	ShowDebug("----------changeLoadout---------","");
	//30,5030,weapon_assault,M16A3,m16_gl,60-30,60m
	weaponName = tableLookup( "mp/weaponslist.csv", 0, stat_loadout[0], 3 );//primaria
	SetClassbyWeapon( weaponName );
	
	weaponName = tableLookup( "mp/weaponslist.csv", 0, stat_loadout[1], 3 );//secundaria
	SetClassbyWeapon( weaponName );
	
	weaponName = tableLookup( "mp/weaponslist.csv", 0, stat_loadout[2], 3 );//nades
	SetClassbyWeapon( weaponName );
	
	ShowDebug("----------changeLoadout END---------","");
	
	
	
	self setClientDvar( "ui_slotname", "CARREGADA!");
	
	self closeMenu();
	self closeInGameMenu();
	
	self.loadingclass = false;
}


//converter os stats em nomes
//retorna: flash_grenade
convertLoadoutIntToString( sLoadout )
{
	string_loadout = [];
	
	self.Class = "assault";
	
	//30,5030,weapon_assault,M16A3,m16_gl,60-30,60m
	//0 na tabela 0= pistols 4=avanços(0->4 = beretta)	
	string_loadout[0] = tableLookup( "mp/weaponslist.csv", 0, sLoadout[0], 4 );//Primaria
	string_loadout[1] = tableLookup( "mp/weaponslist.csv", 0, sLoadout[1], 4 );//Secundaria
	string_loadout[2] = tableLookup( "mp/weaponslist.csv", 0, sLoadout[2], 4 );//Special nade
	
	//carrega a classe para o jogador
	self.Class = getclassbyweapon(string_loadout[0]);	

	if(!isDefined(self.Class))
	self.Class = "assault";
	
	//if(level.showdebug)
	//{
		//iprintln ("convertStringC:  " + self.Class);
		//iprintln ("convertString:  " + string_loadout[0]);//beretta
		//iprintln ("convertString:  " + string_loadout[1]);//beretta
		//iprintln ("convertString:  " + string_loadout[2]);//beretta
	//}

	return string_loadout;
}

//flash_grenade
////30,5030,weapon_assault,M16A3,m16_gl,60-30,60m
changeLoadout( loadout )
{
	//aplica a alteraçao de classe
	self.pers[self.Class]["loadout_primary"] = loadout[0];
	self.pers["loadout_secondary"] = loadout[1];
	self.pers["loadout_sgrenade"] = loadout[2];
	
	
	//iprintln("^6changeLoadoutC: " + self.Class);	
	//iprintln("^6changeLoadout1: " + self.pers[self.Class]["loadout_primary"]);	
	//iprintln("^6changeLoadout2: " + self.pers["loadout_secondary"]);
	//iprintln("^6changeLoadout3: " + self.pers["loadout_sgrenade"]);
	
	
	
	
	
	//Need to show the updates
	//self setClientDvars( "loadout_primary", loadout[0],"loadout_secondary", loadout[1],"loadout_grenade", loadout[2]);
}



saveLoadout()
{

	self.Class = self.pers["class"];
	
	if(!isDefined(self.classIndex))
	self.classIndex = 0;
	
	string_loadout = [];
	
	if(!isDefined(self.Class))
	{
		logPrint("ERROR: saveLoadout -> self.Class nao foi definido");
		//iprintln("ERROR: saveLoadout -> self.Class nao foi definido");	
		return;
	}
	
	string_loadout[0] = StrRepl(self.pers[self.class]["loadout_primary"],"_mp","");//m4_gl
	string_loadout[1] = StrRepl(self.pers["loadout_secondary"],"_mp","");//sig226
	string_loadout[2] = StrRepl(self.pers["loadout_sgrenade"],"_mp","");
	
	//sTwname = StrRepl(response, "(A)", "");
	
	//iprintln("^3saveLoadout0: " + self.Class); //demolition	
	//iprintln("^3saveLoadout1: " + self.pers[self.class]["loadout_primary"]);//m1014_mp
	//iprintln("^3saveLoadout2: " + self.pers["loadout_secondary"]);
	//iprintln("^3saveLoadout3: " + self.pers["loadout_sgrenade"]);

	
	
	//CONVERTE A SELECAO EM STATS
	stat_loadout = self convertLoadoutStringToInt( string_loadout );
	
	//APLICADA E SALVA NA TABELA
	self thread uploadStats( stat_loadout );
}



/*
<filename> The table to look up
<search column num> The column number of the stats table to search through
<search value> The value to use when searching the <search column num>
<return value column num> The column number value to return after we find the correct row
*/
//converte os nomes para numeros
convertLoadoutStringToInt( sLoadout )
{ 
	int_loadout = [];
	// 4 = quarta coluna, oque procurar , 0 = coluna que retorna result
	//30,5030,weapon_assault,M16A3,m16_gl,60-30,60m
	int_loadout[0] = tableLookup( "mp/weaponslist.csv", 4, sLoadout[0], 0 );//38
	int_loadout[1] = tableLookup( "mp/weaponslist.csv", 4, sLoadout[1], 0 );//6
	int_loadout[2] = tableLookup( "mp/weaponslist.csv", 4, sLoadout[2], 0 );//104
	

	//iprintln("^3LoadoutStringToInt: " + int_loadout[0]);		
	//iprintln("^3LoadoutStringToInt: " + int_loadout[1]);
	//iprintln("^3LoadoutStringToInt: " + int_loadout[2]);		
	

	return int_loadout;
}


//USA O CLASSTABLE - SALVA OS STATS
uploadStats( loadout )
{			
	if(level.showdebug)
	{
		iprintln("^2uploadStatsidx: " + self.classIndex);
	}

	self setClientDvar( "ui_slotname", "CLASSE: ^1" + self.classIndex + "^7 SALVA!!");
	
	//self.classIndex = Customclass idx
	//250 so preciso usar 3 stats
	if(self.classIndex == 0)
	{
		self setStat( 250, int( loadout[0] ) );//Primaria
		self setStat( 251, int( loadout[1] ) );//Secundaria
		self setStat( 252, int( loadout[2] ) );//Special nade
		return;
	}
	
	if(self.classIndex == 1)
	{
		self setStat( 253, int( loadout[0] ) );//Primaria
		self setStat( 254, int( loadout[1] ) );//Secundaria
		self setStat( 255, int( loadout[2] ) );//Special nade
		return;
	}
	
	if(self.classIndex == 2)
	{
		self setStat( 256, int( loadout[0] ) );//Primaria
		self setStat( 257, int( loadout[1] ) );//Secundaria
		self setStat( 258, int( loadout[2] ) );//Special nade
		return;
	}	
	//CHEGOU AQUI - ESTA SALVA COM SUCESSO.
}