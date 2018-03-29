# genHTMLlink.awk
# 12:55 vendredi 20 mai 2016
# d'après genhtml.awk # 17:11 vendredi 6 mai 2016
# encapsulation dans une page html du fichier image donné en paramètre
# MODIF 12:55 vendredi 20 mai 2016
#   l'image est maintenant encapsulée sous forme de lien
#   lien en bas de page pour retour vers l'index
# MODIF 20/02/2018 - 10:24:51 ajoute un panneau avec l'image et la description du matériel concerné
# MODIF 20/02/2018 - 16:33:51 prend le fichier de seuil en tant que fichier d'entrée et le nom de l'item de stat en tant que variable
# BUG 20/02/2018 - 17:22:20 - correction d'une mauvaise génération de lien image (doubles quotes oubliées)
# MODIF 29/03/2018 - 16:20:59 - utilise un format plus convivial pour afficher la date de valeur des stats

BEGIN {
	OFS="@"
    FS=";"
    if (fichier !~ /./) { # vérification du fait qu'on a bien fourni un paramètre en entrée
        print "/!\\ erreur dans les paramètres d'entree"
    }
    if (moisfin !~ /./) { # si on ne fournit pas la date concernée, on considère que c'est celle du jour
        moisfin=strftime("%F",systime())
    }

    split(moisfin,jjmmaa,"-")

}
$1 ~ fichier {
    seuil=$2
    label=$3
}
{ #MAIN
	# nbarg=split(FILENAME,nomfich,".")
}
END {
	# print nbarg
	# for (i in nomfich) print i OFS nomfich[i]
	# print PWD
	# cmdstring="\"dir /d\""         ||
	# cmdstring="\"gnuplot " fichier ".plt" "\""
	# print cmdstring
	# system(cmdstring)
	# cmdstring |& getline results
	# print OFS results OFS
	print "<!DOCTYPE html>"
	print "<html lang=\"fr-FR\" class=\"subpage\">"
	print "\t<head>"
	print "\t\t<meta charset=\"UTF-8\" />"
	print "\t\t<title>Statistiques " fichier "</title>"
	print "\t\t<meta name=\"description\" content=\"stats \"" fichier "/>"
	print "\t\t<meta name=\"generator\" content=\"genHTMLlink.awk\" />"
	print "\t\t<meta name=\"date\" content=\"" strftime("%F %T",systime()) "\" />"
	# print "<link rel=\"shortcut icon\" href=\"/favicon.ico\" />"
	print "\t</head>"
	print "\t<body>"
	print "\t\t<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"960px\">"
	print "\t\t\t<caption><b>Statistiques " fichier " au " jjmmaa[3] "/" jjmmaa[2] "/" jjmmaa[1] "</b></caption>"
	print "\t\t\t<colgroup>"
	print "\t\t\t\t<col width=\"640px\">"
	print "\t\t\t\t<col width=\"320px\">"
	print "\t\t\t</colgroup>"
	print "\t\t\t<thead>"
	print "\t\t\t\t<tr>"
	print "\t\t\t\t\t<th>Historique 13 mois</th>"
	print "\t\t\t\t\t<th>Matériel concerné</th>"
	print "\t\t\t\t</tr>"
	print "\t\t\t</thead>"
	print "\t\t\t<tfoot>"
	print "\t\t\t\t<tr>"
	print "\t\t\t\t\t<td colspan=\"2\" align=\"center\"><hr><a href=\"index.html\">Retour au menu </a></td>"
	print "\t\t\t\t</tr>"
	print "\t\t\t</tfoot>"
	print "\t\t\t<tbody>"
	print "\t\t\t\t<tr>"
	print "\t\t\t\t\t<td width=\"640px\">"
	print "\t\t\t\t\t\t<a href=\"" fichier ".png\">"
	print "\t\t\t\t\t\t\t<img style=\"border: 0px solid ; width: 640px; height: 480px;\" src=\"" fichier ".png\" alt=\"Graphique de stat sur fichier\">"
	print "\t\t\t\t\t\t</a>"
	print "\t\t\t\t\t</td>"
	print "\t\t\t\t\t<td style=\"align: center;\">"
	print "\t\t\t\t\t\t<a href=\"../webresources/" fichier ".jpg\">"
	print "\t\t\t\t\t\t\t<img style=\"border: 0px solid ; width: 320px;\" src=\"../webresources/" fichier ".jpg\" alt=\"illustration de " fichier "\">"
	print "\t\t\t\t\t\t</a>"
	print "\t\t\t\t\t</td>"
	print "\t\t\t\t\t<td>"
	print "\t\t\t\t\t<a href=\"" fichier ".png\">"
	print "\t\t\t\t\t</a>"
	print "\t\t\t\t\t\t  <br>"
	print "\t\t\t\t\t</td>"
	print "\t\t\t\t</tr>"
	print "\t\t\t\t<tr>"
	print "\t\t\t\t\t<td><object type=\"text/plain\" data=\"" fichier ".txt \" style=\"overflow: hidden;\" border=\"0\" height=\"100\" width=\"640\"></object><br>"
	print "\t\t\t\t\t</td>"
	print "\t\t\t\t\t<td><object type=\"text/plain\" data=\"../webresources/" fichier ".txt \" style=\"overflow: hidden;\" border=\"0\" height=\"100\" width=\"640\"></object><br>"
	print "\t\t\t\t\t</td>"
	print "\t\t\t\t</tr>"
	print "\t\t\t</tbody>"
	print "\t\t</table>"
	# print "\t\t<hr><a href=\"index.html\">Retour au menu </a>"
	print "\t</body>"
    print "</html>"
    
    # print OFS "fichier " fichier OFS "nomfich " fichier OFS "seuil " seuil OFS "label " label OFS
}