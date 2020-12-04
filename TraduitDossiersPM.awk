# TraduitDossiersPM.awk
# CREATION  12:42 07/10/2020 d'après creedossiersPM.awk du 06/10/2020
# FONCTION  Traduit le tableau de planning fourni par Colissimo en données exploitables pour générer le dossier
# Réécriture du programme de manière à déterminer automatiquement l'affectation des champs, la structure du tableau fourni pouvant chan,g

# PREREQUIS Présence du fichier Planning_PM-IDF.tsv (export de google sheet avec séparateur tabulation)ou similaire comportant les informations suivantes, dans n'importe quel ordre, le nom des champs étant défini dans la première ligne :
#
# ETABLISSEMENT	(inutile)
# REGATE	(inutile)
# CodeColissimo (libellé en Code Colissimo)	(obligatoire)
# SITE	(obligatoire) (contient parfois plusieurs mentions inutiles après plusieurs espaces de sépareation)
# ADRESSE	(obligatoire) (repérer le codepostal/ville)
# NOM	(obligatoire) (attention si vide)
# Date de migration	(obligatoire) Date de déploiement prévu, le poste doit être sur place à J-1
# $7 PM1 + @IP	(inutile) Nom du 1° poste calculé d'après le code regate
# $8 PM2 + @IP	(inutile) Nom du 2° poste calculé d'après le code regate
# Les éventuels champs supplémentaires ne sont pas nécessaires

# Règle pour les champs vides :
# Prendre la valeur de l'enregistrement précédent s'il n'est pas vide
# Si l'enregistrement précédent est vide, mettre #MANQUANT#

BEGIN {
    FS="\t"
    OFS=";"
    IGNORECASE=1    # Afin de ne pas être soumis à un aléa de casse dans la lecture des en-têtes de colonnes
    
    f_CodeColissimo=0
    f_SITE=0
    f_ADRESSE=0
    f_NOM=0
    f_migration=0
    
    erreur=""
}

$0 !~ /[0-z]/ {
# print "ligne vide " NR
    CodeColissimo=""
    SITE=""
    ADRESSE="" ; CPV=""
    NOM=""
    migration=""
    
    next
}

NR==1 { # scanne les en-têtes de colonnes afin de déterminer quelle valeur est dans quel champ
    for (i=1;i<=NF;i++) {
        if ($i ~ /Code.*Colissimo/) {f_CodeColissimo=i}
        if ($i ~ /SITE/) {f_SITE=i}
        if ($i ~ /ADRESSE/) {f_ADRESSE=i}
        if ($i ~ /NOM/) {f_NOM=i}
        if ($i ~ /migration/) {f_migration=i}
    }
    if (f_CodeColissimo==0) {
        erreur="Code Colissimo" 
    }
    if (f_SITE==0) {
        erreur="SITE" 
    }
    if (f_ADRESSE==0) {
        erreur="ADRESSE" 
    }
    if (f_NOM==0) {
        erreur="NOM" 
    }
    if (f_migration==0) {
        erreur="migration" 
    }
    if (erreur ~ /./) {
        print "champ de " erreur " manquant"
        exit NR
    }
    next
}

$f_CodeColissimo !~ /[0-9]{6}/ {
    print "@" $0 "@"
    print "Code Colissimo " $f_CodeColissimo " invalide en ligne " NR
    exit NR
}
$f_SITE !~ /^[A-Z]/ {
    print "@" $0 "@"
    print "Site " $f_SITE " invalide en ligne " NR
    exit NR
}
$f_ADRESSE !~ /[A-z].*[0-9| ]{5,6} [A-z].*/ {
    print "Adresse " $f_ADRESSE " invalide en ligne " NR
    exit NR
}
$f_NOM !~ /[A-z].* [A-z].*/ && NOM !~ /./ {
    $f_NOM="#MANQUANT#"
    # print "Contact " $5 " invalide en ligne " NR
    # exit NR
}
# $6 !~ /[0-9]{4}-[0-1][0-9]-[0-3][0-9]/ {
    # print "Date " $6 " invalide en ligne " NR " elle doit etre au format AAAA-MM-JJ"
    # exit NR
# }


{ # MAIN
    CodeColissimo= $f_CodeColissimo
    SITE= gensub(/   .*$/,vide,1,$f_SITE) # Elimine les éventuelles précisions inutiles après le nom du site
    ADRESSE=gensub(/    */,"*","g",$f_ADRESSE)
    CPV=gensub(/^.* ([0-9| ]{5,6} [A-Z])/,"\\1",1,$f_ADRESSE)
    CPV=gensub(/^([0-9]+) *([0-9]+ [A-Z])/,"\\1" "\\2","g",CPV)
    ADRESSE=gensub(CPV,"",1,ADRESSE)
    ns=split(ADRESSE,ADR,"*")
    # if (ns>2) {ns=2}
    for (i in ADR) {if (ADR[i]==CPV) ADR[i]=""}
    
    if ($f_NOM) {   #Si $5 est vide on garde la valeur précédente
        NOM = $f_NOM
        if ($f_NOM !~ /./) {
            NOM = "#MANQUANT#"
        } else {
            NOM=gensub(/ +/," ","g",$f_NOM)
            NOM=gensub(/\(*Pi\)*$/,"",1,NOM)
        }
    }
    # reste à s'occuper des dates
    migration=$f_migration
    
    # Impression des résultats
    sortie=""
    for (i=1;i<=2;i++) {
        sortie=sortie ADR[i] OFS
    }
    sortie=CodeColissimo OFS SITE OFS sortie OFS CPV OFS NOM OFS migration
    print sortie

}