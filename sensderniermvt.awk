#sensderniermvt.awk
#25/06/2018 - 14:39:23 DEBUT
#donne le sens du dernier mouvement d'un flot d'articles

#basé sur le format suivant :
# 1 Reference
# 2 DateEntree (jj/mm/aaaa)
# 3 Numero Serie
# 4 TagIS
# 5 sens

#critère :
# pour un couple "référence partielle (10 digits sauf les 6° et 7°) + numéro de série
# si la date de la ligne examinée est plus récente que la date de la dernière ligne mémorisée pour ce couple, on mémorise la ligne
# si ce couple n'a jamais été examiné, on mémorise la ligne

BEGIN {
    FS=";"
    OFS=FS
    sepdate="/"
    zero="00 00 00"
    spc=" "
    fmt="%F"
    
    delete adate
}

{ #MAIN
    reference=$1
    jjmmaa=$2
    numserie=$3
    tagis=$4
    sens=$5
    
    refpart=gensub(/^(.....)..(...)$/,"\\1\\2",1,reference)
    couple=refpart numserie
    
    split(jjmmaa,adate,sepdate)
    datestr=adate[3] spc adate[2] spc adate[1] spc zero
    datenbr=mktime(datestr)
    
    if (datenbr>sdate[couple]) {
        sref[couple]=reference
        sdate[couple]=datenbr
        ssn[couple]=numserie
        stag[couple]=tagis
        ssens[couple]=sens
    }
    # print couple OFS sdate[couple]
}

END {
    for (couple in sref) {
        print sref[couple] OFS strftime(fmt,sdate[couple]) OFS ssn[couple] OFS stag[couple] OFS ssens[couple]
    }
}