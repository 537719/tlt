#ExportIS.awk
# Détermine si le flot d'entrée provient d'un export des produits expédiés ou reçus par I&S, et détermine les dates extremales concernées
# en sortie :
# si le fichier n'est pas un export I&S, ne fait rien
# si le fichier est un export des produits expédiés, renomme le fichier avec le préfixe is_out_
# si le fichier est un export des produits reçus, renomme le fichier avec le préfixe is_in_
# si un seul jour est concerné par le fichier, rajoute le suffixe aaaammjj
# si un seul mois est concerné par le fichier, rajoute le suffixe aaaamm
# si une seul année est concerné par le fichier, rajoute le suffixe aaaa
# dans tous les autres cas de fourchette de date, rajoute le suffixe <datedeb>-<datefin>
# puis reprend l'extension .csv

# BUG 26/01/2018 13:38 : oubliait de prendre en compte l'espace comme séparateur entre la date et l'heure
# MODIF 16/03/2018 - 15:44:14 le dossier "Historique" est renommé en "Data"
# MODIF 04/05/2018 - 15:16:46 - Régénération depuis le repositiry github suite à conflit lors de la fusion des branches
# MODIF 20/11/2018 - 14:30:13 - ajoute la gestion des exports de stock
# MODIF 20/11/2018 - 16:24:29 - corrige les exports des sorties dont la désignation contient des séparateurs ; indésirables
# MODIF 27/11/2018 - 15:18:14 - ajoute la prise en compte du nouveau format d'export de stock, 10 champs comme les réceptions
# MODIF 28/11/2018 - 10:36:35 - ajoute la prise en compte du catalogue (12 champs dont le dernir est vide à la date de la modif)
# MODIF 11:47 08/03/2019 inversion de l'ordre d'affichage des dates des bornes dans le nom de fichier de sortie
# MODIF 11:42 01/04/2019 rajout de la prise en compte des fichiers des dossiers traités (OFLX : OFLWEBEXPEDIES) et rajout de commentaires
# MODIF 17:47 23/06/2020 prise en compte du rajout du numéro des colis expédiés dans les OFLX
# MODIF 04:50 28/01/2021 considère que  les exports de stock sans date ni tagis sont de type oldstock et non stock
# MODIF 21:08 05/02/2021 le dossier de travail est désormais sous /ALT/ et non sous /TLT/
# BUG	21:29 05/02/2021 le passage de gawk 4 à gawk 5 impose de remplacer \: par : dans les regexp
BEGIN {
    FS=";"
    OFS=FS
    # outputdir="C:\\Us\\Documents\\TLT\\I&S\\Historique\\"
    # outputdir=ENVIRON["HOME"] "/Documents/TLT/I&S/Historique/" # emplacement relatif constant quelque soit le compte utilisateur
    outputdir=ENVIRON["HOME"] "/Documents/ALT/I&S/Data/" # emplacement relatif constant quelque soit le compte utilisateur
   hzero="00 00 00"
    
}
BEGINFILE {
    delete aligne # raz de l'array restituant les lignes du fichier
    typefich="undef"
    champdate=0
    outputfile=""
    # datemin=2^55
    idatemin=strftime(systime()) # dans les données concernées, aucune raison d'avoir une date postérieure à la date du jour
    idatemax=0
 }
{ #MAIN
    aligne[FNR]=$0
    if (FNR==1) { # la détermination du type de fichier se fait en testant la 1° ligne uniquement
        switch (NF) {
            case 22 : { # fichier des produits expédiés (jusqu'à Pays de destination inclus)
                typefich="out"
                champdate=8
                break
            }
            case 19 : { # fichier des produits expédiés ancienne structure (jusqu'à Tagis inclus)
                typefich="out"
                champdate=8
                break
            }
            case 12 : { # Export du catalogue
                if ($NF=="") { # le dernier champ de l'export du catalogue est vide, y compris sur la ligne d'en-tête)
                    typefich="catalogue"
                    champdate=0
                    break
                } else {
                    typefich="inconnu"
                    champdate=0
                    # pas de break ici, on est censé déclencher ensuite une erreur en passant par le cas default
                }
            }
            case 10 : { # fichier des produits reçus (jusqu'à NumTag inclus), ou de l'extraction des stocks "nouvelle formule" (novembre 2018)
                if ($NF=="") { # le dernier champ de l'export des stocks est vide, y compris sur la ligne d'en-tête)
                    typefich="stock"
                    champdate=9
                } else {
                    typefich="in"
                    champdate=4
                }
                break
            }
            case 7 : { # export du stock (jusqu'au champ vide après Num"ro de s▒"ie)
                typefich="oldstock"
                champdate=0 # pas de champ date dans cette version
                break
            }
            case 16 : { # export des OFLWEBEXPEDIES
                typefich="OFLX"
                champdate=14 # Date Notification - autres choix possibles : 6 (création), 7 (expédition), 13 (souhaité)
                break
            }
            case 17 : { # export des OFLWEBEXPEDIES "nouvelle formule" avec le(s) numéro(s) de colis 
                typefich="OFLX"
                champdate=14 # Date Notification - autres choix possibles : 6 (création), 7 (expédition), 13 (souhaité)
                break
            }
            default : { #indéterminé, on ne fait rien
                print FILENAME " n'est pas un export I&S des produits en stock, expédiés ou reçus ni du catalogue"
                exit NF
            }
        }
    } else { #run
        if (champdate) { # on ne cherche une date que si l'enregistrement est censé en contenir une
            split($champdate,adateevent,/\/|:| /) # extrait les éléments de date/heure en tenant compte du fait qu'on a deux types de séparateurs différents pour la date et l'heure plus un autre entre la date et l'heure
            datestring=adateevent[3] " " adateevent[2] " " adateevent[1] " " adateevent[4] " " adateevent[5] " " adateevent[6] " " hzero " " hzero
            #deux fois hzero car 1°) ça ne gêne pas et 2°) dans un cas on peut avoir une date-heure et dans l'autre non donc il faut la rajouter 
            # print datestring
            # datenum=mktime(dateevent[3] space dateevent[2] space dateevent[1] space dateevent[4] space dateevent[5] space dateevent[6] space hzero space hzero) #deux fois hzero car 1°) ça ne gêne pas et 2°) dans un cas on peut avoir une date-heure et dans l'autre non donc il faut la rajouter 
            datenum=mktime(datestring) 
            if (datenum>0) { #sinon, erreur de date
                if (datenum>idatemax) idatemax=datenum
                if (datenum<idatemin) idatemin=datenum
            } # else print $champdate OFS datestring
            # print datenum
        }
    }
    # if (datenum>systime()) { # pour debug uniquement
        # print
        # print NR OFS (strftime("%F",datemax)) OFS datestring OFS datenum
        # for (i=1;i<6;i++) print i OFS adateevent[i]
        # exit
    # }

}
ENDFILE {
    if (FNR>1) { # création du nom de chaque fichier de sortie
        if (champdate) { # on ne cherche une date que si l'enregistreemnt est censé en contenir une
            # détermination de la fourchette de dates
            # print "Date minimale " strftime("%F",idatemin)
            # print "Date maximale " strftime("%F",idatemax)
            
            sdatemin=strftime("%F",idatemin)
            sdatemax=strftime("%F",idatemax)
            # print sdatemin OFS sdatemax
            
        } else { # si le fichier ne contient pas de date, la date retenue est la date du jour
            idatemin=systime()
            idatemax=idatemin
            sdatemin=strftime("%F",idatemin)
            sdatemax=strftime("%F",idatemax)
        }
        
        split(strftime("%F",idatemin),adatemin,"-")
        split(strftime("%F",idatemax),adatemax,"-")
        
        outputfile="is_" typefich "_"
        
        # for (i in adatemin) {print i OFS adatemin[i]}
        # for (i in adatemax) {print i OFS adatemax[i]}
        
        if (adatemin[1]==adatemax[1]) {
            outputfile=outputfile adatemin[1]
            if (adatemin[2]==adatemax[2]) {
                outputfile=outputfile adatemin[2]
                if (adatemin[3]==adatemax[3]) {
                    outputfile=outputfile adatemin[3]
                }
            }
        } else {
            outputfile=outputfile adatemax[1] adatemax[2] adatemax[3] "-" adatemin[1] adatemin[2] adatemin[3]
        }
        outputfile=outputdir outputfile ".csv"
        print "entrée vient de " FILENAME
        print "sortie vers " outputfile
        # commandline="mv -b -i -u " FILENAME " " outputfile
        # commandline="move " FILENAME " " outputfile
        # commandline="move /?" 
        # print commandline
        # system(commandline)

        # Remplissage de chaque fichier de sortie
        for (i=1; i<=FNR; i++) {
            switch (typefich) {
                case /stock/ : # besoin de détecter et corriger les espaces et parenthèses fermantes éventuellement présents à tort dans la désignation
                {
                    nf=split(aligne[i],alaligne,";") # simulation du NF sur le tableau aligne
                    # print alaligne[3]
                    # FPAT = / +\(/
                    split(alaligne[3],reflib,"(")
                    # patsplit(alaligne[3],reflib,"  +")
                    gsub(/ +$/,"",reflib[1])
                    gsub(/\)$/,"",reflib[2])
                    if (reflib[2]=="") reflib[2]="Lib" 
                    alaligne[3]=reflib[1] OFS reflib[2]
                    # print i OFS alaligne[3]
                    aligne[i]=alaligne[1]
                    for (j=2;j<=nf;j++) {
                        aligne[i]=aligne[i] OFS alaligne[j]
                    }
                    # print aligne[i]
                    # break
                }
                
                case /out/ : # besoin de détecter et corriger les séparateurs ; éventuellement présents à tort dans la désignation
                {
                    nf=split(aligne[i],alaligne,";") # simulation du NF sur le tableau aligne
                    if (nf>22) { # détection et correction des séparateurs ; présents à tort dans la désignation
                        decalage=0
                        for (j=20;j<=nf;j++) { # calcul du décalage des champs
                            if (alaligne[j] ~ /^TE[0-9]{10}$/) {
                                decalage=j-19
                            }
                        }
                        for (j=1;j<=decalage;j++) { # rafistole le champ
                            alaligne[6]=alaligne[6] " " alaligne[j]
                        }
                        for (j=1;j<=decalage;j++) { # décale les champs
                            alaligne[6+i]=alaligne[6+i+decalage]
                        }
                        aligne[i]=alaligne[1]
                        for (j=2;j<=22;j++) { # recrée l'enregistrement
                            aligne[i]=aligne[i] OFS alaligne[j]
                        }
                    }
                }
                
                default :
                {
                    print aligne[i] > outputfile
                }
            }
        }
    }
}