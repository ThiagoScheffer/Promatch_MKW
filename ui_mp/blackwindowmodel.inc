#include "ui_mp/menustyle.inc"
	
	
	// Background button blocker
	itemDef
	{
		type		ITEM_TYPE_BUTTON
		rect		0 0 640 480 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN
		style			WINDOW_STYLE_FILLED
		visible		when( !localvarBool( ui_hideBack ) );
	}

	itemDef
	{
		exp				text(blacktitle)
		style			WINDOW_STYLE_FILLED
		rect			50 25 540 20
		exp				rect y (25 + FRAME_ANIMATEFX(400))
		textstyle		ITEM_TEXTSTYLE_NORMAL
		textfont		UI_FONT_DEFAULT
		textalign		ITEM_ALIGN_LEFT
		textalignx		5
		textaligny		20
		textscale		0.35
		backcolor		0 0 0 1
		forecolor		1 0.6 0 1
		exp forecolor	a ( ((sin(milliseconds()/480) + 1) * 0.25) + 0.55 )
		visible			1
		decoration
	}
	//fundo quadrado
	itemDef
	{
		style			WINDOW_STYLE_FILLED
		rect			49 45 540 420
		exp				rect Y (45 + FRAME_ANIMATEFX(400))
		backcolor		0 0 0 0.5
		border		WINDOW_BORDER_SUNKEN 
		bordercolor	0 0 0 1 
		visible			1
		decoration
	}
	//tarjaup
	itemDef
	{
		style			WINDOW_STYLE_FILLED
		rect			50 45 540 4
		exp				rect X (50 + FRAME_ANIMATEFX(400))
		backcolor		1 0.6 0 1		
		visible			1
		decoration
	}

//visible	when(dvarbool(ui_hidemainmenu))