{
	menuDef
	{
		name			profilebackup
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
		
	
		//MODEL
		#undef blacktitle
		#define blacktitle "PROFILE BACKUP"
		
		#include "ui_mp/blackwindowmodel.inc"

		#undef buttonAlign
		#define buttonAlign 0 0

		#undef SETS_X
		#define SETS_X 75
		
		#undef SETS_Y
		#define SETS_Y 50
	
		#define PROFILEPOSX 80
		#define PROFILEPOSY 20
		
		#define PROF_BUTTON(id,title,script,vis) \
				BUTTONBLACK(PROFILEPOSX, (PROFILEPOSY + id * 30), 80,title,script,vis,title)\
		
		HEAD(0,"PROFILE ACTIONS")		
		
		PROF_BUTTON(2,"^7INICIAR BACKUP",scriptMenuResponse iniciarbackup,1)
		PROF_BUTTON(3,"^2RESTAURAR BACKUP",scriptMenuResponse restaurarbackup,1)
		
		PROF_BUTTON(5,"^1RESETAR CFG",scriptMenuResponse resetarcontroles,1)
		PROF_BUTTON(6,"^1RESETAR PROFILE",scriptMenuResponse zerarprofile,1)
		
	}		
}