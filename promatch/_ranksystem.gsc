#include promatch\_eventmanager;
#include promatch\_utils;
#include promatch\_spreestreaks;

//10 partidas para dar um RANK baseado na qualidade do jogador?

//RANK1 500 - LATAO
//RANK2 2000 - BRONZE
//RANK3 3000 - PRATA
//RANK4 4000 - OURO
//RANK5 5000 - PLATINA
//RANK6 6000 - DIAMANTE
//RANK7 7000 - ELITE
//RANK8 10000 - SUPREMO

//calcular o ultimo rank?
//3182,RANKED
//3183,RANKPOINTS
//3188,RANK


//setRank(0,1) - reseta para nulo o rank
//setRank(0,0) - seria o rank 1
//ao usar o rank a cada 3 muda o icone 1 2 3 - 4 novo icone

init()
{
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );	
}


onPlayerConnected()
{
	//reset todos para 0
	self setRank(0,1);

	self.isRanked = true; // self getStat(3182);
	
	
	if ( level.gametype == "sd")
	{
		self thread onPlayerKilled();
		self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	}
}

//so 1x ao dar spawn por round
onPlayerSpawned()
{
	if ( isDefined( self.pers["isBot"] ) && self.pers["isBot"] )
	{
		self.isRanked = true;
		self.pers["rank"] = self getStat(3188);
		//return;
	}
	
	self thread RankupChecking();
}




//strike2 forca luz e fog?
FogFix()
{
	self endon ( "disconnect" );
	wait 5;
	self setClientDvar( "r_fog", 0 );
}

RankGametypes(gtype)
{
	switch(gtype)
	{
		case "sd":
		return true;
	
		case "ctf":
		return true;
		
		case "dom":
		return true;
		
		default:
		return false;
	}
}

//caregar aqui variaveis de spawn do rank
InitRank()
{
	self.pers["rank"] = self getStat(3188); //para multiplicar o rank xp e giveevp
}

//realtimestats -> achievements() - resume os ranks
//pelo jeito roda so no 1 spawn de cada mapa !
RankupChecking()
{
	self endon("disconnect");
	
	//necessario inicializar mesmo se nao for usado no modo
	self InitRank();
	
	//se for false return. modo nao permitido para rank
	if(!RankGametypes(level.atualgtype)) return;
	
	wait 4;
	
	//if(!isdefined(self.class))
	//return;	
	
	//self iprintln("isRanked: " + self.isRanked);
	
	if(!isDefined(self.checkedplayer))
	{
		//verificar se ele saiu antes da partida acabar!
		self RankDisconnectPunish();
			
		self thread AllowRankPunish();
		
		self thread SetAllPlayerstoMaxRank();
	}

	
	//se o jogador nao faz parte do rank nao tem pq ativar o resto!
	if(!self.isRanked) return;
	
	self DefineRank();
	
	wait 1;	
	
	mortes = self statGets("DEATHS");		
	somakills = statGets("KILLS");
		
	//update Rank menu
	if(self getStat(2305) > 0)
	self setClientDvar("ui_mystat_kratio",  getSubStr( (somakills/mortes), 0, 4 ));	
	
	self setClientDvars("ui_stat_bestname",  getDvar("sv_bestname"),"ui_stat_bestkills",  getDvar("sv_bestkills"),"ui_stat_bestrank", getDvar("sv_bestrank"),"ui_stat_bestkd", getDvar("sv_bestkd"));

	self setClientDvar( "ui_stat_bannedcount",  getDvar("sv_bannedcount") );
	self setClientDvar( "ui_stat_bannedname",  getDvar("sv_bannedaname") );
	
	//self setClientDvars( "ui_stat_worst1",  getDvar("sv_bannedcount") );
	
	//self setClientDvars( "ui_stat_worst2",  getDvar("sv_bannedaname") );
	
	rankname = self ConvertRankToName();
	rankiconname = self ConvertRankToIconName();
	
	if(isDefined(rankname) && isDefined(rankiconname))
	self setClientDvars("ui_rankname", rankname,"ui_rankiconname", rankiconname);
	
	if (isDefined( self.pers["isBot"] ) && self.pers["isBot"])
	{
		self.pers[ "bots" ][ "skill" ][ "base" ] = self.pers["rank"];
	}
}


