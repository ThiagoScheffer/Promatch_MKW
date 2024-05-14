#include promatch\_utils;
//V105

init()
{
	//precacheShader("damage_feedback");
	//precacheShader("damage_feedback_j");

	level thread onPlayerConnect();
}
// NEWHITMARKER
onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);

		player.hud_damagefeedback = newClientHudElem(player);
		player.hud_damagefeedback.horzAlign = "center";
		player.hud_damagefeedback.vertAlign = "middle";
		player.hud_damagefeedback.x = -12;
		player.hud_damagefeedback.y = 30;
		player.hud_damagefeedback.alpha = 0;
		player.hud_damagefeedback.archived = true;
		player.hud_damagefeedback.font = "default";
		player.hud_damagefeedback.fontScale = 1.4;
	}
}

updateDamageFeedback( damage,sMeansOfDeath)
{

	if(damage < 56)
	self.hud_damagefeedback.color = (1,1,1);//branco?
	
	if(damage > 59)
	self.hud_damagefeedback.color = (1,0.7,0.1);
	
	if(damage > 99)
	self.hud_damagefeedback.color = (1,0.1,0.1);
	self.hud_damagefeedback.alpha = 1;
	self.hud_damagefeedback setValue(damage);
	//wait 0.05;
	self.hud_damagefeedback fadeOverTime(0.8);
	//self.hud_damagefeedback.color = (1,1,1);
	self.hud_damagefeedback.alpha = 0;
}