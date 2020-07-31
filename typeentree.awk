# typeentree.awk
# 14:45 mercredi 4 d‚cembre 2019 donne le tag et le type de sortie de chaque ligne d'un export des produits exp‚di‚s par I&S

    @include "typeentreeinclude.awk"

    BEGIN {
    OFS=";"
    FS=";"
}

{ #main
    print $9 OFS typeentree($2,$5,$6,$9,$4)
}