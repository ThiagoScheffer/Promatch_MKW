#include promatch\_utils;

sprayonwall()
{
	self endon( "disconnect" );
	self endon( "spawned_player" );
	self endon( "joined_spectators" );
	self endon( "death" );
	
		
		//if(level.ignorebloodfx)
		//return;
		
		if(isdefined(self.usingspray) && self.usingspray)
		return;
		
		if(!isdefined(self.usedspraytimes))
		self.usedspraytimes = 0;		
		
		if(self.usedspraytimes > 7)
		return;
		
		if(!isDefined(self.pers["rank"]))
		return;		
		
		if(!PodeComprar(20 - self.pers["rank"]))
		{
			self thread showtextfx( "Voce eh muito pobre. sem $$$!");
			return;
		}		
		
		self.usingspray = true;

		if( !self isOnGround() )
		{
			wait 0.2;
			self.usingspray = false;
			return;
		}

		angles = self getPlayerAngles();
		eye = self getTagOrigin( "j_head" );
		forward = eye + tempvector_scale( anglesToForward( angles ), 70 );
		trace = bulletTrace( eye, forward, false, self );
		
		if( trace["fraction"] == 1 ) //we didnt hit the wall or floor
		{
			self.usingspray = false;
			return;		
		}

		position = trace["position"] - tempvector_scale( anglesToForward( angles ), -2 );
		angles = vectorToAngles( eye - position );
		forward = anglesToForward( angles );
		up = anglesToUp( angles );


		sprayidx = self statGets("SPRAY");
		//ShowDebug("SPRAY:[sprayidx]->",sprayidx);
		/*
		type undefined is not an int: (file 'promatch/_dospray.gsc', line 65)
		playFx( level._effect["spray"+sprayidx], position, forward, up );
                       *
		*/
		//Shaders testing
		//ShowDebug("SPRAY:[position]->",position);
		//ShowDebug("SPRAY:[forward]->",forward);
		//ShowDebug("SPRAY:[up]->",up);
		
		
		playFx( level.sprayonwall["spray"+sprayidx], position, forward, up );
		
		self playSound( "sprayit" );
		self statRemove("EVPSCORE",15);
		self.usedspraytimes = self.usedspraytimes + 1;
		wait 3;
		
		self.usingspray = false;

}
