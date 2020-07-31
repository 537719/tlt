# genCumulaire.awk
#
# Usage : Depuis la ligne de commande
# gawk -f genCumulaire.awk [-v BU="xxx"] fichierdentree.csv > nomdescriptgnuplot.plt
# 
#
# Prend en entrée un fichier CSV de données et s'en sert pour générer un graphique en aires cumulées
# CREATION  30/01/2020  22:02 en tant que genplt.awk
# BUG           31/01/2020  23:01 dans le cas où l'on ne traitait pas le premier jeu de données, cumulait le jeu traité avec la première donnée du premier jeu
# MODIF      10:15 samedi 1 février 2020 script renommé en genCumulaire.awk et écriture des commentaires
# MODIF       22:19 samedi 1 février 2020 simplification de la logique de la boucle d'écriture du plot
# MODIF      En cours d'écriture : si pas de BU spécifiée, identifie les BU présente et fait une aire par BU au lieu d'une par produit de la BU spécifiée
# MODIF     16:41 mardi 4 février 2020 rajout de "ISI" en tant que pseudo-BU afin de pouvoir générer les stats d'incident de production I&S qui utilisent le même format de fichier mais avec la valeur ISI là ou l'on a la BU

# Exemple de format de fichier d'entrée
# Date;CHR Ecran;CHR Imprimante;CHR PC;COL Ecran;COL Imprimante;COL PC;Total
# 2018-11-30;93;87;372;4;37;11;2219
# 2018-12-10;91;84;367;7;37;10;2220
# 2019-02-14;313;93;495;5;25;13;2876
# 2019-03-29;340;80;452;4;36;11;2935

# Particularité : la distinction entre les jeux de données se fait sur la présence d'une chaine de 3 caractères suivie par un espace en tête de colonne.
# ATTENTION ! si un des textes passés en paramètre (titre1 ou titre2) contient un "û"  le texte est encapsulé par deux paires de double-quotes au lieu d'une
# Pas trouvé le moyen de résoudre ça autrement que par un SED en sortie (gensub ne fonctionne pas dans ce cas)

BEGIN {
    FS=";"
    OFS=";"
   # if (BU !~ /COL|TEL/ ) BU="CHR"
    # ^^ à supprimer, si pas d'indication de BU prendre tout et faire la ventilation selon le total des données de chaque BU
}

NR==1 && BU ~ /CHR|COL|TEL|ISI/ { # seule la ligne d'en-tête sert pour générer le script
    minind=NF
    maxind=0
    for (i=2;i<=NF;i++) {# détermination du range de colonnes à utiliser
        j=split($i,champ," ")
        if (j) {
            if (champ[1] == BU) {
                if (i > maxind) maxind=i
                if (i<minind) minind=i
            }
        }
    }

    {#   ce mode de définition des couleurs a été préféré parce qu'il permet définir  les mêmes que le choix automatique d'excel    
        couleur[1]="#5B9bD5" #  "light-blue"    # Câblage
        couleur[2]="#ED7D31"    # "orange"       # Divers
        couleur[3]="#A5A5A5"    #  "grey"           # Ecrans
        couleur[4]="#FFC000"    # "yellow"        # Imprimantes
        couleur[5]="#4472C4"    # "blue"            # PC
        couleur[6]="#70AD47"    # "green"          # Reseau
        couleur[7]="#255E91"    # "dark-blue"     # Serveurs
        couleur[8]="#9E480E"    # "dark-red"       # Shipping

        couleur[9]="#5B9bD5" #  "light-blue"    # Câblage
        couleur[10]="#ED7D31"    # "orange"       # Divers
        couleur[11]="#A5A5A5"    #  "grey"           # Ecrans
        couleur[12]="#FFC000"    # "yellow"        # Imprimantes
        couleur[13]="#4472C4"    # "blue"            # PC
        couleur[14]="#70AD47"    # "green"          # Reseau
        # # couleur[7]="#255E91"    # "dark-blue"     # Serveurs
        couleur[15]="#9E480E"    # "dark-red"       # Shipping

        couleur[16]="#5B9bD5" #  "light-blue"    # Câblage
        couleur[17]="#ED7D31"    # "orange"       # Divers
        couleur[18]="#A5A5A5"    #  "grey"           # Ecrans
        # couleur[4]="#FFC000"    # "yellow"        # Imprimantes
        couleur[19]="#4472C4"    # "blue"            # PC
        }
    
    # for (i in couleur) {
    # i=i+1-1 # astuce obligatoire sinon le calcul du max ne marche pas
    # if (i > maxind) maxind=i
    # if (i<minind) minind=i
    # # print i OFS j OFS minind OFS maxind
# }

    # print "champs " minind " à " maxind
    # maxind=maxind+1
    # minind=minind+1
    # print "indices " minind " à " maxind
    # print "#recopier dans gnuplot le texte entre les barres de signe #"
    print "######################################"
    print "# Génération du graphe en aires cumulées pour les données de " BU
    print "# script pour GnuPlot généré automatiquement par genCumulaire.awk le " strftime("%d/%m/%Y %T",systime())
    print "clear"
    print "set xdata time"
    print "set timefmt \"%Y-%m-%d\""
    print "set xtics format \"%m/%y\""
    print "set datafile separator \";\""
    print "set xrange [ARG2:ARG3]"
    print "# fournir la plage de dates en arguments afin de bien borner l'axe des abscisses"
    print "set format y  \"%.0f\""      
    print "set grid"
    print "set grid noxtics"
    print "set terminal png size 1024,768"
    print "filename=\"graphdata.csv\""
    print "set output ARG1 . \"13mois.png\""
    print "# ARG1 est le nom de la BU concerné"
    print "# Attention, séquence compliquée pour l'encodage du titre"
    print "# afin de gérer le cas des titres contenant à la fois une apostrophe (comme dans \"d'incidents\" et un & comme dans \"I&S\""
    print "# sachant que le caractère d'échappement est \\ et qu'il a un comportement selon que la chaîne est enclose entre '' ou \"\" et que son comportement pour & diffère de celui des autres caractères"
    print "set title \"" titre1 "\" . \"\\r\\n\" . '" titre2 "'"
    # Attention, pour qu'un \ et un & soient gérés correctement par gawk, il doivent lui être transmis de manière protégée soit sous la forme \\\&
    print "# l'apostrophe ne peut pas être échappée même dans une chaine entre double quotes"
    print "# l'& ne peut être échappé que dans une chaine entre simple quotes"

# On génère ici l'instruction principale du graphique
# une seule instruction "plot" étalée sur plusieurs lignes se terminant par le signe \ afin de ne faire qu'une seule commande
    print "plot \\"
    for (i=minind;i<=maxind;i++) {# pour le range de colonnes du jeu de données concernant la BU sélectionnée
            commande = "filename using 1:" minind
        if (i>minind) {
            commande = "filename using 1:($" minind # préciser à partir de quel champ on travaille
            for (j=minind+1;j<i;j++) {
                commande=commande "+$" j # cumuler toutes les données afin que les aires se superposent
            }
            
            commande= ", " commande "):($" minind
            for (j=minind+1;j<=i;j++) {
                commande=commande "+$" j #                cumuler toutes les données afin que les aires se superposent
            }
            commande = commande ") "
        }
        commande=commande " title columnhead(" i ") with filledcurves x1 lt rgb \"" couleur[i-1] "\""
        if (i<maxind) commande=commande " \\"
        print commande
    }
    print "\r\n"
    print "######################################"
}

