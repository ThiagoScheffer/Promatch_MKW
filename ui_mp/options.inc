menuDef
{
	name			promatch_controls
	focusColor		COLOR_FOCUSED
	fullScreen		0
	blurWorld		0
	rect			0 0 640 480
	onOpen
	{
		setLocalVarBool ui_hidemainmenu 1;
		exec "setfromdvar ui_sensitivity sensitivity";
	}
	onClose
	{
		setLocalVarBool ui_hidemainmenu 0;
		exec "setfromdvar sensitivity ui_sensitivity";
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
		exp				text("CONTROLS AND BINDINGS")
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

	#undef SETS_X
	#define SETS_X 75
	#undef SETS_Y
	#define SETS_Y 50

	BIND(0, "@MENU_USE", "+activate")
	CHECKBOX_ACT(1, "@MENU_INVERT_MOUSE", ui_mousePitch, "toggle ui_mousePitch 0 1", uiScript update ui_mousePitch)
	BIND(2, "@MENU_LEAN_LEFT", "+leanleft")
	BIND(3, "@MENU_LEAN_RIGHT", "+leanright")
	BIND(4, "@MENU_LOOK_UP", "+lookup")
	BIND(5, "@MENU_LOOK_DOWN", "+lookdown")
	BIND(6, "@MENU_TURN_LEFT", "+left")
	BIND(7, "@MENU_TURN_RIGHT", "+right")
	BIND(8, "@MENU_MOUSE_LOOK", "+mlook")
	BIND(9, "@MENU_CENTER_VIEW", "centerview")
	CHECKBOX(10, "@MENU_FREE_LOOK", cl_freelook, "toggle cl_freelook 0 1")
	CHECKBOX(11, "@MENU_SMOOTH_MOUSE", m_filter, "toggle m_filter 0 1")
	BINDEDITFIELD(12, "@MENU_MOUSE_SENSITIVITY", ui_sensitivity)
	BIND(13, "@MENU_TOGGLE_CROUCH", "togglecrouch")
	BIND(14, "@MENU_TOGGLE_PRONE", "toggleprone")

	BIND(15, "@MENU_CROUCH", "+movedown")
	BIND(16, "@MENU_PRONE", "+prone")

	BIND(17, "@MENU_CHANGE_STANCE", "+stance")
	BIND(18, "@MENU_STRAFE", "+strafe")

	#undef SETS_X
	#define SETS_X 325

	BIND(0, "@MENU_FORWARD", "+forward")
	BIND(1, "@MENU_BACKPEDAL", "+back")
	BIND(2, "@MENU_MOVE_LEFT", "+moveleft")
	BIND(3, "@MENU_MOVE_RIGHT", "+moveright")
	BIND(4, "@MENU_STANDJUMP", "+gostand")
	BIND(5, "@MENU_GO_TO_CROUCH", "gocrouch")
	BIND(6, "@MENU_GO_TO_PRONE", "goprone")
	BIND(7, "@MENU_SPRINT", "+sprint")
	BIND(8, "@MENU_ATTACK", "+attack")
	BIND(9, "@MENU_TOGGLE_AIM_DOWN_THE_SIGHT", "+toggleads_throw")
	BIND(10, "@MENU_AIM_DOWN_THE_SIGHT", "+speed_throw")
	BIND(11, "@MENU_MELEE_ATTACK", "+melee")	
	BIND(12, "@MENU_SWITCH_WEAPON", "weapnext")
	BIND(13, "@MENU_RELOAD_WEAPON", "+reload")
	BIND(14, "@MENU_THROW_FRAG_GRENADE", "+frag")
	BIND(15, "@MENU_THROW_SPECIAL_GRENADE", "+smoke")
	BIND(16, "@MENU_ACTION_INVENTORY", "+actionslot 3")
	BIND(17, "@MENU_AIR_SUPPORT", "+actionslot 2")
	BINDEDITFIELD(18, "ADS ZOOM", zoom_sensitivity_ratio)

	
	PROBUTTON_CMD(54, 439, 120, "BACK", close self, "back")

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

#undef SETS_X
#undef SETS_Y

menuDef
{
	name			options_promatch
	focusColor		COLOR_FOCUSED
	fullScreen		0
	blurWorld		0
	rect			0 0 640 480
	onOpen
	{
		setLocalVarBool ui_hidemainmenu 1;
		
		execOnDvarFloatValue r_zfeather 0 "set ui_zfeather 0";
		execOnDvarFloatValue r_zfeather 1 "set ui_zfeather 1";
		execOnDvarFloatValue r_depthPrepassModels 1 "set ui_zfeather 2";
		
		
		//exec "setfromdvar cg_fov cg_fov";
		exec "setfromdvar ui_cg_fovscale cg_fovscale";		
		exec "setfromdvar ui_weaponfovscale cg_gun_x";		
		exec "setfromdvar ui_r_aasamples r_aasamples";
		exec "setfromdvar ui_r_displayRefresh r_displayRefresh";
		execOnDvarFloatValue com_maxfps 250 "set ui_com_maxfps 1" ;
		execOnDvarFloatValue com_maxfps 125 "set ui_com_maxfps 0" ;
		exec "setfromdvar ui_r_mode r_mode";		
		
		//execOnDvarStringValue cg_debugInfoCornerOffset TOP "set cg_debugInfoCornerOffset 0 370;
		//execOnDvarStringValue cg_debugInfoCornerOffset MID "set cg_debugInfoCornerOffset 0 464;
		//execOnDvarStringValue cg_debugInfoCornerOffset BOTTOM "set cg_debugInfoCornerOffset 0 0;
	}
	onClose
	{
		execOnDvarIntValue ui_zfeather 0 "set r_zfeather 0; set r_depthPrepassModels 0";
		execOnDvarIntValue ui_zfeather 1 "set r_zfeather 1; set r_depthPrepassModels 0";
		execOnDvarIntValue r_lodScaleRigid 2 "set r_lodScaleSkinned 4; set r_lodBiasSkinned -200; set r_lodBiasRigid -100";
		execOnDvarIntValue r_lodScaleRigid 1 "set r_lodScaleSkinned 1; set r_lodBiasSkinned 0; set r_lodBiasRigid 0";
		setLocalVarBool apply_vid 0;
		setLocalVarBool apply_snd 0;
		hide applies;
		//uiScript openMenuOnDvar cl_ingame 1 class;

		execOnDvarStringValue ct_chat_position standard "set cg_hudChatPosition 5 204; set cg_chatHeight 8";
		execOnDvarStringValue ct_chat_position top "set cg_hudChatPosition 125 120; set cg_chatHeight 5";
		execOnDvarStringValue ct_chat_position bottom "set cg_hudChatPosition 5 300; set cg_chatHeight 5";
		
		setLocalVarBool ui_hidemainmenu 0;
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

	//HEAD(0, "@MENU_GRAPHICS")
	LIST_ACT(0, "@MENU_VIDEO_MODE", ui_r_mode, ITEM_TYPE_DVARENUM, dvarEnumList r_mode, setLocalVarBool apply_vid 2)
	LIST_ACT(1, "@MENU_SCREEN_REFRESH_RATE", ui_r_displayRefresh, ITEM_TYPE_DVARENUM, dvarEnumList r_displayRefresh, setLocalVarBool apply_vid 2)
	CHECKBOX_ACT(2, "@MENU_SYNC_EVERY_FRAME", ui_r_vsync, "toggle ui_r_vsync 0 1", setLocalVarBool apply_vid 1)	
	CHECKBOX(3, "@MENU_SHADOWS", sm_enable, "toggle sm_enable 0 1")
	//CHECKBOX(5, "@MENU_SPECULAR_MAP", r_specular, "toggle r_specular 0 1")
	//CHECKBOX(6, "@MENU_DOF", r_dof_enable, "toggle r_dof_enable 0 1")
	CHECKBOX(4, "@MENU_GLOW", r_glow_allowed, "toggle r_glow_allowed 0 1")	
	CHECKBOX_ACT(5, "@MENU_ZFEATHER_SMOKE", ui_zfeather, "toggle ui_zfeather 0 1", setLocalVarBool apply_vid 1)
	CHECKBOX(6, "@MENU_RAGDOLL", ragdoll_enable, "toggle ragdoll_enable 0 1")
	LIST(7, "@MENU_MODEL_DETAIL", r_lodScaleRigid, ITEM_TYPE_MULTI, dvarFloatList { "@MENU_NORMAL" 1 "@MENU_LOW" 2 "@MENU_VERY_LOW" 3 "@MENU_EXTRA_LOW" 4 })
	LIST(8, "@MENU_WATER_DETAIL", r_drawWater, ITEM_TYPE_MULTI, dvarFloatList { "@MENU_NORMAL" 1 "@MENU_LOW" 0 })
	LIST_ACT(9, "@MENU_TEXTURE_MIPMAPS", r_texFilterMipMode, ITEM_TYPE_MULTI, dvarStrList { "@MENU_AUTOMATIC"; "Unchanged"; "@MENU_BILINEAR"; "Force Bilinear"; "@MENU_TRILINEAR"; "Force Trilinear"; "@MENU_OFF"; "Force Mipmaps Off" }, setLocalVarBool apply_vid 1)
	//SLIDER_ACT(10, "@MENU_TEXTURE_ANISOTROPY", r_texFilterAnisoMin, 1, 1, 16, setLocalVarBool apply_vid 1)
	LIST_ACT(10, "@MENU_TEXTURE_QUALITY", ui_r_picmip_manual, ITEM_TYPE_MULTI, dvarFloatList { "@MENU_AUTOMATIC" 0 "@MENU_MANUAL" 1 }, setLocalVarBool apply_vid 1)
	SLIDER(11, "@MENU_BRIGHTNESS", r_gamma, 1, 0.5, 3)	
	LIST_ACT_VIS(12, "@MENU_TEXTURE_RESOLUTION", ui_r_picmip, ITEM_TYPE_MULTI, dvarFloatList { "@MENU_LOW" 3 "@MENU_NORMAL" 2 "@MENU_HIGH" 1 "@MENU_EXTRA" 0 }, setLocalVarBool apply_vid 1, when(dvarInt(ui_r_picmip_manual)))
	LIST_ACT_VIS(13, "@MENU_NORMAL_MAP_RESOLUTION", ui_r_picmip_bump, ITEM_TYPE_MULTI, dvarFloatList { "@MENU_LOW" 3 "@MENU_NORMAL" 2 "@MENU_HIGH" 1 "@MENU_EXTRA" 0 }, setLocalVarBool apply_vid 1, when(dvarInt(ui_r_picmip_manual)))
	//LIST_ACT_VIS(16, "@MENU_SPECULAR_MAP_RESOLUTION", ui_r_picmip_spec, ITEM_TYPE_MULTI, dvarFloatList { "@MENU_LOW" 3 "@MENU_NORMAL" 2 "@MENU_HIGH" 1 "@MENU_EXTRA" 0 }, setLocalVarBool apply_vid 1, when(dvarInt(ui_r_picmip_manual)))
	CHECKBOX(14, "Mostrar Sprays", fx_marks, "toggle fx_marks 0 1")
	CHECKBOX_RESPONSESIMPLE2(15, "Mostrar Huditens", HUDITENS,stat(3166) == 1)
	CHECKBOX_RESPONSESIMPLE2(16, "Mostrar Hudhealth", HUDHEALTH,stat(3167) == 1)
	//#undef SETS_Y
	//#define SETS_Y 0
	
	CHECKBOX_ACT(17, "Modo PC Forte", ui_quality, "openScriptMenu modkeybind qualitytype",;)
	CHECKBOX_ACT(18, "Modo PC Fraco", ui_pcxuxa, "openScriptMenu modkeybind xuxapcOnOff",;)

	#undef SETS_Y
	#define SETS_Y 50
	#undef SETS_X
	#define SETS_X 325
	CHECKBOX(0, "Draw Crosshair", ui_drawCrosshair, "toggle ui_drawCrosshair 0 1")
	LIST_ACT(1, "KillFeedPos", ui_killfeedhud, ITEM_TYPE_MULTI, dvarFloatList { "[Padrao]" 0 "[Topo]" 1}, exec "openScriptMenu modkeybind KILLFEEDHUD" ;)
	LIST_ACT(2, "Draw Chat", cg_chatTime, ITEM_TYPE_MULTI, dvarFloatList {"Off" 0 "On" 9000},;)
	LIST_ACT(3, "Chat Pos.", ct_chat_position, ITEM_TYPE_MULTI, dvarStrList {"Topo"; "top"; "Padrao"; "standard"; "Abaixo"; "bottom" },;)
	LIST_ACT(4, "HUD Vivos", ui_vivosmortoshud, ITEM_TYPE_MULTI, dvarFloatList { "[Topo]" 0 "[Baixo]" 1}, exec "openScriptMenu modkeybind vivosmortoshud" ;)
	CHECKBOX(5, "Show Blood", cg_blood, "toggle cg_blood 0 1")
	LIST_ACT(6, "MaxFPS", com_maxfps, ITEM_TYPE_MULTI, dvarFloatList { "125" 125 "250" 250},;)
	CHECKBOX(7, "Draw Lagometer", cg_drawlagometer, "toggle cg_drawlagometer 0 1")
	CHECKBOX(8, "Draw Decals", r_drawDecals, "toggle r_drawDecals 0 1")
	LIST_ACT(9, "FOV", cg_fov, ITEM_TYPE_MULTI, dvarFloatList {"65" 65 "70" 70 "80" 80 "90" 90},;)
	LIST_ACT(10, "FOV SCALE", ui_cg_fovscale, ITEM_TYPE_MULTI, dvarFloatList {"[1.125]" 125 "[1.25]" 250 "[NORMAL]" 1}, exec "openScriptMenu modkeybind newfovscale" ;)
	LIST_ACT(11, "WEAPON FOV", ui_weaponfovscale, ITEM_TYPE_MULTI, dvarFloatList {"[NORMAL]" 0 "[LONG]" 2 "[REAL MODE]" -2}, exec "openScriptMenu modkeybind weaponfovscale" ;)
	LIST_ACT(12, "FPS POSITION", cg_debugInfoCornerOffset, ITEM_TYPE_MULTI, dvarStrList { "TOP"; "0 370"; "MID"; "0 464"; "BOTTOM"; "0 0" },;)
	LIST_ACT(13, "Draw FPS", cg_drawFPS, ITEM_TYPE_MULTI, dvarStrList { "On"; "simple"; "Off"; "off"},;)
	CHECKBOX(14, "Mouse RAW-INPUT", raw_input, "toggle raw_input 0 1")
		
	#undef SETS_Y
	#define SETS_Y 200

	//HEAD(0, "@MENU_SOUND")
	//CHECKBOX_ACT(0, "Draw Crosshair", ui_r_fullscreen, "toggle ui_r_fullscreen 0 1", setLocalVarBool apply_vid 1)
	//LIST_ACT(3, "@MENU_SOUND_QUALITY", ui_snd_khz, ITEM_TYPE_MULTI, dvarFloatList { "@MENU_11KHZ" 11 "@MENU_22KHZ" 22 "@MENU_44KHZ" 44 }, setLocalVarBool apply_snd 1)
	//LIST_ACT(4, "@MENU_SPEAKER_CONFIG", ui_outputConfig, ITEM_TYPE_MULTI, dvarStrList { "@MENU_WINDOWS_DEFAULT"; "Windows default"; "@MENU_MONO"; "Mono"; "@MENU_STEREO"; "Stereo"; "@MENU_FOUR_SPEAKERS"; "4 speakers"; "@MENU_FIVE_ONE_SPEAKERS"; "5.1 speakers"; }, setLocalVarBool apply_snd 1)

	#undef SETS_Y
	#define SETS_Y 310

	//HEAD(0, "@MENU_GAME_OPTIONS")
	//CHECKBOX(1, "@MENU_SHOW_BLOOD", cg_blood, "toggle cg_blood 0 1")
	//CHECKBOX_ON(2, "@MENU_ENABLE_CONSOLE", monkeytoy, "toggle monkeytoy 0 1", 0)

	SLIDER(2, "@MENU_MASTER_VOLUME", snd_volume, 0.8, 0.0, 1.0)
	//LIVRE 3
	CHECKBOX_ACT(4, "Musicas", ui_music, "openScriptMenu modkeybind musiclevel",;)
	CHECKBOX_ACT(5, "Som ao morrer", ui_animaldeath, "openScriptMenu modkeybind animaldeaths",;)
	
	//final buttons
	PROBUTTON_CMD(54, 439, 120, "BACK", close self, "back")
	#define APPLY(id, visArg, actArg) \
	PROBUTTON_HIDDEN_EXT(466, 439, 120, "SAVE", actArg, visArg, id, group applies)
	APPLY("0", when(localVarBool(apply_vid) == 1 && localVarBool(apply_snd) == 1), execOnDvarStringValue ui_zfeather 0 "set cg_laserLight 0"; execOnDvarStringValue ui_zfeather 1 "set cg_laserLight 1"; exec "wait; wait; r_applyPicmip")
	APPLY("1", when(localVarBool(apply_vid) == 1 && localVarBool(apply_snd) == 0), execOnDvarStringValue ui_zfeather 0 "set cg_laserLight 0"; execOnDvarStringValue ui_zfeather 1 "set cg_laserLight 1"; exec "wait; wait; r_applyPicmip")
	APPLY("2", when(localVarBool(apply_vid) == 2 ), exec "exec vid_restart")

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

#undef SETS_X
#undef SETS_Y

menuDef
{
	name			keybinds_promatch
	focusColor		COLOR_FOCUSED
	fullScreen		0
	blurWorld		0
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

	// Background button blocker
	itemDef
	{
		type		ITEM_TYPE_BUTTON
		rect		0 0 640 480 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN
		visible		1
	}

	itemDef
	{
		exp				text("PROMATCH KEYBINDS")
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

	#define SETS_X 75
	#define SETS_Y 50

	
	BIND(0, "Medic/Medkit", "openScriptMenu modkeybind drophealthpack")
	BIND(1, "Spot Player/Bomb", "openScriptMenu modkeybind marktargets")
	BIND(2, "Show Stats", "openScriptMenu modkeybind showmystats")
	BIND(3, "Attachment(A)", "openScriptMenu modkeybind attachdetach")
	BIND(4, "Weapons Menu", "openScriptMenu modkeybind X")
	BIND(5, "Buy Menu", "openScriptMenu modkeybind openbuymenu")
	BIND(6, "LightModes", "openScriptMenu modkeybind lights")
	BIND(7, "Sunlight", "openScriptMenu modkeybind sunlight")
	BIND(8, "Cyclefov", "openScriptMenu modkeybind cyclefov")
	BIND(9, "Special Suicide", "openScriptMenu modkeybind specialsuicide")
	BIND(10, "Suicide", "openScriptMenu modkeybind suicide")
	BIND(11, "Mute Game", "openScriptMenu modkeybind mutarsom")
	BIND(12, "Teambuff", "openScriptMenu modkeybind teambuff")
	BIND(13, "Skills", "openScriptMenu modkeybind ativarskill")
	//BIND(14, "CSGO Skin", "openScriptMenu modkeybind changeskinweapon")
	BIND(15, "Rcon Server", "openScriptMenu modkeybind advancedacp")
	BIND(16, "Rcon Player", "openScriptMenu modkeybind playercontrol")
	
	//18
	#undef SETS_X
	#define SETS_X 300	
	//#undef SETS_Y
	//#define SETS_Y 0
	BIND(0, "Classe 1", "openScriptMenu modkeybind autoloadclass1")
	BIND(1, "Classe 2", "openScriptMenu modkeybind autoloadclass2")
	BIND(2, "Classe 3", "openScriptMenu modkeybind autoloadclass3")
	BIND(3, "Spray", "openScriptMenu modkeybind sprayonit")
	
	//19
	#undef SETS_Y
	#define SETS_Y 50
	#undef SETS_X
	#define SETS_X 325
	//0-13
	#undef SETS_Y
	#define SETS_Y 200
	//LIST
	#undef SETS_Y
	#define SETS_Y 310
	//SLIDER(2, "@MENU_MASTER_VOLUME", snd_volume, 0.8, 0.0, 1.0)
	//CHECKBOX_ACT(4, "Ambient Music", ui_music, "openScriptMenu modkeybind musiclevel",;)
	//CHECKBOX_ACT(5, "Death Sounds", ui_animaldeath, "openScriptMenu modkeybind animaldeaths",;)
		//final buttons
	PROBUTTON_CMD(54, 439, 120, "BACK", close self, "back")
}

