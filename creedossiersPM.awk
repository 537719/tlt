# creedossiersPM.awk
# CREATION  13:37 02/10/2020 Crée le texte de description pour la création des dossiers de déploiement des postes maîtres Linux pour Colissimo
# BUG       13:34 06/10/2020 Supprime les espaces muntiples à l'intérieur du nom du contact
# BUG       13:34 06/10/2020 Supprime l'éventuelle répétition du code postal+ville à l'intérieur de l'adresse

# PREREQUIS Présence du fichier Planning_PM-IDF.tsv ou similaire comportant les informations suivantes,dans cet ordre :
#
# $1 ETABLISSEMENT	(inutile)
# $2 REGATE	(oblitatoire)
# $3 SITE	(obligatoire) (contient parfois plusieurs mentions inutiles après plusieurs espaces de sépareation)
# $4 ADRESSE	(obligatoire) (repérer le codepostal/ville)
# $5 NOM	(obligatoire) (attention si vide)
# $6 Date de migration	(obligatoire) Date de déploiement prévu, le poste doit être sur place à J-1
# $7 PM1 + @IP	(inutile) Nom du 1° poste calculé d'après le code regate
# $8 PM2 + @IP	(inutile) Nom du 2° poste calculé d'après le code regate
# Les champs supplémentaires ne sont pas nécessaires

# Règle pour les champs vides :
# Prendre la valeur de l'enregistrement précédent s'il n'est pas vide
# Si l'enregistrement précédent est vide, mettre #MANQUANT#

BEGIN {
    FS="\t"
    OFS=";"
}

$0 !~ /[0-z]/ {
# print "ligne vide " NR
    ETABLISSEMENT=""
    REGATE=""
    SITE=""
    ADRESSE="" ; CPV=""
    NOM=""
    migration=""
    
    next
}

NR==1 {next}

$2 !~ /[0-9]{6}/ {
    print "@" $0 "@"
    print "Code regate " $2 " invalide en ligne " NR
    exit NR
}
$3 !~ /^[A-Z]/ {
    print "Site " $3 " invalide en ligne " NR
    exit NR
}
$4 !~ /[A-z].*[0-9]{5} [A-z].*/ {
    print "Adresse " $4 " invalide en ligne " NR
    exit NR
}
$5 !~ /[A-z].* [A-z].*/ && NOM !~ /./ {
    $5="#MANQUANT#"
    # print "Contact " $5 " invalide en ligne " NR
    # exit NR
}
# $6 !~ /[0-9]{4}-[0-1][0-9]-[0-3][0-9]/ {
    # print "Date " $6 " invalide en ligne " NR " elle doit etre au format AAAA-MM-JJ"
    # exit NR
# }


{ # MAIN
    REGATE= $2
    SITE= gensub(/   .*$/,vide,1,$3) # Elimine les éventuelles précisions inutiles après le nom du site
    ADRESSE=gensub(/    */,"*","g",$4)
    CPV=gensub(/^.* ([0-9]{5} [A-Z])/,"\\1",1,$4)
    ADRESSE=gensub(CPV,"",1,ADRESSE)
    ns=split(ADRESSE,ADR,"*")
    # if (ns>2) {ns=2}
    for (i in ADR) {if (ADR[i]==CPV) ADR[i]=""}
    
    if ($5) {   #Si $5 est vide on garde la valeur précédente
        NOM = $5
        if ($5 !~ /./) {
            NOM = "#MANQUANT#"
        } else {
            NOM=gensub(/ +/," ","g",$5)
        }
    }
    # reste à s'occuper des dates
    migration=$6
    
    # Impression des résultats
    sortie=""
    for (i=1;i<=2;i++) {
        sortie=sortie ADR[i] OFS
    }
    sortie=REGATE OFS SITE OFS sortie OFS CPV OFS NOM OFS migration
    print sortie
    
    
    # print "DEPLOIEMENT Postes Maîtres Colissimo Linux de " SITE
    # print "Depuis le stock COLIPOSTE FIL DE L'EAU préparer"
    # print "2 CLP10NF1J5 UC DELL OPTIPLEX CLP 3070 SFF"
    # print "selon la nouvelle procédure SOP_PRC_COL Production de poste maitre.docx disponible sur le serveur I&S (WIGNV1) dans Coliposte\Poste Maitre Linux\ "
    # print "CODE REGATE : " REGATE
    # print "Nom des postes : PM-" REGATE "-1 et PM-" REGATE "-2"
    # print ""
    # print "Après expédition du matériel le dossier devra être affecté à PLANIF_MET sans repasser par le CSV afin de permettre la planification de l'installation"
    # print ""
    # print "/!\\ Attention le poste doit être sur site le " migration
    # print "Coordonnées d'expédition :"
    # print "COLISSIMO " SITE
    # print "attn : " NOM
    # print "ADR " ADRESSE
    # for (i in ADR) {print ADR[i]}
    # print "AD1 " ADR1
    # print "AD2 " ADR2
    # print CPV
}