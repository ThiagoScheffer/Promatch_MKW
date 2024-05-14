#include promatch\_utils;

init()
{
}

quickbuy(response)//b6
{
	self endon("disconnect");
	
	if(!isAlive(self)) return;
	
	//if(level.cod_mode == "torneio" ) return;
	
	if(level.gametype == "sd")
	{
		if(isSubStr(response,"buyrpg")) return;
		
		if(isSubStr(response,"buyc4")) return;
		
		if(isSubStr(response,"buytatical_spawn")) return;//fix taticabuy using keynum
	}
	
	//autocompra
	if(isSubStr(response,"auto"))
	{	
		//iprintln("auto: " + response);
	
		self AutoItemBuy(response);
		return;
	}
	
	//buytime
	if(!isDefined(self.canbuy))
	{
		//self iPrintLn("^3Ja passou o tempo permitido de compra!");
		self thread showtextfx( "^3Ja passou o tempo permitido de compra!");
		self setClientDvar("ui_itemcomprado","Tempo expirou!");
		return;
	}
	
	//impede de outra compra intervir - utils 6229
	if(!isDefined(self.comprandoitem))
	self thread ItemBuy(response);	
}

AutoItemBuy(response)
{
	self endon("disconnect");
	self endon("death");
	
	//autobuytear_grenade
	//remove auto e usa o resto para procurar na tabela e retornar ou setar o valor para 1 ou 0
	itembyname = StrRepl( response, "auto", "");
	statusatual = self GetAutoCompraItemStat(itembyname);
	//iprintln("itembyname: " + itembyname);
	//iprintln("statusatual: " + statusatual);
	
	//se estiver off seta 1
	if(statusatual == 0)
	self SetAutoCompraItemStat(itembyname,1);
	else
	self SetAutoCompraItemStat(itembyname,0);	
	
	//iprintln("statget: " + self getStat(2370));
}


quickpromatch(response)//B4
{
	self endon("disconnect");
	
	if(!isAlive(self)) return;
	
	switch(response)
	{
		case "1":
		self thread promatch\_keybinds::changeskinweapon();
		break;


		case "2":
		if(self.medic && !isDefined( self.carryObject ))
		{
			self thread promatch\_medic::dropHealthPack();
		}
		else
		self Dropcarryitem();
		break;

		case "3":
		if(!isDefined(self.poisonedarrow))
		self suicide();
		break;
		
		case "4":
		self promatch\_promatchbinds::ResetUserConfig();
		break;

		case "5":
		self thread promatch\_promatchbinds::ShowStats();
		xwait(8,false);
		break;
			
		case "6":
		self promatch\_promatchbinds::weaponfov();
		break;

		case "7":
		if ( isDefined( game["state"] ) && game["state"] == "postgame" )
		break;
		else
		self thread promatch\_dynamicattachments::attachDetachAttachment(false);
		break;		
		
		case "doteleport":
		if ( level.cod_mode != "practice")
		{		
			self iPrintLn("^1Invalid Mode or Server Mode, turn off the sv_punkbuster");
			break;
		}
		self thread promatch\_promatchbinds::doTeleport();
		break;
		
		case "nodamage":
		if ( level.cod_mode != "practice")
		{
			self iPrintLn("^1Invalid Mode or Server Mode");				
			break;	
		}
		self thread promatch\_promatchbinds::noDamagePlayer();
		break;
		
	}
}
quickpromatch2(response)//Menu avançado  b61
{
	self endon("disconnect");
	if(!isAlive(self)) return;
	
	switch(response)
	{
		case "doteleport":
		if ( level.cod_mode != "practice")
		{		
			self iPrintLn("^1Invalid Mode or Server Mode, turn off the sv_punkbuster");
			break;
		}
		self thread promatch\_promatchbinds::doTeleport();
		break;
		
	case "b":
		if ( level.cod_mode != "practice" || getDvarInt("sv_punkbuster" ) != 0 )
		{		
			self iPrintLn("^1Invalid Mode or Server Mode or punkbuster is on");
			break;
		}
		self thread promatch\_nadepractice::bot();
		break;
		
	case "p":
		if ( level.cod_mode != "practice")
		{			
			self iPrintLn("^1Invalid Mode or Server Mode");
			break;
		}
		self thread promatch\_promatchbinds::penetration();
		break;
		
	case "r":
		if ( level.cod_mode != "practice")
		{
			self iPrintLn("^1Invalid Mode or Server Mode");			
			break;
		}
		self thread promatch\_promatchbinds::recoil();
		break;
		
	case "t":
		if ( level.cod_mode != "practice")
		{
			self iPrintLn("^1Invalid Mode or Server Mode");				
			break;	
		}
		self iPrintLn("Position= " + self.origin);
		self thread promatch\_promatchbinds::target();
		break;
	case "nodmg":
		if ( level.cod_mode != "practice")
		{
			self iPrintLn("^1Invalid Mode or Server Mode");				
			break;	
		}
		self thread promatch\_promatchbinds::noDamagePlayer();
		break;
	}
}

