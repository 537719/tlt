#TrafficIS.awk
# 21/02/2018 - 15:39:52
# Mesure l'activité I&S sur une période donnée
# Selon que le fichier fourni soit un export des produits expédiés ou réceptionnés :
#   détermine le nombre de produits neufs/reconitionnés concernés, par BU et par famille
#   les familles étant :
#       uc buro/métier
#       pc portables
#       imprimantes métier thermiques
#       imprimantes métier autres
#       écrans
#       imprimantes shipping
#       serveurs
#       autre matériel sérialisé
#       matériel non sérialisé

# travaille d'après ExportIS.awk du 26/01/2018 13:38


BEGIN {
    FS=";"
    OFS=FS
    # outputdir="C:\\Us\\Documents\\TLT\\I&S\\Historique\\"
    # outputdir=ENVIRON["HOME"] "/Documents/TLT/I&S/Historique/" # emplacement relatif constant quelque soit le compte utilisateur
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
                
                reference=$6
                tagis=$19
                numserie=$11
                stock=$10
                
                prior=$2
                codep=$16
                break
            case 19 : # fichier des produits expédiés ancienne structure (jusqu'à Tagis inclus)
                typefich="out"
                champdate=8
                
                reference=$6
                tagis=$19
                numserie=$11
                stock=$10
                
                prior=$2
                codep=$16
                break
            case 10 : # fichier des produits reçus (jusqu'à NumTag inclus)
                typefich="in"
                champdate=4
                
                reference=$2
                tagis=$9
                numserie=$3
                stock=$1
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
        
        #exploitation de la référence
        splitref=gensub(/^(...)(..)(.)(.)(...)$/,"\\1 \\2 \\3 \\4 \\5","1",reference)
        split(splitref,arref," ")
        bu=arref[1]) # 3 caractères, code de la BU
        switch(bu) { #traitement des cas particuliers où la référence n'est pas suffisante (divers, génériques, etc)
            case /CHR|CLP|TLT/ :
            {
                break
            }
            
            default :
            {
                switch(stock) {
                    case /CHR/ :
                    {
                        bu="CHR"
                        break
                    }
                    
                    case /COL/ :
                    {
                        bu="CLP"
                        break
                    }
                    
                    default :
                    {
                        bu="TLT"
                    }
                }
            }
        }
        
        famille=arref[2] # 2 chiffres, famille et sous-famille de produit
        stock=arref[4]) # F fil de l'eau, P projet, S shipping
        switch(famille) { # documentation du champ "famille" en fonction de sa valeur
            case /10/ :
            {
                famille="UC"
                break
            }
            
            case /11/ :
            {
                famille="Portable"
                break
            }
            
            case /2./:
            {
                famille="Ecran"
                break
            }
            
            case /34/:
            {
                if (stock ~ /S/) {
                    famille="Imp Ship"
                } else {
                    famille="Imp Met"
                }
                break
            }
            
            case /3[1-3]/:
            {
                famille="Imprimante"
                break
            }
            
            case /48/:
            {
                famille="Serveur"
                break
            }
            
            default :
            {
                if (sn ~ /./) {
                    famille="Serialise"
                } else {
                    famille="Divers"
                }
            }
        }
        
        etat=arref[3])# N neuf, R reconditionné
        produit=arref[5]) # 3 caractères spécifiant le produit en particulier
        
        
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