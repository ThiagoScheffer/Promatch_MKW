// Some of the functions can be optimalized probably, like closeButton and POP.
//rect			(SETS_X + 111) (SETS_Y + 6 + itemIndex * 20) 10 10 0 0 \
#define buttonAlign HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN

#define MOVE_SPEEDFX 400 //milliseconds

#define UNIT_GROWTH2 sin( sin( min( milliseconds()-dvarInt(ui_time_marker), MOVE_SPEEDFX )*(1.5707/MOVE_SPEEDFX) )*1.5707 )

#define FRAME_ANIMATEFX( offset ) \
		offset-offset*UNIT_GROWTH2
		
#define FRAME_ANIMATEFX2( offset ) \
		offset-offset*UNIT_GROWTH2
		
#define FADEFX 400-400*UNIT_GROWTH2


//exp				rect Y (45 + FRAME_ANIMATE(ANIMATE_DISTANCE))


#define BUTTONBODY(x, y, w, title, act, vis, id, ext) \
itemDef \
{ \
	name		"button_"id \
	style		WINDOW_STYLE_FILLED \
	rect		(x - 2) (y - 2) (w + 2) 20 buttonAlign \
	forecolor	1 1 1 0.85 \
	exp			text(title) \
	type		ITEM_TYPE_BUTTON \
	textfont	UI_FONT_NORMAL \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	textalign	ITEM_ALIGN_CENTER \
	textscale	0.3 \
	textaligny	15.5 \
	border		1 \
	bordercolor	0 0 0 1 \
	background	"black" \
	backcolor	0.5 0.5 0.5 1 \
	visible		vis \
	ext \
	mouseEnter \
	{ \
		play "mouse_over"; \
		setcolor backcolor 0.66 0.66 0.66 1; \
	} \
	mouseExit \
	{ \
		setcolor backcolor 0.5 0.5 0.5 1; \
	} \
	action \
	{ \
		act \
	} \
}


#define BUTTONBLACKSHADER(x, y, w, bgimage, act, vis, id) \
		itemDef \
		{ \
			style		WINDOW_STYLE_SHADER \
			rect		(x - 2) (y - 2) (w + 15) 20 buttonAlign \
			forecolor	1 1 1 0.85 \
			exp			material( bgimage ); \
			border		1 \
			bordercolor	0 0 0 1 \
			backcolor	0.1 0.1 0.1 0.5 \
			visible		vis \
			decoration \
		}\
		itemDef \
		{ \
			name		"button_emb" \
			style		WINDOW_STYLE_FILLED \
			rect		(x - 2) (y - 2) (w + 15) 20 buttonAlign \
			forecolor	1 1 1 0 \
			text		"" \
			type		ITEM_TYPE_BUTTON \
			textfont	UI_FONT_NORMAL \
			textstyle	ITEM_TEXTSTYLE_SHADOWED \
			textalign	ITEM_ALIGN_CENTER \
			textscale	0.3 \
			textaligny	15.5 \
			border		1 \
			bordercolor	0 0 0 1 \
			backcolor	0.1 0.1 0.1 0 \
			visible		vis \
			mouseEnter \
			{ \
				play "mouse_over"; \
				setcolor backcolor 0.66 0.66 0.66 0; \
				setcolor bordercolor 1 0.4 0 1; \
			} \
			mouseExit \
			{ \
				setcolor backcolor 0.1 0.1 0.1 0; \
				setcolor bordercolor 0 0 0 1; \
			} \
			action { \
			act \
			play "oldschool_pickup"; \
			} \
		}\

#define BUTTONSHADERICONSTITLE(x, y, w, bgimage,act,vis,id,title) \
		itemDef \
		{ \
			style		WINDOW_STYLE_SHADER \
			rect		(x - 2) (y - 2) (50) 50 buttonAlign \
			forecolor	1 1 1 0.85 \
			exp			material( bgimage ); \
			border		1 \
			bordercolor	0 0 0 1 \
			backcolor	0.1 0.1 0.1 0.5 \
			visible		0 \
			decoration \
		}\
		itemDef \
		{ \
			name		"button_spray" \
			style		WINDOW_STYLE_FILLED \
			rect		(x - 2) (y - 2) (50) 50 buttonAlign \
			forecolor	1 1 1 0 \
			text		"" \
			type		ITEM_TYPE_BUTTON \
			textfont	UI_FONT_NORMAL \
			textstyle	ITEM_TEXTSTYLE_SHADOWED \
			textalign	ITEM_ALIGN_CENTER \
			textscale	0.3 \
			textaligny	15.5 \
			border		1 \
			bordercolor	0 0 0 1 \
			backcolor	0.1 0.1 0.1 0 \
			visible		1 \
			mouseEnter \
			{ \
				play "mouse_over"; \
				setcolor backcolor 0.66 0.66 0.66 0; \
				setcolor bordercolor 1 0.4 0 1; \
			} \
			mouseExit \
			{ \
				setcolor backcolor 0.1 0.1 0.1 0; \
				setcolor bordercolor 0 0 0 1; \
			} \
			action { \
			scriptMenuResponse act \
			play "oldschool_pickup"; \
			} \
		}\
		itemDef \
		{ \
			name		"button_spraysselected" \
			style		WINDOW_STYLE_FILLED \
			rect		(x - 2) (y - 2) (50) 50 buttonAlign \
			forecolor	1 1 1 0 \
			text		"" \
			type		ITEM_TYPE_BUTTON \
			textfont	UI_FONT_NORMAL \
			textstyle	ITEM_TEXTSTYLE_SHADOWED \
			textalign	ITEM_ALIGN_CENTER \
			textscale	0.3 \
			textaligny	15.5 \
			border		1 \
			bordercolor	0 0 0 1 \
			backcolor	0.1 0.1 0.1 0 \
			visible		vis \
			mouseEnter \
			{ \
				play "mouse_over"; \
				setcolor backcolor 0.66 0.66 0.66 0; \
				setcolor bordercolor 1 1 0 1; \
			} \	
		}\
		
		//70 100 162 92 
