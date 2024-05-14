//**********************************************************************************
//                                                                                  
//        _   _       _        ___  ___      _        ___  ___          _             
//       | | | |     | |       |  \/  |     | |       |  \/  |         | |            
//       | |_| | ___ | |_   _  | .  . | ___ | |_   _  | .  . | ___   __| |___       
//       |  _  |/ _ \| | | | | | |\/| |/ _ \| | | | | | |\/| |/ _ \ / _` / __|      
//       | | | | (_) | | |_| | | |  | | (_) | | |_| | | |  | | (_) | (_| \__ \      
//       \_| |_/\___/|_|\__, | \_|  |_/\___/|_|\__, | \_|  |_/\___/ \__,_|___/      
//                       __/ |                  __/ |                               
//                      |___/                  |___/                                
//                                                                                  
//                       Website: http://www.holymolymods.com                       
//*********************************************************************************
// Original Coded for Openwarfare Mod by [105]HolyMoly  Dec.15/2014
// V.2.0
//Coded for Promatch by EncryptorX  26.5.16

#include promatch\_eventmanager;
#include promatch\_utils;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
//	if(self statGets("SHOWEMBLEMS") == 1 )//inicialmente todos estarao com 0
		//return;
init()
{

	// Get the main module's dvars
	level.scr_playercards = getdvarx( "scr_playercards", "int", 1, 0, 1 );  

        // If not activated
	if ( level.scr_playercards == 0 )
		return;

        // NO Center Obit
        setDvar( "ui_hud_show_center_obituary", "0" );

        // NO KILLCAM............. doesn't show playercards properly! -> Verificar onde o problema ocorre
        //setDvar( "scr_game_allow_killcam", "0" );

        // Dvars Playercards
        if( level.scr_playercards > 0 ) 
		{
			level.scr_playercards_time_visible = getdvarx( "scr_playercards_time_visible", "float", 2.5, 1.5, 5 );
			level.scr_playercards_que = getdvarx( "scr_playercards_que", "int", 3, 1, 10 );
        }

       level.scr_playercards_amount = 21;

     // Precache playercards
	for( cards = 0; cards < level.scr_playercards_amount; cards++ ) 
	{
		precacheShader( "playercard_emblem_" + cards );
	}
	
	precacheStatusIcon( "rank_capt1" );//MEMBER
	precacheStatusIcon( "rank_2ndlt1" );//CUSTOMM
	
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );

}

onPlayerConnected()
{

	if( !isDefined( self.playerCard ) ) //usar stat aqui para o jogador criar sua propria
	{
			//self.playerCard = self statGets("EMBLEMS");//randomIntRange( 0, level.scr_playercards_amount );
			self.playerCard = self statGets("EMBLEM");//randomIntRange( 0, level.scr_playercards_amount );
			self.showingPlayercard = false;
			self.showingPlayercardHp = false;
			self.playercardQue = 0;
			self.playercardHpQue = 0;			
			//showDebug("self.playerCard: ",self.playerCard);
	}
	
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}


showvipIcon()
{
	self endon("disconnect");
	//self endon( "death" );

	xwait( 6.0, false );

	if (isAlive(self)) 
	{		
		if(self.clanmember)
		{
			self.statusicon = "rank_capt1";
			return;
		}
		
		if(self.custommember)
		{
			self.statusicon = "rank_2ndlt1";
			return;
		}
	}
}

