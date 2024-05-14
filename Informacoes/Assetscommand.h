+set r_xassetnum "image=3000 material=2560 xmodel=1200 xanim=3200"


"H:\COD4 Server\server.exe" +set dedicated 2 +set fs_game mods/promatch207 +exec server.cfg  +set dedicated 2  `+map_rotate +set net_port 28961 +set r_xassetnum "material=3560 xmodel=2200 xanim=3200 image=3000 fx=600"



SERVER EXTRAS CMD

SET addAdvertMsg "^1QUEM NAO USAR N VAI CONECTAR - www.prnt.sc/cbsi9e"
addRuleMsg
clearAllMsg
writenvcfg ?
Usage: addCommand <commandname> <"string to execute"> String can contain: $uid $clnum $pow $arg $arg:default

Usage: downloadmap <"url">
For example: downloadmap "http://somehost/cod4/usermaps/mapname"
	Cmd_AddPCommand ("getmodules", SV_GetModules_f, 45);
	Cmd_AddCommand ("killserver", SV_KillServer_f);
	Cmd_AddCommand ("setPerk", SV_SetPerk_f);
	Cmd_AddPCommand ("map_restart", SV_MapRestart_f, 50);
	Cmd_AddCommand ("fast_restart", SV_FastRestart_f);
	Cmd_AddPCommand ("rules", SV_ShowRules_f, 1);
	Cmd_AddCommand ("heartbeat", SV_Heartbeat_f);
	Cmd_AddPCommand ("kick", Cmd_KickPlayer_f, 35);
	Cmd_AddCommand ("clientkick", Cmd_KickPlayer_f);
	Cmd_AddCommand ("onlykick", Cmd_KickPlayer_f);
	Cmd_AddPCommand ("unban", Cmd_UnbanPlayer_f, 80);
	Cmd_AddCommand ("unbanUser", Cmd_UnbanPlayer_f);
	Cmd_AddPCommand ("permban", Cmd_BanPlayer_f, 80);
	Cmd_AddPCommand ("tempban", Cmd_TempBanPlayer_f, 50);
//	Cmd_AddCommand ("bpermban", Cmd_BanPlayer_f);
//	Cmd_AddCommand ("btempban", Cmd_TempBanPlayer_f);
	Cmd_AddCommand ("banUser", Cmd_BanPlayer_f);
	Cmd_AddCommand ("banClient", Cmd_BanPlayer_f);
	Cmd_AddPCommand ("ministatus", SV_MiniStatus_f, 1);
	Cmd_AddPCommand ("say", SV_ConSayChat_f, 70);
	Cmd_AddCommand ("consay", SV_ConSayConsole_f);
	Cmd_AddPCommand ("screensay", SV_ConSayScreen_f, 70);
	Cmd_AddPCommand ("tell", SV_ConTellChat_f, 70);
	Cmd_AddCommand ("contell", SV_ConTellConsole_f);
	Cmd_AddPCommand ("screentell", SV_ConTellScreen_f, 70);
	Cmd_AddPCommand ("dumpuser", SV_DumpUser_f, 50);
	Cmd_AddCommand ("stringUsage", SV_StringUsage_f);
	Cmd_AddCommand ("scriptUsage", SV_ScriptUsage_f);
	Cmd_AddPCommand ("undercover", Cmd_Undercover_f, 60);

