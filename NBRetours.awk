# NBRetours.awk
# CREATION   6:21 vendredi 27 septembre 201
#                   D'après un flot d'entrées en stock I&S
#                   Calcule, pour CHR uniquement, combien d'articles de chaque famille sont entrés en stock
#                   A l'exception du neuf et des retours de RMA
#                   Les familles étant : Ecran, Imprimante, PC Fuxe, Portable, Serveur, Shipping et Divers
#
# La structure du fichier d'entrée est la suivante
# 1 Projet  => indique si le matériel appartient à CHR ou pas
# 2 Reference => Si correspond à une ref normalisée, contient l'indication de Reconditionné et de famille
# 3 Numero Serie => inutilisé ici
# 4 DateEntree => plusieurs formats possibles
# 5 APT => Vide ou commence par IS = retour, commence par ES = Appro = neiuf ou retour de RMA
# 6 RefAppro
# 7 BonTransport
# 8 Libell□
# 9 TagIS => Clé unique pour chauque entrée de matériel donné
# 10 NumTag

# Un même TAGIS peut appaître plusieurs fois en entrée si le matériel a fait l'objet d'une opération entre temps (audit ou préparation)
# La règle va donc être de conserver la date la plus ancienne associée à un tag et l'appairer à la réf la plus récente associée à ce tag
# en effet, l'audit ou la préparation peuvent aboutir à un changement de référence.

BEGIN {
    FS=";"
    OFS=";"
    
}

$1~ /^Projet$/ {next} # on saute la ligne de description des champs
$9 !~ /./ {next} # présence d'un tag IS obligatoire pour procéder
$1 ~ /COLI/ {next} # On ne prend pas en compte le matériel Colissimo 
$5 ~ /^ES[0-9]*$/  {next} # On ne prend pas en compte les entrées autres que retour de stock
$6 ~/^[0-9]{7,11} - /  {next} # réception sur numéro de commande mais sans numéro d'apt

{ #MAIN
    ref=$2
    tag=$9
    dentree=$4


    delete Tdate
    delete Tjour
    delete Theure
    sdate=""
    
    j=split(dentree,Tdate," ")
    if (j>1)         split(Tdate[2],Theure,":")
    if (j>0)         d=split(Tdate[1],Tjour,"/")
    
    Sdate= Tjour[3]  " "  Tjour[2]  " " Tjour[1] " " Theure[1] " " Theure[2] " " Theure[3]  " 00 00 00 00 00 00"
    
    Ndate=mktime(Sdate)
    
    if (tag in Aref) {
        if (Ndate >= Adate[tag]) {
            Aref[tag]=ref
        }
    } else {
        Aref[tag]=ref
        Adate[tag]=Ndate
    }
    # if ($9 ~ /TE1907020034/) {
        # print tag OFS $4 OFS Sdate OFS Ntime OFS Adate[tag]
        
    # }
}

END {
    for (i in Aref) {
        split(Aref[i],Tref," ")
    # print i OFS Tref[1]
        switch(Tref[1]) {
            case /CHR10.[F|P]|UC/ :
                {
                    famille="PC Fixe"
                    break
                }
            case /CHR11|PORT/ :
                {
                    famille="Portable"
                    break
                }
            case /CHR2|ECR/ :
                {
                    famille="Ecran"
                    break
                }

            case /CHR...S/ :
                {
                    famille="Chronoship"
                    break
                }
            case /CHR3|IMPR/ :
                {
                    famille="Imprimante"
                    break
                }
            case /CHR48|SERV/ :
                {
                    famille="Serveur"
                     break
               }
               default :
               {
                    famille="Divers"
                }

        }
        print i OFS strftime("%Y;%m;%d",Adate[i]) OFS famille
    }
}