# statchampscsv.awk
# cree  04/12/2018 - 16:22:52 produit des stats sur les champs du fichier csv fourni en param

# ATTENTION le fichier d'entrée doit être filtré afin que les caractères accentués soient manipulables
# typiquement : cat [fichier].csv |iconv -f CP1250 -t UTF-8 |gawk -f statchampscsv.awk

function pourcent(float)    # retourne le sprint du float sous la forme d'un pourcentage à deux décimales
{
    return sprintf("%3i%%",((0+float)*100/nbrecords)+0.5) # attention nbrecords est une variable GLOBALE
}
BEGIN {
    FS=";"
    OFS=" "
}

NR==1 { # traitement de la ligne d'en-tête
    if ($1 !~ /[^0-9][A-z]+$/) { # 1° champ ne commence pas par un chiffre puis ne contient que des lettres
        print "ERREUR : Manque l'intitulé des champs"
        exit 1
    }
    nbchamps=NF # détermine le nombre de champs du fichier
    gsub(/ /,"_") # remplace tous les espaces par des _
    gsub(/.\251/,"e") # 251 = conversion en octal de 169 en décimal, code ascii du é - le . avant le \251 est là parce que ce caractère est codé sur 2 digits
    for (i=1;i<=NF;i++) {    # détermine les noms des champs
        entete[i]=$i
        if ($i !~ /./) { # cas particulier des champs dont l'en-tête est vide
            entete[i] = "champ_" i
        }
        longmax[i]=0
        longmin[i]=999
    }
    next
}

NR>1 {  # traitement des données
    
    for (i=1;i<=NF;i++) {
        li=length($i)
        long[i] = long[i]+li
        if (li) {
            if (li>longmax[i]) longmax[i]=li
            if (li<longmin[i]) longmin[i]=li
        }
        
        switch($i) { # détermination du type de champ
            case /^[0-9]+$/ :
            {
            # print NR,i,"entier"
                entier[i]++
                break
            }
            
            case /^[0-9]*\.[0-9]*$/ :
            {
            # print NR,i,"float"
                float[i]++
                break
            }
            
            case /^[0-9]+[-|\/][0-9]+[-|\/][0-9]+ +[0-9]+:[0-9]+:*[0-9]*$/ :
            {
            # print NR,i,"dateheure"
                dateheure[i]++
                break
            }
            
            case /^[0-9]+:[0-9]+:*[0-9]*$/ :
            {
            # print NR,i,"heure"
                heure[i]++
                break
            }
            
            case /^[0-9| |_]+[-|\/][0-9| |_]+[-|\/][0-9| |_]+*/ :
            {
            # print NR,i,"date"
                date[i]++
                break
            }
            
            default :
            {
                if (li) {
                # print NR,i,"texte"
                    text[i]++
                } else {
                # print NR,i,"void"
                    void[i]++
                }
            }
        }
    }
}

