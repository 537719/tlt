#lastCHRstock.awk
# d'après lastCHRorder.awk
# fournit la dernière date d'entrée de chaque produit CHRONO et ALTURING présent dans le stock I&S
# selon mail de laurence.quentin@alturing.eu en date du 23 oct. 2019 16:13
# un tableau comme celui-ci
# ref complète	désignation du produit	date de dernière sortie
# CHRxxxxxxx	 	 
# TLTxxxxxxxx	 	 
# 	 	 
# 	 	 

# doit être croisé avec le résultat de lastCHRorder afin d'y rajouter les produits qui ne sont jamais sortis du stock

# travaille sur un export du stock depuis l'extranet I&S

# CREATION  10:12 jeudi 24 octobre 2019

BEGIN {
    FS=";"
    OFS=";"
}

$3 !~ /[^CLP][1-7][0-Z][N|R][R|F|P][0-Z]{3}$/ {next} # on ne prend en compte que les références valides et on exclut coli
$6 !~ /OK/ {next} # on ne prend que les articles OK Dispo
$7 !~ /Disponible/ {next} # on ne prend que les articles OK Dispo

{ #main
    ref=$3
    lib=$5
    liv=$10

    n=split(substr(liv,1,10),tdate,"/") # on ramène au format "jj/mm/aaaa" une donnée écrite en "jj/mm/aaaa hh:mm" (heure non nécessaire)
    if (n != 3) { next } # on saute si la date n'a pas un format valide
    header=" Reference" OFS "Designation" OFS "Date" OFS "Cumul Qte"
    datenum=mktime(tdate[3] " " tdate[2] " " tdate[1] " 00 00 00")
    if (ref in lastref) {
        lastref[ref]=datenum
        lastlib[ref]=lib
    } else {
        if (datenum > lastref[ref]) {
            lastref[ref]=datenum
            lastlib[ref]=lib
        }
    }
    nb[ref]++
    # print ref,lib,liv,strftime("%x", datenum)
}

END {
    # asorti(lastref)
    print header
    for (i in lastref) {
        print i , lastlib[i] , strftime("%Y-%m-%d", lastref[i]),nb[i]
    }
}