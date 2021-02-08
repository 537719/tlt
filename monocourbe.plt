#monocourbe.plt
# CREATION  19:19 19/12/2020 d'après stats.plt du 15:10 19/03/2020

clear
# efface le graphique actuel

pwd
#C:\users\admin\documents\tlt\i&s
# vérifie que l'on s'est bien déplacé dans le bon dossier

set xdata time
# définit l'abscisse comme étant de type temporel

set timefmt "%Y-%m-%d"
# définit le format sous lequel sont écrit les données temporelles à lire

set xtics format "%m/%Y"
# définit le format temporel d'affichage sur l'axe des x


# set datafile separator "\t"
set datafile separator ";"
# définit le séparateur de champ dans le fichier d'entrée

# set xrange [ARG2:ARG3] 
#borne l'étendue temporelle des abscisses à afficher
# prévoir de calculer la borne inférieure comme étant antérieure de 13 mois à la borne supérieure
# MODIF 14:23 jeudi 12 mai 2016s données sont supposées être désormais bornées, donc on prend toute l'étendue en compte
set autoscale xfixmin
set autoscale xfixmax
# MODIF 13:12 29/01/2021 'autoscale sur X permet d'éviter de fournir les bornes temporelles


# set format y  "%.0f"      
# set format y2 "%.0f"  
# set ytics format "%.0f"
# set y2tics format "%.0f"
# définit le format des axes verticaux comme étant entiers
# force l'affichage de l'axe de droite
set yrange [0:]

set grid
set grid noxtics
# force l'affichage d'une grille horizontale

# set terminal windows
set terminal png size 1024,768
# définit le format de sortie


# Récupération du nom de fichier à traiter
# ARG1 est le nom du fichier de data à traiter, fourni sur la ligne de commande comme premier argument après le nom du script à exécuter
# gnuplot -persist -c "genericplot.plt" ARG1 1.23 "This is a plot title"
dotpos=strstrt(ARG1,".") - 1
filename=substr(ARG1,1,dotpos)
subname=substr(ARG1,dotpos-2,dotpos)

# graphcolor= "#" . ARG4
graphcolor= "#000000" 

if (subname eq "CIL") {
    graphcolor= "#009ADF"
} 
if (subname eq "TIM") {
    graphcolor= "#C31625"
}
if (subname eq "S30") {
    graphcolor= "#F7901E"
}

if (filename eq "ada") {
    graphcolor= "#CC0000"
} 
if (filename eq "audit") {
    graphcolor= "#00CC00"
}
if (filename eq "hs") {
    graphcolor= "#0000CC"
}

if (filename eq "sorties") {
    graphcolor= "#CC0000"
} 
if (filename eq "dossiers") {
    graphcolor= "#0000CC"
}
if (filename eq "entrees") {
    graphcolor= "#CC00CC"
}


# set output subname . ".png"
set output filename . ".png"
# définit le le fichier de sortie

if (ARG5) {
    titre = ARG5
    set title titre  . "\r\n du " . ARG2 . " au " . ARG3
    # set title ARG2 . "-" . ARG3
} else {
    titre=ARG2
}

# plot ARG1 using 1:8:($$8+$$13) title columnhead(13) . "+" . columnhead(8) with filledcurves lt rgb "blue",ARG1 using 1:8 title columnhead(8) with filledcurves x1 lt rgb "dark-blue",  ARG1 using 1:2 title columnhead(2) with lines lt rgb "dark-red" lw 3, ARG1 using 1:($$2+$$3) title columnhead(3) . "+" . columnhead(2) with lines lt rgb "dark-red" dashtype "." lw  2, ARG1 using 1:15 title columnhead(15) with lines lt rgb "green" dashtype "-" lw  2
#plot ARG1 using 1:8:($8+$13) title columnhead(13) . "+" . columnhead(8) with filledcurves lt rgb "blue",ARG1 using 1:8 title columnhead(8) with filledcurves x1 lt rgb "dark-blue",  ARG1 using 1:2 title columnhead(2) with lines lt rgb "dark-red" lw 3, ARG1 using 1:($2+$3) title columnhead(3) . "+" . columnhead(2) with lines lt rgb "dark-red" dashtype "." lw  2, ARG1 using 1:15 title columnhead(15) with lines lt rgb "green" dashtype "-" lw  2
# plot ARG1 using 1:8:($8+$13) title columnhead(13) . "+" . columnhead(8) with filledcurves lt rgb "light-blue",ARG1 using 1:8 title columnhead(8) with filledcurves x1 lt rgb "dark-blue",  ARG1 using 1:2 title columnhead(2) with lines lt rgb "dark-red" lw 3, ARG1 using 1:($2+$3) title columnhead(3) . "+" . columnhead(2) with lines lt rgb "dark-red" dashtype "." lw  2, ARG1 using 1:15 title columnhead(15) with lines lt rgb "green" dashtype "-" lw  2
plot ARG1 using 1:2 title titre with lines lt rgb graphcolor lw 3
# trace la ligne correspondant au 1° champ et une ligne correspondant à la somme des 1° et 2° champs
# ainsi qu'une surface correspondant au 6° champ et une autre à la somme des 6° et 11°
# lt = linetype
# lw = linewidth

