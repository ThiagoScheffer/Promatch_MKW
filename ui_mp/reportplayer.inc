{
	menuDef
	{
		name			reportplayer
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
		#define blacktitle "REPORT PLAYER"
		
		#include "ui_mp/blackwindowmodel.inc"
		
			
		//======================================================================================================
		//===================== MENU SELECTION  - MENU OPTIONS APOS TER SELECIONADO TIME ESC====================
		//======================================================================================================
		
		
		#undef buttonAlign
		#define buttonAlign 0 0

		#undef SETS_X
		#define SETS_X 75
		
		#undef SETS_Y
		#define SETS_Y 50
	
		#define REPORTPOSX 80
		#define REPORTPOSY 20
		
		#define REPORT_BUTTON(id,title,script,vis) \
				BUTTONBLACK(REPORTPOSX, (REPORTPOSY + id * 30), 80,title,script,vis,title)\
				
		#define REPORT_BUTTONTEXTS(id,text1) \
				BUTTONTEXTONLYNOBORDER(REPORTPOSX, (REPORTPOSY + id * 30), 80, text1,id)
				
				
		HEAD(0,"REPORTAR E VERIFICAR")		
		
		REPORT_BUTTONTEXTS(2,( "^3" + dvarstring( "ui_leader_player" ) ))		
		REPORT_BUTTON(3,"Next ->",scriptMenuResponse report_nextplayer,when (1))
		
		REPORT_BUTTON( 4, "Motivo",scriptMenuResponse report_nextreason,1)
		REPORT_BUTTONTEXTS(5,( "^3" + dvarstring( "ui_leader_reason" ) ))
		
		
		REPORT_BUTTON(6,"TakeScreenshot",scriptMenuResponse report_TakeScreenshot,1)		
		REPORT_BUTTON(7,"Denunciar",scriptMenuResponse report_registrardenuncia,1)
		//REPORT_BUTTON(4,"Block Damage",scriptMenuResponse damageblock,when ( ( stat( 3401 ) == 1 )))
	}		
}