#define LOADOUT_WIDTH 			270

#ifdef PC
	#define ORIGIN_LOADOUT			((-(LOADOUT_WIDTH - RIGHTITEM_OFFSET))-120/*menor move direita*/) 80// maior Positivo desce
#else
	#define ORIGIN_LOADOUT			(-(LOADOUT_WIDTH - RIGHTITEM_OFFSET)) 38
#endif

#define RATEBAR_FRAME_BORDER		0//WINDOW_BORDER_SUNKEN
#define RATEBAR_FRAME_BORDERSIZE	2
#define RATEBAR_FRAME_BORDERCOLOR	0.4 0.4 0.425 1

#define RATEBAR_BAR_SHADER			"gradient_fadein"
#define RATEBAR_BAR_COLOR			1 1 1 0.3

#define RATE_BAR_WIDTH				98
#define RATE_BAR_HEIGHT				12