#define BUTTONVOTEMAP(x, y, w, bgimage, act, vis, id,actionArg,execnowact,hud_mapName,hud_mapVotes) \
		itemDef\
        {\
            name                      "mapbox" \
            rect                      x y 129 73 HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP\
			exp						  rect X ((x) + FRAME_ANIMATEFX(600))\
            style                     WINDOW_STYLE_SHADER\
            border                    WINDOW_BORDER_FULL\
            borderSize                1\
            foreColor                 1 1 1 1\
            backColor                 1 1 1 0\
            borderColor               0 0 0 1\
            outlineColor              0 0 0 0\
            textFont                  UI_FONT_NORMAL\
            textScale                 3\
            textStyle                 ITEM_TEXTSTYLE_SHADOWED\
            exp                       material ( "custom_map" );\
            visible                   when (1)\
            decoration         \       
        }\
		itemDef\
        {\
            name                      "map1button"\
            rect                      x y 129 73 HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP\
			exp						  rect X ((x) + FRAME_ANIMATEFX(600))\
            group                     "mw2_popup_button"\
            style                     WINDOW_STYLE_FILLED\
            foreColor                 1 1 1 1\
            backColor                 0 0 0 0\
            borderColor               0 0 0 0\
            outlineColor              0 0 0 0\
            type                      ITEM_TYPE_BUTTON\
            textScale                 0.55\
            action                    { play mouse_click ; execnow execnowact; scriptMenuResponse actionArg;  }\
            onFocus                   { play mouse_over ; setItemColor self backcolor 0 1 0 0.25 ;  }\
            leaveFocus                { setItemColor self backcolor 1 1 1 0 ;  }\
            visible                   when ( vis )\
        }\
        itemDef\
        {\
            name                      "map1selected"\
            rect                      (x - 1) (y - 1) 129 73 HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP\
			exp						  rect X ((x - 1) + FRAME_ANIMATEFX(600))\
            style                     WINDOW_STYLE_FILLED\
            border                    WINDOW_BORDER_FULL\
            borderSize                1\
            foreColor                 1 1 1 1\
            backColor                 0 1 0 0.25\
            borderColor               1 1 1 1\
            outlineColor              0 0 0 0\
            textScale                 0.55\
            visible                   when ( ( dvarstring( "ui_selected_vote" ) == id && vis ) )\
            decoration    \            
        }\
        itemDef\
        {\
            name                      "map1tarjatop"\
            rect                      (x + 1) (y + 2) 129 18 HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP\
			exp						  rect X ((x + 1) + FRAME_ANIMATEFX(600))\
            style                     WINDOW_STYLE_SHADER\
            borderSize                1\
            foreColor                 0 0 0 0.9\
            backColor                 0 0 0 0\
            borderColor               0 0 0 0\
            outlineColor              0 0 0 0\
            background                "gradient"\
            textScale                 0.55\
            visible                   when ( vis )\
            decoration    \            
        }\
        itemDef\
        {\
            name                      "map1tarjabttm"\
            rect                      (x - 1) (y + 54) 128 18 HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP\
			exp						  rect X ((x - 1) + FRAME_ANIMATEFX(600))\
            style                     WINDOW_STYLE_SHADER\
            borderSize                1\
            foreColor                 0 0 0 0.9\
            backColor                 0 0 0 0\
            borderColor               0 0 0 0\
            outlineColor              0 0 0 0\
            background                "gradient_fadein"\
            textScale                 0.55\
            visible                   when ( vis )\
            decoration          \      
        }\
        itemDef\
        {\
            name                      "map1name"\
            rect                      (x + 2) (y + 15) 50 50 HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP\
			exp						  rect X ((x + 2) + FRAME_ANIMATEFX(600))\
            style                     WINDOW_STYLE_FILLED\
            borderSize                1\
            foreColor                 1 1 1 1\
            backColor                 0 0 0 0\
            borderColor               0 0 0 0\
            outlineColor              0 0 0 0\
            textFont                  UI_FONT_NORMAL\
            textScale                 0.25\
            textStyle                 ITEM_TEXTSTYLE_SHADOWED\
            exp                       text ( ( dvarstring( hud_mapName ) ) );\
            visible                   when ( vis )\
            decoration       \         
        }\
        itemDef\
        {\
            name                      "map1votes"\
            rect                      (x + 75) (y + 70) 50 50 HORIZONTAL_ALIGN_SUBLEFT VERTICAL_ALIGN_SUBTOP\
			exp						  rect X ((x + 75) + FRAME_ANIMATEFX(600))\
            style                     WINDOW_STYLE_FILLED\
            borderSize                1\
            foreColor                 1 1 1 1\
            backColor                 0 0 0 0\
            borderColor               0 0 0 0\
            outlineColor              0 0 0 0\
            textFont                  UI_FONT_NORMAL\
            textAlign                 ITEM_ALIGN_LEGACY_RIGHT\
            textScale                 0.25\
            textStyle                 ITEM_TEXTSTYLE_SHADOWED\
            exp                       text ( ( dvarstring( hud_mapVotes ) + "/" + dvarstring( "hud_gamesize" ) ) );\
            visible                   when ( vis )\
            decoration                \
        }\
		
		//map1votes == gametype + 0/1
		
#define BUTTONBLACKSHADERICONS(x, y, w, bgimage, act, vis, id) \
		itemDef \
		{ \
			style		WINDOW_STYLE_SHADER \
			rect		(x - 2) (y - 2) (30) 30 buttonAlign \
			forecolor	1 1 1 0.85 \
			exp			material( bgimage ); \
			border		1 \
			bordercolor	0 0 0 1 \
			backcolor	0.1 0.1 0.1 0.5 \
			visible		vis \
			decoration \
		}\
		itemDef \
		{ \
			name		"button_emb" \
			style		WINDOW_STYLE_FILLED \
			rect		(x - 2) (y - 2) (30) 30 buttonAlign \
			forecolor	1 1 1 0 \
			text		"" \
			type		ITEM_TYPE_BUTTON \
			textfont	UI_FONT_NORMAL \
			textstyle	ITEM_TEXTSTYLE_SHADOWED \
			textalign	ITEM_ALIGN_CENTER \
			textscale	0.3 \
			textaligny	15.5 \
			border		1 \
			bordercolor	0 0 0 1 \
			backcolor	0.1 0.1 0.1 0 \
			visible		vis \
			mouseEnter \
			{ \
				play "mouse_over"; \
				setcolor backcolor 0.66 0.66 0.66 0; \
				setcolor bordercolor 1 0.4 0 1; \
			} \
			mouseExit \
			{ \
				setcolor backcolor 0.1 0.1 0.1 0; \
				setcolor bordercolor 0 0 0 1; \
			} \
			action { \
			act \
			play "oldschool_pickup"; \
			} \
		}\
	//usado no class WINDOW_BORDER_HORZ
