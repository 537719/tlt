#lastCHRorder.awk
# fournit la dernière date de sortie de chaque produit CHRONO et ALTURING déstocké par I&S
# selon mail de laurence.quentin@alturing.eu en date du 23 oct. 2019 16:13
# un tableau comme celui-ci
# ref complète	désignation du produit	date de dernière sortie
# CHRxxxxxxx	 	 
# TLTxxxxxxxx	 	 
# 	 	 
# 	 	 

# travaille sur l'export des produits expédiés par I&S

# doit être croisé avec le résultat de lastCHRs afin d'y rajouter les produits qui ne sont jamais sortis du stock

# CREATION  10:12 jeudi 24 octobre 2019

BEGIN {
    FS=";"
    OFS=";"
}

$6 !~ /[^CLP][1-7][0-Z][N|R][R|F|P][0-Z]{3}$/ {next} # on ne prend en compte que les références valides et on exclut coli

{ #main
    ref=$6
    lib=$7
    liv=$8

    n=split(liv,tdate,"/")
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