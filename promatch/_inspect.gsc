init()
{
    level.inspectWeapons = [];
    level.inspectWeaponHoldTime = 0.8;
   // addInspectableWeapon("usp_silencer_mp");
	
	addInspectableWeapon("m21_mp");
	addInspectableWeapon("m21_acog_mp");		
    addInspectableWeapon("colt45_mp");
	addInspectableWeapon("remington700_acog_mp");
	addInspectableWeapon("saw_acog_mp");
	
    thread onPlayerConnect();
}

addInspectableWeapon(weapon)
{
    alt = WeaponAltWeaponName(weapon);
    if (alt == "none" || alt == "")
        return;

    precacheItem(alt);
    i = level.inspectWeapons.size;
    level.inspectWeapons[i] = spawnStruct();
    level.inspectWeapons[i].weapon = weapon;
    level.inspectWeapons[i].alt = alt;
}

onPlayerConnect()
{
    while(1)
    {
        level waittill("connected", player);
        player thread onPlayerSpawn();
    }
}

onPlayerSpawn()
{
    self endon("disconnect");
    while(1)
    {
        self waittill("spawned_player");
        self thread watchForInspectWeapon();
    }
}

getInspectAltWeapon(wpn)
{
    for (i = 0; i < level.inspectWeapons.size; i++)
        if (level.inspectWeapons[i].weapon == wpn)
            return level.inspectWeapons[i].alt;
    return "none";
}

watchForInspectWeapon()
{
    self endon("disconnect");
    self endon("death");
	
	//iprintln(" watchForInspectWeapon: ON ");

    while(1)
    {
        while(!self useButtonPressed())
            wait 0.2;
        
        self.inspectWeaponButtonPressedTime = 0;

        while (self useButtonPressed() && self.inspectWeaponButtonPressedTime < level.inspectWeaponHoldTime)
        {
            self.inspectWeaponButtonPressedTime += 0.2;
            wait 0.2;
        }
        
		if (self.inspectWeaponButtonPressedTime >= level.inspectWeaponHoldTime)
        {
            inspectWpn = self getCurrentWeapon();
            temp = getInspectAltWeapon(inspectWpn);
			
			//iprintln(" getInspectAltWeapon: ON " + temp);
			
            if (temp == "none")
                continue;

            self giveWeapon(temp);
            wait 0.05;
            self switchToWeapon(temp);
            wait 0.05;
            // This is a place where magic happens:
            // setSpawnWeapon saves current animation state but simply replaces
            // current weapon with another.
            self setSpawnWeapon(inspectWpn);
            self takeWeapon(temp);
        }
    }
}