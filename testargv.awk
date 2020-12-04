# testargv.awk
# CREATION  08:47 15/10/2020 teste l'usage des variable d'environnement GAWK à commencer par ARGV

function dumparray(tablo)
{
    for (i in tablo) {
        print "tablo" ,i, tablo[i]
    }
}
BEGIN {
    for (i = 0; i < ARGC; i++) print "ARGV ",i,ARGV[i]
    for (i in ENVIRON) print "ENVIRON",i, ENVIRON[i]
    for (i in FUNCTAB) print "FUNCTAB",i, FUNCTAB[i]

    for (i = 0; i < length(PROCINFO["argv"]); i++)   print "PROCINFO[\"argv \"]",i, PROCINFO["argv"][i]
    print "PROCINFO[\"FS\"]" PROCINFO["FS"]
    print "timetravel begin"
    print "PROCINFO[\"identifiers\"][\"PROCINFO\"] "PROCINFO["identifiers"]["PROCINFO"] 
    print "PROCINFO[\"identifiers\"][\"ENVIRON\"] "PROCINFO["identifiers"]["SYMTAB"] 
    print "PROCINFO[\"identifiers\"][\"i\"] "PROCINFO["identifiers"]["i"] 
    print "PROCINFO[\"identifiers\"][\"dumparray\"] "PROCINFO["identifiers"]["dumparray"] 
    print "timetrabel end"
    print "PROCINFO[\"platform\"] " PROCINFO["platform"]
    print "PROCINFO[\"version\"] " PROCINFO["version"]
    for (i in PROCINFO) if (isarray(PROCINFO[i]) == 0) {
        print "PROCINFO",i, PROCINFO[i]
    } else {
        # for (i in procinfo[i]) {
            print "procinfo","i" , PROCINFO[PROCINFO[i]]
        # }
    }
    for (i in SYMTAB) if (isarray(SYMTAB[i]) == 0) print "SYMTAB",i, SYMTAB[i]
    
    
    
}
      