#define BUTTONBLACK(x, y, w, title, act, vis, id) \
itemDef \
{ \
	name		"button_"id \
	style		WINDOW_STYLE_FILLED \
	rect		(x - 2) (y - 2) (w + 15) 20 buttonAlign \
	exp			rect X ((x - 2) + FRAME_ANIMATEFX(400))\
	forecolor	1 1 1 0.85 \
	exp			text(title) \
	type		ITEM_TYPE_BUTTON \
	textfont	UI_FONT_NORMAL \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	textalign	ITEM_ALIGN_CENTER \
	textscale	0.3 \
	textaligny	15.5 \
	border		WINDOW_BORDER_SUNKEN \
	bordercolor	0 0 0 1 \
	backcolor	0.1 0.1 0.1 0.5 \
	visible		vis \
	mouseEnter \
	{ \
		play "mouse_over"; \
		setcolor backcolor 0.66 0.66 0.66 0.3; \
		setcolor bordercolor 1 0.4 0 1; \
	} \
	mouseExit \
	{ \
		setcolor backcolor 0.1 0.1 0.1 0.5; \
		setcolor bordercolor 0 0 0 1; \
	} \
	action { \
	act \
	play mouse_click \
	} \
}


//(SETS_X + 114) (SETS_Y + 9 + itemIndex * 20) 6 6 0 0 \
#define BUTTONTEXTONLYNOBORDER(x, y, w, text1,id) \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		(x - 2) (y - 2) (w + 25) 20 buttonAlign \
	forecolor	1 1 1 0.85 \
	exp			text(text1) \
	type		ITEM_TYPE_BUTTON \
	textfont	UI_FONT_NORMAL \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	textalign	ITEM_ALIGN_CENTER \
	textscale	0.3 \
	textaligny	15.5 \
	border		0 \
	backcolor 0.1 0.1 0.1 0.5; \
	bordercolor 0.1 0.1 0.1 0.5 \
	visible		1 \
	mouseEnter \
	{ \
		play "mouse_over"; \
	} \
} \


#define BUTTONEXECNOWMEDALS(dist,x, y,title, image,vis,medalnum,statsinfo) \
	itemDef \
	{ \
		style		WINDOW_STYLE_FILLED \
		rect		(x - 2 + dist) (y - 2) 23 23 buttonAlign \
		forecolor	0.8 0.8 1 1 \
		exp			text("") \
		type		ITEM_TYPE_BUTTON \
		textfont	UI_FONT_NORMAL \
		textstyle	ITEM_TEXTSTYLE_SHADOWED \
		textalign	ITEM_ALIGN_CENTER \
		textscale	0.3 \
		textaligny	15.5 \
		border		WINDOW_BORDER_HORZ \
		background		image\
		backcolor		0.8 0.8 1 1 \
		bordercolor 0.1 0.1 0.1 0.5 \
		visible		vis \
		mouseEnter \
		{ \
			play "mouse_over"; \
			setdvar ui_medals_show medalnum;\
			setcolor bordercolor 1 0.4 0 1; \
		} \
		mouseExit \
		{ \
			setdvar ui_medals_show 0;\
			setcolor bordercolor 0.1 0.1 0.1 0.5 \
		} \
	}\
	itemDef\
	{\
		text title\
		style 0\
		textscale .25\
		textstyle 3\
		rect (x - 2 + dist) (y - 2) 23 60 buttonAlign \
		textalign ITEM_ALIGN_CENTER\
		textalignx 0\
		textaligny -4\
		textfont UI_FONT_NORMAL\
		decoration\
		forecolor 1 1 1 1\
		visible when( dvarint(ui_medals_show) == medalnum );\
	}\
	itemDef\
	{\
		exp text statsinfo\
		style 0\
		textscale .25\
		textstyle 3\
		rect (x - 2 + dist) (y - 2) 23 60 buttonAlign \
		textalign ITEM_ALIGN_CENTER\
		textalignx 0\
		textaligny 35\
		textfont UI_FONT_NORMAL\
		decoration\
		forecolor 1 1 1 1\
		visible when( dvarint(ui_medals_show) == medalnum );\
	}\
	
#define BUYBUTTONEXECNOW(x, y, w, title, script,execnowact,vis) \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		(x - 2) (y - 2) (w + 2) 20 buttonAlign \
	forecolor	1 1 1 0.85 \
	exp			text(title) \
	type		ITEM_TYPE_BUTTON \
	textfont	UI_FONT_NORMAL \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	textalign	ITEM_ALIGN_CENTER \
	textscale	0.3 \
	textaligny	15.5 \
	border		WINDOW_BORDER_HORZ \
    backcolor 0.1 0.1 0.1 0.5; \
	bordercolor 0.1 0.1 0.1 0.5 \
	visible		vis \
	mouseEnter \
	{ \
		play "mouse_over"; \
		setcolor backcolor 0.66 0.66 0.66 0.3; \
		setcolor bordercolor 1 0.4 0 1; \
	} \
	mouseExit \
	{ \
		setcolor backcolor 0.1 0.1 0.1 0.5; \
		setcolor bordercolor 0.1 0.1 0.1 0.5 \
	} \
	action \
	{ \
	scriptMenuResponse script \
	play mouse_click \
	} \
	onFocus \
	{ \
	execnow execnowact \
	play mouse_submenu_over \
	} \	
}

