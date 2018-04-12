# genHTMLlink.awk
# 12:55 vendredi 20 mai 2016
# d'après genhtml.awk # 17:11 vendredi 6 mai 2016
# encapsulation dans une page html du fichier image donné en paramètre
# MODIF 12:55 vendredi 20 mai 2016
#   l'image est maintenant encapsulée sous forme de lien
#   lien en bas de page pour retour vers l'index
# MODIF 20/02/2018 - 10:24:51 ajoute un panneau avec l'image et la description du matériel concerné
# MODIF 20/02/2018 - 16:33:51 prend le fichier de seuil en tant que fichier d'entrée et le nom de l'item de stat en tant que variable
# BUG   20/02/2018 - 17:22:20 - correction d'une mauvaise génération de lien image (doubles quotes oubliées)
# MODIF 29/03/2018 - 16:20:59 - utilise un format plus convivial pour afficher la date de valeur des stats
# MODIF 06/04/2018 - 13:48:51 - externalise la création de l'entête de la page HTML dans le module inclus IShtmlInclude.awk et ajoute un accès au menu et à une page d'aide en haut de page afin d'être visible sur les petits écrans
# MODIF 09/04/2018 - 11:30:36 - externalise la création de l'entête de tableau html dans le module inclus IShtmlInclude.awk 


@include "IShtmlInclude.awk"

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

    
    texte="Statistiques " fichier " au " jjmmaa[3] "/" jjmmaa[2] "/" jjmmaa[1]
    makehead(texte,texte,"genHTMLlink.awk","statistiques,flux,sorties,stock,i&s,liste,dates",texte,"http://quipo.alt","gilles.metais@alturing.eu")
    
    tcaption=htmllink("index.html","Menu") "<b> " texte " </b>" htmllink("../webresources/aide.html","Aide")
    theader="<th>Historique 13 mois</th>" "\r\n" "\t\t\t\t\t<th>Matériel concerné</th>"
    tfooter="\t<td colspan=\"2\" align=\"center\"><hr>" htmllink("index.html","Retour au menu") "</td>"
    tcolgroupstring="\t\t\t\t<col width=\"640px\">" "\r\n" "\t\t\t\t<col width=\"320px\">"
    thoptions="width=\"960px\""
    inittableau(tcaption,theader,tfooter,tcolgroupstring,thoptions)
    
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
    
    # le <tbody> correspondant a été préalablement produit par la fonction "inittableau()"
	print "\t\t\t</tbody>"
	print "\t\t</table>"
    # le <body> et le <html> correspondants ont été préalablement produit par la fonction "makehead()"
	print "\t</body>"
    print "</html>"
}