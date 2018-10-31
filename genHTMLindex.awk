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
# MODIF 16/03/2018 - 15:47:05 - prise en compte de l'UTF-8 et rajout de la date de génération dans le header
# MODIF 26/03/2018 - 17:02:50 - Affichage d'un logo en tête de chaque colonne dans la page générée
# MODIF 29/03/2018 - 16:20:59 - utilise un format plus convivial pour afficher la date de valeur des stats
# MODIF 06/04/2018 - 13:48:51 - externalise la création de l'entête dans le module inclus IShtmlInclude.awk et ajoute un accès au menu et à une page d'aide en haut de page afin d'être visible sur les petits écrans
# MODIF 09/04/2018 - 17:03:50 - externalise la création de l'entête de tableau html dans le module inclus IShtmlInclude.awk
# MODIF 13/04/2018 - 11:03:25 - regroupe dans une fonction toutes les parties récurrentes de la génération de la page d'index
# MODIF 04/05/2018 - 15:16:46 - Régénération depuis le repositiry github suite à conflit lors de la fusion des branches
# MODIF 12/10/2018 - 10:34:03 - réécriture du talon du tableau de manière à lier vers la page de suivi des projets

#
# génération de l'index de toutes les pages web générées
# entrée : fichier is-seuil.csv dont seuls les 1° et 3° champs nous intéressent
# 1 Produit
# 2 Seuil
# 3 Désignation

@include "IShtmlInclude.awk"

function iconebu(bu) # rent une chaine html affichant l'icône liée à la bu fournie en argument
{
    return "\t\t\t\t<th colspan=\"2\"><img style=\"border: 0px solid ; width: 64px;\" src=\"../webresources/" bu ".png\" alt=\"logo " bu "\"></th>"
}

function casetablo(item,lib,    templine) # remplit la case de tableau correspondant à l'item fourni en argument
{
    # templine=tabu(4) "<!-- function casetablo(" item "," lib ",    " templine ") -->\r\n"
    templine=templine tabu(5) "<td valign=\"top\"><!-- " item " -->\r\n"
    if (item) {
    templine=templine tabu(6) "<a href=\"" item ".png\">\r\n"
    templine=templine tabu(7) "<img style=\"border: 0px solid ; width: 64px; height: 48px;\" src=\"" item ".png\" alt=\"" item ".png\">\r\n"
    templine=templine tabu(6) "</a>\r\n"
    templine=templine tabu(5) "</td>\r\n"
    templine=templine tabu(5) "<td>\r\n"
    templine=templine tabu(6) "<a href=\"" item ".htm\">\r\n"
    templine=templine tabu(7) lib "\r\n"
    templine=templine tabu(6) "</a>\r\n"
    } else {
        templine=templine tabu(5) "</td>\r\n"
        templine=templine tabu(6) "<!-- aucune donnée " lib " -->\r\n"
        templine=templine tabu(5) "<td>\r\n"
    }
    templine=templine  tabu(5) "</td>\r\n"
    # templine=templine  tabu(4) "<!-- fin fonction -->\r\n"
    return templine
}

BEGIN {
    FS=";"

    ixcol=0
    ixchr=0
    ixshp=0

    if (statdate=="") {
        statdate=strftime("%d-%m-%Y ",systime())
    }

    split(statdate,jjmmaa,"-")

    # génération de la première partie de l'index, qui ne dépend pas des données à afficher
    # header html
    texte="Statistiques I&S par famille de produit au " jjmmaa[3] "/" jjmmaa[2] "/" jjmmaa[1]
    makehead("Index principal",texte,"genHTMLindex.awk","statistiques,flux,sorties,stock,i&s,liste,dates",texte,"http://quipo.alt","gilles.metais@alturing.eu")
    print tabu(2) "<div style=\"width:480px;margin:0px auto 0px auto;padding:20px 0px 0px 0px;\">"
    
    # header du tableau
    tcaption=htmllink("../index.html","Historique") "<b> " texte " </b>" htmllink("../webresources/aide.html","Aide") "<hr>"
    theader=iconebu("COL") "\r\n" "\t\t\t\t\t" iconebu("CHR") "\r\n" "\t\t\t\t\t" iconebu("SHP") 
    tfooter="\t<td colspan=\"6\" align=\"center\"><hr></td>\r\n" tabu(4) "</tr>\r\n"
    tfooter=tfooter tabu(4) "<tr>\t\n"
    tfooter=tfooter tabu(5) "<td colspan=\"2\" align=\"center\">" htmllink("../projets/","Projets") "</td>\r\n"
    tfooter=tfooter tabu(5) "<td colspan=\"2\" align=\"center\">"  htmllink("../","Index des Stats") "</td>\r\n"
    tfooter=tfooter tabu(5) "<td colspan=\"2\" align=\"center\">"  htmllink("alt-stock.csv","(c)Alturing") "</td>\r\n"
    # tfooter=tfooter "</tr>"
    tcolgroupstring=""
    thoptions=""
    inittableau(tcaption,theader,tfooter,tcolgroupstring,thoptions)
}

{ #MAIN
    # ventilation des données selont la BU dont elles relèvent
    if (NR >1) { # pas de génération de lien pour la ligne d'en-tête
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
END { # écriture du corps du tableau et du talon de page
    ixmax=ixcol
    if (ixchr > ixmax) ixmax=ixchr
    if (ixshp > ixmax) ixmax=ixshp	
    for (i=1;i <= ixmax;i++)
    {
        # implémenter l'écriture du tableau html de sortie
        # ligne=OFS col[i] OFS chr[i] OFS shp[i] OFS
        # début de ligne

        ligne=tabu(4) "<tr><!-- " col[i] " " chr[i] " " shp[i] " -->\r\n" # ligne purement informative afin de mieyx s'y retrouver dans le code html généré

        # colissimo
        ligne=ligne casetablo(col[i],collib[i])

        #chronopost
        ligne=ligne casetablo(chr[i],chrlib[i])

        #chronoship
        ligne=ligne casetablo(shp[i],shplib[i])

        # fin de ligne
        ligne=ligne tabu(4) "</tr>"

        print ligne
    }


    # le <tbody> correspondant a été préalablement produit par la fonction "inittableau()"
    print tabu(3) "</tbody>"
    print tabu(2) "</table>"
    print tabu(2) "</div>"
    # le <body> et le <html> correspondants ont été préalablement produit par la fonction "makehead()"
    print tabu(1) "</body>"
    print "</html>"
}
