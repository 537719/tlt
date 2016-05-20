# genHTMLlink.awk
# 12:55 vendredi 20 mai 2016
# d'après genhtml.awk # 17:11 vendredi 6 mai 2016
# encapsulation dans une page html du fichier image donné en paramètre
# MODIF 12:55 vendredi 20 mai 2016
#   l'image est maintenant encapsulée sous forme de lien
#   lien en bas de page pour retour vers l'index

BEGIN {
	OFS="@"
}
{ #MAIN
	nbarg=split(FILENAME,nomfich,".")

}
END {
	# print nbarg
	# for (i in nomfich) print i OFS nomfich[i]
	# print PWD
	# cmdstring="\"dir /d\""         ||
	# cmdstring="\"gnuplot " nomfich[1] ".plt" "\""
	# print cmdstring
	# system(cmdstring)
	# cmdstring |& getline results
	# print OFS results OFS
	print "<!DOCTYPE html>"
	print "<html lang=\"fr-FR\" class=\"subpage\">"
	print ""
	print "<head>"
	print "<meta charset=\"utf-8\" />"
	print "<title>Statistiques " nomfich[1] "</title>"
	print "<meta name=\"description\" content=\"stats\"/>"
	print "<meta name=\"generator\" content=\"genhtmllink.awk\" />"
	# print "<link rel=\"shortcut icon\" href=\"/favicon.ico\" />"
	print "</head>"
	print "<body>"
	print "<a href=\"" nomfich[1] ".png" "\">"
	print "<img style=\"border: 0px solid ; width: 640px; height: 480px;\""
	print "src=" nomfich[1] ".png" " alt=\"Graphique de stat sur " nomfich[1]   "\"/>"
	print "</a>"
	print "<br />"
	print "	<object width=\"640\" height=\"100\" type=\"text/plain\" data=\"" nomfich[1] ".txt \" border=\"0\"  style=\"overflow: hidden;\">"
	print "</object>"
	print "<br />"
	print "<hr><a href=\"index.html\">Retour au menu </a>"
	print "</body>"
}