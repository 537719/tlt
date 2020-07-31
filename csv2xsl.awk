# csv2xsl.awk
# cree  06/12/2018 - 10:30:09   d'apr�s statchampscsv.awk cree  04/12/2018 - 16:22:52 
#                               produit la feuille de style xsl d'affichage des donn�es d'un fichier csv qui sera converti en xml
#                               le fichier r�sultant sera � dupliquer et modifier de mani�re � g�rer les tris croissant et d�croissant
#                               et ce autant de fois qu'il y a de champ (en adaptant le titre et le crit�re de tri � chaque fois)
# MODIF 07/12/2018 - 14:36:19   rajoute les stats sur les types de champs en commentaire en fin de sortie afin d'aider � d�coder de modifier le type le cas �ch�ant.
# MODIF 07/12/2018 - 14:36:19   modifie le calcul d'indicateur de qualit� afin qu'il porte sur toutes les donn�es non vide au lieu de comparer le plus fort � celui qui le suit
# MODIF 11:28 21/02/2019   assouplit les conditions de validit� de l'enregistrement de titre
# MODIF 17:18 20/02/2020   assouplit les motifs de d�tection des types num�riques (int et float) de mani�re � accepter les cadrages � droite (chiffres pr�c�d�s d'espaces)

# ATTENTION le fichier d'entr�e doit �tre filtr� afin que les caract�res accentu�s soient manipulables
# typiquement : cat [fichier].csv |iconv -f CP1250 -t UTF-8 |gawk -f statchampscsv.awk

function pourcent(float)    # retourne le sprint du float sous la forme d'un pourcentage � deux d�cimales
{
    return sprintf("%3i%%",((0+float)*100/nbrecords)+0.5) # attention nbrecords est une variable GLOBALE
}
BEGIN {
    FS=";"
    OFS=" "
    scriptname="csv2xsl.awk"
}

NR==1 { # traitement de la ligne d'en-t�te
    if ($1 !~ /[^0-9][A-z]+$/) if ($1 !~ /[0-9]{4}/) { # 1� champ ne commence pas par un chiffre puis ne contient que des lettres ET 1� champ n'est pas une ann�e
        print "ERREUR : Manque l'intitul� des champs " NR "@" $1 "@"
        exit 1
    }

    nbchamps=NF # d�termine le nombre de champs du fichier
    for (i=1;i<=NF;i++) {    # sauvegarde les noms des champs avec accents et espaces, pour affichage
        accent[i]=$i
    }
    gsub(/ /,"_") # remplace tous les espaces par des _
    gsub(/.\251/,"e") # 251 = conversion en octal de 169 en d�cimal, code ascii du � - le . avant le \251 est l� parce que ce caract�re est cod� sur 2 digits
    for (i=1;i<=NF;i++) {    # d�termine les noms des champs, sans accents ni espaces, pour traitement des donn�es
        entete[i]=$i
        if ($i !~ /./) { # cas particulier des champs dont l'en-t�te est vide
            entete[i] = "champ_" i
        }
        longmax[i]=0
        longmin[i]=999
    }
    next
}