onPlayerSpawned()
{
		//VIP ICON
		if(level.cod_mode == "public")
		{			
			self thread showvipIcon();			
		}
		
		if(level.cod_mode == "torneio")
		return;
		
		if(self statGets("EMBLEM") > level.scr_playercards_amount)
		{
			self statSets("EMBLEM",level.scr_playercards_amount - 1);
			self.playerCard = self statGets("EMBLEM");
		}
	
		//ShowDebug("level.scr_playercards: ",level.scr_playercards);
		
        // Playercards Active
        if( level.scr_playercards > 0 ) 
		{
				// Killed by / You Killed
                if( !isDefined( self.playercardText ) )
				{
	                self.playercardText = newClientHudElem( self );
	                self.playercardText.x = 0; 
                    self.playercardText.y = -90;
	                self.playercardText.alignX = "center";
	                self.playercardText.alignY = "top";
	                self.playercardText.horzAlign = "center";
	                self.playercardText.vertAlign = "bottom";
	                self.playercardText.fontScale = 2;
	                self.playercardText.sort = -1;
	                self.playercardText.glowAlpha = 0;
                    self.playercardText.alpha = 0;

                }

                // Player Name
                if( !isDefined( self.playercardName ) )
				{
	                self.playercardName = newClientHudElem( self );
	                self.playercardName.x = -10; 
                    self.playercardName.y = -65;
	                self.playercardName.alignX = "center";
	                self.playercardName.alignY = "top";
	                self.playercardName.horzAlign = "center";
	                self.playercardName.vertAlign = "bottom";
	                self.playercardName.fontScale = 2.3;
	                self.playercardName.sort = -1;
	                self.playercardName.glowAlpha = 0;
                    self.playercardName.alpha = 0;

                }
				/*              
			   // Player Rank Number
                if( !isDefined( self.playercardRankNumber ) )
				{
	                self.playercardRankNumber = newClientHudElem( self );
	                self.playercardRankNumber.x = -89; 
                    self.playercardRankNumber.y = -60;
	                self.playercardRankNumber.alignX = "center";
	                self.playercardRankNumber.alignY = "top";
	                self.playercardRankNumber.horzAlign = "center";
	                self.playercardRankNumber.vertAlign = "bottom";
	                self.playercardRankNumber.fontScale = 2;
	                self.playercardRankNumber.sort = -1;
	                self.playercardRankNumber.glowAlpha = 0;
                    self.playercardRankNumber.alpha = 0;

                }*/
                // Background Image
                if( !isDefined( self.playercardImage ) ) 
				{
	                self.playercardImage = newClientHudElem( self );
	                self.playercardImage.x = 0;
	                self.playercardImage.y = -70; //-130	
	                self.playercardImage.sort = -2;
                    self.playercardImage.alignX = "center";
	                self.playercardImage.alignY = "top";
	                self.playercardImage.horzAlign = "center";
	                self.playercardImage.vertAlign = "bottom";
                    self.playercardImage.alpha = 0;
                }
			/*	
				// Rank Icon
				if ( !isDefined( self.playercardRankIcon ) ) 
				{
					self.playercardRankIcon = self createIcon( "white", 25, 25 );
					self.playercardRankIcon setPoint( "CENTER", "BOTTOM", -111, -50 );
					self.playercardRankIcon.sort = -1;
					self.playercardRankIcon.alpha = 0;
				}
			
                // Team Icon
                if( level.scr_playercards == 1 ) 
				{
	                if ( !isDefined( self.playercardTeamIcon ) ) 
					{
		                self.playercardTeamIcon = self createIcon( "white", 40, 40 );
		                self.playercardTeamIcon setPoint( "CENTER", "BOTTOM", 105, -50 );
		                self.playercardTeamIcon.sort = -1;
		                self.playercardTeamIcon.alpha = 0;
	                }
                }*/
        }

 
        if( level.scr_playercards > 0 ) 
		{
                self thread waitForKill();
        }
}

//self GetStat( 3153 )
GetrankIcon(statnumer)
{
	//	iprintlnBold(statnumer);
	switch( statnumer )
	{
		case 1:
		return "insignia"+statnumer;
		case 2:
		return "insignia"+statnumer;
		case 3:
		return "insignia"+statnumer;
		case 4:
		return "insignia"+statnumer;
		case 5:
		return "insignia"+statnumer;
		case 6:
		return "insignia"+statnumer;
		case 7:
		return "insignia"+statnumer;
		case 8:
		return "insignia"+statnumer;
		case 9:
		return "insignia"+statnumer;
		case 10:
		return "insignia"+statnumer;
		case 11:
		return "insignia"+statnumer;
		case 12:
		return "insignia"+statnumer;
		case 13:
		return "insignia"+statnumer;
		case 14:
		return "insignia"+statnumer;
		case 15:
		return "insignia"+statnumer;
		
		default:
		return "rank_pfc1";
	}	
}

