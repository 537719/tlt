# typesortie.awk
# 10:27 vendredi 29 novembre 2019 donne le tag et le type de sortie de chaque ligne d'un export des produits expédiés par I&S

    @include "typesortieinclude.awk"

    BEGIN {
    OFS=";"
    FS=";"
}

{ #main
    print $19 OFS typesortie($1,$2,$3,$6,$16)
}