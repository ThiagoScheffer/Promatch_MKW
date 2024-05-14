#include promatch\_utils;

init()
{
	//Modo Tournament
	//addLeagueRuleset( "promatch_r12", "all", rulesets\promatch\promatch::init );
	
	//Regra 30rounds
	//addLeagueRuleset( "promatch_r15", "all", rulesets\promatch\promatch::init );
	
	//Modo publico 
	addLeagueRuleset( "public", "all", rulesets\promatch\promatch::init );
	
	//Modo Free
	//addLeagueRuleset( "custom", "all", rulesets\custom::init );
	
	//Modo Training
	addLeagueRuleset( "practice", "all", rulesets\promatch\promatch::init );
	
	//EVENTO
	addLeagueRuleset( "torneio", "all", rulesets\promatch\promatch::init );
	
}