waitForKill()
{
	self endon("disconnect");

	
	// Wait for the player to die
	self waittill( "player_killed", eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, fDistance );

		if(isDefined(level.nuke) && level.nuke == true)
		return;

        // Suicide
        if( !isPlayer( attacker ) || attacker == self  ) 
		{
              return;
        }

        // Team Kill
        if( level.teamBased ) 
		{
			if( attacker.pers["team"] == self.pers["team"] ) 
			{
					return;
			}
        }
	
        // Victim Info
        playercardVictim = spawnstruct();
        playercardVictim.name = self.name;
		//playercardVictim.rank = self statGets("RANK");//EVP Rank
        playercardVictim.card = self.playerCard;
       // playercardVictim.icon = self GetrankIcon(self statGets("INSIGNIA"));
        //playercardVictim.team = game["icons"][self.team];
        playercardVictim.text = "Morto por";

        //Attacker Info
        playercardAttacker = spawnstruct();
        playercardAttacker.name = attacker.name;
        //playercardAttacker.rank = attacker statGets("EVPRANK");
        playercardAttacker.card = attacker.playerCard;
		//playercardAttacker.icon = attacker GetrankIcon(attacker statGets("INSIGNIA"));
       // playercardAttacker.team = game["icons"][attacker.team];
        playercardAttacker.text = "";
		playercardAttacker.weapon = sWeapon;

        // Victim Thread
        if( isDefined( self ))
                self thread showVictimCard( playercardVictim, playercardAttacker  );
        
        // Attacker Thread
        if( isDefined( attacker ))
                attacker thread showAttackerCard( playercardVictim, playercardAttacker );

        

}