#define BUYBUTTONMINIVOTE(x, y, w, title, script,execnowact,vis,visselct) \
	itemDef \
	{ \
		style		WINDOW_STYLE_FILLED \
		rect		(x - 2) (y - 2) (w + 15) 20 buttonAlign \
		exp			rect X ((x - 2) + FRAME_ANIMATEFX(600))\
		forecolor	1 1 1 0.85 \
		exp			text(title) \
		type		ITEM_TYPE_BUTTON \
		textfont	UI_FONT_NORMAL \
		textstyle	ITEM_TEXTSTYLE_SHADOWED \
		textalign	ITEM_ALIGN_CENTER \
		textscale	0.25 \
		textaligny	15.5 \
		border		WINDOW_BORDER_HORZ \
		bordercolor	0 0 0 1 \
		backcolor	0.1 0.1 0.1 0.5 \
		visible		vis \
		mouseEnter \
		{ \
			play "mouse_over"; \
			setcolor backcolor 0.66 0.66 0.66 0.3; \
			setcolor bordercolor 1 0.4 0 1; \
		} \
		mouseExit \
		{ \
			setcolor backcolor 0.1 0.1 0.1 0.5; \
			setcolor bordercolor 0 0 0 1; \
		} \
		action \
		{ \
		scriptMenuResponse script \
		play oldschool_pickup \
		} \
		onFocus \
		{ \
		execnow execnowact \
		play mouse_submenu_over \
		} \	
	}\
	itemDef\
		{\
			name                      "votetbnselected"\
			rect					  (x - 2) (y - 2) (w + 15) 20 buttonAlign \
			style                     WINDOW_STYLE_FILLED\
			border                    WINDOW_BORDER_FULL\
			borderSize                1\
			foreColor                 1 1 1 1\
			backColor                 0 1 0 0.25\
			borderColor               1 1 1 1\
			outlineColor              0 0 0 0\
			textScale                 0.55\
			visible                   when ( ( dvarstring( "ui_selected_vote" ) == visselct && vis ) )\
			decoration    \            
		}\	

#define BUYBUTTONEXECNOWWEAPONS(x, y, w, title, script,execnowact,vis) \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		(x - 2) (y - 2) (w + 15) 20 buttonAlign \
	exp			rect X ((x - 2) + FRAME_ANIMATEFX(400))\
	forecolor	1 1 1 0.85 \
	exp			text(title) \
	type		ITEM_TYPE_BUTTON \
	textfont	UI_FONT_NORMAL \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	textalign	ITEM_ALIGN_CENTER \
	textscale	0.3 \
	textaligny	15.5 \
	border		WINDOW_BORDER_HORZ \
	bordercolor	0 0 0 1 \
	backcolor	0.1 0.1 0.1 0.5 \
	visible		vis \
	mouseEnter \
	{ \
		play "mouse_over"; \
		setcolor backcolor 0.66 0.66 0.66 0.3; \
		setcolor bordercolor 1 0.4 0 1; \
	} \
	mouseExit \
	{ \
		setcolor backcolor 0.1 0.1 0.1 0.5; \
		setcolor bordercolor 0 0 0 1; \
	} \
	action \
	{ \
	scriptMenuResponse script \
	play oldschool_pickup \
	} \
	onFocus \
	{ \
	execnow execnowact \
	play mouse_submenu_over \
	} \	
}

#define BUTTONTEXTBOXCLASS(x, y, w, title, script,customclass, vis, id,max_chars,max_paintchars) \
itemDef \
{ \
	name		"button_custom" \
	style		WINDOW_STYLE_FILLED \
	rect		(x) (y) (w) 20 buttonAlign \
	forecolor	1 1 1 0.85 \
	type		ITEM_TYPE_EDITFIELD \
	exp			text(title) \
	dvar		customclass \
	textfont	UI_FONT_NORMAL \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	textalign	ITEM_ALIGN_MIDDLE_LEFT \
	textscale	0.3 \
	textaligny	-1 \
	border		1 \
	bordercolor	0.6 0.4 0 1 \
	background	"black" \
	backcolor	0.1 0.1 0.1 0.5 \
	visible		vis \
	maxChars		max_chars \
	maxpaintchars	max_paintchars \
	mouseEnter \
	{ \
		play "mouse_over"; \
		setcolor backcolor 0.66 0.66 0.66 0.3; \
		setcolor bordercolor 0.6 0.4 0 1; \
	} \
	mouseExit \
	{ \
		setcolor backcolor 0.1 0.1 0.1 0.5; \
		setcolor bordercolor 0 0 0 1; \
	} \
	action \
	{ \
		scriptMenuResponse script \
		play oldschool_pickup \
	} \
	accept \
	{ \
		scriptMenuResponse script \
		play oldschool_pickup \
	} \
}


#define BUTTONTEXTENDGAME(x, y, w, title, vis,id) \
itemDef \
{ \
	name		"button_custom" \
	style		WINDOW_STYLE_FILLED \
	rect		(x) (y) (w) 20 buttonAlign \
	forecolor	1 1 1 0.85 \
	type		ITEM_TYPE_TEXT \
	exp			text(title) \
	textfont	UI_FONT_NORMAL \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	textalign	ITEM_ALIGN_MIDDLE_LEFT \
	textscale	0.3 \
	textaligny	-1 \
	border		1 \
	bordercolor	0.6 0.4 0 1 \
	background	"black" \
	backcolor	0.1 0.1 0.1 0.5 \
	visible		vis \
	action \
	{ \
		play oldschool_pickup \
	} \
	accept \
	{ \
		play oldschool_pickup \
	} \
}


#define BUTTONTEXTBOX(x, y, w, title, act, vis, id, ext,max_chars,max_paintchars) \
itemDef \
{ \
	name		"button_"id \
	style		WINDOW_STYLE_FILLED \
	rect		(x - 2) (y - 2) (w + 2) 20 buttonAlign \
	forecolor	1 1 1 0.85 \
	exp			text(title) \
	type		ITEM_TYPE_EDITFIELD \
	textfont	UI_FONT_NORMAL \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	textalign	ITEM_ALIGN_CENTER \
	textscale	0.3 \
	textaligny	15.5 \
	border		1 \
	bordercolor	0 0 0 1 \
	forecolor		1 1 1 1 \
	background	"black" \
	backcolor	0.5 0.5 0.5 1 \
	visible		vis \
	maxChars		max_chars \
	maxpaintchars	max_paintchars \
	ext \
	CHOICE_SCRIPTS_ACTION( itemIndex, actionArg ) \
	mouseEnter \
	{ \
		play "mouse_over"; \
		setcolor backcolor 0.66 0.66 0.66 1; \
	} \
	mouseExit \
	{ \
		setcolor backcolor 0.5 0.5 0.5 1; \
	} \
	action \
	{ \
		act \
	} \
}


#define BUTTONFADE(x, y, w, cond) \
itemDef \
{ \
	type			ITEM_TYPE_BUTTON \
	style			WINDOW_STYLE_FILLED \
	rect			x y w 18 buttonAlign \
	backcolor		0 0 0 0.5 \
	visible			cond \
}
		
