# catalconcat.awk
# CREATION  23:10 19/12/2020 d'après stockconcat.awk 10:35 17/12/2020 du 11:32 18/12/2020 concatène tous les exports de catalogue en un seul fichier en n'en gardant que les champs utiles
# NOTA      Comme on ne prend pas de zones contenant du texte accentué ce n'est pas la peine de convertir en utf8 au préalable (mais pas gênant si c'est fait)

BEGIN {
    # print datefich
    if (split(datefich,tablo)==0) {
        print "La date du fichier doit être passée dans la variable datefich"
        for (i in tablo) print i,tablo[i]   
        exit 1
    }

    if (split(tablo[1],variable,"/") != 3) {
        print "la variable datefich doit contenir une date au format jj/mm/aa et pas la valeur " tablo[1],datefich
        for (i in variable) {
            print i , variable[i]
        }
        exit 2
    }
    dateexport=variable[3] "-" variable[2] "-" variable[1]
    # print dateexport

    FS=";"
    OFS=";"
}

FNR != 1 {
    print $10,$1,$7,$11, dateexport
}
