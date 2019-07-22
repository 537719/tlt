# colonnesparan.awk
# CREE   15/02/2019  11:45 ventile une liste de dates aaaa-mm-jj sous forme de tableau ayant 1 colonne par an
# MODIF 11:11 21/02/2019 permet le paramétrage d'une sortie en csv ou en tableau html

# usage : en pipe après le résultat d'un
# dir ..\statsis\quipo\2* /ad /b /o-d

function inithtml() {
    tbl="<table border=0 cellpadding=0 cellspacing=0 align=\"center\"  width=\"100%\">"
    tblend="</table>"
    tr="<tr>"
    trend="</tr>"
    td="<td>"
    tdend="</d>"
    OFS=""
    return ""
}
function initvoid() {
    tblend=""
    tr=""
    trend=""
    td=""
    tdend=""
    OFS=";"
    return ";"
}

function supprdernierofs(chaine) {
    if (OFS) {
        chaine=substr(chaine,1,length(chaine)-1)
    }
    return chaine
}

BEGIN {
    FS="-"

    nblignes=0
    
    # OFS=inithtml()
    OFS=initvoid()
}

{   #MAIN
    an[$1]++
    colonne[$1,an[$1]]=$0
    
    if (an[$1] > nblignes) nblignes++
}

END {
    # for ( i in an) {
        # for (j=1;j<=an[i];j++) {
            # print i OFS an[i] OFS colonne[i,j]
        # }
    # }
    
    if (tbl) print tbl
    j=0
    for (i in an) {
        j++
        annee[j]=i
    }
    ligne=tr

    
    for (k=1;k<=j;k++) {
        ligne = ligne  td annee[k] tdend OFS
    }
    ligne=ligne trend
    print supprdernierofs(ligne)
    
     for (i=1;i<=nblignes;i++) {
        ligne=tr
        for (k=1;k<=j;k++) {
            valeur=td
            valeur=valeur colonne[annee[k],i]
            ligne = ligne  valeur tdend OFS
        }
        ligne = ligne trend
        print supprdernierofs(ligne)
    }
   if (tblend) print tablend
}