// These 3 should be replaced with 'act' buttons
#define NEWBUTTON_ON(x, y, w, title, response) \
BUTTONBODY(x, y, w, title, scriptMenuResponse response;, 1, "0", ;)

#define NEWBUTTON(x, y, w, title, response, cond) \
BUTTONBODY(x, y, w, title, scriptMenuResponse response;, 1, "0", ;) \
BUTTONFADE(x, y, w, cond)

#define PROBUTTON_ON(x, y, w, title, response, id) \
BUTTONBODY(x, y, w, title, scriptMenuResponse response;, 1, id, ;)

#define PROBUTTON_CMD_ON(x, y, w, title, act) \
BUTTONBODY(x, y, w, title, act, 1, "0", ;)

#define PROBUTTON_CMD(x, y, w, title, act, id) \
BUTTONBODY(x, y, w, title, act, 1, id, ;)

#define PROBUTTON_EXT(x, y, w, title, act, id, ext) \
BUTTONBODY(x, y, w, title, act, 1, id, ext)

#define PROBUTTON(x, y, w, title, act, cond, id) \
BUTTONBODY(x, y, w, title, act, 1, id, ;) \
BUTTONFADE(x, y, w, cond)

#define PROBUTTON_HIDDEN(x, y, w, title, act, vis, id) \
BUTTONBODY(x, y, w, title, act, vis, id, ;)

#define PROBUTTON_HIDDEN_EXT(x, y, w, title, act, vis, id, ext) \
BUTTONBODY(x, y, w, title, act, vis, id, ext)

// for PROBUTTON_VIS we don't need to put when() when pass
// vis or cond, because that's integrated here! It can be
// simplified this way for all the button types in the
// future, but here is was required due to vis && cond
#define PROBUTTON_VIS(x, y, w, title, act, cond, vis, id) \
BUTTONBODY(x, y, w, title, act, when(vis), id, ;) \
BUTTONFADE(x, y, w, when((vis) && (cond)))

/*#define PROBUTTON_VIS_EXT(x, y, w, title, act, cond, vis, id, ext) \
BUTTONBODY(x, y, w, title, act, vis, id, ext) \
BUTTONFADE(x, y, w, cond)*/

#define IMGBUTTON(x, y, img, response, id) \
IMGBUTTON_FULL(x, y, img, scriptMenuResponse response, 16, 0.5 0.5 0.5, 0.66 0.66 0.66, 1, id)

#define IMGBUTTON_VIS(x, y, img, response, vis, id) \
IMGBUTTON_FULL(x, y, img, scriptMenuResponse response, 16, 0.5 0.5 0.5, 0.66 0.66 0.66, vis, id)

#define IMGBUTTON_SIZE(x, y, img, do, w, id) \
IMGBUTTON_FULL(x, y, img, do, w, 0.5 0.5 0.5, 0.66 0.66 0.66, 1, id)

#define IMGBUTTON_HID(x, y, img, response, cond, id) \
IMGBUTTON_FULL(x, y, img, scriptMenuResponse response, 16, 0.5 0.5 0.5, 0.66 0.66 0.66, 1, id) \
IMGBUTTON_FADE(x, y, 16, cond)

#define IMGBUTTON_RED(x, y, img, response, cond, id) \
IMGBUTTON_FULL(x, y, img, scriptMenuResponse response, 16, 0.8 0 0, 1 0 0, 1, id) \
IMGBUTTON_FADE(x, y, 16, cond)

#define IMGBUTTON_SIZE_HID(x, y, img, do, w, cond, col1, col2, id) \
IMGBUTTON_FULL(x, y, img, do, w, col1, col2, vis, id) \
IMGBUTTON_FADE(x, y, w, cond)

#define IMGBUTTON_FULL(x, y, img, do, w, col1, col2, vis, id) \
itemDef \
{ \
	name			"imgbtn"id \
	type			ITEM_TYPE_BUTTON \
	style			WINDOW_STYLE_FILLED \
	rect			(x - 2) (y - 2) (w + 2) 18 buttonAlign \
	border			1 \
	bordersize		1 \
	bordercolor		0 0 0 1 \
	background		"black" \
	backcolor		col1 1 \
	visible			vis \
	mouseEnter \
	{ \
		play "mouse_over"; \
		setcolor backcolor col2 1; \
	} \
	mouseExit \
	{ \
		setcolor backcolor col1 1; \
	} \
	action \
	{ \
		do; \
	} \
} \
itemDef \
{ \
	style			WINDOW_STYLE_SHADER \
	rect			x y w 16 buttonAlign \
	background 		img \
	visible			vis \
	decoration \
}

#define IMGBUTTON_FADE(x, y, w, cond) \
itemDef \
{ \
	type			ITEM_TYPE_BUTTON \
	style			WINDOW_STYLE_FILLED \
	rect			x y w 16 buttonAlign \
	backcolor		0 0 0 0.5 \
	visible			cond \
}

#define MODERNPOPUP_EXT(menutitle, esc, title, body, ext) \
name			menutitle \
rect			0 0 640 480 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
focuscolor		1 1 1 1 \
blurWorld		4 \
style			WINDOW_STYLE_EMPTY \
onESC \
{ \
	esc \
	close self; \
} \
itemDef \
{ \
	type			ITEM_TYPE_BUTTON \
	style			WINDOW_STYLE_FILLED \
	rect			0 0 640 480 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	backcolor		0.4 0.4 0.4 0.5 \
	visible			1 \
} \
itemDef \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			220 190 200 100 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	backcolor		0.1 0.1 0.1 0.75 \
	visible			1 \
	decoration \
} \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		220 190 200 20 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	backcolor	0 0 0 0.75 \
	visible		1 \
	decoration \
} \
itemDef \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			340 190 80 20 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	background		"title_arrows" \
	backcolor		1 1 1 1 \
	visible			1 \
	decoration \
} \
itemDef \
{ \
	exp			text(title) \
	textfont	UI_FONT_NORMAL \
	style		WINDOW_STYLE_FILLED \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	rect		220 190 200 20 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	textalign	ITEM_ALIGN_LEFT \
	textscale	0.4 \
	textaligny	20 \
	textalignx	5 \
	forecolor	1 1 1 1 \
	visible		1 \
	decoration \
} \
itemDef \
{ \
	exp			text(body) \
	textfont	UI_FONT_NORMAL \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	rect		220 210 190 50 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	textalign	ITEM_ALIGN_LEFT \
	textscale	0.25 \
	textaligny	15 \
	textalignx	5 \
	forecolor	1 1 1 0.8 \
	visible		1 \
	autowrapped \
	decoration \
} \
ext

