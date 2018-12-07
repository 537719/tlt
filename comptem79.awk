# comptem79.awk
# CREE  28/11/2018 11:25  - Compte le nombre d'UC de type "M79" dans un flot d'entrée constituée de l'export CSV des produits expédiés par I&StringAdvFunctions
#                           ventile le nombre d'appareils sortis en prod et le nombre d'appareils sortis pour destruction
#                           en dédoublonnant les appareils sortis plusieurs fois et en considérant que toute sortie pour destruction est définitive.
# MODIF 11/28/2018 14:52:18 matériel ausculpté ajustable en modfiant l'expression régulière

@include "..\bin\StringAdvFunctions.awk"
BEGIN {
    FS=";"
}
$6 ~ /CHR10..1A[R-S]/ {
    sn=rightstr($11,8)
    champ2_3=$2 $3
    switch (champ2_3) {
        case /^P5/ : {
            statut[sn]="del"
            break
        }
        case /PAL|DESTR/ : {
            statut[sn]="del"
            break
        }
        default :
            if (statut[sn] != "del") {
                statut[sn]="parc"
            }
    }
}
# {
    # print $6
# }
END {
    for (i in statut) {
        switch(statut[i]) {
            case /del/ : {
                detruits++
                break
            }
            case /parc/ : {
                enparc++
            }
        }
    }
    print 0+enparc " en parc"
    print 0+detruits " detruits"
}
