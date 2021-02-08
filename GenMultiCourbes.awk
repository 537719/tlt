# genMultiCourbes.awk
# CREATION  13:16 29/01/2021 d'après GenEmpilAire.awk du 15:52 25/01/2021 génération d'un graphique à lignes multiples à abscisse mensuelle 
# MODIF     18:24 29/01/2021 détermine le format temporel pour la génération du script gnuplot en fonction du format détecté dans le 1° champ de données

# Usage : Depuis la ligne de commande
# gawk -f genMultiCourbes.awk  fichierdentree.csv > nomdescriptgnuplot.plt

# Prend en entrée un fichier CSV de données et s'en sert pour générer un graphique à plusieurs lignes

# Exemple de format de fichier d'entrée
# Mois;TLD;HABILITATION;ACCES;DEMANDE;METIER;SHIPPING;Achat;Divers
# 2020-01;  1;  10;  19;  10;   4;  12;   49;  3
# 2020-02;  1;   6;  20;   4;   9;  17;   26;  6
# 2020-03;  2;   3;  17;  10;   2;  14;   22;  1

function modulo(a,n,     reste) { # retourne le reste de la division de a par b
    return a - ( int(a/n)*n)
}

BEGIN {
    FS=";"
    OFS=";"
    IGNORECASE=1
}

NR==1 {
    for (i=2;i<=NF;i++) { # à partir de 2 parce que le 1 c'est l'abscisse
    # détermination de la couleur à attribuer à la série
    # avec ce système on peut générer 18 couleurs distinctes ce qui est déjà beaucoup, plus serait inutile, graphique illisible

        j=int((i-2)/2) #transforme la série 123456789 en 001122334
        k=int((i-2)/3) #transforme la série 123456789 en 000111222
        
        # décalage afin de commencer la série avec des couleurs plus jolies
        ii=i+9
        jj=j+9
        kk=k+9

        # le choix de l'ordre d'utilisation des variables i j et k a été déterminé par l'expérience en fonction de la lisibilité
        signeR= (modulo(kk,3)-1)   # en fonction de la variable, rend la série -1 -1 -1 0 0 0 1 1 1
        signeV= (modulo(ii-1,3)-1) # en fonction de la variable, rend la série  0 -1 1 0 -1 1 0 -1 1 
        signeB= -(modulo(jj,3)-1)   # en fonction de la variable, rend la série -1 -1 0 0 1 1 -1 -1 0 0 1 1
        
        couleur[i]=sprintf("#%02X%02X%02X",127+127*signeR,127+127*signeV,127+127*signeB)
    }

}

NR >1 { # Détermination du format de dates
    n=split($1,tablo,"-") # on n'accepte que les dates linux, utilisant le - comme séparateur
    datespec=""
    for (i=1;i<=n;i++) {
        datespec=datespec " " tablo[i] 
    }
    for (i=n;i<6;i++) {
        datespec=datespec " 00"
    }
    if (strftime(mktime(datespec))>0) { format[NR]=n}
    # Si le premier champ contient une date valide au format aaaa ou aaaa-mm ou aaaa-mm-j
    # Alors l'engegistrement de l'array "format" indexé par le rang de la ligne traitée contient le nombre de segments  utilisés pour le format de date : 1 si format année, 2 si aaaa-mm et 3 si aaaa-mm-jj
    # sinon l'enregistrement n'est pas indexé 
    
}


END {
        { # détermination du format de date à utiliser pour la lecture des données à grapher
            for (i in format) {somme=somme+format[i]} 
            if (length(format) == 0) format[1]="-"
            moyenne=int((somme / length(format) + 0.5)) # on calcule et on arrondi la moyenne du nombre de segments moyens utilisés pour le format de date
            # length[array] donne le nombre d'enregistrements du tableau "array"
            switch(moyenne) {
                case 1 :
                {
                    timeformat="%Y"
                    break
                }
                case 2 :
                {
                    timeformat="%Y-%m"
                    break
                }
                case 3 :
                {
                    timeformat="%Y-%m-%d"
                    break
                }
                default :
                {
                    timeformat=""
                }
            }
        }
        { # génération de l'en-tête du script de graphique
            inputfile=PROCINFO["argv"][3]
            outputfile=gensub(/csv$/,"png",1,inputfile)
            print "######################################"
            print "# Génération du graphe en aires cumulées pour les données issues de " PROCINFO["argv"][3]
            print "# script pour GnuPlot généré automatiquement par " PROCINFO["argv"][2] " le " strftime("%d/%m/%Y %T",systime())
            print "clear"
            print "set xdata time"
            print "set timefmt \"" timeformat "\""
            print "set xtics format \"%m/%y\""
            print "set datafile separator \";\""
            # print "# set xrange [ARG2:ARG3] inutile grace aux deux instructions suivantes"
            print "set autoscale xfixmin"
            print "set autoscale xfixmax"
            print "# l'autoscale sur X évite de fournir la plage de dates en arguments afin de bien borner l'axe des abscisses"
            print "set format y  \"%.0f\""      
            print "set grid"
            print "set grid noxtics"
            print "set terminal png size 1024,768"
            print "filename=\"" PROCINFO["argv"][3] "\""
            print "set output \"" outputfile "\""
            print "# fournir un titre en argument"
            print "set title ARG1"
            print "set key top left opaque" 
            print "#légende en haut à gauche pour ne pas interférer avec les données les plus récentes"
            print "#si nécessaire rajouter au set key l'instruction : opaque"
        }
# On génère ici l'instruction principale du graphique
# une seule instruction "plot" étalée sur plusieurs lignes se terminant par le signe \ afin de ne faire qu'une seule commande
    {
    print "plot \\"
        for (i=2;i<=NF;i++) {
{
                if (i>2) {
                    commande= ", " 
                } else commande=""
                {
                    commande = commande "filename using 1:" i " title columnhead(" i ") with lines lw 3 lt rgb \"" couleur[i]  
                }
                if (i<NF) {
                    commande=commande "\"\\" 
                }
            }
            print commande
        }

    }
    print "\r\n"
    print "######################################"

}