#define MODERNPOPUP(menutitle, esc, title, body, btn1title, btn1cmd, btn2title, btn2cmd) \
MODERNPOPUP_EXT(menutitle, esc, title, body, \
			PROBUTTON_CMD(330, 265, 80, btn1title, btn1cmd, "0") \
			PROBUTTON_CMD(230, 265, 80, btn2title, btn2cmd, "1") \
)

#define MODERNPOPUP_INPUT(menutitle, title, body, inputtext, inputdvar) \
name			menutitle \
rect			0 0 640 480 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
focuscolor		1 1 1 1 \
blurWorld		4 \
style			WINDOW_STYLE_EMPTY \
onOpen \
{ \
	setfocus message; \
} \
onESC \
{ \
	close self; \
} \
itemDef \
{ \
	type			ITEM_TYPE_BUTTON \
	style			WINDOW_STYLE_FILLED \
	rect			0 0 640 480 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	backcolor		0.4 0.4 0.4 0.5 \
	visible			1 \
} \
itemDef \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			220 190 200 100 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	backcolor		0.1 0.1 0.1 0.75 \
	visible			1 \
	decoration \
} \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		220 190 200 20 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	backcolor	0 0 0 0.75 \
	visible		1 \
	decoration \
} \
itemDef \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			340 190 80 20 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	background		"title_arrows" \
	backcolor		1 1 1 1 \
	visible			1 \
	decoration \
} \
itemDef \
{ \
	exp			text("@pro_"title"_" + dvarString("lang")) \
	textfont	UI_FONT_NORMAL \
	style		WINDOW_STYLE_FILLED \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	rect		220 190 200 20 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	textalign	ITEM_ALIGN_LEFT \
	textscale	0.4 \
	textaligny	20 \
	textalignx	5 \
	forecolor	1 1 1 1 \
	visible		1 \
	decoration \
} \
itemDef \
{ \
	exp			text(body) \
	textfont	UI_FONT_NORMAL \
	style		WINDOW_STYLE_FILLED \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	rect		220 210 200 50 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	textalign	ITEM_ALIGN_LEFT \
	textscale	0.25 \
	textaligny	15 \
	textalignx	5 \
	forecolor	1 1 1 0.8 \
	visible		1 \
	decoration \
} \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		222 233 196 18 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	backcolor	0.3 0.3 0.3 0.75 \
	border		1 \
	bordercolor	0 0 0 1 \
	visible		1 \
	decoration \
} \
itemDef \
{ \
	name			message \
	type			ITEM_TYPE_EDITFIELD \
	exp				text(locString("@pro_"inputtext"_" + dvarString("lang")) + ": ") \
	dvar			inputdvar \
	rect			220 235 200 14 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	textalignx		5 \
	textaligny		13 \
	maxchars		15 \
	maxpaintchars	15 \
	textalign		ITEM_ALIGN_LEFT \
	textfont		UI_FONT_NORMAL \
	textscale		0.25 \
	forecolor		0.9 0.9 0.9 1 \
	style			WINDOW_STYLE_FILLED \
	visible			1 \
	accept \
	{ \
		exec "setfromdvar info "inputdvar; \
		scriptMenuResponse inputdvar; \
		close self; \
	} \
} \
PROBUTTON_CMD(330, 265, 80, "OK", exec "setfromdvar info "inputdvar; scriptMenuResponse inputdvar; close self;, "0") \
PROBUTTON_CMD(230, 265, 80, "CANCEL", close self;, "1")

#define closeButton(x, y, visArg, actionArg, extArg) \
itemDef \
{ \
	style			WINDOW_STYLE_EMPTY \
	rect			x y 18 18 buttonAlign \
	border			1 \
	bordersize		1 \
	bordercolor		0 0 0 1 \
	visible			visArg \
	extArg \
	decoration \
} \
itemDef \
{ \
	name			"imgdefaultclose" \
	style			WINDOW_STYLE_FILLED \
	rect			(x + 2) (y + 2) 16 16 buttonAlign \
	background		"black" \
	backcolor		0.8 0 0 1 \
	visible			visArg \
	extArg \
	decoration \
} \
itemDef \
{ \
	type		ITEM_TYPE_BUTTON \
	style		WINDOW_STYLE_FILLED \
	rect		(x + 2) (y + 2) 16 16 buttonAlign \
	visible		visArg \
	extArg \
	mouseEnter \
	{ \
		play "mouse_over"; \
		setitemcolor imgdefaultclose backcolor 1 0 0 1; \
	} \
	mouseExit \
	{ \
		setitemcolor imgdefaultclose backcolor 0.8 0 0 1; \
	} \
	action \
	{ \
		actionArg; \
	} \
} \
itemDef \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			(x + 2) (y + 2) 16 16 buttonAlign \
	background		"x" \
	backcolor		1 1 1 1 \
	visible			visArg \
	extArg \
	decoration \
}


