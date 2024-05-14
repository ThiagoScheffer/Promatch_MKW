#include promatch\_eventmanager;
#include promatch\_utils;

init() 
{

	//falha de limite de precacheStatusIcon max 8
	if(level.cod_mode == "torneio")
	return;

	//Waypoint 3d icons
	precacheShader( "waypoint_rank_leader" );
	precacheShader( "waypoint_rank_membr1" );
	precacheShader( "waypoint_rank_membr2" );
	precacheShader( "waypoint_rank_membr3" );
	precacheShader( "waypoint_rank_membr4" );
	precacheShader( "waypoint_rank_membr5" );	
	precacheShader( "waypoint_rank_medics" );//n conta
	
	level.numSquads = 5;//limite de iconestatus
	level.maxSquadSize = 6;
	level.squadIconLeaderSize = 14;
	level.squadIconMemberSize = 12;
	level.squadIconMaxAlpha = 0.6;
	level.squadHeadOffset = 20;
	level.squadMessageTime = 3;

	
	for( i = 0; i < level.numSquads; i++ ) 
	{
		if( !isDefined( game[ promatch\_squadteam::getSquadFromNumber( i ) ] ) )
		{
			game[ promatch\_squadteam::getSquadFromNumber( i ) ] = [];
		}
	}

	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );

}

onPlayerConnected()
{
	//zera Squadsnames
	//self setClientDvar( "squad_name", "" );
	self.cjs = [];

	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}

onPlayerSpawned() 
{
	//self.squadleader = (self getStat(3164) == 1);
	if (statGets("ATTACHSTATUS") == 1)
	self thread promatch\_dynamicattachments::attachDetachAttachment(true);
	
	
	wait 4;
	
	if( !isDefined(self) )
	return;	
	
	//jogador nao esta em squad algum atualmente
	if( !isDefined( self.squad ) )
	{			
		//verifica se o jogador esta em um squad
		squadname = self GetStatSquad();

		if(isDefined(squadname) && squadname != "")
		{
			self.dont_auto_balance = true;
			self.ffkiller = true;			
			self thread joinSquad( squadname );			
			self thread SquadClientDvar();
		}
		return;
	}
	
	
	//apenas no mesmo round caso morra 
	if( isDefined( self.squad ) ) 
	{
		//iprintln(self.name + " <- Squad " + self.squad);
		self.statusicon = self.squad;
		
		thread watchSquadChange();
		
		self thread SquadClientDvar();//fix names not showing
		
		level thread notifyOnDelay( "change_" + self.squad, 0.05 );
	}
}

//usado para destacar o nome do time ?
SquadClientDvar()
{

	//cg_overheadNamesSize "0.5" -> 0.7
	//cg_drawThroughWalls usar so no jogador squad?	
	self setClientDvars("cg_drawThroughWalls", 1);
	self setClientDvars("cg_overheadNamesSize", 0.7);

}


GetStatSquad()
{

	//retorna o numero representando uma letra
	squaddecimal = self getStat(3163);
	
	if(squaddecimal == 0) return "";
	
	letra = DecimaltoChar(squaddecimal);
	
	return "squad_" + letra;	
}


//STAT para manter o SQUAD ativo em round reset
SetStatSquad(nome)
{
	//RESET ALL
	//self ResetSquadStats();

	
	if(nome == "squad_a")
	{
		self setStat(3163,CharToDecimal("a"));
		return;
	}
	
	if(nome == "squad_b")
	{
		self setStat(3163,CharToDecimal("b"));
		return;
	}
	
	if(nome == "squad_c")
	{
		self setStat(3163,CharToDecimal("c"));
		return;
	}
	
	if(nome == "squad_d")
	{
		self setStat(3163,CharToDecimal("d")); return;
	}
	
	if(nome == "squad_e")
	{
		self setStat(3163,CharToDecimal("e")); return;
	}

}

isonSquad()
{
	if(self getStat(3163) != 0) 
	return true;
	else	
	return false;
}


