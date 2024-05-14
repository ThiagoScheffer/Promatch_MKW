#ifndef MAP_X
#define MAP_X					(-(MAP_WIDTH - RIGHTITEM_OFFSET + 165 ))
#endif

#ifndef MAP_Y
#define MAP_Y					70//centro direito AQUI SOBE
#endif

#ifndef MAP_WIDTH
#define MAP_WIDTH				240
#endif

#ifndef MAP_HEIGHT	
#define MAP_HEIGHT				268
#endif

#define ORIGIN_MAP_FRAME		MAP_X MAP_Y
#define MAP_OFFSET 0 21

#define ALLIES_HAVE_UAV (dvarint( ui_uav_allies ) && team( name ) == "TEAM_ALLIES" )
#define AXIS_HAVE_UAV (dvarint( ui_uav_axis ) && team( name ) == "TEAM_AXIS" )
#define CLIENT_HAS_UAV (dvarint( ui_uav_client ) && team( name ) == "TEAM_FREE" )
#define SHOULD_SHOW_MAP (FADEFX == 0)
//#define SHOULD_SHOW_MAP 1

// map display ================================================

//#define UI_MAP_NAME		"@"+tablelookup("mp/mapsTable.csv",0,dvarString(mapname),3)


	itemDef
   	{
		name			"mini_map2"
		rect			ORIGIN_MAP_FRAME MAP_WIDTH MAP_WIDTH RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP
		origin			MAP_OFFSET
		forecolor		1 1 1 1
		background		"compass_map_default"
		ownerdraw		CG_PLAYER_FULLMAP_MAP
		visible			when ( SHOULD_SHOW_MAP );
		decoration
   	}

	itemDef
   	{
		style			WINDOW_STYLE_SHADER
		name			"mini_map2_overlay"
		rect			ORIGIN_MAP_FRAME MAP_WIDTH MAP_WIDTH RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP
		origin			MAP_OFFSET
		forecolor		1 1 1 1
		exp				material( tableLookup( "mp/mapsTable.csv", 0, dvarString( mapname ), 7 ) )
		//visible			when ( SHOULD_SHOW_MAP );
		visible			0
		decoration
   	}
   	
	// Objective pointers
	itemDef
	{
		name			"compasspointers2"
		rect			ORIGIN_MAP_FRAME MAP_WIDTH MAP_WIDTH RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP
		origin			MAP_OFFSET
		forecolor		1 1 1 1
		background		"objective_line"
		ownerdraw		CG_PLAYER_FULLMAP_POINTERS
		visible			when ( SHOULD_SHOW_MAP );		
		decoration
	}
   	// Friendlies pointers
	itemDef
	{
		name			"compassfriendlies2"
		rect			ORIGIN_MAP_FRAME MAP_WIDTH MAP_WIDTH RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP
		origin			MAP_OFFSET
		forecolor		1 1 1 1
		background		"compassping_friendly"
		ownerdraw		CG_PLAYER_FULLMAP_FRIENDS
		visible			when ( SHOULD_SHOW_MAP );
		decoration
	}
   	// Enemy pings
	itemDef
	{
		name			"compassenemies2"
		rect			ORIGIN_MAP_FRAME MAP_WIDTH MAP_WIDTH RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP
		origin			MAP_OFFSET
		forecolor		1 1 1 1
		background		"compassping_enemy"
		ownerdraw		CG_PLAYER_FULLMAP_ENEMIES
		visible			0 //when ( ( dvarbool( ui_hud_hardcore ) == 0 && dvarint( ui_minimap_show_enemies_firing ) == 1 ) || ALLIES_HAVE_UAV || AXIS_HAVE_UAV || CLIENT_HAS_UAV );
		decoration
	}
	// Player direction indicator
	itemDef
	{
		name			"compassplayer2"
		rect			ORIGIN_MAP_FRAME MAP_WIDTH MAP_WIDTH RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP
		origin			MAP_OFFSET
		forecolor		1 1 1 1
		background		"compassping_player"
		ownerdraw		CG_PLAYER_FULLMAP_PLAYER
		visible			when ( SHOULD_SHOW_MAP );
		decoration
	}		

		itemDef	{
			rect			ORIGIN_MAP_FRAME MAP_WIDTH 20 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP
			origin			-6 36
			textfont		UI_FONT_NORMAL
			textstyle		ITEM_TEXTSTYLE_SHADOWED
			textscale		TEXTSIZE_SMALL
			textalign		ITEM_ALIGN_RIGHT
			forecolor		1 1 1 0.85
			exp text ( dvarString(ui_mapname_text) );
			visible			when ( SHOULD_SHOW_MAP );
			decoration
		}

