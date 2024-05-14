#include promatch\_eventmanager;
#include promatch\_utils;
//V104
init()
{
	level.scr_guidcs_enable = getdvarx( "scr_guidcs_enable", "int", 0, 0, 1 );
	level.scr_torneio_check = getdvarx( "scr_torneio_check", "int", 0, 0, 1 );
	//if(level.cod_mode != "public")
	//return;

	if(level.scr_guidcs_enable == 0)
		return;
	
	//REGISTERED NAMES
	level.RegNamesList = getdvarlistx( "scr_RegNamesList_", "string", "" );//Nicknames REgistrado por guid
	//REGISTERED GUIDS
	level.GuidNamesList = getdvarlistx( "scr_GuidNamesList_", "string", "" );//Guid registradas para um unico nome
	//FOR AUTOHACK SET
	level.BadNamesList = getdvarlistx( "scr_Badnames_", "string", "" );//CHECK hack players names
	level.BadGuids = getdvarx( "scr_BadGuids", "string", "" );//CHECK GUIDS for Satanized hackers
	
	//TIMES DO DIA - CADASTRADO PARA ENTRAR
	level.RegtTimesList = getdvarlistx( "scr_RegtTimesTime_", "string", "" );//Time registrados por numero
	//set scr_RegtTimesTime_1 "1"
	//set scr_RegtTimesTime_2 "2"
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}

onPlayerConnected()
{
	
	//dar um tempo do check para garantir todas as outras funcoes de carregar antes de remover o jogador!
	wait 8;
	
	if(!isDefined(self))
	return;	
	
	if(statGets("ADMIN")) return;
	
	if(level.cod_mode == "torneio" && level.scr_torneio_check)
	{
		//if(self statGets("TIMENUM") == 1)
		
		//nao precisa verificar é um streammer
		if(statGets("BROADCASTER") == 1) return;
	
	
		NumeroTime = self statGets("TIMENUM");
		
		
		
		if(level.RegtTimesList.size != 0)
		{
			//Nicknames REgistrado por guid
			for ( i=0; i < level.RegtTimesList.size; i++ ) 
			{					
				
				if(!isSubStr(level.RegtTimesList[i],NumeroTime))// se este numero nao esta cadastrado n tem permissao
				{	

						self closeMenu();
						self closeInGameMenu();
						self iprintlnbold("Voce nao tem permissao para estar neste server !");
						wait (6.0);								
						logPrint( "Blocked;K;" + self.name + ";" + self getguid() + "\n" );
						kick( self getEntityNumber() );
						return;//cancela toda resto da verficaçao pois o jogador foi removido
					
				}			
			} 
		}
		
		return;
	}
	
	if( level.scr_guidcs_enable == 1)//Ativado modo registro
	{
		//bc51fd6e845c7ea20562bf96fa72580a=EncryptorX  ->level.RegNamesList[i]
		SelfGuid = self getguid();
		SelfName = monotone(self.name);
		playerGUIDCheck = self getguid() +"=" + SelfName;
		
		if(level.RegNamesList.size != 0)
		{
			//Nicknames REgistrado por guid
			for ( i=0; i < level.RegNamesList.size; i++ ) 
			{					
				//nome cadastrado mas guid dif avisar e kickar
				if(isSubStr(level.RegNamesList[i],SelfName))// verifica se a nome esta nick, caso nao. ignora.
				{	
					//self iprintlnbold(level.RegNamesList[i]);
					
					if(!isSubStr(level.RegNamesList[i],playerGUIDCheck))
					{
						//self iprintlnbold("Guid errada");			
						//break;
						//Fechar Menus
						self closeMenu();
						self closeInGameMenu();
						self iprintlnbold("Voce esta usando um Name registrado e protegido !");
						wait (6.0);								
						logPrint( "Blocked;K;" + self.name + ";" + self getguid() + "\n" );
						kick( self getEntityNumber() );
						return;//cancela toda resto da verficaçao pois o jogador foi removido
					}
				}			
			} 
		}
		//Procura pela lista a combinaçao registrada do jogador e guid
		if(level.GuidNamesList.size != 0)
		{
			for ( i=0; i < level.GuidNamesList.size; i++ ) 
			{	 
				
				//guid esta cadastrada nao pode usar outro nickname
				if(!isSubStr(level.GuidNamesList[i],SelfGuid))// verifica se a guid esta cadatrado, caso nao. ignora.
				continue;
				
				//self iprintlnbold(SelfGuid +" -> "+level.GuidNamesList[i]);
				//Se o jogador estiver nesta lista e estiver usando outro nick kickar.
				if(!isSubStr(level.GuidNamesList[i],playerGUIDCheck))
				{
					//self iprintlnbold(level.GuidNamesList[i]);			
					//break;
					//Retorna se for normal.
					//Fechar Menus
					self closeMenu();
					self closeInGameMenu();
					self iprintlnbold("Voce nao esta usando o Name registrado para esta uid !");
					//self iprintlnbold( level.GuidNamesList[i]);
					wait (6.0);								
					logPrint( "Blocked;K;" + self.name + ";" + self getguid() + "\n" );
					kick( self getEntityNumber() );
					return;//cancela toda resto da verficaçao pois o jogador foi removido
				}
			}
		}
	}
	
	if(level.BadGuids != "")
	{
		SelfGuid = self getguid();
		//iprintlnbold("BADGUID");
		//Se a guid que este player estiver usando estiver cadastrada verificar.
		if(isSubStr(level.BadGuids,SelfGuid))
		{	
			if ( self statGets("NODAMAGE") == 0)
			self statSets("NODAMAGE",3);//no damage
			//iprintlnbold(SelfGuid);
		}
	}
		
		//iprintln("Size: " + level.BadNamesList.size);
		
		if(level.BadNamesList.size == 0)
			return;

	for ( iLine=0; iLine < level.BadNamesList.size; iLine++ ) 
	{
		thisLine = level.BadNamesList[iLine];
		thisLine = strtok( thisLine, "+" );//Separa os nomes 
		for ( iName = 0; iName < thisLine.size; iName++ ) 
		{
			//iprintln("N: " + thisLine[iName]);
			if (thisLine[iName] == monotone(self.name) )
			{
				//self iprintlnbold("Voce esta usando um nickname proibido!");
				//wait (6.0);	
				logPrint( "BlockedName;K;" + self.name + ";" + self getguid() + "\n" );
				kick( self getEntityNumber() );
				return;
			}
		}
	}	

}