SetSquadMemberNumber(squad)
{
	
	//verificar se ja ha um lider!
	mynumber = self statGets("SQUAD_NUMBER");
	
	//nao sou 1 aguardar setar o Leader antes dos outros
	if(mynumber != 0 && mynumber != 1)
	wait 2;

	if(!isDefined(game[ squad ][0]))
	{
		if(mynumber == 1)
		{
			game[ squad ][0] = self;
			return;
		}
	}
	
	if(!isDefined(game[ squad ][1]))
	{
		game[ squad ][1] = self;
		self statSets("SQUAD_NUMBER",2);
		return;
	}
	
	if(!isDefined(game[ squad ][2]))
	{
		game[ squad ][2] = self;
		self statSets("SQUAD_NUMBER",3);
		return;
	}
	
	if(!isDefined(game[ squad ][3]))
	{
		game[ squad ][3] = self;
		self statSets("SQUAD_NUMBER",4);
		return;
	}
	
	if(!isDefined(game[ squad ][4]))
	{
		game[ squad ][4] = self;
		self statSets("SQUAD_NUMBER",5);
		return;
	}
	
	if(!isDefined(game[ squad ][5]))
	{
		game[ squad ][5] = self;
		self statSets("SQUAD_NUMBER",6);
	}
}

ResetSquadStats()
{
	self endon("disconnect");

	//self iprintln("ResetSquadStats ");
	
	//caso seja um lider Resetar!
	if(self getStat(3164) != 0)	
	self setStat(3164,0);
	
	self setStat(3163,0);
}



notifyOnDelay( notif, time ) 
{
	wait( time );
	self notify( notif );
}

clearSquadNames()
{
	self setClientDvar( "SQUAD_NUMBER", "" );
	self setClientDvar( "squad_member1", "" );
	self setClientDvar( "squad_member2", "" );
	self setClientDvar( "squad_member3", "" );
	self setClientDvar( "squad_member4", "" );	
}
//level.maxSquadSize = 6;
updateSquadNames( squad ) 
{
	if( !isDefined( squad ) )
		return;
	
	for( i = 0; i < game[ squad ].size; i++ ) 
	{
		for( member = 0; member < level.maxSquadSize; member++ ) 
		{
			if(!isDefined( game[ squad ][ i ] ) ) continue;
			
			//iprintln("updateSquadNames-> " + game[ squad ][ i ].name);
			
			//undefined is not an entity			
			if( !isDefined( game[ squad ][ member ] ) ) 
			{			
				game[ squad ][ i ] setClientDvar( "squad_member" + member, "" );
				continue;
			}
			
			if( member == 0 )
				game[ squad ][ i ] setClientDvar( "SQUAD_NUMBER", game[ squad ][ member ].name );
			else
				game[ squad ][ i ] setClientDvar( "squad_member" + member, game[ squad ][ member ].name );
		}
	}
}

squadResponse( response ) 
{

	//squad_a
	//iprintln("squadResponse-> " + response);
					
	if( response == "leave" ) 
	{
		self closeMenu();
		self closeInGameMenu();
		self thread leaveSquad();	
		return;
	}
	
	
	if( response == "lock" ) 
	{
		if( isDefined( self.squad ) && game[ self.squad ][ 0 ] == self ) 
		{
			if( game[ self.squad ].size > 1 ) 
			{
				if( isDefined( self.leaderLock ) ) 
				{
					self.leaderLock = undefined;
					self hudNotifySquad(self.pers["team"], self.squad, "Seu Squad", "esta destravado agora.", level.squadMessageTime );
				}
				else 
				{
					self.leaderLock = true;
					self hudNotifySquad(self.pers["team"], self.squad, "Seu Squad", "esta travado agora.", level.squadMessageTime );
				}
				
				setSquadDvars( self.squad, "squad_lock", isDefined( self.leaderLock ) );
			}
			else
				self hudNotifyPlayer( "Espere!", "voce precisa de membros para travar!", level.squadMessageTime );
		}
		
		return;
	}

	
	if( isDefined( self.squad ) && "squad_" + response != self.squad && getSquadNumber( "squad_" + response ) < level.numSquads && getSquadNumber( "squad_" + response ) >= 0 )
		self leaveSquad();
	
	wait( 0.05 );
	
	if( getSquadNumber( "squad_" + response ) < level.numSquads && getSquadNumber( "squad_" + response ) >= 0 )
		self thread joinSquad( "squad_" + response );
}

notifySquad(squadteam,squad, headingText, bodyText, time ) 
{
	squadArray = game[ squad ];
	for( i = 0; i < squadArray.size; i++ ) 
	{
		if( !isDefined( squadArray[ i ] ) )
			continue;
			
		if(isDefined(squadteam) && squadArray[ i ].pers["team"] == squadteam)
		squadArray[ i ] hudNotifyPlayer( headingText, bodyText, time );
	}
}
//self.pers["team"] added para filtrar avisos para squad que esta em outro time
hudNotifySquad( squadteam,squad, headingText, bodyText, time ) 
{
	level notifySquad(squadteam, squad, headingText, bodyText, time );
}


