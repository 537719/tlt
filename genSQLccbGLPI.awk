# genSQLccbGLPI.awk
# 13/04/2018 - 14:47:22 version initiale :
#   parcourt un fichier des produits expédiés par I&S afin d'en extraire une requête MySQL
#   permettant de retrouver le centre de coût et le bénéficiaire du matériel
# 02/07/2018 - 16:01:09 : ajoute des meta informations sur les conditions de génération du fichier de sortie

# usage :
# gawk -f genSQLccbGLPI.awk nom_de_fichier.csv > nomderequete.SQL
# puis exécution de la requête sql via, par exemple, HeidiSQL
# prévoir ensuite de croiser les résultats avec le fichier d'entrée afin de détecter les imputations non valides

# filtre de manière à ne prendre en considération que les dossiers correspondant aux critères suivants :
# - UC fixe ou PC portable Chronopost non shipping
# - neuf ou reconditionné mais entré en stock après le 01/10/2016
# - sorti sur incident ou demande uniquement
# - sorti dans le cadre d'un dossier GLPI

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

BEGIN {
    scriptname="genSQLccbGLPI.awk"
    FS=";"
    OFS=","
    delete occurences # initialisation à vide du tableau de comptage de occurences des numéros de dossiers sélectionnés
    un=1 # constante programme
    nbdossiers=0 # initialisation du nombre de dossiers concernés
    jjmmaaaa="%d/%m/%Y"
    jourdate=strftime(jjmmaa,systime())
    
    datemax=mktime("1970 01 01 00 00 00")
    datemin=mktime("2038 01 19 03 14 07")
    hzero="00 00 00" # pattern pour la conversion date nombre
    
}

BEGINFILE {
    if (filestring) {
        filestring=filestring ", " FILENAME
    } else {
        filestring = FILENAME
    }
}

$1 ~ /[0-9]{10}/ && $6 ~ /^CHR1[0-1].[^S][^0|^Z]..$/ && $2 ~ /P[2-4]/ && $19>"TE1610000000" { #MAIN
# Explication de l'expression régulière :
#   $1 ~ /[0-9]{10}/ => premier champ contient un numéro de dossier GLPI (peut être constitué d'un mélange de numéro et de texte
#   $6 ~ /^CHR1[0-1].[^S][^0|^Z]..$/ => la référence de l'article porte sur du matériel CHR (uc ou pc portable), neuf ou reconditionné, pas shipping, pas "spécial (Z)" ni d'une référence trop ancienne pour être dans le scope (0)
#   $2 ~ /P[2-4]/ => sorti sur incicent (p2) ou demande (p4) mais pas sur RMA ou destruction (p5). P3 (demande shipping) toléré au titre d'erreur de saisie
#   $19>"TE1610000000" => Entrée en stock postérieure au 01/10/2016 - des entrées de matériel reconditionné après cette date seront néanmoins prises en compte même si hors scope

    designation=$7

    switch (designation)  # pour exclure les HP RP5700/RP5800 et Thinkpad T410 à T440 qui auraient pu passer le filtre de l'IR
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
        # ajustement de la fourchette de dates
        champdate=8
        if ($champdate !~ /\//) champdate=4 # compense les quelques cas d'absence de date de BL en prenant à la place la date de création
        split($champdate,adateevent,/\/|\:| /) # extrait les éléments de date/heure en tenant compte du fait qu'on a deux types de séparateurs différents pour la date et l'heure plus un autre entre la date et l'heure
        datestring=adateevent[3] " " adateevent[2] " " adateevent[1] " " adateevent[4] " " adateevent[5] " " adateevent[6] " " hzero " " hzero
        #deux fois hzero car 1°) ça ne gêne pas et 2°) dans un cas on peut avoir une date-heure et dans l'autre non donc il faut la rajouter 
        datenum=mktime(datestring) 
        if (datenum>0) { #sinon, erreur de date
            if (datenum>datemax) datemax=datenum
            if (datenum<datemin) datemin=datenum
        }
        
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
        # occurences[dossier]++ # il est luxueux de compter, une simple validation de présence aurait suffit
        # occurences[dossier]=1 # gain négligeable (1 pour mille) par rapport à l'incrémentation
        occurences[dossier]=un # gain perceptible (5 pour mille) par rapport à l'incrémentation
     }
}

END {
    for (i in occurences) {
        nbdossiers++ # comptage du nombre de résultats
    }
    for (i in errdossier) {
        nberreurs++ # comptage du nombre d'erreurs
    }
        # print "Date minimale " strftime("%F",datemin)
        # print "Date maximale " strftime("%F",datemax)
    print "-- Extraction des centres de coût et bénéficiaire des " nbdossiers " dossiers GLPI ayant fait l'objet d'un déstockage d'UC ou portable immobilisé par Chronopost"
    print "-- entre le " strftime(jjmmaaaa,datemin) " et le " strftime(jjmmaaaa,datemax)
    if (filestring ~ /, /) {
        filestring= "des fichiers " filestring
    } else {
        filestring= "du fichier " filestring
    }
    print "-- généré par le script " scriptname " le " strftime(jjmmaaaa,systime()) " par traitement " filestring
    print "--"
    if (nberreurs > 0) {
        for (i in errdossier) {
            print "-- erreur de numéro de dossier : " i
        }
    }
    print "SELECT       glpi_groups_tickets.tickets_id AS 'NoDossier',"
    print "             glpi_plugin_shipping_clients.num_contract AS 'Centre_de_Cout', "
    print "             glpi_users.firstname AS 'Prenom', "
    print "             glpi_users.realname AS 'Nom'"
    print "    FROM     glpi_groups_tickets,  glpi_plugin_shipping_clients, glpi_tickets_users,  glpi_users"
    print "    WHERE    glpi_tickets_users.type=1"
    print "    AND      glpi_groups_tickets.type=1"
    print "    AND      glpi_plugin_shipping_clients.groups_id=glpi_groups_tickets.groups_id"
    print "    AND      glpi_users.id=glpi_tickets_users.users_id"
    print "    AND      glpi_groups_tickets.tickets_id=glpi_tickets_users.tickets_id"
    print "    AND"
    print "             glpi_tickets_users.tickets_id IN ("
    for (i in occurences) {
        print "               " i OFS
    }
    print "               0"
    print "    )"
    print "    AND"
    print "             glpi_groups_tickets.tickets_id IN ("
    for (i in occurences) {
        print "               " i OFS
    }
    print "               0"
    print "    )"
    print "    GROUP BY glpi_groups_tickets.tickets_id"
    print "    LIMIT "nbdossiers
    print ";"
}