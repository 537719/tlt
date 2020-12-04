# TXT2CSV.awk
# CREATION  10:02 23/10/2020 Crée à partir d'un fichier descrpitif de stat I&S "flux/stock" un fichier CSV apte à être traité par CSV2XML.awk
#           fonctionne sur tous les .txt du répertoire courant en excluant ceux dont le nom n'est pas en majuscules
#
# ENTREE    La structure des fichiers à traiter est la suivante :
#           1° ligne : titre
#           2° ligne : vide
#           Tout le reste : texte libre
# SORTIE    Un fichier CSV dont les champs seront :
#           <datestat>  la date de stat à laquelle rattacher les infos
#           <produit>   le code du produit sur lequel porte les infos
#           <Description>     le titre du fichier
#           <info>      le texte libre
#
# INVOCATION par gawk -v datestat="%moisfin% -f TXT2CSV.awk *.txt >> SFPlog.csv
# %moisfin% étant un paramètre défini dans la chaîne de scripts appelant celui-ci

BEGIN {
    OFS=";"
    IGNORECASE=0
    if (datestat == "") {
        datestat=strftime("%Y-%m-%d",systime())
    }
    # la ligne suivante ne sert que si l'on recrée le fichier de destination au lieu de l'incrémenter
    # print "DateStat", "Produit","Description","Info"
}

BEGINFILE {
    produit=gensub(/\..*$/,"",1,FILENAME)
    sortie=datestat OFS produit
    if (produit ~ /[a-z]/) produit=""
}

produit !~ /./ {next} # Les fichiers à traiter doivent avoir un nom en majuscule
# On travaille sur la variable utilisateur et non sur la variable système car les noms de fichiers étant case insensitive sous windows, le test ne fonctionne pas

FNR == 1 {    # Extraction de la ligne de titre
    gsub(/^[^0-Z]*/,"") # Elimination d'éventuels caractères non imprimables en tête de fichier
    sortie=sortie OFS $0 OFS 
}
FNR != 1 && $0 {    # Extraction des lignes de texte non vides
    sortie=sortie $0 " "
}

ENDFILE {
    if (produit) print sortie
}