//MOSTRAR O CARTAO DE QUEM FOI MORTO
showVictimCard( playercardVictim, playercardAttacker )
{
	self endon("disconnect");

		/*if(playercardVictim == self)
		{	
			// Victim Info
			playercardVictim = spawnstruct();
			playercardVictim.name = playercardVictim.name;	
			playercardVictim.card = playercardVictim.playerCard;   
			playercardVictim.text = "Morto por";
		}

		if(playercardAttacker == self)
		{	
			//Attacker Info
			playercardAttacker = spawnstruct();
			playercardAttacker.name = playercardAttacker.name;
			playercardAttacker.card = playercardAttacker.playerCard;
			playercardAttacker.text = "";
			//playercardAttacker.weapon = sWeapon;
		}
		*/

        // Add incoming card
        self.playercardQue++;

        // Cards must never be negative amount......... Maybe not needed?
        if( isDefined( self.playercardQue ) && self.playercardQue < 0 )
                self.playercardQue = 0;
      
        // Debug
        // self iprintlnBold( "Playercard = " + self.playercardQue );

        // Return if exceeds Que amount and open Que spot
        if( isDefined( self.playercardQue ) && self.playercardQue > level.scr_playercards_que ) 
		{
                // self iprintlnBold( "Playercard returned!" );
                self.playercardQue--;
                return;
        }

        // Self Spectating
        if( self.sessionstate == "spectator" ) 
		{
			self.showingPlayercard = false;
			self.showingPlayercardHp = false;
			self.playercardQue = 0;
			self.playercardHpQue = 0;
			return;
		}
        // Game ended or Intermission
        if( level.gameEnded || level.intermission) 
		{
                return;
        }

        // Wait if already showing a card
        while( isDefined( self.showingPlayercard ) && self.showingPlayercard == true ) {
                wait level.oneFrame;
        }

        self.showingPlayercard = true;

        // Set shader and make visable
        self.playercardImage setShader( "playercard_emblem_" + playercardAttacker.card, 256, 40 );
        
		//self.playercardRankIcon setShader( playercardAttacker.icon, 25, 25 );

        self.playercardName setText( playercardAttacker.name );
        self.playercardName.color = ( 1, 1, 1 );

        self.playercardText setText( playercardVictim.text );
        self.playercardText.color = ( 0.98, 0.67, 0.67 );

        //self.playercardRankNumber setText( playercardAttacker.rank );
        //self.playercardRankNumber.color = ( 0.97, 0.96, 0.34 );
       // self.playercardTeamIcon setShader( playercardAttacker.team, 40, 40 );
        

        self.playercardImage.alpha = 0.9;
		
		//self.playercardRankIcon.alpha = 1;
        self.playercardName.alpha = 1;
        self.playercardText.alpha = 1;
        //self.playercardRankNumber.alpha = 1;
        // self.playercardTeamIcon.alpha = 1;
        

        // Time shader visible
        wait( level.scr_playercards_time_visible );

        // Move to bottom and set non-visible
        self.playercardImage moveOverTime( 0.40 );
     // self.playercardRankIcon moveOverTime( 0.40 );
        self.playercardName moveOverTime( 0.40 );
        self.playercardText moveOverTime( 0.40 );
       // self.playercardRankNumber moveOverTime( 0.40 );
       // self.playercardTeamIcon moveOverTime( 0.40 );
        

        self.playercardImage.y = 20;
       //self.playercardRankIcon.y = 30;
        self.playercardName.y = 30;
        self.playercardText.y = 0;
       //self.playercardRankNumber.y = 30;
         //self.playercardTeamIcon.y = 40;
        

        // Time wait to move to bottom
        wait( 0.4 );

        // Move back to start position.
        self.playercardImage moveOverTime( 0.40 );
     //  self.playercardRankIcon moveOverTime( 0.40 );
        self.playercardName moveOverTime( 0.40 );
        self.playercardText moveOverTime( 0.40 );
       // self.playercardRankNumber moveOverTime( 0.40 );
       // self.playercardTeamIcon moveOverTime( 0.40 );
       

        self.playercardImage.y = -70;
       // self.playercardRankIcon.y = -50;
        self.playercardName.y = -65;
        self.playercardText.y = -90;
       // self.playercardRankNumber.y = -60;
        //self.playercardTeamIcon.y = -50;
       

        self.playercardImage.alpha = 0;
       // self.playercardRankIcon.alpha = 0;
        self.playercardName.alpha = 0;
        self.playercardText.alpha = 0;
       // self.playercardRankNumber.alpha = 0;
       // self.playercardTeamIcon.alpha = 0;
        

        // Time wait to move back
        wait( 0.4 );

        // Remove card from Que
        self.playercardQue--;

        self.showingPlayercard = false;

        // Hint - to make all the hud elements move together in time you must move the SAME number of units
        //        for each element. Start and stop positions must total the same amount each element must move!

}

