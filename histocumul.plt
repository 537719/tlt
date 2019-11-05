# histocumul.plt
# CREE  23/09/2019  15:57 Création d'un histogramme montrant une barre par ligne de fichier comportant deux valeurs à cumuler.
set boxwidth 0.75
set datafile separator ";"
set style fill   solid 1.00 border lt -1
set key inside right top vertical Left reverse noenhanced autotitle columnhead nobox
set key invert samplen 4 spacing 1 width 0 height 0
set style increment default
set style histogram rowstacked title textcolor lt -1
set datafile missing '-'
set style data histograms
set xtics border in scale 0,0 nomirror rotate by -45  autojustify
set xtics  norangelimit
set xtics   ()
# set title "Répartition des déstockages s matériel neuf et reconditionné\nSeptembre 2019"
set title ARG4 . "\r\n" . ARG5 . ARG2 . " et "  . ARG3
set grid
set grid noxtics

set terminal png size 1024,768
set output "histo_" . ARG2 . "_" . ARG3 . ".png"

# # Les deux instructions sont équivalentes.
# plot "ventilNRan.csv" using 3:xtic(2) lc rgb "#009ADF", for [i=4:4] "" using i lc rgb "#0160A4"
# # La première à l'avantage de donner des codes couleurs plus lisibles mais le # les fait apparaître comme des commentaires par l'analyseur syntaxique
plot ARG1 using 3:xtic(2) lc rgb 39647, for [i=4:4] "" using i lc rgb 15132648
# La seconde donne des codes couleurs moins lisibles mais ne perturbe pas l'analyseur syntaxique
# NB les couleurs utilisées ne sont pas les mêmes dans les deux versions de la commande
