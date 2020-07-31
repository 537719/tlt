# typeentree.awk
# 14:45 mercredi 4 d‚cembre 2019 donne le tag et le type de sortie de chaque ligne d'un export des produits exp‚di‚s par I&S
# MODIF 10:11 15/02/2020 rajoute l'affichage de la date. En effet, un mˆme tag peut subir plusieurs entr‚es avec des types diff‚rents
# MODIF 16:00 26/02/2020 convertit la date au format sql
# MODIF 16:01 26/02/2020 ne traite que s'il y a un tagis

    @include "typeentreeinclude.awk"

BEGIN {
    OFS=";"
    FS=";"
}

$9 ~ /./ { #sans objet s'il n'y a pas de tagis
    if ($4  !~ ":") $4=$4 " 00:00:00"
    print $9 OFS typeentree($2,$5,$6,$9,$4) OFS substr($4,7,4) "-" substr($4,4,2) "-" substr($4,1,2) " "   substr($4,12)
}