// Popup, used with show-hide.
#define POP(nameArg, msgArg, titleArg, descArg, inputArg) \
itemDef \
{ \
	type			ITEM_TYPE_BUTTON \
	group			nameArg \
	style			WINDOW_STYLE_FILLED \
	rect			0 0 640 480 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	backcolor		0.4 0.4 0.4 0.5 \
	visible			0 \
} \
itemDef \
{ \
	group			nameArg \
	style			WINDOW_STYLE_FILLED \
	rect			220 190 200 100 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	backcolor		0.1 0.1 0.1 0.75 \
	visible			0 \
	decoration \
} \
itemDef \
{ \
	group		nameArg \
	style		WINDOW_STYLE_FILLED \
	rect		220 190 200 20 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	backcolor	0 0 0 0.75 \
	visible		0 \
	decoration \
} \
itemDef \
{ \
	group			nameArg \
	style			WINDOW_STYLE_FILLED \
	rect			340 190 80 20 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	background		"title_arrows" \
	backcolor		1 1 1 1 \
	visible			0 \
	decoration \
} \
itemDef \
{ \
	group		nameArg \
	exp			text("@pro_"titleArg"_" + dvarString("lang")) \
	textfont	UI_FONT_NORMAL \
	style		WINDOW_STYLE_FILLED \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	rect		220 190 200 20 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	textalign	ITEM_ALIGN_LEFT \
	textscale	0.4 \
	textaligny	20 \
	textalignx	5 \
	forecolor	1 1 1 1 \
	visible		0 \
	decoration \
} \
itemDef \
{ \
	group		nameArg \
	exp			text(descArg) \
	textfont	UI_FONT_NORMAL \
	style		WINDOW_STYLE_FILLED \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	rect		220 210 200 50 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	textalign	ITEM_ALIGN_LEFT \
	textscale	0.25 \
	textaligny	15 \
	textalignx	5 \
	forecolor	1 1 1 0.8 \
	visible		0 \
	decoration \
} \
itemDef \
{ \
	group		nameArg \
	style		WINDOW_STYLE_FILLED \
	rect		222 233 196 18 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	backcolor	0.3 0.3 0.3 0.75 \
	border		1 \
	bordercolor	0 0 0 1 \
	visible		0 \
	decoration \
} \
itemDef \
{ \
	group			nameArg \
	name			msgArg \
	type			ITEM_TYPE_EDITFIELD \
	exp				text(locString(inputArg)) + ": ") \
	dvar			nameArg \
	rect			220 235 200 14 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	textalignx		5 \
	textaligny		13 \
	maxchars		15 \
	maxpaintchars	15 \
	textalign		ITEM_ALIGN_LEFT \
	textfont		UI_FONT_NORMAL \
	textscale		0.25 \
	forecolor		0.9 0.9 0.9 1 \
	style			WINDOW_STYLE_FILLED \
	visible			0 \
	accept \
	{ \
		execNow "setfromdvar info "nameArg; \
		scriptMenuResponse nameArg; \
		hide nameArg; \
	} \
} \
PROBUTTON_HIDDEN_EXT(330, 265, 80, "OK", execNow "setfromdvar info "nameArg; scriptMenuResponse nameArg; hide nameArg;, 0, nameArg"0", group nameArg) \
PROBUTTON_HIDDEN_EXT(230, 265, 80, "CANCEL", hide nameArg;, 0, nameArg"1", group nameArg)



#define TITLE(itemIndex, textArg, visArg) \
itemDef \
{ \
	rect			(SETS_X + 5) (SETS_Y + 2 + itemIndex * 20) 100 20 0 0 \
	exp				text(textArg) \
	textfont		UI_FONT_NORMAL \
	textscale		0.25 \
	textstyle		0 \
	textAlign		ITEM_ALIGN_MIDDLE_RIGHT \
	forecolor		1 1 1 1 \
	visible			visArg \
	decoration \
} \

#define SLIDER(itemIndex, textArg, dvarArg, defaultArg, minArg, maxArg) \
SLIDER_ACT(itemIndex, textArg, dvarArg, defaultArg, minArg, maxArg, ;)

#define SLIDER_ACT(itemIndex, textArg, dvarArg, defaultArg, minArg, maxArg, actionArg) \
TITLE(itemIndex, textArg, 1) \
itemDef \
{ \
	type			ITEM_TYPE_SLIDER \
	dvarfloat		dvarArg defaultArg minArg maxArg \
	rect			(SETS_X + 110) (SETS_Y + 4 + itemIndex * 20) 120 18 0 0 \
	style			WINDOW_STYLE_FILLED \
	visible			1 \
	onFocus \
	{ \
		play "mouse_over"; \
	} \
	action \
	{ \
		play "mouse_click"; \
		actionArg; \
	} \
}

#define LIST(itemIndex, textArg, dvarArg, listTypeArg, listArg) \
LIST_ACT_VIS(itemIndex, textArg, dvarArg, listTypeArg, listArg, ;, 1)

#define LIST_ACT(itemIndex, textArg, dvarArg, listTypeArg, listArg, actionArg) \
LIST_ACT_VIS(itemIndex, textArg, dvarArg, listTypeArg, listArg, actionArg, 1)

#define LIST_VIS(itemIndex, textArg, dvarArg, listTypeArg, listArg, visArg) \
LIST_ACT_VIS(itemIndex, textArg, dvarArg, listTypeArg, listArg, ;, visArg)

#define LIST_ACT_VIS(itemIndex, textArg, dvarArg, listTypeArg, listArg, actionArg, visArg) \
TITLE(itemIndex, textArg, visArg) \
itemDef \
{ \
	type			listTypeArg \
	dvar			dvarArg \
	listArg \
	rect			(SETS_X + 110) (SETS_Y + 2 + itemIndex * 20) 120 20 0 0 \
	textalign		ITEM_ALIGN_MIDDLE_LEFT \
	textscale		0.25 \
	textstyle 		ITEM_TEXTSTYLE_SHADOWED \
	style			WINDOW_STYLE_FILLED \
	visible			visArg \
	onFocus \
	{ \
		play "mouse_over"; \
	} \
	action \
	{ \
		play "mouse_click"; \
		actionArg; \
	} \
}

#define CHECKBOX(itemIndex, textArg, dvarArg, execArg) \
CHECKBOX_ACT_ON(itemIndex, textArg, dvarArg, execArg, ;, 1) \

#define CHECKBOX_ACT(itemIndex, textArg, dvarArg, execArg, actionArg) \
CHECKBOX_ACT_ON(itemIndex, textArg, dvarArg, execArg, actionArg, 1) \

#define CHECKBOX_ON(itemIndex, textArg, dvarArg, execArg, onArg) \
CHECKBOX_ACT_ON(itemIndex, textArg, dvarArg, execArg, ;, onArg) \

/* Using dvarArg in exec is not working */
#define CHECKBOX_ACT_ON(itemIndex, textArg, dvarArg, execArg, actionArg, onArg) \
TITLE(itemIndex, textArg, 1) \
itemDef \
{ \
	type			ITEM_TYPE_BUTTON \
	rect			(SETS_X + 111) (SETS_Y + 6 + itemIndex * 20) 10 10 0 0 \
	style			WINDOW_STYLE_FILLED \
	border			1 \
	bordersize		1 \
	bordercolor		1 1 1 1 \
	visible			1 \
	onFocus \
	{ \
		play "mouse_over"; \
	} \
	action \
	{ \
		play "mouse_click"; \
		execNow execArg; \
		actionArg; \
	} \
} \
itemDef \
{ \
	type			ITEM_TYPE_BUTTON \
	rect			(SETS_X + 114) (SETS_Y + 9 + itemIndex * 20) 6 6 0 0 \
	style			WINDOW_STYLE_FILLED \
	backcolor		1 1 1 1 \
	visible			when(dvarBool(dvarArg) == onArg) \
	decoration \
}

