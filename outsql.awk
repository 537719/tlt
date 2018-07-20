# outsql.awk
# convertit en csv la sortie d'un query mysql
#
# 18/07/2018 - 10:39:09 - d‚but d'‚criture
#

BEGIN {
    FS="|"
    OFS=";"
    vide=""
    repl="\\1"
}
NF>1 { #MAIN
    ligne=vide
    for (i=2;i<NF;i++) {
        # texte=gensub(/^ *(.*)[ |\t]*$/,repl,1,$i)
        texte=$i
        gsub(/ *$/,vide,texte)
        gsub(/^ */,vide,texte)
        ligne=ligne texte 
        if (i+1<NF) ligne=ligne OFS
    } 
    print ligne
}