showAttackerCard( playercardVictim, playercardAttacker ) // attacker is self
{
	self endon("disconnect");
	//self endon("begin_killcam");
	
	
		/*if(playercardVictim == self)
		{	
			// Victim Info
			playercardVictim = spawnstruct();
			playercardVictim.name = self.name;	
			playercardVictim.card = self.playerCard;   
			playercardVictim.text = "Morto por";
			//Attacker Info
			playercardAttacker = spawnstruct();
			playercardAttacker.name = self.name;
			playercardAttacker.card = self.playerCard;
			playercardAttacker.text = "";
			//playercardAttacker.weapon = sWeapon;
		}*/

        // Add incoming card
        self.playercardQue++;

        // Cards must never be negative amount......... Maybe not needed?
        if( isDefined( self.playercardQue ) && self.playercardQue < 0 )
                self.playercardQue = 0;
      
        // Debug
        // self iprintlnBold( "Playercard = " + self.playercardQue );

        // Return if exceeds Que amount and open Que spot
        if( isDefined( self.playercardQue ) && self.playercardQue > level.scr_playercards_que ) 
		{
                // self iprintlnBold( "Playercard returned!" );
                self.playercardQue--;
                return;
        }

        // Self Spectating
		if( self.sessionstate == "spectator" || self statGets("SHOWEMBLEMS") == 0 )
		{

                self.showingPlayercard = false;
                self.showingPlayercardHp = false;
                self.playercardQue = 0;
                self.playercardHpQue = 0;
                return;
        }

        // Game ended or Intermission
        if( level.gameEnded || level.intermission ) 
		{
                return;
        }

        // Wait if already showing a card
        while( isDefined( self.showingPlayercard ) && self.showingPlayercard == true ) {
               wait level.oneFrame;
        }

        self.showingPlayercard = true;

        // Set shader and make visable
        self.playercardImage setShader( "playercard_emblem_" + playercardVictim.card, 256, 40 );
      // self.playercardRankIcon setShader( playercardVictim.icon, 25, 25 );

        self.playercardText setText( playercardAttacker.text );
        self.playercardText.color = ( 0.73, 0.97, 0.71 );

        self.playercardName setText( playercardVictim.name );
        self.playercardName.color = ( 1, 1, 1 );

        //self.playercardRankNumber setText( playercardVictim.rank );
      // self.playercardRankNumber.color = ( 0.97, 0.96, 0.34 );
      //   self.playercardTeamIcon setShader( playercardVictim.team, 40, 40 );
        

        self.playercardImage.alpha = 0.9;
     // self.playercardRankIcon.alpha = 1;
        self.playercardText.alpha = 1;
        self.playercardName.alpha = 1;
       // self.playercardRankNumber.alpha = 1;
        //  self.playercardTeamIcon.alpha = 1;
        

        // Time shader visible
        wait( level.scr_playercards_time_visible );

        // Move to bottom and set non-visible
        self.playercardImage moveOverTime( 0.40 );
       //self.playercardRankIcon moveOverTime( 0.40 );
        self.playercardText moveOverTime( 0.40 );
        self.playercardName moveOverTime( 0.40 );
       // self.playercardRankNumber moveOverTime( 0.40 );
       // self.playercardTeamIcon moveOverTime( 0.40 );
       

        self.playercardImage.y = 20;
     // self.playercardRankIcon.y = 30;
        self.playercardText.y = 0;
        self.playercardName.y = 30;
       // self.playercardRankNumber.y = 30;
       // self.playercardTeamIcon.y = 40;
        
		// Time wait to move to bottom
        wait( 0.4 );

        // Move back to start position
        self.playercardImage moveOverTime( 0.40 );
       //self.playercardRankIcon moveOverTime( 0.40 );
        self.playercardText moveOverTime( 0.40 );
        self.playercardName moveOverTime( 0.40 );
       // self.playercardRankNumber moveOverTime( 0.40 );
        //  self.playercardTeamIcon moveOverTime( 0.40 );
        

        self.playercardImage.y = -70;
      // self.playercardRankIcon.y = -50;
        self.playercardText.y = -90;
        self.playercardName.y = -65;
       // self.playercardRankNumber.y = -60;
		//self.playercardTeamIcon.y = -50;
        

        self.playercardImage.alpha = 0;
       // self.playercardRankIcon.alpha = 0;
        self.playercardText.alpha = 0;
        self.playercardName.alpha = 0;
        //self.playercardRankNumber.alpha = 0;
         //self.playercardTeamIcon.alpha = 0;
        
        // Time wait to move back
        wait( 0.4 );

        // Remove card from Que
        self.playercardQue--;

        self.showingPlayercard = false;

        // Hint - to make all the hud elements move together in time you must move the SAME number of units
        //        for each element. Start and stop positions must total the same amount each element must move! 

}