# AgeStock.awk
# calcul du temps depuis chaque produit tocké chez I&S est présent en stock
# D'après VieStock.awk
# du 02/10/2019  09:53 

# Champs du fichier d'entrée
# 1 Qte
# 2 Nom projet
# 3 Ref
# 4 Lib
# 5 Designation
# 6 Etat
# 7 Statut
# 8 Num□ro de s□rie
# 9 TagIs
# 10 DateEntree
# 11 (champ vide)


BEGIN {
    FS=";"
    OFS=";"
    nbsecjour=24*60*60
    LN10=log(10)
    datemax=0
    datemin=mktime("2038 01 19 03 14 07")
}

# gawk -F; '{commande=^"ls --full-time  ^" FILENAME ^" ^>timestamp.txt^" ; system(commande);getline timestamp ^< ^"timestamp.txt^";split(timestamp,tablo,^" ^");for (i in tablo){print i OFS tablo[i]};exit}'  is_out_201910.csvk

NR==1 { # récuparation de la date de création du fichier d'entrée
    commande="ls --full-time  " FILENAME " >timestamp.txt" 
    system(commande)
    getline timestamp < "timestamp.txt"
    split(timestamp,tablo," ")
    for (i in tablo) {
        if (tablo[i] ~ /^[0-9]{2,4}-[0-9]{2}-[0-9]{2}$/) datefin=tablo[i]
        if (tablo[i] ~ /^[0-9]{2}:[0-9]{2}:[0-9|\.]*$/) heurefin=tablo[i]
    }
    datefin = datefin " " heurefin
    datefin=gensub(/-|:/," ","g",datefin)
    # print datefin
    datenumsortie=mktime(datefin)
    # exit
}

# $1 !~ /^[0-9]{10}$/ {next} # rien à faire si pas de dossier glpi valide
# $9 ~ /COLI/ {next} # rien à faire si Colissimo
NR==1 && NF!=11 && $11 !~ /^$/ { # sort si l'on n'est pas dans une extraction de stock
    print FILENAME " n'est pas une extraction de stock"
    exit NF
}

NR > 1 { #MAIN - On ne traite qu'au delà du 1° enregistrement afiin de ne pas être parasité par la ligne d'en-t$ete
    ref=$3
    lib=$5
    dateentree=$10
    tagis=$9
    
     dateentree=gensub(/\/|:/," ","g",dateentree)

    
    if (dateentree) {
        split(dateentree,jjmmaaaa," ")
        datespec=jjmmaaaa[3] " " jjmmaaaa[2] " " jjmmaaaa[1] " " jjmmaaaa[4] " " jjmmaaaa[5] " " jjmmaaaa[6] # " " "00" " " "00" " " "00"
        datenumentree=mktime(datespec)
    
         duree=datenumsortie-datenumentree
         # if (duree>maxi) maxi=duree
         # if (duree<mini) mini=duree
         
         produit=substr(ref,8,3)
         etat=substr(ref,6,1)
         famille=substr(ref,4,2)

         
         output = OFS etat OFS produit OFS lib "\r\bn"


         printf "%2s", int(log(duree/nbsecjour)/LN10 + 0.5) OFS
         printf "%6s", int(duree/nbsecjour + 0.5) OFS
         print tagis OFS etat OFS famille OFS produit OFS lib  "\r"
    }
}

END {
    # print "maxi " int(maxi/nbsecjour + 0.5)
    # print "mini " int(mini/nbsecjour + 0.5)
}