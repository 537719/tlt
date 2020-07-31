# fred.awk
# 11:50 19/02/2020 Extraction depuis un export csv de GLPI selon Le besoin :
# Compter par Client (CHR - COL - BIO) pour les différentes ressources (N2 Systèmes - N2 DBA - N2 APPLICATIONS) les différents Changement (RFC puis RFCPA) sur chaque jour de la semaine (Lundi - mardi - mercredi - jeudi - vendredi - samedi - dimanche).:

# Fichier d'entrée Extraction_2019.csv
# 1 Titre
# 2 Entité
# 3 Date d'ouverture
# 4 ID
# 5 Attribué à - Groupe d'attribution
# 6 Attribué à - Technicien
# 7 Statut
# 8 Catégorie
# 9 Description
# 10 Dernière modification


# Problème : le champ "Description" est multilignes, chaque ligne étant séparée par un LF
# Solution : les enregistrements étant séparés par un CRLF cela se résoud par des outils de conversion dans un script CMD exécutant un tr \n \t|mac2unix|unix2dos|sed "s/^\t//"


 # Il ne reste plus qu'à traiter le fichier avec gawk en cherchant les informations suivantes :
# :: CLIENT : champ $2 "Entité"
# :: différents Changement : champ $9 "description" /- Type de la demande : "RFC" ou "RFCPA"
# :: jour de la semaine : calcul sur champ $9 "description" /- Date de d?but : 22/10/2019 06:00
# :: ressources : champ $9 "description" /- Type de ressources N2 : Support proximit?, N2 OUTILS, N2 RESEAU, N2 SYSTEME, N2 TLD
# :: Mauvaise nouvelle : le champ "description" peut contenir des ; qui faussent le compteur de nombre de champs
# :: Bonne nouvelle : on s'en fout, on parse la description via le séparateur tabu pour trouver les sous-champs désirés qui ont tous la structure suivante :
#       \tnom_du_sous-champ : valeur,valeur,valeur\t
#       avec le nom_du_sous-champ écrit toujours de la même manière pour tous les enregistrement
# :: autre difficulté : le sous-champ "resources" contient plusieurs valeurs séparées par des virgules

function trim(chaine) {
    gsub(/^[ |\t]*/,"",chaine)
    gsub(/ *$/,"",chaine)
    return chaine
}

BEGIN {
    FS=";"
    tabu="\t"
    virgule=","
    OFS=";"
    str="x"
    comment=1
    joursem[0]="Dimanche"
    joursem[1]="Lundi"
    joursem[2]="Mardi"
    joursem[3]="Mercredi"
    joursem[4]="Jeudi"
    joursem[5]="Vendredi"
    joursem[6]="Samedi"
}

NR>1 { # la première ligne est une ligne d'en-tête
    delete tt
    ss=split($2,tt,">")
    Entite[NR]=trim(tt[ss])
    id[NR]=$4
    nsc=split($9,description,tabu) # nsc pour "nombre de sous-champs"
    # print NR,Entite[NR],id[NR],nsc
    for (i in description) {
        switch (description[i]) {
            case /- Type de la demande/ :
            {
                delete tt
                split(description[i],tt,":") # tt = tableautemporaire
                typedemande[NR]=trim(tt[2])
                break
            }
            case /- Date de d/ :
            {
                delete tt
                ss=split(description[i],tt,":")
                workdate=tt[2] 
                if (ss>2) workdate=workdate ":" tt[3]
                
                # print str "@" comment "@" workdate
                sub(/^ */,"",workdate)
                # gensub(/\//,"-","g",workdate)
                # print str "@" comment "@" workdate "@"
                
                datedebut[NR]=trim(workdate)
                break
            }
            case /- Type de ressources N2/ :
            {
                delete tt
                split(description[i],tt,":")
                gsub(/+/,",",tt[2])
                ressources[NR]=trim(toupper(tt[2]))
                break
            }
        }
    }
}

END{ # restitution des résultats
    # exit
    print "Id", "BU","Changement","Debut","Jour","Resource"
    for (i in Entite) {
    # print i
        split(ressources[i],subresources,virgule)
        for (j in subresources) {
            libresource=subresources[j]
            switch(libresource) {
                case /SYS/ :
                {
                    libresource="N2 SYSTEME"
                    break
                }
                case /APP/ :
                {
                    libresource="N2 APPLI"
                    break
                }
                case /N2.*R/ :
                {
                    libresource="N2 RESEAU"
                    break
                }
                case /N2.*B/ :
                {
                    libresource="N2 BDD"
                    break
                }
                case /PROX/ :
                {
                    libresource="SPX"
                    break
                }
                case /SANS/ :
                {
                    libresource="NEANT"
                    break
                }
            }
            datespec=datedebut[i]
            datestring=substr(datespec,7,4) " "substr(datespec,4,2) " "substr(datespec,1,2) " " substr(datespec,12,2)  " " substr(datespec,15,2)  " 00"
            epoch=mktime(datestring)
            
            if (libresource) print id[i],Entite[i], typedemande[i],strftime("%Y-%m-%d %H:%M",mktime(datestring)),joursem[strftime("%w",mktime(datestring))],libresource
            # if (libresource) print id[i],Entite[i], typedemande[i],datestring,libresource
        }
    }
}

# select strftime("%w",date(substr(debut,7,4) || "-" || substr(debut,4,2) || "-" || substr(debut,1,2) || substr(debut,11)))   from data;