#include common_scripts\utility;
#include maps\mp\_utility;
#include promatch\_utils;

//carregado pelos maps\gsc
main( bScriptgened, bCSVgened, bsgenabled )
{
	//Added
	if ( isDefined( level._loadStarted ) )
	return;
	// Calculate the multiplier to apply to wait() and gettime(). We use 0.05 as that's how long a frame is in the stock game at 20 fps.
	svFPS = getdvard( "sv_fps", "int", 20, 10, 1000 );
	level.oneFrame = 0.05;// 1.0 / svFPS;	
	//thread monitorFramesPerSecond( svFPS );
	
	level._loadStarted = true;

	struct_class_init();//????? N existe referencias
	//INITFLAGS
	if ( !isdefined( level.flag ) )
	{
		level.flag = [];
		level.flags_lock = [];
	}

	setDvar("scr_RequiredMapAspectratio", "1");		
	thread maps\mp\gametypes\_tweakables::init();
	thread maps\mp\_minefields::minefields();
	thread maps\mp\_destructables::init();
	thread maps\mp\_destructible::init();

	VisionSetNight( "default_night" );
	//force off disable all FX
	level.createFX_enabled = 0;

	setupExploders();

	// Do various things on triggers
	for ( p = 0;p < 6;p ++ )
	{
		switch( p )
		{
			case 0:
				triggertype = "trigger_multiple";
				break;

			case 1:
				triggertype = "trigger_once";
				break;

			case 2:
				triggertype = "trigger_use";
				break;
				
			case 3:	
				triggertype = "trigger_radius";
				break;
			
			case 4:	
				triggertype = "trigger_lookat";
				break;

			default:
				assert( p == 5 );
				triggertype = "trigger_damage";
				break;
		}

		triggers = getentarray( triggertype, "classname" );

		for ( i = 0;i < triggers.size;i ++ )
		{
			if( isdefined( triggers[ i ].script_prefab_exploder) )
				triggers[i].script_exploder = triggers[ i ].script_prefab_exploder;

			if( isdefined( triggers[ i ].script_exploder) )
				level thread maps\mp\_load::exploder_load( triggers[ i ] );
		}
	}
}

monitorFramesPerSecond( svFPS )
{
	activeFPS = svFPS;
	
	for (;;)
	{
		xwait( 1, false );
		
		svFPS = getdvard( "sv_fps", "int", 20, 10, 1000 );
		if ( activeFPS != svFPS ) {
			activeFPS = svFPS;
			level.oneFrame = 1.0 / svFPS;
			iprintln( "New level.oneFrame -> " + level.oneFrame );
		}		
	}	
}

exploder_load( trigger )
{
	level endon( "killexplodertridgers" + trigger.script_exploder );
	trigger waittill( "trigger" );
	if ( isdefined( trigger.script_chance ) && randomfloat( 1 ) > trigger.script_chance )
	{
		if ( isdefined( trigger.script_delay ) )
			xwait( trigger.script_delay, false );
		else
			xwait( 4, false );
		level thread exploder_load( trigger );
		return;
	}
	maps\mp\_utility::exploder( trigger.script_exploder );
	level notify( "killexplodertridgers" + trigger.script_exploder );
}


