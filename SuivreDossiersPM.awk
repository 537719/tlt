# SuivreDossiersPM.awk
# CREATION  12:44 07/10/2020 d'après TraduitDossiersPM.awk du 07/10/2020
# FONCTION  depuis la même source de données, extrait la correspondance entre le code de chaque site et le numéro de dossier qui lui est affecté

# PREREQUIS Présence du fichier Planning_PM-IDF.tsv (export de google sheet avec séparateur tabulation)ou similaire comportant les informations suivantes, dans n'importe quel ordre, le nom des champs étant défini dans la première ligne :
#
# ETABLISSEMENT	(inutile)
# REGATE	(inutile)
# CodeColissimo (libellé en Code Colissimo)	(obligatoire)
# SITE	(inutile) (contient parfois plusieurs mentions inutiles après plusieurs espaces de sépareation)
# ADRESSE	(inutile) (repérer le codepostal/ville)
# NOM	(inutile) (attention si vide)
# Date de migration	(inutile) Date de déploiement prévu, le poste doit être sur place à J-1
# $7 PM1 + @IP	(inutile) Nom du 1° poste calculé d'après le code regate
# $8 PM2 + @IP	(inutile) Nom du 2° poste calculé d'après le code regate
# Dossier GLPI de déploiement (comme son nom l'indique) (obligatoire)
# Les éventuels champs supplémentaires ne sont pas nécessaires

# Règle pour les champs vides : On saute sans déclarer d'erreur et on ne produit rien en sortie

BEGIN {
    FS="\t"
    OFS=";"
    IGNORECASE=1    # Afin de ne pas être soumis à un aléa de casse dans la lecture des en-têtes de colonnes
    
    f_CodeColissimo=0
    f_dossier=0
    
    erreur=""
}

$0 !~ /[0-z]/ {
# print "ligne vide " NR
    CodeColissimo=""
    dossier=""
    
    next
}

NR==1 { # scanne les en-têtes de colonnes afin de déterminer quelle valeur est dans quel champ
    for (i=1;i<=NF;i++) {
        if ($i ~ /Code.*Colissimo/) {f_CodeColissimo=i}
        if ($i ~ /dossier/) {f_dossier=i}
    }
    if (f_CodeColissimo==0) {
        erreur="Code Colissimo" 
    }
    if (f_dossier==0) {
        erreur="Numéro de dossier" 
    }
    if (erreur ~ /./) {
        print "champ de " erreur " manquant"
        exit NR
    }
    next
}

$f_CodeColissimo !~ /[0-9]{6}/ {
    # print "@" $0 "@"
    # print "Code Colissimo " $f_CodeColissimo " invalide en ligne " NR
    next
}
$f_dossier !~ /[0-9]{10}/ {
    # print "@" $0 "@"
    # print "Numéro de dossier " $f_dossier " invalide en ligne " NR
    next
}


{ # MAIN
    CodeColissimo= $f_CodeColissimo
    dossier=$f_dossier
    
    # Impression des résultats
    sortie=""
    sortie=CodeColissimo OFS "PMCOLLX" OFS dossier
    print sortie

}