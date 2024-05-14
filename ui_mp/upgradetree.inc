// Not sure we will have enough free loc string slot to translate these options.

#undef buttonAlign
#define buttonAlign 0 0

menuDef
{
	name			upgradetree
	focusColor		COLOR_FOCUSED
	fullScreen		0
	blurWorld		4.8
	rect			0 0 640 480
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
		close self;
	}

	#undef blacktitle
	#define blacktitle "UPGRADES"
	#include "ui_mp/blackwindowmodel.inc"	

	//#define CHECKBOX_RESPONSESIMPLE(itemIndex, textArg,actionArg, onArg,execnowact) \
	#define CHECKBOX_RESPONSETEXT(itemIndex, textArg,actionArg,onArg) \
	CHECKBOX_RESPONSESIMPLE(itemIndex, textArg,actionArg,execnow "set highlight_dvar "actionArg,onArg) \	

	#undef SETS_X
	#define SETS_X 35
	#undef SETS_Y
	#define SETS_Y 50	
	CHECKBOX_RESPONSETEXT(1, "Runner","upgradefolego", stat(501))
	CHECKBOX_RESPONSETEXT(2, "SoftFall","upgradefalldamage", stat(502))	
	CHECKBOX_RESPONSETEXT(3, "DropShot","upgradeprecisionshoot", stat(504))
	CHECKBOX_RESPONSETEXT(4, "DangerExp","upgradedangercloser", stat(505))
	CHECKBOX_RESPONSETEXT(5, "Quietkill","upgradetakedown", stat(506))
	CHECKBOX_RESPONSETEXT(6, "ColdBlood","upgradecoldblooded", stat(507))
	CHECKBOX_RESPONSETEXT(7, "Stealth","upgradeincognito", stat(508))
	CHECKBOX_RESPONSETEXT(8, "Minimap","upgradeperipherals", stat(509))	
	CHECKBOX_RESPONSETEXT(9, "MedicPro","upgrademedicpro", stat(510))
	CHECKBOX_RESPONSETEXT(10, "Medic/FastRevive","upgradefastrevive", stat(511))
	CHECKBOX_RESPONSETEXT(11, "Medic/Regen","upgradefastRegen", stat(512))
	CHECKBOX_RESPONSETEXT(12, "Medic/MedkitPack","upgrademedkitPack", stat(513))
	CHECKBOX_RESPONSETEXT(13, "Medic/Smokes","upgrademedicsmoke", stat(514))
	CHECKBOX_RESPONSETEXT(14, "Medic/AmmoPack","upgradeammopack", stat(515))
//--------------------coluna 2
	#undef SETS_X
	#define SETS_X 135
	CHECKBOX_RESPONSETEXT(1, "Collateral","upgradecollateral", stat(519))
	CHECKBOX_RESPONSETEXT(2, "BombHacker","upgradebombdisarmer", stat(521))
	CHECKBOX_RESPONSETEXT(3, "Radar","upgradesitrep", stat(524))
	CHECKBOX_RESPONSETEXT(4, "Scavanger","upgradescavenger", stat(525))
	CHECKBOX_RESPONSETEXT(5, "TearGas","upgradeteargas", stat(527))
	CHECKBOX_RESPONSETEXT(6, "Poisonspread","upgradeposiondamage", stat(528))
	CHECKBOX_RESPONSETEXT(7, "Objective","upgradecapturenaderesist", stat(530))
	CHECKBOX_RESPONSETEXT(8, "BuffReset","upgradebuffreset", stat(532))	
	CHECKBOX_RESPONSETEXT(9, "HackMe","upgradehackspot", stat(533))
	CHECKBOX_RESPONSETEXT(10, "Dropitems","upgradedropitems", stat(534))	
	CHECKBOX_RESPONSETEXT(11, "DangerousSensor","upgradesensorseeker", stat(536))
	CHECKBOX_RESPONSETEXT(12, "WallKiller","upgradewallbang", stat(516))
	CHECKBOX_RESPONSETEXT(13, "WallBarrier","upgradewalldamageresist", stat(517))
	CHECKBOX_RESPONSETEXT(14, "FastAttach","upgradefastchange", stat(518))

