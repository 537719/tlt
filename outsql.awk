# outsql.awk
# convertit en csv la sortie d'un query mysql
#
# CREE  18/07/2018 - 10:39:09 - d�but d'�criture
# MODIF 24/10/2018 - 16:42:56 r��criture compl�te pour tenir compte des champs contenant des sauts de lignes
# MODIF 10:57 06/02/2019    Rajoute une v�rification pour ne pas �tre perturb� par d'�ventuelles lignes d'erreurs avant l'en-t�te du tableau de donn�es

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

/^[+|-]+$/ { # le fichier est un tableau texte, pr�fix� et termin� par une ligne constitu�e de + et de - ; la ligne d'en-t�te de colonnes est pr�c�d�e et suivie d'une telle ligne, une autre de ces lignes marque la fin du tableau
    if (offset==0) offset=NR
    if (NR >offset+2) {exit} # d�tection de la fin de tableau
    # print NR OFS "separateur"
    next
}
{ # main
    if (offset) {
        gsub(/\"/,dblblqt)    # prot�ge les doubles quotes d�j� existantes - cette double"quote n'est la que pour le colorateur syntaxique retombe sur ses pattes
        sub(/^\| /,dblqt)    # d�but d'enregistrement
        sub(/ *\|$/,dblqt)    # fin d'enregistrement
        gsub(/ *\| /, OFS)    # s�parateur de champ
        print
    }
}