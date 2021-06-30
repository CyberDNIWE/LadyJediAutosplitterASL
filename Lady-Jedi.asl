//Original author: CyberDNIWE
/*
Adresses 
level (string, part of resource string):    0x41E888;
levelNumberPart:                            0x41E890;
shutdown (string, part of console log?):    0x41EF25;

// These just happen to correspond to states that interest us!
characterIsControllable(float):             0x26CE00;
characterIsAlive (float):                   0x26CD8C;
loading (bool):                             0x41D868;
*/


/*
╔═══════════════════════════════════════════════════════╗
║                   Lady Jedi Map order                 ║
╠═══════════╦══════════════╦════════════════════════════╣
║  Chapter  ║    Mapname   ║   Last 2 digits as short   ║
╠═══════════╬══════════════╬════════════════════════════╣
║     0.    ║  ladyjedi01  ║            12592           ║
║     1.    ║  ladyjedi02  ║            12848           ║
║     2.    ║  ladyjedi03  ║            13104           ║
║     3.    ║  ladyjedi05  ║            13616           ║
║     4.    ║  ladyjedi04  ║            13360           ║
║     5.    ║  ladyjedi06  ║            13872           ║
║     6.    ║  ladyjedi07  ║            14128           ║
║     7.    ║  ladyjedi10  ║            12337           ║
║     8.    ║  ladyjedi11  ║            12593           ║
║     9.    ║  ladyjedi09  ║            14640           ║
║     10.   ║  ladyjedi08  ║            14384           ║
║     11.   ║  ladyjedi12  ║            12849           ║
╚═══════════╩══════════════╩════════════════════════════╝
// Too bad ASL does not support #define- like macroses (I hate magic numbers and adresses)
*/

state("jk2sp")
{
    bool        isLoading:  "jk2sp.exe", 0x41D868;
    string2     level:      "jk2sp.exe", 0x41E890;
    string8     shutdown:   "jk2sp.exe", 0x41EF25;

    //Little endian conversions, can't just cast float to bool on creation :(
    float characterIsControllable:  "jk2gamex86.dll", 0x26CE00;
    float characterIsAlive:         "jk2gamex86.dll", 0x26CD8C;
    
}

init
{
    print("INITIALIZED AUTOSPLITTER FOR [LADY JEDI]!");
    string currentLevel = "";
    string oldLevel = "";
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
    return !(Convert.ToBoolean(current.characterIsControllable) && Convert.ToBoolean(current.characterIsAlive) && !current.isLoading);
}

split
{
    // use buffer, for valid values,
    // because level string is empty momentarily between loading screens
    if(current.level.Length > 0)
    {
        vars.currentLevel = current.level;
    }
    if(old.level.Length > 0)
    {
        vars.oldLevel = old.level;
    }

    // Every level exept for last (12) changes to the next (default)
    switch((string)vars.currentLevel)
    {
        case "12":
        {
            // Check game ended (Nazar does not reset client level back to default upon exit... dick!)
            if(current.shutdown.Contains("down"))
            {
                //print("Run ends!");
                return true;
            }
            break;
        }
        
        default:
        {
            // Check split conditions:
            if(vars.currentLevel != vars.oldLevel)
            {        
                //print("Triggering SPLIT!");
                return true;
            }
            break;
        }
    }
}