#define CHECKBOX_RESPONSESIMPLE(itemIndex, textArg,actionArg,onFocusArg,onArg) \
TITLE(itemIndex, textArg, 1) \
itemDef \
{ \
	type			ITEM_TYPE_BUTTON \
	rect			(SETS_X + 111) (SETS_Y + 6 + itemIndex * 20) 10 10 0 0 \
	style			WINDOW_STYLE_FILLED \
	border			1 \
	bordersize		1 \
	bordercolor		1 1 1 1 \
	visible			1 \
	mouseEnter \
	{ \
		play "mouse_over"; \
		setcolor backcolor 0.66 0.66 0.66 0.3; \
		setcolor bordercolor 1 0 0 1; \
		onFocusArg \
	} \
	mouseExit \
	{ \
		setcolor backcolor 0.1 0.1 0.1 0.5; \
		setcolor bordercolor 1 1 1 1; \
	} \
	action \
	{ \
		play "mouse_click"; \
		scriptMenuResponse actionArg; \
	} \	
} \
itemDef \
{ \
	type			ITEM_TYPE_BUTTON \
	rect			(SETS_X + 114) (SETS_Y + 9 + itemIndex * 20) 6 6 0 0 \
	style			WINDOW_STYLE_FILLED \
	backcolor		1 1 1 1 \
	visible			when(onArg) \
	decoration \
}

#define CHECKBOX_RESPONSESIMPLE2(itemIndex, textArg,actionArg,onArg) \
TITLE(itemIndex, textArg, 1) \
itemDef \
{ \
	type			ITEM_TYPE_BUTTON \
	rect			(SETS_X + 111) (SETS_Y + 6 + itemIndex * 20) 10 10 0 0 \
	style			WINDOW_STYLE_FILLED \
	border			1 \
	bordersize		1 \
	bordercolor		1 1 1 1 \
	visible			1 \
	mouseEnter \
	{ \
		play "mouse_over"; \
		setcolor backcolor 0.66 0.66 0.66 0.3; \
		setcolor bordercolor 1 0 0 1; \
	} \
	mouseExit \
	{ \
		setcolor backcolor 0.1 0.1 0.1 0.5; \
		setcolor bordercolor 1 1 1 1; \
	} \
	action \
	{ \
		play "mouse_click"; \
		scriptMenuResponse actionArg; \
	} \	
}\
itemDef \
{ \
	type			ITEM_TYPE_BUTTON \
	rect			(SETS_X + 114) (SETS_Y + 9 + itemIndex * 20) 6 6 0 0 \
	style			WINDOW_STYLE_FILLED \
	backcolor		1 1 1 1 \
	visible			when(onArg) \
	decoration \
}


#define CHECKBOX_RESPONSE(itemIndex, textArg, dvarArg,actionArg, onArg) \
TITLE(itemIndex, textArg, 1) \
itemDef \
{ \
	type			ITEM_TYPE_BUTTON \
	rect			(SETS_X + 111) (SETS_Y + 6 + itemIndex * 20) 10 10 0 0 \
	style			WINDOW_STYLE_FILLED \
	border			1 \
	bordersize		1 \
	bordercolor		1 1 1 1 \
	visible			1 \
	onFocus \
	{ \
		play "mouse_over"; \
	} \
	action \
	{ \
		play "mouse_click"; \
		scriptMenuResponse actionArg; \
	} \
} \
itemDef \
{ \
	type			ITEM_TYPE_BUTTON \
	rect			(SETS_X + 114) (SETS_Y + 9 + itemIndex * 20) 6 6 0 0 \
	style			WINDOW_STYLE_FILLED \
	backcolor		1 1 1 1 \
	visible			when( dvarArg == onArg) \
	decoration \
}

		
#define BINDEDITFIELD(itemIndex, textArg, cmdArg) \
TITLE(itemIndex, textArg, 1) \
itemDef \
{ \
	type			ITEM_TYPE_EDITFIELD \
	text			" " \
	dvar			cmdArg \
	rect			(SETS_X + 110) (SETS_Y + 2 + itemIndex * 20) 120 20 0 0 \
	textalign		ITEM_ALIGN_MIDDLE_LEFT \
	textscale		0.25 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	style			WINDOW_STYLE_EMPTY \
	forecolor		1 1 1 1 \
	visible			1 \
	maxChars		12 \
	maxpaintchars	12 \
	onFocus \
	{ \
		play "mouse_over"; \
		show keyBindStatus; \
	} \
	leaveFocus \
	{ \
		hide keyBindStatus; \
	} \
	action \
	{ \
		play "mouse_click"; \
	} \
}

	
#define BIND(itemIndex, textArg, cmdArg) \
TITLE(itemIndex, textArg, 1) \
itemDef \
{ \
	type			ITEM_TYPE_BIND \
	dvar			cmdArg \
	rect			(SETS_X + 110) (SETS_Y + 2 + itemIndex * 20) 120 20 0 0 \
	textalign		ITEM_ALIGN_MIDDLE_LEFT \
	textscale		0.25 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	style			WINDOW_STYLE_EMPTY \
	forecolor		1 1 1 1 \
	visible			1 \
	onFocus \
	{ \
		play "mouse_over"; \
		show keyBindStatus; \
	} \
	leaveFocus \
	{ \
		hide keyBindStatus; \
	} \
	action \
	{ \
		play "mouse_click"; \
	} \
}

#define HEAD(itemIndex, textArg) \
itemDef \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			SETS_X (SETS_Y + 21 + itemIndex * 20) 230 1 0 0 \
	exp				text(textArg) \
	textfont		UI_FONT_NORMAL \
	textscale		0.35 \
	textstyle		0 \
	textAlignY		-2 \
	textAlign		ITEM_ALIGN_CENTER \
	forecolor		0.8 0.8 1 1 \
	background		"line_horizontal" \
	backcolor		0.8 0.8 1 1 \
	visible			1 \
	decoration \
}