//ao sair de uma partida ou evento X
// o jogador ira ser punido e perder pontos
//aqui vai rodar quando o jogador conectar no server novamente 
//foi constatado que no final do mapa ele nao resetou o valor do stat para 0
//sendo entao confirmado que ele saiu antes de terminar o mapa
AllowRankPunish()
{
	self endon("disconnect");
		
	if(level.gametype != "sd") 
	return;
	
	if(level.cod_mode != "public") return;
	
	if (isDefined( self.pers["isBot"] ) && self.pers["isBot"])
	return;
	
	if(level.players.size <= 5) //normal 8
	return;

	if(!self.isRanked) return;
	
	self iprintln("^125s para o Rank Lock! ^3( Apenas podera sair no Votemap !)");

	wait 25;//tempo para o jogador sair e n ser marcado
	
	//if(isDefined(self.admin) && self.admin)
	//return;
	
	//punish ativado! apenas em SD
	if(isDefined(self))
	self setStat(3185,1);
	
	self iprintln("^1Rank Locked !");	
}
//reseta no fim na votacao - SaveRankPointstoProfile
RankDisconnectPunish()
{
	self endon("disconnect");
	
	if (isDefined( self.pers["isBot"] ) && self.pers["isBot"])
	return;

	//se na ofor SD ou nao for modo public
	if(level.gametype != "sd" || level.cod_mode != "public")
	{
		self setStat(3185,0);//reset punish
		return;
	}
	
	wait 2;//dar um tempo parra essas verificacoes	
	
	if(isDefined(self.admin) && self.admin)
	{
		self setStat(3185,0);//reset punish
		return;
	}	
	
	if(level.players.size < 4)
	{
		self setStat(3185,0);//reset punish
		return;
	}
	
	//se estiver em modo de teste ignorar punish
	//if(self getStat(3184) == 0) return;
	
	//RANKED
	//if(self.isRanked) return;
	
	//punish
	if(self getStat(3185) != 0)
	{
		self setStat(3185,0);//reset punish		
		
		discrank = -5000;
		
		if(self getStat(3183) >= 2500)
		self statAdds("RANKPOINTS",discrank);
		
		iprintln(self.name + " ^1<-- Saiu antes de uma partida em ^2Rankeada^1.");
		
		//registra o evento
		//self thread logteste(self GetDate() + ": " + self.name + " [PUNISHEDRANK]");
	}
}


//3184,RANKPASSED
//Apos estar registrado em modo prestigio
//conta cada partida jogada por inteiro
//assim que jogar as 10 o sistema verificar os pontos e seta um RANK
//apartir do desempenho do jogador nos jogos
DefineRank()
{
	if(!self.isRanked) return;
	
	//qual a atuao pontuacao?
	rankpoints = self GetRankPoints();
	
	if (isDefined( self.pers[ "isBot" ] ) && self.pers[ "isBot" ] == true)
	{
		rankpoints = randomintrange(4000,6000);
	}
	//iprintln("DefineRank points: " + rankpoints);
	
	//nao refazer toda hora o codigo ao dar spawn!
	//if(isDefined(self.pers["rank"]) && self.pers["rank"] != 0)
	//return;
	
	//MANTEM O RANK DENTRO DO LIMITE
	//---------------------------
	if(rankpoints < 1)
	self SetApplyRankPoints(1);
	
	if(rankpoints > 9000)
	self SetApplyRankPoints(9000);
	//---------------------------
	
	if(rankpoints < 1000)
	{
		self setRank(0,1);
		self statSets("RANK",1);
		self.pers["rank"] = 1;
		return;
	}
	
	//entre 1-500
	if(rankpoints >= 1000 && rankpoints < 2000)
	{
		rankx = randomintrange(0,2);
		self setRank(rankx,0);
		self statSets("RANK",1);
		self.pers["rank"] = 1;
		return;
	}
	
	if(rankpoints >= 2000 && rankpoints < 3000)
	{
		
		rankx = randomintrange(3,5);
		self setRank(rankx,0);
		self statSets("RANK",2);
		self.pers["rank"] = 2;
		return;
	}
	
	if(rankpoints >= 3000 && rankpoints < 4000)
	{
		rankx = randomintrange(6,8);
		self setRank(rankx,0);
		self statSets("RANK",3);
		self.pers["rank"] = 3;
		return;
	}
	
	if(rankpoints >= 4000 && rankpoints < 5000)
	{
		rankx = randomintrange(9,11);
		self setRank(rankx,0);
		self statSets("RANK",4);
		self.pers["rank"] = 4;
		return;
	}
	

	
	if(rankpoints >= 5000 && rankpoints < 6000)
	{
		rankx = randomintrange(12,14);
		self setRank(rankx,0);
		self statSets("RANK",5);
		self.pers["rank"] = 5;
		return;
	}
	
	//acima rank 
	self.ffkiller = true;
	
	if(rankpoints >= 6000 && rankpoints < 7000)
	{
		rankx = randomintrange(15,17);
		self setRank(rankx,0);
		self statSets("RANK",6);
		self.pers["rank"] = 6;
		return;
	}
	
	if(rankpoints >= 7000 && rankpoints < 8000)
	{
		rankx = randomintrange(18,20);
		self setRank(rankx,0);
		self statSets("RANK",7);
		self.pers["rank"] = 7;
		return;
	}
	
	if(rankpoints >= 8000)
	{
		self setRank(21,0);
		self statSets("RANK",8);
		self.pers["rank"] = 8;
		return;
	}
	
}