hudNotifyPlayer( headingText, bodyText, time ) 
{
	//mudando de time ignorar msg?
	//if(!isDefined( self.switching_teams ))
	self iprintlnbold(headingText +" "+bodyText );
}


joinSquad( squad ) 
{
	self endon("disconnect");
	
	//ja esta em um squad
	if( isDefined( self.squad ) )
	return;
		
	//iprintln("joinSquad-> " + squad);
	
	if( self isBlocked( squad ) ) 
	{
		self hudNotifyPlayer( "Desculpe!", "Voce nao pode entrar agora. " + getSquadTextName( squad ) + " squad", level.squadMessageTime );
		return;
	}

	//esta no limite de squads ou passou? - nao pode entrar no squad
	if( game[ squad ].size >= level.maxSquadSize ) 
	{
		self hudNotifyPlayer( "Desculpe!", getSquadTextName( squad ) + " squad lotado", level.squadMessageTime );
		return;
	}
	//este quebra o invite dos membros - fazer novo codigo !
	//iprintln("game[ squad ][ 0 ]-> " + game[ squad ][ 0 ].name);
	//undefined is not a field object:
	//if( game[ squad ].size > 0 && isDefined( game[ squad ][ 0 ]) ) 
	//{
	//	if(isDefined( game[ squad ][ 0 ].leaderLock ))
	//	self hudNotifyPlayer( "Desculpe!", getSquadTextName( squad ) + " squad esta travado", level.squadMessageTime );
	//	return;
	//}
	
	//iprintln("GetStatSquad1-> " + self GetStatSquad());
	
	//se nao esta em squad algum nem registrado forma um novo squad
	//ainda nao registra o membro apenas avisos
	if( game[ squad ].size == 0 && self GetStatSquad() == "")
	{
		self hudNotifyPlayer( getSquadTextName( squad ), "Squad Formado!", level.squadMessageTime );
		self.leaderLock = undefined;
		self.classLock = undefined;
		self.squadleader = true;
		self statSets("SQUAD_NUMBER",1);
	}
	else //aqui invita outros jogaores a entrar
	{	
		if(self GetStatSquad() == "")
		{			
			self hudNotifyPlayer( "Voce esta agora no Squad ", getSquadTextName( squad ), level.squadMessageTime );
			level hudNotifySquad(self.pers["team"], squad, self.name, "Entrou no seu Squad", level.squadMessageTime );
		}
	}
	
	//grava uma posicao no Array do Squad
	self SetSquadMemberNumber(squad);
	
	//DENTRO DO SQUAD E SALVO
	//squad_a <--
	self.statusicon = squad;
	self.squad = squad;

	self setClientDvar( "squad_name", "^1" + getSquadTextName( self.squad ) + " Squad" );
	self thread SetStatSquad(squad);
	
	//iprintln("GetStatSquad2-> " + self GetStatSquad());
	//----------------------------
	
	self thread leaveSquadOnDisconnect();
	self thread watchSquadChange();
	
	self thread blockOut( squad, 10 );
	
	level notify( "change_" + squad );
	//level thread updateSquadNames( squad );
	
	//undefined is not a field object
	if(isDefined( game[ self.squad ][ 0 ]))
	{
		self setClientDvar( "squad_lock", isDefined( game[ self.squad ][ 0 ].leaderLock ) );
		self setClientDvar( "squad_classlock", isDefined( game[ self.squad ][ 0 ].classLock ) );
	}
	
	
	self closeMenu();
	self closeInGameMenu();
	
	//self iprintln("SQUAD_NUMBER: " + self getStat(3164));
}



leaveSquadOnDisconnect() 
{
	self endon( "leftsquad" );
	
	leaving = self.squad;
	
	self waittill( "disconnect" );
	
	newArray = [];
	for( i = 0; i < game[ leaving ].size; i++ ) 
	{
		if( isDefined( game[ leaving ][ i ] ) )
			newArray[ newArray.size ] = game[ leaving ][ i ];
	}
	game[ leaving ] = newArray;
	
	if( game[ leaving ].size == 1 )
		game[ leaving ][ 0 ].leaderLock = undefined;
	
	level notify( "change_" + leaving );
//	level thread updateSquadNames( leaving );
	
	if( game[ leaving ].size > 1 )
	setSquadDvars( leaving, "squad_lock", isDefined( game[ leaving ][ 0 ].leaderLock ) );
	
	if( game[ leaving ].size > 1 )
	setSquadDvars( leaving, "squad_classlock", isDefined( game[ leaving ][ 0 ].classLock ) );
}

