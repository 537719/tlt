# outsql.awk
# convertit en csv la sortie d'un query mysql
#
# CREE  18/07/2018 - 10:39:09 - d‚but d'‚criture
# MODIF 24/10/2018 - 16:42:56 réécriture complète pour tenir compte des champs contenant des sauts de lignes
# MODIF 10:57 06/02/2019    Rajoute une vérification pour ne pas être perturbé par d'éventuelles lignes d'erreurs avant l'en-tête du tableau de données

BEGIN {
    FS="|"
    # OFS=";"
    vide=""
    repl="\\1"
    dblqt="\"" #" double quote en commentaire pour que la coloration syntaxique retombe sur ses pieds
    OFS=dblqt ";" dblqt
    dblblqt=dblqt dblqt
    
    offset=0
}
# NF>1 { #MAIN - structure du 18/07/2018 - 10:39:09
    # ligne=vide
    # for (i=2;i<NF;i++) {
#        texte=gensub(/^ *(.*)[ |\t]*$/,repl,1,$i)
        # texte=dblqt $i dblqt
        # gsub(/ *$/,vide,texte)
        # gsub(/^ */,vide,texte)
        # ligne=ligne texte 
        # if (i+1<NF) ligne=ligne OFS
    # } 
    # print ligne
# }

/^[+|-]+$/ { # le fichier est un tableau texte, préfixé et terminé par une ligne constituée de + et de - ; la ligne d'en-tête de colonnes est précédée et suivie d'une telle ligne, une autre de ces lignes marque la fin du tableau
    if (offset==0) offset=NR
    if (NR >offset+2) {exit} # détection de la fin de tableau
    # print NR OFS "separateur"
    next
}
{ # main
    if (offset) {
        gsub(/\"/,dblblqt)    # protège les doubles quotes déjà existantes - cette double"quote n'est la que pour le colorateur syntaxique retombe sur ses pattes
        sub(/^\| /,dblqt)    # début d'enregistrement
        sub(/ *\|$/,dblqt)    # fin d'enregistrement
        gsub(/ *\| /, OFS)    # séparateur de champ
        print
    }
}