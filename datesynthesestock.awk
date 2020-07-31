# datesynthesestock.awk
# rajoute à un lot de fichiers quotidiens de synthèse des stocks la date concernée en dernière colonne
# en partant du principe que la date en question fait partie du nom de chacun des fichier
# CREATION  11:22 19/05/2020
# MODIF     10:29 20/05/2020 travaille sur un lot de fichiers et non sur un seul
#
BEGIN {
    FS=";"
    OFS=";"
}

BEGINFILE {
    datefich=gensub(/.*([0-9]{4})([0-9]{2})([0-9]{2}).*/,"\\1-\\2-\\3",1,FILENAME)
}

FNR==1 { # non-réécriture de l'en-tête
    if (NR != 1) next # on ne traite pas le 1° enregistrement du fichier, sauf s'il s'agit du 1° fichier
}
NF == 9 { # on ignore les enregistrements mal formés ou relevant d'un autre format de fichier
     print $0 OFS datefich
}