setSquadDvars( squad, dvar, dvarVal ) 
{
	members = game[ squad ];
	for( i = 0; i < members.size; i++ )
		members[ i ] setClientDvar( dvar, dvarVal );
}


leaveSquad( kicked ) 
{
	if( !isDefined( self.squad ) )
		return;
	
	if( !isDefined( kicked ) )
		kicked = false;
	
	leaving = self.squad;
	
	//iprintln("Leaving: " + leaving);
	
	newArray = [];
	for( i = 0; i < game[ leaving ].size; i++ ) 
	{
	//talvez remover da array se este nao estive aqui?
		if(!isDefined(game[ leaving ][ i ])) continue;
		//pair 'undefined' and 'entity'
		if( game[ leaving ][ i ] != self )
			newArray[ newArray.size ] = game[ leaving ][ i ];
	}
	game[ leaving ] = newArray;
	
	self.squad = undefined;
	self setClientDvar( "squad_name", "" );
	self.statusicon = "";
	self ResetSquadStats();
	self notify( "leftsquad" );
	
	if( kicked )
		level hudNotifySquad(self.pers["team"], leaving, self.name, "Foi removido do seu Squad", level.squadMessageTime );
	else
		level hudNotifySquad(self.pers["team"], leaving, self.name, "saiu do seu Squad", level.squadMessageTime );
	
	//quando eu mudo de time estando em um squad
	if( game[ leaving ].size == 1 ) 
	{
		game[ leaving ][ 0 ].leaderLock = undefined;
		self hudNotifyPlayer( getSquadTextName( leaving ) + " squad", "esta travado!", level.squadMessageTime );
	}
	
	
	if( kicked )
		self hudNotifyPlayer( getSquadTextName( leaving ), " foi removido do grupo", level.squadMessageTime );
	else
		self hudNotifyPlayer( getSquadTextName( leaving ), " saiu do squad.", level.squadMessageTime );
	
	if( kicked )
		self thread blockOut( leaving, 30 );
	
	//self clearSquadNames();
	level notify( "change_" + leaving );
	//level thread updateSquadNames( leaving );
	
	if( game[ leaving ].size > 0 ) 
	{
		setSquadDvars( leaving, "squad_lock", isDefined( game[ leaving ][ 0 ].leaderLock ) );
		setSquadDvars( leaving, "squad_classlock", isDefined( game[ leaving ][ 0 ].classLock ) );
	}

}

blockOut( squad, time ) 
{
	self endon( "disconnect" );
	
	self.cjs[ self.cjs.size ] = squad;
	wait( time );
	
	newArray = [];
	for( i = 0; i < self.cjs.size; i++ ) 
	{
		if( self.cjs[ i ] != squad )
			newArray[ newArray.size ] = self.cjs[ i ];
	}
	self.cjs = newArray;
}

isBlocked( squad ) 
{
	if(!isDefined(self.cjs))
	return false;
	
	for( i = 0; i < self.cjs.size; i++ ) 
	{
		if( self.cjs[ i ] == squad )
			return true;
	}
	
	return false;
}

watchSquadChange() 
{
	self endon( "disconnect" );
	self endon( "leftsquad" );
	self endon( "death" );
	
	while( 1 ) 
	{
		level waittill( "change_" + self.squad );
		self SetStatSquad(self.squad);
		self thread updateSquadIcons();
	}
}
//
updateSquadIcons() 
{
	for( i = 0; i < game[ self.squad ].size; i++ ) 
	{
		
		if(!isDefined(game[ self.squad ][ i ]))//fix
		continue;
		
		//pair 'undefined' and 'entity'
		if( game[ self.squad ][ i ] == self )
		continue;
		
		elem = newClientHudElem( self );
		elem.shader = "";
		switch( i ) 
		{
			case 0:
				elem.shader = "waypoint_rank_leader";
				break;
			case 1:
				elem.shader = "waypoint_rank_membr1";
				break;
			case 2:
				elem.shader = "waypoint_rank_membr2";
				break;
			case 3:
				elem.shader = "waypoint_rank_membr3";
				break;
			case 4:
				elem.shader = "waypoint_rank_membr4";
				break;
			default:
				elem.shader = "waypoint_rank_membr5";
				break;
		}
		
		//pode ser usado para feridos...
		//if( isDefined( game[ self.squad ][ i ].needmedic ) )
		//	elem.shader = "specialty_longersprint";
		
		//se for um medico
		if( isDefined( game[ self.squad ][ i ].medicpro ) && game[ self.squad ][ i ].medicpro)
		elem.shader = "waypoint_rank_medics";
		
		elem setShader( elem.shader, level.squadIconLeaderSize, level.squadIconLeaderSize );
		elem setWayPoint( false,elem.shader );
		//elem setTargetEnt( self );
		elem.alpha = 0;		
		elem thread destroyOnUpdate( self.squad );
		elem thread destroyOnDeath( self );
		elem thread destroyOnDisconnect( self );
		elem thread destroyOnDeath( game[ self.squad ][ i ] );
		elem thread destroyOnDisconnect( game[ self.squad ][ i ] );
		//elem thread showSquadOnMinimap( objCompass,elem.shader,self.team );
		elem thread keepPosition( game[ self.squad ][ i ], self, level.squadHeadOffset, false );
		
		//game[ self.squad ][ i ] -> nao sao os jogadores !! squad_a
		
		
	}
	
	//iprintln("updateSquadIcons");
}

