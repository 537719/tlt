#genericplot.plt
#autoformation à gnuplot
#15:31 lundi 2 mai 2016
# spex :
# - incidents : ligne pleine rouge sombre, libellé "incidents"
# - demandes : ligne pointillée rouge claire cumulée avec les incidents, libellé "demandes + incidents"
# - stock ok dispo : surface bleue marine, libellé "stock dispo"
# - livraisons attendues : surface bleue claire cumulée avec le stock ok dispo, sans le masquer, libellé "livraisons attendues + stock"
# - même échelle sur les deux axes Y
# - ligne horizontale entre les graduations primaires des deux axes
# - axe des abscisses gradué en "mm aa" sur 13 mois antérieurement à la dernière date d'abscisse
# - carré de légende superposé au graphique
# - titre du graphique donné par le nom du fichier
# MODIF 14:20 jeudi 12 mai 2016 transformation en script acceptant plusieurs sources différentes (au même format)
#                               au lieu d'avoir un lot de scripts différents mais quasi-identiques au nom du fichier de data près
# invocation par gnuplot -persist -c genericplot.plt pv.tab # ou autre fichier .tab
# MODIF 11:17 vendredi 13 mai 2016 affiche le niveau du seuil d'alerte 
# MODIF 14:17 mardi 17 mai 2016 format d'entrée aaaa-mm-jj au lieu de mm/aaaa
# MODIF 15:44 jeudi 19 mai 2016 adaptation des champs à la nouvelle structure des fichiers de données
# FINGERPRINT	incident	demande	RMA	destruction	undef	stock\TEexport_20160512.csv	OKdispo	OKreserve	SAV	Maintenance	Destruction	aLivrer	Seuil
# 2015-01-31	42	10	98	0	0	FINGERPRINT	393	0	0	0	0	0	170
# 2015-02-27	43	11	104	0	0	FINGERPRINT	460	0	0	0	0	0	170
# 2015-03-31	56	36	64	0	0	FINGERPRINT	445	0	0	2	0	0	170

# reste à faire : modifier éventuellement la palette de couleurs
clear
# efface le graphique actuel

#cd "/users/admin/documents/tlt/i&s"
# se positionne dans le dossier contenant les données

pwd
#C:\users\admin\documents\tlt\i&s
# vérifie que l'on s'est bien déplacé dans le bon dossier

set xdata time
# définit l'abscisse comme étant de type temporel

set timefmt "%Y-%m-%d"
# définit le format sous lequel sont écrit les données temporelles à lire

set xtics format "%m/%y"
# définit le format temporel d'affichage sur l'axe des x


set datafile separator "\t"
# définit le séparateur de champ dans le fichier d'entrée

# set xrange ["2015-04-30":"2016-05-12"] 
# set xrange ["2015-04-30":*] 
set xrange [ARG2:ARG3] 
#borne l'étendue temporelle des abscisses à afficher
# prévoir de calculer la borne inférieure comme étant antérieure de 13 mois à la borne supérieure
# MODIF 14:23 jeudi 12 mai 2016s données sont supposées être désormais bornées, donc on prend toute l'étendue en compte

set format y  "%.0f"      
set format y2 "%.0f"  
# set ytics format "%.0f"
# set y2tics format "%.0f"
# définit le format des axes verticaux comme étant entiers
# force l'affichage de l'axe de droite

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

set output filename . ".png"
# définit le le fichier de sortie

set title filename
# set title ARG2 . "-" . ARG3

plot ARG1 using 1:8:($$8+$$13) title columnhead(13) . "+" . columnhead(8) with filledcurves lt rgb "blue",ARG1 using 1:8 title columnhead(8) with filledcurves x1 lt rgb "dark-blue",  ARG1 using 1:2 title columnhead(2) with lines lt rgb "dark-red" lw 3, ARG1 using 1:($$2+$$3) title columnhead(3) . "+" . columnhead(2) with lines lt rgb "red" dashtype "." lw  2, ARG1 using 1:15 title columnhead(15) with lines lt rgb "green" dashtype "-" lw  2
# trace la ligne correspondant au 1° champ et une ligne correspondant à la somme des 1° et 2° champs
# ainsi qu'une surface correspondant au 6° champ et une autre à la somme des 6° et 11°
# lt = linetype
# lw = linewidth

