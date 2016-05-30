# genHTMLindex.awk
# 12:56 vendredi 20 mai 2016
# d'après genHTMLlink.awk 12:55 vendredi 20 mai 2016
#
# génération de l'index de toutes les pages web générées
# entrée : fichier is-seuil.csv dont seuls les 1° et 3° champs nous intéressent
# 1 Produit
# 2 Seuil
# 3 Désignation

BEGIN {
	FS=";"
	if (statdate=="") {
		statdate=strftime("%d %m %Y ",systime())
	}
	
	# génération de la première partie de l'index
	print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2 Final//EN\">"
	print "<html>"
	print " <head>"
	print "  <title>Statitstiques I&S par famille de produit</title>"
	print " </head>"
	print " <body>"
	print "<div style=\"width:480px;margin:0px auto 0px auto;padding:20px 0px 0px 0px;\">"
	print "  <table>"
	print "   <tr><th colspan=\"2\">Statistiques I&S par famille de produit au " statdate " </th></tr>"
	print "<tr><th colspan=\"2\"><hr></th></tr>"
}

{ #MAIN
	if (NR >1) { # pas de génération de lien pour la ligne d'en-tête
		print "<tr><td valign=\"top\"><img style=\"border: 0px solid ; width: 64px; height: 48px;\""
		print "<img src=\"" $1 ".png\""
		print "alt=\"[IMG]\"></td><td><a href=\""
		print $1 ".htm"
		print "\">"
		print $3
		print "</a></td></tr>"
	}
}
END {
	print "<tr><th colspan=\"2\"><hr></th></tr>"
	print "<tr><th colspan=\"2\">"
	print "<a href=\""
	print "..\\"
	print "\">"
	print "Index des Stats</a></th></tr>"
	print "</table>"
	print "</div>"
	print ""
	print "</body>"
	print "</html>"
}