ConvertRankToName()
{
	
	//qual a atuao pontuacao?
	rankpoints = self GetRankPoints();
	
	//entre 1-1999
	if(rankpoints >= 1000 && rankpoints < 2000)
	return "LIXAO";
	
	if(rankpoints >= 2000 && rankpoints < 3000)
	return "BRONZE";
	
	if(rankpoints >= 3000 && rankpoints < 4000)
	return "PRATA";
	
	if(rankpoints >= 4000 && rankpoints < 5000)
	return "OURO";
	
	if(rankpoints >= 5000 && rankpoints < 6000)
	return "PLATINA";
	
	if(rankpoints >= 6000 && rankpoints < 7000)
	return "DIAMANTE";
	
	if(rankpoints >= 7000 && rankpoints < 8000)
	return "ELITE";
	
	if(rankpoints >= 8000)
	return "SUPREMO";	
}

ConvertRankToIconName()
{
	//qual a atuao pontuacao?
	rankpoints = self GetRankPoints();
	
	//entre 1-1999
	if(rankpoints >= 1000 && rankpoints < 2000)
	return "rank_pfc1";
	
	if(rankpoints >= 2000 && rankpoints < 3000)
	return "rank_lcpl1";
	
	if(rankpoints >= 3000 && rankpoints < 4000)
	return "rank_cpl1";
	
	if(rankpoints >= 4000 && rankpoints < 5000)
	return "rank_sgt1";
	
	if(rankpoints >= 5000 && rankpoints < 6000)
	return "rank_ssgt1";
	
	if(rankpoints >= 6000 && rankpoints < 7000)
	return "rank_gysgt1";
	
	if(rankpoints >= 7000 && rankpoints < 8000)
	return "rank_msgt1";
	
	if(rankpoints >= 8000)
	return "rank_mgysgt1";	
}


onPlayerKilled()
{
	self endon("disconnect");	
	
	if(level.cod_mode == "torneio") return;

	//se for false return. modo nao permitido para rank
	//if(!RankGametypes(level.atualgtype)) return;
	if(level.gametype != "sd") return;
		
	for (;;) 
	{
		self waittill( "player_killed", eInflictor, attacker,iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, fDistance);
		
		if ( sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_SUICIDE" ) continue;
		
		if(level.players.size < 4)
		continue;
		
		victim = self;	
		
		//cannot cast undefined to bool
		if(!isDefined(victim)) continue;
		
		if(!isDefined(attacker)) continue;
		
		if ( !isPlayer( attacker )) continue;
					
		if(attacker.pers["team"] == victim.pers["team"]) continue;
				
		if(attacker == self) continue;

		//eu morri perco meu rank em pontos
		victim SetRankPoints(victim.pers["rank"] * -45);
		
		//matei recebo o rank da vitima
		attacker SetRankPoints(victim.pers["rank"] * 45);

		//victim thread onPlayerKilledTicket();
		
		//attacker thread onPlayerKilledTicket();
	}
}


//set death updates rate - save stats
UpdateandSaveRank()
{
	self endon("disconnect");	
		
	self SaveRankPointstoonDeath();
	
	//update rank points
	self thread DefineRank();
}


ResetRankStatsInit()
{	
	self statSets("WLRATIO",0);	
	self statSets("KILLS",0);
	self statSets("SCORE",0);
	self statSets("KILL_STREAK",0);
	self statSets("DEATHS",0);
	self statSets("ACCURACY",0);
	self statSets("ASSISTS",0);
	self statSets("HEADSHOTS",0);
	self statSets("KNIFES",0);
	self statSets("HUMILIATIONS",0);
	self statSets("OWNAGES",0);
	self statSets("KDRATIO",0);
	self statSets("WINS",0);
	self statSets("LOSSES",0);
	self statSets("DEFUSED",0);
	self statSets("PLANTED",0);
	self statSets("FIRSTBLOOD",0);
	self statSets("LOSSES",0);
	self statSets("TIME_PLAYED_ALLIES",0);
	self statSets("TIME_PLAYED_OPFOR",0);
	self statSets("TIME_PLAYED_TOTAL",0);
	
	self setStat(3182,0);
	self setStat(3183,0);
	self setStat(3184,0);
	self setStat(3185,0);
	self setStat(3186,0);
	self setStat(3187,0);
	self setStat(3188,0);
}

ResetRankStats()
{	
	//self statSets("VIPUSER",1);
	//self.vipuser = true; 
	//self statSets("RANK",8);
	//self statSets("RANKPOINTS",8000);	
}

SetAllPlayerstoMaxRank()
{
	//se ja estiver em rank ignorar
	if (self getStat(3182) > 0)
	return;
	 
	//self statSets("VIPUSER",1);
	//self.vipuser = true; 
	self statSets("RANK",8);
	self statSets("RANKPOINTS",8000);
	self statSets("RANKED",1);//ativo em modo rank
}

//remover depois!
ChangeTempRankID()
{
	//SET A VERSION KEY TO AVOID BACKUP HACK
	//3169,CHAVEDEUPDATE v7.0
	//APOS 1-2 SEMANAS QUEM NAO TIVER ESSA CHAVE RESETA O RANK SEMPRE!
	//self setStat(3169,70);
	//18.10.20
	/*if (self getStat(3169) != 70)
	{
		self statSets("VIPUSER",0);
		self.vipuser = false; 
		self statSets("RANK",1);
		self statSets("RANKPOINTS",1);
		self statSets("RANKED",1);//ativo em modo rank
	}*/
}