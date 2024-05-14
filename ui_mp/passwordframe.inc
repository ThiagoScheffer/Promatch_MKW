//POSICAO DO FRAME
#define PASS_FRAME_X         220
#define PASS_FRAME_Y         160

itemDef
{
	//name acwindow
	group grpControlbutton
	rect (PASS_FRAME_X+0) (PASS_FRAME_Y+2) 121 60
	style WINDOW_STYLE_FILLED
	border 1
	bordercolor .5 .5 .5 .5
	forecolor 1 1 1 1
	backcolor 0 0 0 .85
	visible 1;
	decoration
}

itemDef //FRAME AZUL
{
	//name acwindow2
	group grpControlbutton
	rect (PASS_FRAME_X+2) (PASS_FRAME_Y+4) 117 20
	style WINDOW_STYLE_FILLED
	border 1
	bordercolor .1 .1 .1 .2
	forecolor 1 1 1 1
	backcolor .4 .6 .85 .3
	visible 1;
	decoration
}


itemDef //TEXTO FRAME AZUL
{
	text "SENHA/SENHA VIP"
	style 0
	textscale .25
	textstyle 3
	rect (PASS_FRAME_X) (PASS_FRAME_Y+20) 110 20
	textalign ITEM_ALIGN_CENTER
	textalignx 0
	textaligny 0
	textfont UI_FONT_NORMAL
	decoration
	forecolor 1 1 1 1
	visible 1;
}

//CAMPO SENHA
itemDef {
	//name			passwordEntry
	group			grpControlbutton
	TYPE			4
	text			" "
	dvar			"password"
	rect			(PASS_FRAME_X+5) (PASS_FRAME_Y+30) 110 20
	//origin			40 -8
	textaligny		-2
	maxchars		12
	maxpaintchars	12
	textalign		ITEM_ALIGN_MIDDLE_LEFT
	textfont		UI_FONT_NORMAL
	textscale		TEXTSIZE_SMALL
	forecolor		.9 .9 .9 1
	style			WINDOW_STYLE_FILLED
	backcolor		0 0 0 .3
	visible			1
	mouseenter		{ show keyBindStatus; play "mouse_over"; }
	mouseexit		{ hide keyBindStatus; setfocus ok_button; }
	accept			{}
}