NR==1 && BU !~ /./ { # pas d'indication de BU, on trace donc une aire par BU, cumulant toutes les données de chacune des BU
    for (i=2;i<=NF;i++) { # on parcourt tous les en-têtes de colonnes pour en extraire tous les noms de BUG
        j=split($i,champ," ")-1 # split ne donne pas le nombre de séparateurs mais me nombre d'éléments du tableau
        if (j) { # On a trouvé un espace, donc la BU est le premier mot
            BU=champ[1] # c'est plus simple à manipuler
            { # initialisation des index de bornes de la BU
                if (minind[BU]==0)  minind[BU]=NF
                if (maxind[BU]==0) maxind[BU]=i
            }
            if (i > maxind[BU]) maxind[BU]=i
            if (i < minind[BU]) minind[BU]=i
        }
        liste[BU]=j
        nom[i]=BU # chacun des champs est indexé en fonction de la BU à laquelle il appartient
        if (BU~/CHR/) couleur[i]="dark-blue"
        if (BU~/TEL|ALT/) couleur[i]="red"
        if (BU~/COL|CLP/) couleur[i]="dark-yellow"
    }
    # for (BU in liste) {
        # print BU,minind[BU],maxind[BU]
    # }
    
    { # génération de l'en-tête du script de graphique
        print "######################################"
        texte = "# Génération du graphe en aires cumulées pour les données de "
        for (BU in liste) {
            listeBU=listeBU BU " "
        }
        print texte listeBU
        print "# script pour GnuPlot généré automatiquement par genCumulaire.awk le " strftime("%d/%m/%Y %T",systime())
        print "clear"
        print "set xdata time"
        print "set timefmt \"%Y-%m-%d\""
        print "set xtics format \"%m/%y\""
        print "set datafile separator \";\""
        print "set xrange [ARG2:ARG3]"
        print "# fournir la plage de dates en arguments afin de bien borner l'axe des abscisses"
        print "set format y  \"%.0f\""      
        print "set grid"
        print "set grid noxtics"
        print "set terminal png size 1024,768"
        print "filename=\"graphdata.csv\""
        print "set output ARG1 . \"13mois.png\""
        print "# ARG1 est le préfixe nom de fichier de sortie"
        print "set title \"Couts de stockage hebdomadaire pour " listeBU  "\""
    }
# On génère ici l'instruction principale du graphique
# une seule instruction "plot" étalée sur plusieurs lignes se terminant par le signe \ afin de ne faire qu'une seule commande
    print "plot \\"
    for (BU in liste) {
        for (i=minind[BU];i<=maxind[BU];i++) {# pour le range de colonnes du jeu de données concernant la BU sélectionnée
                commande = "filename using 1:" minind[BU]
            if (i>minind[BU]) {
                commande = "filename using 1:($" minind[BU] # préciser à partir de quel champ on travaille
                for (j=minind[BU]+1;j<i;j++) {
                    commande=commande "+$" j # cumuler toutes les données afin que les aires se superposent
                }
                
                commande= ", " commande "):($" minind[BU]
                for (j=minind[BU]+1;j<=i;j++) {
                    commande=commande "+$" j #                cumuler toutes les données afin que les aires se superposent
                }
                commande = commande ") "
            }
            commande=commande " title word(columnhead($" j ") ,1) with filledcurves x1 lt rgb \"" couleur[i-1] "\""
            # commande=commande "  with filledcurves x1 lt rgb \"" couleur[i-1] "\""
            if (i<maxind[BU]) commande=commande " \\"
            print commande
        }
    }
    print "\r\n"
    print "######################################"

}