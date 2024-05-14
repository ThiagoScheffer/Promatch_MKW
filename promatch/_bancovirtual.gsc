#include promatch\_eventmanager;
#include promatch\_utils;

//MENU BANCO
//REGISTRAR USUARIO
//QUANTO EVP TENHO
//QUANTO VOU APLICAR

init()
{

	level.scr_bancovirtual = 0 ; //getdvarx( "scr_bancovirtual", "int", 0, 1, 1 );

	if ( level.scr_bancovirtual == 0 )
		return;
		
	//quanto esta rendendo esse dia
	//tornar dinamico 2 3 4 5 6
	level.taxaatual = ConvertoFloat(getdvarint("taxaatual"));
	
	//quanto do montante acomulado o server recebe - vips?  1%
	level.taxadoserver = 1.0;
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}

//faz apenas uma vez o recebimento do dia
onPlayerSpawned()
{
	//esse esta aplicando?
	self thread Recebimento();	
}

Recebimento()
{
	self endon("disconnect");
		
	//STAT APLICADO
	
	//DIA CONTADO


}