quickcommands(response)
{
	self endon ( "disconnect" );	
	
	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || isdefined(self.spamdelay))
	return;

	self.spamdelay = true;
	switch(response)		
	{
	case "1":
		soundalias = "mp_cmd_movein";			
		saytext = "Para o ^1A";
		
		break;

	case "2":
		soundalias = "mp_cmd_movein";			
		saytext = "Para o ^1B";
		
		break;

	case "3":
		soundalias = "mp_cmd_movein";			
		saytext = "Pelo centro!";
		
		break;

	case "4":
		soundalias = "mp_stm_needreinforcements";			
		saytext = "De-me Cobertura !";
		
		break;

	case "5":
		soundalias = "";			
		saytext = "Defendendo o ^1B";
		
		break;

	case "6":
		soundalias = "";			
		saytext = "Defendendo o ^1A";
		
		break;

	case "7":
		soundalias = "mp_cmd_holdposition";			
		saytext = "Guardem esta posicao!";
		
		break;

	default:
		assert(response == "8");
		soundalias = "mp_cmd_followme";			
		saytext = "Reunam-se comigo!";
		
		break;
	}

	self doQuickMessage(soundalias, saytext);

	xwait( 2.0, false );
	self.spamdelay = undefined;
	
}

quickstatements(response)
{
	self endon("disconnect");
	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || isdefined(self.spamdelay))
	return;

	self.spamdelay = true;
	
	switch(response)			
	{
	case "1":
		soundalias = "";			
		saytext = "Contato avistado no ^1A";
		
		break;

	case "2":
		soundalias = "";			
		saytext = "Contato avistado no ^1B";
		
		break;

	case "3":
		soundalias = "mp_stm_areasecure";			
		saytext = "A Limpa !";
		
		break;

	case "4":
		soundalias = "mp_stm_areasecure";			
		saytext = "B Limpa !";
		
		break;

	case "5":
		soundalias = "";
		saytext = "Contato avistado no nosso ^1Spawn";

		break;

	case "6":
		soundalias = "";
		saytext = "";
		self CallMedic();
		break;

	default:
		assert(response == "7");
		soundalias = "";
		saytext = "Inimigo perto de mim ! ";
		break;
	}

	self doQuickMessage(soundalias, saytext);

	xwait( 2.0, false );
	self.spamdelay = undefined;
}

CallMedic()
{	
	if(self.sessionstate != "playing")
	return;

	if(isdefined(self.spamdelay))
	return;

	if ( !level.teamBased )
	return;
	
	if(!isDefined(self.health))
	return;
	
	//se nao ha medicos no time
	if(!CheckTeamforMedic(self.pers["team"]))
	return;
	
	self.spamdelay = true;
	soundalias = "";
	
	//preciso de vida!
	if(self.health < 95)
	{
		if(!isDefined(self.medicmarker))
		self thread promatch\_medic::ShowonCompass(self,false);
	
		//TODO medic - send msg and health
		medictaunt = randomint(2);
		if(medictaunt == 1)
		soundalias = "medic1";
		else
		soundalias = "medic2";	
	} 
	//cannot cast undefined to bool: (file 'maps/mp/gametypes/_quickmessages.gsc', line 462)
	//se eu preciso de municao 
	if(self.health >= 100 && self NeedAmmoCheck())
	{
		//TODO medic - send msg and health
		medictaunt = randomint(2);
		if(medictaunt == 1)
		soundalias = "needammo1";
		else
		soundalias = "needammo2";
	}
		//iprintln(soundalias);
		
		self playSound( soundalias );
		
		if(isSubStr(soundalias,"medic"))
		self sayTeam("Medico !");
		else if(isSubStr(soundalias,"needammo"))
		self sayTeam("Preciso de Municao !");
	
	
	xwait( 2.0, false );
	self.spamdelay = undefined;
}

quickresponses(response)
{
	self endon("disconnect");
	
	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || isdefined(self.spamdelay))
	return;

	self.spamdelay = true;

	switch(response)		
	{
	case "1":
		soundalias = "mp_rsp_yessir";
		saytext = "Afirmativo.";

		break;

	case "2":
		soundalias = "mp_rsp_nosir";			
		saytext = "Negativo.";
		
		break;

	case "3":
		soundalias = "";			
		saytext = "Obrigado.";
		
		break;

	case "4":
		soundalias = "mp_rsp_sorry";			
		saytext = "Desculpa!";

		break;

	case "5":
		soundalias = "mp_rsp_greatshot";
		saytext = "Belo Tiro!";

		break;

	default:
		assert(response == "6");
		soundalias = "mp_stm_enemydown";
		saytext = "Alvo eliminado!";

		break;
	}

	self doQuickMessage(soundalias, saytext);

	xwait( 2.0, false );
	self.spamdelay = undefined;
}


doQuickMessage( soundalias, saytext )
{
	if(self.sessionstate != "playing")
	return;

	if ( self.pers["team"] == "allies" )
	{
		if ( game["allies"] == "sas" )
		prefix = "UK_";
		else
		prefix = "US_";
	}
	else
	{
		if ( game["axis"] == "russian" )
		prefix = "RU_";
		else
		prefix = "AB_";
	}

	if(isdefined(level.QuickMessageToAll) && level.QuickMessageToAll)
	{
		if(soundalias != ""){self playSound( prefix+soundalias );};
		
		self sayAll(saytext);
	}
	else
	{
		if(soundalias != ""){self playSound( prefix+soundalias );};
		self sayTeam( saytext );
		self pingPlayer();
	}
}