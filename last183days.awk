# last183days.awk
# reconnait le premier champ date dans un flot d'entr‚e, m‚morise la date la plus r‚cente, calcule la date ant‚rieure de 6 mois et considŠre comme … traiter toutes les donn‚es entre ces deux dates
# DEBUT 23/07/2019  15:14               219 création last183days.awk
# ETAT au 15:58 23/07/2019              isole  le premier champ de date dans le flot d'entrée et s'en sert pour en retenir la date la plus récente et calculer la date 5 mois antérieure
# BUG 11:37 vendredi 13 septembre 2019 remplace par un espace l'OFS précédement utilisé pour séparer la date, vu que c'étaiit un ; ça ne pouvait pas marcher
# MODIF 11:39 vendredi 13 septembre 2019 rajoute la "famille" de produit (c'est à dire les 2 caractères, habituellement numériques, situés juste après les 3 caractères (lettres) indiquant la BU dans l'écriture de la référence
# MODIF 11:47 vendredi 13 septembre 2019 rajoute une ligne d'en-tête dans le flot de sortie - supprimé le 14:58 13/09/2019
# MODIF 14:55 vendredi 13 septembre 2019 rajoute la désignation de l'article

BEGIN {
    FS=";"
    OFS=";"
    champdate=0
    deltaj=183*24*60*60 # valeur de 183 jours en terme de mktime
    datemin=mktime("2038 01 19 03 14 07")
    datemax=0
    # VR=0 pour débuggage seulement
}

@include "typesortieinclude.awk"

$1 !~ /^[0-9]{10}$/ {next} # rien à faire si pas de dossier glpi valide
$6 !~ /^CHR[1-9][0-Z][N|R][F|P|S][0-Z]{3}$/ {next} # rien à faire si pas de référence Chronopost valide
# Les deux lignes précédentes réduisent le volume à traiter d'environ de moitié

{ #MAIN
    if (typesortie(1,$2,$3,$6,$16)~/RMA|DEL/) {next}     # Exclusion des cas de RMA et destruction
    
    if (champdate==0) {
        for (i=1;i<=NF;i++) {
            if ($i ~ /^[0-3][0-9]\/[0-1][0-9]\/[0-9]{4}$/) { # recherche du premier champ contenant une date au format jj/mm/aaaa
                 champdate=i
                break
            }
        }
    # print NR OFS champdate
    }
    if (champdate) { # attention, on ne peut pas faire un "else" sur le test précédent car il faut aussi traiter l'enregistrement où l'on définit le champ date en question
        # VR++ #Valid Record
        split($champdate,jjmmaaaa,"/")
        datespec=jjmmaaaa[3] " " jjmmaaaa[2] " " jjmmaaaa[1] " " "00" " " "00" " " "00"
        datenum=mktime(datespec)
       # print NR OFS $champdate OFS strftime("%F",datenum-deltaj) OFS strftime("%F",datenum) OFS datespec
        if (datenum > datemax) {
            datemax=datenum
        }
        
        produit=substr($6,8,3)
        famille=substr($6,4,2)
        lib=$7
        
        tag=$19 # identifiant unique de la ligne de sortie de stock, permet d'éviter de compter 2 fois un même déstockage si plusieurs fichiers contenant des doublons sont fournis dans le flot d'entrée
        stock=$10 # chaine relativement longue et appartenant à un semble réduit, il est bien plus économe de la piocher dans une table que de la stocker telle quelle
        
        # vérification de la connaissance du nom de stock dans la table des noms de stock, et création le cas échéant
        if (IXstock[stock]=="") {
            IXstock[stock]=NR # valeur arbitraire quelconque dont on sait qu'elle n'entre pas en conflit avec un autre enregistrement
        }
        # print  NR OFS IXstock[stock] OFS VR
        
        RECstock[tag]=IXstock[stock]
        RECprod[tag]=produit
        RECdate[tag]=datenum
        REClib[tag]=lib
        
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
        print i OFS famille OFS RECprod[i] OFS strftime("%Y",RECdate[i]) OFS strftime("%m",RECdate[i]) OFS strftime("%d",RECdate[i]) OFS TABstock[RECstock[i]] OFS REClib[i]
    }
    # for (i in IXstock) {print i OFS IXstock[i]}
    # for (i in TABstock) {print i OFS TABstock[i]}
}