# genSQLddrGLPI.awk
# d'après genSQLccbGLPI.awk 18/07/2018 - 14:42:41
#   parcourt une liste de numéros de dossiers GLPI afin d'en extraire une requête MySQL
#   permettant de retrouver le demandeur du dossier GLPI
# CREE  31/10/2018 - 13:56:43 version initiale :

# usage :
# gawk -v outputfile="chemindufichierdesortie" -f genSQLbenGLPI.awk nom_de_fichier.csv > nomderequete.SQL
# puis exécution de la requête sql via, par exemple, une ligne de commande MySQL
# prévoir ensuite d'intégrer le fichier résultant dans une chaîne croisant le nom de dossier avec le nom du demandeur
# en pratique : invocation depuis le script projets.cmd


BEGIN {
    if (outputfile=="") {
        # la variable outputfile doit être définie sur la ligne de commande
        # elle sert à paramétrer la redirection de la sortie via l'instruction tee dans le script généré
        exit 1
        # saute directement à la section END
    }
    
    scriptname="genSQLbenGLPI.awk"
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

/NF/ > 1 { # Vérification de la cohérence du fichier d'entrée, qui ne doit être qu'une liste de numéros de dossiers
    nberreurs++
    errdossier[NR]="la ligne " NR " contient " NF " champs : "$0
    next
}

$0 !~ /[0-9]{10}/ { # Vérification de la cohérence du fichier d'entrée, qui ne doit être qu'une liste de numéros de dossiers
    nberreurs++
    errdossier[NR]="la ligne " NR " contient autre chose qu'un numéro de dossier GLPI : " $0
    next
}
{ #MAIN
    dossier=$1
    occurences[dossier]=un # gain perceptible (5 pour mille) par rapport à l'incrémentation
}

END {
    if (outputfile=="") {
        print "-- variable outputfile non définie sur la ligne de commande"
        exit 1
    }
    
    for (i in occurences) {
        nbdossiers++ # comptage du nombre de résultats
    }
    print "-- Extraction des centres des demandeurs des " nbdossiers " dossiers GLPI fournis en paramètres"
    print "-- généré par le script " scriptname " le " strftime(jjmmaaaa,systime()) " par traitement " filestring
    print "--"
    if (nberreurs > 0) {
        for (i in errdossier) {
            print "-- erreur de numéro de dossier : " errdossier[i]
        }
    }
    print "-- redirection de la sortie"
    print "tee " outputfile
    print "SELECT       glpi_groups_tickets.tickets_id AS 'NoDossier',"
    print "             CONCAT(glpi_users.realname,' ',glpi_users.firstname) AS 'Demandeur'"
    print "    FROM     glpi_groups_tickets,  glpi_tickets_users,  glpi_users"
    print "    WHERE    glpi_tickets_users.type=3 -- 3 = demandeur"
    print "    AND      glpi_groups_tickets.type=1"
    print "    AND      glpi_users.id=glpi_tickets_users.users_id"
    print "    AND      glpi_groups_tickets.tickets_id=glpi_tickets_users.tickets_id"
    print "    AND"
    print "             glpi_tickets_users.tickets_id IN ("
    for (i in occurences) {
        print "               " i OFS
    }
    print "               0"
    print "    )"
    print "    GROUP BY glpi_groups_tickets.tickets_id"
    print "    LIMIT " nbdossiers
    print ";"
    print "notee"
}