NR>1 {  # traitement des donn�es
    
    for (i=1;i<=NF;i++) {
        li=length($i)
        long[i] = long[i]+li
        if (li) {
            if (li>longmax[i]) longmax[i]=li
            if (li<longmin[i]) longmin[i]=li
        }
        
        switch($i) { # d�termination du type de champ
            case /^ *[0-9]+$/ :
            {
            # print NR,i,"entier"
                entier[i]++
                break
            }
            
            case /^ *[0-9]*\.[0-9]*$/ :
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

END {   #   Restitution des r�sultats
    nbrecords=NR-1 # -1 � cause de la ligne d'en-t�te
    for (i in entete) { # d�termination du type et de la largeur de chaque champ
        delete taux
        
        # remplissage de la table d'estimation du type de champ
        # le % de donn�es de chaque type est concat�n� au nom du type
        taux["entier"]=pourcent(entier[i]) "entier"
        taux["float"]=pourcent(float[i]) "float"
        taux["dateheure"]=pourcent(dateheure[i]) "horodate"
        taux["date"]=pourcent(date[i]) "date"
        taux["heure"]=pourcent(heure[i]) "heure"
        taux["texte"]=pourcent(text[i]) "texte"
        # puis tri� : le dernier de la liste est donc le bon
        asort(taux)
        split(taux[6],taux6,"%")
        # split(taux[5],taux5,"%")
        # print taux6[1],taux5[1]
        qualite=taux6[1]/(NR-1-void[i])
        # �pur�
#        gsub(/.*%/,"",taux[6])
        # et mis en forme
        taux[6]=toupper(sprintf("%8s",taux[6]))
        switch (taux[6]) {
            # px = largeur en pixels du champ de tableau concern�
            # class = classe css � appliquer dans la feuille de style associ�e. Sert � d�terminer en particulier si la donn�e sera cadr�e � droite ou � gauche
            case /ENTIER/ :
            {
                 px[i]=10*longmax[i]
               # px[i]=9*long[i]/(NR-1-void[i])
                class[i]="num"
                break
            }
           case /DATE|HEURE/ :
            {
                px[i]=8*long[i]/(NR-1-void[i]) # test� pour les dates uniquement, pas trouv� de cas de dateheure ni heure � afficher
                class[i]="num"
                break
            }
            case /FLOAT/ :
            {
                px[i]=9*longmax[i] # pas test� car pas de donn�es correspondantes
                class[i]="num"
                break
            }
            case /TEXT/ :
            {
                px[i]=10*longmax[i]
                # px[i]=int(9*long[i]/(NR-1-void[i])+0.5) # pas pertinent
                class[i]="txt"
                break
            }
        }
        if (px[i]>240) px[i]=240 # born� � 240 maxi
        
        # r�cap des donn�es vestige de statchampscsv.awk # report� en fin de fichier
        # print sprintf("%2d",i) OFS "min:" sprintf("%3s",longmin[i]) OFS "moy:" sprintf("%6.2f",long[i]/(NR-1-void[i])) OFS "max:" sprintf("%3d",longmax[i]) OFS "int:" pourcent(entier[i]) OFS "float:" pourcent(float[i]) OFS "dateheure:" pourcent(dateheure[i]) OFS "heure:" pourcent(heure[i]) OFS "date:" pourcent(date[i]) OFS "texte:" pourcent(text[i]) OFS "vide:" pourcent(void[i]) OFS taux[6] OFS sprintf("%3i%%",(qualite*100)+.5) OFS entete[i] # car 6 types de champ � analyser
        
        if (FILENAME == "") {
            fichier= "fichier d'entr�e " FILENAME
        } else {
            fichier="flot d'entr�e"
        }
    }
    { # sortie des r�sultats
        print "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"
        print "<xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">"
        print "	<xsl:template match=\"/\">"
        print "		<html>"
        print "			<head>"
        print "				<title>#titredelapage# - Tri par #criteredetri# croissant</title><!-- modifier ici -->"
        print "			</head>"
        print "			<body>"
        print "					<div id=\"titre\">"
        print "				<table border=\"3\"  cellspacing=\"4\" cellpadding=\"2\" align=\"center\">"
        print "					<caption align=\"center\"><!-- modifier ici -->"
        print "						Tri par #criteredetri# croissant"
        print "					</caption>"
        print "					<colgroup>"
        for (i in entete) { # �criture des lignes fixant la largeur des colonnes de titre
            print "\t\t\t\t\t\t<col style=\"width:" px[i] "px\"  />"
        }
        print "					</colgroup>"
        print "					<tr>"
        for (i in entete) { # �criture des en-t�tes de colonnes
            print "\t\t\t\t\t\t<th id=\"" entete[i] "\" abbr=\"" entete[i] "\">" gensub(/_/," ","g",accent[i]) "</th>" # gensub reste n�cessire dans le cas des champs contenant d�j� des _
        }
        print "					</tr>"
        print "					</table>"
        print "					</div>"
        print "				<table border=\"3\"  cellspacing=\"4\" cellpadding=\"2\" align=\"center\">"
        print "					<colgroup>"
        for (i in entete) { # �criture des lignes fixant la largeur des colonnes de donn�es
            print "\t\t\t\t\t\t<col style=\"width:" px[i] "px\"  />"
        }
        print "					</colgroup>"
        print "					<xsl:for-each select=\"fichier/enregistrement\">"
        print "					<xsl:sort select=\"#nomduchamp#\" order=\"ascending\" /><!-- modifier ici -->"
        print "						<tr>"
        print "							<xsl:if test=\"position() mod 2 != 1\">"
        print "								<xsl:attribute name=\"class\">pair"
        print "								</xsl:attribute>"
        print "							</xsl:if>"
        print "							<xsl:if test=\"position() mod 2 != 0\">"
        print "								<xsl:attribute name=\"class\">impair"
        print "								</xsl:attribute>"
        print "							</xsl:if>"
        for (i in entete) { # �criture des lignes d'affichage des donn�es
            print "\t\t\t\t\t\t\t<td class=\"" class[i] "\"><xsl:value-of select=\"" entete[i] "\"/></td> " # <!-- " longmax[i] " " long[i]/(NR-1-void[i]) " nombres de caract�res max et moyen d�tect�s dans les donn�es -->"
        }
        print "						</tr>"
        print "					</xsl:for-each>"
        print "				</table>"
        print "			</body>"
        print "		</html>"
        print "	</xsl:template>"
        print "</xsl:stylesheet>"
        print "<!-- penser a dupliquer ce fichier pour tenir compte de l'ordre de tri , ligne xsl:sort -->"
        print "<!-- et a le multiplier autant de fois qu'il y a de champs soit : -->"
        for (i in entete) {
            print "\t<!-- " entete[i] " -->"
        }
        print "<!-- les lignes a modifier sont rep�r�es par le commentaire suivant : --> <!-- modifier ici -->"
        # r�cap des donn�es vestige de statchampscsv.awk
        for (i in entete) { # l'avant derni�re colonne donne un r�sultat erron�, � corriger
            print "<!-- " sprintf("%2d",i) OFS "min:" sprintf("%3s",longmin[i]) OFS "moy:" sprintf("%6.2f",long[i]/(NR-1-void[i])) OFS "max:" sprintf("%3d",longmax[i]) OFS "int:" pourcent(entier[i]) OFS "float:" pourcent(float[i]) OFS "dateheure:" pourcent(dateheure[i]) OFS "heure:" pourcent(heure[i]) OFS "date:" pourcent(date[i]) OFS "texte:" pourcent(text[i]) OFS "vide:" pourcent(void[i]) OFS taux[i] OFS sprintf("%3i%%",(qualite*100)+.5) OFS entete[i] " -->" # car 6 types de champ � analyser
        }
 
 print "<!-- creation par " scriptname " sur le " fichier " le " strftime("%c",systime()) " -->"
    }
}


