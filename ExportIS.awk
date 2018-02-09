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

BEGIN {
    FS=";"
    OFS=FS
    # outputdir="C:\\Us\\Documents\\TLT\\I&S\\Historique\\"
    outputdir=ENVIRON["HOME"] "/Documents/TLT/I&S/Historique/" # emplacement relatif constant quelque soit le compte utilisateur
   hzero="00 00 00"
    
}
BEGINFILE {
    delete aligne # raz de l'array restituant les lignes du fichier
    typefich="undef"
    champdate=0
    outputfile=""
    # datemin=2^55
    datemin=strftime(systime()) # dans les données concernées, aucune raison d'avoir une date postérieure à la date du jour
    datemax=0
 }
{ #MAIN
    aligne[FNR]=$0
    if (FNR==1) { # la détermination du type de fichier se fait en testant la 1° ligne uniquement
        switch (NF) {
            case 22 : # fichier des produits expédiés (jusqu'à Pays de destination inclus)
                typefich="out"
                champdate=8
                break
            case 19 : # fichier des produits expédiés ancienne structure (jusqu'à Tagis inclus)
                typefich="out"
                champdate=8
                break
            case 10 : # fichier des produits reçus (jusqu'à NumTag inclus)
                typefich="in"
                champdate=4
                break
            default : #indéterminé, on ne fait rien
                print FILENAME " n'est pas un export I&S des produits expédiés ou reçus"
                exit NF
        }
    } else { #run
        split($champdate,adateevent,/\/|\:| /) # extrait les éléments de date/heure en tenant compte du fait qu'on a deux types de séparateurs différents pour la date et l'heure plus un autre entre la date et l'heure
        datestring=adateevent[3] " " adateevent[2] " " adateevent[1] " " adateevent[4] " " adateevent[5] " " adateevent[6] " " hzero " " hzero
        #deux fois hzero car 1°) ça ne gêne pas et 2°) dans un cas on peut avoir une date-heure et dans l'autre non donc il faut la rajouter 
        # print datestring
        # datenum=mktime(dateevent[3] space dateevent[2] space dateevent[1] space dateevent[4] space dateevent[5] space dateevent[6] space hzero space hzero) #deux fois hzero car 1°) ça ne gêne pas et 2°) dans un cas on peut avoir une date-heure et dans l'autre non donc il faut la rajouter 
        datenum=mktime(datestring) 
        if (datenum>0) { #sinon, erreur de date
            if (datenum>datemax) datemax=datenum
            if (datenum<datemin) datemin=datenum
        } # else print $champdate OFS datestring
        # print datenum
    }
    # if (datenum>systime()) { # pour debug uniquement
        # print
        # print NR OFS (strftime("%F",datemax)) OFS datestring OFS datenum
        # for (i=1;i<6;i++) print i OFS adateevent[i]
        # exit
    # }

}
ENDFILE {
    if (FNR>1) {
        # détermination de la fourchette de dates
        print "Date minimale " strftime("%F",datemin)
        print "Date maximale " strftime("%F",datemax)
        
        split(strftime("%F",datemin),adatemin,"-")
        split(strftime("%F",datemax),adatemax,"-")
        
        outputfile="is_" typefich "_"
        
        datemin=strftime("%F",datemin)
        datemax=strftime("%F",datemax)
        
        if (adatemin[1]==adatemax[1]) {
            outputfile=outputfile adatemin[1]
            if (adatemin[2]==adatemax[2]) {
                outputfile=outputfile adatemin[2]
                if (adatemin[3]==adatemax[3]) {
                    outputfile=outputfile adatemin[3]
                }
            }
        } else {
            outputfile=outputfile adatemin[1] adatemin[2] adatemin[3] "-" adatemax[1] adatemax[2] adatemax[3]
        }
        outputfile=outputdir outputfile ".csv"
        print "entrée vient de " FILENAME
        print "sortie vers " outputfile
        # commandline="mv -b -i -u " FILENAME " " outputfile
        # commandline="move " FILENAME " " outputfile
        # commandline="move /?" 
        # print commandline
        # system(commandline)

        for (i=1; i<=FNR; i++) {
            print aligne[i] > outputfile
        }
    }
}