destroyOnUpdate( squad ) 
{
	self endon( "death" );
	
	level waittill( "change_" + squad );
	self destroy();
}

destroyOnDisconnect( owner ) 
{
	self endon( "death" );
	
	owner waittill( "disconnect" );
	self destroy();
}

destroyOnDeath( owner ) 
{
	self endon( "death" );
	
	owner waittill( "death" );
	
	self destroy();
}

keepPosition( target, owner, zOff, teamIcon ) 
{
	self endon( "death" );
	
	while( 1 ) 
	{
		wait level.oneFrame;
		
		if( !isDefined( owner.pers ) || !isDefined( target.pers ) || !isDefined( target.sessionState ) ) 
		{
			self.alpha = 0;
			continue;
		}
		
		if( owner.pers[ "team" ] != target.pers[ "team" ] || target.sessionState != "playing" ) 
		{
			self.alpha = 0;
			continue;
		}
		
		if( isDefined( owner.squad ) && isDefined( target.squad ) && teamIcon ) 
		{
			if( owner.squad == target.squad ) {
				self.alpha = 0;
				continue;
			}
		}
		
		headPos = target getTagOrigin( "j_head" );
		
		if( !isDefined( headPos ) ) 
		{
			self.alpha = 0;
			continue;
		}
		
		self.alpha = level.squadIconMaxAlpha;
		
		self.x = headPos[ 0 ];
		self.y = headPos[ 1 ];
		self.z = headPos[ 2 ] + zOff;
	}
}


getSquadNumber( squadName ) {
	switch( squadName ) {
		case "squad_a":
			return 0;
		case "squad_b":
			return 1;
		case "squad_c":
			return 2;
		case "squad_d":
			return 3;
		case "squad_e":
			return 4;
		case "squad_f":
			return 5;
		case "squad_g":
			return 6;
		case "squad_h":
			return 7;
		case "squad_i":
			return 8;
		case "squad_j":
			return 9;
		case "squad_k":
			return 10;
		case "squad_l":
			return 11;
		case "squad_m":
			return 12;
		case "squad_n":
			return 13;
	}
	return -1;
}

getSquadFromNumber( squadNumber ) {
	switch( squadNumber ) 
	{
		case 0:
			return "squad_a";
		case 1:
			return "squad_b";
		case 2:
			return "squad_c";
		case 3:
			return "squad_d";
		case 4:
			return "squad_e";
		case 5:
			return "squad_f";
		case 6:
			return "squad_g";
		case 7:
			return "squad_h";
		case 8:
			return "squad_i";
		case 9:
			return "squad_j";
		case 10:
			return "squad_k";
		case 11:
			return "squad_l";
		case 12:
			return "squad_m";
		case 13:
			return "squad_n";
	}
	return "none";
}

getSquadName( squadNumber ) 
{
	switch( squadNumber ) 
	{
		case 0:
			return "squad_a";
		case 1:
			return "squad_b";
		case 2:
			return "squad_c";
		case 3:
			return "squad_d";
		case 4:
			return "squad_e";
	}
	return "none";
}

getSquadTextName( squad ) 
{
	switch( squad ) 
	{
		case "squad_a":
			return "Alpha";
		case "squad_b":
			return "Bravo";
		case "squad_c":
			return "Charlie";
		case "squad_d":
			return "Delta";
		case "squad_e":
			return "Echo";
	}
	return "Invalid";
}

getPlayerFromEntNum( num ) {
	players = level.players;
	for( i = 0; i < players.size; i++ ) {
		if( players[ i ] getEntityNumber() == num )
			return players[ i ];
	}
	
	return undefined;
}