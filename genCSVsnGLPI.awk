# genCSVsnGLPI.awk
# d'après genSQLccbGLPI.awk du 18/07/2018 - 14:42:41
#   parcourt un fichier des produits expédiés par I&S afin d'en extraire un fichier CSV listant le numéro de dossier, date d'envoi et numéro de série selon les critères suivants :
# filtre de manière à ne prendre en considération que les dossiers correspondant aux critères suivants :
# - UC fixe ou PC portable Chronopost non shipping
# - neuf ou reconditionné mais entré en stock après le 01/10/2016
# - sorti sur incident ou demande uniquement
# - sorti dans le cadre d'un dossier GLPI

# usage :
# gawk -f genCSVsnGLPI.awk nom_de_fichier.csv > nomdefichier.csv
# pour utilisation ultérieure par croisement sur le numéro de dossier avec une extraction glpi

# MODIF 31/10/2018 - 11:09:03 rajout de quelques contrôles de conformité du fichier lors de la lecture du premier enregistrement
# BUG   09/01/2019 - 11:29:16 suppression d'un point virgule en fin de champ lors de la sortie des enregistrements, ce qui fausait l'import ultérieur via sqlite


# structure des fichiers de données à traiter
# $1 GLPI
# $2 Priorité
# $3 Provenance
# $4 DateCréation
# $5 CentreCout
# $6 Reference
# $7 Description
# $8 Date BL
# $9 Dépot
# $10 sDepot
# $11 Num Serie
# $12 Nom Client L
# $13 Adr1 L
# $14 Adr2 L
# $15 Adr3 L
# $16 CP L
# $17 Dep
# $18 Ville L
# $19 Tagis
# $20 Societe L
# $21 NumeroOfl
# $22  Pays de destination

# MODIF 30/10/2018 - 11:46:30 rajoute comme condition que le numéro de série ne soit pas vide
# MODIF 30/10/2018 - 11:46:30 rajoute les en-êtes de champ

BEGIN {
    FS=";"
    OFS=";"
}
NR==1 { # Titre
    print $1 OFS $8 OFS $11
    if ($1 !~ /GLPI/) {
        print "la première ligne ne contient pas la description des champs"
        exit 1
    }
    if (NF !~ 22) {
        print "Ce cichier contient " NF " champs alors qu'on en attend 22"
        exit NF
    }
}
$1 ~ /[0-9]{10}/ && $6 ~ /^CHR1[0-1].[^S][^0|^Z]..$/ && $2 ~ /P[2-4]/ && $19>"TE1610000000" && $11 ~ /./ { #MAIN
# Explication de l'expression régulière :
#   $1 ~ /[0-9]{10}/ => premier champ contient un numéro de dossier GLPI (peut être constitué d'un mélange de numéro et de texte
#   $6 ~ /^CHR1[0-1].[^S][^0|^Z]..$/ => la référence de l'article porte sur du matériel CHR (uc ou pc portable), neuf ou reconditionné, pas shipping, pas "spécial (Z)" ni d'une référence trop ancienne pour être dans le scope (0)
#   $2 ~ /P[2-4]/ => sorti sur incicent (p2) ou demande (p4) mais pas sur RMA ou destruction (p5). P3 (demande shipping) toléré au titre d'erreur de saisie
#   $19>"TE1610000000" => Entrée en stock postérieure au 01/10/2016 - des entrées de matériel reconditionné après cette date seront néanmoins prises en compte même si hors scope

    designation=$7
    sn=$11

    switch (designation)  # pour exclure les HP RP5700/RP5800 et Thinkpad T410 à T440 qui auraient pu passer le filtre de l'ER
    {
        case /5[7|8]00/ : # HP RP5700/RP5800
        {
            sortir=0
            break
        }
        
        case /T4[1-4]0/ : # Thinkpad T410 à T440
        {
            sortir=0
            break
        }
        
        default :
        {
            sortir=1
        }
    }   #end switch
    if (sortir) {
        # ajustement des donnnées
        champdate=8
        if ($champdate !~ /\//) champdate=4 # compense les quelques cas d'absence de date de BL en prenant à la place la date de création
        if ($1 ~ /[^0-9]/) { # 5% plus rapide de n'appliquer le gensub que dans les cas nécessaires (cas des numéros de dossiers associés à du texte)
            dossier=gensub(/([0-9]{10})/,"\\1","1",$1)
            next
        } else {
            if ($1 ~ /[0-9]{11}/) { # détection de numéros de dossier comportant plus de 10 chiffres (erreur de saisie)
                errdossier[$1]++
            } else {
                dossier=$1
            }
        }
        print dossier OFS $champdate OFS sn 
     }
}