//--------------------coluna 3
#undef SETS_X
	#define SETS_X 235
	CHECKBOX_RESPONSETEXT(1, "Spotondeath","upgradespotondeath", stat(520))
	CHECKBOX_RESPONSETEXT(2, "Sensorgas","upgradesensorgas", stat(522))
	CHECKBOX_RESPONSETEXT(3, "Spydrone Pro","upgradespydronepro", stat(523))
	/*CHECKBOX_RESPONSETEXT(3, "skillbuffpredator","upgradesitrep", stat(524))
	CHECKBOX_RESPONSETEXT(4, "Scavanger","upgradescavenger", stat(525))
	CHECKBOX_RESPONSETEXT(5, "TearGas","upgradeteargas", stat(527))
	CHECKBOX_RESPONSETEXT(6, "Poisonspread","upgradeposiondamage", stat(528))
	CHECKBOX_RESPONSETEXT(7, "Objective","upgradecapturenaderesist", stat(530))
	CHECKBOX_RESPONSETEXT(8, "BuffReset","upgradebuffreset", stat(532))	
	CHECKBOX_RESPONSETEXT(9, "HackMe","upgradehackspot", stat(533))
	CHECKBOX_RESPONSETEXT(10, "Dropitems","upgradedropitems", stat(534))	
	CHECKBOX_RESPONSETEXT(11, "DangerousSensor","upgradesensorseeker", stat(536))
	CHECKBOX_RESPONSETEXT(12, "WallKiller","upgradewallbang", stat(516))
	CHECKBOX_RESPONSETEXT(13, "WallBarrier","upgradewalldamageresist", stat(517))
	CHECKBOX_RESPONSETEXT(14, "FastAttach","upgradefastchange", stat(518))*/
	
	
//--------------------coluna 4
	#undef SETS_X
	#define SETS_X 350	
	//SKILS
	HEAD(1,"^3--ABILITY SKILLS--")
	#undef SETS_X
	#define SETS_X 370
	CHECKBOX_RESPONSETEXT(3, "Steal","skilleliteSteal", stat(538))
	CHECKBOX_RESPONSETEXT(4, "Barbed wire","skillbarbedwire", stat(539))
	CHECKBOX_RESPONSETEXT(5, "Medic share","skillmedicshare", stat(540))
	CHECKBOX_RESPONSETEXT(6, "Spy","skillsteathspy", stat(541))
	//CHECKBOX_RESPONSETEXT(7, "Signal","skillsignal", stat(542))

	#undef SETS_X
	#define SETS_X 350	
	//SKILS
	HEAD(8,"^3--TEAMBUFF--")
	#undef SETS_X
	#define SETS_X 370
	CHECKBOX_RESPONSETEXT(9, "Uphand","skillbuffuphand", stat(548))
	CHECKBOX_RESPONSETEXT(10, "Defense","skillbuffdefense", stat(549))
	CHECKBOX_RESPONSETEXT(11, "Healing","skillbuffhealing", stat(550))
	CHECKBOX_RESPONSETEXT(12, "Nowhere","skillbuffnowhere", stat(551))
	CHECKBOX_RESPONSETEXT(13, "Stealth","skillbuffjammer", stat(552))
	CHECKBOX_RESPONSETEXT(14, "Hack","skillbuffhack", stat(553))
	CHECKBOX_RESPONSETEXT(15, "SpyDrone","skillbuffspydrone", stat(554))
	CHECKBOX_RESPONSETEXT(16, "Predador","skillbuffpredator", stat(555))
	CHECKBOX_RESPONSETEXT(17, "Carepackage","skillbuffcarepackage", stat(547))
	
	#undef SETS_X
	#define SETS_X 190
	HEAD(16,"^3$$$: ^1" + stat( 3181 ))
	HEAD(17,"UPGRADE: ^1" + dvarString(ui_upgradestatus))
	HEAD(18,"^3" + ""+tablelookup("mp/aprimoramentos.csv",2,dvarString(highlight_dvar),3))
	HEAD(19,"^1 Custo " + ""+tablelookup("mp/aprimoramentos.csv",2,dvarString(highlight_dvar),1))
	itemDef
	{
		name			keyBindStatus
		rect			180 439 1 20
		ownerdraw		UI_KEYBINDSTATUS
		textstyle		ITEM_TEXTSTYLE_SHADOWED
		style			WINDOW_STYLE_EMPTY
		forecolor		0.9 0.9 0.9 1
		textscale		0.3
		textAlignY		16
		textalign		ITEM_ALIGN_MIDDLE_LEFT
		visible			0
		decoration
	}
}

