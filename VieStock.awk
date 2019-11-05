# VieStock.awk
# calcul du temps que chaque produit déstocké par I&S aura passé en stock
#   Pour chaque article non COL déstocké sur dossier valide et hors destruction ou rma
#   Calculer le nombre de jours entre la date de déstockage (à défaut la date de demande de déstockage) avec la date d'entrée en stock
#   produire : état neuf/recond, code produit (3 derniers caractères de la référence), désignation, nb de jours de stockage.

# CREE   01/10/2019  14:26
# OK       01/10/2019  16:31
# MODIF  02/10/2019  09:53 ajoute en première colonne le log décimal de la durée calculée

# Champs du fichier d'entrée
# 1 GLPI
# 2 Priorit□
# 3 Provenance
# 4 DateCr□ation
# 5 CentreCout
# 6 Reference
# 7 Description
# 8 Date BL
# 9 D□pot
# 10 sDepot
# 11 Num Serie
# 12 Nom Client L
# 13 Adr1 L
# 14 Adr2 L
# 15 Adr3 L
# 16 CP L
# 17 Dep
# 18 Ville L
# 19 Tagis
# 20 Societe L
# 21 NumeroOfl
# 22  Pays de destination


BEGIN {
    FS=";"
    OFS=";"
    nbsecjour=24*60*60
    LN10=log(10)
    # maxi=0
    # mini=mktime("2038 01 19 03 14 07")
}

@include "typesortieinclude.awk"

$1 !~ /^[0-9]{10}$/ {next} # rien à faire si pas de dossier glpi valide
$9 ~ /COLI/ {next} # rien à faire si Colissimo

{ #MAIN
    if (typesortie(1,$2,$3,$6,$16)~/RMA|DEL/) {next}     # Exclusion des cas de RMA et destruction
    
    ref=$6
    lib=$7
    datesortie=$8
    tagis=$19
    
    # contrôle d'existence de la date de sortie (peut être exceptionnellement vide)
    if (datesortie + 0 == 0) datesortie = $4
    
    if (datesortie) {
        split(datesortie,jjmmaaaa,"/")
        datespec=jjmmaaaa[3] " " jjmmaaaa[2] " " jjmmaaaa[1] " " "00" " " "00" " " "00"
        # print datespec
        datenumsortie=mktime(datespec)
        
        if (length(tagis)==12) {
            datespec="20" substr(tagis,3,2) " " substr(tagis,5,2)  " " substr(tagis,7,2)  " " "00" " " "00" " " "00"
        } else {
            datespec=substr(tagis,3,2) " " substr(tagis,5,2)  " " substr(tagis,7,2)  " " "00" " " "00" " " "00"
        }
        # print datespec
        datenumentree=mktime(datespec)
    
         duree=datenumsortie-datenumentree
         # if (duree>maxi) maxi=duree
         # if (duree<mini) mini=duree
         
         produit=substr(ref,8,3)
         etat=substr(ref,6,1)
         famille=substr(ref,4,2)

         
         output = OFS etat OFS produit OFS lib "\r\bn"
         printf "%2s", int(log(duree/nbsecjour)/LN10 + 0.5) OFS
         printf "%5s", int(duree/nbsecjour + 0.5) OFS
         # printf "%10s", duree
         print tagis OFS etat OFS famille OFS produit OFS lib  "\r"
    }
}

END {
    # print "maxi " int(maxi/nbsecjour + 0.5)
    # print "mini " int(mini/nbsecjour + 0.5)
}