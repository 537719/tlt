# outsql.awk
# convertit en csv la sortie d'un query mysql
#
# CREE  18/07/2018 - 10:39:09 - d�but d'�criture
# MODIF 24/10/2018 - 16:42:56 r��criture compl�te pour tenir compte des champs contenant des sauts de lignes

BEGIN {
    FS="|"
    OFS=";"
    vide=""
    repl="\\1"
    dblqt="\"" #" double quote en commentaire pour que la coloration syntaxique retombe sur ses pieds
    OFS=dblqt ";" dblqt
    dblblqt=dblqt dblqt
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

/^[+|-]+$/ { # le fichier est un tableau texte, pr�fix� et termin� par une ligne constitu�e de + et de - ; la ligne d'en-t�te de colonnes est pr�c�d�e et suivie d'une telle ligne, une autre de ces lignes marque la fin du tableau
    if (NR >3) {exit} # d�tection de la fin de tableau
    next
}
{ # main
    gsub(/\"/,dblblqt)    # prot�ge les doubles quotes d�j� existantes
    sub(/^\| /,dblqt)    # d�but d'enregistrement
    sub(/ *\|$/,dblqt)    # fin d'enregistrement
    gsub(/ *\| /, OFS)    # s�parateur de champ
    print
}