setupExploders()
{
	// Hide exploder models.
	ents = getentarray( "script_brushmodel", "classname" );
	smodels = getentarray( "script_model", "classname" );
	for ( i = 0;i < smodels.size;i ++ )
		ents[ ents.size ] = smodels[ i ];

	for ( i = 0;i < ents.size;i ++ )
	{
		if ( isdefined( ents[ i ].script_prefab_exploder ) )
			ents[ i ].script_exploder = ents[ i ].script_prefab_exploder;

		if ( isdefined( ents[ i ].script_exploder ) )
		{
			if ( ( ents[ i ].model == "fx" ) && ( ( !isdefined( ents[ i ].targetname ) ) || ( ents[ i ].targetname != "exploderchunk" ) ) )
				ents[ i ] hide();
			else if ( ( isdefined( ents[ i ].targetname ) ) && ( ents[ i ].targetname == "exploder" ) )
			{
				ents[ i ] hide();
				ents[ i ] notsolid();
			}
			else if ( ( isdefined( ents[ i ].targetname ) ) && ( ents[ i ].targetname == "exploderchunk" ) )
			{
				ents[ i ] hide();
				ents[ i ] notsolid();
			}
		}
	}

	script_exploders = [];

	potentialExploders = getentarray( "script_brushmodel", "classname" );
	for ( i = 0;i < potentialExploders.size;i ++ )
	{
		if ( isdefined( potentialExploders[ i ].script_prefab_exploder ) )
			potentialExploders[ i ].script_exploder = potentialExploders[ i ].script_prefab_exploder;
			
		if ( isdefined( potentialExploders[ i ].script_exploder ) )
			script_exploders[ script_exploders.size ] = potentialExploders[ i ];
	}

	potentialExploders = getentarray( "script_model", "classname" );
	for ( i = 0;i < potentialExploders.size;i ++ )
	{
		if ( isdefined( potentialExploders[ i ].script_prefab_exploder ) )
			potentialExploders[ i ].script_exploder = potentialExploders[ i ].script_prefab_exploder;

		if ( isdefined( potentialExploders[ i ].script_exploder ) )
			script_exploders[ script_exploders.size ] = potentialExploders[ i ];
	}

	potentialExploders = getentarray( "item_health", "classname" );
	for ( i = 0;i < potentialExploders.size;i ++ )
	{
		if ( isdefined( potentialExploders[ i ].script_prefab_exploder ) )
			potentialExploders[ i ].script_exploder = potentialExploders[ i ].script_prefab_exploder;

		if ( isdefined( potentialExploders[ i ].script_exploder ) )
			script_exploders[ script_exploders.size ] = potentialExploders[ i ];
	}
	
	if ( !isdefined( level.createFXent ) )
		level.createFXent = [];
	
	acceptableTargetnames = [];
	acceptableTargetnames[ "exploderchunk visible" ] = true;
	acceptableTargetnames[ "exploderchunk" ] = true;
	acceptableTargetnames[ "exploder" ] = true;
	
	for ( i = 0; i < script_exploders.size; i ++ )
	{
		exploder = script_exploders[ i ];
		ent = createExploder( exploder.script_fxid );
		ent.v = [];
		ent.v[ "origin" ] = exploder.origin;
		ent.v[ "angles" ] = exploder.angles;
		ent.v[ "delay" ] = exploder.script_delay;
		ent.v[ "firefx" ] = exploder.script_firefx;
		ent.v[ "firefxdelay" ] = exploder.script_firefxdelay;
		ent.v[ "firefxsound" ] = exploder.script_firefxsound;
		ent.v[ "firefxtimeout" ] = exploder.script_firefxtimeout;
		ent.v[ "earthquake" ] = exploder.script_earthquake;
		ent.v[ "damage" ] = exploder.script_damage;
		ent.v[ "damage_radius" ] = exploder.script_radius;
		ent.v[ "soundalias" ] = exploder.script_soundalias;
		ent.v[ "repeat" ] = exploder.script_repeat;
		ent.v[ "delay_min" ] = exploder.script_delay_min;
		ent.v[ "delay_max" ] = exploder.script_delay_max;
		ent.v[ "target" ] = exploder.target;
		ent.v[ "ender" ] = exploder.script_ender;
		ent.v[ "type" ] = "exploder";

		if ( !isdefined( exploder.script_fxid ) )
			ent.v[ "fxid" ] = "No FX";
		else
			ent.v[ "fxid" ] = exploder.script_fxid;
		ent.v[ "exploder" ] = exploder.script_exploder;
		assertEx( isdefined( exploder.script_exploder ), "Exploder at origin " + exploder.origin + " has no script_exploder" );

		if ( !isdefined( ent.v[ "delay" ] ) )
			ent.v[ "delay" ] = 0;
			
		if ( isdefined( exploder.target ) )
		{
			org = getent( ent.v[ "target" ], "targetname" ).origin;
			ent.v[ "angles" ] = vectortoangles( org - ent.v[ "origin" ] );
		}
			
		// this basically determines if its a brush / model exploder or not
		if ( exploder.classname == "script_brushmodel" || isdefined( exploder.model ) )
		{
			ent.model = exploder;
			ent.model.disconnect_paths = exploder.script_disconnectpaths;
		}
		
		if ( isdefined( exploder.targetname ) && isdefined( acceptableTargetnames[ exploder.targetname ] ) )
			ent.v[ "exploder_type" ] = exploder.targetname;
		else
			ent.v[ "exploder_type" ] = "normal";
		
		ent maps\mp\_createfx::post_entity_creation_function();
	}
}


script_gen_dump()
{
	
}
