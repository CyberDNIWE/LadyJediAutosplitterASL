//Original author: CyberDNIWE

/*
╔══════════════════════════╗
║    Lady Jedi Map order   ║
╠═══════════╦══════════════╣
║  Chapter  ║    Mapname   ║
╠═══════════╬══════════════╣
║     0.    ║  ladyjedi01  ║
║     1.    ║  ladyjedi02  ║
║     2.    ║  ladyjedi03  ║
║     3.    ║  ladyjedi05  ║
║     4.    ║  ladyjedi04  ║
║     5.    ║  ladyjedi06  ║
║     6.    ║  ladyjedi07  ║
║     7.    ║  ladyjedi10  ║
║     8.    ║  ladyjedi11  ║
║     9.    ║  ladyjedi09  ║
║     10.   ║  ladyjedi08  ║
║     11.   ║  ladyjedi12  ║ "12"(last part of "ladyjedi12") interpreted as int32 is 12849
╚═══════════╩══════════════╝
*/

state("jk2sp")
{
    string10 level      : "jk2sp.exe", 0x41E888;
    string2  mapNum     : "jk2sp.exe", 0x41E890; // level + 8, ie last 2 digits of "ladyjediNN"
    string8  shutdown   : "jk2sp.exe", 0x41EF25;

    //Little endian conversions, can't just cast float to bool on creation :(
    float characterIsControllable:  "jk2gamex86.dll", 0x26CE00;
    float characterIsAlive:         "jk2gamex86.dll", 0x26CD8C;
}

init
{
    print("INITIALIZED AUTOSPLITTER FOR [LADY JEDI]!");
    string2 currentLevel = "";
    string2 oldLevel = "";
}

startup
{
    print("LOADED AUTOSPLITTER FOR [LADY JEDI]!");
}

start
{
    return (old.level.Length == 0 && current.level.Length != old.level.Length);
}

/*
reset
{
    print("RESET CALLED!");
    vars.currentLevel = "";
    vars.oldLevel = "";
}
*/

// Timer pauses whilst isLoading returns true
isLoading
{
    return !(Convert.ToBoolean(current.characterIsControllable) && Convert.ToBoolean(current.characterIsAlive));
}

split
{
    // use buffer, for valid values,
    // because level string is empty momentarily between loading screens
    if(current.level.Length > 0)
    {
        vars.currentLevel = current.mapNum;
    }
    if(old.level.Length > 0)
    {
        vars.oldLevel = old.mapNum;
    }

    // Check split conditions:
    if(vars.currentLevel != vars.oldLevel)
    {        
        print("Triggering SPLIT!");
        return true;
    }
    // Check game ended (Nazar does not reset client level back to default upon exit... dick!)
    else if(vars.currentLevel == "12")
    {
        if(current.shutdown == "shutdown")
        {
            print("Triggering SPLIT! Run ends!");
            return true;
        }
    }
}