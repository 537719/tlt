# newgenHTMLlink.awk
# d'après genHTMLlink.awk du 13/04/2018 - 11:49:13 
# encapsulation dans une page html du fichier image de type PNG dont la racine du nom est prise dans le flot d'entrée
# L'usage normal de ce script est d'être invoqué par plotloopnew.cmd
# Différences avec genHTMLlink.awk :
#   On n'a plus besoin de travailler spécifiquement sur le fichier is-seuil.csv mais sur toute liste fournie dans le flot d'entrée
#   On ne travaille plus pour le seul argument fourni en paramètre mais mes arguments sont pris dans le flot d'entrée
#   Par voie de conséquence le contenu de l'ancienne section END est reporté dans la section BODY et redirigée vers un nom de fichier défini d'après le paramètre
#   Ce qui impose de compléter les routines définies dans IShtmlInclude de manière à gérer un paramètre supplémentaire, facultatif, de redirection de sortie

@include "IShtmlInclude.awk"

BEGIN {
	OFS="@"
    FS=";"
    # if (fichier !~ /./) { # vérification du fait qu'on a bien fourni un paramètre en entrée
        # print "/!\\ erreur dans les paramètres d'entree">>outfile
    # }
    if (moisfin !~ /./) { # si on ne fournit pas la date concernée, on considère que c'est celle du jour
        moisfin=strftime("%F",systime())
    }

    split(moisfin,jjmmaa,"-")

}
# $1 ~ fichier {
    # seuil=$2
    # label=$3
# }
{ #MAIN
	# nbarg=split(FILENAME,nomfich,".")
}
{  #BODY
    fichier = $1
    outfile = $1 ".htm"
    # outfile = "-"
    
    
    texte="Statistiques " fichier " au " jjmmaa[3] "/" jjmmaa[2] "/" jjmmaa[1]
    makehead(texte,texte,"genHTMLlink.awk","statistiques,flux,sorties,stock,i&s,liste,dates",texte,"http://quipo.alt","gilles.metais@alturing.eu"   ,outfile)
    
    tcaption=htmllink("index.html","Menu") "<b> " texte " </b>" htmllink("../webresources/aide.html","Aide") 
    theader="<th>Historique 13 mois</th>" "\r\n" "\t\t\t\t\t<th>Matériel concerné</th>"
    tfooter="\t<td colspan=\"2\" align=\"center\"><hr>" htmllink("index.html","Retour au menu") "</td>"
    tcolgroupstring="\t\t\t\t<col width=\"640px\">" "\r\n" "\t\t\t\t<col width=\"320px\">"
    thoptions="width=\"960px\""
    inittableau(tcaption,theader,tfooter,tcolgroupstring,thoptions  ,outfile)
    
    print tabu(4) "<tr>">>outfile
    print tabu(5) "<td width=\"640px\">">>outfile
    print tabu(6) "<a href=\"" fichier ".png\">">>outfile
    print tabu(7) "<img style=\"border: 0px solid ; width: 640px; height: 480px;\" src=\"" fichier ".png\" alt=\"Graphique de stat sur fichier\">">>outfile
    print tabu(6) "</a>">>outfile
    print tabu(5) "</td>">>outfile
    print tabu(5) "<td style=\"align: center;\">">>outfile
    print tabu(6) "<a href=\"../webresources/" fichier ".jpg\">">>outfile
    print tabu(7) "<img style=\"border: 0px solid ; width: 320px;\" src=\"../webresources/" fichier ".jpg\" alt=\"illustration de " fichier "\">">>outfile
    print tabu(6) "</a>">>outfile
    print tabu(5) "</td>">>outfile
    print tabu(5) "<td>">>outfile
    print tabu(6) "<a href=\"" fichier ".png\">">>outfile
    print tabu(6) "</a>">>outfile
    print tabu(6) "<br>">>outfile
    print tabu(5) "</td>">>outfile
    print tabu(4) "</tr>">>outfile
    print tabu(4) "<tr>">>outfile
    print tabu(5) "<td><object type=\"text/plain\" data=\"" fichier ".txt \" style=\"overflow: hidden;\" border=\"0\" height=\"100\" width=\"640\"></object><br>">>outfile
    print tabu(5) "</td>">>outfile
    print tabu(5) "<td><object type=\"text/plain\" data=\"../webresources/" fichier ".txt \" style=\"overflow: hidden;\" border=\"0\" height=\"100\" width=\"640\"></object><br>">>outfile
    print tabu(5) "</td>">>outfile
    print tabu(4) "</tr>">>outfile
    
    # le <tbody> correspondant a été préalablement produit par la fonction "inittableau()"
    print tabu(3) "</tbody>">>outfile
    print tabu(2) "</table>">>outfile
    # le <body> et le <html> correspondants ont été préalablement produit par la fonction "makehead()"
    print tabu(1) "</body>">>outfile
    print "</html>">>outfile
}