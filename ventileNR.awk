# ventileNR.awk
# d'après du 14:55 vendredi 13 septembre 2019 
#
# produit le nombre d'articles de chaque famille sortis en neuf/reconditionnés ventilés par stock et excluant les articles ne vivant qu'en neuf
# Les articles ne vivant qu'en neuf sont ceux dont le code "famille" ne se termine pas par 9 ou commence par un nombre de 1 à 4
# Le code "famille" est constitué d'un chiffre et un caractère (chiffre ou lettre) situé après le code spécifiant la BU dans la référence (soit les 4° et 5° caractères)
#
# Les "familles" en sorties sont légèrement différente de celles spécifiées dans la référence
# 10 UC
# 11  Portables
# 1[autres] Autres ordinateurs => Divers
# 2. Écrans
# 3[0-3] Imprimantes bureautique
# 34 Imprimantes thermiques (particularité : ne prendre en compte que le shipping (7° caractère de la référence = "S") car dans les autres cas ça ne vit qu'en neuf
# Dans une première version, on ne sépare pas bureautique et thermique en shipping et on voit si le résultat est accepté
# la règle devient alors :
# 3. Imprimante
# 4[^8] Équipement réseau => Divers
# 48 Serveurs

#   Création 16/09/2019  11:53
#   Modif 11:44 mardi 17 septembre 2019 agrège tous les produits "shipping" comme étant une seule famille
#   Modif 14:20 mardi 24 septembre 2019 remplace le nom de famille "PC Fixe" par "UC Fixe" pour des raisons d'ordre de tri
#   Modif 16:35 vendredi 8 janvier 2021 programme rendu obsolète par le portage de la stat sous sqlite


BEGIN {
    {
        print "Script " PROCINFO["argv"][2] " obsolete, ne plus utiliser, voir code source"
        exit 1
    }
    FS=";"
    OFS=";"
    champdate=0 # dans le cas où on ne sait pas du tout où se trouve le premier champ de date
    champdate=8 # dans le cas présent on sait que la date de livraison est dans le 8° champ

    deltaj=183*24*60*60 # valeur de 183 jours en terme de mktime
    datemin=mktime("2038 01 19 03 14 07")
    datemax=0
    # VR=0 # pour débuggage seulement
    
    # Initialisation de la table des familles
    Tfam[10]="PC fixe"
    Tfam[11]="Portable"
    Tfam[2]="Ecran"
    Tfam[3]="Imprimante"
    Tfam[34]="Shipping"
    Tfam[48]="Serveur"
    Tfam[99]="Divers"
    
    # Initialisation de la table des états
    Tetat["N"]="Neuf"
    Tetat["R"]="Recond"
}

@include "typesortieinclude.awk"

$1 !~ /^[0-9]{10}$/ {next} # rien à faire si pas de dossier glpi valide
$6 !~ /^CHR[1-4][0-8][N|R][F|P|S][0-Z]{3}$/ {next} # rien à faire si pas de référence Chronopost valide ET ne correspondant pas à un produit qui ne sort qu'en neuf
# Les deux lignes précédentes réduisent le volume à traiter d'environ de moitié
$6 ~ /^CHR34[N|R][F|P][0-Z]{3}$/ {next} #les imprimantes thermiques "non métier" ne sont censées sortir qu'en neuf.

# $19 !~ /TE19070/ {next} # on teste sur un range réduit d'enregistrements

{ #MAIN
    if (typesortie(1,$2,$3,$6,$16)~/RMA|DEL/) {next}     # Exclusion des cas de RMA et destruction
    
    # if (champdate == 0) {
        # for (i=1;i<=NF;i++) {
            # if ($i ~ /^[0-3][0-9]\/[0-1][0-9]\/[0-9]{4}$/) { # recherche du premier champ contenant une date au format jj/mm/aaaa
                 # champdate=i
                # break
            # }
        # }
    # print NR OFS champdate
    # }
    if (champdate) { # attention, on ne peut pas faire un "else" sur le test précédent car il faut aussi traiter l'enregistrement où l'on définit le champ date en question
        # VR++ #Valid Record
        
        split($champdate,jjmmaaaa,"/")
        datespec=jjmmaaaa[3] " " jjmmaaaa[2] " " jjmmaaaa[1] " " "00" " " "00" " " "00"
        datenum=mktime(datespec)
        if (datenum > datemax) {
            datemax=datenum
        }
        
        # produit=substr($6,8,3) # ne sert pas ici
        famille = substr($6,4,2)
        etat = substr($6,6,1)        # ^^ N(euf) ou (R)econditionné
       # print NR OFS $champdate OFS strftime("%F",datenum-deltaj) OFS strftime("%F",datenum) OFS datespec OFS famille OFS etat OFS $6
        switch(famille) { # réduction du code "famillle" aux seuls cas désirés
            case /1[0-1]/ :
            {
                if ($10 ~ /SHIP/) { # agrège les UC Chronoship à la famille shipping
                    famille=34
                }
                break
            }
           case /2./ :
            {
                famille=2
                break
            }
           case /34/ : # les seules imprimantes thermiques restant vues sont celles du shipping
            {
                break
            }
           case /3./ :
            {
                famille=3
                break
            }
           case /48/ :
            {
               break
            }
            default :
            {
                famille=99
            }
        }
        
        # lib=$7
        
        tag=$19 # identifiant unique de la ligne de sortie de stock, permet d'éviter de compter 2 fois un même déstockage si plusieurs fichiers contenant des doublons sont fournis dans le flot d'entrée
        stock=$10 # chaine relativement longue et appartenant à un ensemble réduit, il est bien plus économe de la piocher dans une table que de la stocker telle quelle
        
        # vérification de la connaissance du nom de stock dans la table des noms de stock, et création le cas échéant
        if (IXstock[stock]=="") {
            IXstock[stock]=NR # valeur arbitraire quelconque dont on sait qu'elle n'entre pas en conflit avec un autre enregistrement
        }
        # print  NR OFS IXstock[stock] OFS VR
        
        RECstock[tag]=IXstock[stock]
        # RECprod[tag]=produit
        RECfam[tag]=famille
        RECdate[tag]=datenum
        RECetat[tag] = etat
        # print RECetat[tag] OFS tag
        # REClib[tag]=lib
        # RECref[tag]=$6 # pour contrôle
        
        # print tag OFS produit OFS strftime("%F",datenum) OFS IXstock[stock]
    }
}

END {
    # Inverse la table des noms de stocks
    for (i in IXstock) {TABstock[IXstock[i]]=i}
    
    # Affiche les résultats
    # if (FILENAME=="") FILENAME="le flot d'entrée"
    # print VR "/" NR " enregistrements vus dans " FILENAME
    # print "fourchette de 6 mois entre " strftime("%F",datemax-deltaj) " et " strftime("%F",datemax)
    # print "TAGis" OFS "Famille" OFS "Produit" OFS "Annee" OFS "Mois" OFS "Jour" OFS "Stock" OFS "Désignation"
    # ne pas imprimer la ligne d'en-tête car la BDD de destination étant prédéfinie on aboutirait à créer un enregistrement parasite

    for (i in RECdate) {
        print i OFS Tfam[RECfam[i]] OFS Tetat[RECetat[i]] OFS  strftime("%Y",RECdate[i]) OFS strftime("%m",RECdate[i]) OFS strftime("%d",RECdate[i]) OFS TABstock[RECstock[i]]
    }
    # for (i in IXstock) {print i OFS IXstock[i]}
    # for (i in TABstock) {print i OFS TABstock[i]}
}