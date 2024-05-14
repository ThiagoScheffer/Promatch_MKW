// Not sure we will have enough free loc string slot to translate these options.

#undef buttonAlign
#define buttonAlign 0 0

#undef SETS_X
#undef SETS_Y

menuDef
{
	name			weapons_promatch
	focusColor		COLOR_FOCUSED
	fullScreen		0
	blurWorld		4.8
	rect			0 0 640 480
	onOpen
	{

		
	}
	onClose
	{


	}
	onEsc
	{
		close self;
	}

	// Background button blocker
	itemDef
	{
		type		ITEM_TYPE_BUTTON
		rect		0 0 640 480 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN
		visible		1
	}

	itemDef
	{
		exp				text("GRAPHICS AND UI OPTIONS")
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
	//tarjaup
	itemDef
	{
		style			WINDOW_STYLE_FILLED
		rect			50 45 540 4
		backcolor		1 0.6 0 1
		visible			1
		decoration
	}
	//---------------
	itemDef
	{
		style			WINDOW_STYLE_FILLED
		rect			50 436 540 24
		backcolor		0.1 0.1 0.1 0.85
		visible			1
		decoration
	}
	//tarjadown
//	itemDef
//	{
//		style			WINDOW_STYLE_FILLED
//		rect			50 436 540 5
//		backcolor		1 0.6 0 1
//		visible			1
//		decoration
//	}

	#define SETS_X 75
	#define SETS_Y 50
	
	
	#undef SETS_Y
	#define SETS_Y 200


	#undef SETS_Y
	#define SETS_Y 310


	//#define WEAPON_PRIMARYBUTTON(itemNum, weaponName,visArg )\
	//IMGBUTTON( itemNum,weaponName,LOCAL_SETPRIMARY(weaponName),visArg)\
	//IMGBUTTON_HID(x, y, img, response, cond, id)
	
	//IMGBUTTON_HID(300, 253, "weapon_ak47",  scriptMenuResponse "loadout_primary:AK-47", 1, "0")
	//APBBUTTON(517, 440, 100, "weapon_ak47",  scriptMenuResponse  "loadout_primary:AK-47", 1, "0")
	APBBUTTON_ON(217, 439, 120, "BACKsdasd", "loadout_primary:AK-47", "back")
	//HEAD(0, "@MENU_GAME_OPTIONS")
	CHECKBOX_ACT(3, "@MENU_SYNC_EVERY_FRAME", ui_r_vsync, "toggle ui_r_vsync 0 1" "toggle r_vsync 0 1", setLocalVarBool apply_vid 1)
	//CHECKBOX(1, "@MENU_SHOW_BLOOD", cg_blood, "toggle cg_blood 0 1")
	//CHECKBOX_ON(2, "@MENU_ENABLE_CONSOLE", monkeytoy, "toggle monkeytoy 0 1", 0)

	//final buttons
	APBBUTTON_CMD(54, 439, 120, "BACK", close self, "back")
	
	#define APPLYWEAPONS(id, visArg, actArg) \
	APBBUTTON_HIDDEN_EXT(466, 439, 120, "SAVE", actArg, visArg, id, group applies)
	APPLYWEAPONS("0", when(localVarBool(apply_vid) == 1 && localVarBool(apply_snd) == 1), execOnDvarStringValue ui_zfeather 0 "set cg_laserLight 0"; execOnDvarStringValue ui_zfeather 1 "set cg_laserLight 1"; exec "wait; wait; r_applyPicmip")
	APPLYWEAPONS("1", when(localVarBool(apply_vid) == 1 && localVarBool(apply_snd) == 0), execOnDvarStringValue ui_zfeather 0 "set cg_laserLight 0"; execOnDvarStringValue ui_zfeather 1 "set cg_laserLight 1"; exec "wait; wait; r_applyPicmip")
	APPLYWEAPONS("2", when(localVarBool(apply_vid) == 2 ), exec "exec vid_restart")

	// In-mission fade ~ we can't use "cond" in the buttons, because they can be hidden
	itemDef
	{
		type			ITEM_TYPE_BUTTON
		style			WINDOW_STYLE_FILLED
		rect			466 439 120 18 buttonAlign
		backcolor		0 0 0 0.5
		visible			when(dvarBool("mission") == 1 && (localVarBool(apply_vid) == 1 || localVarBool(apply_snd) == 1))
	}
}
