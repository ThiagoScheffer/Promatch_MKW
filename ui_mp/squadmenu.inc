{
	menuDef
	{
		name			squadmenu
		rect			0 0 640 480
		focuscolor		COLOR_FOCUSED
		style			WINDOW_STYLE_EMPTY
		blurWorld		8.0
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
			close self ;
			play "menu_close";
		}
		
		

		
		// ------------------ TREE TITLE ------------------
		
		//mostra o nome do modo apenas, o fundo nao tem haver com isso.
		//CHOICE_MENU_TITLE( gametypename())
	
		//MODEL
		#undef blacktitle
		#define blacktitle "SQUAD MENU"
		
		#include "ui_mp/blackwindowmodel.inc"

		//USA O LEADERMENU
		//======================================================================================================
		//===================== MENU SELECTION  - MENU OPTIONS APOS TER SELECIONADO TIME ESC====================
		//======================================================================================================
		
		
		#undef buttonAlign
		#define buttonAlign 0 0

		#undef SETS_X
		#define SETS_X 75
		
		#undef SETS_Y
		#define SETS_Y 50
	
		#define SQUADPOSX 80
		#define SQUADPOSY 20
		
		#define SQUAD_BUTTON(id,title,script,vis) \
				BUTTONBLACK(SQUADPOSX, (SQUADPOSY + id * 30), 80,title,script,vis,title)\
		
		HEAD(0,"SQUAD MEMBERS")		
		
		SQUAD_BUTTON(2,"ENTER SQUAD A",scriptMenuResponse squad_a,when ( ( stat( 3163 ) == 0 || stat( 3163 ) != 1 ) ))
		SQUAD_BUTTON(3,"ENTER SQUAD B",scriptMenuResponse squad_b,when ( ( stat( 3163 ) == 0 || stat( 3163 ) != 2 ) ))
		SQUAD_BUTTON(4,"ENTER SQUAD C",scriptMenuResponse squad_c,when ( ( stat( 3163 ) == 0 || stat( 3163 ) != 3 ) ))
		SQUAD_BUTTON(5,"ENTER SQUAD D",scriptMenuResponse squad_d,when ( ( stat( 3163 ) == 0 || stat( 3163 ) != 4 ) ))
		SQUAD_BUTTON(6,"ENTER SQUAD E",scriptMenuResponse squad_e,when ( ( stat( 3163 ) == 0 || stat( 3163 ) != 5 ) ))
		
		
		
		//SQUADCONTROL
		SQUAD_BUTTON(8,"QUIT SQUAD",scriptMenuResponse squad_leave,when ( ( stat( 3163 ) != 0 ) ))
		SQUAD_BUTTON(9,"LOCK SQUAD",scriptMenuResponse squad_lock,when ( ( stat( 3164 ) == 1 ) ))
		//PLAYER LIST
		//--NAMES HERE--
		//BUTTONTEXTONLYNOBORDER(10,SQUADPOSX, (SQUADPOSY + 10 * 30),80,( "^3" + dvarstring( "ui_leader_player" ) ))
		HEAD(13,( "^3" + dvarstring( "ui_leader_player" ) ))
		//< > BUTTON
		SQUAD_BUTTON(11,"Next ->",scriptMenuResponse squad_nextplayer,when ( ( stat( 3164 ) == 1 ) ))

		//REMOVER OR ADD PLAYER
		SQUAD_BUTTON(12,"ADD PLAYER",scriptMenuResponse squad_add,when ( ( stat( 3164 ) == 1 ) ))
		SQUAD_BUTTON(13,"REMOVE PLAYER",scriptMenuResponse squad_kick,when ( ( stat( 3164 ) == 1 ) ))
		
		
		
	}		
}