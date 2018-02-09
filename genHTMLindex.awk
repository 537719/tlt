# genHTMLindex.awk
# 12:56 vendredi 20 mai 2016
# d'après genHTMLlink.awk 12:55 vendredi 20 mai 2016
# MODIF 15:05 vendredi 1 juillet 2016 ajoute le nom du générateur dans le header htmp
# MODIF 15:05 vendredi 1 juillet 2016 Rend cliquable l'icone de chaque ligne d'index
# MODIF 14:35 lundi 9 janvier 2017 réécriture presque totale
# 	sortie sous la forme de page web 3 colonnes (une par ligne de produits : COLissimo / CHRonopost / chronoSHiP) au lieu d'une seule
# BUG 09/02/2018 - 10:58:06 correction d'erreurs de calage des colonnes dans le code html généré
# MODIF 09/02/2018 - 12:57:15 ajout de commentaires relatifs aux données contenues dans le code html généré
# MODIF 09/02/2018 - 13:34:56 correction de l'indentation du code html généré et ajout d'autre commentaires
#
# génération de l'index de toutes les pages web générées
# entrée : fichier is-seuil.csv dont seuls les 1° et 3° champs nous intéressent
# 1 Produit
# 2 Seuil
# 3 Désignation

BEGIN {
	FS=";"
	
	ixcol=0
	ixchr=0
	ixshp=0
	
	if (statdate=="") {
		statdate=strftime("%d %m %Y ",systime())
	}
	
	# génération de la première partie de l'index
	print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2 Final//EN\">"
	print "<html>"
	print " <head>"
	# print "<meta charset=\"utf-8\" />"
	print "  <title>Statistiques I&S par famille de produit</title>"
	print "  <meta name=\"description\" content=\"statsindex\"/>"
	print "  <meta name=\"generator\" content=\"genHTMLindex.awk\" />"
	print " </head>"
	print " <body>"
	print "  <div style=\"width:480px;margin:0px auto 0px auto;padding:20px 0px 0px 0px;\">"
	print "   <table><!--Statistiques I&S par famille de produit au " statdate " -->"
	print "    <tr><th colspan=\"6\">Statistiques I&S par famille de produit au " statdate " </th></tr>"
	print "    <tr><th colspan=\"6\"><hr></th></tr>"
}