END {   #   Restitution des résultats
    nbrecords=NR-1 # -1 à cause de la ligne d'en-tête
    for (i in entete) {
        delete taux
        
        # remplissage de la table d'estimation du type de champ
        # le % de données de chaque type est concaténé au nom du type
        taux["entier"]=pourcent(entier[i]) "entier"
        taux["float"]=pourcent(float[i]) "float"
        taux["dateheure"]=pourcent(dateheure[i]) "horodate"
        taux["date"]=pourcent(date[i]) "date"
        taux["heure"]=pourcent(heure[i]) "heure"
        taux["texte"]=pourcent(text[i]) "texte"
        # puis trié : le dernier de la liste est donc le bon
        asort(taux)
        split(taux[6],taux6,"%")
        split(taux[5],taux5,"%")
        # print taux6[1],taux5[1]
        qualite=taux6[1]/(taux6[1]+taux5[1])
        # épuré
        gsub(/.*%/,"",taux[6])
        # et mis en forme
        taux[6]=toupper(sprintf("%8s",taux[6]))
        switch (taux[6]) {
            case /ENTIER/ :
            {
                 px[i]=10*longmax[i]
               class[i]="num"
                break
            }
           case /DATE|HEURE/ :
            {
                px[i]=8*long[i]/(NR-1-void[i])
                class[i]="num"
                break
            }
            case /FLOAT/ :
            {
                px[i]=9*longmax[i]
                class[i]="num"
                break
            }
            case /TEXT/ :
            {
                px[i]=10*longmax[i]
                class[i]="txt"
                break
            }
        }
        if (px[i]>240) px[i]=240
        
        # récap des données
        print sprintf("%2d",i) OFS "min:" sprintf("%3s",longmin[i]) OFS "moy:" sprintf("%6.2f",long[i]/(NR-1-void[i])) OFS "max:" sprintf("%3d",longmax[i]) OFS "int:" pourcent(entier[i]) OFS "float:" pourcent(float[i]) OFS "dateheure:" pourcent(dateheure[i]) OFS "heure:" pourcent(heure[i]) OFS "date:" pourcent(date[i]) OFS "texte:" pourcent(text[i]) OFS "vide:" pourcent(void[i]) OFS taux[6] OFS sprintf("%3i%%",(qualite*100)+.5) OFS entete[i] # car 6 types de champ à analyser
    }        
        # la partie suivante relève en fait du script csv2xsl.awk
        # print "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"
        # print "<xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">"
        # print "	<xsl:template match=\"/\">"
        # print "		<html>"
        # print "			<head>"
        # print "				<title>Stock Alturing par famille de produits - Tri par centre de coût croissant</title>"
        # print "			</head>"
        # print "			<body>"
        # print "					<div id=\"titre\">"
        # print "				<table border=\"3\"  cellspacing=\"4\" cellpadding=\"2\" align=\"center\">"
        # print "					<caption align=\"center\">"
        # print "						Tri par centre de coût croissant"
        # print "					</caption>"
        # print "					<colgroup>"
        # for (i in entete) {
            # print "\t\t\t\t\t\t<col style=\"width:" px[i] "px\"  />"
        # }
        # print "					</colgroup>"
        # print "					<tr>"
        # for (i in entete) { # écriture des lignes fixant la largeur des colonnes de titre
            # print "\t\t\t\t\t\t<th id=\"" entete[i] "\" abbr=\"" entete[i] "\">" gensub(/_/," ","g",entete[i]) "</th>"
        # }
        # print "					</tr>"
        # print "					</table>"
        # print "					</div>"
        # print "				<table border=\"3\"  cellspacing=\"4\" cellpadding=\"2\" align=\"center\">"
        # print "					<colgroup>"
        # for (i in entete) { # écriture des lignes fixant la largeur des colonnes de données
            # print "\t\t\t\t\t\t<col style=\"width:" px[i] "px\"  />"
        # }
        # print "					</colgroup>"
        # print "					<xsl:for-each select=\"fichier/enregistrement\">"
        # print "					<xsl:sort select=\"Centre_de_Cout\" order=\"ascending\" />"
        # print "						<tr>"
        # print "							<xsl:if test=\"position() mod 2 != 1\">"
        # print "								<xsl:attribute name=\"class\">pair"
        # print "								</xsl:attribute>"
        # print "							</xsl:if>"
        # print "							<xsl:if test=\"position() mod 2 != 0\">"
        # print "								<xsl:attribute name=\"class\">impair"
        # print "								</xsl:attribute>"
        # print "							</xsl:if>"
        # for (i in entete) { # écriture des lignes d'affichage des données
            # print "\t\t\t\t\t\t\t<td class=\"" class[i] "\"><xsl:value-of select=\"" entete[i] "\"/></td> # <!-- " longmax[i] " " long[i]/(NR-1-void[i]) " nombres de caractères max et moyen détectés dans les données -->"
        # }
        # print "						</tr>"
        # print "					</xsl:for-each>"
        # print "				</table>"
        # print "			</body>"
        # print "		</html>"
        # print "	</xsl:template>"
        # print "</xsl:stylesheet>       " 
        

}
