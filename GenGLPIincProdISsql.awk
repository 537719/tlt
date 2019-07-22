# GenGLPIincProdISsql.awk
# 16:07 25/01/2019 génère la requête d'extraction de GLPI les données relatives aux incidents de productions détectés par I&S


BEGIN {
    if (mois>0) {    # mois : variable facultative indiquant de combien de mois en amont de la date courante on souhaite la stat
        print "le mois sur lequel on souhaite travailler doit etre indiqué en nombre négatif par rapport à la date courante"
        exit mois
    }
    
    moiscourant=strftime("%m",systime())
    anneecourante=strftime("%Y",systime())
    
    decalan=int(mois/12)    # mois : variable facultative indiquant de combien de mois en amont de la date courante on souhaite la stat
    decalmois=int(mois-(12*decalan))
    print decalan OFS decalmois
    
    moisstatstring="0" moiscourant    +decalmois
    print moisstatstring
    lmoisstatstring=length(moisstatstring)
    print lmoisstatstring
    # moisstatstring=substr(moisstatstring,
    # moisstat=substr("0" moiscourant    +decalmois)
    anstat    =anneecourante+decalan
    
    statdebut=anstat "-" moisstat "-" "01"
    
    print statdebut
}