{ #MAIN
	if (NR >1) { # pas de génération de lien pour la ligne d'en-tête
		# print "<tr><td valign=\"top\"><a href=\""
		# print $1 ".png"
		# print "\">"
		# print "<img style=\"border: 0px solid ; width: 64px; height: 48px;\""
		# print "<img src=\"" $1 ".png\""
		# print "alt=\"[IMG]\"></a></td><td><a href=\""
		# print $1 ".htm"
		# print "\">"
		# print $3
		# print "</a></td></tr>"
		BU=$3
		switch (BU) {
			case /Colissimo/ :
			{
				colonne="COL"
				ixcol++
				col[ixcol]=$1
				collib[ixcol]=$3
				break
			}
			case /Chronopost/ :
			{
				colonne="CHR"
				ixchr++
				chr[ixchr]=$1
				chrlib[ixchr]=$3
				break
			}
			case /Chronoship/ :
			{
				colonne="SHP"
				ixshp++
				shp[ixshp]=$1
				shplib[ixshp]=$3
				break
			}
		}
	}
}
END {
	ixmax=ixcol
	if (ixchr > ixmax) ixmax=ixchr
	if (ixshp > ixmax) ixmax=ixshp	
	for (i=1;i <= ixmax;i++)
	{
		# implémenter l'écriture du tableau html de sortie
		# ligne=OFS col[i] OFS chr[i] OFS shp[i] OFS
		# début de ligne
		
		if (col[i]=="") {
			colpng=""
			colhtm=""
		} else {
			colpng=col[i] ".png"
			colhtm=col[i] ".htm"
		}
		if (chr[i]=="") {
			chrpng=""
			chrhtm=""
		} else {
			chrpng=chr[i] ".png"
			chrhtm=chr[i] ".htm"
		}
		if (shp[i]=="") {
			shppng=""
			shphtm=""
		} else {
			shppng=shp[i] ".png"
			shphtm=shp[i] ".htm"
		}
		
		ligne="    <tr><!-- " col[i] " " chr[i] " " shp[i] " -->\r\n"
		
		# colissimo
		ligne=ligne "     <td valign=\"top\"><!-- " col[i] " -->\r\n"
		if (colpng) {
		ligne=ligne "      <a href=\"" colpng "\">\r\n"
		ligne=ligne "       <img style=\"border: 0px solid ; width: 64px; height: 48px;\" src=\"" colpng "\" alt=\"" colpng "\">\r\n"
		ligne=ligne "      </a>\r\n"
		ligne=ligne "     </td>\r\n"
		ligne=ligne "     <td>\r\n"
		ligne=ligne "      <a href=\"" colhtm "\">\r\n"
		ligne=ligne "       " collib[i] "\r\n"
		ligne=ligne "      </a>\r\n"
		} else {
            ligne=ligne "     </td>\r\n"
            ligne=ligne "     <td>\r\n"
            ligne=ligne "      <!-- aucune donnée colissimo -->\r\n"
        }
		ligne=ligne "     </td>\r\n"
		
		#chronopost
		ligne=ligne "     <td valign=\"top\"><!-- " chr[i] " -->\r\n"
		if (chrpng) {
		ligne=ligne "      <a href=\"" chrpng "\">\r\n"
		ligne=ligne "       <img style=\"border: 0px solid ; width: 64px; height: 48px;\" src=\"" chrpng "\" alt=\"" chrpng "\">\r\n"
		ligne=ligne "      </a>\r\n"
		ligne=ligne "     </td>\r\n"
		ligne=ligne "     <td>\r\n"
		ligne=ligne "      <a href=\"" chrhtm "\">\r\n"
		ligne=ligne "       " chrlib[i] "\r\n"
		ligne=ligne "      </a>\r\n"
		} else {
            ligne=ligne "     </td>\r\n"
            ligne=ligne "     <td>\r\n"
            ligne=ligne "      <!-- aucune donnée chronopost -->\r\n"
        }
		ligne=ligne "     </td>\r\n"
		
		#chronoship
		ligne=ligne "     <td valign=\"top\"><!-- " shp[i] " -->\r\n"
		if (shppng) {
		ligne=ligne "      <a href=\"" shppng "\">\r\n"
		ligne=ligne "       <img style=\"border: 0px solid ; width: 64px; height: 48px;\" src=\"" shppng "\" alt=\"" shppng "\">\r\n"
		ligne=ligne "      </a>\r\n"
		ligne=ligne "     </td>\r\n"
		ligne=ligne "     <td>\r\n"
		ligne=ligne "      <a href=\"" shphtm "\">\r\n"
		ligne=ligne "       " shplib[i] "\r\n"
		ligne=ligne "      </a>\r\n"
		} else {
            ligne=ligne "     </td>\r\n"
            ligne=ligne "     <td>\r\n"
            ligne=ligne "      <!-- aucune donnée chronoship -->\r\n"
        }
		ligne=ligne "     </td>\r\n"
		
		# fin de ligne
		ligne=ligne "    </tr>"
		
		print ligne
	}
	
	
	print "    <tr><th colspan=\"6\"><hr></th></tr>"
	print "    <tr><th colspan=\"6\">"
	print "     <a href=\"" "..\\" "\">" "<!-- retour à l'index -->"
	print "      Index des Stats"
    print "     </a>"
    print "    </th></tr>"
	print "   </table>"
	print "  </div>"
	# print ""
	print " </body>"
	print "</html>"
}
