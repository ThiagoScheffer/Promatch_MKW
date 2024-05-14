#define ABOUT_MOD_X         400
#define ABOUT_MOD_Y         200

itemDef
{
	//name acwindow
	group grpControlbutton
	rect (ABOUT_MOD_X+0) (ABOUT_MOD_Y+2) 235 175
	style WINDOW_STYLE_FILLED
	border 1
	bordercolor .5 .5 .5 .5
	forecolor 1 1 1 1
	backcolor 0 0 0 .85
	visible when( dvarbool(ui_about_show) );
	decoration
}

itemDef
{
	//name acwindow2
	group grpControlbutton
	rect (ABOUT_MOD_X+2) (ABOUT_MOD_Y+4) 231 20
	style WINDOW_STYLE_FILLED
	border 1
	bordercolor .1 .1 .1 .2
	forecolor 1 1 1 1
	backcolor .4 .6 .85 .3
	visible when( dvarbool(ui_about_show) );
	decoration
}


itemDef
{
	text "About Promatch"
	style 0
	textscale .25
	textstyle 3
	rect (ABOUT_MOD_X+116) (ABOUT_MOD_Y+20) 110 20
	textalign ITEM_ALIGN_CENTER
	textalignx -55
	textaligny 0
	textfont UI_FONT_NORMAL
	decoration
	forecolor 1 1 1 1
	visible when( dvarbool(ui_about_show) );
}

// Current version display
itemDef
{
	text "Promatch by EncryptorX"
	style 0
	textscale .25
	textstyle 3
	rect (ABOUT_MOD_X+30) (ABOUT_MOD_Y+40) 110 20
	textalign ITEM_ALIGN_LEFT
	textalignx 0
	textaligny 0
	textfont UI_FONT_NORMAL
	decoration
	forecolor 1 1 1 1
	visible when( dvarbool(ui_about_show) );
}

// Update version display
itemDef
{
	text "Code merged with OW v4.104.130"
	style 0
	textscale .25
	textstyle 3
	rect (ABOUT_MOD_X+30) (ABOUT_MOD_Y+70) 110 20
	textalign ITEM_ALIGN_LEFT
	textalignx 0
	textaligny 0
	textfont UI_FONT_NORMAL
	decoration
	forecolor 1 1 1 1
	visible when( dvarbool(ui_about_show) );
}

itemDef
{
	text "This is not the Original Promatch Mod."
	style 0
	textscale .25
	textstyle 3
	rect (ABOUT_MOD_X+30) (ABOUT_MOD_Y+85) 110 20
	textalign ITEM_ALIGN_LEFT
	textalignx 0
	textaligny 0
	textfont UI_FONT_NORMAL
	decoration
	forecolor 1 1 1 1
	visible when( dvarbool(ui_about_show) );
}

itemDef
{
	text "Promatch 2024 4Fun Modded"
	style 0
	textscale .25
	textstyle 3
	rect (ABOUT_MOD_X+30) (ABOUT_MOD_Y+100) 110 20
	textalign ITEM_ALIGN_LEFT
	textalignx 0
	textaligny 0
	textfont UI_FONT_NORMAL
	decoration
	forecolor 1 1 1 1
	visible when( dvarbool(ui_about_show) );
}

itemDef
{
	text "COD4x 2.1 V22+ Full support and commands"
	style 0
	textscale .25
	textstyle 3
	rect (ABOUT_MOD_X+30) (ABOUT_MOD_Y+130) 110 20
	textalign ITEM_ALIGN_LEFT
	textalignx 0
	textaligny 0
	textfont UI_FONT_NORMAL
	decoration
	forecolor 1 1 1 1
	visible when( dvarbool(ui_about_show) );
}
itemDef
{
	text "COD4X Site: www.cod4x.ovh"
	style 0
	textscale .25
	textstyle 3
	rect (ABOUT_MOD_X+30) (ABOUT_MOD_Y+145) 110 20
	textalign ITEM_ALIGN_LEFT
	textalignx 0
	textaligny 0
	textfont UI_FONT_NORMAL
	decoration
	forecolor 1 1 1 1
	visible when( dvarbool(ui_about_show) );
}