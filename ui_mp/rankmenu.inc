{
	menuDef
	{
		name			rankmenu
		rect			0 0 640 480
		focuscolor		COLOR_FOCUSED
		style			WINDOW_STYLE_EMPTY
		blurWorld		5.0
		onOpen
		{
			setLocalVarBool ui_hidemainmenu 1;
		}
		onClose
		{
			setLocalVarBool ui_hidemainmenu 0;
		}
		onEsc
		{
			//scriptMenuResponse "back";
			close self;
			play "menu_close";
		}
		
	itemDef
	{
		exp				text("RANK STATUS")
		style			WINDOW_STYLE_FILLED
		rect			50 25 540 20
		textstyle		ITEM_TEXTSTYLE_NORMAL
		textfont		UI_FONT_DEFAULT
		textalign		ITEM_ALIGN_LEFT
		textalignx		5
		textaligny		20
		textscale		0.4
		backcolor		0 0 0 1
		forecolor		1 1 1 1
		visible			1
		decoration
	}

	itemDef
	{
		style			WINDOW_STYLE_FILLED
		rect			50 45 540 391
		backcolor		0 0 0 0.85
		visible			1
		decoration
	}

	itemDef
	{
		style			WINDOW_STYLE_FILLED
		rect			50 436 540 24
		backcolor		0.1 0.1 0.1 0.85
		visible			1
		decoration
	}
		// ------------------ TREE TITLE ------------------
		
		//mostra o nome do modo apenas, o fundo nao tem haver com isso.
		//CHOICE_MENU_TITLE( gametypename())
		
		//MODEL
		#undef blacktitle
		#define blacktitle "RANK MENU"
		
		#include "ui_mp/blackwindowmodel.inc"
			
		//#include "ui_mp/navcontrols.inc"
		#include "ui_mp/player_rankinfo.inc"

	
		#define RANKPOSX 100
		#define RANKPOSY 20
		
		#define HEADRANK(itemIndex, textArg) \
		itemDef \
		{ \
			style			WINDOW_STYLE_FILLED \
			rect			(RANKPOSX - 37 ) (RANKPOSY + 37 + itemIndex * 25) 150 1 0 0 \
			exp				text(textArg) \
			textfont		UI_FONT_NORMAL \
			textscale		0.35 \
			textstyle		0 \
			textAlignY		-2 \
			textAlign		ITEM_ALIGN_CENTER \
			forecolor		0.8 0.8 1 1 \
			background		"line_horizontal" \
			backcolor		0.8 0.8 1 1 \
			visible			1 \
			decoration \
		}
		
		//#define RANK_BUTTON(id,toptext) \
			//BUTTONTEXTONLYNOBORDER(id,RANKPOSX,(RANKPOSY + id * 37),80,toptext)\
	
		
		HEADRANK(1,"^1BEST PLAYER")	
		HEADRANK(2,"NAME:^7 " + dvarString("ui_stat_bestname"))		
		HEADRANK(3,"KILLS:^7 " + dvarString("ui_stat_bestkills"))
		HEADRANK(4,"K/D:^7 " + dvarString(ui_stat_bestkd))
		
		HEADRANK(5,"^1CHEATERS")
		HEADRANK(6,"Banidos: ^7" + dvarString(ui_stat_bannedcount))		
		HEADRANK(7,"Ultimo: ^7" + dvarString(ui_stat_bannedname))
		
		HEADRANK(8,"^1WORST PLAYERS")
		HEADRANK(9,"CoronaVirus: ^7" + dvarString(ui_stat_worst1))		
		HEADRANK(10,"AnusdeBurro: ^7" + dvarString(ui_stat_worst2))		
	}		
}