//=========================================================
//===================== TARJAS=============================
//=========================================================
// background overlay
itemDef
{
	style			WINDOW_STYLE_FILLED
	rect			0 0 640 480 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN
	backcolor		0 0 0 0.9
	visible			0//when ( localVarString( ui_team ) == "marines" || localVarString( ui_team ) == "opfor")
	decoration
}
itemDef
{
//TOPO
	rect 0 0 640 50 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN
	style WINDOW_STYLE_SHADER
	forecolor 0 0 0 0.9
	background "white"
	visible 1
	decoration
}

itemDef
{
//LISTRA-TOP
	rect 0 45 640 2 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN
	style WINDOW_STYLE_SHADER
	forecolor 1 0.6 0 1
	background "white"
	visible 1
	decoration
}
//BOTTOM
itemDef
{
	rect 0 437 640 50 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN
	style WINDOW_STYLE_SHADER
	forecolor 0 0 0 0.9
	background "white"
	visible 1
	decoration
}

itemDef
{
//LISTRA-bottom
	rect 0 440 640 2 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN
	style WINDOW_STYLE_SHADER
	forecolor 1 0.6 0 1
	background "white"
	visible 1
	decoration
}