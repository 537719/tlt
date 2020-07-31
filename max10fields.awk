# max10fields.awk
# concatène au 9° champ tous les champs qui vont du 10° à l'avant dernier (le dernier étant le 10°, et à sa place)
# pour réparer un problème de champs contenant des point-virgule

BEGIN {
    FS=";"
    OFS=FS
}

NF == 10 { print}

NF > 10 {
    ligne=$1
    for (i=2;i<=9;i++) {
        ligne=ligne OFS $i
    }
    for (i=10;i<NF;i++) {
        ligne=ligne "," $i
    }
    ligne=ligne OFS $NF
    print ligne
}