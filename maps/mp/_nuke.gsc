//******************************************************************************
//  _____                  _    _             __
// |  _  |                | |  | |           / _|
// | | | |_ __   ___ _ __ | |  | | __ _ _ __| |_ __ _ _ __ ___
// | | | | '_ \ / _ \ '_ \| |/\| |/ _` | '__|  _/ _` | '__/ _ \
// \ \_/ / |_) |  __/ | | \  /\  / (_| | |  | || (_| | | |  __/
//  \___/| .__/ \___|_| |_|\/  \/ \__,_|_|  |_| \__,_|_|  \___|
//       | |               We don't make the game you play.
//       |_|                 We make the game you play BETTER.
//
//            Website: http://openwarfaremod.com/
//******************************************************************************

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include promatch\_utils;
init()
{
// Nuke related dvars
	level.scr_nuke_timer = getdvarx( "scr_nuke_time", "int", 11, 10, 50 );
	level.scr_nuke_endgame = getdvarx( "scr_nuke_endgame", "int", 1, 0, 1 );	
	level.nukefx = loadfx ("explosions/nuke");
	level.nukefx2 = loadfx ("explosions/nuke_explosion");
	level.nukeflash = loadfx ("explosions/nuke_flash");
	
	precacheShader("hudStopwatch");
	precacheShader( "icon_0" );
	precacheShader( "icon_1" );
	precacheShader( "icon_2" );
	precacheShader( "icon_3" );
	precacheShader( "icon_4" );
	precacheShader( "icon_5" );

	precacheShellShock( "radiation_high" );
	//precacheShellShock( "flash" );

	
	level.nukeuser = undefined;
	level.nuke = false;

}
rotatingNukeIcon()
{
    self endon("death");
   
    iconNumber = 0;
   
    for (;;) 
	{
        if ( isDefined( self ) )
            self setShader( "icon_" + iconNumber, 32, 32 );
       
        iconNumber++;
        if ( iconNumber > 5 ) iconNumber = 0;
       
        wait 0.08;
    }
}

nuke()
{
	self endon("disconnect");
	self endon("killed_player"); 
	
	loc = level.mapCenter;
	
	self thread NukeCountdown( loc );
	
}

AllplayersNuke()
{
	self playLocalSound( "nuke_warning" );
	
  if(!isDefined(self.watch))
  {
     self.watch = newClientHudElem(self);
     self.watch.x = 200;
     self.watch.y = 100;
     self.watch.alignx = "center";
     self.watch.aligny = "middle";
     self.watch.horzAlign = "fullscreen";
     self.watch.vertAlign = "fullscreen";
     self.watch.alpha = .9;
     self.watch.fontScale = 2;
     self.watch.sort = 100;
     self.watch.foreground = true;
     self.watch.color = (1,0,0);
     self.watch.glowColor = (0.2, 0.3, 0.7);
     self.watch.glowAlpha = 1;
     self.watch setTenthsTimer( level.scr_nuke_timer );
  }
  if(!isDefined(self.nuke_icon))
  {
     self.nuke_icon = newClientHudElem(self);
     self.nuke_icon.x = 143;
     self.nuke_icon.y = 98;
     self.nuke_icon.alignx = "center";
     self.nuke_icon.aligny = "middle";
     self.nuke_icon.horzAlign = "fullscreen";
     self.nuke_icon.vertAlign = "fullscreen";
	 self.nuke_icon.glowColor = (0.2, 0.3, 0.7);
     self.nuke_icon.glowAlpha = 1;
     self.nuke_icon.alpha = .9;
     self.nuke_icon.sort = 100;
     self.nuke_icon.foreground = true;
	 self.nuke_icon thread rotatingNukeIcon();  
  }
  
   wait level.scr_nuke_timer;
  
  if(isDefined(self.watch))
  {  
	self.watch destroy();
	self.nuke_icon destroy();
  }
  
}

NukeCountdown( position )
{
   level notify( "nuke" );
   
   level.nukeuser = self;
   
   //nukeTimer = level.scr_nuke_timer;
   
      team = level.nukeuser.pers["team"];
      otherTeam = level.otherTeam[team];
      
	  //pq o wav nao le mais? - tem que estar em MP3
      maps\mp\gametypes\_globallogic::leaderDialog( "nuke_friendly", team );
      maps\mp\gametypes\_globallogic::leaderDialog( "nuke_enemy", level.otherTeam[team] );

	randint = randomint(5);
	mensagem = "";
	
	if(randint == 0 || randint == 1)
      mensagem = " chamou o Tactical Nuke .. fodam-se todos !! vlww flwww!";
	  if(randint == 2)
      mensagem = " Esta bombando o futuro de voces...";
	  if(randint == 3)
      mensagem = " chamou a Bomba da xuxa stars..";
	  if(randint == 4)
      mensagem = " the Hell is coming..Corram para a muralha que derrete!";
	  if(randint == 5)
      mensagem = " e Deus entao disse... Humanos pra que ?";

	players = getEntarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		player iprintlnbold(level.nukeuser.name + mensagem);
		
		if(level.nukeuser == player)
		player GiveEVP(2000,100);
		
		player thread AllplayersNuke();
		player setClientDvar( "r_filmusetweaks", 0);
		player setClientDvar( "r_fullbright", "0" );
	}
	
	
	wait level.scr_nuke_timer;

	position = level.mapCenter;
	position2 = (250,0,0);
	position3 = (300,100,0);
	
	self playSound( "V1Rocket" );
	wait 8;
	
	nuke = spawn( "script_origin", position );

	nuke playSound( "nuke_fuse" );

	wait 2;

	playFX( level.nukefx, position );

	visionSetNaked("nuke",0);
	
	playFX( level.nukeflash, position3 );

	nuke playSound( "nuke_drop" );
	nuke playSound( "nuke_explode" );

	wait 0.1;

	playFX( level.nukefx2, position2 );
	
	level.nuke = true;

	wait 0.5;

	earthquake( 1, 1.5, position, 80000);

	players = getEntarray( "player", "classname" );

	for( i = 0; i < players.size; i++ )
	{
		player = players[i];

		player playSound( "nuke_aftermath" );

		player shellshock( "radiation_high", 1 );

		player ViewKick( 127, player.origin );

		player.health = player.maxhealth - 45;
	}


	wait 0.8;

/*
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];

		handOrigin = self getTagOrigin( "tag_weapon_right" );

		playFX( level.nukewind, handOrigin );

	}
*/

	wait 5.0;


	// Kill players
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];

		player thread maps\mp\_flashgrenades::applyFlash(3, 0.75);

	}


	wait 0.8;


	// Kill all Players
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		
		player thread [[level.callbackPlayerDamage]]( level.nukeuser, level.nukeuser, player.health, level.iDFLAGS_NO_KNOCKBACK, "MOD_EXPLOSIVE", "gl_mp", ( 0, 0, 0 ), ( 0, 0, 0 ), "torso_upper", 0 );

	}
	
	visionSetNaked("nuke2",1);

	AmbientStop( 20 );


	wait 1.5;
	//thread maps\mp\gametypes\_globallogic::endGame( "allies", "Tactical Nuke" );
	level.endedbynuke = true;
	
	if(isDefined(self))
	thread maps\mp\gametypes\_globallogic::endGame( level.nukeuser.pers["team"], "Tactical Nuke" );
	else
	level thread maps\mp\gametypes\_globallogic::endGame( undefined, "Tactical Nuke" );
	
	level.nukeuser = undefined;
	level.nuke = false;

	nuke Delete();
}