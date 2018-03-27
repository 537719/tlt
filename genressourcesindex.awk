# genressourcesindex.awk
# 26/03/2018  11:49
# d'après genHTMLindex.awk version du 16/03/2018 - 15:47:05
# et genHTMLlink.awk version du 20/02/2018 - 17:22:20
# d'après genHTMLlink.awk 12:55 vendredi 20 mai 2016
#
# génération de l'index des produits monitorés
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
    print "  <title>Familles de produits monitorés chez chez I&S</title>"
    print "  <meta charset=\"UTF-8\" />"
    print "  <meta name=\"description\" content=\"statsindex\"/>"
    print "  <meta name=\"generator\" content=\"genHTMLindex.awk\" />"
    print "  <meta name=\"date\" content=\"" strftime("%F %T",systime()) "\" />"
    print " </head>"
    print " <body>"
    print "  <div style=\"width:480px;margin:0px auto 0px auto;padding:20px 0px 0px 0px;\">"
    print "   <table><!-- Liste des familles de produits monitorés chez chez I&S -->"
    print "    <tr><th colspan=\"3\">Liste des familles de produits monitorés chez chez I&S</th></tr>"
    print "    <tr><th colspan=\"3\"><hr></th></tr>"
}

{ #MAIN
    if (NR >1) { # pas de génération de lien pour la ligne d'en-tête
        fichier=$1
        BU=$3
        colonne=""
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
        print "      <tr>"
        if (colonne ~ /./) { # on ne sort rien pour les lignes "hors scope", qui correspondent à des produits non monitorés
            print "          <td style=\"align: center;\">"
            print "            <a href=\"../webresources/" fichier ".jpg\">"
            print "              <img style=\"border: 0px solid ; width: 64px;\" src=\"../webresources/" fichier ".jpg\" alt=\"illustration de " fichier "\">"
            print "            </a>"
            print "          </td>"
            print "          <td style=\"align: center;\">"
            print "              <img style=\"border: 0px solid ; width: 64px;\" src=\"../webresources/" colonne ".png\" alt=\"logo de " fichier "\">"
            print "          </td>"
            print "          <td><object type=\"text/plain\" data=\"../webresources/" fichier ".txt \" style=\"overflow: hidden;\" border=\"0\" height=\"100\" width=\"640\"></object><br>"
            print "          </td>"
            print "      </tr>"
        }
    }
}
END {
    print "    <tr><th colspan=\"3\"><hr></th></tr>"
    print "    <tr><th colspan=\"3\">"
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
