# completecsv.awk
# CREATION 18:43 11/12/2020 rajoute des champs vides aux lignes qui en ont moins que la 1° ligne du fichier
# USAGE    pour corriger certains OFLX dont certaines lignes ont un enregistrement de moins
BEGIN {
FS=";"
nbchamps=0
}
NR==1 { # définit le nombre de champs que le fichier est censé avoir
    nbchamps=NF
} 
NR>1 { # vérifie tous les enregistrements suivants
    for (i=NF+1;i<=nbchamps;i++) { # on n'exécute que s'il y a moins de champs que calculé du début
        $0 = $0 FS # rajoute un champ
    }
} 
{print} # dans tous les cas imprime la ligne, soit d'origine, soit enrichie d'un champ

