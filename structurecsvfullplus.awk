# structurecsvfullplus.awk
# d'après structurecsvfullp.awk du 10:27 15/02/2020 
# affiche le nom des champs composant le fichier csv passé en argumument, ainsi que leur longueur maximale et leur type
# réécriture plus lisible et prévoit de traiter plus de types (flottant, scientifique)
BEGIN {
    FS=";"
    # OFS="\t"
    OFS=";"
}


NR==1 {
    for (i=1;i<=NF;i++) {
        champ[i]=$i
        type[i]=""
        void[i]=0
        long[i]=0
    }
} 
NR>1 {
    for (i=1;i<=NF;i++) {
        currentfield=$i
        if (length(currentfield) > long[i]) long[i]=length(currentfield)
        if (currentfield !~ /./) {
                void[i]++
        } else {
            switch (currentfield) {
                case /[^\.]/ :
                {
                    void[i]++
                    break
                }
                # case /^ *[0-9]* *$/ :
                case /^[0-9]*$/ :
                {
                    type[i,NR]="int"
                   break
                }
                case /^ *[0-9]*\.*[0-9]* *$/ :
                {
                    type[i,NR]="float"
                     break
                }
                case /^ *[0-9]\.[0-9]+[e|E][+|-][0-9]+ *$/ :
                {
                    type[i,NR]="sci"
                    break
                }
                    case /[0-9]*[-|\/][0-9]*[-|\/][0-9]*/ :
                {
                    type[i,NR]="date"
    #                pas de break ici afin de traiter le cas du type "dateheure" en suivant
                }
                case /[0-9]*:[0-9]*/ :
                {
                    type[i,NR]=type[i,NR] "heure"
                    break
                }

                default :
                {
                    type[i,NR]="text"
                }
            }
        }
    }
}

END {
    print "No" OFS "Type" OFS "long" OFS "Vide" OFS "Champ"
    for (j=1;j<=NR;j++) {
        printf "%d" ,j 
        for (i in champ) {
            printf "%s" , "@" type[i,j]  "@"
            # void[i]=int(10000*(void[i]/(NR-1)))/100
            # print i OFS type[i] OFS long[i] OFS void[i] OFS champ[i]
            # printf "%4d %s %3d %3.2f\%  %s\r\n" i , type[i], long[i] , void[i] , champ[i]
        }
        printf "%s" , "\r\n"
    }
}